extends SceneTree

# ============================================================
# Builder genérico: tileset Wang do PixelLab -> TileSet Godot
# (autotiling por cantos, 2 terrenos). Lê tile_size do metadata.
#
# Uso:
#   godot --headless -s res://scratch/build_topdown_tileset.gd -- \
#       <tex.png> <meta.json> <out.tres> <nome_terreno_lower> <nome_terreno_upper>
# ============================================================

func _init() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() < 5:
		push_error("args: <tex.png> <meta.json> <out.tres> <lower_name> <upper_name>")
		quit(1); return
	var tex_path := a[0]
	var meta_path := a[1]
	var out_path := a[2]
	var lower_name := a[3]
	var upper_name := a[4]

	var tex := load(tex_path) as Texture2D
	if tex == null:
		push_error("Textura não importada: %s" % tex_path); quit(1); return
	var f := FileAccess.open(meta_path, FileAccess.READ)
	if f == null:
		push_error("Metadata não encontrado: %s" % meta_path); quit(1); return
	var meta: Dictionary = JSON.parse_string(f.get_as_text())
	f.close()

	var tsize_d = meta.get("tile_size", {"width": 16, "height": 16})
	var tile := int(tsize_d.get("width", 16))
	var tiles: Array = meta.get("tileset_data", {}).get("tiles", [])
	if tiles.is_empty():
		push_error("Metadata sem tiles."); quit(1); return

	var ts := TileSet.new()
	ts.tile_shape = TileSet.TILE_SHAPE_SQUARE
	ts.tile_size = Vector2i(tile, tile)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(tile, tile)
	ts.add_source(src)

	ts.add_terrain_set()
	ts.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	ts.add_terrain(0)
	ts.set_terrain_name(0, 0, lower_name)
	ts.set_terrain_color(0, 0, Color(0.35, 0.7, 0.35))
	ts.add_terrain(0)
	ts.set_terrain_name(0, 1, upper_name)
	ts.set_terrain_color(0, 1, Color(0.7, 0.5, 0.3))

	var corner_bit := {
		"NW": TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
		"NE": TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
		"SW": TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
		"SE": TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	}
	var n := 0
	for t in tiles:
		var bb: Dictionary = t.get("bounding_box", {})
		var coords := Vector2i(int(bb.get("x", 0)) / tile, int(bb.get("y", 0)) / tile)
		if not src.has_tile(coords):
			src.create_tile(coords)
		var td := src.get_tile_data(coords, 0)
		td.terrain_set = 0
		var corners: Dictionary = t.get("corners", {})
		for ck in corner_bit.keys():
			var terr := 1 if str(corners.get(ck, "lower")) == "upper" else 0
			td.set_terrain_peering_bit(corner_bit[ck], terr)
		n += 1

	var err := ResourceSaver.save(ts, out_path)
	if err != OK:
		push_error("Falha ao salvar: %d" % err); quit(1); return
	print("[build_topdown_tileset] OK — %d tiles (%dpx), %s/%s -> %s" % [n, tile, lower_name, upper_name, out_path])
	quit(0)
