class_name NenSkillTreeUI
extends Control

# ==============================================================================
# HUNTER ONLINE — NEN SKILL TREE CONSTELLATION MAP (REDESIGN PROFUNDO)
# ==============================================================================
# Interface estilo ARPG autêntico (Path of Exile / FFX Sphere Grid / Grim Dawn):
# - Mapa estelar contendo mais de 400 nós interconectados em 10 regiões.
# - Câmera livre: Arrastar com mouse (Pan), Zoom contínuo (0.25x a 2.0x).
# - Culling de Viewport: 60+ FPS estáveis renderizando apenas nós visíveis.
# - Modos de exibição: Embutido na aba do menu ou Tela Cheia Imersiva.
# - Busca rápida por texto / tags (realce de caminhos de build).
# - Inspetor lateral com alocação e Tooltip flutuante instantâneo.
# - Reset da árvore com confirmação e reembolso integral de pontos.
# ==============================================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var skill_tree: NenSkillTree = null
var database: SkillTreeDatabase = null

# Câmera e Navegação
var pan_offset: Vector2 = Vector2.ZERO
var target_pan: Vector2 = Vector2.ZERO
var zoom_level: float = 0.85
var target_zoom: float = 0.85
const MIN_ZOOM: float = 0.25
const MAX_ZOOM: float = 2.20
var is_dragging: bool = false
var drag_start_mouse: Vector2 = Vector2.ZERO
var drag_start_pan: Vector2 = Vector2.ZERO
var has_dragged: bool = false

# Seleção e Hover
var hovered_node_id: StringName = &""
var selected_node_id: StringName = &"nexus_center"
var search_filter: String = ""
var selected_region_filter: StringName = &""
var is_fullscreen: bool = false

# Componentes de UI
var map_viewport: Control
var top_bar: PanelContainer
var bottom_bar: PanelContainer
var inspector_panel: PanelContainer
var tooltip_panel: PanelContainer
var confirmation_dialog: ConfirmationDialog
var search_edit: LineEdit
var lbl_points: Label
var btn_fullscreen: Button
var btn_invest: Button

# Inspetor
var lbl_insp_name: Label
var lbl_insp_type: Label
var lbl_insp_rank: Label
var lbl_insp_desc: Label
var lbl_insp_effects: Label
var lbl_insp_prereqs: Label
var lbl_insp_tags: Label

# Tooltip Flutuante
var lbl_tip_title: Label
var lbl_tip_type: Label
var lbl_tip_cost: Label
var lbl_tip_desc: Label
var lbl_tip_effects: Label


# ------------------------------------------------------------------------------
# READY & INICIALIZAÇÃO
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true

	database = SkillTreeDatabase.get_instance()
	_localizar_skill_tree()
	_construir_ui()

	# Centralizar inicialmente no Nexus (0,0)
	call_deferred("_centralizar_no_nexus")


func _localizar_skill_tree() -> void:
	if PlayerData != null and "skill_tree" in PlayerData and PlayerData.skill_tree != null:
		skill_tree = PlayerData.skill_tree as NenSkillTree

	if skill_tree == null:
		var trees = get_tree().get_nodes_in_group("nen_skill_tree")
		if not trees.is_empty():
			skill_tree = trees[0] as NenSkillTree

	if skill_tree == null and PlayerData != null and PlayerData.has_method("obter_skill_tree"):
		skill_tree = PlayerData.obter_skill_tree() as NenSkillTree

	if skill_tree != null:
		if not skill_tree.skill_investida.is_connected(_on_skill_investida):
			skill_tree.skill_investida.connect(_on_skill_investida)
		if not skill_tree.pontos_alterados.is_connected(_on_pontos_alterados):
			skill_tree.pontos_alterados.connect(_on_pontos_alterados)


func _process(delta: float) -> void:
	# Interpolação suave de Pan e Zoom
	var needs_redraw := false
	if pan_offset.distance_to(target_pan) > 0.5:
		pan_offset = pan_offset.lerp(target_pan, clamp(delta * 14.0, 0.0, 1.0))
		needs_redraw = true
	else:
		pan_offset = target_pan

	if abs(zoom_level - target_zoom) > 0.005:
		zoom_level = lerp(zoom_level, target_zoom, clamp(delta * 14.0, 0.0, 1.0))
		needs_redraw = true
	else:
		zoom_level = target_zoom

	if needs_redraw and map_viewport != null:
		map_viewport.queue_redraw()


