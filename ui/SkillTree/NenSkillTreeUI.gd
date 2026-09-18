class_name NenSkillTreeUI
extends Control

# ==============================================================================
# HUNTER ONLINE — NEN SKILL TREE CONSTELLATION MAP (REDESIGN PROFUNDO)
# ==============================================================================
# Interface estilo ARPG/MMO (PoE / WoW Dragonflight / Last Epoch):
# - Hierarquia de nós clara (Small/Medium/Major/Keystone) com anéis e glow.
# - Conexões com fluxo de aura animado nos caminhos alocados.
# - Pulse em nós disponíveis + busca com dim agressivo (legibilidade PoE).
# - Labels de região, pips de rank, burst de unlock e path highlight.
# - Câmera livre (pan/zoom), culling de viewport, inspetor + tooltip.
# ==============================================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var skill_tree: NenSkillTree = null
var database: SkillTreeDatabase = null
var _bg_texture: Texture2D = null
var _tex_nen_icons: Texture2D = null
var _tex_small_node_icons: Texture2D = null
var _tex_node_rings: Texture2D = null

# Câmera e Navegação
var pan_offset: Vector2 = Vector2.ZERO
var target_pan: Vector2 = Vector2.ZERO
var zoom_level: float = 0.70
var target_zoom: float = 0.70
const MIN_ZOOM: float = 0.20
const MAX_ZOOM: float = 2.20
var is_dragging: bool = false
var drag_start_mouse: Vector2 = Vector2.ZERO
var drag_start_pan: Vector2 = Vector2.ZERO
var has_dragged: bool = false

# FX / animação (estilo MMO talent trees)
var _fx_time: float = 0.0
var _path_highlight: Dictionary = {} # StringName -> true
var _search_matches: Array[StringName] = []
var _search_match_idx: int = -1
var _unlock_bursts: Array[Dictionary] = [] # {pos: Vector2 world, t: float, color: Color}

signal fullscreen_toggled(is_fullscreen: bool)

# Seleção e Hover
var hovered_node_id: StringName = &""
var selected_node_id: StringName = &"nexus_center"
var search_filter: String = ""
var selected_region_filter: StringName = &""
var is_fullscreen: bool = false
var is_inspector_collapsed: bool = false

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
var btn_collapse: Button = null
var scroll_insp: ScrollContainer = null
var vbox_insp_main: VBoxContainer = null

# Inspetor
var lbl_insp_name: Label
var lbl_insp_type: Label
var lbl_insp_rank: Label
var lbl_insp_desc: Label
var lbl_insp_effects: Label
var lbl_insp_prereqs: Label
var lbl_insp_tags: Label
var lbl_insp_condicao: Label

# Overlay de bloqueio pré-despertar (Arena Celestial)
var lock_overlay: PanelContainer = null
var lbl_lock_overlay: Label = null

# Compatibilidade com testes e integrações legadas
var tree_canvas: Control = null
var node_buttons: Dictionary = {}

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

	_carregar_texturas_tema()
	database = SkillTreeDatabase.get_instance()
	_localizar_skill_tree()
	_construir_ui()

	resized.connect(_atualizar_layout_responsivo)
	call_deferred("_atualizar_layout_responsivo")

	# Centralizar inicialmente no Nexus (0,0)
	call_deferred("_centralizar_no_nexus")
	call_deferred("_rebuild_path_highlight", selected_node_id)


func _carregar_texturas_tema() -> void:
	if ResourceLoader.exists("res://assets/sprites/ui/nen_skill_tree_bg.png"):
		_bg_texture = load("res://assets/sprites/ui/nen_skill_tree_bg.png")
	if ResourceLoader.exists("res://assets/sprites/ui/nen_category_icons.png"):
		_tex_nen_icons = load("res://assets/sprites/ui/nen_category_icons.png")
	if ResourceLoader.exists("res://assets/sprites/ui/nen_small_node_icons.png"):
		_tex_small_node_icons = load("res://assets/sprites/ui/nen_small_node_icons.png")
	if ResourceLoader.exists("res://assets/sprites/ui/nen_skill_node_rings.png"):
		_tex_node_rings = load("res://assets/sprites/ui/nen_skill_node_rings.png")


func _draw_node_icon(node: SkillTreeNodeData, pos: Vector2, radius: float, is_unlocked: bool, is_available: bool) -> void:
	var a := 1.0 if is_unlocked else (0.88 if is_available else 0.40)
	var icon_r := radius * (0.70 if node.node_type == SkillTreeNodeData.NodeType.SMALL else 0.82)
	var dst := Rect2(pos - Vector2(icon_r, icon_r), Vector2(icon_r * 2, icon_r * 2))

	# Disco de contraste atrás do ícone (legibilidade estilo WoW talent icon)
	map_viewport.draw_circle(pos, icon_r * 0.95, Color(0.04, 0.03, 0.02, 0.55 * a))

	if node.node_type == SkillTreeNodeData.NodeType.SMALL and _tex_small_node_icons != null:
		var cols := 12
		var cell_w := int(_tex_small_node_icons.get_width() / float(cols))
		var cell_h := _tex_small_node_icons.get_height()
		if cell_w < 4:
			cols = maxi(1, int(_tex_small_node_icons.get_width() / 16.0))
			cell_w = int(_tex_small_node_icons.get_width() / float(cols))
		var idx := absi(hash(node.id)) % cols
		var src := Rect2(idx * cell_w, 0, cell_w, cell_h)
		map_viewport.draw_texture_rect_region(_tex_small_node_icons, dst, src, Color(1, 1, 1, a))
		return

	if _tex_nen_icons == null:
		var mark := Color(0.95, 0.88, 0.55, a)
		map_viewport.draw_circle(pos, maxf(1.5, radius * 0.28), mark)
		return

	var cat_idx := _indice_categoria_regiao(node.region_id)
	if cat_idx < 0:
		return
	var cols2 := _nen_icon_column_count()
	var cw := int(_tex_nen_icons.get_width() / float(cols2))
	var ch := _tex_nen_icons.get_height()
	var src2 := Rect2(mini(cat_idx, cols2 - 1) * cw, 0, cw, ch)
	map_viewport.draw_texture_rect_region(_tex_nen_icons, dst, src2, Color(1, 1, 1, a))


