class_name ComicBalloon
extends Node2D

# ============================================================
# HUNTER ONLINE - COMIC SPEECH BALLOON (BALÃO DE QUADRINHOS / MANGÁ)
# ============================================================
#
# Balão de fala estilo quadrinhos clássicos e mangá:
# - Fundo branco puro com borda preta sólida (estilo traço de mangá).
# - Texto em preto de alto contraste com rabicho inferior apontando para a cabeça.
# - Animação rápida de pop-in elástico, sustentação e subida com fade-out.
# - Desacoplado da rotação/flip do sprite do personagem para legibilidade perfeita.
#
# ============================================================

var panel: PanelContainer
var label: Label
var tail_polygon: Polygon2D
var target_node: Node2D = null
var offset_pos: Vector2 = Vector2(0, -36)


static func mostrar(alvo: Node2D, texto: String, duracao: float = 2.2, offset_y: float = -36.0) -> Node2D:
	if alvo == null or not alvo.is_inside_tree() or texto.strip_edges().is_empty():
		return null

	var scn: GDScript = load("res://scripts/ui/ComicBalloon.gd") as GDScript
	if scn == null:
		return null
	var balloon: Node2D = scn.new() as Node2D
	balloon.target_node = alvo
	balloon.offset_pos = Vector2(0, offset_y)
	
	# Adicionar no pai do alvo (para não herdar scale/flip de sprite) ou no root
	var parent = alvo.get_parent()
	if parent != null:
		parent.add_child(balloon)
		balloon.global_position = alvo.global_position + balloon.offset_pos
	else:
		alvo.add_child(balloon)
		balloon.position = balloon.offset_pos

	balloon._configurar_visual(texto, duracao)
	return balloon


func _configurar_visual(texto: String, duracao: float) -> void:
	z_index = 25 # Garante que fica visível acima de inimigos e cenários

	# Container Central
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(50, 20)
	
	# Estilo Mangá: Fundo Branco com borda preta sólida
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.98)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.04, 0.04, 0.06, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.35)
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
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.06, 0.06, 0.08, 1.0))
	margin.add_child(label)

	# Centralizar o painel acima da origem
	call_deferred("_ajustar_posicao_e_rabicho", duracao)


func _ajustar_posicao_e_rabicho(duracao: float) -> void:
	if panel == null:
		return

	var p_size = panel.size
	panel.position = Vector2(-p_size.x / 2.0, -p_size.y)

	# Criar Rabicho de Quadrinhos apontando para baixo
	tail_polygon = Polygon2D.new()
	tail_polygon.color = Color(1.0, 1.0, 1.0, 1.0)
	var pts := PackedVector2Array([
		Vector2(-4, 0),
		Vector2(4, 0),
		Vector2(-1, 6)
	])
	tail_polygon.polygon = pts
	tail_polygon.position = Vector2(0, 0)
	add_child(tail_polygon)

	# Borda do rabicho
	var line := Line2D.new()
	line.width = 1.5
	line.default_color = Color(0.04, 0.04, 0.06, 1.0)
	line.points = PackedVector2Array([
		Vector2(-4, 0),
		Vector2(-1, 6),
		Vector2(4, 0)
	])
	add_child(line)

	# Animação estilo Mangá Pop-in
	scale = Vector2(0.2, 0.2)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.06)
	
	# Tempo de leitura antes de sumir
	tween.tween_interval(max(1.5, duracao))
	
	# Fade-out e subida suave
	tween.parallel().tween_property(self, "position:y", position.y - 12.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)


func _process(_delta: float) -> void:
	if target_node != null and is_instance_valid(target_node):
		# Seguir o alvo suavemente sem herdar rotação
		global_position = target_node.global_position + offset_pos
	elif target_node != null and not is_instance_valid(target_node):
		queue_free()
