class_name CardDuelUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE — UI DE DUELO DE CARTAS GI (S4)
# ============================================================

const CardDuelSystemScript = preload("res://scripts/systems/CardDuelSystem.gd")
const CatalogScript = preload("res://resource/greed_island/GreedIslandCardCatalog.gd")

var duel: CardDuelSystem = null
var lbl_header: Label
var lbl_hp: Label
var lbl_log: Label
var hand_box: VBoxContainer
var difficulty: String = "antokiba"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 16
	visible = false
	duel = CardDuelSystemScript.new()
	_build_ui()


func abrir(diff: String = "antokiba") -> void:
	difficulty = diff
	visible = true
	get_tree().paused = true
	var res: Dictionary = duel.start_from_inventory(difficulty)
	if not bool(res.get("ok", false)):
		lbl_log.text = "Falha ao iniciar: %s" % str(res.get("error", "?"))
	_refresh()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.05, 0.04, 0.88)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 240)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.12, 0.10, 0.97)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.35, 0.85, 0.55, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	for m in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(m, 8)
	for m in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(m, 6)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 4)
	margin.add_child(root)

	lbl_header = Label.new()
	lbl_header.text = "🃏 DUELO DE CARTAS — GREED ISLAND"
	lbl_header.add_theme_font_size_override("font_size", 10)
	lbl_header.add_theme_color_override("font_color", Color(0.45, 1.0, 0.7, 1))
	lbl_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(lbl_header)

	lbl_hp = Label.new()
	lbl_hp.add_theme_font_size_override("font_size", 8)
	lbl_hp.add_theme_color_override("font_color", Color(1, 0.9, 0.4, 1))
	lbl_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(lbl_hp)

	lbl_log = Label.new()
	lbl_log.add_theme_font_size_override("font_size", 6)
	lbl_log.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_log.add_theme_color_override("font_color", Color(0.85, 0.9, 0.85, 1))
	root.add_child(lbl_log)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 120)
	root.add_child(scroll)
	hand_box = VBoxContainer.new()
	hand_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_box.add_theme_constant_override("separation", 2)
	scroll.add_child(hand_box)

	var row := HBoxContainer.new()
	root.add_child(row)
	var btn_restart := Button.new()
	btn_restart.text = "Novo Duelo"
	btn_restart.add_theme_font_size_override("font_size", 7)
	btn_restart.pressed.connect(func(): abrir(difficulty))
	row.add_child(btn_restart)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var btn_close := Button.new()
	btn_close.text = "Sair"
	btn_close.add_theme_font_size_override("font_size", 7)
	btn_close.pressed.connect(fechar)
	row.add_child(btn_close)


func _refresh() -> void:
	if duel == null:
		return
	var snap: Dictionary = duel.snapshot()
	lbl_header.text = "🃏 DUELO vs %s" % str(snap.get("opponent", "?"))
	lbl_hp.text = "Você %d HP  ·  Rival %d HP  ·  Turno %d" % [
		int(snap.get("player_hp", 0)),
		int(snap.get("enemy_hp", 0)),
		int(snap.get("turn", 0)),
	]
	var w := str(snap.get("winner", ""))
	if w == "player":
		lbl_log.text = "VITÓRIA! %s" % str(snap.get("log", ""))
	elif w == "enemy":
		lbl_log.text = "DERROTA. %s" % str(snap.get("log", ""))
	elif w == "draw":
		lbl_log.text = "EMPATE. %s" % str(snap.get("log", ""))
	else:
		lbl_log.text = str(snap.get("log", "Escolha uma carta."))

	for c in hand_box.get_children():
		c.queue_free()
	var hand: Array = snap.get("hand", [])
	var finished := not w.is_empty()
	for i in range(hand.size()):
		var card: Dictionary = hand[i]
		var btn := Button.new()
		btn.text = "#%s %s  ATK%d/DEF%d [%s]" % [
			str(card.get("num", "?")),
			str(card.get("nome", "?")),
			int(card.get("atk", 0)),
			int(card.get("def", 0)),
			str(card.get("kind", "?")),
		]
		btn.add_theme_font_size_override("font_size", 6)
		btn.disabled = finished
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var idx := i
		btn.pressed.connect(func(): _on_play(idx))
		hand_box.add_child(btn)


func _on_play(index: int) -> void:
	var res: Dictionary = duel.play_card_at(index)
	if not bool(res.get("ok", false)):
		lbl_log.text = "Jogada inválida: %s" % str(res.get("error", "?"))
		return
	_refresh()
