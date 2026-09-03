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
	EN,
	KO,
	RYU_OFENSIVO,
	RYU_DEFENSIVO,
	RYU_EQUILIBRADO,
	SHU,
	COMPORTAMENTAL,
	SINERGIA
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
	var categoria: int = 0
	var custo_pontos: int = 1
	var nivel_max: int = 1
	var pre_requisitos: Array[String] = []
	var efeitos: Array = []
	var conditions: Array = []
	var tags: Array[String] = []

	func _init(
		p_id: String,
		p_nome: String,
		p_descricao: String,
		p_categoria: int,
		p_nivel_max: int,
		p_pre_requisitos: Array[String],
		p_efeitos: Array,
		p_conditions: Array = [],
		p_tags: Array = []
	) -> void:
		id = p_id
		nome = p_nome
		descricao = p_descricao
		categoria = p_categoria
		nivel_max = p_nivel_max
		pre_requisitos = p_pre_requisitos
		efeitos = p_efeitos
		conditions = p_conditions
		tags = GameplayTags.normalize(p_tags)

	func is_contextual() -> bool:
		return not conditions.is_empty()


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
	sincronizar_com_player_data()

	print("=================================")
	print("NEN SKILL TREE INICIADA")
	print("Nós registrados: ", node_definitions.size())
	print("=================================")


func sincronizar_com_player_data() -> void:
	if PlayerData == null:
		return
	if not PlayerData.nen_skill_tree_progress.is_empty():
		for node_id in PlayerData.nen_skill_tree_progress.keys():
			node_levels[node_id] = PlayerData.nen_skill_tree_progress[node_id]
	if not PlayerData.nen_ryu_caminho.is_empty():
		ryu_caminho = PlayerData.nen_ryu_caminho
	recalcular_todos_modificadores()


