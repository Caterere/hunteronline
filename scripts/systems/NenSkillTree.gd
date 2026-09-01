class_name NenSkillTree
extends Node


# ============================================================
# HUNTER ONLINE - NEN SKILL TREE
# ============================================================
#
# Sistema de progressão passiva de Nen.
#
# Técnicas de Nen (TEN, ZETSU, REN, GYO, KO, RYU, SHU)
# concedem BUFFS PASSIVOS PERMANENTES ao personagem.
#
# O jogador ganha Nen Skill Points ao subir de Level
# e os investe nos nós da árvore.
#
# ARQUITETURA:
#
# NEN XP → Level Up → +1 Skill Point → Investir na Árvore
#                                        ↓
#                               Modificador Passivo
#                                        ↓
#                            PlayerData.active_modifiers
#                                        ↓
#                             Stats Finais Recalculados
#
# ============================================================


signal skill_investida(node_id: String, novo_nivel: int)
signal pontos_alterados(pontos_disponiveis: int)


# ============================================================
# CATEGORIAS
# ============================================================

enum Categoria {
	TEN,
	ZETSU,
	REN,
	GYO,
	KO,
	RYU_OFENSIVO,
	RYU_DEFENSIVO,
	RYU_EQUILIBRADO,
	SHU
}


# ============================================================
# TIPOS DE MODIFICADOR
# ============================================================

enum TipoMod {
	FLAT,       # +10
	PERCENTAGE  # +10%
}


# ============================================================
# DEFINIÇÃO DE UM NÓ DA SKILL TREE
# ============================================================

class SkillNodeDef:
	var id: String = ""
	var nome: String = ""
	var descricao: String = ""
	var categoria: int = 0  # Categoria enum
	var nivel_max: int = 1
	var pre_requisitos: Array[String] = []
	var efeitos: Array = []  # Array de {stat, tipo, valor}

	func _init(
		p_id: String,
		p_nome: String,
		p_descricao: String,
		p_categoria: int,
		p_nivel_max: int,
		p_pre_requisitos: Array[String],
		p_efeitos: Array
	) -> void:
		id = p_id
		nome = p_nome
		descricao = p_descricao
		categoria = p_categoria
		nivel_max = p_nivel_max
		pre_requisitos = p_pre_requisitos
		efeitos = p_efeitos


# ============================================================
# CONFIGURAÇÃO DOS NÓS
# ============================================================
#
# Todos os valores estão centralizados aqui.
# Para balanceamento futuro, alterar apenas este dicionário.
#
# ============================================================

var node_definitions: Dictionary = {}


# ============================================================
# ESTADO DO JOGADOR
# ============================================================

# Níveis investidos em cada nó: { "ten_1": 1, "ko_2": 0 }
var node_levels: Dictionary = {}

# Caminho de Ryu escolhido: "", "ofensivo", "defensivo", "equilibrado"
var ryu_caminho: String = ""


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	add_to_group("nen_skill_tree")
	_registrar_definicoes()
	_inicializar_niveis()

	print("=================================")
	print("NEN SKILL TREE INICIADA")
	print("Nós registrados: ", node_definitions.size())
	print("=================================")


# ============================================================
# REGISTRAR DEFINIÇÕES DOS NÓS
# ============================================================

