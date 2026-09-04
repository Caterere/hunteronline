extends Node

const AuraVisualProfile = preload("res://resource/hatsu/AuraVisualProfile.gd")

# ============================================================
# HUNTER ONLINE - PLAYER DATA
# ============================================================
#
# LEVEL NORMAL:
# Vida
# Força
# Defesa
# Velocidade
#
# LEVEL NEN:
# Aura Máxima
#
# XP NORMAL e XP NEN são sistemas separados.
#
# ============================================================


# ============================================================
# SINAIS DE PROGRESSÃO E ATRIBUTOS
# ============================================================

signal nivel_alterado(novo_nivel: int)
signal atributos_recalculados()

var attributes: Dictionary = {

	"vida": 100,
	"vida_max": 100,

	"forca": 10,

	"defesa": 10,

	"velocidade": 10,

	# ========================================================
	# NEN
	# ========================================================

	"aura": 0.0,
	"aura_max": 0.0,

	"nivel_nen": 0,
	"xp_nen": 0,

	# ========================================================
	# LEVEL NORMAL & XP
	# ========================================================

	"nivel": 1,
	"xp": 0
}

# ============================================================
# TAGS CANÔNICAS DE RESISTÊNCIA & MITIGAÇÃO (FASE 3)
# ============================================================

var resistance_tags: Array[String] = []
var weakness_tags: Array[String] = []
var immunity_tags: Array[String] = []

func eh_vulneravel_a(tags: Array) -> bool:
	return GameplayTags.has_any(weakness_tags, tags)

func eh_resistente_a(tags: Array) -> bool:
	return GameplayTags.has_any(resistance_tags, tags)

func eh_imune_a(tags: Array) -> bool:
	return GameplayTags.has_any(immunity_tags, tags)


# ============================================================
# QUESTS
# ============================================================

var quest_states: Dictionary = {}

# ============================================================
# PROGRESSÃO DE ARCO DA HISTÓRIA
# ============================================================

var arco_atual: int = 1
var etapa_quest_arco: int = 1
var max_arco_desbloqueado: int = 1
var modo_historia_concluido: bool = false
var torre_andar_atual: int = 1
var casa_desbloqueada: bool = true
var tour_lobby_concluido: bool = false
var tutorial_concluido: bool = false
var tutorial_etapa_atual: int = 0
var tutorial_data: Dictionary = {
	"tutorial_inicial_concluido": false,
	"movimento": false,
	"interacao": false,
	"menus": false,
	"inventario": false,
	"combate": false,
	"status": false,
	"nen_conceito": false,
	"nen_despertar_visto": false,
	"hatsu_visto": false,
	"gyo_visto": false,
	"treinamento_visto": false
}
var conhecimentos_desbloqueados: Array[String] = [
	"mundo_associacao_hunter",
	"combate_basico",
	"atributos_vitalidade",
	"menus_sistema"
]
var mapa_atual_salvo: String = "res://world/lobby.tscn"
var posicao_salva: Vector2 = Vector2.ZERO

func avancar_arco() -> void:
	var tem_prox: bool = false
	if StoryManager != null and StoryManager.has_method("tem_proxima_saga"):
		tem_prox = StoryManager.tem_proxima_saga(arco_atual)
	else:
		tem_prox = arco_atual < 9

	if tem_prox:
		arco_atual += 1
		etapa_quest_arco = 1
	else:
		modo_historia_concluido = true
		print("[PlayerData] MODO HISTÓRIA TOTALMENTE CONCLUÍDO!")
		
	max_arco_desbloqueado = max(max_arco_desbloqueado, arco_atual)

	if is_greed_island_concluida():
		desbloquear_hatsu_creator()

	print("=================================")
	print("[PlayerData] ARCO AVANÇADO PARA: ", arco_atual, " | MAX DESBLOQUEADO: ", max_arco_desbloqueado)
	print("=================================")
	
	if GameState != null and GameState.has_method("salvar_jogo"):
		GameState.salvar_jogo()


func completar_etapa_historia(arco: int = -1) -> void:
	if arco == 5:
		desbloquear_hatsu_creator()
	if arco > 0 and arco == arco_atual:
		avancar_arco()
	elif arco <= 0:
		avancar_arco()


func is_greed_island_concluida() -> bool:
	if modo_historia_concluido:
		return true
	if arco_atual > 5 or max_arco_desbloqueado > 5:
		return true
	if quest_states.get("arco5_concluido", false) == true:
		return true
	return false


func desbloquear_hatsu_creator() -> void:
	if HatsuProgressionManager != null and not HatsuProgressionManager.is_slot_unlocked(1):
		HatsuProgressionManager.unlock_slot(1)
	elif not hatsu_creation_unlocked or not hatsu_desbloqueado:
		hatsu_creation_unlocked = true
		hatsu_desbloqueado = true
		print("[PlayerData] 🥋 HATSU CREATOR DESBLOQUEADO PERMANENTEMENTE!")
		if GameState != null and GameState.has_method("salvar_jogo"):
			GameState.salvar_jogo()



# ============================================================
# DADOS DO PERSONAGEM E SELEÇÃO
# ============================================================

enum Dificuldade { FACIL, NORMAL, DIFICIL, MUITO_DIFICIL, HUNTER_SUPREMO }

@export var dificuldade: Dificuldade = Dificuldade.NORMAL
var potencial: float = 1.0
var reputacao_hunter: int = 0
var titulo_equipado: String = "Hunter Novato"
var titulos_desbloqueados: Array[String] = ["Hunter Novato"]
var faccao_atual: String = ""
var faccao_rank: int = 0
var segredos_descobertos: Array[String] = []
var socos_netero_contador: int = 0
var fita_ging_ouvida: bool = false

