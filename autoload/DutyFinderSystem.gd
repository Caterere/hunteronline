extends Node

## Duty Finder — filas dungeon/raid/arena com fill offline (stub).
## Cosmético de matchmaking; não altera balanceamento de combate.

signal queue_updated(duty_id: String, status: String, filled: int, needed: int)
signal match_ready(duty_id: String, party: Array)
signal queue_cancelled(duty_id: String)

const DUTIES := {
	"ruins_zaban_vertical": {
		"id": "ruins_zaban_vertical",
		"kind": "raid",
		"title": "Ruínas de Zaban (Raid 8)",
		"needed": 8,
		"min_level": 12,
		"scene": "res://world/maps/DungeonRuinasZabanMap.tscn",
	},
	"coop_dungeon_default": {
		"id": "coop_dungeon_default",
		"kind": "dungeon",
		"title": "Masmorra Cooperativa",
		"needed": 4,
		"min_level": 5,
		"scene": "res://world/maps/DungeonRuinasZabanMap.tscn",
	},
	"arena_1v1_ranked": {
		"id": "arena_1v1_ranked",
		"kind": "arena",
		"title": "Heaven's Arena Ranked 1v1",
		"needed": 2,
		"min_level": 1,
		"scene": "",
	},
}

var _active_duty: String = ""
var _filled: int = 0
var _needed: int = 0
var _party: Array = []
var _elapsed: float = 0.0
var _offline_fill_rate: float = 1.2 ## stubs por segundo em fila offline


func _process(delta: float) -> void:
	if _active_duty.is_empty():
		return
	_elapsed += delta
	# Fill offline stubs até completar
	if _filled < _needed:
		var add := int(floor(_elapsed * _offline_fill_rate)) - (_filled - 1)
		if add > 0:
			for i in range(add):
				if _filled >= _needed:
					break
				_filled += 1
				_party.append({"peer_id": 1000 + _filled, "stub": true, "name": "Hunter Stub %d" % _filled})
			queue_updated.emit(_active_duty, "queued", _filled, _needed)
	if _filled >= _needed:
		_ready_match()


func list_duties() -> Array:
	var out: Array = []
	for k in DUTIES.keys():
		out.append((DUTIES[k] as Dictionary).duplicate(true))
	return out


func get_duty(duty_id: String) -> Dictionary:
	return DUTIES.get(duty_id, {}).duplicate(true)


func is_queued() -> bool:
	return not _active_duty.is_empty()


func get_queue_status() -> Dictionary:
	return {
		"duty_id": _active_duty,
		"filled": _filled,
		"needed": _needed,
		"party": _party.duplicate(true),
		"elapsed": _elapsed,
	}


func enqueue(duty_id: String, local_peer_id: int = 1) -> Dictionary:
	if not DUTIES.has(duty_id):
		return {"ok": false, "error": "duty_desconhecido"}
	if not _active_duty.is_empty():
		return {"ok": false, "error": "ja_na_fila"}
	var d: Dictionary = DUTIES[duty_id]
	_active_duty = duty_id
	_needed = int(d.get("needed", 4))
	_filled = 1
	_party = [{"peer_id": local_peer_id, "stub": false, "name": "You"}]
	_elapsed = 0.0
	set_process(true)
	queue_updated.emit(_active_duty, "queued", _filled, _needed)
	return {"ok": true, "duty": d.duplicate(true)}


func cancel_queue() -> void:
	var was := _active_duty
	_reset()
	if not was.is_empty():
		queue_cancelled.emit(was)


func _ready_match() -> void:
	var duty_id := _active_duty
	var party := _party.duplicate(true)
	var d: Dictionary = DUTIES.get(duty_id, {})
	match_ready.emit(duty_id, party)
	# Wire raid / party mode when applicable
	if str(d.get("kind", "")) == "raid" and PartyManager != null and PartyManager.has_method("entrar_modo_raid"):
		PartyManager.entrar_modo_raid()
	if str(d.get("kind", "")) == "raid":
		_start_raid_instance(duty_id, party)
	_reset()


func _start_raid_instance(duty_id: String, party: Array) -> void:
	var members: Array[int] = []
	for row in party:
		if row is Dictionary:
			members.append(int(row.get("peer_id", 0)))
	var catalog: Dictionary = RaidCatalog.get_raid(duty_id)
	# RaidInstance is RefCounted (not a Node) — keep via Engine meta only
	if Engine.has_meta("active_raid_instance"):
		Engine.remove_meta("active_raid_instance")
	var raid := RaidInstance.new()
	raid.start_raid(duty_id, members, catalog)
	Engine.set_meta("active_raid_instance", raid)
	Engine.set_meta("active_raid_id", duty_id)
	if SeasonPassSystem != null and SeasonPassSystem.has_method("notify_raid_queue"):
		SeasonPassSystem.notify_raid_queue()


func _reset() -> void:
	_active_duty = ""
	_filled = 0
	_needed = 0
	_party.clear()
	_elapsed = 0.0
	set_process(false)