func resetar_arvore() -> void:
	_inicializar_niveis()
	ryu_caminho = ""
	if PlayerData != null:
		PlayerData.remover_modificadores_da_fonte("nen_skill_tree")
		PlayerData.remover_modificadores_da_fonte("nen_skill_tree_contextual")


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
	# ZETSU — Furtividade Ativa (Stealth Real) & Regeneração
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"zetsu_1", "ZETSU I", "Furtividade +20% | Reducao de Deteccao -20%",
		Categoria.ZETSU, 1, [],
		[
			{"stat": "zetsu_stealth", "tipo": TipoMod.PERCENTAGE, "valor": 0.20},
			{"stat": "regen_hp", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"zetsu_2", "ZETSU II", "Furtividade +35% | Reducao de Deteccao -35%",
		Categoria.ZETSU, 1, ["zetsu_1"],
		[
			{"stat": "zetsu_stealth", "tipo": TipoMod.PERCENTAGE, "valor": 0.15},
			{"stat": "regen_hp", "tipo": TipoMod.PERCENTAGE, "valor": 0.20}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"zetsu_3", "ZETSU III", "Furtividade +50% | Reducao de Deteccao -50%",
		Categoria.ZETSU, 1, ["zetsu_2"],
		[
			{"stat": "zetsu_stealth", "tipo": TipoMod.PERCENTAGE, "valor": 0.15},
			{"stat": "regen_hp", "tipo": TipoMod.PERCENTAGE, "valor": 0.30}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"zetsu_4", "ZETSU IV", "Furtividade +65% | Reducao de Deteccao -65%",
		Categoria.ZETSU, 1, ["zetsu_3"],
		[
			{"stat": "zetsu_stealth", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"zetsu_5", "ZETSU V", "Mestre da Ocultacao: Furtividade +80%",
		Categoria.ZETSU, 1, ["zetsu_4"],
		[
			{"stat": "zetsu_stealth", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}
		]
	))

	# ======================================================
	# REN — Alcance de Ataque & Dano Físico
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"ren_1", "REN I", "Alcance +5% | Dano +5%",
		Categoria.REN, 1, [],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}, {"stat": "dano_fisico", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ren_2", "REN II", "Alcance +10% | Dano +10%",
		Categoria.REN, 1, ["ren_1"],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}, {"stat": "dano_fisico", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ren_3", "REN III", "Alcance +15% | Dano +15%",
		Categoria.REN, 1, ["ren_2"],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}, {"stat": "dano_fisico", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ren_4", "REN IV", "Alcance +20% | Dano +20%",
		Categoria.REN, 1, ["ren_3"],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.20}, {"stat": "dano_fisico", "tipo": TipoMod.PERCENTAGE, "valor": 0.20}]
	))
	_adicionar_no(SkillNodeDef.new(
		"ren_5", "REN V", "Alcance +25% | Dano +25%",
		Categoria.REN, 1, ["ren_4"],
		[{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.25}, {"stat": "dano_fisico", "tipo": TipoMod.PERCENTAGE, "valor": 0.25}]
	))

	# ======================================================
	# EN — Deteccao Espacial e Intimidacao em Area
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"en_1", "EN I", "Raio de En +60px | Intimidacao -5% Defesa Inimiga",
		Categoria.EN, 1, [],
		[
			{"stat": "en_range", "tipo": TipoMod.FLAT, "valor": 60.0},
			{"stat": "en_intimidation_defense_reduction", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"en_2", "EN II", "Raio de En +120px | Intimidacao -10% Defesa Inimiga",
		Categoria.EN, 1, ["en_1"],
		[
			{"stat": "en_range", "tipo": TipoMod.FLAT, "valor": 60.0},
			{"stat": "en_intimidation_defense_reduction", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"en_3", "EN III", "Raio de En +180px | Intimidacao -15% Defesa Inimiga",
		Categoria.EN, 1, ["en_2"],
		[
			{"stat": "en_range", "tipo": TipoMod.FLAT, "valor": 60.0},
			{"stat": "en_intimidation_defense_reduction", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"en_4", "EN IV", "Raio de En +240px | Intimidacao -20% Defesa Inimiga",
		Categoria.EN, 1, ["en_3"],
		[
			{"stat": "en_range", "tipo": TipoMod.FLAT, "valor": 60.0},
			{"stat": "en_intimidation_defense_reduction", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"en_5", "EN V", "Cupula Imperial: Raio +330px | Intimidacao -30% Defesa",
		Categoria.EN, 1, ["en_4"],
		[
			{"stat": "en_range", "tipo": TipoMod.FLAT, "valor": 90.0},
			{"stat": "en_intimidation_defense_reduction", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}
		]
	))

	# ======================================================
	# GYO — Percepcao Multi-Tier e Revelacao de Segredos
	# ======================================================
	_adicionar_no(SkillNodeDef.new(
		"gyo_1", "GYO I", "Percepcao Tier 1 (Segredos Faceis) | Esquiva +3%",
		Categoria.GYO, 1, [],
		[
			{"stat": "gyo_perception_level", "tipo": TipoMod.FLAT, "valor": 1.0},
			{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.03}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"gyo_2", "GYO II", "Percepcao Tier 2 (Segredos Intermediarios) | Esquiva +6%",
		Categoria.GYO, 1, ["gyo_1"],
		[
			{"stat": "gyo_perception_level", "tipo": TipoMod.FLAT, "valor": 1.0},
			{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.06}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"gyo_3", "GYO III", "Percepcao Tier 3 (Segredos Avancados) | Critico +5%",
		Categoria.GYO, 1, ["gyo_2"],
		[
			{"stat": "gyo_perception_level", "tipo": TipoMod.FLAT, "valor": 1.0},
			{"stat": "critico", "tipo": TipoMod.PERCENTAGE, "valor": 0.05}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"gyo_4", "GYO IV", "Percepcao Tier 4 | Critico +10%",
		Categoria.GYO, 1, ["gyo_3"],
		[
			{"stat": "gyo_perception_level", "tipo": TipoMod.FLAT, "valor": 1.0},
			{"stat": "critico", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}
		]
	))
	_adicionar_no(SkillNodeDef.new(
		"gyo_5", "GYO V", "Olhar da Verdade Absoluto (Tier 5) | Critico +15%",
		Categoria.GYO, 1, ["gyo_4"],
		[
			{"stat": "gyo_perception_level", "tipo": TipoMod.FLAT, "valor": 1.0},
			{"stat": "critico", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}
		]
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

	# ======================================================
	# NÓS COMPORTAMENTAIS (CONTEXTUAL / GAMEPLAY CONDITIONS)
	# ======================================================

	# 1. First Strike: Golpe de abertura após tempo sem sofrer dano
	var cond_first_strike := GameplayCondition.new()
	cond_first_strike.condition_type = GameplayCondition.Type.NO_DAMAGE_FOR_SECONDS
	cond_first_strike.threshold = 4.0
	_adicionar_no(SkillNodeDef.new(
		"first_strike", "First Strike", "Golpe de Abertura: Força +20% ao atacar sem ter sofrido dano nos últimos 4s",
		Categoria.COMPORTAMENTAL, 1, ["ren_1"],
		[{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.20}],
		[cond_first_strike],
		["offensive", "first_strike", "burst"]
	))

	# 2. Bloodied: Sobrevivência crítica quando a vida cai
	var cond_bloodied := GameplayCondition.new()
	cond_bloodied.condition_type = GameplayCondition.Type.PLAYER_HP_BELOW
	cond_bloodied.threshold = 0.35
	_adicionar_no(SkillNodeDef.new(
		"bloodied", "Bloodied", "Sobrevivência Crítica: Força +20% e Defesa +15% quando a Vida estiver abaixo de 35%",
		Categoria.COMPORTAMENTAL, 1, ["ten_2"],
		[
			{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.20},
			{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}
		],
		[cond_bloodied],
		["offensive", "defensive", "bloodied", "survival"]
	))

	# 3. Surrounded: Defesa espacial e esquiva ao ser cercado
	var cond_surrounded := GameplayCondition.new()
	cond_surrounded.condition_type = GameplayCondition.Type.ENEMIES_NEARBY_AT_LEAST
	cond_surrounded.required_count = 3
	_adicionar_no(SkillNodeDef.new(
		"surrounded", "Surrounded", "Defesa Cercada: Defesa +25% e Esquiva +10% contra 3 ou mais inimigos próximos",
		Categoria.COMPORTAMENTAL, 1, ["gyo_2"],
		[
			{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.25},
			{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}
		],
		[cond_surrounded],
		["defensive", "surrounded", "awareness"]
	))

	# 4. Isolated Target: Duelo 1x1 focado
	var cond_isolated := GameplayCondition.new()
	cond_isolated.condition_type = GameplayCondition.Type.SINGLE_TARGET
	cond_isolated.required_count = 1
	_adicionar_no(SkillNodeDef.new(
		"isolated_target", "Isolated Target", "Predador Solitário: Força +15% e Velocidade +10% em combate contra alvo isolado",
		Categoria.COMPORTAMENTAL, 1, ["ko_1"],
		[
			{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.15},
			{"stat": "velocidade", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}
		],
		[cond_isolated],
		["offensive", "single_target", "isolated_target"]
	))

	# 5. Hunter's Mark: Amplificação contra presa marcada
	var cond_hunters_mark := GameplayCondition.new()
	cond_hunters_mark.condition_type = GameplayCondition.Type.TARGET_MARKED
	_adicionar_no(SkillNodeDef.new(
		"hunters_mark", "Hunter's Mark", "Foco no Marcado: Força +20% e Alcance +15% contra alvos marcados",
		Categoria.COMPORTAMENTAL, 1, ["gyo_2"],
		[
			{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.20},
			{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.15}
		],
		[cond_hunters_mark],
		["offensive", "mark", "hunters_mark"]
	))

	# ======================================================
	# SINERGIAS ENTRE TÉCNICAS (FUNDAMENTAL NEN SYNERGIES)
	# ======================================================

	# 1. Ken: Blindagem avançada combinando Ten e Ren
	_adicionar_no(SkillNodeDef.new(
		"ken_mastery", "Ken: Mestre da Blindagem", "Sinergia Ten + Ren: Sustenta proteção densa de aura. Defesa +15%, Força +10%",
		Categoria.SINERGIA, 1, ["ten_3", "ren_3"],
		[
			{"stat": "defesa", "tipo": TipoMod.PERCENTAGE, "valor": 0.15},
			{"stat": "forca", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}
		],
		[],
		["nen_synergy", "ken", "defensive", "offensive"]
	))

	# 2. In: Ocultação refinada combinando Zetsu e Gyo
	_adicionar_no(SkillNodeDef.new(
		"in_mastery", "In: Mestre da Ocultação", "Sinergia Zetsu + Gyo: Camufla aura enquanto afia sentidos. Esquiva +15%, Velocidade +10%",
		Categoria.SINERGIA, 1, ["zetsu_2", "gyo_2"],
		[
			{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.15},
			{"stat": "velocidade", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}
		],
		[],
		["nen_synergy", "in", "stealth", "perception"]
	))

	# 3. En: Expansão do campo de percepção combinando Gyo e Ren
	var cond_en := GameplayCondition.new()
	cond_en.condition_type = GameplayCondition.Type.PLAYER_IN_EN
	_adicionar_no(SkillNodeDef.new(
		"en_expansion", "En: Expansão Sensorial", "Sinergia Gyo + Ren: Projeta aura em campo esférico. Alcance +25% e Esquiva +10% enquanto em En",
		Categoria.SINERGIA, 1, ["gyo_3", "ren_3"],
		[
			{"stat": "alcance", "tipo": TipoMod.PERCENTAGE, "valor": 0.25},
			{"stat": "esquiva", "tipo": TipoMod.PERCENTAGE, "valor": 0.10}
		],
		[cond_en],
		["nen_synergy", "en", "awareness", "range"]
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

	# Nós com condições contextuais são ativados dinamicamente via contexto de combate
	if nivel <= 0 or def.is_contextual():
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
	var modifier_type: StatModifier.Type = StatModifier.Type.FLAT
	if tipo == TipoMod.PERCENTAGE:
		modifier_type = StatModifier.Type.PERCENTAGE
	return StatModifier.new(mod_id, StringName(stat_name), modifier_type, valor, -1.0, source)


# ============================================================
# RECALCULAR TODOS OS MODIFICADORES
# ============================================================
#
# Remove todos os modificadores das fontes "nen_skill_tree" e
# "nen_skill_tree_contextual" e reaplica nós estáticos investidos.
#
# Usado ao carregar save ou após respec.
#
# ============================================================

func recalcular_todos_modificadores() -> void:
	# Remover todos os modificadores da Skill Tree (estáticos e contextuais)
	PlayerData.remover_modificadores_da_fonte("nen_skill_tree")
	PlayerData.remover_modificadores_da_fonte("nen_skill_tree_contextual")

	# Reaplicar todos os nós estáticos investidos
	for node_id in node_levels:
		if node_levels[node_id] > 0:
			_aplicar_modificadores_do_no(node_id)


# ============================================================
# AVALIAÇÃO CONTEXTUAL E SINERGIAS (GAMEPLAY CONDITION & STATS)
# ============================================================

## Avalia se as condições de um nó são atendidas com base no dicionário de contexto fornecido.
func avaliar_condicoes_no(node_id: String, contexto: Dictionary) -> Dictionary:
	if not node_definitions.has(node_id):
		return {"met": false, "motivo": "Nó inexistente: " + node_id, "detalhes": []}

	var def: SkillNodeDef = node_definitions[node_id]
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


## Retorna a lista de instâncias de StatModifier que seriam ativadas pelo contexto atual.
func obter_modificadores_contextuais_ativos(contexto: Dictionary) -> Array:
	var mods_ativos: Array = []
	for node_id in node_levels:
		if node_levels[node_id] <= 0:
			continue
		if not node_definitions.has(node_id):
			continue
		var def: SkillNodeDef = node_definitions[node_id]
		if not def.is_contextual():
			continue

		var avaliacao := avaliar_condicoes_no(node_id, contexto)
		if avaliacao.get("met", false):
			for i in range(def.efeitos.size()):
				var efeito: Dictionary = def.efeitos[i]
				var mod_id: StringName = StringName("nen_st_ctx_" + node_id + "_" + str(i))
				var mod = _criar_modificador(
					mod_id,
					efeito.get("stat", ""),
					efeito.get("tipo", TipoMod.PERCENTAGE),
					efeito.get("valor", 0.0),
					"nen_skill_tree_contextual"
				)
				if mod != null:
					mods_ativos.append(mod)
	return mods_ativos


## Atualiza dinamicamente o pipeline de StatModifier em PlayerData com base no contexto.
## Retorna quais nós contextuais foram ativados e quais modificadores foram aplicados.
func atualizar_modificadores_contextuais(contexto: Dictionary) -> Dictionary:
	var nos_ativos: Array[String] = []
	var mods_aplicados: Array = []

	for node_id in node_definitions:
		var def: SkillNodeDef = node_definitions[node_id]
		if not def.is_contextual():
			continue

		var nivel: int = node_levels.get(node_id, 0)
		var ativado := false
		if nivel > 0:
			var avaliacao := avaliar_condicoes_no(node_id, contexto)
			if avaliacao.get("met", false):
				ativado = true

		if ativado:
			nos_ativos.append(node_id)
			for i in range(def.efeitos.size()):
				var efeito: Dictionary = def.efeitos[i]
				var mod_id: StringName = StringName("nen_st_ctx_" + node_id + "_" + str(i))
				var mod = _criar_modificador(
					mod_id,
					efeito.get("stat", ""),
					efeito.get("tipo", TipoMod.PERCENTAGE),
					efeito.get("valor", 0.0),
					"nen_skill_tree_contextual"
				)
				if mod != null:
					PlayerData.adicionar_modificador(mod)
					mods_aplicados.append(mod)
		else:
			for i in range(def.efeitos.size()):
				var mod_id: StringName = StringName("nen_st_ctx_" + node_id + "_" + str(i))
				PlayerData.remover_modificador(mod_id)

	return {
		"nos_ativos": nos_ativos,
		"modificadores": mods_aplicados
	}


## Remove todos os modificadores de contexto da Skill Tree ativos no PlayerData.
func limpar_modificadores_contextuais() -> void:
	PlayerData.remover_modificadores_da_fonte("nen_skill_tree_contextual")


## Retorna as tags canônicas configuradas em um nó.
func obter_tags_no(node_id: String) -> Array[String]:
	if node_definitions.has(node_id):
		return (node_definitions[node_id] as SkillNodeDef).tags.duplicate()
	return []


## Verifica se o nó possui uma tag específica.
func no_tem_tag(node_id: String, required_tag: String) -> bool:
	if node_definitions.has(node_id):
		return GameplayTags.has_tag((node_definitions[node_id] as SkillNodeDef).tags, required_tag)
	return false


# ============================================================
# CONSULTAS
# ============================================================

func obter_nivel_no(node_id: String) -> int:
	return node_levels.get(node_id, 0)


func obter_progresso_no(node_id: String) -> int:
	return node_levels.get(node_id, 0)


func obter_pontos_disponiveis() -> int:
	return PlayerData.nen_skill_points if PlayerData != null else 0


func pode_investir(node_id: String) -> bool:
	if not node_definitions.has(node_id):
		return false
	var def: SkillNodeDef = node_definitions[node_id]
	var nivel_atual: int = node_levels.get(node_id, 0)
	if nivel_atual >= def.nivel_max:
		return false
	if PlayerData == null or PlayerData.nen_skill_points <= 0:
		return false
	for prereq in def.pre_requisitos:
		if node_levels.get(prereq, 0) <= 0:
			return false
	if _eh_no_ryu(node_id):
		if ryu_caminho != "" and ryu_caminho != _extrair_caminho_ryu(node_id):
			return false
	return true


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


func obter_nos_contextuais() -> Array:
	var lista: Array = []
	for node_id in node_definitions:
		var def: SkillNodeDef = node_definitions[node_id]
		if def.is_contextual():
			lista.append(def)
	return lista


func obter_nos_sinergia() -> Array:
	var lista: Array = []
	for node_id in node_definitions:
		var def: SkillNodeDef = node_definitions[node_id]
		if def.categoria == Categoria.SINERGIA:
			lista.append(def)
	return lista


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
