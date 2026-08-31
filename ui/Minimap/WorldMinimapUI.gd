class_name WorldMinimapUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - RADAR MINIMAP & WORLD MAP (ESTILO MINECRAFT)
# ============================================================
#
# Sistema de Navegação Cartográfica para o Mundo / Lobby:
# 1. Radar Minimap Compacto no canto inferior esquerdo (sempre visível).
# 2. Mapa Completo Expandido ao pressionar [TAB] ou [M].
# 3. Zoom reduzido para visualização de todo o mapa e distritos de uma só vez.
# 4. Exibe a posição do jogador (📍 Você), NPCs, Portais e Distritos.
# 5. Sistema de Bússola e Coordenadas (X, Y).
#
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var player_node: CharacterBody2D = null

# Componentes do Minimapa Compacto (Canto Inferior Esquerdo)
var minimap_panel: PanelContainer
var minimap_canvas: Control
var lbl_coords: Label

# Componentes do Mapa Expandido ([TAB] / [M])
var full_map_layer: Control
var full_map_canvas: Control
var map_open: bool = false
var lbl_guia_distancias: Label

# Escala do Radar (Reduzido em 25%)
const MINIMAP_SIZE := Vector2(48, 35)
const MINIMAP_SCALE := 0.035 # Escala do radar compacto próximo
const FULL_MAP_SIZE := Vector2(180, 134)
const FULL_MAP_SCALE := 0.048 # Zoom reduzido para enxergar o mapa inteiro


func _ready() -> void:
	layer = 35
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_minimap_compacto()
	_construir_full_map_modal()


func setup(player: CharacterBody2D) -> void:
	player_node = player


func _unhandled_input(event: InputEvent) -> void:
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null and not input_ctx.is_global_hotkey_allowed():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M or event.is_action_pressed("open_map_menu"):
			toggle_full_map()
			get_viewport().set_input_as_handled()


func toggle_full_map() -> void:
	map_open = not map_open
	if full_map_layer != null:
		full_map_layer.visible = map_open
	get_tree().paused = map_open
	if map_open and full_map_canvas != null:
		full_map_canvas.queue_redraw()


# ============================================================
# 1. MINIMAPA COMPACTO (CANTO INFERIOR ESQUERDO)
# ============================================================

func _construir_minimap_compacto() -> void:
	minimap_panel = PanelContainer.new()
	minimap_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	minimap_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	minimap_panel.offset_left = 6.0
	minimap_panel.offset_bottom = -6.0
	minimap_panel.offset_top = -48.0
	minimap_panel.offset_right = 58.0
	minimap_panel.custom_minimum_size = Vector2(52, 42)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.10, 0.88)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.7, 1.0, 0.85)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	minimap_panel.add_theme_stylebox_override("panel", style)
	add_child(minimap_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	minimap_panel.add_child(vbox)

	var hbox_hdr := HBoxContainer.new()
	vbox.add_child(hbox_hdr)

	var lbl_tit := Label.new()
	lbl_tit.text = "🧭 [TAB]"
	lbl_tit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_tit.add_theme_font_size_override("font_size", 6)
	lbl_tit.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	hbox_hdr.add_child(lbl_tit)

	lbl_coords = Label.new()
	lbl_coords.text = "0, 0"
	lbl_coords.add_theme_font_size_override("font_size", 6)
	lbl_coords.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	hbox_hdr.add_child(lbl_coords)

	minimap_canvas = Control.new()
	minimap_canvas.custom_minimum_size = MINIMAP_SIZE
	minimap_canvas.draw.connect(_desenhar_minimap_compacto)
	vbox.add_child(minimap_canvas)


func _desenhar_minimap_compacto() -> void:
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player_node == null:
		return

	var center := MINIMAP_SIZE / 2.0
	var p_pos := player_node.global_position

	# Fundo do Radar com círculos concêntricos
	minimap_canvas.draw_rect(Rect2(Vector2.ZERO, MINIMAP_SIZE), Color(0.02, 0.04, 0.08, 0.95), true)
	minimap_canvas.draw_circle(center, 22.0, Color(0.1, 0.2, 0.35, 0.5), false, 1.0)
	minimap_canvas.draw_circle(center, 12.0, Color(0.1, 0.2, 0.35, 0.4), false, 1.0)
	minimap_canvas.draw_line(Vector2(center.x, 2), Vector2(center.x, MINIMAP_SIZE.y - 2), Color(0.15, 0.3, 0.5, 0.4), 1.0)
	minimap_canvas.draw_line(Vector2(2, center.y), Vector2(MINIMAP_SIZE.x - 2, center.y), Color(0.15, 0.3, 0.5, 0.4), 1.0)

	# Desenhar Pontos de Interesse no radar compacto
	var pontos = _obter_pontos_interesse()
	for pt in pontos:
		var delta_pos: Vector2 = (pt["pos"] - p_pos) * MINIMAP_SCALE
		var pt_draw := center + delta_pos
		if pt_draw.x >= 3 and pt_draw.x <= MINIMAP_SIZE.x - 3 and pt_draw.y >= 3 and pt_draw.y <= MINIMAP_SIZE.y - 3:
			minimap_canvas.draw_circle(pt_draw, 2.0, pt["cor"])

	# Jogador no Centro (Ponto Verde)
	minimap_canvas.draw_circle(center, 2.5, Color(0.2, 1.0, 0.4, 1.0))
	minimap_canvas.draw_circle(center, 4.0, Color(0.2, 1.0, 0.4, 0.4), false, 1.0)


# ============================================================
# 2. MAPA COMPLETO EXPANDIDO ([TAB] / ZOOM REDUZIDO)
# ============================================================

func _construir_full_map_modal() -> void:
	full_map_layer = Control.new()
	full_map_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	full_map_layer.visible = false
	add_child(full_map_layer)

	var root_control := Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	full_map_layer.add_child(root_control)

	# Fundo Escurecido
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(bg)

	var center_container := CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(center_container)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(304, 168)
	panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	center_container.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	# Header
	var hbox_hdr := HBoxContainer.new()
	vbox.add_child(hbox_hdr)

	var lbl_map_tit := Label.new()
	lbl_map_tit.text = "🗺️ MAPA MUNDIAL (VISÃO GERAL COMPLETA)"
	lbl_map_tit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_map_tit.add_theme_font_size_override("font_size", 5)
	lbl_map_tit.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox_hdr.add_child(lbl_map_tit)

	var btn_fechar := Button.new()
	btn_fechar.text = "✖ Fechar [M]"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_fechar, HunterUIStyle.COLOR_BORDER_GREEN)
	btn_fechar.pressed.connect(toggle_full_map)
	hbox_hdr.add_child(btn_fechar)

	# Conteúdo Principal: Canvas do Mapa + Lista de Pontos
	var hbox_body := HBoxContainer.new()
	hbox_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_body.add_theme_constant_override("separation", 6)
	vbox.add_child(hbox_body)

	full_map_canvas = Control.new()
	full_map_canvas.custom_minimum_size = Vector2(185, 136)
	full_map_canvas.draw.connect(_desenhar_full_map)
	hbox_body.add_child(full_map_canvas)

	# Painel Lateral de Legenda & Distâncias
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_body.add_child(scroll)

	lbl_guia_distancias = Label.new()
	lbl_guia_distancias.text = ""
	lbl_guia_distancias.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_guia_distancias.add_theme_font_size_override("font_size", 3)
	scroll.add_child(lbl_guia_distancias)


