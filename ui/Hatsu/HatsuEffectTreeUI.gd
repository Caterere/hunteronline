class_name HatsuEffectTreeUI
extends Control

# ============================================================
# Hatsu Creator — árvore radial tematizada (estilo constelação)
# ============================================================
# Compacta (~40–70 nós), pan/zoom, ícones/anéis, pontos das restrições.
# ============================================================

const EffectTree = preload("res://scripts/systems/hatsu/HatsuEffectTree.gd")
const DB = preload("res://scripts/systems/hatsu/HatsuEffectTreeDatabase.gd")
const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

signal confirmado(tree: RefCounted)
signal cancelado

var tree: HatsuEffectTree = null
var pan: Vector2 = Vector2.ZERO
var zoom: float = 1.0
var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var pan_start: Vector2 = Vector2.ZERO
var hovered: StringName = &""
var selected: StringName = &"hx_center"
var _bg: Texture2D = null
var _tex_nen_icons: Texture2D = null
var _tex_small_icons: Texture2D = null
var _fx_t: float = 0.0
var _path_hl: Dictionary = {}

var lbl_points: Label
var lbl_tip: Label
var lbl_insp_name: Label
var lbl_insp_body: Label
var btn_ok: Button
var btn_back: Button
var btn_alloc: Button


func setup(effect_tree: HatsuEffectTree) -> void:
	tree = effect_tree
	if tree != null and not tree.pontos_alterados.is_connected(_on_pts):
		tree.pontos_alterados.connect(_on_pts)
	_on_pts(tree.obter_saldo() if tree else 0)
	_rebuild_path(selected)
	_refresh_inspector()
	_refresh_confirm_btn()
	queue_redraw()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	_load_textures()
	_build_chrome()
	queue_redraw()


func _load_textures() -> void:
	if ResourceLoader.exists("res://assets/sprites/ui/nen_skill_tree_bg.png"):
		_bg = load("res://assets/sprites/ui/nen_skill_tree_bg.png") as Texture2D
	if ResourceLoader.exists("res://assets/sprites/ui/nen_category_icons.png"):
		_tex_nen_icons = load("res://assets/sprites/ui/nen_category_icons.png") as Texture2D
	if ResourceLoader.exists("res://assets/sprites/ui/nen_small_node_icons.png"):
		_tex_small_icons = load("res://assets/sprites/ui/nen_small_node_icons.png") as Texture2D


func _build_chrome() -> void:
	var top := PanelContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 22.0
	top.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 1))
	top.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(top)
	var hb := HBoxContainer.new()
	top.add_child(hb)
	lbl_points = Label.new()
	lbl_points.add_theme_font_size_override("font_size", 5)
	lbl_points.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_points.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_points.text = "Pontos: —"
	hb.add_child(lbl_points)
	btn_back = Button.new()
	btn_back.text = "← Base"
	btn_back.add_theme_font_size_override("font_size", 4)
	btn_back.pressed.connect(func(): cancelado.emit())
	hb.add_child(btn_back)
	btn_ok = Button.new()
	btn_ok.text = "Confirmar Árvore"
	btn_ok.add_theme_font_size_override("font_size", 4)
	btn_ok.pressed.connect(_on_confirm)
	hb.add_child(btn_ok)

	# Inspetor lateral
	var insp := PanelContainer.new()
	insp.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	insp.offset_left = -110.0
	insp.offset_top = 24.0
	insp.offset_bottom = -38.0
	insp.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 1))
	insp.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(insp)
	var im := MarginContainer.new()
	im.add_theme_constant_override("margin_left", 4)
	im.add_theme_constant_override("margin_top", 3)
	im.add_theme_constant_override("margin_right", 4)
	im.add_theme_constant_override("margin_bottom", 3)
	insp.add_child(im)
	var iv := VBoxContainer.new()
	iv.add_theme_constant_override("separation", 2)
	im.add_child(iv)
	lbl_insp_name = Label.new()
	lbl_insp_name.add_theme_font_size_override("font_size", 5)
	lbl_insp_name.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_insp_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_name.text = "Núcleo do Hatsu"
	iv.add_child(lbl_insp_name)
	lbl_insp_body = Label.new()
	lbl_insp_body.add_theme_font_size_override("font_size", 4)
	lbl_insp_body.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95))
	lbl_insp_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_insp_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lbl_insp_body.text = "Escolha o raio da sua categoria e gaste o saldo."
	iv.add_child(lbl_insp_body)
	btn_alloc = Button.new()
	btn_alloc.text = "Alocar / Remover"
	btn_alloc.add_theme_font_size_override("font_size", 4)
	btn_alloc.pressed.connect(_on_alloc_selected)
	iv.add_child(btn_alloc)

	lbl_tip = Label.new()
	lbl_tip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	lbl_tip.offset_top = -36
	lbl_tip.add_theme_font_size_override("font_size", 4)
	lbl_tip.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	lbl_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_tip.text = "Arraste · Zoom · Clique gasta pts · Anel 3 exige Lv+Mastery — maximizar é raro"
	add_child(lbl_tip)


