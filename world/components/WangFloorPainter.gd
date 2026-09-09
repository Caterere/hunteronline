class_name WangFloorPainter
extends RefCounted

# ============================================================
# Pinta um piso a partir de um TileSet Wang (corner-match) gerado no PixelLab.
# Lookup determinístico canto->tile lido do próprio TileSet (2 terrenos:
# 0 = terreno base/"lower", 1 = terreno "upper").
#
# upper_fn: Callable(cx: int, cy: int) -> bool  — se o CANTO (cx,cy) é "upper".
# Retorna o TileMapLayer criado (ou existente).
# ============================================================

const CORNER_NEIGH := [
	TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
]


static func pintar(parent: Node, tileset_path: String, layer_name: String, z: int,
		x0: int, y0: int, x1: int, y1: int, upper_fn: Callable) -> TileMapLayer:
	if parent == null or parent.get_node_or_null(layer_name) != null:
		return null
	if not ResourceLoader.exists(tileset_path):
		return null
	var ts: TileSet = load(tileset_path)
	var src_id := ts.get_source_id(0)
	var src := ts.get_source(src_id) as TileSetAtlasSource
	if src == null:
		return null

	# Monta o lookup canto->tile a partir dos peering bits do TileSet.
	var lut := {}
	for i in range(src.get_tiles_count()):
		var coords := src.get_tile_id(i)
		var td := src.get_tile_data(coords, 0)
		var key := "%d%d%d%d" % [
			td.get_terrain_peering_bit(CORNER_NEIGH[0]),
			td.get_terrain_peering_bit(CORNER_NEIGH[1]),
			td.get_terrain_peering_bit(CORNER_NEIGH[2]),
			td.get_terrain_peering_bit(CORNER_NEIGH[3]),
		]
		lut[key] = coords

	var layer := TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = ts
	layer.z_index = z
	parent.add_child(layer)

	for ty in range(y0, y1 + 1):
		for tx in range(x0, x1 + 1):
			var key := "%d%d%d%d" % [
				1 if bool(upper_fn.call(tx, ty)) else 0,
				1 if bool(upper_fn.call(tx + 1, ty)) else 0,
				1 if bool(upper_fn.call(tx, ty + 1)) else 0,
				1 if bool(upper_fn.call(tx + 1, ty + 1)) else 0,
			]
			if lut.has(key):
				layer.set_cell(Vector2i(tx, ty), src_id, lut[key])
	return layer
