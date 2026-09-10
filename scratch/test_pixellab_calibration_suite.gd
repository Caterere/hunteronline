extends Node

# ============================================================
# HUNTER ONLINE — PixelLab Calibration Batch §94 smoke
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 PIXELLAB CALIBRATION BATCH §94 SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_assets_on_disk()
	await _test_estrada_kit()
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


func _test_assets_on_disk() -> void:
	print("\n[1] Assets do Batch 94 presentes...")
	var required := [
		"res://assets/sprites/tilesets/pixellab/calibration_grass_dirt_wang.png",
		"res://assets/sprites/objects/calibration_tree_a.png",
		"res://assets/sprites/objects/calibration_tree_b.png",
		"res://assets/sprites/objects/calibration_bush_a.png",
		"res://assets/sprites/objects/calibration_rock_a.png",
		"res://assets/sprites/objects/calibration_rock_b.png",
		"res://assets/sprites/objects/calibration_ground_details.png",
		"res://assets/sprites/characters/npc_calibration_viajante_padokia_8dir.png",
	]
	for path in required:
		_ok(ResourceLoader.exists(path), "Asset existe: %s" % path.get_file())

	var sheet: Texture2D = load("res://assets/sprites/characters/npc_calibration_viajante_padokia_8dir.png")
	_ok(sheet != null and sheet.get_width() == 384 and sheet.get_height() == 48, "NPC sheet 384x48 (8×48)")
	var wang: Texture2D = load("res://assets/sprites/tilesets/pixellab/calibration_grass_dirt_wang.png")
	_ok(wang != null and wang.get_width() == 64 and wang.get_height() == 64, "Wang grass/dirt 64x64")


func _test_estrada_kit() -> void:
	print("\n[2] CalibrationArtKit na Estrada Real...")
	var MapScript = load("res://world/maps/EstradaPadokiaMap.gd")
	_ok(MapScript != null, "EstradaPadokiaMap.gd carrega")
	if MapScript == null:
		return

	var mapa = MapScript.new()
	mapa.name = "EstradaCalibrationSmoke"
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	var kit = mapa.get_node_or_null("CalibrationArtKit")
	_ok(kit != null, "CalibrationArtKit anexado")
	if kit != null:
		_ok(kit.get_node_or_null("CalibrationProps") != null, "CalibrationProps presente")
		_ok(kit.get_node_or_null("CalibrationProps/CalTreeA_1") != null, "Tree A presente")
		_ok(kit.get_node_or_null("CalibrationProps/CalTreeB_1") != null, "Tree B presente")
		_ok(kit.get_node_or_null("CalibrationProps/CalBush_1") != null, "Bush A presente")
		_ok(kit.get_node_or_null("CalibrationProps/CalRockA_1") != null, "Rock A presente")
		_ok(kit.get_node_or_null("CalibrationProps/CalRockB_1") != null, "Rock B presente")
		_ok(kit.get_node_or_null("CalibrationProps/CalGround_1") != null, "Ground details presente")
		_ok(kit.get_node_or_null("ViajanteCalibracao") != null, "ViajanteCalibracao NPC presente")
		var viajante = kit.get_node_or_null("ViajanteCalibracao")
		if viajante != null:
			var spr = viajante.get_node_or_null("Sprite2D") as Sprite2D
			_ok(spr != null and spr.hframes == 8, "Viajante hframes=8")
			_ok(spr != null and spr.texture != null, "Viajante textura carregada")

	mapa.queue_free()
	await get_tree().process_frame