func _desenhar_full_map() -> void:
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player_node == null:
		return

	var canvas_size := Vector2(185, 136)
	var map_center := canvas_size / 2.0
	var p_pos := player_node.global_position

	# Fundo da Grade Cartográfica
	full_map_canvas.draw_rect(Rect2(Vector2.ZERO, canvas_size), Color(0.03, 0.05, 0.10, 0.95), true)

	# Grid Cartográfico
	for x in range(0, int(canvas_size.x), 15):
		full_map_canvas.draw_line(Vector2(x, 0), Vector2(x, canvas_size.y), Color(0.1, 0.2, 0.35, 0.25), 1.0)
	for y in range(0, int(canvas_size.y), 15):
		full_map_canvas.draw_line(Vector2(0, y), Vector2(canvas_size.x, y), Color(0.1, 0.2, 0.35, 0.25), 1.0)

	# Eixos Cardeais (N, S, L, O)
	full_map_canvas.draw_line(Vector2(map_center.x, 2), Vector2(map_center.x, canvas_size.y - 2), Color(0.2, 0.4, 0.6, 0.4), 1.0)
	full_map_canvas.draw_line(Vector2(2, map_center.y), Vector2(canvas_size.x - 2, map_center.y), Color(0.2, 0.4, 0.6, 0.4), 1.0)

	# Nomes dos 4 Distritos Cardeais no fundo
	# Norte: Mestres de Nen | Sul: Bounties | Oeste: Comércio & Casa | Leste: Torre Celestial
	var pontos = _obter_pontos_interesse()
	var texto_legenda: String = "📍 PONTOS DE INTERESSE:\n\n"

	for pt in pontos:
		var pt_pos: Vector2 = pt["pos"]
		var pt_draw: Vector2 = map_center + (pt_pos * FULL_MAP_SCALE)

		var dist: float = p_pos.distance_to(pt_pos)
		var direcao_str: String = _obter_direcao_cardeal(p_pos, pt_pos)
		texto_legenda += "%s %s\n  ➜ %.0fm (%s)\n\n" % [pt["icone"], pt["nome"], dist, direcao_str]

		# Desenhar Ponto no Mapa se estiver dentro dos limites visuais
		if pt_draw.x >= 4 and pt_draw.x <= canvas_size.x - 4 and pt_draw.y >= 4 and pt_draw.y <= canvas_size.y - 4:
			full_map_canvas.draw_circle(pt_draw, 3.0, pt["cor"])
			full_map_canvas.draw_circle(pt_draw, 4.0, Color.BLACK, false, 1.0)

	if lbl_guia_distancias != null:
		lbl_guia_distancias.text = texto_legenda

	# Desenhar Jogador Atual no Mapa
	var player_draw: Vector2 = map_center + (p_pos * FULL_MAP_SCALE)
	if player_draw.x >= 4 and player_draw.x <= canvas_size.x - 4 and player_draw.y >= 4 and player_draw.y <= canvas_size.y - 4:
		full_map_canvas.draw_circle(player_draw, 3.5, Color(0.2, 1.0, 0.4, 1.0))
		full_map_canvas.draw_circle(player_draw, 6.0, Color(1.0, 1.0, 1.0, 0.8), false, 1.0)



