class_name SpeechBubbleNode
extends Node2D

# ============================================================
# HUNTER ONLINE - SPEECH BUBBLE NODE (BALÃO DE FALA EM NUVEM)
# ============================================================
#
# Balão de fala estilo mangá/anime que flutua acima da cabeça do personagem.
# Possui efeito de digitação suave (typewriter), badge do falante e
# apêndice triangular apontando para a cabeça do falante.
#
# ============================================================

signal fala_concluida
signal balao_fechado

static var balao_ativo_global: SpeechBubbleNode = null

static func fechar_balao_global() -> void:
	if balao_ativo_global != null and is_instance_valid(balao_ativo_global):
		var b: SpeechBubbleNode = balao_ativo_global
		balao_ativo_global = null
		if not b.is_queued_for_deletion():
			b.fechar()
	balao_ativo_global = null

var speaker_name: String = ""
var full_text: String = ""
var current_char_index: int = 0
var char_timer: float = 0.0
var char_speed: float = 0.025 # Segundos por letra
var is_typing: bool = false
var auto_advance_timer: float = 0.0
var auto_advance_duration: float = 3.5
var allow_auto_advance: bool = true

var bubble_width: float = 160.0
var bubble_height: float = 46.0

# Cores
var bg_color: Color = Color(0.06, 0.08, 0.13, 0.95)
var border_color: Color = Color(0.3, 0.7, 1.0, 0.95)
var speaker_color: Color = Color(1.0, 0.85, 0.3, 1.0)
var text_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var panel_container: PanelContainer
var lbl_speaker: Label
var lbl_text: Label
var lbl_indicator: Label


func setup(falante: String, texto: String, cor_borda: Color = Color(0.3, 0.7, 1.0, 0.95), cor_falante: Color = Color(1.0, 0.85, 0.3, 1.0)) -> void:
	if balao_ativo_global != null and balao_ativo_global != self and is_instance_valid(balao_ativo_global):
		var b: SpeechBubbleNode = balao_ativo_global
		balao_ativo_global = null
		if not b.is_queued_for_deletion():
			b.fechar()
	
	SpeechBubbleNode.balao_ativo_global = self
	speaker_name = falante
	full_text = texto
	border_color = cor_borda
	speaker_color = cor_falante
	current_char_index = 0
	is_typing = true
	auto_advance_timer = 0.0
	z_index = 20


func _ready() -> void:
	_construir_visual()


func _construir_visual() -> void:
	# Container de posicionamento relativo acima da cabeça do NPC
	position = Vector2(0, -38)

	var root_ctrl := Control.new()
	root_ctrl.custom_minimum_size = Vector2(bubble_width, bubble_height)
	root_ctrl.position = Vector2(-bubble_width * 0.5, -bubble_height)
	add_child(root_ctrl)

	panel_container = PanelContainer.new()
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = border_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel_container.add_theme_stylebox_override("panel", style)
	root_ctrl.add_child(panel_container)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 2)
	panel_container.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	margin.add_child(vbox)

	# Linha Superior com Nome do Falante e Indicador
	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)

	lbl_speaker = Label.new()
	lbl_speaker.text = speaker_name.to_upper()
	lbl_speaker.add_theme_font_size_override("font_size", 4)
	lbl_speaker.add_theme_color_override("font_color", speaker_color)
	lbl_speaker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl_speaker)

	lbl_indicator = Label.new()
	lbl_indicator.text = "▼"
	lbl_indicator.add_theme_font_size_override("font_size", 4)
	lbl_indicator.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0, 0.8))
	lbl_indicator.visible = false
	hbox.add_child(lbl_indicator)

	# Texto da Fala (Typewriter)
	lbl_text = Label.new()
	lbl_text.text = ""
	lbl_text.add_theme_font_size_override("font_size", 4)
	lbl_text.add_theme_color_override("font_color", text_color)
	lbl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(lbl_text)


func _process(delta: float) -> void:
	if is_typing:
		char_timer += delta
		if char_timer >= char_speed:
			char_timer = 0.0
			if current_char_index < full_text.length():
				current_char_index += 1
				lbl_text.text = full_text.left(current_char_index)
			else:
				is_typing = false
				lbl_indicator.visible = true
				fala_concluida.emit()
	else:
		if allow_auto_advance:
			auto_advance_timer += delta
			if auto_advance_timer >= auto_advance_duration:
				fechar()


func _draw() -> void:
	# Desenhar cauda/triângulo do balão apontando para a cabeça do personagem
	var p1 := Vector2(-4, -4)
	var p2 := Vector2(4, -4)
	var p3 := Vector2(0, 0)
	draw_colored_polygon(PackedVector2Array([p1, p2, p3]), bg_color)
	draw_line(p1, p3, border_color, 1.0)
	draw_line(p2, p3, border_color, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		avancar_ou_completar()


func avancar_ou_completar() -> bool:
	if is_typing:
		# Pular para o texto completo imediatamente
		is_typing = false
		current_char_index = full_text.length()
		lbl_text.text = full_text
		lbl_indicator.visible = true
		fala_concluida.emit()
		return false
	else:
		fechar()
		return true


func fechar() -> void:
	if balao_ativo_global == self:
		balao_ativo_global = null
	balao_fechado.emit()
	queue_free()