# ------------------------------------------------------------------------------
# CONSTRUÇÃO DA INTERFACE
# ------------------------------------------------------------------------------
func _construir_ui() -> void:
	for child in get_children():
		child.queue_free()

	# 1. Viewport do Mapa Estelar (Canvas Interativo de Fundo)
	map_viewport = Control.new()
	map_viewport.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_viewport.mouse_filter = Control.MOUSE_FILTER_PASS
	map_viewport.draw.connect(_on_map_draw)
	map_viewport.gui_input.connect(_on_map_gui_input)
	add_child(map_viewport)

	# 2. Top Header Bar (Controles de Navegação, Filtros, Busca, Zoom)
	_construir_top_bar()

	# 3. Bottom Bar (Pontos de Nen, Reset, Centros)
	_construir_bottom_bar()

	# 4. Inspetor Lateral Direito (Detalhes do Nó Selecionado)
	_construir_inspector()

	# 5. Tooltip Flutuante
	_construir_floating_tooltip()

	# 6. Modal de Confirmação de Reset
	confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.title = "⚠️ RESETAR SKILL TREE"
	confirmation_dialog.dialog_text = "Deseja resetar todos os pontos investidos na Skill Tree?\n\nTodos os pontos serão devolvidos integralmente ao seu Caçador.\nSeu Nível, XP, Atributos Base, Técnicas e Hatsu permanecerão intactos."
	confirmation_dialog.confirmed.connect(_confirmar_reset_arvore)
	add_child(confirmation_dialog)


func _construir_top_bar() -> void:
	top_bar = PanelContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 44.0
	top_bar.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 2))
	add_child(top_bar)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	top_bar.add_child(hbox)

	var lbl_title := Label.new()
	lbl_title.text = "🌌 CONSTELAÇÃO DO NEN"
	lbl_title.add_theme_font_size_override("font_size", 11)
	lbl_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox.add_child(lbl_title)

	# Busca de Nós
	search_edit = LineEdit.new()
	search_edit.placeholder_text = "🔍 Buscar nó por nome, stat ou tag..."
	search_edit.custom_minimum_size = Vector2(210, 24)
	search_edit.add_theme_font_size_override("font_size", 9)
	search_edit.text_changed.connect(_on_search_changed)
	hbox.add_child(search_edit)

	# Menu de Regiões
	var opt_regions := OptionButton.new()
	opt_regions.add_item("Todas as Regiões", 0)
	var idx := 1
	for reg_id in database.REGIONS.keys():
		opt_regions.add_item(database.REGIONS[reg_id]["name"], idx)
		opt_regions.set_item_metadata(idx, reg_id)
		idx += 1
	opt_regions.item_selected.connect(_on_region_selected)
	opt_regions.add_theme_font_size_override("font_size", 8)
	hbox.add_child(opt_regions)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Controles de Zoom
	var btn_zoom_out := Button.new()
	btn_zoom_out.text = " ➖ "
	btn_zoom_out.pressed.connect(func(): _ajustar_zoom(1.0 / 1.25))
	hbox.add_child(btn_zoom_out)

	var btn_zoom_in := Button.new()
	btn_zoom_in.text = " ➕ "
	btn_zoom_in.pressed.connect(func(): _ajustar_zoom(1.25))
	hbox.add_child(btn_zoom_in)

	var btn_center_nexus := Button.new()
	btn_center_nexus.text = " 🎯 Nexus "
	btn_center_nexus.add_theme_font_size_override("font_size", 8)
	btn_center_nexus.pressed.connect(_centralizar_no_nexus)
	hbox.add_child(btn_center_nexus)

	var btn_center_last := Button.new()
	btn_center_last.text = " ⭐ Progresso "
	btn_center_last.add_theme_font_size_override("font_size", 8)
	btn_center_last.pressed.connect(_centralizar_no_progresso)
	hbox.add_child(btn_center_last)

	btn_fullscreen = Button.new()
	btn_fullscreen.text = " ⛶ Tela Cheia "
	btn_fullscreen.add_theme_font_size_override("font_size", 8)
	btn_fullscreen.pressed.connect(_toggle_fullscreen)
	hbox.add_child(btn_fullscreen)


