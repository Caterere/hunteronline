class_name MissionGPSIndicator
extends Node2D

# ============================================================
# HUNTER ONLINE - GPS DE MISSÕES (bússola visual)
# Consome MissionObjectiveResolver — fonte única de verdade.
# ============================================================

const MissionObjectiveResolverScript = preload("res://scripts/missions/MissionObjectiveResolver.gd")

var player_ref: CharacterBody2D = null
var current_target_node: Node2D = null
var current_target_pos: Vector2 = Vector2.ZERO
var current_target_name: String = ""
var current_target_type: String = ""
var target_found: bool = false
var distance_to_target: float = 0.0

var pulse_time: float = 0.0
var smooth_angle: float = 0.0

var canvas_layer: CanvasLayer = null
var screen_edge_indicator: Control = null
var lbl_target_info: Label = null

const ORBIT_RADIUS: float = 30.0
const ARRIVAL_DISTANCE: float = 35.0


func _ready() -> void:
	z_index = 50
	_criar_overlay_tela()


func _criar_overlay_tela() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 15
	add_child(canvas_layer)

	screen_edge_indicator = Control.new()
	screen_edge_indicator.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_edge_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(screen_edge_indicator)

	var panel := PanelContainer.new()
	panel.name = "GPSBottomPanel"
	panel.position = Vector2(160 - 85, 160)
	panel.custom_minimum_size = Vector2(170, 15)
	panel.scale = Vector2(0.75, 0.75)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.10, 0.85)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 0.8, 0.2, 0.9)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	panel.add_theme_stylebox_override("panel", style)
	screen_edge_indicator.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	panel.add_child(margin)

	lbl_target_info = Label.new()
	lbl_target_info.text = "🧭 GPS: Localizando rota..."
	lbl_target_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_target_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_target_info.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	margin.add_child(lbl_target_info)


func _process(delta: float) -> void:
	pulse_time += delta
	_localizar_player()

	if player_ref == null or not is_instance_valid(player_ref):
		visible = false
		if screen_edge_indicator:
			screen_edge_indicator.visible = false
		return

	global_position = player_ref.global_position
	visible = true
	if screen_edge_indicator:
		screen_edge_indicator.visible = true

	_atualizar_alvo_ativo()
	queue_redraw()


func _localizar_player() -> void:
	if player_ref != null and is_instance_valid(player_ref):
		return
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is CharacterBody2D:
		player_ref = players[0] as CharacterBody2D


func _atualizar_alvo_ativo() -> void:
	target_found = false
	current_target_node = null
	current_target_name = ""
	current_target_type = ""
	current_target_pos = Vector2.ZERO

	var tree := get_tree()
	if tree == null:
		return

	var resolved: Dictionary = MissionObjectiveResolverScript.resolve(tree, player_ref)

	if resolved.get("secret", false):
		if lbl_target_info:
			lbl_target_info.text = str(resolved.get("gps_label", "🔍 Segredo — sem GPS"))
			lbl_target_info.add_theme_color_override("font_color", resolved.get("gps_color", Color(0.9, 0.7, 1.0, 1.0)))
		return

	if resolved.get("found", false):
		target_found = true
		current_target_node = resolved.get("node", null)
		current_target_pos = resolved.get("position", Vector2.ZERO)
		current_target_name = str(resolved.get("name", ""))
		current_target_type = str(resolved.get("type", ""))
		if player_ref != null:
			distance_to_target = player_ref.global_position.distance_to(current_target_pos)
			var dir_vec = (current_target_pos - player_ref.global_position).normalized()
			smooth_angle = lerp_angle(smooth_angle, dir_vec.angle(), 0.25)

	if lbl_target_info:
		lbl_target_info.text = str(resolved.get("gps_label", "🧭 GPS: Localizando rota..."))
		lbl_target_info.add_theme_color_override(
			"font_color",
			resolved.get("gps_color", Color(1.0, 0.85, 0.3, 1.0))
		)


func _draw() -> void:
	if not target_found or player_ref == null:
		return

	var bobbing = sin(pulse_time * 5.0) * 3.0
	var radius = ORBIT_RADIUS + bobbing
	var dir = Vector2.from_angle(smooth_angle)
	var arrow_center = dir * radius

	var cor_principal := Color(1.0, 0.85, 0.2, 0.95)
	var cor_borda := Color(0.1, 0.1, 0.1, 0.9)

	match current_target_type:
		"npc":
			cor_principal = Color(0.3, 0.9, 1.0, 0.95)
		"enemy":
			cor_principal = Color(1.0, 0.3, 0.3, 0.95)
		"loot":
			cor_principal = Color(0.4, 1.0, 0.4, 0.95)
		"portal":
			cor_principal = Color(1.0, 0.9, 0.2, 0.95)
		"zone":
			cor_principal = Color(0.85, 0.8, 0.4, 0.9)
		"clue":
			cor_principal = Color(0.2, 0.9, 1.0, 0.95)
		"stealth":
			cor_principal = Color(0.4, 1.0, 0.7, 0.95)

	if distance_to_target <= ARRIVAL_DISTANCE:
		var pulse_radius = 12.0 + sin(pulse_time * 8.0) * 4.0
		draw_arc(Vector2.ZERO, pulse_radius, 0, TAU, 24, Color(cor_principal.r, cor_principal.g, cor_principal.b, 0.6), 1.5, true)

	var angle = smooth_angle
	var p_tip = arrow_center + Vector2.from_angle(angle) * 7.0
	var p_left = arrow_center + Vector2.from_angle(angle + 2.5) * 5.0
	var p_right = arrow_center + Vector2.from_angle(angle - 2.5) * 5.0
	var pontos = PackedVector2Array([p_tip, p_left, p_right])
	draw_colored_polygon(pontos, cor_principal)
	draw_polyline(PackedVector2Array([p_tip, p_left, p_right, p_tip]), cor_borda, 1.0, true)
