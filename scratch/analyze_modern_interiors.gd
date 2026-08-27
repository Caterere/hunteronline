extends SceneTree

func _init() -> void:
	print("==================================================")
	print("ANALISE DETALHADA DOS ASSETS MODERN INTERIORS")
	print("==================================================")
	
	var paths = [
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Interiors_free_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/32x32/Room_Builder_32x32.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/48x48/Room_Builder_48x48.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Interiors/Theme_Sorter_MV/A2_Floors_MV.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Interiors/Theme_Sorter_MV/A4_Walls_MV.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Interiors/Theme_Sorter_MV/B-C-D-E_Living_Room_01.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Interiors/Theme_Sorter_MV/B-C-D-E_Bedroom_01.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Interiors/Theme_Sorter_MV/B-C-D-E_Kitchen_01.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Interiors/Theme_Sorter_MV/B-C-D-E_Grocery_Store_01.png"
	]
	
	for p in paths:
		if ResourceLoader.exists(p):
			var tex = load(p) as Texture2D
			if tex:
				var w = tex.get_width()
				var h = tex.get_height()
				print("\n📁 Arquivo: ", p.get_file())
				print("   Caminho: ", p)
				print("   Dimensões: %d x %d px" % [w, h])
				print("   16x16: %d colunas x %d linhas (%d tiles)" % [w / 16, h / 16, (w / 16) * (h / 16)])
				print("   32x32: %d colunas x %d linhas (%d tiles)" % [w / 32, h / 32, (w / 32) * (h / 32)])
				print("   48x48: %d colunas x %d linhas (%d tiles)" % [w / 48, h / 48, (w / 48) * (h / 48)])
		else:
			print("❌ Não encontrado: ", p)
			
	quit(0)
