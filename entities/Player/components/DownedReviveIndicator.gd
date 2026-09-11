class_name DownedReviveIndicator
extends Node2D

## Indicador compacto acima de caçador desmaiado: "DESMAIADO" + "[E] Reviver".
## Tamanho próximo ao sprite do player (~48px), flutuando acima da cabeça.

const LABEL_WIDTH := 56.0

var _panel: PanelContainer = null
var _lbl_status: Label = null
var _lbl_hint: Label = null
var _visible_for_allies: bool = true


func _ready() -> void:
	z_index = 20
	_build_ui()
	visible = false


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "PromptPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.custom_minimum_size = Vector2(LABEL_WIDTH, 18)
	_panel.position = Vector2(-LABEL_WIDTH * 0.5, -42.0)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.82)
	style.border_color = Color(0.85, 0.25, 0.25, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 3
	style.content_margin_right = 3
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	_panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_panel.add_child(vbox)

	_lbl_status = Label.new()
	_lbl_status.text = "DESMAIADO"
	_lbl_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_status.add_theme_font_size_override("font_size", 4)
	_lbl_status.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
	vbox.add_child(_lbl_status)

	_lbl_hint = Label.new()
	_lbl_hint.text = "Aperte [E] reviver"
	_lbl_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_hint.add_theme_font_size_override("font_size", 3)
	_lbl_hint.add_theme_color_override("font_color", Color(0.95, 0.9, 0.55))
	vbox.add_child(_lbl_hint)

	add_child(_panel)


func show_for_ally(show_hint: bool = true) -> void:
	if _lbl_hint != null:
		_lbl_hint.visible = show_hint
		_lbl_hint.text = "[E] Reviver" if show_hint else ""
	if _lbl_status != null:
		_lbl_status.text = "DESMAIADO"
	visible = true


func show_self_downed() -> void:
	## Local player vê status sem hint de E (ele não se revive).
	if _lbl_hint != null:
		_lbl_hint.visible = true
		_lbl_hint.text = "Aguardando..."
		_lbl_hint.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	if _lbl_status != null:
		_lbl_status.text = "DESMAIADO"
	visible = true


func hide_prompt() -> void:
	visible = false


func _process(_delta: float) -> void:
	if not visible or _panel == null:
		return
	# Leve flutuação
	var t := Time.get_ticks_msec() * 0.004
	_panel.position.y = -42.0 + sin(t) * 1.5
