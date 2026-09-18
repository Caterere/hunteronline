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
# 5. Investigativa: "Vestígios do Furto de Aura" (Gyo)
#
# ============================================================

const QuestScript = preload("res://scripts/missions/Quest.gd")
const QuestObjectiveScript = preload("res://scripts/missions/QuestObjective.gd")


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
	q.reward_gold = 900
	
	# Objetivo 1: Falar com Wing
	var obj1 = QuestObjectiveScript.new()
	obj1.type = QuestObjectiveScript.Type.VISIT
	obj1.target_npc_id = &"wing"
	obj1.target_npc_name = "Mestre Wing"
	
	# Objetivo 2: Derrotar feras na floresta
	var obj2 = QuestObjectiveScript.new()
	obj2.type = QuestObjectiveScript.Type.KILL
	obj2.enemy_type = &"fera_floresta"
	obj2.required_amount = 2
	
	# Objetivo 3: Derrotar o Chefe das Ruínas
	var obj3 = QuestObjectiveScript.new()
	obj3.type = QuestObjectiveScript.Type.KILL
	obj3.enemy_type = &"guardiao_ancestral"
	obj3.required_amount = 1
	
	var objs: Array[QuestObjective] = [obj1, obj2, obj3]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 2. QUEST SECUNDÁRIA 1: ERVAS DA FLORESTA (GATHERING/COMBAT)
# ------------------------------------------------------------
static func obter_quest_secundaria_1() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "Ervas Medicinais da Floresta"
	q.description = "O Vendedor do Empório necessita de proteção contra as feras para reabastecer o estoque de tônicos com ervas da Árvore Milenar."
	q.auto_complete = true
	q.turn_in_npc_key = &"vendedor"
	q.reward_xp = 150
	q.reward_gold = 250
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.KILL
	obj.enemy_type = &"fera_floresta"
	obj.required_amount = 2
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 3. QUEST SECUNDÁRIA 2: MINÉRIOS DAS RUÍNAS (CRAFTING/COMBAT)
# ------------------------------------------------------------
static func obter_quest_secundaria_2() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "Minérios das Ruínas de Zaban"
	q.description = "Ferreiro Duran precisa de fragmentos de pedra ancestral guardados pelas Sentinelas das Ruínas para aprimorar armas."
	q.auto_complete = true
	q.turn_in_npc_key = &"ferreiro"
	q.reward_xp = 250
	q.reward_gold = 400
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.KILL
	obj.enemy_type = &"sentinela_pedra"
	obj.required_amount = 2
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 4. QUEST SECUNDÁRIA 3: SEGURANÇA DA ESTRADA REAL (ESCORT/PATROL)
# ------------------------------------------------------------
static func obter_quest_secundaria_estrada() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "Escolta Noturna da Caravana Real"
	q.description = "O Guarda da Estrada pediu proteção à carroça de mercadores. Permaneça na Estrada Real após o anoitecer — salteadores emboscam a caravana sob a lua."
	q.auto_complete = true
	q.turn_in_npc_key = &"guarda_patrulha"
	q.reward_xp = 220
	q.reward_gold = 350

	var obj1 = QuestObjectiveScript.new()
	obj1.type = QuestObjectiveScript.Type.VISIT
	obj1.target_npc_id = &"guarda_patrulha"
	obj1.target_npc_name = "Guarda Hunter"

	var obj2 = QuestObjectiveScript.new()
	obj2.type = QuestObjectiveScript.Type.KILL
	obj2.enemy_type = &"ladrao_estrada"
	obj2.required_amount = 2

	var objs: Array[QuestObjective] = [obj1, obj2]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 5. QUEST DESAFIO: PREDADORES DA RAVINA (TEN HAZARD CHALLENGE)
# ------------------------------------------------------------
static func obter_quest_desafio_ravina() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "Extermínio dos Predadores da Ravina"
	q.description = "O Caçador de Zaban adverte que as criaturas venenosas da Ravina do Miasma estão se multiplicando. Mantenha TEN ativo para resistir ao veneno e abater os predadores."
	q.auto_complete = false
	q.turn_in_npc_key = &"cacador_de_zaban"
	q.reward_xp = 350
	q.reward_gold = 550
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.KILL
	obj.enemy_type = &"predador_miasma"
	obj.required_amount = 2
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 6. QUEST SECRETA: O ENIGMA DA ROCHA RACHADA (NEN KO)
# ------------------------------------------------------------
static func obter_quest_secreta() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "O Enigma da Rocha Rachada"
	q.description = "Dizem que nas colinas ao norte há uma fenda ancestral selada por uma rocha gigantesca. Apenas um golpe concentrado de KO pode rompê-la."
	q.auto_complete = false
	q.is_secret = true
	q.turn_in_npc_key = &"ermitao"
	q.reward_xp = 400
	q.reward_gold = 800
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.INVESTIGATE
	obj.target_clue_id = &"pista_rocha_nen"
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 7. QUEST SECRETA: O ALTAR DA CHAMA DE NEN (REN BEACON)
# ------------------------------------------------------------
static func obter_quest_secreta_altar() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "O Altar da Chama de Nen"
	q.description = "O Guardião da Floresta sussurra sobre um Altar Ancestral nas ruínas que reage à liberação de Ren. Canalize sua presença para despertar a relíquia."
	q.auto_complete = false
	q.is_secret = true
	q.turn_in_npc_key = &"guardiao_da_floresta"
	q.reward_xp = 300
	q.reward_gold = 450
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.STEALTH_PASS
	obj.target_zone_id = &"ninho_feras_padokia"
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 8. QUEST INVESTIGATIVA: FURTO DE AURA NA VILA (GYO)
# Disponível apenas após despertar Nen (Arena Celestial / Mestre Wing).
# ------------------------------------------------------------
static func obter_quest_investigacao_furto() -> Quest:
	var q = QuestScript.new()
	q.quest_name = "Vestígios do Furto de Aura"
	q.description = "Após despertar seu Nen com o Mestre Wing, use GYO para rastrear as pegadas de aura do furto no Empório de Padokia e identificar o culpado."
	q.auto_complete = false
	q.turn_in_npc_key = &"vendedor"
	q.reward_xp = 280
	q.reward_gold = 400

	var obj1 = QuestObjectiveScript.new()
	obj1.type = QuestObjectiveScript.Type.VISIT
	obj1.target_npc_id = &"vendedor"
	obj1.target_npc_name = "Mercador do Empório"

	var obj2 = QuestObjectiveScript.new()
	obj2.type = QuestObjectiveScript.Type.INVESTIGATE
	obj2.target_clue_id = &"pista_furto_janela"
	obj2.required_amount = 1

	var obj3 = QuestObjectiveScript.new()
	obj3.type = QuestObjectiveScript.Type.INVESTIGATE
	obj3.target_clue_id = &"pista_furto_pegada"
	obj3.required_amount = 1

	var obj4 = QuestObjectiveScript.new()
	obj4.type = QuestObjectiveScript.Type.INVESTIGATE
	obj4.target_clue_id = &"pista_furto_esconderijo"
	obj4.required_amount = 1

	var objs: Array[QuestObjective] = [obj1, obj2, obj3, obj4]
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
		obter_quest_secundaria_estrada(),
		obter_quest_desafio_ravina(),
		obter_quest_secreta(),
		obter_quest_secreta_altar(),
		obter_quest_investigacao_furto()
	]
	return lista
