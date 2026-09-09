extends SceneTree

func _init():
	var raw_img = Image.load_from_file(ProjectSettings.globalize_path("res://scratch/test_gon_south.png"))
	if not raw_img:
		print("Failed to load test_gon_south.png")
		quit(1)

	# 1. Obter Bounding Box exata do personagem na imagem 68x68
	var min_x = 68; var max_x = -1; var min_y = 68; var max_y = -1
	for y in range(68):
		for x in range(68):
			var c = raw_img.get_pixel(x, y)
			if c.a > 0.15:
				if x < min_x: min_x = x
				if x > max_x: max_x = x
				if y < min_y: min_y = y
				if y > max_y: max_y = y

	var char_w = max_x - min_x + 1
	var char_h = max_y - min_y + 1
	print("Raw Gon BBox: [%d,%d -> %d,%d] size=%dx%d" % [min_x, min_y, max_x, max_y, char_w, char_h])

	# Cortar apenas o personagem
	var cropped = raw_img.get_region(Rect2i(min_x, min_y, char_w, char_h))

	# Queremos altura alvo de 21 ou 22 pixels (para bater 100% com o player.png)
	var target_h = 22
	var scale_factor = float(target_h) / float(char_h)
	var target_w = max(int(round(float(char_w) * scale_factor)), 10)

	var scaled = Image.create(target_w, target_h, false, Image.FORMAT_RGBA8)
	scaled.copy_from(cropped)
	scaled.resize(target_w, target_h, Image.INTERPOLATE_NEAREST)

	# Criar canvas canônico 48x48
	var canvas = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))

	# Posicionar pés em Y=42 e centralizado horizontalmente
	var dest_y = 42 - target_h + 1
	var dest_x = int((48 - target_w) / 2.0)

	# Blit dos pixels com quantização / binarização de alpha
	for y in range(target_h):
		for x in range(target_w):
			var p = scaled.get_pixel(x, y)
			if p.a >= 0.5:
				p.a = 1.0
				canvas.set_pixel(dest_x + x, dest_y + y, p)

	# Adicionar sombra elíptica nos pés (Y=41 e 42) idêntica ao player.png
	var shadow_col = Color(0.047, 0.055, 0.098, 0.5)
	for sx in range(dest_x - 1, dest_x + target_w + 1):
		if canvas.get_pixel(sx, 42).a < 0.1:
			canvas.set_pixel(sx, 42, shadow_col)
		if canvas.get_pixel(sx, 41).a < 0.1 and sx >= dest_x and sx < dest_x + target_w:
			canvas.set_pixel(sx, 41, shadow_col)

	var out_path = "res://scratch/processed_gon_48.png"
	canvas.save_png(ProjectSettings.globalize_path(out_path))
	print("Processed Gon saved to: ", out_path)

	# Validar dimensões e bbox do resultado
	var res_min_x = 48; var res_max_x = -1; var res_min_y = 48; var res_max_y = -1
	var col_count = {}
	for y in range(48):
		for x in range(48):
			var c = canvas.get_pixel(x, y)
			if c.a > 0.1:
				if x < res_min_x: res_min_x = x
				if x > res_max_x: res_max_x = x
				if y < res_min_y: res_min_y = y
				if y > res_max_y: res_max_y = y
				col_count[c.to_html(false)] = true

	print("Canvas 48x48 bbox: [%d,%d -> %d,%d] size=%dx%d feet_y=%d colors=%d" % [
		res_min_x, res_min_y, res_max_x, res_max_y,
		res_max_x - res_min_x + 1, res_max_y - res_min_y + 1,
		res_max_y, col_count.size()
	])

	quit(0)