func _construir_bottom_bar() -> void:
	bottom_bar = PanelContainer.new()
	bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bar.offset_top = -36.0
	bottom_bar.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_BLUE, 2))
	add_child(bottom_bar)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	bottom_bar.add_child(hbox)

	lbl_points = Label.new()
	lbl_points.text = "⭐ PONTOS DE NEN DISPONÍVEIS: %d" % (PlayerData.nen_skill_points if PlayerData != null else 0)
	lbl_points.add_theme_font_size_override("font_size", 10)
	lbl_points.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox.add_child(lbl_points)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var btn_reset := Button.new()
	btn_reset.text = " 🔄 Resetar Árvore "
	btn_reset.add_theme_font_size_override("font_size", 9)
	btn_reset.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	btn_reset.pressed.connect(func(): confirmation_dialog.popup_centered())
	hbox.add_child(btn_reset)


func _construir_inspector() -> void:
	inspector_panel = PanelContainer.new()
	inspector_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	inspector_panel.offset_left = -260.0
	inspector_panel.offset_top = 48.0
	inspector_panel.offset_bottom = -40.0
	inspector_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 3))
	add_child(inspector_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	inspector_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	lbl_insp_name = Label.new()
	lbl_insp_name.text = "Selecione um Nó"
	lbl_insp_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_name.add_theme_font_size_override("font_size", 11)
	lbl_insp_name.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vbox.add_child(lbl_insp_name)

	var hbox_type := HBoxContainer.new()
	vbox.add_child(hbox_type)

	lbl_insp_type = Label.new()
	lbl_insp_type.text = "TIPO: -"
	lbl_insp_type.add_theme_font_size_override("font_size", 8)
	hbox_type.add_child(lbl_insp_type)

	var sp_typ := Control.new()
	sp_typ.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_type.add_child(sp_typ)

	lbl_insp_rank = Label.new()
	lbl_insp_rank.text = "Rank: 0/1"
	lbl_insp_rank.add_theme_font_size_override("font_size", 8)
	hbox_type.add_child(lbl_insp_rank)

	var sep1 := HSeparator.new()
	vbox.add_child(sep1)

	lbl_insp_desc = Label.new()
	lbl_insp_desc.text = "Clique em qualquer nó da constelação para visualizar sua descrição e efeitos de progressão."
	lbl_insp_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_desc.add_theme_font_size_override("font_size", 8)
	lbl_insp_desc.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	vbox.add_child(lbl_insp_desc)

	lbl_insp_effects = Label.new()
	lbl_insp_effects.text = ""
	lbl_insp_effects.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_effects.add_theme_font_size_override("font_size", 9)
	lbl_insp_effects.add_theme_color_override("font_color", Color(0.3, 0.95, 0.5))
	vbox.add_child(lbl_insp_effects)

	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	lbl_insp_prereqs = Label.new()
	lbl_insp_prereqs.text = "Pré-requisitos: Nenhum"
	lbl_insp_prereqs.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_prereqs.add_theme_font_size_override("font_size", 8)
	vbox.add_child(lbl_insp_prereqs)

	lbl_insp_tags = Label.new()
	lbl_insp_tags.text = "Tags: -"
	lbl_insp_tags.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_tags.add_theme_font_size_override("font_size", 8)
	lbl_insp_tags.add_theme_color_override("font_color", Color(0.7, 0.7, 0.85))
	vbox.add_child(lbl_insp_tags)

	var sp_end := Control.new()
	sp_end.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(sp_end)

	btn_invest = Button.new()
	btn_invest.text = "⚡ INVESTIR PONTO (1 SP)"
	btn_invest.custom_minimum_size = Vector2(0, 32)
	btn_invest.add_theme_font_size_override("font_size", 10)
	btn_invest.pressed.connect(_on_invest_pressed)
	vbox.add_child(btn_invest)


func _construir_floating_tooltip() -> void:
	tooltip_panel = PanelContainer.new()
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.visible = false
	tooltip_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 2))
	add_child(tooltip_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	tooltip_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	lbl_tip_title = Label.new()
	lbl_tip_title.add_theme_font_size_override("font_size", 9)
	lbl_tip_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vbox.add_child(lbl_tip_title)

	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)

	lbl_tip_type = Label.new()
	lbl_tip_type.add_theme_font_size_override("font_size", 7)
	hbox.add_child(lbl_tip_type)

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(sp)

	lbl_tip_cost = Label.new()
	lbl_tip_cost.add_theme_font_size_override("font_size", 7)
	hbox.add_child(lbl_tip_cost)

	lbl_tip_effects = Label.new()
	lbl_tip_effects.add_theme_font_size_override("font_size", 8)
	lbl_tip_effects.add_theme_color_override("font_color", Color(0.35, 1.0, 0.6))
	vbox.add_child(lbl_tip_effects)