func _localizar_skill_tree() -> void:
	if PlayerData != null and "skill_tree" in PlayerData and PlayerData.skill_tree != null:
		skill_tree = PlayerData.skill_tree as NenSkillTree

	if skill_tree == null and is_inside_tree() and get_tree() != null:
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
	_fx_time += delta
	# Interpolação suave de Pan e Zoom
	var needs_redraw := true # animações de pulse/fluxo pedem redraw contínuo
	if pan_offset.distance_to(target_pan) > 0.5:
		pan_offset = pan_offset.lerp(target_pan, clamp(delta * 14.0, 0.0, 1.0))
	else:
		pan_offset = target_pan

	if abs(zoom_level - target_zoom) > 0.005:
		zoom_level = lerp(zoom_level, target_zoom, clamp(delta * 14.0, 0.0, 1.0))
	else:
		zoom_level = target_zoom

	# Bursts de unlock (fade out)
	if not _unlock_bursts.is_empty():
		var vivos: Array[Dictionary] = []
		for b in _unlock_bursts:
			b["t"] = float(b.get("t", 0.0)) + delta
			if float(b["t"]) < 0.85:
				vivos.append(b)
		_unlock_bursts = vivos

	if needs_redraw and map_viewport != null and is_visible_in_tree():
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
	tree_canvas = map_viewport
	_sincronizar_node_buttons()

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

	# 7. Overlay de bloqueio até despertar Nen (Arena Celestial / Wing)
	_construir_overlay_bloqueio()
	_atualizar_estado_bloqueio()


func _construir_overlay_bloqueio() -> void:
	lock_overlay = PanelContainer.new()
	lock_overlay.name = "NenLockOverlay"
	lock_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lock_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.04, 0.05, 0.08, 0.88)
	st.border_color = HunterUIStyle.COLOR_BORDER_GOLD
	st.border_width_left = 1
	st.border_width_top = 1
	st.border_width_right = 1
	st.border_width_bottom = 1
	lock_overlay.add_theme_stylebox_override("panel", st)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lock_overlay.add_child(center)

	lbl_lock_overlay = Label.new()
	lbl_lock_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_lock_overlay.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_lock_overlay.custom_minimum_size = Vector2(220, 0)
	lbl_lock_overlay.add_theme_font_size_override("font_size", 7)
	lbl_lock_overlay.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	center.add_child(lbl_lock_overlay)
	add_child(lock_overlay)


func _atualizar_estado_bloqueio() -> void:
	if lock_overlay == null:
		return
	var bloqueada: bool = PlayerData == null or not PlayerData.despertou_nen
	lock_overlay.visible = bloqueada
	if bloqueada and lbl_lock_overlay != null:
		var sp: int = PlayerData.nen_skill_points if PlayerData != null else 0
		lbl_lock_overlay.text = (
			"🔒 CONSTELAÇÃO DE NEN SELADA\n\n"
			+ "Os princípios de Nen só se revelam na Arena Celestial,\n"
			+ "sob a orientação do Mestre Wing.\n\n"
			+ "⚡ SP acumulados: %d\n(liberados ao despertar)" % sp
		)
	if btn_invest != null and bloqueada:
		btn_invest.disabled = true


func _construir_top_bar() -> void:
	top_bar = PanelContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 24.0
	top_bar.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 1))
	add_child(top_bar)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	top_bar.add_child(hbox)

	var lbl_title := Label.new()
	lbl_title.text = "CONSTELAÇÃO DE NEN"
	lbl_title.add_theme_font_size_override("font_size", 8)
	lbl_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_title.add_theme_color_override("font_shadow_color", Color(0.05, 0.02, 0.0, 0.85))
	lbl_title.add_theme_constant_override("shadow_offset_x", 1)
	lbl_title.add_theme_constant_override("shadow_offset_y", 1)
	hbox.add_child(lbl_title)

	# Busca de Nós Compacta
	search_edit = LineEdit.new()
	search_edit.placeholder_text = "🔍 Buscar nó, stat, tag..."
	search_edit.custom_minimum_size = Vector2(110, 18)
	search_edit.add_theme_font_size_override("font_size", 6)
	search_edit.text_changed.connect(_on_search_changed)
	hbox.add_child(search_edit)

	var btn_next_match := Button.new()
	btn_next_match.text = "⏭"
	btn_next_match.tooltip_text = "Ir para o próximo resultado da busca"
	btn_next_match.add_theme_font_size_override("font_size", 6)
	btn_next_match.pressed.connect(_ir_proximo_match_busca)
	hbox.add_child(btn_next_match)

	# Menu de Regiões Compacto
	var opt_regions := OptionButton.new()
	opt_regions.add_item("Regiões (Todas)", 0)
	var idx := 1
	for reg_id in database.REGIONS.keys():
		opt_regions.add_item(database.REGIONS[reg_id]["name"], idx)
		opt_regions.set_item_metadata(idx, reg_id)
		idx += 1
	opt_regions.item_selected.connect(_on_region_selected)
	opt_regions.add_theme_font_size_override("font_size", 6)
	hbox.add_child(opt_regions)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Controles de Zoom Compactos
	var btn_zoom_out := Button.new()
	btn_zoom_out.text = " - "
	btn_zoom_out.add_theme_font_size_override("font_size", 6)
	btn_zoom_out.pressed.connect(func(): _ajustar_zoom(1.0 / 1.25))
	hbox.add_child(btn_zoom_out)

	var btn_zoom_in := Button.new()
	btn_zoom_in.text = " + "
	btn_zoom_in.add_theme_font_size_override("font_size", 6)
	btn_zoom_in.pressed.connect(func(): _ajustar_zoom(1.25))
	hbox.add_child(btn_zoom_in)

	var btn_center_nexus := Button.new()
	btn_center_nexus.text = "🎯 Nexus"
	btn_center_nexus.add_theme_font_size_override("font_size", 6)
	btn_center_nexus.pressed.connect(_centralizar_no_nexus)
	hbox.add_child(btn_center_nexus)

	var btn_center_last := Button.new()
	btn_center_last.text = "⭐ Progresso"
	btn_center_last.add_theme_font_size_override("font_size", 6)
	btn_center_last.pressed.connect(_centralizar_no_progresso)
	hbox.add_child(btn_center_last)

	btn_fullscreen = Button.new()
	btn_fullscreen.text = "⛶ Tela Cheia"
	btn_fullscreen.add_theme_font_size_override("font_size", 6)
	btn_fullscreen.pressed.connect(_toggle_fullscreen)
	hbox.add_child(btn_fullscreen)


