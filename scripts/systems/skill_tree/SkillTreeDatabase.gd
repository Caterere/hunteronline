class_name SkillTreeDatabase
extends RefCounted

# ==============================================================================
# HUNTER ONLINE — SKILL TREE DATABASE (400+ DATA-DRIVEN PROGRESSION NODES)
# ==============================================================================
# Repositório central de dados da constelação de progressão.
# Organizado em 10 Regiões Temáticas dispostas radialmente ao redor do Nexus:
# 1. BODY (Norte-Noroeste) — Vida Máx, Defesa, Resistência, Mitigação
# 2. WARRIOR (Norte-Nordeste) — Dano Básico, Cadência, Combo, Dano Físico
# 3. NEN (Leste) — Fundamentos Ten, Ren, Gyo, Zetsu, En, Ken, Ko, Ryu, Shu
# 4. HATSU (Sudeste) — Dano de Hatsu, Cooldown, Custo de Aura, Área, Penetração
# 5. SPEED (Sul-Sudeste) — Velocidade, Evasão, Mobilidade, Esquiva
# 6. CRITICAL (Sul-Sudoeste) — Chance Crítica, Dano Crítico, Execução
# 7. VITALITY (Sudoeste) — Regeneração de Vida, Life Steal, Cura, Sustain
# 8. AURA (Oeste) — Aura Máxima, Regeneração de Aura, Eficiência de Custo
# 9. SPECIALIZATION (Noroeste) — Keystones com regras alteradas e tradeoffs
# 10. MASTER (Anel Externo) — Maestria Suprema, nós híbridos e sinergias
# ==============================================================================

const REGIONS: Dictionary = {
	&"nexus": {
		"name": "Nexus Inicial",
		"desc": "O despertar do potencial latente do Hunter.",
		"color": Color(1.0, 0.9, 0.4),
		"angle": 0.0
	},
	&"body": {
		"name": "Fortaleza Corpórea",
		"desc": "Condicionamento físico extremo, densidade muscular e armadura biológica.",
		"color": Color(0.3, 0.7, 1.0),
		"angle": -PI * 0.40 # ~-72°
	},
	&"warrior": {
		"name": "Arte Marcial do Caçador",
		"desc": "Golpes impiedosos, cadência de ataques básicos e controle de postura.",
		"color": Color(1.0, 0.35, 0.2),
		"angle": -PI * 0.20 # ~-36°
	},
	&"nen": {
		"name": "Fundamentos do Nen",
		"desc": "Maestria das técnicas de Shingen-ryu: Ten, Ren, Zetsu, Gyo, Ko, En, Ryu.",
		"color": Color(0.3, 0.95, 0.6),
		"angle": 0.0 # 0° Leste
	},
	&"hatsu": {
		"name": "Canalização de Hatsu",
		"desc": "Potência destrutiva, ressonância elemental, área e eficiência de habilidades.",
		"color": Color(0.85, 0.4, 1.0),
		"angle": PI * 0.20 # ~36°
	},
	&"speed": {
		"name": "Mobilidade Fantasma",
		"desc": "Agilidade supersônica, passos evasivos e reposicionamento instantâneo.",
		"color": Color(0.2, 0.85, 0.95),
		"angle": PI * 0.40 # ~72°
	},
	&"critical": {
		"name": "Instinto Predatório & Crítico",
		"desc": "Foco cirúrgico em pontos vitais, golpes fatais e multiplicadores extremos.",
		"color": Color(1.0, 0.8, 0.1),
		"angle": PI * 0.60 # ~108°
	},
	&"vitality": {
		"name": "Sustentação Vital",
		"desc": "Regeneração acelerada, drenagem de essência (Life Steal) e resistência.",
		"color": Color(0.2, 0.9, 0.3),
		"angle": PI * 0.80 # ~144°
	},
	&"aura": {
		"name": "Reservatório Espiritual",
		"desc": "Capacidade de aura expandida, taxa de fluxo de energia e resiliência espiritual.",
		"color": Color(0.4, 0.6, 1.0),
		"angle": PI # 180° Oeste
	},
	&"specialization": {
		"name": "Divergência de Especialização",
		"desc": "Keystones transformadores que quebram convenções em troca de poder sublime.",
		"color": Color(0.95, 0.2, 0.5),
		"angle": -PI * 0.80 # ~-144°
	},
	&"master": {
		"name": "Círculo dos Mestres",
		"desc": "O ápice do poder no Nível 1000+, conectando todas as filosofias de combate.",
		"color": Color(1.0, 0.85, 0.3),
		"angle": -PI * 0.60 # ~-108°
	}
}

var nodes: Dictionary = {} # StringName -> SkillTreeNodeData
var adjacency_forward: Dictionary = {} # StringName -> Array[StringName]
var spatial_grid: Dictionary = {} # Vector2i -> Array[StringName] (Tamanho de célula 400x400)
const CELL_SIZE: float = 400.0

static var _instance: SkillTreeDatabase = null

static func get_instance() -> SkillTreeDatabase:
	if _instance == null:
		_instance = SkillTreeDatabase.new()
		_instance._build_database()
	return _instance

func _init() -> void:
	pass

