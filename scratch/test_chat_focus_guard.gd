extends SceneTree

## Garante que o chat começa travado e não rouba input do player.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := 0
	var script := load("res://ui/chat/MultiplayerChatHUD.gd")
	if script == null:
		push_error("MultiplayerChatHUD missing")
		quit(1)
		return
	var hud: Node = script.new()
	root.add_child(hud)
	await process_frame
	await process_frame

	var line: LineEdit = hud.get("line_input") as LineEdit
	if line == null:
		line = _find_line(hud)
	if line == null:
		push_error("LineEdit not found")
		failed += 1
	else:
		if line.editable:
			push_error("chat should start non-editable")
			failed += 1
		else:
			print("OK chat starts locked")
		if line.focus_mode != Control.FOCUS_NONE:
			push_error("chat should start FOCUS_NONE")
			failed += 1
		else:
			print("OK chat FOCUS_NONE")
		if hud.has_method("_abrir_chat"):
			hud.call("_abrir_chat")
			await process_frame
			if not line.editable:
				push_error("chat should be editable after open")
				failed += 1
			else:
				print("OK chat opens editable")
		if hud.has_method("_fechar_chat"):
			hud.call("_fechar_chat")
			await process_frame
			if line.editable or line.focus_mode != Control.FOCUS_NONE:
				push_error("chat should lock after close")
				failed += 1
			else:
				print("OK chat closes locked")

	print("=== RESULT failed=%d ===" % failed)
	quit(1 if failed > 0 else 0)


func _find_line(n: Node) -> LineEdit:
	if n is LineEdit:
		return n as LineEdit
	for c in n.get_children():
		var f := _find_line(c)
		if f != null:
			return f
	return null
