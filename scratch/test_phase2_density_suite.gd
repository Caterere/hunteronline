extends Node

# ============================================================
# HUNTER ONLINE — Phase 2 world density smoke
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 PHASE 2 WORLD DENSITY SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_assets()
	await _test_estrada()
	await _test_floresta()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	if not _failures.is_empty():
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
	print("\n[1] Phase 2 assets...")
	var required := [
		"res://assets/sprites/tilesets/pixellab/phase2_grass_dirt_wang.png",
		"res://assets/sprites/objects/phase2_tree_green_a.png",
		"res://assets/sprites/objects/phase2_tree_green_b.png",
		"res://assets/sprites/objects/phase2_tree_autumn_a.png",
		"res://assets/sprites/objects/phase2_bush_berry.png",
		"res://assets/sprites/objects/phase2_bush_round.png",
		"res://assets/sprites/objects/phase2_rock_boulder.png",
		"res://assets/sprites/objects/phase2_rock_cluster.png",
		"res://assets/sprites/objects/phase2_flowers_white.png",
		"res://assets/sprites/objects/phase2_stump.png",
		"res://assets/reference/world_detail_grass_dirt_trees_ref.png",
	]
	for path in required:
		_ok(ResourceLoader.exists(path), "Existe: %s" % path.get_file())
	var wang: Texture2D = load("res://assets/sprites/tilesets/pixellab/phase2_grass_dirt_wang.png")
	_ok(wang != null and wang.get_width() == 64 and wang.get_height() == 64, "Wang phase2 64x64")


func _test_estrada() -> void:
	print("\n[2] WorldDensityKit na Estrada...")
	var MapScript = load("res://world/maps/EstradaPadokiaMap.gd")
	_ok(MapScript != null, "EstradaPadokiaMap carrega")
	if MapScript == null:
		return
	var mapa = MapScript.new()
	mapa.name = "EstradaPhase2Smoke"
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	var kit = mapa.get_node_or_null("WorldDensityKit")
	_ok(kit != null, "WorldDensityKit anexado (Estrada)")
	if kit != null:
		_ok(kit.get_node_or_null("DensityProps") != null, "DensityProps Estrada")
		_ok(kit.get_node_or_null("DensityProps/P2Tree_0") != null, "Árvore phase2 Estrada")
		_ok(kit.get_node_or_null("DensityProps/P2Bush_0") != null, "Bush phase2 Estrada")
		_ok(kit.get_node_or_null("DensityProps/P2Flower_0") != null, "Flores Estrada")
	mapa.queue_free()
	await get_tree().process_frame


func _test_floresta() -> void:
	print("\n[3] WorldDensityKit na Floresta...")
	var MapScript = load("res://world/maps/FlorestaVestigiosMap.gd")
	_ok(MapScript != null, "FlorestaVestigiosMap carrega")
	if MapScript == null:
		return
	var mapa = MapScript.new()
	mapa.name = "FlorestaPhase2Smoke"
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	var kit = mapa.get_node_or_null("WorldDensityKit")
	_ok(kit != null, "WorldDensityKit anexado (Floresta)")
	if kit != null:
		_ok(kit.get_node_or_null("DensityProps") != null, "DensityProps Floresta")
		_ok(kit.get_node_or_null("DensityProps/P2FTree_0") != null, "Árvore phase2 Floresta")
		_ok(kit.get_node_or_null("DensityProps/P2FBush_0") != null, "Bush phase2 Floresta")
		_ok(kit.get_node_or_null("DensityProps/P2FRock_0") != null, "Rock phase2 Floresta")
	mapa.queue_free()
	await get_tree().process_frame
