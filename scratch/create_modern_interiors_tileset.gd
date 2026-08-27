extends SceneTree

func _init() -> void:
	print("--- GERANDO TILESET MODERN INTERIORS (16x16) ---")
	
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	
	# 1. Source 0: Room Builder (Paredes, Pisos, Janelas, Portas)
	var path_builder = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png"
	var tex_builder = load(path_builder) as Texture2D
	var src_builder = TileSetAtlasSource.new()
	src_builder.texture = tex_builder
	src_builder.texture_region_size = Vector2i(16, 16)
	
	var cols_b = tex_builder.get_width() / 16
	var rows_b = tex_builder.get_height() / 16
	for y in range(rows_b):
		for x in range(cols_b):
			src_builder.create_tile(Vector2i(x, y))
			
	tileset.add_source(src_builder, 0)
	print("Source 0 (Room Builder): %d tiles adicionados (%d x %d)" % [cols_b * rows_b, cols_b, rows_b])
	
	# 2. Source 1: Interiors (Móveis, Decorações, Camas, Cadeiras, Mesas)
	var path_interiors = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Interiors_free_16x16.png"
	var tex_interiors = load(path_interiors) as Texture2D
	var src_interiors = TileSetAtlasSource.new()
	src_interiors.texture = tex_interiors
	src_interiors.texture_region_size = Vector2i(16, 16)
	
	var cols_i = tex_interiors.get_width() / 16
	var rows_i = tex_interiors.get_height() / 16
	for y in range(rows_i):
		for x in range(cols_i):
			src_interiors.create_tile(Vector2i(x, y))
			
	tileset.add_source(src_interiors, 1)
	print("Source 1 (Interiors): %d tiles adicionados (%d x %d)" % [cols_i * rows_i, cols_i, rows_i])
	
	var save_path = "res://world/tilesets/modern_interiors_tileset.tres"
	var err = ResourceSaver.save(tileset, save_path)
	if err == OK:
		print("✅ TileSet salvo com sucesso em: ", save_path)
	else:
		print("❌ Erro ao salvar TileSet: ", err)
		
	quit()
