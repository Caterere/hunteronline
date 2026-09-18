class_name ComicBalloon
extends Node2D

# ============================================================
# HUNTER ONLINE - COMIC SPEECH BALLOON (BALÃO TEMÁTICO HUNTER)
# ============================================================
#
# Balão de fala no visual madeira/pergaminho + ouro da UI Hunter:
# - Fundo pergaminho, borda bronze/madeira (HunterUIStyle).
# - Texto em tinta escura de alto contraste com rabicho inferior.
# - Animação rápida de pop-in elástico, sustentação e subida com fade-out.
# - Desacoplado da rotação/flip do sprite do personagem.
#
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var panel: PanelContainer
var label: Label
var tail_polygon: Polygon2D
var target_node: Node2D = null
var offset_pos: Vector2 = Vector2(0, -36)
var _bg_color: Color = HunterUIStyle.COLOR_PANEL_PETROL
var _border_color: Color = HunterUIStyle.COLOR_BORDER_GOLD


static func mostrar(
	alvo: Node2D,
	texto: String,
	duracao: float = 2.2,
	offset_y: float = -36.0,
	bg_color: Color = Color(0.74, 0.64, 0.44, 0.97),
	border_color: Color = Color(0.48, 0.30, 0.12, 1.0)
) -> Node2D:
	if alvo == null or not alvo.is_inside_tree() or texto.strip_edges().is_empty():
		return null

	var scn: GDScript = load("res://scripts/ui/ComicBalloon.gd") as GDScript
	if scn == null:
		return null
	var balloon: Node2D = scn.new() as Node2D
	balloon.target_node = alvo
	balloon.offset_pos = Vector2(0, offset_y)

	var parent = alvo.get_parent()
	if parent != null:
		parent.add_child(balloon)
		balloon.global_position = alvo.global_position + balloon.offset_pos
	else:
		alvo.add_child(balloon)
		balloon.position = balloon.offset_pos

	balloon._configurar_visual(texto, duracao, bg_color, border_color)
	return balloon


func _configurar_visual(texto: String, duracao: float, bg_color: Color, border_color: Color) -> void:
	z_index = 25
	_bg_color = bg_color
	_border_color = border_color

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(50, 20)

	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0.05, 0.02, 0.0, 0.35)
	style.shadow_size = 2
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	label = Label.new()
	label.text = texto
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var calculated_width: float = clamp(float(texto.length()) * 6.0 + 16.0, 50.0, 180.0)
	label.custom_minimum_size = Vector2(calculated_width, 0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var font_col = Color(0.95, 0.95, 0.95, 1.0) if bg_color.get_luminance() < 0.5 else HunterUIStyle.COLOR_TEXT_PRIMARY
	label.add_theme_color_override("font_color", font_col)
	margin.add_child(label)

	call_deferred("_ajustar_posicao_e_rabicho", duracao)


func _ajustar_posicao_e_rabicho(duracao: float) -> void:
	if panel == null:
		return

	var p_size = panel.size
	panel.position = Vector2(-p_size.x / 2.0, -p_size.y)

	tail_polygon = Polygon2D.new()
	tail_polygon.color = _bg_color
	var pts := PackedVector2Array([
		Vector2(-4, 0),
		Vector2(4, 0),
		Vector2(-1, 6)
	])
	tail_polygon.polygon = pts
	tail_polygon.position = Vector2(0, 0)
	add_child(tail_polygon)

	var line := Line2D.new()
	line.width = 1.5
	line.default_color = _border_color
	line.points = PackedVector2Array([
		Vector2(-4, 0),
		Vector2(-1, 6),
		Vector2(4, 0)
	])
	add_child(line)

	scale = Vector2(0.2, 0.2)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.06)
	tween.tween_interval(max(1.5, duracao))
	tween.parallel().tween_property(self, "position:y", position.y - 12.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)


func _process(_delta: float) -> void:
	if target_node != null and is_instance_valid(target_node):
		global_position = target_node.global_position + offset_pos
	elif target_node != null and not is_instance_valid(target_node):
		queue_free()
