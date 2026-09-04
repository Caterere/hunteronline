class_name NenSkillTree
extends Node

# ==============================================================================
# HUNTER ONLINE — NEN SKILL TREE RUNTIME ENGINE
# ==============================================================================
# Sistema de autoridade central para a constelação de habilidades.
# Conectado ao SkillTreeDatabase (400+ nós, 10 regiões).
#
# FLUXO DE PROGRESSÃO:
# Level Up → +1 Skill Point → Investimento na Árvore
#                                  ↓
#                          Modificador Passivo
#                                  ↓
#                      PlayerData.active_modifiers
#                                  ↓
#                       Recálculo de Atributos
# ==============================================================================

signal skill_investida(node_id: String, novo_nivel: int)
signal pontos_alterados(pontos_disponiveis: int)

# ==============================================================================
# CATEGORIAS (PRESERVADAS PARA COMPATIBILIDADE CANÔNICA)
# ==============================================================================
enum Categoria {
	TEN = 0,
	ZETSU = 1,
	REN = 2,
	GYO = 3,
	EN = 4,
	KO = 5,
	RYU_OFENSIVO = 6,
	RYU_DEFENSIVO = 7,
	RYU_EQUILIBRADO = 8,
	SHU = 9,
	COMPORTAMENTAL = 10,
	SINERGIA = 11
}

enum TipoMod {
	FLAT = 0,
	PERCENTAGE = 1,
	MULTIPLICATIVE = 2
}

const SkillNodeDef = preload("res://scripts/systems/skill_tree/SkillTreeNodeData.gd")

# ==============================================================================
# ESTADO E BANCO DE DADOS
# ==============================================================================
var database: SkillTreeDatabase = null
var node_definitions: Dictionary = {} # StringName -> SkillTreeNodeData / SkillNodeDef
var node_levels: Dictionary = {}      # StringName / String -> int (rank)
var ryu_caminho: String = ""          # "", "ofensivo", "defensivo", "equilibrado"


# ==============================================================================
# CICLO DE VIDA (READY & SINCRONIZAÇÃO)
# ==============================================================================
func _ready() -> void:
	add_to_group("nen_skill_tree")
	_inicializar_banco()
	_inicializar_niveis()
	sincronizar_com_player_data()

	print("=================================")
	print("NEN SKILL TREE MOTOR ATIVO")
	print("Nós disponíveis na constelação: ", node_definitions.size())
	print("=================================")


func _inicializar_banco() -> void:
	database = SkillTreeDatabase.get_instance()
	node_definitions.clear()
	for nid in database.nodes.keys():
		var nd: SkillTreeNodeData = database.nodes[nid]
		node_definitions[String(nid)] = nd
		node_definitions[nid] = nd


func _inicializar_niveis() -> void:
	for nid in database.nodes.keys():
		var s_nid := String(nid)
		if not node_levels.has(s_nid) and not node_levels.has(nid):
			var def: SkillTreeNodeData = database.nodes[nid]
			node_levels[s_nid] = 1 if def.is_starting_node else 0
			if def.is_starting_node:
				node_levels[nid] = 1


func sincronizar_com_player_data() -> void:
	if PlayerData == null:
		return
	if not PlayerData.nen_skill_tree_progress.is_empty():
		for node_id in PlayerData.nen_skill_tree_progress.keys():
			var s_id := String(node_id)
			node_levels[s_id] = int(PlayerData.nen_skill_tree_progress[node_id])
	if not PlayerData.nen_ryu_caminho.is_empty():
		ryu_caminho = PlayerData.nen_ryu_caminho
	recalcular_todos_modificadores()


