extends SceneTree

func _init() -> void:
	print("--- INSPEÇÃO DETALHADA DE VERSÕES DE TILES ---")
	
	var paths = [
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Interiors_free_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Floors_TILESET_A2_.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Walls_TILESET_A4_.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Interiors/Theme_Sorter_MV/Living_Room_01.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_XP/0_Everything.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_XP/2_LivingRoom.png"
	]
	
	for p in paths:
		var tex = load(p) as Texture2D
		if tex:
			print("Arquivo: %s" % p.get_file())
			print("  Dimensão: %d x %d pixels" % [tex.get_width(), tex.get_height()])
		else:
			print("Arquivo não encontrado: %s" % p)
			
	quit()
