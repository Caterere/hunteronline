class_name BlacklistHuntBoardUI
extends CanvasLayer

# Quadro de Caça Blacklist (A7) — open hunt + pistas.

var lbl_status: Label
var lbl_clue: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 15
	visible = false
	_build()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	_refresh()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.72)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 280)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.06, 0.08, 0.97)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.75, 0.15, 0.2, 1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(m, 10)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	margin.add_child(root)

	var title := Label.new()
	title.text = "☠️ QUADRO BLACKLIST — OPEN HUNT"
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	lbl_status = Label.new()
	lbl_status.add_theme_font_size_override("font_size", 8)
	lbl_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(lbl_status)

	lbl_clue = Label.new()
	lbl_clue.add_theme_font_size_override("font_size", 8)
	lbl_clue.add_theme_color_override("font_color", Color(0.85, 0.8, 0.55, 1))
	lbl_clue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(lbl_clue)

	var row := HBoxContainer.new()
	root.add_child(row)

	var btn_clue := Button.new()
	btn_clue.text = "Investigar pista"
	btn_clue.pressed.connect(_on_clue)
	row.add_child(btn_clue)

	var btn_start := Button.new()
	btn_start.text = "Iniciar caça"
	btn_start.pressed.connect(_on_start)
	row.add_child(btn_start)

	var btn_rotate := Button.new()
	btn_rotate.text = "Rotacionar alvo"
	btn_rotate.pressed.connect(_on_rotate)
	row.add_child(btn_rotate)

	var btn_close := Button.new()
	btn_close.text = "Fechar"
	btn_close.pressed.connect(fechar)
	root.add_child(btn_close)


func _refresh() -> void:
	if BlacklistOpenHuntSystem == null:
		lbl_status.text = "Sistema indisponível."
		return
	var snap: Dictionary = BlacklistOpenHuntSystem.get_hunt_snapshot()
	var t: Dictionary = snap.get("target", {})
	lbl_status.text = (
		"Alvo: %s (Rank %s)\nRegião: %s | Nv.%d\nPistas: %d | Localização: %s\nCaça ativa: %s | Caçadores: %d | HP: %d | Fase: %d"
		% [
			str(t.get("name", "?")),
			str(t.get("rank", "?")),
			str(t.get("region", "?")),
			int(t.get("level", 0)),
			int(snap.get("clue_tier", 0)),
			"REVELADA" if bool(snap.get("location_revealed", false)) else "oculta",
			"SIM" if bool(snap.get("hunt_active", false)) else "não",
			int(snap.get("hunters", 0)),
			int(snap.get("hp", 0)),
			int(snap.get("phase", 1)),
		]
	)
	var clues: Array = t.get("clues", [])
	var tier: int = int(snap.get("clue_tier", 0))
	if tier <= 0 or clues.is_empty():
		lbl_clue.text = "Nenhuma pista coletada. Fale com informantes ou investigue."
	else:
		lbl_clue.text = "Última pista: %s" % str(clues[mini(clues.size(), tier) - 1])


func _on_clue() -> void:
	if BlacklistOpenHuntSystem != null:
		BlacklistOpenHuntSystem.discover_clue(1)
	_refresh()


func _on_start() -> void:
	if BlacklistOpenHuntSystem == null:
		return
	var res: Dictionary = BlacklistOpenHuntSystem.start_hunt()
	if bool(res.get("ok", false)):
		BlacklistOpenHuntSystem.join_hunt(1, "local")
	_refresh()


func _on_rotate() -> void:
	if BlacklistOpenHuntSystem != null:
		BlacklistOpenHuntSystem.rotate_daily_target()
	_refresh()
