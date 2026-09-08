extends SceneTree

func _init() -> void:
	var files = [
		'assets/sprites/tilesets/construcoes/monasterio.png',
		'assets/sprites/tilesets/construcoes/castelo.png',
		'assets/sprites/tilesets/construcoes/quartel.png',
		'assets/sprites/tilesets/construcoes/arquearia.png',
		'assets/sprites/tilesets/construcoes/torre.png',
		'assets/sprites/tilesets/construcoes/casa_1.png',
		'assets/sprites/tilesets/construcoes/casa_2.png',
		'assets/sprites/tilesets/construcoes/casa_3.png'
	]
	for path in files:
		var img = Image.load_from_file(path)
		if not img: continue
		var cols = img.get_width() / 16
		var rows = img.get_height() / 16
		var row_opaque = []
		for r in range(rows):
			var count = 0
			for y in range(r * 16, (r + 1) * 16):
				for x in range(img.get_width()):
					if img.get_pixel(x, y).a > 0.05: count += 1
			row_opaque.append(count)
		print(path.get_file(), ' cols=', cols, ' rows=', rows)
		for r in range(rows):
			if row_opaque[r] > 0 or r >= rows - 4:
				print('  row ', r, ': ', row_opaque[r], ' px')
	quit()
