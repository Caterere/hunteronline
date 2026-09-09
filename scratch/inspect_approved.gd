extends SceneTree

func _init():
	var paths = [
		"res://assets/sprites/characters/npc_recepcionista_elena_8dir.png",
		"res://assets/sprites/characters/npc_instrutor_combate_8dir.png"
	]
	for p in paths:
		var img = Image.load_from_file(ProjectSettings.globalize_path(p))
		print(p.get_file(), ": total size = ", img.get_width(), "x", img.get_height())
		for f in range(8):
			var frame = img.get_region(Rect2i(f * 48, 0, 48, 48))
			var min_x = 48; var max_x = -1; var min_y = 48; var max_y = -1
			for y in range(48):
				for x in range(48):
					if frame.get_pixel(x, y).a > 0.1:
						if x < min_x: min_x = x
						if x > max_x: max_x = x
						if y < min_y: min_y = y
						if y > max_y: max_y = y
			var bw = max_x - min_x + 1 if max_x >= min_x else 0
			var bh = max_y - min_y + 1 if max_y >= min_y else 0
			print("  frame %d: bbox=[%d,%d -> %d,%d] size=%dx%d feet_y=%d" % [f, min_x, min_y, max_x, max_y, bw, bh, max_y])
	quit(0)
