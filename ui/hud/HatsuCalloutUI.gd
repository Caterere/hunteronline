class_name HatsuCalloutUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - DRAMATIC HATSU CALLOUT UI
# ============================================================
#
# Pipeline de Ativação Dramática de Hatsu:
# - Flash de aura ao redor do usuário
# - Banner cinematográfico com o nome da técnica em tipografia HxH
# - Subtítulo temático da categoria de Nen ou citação
# - Efeito sonoro característico de ativação
# - Pós-efeito de tremor de câmera
# ============================================================

var _callout_panel: PanelContainer
var _lbl_categoria: Label
var _lbl_nome_hatsu: Label
var _lbl_subtitulo: Label
var _active_tween: Tween = null


func _ready() -> void:
	layer = 120 # Acima do HUD normal
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_ui()
	if EventBus != null and not EventBus.hatsu_dramatic_callout_requested.is_connected(_on_hatsu_callout_requested):
		EventBus.hatsu_dramatic_callout_requested.connect(_on_hatsu_callout_requested)


func _construir_ui() -> void:
	_callout_panel = PanelContainer.new()
	_callout_panel.custom_minimum_size = Vector2(340, 56)
	_callout_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_callout_panel.offset_top = 28
	_callout_panel.offset_bottom = 84
	_callout_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_callout_panel.modulate.a = 0.0
	_callout_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.08, 0.88)
	style.border_color = Color(1.0, 0.85, 0.25, 0.95)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 0
	style.border_width_right = 0
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	style.content_margin_left = 12
	style.content_margin_right = 12
	_callout_panel.add_theme_stylebox_override("panel", style)
	add_child(_callout_panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 1)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_callout_panel.add_child(vbox)

	_lbl_categoria = Label.new()
	_lbl_categoria.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_categoria.add_theme_font_size_override("font_size", 9)
	_lbl_categoria.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))
	_lbl_categoria.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_lbl_categoria.add_theme_constant_override("outline_size", 1)
	_lbl_categoria.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_lbl_categoria)

	_lbl_nome_hatsu = Label.new()
	_lbl_nome_hatsu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_nome_hatsu.add_theme_font_size_override("font_size", 16)
	_lbl_nome_hatsu.add_theme_color_override("font_color", Color(1.0, 0.92, 0.35))
	_lbl_nome_hatsu.add_theme_color_override("font_outline_color", Color(0.08, 0.02, 0.02, 1))
	_lbl_nome_hatsu.add_theme_constant_override("outline_size", 3)
	_lbl_nome_hatsu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_lbl_nome_hatsu)

	_lbl_subtitulo = Label.new()
	_lbl_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_subtitulo.add_theme_font_size_override("font_size", 8)
	_lbl_subtitulo.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	_lbl_subtitulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_lbl_subtitulo)


func _on_hatsu_callout_requested(user_node: Node, hatsu_nome: String, subtitle: String, cor_aura: Color) -> void:
	exibir_callout(user_node, hatsu_nome, subtitle, cor_aura)


func exibir_callout(user_node: Node, hatsu_nome: String, subtitle: String = "", cor_aura: Color = Color(0.8, 0.4, 1.0)) -> void:
	if _callout_panel == null:
		return

	# 1. Flash de Aura ao redor do usuário
	if user_node != null and user_node is Node2D and is_instance_valid(user_node):
		CombatImpactEffect.spawn_aura_burst(user_node, user_node.global_position, cor_aura)

	# 2. SFX de ativação
	if AudioManager != null:
		AudioManager.tocar_sfx_tipo("hatsu_cast", 1.1)

	# 3. Tremor de câmera dramático
	if EventBus != null:
		EventBus.emit_camera_shake(0.35, 0.22)

	# 4. Atualizar textos
	_lbl_categoria.text = "◆ NEN HATSU ACTIVATION ◆"
	_lbl_categoria.add_theme_color_override("font_color", cor_aura)
	_lbl_nome_hatsu.text = hatsu_nome.to_upper()
	_lbl_subtitulo.text = subtitle if not subtitle.is_empty() else "Técnica Secreta de Combate"
	_lbl_subtitulo.visible = not _lbl_subtitulo.text.is_empty()

	# Atualizar borda com cor da aura
	var style = _callout_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style != null:
		style.border_color = cor_aura

	# 5. Animação dramática de Pop-in / Hold / Fade-out
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()

	_callout_panel.modulate.a = 0.0
	_callout_panel.scale = Vector2(1.15, 1.15)
	_callout_panel.pivot_offset = _callout_panel.size * 0.5

	_active_tween = create_tween()
	_active_tween.set_parallel(true)
	_active_tween.tween_property(_callout_panel, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(_callout_panel, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_active_tween.set_parallel(false)
	_active_tween.tween_interval(0.75)
	_active_tween.tween_property(_callout_panel, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
