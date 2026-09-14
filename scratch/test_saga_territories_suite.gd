extends SceneTree

var _ok := 0
var _fail := 0


func _initialize() -> void:
	print("🚀 SUÍTE SAGA TERRITORIES — packs comprados")
	_check_kit_file()
	_check_pack_paths()
	_check_palettes()
	await _check_runtime_paint()
	_check_hub_wiring()
	print("============================================================")
	print("✅ PASSED: %d | ❌ FAILED: %d" % [_ok, _fail])
	quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✓ ", msg)
	else:
		_fail += 1
		print("  ✗ ", msg)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	return f.get_as_text() if f else ""


func _check_kit_file() -> void:
	print("-- SagaTerritoryKit --")
	var src := _read("res://world/components/SagaTerritoryKit.gd")
	_assert(src.contains("class_name SagaTerritoryKit"), "class_name")
	_assert(src.contains("static func attach"), "attach")
	_assert(src.contains("static func palette_for_saga"), "palette_for_saga")
	_assert(src.contains("world_tileset.tres"), "usa world_tileset")
	_assert(src.contains("TX Tileset Stone Ground.png"), "pack stone")
	_assert(src.contains("floors/wooden.png"), "pack wood")
	_assert(src.contains("floors/carpet.png"), "pack carpet")
	_assert(src.contains("terreno/terreno_"), "pack terreno")
	_assert(src.contains("_build_pack_tileset"), "build pack tileset")
	_assert(not src.contains("_build_solid_tileset"), "não usa tiles sólidos procedurais")


func _check_pack_paths() -> void:
	print("-- Pack paths --")
	var paths := [
		"res://world/tilesets/world_tileset.tres",
		"res://assets/sprites/tilesets/grass.png",
		"res://assets/sprites/tilesets/plains.png",
		"res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Tileset Stone Ground.png",
		"res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Tileset Grass.png",
		"res://assets/sprites/tilesets/floors/wooden.png",
		"res://assets/sprites/tilesets/floors/carpet.png",
		"res://assets/sprites/tilesets/floors/flooring.png",
		"res://assets/sprites/tilesets/terreno/terreno_1.png",
		"res://assets/sprites/tilesets/terreno/agua.png",
	]
	for p in paths:
		_assert(ResourceLoader.exists(p), "exists %s" % p.get_file())


func _check_palettes() -> void:
	print("-- Paletas / receitas --")
	var seen: Array[int] = []
	for s in range(1, 10):
		var pal: Dictionary = SagaTerritoryKit.palette_for_saga(s)
		_assert(pal.has("nome"), "saga %d nome" % s)
		_assert(pal.has("base") and pal["base"] is Dictionary, "saga %d base tile" % s)
		_assert(pal.has("path") and pal["path"] is Dictionary, "saga %d path tile" % s)
		_assert(pal.has("bands") and (pal["bands"] as Array).size() == 4, "saga %d bands" % s)
		var src_id := int((pal["base"] as Dictionary).get("src", -1))
		_assert(src_id >= 0, "saga %d base src" % s)
		seen.append(src_id)


func _check_runtime_paint() -> void:
	print("-- Runtime paint --")
	var root := Node2D.new()
	root.name = "FakeHub"
	get_root().add_child(root)
	var chao := TileMapLayer.new()
	chao.name = "Chao_TileMapLayer"
	root.add_child(chao)
	for sid in range(1, 10):
		var old := root.get_node_or_null("SagaTerritoryKit")
		if old:
			root.remove_child(old)
			old.free()
		var kit := SagaTerritoryKit.attach(root, sid)
		_assert(kit != null, "attach saga %d" % sid)
		# Aguarda bootstrap deferred
		await process_frame
		await process_frame
		var ground := kit.get_node_or_null("SagaTerritoryGround") as TileMapLayer
		if ground == null:
			ground = root.get_node_or_null("SagaTerritoryGround") as TileMapLayer
		_assert(ground != null, "ground layer saga %d" % sid)
		if ground != null:
			_assert(ground.tile_set != null, "tileset saga %d" % sid)
			_assert(ground.get_cell_source_id(Vector2i(0, 0)) != -1, "cell painted saga %d" % sid)
			var src_id := ground.get_cell_source_id(Vector2i(0, 0))
			_assert(ground.tile_set.has_source(src_id), "source válido saga %d" % sid)
		_assert(kit.get_node_or_null("BiomeBanner") != null, "banner saga %d" % sid)
		_assert(kit.get_node_or_null("AmbientFx") != null, "ambient saga %d" % sid)
	root.queue_free()


func _check_hub_wiring() -> void:
	print("-- Hub wiring --")
	var files := {
		1: "res://world/maps/ExameMaratonaMap.gd",
		2: "res://world/maps/MontanhaKukurooMap.gd",
		3: "res://world/maps/ArenaCelestialMap.gd",
		4: "res://world/maps/YorknewCityMap.gd",
		5: "res://world/maps/GreedIslandMap.gd",
		6: "res://world/maps/NGLFormigasMap.gd",
		7: "res://world/maps/AssociacaoHunterMap.gd",
		8: "res://world/maps/ContinenteNegroMap.gd",
		9: "res://world/maps/BlackWhale1Map.gd",
	}
	for sid in files.keys():
		var src := _read(str(files[sid]))
		_assert(src.contains("SagaTerritoryKit.attach(self, %d)" % int(sid)), "wire hub %d" % int(sid))
