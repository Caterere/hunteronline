extends SceneTree

func _init():
	var path = "res://assets/sprites/characters/player.png"
	var img = Image.load_from_file(ProjectSettings.globalize_path(path))
	var frame = img.get_region(Rect2i(0, 0, 48, 48))

	print("=== FRAME 0 ASCII PIXEL MATRIX ===")
	# Map colors to readable tokens
	# #573a23 = H (hair base)
	# #402717 = h (hair shadow)
	# #21110d = # (hair deep)
	# #c1ac8f = S (skin light)
	# #ac7b5d = s (skin base)
	# #000000 = B (black outline / eye)
	# #0c0e19 = O (dark body outline)
	# #a4a8b5 = T (shirt)
	# #787e97 = t (shirt shadow)
	# #2c65b5 = P (pants)
	# #1d438a = p (pants shadow)

	for y in range(20, 44):
		var line = "%02d: " % y
		for x in range(16, 33):
			var p = frame.get_pixel(x, y)
			if p.a < 0.1:
				line += ". "
			else:
				var hex = p.to_html(false)
				match hex:
					"573a23": line += "H "
					"402717": line += "h "
					"21110d": line += "# "
					"c1ac8f": line += "S "
					"ac7b5d": line += "s "
					"000000": line += "B "
					"0c0e19": line += "O "
					"a4a8b5": line += "T "
					"787e97": line += "t "
					"2c65b5": line += "P "
					"1d438a": line += "p "
					_: line += "? "
		print(line)
	quit(0)
