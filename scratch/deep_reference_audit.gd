extends SceneTree

func _init():
	var path = "res://assets/sprites/characters/player.png"
	var img = Image.load_from_file(ProjectSettings.globalize_path(path))
	var fw = 48
	var fh = 48
	var cols = img.get_width() / fw
	var rows = img.get_height() / fh

	print("=== DETAILED METRICS OF PLAYER REFERENCE SHEET ===")
	print("Sheet Size: %dx%d (%d columns, %d rows, %d total frames)" % [img.get_width(), img.get_height(), cols, rows, cols * rows])

	var anim_names = [
		"idle_down", "idle_right", "idle_up",
		"walk_down", "walk_right", "walk_up",
		"attack_down", "attack_right", "attack_up",
		"death"
	]

	var all_colors = {}
	var heights = []
	var widths = []
	var feet_y_list = []
	var head_y_list = []

	for row in range(rows):
		var row_name = anim_names[row] if row < anim_names.size() else "row_%d" % row
		print("\n--- Row %d: %s ---" % [row, row_name])
		for col in range(cols):
			var frame_img = img.get_region(Rect2i(col * fw, row * fh, fw, fh))
			var min_x = fw; var max_x = -1; var min_y = fh; var max_y = -1
			var colors_in_frame = {}
			var opaque_count = 0

			for y in range(fh):
				for x in range(fw):
					var p = frame_img.get_pixel(x, y)
					if p.a > 0.1:
						opaque_count += 1
						var hex = p.to_html(false)
						all_colors[hex] = all_colors.get(hex, 0) + 1
						colors_in_frame[hex] = colors_in_frame.get(hex, 0) + 1
						if x < min_x: min_x = x
						if x > max_x: max_x = x
						if y < min_y: min_y = y
						if y > max_y: max_y = y

			if opaque_count > 0:
				var w = max_x - min_x + 1
				var h = max_y - min_y + 1
				widths.append(w)
				heights.append(h)
				feet_y_list.append(max_y)
				head_y_list.append(min_y)
				print("  Col %d: BBox [%d,%d -> %d,%d] (%dx%d px) | Feet Y=%d, Head Y=%d | %d opaque px, %d colors" % [
					col, min_x, min_y, max_x, max_y, w, h, max_y, min_y, opaque_count, colors_in_frame.size()
				])

	# Overall statistics
	var min_w = 999; var max_w = -1; var avg_w = 0.0
	var min_h = 999; var max_h = -1; var avg_h = 0.0
	for w in widths:
		if w < min_w: min_w = w
		if w > max_w: max_w = w
		avg_w += w
	avg_w /= widths.size()
	for h in heights:
		if h < min_h: min_h = h
		if h > max_h: max_h = h
		avg_h += h
	avg_h /= heights.size()

	print("\n=== SUMMARY STATISTICS ===")
	print("Character Width: Min=%d, Max=%d, Avg=%.1f px (in 48px canvas)" % [min_w, max_w, avg_w])
	print("Character Height: Min=%d, Max=%d, Avg=%.1f px (in 48px canvas)" % [min_h, max_h, avg_h])
	print("Feet Y baseline: mode around 42 (range %d to %d)" % [feet_y_list.min(), feet_y_list.max()])
	print("Head Y top: range %d to %d (typically 20-23 for standing)" % [head_y_list.min(), head_y_list.max()])
	print("Total unique colors across all 24 frames: %d" % all_colors.size())

	print("\n=== COMPLETE PALETTE BREAKDOWN ===")
	var sorted_c = []
	for k in all_colors:
		sorted_c.append({"hex": k, "count": all_colors[k]})
	sorted_c.sort_custom(func(a, b): return a.count > b.count)
	for item in sorted_c:
		print("  Color #%s: %d pixels" % [item.hex, item.count])

	quit(0)