func obter_multiplicador_dificuldade() -> Dictionary:
	match dificuldade:
		Dificuldade.FACIL: return {"hp": 1.2, "dano": 1.2, "xp": 1.5}
		Dificuldade.NORMAL: return {"hp": 1.0, "dano": 1.0, "xp": 1.0}
		Dificuldade.DIFICIL: return {"hp": 0.8, "dano": 0.8, "xp": 0.8}
		Dificuldade.MUITO_DIFICIL: return {"hp": 0.6, "dano": 0.6, "xp": 0.5}
		Dificuldade.HUNTER_SUPREMO: return {"hp": 0.4, "dano": 0.4, "xp": 0.3}
	return {"hp": 1.0, "dano": 1.0, "xp": 1.0}

func obter_multiplicador_dificuldade_inimigo() -> Dictionary:
	match dificuldade:
		Dificuldade.FACIL: return {"hp": 0.8, "dano": 0.8, "defesa": 0.8}
		Dificuldade.NORMAL: return {"hp": 1.0, "dano": 1.0, "defesa": 1.0}
		Dificuldade.DIFICIL: return {"hp": 1.6, "dano": 1.5, "defesa": 1.4}
		Dificuldade.MUITO_DIFICIL: return {"hp": 2.5, "dano": 2.2, "defesa": 2.0}
		Dificuldade.HUNTER_SUPREMO: return {"hp": 4.0, "dano": 3.5, "defesa": 3.0}
	return {"hp": 1.0, "dano": 1.0, "defesa": 1.0}

func obter_nome_dificuldade() -> String:
	match dificuldade:
		Dificuldade.FACIL: return "Fácil"
		Dificuldade.NORMAL: return "Normal"
		Dificuldade.DIFICIL: return "Difícil"
		Dificuldade.MUITO_DIFICIL: return "Muito Difícil"
		Dificuldade.HUNTER_SUPREMO: return "Hunter Supremo"
	return "Normal"

var character_id: String = ""
var nome_personagem: String = "Hunter"
var afinidade_nen: NenAffinityData.CategoriaAfinidade = NenAffinityData.CategoriaAfinidade.INTENSIFICACAO
var slot_ativo: int = 1
var is_character_ready: bool = false

var character_colors: Dictionary = {
	"cabelo": Color(0.15, 0.15, 0.15, 1.0),
	"roupa": Color(0.2, 0.6, 0.3, 1.0)
}

func gerar_novo_character_id() -> String:
	var chars = "abcdef0123456789"
	var rand_part = ""
	for i in range(8):
		rand_part += chars[randi() % chars.length()]
	character_id = "hxr-%s-s%d" % [rand_part, slot_ativo]
	return character_id




# ============================================================
# INVENTÁRIO
# ============================================================


var inventory: Dictionary = {}
var tecnicas_nen: Dictionary = {}


# ============================================================
# PROGRESSÃO DE HISTÓRIA / LORE
# ============================================================

var despertou_nen: bool = false            # Desbloqueado com Wing na Arena Celestial

# ============================================================
# NEN SKILL TREE
# ============================================================

var nen_skill_points: int = 0
var nen_skill_tree_progress: Dictionary = {}
var nen_ryu_caminho: String = ""
var hatsu_desbloqueado: bool = false        # Desbloqueado com Biscuit após Greed Island
var hatsu_creation_unlocked: bool = false   # Flag canônica definitiva de criação de Hatsu
var besta_nen_desbloqueada: bool = false
var besta_nen_equipada: NenBeastData = null
var bestas_nen_desbloqueadas: Array = []
var conquistas_desbloqueadas: Array = []
var conquistas_resgatadas: Array = []

var stats_globais: Dictionary = {
	"inimigos_derrotados": 0,
	"perfect_dodges": 0,
	"dano_maximo_golpe": 0,
	"bounties_capturados": 0,
	"equipamentos_mais_10": 0,
	"cartas_coletadas": 0,
	"hatsus_executados": 0,
	"jenny_acumulado": 0
}


func registrar_estatistica(chave: String, valor: int = 1) -> void:
	if not stats_globais.has(chave):
		stats_globais[chave] = 0
	stats_globais[chave] += valor
	var ach_sys = Engine.get_main_loop().root.get_node_or_null("/root/AchievementSystem") if Engine.get_main_loop() else null
	if ach_sys and ach_sys.has_method("verificar_todas_conquistas"):
		ach_sys.verificar_todas_conquistas()



func desbloquear_besta_nen(besta: NenBeastData) -> void:
	if besta == null:
		return
	besta_nen_desbloqueada = true
	var ja_tem = false
	for b in bestas_nen_desbloqueadas:
		if b is NenBeastData and b.nome_besta == besta.nome_besta:
			ja_tem = true
			break
	if not ja_tem:
		bestas_nen_desbloqueadas.append(besta)
	if besta_nen_equipada == null:
		equipar_besta_nen(besta)


func equipar_besta_nen(besta: NenBeastData) -> void:
	besta_nen_equipada = besta
	besta_nen_desbloqueada = true
	var n_sys = Engine.get_main_loop().root.get_tree().get_first_node_in_group("nen_beast_system") if Engine.get_main_loop() else null
	if n_sys and n_sys.has_method("equipar_besta"):
		n_sys.equipar_besta(besta)


# MISSÕES PARALELAS (XENOVERSE STYLE)
var parallel_quests_concluidas: Array = []
var missao_paralela_ativa_id: int = -1

func concluir_missao_paralela(pq_id: int) -> void:
	if not parallel_quests_concluidas.has(pq_id):
		parallel_quests_concluidas.append(pq_id)
		print("[PlayerData] Missão Paralela PQ %d CONCLUÍDA COM SUCESSO!" % pq_id)
	if GameState != null:
		GameState.salvar_jogo()



# ============================================================
# HATSU & ABSORÇÃO PERMANENTE (ESPECIALIZAÇÃO)
# ============================================================