func _construir_bottom_bar() -> void:
	bottom_bar = PanelContainer.new()
	bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bar.offset_top = -20.0
	bottom_bar.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_CYAN, 1))
	add_child(bottom_bar)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	bottom_bar.add_child(hbox)

	lbl_points = Label.new()
	lbl_points.text = "⭐ PONTOS DE NEN: %d SP" % (PlayerData.nen_skill_points if PlayerData != null else 0)
	lbl_points.add_theme_font_size_override("font_size", 6)
	lbl_points.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox.add_child(lbl_points)

	var lbl_legend := Label.new()
	lbl_legend.text = "  ● Peq  ◉ Médio  ◆ Major  ★ Keystone  ··· disponível  ═ alocado"
	lbl_legend.add_theme_font_size_override("font_size", 5)
	lbl_legend.add_theme_color_override("font_color", Color(0.75, 0.68, 0.48, 0.85))
	hbox.add_child(lbl_legend)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var btn_reset := Button.new()
	btn_reset.text = "🔄 Resetar"
	btn_reset.add_theme_font_size_override("font_size", 6)
	btn_reset.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	btn_reset.pressed.connect(func(): confirmation_dialog.popup_centered())
	hbox.add_child(btn_reset)


func _construir_inspector() -> void:
	inspector_panel = PanelContainer.new()
	inspector_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	var initial_w := clampf(size.x * 0.14, 130.0, 190.0) if size.x > 50.0 else 140.0
	inspector_panel.offset_left = -initial_w
	inspector_panel.offset_top = 26.0
	inspector_panel.offset_bottom = -22.0
	inspector_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 2))
	add_child(inspector_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	inspector_panel.add_child(margin)

	vbox_insp_main = VBoxContainer.new()
	vbox_insp_main.add_theme_constant_override("separation", 2)
	margin.add_child(vbox_insp_main)

	# Cabeçalho com Nome e Botão de Recolher
	var hbox_header := HBoxContainer.new()
	vbox_insp_main.add_child(hbox_header)

	lbl_insp_name = Label.new()
	lbl_insp_name.text = "Selecione um Nó"
	lbl_insp_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_insp_name.add_theme_font_size_override("font_size", 7)
	lbl_insp_name.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox_header.add_child(lbl_insp_name)

	btn_collapse = Button.new()
	btn_collapse.text = "▶"
	btn_collapse.tooltip_text = "Recolher / Expandir Painel"
	btn_collapse.add_theme_font_size_override("font_size", 6)
	btn_collapse.pressed.connect(_toggle_inspector_collapse)
	hbox_header.add_child(btn_collapse)

	# Conteúdo Rolável
	scroll_insp = ScrollContainer.new()
	scroll_insp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_insp.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox_insp_main.add_child(scroll_insp)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	scroll_insp.add_child(vbox)

	var hbox_type := HBoxContainer.new()
	vbox.add_child(hbox_type)

	lbl_insp_type = Label.new()
	lbl_insp_type.text = "TIPO: -"
	lbl_insp_type.add_theme_font_size_override("font_size", 5)
	hbox_type.add_child(lbl_insp_type)

	var sp_typ := Control.new()
	sp_typ.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_type.add_child(sp_typ)

	lbl_insp_rank = Label.new()
	lbl_insp_rank.text = "Rank: 0/1"
	lbl_insp_rank.add_theme_font_size_override("font_size", 5)
	hbox_type.add_child(lbl_insp_rank)

	var sep1 := HSeparator.new()
	vbox.add_child(sep1)

	lbl_insp_desc = Label.new()
	lbl_insp_desc.text = "Clique em qualquer nó da constelação para visualizar sua descrição e efeitos."
	lbl_insp_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_desc.add_theme_font_size_override("font_size", 5)
	lbl_insp_desc.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	vbox.add_child(lbl_insp_desc)

	lbl_insp_effects = Label.new()
	lbl_insp_effects.text = ""
	lbl_insp_effects.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_effects.add_theme_font_size_override("font_size", 6)
	lbl_insp_effects.add_theme_color_override("font_color", Color(0.3, 0.95, 0.5))
	vbox.add_child(lbl_insp_effects)

	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	lbl_insp_prereqs = Label.new()
	lbl_insp_prereqs.text = "Pré-requisitos: Nenhum"
	lbl_insp_prereqs.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_prereqs.add_theme_font_size_override("font_size", 5)
	vbox.add_child(lbl_insp_prereqs)

	lbl_insp_tags = Label.new()
	lbl_insp_tags.text = "Tags: -"
	lbl_insp_tags.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_tags.add_theme_font_size_override("font_size", 5)
	lbl_insp_tags.add_theme_color_override("font_color", Color(0.7, 0.7, 0.85))
	vbox.add_child(lbl_insp_tags)

	lbl_insp_condicao = Label.new()
	lbl_insp_condicao.text = ""
	lbl_insp_condicao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_condicao.add_theme_font_size_override("font_size", 5)
	lbl_insp_condicao.add_theme_color_override("font_color", Color(0.9, 0.7, 0.4))
	vbox.add_child(lbl_insp_condicao)

	# Botão de Investimento na base
	btn_invest = Button.new()
	btn_invest.text = "⚡ INVESTIR (1 SP)"
	btn_invest.custom_minimum_size = Vector2(0, 20)
	btn_invest.add_theme_font_size_override("font_size", 6)
	btn_invest.pressed.connect(_on_invest_pressed)
	vbox_insp_main.add_child(btn_invest)


func _construir_floating_tooltip() -> void:
	tooltip_panel = PanelContainer.new()
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.visible = false
	tooltip_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 1))
	add_child(tooltip_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 3)
	tooltip_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	margin.add_child(vbox)

	lbl_tip_title = Label.new()
	lbl_tip_title.add_theme_font_size_override("font_size", 6)
	lbl_tip_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vbox.add_child(lbl_tip_title)

	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)

	lbl_tip_type = Label.new()
	lbl_tip_type.add_theme_font_size_override("font_size", 5)
	hbox.add_child(lbl_tip_type)

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(sp)

	lbl_tip_cost = Label.new()
	lbl_tip_cost.add_theme_font_size_override("font_size", 5)
	lbl_tip_cost.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox.add_child(lbl_tip_cost)

	lbl_tip_effects = Label.new()
	lbl_tip_effects.add_theme_font_size_override("font_size", 5)
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

	_draw_background_grid(center_screen)
	_draw_region_labels(center_screen, vp_rect)

	# 1. Linhas conectoras (fluxo de aura + path highlight)
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

			var line_rect := Rect2(from_world, Vector2.ZERO).expand(to_world).grow(100.0)
			if not vp_rect.intersects(line_rect):
				continue

			var is_unlocked: bool = (skill_tree != null and skill_tree.no_desbloqueado(nid))
			var is_prereq_unlocked: bool = (skill_tree != null and skill_tree.no_desbloqueado(prereq_id))
			var is_available: bool = (skill_tree != null and skill_tree.pode_investir(nid))
			var on_path: bool = _path_highlight.has(nid) and _path_highlight.has(prereq_id)

			var line_color := Color(0.28, 0.20, 0.12, 0.35)
			var line_width := 1.1 * zoom_level
			var reg_tint: Color = Color(0.55, 0.45, 0.30)
			if database.REGIONS.has(node.region_id):
				reg_tint = database.REGIONS[node.region_id].get("color", reg_tint)

			if is_unlocked and is_prereq_unlocked:
				line_color = Color(reg_tint.r, reg_tint.g, reg_tint.b, 0.95).lerp(Color(0.35, 0.92, 1.0, 0.95), 0.35)
				line_width = 2.8 * zoom_level
				# Glow externo (PoE allocated edge)
				map_viewport.draw_line(from_screen, to_screen, Color(1.0, 0.85, 0.35, 0.22), line_width + 3.5, true)
				map_viewport.draw_line(from_screen, to_screen, Color(0.4, 0.95, 1.0, 0.18), line_width + 1.5, true)
				_draw_aura_flow(from_screen, to_screen, line_color)
			elif is_prereq_unlocked and is_available:
				# Trace path disponível (WoW / PoE hover path)
				var pulse := 0.55 + 0.45 * sin(_fx_time * 3.2)
				line_color = Color(reg_tint.r, reg_tint.g, reg_tint.b, 0.55 + 0.35 * pulse).lerp(Color(0.45, 1.0, 0.55, 0.9), 0.45)
				line_width = 2.0 * zoom_level
				_draw_dashed_line(from_screen, to_screen, line_color, line_width)
			else:
				line_color = Color(reg_tint.r * 0.35, reg_tint.g * 0.35, reg_tint.b * 0.35, 0.22)

			if on_path and not (is_unlocked and is_prereq_unlocked):
				line_color = Color(1.0, 0.82, 0.28, 0.75)
				line_width = maxf(line_width, 2.2 * zoom_level)

			if not search_filter.is_empty():
				var matches_filter = _node_matches_search(node) or _node_matches_search(prereq_node)
				if not matches_filter:
					line_color.a *= 0.08

			if not (is_prereq_unlocked and is_available and not (is_unlocked and is_prereq_unlocked)):
				map_viewport.draw_line(from_screen, to_screen, line_color, line_width, true)

	# 2. Nós
	for nid in database.nodes.keys():
		var node: SkillTreeNodeData = database.nodes[nid]
		if not vp_rect.has_point(node.position):
			continue
		var screen_pos := (node.position * zoom_level) + center_screen + pan_offset
		_draw_skill_node(node, screen_pos)

	# 3. Bursts de unlock (acima dos nós)
	_draw_unlock_bursts(center_screen)

	# 4. Vignette suave (foco no mapa)
	_draw_vignette()


