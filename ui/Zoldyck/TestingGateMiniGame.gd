class_name TestingGateMiniGame
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - TESTING GATE MINI-GAME (PORTÃO DA TESTAGEM)
# ============================================================
#
# Mini-game do Portão dos Zoldyck na Montanha Kukuroo:
# O jogador precisa acumular toneladas de força (2t a 16t)
# apertando a tecla ESPAÇO repetidamente dentro do tempo limite.
#
# ============================================================

signal portao_aberto()

var panel: PanelContainer
var bar_forca: ProgressBar
var lbl_toneladas: Label
var lbl_timer: Label

var toneladas_acumuladas: float = 0.0
var toneladas_alvo: float = 4.0 # 4 Toneladas (Portão de 2 Folhas)
var tempo_restante: float = 6.0
var ativo: bool = false


func setup(alvo_ton: float = 4.0) -> void:
	toneladas_alvo = alvo_ton
	toneladas_acumuladas = 0.0
	tempo_restante = 6.0
	ativo = true
	visible = true
	get_tree().paused = true


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 17
	visible = false
	_construir_ui()


func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(240, 130)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.20, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.7, 0.7, 0.8, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var lbl_title := Label.new()
	lbl_title.text = "⛩️ PORTÃO DA TESTAGEM — FAMÍLIA ZOLDYCK"
	lbl_title.add_theme_font_size_override("font_size", 6)
	lbl_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_title)

	lbl_toneladas = Label.new()
	lbl_toneladas.text = "Força Aplicada: 0.0t / 4.0t"
	lbl_toneladas.add_theme_font_size_override("font_size", 5)
	lbl_toneladas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_toneladas)

	bar_forca = ProgressBar.new()
	bar_forca.min_value = 0
	bar_forca.max_value = 100
	bar_forca.show_percentage = false
	bar_forca.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(bar_forca)

	lbl_timer = Label.new()
	lbl_timer.text = "Tempo Limite: 6.0s"
	lbl_timer.add_theme_font_size_override("font_size", 4)
	lbl_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_timer)

	var lbl_inst := Label.new()
	lbl_inst.text = "[Pressione ESPAÇO repetidamente para empurrar!]"
	lbl_inst.add_theme_font_size_override("font_size", 4)
	lbl_inst.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1))
	lbl_inst.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_inst)


func _input(event: InputEvent) -> void:
	if not ativo:
		return

	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		get_viewport().set_input_as_handled()
		var bonus_forca: float = float(PlayerData.attributes.get("forca", 10)) * 0.05
		toneladas_acumuladas += 0.35 + bonus_forca
		_atualizar_barras()

		if toneladas_acumuladas >= toneladas_alvo:
			_vencer()


func _process(delta: float) -> void:
	if not ativo:
		return

	tempo_restante -= delta
	lbl_timer.text = "Tempo Limite: %.1fs" % max(0.0, tempo_restante)

	# Decaimento leve de força
	toneladas_acumuladas = max(0.0, toneladas_acumuladas - (delta * 0.4))
	_atualizar_barras()

	if tempo_restante <= 0.0:
		_falhar()


func _atualizar_barras() -> void:
	lbl_toneladas.text = "Força Aplicada: %.1ft / %.1ft" % [toneladas_acumuladas, toneladas_alvo]
	bar_forca.value = clamp((toneladas_acumuladas / toneladas_alvo) * 100.0, 0.0, 100.0)


func _vencer() -> void:
	ativo = false
	visible = false
	get_tree().paused = false
	print("[TestingGate] O Portão da Testagem ABRIU! Você empurrou ", toneladas_alvo, " toneladas!")
	portao_aberto.emit()


func _falhar() -> void:
	ativo = false
	visible = false
	get_tree().paused = false
	print("[TestingGate] Você não teve força suficiente para mover o Portão da Testagem! Treine mais sua Força.")
