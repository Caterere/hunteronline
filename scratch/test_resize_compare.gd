extends SceneTree

func _init():
	var elena_img = Image.load_from_file(ProjectSettings.globalize_path('res://assets/sprites/characters/npc_recepcionista_elena_8dir.png'))
	var player_img = Image.load_from_file(ProjectSettings.globalize_path('res://assets/sprites/characters/player.png'))
	
	var elena_frame = elena_img.get_region(Rect2i(0, 0, 68, 68))
	var player_frame = player_img.get_region(Rect2i(0, 0, 48, 48))
	
	# Testar redimensionamentos:
	# 1. Elena original (1.0x) -> 68x68
	# 2. Elena scaled 0.48x via bilinear / area
	var elena_scaled = Image.new()
	elena_scaled.copy_from(elena_frame)
	elena_scaled.resize(int(68 * 0.46), int(68 * 0.46), Image.INTERPOLATE_BILINEAR)
	
	var elena_nearest = Image.new()
	elena_nearest.copy_from(elena_frame)
	elena_nearest.resize(int(68 * 0.46), int(68 * 0.46), Image.INTERPOLATE_NEAREST)
	
	print('Player frame: ', player_frame.get_size())
	print('Elena original frame: ', elena_frame.get_size())
	print('Elena scaled bilinear: ', elena_scaled.get_size())
	print('Elena scaled nearest: ', elena_nearest.get_size())
	
	quit(0)