var hatsu_criados: Array = []
var hatsu_slots: Array = [-1, -1, -1, -1]
var stored_hatsus: Array[Dictionary] = []
var absorbed_stats_registry: Dictionary = {} # {"enemy_id": int(count)} para diminishing returns
var hatsu_fragments_discovered: Array[String] = [] # Modificadores e fragmentos descobertos
var aura_visual_profile: AuraVisualProfile = null
var is_debug_mode: bool = false
var skill_tree: Node = null # Instância canônica permanente de NenSkillTree
var backup_state_before_debug: Dictionary = {}


func _ready() -> void:
	reset()
	_inicializar_skill_tree()


func _inicializar_skill_tree() -> void:
	if skill_tree == null or not is_instance_valid(skill_tree):
		var st_script = load("res://scripts/systems/NenSkillTree.gd")
		if st_script != null:
			skill_tree = st_script.new()
			skill_tree.name = "NenSkillTree"
			add_child(skill_tree)


func obter_skill_tree() -> Node:
	if skill_tree == null or not is_instance_valid(skill_tree):
		_inicializar_skill_tree()
	return skill_tree


func reset() -> void:
	is_debug_mode = false
	backup_state_before_debug.clear()
	hatsu_criados.clear()
	hatsu_slots = [-1, -1, -1, -1]
	stored_hatsus.clear()
	hatsu_creation_unlocked = false
	hatsu_desbloqueado = false
	if HatsuProgressionManager != null:
		HatsuProgressionManager.unlocked_slots = {1: false, 2: false, 3: false, 4: false}
		HatsuProgressionManager.archive.clear()
		HatsuProgressionManager.active_slots_map = {1: "", 2: "", 3: "", 4: ""}
		HatsuProgressionManager.last_creation_timestamp = 0
		HatsuProgressionManager.slot_switch_timestamps = {1: 0, 2: 0, 3: 0, 4: 0}
		HatsuProgressionManager.hatsu_slots_atualizados.emit()
	absorbed_stats_registry.clear()
	hatsu_fragments_discovered.clear()
	active_modifiers.clear()
	aura_visual_profile = AuraVisualProfile.new()
	attributes = {
		"vida": 100,
		"vida_max": 100,
		"forca": 10,
		"defesa": 10,
		"velocidade": 10,
		"aura": 100.0,
		"aura_max": 100.0,
		"nivel_nen": 1,
		"xp_nen": 0,
		"nivel": 1,
		"xp": 0
	}
	recalcular_todos_atributos()
	attributes["vida"] = attributes["vida_max"]
	attributes["aura"] = attributes["aura_max"]

	# Skill Tree
	nen_skill_points = 0
	nen_skill_tree_progress.clear()
	nen_ryu_caminho = ""
	if skill_tree != null and is_instance_valid(skill_tree) and skill_tree.has_method("resetar_arvore"):
		skill_tree.resetar_arvore()



# ============================================================
# STAT MODIFIERS & PIPELINE DE ATRIBUTOS
# ============================================================

var active_modifiers: Array = [] # Array de StatModifier

func adicionar_modificador(mod) -> void:
	if mod == null:
		return
	# Remover modificador anterior com mesmo ID se existir
	remover_modificador(mod.id)
	active_modifiers.append(mod)
	recalcular_todos_atributos()

func remover_modificador(mod_id: StringName) -> void:
	if mod_id.is_empty():
		return
	for i in range(active_modifiers.size() - 1, -1, -1):
		if active_modifiers[i].id == mod_id:
			active_modifiers.remove_at(i)
	recalcular_todos_atributos()

func remover_modificadores_da_fonte(source: String) -> void:
	for i in range(active_modifiers.size() - 1, -1, -1):
		if active_modifiers[i].source == source:
			active_modifiers.remove_at(i)
	recalcular_todos_atributos()

func obter_modificador_total(stat_name: String) -> float:
	var total: float = 0.0
	for m in active_modifiers:
		if m == null or str(m.stat_name) != stat_name:
			continue
		total += float(m.value)
	return total

func obter_modificador_flat(stat_name: String) -> float:
	var total: float = 0.0
	for m in active_modifiers:
		if m == null or str(m.stat_name) != stat_name:
			continue
		if int(m.type) == 0:
			total += float(m.value)
	return total

func obter_modificador_percentual(stat_name: String) -> float:
	var total: float = 0.0
	for m in active_modifiers:
		if m == null or str(m.stat_name) != stat_name:
			continue
		if int(m.type) == 1:
			total += float(m.value)
	return total

func obter_aura() -> float:
	return float(attributes.get("aura", 0.0))

func obter_aura_max() -> float:
	return float(attributes.get("aura_max", 100.0))

func consumir_aura(quantidade: float) -> bool:
	var atual: float = obter_aura()
	if atual >= quantidade:
		attributes["aura"] = max(0.0, atual - quantidade)
		return true
	return false

