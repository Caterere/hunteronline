extends SceneTree

func _init():
	var img = Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/characters/player.png"))
	var count = 0
	for y in range(img.get_height()):
		var ly = y % 48
		for x in range(img.get_width()):
			var lx = x % 48
			var c = img.get_pixel(x, y)
			if c.a > 0.05 and c.a < 0.95:
				count += 1
				if count <= 10:
					print("Partial alpha at sheet(%d,%d) frame(%d,%d): alpha=%.3f, color=#%s" % [x, y, lx, ly, c.a, c.to_html(true)])
	print("Total partial alpha pixels: ", count)
	quit(0)
