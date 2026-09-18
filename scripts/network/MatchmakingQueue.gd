class_name MatchmakingQueue
extends RefCounted

# Ponte Duty Finder / arena ↔ fila offline-first (+ anúncio leve no Master Registry).

const MasterServerRegistryScript = preload("res://scripts/network/MasterServerRegistry.gd")

static func list_queues() -> Array:
	if DutyFinderSystem == null:
		return []
	return DutyFinderSystem.list_duties()


static func enqueue(duty_id: String, role: int = 0) -> Dictionary:
	if DutyFinderSystem == null:
		return {"ok": false, "reason": "NO_DUTY_FINDER"}
	return DutyFinderSystem.enqueue(duty_id, role)


static func cancel() -> void:
	if DutyFinderSystem != null:
		DutyFinderSystem.cancel_queue()


static func status() -> Dictionary:
	if DutyFinderSystem == null:
		return {}
	return DutyFinderSystem.get_queue_status()


static func format_registry_queue_line(duty_id: String, filled: int, needed: int) -> String:
	return "QUEUE|%s|%d|%d|%d" % [duty_id, filled, needed, Time.get_ticks_msec()]


static func parse_registry_queue_line(text: String) -> Dictionary:
	if not text.begins_with("QUEUE|"):
		return {}
	var parts := text.split("|")
	if parts.size() < 4:
		return {}
	return {
		"duty_id": parts[1],
		"filled": int(parts[2]),
		"needed": int(parts[3]),
	}


static func announce_queue_to_registry(registry: Variant, duty_id: String, filled: int, needed: int) -> void:
	if registry == null or not registry.is_active or registry.mode != "announce":
		return
	if registry.has_method("send_aux_line"):
		registry.send_aux_line(format_registry_queue_line(duty_id, filled, needed))
