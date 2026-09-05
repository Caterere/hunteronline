class_name PlayerNetworkState
extends RefCounted

# ============================================================
# HUNTER ONLINE — PLAYER NETWORK STATE (COMPACT SERIALIZATION)
# ============================================================
#
# Estrutura padronizada para transporte de dados vitais, posicionais
# e cosméticos entre o cliente e o servidor de jogo.
# ============================================================

var peer_id: int = 1
var character_name: String = "Hunter"
var level: int = 1
var nen_affinity: String = "Intensificação"
var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN
var hp: int = 100
var hp_max: int = 100
var aura: float = 100.0
var aura_max: float = 100.0
var active_nen: String = ""
var active_hatsu_id: String = ""
var animation: String = "idle"
var is_sprinting: bool = false
var is_dodging: bool = false
var is_dead: bool = false
var timestamp_ms: int = 0


func to_dict() -> Dictionary:
	return {
		"pid": peer_id,
		"name": character_name,
		"lvl": level,
		"aff": nen_affinity,
		"px": snappedf(position.x, 0.1),
		"py": snappedf(position.y, 0.1),
		"vx": snappedf(velocity.x, 0.1),
		"vy": snappedf(velocity.y, 0.1),
		"fx": snappedf(facing.x, 0.01),
		"fy": snappedf(facing.y, 0.01),
		"hp": hp,
		"hp_max": hp_max,
		"aura": snappedf(aura, 0.1),
		"aura_max": snappedf(aura_max, 0.1),
		"nen": active_nen,
		"hatsu": active_hatsu_id,
		"anim": animation,
		"sprint": is_sprinting,
		"dodge": is_dodging,
		"dead": is_dead,
		"ts": timestamp_ms
	}


static func from_dict(d: Dictionary) -> PlayerNetworkState:
	var state := (load("res://scripts/network/PlayerNetworkState.gd") as GDScript).new() as PlayerNetworkState
	state.peer_id = int(d.get("pid", 1))
	state.character_name = str(d.get("name", "Hunter"))
	state.level = int(d.get("lvl", 1))
	state.nen_affinity = str(d.get("aff", "Intensificação"))
	state.position = Vector2(float(d.get("px", 0.0)), float(d.get("py", 0.0)))
	state.velocity = Vector2(float(d.get("vx", 0.0)), float(d.get("vy", 0.0)))
	state.facing = Vector2(float(d.get("fx", 0.0)), float(d.get("fy", 1.0)))
	state.hp = int(d.get("hp", 100))
	state.hp_max = int(d.get("hp_max", 100))
	state.aura = float(d.get("aura", 100.0))
	state.aura_max = float(d.get("aura_max", 100.0))
	state.active_nen = str(d.get("nen", ""))
	state.active_hatsu_id = str(d.get("hatsu", ""))
	state.animation = str(d.get("anim", "idle"))
	state.is_sprinting = bool(d.get("sprint", false))
	state.is_dodging = bool(d.get("dodge", false))
	state.is_dead = bool(d.get("dead", false))
	state.timestamp_ms = int(d.get("ts", Time.get_ticks_msec()))
	return state
