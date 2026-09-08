extends SceneTree

func _init() -> void:
	var files = [
		'assets/sprites/tilesets/construcoes/casa_1.png',
		'assets/sprites/tilesets/construcoes/casa_2.png',
		'assets/sprites/tilesets/construcoes/castelo.png',
		'assets/sprites/tilesets/construcoes/monasterio.png',
		'assets/sprites/tilesets/construcoes/quartel.png',
		'assets/sprites/tilesets/construcoes/torre.png'
	]
	for path in files:
		var img = Image.load_from_file(path)
		if img:
			var w = img.get_width()
			var h = img.get_height()
			var min_x = w; var max_x = 0; var min_y = h; var max_y = 0
			for y in range(h):
				for x in range(w):
					if img.get_pixel(x, y).a > 0.05:
						if x < min_x: min_x = x
						if x > max_x: max_x = x
						if y < min_y: min_y = y
						if y > max_y: max_y = y
			print(path.get_file(), ' Image:', w, 'x', h, ' Opaque: [', min_x, ',', max_x, '] w=', (max_x - min_x + 1), ' y:[', min_y, ',', max_y, '] h=', (max_y - min_y + 1))
	quit()
