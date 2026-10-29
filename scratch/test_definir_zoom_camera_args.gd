extends SceneTree

## Runtime smoke: definir_zoom_camera(1 arg) e (2 args) sem erro de assinatura.
func _initialize() -> void:
	var fail := 0
	var packed: PackedScene = load("res://entities/Player/Player.tscn")
	if packed == null:
		push_error("FAIL: Player.tscn não carregou")
		quit(1)
		return

	var player: Node = packed.instantiate()
	player.name = "PlayerZoomSmoke"
	root.add_child(player)
	await process_frame

	if not player.has_method("definir_zoom_camera"):
		push_error("FAIL: método ausente")
		fail += 1
	else:
		# Antes do fix isto gerava: Expected 1 argument(s).
		player.call("definir_zoom_camera", Vector2(1.5, 1.5))
		player.call("definir_zoom_camera", Vector2(0.88, 0.88), 0.8)
		player.call("definir_zoom_camera", 1.2, 0.0)
		print("OK: definir_zoom_camera aceita 1 e 2 argumentos")
		var cam: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
		if cam == null:
			push_error("FAIL: Camera2D ausente")
			fail += 1
		else:
			print("OK: Camera2D zoom atual=", cam.zoom)

	var banner_src := FileAccess.get_file_as_string("res://ui/boss/BossIntroBanner.gd")
	if "definir_zoom_camera(Vector2(0.88, 0.88), 0.8)" not in banner_src:
		push_error("FAIL: BossIntroBanner call site")
		fail += 1
	else:
		print("OK: BossIntroBanner call site alinhado")

	player.queue_free()
	await process_frame
	quit(0 if fail == 0 else 1)
