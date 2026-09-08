extends SceneTree

func _init():
	var paths = [
		'res://assets/sprites/objects/boneco_treino_dummy.png',
		'res://assets/sprites/objects/fogueira_acampamento_prop.png',
		'res://assets/sprites/objects/marco_pedra_milestone.png'
	]
	for path in paths:
		var img = Image.load_from_file(ProjectSettings.globalize_path(path))
		var w = img.get_width()
		var h = img.get_height()
		var min_x = w; var max_x = -1; var min_y = h; var max_y = -1
		for y in range(h):
			for x in range(w):
				if img.get_pixel(x, y).a > 0.05:
					if x < min_x: min_x = x
					if x > max_x: max_x = x
					if y < min_y: min_y = y
					if y > max_y: max_y = y
		print('%s -> BBox: [%d,%d -> %d,%d] => %dx%d' % [path.get_file(), min_x, min_y, max_x, max_y, max_x - min_x + 1, max_y - min_y + 1])
	quit(0)
