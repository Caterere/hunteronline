extends SceneTree

func analyze_image(label: String, path: String, frame_w: int, frame_h: int):
	var real_path = ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	var img = Image.load_from_file(real_path)
	if not img:
		print("Failed to load: ", path)
		return
	print("\n================== ", label, " ==================")
	print("Size: ", img.get_width(), "x", img.get_height())
	var colors = {}
	var transparent_count = 0
	var opaque_count = 0
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)
			if c.a < 0.05:
				transparent_count += 1
			else:
				opaque_count += 1
				var hex = c.to_html(false)
				colors[hex] = colors.get(hex, 0) + 1
	print("Total unique opaque colors in whole sheet: ", colors.size())
	print("Opaque pixels: ", opaque_count, " | Transparent pixels: ", transparent_count)
	
	# Analyze first frame bounding box
	var fw = mini(frame_w, img.get_width())
	var fh = mini(frame_h, img.get_height())
	var min_x = fw; var max_x = -1; var min_y = fh; var max_y = -1
	var frame_colors = {}
	for y in range(fh):
		for x in range(fw):
			var c = img.get_pixel(x, y)
			if c.a > 0.05:
				if x < min_x: min_x = x
				if x > max_x: max_x = x
				if y < min_y: min_y = y
				if y > max_y: max_y = y
				var h = c.to_html(false)
				frame_colors[h] = frame_colors.get(h, 0) + 1
	var ow = (max_x - min_x + 1) if max_x >= min_x else 0
	var oh = (max_y - min_y + 1) if max_y >= min_y else 0
	print("Frame 0 BBox: [", min_x, ",", min_y, " -> ", max_x, ",", max_y, "] -> ", ow, "x", oh)
	print("Frame 0 unique opaque colors: ", frame_colors.size())
	var sorted_frame_colors = []
	for k in frame_colors:
		sorted_frame_colors.append({"hex": k, "count": frame_colors[k]})
	sorted_frame_colors.sort_custom(func(a, b): return a.count > b.count)
	for sc in sorted_frame_colors:
		print("   Frame color #", sc.hex, ": ", sc.count)

func _init():
	analyze_image("CANONICAL PLAYER (res://assets/sprites/characters/player.png)", "res://assets/sprites/characters/player.png", 48, 48)
	analyze_image("DOWNLOADS HUNTER ONLINE STYLE REFERENCE", "C:/Users/Ditec/Downloads/hunter_online_style_reference_240x240.png", 48, 48)
	analyze_image("DOWNLOADS CHARACTER MODEL", "C:/Users/Ditec/Downloads/charactermodel.png", 48, 48)
	analyze_image("REJECTED PIXELLAB GON", "C:/Users/Ditec/Downloads/pixellab-Create-a-48-48-pixel-art-game--1788658904936.png", 48, 48)
	quit(0)