func obter_stat_calculado(stat_name: String) -> float:
	var nivel: int = int(attributes.get("nivel", 1))
	var nivel_nen: int = int(attributes.get("nivel_nen", 0))

	var base_val: float = ProgressionConfig.calcular_stat_base(stat_name, nivel)
	if stat_name == "aura_max":
		if not despertou_nen and nivel_nen <= 0:
			base_val = 0.0
		else:
			# Base canônica pelo Nível do personagem + refino adicional por maestria/nível_nen
			base_val = ProgressionConfig.calcular_stat_base("aura_max", nivel) + float(nivel_nen * 25)

	# 1. Bônus Base por Afinidade
	var mult_afinidade: float = 1.0
	match afinidade_nen:
		NenAffinityData.CategoriaAfinidade.INTENSIFICACAO:
			if stat_name == "forca" or stat_name == "vida_max": mult_afinidade = 1.20
		NenAffinityData.CategoriaAfinidade.TRANSFORMACAO:
			if stat_name == "aura_max": mult_afinidade = 1.25
		NenAffinityData.CategoriaAfinidade.CONJURACAO:
			if stat_name == "defesa": mult_afinidade = 1.30
		NenAffinityData.CategoriaAfinidade.MANIPULACAO:
			if stat_name == "velocidade": mult_afinidade = 1.25
		NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
			if stat_name == "vida_max" or stat_name == "forca" or stat_name == "defesa": mult_afinidade = 1.50
			elif stat_name == "aura_max": mult_afinidade = 1.60
			elif stat_name == "velocidade": mult_afinidade = 1.40

	base_val *= mult_afinidade

	# 2. Pipeline de Modificadores (Flat -> Percentage -> Multiplicative)
	var flat_sum: float = 0.0
	var pct_sum: float = 0.0
	var mult_product: float = 1.0

	for m in active_modifiers:
		if m == null or str(m.stat_name) != stat_name:
			continue
		match int(m.type):
			0: # FLAT
				flat_sum += m.value
			1: # PERCENTAGE
				pct_sum += m.value
			2: # MULTIPLICATIVE
				mult_product *= m.value

	var final_val: float = (base_val + flat_sum) * (1.0 + pct_sum) * mult_product
	if stat_name == "aura_max":
		return max(0.0, final_val) if (despertou_nen or nivel_nen > 0) else 0.0
	if stat_name in ["vida_max", "forca", "defesa", "velocidade"]:
		return max(1.0, final_val)
	return max(0.0, final_val)

func recalcular_todos_atributos() -> void:
	attributes["vida_max"] = int(obter_stat_calculado("vida_max"))
	attributes["forca"] = int(obter_stat_calculado("forca"))
	attributes["defesa"] = int(obter_stat_calculado("defesa"))
	attributes["velocidade"] = int(obter_stat_calculado("velocidade"))
	attributes["aura_max"] = obter_stat_calculado("aura_max")

	# Ajustar vida e aura atuais aos novos limites
	if attributes.has("vida"):
		attributes["vida"] = clamp(attributes["vida"], 0, attributes["vida_max"])
	if attributes.has("aura"):
		attributes["aura"] = clamp(attributes["aura"], 0.0, attributes["aura_max"])

	atributos_recalculados.emit()

func curar_vida(quantidade: int) -> void:
	if quantidade <= 0:
		return
	var hp_atual: int = int(attributes.get("vida", 100))
	var hp_max: int = int(attributes.get("vida_max", 100))
	attributes["vida"] = clamp(hp_atual + quantidade, 0, hp_max)

# ============================================================
# ATRIBUTOS
# ============================================================

func get_attributes() -> Dictionary:
	return attributes

# ============================================================
# LEVEL NORMAL
# ============================================================

func aplicar_nivel(novo_nivel: int) -> void:
	if novo_nivel < 1:
		novo_nivel = 1
	if novo_nivel > ProgressionConfig.MAX_LEVEL:
		novo_nivel = ProgressionConfig.MAX_LEVEL

	attributes["nivel"] = novo_nivel
	recalcular_todos_atributos()
	attributes["vida"] = attributes["vida_max"]
	if despertou_nen or int(attributes.get("nivel_nen", 0)) > 0:
		attributes["aura"] = attributes["aura_max"]

	nivel_alterado.emit(novo_nivel)
	if HatsuProgressionManager != null:
		HatsuProgressionManager.check_and_unlock_slots()

	print("=================================")
	print("ATRIBUTOS ATUALIZADOS")
	print("LEVEL NORMAL: ", novo_nivel, " / ", ProgressionConfig.MAX_LEVEL)
	print("VIDA: ", attributes["vida"], "/", attributes["vida_max"])
	print("FORÇA: ", attributes["forca"])
	print("DEFESA: ", attributes["defesa"])
	print("VELOCIDADE: ", attributes["velocidade"])
	print("NÍVEL NEN: ", attributes["nivel_nen"])
	print("AURA: ", attributes["aura"], "/", attributes["aura_max"])
	print("=================================")



# ============================================================
# APLICAR LEVEL NEN
# ============================================================
#
# Essa função é a ÚNICA responsável por alterar:
#
# nivel_nen
# aura_max
#
# Regra:
#
# Nen Lv.0 → Aura Máxima 0
# Nen Lv.1 → Aura Máxima 100
# Nen Lv.2 → Aura Máxima 200
# Nen Lv.3 → Aura Máxima 300
#
# etc.
#
# ============================================================

func aplicar_nivel_nen(novo_nivel: int) -> void:
	if novo_nivel < 0:
		novo_nivel = 0

	attributes["nivel_nen"] = novo_nivel
	recalcular_todos_atributos()
	attributes["aura"] = attributes["aura_max"]

	print("=================================")
	print("NEN LEVEL UP!")
	print("NÍVEL NEN: ", novo_nivel)
	print("AURA: ", attributes["aura"], "/", attributes["aura_max"])
	print("=================================")



# ============================================================
# QUEST ID
# ============================================================

func _get_quest_id(quest: Quest) -> String:
	if quest == null:
		return ""
	if not quest.resource_path.is_empty():
		return quest.resource_path
	if not quest.quest_name.is_empty():
		return quest.quest_name
	return str(quest.get_instance_id())


# ============================================================
# QUEST COMPLETADA
# ============================================================

func is_quest_completed(quest: Quest) -> bool:

	if quest == null:
		return false


	var quest_id := _get_quest_id(quest)


	if quest_id.is_empty():
		return false


	if not quest_states.has(quest_id):
		return false


	return (
		quest_states[quest_id]["status"]
		== "completed"
	)


# ============================================================
# QUEST ATIVA
# ============================================================

