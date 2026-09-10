extends SceneTree

# ============================================================
# Constrói um TileSet Godot (autotiling por cantos / Wang, 2 terrenos)
# a partir do tileset PixelLab da Arena Celestial + seu metadata.
# Saída: res://world/tilesets/arena_celestial_tileset.tres
# ============================================================

const TEX := "res://assets/sprites/tilesets/pixellab/arena_celestial/arena_floor_tileset.png"
const META := "res://assets/sprites/tilesets/pixellab/arena_celestial/arena_floor_tileset_metadata.json"
const OUT := "res://world/tilesets/arena_celestial_tileset.tres"
const TILE := 16

func _init() -> void:
	var tex := load(TEX) as Texture2D
	if tex == null:
		push_error("Textura não encontrada/importada: %s" % TEX); quit(1); return

	var f := FileAccess.open(META, FileAccess.READ)
	var meta: Dictionary = JSON.parse_string(f.get_as_text())
	f.close()
	var tiles: Array = meta.get("tileset_data", {}).get("tiles", [])
	if tiles.is_empty():
		push_error("Metadata sem tiles."); quit(1); return

	var ts := TileSet.new()
	ts.tile_shape = TileSet.TILE_SHAPE_SQUARE
	ts.tile_size = Vector2i(TILE, TILE)

	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE, TILE)
	var src_id := ts.add_source(src)

	# Terrain set com 2 terrenos, casamento por cantos.
	ts.add_terrain_set()
	ts.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	ts.add_terrain(0)
	ts.set_terrain_name(0, 0, "marmore_arena")
	ts.set_terrain_color(0, 0, Color(0.92, 0.86, 0.62))
	ts.add_terrain(0)
	ts.set_terrain_name(0, 1, "tapete_carmesim")
	ts.set_terrain_color(0, 1, Color(0.70, 0.12, 0.16))

	var corner_bit := {
		"NW": TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
		"NE": TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
		"SW": TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
		"SE": TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	}

	var criados := 0
	for t in tiles:
		var bb: Dictionary = t.get("bounding_box", {})
		var coords := Vector2i(int(bb.get("x", 0)) / TILE, int(bb.get("y", 0)) / TILE)
		if not src.has_tile(coords):
			src.create_tile(coords)
		var td := src.get_tile_data(coords, 0)
		td.terrain_set = 0
		var corners: Dictionary = t.get("corners", {})
		for ck in corner_bit.keys():
			var terr := 1 if str(corners.get(ck, "lower")) == "upper" else 0
			td.set_terrain_peering_bit(corner_bit[ck], terr)
		criados += 1

	var err := ResourceSaver.save(ts, OUT)
	if err != OK:
		push_error("Falha ao salvar TileSet: %d" % err); quit(1); return
	print("[build_arena_tileset] OK — %d tiles, terrain_set corner-match, salvo em %s" % [criados, OUT])
	quit(0)
