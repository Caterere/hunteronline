extends SceneTree

## Headless: densificação Yorknew/Arena + kits de props + audit chibi player.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := 0
	print("=== TEST: overnight map polish ===")

	failed += await _check_kit(WorldPropsKit.KitKind.ESTRADA, 20, "ESTRADA")
	failed += await _check_kit(WorldPropsKit.KitKind.FLORESTA, 20, "FLORESTA")
	failed += await _check_kit(WorldPropsKit.KitKind.YORKNEW, 40, "YORKNEW")
	failed += await _check_kit(WorldPropsKit.KitKind.ARENA, 25, "ARENA")
	failed += await _check_kit(WorldPropsKit.KitKind.DUNGEON, 30, "DUNGEON")

	var player_tex: Texture2D = load("res://assets/sprites/characters/player.png")
	var gon_tex: Texture2D = load("res://assets/sprites/characters/npc_gon_8dir.png")
	if player_tex == null or player_tex.get_width() != 288:
		push_error("player sheet unexpected (expect 288x480 legacy 48px)")
		failed += 1
	else:
		print("OK player legacy 48px sheet ", player_tex.get_width(), "x", player_tex.get_height())
	if gon_tex == null or gon_tex.get_width() != 768:
		push_error("gon 8dir unexpected (expect 768x96 = 96px frames)")
		failed += 1
	else:
		print("OK gon quality-pack 96px ", gon_tex.get_width(), "x", gon_tex.get_height())
	print("CHIBI: cast priority 96px (~2.5 heads); player regen Style Lock v2 = P0 arte")

	var err := change_scene_to_file("res://world/lobby.tscn")
	if err != OK:
		push_error("lobby load failed")
		failed += 1
	else:
		await process_frame
		await process_frame
		await create_timer(0.45).timeout
		var found: Node = null
		for n in root.get_children():
			if n.get_script() != null and str(n.get_script().resource_path).ends_with("Lobby.gd"):
				found = n
				break
		if found == null and root.get_child_count() > 0:
			found = root.get_child(root.get_child_count() - 1)
		var decor: Node = null
		if found != null:
			decor = found.get_node_or_null("LobbyPixelDecorRoot")
		if decor == null:
			push_error("LobbyPixelDecorRoot missing")
			failed += 1
		else:
			var n := decor.get_child_count()
			print("OK LobbyPixelDecorRoot children=", n)
			if n < 25:
				push_error("lobby decor too sparse: %d" % n)
				failed += 1

	print("=== RESULT failed=", failed, " ===")
	if failed == 0:
		print("ALL PASS")
	quit(1 if failed > 0 else 0)


func _check_kit(kind: int, min_count: int, label: String) -> int:
	var host := Node2D.new()
	root.add_child(host)
	var kit := WorldPropsKit.new()
	kit.kit_kind = kind
	host.add_child(kit)
	await process_frame
	await process_frame
	var phase := kit.get_node_or_null("Phase3Props")
	var count := 0 if phase == null else phase.get_child_count()
	print("  %s Phase3Props count=%d" % [label, count])
	host.queue_free()
	await process_frame
	if count < min_count:
		push_error("%s props too sparse: %d (min %d)" % [label, count, min_count])
		return 1
	print("OK %s props=%d" % [label, count])
	return 0