func is_quest_active(quest: Quest) -> bool:

	if quest == null:
		return false


	var quest_id := _get_quest_id(quest)


	if quest_id.is_empty():
		return false


	if not quest_states.has(quest_id):
		return false


	return (
		quest_states[quest_id]["status"]
		== "active"
	)


# ============================================================
# COMEÇAR QUEST
# ============================================================

func start_quest(quest: Quest) -> bool:

	if quest == null:
		return false


	var quest_id := _get_quest_id(quest)


	if quest_id.is_empty():
		return false


	if is_quest_active(quest):
		return false


	if is_quest_completed(quest):
		return false


	var progress: Array[int] = []


	for objective in quest.objectives:

		progress.append(0)


	quest_states[quest_id] = {

		"status": "active",

		"progress": progress
	}


	print(
		"Quest iniciada: ",
		quest.quest_name
	)


	return true


# ============================================================
# PROGRESSO
# ============================================================

func get_quest_objective_progress(
	quest: Quest,
	objective_index: int
) -> int:

	if quest == null:
		return 0


	var quest_id := _get_quest_id(quest)


	if quest_id.is_empty():
		return 0


	if not quest_states.has(quest_id):
		return 0


	var progress: Array = (
		quest_states[quest_id]["progress"]
	)


	if (
		objective_index < 0
		or objective_index >= progress.size()
	):

		return 0


	return progress[objective_index]


# ============================================================
# DEFINIR PROGRESSO
# ============================================================

func set_quest_objective_progress(
	quest: Quest,
	objective_index: int,
	value: int
) -> void:

	if quest == null:
		return


	var quest_id := _get_quest_id(quest)


	if quest_id.is_empty():
		return


	if not quest_states.has(quest_id):
		return


	var progress: Array = (
		quest_states[quest_id]["progress"]
	)


	if (
		objective_index < 0
		or objective_index >= progress.size()
	):

		return


	progress[objective_index] = value


# ============================================================
# COMPLETAR QUEST
# ============================================================

func complete_quest(quest: Quest) -> void:

	if quest == null:
		return


	var quest_id := _get_quest_id(quest)


	if quest_id.is_empty():
		return


	if not quest_states.has(quest_id):
		return


	quest_states[quest_id]["status"] = "completed"


	print(
		"Quest concluída: ",
		quest.quest_name
	)


# ============================================================
# INVENTÁRIO
# ============================================================

func adicionar_item(
	item_id: StringName,
	quantidade: int = 1
) -> void:

	if item_id.is_empty():
		return

	if quantidade <= 0:
		return

	if not inventory.has(item_id):
		inventory[item_id] = 0

	inventory[item_id] += quantidade

	print(
		"Item adicionado: ",
		item_id,
		" +",
		quantidade
	)


# ============================================================
# REMOVER ITEM
# ============================================================

func remover_item(
	item_id: StringName,
	quantidade: int = 1
) -> bool:

	if item_id.is_empty():
		return false

	if quantidade <= 0:
		return false

	if not inventory.has(item_id):
		return false

	if inventory[item_id] < quantidade:
		return false

	inventory[item_id] -= quantidade

	if inventory[item_id] <= 0:
		inventory.erase(item_id)

	print(
		"Item removido: ",
		item_id,
		" -",
		quantidade
	)

	return true


# ============================================================
# OBTER QUANTIDADE DE ITEM
# ============================================================

func obter_item_quantidade(item_id: StringName) -> int:

	if not inventory.has(item_id):
		return 0

	return inventory[item_id]


# ============================================================
# VERIFICAR ITEM
# ============================================================

func tem_item(
	item_id: StringName,
	quantidade: int = 1
) -> bool:

	return obter_item_quantidade(item_id) >= quantidade


# ============================================================
# BÔNUS DA AFINIDADE DE NEN
# ============================================================

func aplicar_bonuses_afinidade() -> void:
	recalcular_todos_atributos()




# ============================================================
# ============================================================
# HATSU MANAGEMENT
# ============================================================

func popular_hatsus_iniciais() -> void:
	# Função utilitária/debug (NÃO é mais executada no boot de novo personagem)
	hatsu_criados.clear()
	for info in CanonHatsuCatalog.obter_hatsus_canonicos():
		var h: HatsuData = HatsuManager.obter_hatsu_canonico(info["id"])
		if h != null:
			hatsu_criados.append(h)
			
	if hatsu_slots[0] == -1 and hatsu_criados.size() >= 4:
		hatsu_slots = [0, 1, 2, 3]
	hatsu_desbloqueado = true
	print("[PlayerData] Popular Hatsus Iniciais concluído: ", hatsu_criados.size(), " habilidades disponíveis.")


func obter_todos_hatsus_disponiveis() -> Array[HatsuData]:
	var lista: Array[HatsuData] = []
	for h in hatsu_criados:
		if h is HatsuData:
			lista.append(h)
	return lista


func adicionar_hatsu(hatsu: HatsuData) -> int:
	if hatsu == null:
		return -1

	if HatsuProgressionManager != null:
		var check = HatsuProgressionManager.can_create_hatsu()
		if not check.get("can_create", false):
			push_warning("[PlayerData] Bloqueio anti-bypass: %s" % check.get("message", "Criação não permitida"))
			return -1

	if hatsu.hatsu_id.is_empty():
		hatsu.gerar_novo_id()

	if HatsuProgressionManager != null:
		if not (hatsu in HatsuProgressionManager.archive):
			HatsuProgressionManager.archive.append(hatsu)
		HatsuProgressionManager._sync_player_data_archive()
	else:
		hatsu_criados.append(hatsu)

	hatsu_desbloqueado = true
	var index: int = hatsu_criados.find(hatsu)
	if index == -1:
		index = hatsu_criados.size() - 1

	# Auto-equipar APENAS no primeiro slot livre que esteja DESBLOQUEADO
	for i in range(hatsu_slots.size()):
		if hatsu_slots[i] == -1:
			var slot_id: int = i + 1
			if HatsuProgressionManager == null or HatsuProgressionManager.is_slot_unlocked(slot_id):
				if HatsuProgressionManager != null:
					HatsuProgressionManager.equipar_hatsu(slot_id, hatsu.hatsu_id)
				else:
					hatsu_slots[i] = index
				print("[PlayerData] Hatsu auto-equipado no slot ", i + 1, " (ID: ", hatsu.hatsu_id, ")")
				break

	print("[PlayerData] Hatsu registrado com sucesso: '%s' [ID: %s] | Total de Hatsus: %d" % [hatsu.nome, hatsu.hatsu_id, hatsu_criados.size()])
	return index