func _draw_background_grid(center_screen: Vector2) -> void:
	var full := Rect2(Vector2.ZERO, size)
	# Base 100% opaca (evita “checkerboard” de alpha no capture/viewport)
	map_viewport.draw_rect(full, Color(0.09, 0.06, 0.035, 1.0), true)
	if _bg_texture != null:
		var tile := 512.0 * maxf(zoom_level, 0.55)
		var origin := Vector2(
			fposmod(pan_offset.x * 0.28, tile),
			fposmod(pan_offset.y * 0.28, tile)
		)
		var x0 := -tile + origin.x
		while x0 < size.x + tile:
			var y0 := -tile + origin.y
			while y0 < size.y + tile:
				map_viewport.draw_texture_rect(_bg_texture, Rect2(Vector2(x0, y0), Vector2(tile, tile)), false, Color(0.92, 0.85, 0.7, 0.42))
				y0 += tile
			x0 += tile
	else:
		map_viewport.draw_circle(center_screen + pan_offset * 0.15, size.x * 0.55, Color(0.08, 0.22, 0.28, 0.35))
		map_viewport.draw_circle(center_screen + Vector2(size.x * 0.2, -size.y * 0.1) + pan_offset * 0.1, size.x * 0.35, Color(0.35, 0.18, 0.08, 0.22))

	# Nebulosa de aura por cima do tile (costura as bordas)
	map_viewport.draw_circle(center_screen + pan_offset * 0.12, size.x * 0.48, Color(0.06, 0.16, 0.2, 0.22))
	map_viewport.draw_circle(center_screen + Vector2(-size.x * 0.15, size.y * 0.1), size.x * 0.32, Color(0.25, 0.12, 0.06, 0.18))

	# Estrelas / partículas de aura estáveis
	var rng := RandomNumberGenerator.new()
	rng.seed = 287001
	for i in range(110):
		var p := Vector2(rng.randf() * size.x, rng.randf() * size.y)
		var twinkle := 0.5 + 0.5 * sin(_fx_time * rng.randf_range(1.2, 2.8) + float(i))
		var a := rng.randf_range(0.06, 0.28) * twinkle
		map_viewport.draw_circle(p, rng.randf_range(0.55, 1.5), Color(0.9, 0.82, 0.55, a))

	# Hexágono do gráfico de Nen (6 categorias)
	var nexus := center_screen + pan_offset
	var hex_r: float = 220.0 * zoom_level
	var hex_pts := PackedVector2Array()
	for i in range(6):
		var a := -PI * 0.5 + TAU * float(i) / 6.0
		hex_pts.append(nexus + Vector2(cos(a), sin(a)) * hex_r)
	for i in range(6):
		var pulse_a := 0.22 + 0.08 * sin(_fx_time * 1.4 + float(i))
		map_viewport.draw_line(hex_pts[i], hex_pts[(i + 1) % 6], Color(0.55, 0.38, 0.14, pulse_a), 1.6, true)
		map_viewport.draw_line(nexus, hex_pts[i], Color(0.25, 0.65, 0.75, 0.10), 1.0, true)

	# Anéis de profundidade (órbitas PoE-like)
	var rings: Array[float] = [300.0, 700.0, 1200.0, 1800.0, 2400.0, 3000.0]
	for ri in range(rings.size()):
		var r: float = rings[ri]
		var r_screen: float = r * zoom_level
		var a2 := 0.08 + 0.04 * sin(_fx_time * 0.7 + float(ri))
		map_viewport.draw_arc(nexus, r_screen, 0.0, TAU, 72, Color(0.35, 0.55, 0.45, a2), 1.0)


