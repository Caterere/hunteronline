extends SceneTree

func _init():
	var img = Image.load_from_file(ProjectSettings.globalize_path("res://scratch/test_gon_south.png"))
	if not img:
		print("Failed to load test_gon_south.png")
		quit(1)
	var w = img.get_width()
	var h = img.get_height()
	var min_x = w; var max_x = -1; var min_y = h; var max_y = -1
	var colors = {}
	for y in range(h):
		for x in range(w):
			var c = img.get_pixel(x, y)
			if c.a > 0.1:
				if x < min_x: min_x = x
				if x > max_x: max_x = x
				if y < min_y: min_y = y
				if y > max_y: max_y = y
				colors[c.to_html(false)] = true
	var bw = max_x - min_x + 1 if max_x >= min_x else 0
	var bh = max_y - min_y + 1 if max_y >= min_y else 0
	print("Test Gon: size=%dx%d bbox=[%d,%d -> %d,%d] dims=%dx%d colors=%d" % [w, h, min_x, min_y, max_x, max_y, bw, bh, colors.size()])
	quit(0)