func _on_pts(n: int) -> void:
	if lbl_points != null:
		var cat_n := "—"
		if tree != null and tree.primary_category >= 0:
			cat_n = HatsuManager.obter_nome_categoria(tree.primary_category as HatsuData.Categoria)
		var bond_ch: int = EffectTree.obter_bond_chapter(tree.bond_uses if tree else 0)
		var bond_t: String = EffectTree.bond_titulo(bond_ch)
		lbl_points.text = "Saldo: %d  |  %d/%d  |  %s  |  M%.0f  |  %s" % [
			n,
			tree.budget_spent if tree else 0,
			tree.budget_total if tree else 0,
			cat_n,
			tree.mastery_level if tree else 0.0,
			bond_t
		]
	_refresh_confirm_btn()
	queue_redraw()


func _refresh_confirm_btn() -> void:
	if btn_ok == null or tree == null:
		return
	var ok_primary := tree.tem_compromisso_categoria()
	btn_ok.disabled = not ok_primary
	btn_ok.modulate = Color(0.45, 1.0, 0.6) if ok_primary else Color(0.55, 0.55, 0.55)
	btn_ok.tooltip_text = "OK" if ok_primary else "Aloque ao menos o Marco da sua categoria (ou outro raio)"


func _on_confirm() -> void:
	if tree == null or not tree.tem_compromisso_categoria():
		if lbl_tip != null:
			lbl_tip.text = "Comprometa um Marco de categoria antes de confirmar."
		return
	confirmado.emit(tree)


func _on_alloc_selected() -> void:
	if selected == &"" or tree == null:
		return
	_try_toggle(selected)


func _process(delta: float) -> void:
	_fx_t += delta
	queue_redraw()


func _world_to_screen(p: Vector2) -> Vector2:
	var center := size * 0.5
	return center + (p + pan) * zoom


func _screen_to_world(p: Vector2) -> Vector2:
	var center := size * 0.5
	return (p - center) / maxf(zoom, 0.05) - pan


func _draw() -> void:
	if _bg != null:
		draw_texture_rect(_bg, Rect2(Vector2.ZERO, size), false, Color(0.55, 0.55, 0.7, 1.0))
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.04, 0.1, 1.0))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.06, 0.35))

	if tree == null:
		return

	_draw_spoke_labels()

	# Arestas
	for nid in tree.nodes.keys():
		var def: Dictionary = tree.nodes[nid]
		var from_pos: Vector2 = _world_to_screen(def.get("pos", Vector2.ZERO))
		for pre in def.get("prereqs", []):
			if not tree.nodes.has(pre):
				continue
			var to_pos: Vector2 = _world_to_screen(tree.nodes[pre].get("pos", Vector2.ZERO))
			var both: bool = tree.allocated.get(nid, false) and tree.allocated.get(pre, false)
			var on_path: bool = _path_hl.has(nid) and _path_hl.has(pre)
			var col: Color
			var w: float
			if both:
				col = Color(1.0, 0.55, 0.2, 0.95)
				w = 2.2
			elif on_path:
				col = Color(0.85, 0.55, 1.0, 0.75)
				w = 1.6
			else:
				col = Color(0.35, 0.32, 0.4, 0.55)
				w = 1.0
			draw_line(from_pos, to_pos, col, w)
			if both:
				_draw_aura_flow(from_pos, to_pos, Color(1.0, 0.7, 0.35, 0.55))

	# Nós
	for nid in tree.nodes.keys():
		_draw_node(nid)


