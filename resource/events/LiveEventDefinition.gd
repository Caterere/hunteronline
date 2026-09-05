class_name LiveEventDefinition
extends Resource

# ============================================================
# HUNTER ONLINE — LIVE EVENT DEFINITION (FASE L)
# ============================================================
#
# Estrutura declarativa de dados para Eventos Vivos e Temporários:
# - Aparição de feras raras, comerciantes itinerantes, chefes temporários.
# - Duração em horas de jogo, região alvo e condições climáticas/temporais.
# - Recompensas únicas com proteção anti-duplicação e suporte co-op.
# ============================================================

@export var event_id: StringName = &""
@export var event_name: String = ""
@export_multiline var description: String = ""
@export var target_region: StringName = &""
@export var duration_hours: float = 4.0

# Condições de Ativação (Avaliadas pelo StoryGatingEvaluator)
@export var requirements: Array[Dictionary] = []
@export var weather_condition: int = -1 # -1: Qualquer clima
@export var time_phase_condition: int = -1 # -1: Qualquer fase solar

# Entidades geradas no evento:
# [{"id": "fera_mitica", "type": "enemy", "is_boss": true, "spawn_pos": [200, 300]}]
@export var spawn_entities: Array = []

# Recompensas
@export var rewards: Dictionary = {
	"xp": 2500,
	"gold": 5000,
	"items": ["reliquia_ancestral"]
}

@export var coop_supported: bool = true
@export var is_temporary: bool = true
@export var is_repeatable: bool = false
@export var flags: Array = [&"live_event", &"world_event"]


func _init(
	p_id: StringName = &"",
	p_name: String = "",
	p_region: StringName = &"",
	p_duration: float = 4.0
) -> void:
	event_id = p_id
	event_name = p_name
	target_region = p_region
	duration_hours = p_duration


func to_dict() -> Dictionary:
	return {
		"event_id": String(event_id),
		"event_name": event_name,
		"description": description,
		"target_region": String(target_region),
		"duration_hours": duration_hours,
		"requirements": requirements.duplicate(true),
		"weather_condition": weather_condition,
		"time_phase_condition": time_phase_condition,
		"spawn_entities": spawn_entities.duplicate(true),
		"rewards": rewards.duplicate(true),
		"coop_supported": coop_supported,
		"is_temporary": is_temporary,
		"is_repeatable": is_repeatable,
		"flags": flags.map(func(f): return String(f))
	}


static func from_dict(data: Dictionary) -> Resource:
	var def = (load("res://resource/events/LiveEventDefinition.gd") as GDScript).new()
	def.event_id = StringName(data.get("event_id", ""))
	def.event_name = str(data.get("event_name", ""))
	def.description = str(data.get("description", ""))
	def.target_region = StringName(data.get("target_region", ""))
	def.duration_hours = float(data.get("duration_hours", 4.0))
	def.requirements = (data.get("requirements", []) as Array).duplicate(true)
	def.weather_condition = int(data.get("weather_condition", -1))
	def.time_phase_condition = int(data.get("time_phase_condition", -1))
	def.spawn_entities = (data.get("spawn_entities", []) as Array).duplicate(true)
	def.rewards = (data.get("rewards", {}) as Dictionary).duplicate(true)
	def.coop_supported = bool(data.get("coop_supported", true))
	def.is_temporary = bool(data.get("is_temporary", true))
	def.is_repeatable = bool(data.get("is_repeatable", false))
	
	def.flags.clear()
	for f in data.get("flags", []):
		def.flags.append(StringName(f))
		
	return def