func _process(_delta: float) -> void:
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as CharacterBody2D

	if player_node != null:
		if lbl_coords != null:
			lbl_coords.text = "X: %d, Y: %d" % [int(player_node.global_position.x), int(player_node.global_position.y)]
		if minimap_canvas != null and minimap_canvas.is_visible_in_tree():
			minimap_canvas.queue_redraw()
		if map_open and full_map_canvas != null and full_map_canvas.is_visible_in_tree():
			full_map_canvas.queue_redraw()


# ============================================================
# CATÁLOGO DE COORDENADAS DOS PONTOS DE INTERESSE
# ============================================================

func _obter_pontos_interesse() -> Array[Dictionary]:
	return [
		{"nome": "Estátua de Netero", "pos": Vector2(0, -280), "icone": "🏛️", "cor": Color(1.0, 0.9, 0.4)},
		{"nome": "Quadro de Procurados", "pos": Vector2(0, 300), "icone": "📜", "cor": Color(1.0, 0.7, 0.3)},
		{"nome": "Recepcionista Elena", "pos": Vector2(320, 0), "icone": "👩‍💼", "cor": Color(1.0, 0.6, 0.8)},
		{"nome": "Instrutor de Combate", "pos": Vector2(-320, 0), "icone": "⚔️", "cor": Color(0.4, 0.8, 1.0)},
		
		{"nome": "Mestre Wing (Nen)", "pos": Vector2(400, -640), "icone": "🥋", "cor": Color(0.3, 1.0, 0.6)},
		{"nome": "Discípulo Zushi", "pos": Vector2(640, -640), "icone": "🥋", "cor": Color(1.0, 0.95, 0.7)},
		{"nome": "Biscuit Krueger (Hatsu)", "pos": Vector2(880, -640), "icone": "🎀", "cor": Color(1.0, 0.4, 0.7)},
		{"nome": "Mestre Alquimista (Troca)", "pos": Vector2(1120, -640), "icone": "🔮", "cor": Color(0.9, 0.3, 1.0)},

		{"nome": "Ferreiro de Forja", "pos": Vector2(-640, -240), "icone": "🔨", "cor": Color(1.0, 0.5, 0.2)},
		{"nome": "Mercador Hunter", "pos": Vector2(-640, 240), "icone": "💰", "cor": Color(1.0, 0.85, 0.2)},
		{"nome": "Casa Pessoal do Caçador", "pos": Vector2(-1040, 0), "icone": "🏠", "cor": Color(0.4, 1.0, 0.5)},

		{"nome": "Portal Hunter (9 Sagas)", "pos": Vector2(560, 440), "icone": "🌌", "cor": Color(0.5, 0.5, 1.0)},
		{"nome": "Examinador Chrono (PQs)", "pos": Vector2(840, 440), "icone": "⏳", "cor": Color(0.4, 0.9, 1.0)},
		{"nome": "Curador de Bestas de Nen", "pos": Vector2(1120, 440), "icone": "🐉", "cor": Color(0.85, 0.4, 1.0)},
		{"nome": "Torre Celestial (Arena)", "pos": Vector2(1400, 0), "icone": "🏯", "cor": Color(1.0, 0.8, 0.2)}
	]


func _obter_direcao_cardeal(de: Vector2, para: Vector2) -> String:
	var delta: Vector2 = para - de
	var angulo: float = rad_to_deg(delta.angle())
	if angulo >= -22.5 and angulo < 22.5: return "Leste ➜"
	elif angulo >= 22.5 and angulo < 67.5: return "Sudeste ↘"
	elif angulo >= 67.5 and angulo < 112.5: return "Sul ⬇"
	elif angulo >= 112.5 and angulo < 157.5: return "Sudoeste ↙"
	elif angulo >= -67.5 and angulo < -22.5: return "Nordeste ↗"
	elif angulo >= -112.5 and angulo < -67.5: return "Norte ⬆"
	elif angulo >= -157.5 and angulo < -112.5: return "Noroeste ↖"
	else: return "Oeste ⬅"
