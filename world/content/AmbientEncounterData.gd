class_name AmbientEncounterData
extends Resource

# ============================================================
# HUNTER ONLINE - AMBIENT ENCOUNTER DATA
# ============================================================
#
# Estrutura de dados para encontros ambientais menores que
# dão sensação de vida orgânica ao mundo sem exigir quests:
# - Hunter viajando, Comerciante nômade, Animal atravessando,
#   Pessoa meditando com Nen, Luta de caçador em andamento
#
# ============================================================

enum EncounterType {
	HUNTER_TRAVELING = 0,
	ANIMAL_CROSSING = 1,
	INJURED_NPC = 2,
	WANDERING_MERCHANT = 3,
	BANDIT_SKIRMISH = 4,
	HUNTER_VS_CREATURE = 5,
	NEN_TRAINING = 6
}

@export var id: String = ""
@export var encounter_type: int = EncounterType.HUNTER_TRAVELING
@export var title: String = ""
@export var dialogue_text: String = ""
@export var pos: Vector2 = Vector2.ZERO
@export var duration: float = 60.0
@export var is_active: bool = false


static func type_to_string(t: int) -> String:
	match t:
		EncounterType.HUNTER_TRAVELING: return "HUNTER_TRAVELING"
		EncounterType.ANIMAL_CROSSING: return "ANIMAL_CROSSING"
		EncounterType.INJURED_NPC: return "INJURED_NPC"
		EncounterType.WANDERING_MERCHANT: return "WANDERING_MERCHANT"
		EncounterType.BANDIT_SKIRMISH: return "BANDIT_SKIRMISH"
		EncounterType.HUNTER_VS_CREATURE: return "HUNTER_VS_CREATURE"
		EncounterType.NEN_TRAINING: return "NEN_TRAINING"
		_: return "UNKNOWN"
