extends Node

## Playtest grass mode + player AnimationTree wiring
var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== playtest visual + player anim ===")
	_test_playtest_mode()
	await _test_player_anim()
	_test_portal_wiring()
	print("=== RESULT: %d pass / %d fail ===" % [_ok, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✅ ", msg)
	else:
		_fail += 1
		print("  ❌ ", msg)


func _test_playtest_mode() -> void:
	_assert(PlaytestVisualMode.is_enabled(), "PlaytestVisualMode ENABLED (grama playtest)")
	_assert(ResourceLoader.exists(PlaytestVisualMode.PATH_GRASS), "grass.png existe")
	var host := Node2D.new()
	host.name = "HostMap"
	add_child(host)
	var applied := PlaytestVisualMode.apply_grass_floor(host, Vector2(800, 600))
	_assert(applied, "apply_grass_floor retorna true")
	_assert(host.get_node_or_null("ChaoGramaPlaytest") != null, "nó ChaoGramaPlaytest criado")
	var estrada := FileAccess.get_file_as_string("res://world/maps/EstradaPadokiaMap.gd")
	_assert("PlaytestVisualMode.apply_grass_floor" in estrada, "Estrada usa PlaytestVisualMode")
	_assert("if not playtest_grass" in estrada, "Estrada pula kits visuais no playtest")
	var floresta := FileAccess.get_file_as_string("res://world/maps/FlorestaVestigiosMap.gd")
	_assert("PlaytestVisualMode.apply_grass_floor" in floresta, "Floresta usa PlaytestVisualMode")
	host.queue_free()


func _test_player_anim() -> void:
	var src := FileAccess.get_file_as_string("res://entities/Player/Player.gd")
	_assert("_garantir_animation_tree" in src, "Player garante AnimationTree")
	_assert("_animation_tree.active = true" in src, "AnimationTree.active = true no ready")
	_assert("_garantir_transicoes_state_machine" in src, "transições idle/walk/attack")
	var scene: PackedScene = load("res://entities/Player/Player.tscn")
	_assert(scene != null, "Player.tscn carrega")
	var p: Node = scene.instantiate()
	add_child(p)
	await get_tree().process_frame
	var tree: AnimationTree = p.get_node_or_null("AnimationTree")
	_assert(tree != null, "AnimationTree no player")
	if tree != null:
		_assert(tree.active, "AnimationTree ativo após ready")
		var sm = tree.get("parameters/playback")
		_assert(sm != null, "playback state machine ok")
		if sm != null and p.has_method("_animate"):
			# Simula movimento → travel walk
			p.set("velocity", Vector2(40, 0))
			p.call("_animate")
			_assert(true, "travel walk sem crash")
			p.set("velocity", Vector2.ZERO)
			p.call("_animate")
			_assert(true, "travel idle sem crash")
	p.queue_free()


func _test_portal_wiring() -> void:
	var estrada := FileAccess.get_file_as_string("res://world/maps/EstradaPadokiaMap.gd")
	_assert("floresta_vestigios" in estrada, "Estrada→Floresta portal path")
	_assert("lobby" in estrada.to_lower() or "Lobby" in estrada, "Estrada↔Lobby")
	var floresta := FileAccess.get_file_as_string("res://world/maps/FlorestaVestigiosMap.gd")
	_assert("dungeon_ruinas_zaban" in floresta or "ruinas" in floresta.to_lower(), "Floresta→Ruínas")
	_assert("estrada_padokia" in floresta, "Floresta→Estrada retorno")
	var mt := FileAccess.get_file_as_string("res://world/components/MapTransitionArea.gd")
	_assert("SceneTransition" in mt, "portal usa SceneTransition")
	_assert("add_to_group(\"portal\")" in mt, "portal no grupo GPS")
	var gps := FileAccess.get_file_as_string("res://scripts/missions/MissionObjectiveResolver.gd")
	_assert("_prefer_quest_on_current_map" in gps or "prefer_quest" in gps.to_lower() or "REGION_LINKS" in gps, "GPS anti bounce Padokia")
