class_name Quest
extends Resource

## Define como os objetivos precisam ser completados.
enum Completion {
	ALL,
	ANY
}

## Define como os pré-requisitos de quests funcionam.
enum RequiresMode {
	ALL,
	ANY
}

# =========================================================
# INFORMAÇÕES BÁSICAS
# =========================================================

@export_category("Quest")

@export var quest_name: String = "Nova Quest"

@export_multiline var description: String = ""

@export var objectives: Array[QuestObjective] = []

@export var completion: Completion = Completion.ALL

## Se true, a quest termina automaticamente quando os objetivos
## forem concluídos.
@export var auto_complete: bool = false


# =========================================================
# REQUISITOS
# =========================================================

@export_category("Requirements")

## Nível mínimo para aceitar a quest.
## 0 = sem requisito.
@export var min_level: int = 0

## Quests que precisam estar concluídas antes desta.
@export var requires_quests: Array[Quest] = []

## Define se todas ou apenas uma das quests anteriores
## precisam estar concluídas.
@export var requires_mode: RequiresMode = RequiresMode.ALL


# =========================================================
# ENTREGA
# =========================================================

@export_category("Turn In")

## Se preenchido, somente esse NPC poderá receber a quest.
## Futuramente podemos ligar isso diretamente ao nosso sistema de NPC.
@export var turn_in_npc_key: StringName = &""


# =========================================================
# RECOMPENSAS
# =========================================================

@export_category("Rewards")

@export var reward_xp: int = 0

@export var reward_gold: int = 0

@export var reward_items: Array[QuestReward] = []

@export_group("Optional Rewards & Consequences")
@export var optional_reward_xp: int = 0
@export var optional_reward_gold: int = 0
@export var optional_rewards: Array[QuestReward] = []
@export var consequence_tags: Array[String] = []
@export var optional_consequence_tags: Array[String] = []


# =========================================================
# FUNÇÕES
# =========================================================

func has_optional_objectives() -> bool:
	for obj in objectives:
		if obj != null and obj.is_optional:
			return true
	return false


func get_mandatory_objectives() -> Array[QuestObjective]:
	var mandatory: Array[QuestObjective] = []
	for obj in objectives:
		if obj != null and not obj.is_optional:
			mandatory.append(obj)
	return mandatory

## Verifica se os pré-requisitos básicos da quest foram cumpridos.
func prerequisites_met(player_data) -> bool:
	
	# Verifica nível.
	if min_level > 0:
		var p_lvl: int = int(player_data.attributes.get("nivel", player_data.attributes.get("level", 1)))
		if p_lvl < min_level:
			return false
	
	# Se não existem quests anteriores, está liberada.
	if requires_quests.is_empty():
		return true
	
	var completed_count := 0
	
	for quest in requires_quests:
		if quest == null:
			continue
		
		if player_data.is_quest_completed(quest):
			completed_count += 1
	
	# ALL = todas precisam estar concluídas.
	if requires_mode == RequiresMode.ALL:
		return completed_count == requires_quests.size()
	
	# ANY = apenas uma precisa estar concluída.
	return completed_count > 0
