extends Node

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 PHASE 6 MAP POLISH + STORY + SECRETS SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_assets()
	await _test_kits()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	for f in _failures:
		print("   ❌ ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)


func _test_assets() -> void:
	print("\n[1] Phase 6 assets...")
	var req := [
		"res://assets/sprites/objects/phase6_story_abandoned_camp.png",
		"res://assets/sprites/objects/phase6_story_broken_cart.png",
		"res://assets/sprites/objects/phase6_story_scuffle_mark.png",
		"res://assets/sprites/objects/phase6_story_torn_banner.png",
		"res://assets/sprites/objects/phase6_story_broken_weapon.png",
		"res://assets/sprites/objects/phase6_secret_hollow_stump.png",
		"res://assets/sprites/objects/phase6_secret_false_rock.png",
		"res://assets/sprites/objects/phase6_secret_glint.png",
		"res://assets/sprites/objects/phase6_secret_trail_marker.png",
		"res://assets/sprites/objects/phase6_polish_path_crack.png",
		"res://assets/sprites/objects/phase6_polish_moss_patch.png",
		"res://assets/sprites/objects/phase6_polish_fence_ruin.png",
	]
	for p in req:
		_ok(ResourceLoader.exists(p), "Existe: %s" % p.get_file())
	_ok(FileAccess.file_exists("res://scripts/tools/pixellab_phase6_polish.py"), "script pixellab_phase6_polish.py")
	_ok(FileAccess.file_exists("res://world/components/WorldPolishKit.gd"), "WorldPolishKit.gd")
	_ok(FileAccess.file_exists("res://assets/sprites/tilesets/pixellab/phase6_polish_jobs.json"), "phase6_polish_jobs.json")


func _test_kits() -> void:
	print("\n[2] WorldPolishKit...")
	var Estrada = load("res://world/maps/EstradaPadokiaMap.gd")
	var Floresta = load("res://world/maps/FlorestaVestigiosMap.gd")
	_ok(Estrada != null, "EstradaPadokiaMap carrega")
	_ok(Floresta != null, "FlorestaVestigiosMap carrega")
	if Estrada == null or Floresta == null:
		return

	var e = Estrada.new()
	e.name = "EstradaP6"
	add_child(e)
	await get_tree().process_frame
	await get_tree().process_frame
	var ek = e.get_node_or_null("WorldPolishKit")
	_ok(ek != null, "WorldPolishKit Estrada")
	if ek:
		_ok(ek.get_node_or_null("Phase6Polish") != null, "Phase6Polish Estrada")
		_ok(ek.get_node_or_null("Phase6Story") != null, "Phase6Story Estrada")
		_ok(ek.get_node_or_null("Phase6Secrets") != null, "Phase6Secrets Estrada")
		_ok(ek.get_node_or_null("Phase6Story/P6Camp") != null, "Story camp Estrada")
		_ok(ek.get_node_or_null("Phase6Secrets/P6Secret_Stump") != null, "Secret stump Estrada")
		_ok(ek.get_node_or_null("Phase6Polish/P6Fence_Ruin") != null, "Polish fence Estrada")
	e.queue_free()
	await get_tree().process_frame

	var f = Floresta.new()
	f.name = "FlorestaP6"
	add_child(f)
	await get_tree().process_frame
	await get_tree().process_frame
	var fk = f.get_node_or_null("WorldPolishKit")
	_ok(fk != null, "WorldPolishKit Floresta")
	if fk:
		_ok(fk.get_node_or_null("Phase6Polish/P6Moss_0") != null, "Moss Floresta")
		_ok(fk.get_node_or_null("Phase6Story/P6Banner") != null, "Story banner Floresta")
		_ok(fk.get_node_or_null("Phase6Secrets/P6Secret_Glint") != null, "Secret glint Floresta")
		_ok(fk.get_node_or_null("Phase6Secrets/P6Secret_Marker2") != null, "Secret marker2 Floresta")
	f.queue_free()
	await get_tree().process_frame
