extends Node

# Live ops — stub de hot-reload (F9) para dev; não recarrega assets em produção ainda.

const ContentVersionConfigScript = preload("res://scripts/core/ContentVersionConfig.gd")

signal reload_requested()
signal reload_finished(ok: bool, detail: String)

var _cooldown_sec: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F9:
			tentar_reload_debug()
			get_viewport().set_input_as_handled()


func tentar_reload_debug() -> Dictionary:
	if _cooldown_sec > 0.0:
		return {"ok": false, "reason": "COOLDOWN"}
	reload_requested.emit()
	var detail := "ContentHotReload stub: revalidando ContentVersionConfig + caches leves."
	var info = ContentVersionConfigScript.get_version_info()
	if not info.is_empty():
		detail += " [%s / %s / save %s]" % [
			str(info.get("game_version", "")),
			str(info.get("content_version", "")),
			str(info.get("save_version", "")),
		]
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("F9 Hot Reload (stub): OK", Color(0.5, 0.9, 1.0))
	print("[ContentHotReload] ", detail)
	reload_finished.emit(true, detail)
	_cooldown_sec = 2.0
	return {"ok": true, "detail": detail}


func _process(delta: float) -> void:
	if _cooldown_sec > 0.0:
		_cooldown_sec = maxf(0.0, _cooldown_sec - delta)