func obter_hatsu_por_id(id: String) -> HatsuData:
	if id.is_empty():
		return null
	if HatsuProgressionManager != null:
		return HatsuProgressionManager.obter_hatsu_archive_por_id(id)
	for h in hatsu_criados:
		if h is HatsuData and h.hatsu_id == id:
			return h
	return null


func remover_hatsu(index: int) -> bool:
	if index < 0 or index >= hatsu_criados.size():
		return false
	var h: HatsuData = hatsu_criados[index] as HatsuData
	if HatsuProgressionManager != null and h != null:
		var res: Dictionary = HatsuProgressionManager.excluir_hatsu_archive(h.hatsu_id)
		return res.get("success", false)

	# Fallback legado
	for s in range(hatsu_slots.size()):
		if hatsu_slots[s] == index:
			hatsu_slots[s] = -1
		elif hatsu_slots[s] > index:
			hatsu_slots[s] -= 1
	hatsu_criados.remove_at(index)
	return true


func equipar_hatsu(slot: int, hatsu_index: int) -> bool:
	if slot < 0 or slot >= hatsu_slots.size():
		return false
	if hatsu_index < 0 or hatsu_index >= hatsu_criados.size():
		return false

	var slot_id: int = slot + 1
	if HatsuProgressionManager != null:
		return HatsuProgressionManager.equipar_hatsu(slot_id, hatsu_index)

	hatsu_slots[slot] = hatsu_index
	return true


func equipar_hatsu_slot(slot: int, hatsu: HatsuData) -> bool:
	if hatsu == null or slot < 0 or slot >= hatsu_slots.size():
		return false
	var slot_id: int = slot + 1
	if HatsuProgressionManager != null and not HatsuProgressionManager.is_slot_unlocked(slot_id):
		push_warning("[PlayerData] Bloqueio anti-bypass: Slot %d não está desbloqueado para equipar Hatsu!" % slot_id)
		return false
	var idx: int = adicionar_hatsu(hatsu)
	if idx < 0:
		return false
	return equipar_hatsu(slot, idx)


func desequipar_hatsu(slot: int) -> void:
	if slot >= 0 and slot < hatsu_slots.size():
		var slot_id: int = slot + 1
		if HatsuProgressionManager != null:
			HatsuProgressionManager.desequipar_hatsu(slot_id)
		else:
			hatsu_slots[slot] = -1


func obter_hatsu_slot(slot: int) -> HatsuData:
	if slot < 0 or slot >= hatsu_slots.size():
		return null

	var slot_id: int = slot + 1
	if HatsuProgressionManager != null:
		return HatsuProgressionManager.obter_hatsu_ativo(slot_id)

	var idx: int = hatsu_slots[slot]
	if idx < 0 or idx >= hatsu_criados.size():
		return null
	return hatsu_criados[idx] as HatsuData


# ============================================================
# ARMAZENAMENTO DE HATSUS ROUBADOS / COPIADOS (LIVRO / STORAGE)
# ============================================================

func adicionar_hatsu_armazenado(hatsu: HatsuData, source_name: String = "Inimigo", remaining_uses: int = -1, max_capacity: int = 5) -> Dictionary:
	if hatsu == null:
		return {"sucesso": false, "mensagem": "Hatsu inválido"}
	
	if stored_hatsus.size() >= max_capacity:
		return {"sucesso": false, "mensagem": "Capacidade do Livro cheia (%d/%d)" % [stored_hatsus.size(), max_capacity]}
	
	var entry := {
		"id": "stored_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 1000),
		"source_name": source_name,
		"hatsu_data": hatsu,
		"remaining_uses": remaining_uses,
		"acquired_at": Time.get_datetime_string_from_system(),
		"active": true
	}
	stored_hatsus.append(entry)
	print("[PlayerData] 📖 Hatsu armazenado no Livro com sucesso: %s (Fonte: %s)" % [hatsu.nome, source_name])
	return {"sucesso": true, "mensagem": "Hatsu armazenado com sucesso!", "index": stored_hatsus.size() - 1, "entry": entry}


func remover_hatsu_armazenado(index: int) -> bool:
	if index < 0 or index >= stored_hatsus.size():
		return false
	stored_hatsus.remove_at(index)
	return true


func obter_todos_hatsus_armazenados() -> Array[Dictionary]:
	return stored_hatsus


func obter_hatsu_armazenado(index: int) -> Dictionary:
	if index >= 0 and index < stored_hatsus.size():
		return stored_hatsus[index]
	return {}


func consumir_uso_hatsu_armazenado(index: int) -> bool:
	if index < 0 or index >= stored_hatsus.size():
		return false
	var entry = stored_hatsus[index]
	var rem: int = int(entry.get("remaining_uses", -1))
	if rem > 0:
		rem -= 1
		entry["remaining_uses"] = rem
		if rem == 0:
			print("[PlayerData] 📖 Usos de %s esgotados! Hatsu removido do Livro." % entry.get("hatsu_data").nome)
			stored_hatsus.remove_at(index)
			return true
	return false


