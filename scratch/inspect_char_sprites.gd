extends SceneTree

func _init() -> void:
	print("--- INSPEÇÃO DE SPRITESHEETS DE PERSONAGENS ---")
	
	var char_paths = [
		"res://assets/sprites/characters/player.png",
		"res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Player.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Characters_free/Adam_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Characters_free/Adam_idle_anim_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Characters_free/Adam_run_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Characters_free/Alex_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Characters_free/Amelia_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Characters_free/Bob_16x16.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_MV/Characters/Characters_MV.png",
		"res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_VX_ACE (WIP)/Characters_01.png"
	]
	
	for p in char_paths:
		var tex = load(p) as Texture2D
		if tex:
			print("%s: %d x %d px" % [p.get_file(), tex.get_width(), tex.get_height()])
		else:
			print("Não encontrado: %s" % p)
			
	quit()