func _draw_region_labels(center_screen: Vector2, vp_rect: Rect2) -> void:
	if database == null or zoom_level < 0.28:
		return
	for reg_id in database.REGIONS.keys():
		if reg_id == &"nexus":
			continue
		var info: Dictionary = database.REGIONS[reg_id]
		var angle := float(info.get("angle", 0.0))
		var world := Vector2.from_angle(angle) * 980.0
		if not vp_rect.grow(180.0).has_point(world):
			continue
		var screen := (world * zoom_level) + center_screen + pan_offset
		var col: Color = info.get("color", Color.WHITE)
		var nome: String = str(info.get("name", reg_id))
		# Pill de região
		var font := ThemeDB.fallback_font
		var fs := 8 if zoom_level > 0.55 else 6
		var tw := font.get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var pad := Vector2(8, 4)
		var rect := Rect2(screen - Vector2(tw * 0.5 + pad.x, 10), Vector2(tw + pad.x * 2, 16))
		map_viewport.draw_rect(rect, Color(0.06, 0.04, 0.02, 0.72), true)
		map_viewport.draw_rect(rect, Color(col.r, col.g, col.b, 0.55), false, 1.2)
		map_viewport.draw_string(font, rect.position + Vector2(pad.x, 12), nome, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(col.r, col.g, col.b, 0.95).lerp(Color(1, 0.92, 0.7), 0.35))


func _draw_vignette() -> void:
	var w := size.x
	var h := size.y
	var edge := Color(0.02, 0.015, 0.01, 0.55)
	map_viewport.draw_rect(Rect2(0, 0, w, 28), Color(edge.r, edge.g, edge.b, 0.35), true)
	map_viewport.draw_rect(Rect2(0, h - 26, w, 26), Color(edge.r, edge.g, edge.b, 0.4), true)
	map_viewport.draw_rect(Rect2(0, 0, 18, h), Color(edge.r, edge.g, edge.b, 0.3), true)
	map_viewport.draw_rect(Rect2(w - 18, 0, 18, h), Color(edge.r, edge.g, edge.b, 0.3), true)


func _draw_aura_flow(from_s: Vector2, to_s: Vector2, col: Color) -> void:
	var dir := to_s - from_s
	var len_v := dir.length()
	if len_v < 8.0:
		return
	var n := dir / len_v
	var count := clampi(int(len_v / 42.0), 2, 8)
	for i in range(count):
		var t := fmod((_fx_time * 0.35) + float(i) / float(count), 1.0)
		var p := from_s.lerp(to_s, t)
		var a := 0.25 + 0.55 * sin(t * PI)
		map_viewport.draw_circle(p, 2.0 * zoom_level + 0.8, Color(col.r, col.g, col.b, a))
		map_viewport.draw_circle(p, 1.0 * zoom_level, Color(1.0, 0.95, 0.7, a * 0.9))


func _draw_dashed_line(from_s: Vector2, to_s: Vector2, col: Color, width: float) -> void:
	var dir := to_s - from_s
	var len_v := dir.length()
	if len_v < 4.0:
		return
	var n := dir / len_v
	var dash := 8.0 * zoom_level
	var gap := 5.0 * zoom_level
	var d := 0.0
	var phase := fmod(_fx_time * 22.0, dash + gap)
	d = -phase
	while d < len_v:
		var a := clampf(d, 0.0, len_v)
		var b := clampf(d + dash, 0.0, len_v)
		if b > a:
			map_viewport.draw_line(from_s + n * a, from_s + n * b, col, width, true)
		d += dash + gap


func _draw_unlock_bursts(center_screen: Vector2) -> void:
	for b in _unlock_bursts:
		var t: float = float(b.get("t", 0.0))
		var world: Vector2 = b.get("pos", Vector2.ZERO)
		var col: Color = b.get("color", Color(1.0, 0.85, 0.35))
		var screen := (world * zoom_level) + center_screen + pan_offset
		var life := clampf(t / 0.85, 0.0, 1.0)
		var rad := (18.0 + life * 42.0) * zoom_level
		var a := (1.0 - life) * 0.7
		map_viewport.draw_arc(screen, rad, 0.0, TAU, 40, Color(col.r, col.g, col.b, a), 2.5)
		map_viewport.draw_arc(screen, rad * 0.55, 0.0, TAU, 28, Color(1, 1, 1, a * 0.5), 1.5)
		for i in range(8):
			var ang := TAU * float(i) / 8.0 + t * 4.0
			var p := screen + Vector2(cos(ang), sin(ang)) * rad * 0.85
			map_viewport.draw_circle(p, 2.2 * (1.0 - life) * zoom_level, Color(col.r, col.g, col.b, a))


