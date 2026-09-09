extends SceneTree

# Reamostra rotações PixelLab (68px) para folhas Style Lock 48×48 (pés Y=42, h≈22).

const CELL := 48
const TARGET_H := 22
const TARGET_FEET_Y := 42
const DIRS := [
	"south", "south-east", "east", "north-east",
	"north", "north-west", "west", "south-west"
]

const CHARACTERS := [
	"npc_mordoma_canary",
	"npc_mordomo_gotoh",
	"npc_silva_zoldyck",
	"npc_melody",
	"npc_battera",
	"npc_tsezguerra",
	"enemy_sentinela_pedra",
]


func _init() -> void:
	var base := ProjectSettings.globalize_path("res://assets/sprites/characters/")
	var ok_all := true
	for char_id in CHARACTERS:
		var rot_dir := base.path_join(char_id + "_rotations")
		var sheet := Image.create(CELL * 8, CELL, false, Image.FORMAT_RGBA8)
		sheet.fill(Color(0, 0, 0, 0))
		var missing := 0
		for i in range(DIRS.size()):
			var src_path := rot_dir.path_join(DIRS[i] + ".png")
			var src := Image.load_from_file(src_path)
			if src == null:
				print("[-] missing ", src_path)
				missing += 1
				continue
			var frame := _fit_to_style_lock(src)
			sheet.blit_rect(frame, Rect2i(0, 0, CELL, CELL), Vector2i(i * CELL, 0))
		var out_path := base.path_join(char_id + "_8dir.png")
		var err := sheet.save_png(out_path)
		if err != OK or missing > 0:
			ok_all = false
			print("[-] FAIL ", char_id, " err=", err, " missing=", missing)
		else:
			print("[+] wrote ", out_path)
	quit(0 if ok_all else 1)


func _fit_to_style_lock(raw: Image) -> Image:
	var w := raw.get_width()
	var h := raw.get_height()
	var min_x := w
	var max_x := -1
	var min_y := h
	var max_y := -1
	for y in range(h):
		for x in range(w):
			if raw.get_pixel(x, y).a > 0.15:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)

	var char_w := max_x - min_x + 1
	var char_h := max_y - min_y + 1
	var cropped := raw.get_region(Rect2i(min_x, min_y, char_w, char_h))

	var scale_factor := float(TARGET_H) / float(char_h)
	var target_w := clampi(int(round(float(char_w) * scale_factor)), 8, 18)
	var target_h := TARGET_H
	var scaled := Image.create(target_w, target_h, false, Image.FORMAT_RGBA8)
	scaled.copy_from(cropped)
	scaled.resize(target_w, target_h, Image.INTERPOLATE_NEAREST)

	var canvas := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var dest_y := TARGET_FEET_Y - target_h + 1
	var dest_x := int((CELL - target_w) / 2.0)
	for y in range(target_h):
		for x in range(target_w):
			var p := scaled.get_pixel(x, y)
			if p.a >= 0.5:
				p.a = 1.0
				canvas.set_pixel(dest_x + x, dest_y + y, p)

	_quantize_opaque(canvas, 12)

	# Sombra elíptica nos pés (alpha 0.5 — tolerada pelo validator em Y>=38)
	var shadow_col := Color(0.047, 0.055, 0.098, 0.5)
	for sx in range(dest_x - 1, dest_x + target_w + 1):
		if sx < 0 or sx >= CELL:
			continue
		if canvas.get_pixel(sx, 42).a < 0.1:
			canvas.set_pixel(sx, 42, shadow_col)
		if sx >= dest_x and sx < dest_x + target_w and canvas.get_pixel(sx, 41).a < 0.1:
			canvas.set_pixel(sx, 41, shadow_col)
	return canvas


func _quantize_opaque(img: Image, max_colors: int) -> void:
	var counts: Dictionary = {}
	for y in range(CELL):
		for x in range(CELL):
			var p := img.get_pixel(x, y)
			if p.a < 0.95:
				continue
			var key := p.to_html(false)
			counts[key] = int(counts.get(key, 0)) + 1
	if counts.size() <= max_colors:
		return

	var palette: Array[Color] = []
	var weights: Array[int] = []
	for k in counts.keys():
		palette.append(Color.html("#" + str(k)))
		weights.append(int(counts[k]))

	while palette.size() > max_colors:
		var best_i := 0
		var best_j := 1
		var best_d := 999.0
		for i in range(palette.size()):
			for j in range(i + 1, palette.size()):
				var d := _color_dist(palette[i], palette[j])
				if d < best_d:
					best_d = d
					best_i = i
					best_j = j
		var wi := weights[best_i]
		var wj := weights[best_j]
		var total := maxi(1, wi + wj)
		var merged := Color(
			(palette[best_i].r * wi + palette[best_j].r * wj) / float(total),
			(palette[best_i].g * wi + palette[best_j].g * wj) / float(total),
			(palette[best_i].b * wi + palette[best_j].b * wj) / float(total),
			1.0
		)
		palette[best_i] = merged
		weights[best_i] = total
		palette.remove_at(best_j)
		weights.remove_at(best_j)

	for y in range(CELL):
		for x in range(CELL):
			var p := img.get_pixel(x, y)
			if p.a < 0.95:
				continue
			var best := palette[0]
			var best_d2 := 999.0
			for c in palette:
				var d2 := _color_dist(p, c)
				if d2 < best_d2:
					best_d2 = d2
					best = c
			best.a = 1.0
			img.set_pixel(x, y, best)


func _color_dist(a: Color, b: Color) -> float:
	var dr := a.r - b.r
	var dg := a.g - b.g
	var db := a.b - b.b
	return sqrt(dr * dr + dg * dg + db * db)