func _draw_spoke_labels() -> void:
	var font := ThemeDB.fallback_font
	if font == null or zoom < 0.55:
		return
	var labels := [
		{"cat": int(HatsuData.Categoria.INTENSIFICACAO), "nome": "Intensificação", "ang": -90.0},
		{"cat": int(HatsuData.Categoria.EMISSAO), "nome": "Emissão", "ang": -30.0},
		{"cat": int(HatsuData.Categoria.TRANSFORMACAO), "nome": "Transformação", "ang": 30.0},
		{"cat": int(HatsuData.Categoria.CONJURACAO), "nome": "Conjuração", "ang": 90.0},
		{"cat": int(HatsuData.Categoria.MANIPULACAO), "nome": "Manipulação", "ang": 150.0},
		{"cat": int(HatsuData.Categoria.ESPECIALIZACAO), "nome": "Especialização", "ang": 210.0},
	]
	for L in labels:
		var ang := deg_to_rad(float(L["ang"]))
		var pos := _world_to_screen(Vector2(cos(ang), sin(ang)) * 320.0)
		var primary := tree != null and tree.primary_category == int(L["cat"])
		var col := Color(1.0, 0.85, 0.35, 0.95) if primary else Color(0.75, 0.8, 0.95, 0.7)
		draw_string(font, pos + Vector2(-20, 0), str(L["nome"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 4, col)


func _draw_aura_flow(from_s: Vector2, to_s: Vector2, col: Color) -> void:
	var dir := to_s - from_s
	var len_v := dir.length()
	if len_v < 4.0:
		return
	var n := dir / len_v
	var t := fmod(_fx_t * 40.0, len_v)
	var p := from_s + n * t
	draw_circle(p, 2.0, col)


func _draw_node(nid: StringName) -> void:
	var def: Dictionary = tree.nodes[nid]
	var pos: Vector2 = _world_to_screen(def.get("pos", Vector2.ZERO))
	var kind: int = int(def.get("kind", 0))
	var r: float = DB.node_radius(kind) * zoom
	var allocated: bool = tree.allocated.get(nid, false)
	var can := bool(tree.pode_alocar(nid).get("ok", false))
	var base_col: Color = def.get("cor", Color(0.7, 0.75, 0.9))
	var fill: Color
	var border: Color
	var glow_a := 0.0
	if allocated:
		fill = base_col.lerp(Color(0.95, 0.85, 0.45), 0.25)
		fill.a = 0.98
		border = Color(1.0, 0.86, 0.32)
		glow_a = 0.28
	elif can:
		var pulse := 0.5 + 0.5 * sin(_fx_t * 3.6)
		fill = Color(0.10, 0.20, 0.16, 0.94)
		border = Color(0.35, 1.0, 0.55, 0.65 + 0.35 * pulse)
		glow_a = 0.12 + 0.16 * pulse
	else:
		fill = Color(0.12, 0.1, 0.14, 0.88)
		border = Color(0.28, 0.24, 0.32, 0.55)

	if _path_hl.has(nid) and not allocated:
		border = Color(0.85, 0.55, 1.0, 0.9)
		glow_a = maxf(glow_a, 0.16)

	draw_circle(pos + Vector2(1.2, 1.6) * zoom, r * 1.05, Color(0, 0, 0, 0.4))
	if glow_a > 0.01:
		draw_circle(pos, r * 1.45, Color(border.r, border.g, border.b, glow_a))

	match kind:
		DB.NodeKind.HUB:
			draw_circle(pos, r, fill)
			draw_arc(pos, r, 0.0, TAU, 28, border, 2.0)
			draw_arc(pos, r * 0.65, 0.0, TAU, 20, border * Color(1, 1, 1, 0.6), 1.0)
		DB.NodeKind.SMALL:
			draw_circle(pos, r, fill)
			draw_arc(pos, r, 0.0, TAU, 20, border, 1.4)
		DB.NodeKind.MAJOR:
			_draw_poly(pos, r, 8, fill, border, 1.8)
		DB.NodeKind.KEYSTONE:
			var kp := 0.5 + 0.5 * sin(_fx_t * 2.4)
			if allocated or can:
				draw_arc(pos, r * (1.25 + 0.08 * kp), 0.0, TAU, 36, Color(0.4, 0.9, 1.0, 0.3), 2.0)
			_draw_poly(pos, r, 6, fill, border, 2.2)
			_draw_poly(pos, r * 0.55, 6, fill.darkened(0.25), border * 0.8, 1.0)
		_:
			draw_circle(pos, r, fill)

	if zoom > 0.45:
		_draw_icon(nid, def, pos, r, allocated, can)

	if nid == hovered:
		draw_arc(pos, r + 4.0, 0.0, TAU, 28, Color(1, 1, 1, 0.85), 1.6)
	if nid == selected:
		var sp := 0.5 + 0.5 * sin(_fx_t * 4.0)
		draw_arc(pos, r + 6.0 + sp, 0.0, TAU, 32, HunterUIStyle.COLOR_GOLD, 2.0)


func _draw_poly(pos: Vector2, radius: float, sides: int, fill_col: Color, border_col: Color, width: float) -> void:
	var pts := PackedVector2Array()
	for i in range(sides):
		var a := -PI * 0.5 + TAU * float(i) / float(sides)
		pts.append(pos + Vector2(cos(a), sin(a)) * radius)
	draw_colored_polygon(pts, fill_col)
	for i in range(sides):
		draw_line(pts[i], pts[(i + 1) % sides], border_col, width)


func _draw_icon(nid: StringName, def: Dictionary, pos: Vector2, radius: float, allocated: bool, can: bool) -> void:
	var a := 1.0 if allocated else (0.88 if can else 0.4)
	var icon_r := radius * 0.72
	var dst := Rect2(pos - Vector2(icon_r, icon_r), Vector2(icon_r * 2, icon_r * 2))
	draw_circle(pos, icon_r * 0.9, Color(0.04, 0.03, 0.02, 0.5 * a))
	var kind: int = int(def.get("kind", 0))
	var cat: int = int(def.get("categoria", -1))
	if kind == DB.NodeKind.SMALL and _tex_small_icons != null:
		var cols := 12
		var cell_w := int(_tex_small_icons.get_width() / float(cols))
		var cell_h := _tex_small_icons.get_height()
		var idx := int(def.get("icon", absi(hash(nid)) % cols))
		var src := Rect2((idx % cols) * cell_w, 0, cell_w, cell_h)
		draw_texture_rect_region(_tex_small_icons, dst, src, Color(1, 1, 1, a))
		return
	if _tex_nen_icons != null and cat >= 0:
		var cols2 := 6
		var cw := int(_tex_nen_icons.get_width() / float(cols2))
		var ch := _tex_nen_icons.get_height()
		# Ordem visual do atlas ≈ Intensificação, Transformação, Emissão, Conjuração, Manipulação, Especialização
		var atlas_idx := _cat_to_atlas(cat)
		var src2 := Rect2(atlas_idx * cw, 0, cw, ch)
		draw_texture_rect_region(_tex_nen_icons, dst, src2, Color(1, 1, 1, a))
	else:
		draw_circle(pos, maxf(1.2, radius * 0.22), Color(0.95, 0.88, 0.55, a))


func _cat_to_atlas(cat: int) -> int:
	match cat:
		int(HatsuData.Categoria.INTENSIFICACAO): return 0
		int(HatsuData.Categoria.TRANSFORMACAO): return 1
		int(HatsuData.Categoria.EMISSAO): return 2
		int(HatsuData.Categoria.CONJURACAO): return 3
		int(HatsuData.Categoria.MANIPULACAO): return 4
		int(HatsuData.Categoria.ESPECIALIZACAO): return 5
		_: return 0


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom = clampf(zoom * 1.1, 0.35, 2.4)
			queue_redraw()
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom = clampf(zoom / 1.1, 0.35, 2.4)
			queue_redraw()
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_MIDDLE or mb.button_index == MOUSE_BUTTON_RIGHT:
			dragging = mb.pressed
			drag_start = mb.position
			pan_start = pan
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				var nid := _pick_node(mb.position)
				if nid == &"":
					dragging = true
					drag_start = mb.position
					pan_start = pan
				else:
					_try_click(mb.position)
				accept_event()
			else:
				dragging = false
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if dragging:
			pan = pan_start + (mm.position - drag_start) / maxf(zoom, 0.05)
			queue_redraw()
		else:
			_update_hover(mm.position)


func _update_hover(screen_pos: Vector2) -> void:
	hovered = _pick_node(screen_pos)
	if hovered != &"" and tree != null and tree.nodes.has(hovered):
		var def: Dictionary = tree.nodes[hovered]
		var cost: int = tree.obter_custo_efetivo(hovered)
		var st := "ALOCADO" if tree.allocated.get(hovered, false) else ("DISPONÍVEL (%d pts)" % cost if tree.pode_alocar(hovered).get("ok", false) else "BLOQUEADO")
		lbl_tip.text = "%s — %s · %s" % [str(def.get("nome", "")), st, str(def.get("desc", ""))]
	queue_redraw()


func _pick_node(screen_pos: Vector2) -> StringName:
	if tree == null:
		return &""
	# Ignora cliques sob o inspetor direito
	if screen_pos.x > size.x - 110.0 and screen_pos.y > 24.0 and screen_pos.y < size.y - 36.0:
		return &""
	var best: StringName = &""
	var best_d := 9999.0
	for nid in tree.nodes.keys():
		var def: Dictionary = tree.nodes[nid]
		var p: Vector2 = _world_to_screen(def.get("pos", Vector2.ZERO))
		var r: float = DB.node_radius(int(def.get("kind", 0))) * zoom + 4.0
		var d: float = p.distance_to(screen_pos)
		if d <= r and d < best_d:
			best_d = d
			best = nid
	return best


func _try_click(screen_pos: Vector2) -> void:
	var nid := _pick_node(screen_pos)
	if nid == &"":
		return
	selected = nid
	_rebuild_path(selected)
	_refresh_inspector()
	_try_toggle(nid)


func _try_toggle(nid: StringName) -> void:
	if tree == null:
		return
	if tree.allocated.get(nid, false):
		tree.desfazer_folha(nid)
	else:
		var ok := tree.alocar(nid)
		if not ok and lbl_tip != null:
			var reason: String = str(tree.pode_alocar(nid).get("reason", "falhou"))
			lbl_tip.text = "Não alocou: %s" % reason
	_rebuild_path(selected)
	_refresh_inspector()
	_refresh_confirm_btn()
	queue_redraw()


func _rebuild_path(nid: StringName) -> void:
	_path_hl.clear()
	if tree == null or not tree.nodes.has(nid):
		return
	var stack: Array[StringName] = [nid]
	while not stack.is_empty():
		var cur: StringName = stack.pop_back()
		if _path_hl.has(cur):
			continue
		_path_hl[cur] = true
		var def: Dictionary = tree.nodes.get(cur, {})
		for pre in def.get("prereqs", []):
			stack.append(pre)


func _refresh_inspector() -> void:
	if lbl_insp_name == null or tree == null or not tree.nodes.has(selected):
		return
	var def: Dictionary = tree.nodes[selected]
	var cost: int = tree.obter_custo_efetivo(selected)
	var allocated: bool = tree.allocated.get(selected, false)
	var can := tree.pode_alocar(selected)
	lbl_insp_name.text = str(def.get("nome", "?"))
	var st := "ALOCADO" if allocated else ("DISPONÍVEL" if can.get("ok", false) else "BLOQUEADO")
	var fx_txt := ""
	var fx: Dictionary = def.get("effects", {})
	for k in fx.keys():
		if k == "core":
			continue
		fx_txt += "\n• %s: %s" % [str(k), str(fx[k])]
	var ring: int = int(def.get("ring", 0))
	var ring_n: String = DB.ring_label(ring)
	var gate := tree.gate_anel(ring) if tree != null else {"ok": true}
	var gate_txt := ""
	if not allocated and not can.get("ok", false):
		gate_txt = "\n🔒 %s" % str(can.get("reason", gate.get("reason", "")))
	lbl_insp_body.text = "%s · %s · custo %d\n%s%s%s" % [st, ring_n, cost, str(def.get("desc", "")), fx_txt, gate_txt]
	if btn_alloc != null:
		btn_alloc.text = "Remover folha" if allocated else ("Alocar (%d)" % cost)
		btn_alloc.disabled = selected == &"hx_center" or (not allocated and not can.get("ok", false))