func _draw_skill_node(node: SkillTreeNodeData, pos: Vector2) -> void:
	var rank: int = skill_tree.obter_nivel_no(node.id) if skill_tree != null else 0
	var is_unlocked := rank > 0
	var is_available := skill_tree != null and skill_tree.pode_investir(node.id)
	var is_maxed := rank >= node.nivel_max
	var is_selected := (node.id == selected_node_id)
	var is_hovered := (node.id == hovered_node_id)
	var on_path := _path_highlight.has(node.id)

	var base_radius: float = 12.0
	match node.node_type:
		SkillTreeNodeData.NodeType.SMALL: base_radius = 11.0
		SkillTreeNodeData.NodeType.MEDIUM: base_radius = 16.0
		SkillTreeNodeData.NodeType.MAJOR: base_radius = 22.0
		SkillTreeNodeData.NodeType.KEYSTONE: base_radius = 30.0

	var radius: float = base_radius * clampf(zoom_level, 0.5, 1.4)
	var reg_color: Color = Color.WHITE
	if database != null and database.REGIONS.has(node.region_id):
		reg_color = database.REGIONS[node.region_id].get("color", Color.WHITE)

	var is_highlighted := true
	if not search_filter.is_empty():
		is_highlighted = _node_matches_search(node)

	# Paleta por estado (contraste alto estilo PoE allocated)
	var fill_color := Color(0.12, 0.09, 0.05, 0.94)
	var border_color := Color(0.35, 0.26, 0.14, 0.7)
	var border_width := 1.6 * zoom_level
	var glow_a := 0.0

	if is_unlocked:
		fill_color = reg_color.lerp(Color(0.15, 0.55, 0.75), 0.35)
		fill_color = fill_color.lerp(Color(0.95, 0.85, 0.45), 0.25)
		fill_color.a = 0.98
		border_color = Color(1.0, 0.86, 0.32) if is_maxed else Color(0.45, 0.95, 1.0)
		border_width = 2.8 * zoom_level
		glow_a = 0.28
	elif is_available:
		var pulse := 0.5 + 0.5 * sin(_fx_time * 3.6 + hash(node.id) * 0.001)
		fill_color = Color(0.10, 0.20, 0.16, 0.94)
		border_color = Color(0.35, 1.0, 0.55, 0.65 + 0.35 * pulse)
		border_width = 2.2 * zoom_level
		glow_a = 0.12 + 0.16 * pulse
	else:
		fill_color = Color(0.10, 0.08, 0.05, 0.88)
		border_color = Color(0.28, 0.22, 0.14, 0.55)

	if on_path and not is_unlocked:
		border_color = Color(1.0, 0.82, 0.3, 0.9)
		glow_a = maxf(glow_a, 0.18)

	if not is_highlighted:
		fill_color.a *= 0.12
		border_color.a *= 0.12
		glow_a *= 0.08
	elif not search_filter.is_empty():
		# Match de busca: anel amarelo pulsante (PoE search glow)
		var sp := 0.5 + 0.5 * sin(_fx_time * 5.0)
		map_viewport.draw_arc(pos, radius + 6.0 + sp * 3.0, 0.0, TAU, 36, Color(1.0, 0.92, 0.25, 0.55 + 0.35 * sp), 2.4)

	# Sombra
	map_viewport.draw_circle(pos + Vector2(1.5, 2.0) * zoom_level, radius * 1.05, Color(0, 0, 0, 0.35 * fill_color.a))

	# Glow externo
	if glow_a > 0.01:
		map_viewport.draw_circle(pos, radius * 1.55, Color(border_color.r, border_color.g, border_color.b, glow_a))
		map_viewport.draw_circle(pos, radius * 1.25, Color(border_color.r, border_color.g, border_color.b, glow_a * 0.55))

	# Corpo por tipo (hierarquia visual clara)
	match node.node_type:
		SkillTreeNodeData.NodeType.SMALL:
			map_viewport.draw_circle(pos, radius, fill_color)
			map_viewport.draw_arc(pos, radius, 0.0, TAU, 28, border_color, border_width)
			# Bevel interno
			map_viewport.draw_arc(pos, radius * 0.78, 0.0, TAU, 20, Color(1, 1, 1, 0.12 * fill_color.a), 1.0)
		SkillTreeNodeData.NodeType.MEDIUM:
			map_viewport.draw_circle(pos, radius, fill_color)
			map_viewport.draw_arc(pos, radius, 0.0, TAU, 36, border_color, border_width)
			map_viewport.draw_arc(pos, radius * 0.68, 0.0, TAU, 28, border_color * Color(1, 1, 1, 0.7), border_width * 0.55)
			_draw_ring_ornament(pos, radius, false)
		SkillTreeNodeData.NodeType.MAJOR:
			_draw_polygon_node(pos, radius, 8, fill_color, border_color, border_width)
			map_viewport.draw_arc(pos, radius * 0.55, 0.0, TAU, 24, Color(border_color.r, border_color.g, border_color.b, 0.55), 1.2)
			_draw_ring_ornament(pos, radius, true)
		SkillTreeNodeData.NodeType.KEYSTONE:
			if is_unlocked or is_available:
				var kp := 0.5 + 0.5 * sin(_fx_time * 2.4)
				map_viewport.draw_arc(pos, radius * (1.28 + 0.08 * kp), 0.0, TAU, 40, Color(0.4, 0.9, 1.0, 0.28 + 0.12 * kp), 2.4 * zoom_level)
			_draw_polygon_node(pos, radius, 6, fill_color, border_color, border_width * 1.35)
			_draw_polygon_node(pos, radius * 0.62, 6, Color(fill_color.r * 0.7, fill_color.g * 0.7, fill_color.b * 0.7, fill_color.a), border_color * 0.8, border_width * 0.6)
			_draw_ring_ornament(pos, radius * 1.05, true)

	# Ícones
	if zoom_level > 0.32:
		_draw_node_icon(node, pos, radius, is_unlocked, is_available)

	# Rank pips (nós multi-nível)
	if node.nivel_max > 1 and zoom_level > 0.45:
		_draw_rank_pips(pos, radius, rank, node.nivel_max, is_highlighted)

	if is_hovered:
		map_viewport.draw_arc(pos, radius + 5.0, 0.0, TAU, 36, Color(1.0, 1.0, 1.0, 0.85), 2.0)
	if is_selected:
		var sel_pulse := 0.5 + 0.5 * sin(_fx_time * 4.0)
		map_viewport.draw_arc(pos, radius + 7.5 + sel_pulse, 0.0, TAU, 40, HunterUIStyle.COLOR_GOLD, 2.6)
		map_viewport.draw_arc(pos, radius + 10.0 + sel_pulse * 0.5, 0.0, TAU, 40, Color(1.0, 0.85, 0.35, 0.35), 1.2)


