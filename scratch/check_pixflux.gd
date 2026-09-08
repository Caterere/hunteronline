extends SceneTree

func _init():
	var path = "C:/Users/Ditec/.gemini/antigravity/brain/4d0e3c61-57f7-4ab3-a822-d08b034bbe26/.system_generated/steps/407/media_0.png"
	var img = Image.load_from_file(path)
	if img == null:
		print("Failed to load image")
		quit()
		return
	print("Dimensions: ", img.get_width(), "x", img.get_height())
	var min_x = 999
	var max_x = -1
	var min_y = 999
	var max_y = -1
	var color_set = {}
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)
			if c.a > 0.05:
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)
				var key = "%02x%02x%02x" % [int(c.r*255), int(c.g*255), int(c.b*255)]
				color_set[key] = true
	print("Bounding box: x=[", min_x, ",", max_x, "] y=[", min_y, ",", max_y, "]")
	print("Width: ", max_x - min_x + 1, " Height: ", max_y - min_y + 1)
	print("Feet Y (max_y): ", max_y)
	print("Headroom (min_y): ", min_y)
	print("Unique colors: ", color_set.size())
	quit()