# ------------------------------------------------------------------------------
# RENDERIZAÇÃO DO GRAFO (DESENHO DE ALTA PERFORMANCE)
# ------------------------------------------------------------------------------
func _on_map_draw() -> void:
	if database == null or database.nodes.is_empty():
		return

	var view_size := size
	var center_screen := view_size * 0.5
	var vp_rect := Rect2(
		(-pan_offset - center_screen) / zoom_level,
		view_size / zoom_level
	)

	# Fundo estelar sutil / grade polar
	_draw_background_grid(center_screen)

	# 1. Desenhar Linhas Conectoras
	var drawn_lines: Dictionary = {}
	for nid in database.nodes.keys():
		var node: SkillTreeNodeData = database.nodes[nid]
		var from_world := node.position
		var from_screen := (from_world * zoom_level) + center_screen + pan_offset

		for prereq_id in node.prerequisites:
			var pair_key = "%s->%s" % [String(prereq_id), String(nid)]
			if drawn_lines.has(pair_key):
				continue
			drawn_lines[pair_key] = true

			if not database.nodes.has(prereq_id):
				continue

			var prereq_node: SkillTreeNodeData = database.nodes[prereq_id]
			var to_world := prereq_node.position
			var to_screen := (to_world * zoom_level) + center_screen + pan_offset

			# Viewport Culling da Linha: desenha se pelo menos um ponto estiver no viewport expandido
			var line_rect := Rect2(from_world, Vector2.ZERO).expand(to_world).grow(100.0)
			if not vp_rect.intersects(line_rect):
				continue

			var is_unlocked: bool = (skill_tree != null and skill_tree.no_desbloqueado(nid))
			var is_prereq_unlocked: bool = (skill_tree != null and skill_tree.no_desbloqueado(prereq_id))
			var is_available: bool = (skill_tree != null and skill_tree.pode_investir(nid))

			var line_color := Color(0.18, 0.22, 0.32, 0.40)
			var line_width := 1.2 * zoom_level

			if is_unlocked and is_prereq_unlocked:
				line_color = Color(1.0, 0.85, 0.3, 0.95)
				line_width = 2.4 * zoom_level
			elif is_prereq_unlocked and is_available:
				line_color = Color(0.3, 0.95, 0.6, 0.85)
				line_width = 1.8 * zoom_level

			# Atenuação se houver filtro de busca ativo e o nó não for compatível
			if not search_filter.is_empty():
				var matches_filter = _node_matches_search(node) or _node_matches_search(prereq_node)
				if not matches_filter:
					line_color.a *= 0.15

			map_viewport.draw_line(from_screen, to_screen, line_color, line_width, true)

	# 2. Desenhar Nós
	for nid in database.nodes.keys():
		var node: SkillTreeNodeData = database.nodes[nid]
		if not vp_rect.has_point(node.position):
			continue

		var screen_pos := (node.position * zoom_level) + center_screen + pan_offset
		_draw_node_icon(node, screen_pos)


