extends Node

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 PHASE 4 LANDMARKS + NPC/ENEMY SUITE")
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
	print("\n[1] Phase 4 assets...")
	var req := [
		"res://assets/sprites/objects/phase4_landmark_hunter_arch.png",
		"res://assets/sprites/objects/phase4_landmark_nen_shrine.png",
		"res://assets/sprites/objects/phase4_landmark_ruin_pillar.png",
		"res://assets/sprites/characters/npc_phase4_guarda_estrada_8dir.png",
		"res://assets/sprites/characters/enemy_phase4_fera_padokia_8dir.png",
	]
	for p in req:
		_ok(ResourceLoader.exists(p), "Existe: %s" % p.get_file())
	_ok(FileAccess.file_exists("res://scripts/tools/pixellab_phase4_landmarks.py"), "script pixellab_phase4_landmarks.py")
	_ok(FileAccess.file_exists("res://world/components/WorldLandmarkKit.gd"), "WorldLandmarkKit.gd")
	_ok(FileAccess.file_exists("res://docs/bibles/ART_PIPELINE_CANON.md"), "ART_PIPELINE_CANON.md")


func _test_kits() -> void:
	print("\n[2] WorldLandmarkKit...")
	var Estrada = load("res://world/maps/EstradaPadokiaMap.gd")
	var Floresta = load("res://world/maps/FlorestaVestigiosMap.gd")
	_ok(Estrada != null, "EstradaPadokiaMap carrega")
	_ok(Floresta != null, "FlorestaVestigiosMap carrega")
	if Estrada == null or Floresta == null:
		return

	var e = Estrada.new()
	e.name = "EstradaP4"
	add_child(e)
	await get_tree().process_frame
	await get_tree().process_frame
	var ek = e.get_node_or_null("WorldLandmarkKit")
	_ok(ek != null, "WorldLandmarkKit Estrada")
	if ek:
		_ok(ek.get_node_or_null("Phase4Landmarks") != null, "Phase4Landmarks Estrada")
		_ok(ek.get_node_or_null("Phase4Landmarks/P4Arch_Norte") != null, "Arch Estrada")
		_ok(ek.get_node_or_null("Phase4Landmarks/P4Pillar_Oeste") != null, "Pillar Estrada")
		_ok(ek.get_node_or_null("Phase4Landmarks/P4Shrine_Leste") != null, "Shrine Estrada")
		_ok(ek.get_node_or_null("GuardaEstradaAmbient") != null, "Guarda ambient Estrada")
		_ok(ek.get_node_or_null("FeraPadokiaAmbient") == null, "Sem Fera na Estrada")
	e.queue_free()
	await get_tree().process_frame

	var f = Floresta.new()
	f.name = "FlorestaP4"
	add_child(f)
	await get_tree().process_frame
	await get_tree().process_frame
	var fk = f.get_node_or_null("WorldLandmarkKit")
	_ok(fk != null, "WorldLandmarkKit Floresta")
	if fk:
		_ok(fk.get_node_or_null("Phase4Landmarks/P4Shrine_Centro") != null, "Shrine Floresta")
		_ok(fk.get_node_or_null("Phase4Landmarks/P4Pillar_Norte") != null, "Pillar Norte Floresta")
		_ok(fk.get_node_or_null("Phase4Landmarks/P4Arch_Sul") != null, "Arch Sul Floresta")
		_ok(fk.get_node_or_null("FeraPadokiaAmbient") != null, "Fera ambient Floresta")
		_ok(fk.get_node_or_null("GuardaEstradaAmbient") == null, "Sem Guarda na Floresta")
	f.queue_free()
	await get_tree().process_frame
