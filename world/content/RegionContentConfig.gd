class_name RegionContentConfig
extends Resource

# ============================================================
# HUNTER ONLINE - REGION CONTENT CONFIG
# ============================================================
#
# Configuração data-driven de densidade de conteúdo por região:
# - Densidades de NPCs, PvE, Eventos, Encontros e POIs
# - Métricas de distância espacial (por 1000 tiles)
# - Perfis de risco zonal (SAFE, LOW_RISK, MEDIUM_RISK, HIGH_RISK, DANGER)
# - Limites populacionais e intervalos de ativação
#
# ============================================================

enum ZoneRisk {
	SAFE = 0,
	LOW_RISK = 1,
	MEDIUM_RISK = 2,
	HIGH_RISK = 3,
	DANGER = 4
}

@export var region_id: String = "val_padokia"
@export var region_name: String = "Vale de Padokia"
@export var seed_val: int = 184729

@export_category("Limites Populacionais & Anti-Spam")
@export var max_active_npcs: int = 24
@export var max_active_enemies: int = 32
@export var max_active_events: int = 4
@export var max_active_encounters: int = 6
@export var minimum_distance_between_events: float = 320.0 # ~20 tiles em pixels
@export var spawn_radius_min: float = 400.0
@export var spawn_radius_max: float = 700.0
@export var despawn_radius: float = 1200.0

@export_category("Métricas de Distância (por 1000 Tiles)")
@export var events_per_1000_tiles: float = 3.0
@export var encounters_per_1000_tiles: float = 6.0
@export var npcs_per_1000_tiles: float = 8.0
@export var enemies_per_1000_tiles: float = 15.0

@export_category("Intervalos e Probabilidades")
@export var event_min_interval_sec: float = 30.0
@export var event_max_interval_sec: float = 90.0
@export var encounter_min_interval_sec: float = 15.0
@export var encounter_max_interval_sec: float = 45.0

@export var rare_event_chance: float = 0.15
@export var elite_spawn_chance: float = 0.10
@export var special_event_chance: float = 0.05

# Perfis de Densidade por Zona de Risco
var zone_profiles: Dictionary = {
	ZoneRisk.SAFE: {
		"name": "Zona Segura (Cidade/Vila)",
		"npc_density": 1.0,
		"pve_density": 0.0,
		"event_density": 0.4,
		"encounter_density": 0.8,
		"allowed_pve": [],
		"allowed_events": ["MERCHANT", "TRAVELER", "NPC_ENCOUNTER", "HUNTER_ENCOUNTER"]
	},
	ZoneRisk.LOW_RISK: {
		"name": "Baixo Risco (Estrada Real)",
		"npc_density": 0.6,
		"pve_density": 0.25,
		"event_density": 0.3,
		"encounter_density": 0.5,
		"allowed_pve": ["slime", "small_beast"],
		"allowed_events": ["TRAVELER", "MERCHANT", "PATROL", "BANDIT_ATTACK"]
	},
	ZoneRisk.MEDIUM_RISK: {
		"name": "Médio Risco (Floresta/Campos)",
		"npc_density": 0.25,
		"pve_density": 0.7,
		"event_density": 0.6,
		"encounter_density": 0.6,
		"allowed_pve": ["slime", "forest_beast", "wolf"],
		"allowed_events": ["AMBUSH", "MONSTER_GROUP", "RESCUE", "HUNTER_FIGHT"]
	},
	ZoneRisk.HIGH_RISK: {
		"name": "Alto Risco (Floresta Profunda/Ruínas)",
		"npc_density": 0.1,
		"pve_density": 0.9,
		"event_density": 0.8,
		"encounter_density": 0.7,
		"allowed_pve": ["ancient_beast", "ruins_guardian", "elite_shadow"],
		"allowed_events": ["RARE_MONSTER", "AMBUSH", "BANDIT_ATTACK", "WORLD_EVENT"]
	},
	ZoneRisk.DANGER: {
		"name": "Perigo Extremo (Ravina/Dungeon)",
		"npc_density": 0.05,
		"pve_density": 1.0,
		"event_density": 1.0,
		"encounter_density": 0.9,
		"allowed_pve": ["miasma_fiend", "elite_guardian", "boss_candidate"],
		"allowed_events": ["RARE_MONSTER", "AMBUSH", "WORLD_EVENT", "HUNTER_FIGHT"]
	}
}


static func create_default() -> Resource:
	var script = load("res://world/content/RegionContentConfig.gd") as GDScript
	var cfg = script.new()
	return cfg
