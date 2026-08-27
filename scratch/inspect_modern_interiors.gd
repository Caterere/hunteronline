extends SceneTree

func _init() -> void:
	print("--- INVENTÁRIO MODERN INTERIORS 16x16 ---")
	var path_builder = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png"
	var path_interiors = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Interiors_free_16x16.png"

	var tex_builder = load(path_builder) as Texture2D
	if tex_builder != null:
		var w = tex_builder.get_width()
		var h = tex_builder.get_height()
		print("Room_Builder_free_16x16.png: %d x %d pixels (%d x %d tiles de 16x16)" % [w, h, w / 16, h / 16])
	else:
		print("Falha ao carregar Room_Builder_free_16x16.png")

	var tex_interiors = load(path_interiors) as Texture2D
	if tex_interiors != null:
		var w = tex_interiors.get_width()
		var h = tex_interiors.get_height()
		print("Interiors_free_16x16.png: %d x %d pixels (%d x %d tiles de 16x16)" % [w, h, w / 16, h / 16])
	else:
		print("Falha ao carregar Interiors_free_16x16.png")

	quit()