# ==============================================================================
# INVESTIMENTO DE PONTOS
# ==============================================================================
func investir_ponto(node_id: Variant) -> bool:
	var s_id := String(node_id)
	var sn_id := StringName(s_id)

	if not node_definitions.has(sn_id) and not node_definitions.has(s_id):
		push_warning("[NenSkillTree] Nó desconhecido: " + s_id)
		return false

	var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
	var nivel_atual: int = node_levels.get(s_id, node_levels.get(sn_id, 0))

	# 1. Verificar rank máximo
	if nivel_atual >= def.nivel_max:
		push_warning("[NenSkillTree] Nó já está no nível máximo: " + s_id)
		return false

	# 2. Verificar custo de pontos
	var custo := def.custo_pontos
	if PlayerData == null or PlayerData.nen_skill_points < custo:
		push_warning("[NenSkillTree] Pontos insuficientes (%d necessários, %d disponíveis)" % [custo, PlayerData.nen_skill_points if PlayerData != null else 0])
		return false

	# 3. Verificar pré-requisitos
	for prereq in def.pre_requisitos:
		var pr_s := String(prereq)
		if pr_s == "nexus_center":
			continue # Nexus central é o ponto de partida do despertar, sempre ativo
		var pr_sn := StringName(pr_s)
		var prereq_level: int = node_levels.get(pr_s, node_levels.get(pr_sn, 0))
		if prereq_level <= 0:
			push_warning("[NenSkillTree] Pré-requisito não atendido: " + pr_s)
			return false

	# 4. Verificar exclusividade de Ryu
	if _eh_no_ryu(s_id):
		if ryu_caminho != "" and ryu_caminho != _extrair_caminho_ryu(s_id):
			push_warning("[NenSkillTree] Caminho Ryu já escolhido: " + ryu_caminho)
			return false

	# 5. Consumir pontos
	PlayerData.nen_skill_points -= custo

	# 6. Incrementar nível/rank
	var novo_nivel := nivel_atual + 1
	node_levels[s_id] = novo_nivel
	node_levels[sn_id] = novo_nivel

	# 7. Registrar caminho Ryu se aplicável
	if _eh_no_ryu(s_id):
		ryu_caminho = _extrair_caminho_ryu(s_id)

	# 8. Aplicar modificadores passivos escalonados por rank
	_aplicar_modificadores_do_no(s_id)

	# 9. Sincronizar com PlayerData
	PlayerData.nen_skill_tree_progress = node_levels.duplicate()
	PlayerData.nen_ryu_caminho = ryu_caminho

	print("[NenSkillTree] Investido com sucesso: %s (Rank %d/%d)" % [def.nome, novo_nivel, def.nivel_max])

	skill_investida.emit(s_id, novo_nivel)
	pontos_alterados.emit(PlayerData.nen_skill_points)

	return true


# ==============================================================================
# RESET DA ÁRVORE (RESPEC COM DEVOLUÇÃO TOTAL DE PONTOS)
# ==============================================================================
func resetar_arvore() -> int:
	var pontos_devolvidos: int = 0

	# 1. Contabilizar todos os pontos investidos
	for nid in node_levels.keys():
		var rank: int = int(node_levels[nid])
		if rank > 0:
			var s_id := String(nid)
			var sn_id := StringName(s_id)
			var cost: int = 1
			if node_definitions.has(sn_id):
				cost = node_definitions[sn_id].custo_pontos
			elif node_definitions.has(s_id):
				cost = node_definitions[s_id].custo_pontos
			pontos_devolvidos += rank * cost

	# Evitar contagem dupla caso haja chaves duplicadas String e StringName
	# Como node_levels armazena String e StringName, garantimos unicidade contando por String
	var contados: Dictionary = {}
	pontos_devolvidos = 0
	for nid in node_levels.keys():
		var s_id := String(nid)
		if contados.has(s_id):
			continue
		contados[s_id] = true
		var rank: int = int(node_levels[nid])
		if rank > 0:
			var sn_id := StringName(s_id)
			var cost: int = 1
			if node_definitions.has(sn_id):
				cost = node_definitions[sn_id].custo_pontos
			elif node_definitions.has(s_id):
				cost = node_definitions[s_id].custo_pontos
			pontos_devolvidos += rank * cost

	# 2. Reembolsar pontos ao PlayerData
	if PlayerData != null:
		PlayerData.nen_skill_points += pontos_devolvidos
		PlayerData.nen_skill_tree_progress.clear()
		PlayerData.nen_ryu_caminho = ""
		PlayerData.remover_modificadores_da_fonte("nen_skill_tree")
		PlayerData.remover_modificadores_da_fonte("nen_skill_tree_contextual")
		PlayerData.recalcular_todos_atributos()

	# 3. Limpar estado local
	node_levels.clear()
	ryu_caminho = ""
	_inicializar_niveis()

	print("[NenSkillTree] Reset da Skill Tree concluído: %d pontos devolvidos ao jogador." % pontos_devolvidos)

	pontos_alterados.emit(PlayerData.nen_skill_points if PlayerData != null else 0)
	return pontos_devolvidos


