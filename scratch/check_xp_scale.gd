extends SceneTree

func _init() -> void:
	var path_xp = "res://assets/sprites/tilesets/Modern_Interiors_RPG_Maker_Version/Modern_Interiors_RPG_Maker_Version/RPG_MAKER_XP/2_LivingRoom.png"
	var tex = load(path_xp) as Texture2D
	if tex:
		print("RPG_MAKER_XP 2_LivingRoom: width=%d, height=%d (Cols de 16px: %d, Rows de 16px: %d | Cols de 32px: %d, Rows de 32px: %d)" % [
			tex.get_width(), tex.get_height(),
			tex.get_width() / 16, tex.get_height() / 16,
			tex.get_width() / 32, tex.get_height() / 32
		])
	quit()
