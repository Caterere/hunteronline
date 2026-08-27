extends SceneTree

func _init() -> void:
	print("--- CONSTRUINDO MASTER WORLD TILESET (16x16) ---")
	
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	tileset.add_physics_layer(0)
	tileset.set_physics_layer_collision_layer(0, 1) # Layer 1 (Mundo/Paredes)
	
	var sources_info = [
		{"id": 0, "path": "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png", "has_col": false},
		{"id": 1, "path": "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Interiors_free_16x16.png", "has_col": false},
		{"id": 2, "path": "res://assets/sprites/tilesets/grass.png", "has_col": false},
		{"id": 3, "path": "res://assets/sprites/tilesets/plains.png", "has_col": false},
		{"id": 4, "path": "res://assets/sprites/tilesets/walls/walls.png", "has_col": true},
		{"id": 5, "path": "res://assets/sprites/tilesets/decor_16x16.png", "has_col": false},
		{"id": 6, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Tileset Grass.png", "has_col": false},
		{"id": 7, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Plant.png", "has_col": false},
		{"id": 8, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Props.png", "has_col": false},
		{"id": 9, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Struct.png", "has_col": false},
		{"id": 10, "path": "res://assets/sprites/tilesets/terreno/agua.png", "has_col": false}
	]
	
	for info in sources_info:
		if not ResourceLoader.exists(info["path"]):
			continue
			
		var tex = load(info["path"]) as Texture2D
		if tex == null:
			continue
			
		var src = TileSetAtlasSource.new()
		src.texture = tex
		src.texture_region_size = Vector2i(16, 16)
		
		var cols = tex.get_width() / 16
		var rows = tex.get_height() / 16
		
		for y in range(rows):
			for x in range(cols):
				var tile_coord = Vector2i(x, y)
				src.create_tile(tile_coord)
				
		tileset.add_source(src, info["id"])
		
		# Adicionar colisão se for a fonte de paredes (Source 4) após adicionar ao TileSet
		if info["has_col"]:
			var poly = PackedVector2Array([
				Vector2(-8, -8),
				Vector2(8, -8),
				Vector2(8, 8),
				Vector2(-8, 8)
			])
			for y in range(rows):
				for x in range(cols):
					var td = src.get_tile_data(Vector2i(x, y), 0)
					if td != null:
						td.set_collision_polygons_count(0, 1)
						td.set_collision_polygon_points(0, 0, poly)
						
		print("  ✅ Source %d carregado: %s (%d tiles)" % [info["id"], info["path"].get_file(), cols * rows])
		
	var save_path = "res://world/tilesets/world_tileset.tres"
	var err = ResourceSaver.save(tileset, save_path)
	if err == OK:
		print("🎉 Master TileSet salvo com sucesso em: ", save_path)
	else:
		print("❌ Erro ao salvar Master TileSet: ", err)
		
	quit(0 if err == OK else 1)