func _draw_ring_ornament(pos: Vector2, radius: float, ornate: bool) -> void:
	# Ornamento procedural (evita o avatar/retrato do atlas de rings).
	if not ornate or zoom_level < 0.5:
		return
	var r := radius * 1.08
	var studs := 6
	for i in range(studs):
		var a := -PI * 0.5 + TAU * float(i) / float(studs)
		var p := pos + Vector2(cos(a), sin(a)) * r
		map_viewport.draw_circle(p, 1.6 * zoom_level, Color(0.85, 0.68, 0.28, 0.75))
		map_viewport.draw_circle(p, 0.7 * zoom_level, Color(1.0, 0.92, 0.55, 0.9))


func _draw_rank_pips(pos: Vector2, radius: float, rank: int, max_rank: int, visible: bool) -> void:
	if not visible:
		return
	var n := mini(max_rank, 6)
	var spacing := 4.5 * zoom_level
	var total_w := spacing * float(n - 1)
	var base := pos + Vector2(-total_w * 0.5, radius + 6.0 * zoom_level)
	for i in range(n):
		var filled := i < rank
		var p := base + Vector2(spacing * float(i), 0)
		var c := Color(1.0, 0.85, 0.3, 0.95) if filled else Color(0.25, 0.2, 0.12, 0.7)
		map_viewport.draw_circle(p, 1.8 * zoom_level, c)


func _nen_icon_column_count() -> int:
	if _tex_nen_icons == null:
		return 6
	var w := _tex_nen_icons.get_width()
	if w >= 180 and (w % 6) == 0:
		return 6
	if w >= 120 and (w % 4) == 0:
		return 4
	return 6 if w >= 160 else 4


func _indice_categoria_regiao(region_id: StringName) -> int:
	match String(region_id):
		"warrior", "body":
			return 0
		"nen", "vitality":
			return 1
		"hatsu", "critical":
			return 2
		"aura", "master":
			return 3
		"speed":
			return 4
		"specialization", "nexus":
			return 5
		_:
			return -1


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
	var old_zoom: float = target_zoom
	var new_zoom: float = clampf(old_zoom * factor, MIN_ZOOM, MAX_ZOOM)
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
		_rebuild_path_highlight(clicked_id)
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
	if database == null:
		database = SkillTreeDatabase.get_instance()
	if database == null or not database.nodes.has(selected_node_id):
		return
	if lbl_insp_name == null:
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
			var pr_n: String = pr_node.name if pr_node != null else String(pr)
			var met: bool = skill_tree != null and skill_tree.no_desbloqueado(pr)
			if not met: all_met = false
			pr_names.append("%s (%s)" % [pr_n, "✓" if met else "✗"])
		lbl_insp_prereqs.text = "Pré-requisitos:\n" + "\n".join(pr_names)
		lbl_insp_prereqs.add_theme_color_override("font_color", Color(0.3, 0.95, 0.5) if all_met else Color(1.0, 0.4, 0.4))

	lbl_insp_tags.text = "Tags: %s" % ", ".join(node.tags)

	if lbl_insp_condicao != null:
		if node.tags.has("bloodied"):
			lbl_insp_condicao.text = "Condição: Vida abaixo de 40%"
		elif node.tags.has("isolated_target"):
			lbl_insp_condicao.text = "Condição: Alvo isolado"
		elif node.tags.has("surrounded"):
			lbl_insp_condicao.text = "Condição: Cercado por 3+ inimigos"
		elif node.tags.has("first_strike"):
			lbl_insp_condicao.text = "Condição: Primeiro golpe contra o alvo"
		elif not node.tags.is_empty():
			lbl_insp_condicao.text = "Condição: Requisitos de combate padrão"
		else:
			lbl_insp_condicao.text = ""

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
	var tip_sz: Vector2 = tooltip_panel.size if tooltip_panel.size.x > 10.0 else Vector2(120, 50)
	var pos := mouse_pos + Vector2(10, 10)
	if pos.x + tip_sz.x > size.x:
		pos.x = mouse_pos.x - tip_sz.x - 10.0
	if pos.y + tip_sz.y > size.y:
		pos.y = mouse_pos.y - tip_sz.y - 10.0
	pos.x = maxf(pos.x, 4.0)
	pos.y = maxf(pos.y, 4.0)
	tooltip_panel.position = pos


# ------------------------------------------------------------------------------
# AÇÕES E EVENTOS
# ------------------------------------------------------------------------------
func _on_invest_pressed() -> void:
	if PlayerData != null and not PlayerData.despertou_nen:
		_atualizar_estado_bloqueio()
		if EventBus != null:
			EventBus.emit_toast(
				"🔒 Árvore bloqueada até despertar Nen com Wing.",
				HunterUIStyle.COLOR_TEXT_MUTED
			)
		return
	if skill_tree == null or selected_node_id.is_empty():
		return
	var sucesso := skill_tree.investir_ponto(selected_node_id)
	if sucesso:
		_spawn_unlock_burst(selected_node_id)
		_rebuild_path_highlight(selected_node_id)
		_atualizar_inspector()
		map_viewport.queue_redraw()


func _spawn_unlock_burst(nid: StringName) -> void:
	if database == null or not database.nodes.has(nid):
		return
	var node: SkillTreeNodeData = database.nodes[nid]
	var col := Color(1.0, 0.85, 0.35)
	if database.REGIONS.has(node.region_id):
		col = database.REGIONS[node.region_id].get("color", col)
	_unlock_bursts.append({"pos": node.position, "t": 0.0, "color": col})
	if AudioManager != null and AudioManager.has_method("tocar_sfx_tipo"):
		AudioManager.tocar_sfx_tipo("nen_gyo", 1.05)


func _rebuild_path_highlight(nid: StringName) -> void:
	_path_highlight.clear()
	if database == null or not database.nodes.has(nid):
		return
	var stack: Array[StringName] = [nid]
	var seen: Dictionary = {}
	while not stack.is_empty():
		var cur: StringName = stack.pop_back()
		if seen.has(cur):
			continue
		seen[cur] = true
		_path_highlight[cur] = true
		var node: SkillTreeNodeData = database.nodes.get(cur)
		if node == null:
			continue
		for pr in node.prerequisites:
			if database.nodes.has(pr):
				stack.append(pr)


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
		var sp: int = PlayerData.nen_skill_points if PlayerData != null else 0
		if PlayerData != null and not PlayerData.despertou_nen:
			lbl_points.text = "🔒 SP ACUMULADOS: %d (bloqueados até Arena Celestial)" % sp
		else:
			lbl_points.text = "⭐ PONTOS DE NEN DISPONÍVEIS: %d" % sp
	_atualizar_estado_bloqueio()


