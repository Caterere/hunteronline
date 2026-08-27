extends SceneTree

func _init() -> void:
	var path_builder = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png"
	var img = Image.load_from_file(path_builder)
	
	print("--- AMOSTRAGEM DE TILES (ROOM BUILDER) ---")
	# Inspecionar cores predominantes de alguns tiles para identificar piso, parede, borda
	var coordenadas_teste = [
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), # Pisos/Paredes superiores
		Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), # Piso de Madeira
		Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5), # Piso Cerâmico / Concreto
		Vector2i(0, 9), Vector2i(1, 9), Vector2i(2, 9), # Piso Alternativo
		Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1)  # Paredes
	]
	
	for coord in coordenadas_teste:
		var c_centro = img.get_pixel(coord.x * 16 + 8, coord.y * 16 + 8)
		print("Tile (%d, %d): Cor Centro RGBA = (%.2f, %.2f, %.2f, %.2f)" % [coord.x, coord.y, c_centro.r, c_centro.g, c_centro.b, c_centro.a])
		
	quit()