func adicionar_gold(quantidade: int) -> void:
	Economy.adicionar_gold(quantidade)


func adicionar_ouro(quantidade: int) -> void:
	Economy.adicionar_gold(quantidade)


# ============================================================
# TÍTULOS E SEGREDO
# ============================================================

func desbloquear_titulo(titulo: String) -> void:
	if not titulos_desbloqueados.has(titulo):
		titulos_desbloqueados.append(titulo)
		print("[PlayerData] 🎖️ TÍTULO DESBLOQUEADO: ", titulo)
		var ach_sys = Engine.get_main_loop().root.get_node_or_null("/root/AchievementSystem") if Engine.get_main_loop() else null
		if ach_sys and ach_sys.has_method("verificar_todas_conquistas"):
			ach_sys.verificar_todas_conquistas()


func equipar_titulo(titulo: String) -> bool:
	if titulos_desbloqueados.has(titulo):
		titulo_equipado = titulo
		print("[PlayerData] Título equipado: ", titulo)
		
		# Limpar modificadores de títulos anteriores
		remover_modificadores_da_fonte("titulo")
		
		# Aplicar bônus passivo do título equipado
		var t_lower = titulo.to_lower()
		if "hunter" in t_lower:
			adicionar_modificador(StatModifier.new(&"mod_titulo_hunter_forca", &"forca", StatModifier.Type.FLAT, 3.0, -1.0, "titulo"))
			adicionar_modificador(StatModifier.new(&"mod_titulo_hunter_defesa", &"defesa", StatModifier.Type.FLAT, 3.0, -1.0, "titulo"))
			adicionar_modificador(StatModifier.new(&"mod_titulo_hunter_vel", &"velocidade", StatModifier.Type.FLAT, 2.0, -1.0, "titulo"))
		elif "pacificador" in t_lower or "zaban" in t_lower:
			adicionar_modificador(StatModifier.new(&"mod_titulo_zaban_hp", &"vida_max", StatModifier.Type.FLAT, 25.0, -1.0, "titulo"))
			adicionar_modificador(StatModifier.new(&"mod_titulo_zaban_def", &"defesa", StatModifier.Type.FLAT, 5.0, -1.0, "titulo"))
		elif "ten" in t_lower:
			adicionar_modificador(StatModifier.new(&"mod_titulo_ten_def", &"defesa", StatModifier.Type.FLAT, 6.0, -1.0, "titulo"))
		elif "ko" in t_lower:
			adicionar_modificador(StatModifier.new(&"mod_titulo_ko_forca", &"forca", StatModifier.Type.FLAT, 6.0, -1.0, "titulo"))
			
		recalcular_todos_atributos()
		
		var ply = Engine.get_main_loop().root.get_tree().get_first_node_in_group("player") if Engine.get_main_loop() else null
		if ply and ply.has_node("PlayerNameLabel"):
			var lbl = ply.get_node("PlayerNameLabel") as Label
			if lbl:
				lbl.text = "%s\n[%s]" % [nome_personagem, titulo_equipado]
		return true
	return false


func registrar_segredo(segredo_id: String) -> void:
	if not segredos_descobertos.has(segredo_id):
		segredos_descobertos.append(segredo_id)
		print("[PlayerData] 🔍 SEGREDO REGISTRADO: ", segredo_id)
		if GameState != null:
			GameState.salvar_jogo()


# ============================================================
# CONHECIMENTO & HUNTER GUIDE
# ============================================================

func desbloquear_conhecimento(conhecimento_id: String, categoria: String = "") -> bool:
	if not conhecimentos_desbloqueados.has(conhecimento_id):
		conhecimentos_desbloqueados.append(conhecimento_id)
		print("[PlayerData] 📖 NOVO CONHECIMENTO DESBLOQUEADO: ", conhecimento_id, " (Cat: ", categoria, ")")
		if EventBus != null:
			EventBus.tutorial_knowledge_unlocked.emit(conhecimento_id, categoria)
			EventBus.emit_toast("📖 Novo Conhecimento: " + conhecimento_id.replace("_", " ").capitalize(), Color(0.4, 0.9, 1.0))
		return true
	return false


func tem_conhecimento(conhecimento_id: String) -> bool:
	return conhecimentos_desbloqueados.has(conhecimento_id)


func concluir_etapa_tutorial(etapa_id: String) -> void:
	tutorial_data[etapa_id] = true
	print("[PlayerData] Etapa de tutorial concluída: ", etapa_id)


# ============================================================
# GERADOR DE HUNTER LEVEL 100 / DEBUG PLAYTEST ENGINE
# ============================================================