func _draw_background_grid(center_screen: Vector2) -> void:
	# Círculos concêntricos e eixos radiais sutis
	var rings := [300.0, 600.0, 1000.0, 1500.0, 2100.0, 2600.0]
	for r in rings:
		var r_screen := r * zoom_level
		var center_pt := center_screen + pan_offset
		map_viewport.draw_arc(center_pt, r_screen, 0.0, TAU, 64, Color(0.15, 0.25, 0.40, 0.15), 1.0)


func _draw_node_icon(node: SkillTreeNodeData, pos: Vector2) -> void:
	var rank: int = skill_tree.obter_nivel_no(node.id) if skill_tree != null else 0
	var is_unlocked := rank > 0
	var is_available := skill_tree != null and skill_tree.pode_investir(node.id)
	var is_maxed := rank >= node.nivel_max
	var is_selected := (node.id == selected_node_id)
	var is_hovered := (node.id == hovered_node_id)

	# Raio base dependendo do tipo do nó
	var base_radius := 12.0
	match node.node_type:
		SkillTreeNodeData.NodeType.SMALL: base_radius = 11.0
		SkillTreeNodeData.NodeType.MEDIUM: base_radius = 16.0
		SkillTreeNodeData.NodeType.MAJOR: base_radius = 22.0
		SkillTreeNodeData.NodeType.KEYSTONE: base_radius = 30.0

	var radius := base_radius * clamp(zoom_level, 0.5, 1.4)
	var reg_color := database.REGIONS.get(node.region_id, {}).get("color", Color.WHITE) as Color

	# Filtro de Busca
	var is_highlighted := true
	if not search_filter.is_empty():
		is_highlighted = _node_matches_search(node)

	# Cores de Estado
	var fill_color := Color(0.08, 0.10, 0.16, 0.9)
	var border_color := Color(0.25, 0.30, 0.42, 0.7)
	var border_width := 1.5 * zoom_level

	if is_unlocked:
		fill_color = reg_color.lerp(Color(1.0, 0.85, 0.3), 0.5)
		fill_color.a = 0.95
		border_color = Color(1.0, 0.9, 0.4)
		border_width = 2.5 * zoom_level
	elif is_available:
		fill_color = Color(0.12, 0.25, 0.20, 0.9)
		border_color = Color(0.3, 0.95, 0.6)
		border_width = 2.0 * zoom_level

	if not is_highlighted:
		fill_color.a *= 0.20
		border_color.a *= 0.20

	# Desenho de acordo com o formato
	match node.node_type:
		SkillTreeNodeData.NodeType.SMALL:
			map_viewport.draw_circle(pos, radius, fill_color)
			map_viewport.draw_arc(pos, radius, 0.0, TAU, 24, border_color, border_width)

		SkillTreeNodeData.NodeType.MEDIUM:
			map_viewport.draw_circle(pos, radius, fill_color)
			map_viewport.draw_arc(pos, radius, 0.0, TAU, 32, border_color, border_width)
			map_viewport.draw_arc(pos, radius * 0.65, 0.0, TAU, 24, border_color * 0.7, border_width * 0.6)

		SkillTreeNodeData.NodeType.MAJOR:
			# Octágono
			_draw_polygon_node(pos, radius, 8, fill_color, border_color, border_width)

		SkillTreeNodeData.NodeType.KEYSTONE:
			# Losango Majestoso com Aura
			if is_unlocked or is_available:
				map_viewport.draw_arc(pos, radius * 1.3, 0.0, TAU, 32, border_color * 0.4, 2.0 * zoom_level)
			_draw_polygon_node(pos, radius, 4, fill_color, border_color, border_width * 1.4)

	# Efeito de Hover / Seleção
	if is_hovered:
		map_viewport.draw_arc(pos, radius + 4.0, 0.0, TAU, 32, Color(1.0, 1.0, 1.0, 0.8), 2.0)

	if is_selected:
		map_viewport.draw_arc(pos, radius + 7.0, 0.0, TAU, 32, HunterUIStyle.COLOR_GOLD_LIGHT, 2.5)


