class_name WorldEventData
extends Resource

# ============================================================
# HUNTER ONLINE - WORLD EVENT DATA
# ============================================================
#
# Estrutura de dados para eventos dinâmicos espaciais:
# - Tipos de eventos (Emboscadas, Monstros Raros, Resgates, etc.)
# - Duração, perigo, regras de localização e cooldown
#
# ============================================================

enum EventType {
	NPC_ENCOUNTER = 0,
	AMBUSH = 1,
	MONSTER_GROUP = 2,
	RARE_MONSTER = 3,
	HUNTER_ENCOUNTER = 4,
	MERCHANT = 5,
	TRAVELER = 6,
	RESCUE = 7,
	PATROL = 8,
	BANDIT_ATTACK = 9,
	HUNTER_FIGHT = 10,
	WORLD_EVENT = 11
}

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var type: int = EventType.NPC_ENCOUNTER
@export var rarity: float = 0.5 # 0.0=Comum, 1.0=Lendário
@export var duration: float = 120.0 # segundos
@export var min_players: int = 1
@export var max_players: int = 4
@export var danger_level: int = 1 # 1 a 5
@export var location_rules: Array = [] # ["forest", "road", "ruins"]
@export var cooldown: float = 180.0 # segundos após conclusão
@export var spawn_pos: Vector2 = Vector2.ZERO
@export var is_active: bool = false


static func type_to_string(t: int) -> String:
	match t:
		EventType.NPC_ENCOUNTER: return "NPC_ENCOUNTER"
		EventType.AMBUSH: return "AMBUSH"
		EventType.MONSTER_GROUP: return "MONSTER_GROUP"
		EventType.RARE_MONSTER: return "RARE_MONSTER"
		EventType.HUNTER_ENCOUNTER: return "HUNTER_ENCOUNTER"
		EventType.MERCHANT: return "MERCHANT"
		EventType.TRAVELER: return "TRAVELER"
		EventType.RESCUE: return "RESCUE"
		EventType.PATROL: return "PATROL"
		EventType.BANDIT_ATTACK: return "BANDIT_ATTACK"
		EventType.HUNTER_FIGHT: return "HUNTER_FIGHT"
		EventType.WORLD_EVENT: return "WORLD_EVENT"
		_: return "UNKNOWN"


static func string_to_type(s: String) -> int:
	match s.to_upper():
		"NPC_ENCOUNTER": return EventType.NPC_ENCOUNTER
		"AMBUSH": return EventType.AMBUSH
		"MONSTER_GROUP": return EventType.MONSTER_GROUP
		"RARE_MONSTER": return EventType.RARE_MONSTER
		"HUNTER_ENCOUNTER": return EventType.HUNTER_ENCOUNTER
		"MERCHANT": return EventType.MERCHANT
		"TRAVELER": return EventType.TRAVELER
		"RESCUE": return EventType.RESCUE
		"PATROL": return EventType.PATROL
		"BANDIT_ATTACK": return EventType.BANDIT_ATTACK
		"HUNTER_FIGHT": return EventType.HUNTER_FIGHT
		"WORLD_EVENT": return EventType.WORLD_EVENT
		_: return EventType.NPC_ENCOUNTER