# ==============================================================================
# REGRAS DE RYU
# ==============================================================================
func _eh_no_ryu(node_id: String) -> bool:
	return node_id.begins_with("ryu_")

func _extrair_caminho_ryu(node_id: String) -> String:
	if node_id == "ryu_ofensivo": return "ofensivo"
	elif node_id == "ryu_defensivo": return "defensivo"
	elif node_id == "ryu_equilibrado": return "equilibrado"
	return ""


# ==============================================================================
# APLICAÇÃO DE MODIFICADORES (COM ESCALONAMENTO DE RANK)
# ==============================================================================
func _aplicar_modificadores_do_no(node_id: String) -> void:
	var s_id := String(node_id)
	var sn_id := StringName(s_id)
	if not node_definitions.has(sn_id) and not node_definitions.has(s_id):
		return

	var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
	var nivel: int = node_levels.get(s_id, node_levels.get(sn_id, 0))

	if nivel <= 0 or def.is_contextual():
		return

	# Remover modificadores anteriores deste nó
	PlayerData.remover_modificador(StringName("nen_st_" + s_id))

	# Aplicar cada efeito escalonado pelo rank
	for i in range(def.efeitos.size()):
		var efeito: Dictionary = def.efeitos[i]
		var mod_id: StringName = StringName("nen_st_" + s_id + "_" + str(i))
		PlayerData.remover_modificador(mod_id)

		var valor_base := float(efeito.get("value_per_rank", efeito.get("valor", 0.0)))
		var valor_total := valor_base * float(nivel) # Escalonamento linear pelo rank

		var tipo_int := int(efeito.get("mod_type", efeito.get("tipo", TipoMod.PERCENTAGE)))
		var mod = _criar_modificador(
			mod_id,
			efeito.get("stat", ""),
			tipo_int,
			valor_total,
			"nen_skill_tree"
		)

		if mod != null:
			PlayerData.adicionar_modificador(mod)


func _criar_modificador(mod_id: StringName, stat_name: String, tipo: int, valor: float, source: String):
	var modifier_type: StatModifier.Type = StatModifier.Type.FLAT
	if tipo == TipoMod.PERCENTAGE or tipo == 1:
		modifier_type = StatModifier.Type.PERCENTAGE
	elif tipo == TipoMod.MULTIPLICATIVE or tipo == 2:
		modifier_type = StatModifier.Type.MULTIPLICATIVE
	return StatModifier.new(mod_id, StringName(stat_name), modifier_type, valor, -1.0, source)


func recalcular_todos_modificadores() -> void:
	if PlayerData == null:
		return
	PlayerData.remover_modificadores_da_fonte("nen_skill_tree")
	PlayerData.remover_modificadores_da_fonte("nen_skill_tree_contextual")

	for node_id in node_levels.keys():
		var rank: int = int(node_levels[node_id])
		if rank > 0:
			_aplicar_modificadores_do_no(String(node_id))


# ==============================================================================
# CONTEXTO DE COMBATE & GAMEPLAY CONDITIONS
# ==============================================================================
func avaliar_condicoes_no(node_id: Variant, contexto: Dictionary) -> Dictionary:
	var s_id := String(node_id)
	var sn_id := StringName(s_id)
	if not node_definitions.has(sn_id) and not node_definitions.has(s_id):
		return {"met": false, "motivo": "Nó inexistente: " + s_id, "detalhes": []}

	var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
	if def.conditions.is_empty():
		return {"met": true, "motivo": "", "detalhes": []}

	var detalhes: Array = []
	for cond in def.conditions:
		if cond is GameplayCondition:
			var res: Dictionary = cond.evaluate(contexto)
			detalhes.append(res)
			if not res.get("met", false):
				return {
					"met": false,
					"motivo": "Condição não satisfeita: %d" % int(cond.condition_type),
					"detalhes": detalhes
				}

	return {"met": true, "motivo": "", "detalhes": detalhes}


