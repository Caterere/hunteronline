class_name PadokiaQuestCatalog
extends RefCounted

# ============================================================
# HUNTER ONLINE - PADOKIA QUEST CATALOG (VERTICAL SLICE)
# ============================================================
#
# Catálogo de Quests da Região Piloto (Vale de Padokia):
# 1. Principal: "O Despertar da Aura & O Guardião de Zaban"
# 2. Secundária 1: "Ervas Medicinais da Floresta"
# 3. Secundária 2: "Minérios das Ruínas de Zaban"
# 4. Secreta: "O Enigma da Rocha Rachada (Nen KO)"
#
# ============================================================

const QuestScript = preload("res://scripts/Quest.gd")
const QuestObjectiveScript = preload("res://scripts/QuestObjective.gd")


# ------------------------------------------------------------
# 1. QUEST PRINCIPAL
# ------------------------------------------------------------
static func obter_quest_principal() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "O Despertar da Aura & O Guardião de Zaban"
	q.description = "Mestre Wing solicitou que você domine o fluxo de Ten, explore a Floresta dos Vestígios e derrote o Guardião Ancestral adormecido nas Ruínas de Zaban."
	q.auto_complete = false
	q.turn_in_npc_key = &"wing"
	q.reward_xp = 500
	q.reward_gold = 2500
	
	# Objetivo 1: Falar com Wing
	var obj1 = QuestObjectiveScript.new()
	obj1.type = QuestObjectiveScript.Type.VISIT
	obj1.target_npc_id = &"wing"
	obj1.target_npc_name = "Mestre Wing"
	
	# Objetivo 2: Derrotar monstros na floresta
	var obj2 = QuestObjectiveScript.new()
	obj2.type = QuestObjectiveScript.Type.KILL
	obj2.enemy_type = &"slime"
	obj2.required_amount = 3
	
	# Objetivo 3: Derrotar o Chefe das Ruínas
	var obj3 = QuestObjectiveScript.new()
	obj3.type = QuestObjectiveScript.Type.KILL
	obj3.enemy_type = &"guardiao_ancestral"
	obj3.required_amount = 1
	
	var objs: Array[QuestObjective] = [obj1, obj2, obj3]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 2. QUEST SECUNDÁRIA 1: ERVAS DA FLORESTA
# ------------------------------------------------------------
static func obter_quest_secundaria_1() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "Ervas Medicinais da Floresta"
	q.description = "A Herbalista da vila necessita de proteção contra as feras para coletar ervas nos arredores da Árvore Milenar."
	q.auto_complete = true
	q.turn_in_npc_key = &"vendedor"
	q.reward_xp = 150
	q.reward_gold = 600
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.KILL
	obj.enemy_type = &"slime"
	obj.required_amount = 2
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 3. QUEST SECUNDÁRIA 2: MINÉRIOS DAS RUÍNAS
# ------------------------------------------------------------
static func obter_quest_secundaria_2() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "Minérios das Ruínas de Zaban"
	q.description = "Ferreiro Duran precisa de fragmentos de pedra ancestral guardados pelas Sentinelas das Ruínas para aprimorar armas."
	q.auto_complete = true
	q.turn_in_npc_key = &"ferreiro"
	q.reward_xp = 250
	q.reward_gold = 1000
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.KILL
	obj.enemy_type = &"sentinela_pedra"
	obj.required_amount = 2
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 4. QUEST SECRETA: O ENIGMA DA ROCHA RACHADA (NEN KO)
# ------------------------------------------------------------
static func obter_quest_secreta() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "O Enigma da Rocha Rachada"
	q.description = "Dizem que nas colinas ao norte há uma fenda ancestral selada por uma rocha gigantesca. Apenas um golpe concentrado de KO pode rompê-la."
	q.auto_complete = false
	q.turn_in_npc_key = &"ermitao"
	q.reward_xp = 400
	q.reward_gold = 3000
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.INVESTIGATE
	obj.target_clue_id = &"pista_rocha_nen"
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# LISTA COMPLETA
# ------------------------------------------------------------
static func obter_todas_quests() -> Array[Quest]:
	var lista: Array[Quest] = [
		obter_quest_principal(),
		obter_quest_secundaria_1(),
		obter_quest_secundaria_2(),
		obter_quest_secreta()
	]
	return lista
