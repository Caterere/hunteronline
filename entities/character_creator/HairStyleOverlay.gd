class_name HairStyleOverlay
extends Node2D

# ============================================================
# Silhuetas procedurais de cabelo + pontos de olho (pixel art).
# Usado no preview de criação e no Player em runtime.
# ============================================================

var hair_id: String = "hair_gon_01" # IDs = CharacterAssetDatabase.HAIR_STYLES
var hair_color: Color = Color(0.1, 0.1, 0.12, 1.0)
var eyes_color: Color = Color(0.15, 0.45, 0.85, 1.0)
var show_eyes: bool = true
var facing_left: bool = false


func configurar(p_hair_id: String, p_hair: Color, p_eyes: Color, p_show_eyes: bool = true) -> void:
	hair_id = p_hair_id
	hair_color = p_hair
	eyes_color = p_eyes
	show_eyes = p_show_eyes
	queue_redraw()


func _draw() -> void:
	var flip: float = -1.0 if facing_left else 1.0
	_desenhar_cabelo(flip)
	if show_eyes:
		_desenhar_olhos(flip)


func _desenhar_olhos(flip: float) -> void:
	# Posição aproximada dos olhos no sprite 48px (âncora no peito/pés do Player)
	var y_eye := -28.0
	var x_l := -3.5 * flip
	var x_r := 3.5 * flip
	var pupil := eyes_color
	var white := Color(0.95, 0.95, 0.98, 0.95)
	draw_circle(Vector2(x_l, y_eye), 1.6, white)
	draw_circle(Vector2(x_r, y_eye), 1.6, white)
	draw_circle(Vector2(x_l, y_eye), 1.05, pupil)
	draw_circle(Vector2(x_r, y_eye), 1.05, pupil)
	draw_circle(Vector2(x_l + 0.35 * flip, y_eye - 0.35), 0.35, Color(1, 1, 1, 0.85))
	draw_circle(Vector2(x_r + 0.35 * flip, y_eye - 0.35), 0.35, Color(1, 1, 1, 0.85))


func _desenhar_cabelo(flip: float) -> void:
	var base := hair_color
	var shade := base.darkened(0.28)
	var tip := base.lightened(0.18)
	var y0 := -36.0

	match hair_id:
		"hair_gon_01":
			# Espinhos altos estilo Gon
			var spikes: Array = [
				PackedVector2Array([Vector2(0, y0 - 14), Vector2(-3, y0 - 2), Vector2(3, y0 - 2)]),
				PackedVector2Array([Vector2(-6 * flip, y0 - 12), Vector2(-9 * flip, y0), Vector2(-3 * flip, y0 - 1)]),
				PackedVector2Array([Vector2(6 * flip, y0 - 11), Vector2(3 * flip, y0 - 1), Vector2(9 * flip, y0)]),
				PackedVector2Array([Vector2(-10 * flip, y0 - 7), Vector2(-12 * flip, y0 + 2), Vector2(-6 * flip, y0 + 1)]),
				PackedVector2Array([Vector2(10 * flip, y0 - 6), Vector2(6 * flip, y0 + 1), Vector2(12 * flip, y0 + 2)]),
			]
			for poly in spikes:
				draw_colored_polygon(poly, tip)
			draw_circle(Vector2(0, y0 + 2), 7.5, base)
			draw_circle(Vector2(-1 * flip, y0 + 3), 5.5, shade)

		"hair_killua_01":
			# Volume alto desfiado (Killua)
			draw_circle(Vector2(0, y0 + 1), 8.2, base)
			var k_spikes: Array = [
				PackedVector2Array([Vector2(-2, y0 - 13), Vector2(-5, y0 - 1), Vector2(1, y0 - 2)]),
				PackedVector2Array([Vector2(3, y0 - 14), Vector2(0, y0 - 2), Vector2(6, y0 - 1)]),
				PackedVector2Array([Vector2(-8 * flip, y0 - 9), Vector2(-10 * flip, y0 + 1), Vector2(-4 * flip, y0)]),
				PackedVector2Array([Vector2(8 * flip, y0 - 10), Vector2(4 * flip, y0), Vector2(11 * flip, y0 + 1)]),
				PackedVector2Array([Vector2(-5 * flip, y0 - 11), Vector2(-7 * flip, y0 - 1), Vector2(-2 * flip, y0 - 2)]),
			]
			for poly in k_spikes:
				draw_colored_polygon(poly, tip)
			draw_circle(Vector2(1 * flip, y0 + 3), 5.0, shade)

		"hair_kurapika_01":
			# Bob médio com franja
			draw_circle(Vector2(0, y0 + 3), 8.0, base)
			draw_rect(Rect2(-9, y0 - 2, 18, 10), base)
			draw_rect(Rect2(-8, y0 + 6, 16, 5), shade)
			# Franja
			draw_colored_polygon(PackedVector2Array([
				Vector2(-7 * flip, y0 + 1), Vector2(-2 * flip, y0 + 8), Vector2(0, y0 + 2)
			]), tip)
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, y0 + 2), Vector2(2 * flip, y0 + 8), Vector2(7 * flip, y0 + 1)
			]), tip)

		"hair_leorio_01":
			# Curto social
			draw_circle(Vector2(0, y0 + 3), 7.0, base)
			draw_rect(Rect2(-8, y0 + 1, 16, 7), base)
			draw_colored_polygon(PackedVector2Array([
				Vector2(-8 * flip, y0 + 2), Vector2(-4 * flip, y0 - 3), Vector2(0, y0 + 2)
			]), tip)
			draw_circle(Vector2(0, y0 + 5), 4.5, shade)

		"hair_ponytail_01":
			draw_circle(Vector2(0, y0 + 2), 7.2, base)
			draw_colored_polygon(PackedVector2Array([
				Vector2(-2, y0 - 2), Vector2(2, y0 - 2), Vector2(1, y0 + 18), Vector2(-1, y0 + 18)
			]), base)
			draw_circle(Vector2(0, y0 + 18), 2.2, tip)
			draw_rect(Rect2(-7, y0, 14, 5), shade)

		"hair_afro_01":
			draw_circle(Vector2(0, y0), 10.5, base)
			draw_circle(Vector2(-4 * flip, y0 - 2), 5.0, tip)
			draw_circle(Vector2(4 * flip, y0 + 1), 4.5, shade)

		"hair_bald_01":
			# Sem cabelo — só brilho de crânio sutil
			draw_circle(Vector2(-1 * flip, y0 + 4), 2.0, Color(1, 1, 1, 0.12))

		_:
			draw_circle(Vector2(0, y0 + 2), 7.5, base)