func debug_create_level_100_hunter(equip_all_hatsus: bool = true) -> Dictionary:
	# 1. Snapshot de segurança antes da alteração
	if backup_state_before_debug.is_empty():
		backup_state_before_debug = {
			"attributes": attributes.duplicate(true),
			"tecnicas_nen": tecnicas_nen.duplicate(true),
			"hatsu_slots": hatsu_slots.duplicate(true),
			"despertou_nen": despertou_nen,
			"hatsu_desbloqueado": hatsu_desbloqueado,
			"hatsu_creation_unlocked": hatsu_creation_unlocked,
			"besta_nen_desbloqueada": besta_nen_desbloqueada,
			"titulo_equipado": titulo_equipado
		}

	var old_level: int = int(attributes.get("nivel", 1))
	var old_xp: int = int(attributes.get("xp", 0))

	# 2. Modo Debug Ativo
	is_debug_mode = true

	# 3. Progressão de Nível e Nível de Nen
	attributes["nivel"] = 100
	attributes["nivel_nen"] = 100
	var xp_tabelado: int = ProgressionConfig.calcular_xp_necessario(100)
	attributes["xp"] = xp_tabelado
	attributes["xp_nen"] = 1000000
	attributes["gold"] = max(int(attributes.get("gold", 0)), 999999)

	despertou_nen = true
	hatsu_creation_unlocked = true
	hatsu_desbloqueado = true
	besta_nen_desbloqueada = true
	titulo_equipado = "Hunter Supremo (Lvl 100 Debug)"

	# 4. Desbloqueio e Nível 100 em Todas as 9 Técnicas de Nen
	tecnicas_nen = {
		"ten": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"ren": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"zetsu": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"gyo": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"shu": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"ko": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"en": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"ken": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"ryu": {"nivel": 100, "xp": 0, "desbloqueada": true}
	}

	# 5. Recálculo Oficial de Atributos (Pipeline Canônica)
	recalcular_todos_atributos()
	attributes["vida"] = attributes["vida_max"]
	attributes["aura"] = attributes["aura_max"]

	# 6. Equipamento de Hatsus Modulares Canônicos se solicitado
	var hatsu_status_str := "READY"
	if equip_all_hatsus:
		popular_hatsus_iniciais()
		if hatsu_criados.size() >= 4:
			hatsu_slots = [0, 1, 2, 3]
	else:
		if hatsu_criados.is_empty():
			hatsu_status_str = "NOT AVAILABLE"

	# 7. Sincronização com nós em cena (XPSystem, NenSystem, Player)
	var nen_status_str := "READY"
	var tree := get_tree()
	if tree != null:
		var xp_sys = tree.get_first_node_in_group("xp_system")
		if xp_sys != null and xp_sys.has_method("sincronizar_com_player_data"):
			xp_sys.sincronizar_com_player_data()
		
		var nen_sys = tree.get_first_node_in_group("nen_system")
		if nen_sys != null and nen_sys.has_method("sincronizar_com_player_data"):
			nen_sys.sincronizar_com_player_data()

	# 8. Log Estruturado
	print("========================================")
	print("DEBUG HUNTER GENERATOR")
	print("========================================")
	print("DEBUG MODE: ON")
	print("OLD LEVEL: %d" % old_level)
	print("NEW LEVEL: 100")
	print("OLD XP: %d" % old_xp)
	print("NEW XP: %d" % xp_tabelado)
	print("HP: %d / %d" % [attributes["vida"], attributes["vida_max"]])
	print("FORÇA: %d" % attributes["forca"])
	print("DEFESA: %d" % attributes["defesa"])
	print("AURA: %d / %d" % [int(attributes["aura"]), int(attributes["aura_max"])])
	print("NEN: %s" % nen_status_str)
	print("HATSU SYSTEM: %s" % hatsu_status_str)
	print("========================================")

	return {
		"status": "SUCCESS",
		"old_level": old_level,
		"new_level": 100,
		"attributes": attributes.duplicate()
	}


func reset_debug_character() -> bool:
	if not backup_state_before_debug.is_empty():
		attributes = backup_state_before_debug.get("attributes", attributes).duplicate(true)
		tecnicas_nen = backup_state_before_debug.get("tecnicas_nen", tecnicas_nen).duplicate(true)
		hatsu_slots = backup_state_before_debug.get("hatsu_slots", hatsu_slots).duplicate(true)
		despertou_nen = backup_state_before_debug.get("despertou_nen", false)
		hatsu_desbloqueado = backup_state_before_debug.get("hatsu_desbloqueado", false)
		hatsu_creation_unlocked = backup_state_before_debug.get("hatsu_creation_unlocked", false)
		besta_nen_desbloqueada = backup_state_before_debug.get("besta_nen_desbloqueada", false)
		titulo_equipado = backup_state_before_debug.get("titulo_equipado", "Novato")
		backup_state_before_debug.clear()
	else:
		reset()

	is_debug_mode = false
	recalcular_todos_atributos()
	attributes["vida"] = attributes["vida_max"]
	attributes["aura"] = attributes["aura_max"]

	var tree := get_tree()
	if tree != null:
		var xp_sys = tree.get_first_node_in_group("xp_system")
		if xp_sys != null and xp_sys.has_method("sincronizar_com_player_data"):
			xp_sys.sincronizar_com_player_data()
		
		var nen_sys = tree.get_first_node_in_group("nen_system")
		if nen_sys != null and nen_sys.has_method("sincronizar_com_player_data"):
			nen_sys.sincronizar_com_player_data()

	var cur_lvl = int(attributes.get("nivel", 1))
	print("========================================")
	print("DEBUG HUNTER RESET")
	print("========================================")
	print("DEBUG MODE: OFF")
	print("LEVEL: %d" % cur_lvl)
	print("========================================")
	return true


func debug_set_level(target_level: int, awaken_nen: bool = true) -> Dictionary:
	var lvl_clamped: int = clamp(target_level, ProgressionConfig.BASE_LEVEL, ProgressionConfig.MAX_LEVEL)
	attributes["nivel"] = lvl_clamped
	attributes["xp"] = ProgressionConfig.calcular_xp_necessario(lvl_clamped)
	if awaken_nen:
		despertou_nen = true
		attributes["nivel_nen"] = min(100, int(lvl_clamped / 10))
	recalcular_todos_atributos()
	attributes["vida"] = attributes["vida_max"]
	attributes["aura"] = attributes["aura_max"]
	
	var tree := get_tree()
	if tree != null:
		var xp_sys = tree.get_first_node_in_group("xp_system")
		if xp_sys != null and xp_sys.has_method("sincronizar_com_player_data"):
			xp_sys.sincronizar_com_player_data()
			
		var nen_sys = tree.get_first_node_in_group("nen_system")
		if nen_sys != null and nen_sys.has_method("sincronizar_com_player_data"):
			nen_sys.sincronizar_com_player_data()
	
	nivel_alterado.emit(lvl_clamped)
	return {
		"level": lvl_clamped,
		"attributes": attributes.duplicate()
	}