func obter_modificadores_contextuais_ativos(contexto: Dictionary) -> Array:
	var mods_ativos: Array = []
	for node_id in node_levels.keys():
		var rank: int = int(node_levels[node_id])
		if rank <= 0:
			continue
		var s_id := String(node_id)
		var sn_id := StringName(s_id)
		if not node_definitions.has(sn_id) and not node_definitions.has(s_id):
			continue
		var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
		if not def.is_contextual():
			continue

		var avaliacao := avaliar_condicoes_no(s_id, contexto)
		if avaliacao.get("met", false):
			for i in range(def.efeitos.size()):
				var efeito: Dictionary = def.efeitos[i]
				var mod_id: StringName = StringName("nen_st_ctx_" + s_id + "_" + str(i))
				var valor_base := float(efeito.get("value_per_rank", efeito.get("valor", 0.0)))
				var valor_total := valor_base * float(rank)
				var tipo_int := int(efeito.get("mod_type", efeito.get("tipo", TipoMod.PERCENTAGE)))
				var mod = _criar_modificador(mod_id, efeito.get("stat", ""), tipo_int, valor_total, "nen_skill_tree_contextual")
				if mod != null:
					mods_ativos.append(mod)
	return mods_ativos


func atualizar_modificadores_contextuais(contexto: Dictionary) -> Dictionary:
	var nos_ativos: Array[String] = []
	var mods_aplicados: Array = []

	for node_id in node_levels.keys():
		var rank: int = int(node_levels[node_id])
		var s_id := String(node_id)
		var sn_id := StringName(s_id)
		if not node_definitions.has(sn_id) and not node_definitions.has(s_id):
			continue
		var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
		if not def.is_contextual():
			continue

		var ativado := false
		if rank > 0:
			var avaliacao := avaliar_condicoes_no(s_id, contexto)
			if avaliacao.get("met", false):
				ativado = true

		if ativado:
			nos_ativos.append(s_id)
			for i in range(def.efeitos.size()):
				var efeito: Dictionary = def.efeitos[i]
				var mod_id: StringName = StringName("nen_st_ctx_" + s_id + "_" + str(i))
				var valor_base := float(efeito.get("value_per_rank", efeito.get("valor", 0.0)))
				var valor_total := valor_base * float(rank)
				var tipo_int := int(efeito.get("mod_type", efeito.get("tipo", TipoMod.PERCENTAGE)))
				var mod = _criar_modificador(mod_id, efeito.get("stat", ""), tipo_int, valor_total, "nen_skill_tree_contextual")
				if mod != null:
					PlayerData.adicionar_modificador(mod)
					mods_aplicados.append(mod)
		else:
			for i in range(def.efeitos.size()):
				var mod_id: StringName = StringName("nen_st_ctx_" + s_id + "_" + str(i))
				PlayerData.remover_modificador(mod_id)

	return {
		"nos_ativos": nos_ativos,
		"modificadores": mods_aplicados
	}


func limpar_modificadores_contextuais() -> void:
	if PlayerData != null:
		PlayerData.remover_modificadores_da_fonte("nen_skill_tree_contextual")


func obter_tags_no(node_id: Variant) -> Array[String]:
	var s_id := String(node_id)
	var sn_id := StringName(s_id)
	if node_definitions.has(sn_id) or node_definitions.has(s_id):
		var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
		return def.tags.duplicate()
	return []


func no_tem_tag(node_id: Variant, required_tag: String) -> bool:
	var s_id := String(node_id)
	var sn_id := StringName(s_id)
	if node_definitions.has(sn_id) or node_definitions.has(s_id):
		var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
		return def.has_tag(required_tag) or (GameplayTags != null and GameplayTags.has_tag(def.tags, required_tag))
	return false


