class_name RoomComposer
extends RefCounted

# ============================================================
# HUNTER ONLINE - ROOM COMPOSER (COMPOSITOR SEMÂNTICO DE SALAS)
# ============================================================
#
# Construtor de alto nível que recebe instruções semânticas
# e monta ambientes completos sem nenhuma coordenada hardcoded:
# - Preenche pisos com IDs de piso do catálogo
# - Resolve cantos e bordas de paredes com WallSets (9-slice)
# - Abre vãos de porta e posiciona soleiras
# - Posiciona objetos compostos (multi-tile) e móveis individuais
#
# ============================================================

const TileDatabaseScript = preload("res://world/catalog/TileDatabase.gd")


static func compose_room(
	layers: Dictionary, # {"chao": TileMapLayer, "paredes": TileMapLayer, "decor": TileMapLayer}
	room_rect: Rect2i,
	floor_id: String = "wood_floor_parquet",
	wall_set_id: String = "wood_wall_classic",
	door_pos: Vector2i = Vector2i(-1, -1),
	furniture_list: Array = [] # Array de Dictionaries: {"id": String, "pos": Vector2i}
) -> bool:
	var db = TileDatabaseScript.get_instance()
	var chao_layer: TileMapLayer = layers.get("chao", null)
	var paredes_layer: TileMapLayer = layers.get("paredes", null)
	var decor_layer: TileMapLayer = layers.get("decor", null)
	
	if chao_layer == null or paredes_layer == null:
		push_error("[RoomComposer] Camadas chao ou paredes não fornecidas!")
		return false
		
	# ------------------------------------------------------------
	# 1. PREENCHER CHÃO (FLOOR)
	# ------------------------------------------------------------
	var floor_entry = db.get_tile(floor_id)
	if floor_entry == null:
		floor_entry = db.get_random_floor()
		
	if floor_entry != null:
		for y in range(room_rect.position.y, room_rect.position.y + room_rect.size.y):
			for x in range(room_rect.position.x, room_rect.position.x + room_rect.size.x):
				chao_layer.set_cell(Vector2i(x, y), floor_entry.source_id, floor_entry.atlas_coords)
				
	# ------------------------------------------------------------
	# 2. CONSTRUIR PAREDES COM RESOLUÇÃO DE CANTOS (WALL SET)
	# ------------------------------------------------------------
	var ws = db.get_wall_set(wall_set_id)
	if ws != null:
		var x0 = room_rect.position.x
		var y0 = room_rect.position.y
		var x1 = room_rect.position.x + room_rect.size.y - 1 # Note: x1 is position.x + size.x - 1
		x1 = room_rect.position.x + room_rect.size.x - 1
		var y1 = room_rect.position.y + room_rect.size.y - 1
		
		# Cantos
		_colocar_tile_por_id(paredes_layer, db, Vector2i(x0, y0), ws.corner_top_left)
		_colocar_tile_por_id(paredes_layer, db, Vector2i(x1, y0), ws.corner_top_right)
		_colocar_tile_por_id(paredes_layer, db, Vector2i(x0, y1), ws.corner_bottom_left)
		_colocar_tile_por_id(paredes_layer, db, Vector2i(x1, y1), ws.corner_bottom_right)
		
		# Borda Superior e Inferior
		for x in range(x0 + 1, x1):
			_colocar_tile_por_id(paredes_layer, db, Vector2i(x, y0), ws.wall_top)
			_colocar_tile_por_id(paredes_layer, db, Vector2i(x, y1), ws.wall_bottom)
			
		# Borda Esquerda e Direita
		for y in range(y0 + 1, y1):
			_colocar_tile_por_id(paredes_layer, db, Vector2i(x0, y), ws.wall_left)
			_colocar_tile_por_id(paredes_layer, db, Vector2i(x1, y), ws.wall_right)
			
	# ------------------------------------------------------------
	# 3. ABERTURA DE PORTA (DOOR OPENING & THRESHOLD)
	# ------------------------------------------------------------
	if door_pos.x >= 0 and door_pos.y >= 0:
		paredes_layer.erase_cell(door_pos)
		_colocar_tile_por_id(chao_layer, db, door_pos, "door_threshold_wood")
		
	# ------------------------------------------------------------
	# 4. POSICIONAR MOBÍLIAS & OBJETOS COMPOSTOS
	# ------------------------------------------------------------
	for item in furniture_list:
		var item_id = item.get("id", "")
		var item_pos = item.get("pos", Vector2i.ZERO)
		
		# Verificar se é Objeto Composto
		var comp_obj = db.get_composite_object(item_id)
		if comp_obj != null:
			for part in comp_obj.parts:
				var dx = part.get("dx", 0)
				var dy = part.get("dy", 0)
				var target_cell = item_pos + Vector2i(dx, dy)
				var src_id = part.get("source_id", 1)
				var coords_arr = part.get("atlas_coords", [0, 0])
				var coords = Vector2i(coords_arr[0], coords_arr[1])
				var layer_id = part.get("layer", 2)
				var target_layer = decor_layer if (layer_id == 2 and decor_layer != null) else paredes_layer
				target_layer.set_cell(target_cell, src_id, coords)
			continue
			
		# Verificar se é Tile Individual
		var single_tile = db.get_tile(item_id)
		if single_tile != null:
			var target_layer = decor_layer if (single_tile.layer == 2 and decor_layer != null) else paredes_layer
			target_layer.set_cell(item_pos, single_tile.source_id, single_tile.atlas_coords)
			
	return true


static func _colocar_tile_por_id(layer: TileMapLayer, db: RefCounted, cell: Vector2i, tile_id: String) -> void:
	if tile_id.is_empty(): return
	var entry = db.get_tile(tile_id)
	if entry != null:
		layer.set_cell(cell, entry.source_id, entry.atlas_coords)
