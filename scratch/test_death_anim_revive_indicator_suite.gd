extends Node2D

## Valida animação death no Player + indicador de revive.

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== PREREQ-2 death anim + revive indicator ===")
	_test_player_scene_has_death()
	_test_indicator_script()
	_test_network_player_downed_api()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_player_scene_has_death() -> void:
	print("\n[1] Player.tscn death")
	var scn: PackedScene = load("res://entities/Player/Player.tscn")
	_ok(scn != null, "Player.tscn carrega")
	if scn == null:
		return
	var player: Node = scn.instantiate()
	add_child(player)
	var anim: AnimationPlayer = player.get_node_or_null("Animation") as AnimationPlayer
	_ok(anim != null, "AnimationPlayer existe")
	_ok(anim != null and anim.has_animation("death"), "anim 'death' no library")
	if anim != null and anim.has_animation("death"):
		var a: Animation = anim.get_animation("death")
		_ok(a != null and a.track_get_key_count(0) >= 3, "death tem >= 3 keys de frame")
		if a != null and a.track_get_key_count(0) >= 3:
			var f0 = a.track_get_key_value(0, 0)
			var f2 = a.track_get_key_value(0, 2)
			_ok(int(f0) == 57 and int(f2) == 59, "frames 57..59 (últimos 3 do sheet)")
	var tree: AnimationTree = player.get_node_or_null("AnimationTree") as AnimationTree
	_ok(tree != null, "AnimationTree existe")
	if tree != null:
		var root = tree.tree_root
		_ok(root != null and root.has_node("death"), "state machine tem nó death")
	_ok(player.has_method("tocar_animacao_morte"), "Player.tocar_animacao_morte")
	_ok(player.has_method("limpar_estado_desmaio"), "Player.limpar_estado_desmaio")
	if player.has_method("tocar_animacao_morte"):
		player.tocar_animacao_morte()
		_ok(bool(player.get("_esta_desmaiado")), "flag desmaiado após tocar morte")
		var ind = player.get_node_or_null("DownedReviveIndicator")
		_ok(ind != null and ind.visible, "indicador self visível")
	player.queue_free()


func _test_indicator_script() -> void:
	print("\n[2] DownedReviveIndicator")
	var script = load("res://entities/Player/components/DownedReviveIndicator.gd")
	_ok(script != null, "script carrega")
	var node: Node2D = script.new()
	add_child(node)
	await get_tree().process_frame
	node.call("show_for_ally", true)
	_ok(node.visible, "show_for_ally deixa visível")
	var lbls: Array = []
	_collect_labels(node, lbls)
	var joined := ""
	for l in lbls:
		joined += str(l.text) + " "
	_ok(joined.find("DESMAIADO") >= 0, "texto DESMAIADO")
	_ok(joined.find("[E]") >= 0 or joined.find("Reviver") >= 0, "texto [E] Reviver")
	node.call("hide_prompt")
	_ok(not node.visible, "hide_prompt")
	node.queue_free()


func _collect_labels(n: Node, out: Array) -> void:
	if n is Label:
		out.append(n)
	for c in n.get_children():
		_collect_labels(c, out)


func _test_network_player_downed_api() -> void:
	print("\n[3] NetworkPlayer set_downed")
	var np_script = load("res://scripts/network/NetworkPlayer.gd")
	_ok(np_script != null, "NetworkPlayer carrega")
	var np: Node = np_script.new()
	add_child(np)
	await get_tree().process_frame
	_ok(np.has_method("set_downed"), "tem set_downed")
	np.call("set_downed", true, Vector2(50, 60))
	_ok(bool(np.get("is_downed")), "is_downed true")
	var spr: Sprite2D = np.get("sprite") as Sprite2D
	_ok(spr != null and spr.hframes == 6 and spr.vframes == 10, "sprite 6x10")
	_ok(spr != null and spr.frame >= 57, "frame de morte")
	var ind = np.get_node_or_null("DownedReviveIndicator")
	_ok(ind != null and ind.visible, "indicador ally visível")
	np.call("set_downed", false)
	_ok(not bool(np.get("is_downed")), "is_downed false após revive")
	np.queue_free()
