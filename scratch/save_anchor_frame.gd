extends SceneTree

func _init():
	var sheet = Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/characters/player.png"))
	var f0 = sheet.get_region(Rect2i(0, 0, 48, 48))
	f0.save_png("res://assets/sprites/characters/player_frame0_anchor.png")
	print("Saved player_frame0_anchor.png (48x48)")
	quit(0)