# ==============================================================================
# CONSULTAS DE PROGRESSÃO
# ==============================================================================
func obter_nivel_no(node_id: Variant) -> int:
	var s_id := String(node_id)
	var sn_id := StringName(s_id)
	return node_levels.get(s_id, node_levels.get(sn_id, 0))


func obter_progresso_no(node_id: Variant) -> int:
	return obter_nivel_no(node_id)


func obter_pontos_disponiveis() -> int:
	return PlayerData.nen_skill_points if PlayerData != null else 0


func pode_investir(node_id: Variant) -> bool:
	var s_id := String(node_id)
	var sn_id := StringName(s_id)
	if not node_definitions.has(sn_id) and not node_definitions.has(s_id):
		return false

	var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
	var nivel_atual: int = node_levels.get(s_id, node_levels.get(sn_id, 0))

	if nivel_atual >= def.nivel_max:
		return false
	if PlayerData == null or PlayerData.nen_skill_points < def.custo_pontos:
		return false

	for prereq in def.pre_requisitos:
		var pr_s := String(prereq)
		if pr_s == "nexus_center":
			continue
		var pr_sn := StringName(pr_s)
		if node_levels.get(pr_s, node_levels.get(pr_sn, 0)) <= 0:
			return false

	if _eh_no_ryu(s_id):
		if ryu_caminho != "" and ryu_caminho != _extrair_caminho_ryu(s_id):
			return false

	return true


func no_desbloqueado(node_id: Variant) -> bool:
	return obter_nivel_no(node_id) > 0


func obter_bonus_total_stat(stat_name: String) -> float:
	var total: float = 0.0
	for nid in node_levels.keys():
		var rank: int = int(node_levels[nid])
		if rank <= 0:
			continue
		var s_id := String(nid)
		var sn_id := StringName(s_id)
		if not node_definitions.has(sn_id) and not node_definitions.has(s_id):
			continue
		var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
		for ef in def.efeitos:
			if ef.get("stat", "") == stat_name:
				var v := float(ef.get("value_per_rank", ef.get("valor", 0.0)))
				total += v * float(rank)
	return total


func obter_nivel_tecnica_passiva(categoria: int) -> int:
	var count: int = 0
	for nid in node_levels.keys():
		if int(node_levels[nid]) > 0:
			var s_id := String(nid)
			var sn_id := StringName(s_id)
			if node_definitions.has(sn_id) or node_definitions.has(s_id):
				var def: SkillTreeNodeData = node_definitions.get(sn_id, node_definitions.get(s_id))
				if def.categoria == categoria:
					count += 1
	return count


func obter_nos_contextuais() -> Array:
	var lista: Array = []
	for nid in database.nodes.keys():
		var def: SkillTreeNodeData = database.nodes[nid]
		if def.is_contextual():
			lista.append(def)
	return lista


func obter_nos_sinergia() -> Array:
	var lista: Array = []
	for nid in database.nodes.keys():
		var def: SkillTreeNodeData = database.nodes[nid]
		if def.categoria == Categoria.SINERGIA or def.has_tag("nen_synergy"):
			lista.append(def)
	return lista


# ==============================================================================
# SERIALIZAÇÃO & MIGRATION (SAVE/LOAD)
# ==============================================================================
func to_dict() -> Dictionary:
	return {
		"version": 2,
		"node_levels": node_levels.duplicate(),
		"ryu_caminho": ryu_caminho
	}


func from_dict(data: Dictionary) -> void:
	if data.has("node_levels") and data["node_levels"] is Dictionary:
		for key in data["node_levels"]:
			var s_k := String(key)
			var sn_k := StringName(s_k)
			var val := int(data["node_levels"][key])
			node_levels[s_k] = val
			node_levels[sn_k] = val

	if data.has("ryu_caminho"):
		ryu_caminho = str(data["ryu_caminho"])

	_inicializar_niveis()
	recalcular_todos_modificadores()