func _build_database() -> void:
	nodes.clear()
	adjacency_forward.clear()
	spatial_grid.clear()

	# 1. Criar Nexus Central (Ponto de Origem de Todo Hunter)
	_add_node(SkillTreeNodeData.new(
		&"nexus_center",
		"Despertar da Essência",
		"O ponto inicial onde todo aspirante descobre o controle do próprio fluxo vital.",
		&"nexus",
		SkillTreeNodeData.NodeType.KEYSTONE,
		Vector2(0, 0),
		0, 1, [],
		[
			{"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.02},
			{"type": "stat_modifier", "stat": "aura_max", "mod_type": 1, "value_per_rank": 0.02}
		],
		[],
		["nexus", "starter"]
	))
	nodes[&"nexus_center"].is_starting_node = true

	# 2. Registrar Nós Canônicos Legados (Preserva Compatibilidade Absoluta com Saves & Testes)
	_register_legacy_canonical_nodes()

	# 3. Construir as 10 Regiões com Ramificações, Bifurcações, Loops e Keystones
	_build_region_body()
	_build_region_warrior()
	_build_region_nen_expansion()
	_build_region_hatsu()
	_build_region_speed()
	_build_region_critical()
	_build_region_vitality()
	_build_region_aura()
	_build_region_specialization()
	_build_region_master()

	# 4. Construir Ligações e Estrutura Espacial
	_build_graph_and_spatial_index()

	print("[SkillTreeDatabase] Constelação inicializada com sucesso: %d nós registrados." % nodes.size())


# ------------------------------------------------------------------------------
# REGISTRO DOS 27 NÓS CANÔNICOS LEGADOS (FASE 1 & 2 PRESERVADAS)
# ------------------------------------------------------------------------------
func _register_legacy_canonical_nodes() -> void:
	# Pilar Ten
	_add_node(SkillTreeNodeData.new(&"ten_1", "Ten I", "Defesa +5%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(180, -220), 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.05}], [], ["ten", "defense"]))
	_add_node(SkillTreeNodeData.new(&"ten_2", "Ten II", "Defesa +10%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(240, -320), 1, 1, [&"ten_1"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.10}], [], ["ten", "defense"]))
	_add_node(SkillTreeNodeData.new(&"ten_3", "Ten III", "Defesa +15%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(300, -420), 1, 1, [&"ten_2"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.15}], [], ["ten", "defense"]))
	_add_node(SkillTreeNodeData.new(&"ten_4", "Ten IV", "Defesa +20%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(360, -520), 1, 1, [&"ten_3"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.20}], [], ["ten", "defense"]))
	_add_node(SkillTreeNodeData.new(&"ten_5", "Ten V", "Defesa +25% e Postura Inquebrável", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(420, -620), 1, 1, [&"ten_4"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.25}], [], ["ten", "defense", "major"]))

	# Pilar Ren
	_add_node(SkillTreeNodeData.new(&"ren_1", "Ren I", "Dano Físico +5%, Alcance +5%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(260, -140), 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.05}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.05}], [], ["ren", "offensive"]))
	_add_node(SkillTreeNodeData.new(&"ren_2", "Ren II", "Dano Físico +10%, Força +5%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(360, -180), 1, 1, [&"ren_1"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.10}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.05}], [], ["ren", "offensive"]))
	_add_node(SkillTreeNodeData.new(&"ren_3", "Ren III", "Dano Físico +15%, Força +10%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(460, -220), 1, 1, [&"ren_2"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.10}], [], ["ren", "offensive"]))
	_add_node(SkillTreeNodeData.new(&"ren_4", "Ren IV", "Dano Físico +20%, Força +12%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(560, -260), 1, 1, [&"ren_3"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.20}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.12}], [], ["ren", "offensive"]))
	_add_node(SkillTreeNodeData.new(&"ren_5", "Ren V", "Ren Supremo: Dano Físico +25%, Força +20%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(660, -300), 1, 1, [&"ren_4"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.25}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.20}], [], ["ren", "offensive", "major"]))

	# Pilar Zetsu
	_add_node(SkillTreeNodeData.new(&"zetsu_1", "Zetsu I", "Furtividade +20%, Regen HP +10%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(240, 140), 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "zetsu_stealth", "mod_type": 1, "value_per_rank": 0.20}, {"type": "stat_modifier", "stat": "regen_hp", "mod_type": 1, "value_per_rank": 0.10}], [], ["zetsu", "stealth"]))
	_add_node(SkillTreeNodeData.new(&"zetsu_2", "Zetsu II", "Furtividade +35%, Regen HP +20%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(340, 180), 1, 1, [&"zetsu_1"], [{"type": "stat_modifier", "stat": "zetsu_stealth", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "regen_hp", "mod_type": 1, "value_per_rank": 0.20}], [], ["zetsu", "stealth"]))
	_add_node(SkillTreeNodeData.new(&"zetsu_3", "Zetsu III", "Furtividade +50%, Regen HP +30%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(440, 220), 1, 1, [&"zetsu_2"], [{"type": "stat_modifier", "stat": "zetsu_stealth", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "regen_hp", "mod_type": 1, "value_per_rank": 0.30}], [], ["zetsu", "stealth"]))
	_add_node(SkillTreeNodeData.new(&"zetsu_4", "Zetsu IV", "Furtividade +65%, Invisibilidade Tática", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(540, 260), 1, 1, [&"zetsu_3"], [{"type": "stat_modifier", "stat": "zetsu_stealth", "mod_type": 1, "value_per_rank": 0.15}], [], ["zetsu", "stealth"]))
	_add_node(SkillTreeNodeData.new(&"zetsu_5", "Zetsu V", "Mestre da Ocultação: Furtividade +80%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(640, 300), 1, 1, [&"zetsu_4"], [{"type": "stat_modifier", "stat": "zetsu_stealth", "mod_type": 1, "value_per_rank": 0.15}], [], ["zetsu", "stealth", "major"]))

	# Pilar Gyo
	_add_node(SkillTreeNodeData.new(&"gyo_1", "Gyo I", "Detecção de Nen Tier 1, Esquiva +5%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(180, 220), 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "esquiva", "mod_type": 1, "value_per_rank": 0.05}], [], ["gyo", "perception"]))
	_add_node(SkillTreeNodeData.new(&"gyo_2", "Gyo II", "Detecção Tier 2, Crítico +5%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(240, 320), 1, 1, [&"gyo_1"], [{"type": "stat_modifier", "stat": "crit_chance", "mod_type": 1, "value_per_rank": 0.05}], [], ["gyo", "perception", "crit"]))
	_add_node(SkillTreeNodeData.new(&"gyo_3", "Gyo III", "Detecção Tier 3, Dano Crítico +15%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(300, 420), 1, 1, [&"gyo_2"], [{"type": "stat_modifier", "stat": "crit_damage", "mod_type": 1, "value_per_rank": 0.15}], [], ["gyo", "perception", "crit"]))
	_add_node(SkillTreeNodeData.new(&"gyo_4", "Gyo IV", "Detecção Tier 4, Percepção +25%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(360, 520), 1, 1, [&"gyo_3"], [{"type": "stat_modifier", "stat": "raio_percepcao_bonus", "mod_type": 0, "value_per_rank": 50.0}], [], ["gyo", "perception"]))
	_add_node(SkillTreeNodeData.new(&"gyo_5", "Gyo V", "Olhos da Verdade: Detecção Tier 5 Máxima", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(420, 620), 1, 1, [&"gyo_4"], [{"type": "stat_modifier", "stat": "crit_chance", "mod_type": 1, "value_per_rank": 0.10}, {"type": "stat_modifier", "stat": "crit_damage", "mod_type": 1, "value_per_rank": 0.25}], [], ["gyo", "perception", "crit", "major"]))

	# Pilar Ko
	_add_node(SkillTreeNodeData.new(&"ko_1", "Ko I", "Concentração Total: Dano de Burst +10%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(380, -60), 1, 1, [&"ren_1"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.10}], [], ["ko", "burst"]))
	_add_node(SkillTreeNodeData.new(&"ko_2", "Ko II", "Concentração Ofensiva: Dano Burst +15%", &"nen", SkillTreeNodeData.NodeType.SMALL, Vector2(480, -80), 1, 1, [&"ko_1"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.15}], [], ["ko", "burst"]))
	_add_node(SkillTreeNodeData.new(&"ko_3", "Ko III", "Impacto Destruidor: Dano Burst +20%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(580, -100), 1, 1, [&"ko_2"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.20}], [], ["ko", "burst"]))
	_add_node(SkillTreeNodeData.new(&"ko_4", "Ko IV", "Golpe Sísmico: Dano Burst +25%", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(680, -120), 1, 1, [&"ko_3"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.25}], [], ["ko", "burst"]))
	_add_node(SkillTreeNodeData.new(&"ko_5", "Ko V", "Punho Supremo de Ko: Dano Burst +35%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(780, -140), 1, 1, [&"ko_4"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.35}], [], ["ko", "burst", "major"]))

	# Shu & Sinergias Fundamentais
	_add_node(SkillTreeNodeData.new(&"shu_1", "Shu I", "Extensão de Aura em Armas e Equipamentos", &"nen", SkillTreeNodeData.NodeType.MEDIUM, Vector2(460, 40), 1, 1, [&"ren_2", &"ten_2"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.12}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.08}], [], ["shu", "weapon"]))
	_add_node(SkillTreeNodeData.new(&"ken_mastery", "Ken: Muralha Integral", "Sinergia Ten + Ren: Escudo de aura contínuo. Defesa +15%, Força +10%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(480, -380), 1, 1, [&"ten_3", &"ren_3"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.10}], [], ["ken", "nen_synergy", "major"]))
	_add_node(SkillTreeNodeData.new(&"in_mastery", "In: Ocultação Refinada", "Sinergia Zetsu + Gyo: Camufla aura. Esquiva +15%, Velocidade +10%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(480, 360), 1, 1, [&"zetsu_2", &"gyo_2"], [{"type": "stat_modifier", "stat": "esquiva", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "velocidade", "mod_type": 1, "value_per_rank": 0.10}], [], ["in", "nen_synergy", "major"]))

	# Modos de Ryu (Exclusividade Mútua)
	_add_node(SkillTreeNodeData.new(&"ryu_ofensivo", "Ryu Ofensivo (70/30)", "Distribui 70% de aura no ataque e 30% na defesa. Dano Físico +20%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(560, -20), 1, 1, [&"shu_1"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.20}], [], ["ryu", "ryu_mode", "offensive"]))
	_add_node(SkillTreeNodeData.new(&"ryu_defensivo", "Ryu Defensivo (30/70)", "Distribui 70% de aura na defesa e 30% no ataque. Defesa +25%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(560, 100), 1, 1, [&"shu_1"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.25}], [], ["ryu", "ryu_mode", "defensive"]))
	_add_node(SkillTreeNodeData.new(&"ryu_equilibrado", "Ryu Equilibrado (50/50)", "Distribuição harmoniosa: Dano Físico +10%, Defesa +12%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(620, 40), 1, 1, [&"shu_1"], [{"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.10}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.12}], [], ["ryu", "ryu_mode", "balanced"]))

	# Nós Comportamentais & Contextuais (GameplayConditions)
	var cond_fs := GameplayCondition.new()
	cond_fs.condition_type = GameplayCondition.Type.NO_DAMAGE_FOR_SECONDS
	cond_fs.target_value = 4.0
	_add_node(SkillTreeNodeData.new(&"first_strike", "Primeiro Golpe", "Sem receber dano há 4s: Primeiro acerto causa +35% de dano", &"warrior", SkillTreeNodeData.NodeType.KEYSTONE, Vector2(320, -80), 1, 1, [&"ren_1"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.35}], [cond_fs], ["first_strike", "contextual", "keystone"]))

	var cond_bl := GameplayCondition.new()
	cond_bl.condition_type = GameplayCondition.Type.PLAYER_HP_BELOW
	cond_bl.target_value = 0.35
	_add_node(SkillTreeNodeData.new(&"bloodied", "Fúria do Sangue", "HP abaixo de 35%: Força +20% e Resistência +15%", &"body", SkillTreeNodeData.NodeType.KEYSTONE, Vector2(160, -340), 1, 1, [&"ten_2"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.20}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.15}], [cond_bl], ["bloodied", "contextual", "keystone"]))

	var cond_sr := GameplayCondition.new()
	cond_sr.condition_type = GameplayCondition.Type.ENEMIES_NEARBY_AT_LEAST
	cond_sr.target_value = 3.0
	_add_node(SkillTreeNodeData.new(&"surrounded", "Cercado", "3+ inimigos por perto: Defesa +20% e Evasão +10%", &"body", SkillTreeNodeData.NodeType.MEDIUM, Vector2(180, 360), 1, 1, [&"gyo_2"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.20}, {"type": "stat_modifier", "stat": "esquiva", "mod_type": 1, "value_per_rank": 0.10}], [cond_sr], ["surrounded", "contextual"]))

	var cond_iso := GameplayCondition.new()
	cond_iso.condition_type = GameplayCondition.Type.SINGLE_TARGET
	cond_iso.target_value = 1.0
	_add_node(SkillTreeNodeData.new(&"isolated_target", "Alvo Isolado", "Apenas 1 inimigo por perto: Dano de Combate +25%", &"warrior", SkillTreeNodeData.NodeType.MEDIUM, Vector2(460, -120), 1, 1, [&"ko_1"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.25}], [cond_iso], ["isolated_target", "contextual"]))

	var cond_hm := GameplayCondition.new()
	cond_hm.condition_type = GameplayCondition.Type.TARGET_MARKED
	_add_node(SkillTreeNodeData.new(&"hunters_mark", "Marca do Caçador", "Contra alvos marcados com Gyo: Dano Crítico +30%", &"critical", SkillTreeNodeData.NodeType.MEDIUM, Vector2(360, 360), 1, 1, [&"gyo_2"], [{"type": "stat_modifier", "stat": "crit_damage", "mod_type": 1, "value_per_rank": 0.30}], [cond_hm], ["hunters_mark", "contextual"]))

	var cond_en := GameplayCondition.new()
	cond_en.condition_type = GameplayCondition.Type.PLAYER_IN_EN
	_add_node(SkillTreeNodeData.new(&"en_expansion", "En: Expansão Sensorial", "En ativo: Alcance +25% e Esquiva +10%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(520, 240), 1, 1, [&"gyo_3", &"ren_3"], [{"type": "stat_modifier", "stat": "esquiva", "mod_type": 1, "value_per_rank": 0.10}], [cond_en], ["en", "nen_synergy", "major"]))


# ------------------------------------------------------------------------------
# CONSTRUÇÃO DAS 10 REGIÕES EXPANDIDAS (GERAÇÃO ORGÂNICA DE 400+ NÓS)
# ------------------------------------------------------------------------------
func _build_region_body() -> void:
	# Região 1: BODY (Norte-Noroeste) - ~45 nós
	# Foco: Vida Máx, Defesa, Mitigação, Redução de Dano, Armadura Biológica
	var r_angle := float(REGIONS[&"body"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	# Gateway do Nexus
	var gw_id := &"body_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Portal da Fortaleza", "Entrada na disciplina da têmpera corporal.", &"body", SkillTreeNodeData.NodeType.MEDIUM, base_dir * 240.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.04}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.04}], [], ["body", "gateway"]))

	# 3 Braços principais: Ramo A (Vida), Ramo B (Defesa/Armadura), Ramo C (Mitigação/Poise)
	_generate_cluster_branch(&"body", gw_id, "body_hp", "Vitalidade Corpórea", "vida_max", 0.015, base_dir, normal * -140.0, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"body", gw_id, "body_def", "Placas de Titânio", "defesa", 0.015, base_dir, Vector2.ZERO, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"body", gw_id, "body_mit", "Têmpera Biológica", "reducao_dano", 0.01, base_dir, normal * 140.0, 14, SkillTreeNodeData.NodeType.SMALL)

	# Cross-links / Loops
	_connect_nodes(&"body_hp_03", &"body_def_03")
	_connect_nodes(&"body_def_05", &"body_mit_05")
	_connect_nodes(&"body_hp_08", &"body_def_08")
	_connect_nodes(&"body_def_11", &"body_mit_11")

	# Major Nodes
	_add_node(SkillTreeNodeData.new(&"body_major_iron_skin", "Corpo de Ferro", "Músculos impenetráveis como ligas metálicas. Defesa +12%, Vida +8%", &"body", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1250.0 + normal * -80.0, 1, 1, [&"body_def_07", &"body_hp_07"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.12}, {"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.08}], [], ["body", "defense", "major"]))
	_add_node(SkillTreeNodeData.new(&"body_major_colossus", "Presença Colossal", "Aura pesada que dissipa impactos. Redução de Dano +8%, Poise +30%", &"body", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1650.0 + normal * 80.0, 1, 1, [&"body_def_10", &"body_mit_10"], [{"type": "stat_modifier", "stat": "reducao_dano", "mod_type": 1, "value_per_rank": 0.08}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.10}], [], ["body", "mitigation", "major"]))

	# Keystone: "Baluarte Inabalável" (Grande bônus de defesa e mitigação com redução de velocidade)
	_add_node(SkillTreeNodeData.new(&"body_keystone_unshakable", "Baluarte Inabalável", "Keystone: Defesa +25%, Redução de Dano +12%. Velocidade de Movimento -10%", &"body", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 2100.0, 1, 1, [&"body_major_colossus", &"body_def_14"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.25}, {"type": "stat_modifier", "stat": "reducao_dano", "mod_type": 1, "value_per_rank": 0.12}, {"type": "stat_modifier", "stat": "velocidade", "mod_type": 1, "value_per_rank": -0.10}], [], ["body", "keystone", "tank"]))


func _build_region_warrior() -> void:
	# Região 2: WARRIOR (Norte-Nordeste) - ~45 nós
	# Foco: Dano de Ataque Básico, Cadência/Velocidade de Ataque, Combos, Força
	var r_angle := float(REGIONS[&"warrior"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	var gw_id := &"warrior_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Postura Marcial", "Iniciação ao combate físico veloz e cadenciado.", &"warrior", SkillTreeNodeData.NodeType.MEDIUM, base_dir * 240.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.04}, {"type": "stat_modifier", "stat": "dano_ataque_basico", "mod_type": 1, "value_per_rank": 0.05}], [], ["warrior", "gateway"]))

	_generate_cluster_branch(&"warrior", gw_id, "war_str", "Força de Impacto", "forca", 0.015, base_dir, normal * -140.0, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"warrior", gw_id, "war_atk", "Golpe Furioso", "dano_ataque_basico", 0.02, base_dir, Vector2.ZERO, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"warrior", gw_id, "war_spd", "Cadência Marcial", "velocidade_ataque", 0.015, base_dir, normal * 140.0, 14, SkillTreeNodeData.NodeType.SMALL)

	_connect_nodes(&"war_str_03", &"war_atk_03")
	_connect_nodes(&"war_atk_06", &"war_spd_06")
	_connect_nodes(&"war_str_09", &"war_atk_09")
	_connect_nodes(&"war_atk_12", &"war_spd_12")

	_add_node(SkillTreeNodeData.new(&"warrior_major_momentum", "Ímpeto do Lutador", "Cada acerto consecutivo acelera a cadência de combate. Dano Básico +15%, Força +8%", &"warrior", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1250.0 + normal * -80.0, 1, 1, [&"war_str_07", &"war_atk_07"], [{"type": "stat_modifier", "stat": "dano_ataque_basico", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.08}], [], ["warrior", "combo", "major"]))
	_add_node(SkillTreeNodeData.new(&"warrior_major_heavy_blows", "Golpes Pesados", "Ataques físicos quebram posturas inimigas. Força +12%, Dano Físico +10%", &"warrior", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1650.0 + normal * 80.0, 1, 1, [&"war_atk_10", &"war_spd_10"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.12}, {"type": "stat_modifier", "stat": "dano_fisico", "mod_type": 1, "value_per_rank": 0.10}], [], ["warrior", "strength", "major"]))

	_add_node(SkillTreeNodeData.new(&"warrior_keystone_overpower", "Frenesi do Guerreiro", "Keystone: Dano de Ataque Básico +30%, Força +15%. Dano de Hatsu reduzido em -15%", &"warrior", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 2100.0, 1, 1, [&"warrior_major_heavy_blows", &"war_atk_14"], [{"type": "stat_modifier", "stat": "dano_ataque_basico", "mod_type": 1, "value_per_rank": 0.30}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "dano_hatsu", "mod_type": 1, "value_per_rank": -0.15}], [], ["warrior", "keystone", "brawler"]))


func _build_region_nen_expansion() -> void:
	# Região 3: NEN (Leste) - Expande os 27 nós canônicos para ~50 nós com nós de transição e especialização
	var r_angle := float(REGIONS[&"nen"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	# Nós avançados de Shingen-ryu
	_generate_cluster_branch(&"nen", &"ten_5", "nen_ten_adv", "Ten Cristalino", "defesa", 0.02, base_dir, normal * -180.0, 6, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"nen", &"ren_5", "nen_ren_adv", "Ren Flamejante", "forca", 0.02, base_dir, normal * -60.0, 6, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"nen", &"zetsu_5", "nen_zet_adv", "Silêncio Total", "zetsu_stealth", 0.02, base_dir, normal * 60.0, 6, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"nen", &"gyo_5", "nen_gyo_adv", "Visão Aguçada", "crit_chance", 0.015, base_dir, normal * 180.0, 6, SkillTreeNodeData.NodeType.SMALL)

	_add_node(SkillTreeNodeData.new(&"nen_major_perfect_ten", "Ten Perfeito", "Muralha de aura impenetrável. Defesa +15%, Redução de Dano +5%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(1100, -500), 1, 1, [&"nen_ten_adv_03"], [{"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "reducao_dano", "mod_type": 1, "value_per_rank": 0.05}], [], ["ten", "nen", "major"]))
	_add_node(SkillTreeNodeData.new(&"nen_major_aura_burst", "Explosão de Ren", "Aura ofensiva devastadora. Força +18%, Dano de Nen +15%", &"nen", SkillTreeNodeData.NodeType.MAJOR, Vector2(1100, -200), 1, 1, [&"nen_ren_adv_03"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.18}, {"type": "stat_modifier", "stat": "dano_nen", "mod_type": 1, "value_per_rank": 0.15}], [], ["ren", "nen", "major"]))

	_add_node(SkillTreeNodeData.new(&"nen_keystone_absolute_domain", "Domínio Absoluto", "Keystone: Eficiência de todas as técnicas de Nen +25%, Dano de Nen +20%. Custo de Aura de Hatsu +15%", &"nen", SkillTreeNodeData.NodeType.KEYSTONE, Vector2(1600, 0), 1, 1, [&"nen_major_perfect_ten", &"nen_major_aura_burst", &"ryu_equilibrado"], [{"type": "stat_modifier", "stat": "dano_nen", "mod_type": 1, "value_per_rank": 0.20}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.15}], [], ["nen", "keystone", "mastery"]))


func _build_region_hatsu() -> void:
	# Região 4: HATSU (Sudeste) - ~45 nós
	# Foco: Dano de Hatsu, Redução de Cooldown, Redução de Custo, Área de Efeito
	var r_angle := float(REGIONS[&"hatsu"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	var gw_id := &"hatsu_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Iniciação ao Hatsu", "Manifestação da individualidade através da aura.", &"hatsu", SkillTreeNodeData.NodeType.MEDIUM, base_dir * 240.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "dano_hatsu", "mod_type": 1, "value_per_rank": 0.05}, {"type": "stat_modifier", "stat": "aura_max", "mod_type": 1, "value_per_rank": 0.03}], [], ["hatsu", "gateway"]))

	_generate_cluster_branch(&"hatsu", gw_id, "hat_dmg", "Ressonância Ofensiva", "dano_hatsu", 0.02, base_dir, normal * -140.0, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"hatsu", gw_id, "hat_cst", "Eficiência Energética", "reducao_custo_aura", 0.015, base_dir, Vector2.ZERO, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"hatsu", gw_id, "hat_cdr", "Fluidez de Execução", "reducao_cooldown", 0.015, base_dir, normal * 140.0, 14, SkillTreeNodeData.NodeType.SMALL)

	_connect_nodes(&"hat_dmg_03", &"hat_cst_03")
	_connect_nodes(&"hat_cst_06", &"hat_cdr_06")
	_connect_nodes(&"hat_dmg_09", &"hat_cst_09")
	_connect_nodes(&"hat_cst_12", &"hat_cdr_12")

	_add_node(SkillTreeNodeData.new(&"hatsu_major_resonance", "Ressonância do Hatsu", "Habilidades de Hatsu causam dano em cadeia. Dano de Hatsu +15%, Área +20%", &"hatsu", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1250.0 + normal * -80.0, 1, 1, [&"hat_dmg_07", &"hat_cst_07"], [{"type": "stat_modifier", "stat": "dano_hatsu", "mod_type": 1, "value_per_rank": 0.15}], [], ["hatsu", "damage", "major"]))
	_add_node(SkillTreeNodeData.new(&"hatsu_major_rapid_cast", "Conjuração Instantânea", "Cadência veloz de técnicas especiais. Redução de Cooldown +12%, Custo -10%", &"hatsu", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1650.0 + normal * 80.0, 1, 1, [&"hat_cst_10", &"hat_cdr_10"], [{"type": "stat_modifier", "stat": "reducao_cooldown", "mod_type": 1, "value_per_rank": 0.12}, {"type": "stat_modifier", "stat": "reducao_custo_aura", "mod_type": 1, "value_per_rank": 0.10}], [], ["hatsu", "cdr", "major"]))

	_add_node(SkillTreeNodeData.new(&"hatsu_keystone_overcharge", "Sobrecarga de Hatsu", "Keystone: Dano de Hatsu +35%, Área +25%. Custo de Aura aumentado em +20%", &"hatsu", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 2100.0, 1, 1, [&"hatsu_major_rapid_cast", &"hat_dmg_14"], [{"type": "stat_modifier", "stat": "dano_hatsu", "mod_type": 1, "value_per_rank": 0.35}, {"type": "stat_modifier", "stat": "reducao_custo_aura", "mod_type": 1, "value_per_rank": -0.20}], [], ["hatsu", "keystone", "nuke"]))


func _build_region_speed() -> void:
	# Região 5: SPEED (Sul-Sudeste) - ~45 nós
	# Foco: Velocidade de Movimento, Evasão, Mobilidade, Esquiva
	var r_angle := float(REGIONS[&"speed"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	var gw_id := &"speed_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Passo Rápido", "Leveza nos pés e resposta neuromuscular veloz.", &"speed", SkillTreeNodeData.NodeType.MEDIUM, base_dir * 240.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "velocidade", "mod_type": 1, "value_per_rank": 0.04}, {"type": "stat_modifier", "stat": "esquiva", "mod_type": 1, "value_per_rank": 0.03}], [], ["speed", "gateway"]))

	_generate_cluster_branch(&"speed", gw_id, "spd_vel", "Pernas de Vento", "velocidade", 0.015, base_dir, normal * -140.0, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"speed", gw_id, "spd_eva", "Reflexo Esquivo", "esquiva", 0.015, base_dir, Vector2.ZERO, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"speed", gw_id, "spd_mob", "Celeridade Tática", "velocidade", 0.012, base_dir, normal * 140.0, 14, SkillTreeNodeData.NodeType.SMALL)

	_connect_nodes(&"spd_vel_03", &"spd_eva_03")
	_connect_nodes(&"spd_eva_06", &"spd_mob_06")
	_connect_nodes(&"spd_vel_09", &"spd_eva_09")
	_connect_nodes(&"spd_eva_12", &"spd_mob_12")

	_add_node(SkillTreeNodeData.new(&"speed_major_phantom_step", "Passo Fantasma", "Movimento tão súbito que confunde a visão adversária. Esquiva +12%, Velocidade +10%", &"speed", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1250.0 + normal * -80.0, 1, 1, [&"spd_vel_07", &"spd_eva_07"], [{"type": "stat_modifier", "stat": "esquiva", "mod_type": 1, "value_per_rank": 0.12}, {"type": "stat_modifier", "stat": "velocidade", "mod_type": 1, "value_per_rank": 0.10}], [], ["speed", "evasion", "major"]))
	_add_node(SkillTreeNodeData.new(&"speed_major_adrenaline", "Surto de Adrenalina", "Aceleração contínua durante combate. Velocidade +15%, Dano após Esquiva +20%", &"speed", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1650.0 + normal * 80.0, 1, 1, [&"spd_eva_10", &"spd_mob_10"], [{"type": "stat_modifier", "stat": "velocidade", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.08}], [], ["speed", "adrenaline", "major"]))

	_add_node(SkillTreeNodeData.new(&"speed_keystone_lightning_reflexes", "Reflexos de Relâmpago", "Keystone: Esquiva +20%, Velocidade +25%. Defesa base reduzida em -12%", &"speed", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 2100.0, 1, 1, [&"speed_major_adrenaline", &"spd_eva_14"], [{"type": "stat_modifier", "stat": "esquiva", "mod_type": 1, "value_per_rank": 0.20}, {"type": "stat_modifier", "stat": "velocidade", "mod_type": 1, "value_per_rank": 0.25}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": -0.12}], [], ["speed", "keystone", "dodge"]))


func _build_region_critical() -> void:
	# Região 6: CRITICAL (Sul-Sudoeste) - ~45 nós
	# Foco: Chance Crítica, Dano Crítico, Execução, Multiplicador Fatal
	var r_angle := float(REGIONS[&"critical"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	var gw_id := &"crit_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Olhar Perfurante", "Detecção instantânea de aberturas na guarda adversária.", &"critical", SkillTreeNodeData.NodeType.MEDIUM, base_dir * 240.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "crit_chance", "mod_type": 1, "value_per_rank": 0.03}, {"type": "stat_modifier", "stat": "crit_damage", "mod_type": 1, "value_per_rank": 0.08}], [], ["critical", "gateway"]))

	_generate_cluster_branch(&"critical", gw_id, "crt_chn", "Foco Cirúrgico", "crit_chance", 0.01, base_dir, normal * -140.0, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"critical", gw_id, "crt_dmg", "Golpe Devastador", "crit_damage", 0.025, base_dir, Vector2.ZERO, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"critical", gw_id, "crt_exe", "Veredito Fatal", "dano_fisico", 0.015, base_dir, normal * 140.0, 14, SkillTreeNodeData.NodeType.SMALL)

	_connect_nodes(&"crt_chn_03", &"crt_dmg_03")
	_connect_nodes(&"crt_dmg_06", &"crt_exe_06")
	_connect_nodes(&"crt_chn_09", &"crt_dmg_09")
	_connect_nodes(&"crt_dmg_12", &"crt_exe_12")

	_add_node(SkillTreeNodeData.new(&"crit_major_assassin_instinct", "Instinto Assassino", "Golpes críticos geram surtos de energia. Chance Crítica +8%, Dano Crítico +25%", &"critical", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1250.0 + normal * -80.0, 1, 1, [&"crt_chn_07", &"crt_dmg_07"], [{"type": "stat_modifier", "stat": "crit_chance", "mod_type": 1, "value_per_rank": 0.08}, {"type": "stat_modifier", "stat": "crit_damage", "mod_type": 1, "value_per_rank": 0.25}], [], ["critical", "major"]))
	_add_node(SkillTreeNodeData.new(&"crit_major_executioner", "Mestre da Execução", "Dano letal amplificado contra alvos fragilizados. Dano Crítico +35%", &"critical", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1650.0 + normal * 80.0, 1, 1, [&"crt_dmg_10", &"crt_exe_10"], [{"type": "stat_modifier", "stat": "crit_damage", "mod_type": 1, "value_per_rank": 0.35}], [], ["critical", "execution", "major"]))

	_add_node(SkillTreeNodeData.new(&"crit_keystone_glass_cannon", "Canhão de Vidro", "Keystone: Chance Crítica +15%, Dano Crítico +50%. Defesa reduzida em -20%", &"critical", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 2100.0, 1, 1, [&"crit_major_executioner", &"crt_dmg_14"], [{"type": "stat_modifier", "stat": "crit_chance", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "crit_damage", "mod_type": 1, "value_per_rank": 0.50}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": -0.20}], [], ["critical", "keystone", "risk_reward"]))


func _build_region_vitality() -> void:
	# Região 7: VITALITY (Sudoeste) - ~45 nós
	# Foco: Regeneração de Vida, Life Steal, Cura, Sustentação
	var r_angle := float(REGIONS[&"vitality"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	var gw_id := &"vit_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Pulso de Vida", "Ativação do metabolismo celular acelerado.", &"vitality", SkillTreeNodeData.NodeType.MEDIUM, base_dir * 240.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.04}, {"type": "stat_modifier", "stat": "regen_hp", "mod_type": 1, "value_per_rank": 0.08}], [], ["vitality", "gateway"]))

	_generate_cluster_branch(&"vitality", gw_id, "vit_reg", "Metabolismo Acelerado", "regen_hp", 0.02, base_dir, normal * -140.0, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"vitality", gw_id, "vit_max", "Vigor Inabalável", "vida_max", 0.015, base_dir, Vector2.ZERO, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"vitality", gw_id, "vit_stl", "Drenagem Vital", "life_steal", 0.005, base_dir, normal * 140.0, 14, SkillTreeNodeData.NodeType.SMALL)

	_connect_nodes(&"vit_reg_03", &"vit_max_03")
	_connect_nodes(&"vit_max_06", &"vit_stl_06")
	_connect_nodes(&"vit_reg_09", &"vit_max_09")
	_connect_nodes(&"vit_max_12", &"vit_stl_12")

	_add_node(SkillTreeNodeData.new(&"vit_major_immortal_surge", "Surto Imortal", "Cura contínua que não cessa nem sob ataques. Regen HP +25%, Vida Máx +10%", &"vitality", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1250.0 + normal * -80.0, 1, 1, [&"vit_reg_07", &"vit_max_07"], [{"type": "stat_modifier", "stat": "regen_hp", "mod_type": 1, "value_per_rank": 0.25}, {"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.10}], [], ["vitality", "regen", "major"]))
	_add_node(SkillTreeNodeData.new(&"vit_major_vampiric_touch", "Toque Vampírico", "Golpes físicos convertem a dor alheia em recuperação. Life Steal +5%, Vida +8%", &"vitality", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1650.0 + normal * 80.0, 1, 1, [&"vit_max_10", &"vit_stl_10"], [{"type": "stat_modifier", "stat": "life_steal", "mod_type": 0, "value_per_rank": 0.05}, {"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.08}], [], ["vitality", "lifesteal", "major"]))

	_add_node(SkillTreeNodeData.new(&"vit_keystone_blood_hunter", "Caçador de Sangue", "Keystone: 10% de todo dano causado é convertido em recuperação de Vida. Regeneração passiva fora de combate reduzida em -50%", &"vitality", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 2100.0, 1, 1, [&"vit_major_vampiric_touch", &"vit_stl_14"], [{"type": "stat_modifier", "stat": "life_steal", "mod_type": 0, "value_per_rank": 0.10}, {"type": "stat_modifier", "stat": "regen_hp", "mod_type": 1, "value_per_rank": -0.50}], [], ["vitality", "keystone", "lifesteal"]))


func _build_region_aura() -> void:
	# Região 8: AURA (Oeste) - ~45 nós
	# Foco: Aura Máxima, Regeneração de Aura, Eficiência de Custo
	var r_angle := float(REGIONS[&"aura"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	var gw_id := &"aura_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Fonte Espiritual", "Desbloqueio dos microporos energéticos do corpo.", &"aura", SkillTreeNodeData.NodeType.MEDIUM, base_dir * 240.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "aura_max", "mod_type": 1, "value_per_rank": 0.05}, {"type": "stat_modifier", "stat": "regen_aura", "mod_type": 1, "value_per_rank": 0.05}], [], ["aura", "gateway"]))

	_generate_cluster_branch(&"aura", gw_id, "aur_cap", "Poço Sem Fundo", "aura_max", 0.02, base_dir, normal * -140.0, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"aura", gw_id, "aur_reg", "Recuperação Dinâmica", "regen_aura", 0.02, base_dir, Vector2.ZERO, 14, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"aura", gw_id, "aur_eff", "Economia Espiritual", "eficiencia_aura", 0.015, base_dir, normal * 140.0, 14, SkillTreeNodeData.NodeType.SMALL)

	_connect_nodes(&"aur_cap_03", &"aur_reg_03")
	_connect_nodes(&"aur_reg_06", &"aur_eff_06")
	_connect_nodes(&"aur_cap_09", &"aur_reg_09")
	_connect_nodes(&"aur_reg_12", &"aur_eff_12")

	_add_node(SkillTreeNodeData.new(&"aura_major_reservoir", "Reservatório Infinito", "Capacidade extraordinária de armazenamento de aura. Aura Máxima +18%", &"aura", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1250.0 + normal * -80.0, 1, 1, [&"aur_cap_07", &"aur_reg_07"], [{"type": "stat_modifier", "stat": "aura_max", "mod_type": 1, "value_per_rank": 0.18}], [], ["aura", "capacity", "major"]))
	_add_node(SkillTreeNodeData.new(&"aura_major_torrent", "Torrente Contínua", "Recuperação fulminante mesmo durante o calor da batalha. Regen de Aura +25%", &"aura", SkillTreeNodeData.NodeType.MAJOR, base_dir * 1650.0 + normal * 80.0, 1, 1, [&"aur_reg_10", &"aur_eff_10"], [{"type": "stat_modifier", "stat": "regen_aura", "mod_type": 1, "value_per_rank": 0.25}], [], ["aura", "regen", "major"]))

	_add_node(SkillTreeNodeData.new(&"aura_keystone_infinite_spring", "Fonte Inesgotável", "Keystone: Regeneração de Aura +40%, Eficiência +15%. Reduz a Força base em -10%", &"aura", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 2100.0, 1, 1, [&"aura_major_torrent", &"aur_reg_14"], [{"type": "stat_modifier", "stat": "regen_aura", "mod_type": 1, "value_per_rank": 0.40}, {"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": -0.10}], [], ["aura", "keystone", "sustain"]))


func _build_region_specialization() -> void:
	# Região 9: SPECIALIZATION (Noroeste) - ~35 nós
	# Foco: Keystones com regras transformadoras, tradeoffs e sinergias
	var r_angle := float(REGIONS[&"specialization"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	var gw_id := &"spec_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Desvio da Norma", "O caminho dos caçadores que recusam limitações pré-definidas.", &"specialization", SkillTreeNodeData.NodeType.MEDIUM, base_dir * 240.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.03}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.03}], [], ["spec", "gateway"]))

	_generate_cluster_branch(&"specialization", gw_id, "spc_bal", "Equilíbrio Dissidente", "forca", 0.015, base_dir, normal * -120.0, 10, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"specialization", gw_id, "spc_flw", "Transe Tático", "aura_max", 0.015, base_dir, normal * 120.0, 10, SkillTreeNodeData.NodeType.SMALL)

	_connect_nodes(&"spc_bal_03", &"spc_flw_03")
	_connect_nodes(&"spc_bal_07", &"spc_flw_07")

	# Keystones Especiais da Região
	_add_node(SkillTreeNodeData.new(&"spec_keystone_flow_state", "Estado de Fluxo", "Keystone: Após 5s sem sofrer dano, ganha +35% de Regeneração de Aura e +15% de Velocidade", &"specialization", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 1300.0, 1, 1, [&"spc_flw_05", &"spc_bal_05"], [{"type": "stat_modifier", "stat": "regen_aura", "mod_type": 1, "value_per_rank": 0.35}, {"type": "stat_modifier", "stat": "velocidade", "mod_type": 1, "value_per_rank": 0.15}], [], ["spec", "keystone", "flow"]))
	_add_node(SkillTreeNodeData.new(&"spec_keystone_predator_instinct", "Instinto Predador", "Keystone: Dano contra inimigos abaixo de 40% de vida aumenta em +30%", &"specialization", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 1750.0 + normal * -80.0, 1, 1, [&"spc_bal_08"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.30}], [], ["spec", "keystone", "execute"]))
	_add_node(SkillTreeNodeData.new(&"spec_keystone_iron_will", "Vontade Indomável", "Keystone: Resistência a efeitos de controle (Stun/Slow) +50%, Vida Máxima +15%", &"specialization", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 1750.0 + normal * 80.0, 1, 1, [&"spc_flw_08"], [{"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.15}], [], ["spec", "keystone", "tenacity"]))


func _build_region_master() -> void:
	# Região 10: MASTER (Anel Externo & Nexus) - ~50 nós
	# Foco: Maestria Suprema conectando as pontas das 9 regiões anteriores (Endgame 1000+)
	var r_angle := float(REGIONS[&"master"]["angle"])
	var base_dir := Vector2.from_angle(r_angle)
	var normal := Vector2(-base_dir.y, base_dir.x)

	var gw_id := &"master_gateway"
	_add_node(SkillTreeNodeData.new(gw_id, "Limiar dos Mestres", "Acesso aos segredos reservados para os caçadores de três estrelas.", &"master", SkillTreeNodeData.NodeType.MAJOR, base_dir * 300.0, 1, 1, [&"nexus_center"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.05}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.05}, {"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.05}, {"type": "stat_modifier", "stat": "aura_max", "mod_type": 1, "value_per_rank": 0.05}], [], ["master", "gateway", "major"]))

	_generate_cluster_branch(&"master", gw_id, "mst_all", "Ascensão Universal", "forca", 0.015, base_dir, normal * -120.0, 12, SkillTreeNodeData.NodeType.SMALL)
	_generate_cluster_branch(&"master", gw_id, "mst_def", "Baluarte Supremo", "defesa", 0.015, base_dir, normal * 120.0, 12, SkillTreeNodeData.NodeType.SMALL)

	_connect_nodes(&"mst_all_04", &"mst_def_04")
	_connect_nodes(&"mst_all_08", &"mst_def_08")

	# Grandes Nós de Maestria Conectando os Nós Finais das Regiões
	_add_node(SkillTreeNodeData.new(&"master_keystone_enlightenment", "Iluminação Shingen-ryu", "Keystone Supremo: Todos os atributos aumentados em +15%, Vida e Aura regeneram +20% mais rápido.", &"master", SkillTreeNodeData.NodeType.KEYSTONE, base_dir * 2200.0, 1, 1, [&"mst_all_12", &"mst_def_12"], [{"type": "stat_modifier", "stat": "forca", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "defesa", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "vida_max", "mod_type": 1, "value_per_rank": 0.15}, {"type": "stat_modifier", "stat": "aura_max", "mod_type": 1, "value_per_rank": 0.15}], [], ["master", "keystone", "apex"]))


# ------------------------------------------------------------------------------
# GERADOR DE RAMOS E CLUSTERS
# ------------------------------------------------------------------------------
func _generate_cluster_branch(
	p_region: StringName,
	p_parent_id: StringName,
	p_prefix: String,
	p_title: String,
	p_stat: String,
	p_val_per_rank: float,
	p_base_dir: Vector2,
	p_offset: Vector2,
	p_count: int,
	p_type: SkillTreeNodeData.NodeType
) -> void:
	var prev_id := p_parent_id
	var start_pos = nodes[p_parent_id].position if nodes.has(p_parent_id) else Vector2.ZERO

	for i in range(1, p_count + 1):
		var node_id := StringName("%s_%02d" % [p_prefix, i])
		var step_dist := 120.0 * float(i)
		var pos = start_pos + (p_base_dir * step_dist) + (p_offset * (1.0 + float(i) * 0.08))

		# Variação sutil a cada 4 nós para criar Nós Médios com multi-rank
		var n_type := p_type
		var max_rk := 1
		var val := p_val_per_rank
		var cost := 1
		if i % 4 == 0:
			n_type = SkillTreeNodeData.NodeType.MEDIUM
			max_rk = 3
			val = p_val_per_rank * 1.5

		var eff := [{
			"type": "stat_modifier",
			"stat": p_stat,
			"mod_type": 1,
			"value_per_rank": val
		}]

		var n_data := SkillTreeNodeData.new(
			node_id,
			"%s %s" % [p_title, _to_roman(i)],
			"+%.1f%% %s por rank." % [val * 100.0, p_stat.capitalize()],
			p_region,
			n_type,
			pos,
			cost,
			max_rk,
			[prev_id],
			eff,
			[],
			[String(p_region), p_stat]
		)

		_add_node(n_data)
		prev_id = node_id


func _add_node(node_data: SkillTreeNodeData) -> void:
	nodes[node_data.id] = node_data


func _connect_nodes(from_id: StringName, to_id: StringName) -> void:
	if nodes.has(to_id) and nodes.has(from_id):
		var to_node: SkillTreeNodeData = nodes[to_id]
		if not to_node.prerequisites.has(from_id):
			to_node.prerequisites.append(from_id)


func _build_graph_and_spatial_index() -> void:
	adjacency_forward.clear()
	spatial_grid.clear()

	for nid in nodes.keys():
		adjacency_forward[nid] = []

	for nid in nodes.keys():
		var node: SkillTreeNodeData = nodes[nid]
		# Spatial Hash Index
		var grid_pos := Vector2i(int(floor(node.position.x / CELL_SIZE)), int(floor(node.position.y / CELL_SIZE)))
		if not spatial_grid.has(grid_pos):
			spatial_grid[grid_pos] = []
		spatial_grid[grid_pos].append(nid)

		# Forward Graph
		for prereq in node.prerequisites:
			if adjacency_forward.has(prereq):
				adjacency_forward[prereq].append(nid)


func get_nodes_in_rect(rect: Rect2) -> Array[StringName]:
	var result: Array[StringName] = []
	var min_cell := Vector2i(int(floor(rect.position.x / CELL_SIZE)), int(floor(rect.position.y / CELL_SIZE)))
	var max_cell := Vector2i(int(floor((rect.position.x + rect.size.x) / CELL_SIZE)), int(floor((rect.position.y + rect.size.y) / CELL_SIZE)))

	for cx in range(min_cell.x, max_cell.x + 1):
		for cy in range(min_cell.y, max_cell.y + 1):
			var cell := Vector2i(cx, cy)
			if spatial_grid.has(cell):
				for nid in spatial_grid[cell]:
					var n: SkillTreeNodeData = nodes[nid]
					if rect.has_point(n.position):
						result.append(nid)
	return result


func _to_roman(val: int) -> String:
	match val:
		1: return "I"
		2: return "II"
		3: return "III"
		4: return "IV"
		5: return "V"
		6: return "VI"
		7: return "VII"
		8: return "VIII"
		9: return "IX"
		10: return "X"
		11: return "XI"
		12: return "XII"
		13: return "XIII"
		14: return "XIV"
		15: return "XV"
	return str(val)