func _draw_polygon_node(pos: Vector2, radius: float, sides: int, fill_col: Color, border_col: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var angle_step := TAU / float(sides)
	for i in range(sides):
		var a := angle_step * float(i) - PI * 0.5
		pts.append(pos + Vector2(cos(a), sin(a)) * radius)

	map_viewport.draw_colored_polygon(pts, fill_col)
	for i in range(sides):
		var next_i := (i + 1) % sides
		map_viewport.draw_line(pts[i], pts[next_i], border_col, width, true)


# ------------------------------------------------------------------------------
# ENTRADA DE USUÁRIO (PAN, ZOOM, SELEÇÃO E HOVER)
# ------------------------------------------------------------------------------
func _on_map_gui_input(event: InputEvent) -> void:
	var center_screen := size * 0.5

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			if mb.pressed:
				is_dragging = true
				drag_start_mouse = mb.position
				drag_start_pan = target_pan
				has_dragged = false
			else:
				is_dragging = false
				if not has_dragged and mb.button_index == MOUSE_BUTTON_LEFT:
					# Clique rápido em nó
					_processar_clique_em_no(mb.position)

		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_ajustar_zoom_no_cursor(1.15, mb.position)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_ajustar_zoom_no_cursor(1.0 / 1.15, mb.position)

	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if is_dragging:
			var dist = mm.position.distance_to(drag_start_mouse)
			if dist > 4.0:
				has_dragged = true
			target_pan = drag_start_pan + (mm.position - drag_start_mouse)
		else:
			_processar_hover_em_no(mm.position)


func _ajustar_zoom(factor: float) -> void:
	target_zoom = clamp(target_zoom * factor, MIN_ZOOM, MAX_ZOOM)
	map_viewport.queue_redraw()


func _ajustar_zoom_no_cursor(factor: float, cursor_pos: Vector2) -> void:
	var center_screen := size * 0.5
	var old_zoom := target_zoom
	var new_zoom := clamp(old_zoom * factor, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(old_zoom, new_zoom):
		return

	target_zoom = new_zoom
	# Zoom centrado na posição do cursor do mouse
	var cursor_world := (cursor_pos - center_screen - target_pan) / old_zoom
	target_pan = cursor_pos - center_screen - (cursor_world * new_zoom)
	map_viewport.queue_redraw()


func _processar_clique_em_no(click_pos: Vector2) -> void:
	var clicked_id := _obter_no_sob_cursor(click_pos)
	if not clicked_id.is_empty():
		selected_node_id = clicked_id
		_atualizar_inspector()
		map_viewport.queue_redraw()


func _processar_hover_em_no(mouse_pos: Vector2) -> void:
	var found_id := _obter_no_sob_cursor(mouse_pos)
	if found_id != hovered_node_id:
		hovered_node_id = found_id
		_atualizar_floating_tooltip(mouse_pos)
		map_viewport.queue_redraw()
	elif not hovered_node_id.is_empty():
		# Mover tooltip
		_posicionar_tooltip(mouse_pos)


func _obter_no_sob_cursor(screen_pos: Vector2) -> StringName:
	var center_screen := size * 0.5
	var world_mouse := (screen_pos - center_screen - pan_offset) / zoom_level

	var closest_id: StringName = &""
	var min_dist := 24.0 / zoom_level

	for nid in database.nodes.keys():
		var node: SkillTreeNodeData = database.nodes[nid]
		var dist := node.position.distance_to(world_mouse)
		if dist < min_dist:
			min_dist = dist
			closest_id = nid

	return closest_id


# ------------------------------------------------------------------------------
# ATUALIZAÇÃO DO INSPETOR E TOOLTIP
# ------------------------------------------------------------------------------
func _atualizar_inspector() -> void:
	if not database.nodes.has(selected_node_id):
		return

	var node: SkillTreeNodeData = database.nodes[selected_node_id]
	var rank := skill_tree.obter_nivel_no(node.id) if skill_tree != null else 0
	var can_invest := skill_tree != null and skill_tree.pode_investir(node.id)
	var is_maxed := rank >= node.nivel_max

	lbl_insp_name.text = node.name
	var type_str := "COMUM"
	match node.node_type:
		SkillTreeNodeData.NodeType.SMALL: type_str = "PEQUENO"
		SkillTreeNodeData.NodeType.MEDIUM: type_str = "INTERMEDIÁRIO"
		SkillTreeNodeData.NodeType.MAJOR: type_str = "ESPECIALIZAÇÃO"
		SkillTreeNodeData.NodeType.KEYSTONE: type_str = "KEYSTONE SUPREMO"

	lbl_insp_type.text = "TIPO: %s" % type_str
	lbl_insp_rank.text = "Rank: %d / %d" % [rank, node.nivel_max]
	lbl_insp_desc.text = node.description

	# Efeitos formatados
	var eff_text := ""
	for ef in node.effects_per_rank:
		var stat_name: String = ef.get("stat", "").capitalize()
		var val: float = float(ef.get("value_per_rank", ef.get("valor", 0.0)))
		var is_pct: bool = int(ef.get("mod_type", ef.get("tipo", 1))) == 1
		if is_pct:
			eff_text += "• +%.1f%% %s por Rank\n" % [val * 100.0, stat_name]
		else:
			eff_text += "• +%.0f %s por Rank\n" % [val, stat_name]

	lbl_insp_effects.text = eff_text.strip_edges()

	# Pré-requisitos
	if node.prerequisites.is_empty():
		lbl_insp_prereqs.text = "Pré-requisitos: Nenhum"
		lbl_insp_prereqs.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	else:
		var pr_names: Array[String] = []
		var all_met := true
		for pr in node.prerequisites:
			var pr_node = database.nodes.get(pr)
			var pr_n := pr_node.name if pr_node != null else String(pr)
			var met: bool = skill_tree != null and skill_tree.no_desbloqueado(pr)
			if not met: all_met = false
			pr_names.append("%s (%s)" % [pr_n, "✓" if met else "✗"])
		lbl_insp_prereqs.text = "Pré-requisitos:\n" + "\n".join(pr_names)
		lbl_insp_prereqs.add_theme_color_override("font_color", Color(0.3, 0.95, 0.5) if all_met else Color(1.0, 0.4, 0.4))

	lbl_insp_tags.text = "Tags: %s" % ", ".join(node.tags)

	# Botão de Investimento
	if is_maxed:
		btn_invest.text = "✓ DOMINADO NO MÁXIMO"
		btn_invest.disabled = true
	elif can_invest:
		btn_invest.text = "⚡ INVESTIR PONTO (%d SP)" % node.custo_pontos
		btn_invest.disabled = false
	else:
		btn_invest.text = "🔒 BLOQUEADO (%d SP)" % node.custo_pontos
		btn_invest.disabled = true


func _atualizar_floating_tooltip(mouse_pos: Vector2) -> void:
	if hovered_node_id.is_empty() or not database.nodes.has(hovered_node_id):
		tooltip_panel.visible = false
		return

	var node: SkillTreeNodeData = database.nodes[hovered_node_id]
	var rank := skill_tree.obter_nivel_no(node.id) if skill_tree != null else 0

	lbl_tip_title.text = node.name
	var type_str := "Pequeno"
	match node.node_type:
		SkillTreeNodeData.NodeType.MEDIUM: type_str = "Médio"
		SkillTreeNodeData.NodeType.MAJOR: type_str = "Especialização"
		SkillTreeNodeData.NodeType.KEYSTONE: type_str = "Keystone"

	lbl_tip_type.text = "%s (Rank %d/%d)" % [type_str, rank, node.nivel_max]
	lbl_tip_cost.text = "Custo: %d SP" % node.custo_pontos

	var eff_text := ""
	for ef in node.effects_per_rank:
		var stat_name: String = ef.get("stat", "").capitalize()
		var val: float = float(ef.get("value_per_rank", ef.get("valor", 0.0)))
		var is_pct: bool = int(ef.get("mod_type", ef.get("tipo", 1))) == 1
		if is_pct:
			eff_text += "+%.1f%% %s\n" % [val * 100.0, stat_name]
		else:
			eff_text += "+%.0f %s\n" % [val, stat_name]

	lbl_tip_effects.text = eff_text.strip_edges()
	tooltip_panel.visible = true
	_posicionar_tooltip(mouse_pos)


func _posicionar_tooltip(mouse_pos: Vector2) -> void:
	var offset := Vector2(16, 16)
	var pos := mouse_pos + offset
	if pos.x + 200.0 > size.x:
		pos.x = mouse_pos.x - 210.0
	if pos.y + 100.0 > size.y:
		pos.y = mouse_pos.y - 110.0
	tooltip_panel.position = pos


# ------------------------------------------------------------------------------
# AÇÕES E EVENTOS
# ------------------------------------------------------------------------------
func _on_invest_pressed() -> void:
	if skill_tree == null or selected_node_id.is_empty():
		return
	var sucesso := skill_tree.investir_ponto(selected_node_id)
	if sucesso:
		_atualizar_inspector()
		map_viewport.queue_redraw()


func _on_skill_investida(_nid: String, _rank: int) -> void:
	_atualizar_inspector()
	_atualizar_badge_pontos()
	map_viewport.queue_redraw()


func _on_pontos_alterados(_pts: int) -> void:
	_atualizar_badge_pontos()
	_atualizar_inspector()
	map_viewport.queue_redraw()


func _atualizar_badge_pontos() -> void:
	if lbl_points != null:
		lbl_points.text = "⭐ PONTOS DE NEN DISPONÍVEIS: %d" % (PlayerData.nen_skill_points if PlayerData != null else 0)


func _confirmar_reset_arvore() -> void:
	if skill_tree != null:
		var devolvidos := skill_tree.resetar_arvore()
		print("[NenSkillTreeUI] Árvore resetada com sucesso. Devolvidos: %d pontos." % devolvidos)
		_atualizar_inspector()
		_atualizar_badge_pontos()
		map_viewport.queue_redraw()


func _on_search_changed(new_text: String) -> void:
	search_filter = new_text.strip_edges().to_lower()
	map_viewport.queue_redraw()


func _on_region_selected(idx: int) -> void:
	if idx == 0:
		selected_region_filter = &""
		_centralizar_no_nexus()
		return

	var reg_id = database.REGIONS.keys()[idx - 1]
	selected_region_filter = reg_id

	# Calcular centro aproximado da região e navegar até ela
	var reg_info = database.REGIONS[reg_id]
	var angle := float(reg_info["angle"])
	var reg_target_pos := Vector2.from_angle(angle) * 1100.0
	_navegar_para_posicao_mundo(reg_target_pos, 0.80)


func _centralizar_no_nexus() -> void:
	_navegar_para_posicao_mundo(Vector2.ZERO, 0.85)


func _centralizar_no_progresso() -> void:
	if skill_tree == null or skill_tree.node_levels.is_empty():
		_centralizar_no_nexus()
		return

	var highest_node: SkillTreeNodeData = null
	var max_dist := -1.0

	for nid in skill_tree.node_levels.keys():
		if int(skill_tree.node_levels[nid]) > 0:
			var node = database.nodes.get(nid, database.nodes.get(StringName(String(nid))))
			if node != null:
				var dist = node.position.length()
				if dist > max_dist:
					max_dist = dist
					highest_node = node

	if highest_node != null:
		selected_node_id = highest_node.id
		_navegar_para_posicao_mundo(highest_node.position, 1.10)
		_atualizar_inspector()
	else:
		_centralizar_no_nexus()


func _navegar_para_posicao_mundo(world_pos: Vector2, target_z: float = 0.85) -> void:
	target_zoom = target_z
	target_pan = -world_pos * target_zoom
	map_viewport.queue_redraw()


func _toggle_fullscreen() -> void:
	is_fullscreen = not is_fullscreen
	if is_fullscreen:
		btn_fullscreen.text = " 🗗 Reduzir "
		inspector_panel.offset_left = -300.0
	else:
		btn_fullscreen.text = " ⛶ Tela Cheia "
		inspector_panel.offset_left = -260.0
	map_viewport.queue_redraw()


func _node_matches_search(node: SkillTreeNodeData) -> bool:
	if search_filter.is_empty():
		return true
	if node.name.to_lower().contains(search_filter):
		return true
	if String(node.region_id).to_lower().contains(search_filter):
		return true
	for tg in node.tags:
		if tg.to_lower().contains(search_filter):
			return true
	for ef in node.effects_per_rank:
		if ef.get("stat", "").to_lower().contains(search_filter):
			return true
	return false