func _confirmar_reset_arvore() -> void:
	if skill_tree != null:
		var devolvidos := skill_tree.resetar_arvore()
		print("[NenSkillTreeUI] Árvore resetada com sucesso. Devolvidos: %d pontos." % devolvidos)
		_atualizar_inspector()
		_atualizar_badge_pontos()
		map_viewport.queue_redraw()


func _on_search_changed(new_text: String) -> void:
	search_filter = new_text.strip_edges().to_lower()
	_rebuild_search_matches()
	map_viewport.queue_redraw()


func _rebuild_search_matches() -> void:
	_search_matches.clear()
	_search_match_idx = -1
	if search_filter.is_empty() or database == null:
		return
	for nid in database.nodes.keys():
		var node: SkillTreeNodeData = database.nodes[nid]
		if _node_matches_search(node):
			_search_matches.append(nid)


func _ir_proximo_match_busca() -> void:
	if _search_matches.is_empty():
		_rebuild_search_matches()
	if _search_matches.is_empty():
		return
	_search_match_idx = (_search_match_idx + 1) % _search_matches.size()
	var nid: StringName = _search_matches[_search_match_idx]
	selected_node_id = nid
	_rebuild_path_highlight(nid)
	var node: SkillTreeNodeData = database.nodes[nid]
	_navegar_para_posicao_mundo(node.position, clampf(target_zoom, 0.9, 1.35))
	_atualizar_inspector()
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
		btn_fullscreen.text = "🗗 Reduzir"
		target_zoom = 0.55
	else:
		btn_fullscreen.text = "⛶ Tela Cheia"
		target_zoom = 0.70
	_atualizar_layout_responsivo()
	fullscreen_toggled.emit(is_fullscreen)
	map_viewport.queue_redraw()


func _atualizar_layout_responsivo() -> void:
	if inspector_panel != null:
		if is_inspector_collapsed:
			inspector_panel.offset_left = -22.0
		else:
			var cur_w: float = size.x if size.x > 50.0 else (get_viewport().get_visible_rect().size.x if get_viewport() != null else 1280.0)
			# Ocupa estritamente entre 12% e 15% da largura da tela (130px a 190px)
			var target_w: float = clampf(cur_w * 0.14, 130.0, 190.0)
			inspector_panel.offset_left = -target_w
		inspector_panel.offset_top = 26.0
		inspector_panel.offset_bottom = -22.0

	if top_bar != null:
		top_bar.offset_bottom = 24.0

	if bottom_bar != null:
		bottom_bar.offset_top = -20.0

	if map_viewport != null:
		map_viewport.queue_redraw()


func _toggle_inspector_collapse() -> void:
	is_inspector_collapsed = not is_inspector_collapsed
	if is_inspector_collapsed:
		if btn_collapse != null:
			btn_collapse.text = "◀"
		if scroll_insp != null:
			scroll_insp.visible = false
		if btn_invest != null:
			btn_invest.visible = false
		if lbl_insp_name != null:
			lbl_insp_name.visible = false
		if inspector_panel != null:
			inspector_panel.offset_left = -22.0
	else:
		if btn_collapse != null:
			btn_collapse.text = "▶"
		if scroll_insp != null:
			scroll_insp.visible = true
		if btn_invest != null:
			btn_invest.visible = true
		if lbl_insp_name != null:
			lbl_insp_name.visible = true
		_atualizar_layout_responsivo()


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


# ------------------------------------------------------------------------------
# ATUALIZAÇÃO DA EXIBIÇÃO & COMPATIBILIDADE CANÔNICA
# ------------------------------------------------------------------------------
func _atualizar_exibicao() -> void:
	atualizar_exibicao()


func atualizar_exibicao() -> void:
	if database == null:
		database = SkillTreeDatabase.get_instance()
	_localizar_skill_tree()
	_atualizar_badge_pontos()
	_atualizar_inspector()
	_atualizar_estado_bloqueio()
	if map_viewport != null:
		map_viewport.queue_redraw()
	# Tip de primeira abertura após despertar Nen
	if PlayerData != null and PlayerData.despertou_nen:
		if TutorialManager != null and TutorialManager.has_method("disparar_tutorial_contextual"):
			TutorialManager.disparar_tutorial_contextual("nen_arvore")


func _sincronizar_node_buttons() -> void:
	node_buttons.clear()
	if database == null:
		database = SkillTreeDatabase.get_instance()
	if database != null:
		for nid in database.nodes.keys():
			node_buttons[nid] = map_viewport
			node_buttons[String(nid)] = map_viewport


func _atualizar_painel_inspetor() -> void:
	_atualizar_inspector()


func _on_botao_investir_pressionado() -> void:
	_on_invest_pressed()


func _corresponde_ao_filtro(cat: int, filtro: String) -> bool:
	var f := filtro.to_lower()
	match f:
		"todos":
			return true
		"fundamentos":
			return cat in [
				NenSkillTree.Categoria.TEN,
				NenSkillTree.Categoria.ZETSU,
				NenSkillTree.Categoria.REN,
				NenSkillTree.Categoria.GYO,
				NenSkillTree.Categoria.EN,
				NenSkillTree.Categoria.KO,
				NenSkillTree.Categoria.SHU
			]
		"defesa":
			return cat in [
				NenSkillTree.Categoria.TEN,
				NenSkillTree.Categoria.ZETSU,
				NenSkillTree.Categoria.RYU_DEFENSIVO
			]
		"ofensa":
			return cat in [
				NenSkillTree.Categoria.REN,
				NenSkillTree.Categoria.KO,
				NenSkillTree.Categoria.RYU_OFENSIVO
			]
		"ryu":
			return cat in [
				NenSkillTree.Categoria.RYU_OFENSIVO,
				NenSkillTree.Categoria.RYU_DEFENSIVO,
				NenSkillTree.Categoria.RYU_EQUILIBRADO
			]
		"comportamentais", "comportamental":
			return cat == NenSkillTree.Categoria.COMPORTAMENTAL
		"sinergias", "sinergia":
			return cat == NenSkillTree.Categoria.SINERGIA
		_:
			return true

