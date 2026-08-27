extends SceneTree

func _init() -> void:
	var path_builder = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png"
	var img = Image.load_from_file(path_builder)
	
	print("--- MAPA DE TILES EM ROOM BUILDER 16x16 ---")
	print("Dimensões: %d x %d (Tiles: %d colunas, %d linhas)" % [img.get_width(), img.get_height(), img.get_width() / 16, img.get_height() / 16])
	
	# Verificar se os tiles possuem pixels preenchidos
	for y in range(img.get_height() / 16):
		var row_str = "Linha %02d: " % y
		for x in range(img.get_width() / 16):
			var has_content = false
			for py in range(16):
				for px in range(16):
					var col = img.get_pixel(x * 16 + px, y * 16 + py)
					if col.a > 0.1:
						has_content = true
						break
				if has_content:
					break
			row_str += "[X]" if has_content else "[ ]"
		print(row_str)
		
	quit()
