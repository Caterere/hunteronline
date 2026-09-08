extends SceneTree

func _init():
	var images = {
		"Satotz": "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/407/media_0.png",
		"Zushi": "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/439/media_0.png",
		"Wing": "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/441/media_0.png",
		"Ferreiro": "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/443/media_0.png",
		"Mercador": "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/445/media_0.png",
		"Guarda": "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/447/media_0.png",
		"Elena": "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/449/media_0.png",
		"Scout": "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/451/media_0.png",
	}
	
	for name in images:
		var path = images[name]
		var img = Image.load_from_file(path)
		if img == null:
			print(name, ": FAILED TO LOAD")
			continue
		var min_x = 999
		var max_x = -1
		var min_y = 999
		var max_y = -1
		var colors = {}
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var c = img.get_pixel(x, y)
				if c.a > 0.05:
					min_x = min(min_x, x)
					max_x = max(max_x, x)
					min_y = min(min_y, y)
					max_y = max(max_y, y)
					var k = "%02x%02x%02x" % [int(c.r*255), int(c.g*255), int(c.b*255)]
					colors[k] = true
		var w = max_x - min_x + 1
		var h = max_y - min_y + 1
		print("%s: %dx%d px | BBox: x=[%d,%d] (w=%d) y=[%d,%d] (h=%d) | feet Y=%d | colors=%d" % [
			name, img.get_width(), img.get_height(), min_x, max_x, w, min_y, max_y, h, max_y, colors.size()
		])
	quit()
