class_name HatsuEffectTreeUI
extends Control

# ============================================================
# Hatsu Creator — árvore radial tematizada (estilo constelação)
# ============================================================
# Compacta (~60 nós), pan/zoom, pontos vindos das restrições.
# ============================================================

const EffectTree = preload("res://scripts/systems/hatsu/HatsuEffectTree.gd")
const DB = preload("res://scripts/systems/hatsu/HatsuEffectTreeDatabase.gd")

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
var _fx_t: float = 0.0

var lbl_points: Label
var lbl_tip: Label
var btn_ok: Button
var btn_back: Button


func setup(effect_tree: HatsuEffectTree) -> void:
	tree = effect_tree
	if tree != null and not tree.pontos_alterados.is_connected(_on_pts):
		tree.pontos_alterados.connect(_on_pts)
	_on_pts(tree.obter_saldo() if tree else 0)
	queue_redraw()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_bg = load("res://assets/sprites/ui/nen_skill_tree_bg.png") as Texture2D
	_build_chrome()
	queue_redraw()


func _build_chrome() -> void:
	var top := PanelContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.custom_minimum_size = Vector2(0, 22)
	add_child(top)
	var hb := HBoxContainer.new()
	top.add_child(hb)
	lbl_points = Label.new()
	lbl_points.add_theme_font_size_override("font_size", 5)
	lbl_points.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
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
	btn_ok.pressed.connect(func(): confirmado.emit(tree))
	hb.add_child(btn_ok)

	lbl_tip = Label.new()
	lbl_tip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	lbl_tip.offset_top = -36
	lbl_tip.add_theme_font_size_override("font_size", 4)
	lbl_tip.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	lbl_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_tip.text = "Arraste para navegar · Scroll zoom · Clique para gastar pontos no raio da sua categoria"
	add_child(lbl_tip)


func _on_pts(n: int) -> void:
	if lbl_points != null:
		lbl_points.text = "Saldo: %d pts  |  gastos: %d/%d" % [
			n,
			tree.budget_spent if tree else 0,
			tree.budget_total if tree else 0
		]
	queue_redraw()


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
	# Fundo cósmico
	if _bg != null:
		draw_texture_rect(_bg, Rect2(Vector2.ZERO, size), false, Color(0.55, 0.55, 0.7, 1.0))
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.04, 0.1, 1.0))
	# vinheta
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.06, 0.35))

	if tree == null:
		return

	# Arestas
	for nid in tree.nodes.keys():
		var def: Dictionary = tree.nodes[nid]
		var from_pos: Vector2 = _world_to_screen(def.get("pos", Vector2.ZERO))
		for pre in def.get("prereqs", []):
			if not tree.nodes.has(pre):
				continue
			var to_pos: Vector2 = _world_to_screen(tree.nodes[pre].get("pos", Vector2.ZERO))
			var both: bool = tree.allocated.get(nid, false) and tree.allocated.get(pre, false)
			var col := Color(1.0, 0.55, 0.2, 0.95) if both else Color(0.35, 0.32, 0.4, 0.55)
			draw_line(from_pos, to_pos, col, 2.0 if both else 1.0)

	# Nós
	for nid in tree.nodes.keys():
		var def: Dictionary = tree.nodes[nid]
		var pos: Vector2 = _world_to_screen(def.get("pos", Vector2.ZERO))
		var kind: int = int(def.get("kind", 0))
		var r: float = DB.node_radius(kind) * zoom
		var allocated: bool = tree.allocated.get(nid, false)
		var can := tree.pode_alocar(nid).get("ok", false)
		var base_col: Color = def.get("cor", Color(0.7, 0.75, 0.9))
		var fill: Color
		if allocated:
			fill = base_col.lightened(0.15)
		elif can:
			var pulse := 0.55 + 0.25 * sin(_fx_t * 3.0)
			fill = Color(base_col.r, base_col.g, base_col.b, pulse)
		else:
			fill = Color(0.2, 0.2, 0.25, 0.85)
		draw_circle(pos, r + 2.0, Color(0, 0, 0, 0.55))
		draw_circle(pos, r, fill)
		if nid == selected or nid == hovered:
			draw_arc(pos, r + 3.0, 0.0, TAU, 24, Color(1.0, 0.9, 0.4, 0.95), 1.5)


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
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_try_click(mb.position)
			accept_event()
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
		lbl_tip.text = "%s — %s\n%s" % [str(def.get("nome", "")), st, str(def.get("desc", ""))]
	queue_redraw()


func _pick_node(screen_pos: Vector2) -> StringName:
	if tree == null:
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
	if tree == null:
		return
	if tree.allocated.get(nid, false):
		# clique em folha alocada = desfaz
		tree.desfazer_folha(nid)
	else:
		var ok := tree.alocar(nid)
		if not ok and lbl_tip != null:
			var reason: String = str(tree.pode_alocar(nid).get("reason", "falhou"))
			lbl_tip.text = "Não alocou: %s" % reason
	queue_redraw()