func _registrar_definicoes() -> void:

	# ======================================================
	# TEN — Defesa Passiva
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"ten_1", "TEN I", "Defesa +5%",
		Categoria.TEN, 1, [],
		[{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ten_2", "TEN II", "Defesa +10%",
		Categoria.TEN, 1, ["ten_1"],
		[{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ten_3", "TEN III", "Defesa +15%",
		Categoria.TEN, 1, ["ten_2"],
		[{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ten_4", "TEN IV", "Defesa +20%",
		Categoria.TEN, 1, ["ten_3"],
		[{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.20}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ten_5", "TEN V", "Defesa +25%",
		Categoria.TEN, 1, ["ten_4"],
		[{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.25}]
	))

	# ======================================================
	# ZETSU — Regeneração HP
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"zetsu_1", "ZETSU I", "Regeneracao HP +10%",
		Categoria.ZETSU, 1, [],
		[{"stat": "regen_hp", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}]
	))
	_adicionar_no(SkillNodeDef.new(
		"zetsu_2", "ZETSU II", "Regeneracao HP +20%",
		Categoria.ZETSU, 1, ["zetsu_1"],
		[{"stat": "regen_hp", "tipo": TipoMod.PERCENTAGE, "valor": 0.20}]
	))
	_adicionar_no(SkillNodeDef.new(
		"zetsu_3", "ZETSU III", "Regeneracao HP +30%",
		Categoria.ZETSU, 1, ["zetsu_2"],
		[{"stat": "regen_hp", "tipo": TipoMod.PERCENTAGE, "valor": 0.30}]
	))

	# ======================================================
	# REN — Alcance de Ataque
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"ren_1", "REN I", "Alcance +5%",
		Categoria.REN, 1, [],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ren_2", "REN II", "Alcance +10%",
		Categoria.REN, 1, ["ren_1"],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ren_3", "REN III", "Alcance +15%",
		Categoria.REN, 1, ["ren_2"],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ren_4", "REN IV", "Alcance +20%",
		Categoria.REN, 1, ["ren_3"],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.20}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ren_5", "REN V", "Alcance +25%",
		Categoria.REN, 1, ["ren_4"],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.25}]
	))

	# ======================================================
	# GYO — Esquiva
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"gyo_1", "GYO I", "Esquiva +3%",
		Categoria.GYO, 1, [],
		[{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.03}]
	))
	_adicionar_no(SkillNodeDef.new(
		"gyo_2", "GYO II", "Esquiva +6%",
		Categoria.GYO, 1, ["gyo_1"],
		[{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.06}]
	))
	_adicionar_no(SkillNodeDef.new(
		"gyo_3", "GYO III", "Esquiva +9%",
		Categoria.GYO, 1, ["gyo_2"],
		[{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.09}]
	))
	_adicionar_no(SkillNodeDef.new(
		"gyo_4", "GYO IV", "Esquiva +12%",
		Categoria.GYO, 1, ["gyo_3"],
		[{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.12}]
	))
	_adicionar_no(SkillNodeDef.new(
		"gyo_5", "GYO V", "Esquiva +15%",
		Categoria.GYO, 1, ["gyo_4"],
		[{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}]
	))

	# ======================================================
	# KO — Dano
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"ko_1", "KO I", "Dano +5%",
		Categoria.KO, 1, [],
		[{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ko_2", "KO II", "Dano +10%",
		Categoria.KO, 1, ["ko_1"],
		[{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ko_3", "KO III", "Dano +15%",
		Categoria.KO, 1, ["ko_2"],
		[{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ko_4", "KO IV", "Dano +20%",
		Categoria.KO, 1, ["ko_3"],
		[{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.20}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ko_5", "KO V", "Dano +25%",
		Categoria.KO, 1, ["ko_4"],
		[{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.25}]
	))

	# ======================================================
	# RYU — Caminhos (Mutuamente exclusivos entre si)
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"ryu_ofensivo", "RYU Ofensivo", "Dano +10%",
		Categoria.RYU_OFENSIVO, 1, [],
		[{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ryu_defensivo", "RYU Defensivo", "Defesa +10%",
		Categoria.RYU_DEFENSIVO, 1, [],
		[{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ryu_equilibrado", "RYU Equilibrado", "Dano +5%, Defesa +5%",
		Categoria.RYU_EQUILIBRADO, 1, [],
		[
			{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.05},
			{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}
		]
	))

	# ======================================================
	# SHU — Reservado
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"shu_1", "SHU I", "Reservado para implementacao futura",
		Categoria.SHU, 1, [],
		[]  # Sem efeitos por enquanto
	))


func _adicionar_no(def: SkillNodeDef) -> void:
	node_definitions[def.id] = def


func _inicializar_niveis() -> void:
	for node_id in node_definitions:
		if not node_levels.has(node_id):
			node_levels[node_id] = 0


# ============================================================
# INVESTIR PONTO
# ============================================================

func investir_ponto(node_id: String) -> bool:
	if not node_definitions.has(node_id):
		push_warning("[NenSkillTree] Nó desconhecido: " + node_id)
		return false

	var def: SkillNodeDef = node_definitions[node_id]
	var nivel_atual: int = node_levels.get(node_id, 0)

	# Verificar nível máximo
	if nivel_atual >= def.nivel_max:
		push_warning("[NenSkillTree] Nó já está no nível máximo: " + node_id)
		return false

	# Verificar pontos disponíveis
	if PlayerData.nen_skill_points <= 0:
		push_warning("[NenSkillTree] Sem pontos disponíveis")
		return false

	# Verificar pré-requisitos
	for prereq in def.pre_requisitos:
		var prereq_level: int = node_levels.get(prereq, 0)
		if prereq_level <= 0:
			push_warning("[NenSkillTree] Pré-requisito não atendido: " + prereq)
			return false

	# Verificar exclusividade de Ryu
	if _eh_no_ryu(node_id):
		if ryu_caminho != "" and ryu_caminho != _extrair_caminho_ryu(node_id):
			push_warning("[NenSkillTree] Caminho Ryu já escolhido: " + ryu_caminho)
			return false

	# Consumir ponto
	PlayerData.nen_skill_points -= 1

	# Incrementar nível
	node_levels[node_id] = nivel_atual + 1

	# Registrar caminho Ryu se aplicável
	if _eh_no_ryu(node_id):
		ryu_caminho = _extrair_caminho_ryu(node_id)

	# Aplicar modificadores passivos
	_aplicar_modificadores_do_no(node_id)

	# Sincronizar com PlayerData
	PlayerData.nen_skill_tree_progress = node_levels.duplicate()
	PlayerData.nen_ryu_caminho = ryu_caminho

	print("[NenSkillTree] Investido em: ", def.nome, " (Lv.", node_levels[node_id], ")")

	skill_investida.emit(node_id, node_levels[node_id])
	pontos_alterados.emit(PlayerData.nen_skill_points)

	return true


# ============================================================
# VERIFICAÇÕES DE RYU
# ============================================================

func _eh_no_ryu(node_id: String) -> bool:
	return node_id.begins_with("ryu_")


func _extrair_caminho_ryu(node_id: String) -> String:
	if node_id == "ryu_ofensivo":
		return "ofensivo"
	elif node_id == "ryu_defensivo":
		return "defensivo"
	elif node_id == "ryu_equilibrado":
		return "equilibrado"
	return ""


# ============================================================
# APLICAR MODIFICADORES
# ============================================================

func _aplicar_modificadores_do_no(node_id: String) -> void:
	if not node_definitions.has(node_id):
		return

	var def: SkillNodeDef = node_definitions[node_id]
	var nivel: int = node_levels.get(node_id, 0)

	if nivel <= 0:
		return

	# Remover modificadores anteriores deste nó
	PlayerData.remover_modificador(StringName("nen_st_" + node_id))

	# Aplicar cada efeito
	for i in range(def.efeitos.size()):
		var efeito: Dictionary = def.efeitos[i]
		var mod_id: StringName = StringName("nen_st_" + node_id + "_" + str(i))

		# Remover anterior se existir
		PlayerData.remover_modificador(mod_id)

		var mod = _criar_modificador(
			mod_id,
			efeito.get("stat", ""),
			efeito.get("tipo", TipoMod.PERCENTAGE),
			efeito.get("valor", 0.0),
			"nen_skill_tree"
		)

		if mod != null:
			PlayerData.adicionar_modificador(mod)


func _criar_modificador(mod_id: StringName, stat_name: String, tipo: int, valor: float, source: String):
	# Usa a mesma estrutura de StatModifier que o PlayerData espera
	var mod = RefCounted.new()
	mod.set_meta("id", mod_id)
	mod.set_meta("stat_name", stat_name)
	mod.set_meta("type", tipo)  # 0=FLAT, 1=PERCENTAGE
	mod.set_meta("value", valor)
	mod.set_meta("source", source)

	# Criar objeto compatível com o pipeline existente
	# O PlayerData espera objetos com propriedades: id, stat_name, type, value, source
	return NenSkillModifier.new(mod_id, stat_name, tipo, valor, source)


# ============================================================
# STAT MODIFIER INTERNO
# ============================================================

class NenSkillModifier:
	var id: StringName = &""
	var stat_name: String = ""
	var type: int = 1  # 0=FLAT, 1=PERCENTAGE
	var value: float = 0.0
	var source: String = ""

	func _init(p_id: StringName, p_stat: String, p_type: int, p_value: float, p_source: String) -> void:
		id = p_id
		stat_name = p_stat
		type = p_type
		value = p_value
		source = p_source


# ============================================================
# RECALCULAR TODOS OS MODIFICADORES
# ============================================================
#
# Remove todos os modificadores da fonte "nen_skill_tree"
# e reaplica com base no progresso atual.
#
# Usado ao carregar save ou após respec.
#
# ============================================================

func recalcular_todos_modificadores() -> void:
	# Remover todos os modificadores da Skill Tree
	PlayerData.remover_modificadores_da_fonte("nen_skill_tree")

	# Reaplicar todos os nós investidos
	for node_id in node_levels:
		if node_levels[node_id] > 0:
			_aplicar_modificadores_do_no(node_id)


# ============================================================
# CONSULTAS
# ============================================================

func obter_nivel_no(node_id: String) -> int:
	return node_levels.get(node_id, 0)


func no_desbloqueado(node_id: String) -> bool:
	return node_levels.get(node_id, 0) > 0


func obter_nivel_maior_da_categoria(categoria: int) -> int:
	var maior: int = 0
	for node_id in node_definitions:
		var def: SkillNodeDef = node_definitions[node_id]
		if def.categoria == categoria:
			var nivel: int = node_levels.get(node_id, 0)
			if nivel > maior:
				maior = nivel
	return maior


func obter_bonus_total_stat(stat_name: String) -> float:
	var total: float = 0.0
	for node_id in node_levels:
		if node_levels[node_id] <= 0:
			continue
		if not node_definitions.has(node_id):
			continue
		var def: SkillNodeDef = node_definitions[node_id]
		for efeito in def.efeitos:
			if efeito.get("stat", "") == stat_name:
				total += efeito.get("valor", 0.0)
	return total


# Quantos nós da categoria foram investidos (para usar como "nível da técnica")
func obter_nivel_tecnica_passiva(categoria: int) -> int:
	var count: int = 0
	for node_id in node_definitions:
		var def: SkillNodeDef = node_definitions[node_id]
		if def.categoria == categoria and node_levels.get(node_id, 0) > 0:
			count += 1
	return count


# ============================================================
# SERIALIZAÇÃO
# ============================================================

func to_dict() -> Dictionary:
	return {
		"node_levels": node_levels.duplicate(),
		"ryu_caminho": ryu_caminho
	}


func from_dict(data: Dictionary) -> void:
	if data.has("node_levels") and data["node_levels"] is Dictionary:
		for key in data["node_levels"]:
			node_levels[key] = int(data["node_levels"][key])

	if data.has("ryu_caminho"):
		ryu_caminho = str(data["ryu_caminho"])

	# Garantir que nós novos adicionados em updates tenham nível 0
	_inicializar_niveis()

	# Recalcular modificadores após carregar
	recalcular_todos_modificadores()
