extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var failed := 0
	print("=== TEST: Lobby / map density ===")
	var err := change_scene_to_file("res://world/lobby.tscn")
	if err != OK:
		push_error("failed to load lobby"); quit(1); return
	await process_frame
	await process_frame
	await create_timer(0.4).timeout
	var lobby := root.get_child(root.get_child_count() - 1)
	# scene tree root children vary; find Lobby
	var scene := root.get_node_or_null("/root") 
	var found: Node = null
	for n in root.get_children():
		if n.get_script() != null and str(n.get_script().resource_path).ends_with("Lobby.gd"):
			found = n
			break
	if found == null:
		# current scene
		found = root.get_child(root.get_child_count()-1)
	var decor := found.get_node_or_null("LobbyPixelDecorRoot")
	if decor == null:
		push_error("LobbyPixelDecorRoot missing"); failed += 1
	else:
		var n := decor.get_child_count()
		print("OK LobbyPixelDecorRoot children=", n)
		if n < 25:
			push_error("expected denser lobby decor (>=25), got %d" % n); failed += 1
		else:
			print("OK lobby density threshold")
	# chibi audit sizes
	var player_tex: Texture2D = load("res://assets/sprites/characters/player.png")
	var gon_tex: Texture2D = load("res://assets/sprites/characters/npc_gon_8dir.png")
	if player_tex:
		print("OK player sheet ", player_tex.get_width(), "x", player_tex.get_height(), " (expect 288x480 = 48px frames)")
		if player_tex.get_width() != 288:
			push_error("player sheet unexpected"); failed += 1
	if gon_tex:
		print("OK gon 8dir ", gon_tex.get_width(), "x", gon_tex.get_height(), " (expect 768x96 = 96px frames)")
	print("CHIBI AUDIT: player still 48px legacy; named cast NPCs 96px quality-pack — regen player is P0")
	print("=== RESULT failed=", failed, " ===")
	quit(1 if failed > 0 else 0)
