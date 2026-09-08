extends SceneTree

func _init():
	var path = 'res://assets/sprites/characters/player.png'
	var img = Image.load_from_file(ProjectSettings.globalize_path(path))
	var frame_w = 48
	var frame_h = 48
	for row in range(4):
		for col in range(6):
			var idx = row * 6 + col
			var frame_img = img.get_region(Rect2i(col * frame_w, row * frame_h, frame_w, frame_h))
			var min_x = frame_w
			var max_x = -1
			var min_y = frame_h
			var max_y = -1
			for y in range(frame_h):
				for x in range(frame_w):
					if frame_img.get_pixel(x, y).a > 0.05:
						if x < min_x: min_x = x
						if x > max_x: max_x = x
						if y < min_y: min_y = y
						if y > max_y: max_y = y
			var opaque_w = (max_x - min_x + 1) if max_x >= min_x else 0
			var opaque_h = (max_y - min_y + 1) if max_y >= min_y else 0
			if opaque_h > 0:
				print('Frame %d (r=%d, c=%d): BBox [%d,%d -> %d,%d] -> %dx%d' % [idx, row, col, min_x, min_y, max_x, max_y, opaque_w, opaque_h])
	quit(0)
