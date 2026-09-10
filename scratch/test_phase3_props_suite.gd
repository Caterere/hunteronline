extends Node

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 PHASE 3 PROPS + ART CANON SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_docs_canon()
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


func _test_docs_canon() -> void:
	print("\n[1] Docs canônicos...")
	_ok(FileAccess.file_exists("res://docs/bibles/ART_PIPELINE_CANON.md"), "ART_PIPELINE_CANON.md")
	_ok(FileAccess.file_exists("res://docs/bibles/PIXEL_ART_PRODUCTION_BIBLE.md"), "PIXEL_ART_PRODUCTION_BIBLE.md em docs/bibles")
	_ok(FileAccess.file_exists("res://docs/guides/PIXELLAB_PROMPT_LIBRARY.md"), "PIXELLAB_PROMPT_LIBRARY.md em docs/guides")
	_ok(FileAccess.file_exists("res://docs/bibles/PIXEL_ART_STYLE_BIBLE.md"), "PIXEL_ART_STYLE_BIBLE.md")
	# stubs na raiz
	_ok(FileAccess.file_exists("res://HUNTER_ONLINE_PIXELART_PRODUCTION_BIBLE.md"), "stub Production na raiz")
	_ok(FileAccess.file_exists("res://HUNTER_ONLINE_PIXELLAB_PROMPT_LIBRARY.md"), "stub Prompt Library na raiz")


func _test_assets() -> void:
	print("\n[2] Phase 3 assets...")
	var req := [
		"res://assets/sprites/objects/phase3_fence_wood.png",
		"res://assets/sprites/objects/phase3_fence_wood_post.png",
		"res://assets/sprites/objects/phase3_signpost.png",
		"res://assets/sprites/objects/phase3_barrel.png",
		"res://assets/sprites/objects/phase3_crate.png",
		"res://assets/sprites/objects/phase3_crate_large.png",
		"res://assets/sprites/objects/phase3_well.png",
		"res://assets/sprites/objects/phase3_lantern_post.png",
	]
	for p in req:
		_ok(ResourceLoader.exists(p), "Existe: %s" % p.get_file())


func _test_kits() -> void:
	print("\n[3] WorldPropsKit...")
	var Estrada = load("res://world/maps/EstradaPadokiaMap.gd")
	var Floresta = load("res://world/maps/FlorestaVestigiosMap.gd")
	_ok(Estrada != null, "EstradaPadokiaMap carrega")
	_ok(Floresta != null, "FlorestaVestigiosMap carrega")
	if Estrada == null or Floresta == null:
		return

	var e = Estrada.new()
	e.name = "EstradaP3"
	add_child(e)
	await get_tree().process_frame
	await get_tree().process_frame
	var ek = e.get_node_or_null("WorldPropsKit")
	_ok(ek != null, "WorldPropsKit Estrada")
	if ek:
		_ok(ek.get_node_or_null("Phase3Props") != null, "Phase3Props Estrada")
		_ok(ek.get_node_or_null("Phase3Props/P3FenceL_0") != null, "Fence Estrada")
		_ok(ek.get_node_or_null("Phase3Props/P3Sign_Norte") != null, "Sign Estrada")
		_ok(ek.get_node_or_null("Phase3Props/P3Well_0") != null, "Well Estrada")
	e.queue_free()
	await get_tree().process_frame

	var f = Floresta.new()
	f.name = "FlorestaP3"
	add_child(f)
	await get_tree().process_frame
	await get_tree().process_frame
	var fk = f.get_node_or_null("WorldPropsKit")
	_ok(fk != null, "WorldPropsKit Floresta")
	if fk:
		_ok(fk.get_node_or_null("Phase3Props/P3FSign_Entrada") != null, "Sign Floresta")
		_ok(fk.get_node_or_null("Phase3Props/P3FWell_Clareira") != null, "Well Floresta")
	f.queue_free()
	await get_tree().process_frame
