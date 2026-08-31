class_name NenQuickActionBar
extends Control

# ============================================================
# HUNTER ONLINE - NEN QUICK ACTION BAR (MODIFIER LAYER)
# ============================================================
#
# Barra de Ação Rápida de Nen exibida dinamicamente ao SEGURAR [Q] / [LB]:
# - Permite ativar/desativar técnicas durante o combate sem abrir menus.
# - Mapeia as 8 técnicas de Nen canônicas para teclas rápidas:
#   [1] TEN   [2] REN   [3] ZETSU   [4] GYO
#   [E] KO    [R] EN    [T] KEN     [F] RYU
#   [X] DESATIVAR TUDO
#
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

const TEC_TEN: int = 0
const TEC_REN: int = 1
const TEC_ZETSU: int = 2
const TEC_GYO: int = 3
const TEC_SHU: int = 4
const TEC_KO: int = 5
const TEC_EN: int = 6
const TEC_KEN: int = 7
const TEC_RYU: int = 8
const TEC_OFF: int = -1

var container_tecnicas: HBoxContainer
var tecnica_buttons: Dictionary = {}
var lbl_instrucao: Label

var is_holding_modifier: bool = false
var nen_system: Node = null

const TECNICAS_CONFIG: Array[Dictionary] = [
	{"tecla": "1", "code": KEY_1, "tecnica": TEC_TEN, "nome": "TEN", "desc": "Defesa +40%", "cor": Color(0.3, 0.7, 1.0)},
	{"tecla": "2", "code": KEY_2, "tecnica": TEC_REN, "nome": "REN", "desc": "Alcance & Pressão", "cor": Color(1.0, 0.4, 0.2)},
	{"tecla": "3", "code": KEY_3, "tecnica": TEC_ZETSU, "nome": "ZETSU", "desc": "Furtivo & Regen", "cor": Color(0.4, 1.0, 0.5)},
	{"tecla": "4", "code": KEY_4, "tecnica": TEC_GYO, "nome": "GYO", "desc": "Visão & Crítico", "cor": Color(0.9, 0.8, 0.2)},
	{"tecla": "E", "code": KEY_E, "tecnica": TEC_KO, "nome": "KO", "desc": "+75% Dano / Quebra", "cor": Color(1.0, 0.2, 0.2)},
	{"tecla": "R", "code": KEY_R, "tecnica": TEC_EN, "nome": "EN", "desc": "Percepção Total", "cor": Color(0.7, 0.4, 1.0)},
	{"tecla": "T", "code": KEY_T, "tecnica": TEC_KEN, "nome": "KEN", "desc": "Blindagem Geral", "cor": Color(0.2, 0.9, 0.9)},
	{"tecla": "F", "code": KEY_F, "tecnica": TEC_RYU, "nome": "RYU", "desc": "Fluxo Ofensivo", "cor": Color(1.0, 0.6, 0.1)},
	{"tecla": "X", "code": KEY_X, "tecnica": TEC_OFF, "nome": "OFF", "desc": "Desativar Nen", "cor": Color(0.7, 0.7, 0.7)}
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	modulate.a = 0.0
	visible = false
	_construir_ui()


func _construir_ui() -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 42)
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.offset_left = -160.0
	panel.offset_right = 160.0
	panel.offset_top = -92.0
	panel.offset_bottom = -50.0
	panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_AURA_CYAN, 4))
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	lbl_instrucao = Label.new()
	lbl_instrucao.text = "⚡ NEN QUICK SELECT (SEGURE Q + TECLA)"
	lbl_instrucao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_instrucao.add_theme_font_size_override("font_size", 8)
	lbl_instrucao.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_instrucao)

	container_tecnicas = HBoxContainer.new()
	container_tecnicas.add_theme_constant_override("separation", 2)
	container_tecnicas.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(container_tecnicas)

	for cfg in TECNICAS_CONFIG:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(32, 22)
		btn.text = "[%s]\n%s" % [cfg["tecla"], cfg["nome"]]
		btn.add_theme_font_size_override("font_size", 8)
		HunterUIStyle.aplicar_estilo_botao(btn, cfg["cor"])
		btn.add_theme_color_override("font_color", cfg["cor"])
		btn.pressed.connect(func(): _acionar_tecnica(cfg))
		container_tecnicas.add_child(btn)
		tecnica_buttons[cfg["nome"]] = btn


func _process(_delta: float) -> void:
	if nen_system == null:
		var p = get_tree().get_first_node_in_group("player")
		if p != null:
			nen_system = p.get_node_or_null("NenSystem")

	# Detectar segurar a tecla Q
	var holding_q = Input.is_key_pressed(KEY_Q) or (InputMap.has_action("nen_modifier") and Input.is_action_pressed("nen_modifier"))
	
	# Só ativa se o contexto de gameplay estiver autorizado
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null and not input_ctx.is_gameplay_input_allowed():
		holding_q = false

	# Só ativa se nenhum menu modal estiver aberto
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr != null and ui_mgr.menu_atual_aberto != null and ui_mgr.menu_atual_aberto.visible:
		holding_q = false

	if holding_q != is_holding_modifier:
		is_holding_modifier = holding_q
		_animar_visibilidade(is_holding_modifier)

	if is_holding_modifier:
		_atualizar_destaques_ativos()


func _unhandled_input(event: InputEvent) -> void:
	if not is_holding_modifier:
		return
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null and not input_ctx.is_gameplay_input_allowed():
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	for cfg in TECNICAS_CONFIG:
		if event.keycode == cfg["code"]:
			_acionar_tecnica(cfg)
			get_viewport().set_input_as_handled()
			return


func _acionar_tecnica(cfg: Dictionary) -> void:
	if nen_system == null:
		return

	var tec_id: int = cfg["tecnica"]
	if tec_id == TEC_OFF:
		if nen_system.has_method("desativar_todas_tecnicas"):
			nen_system.desativar_todas_tecnicas()
		if EventBus != null:
			EventBus.emit_toast("🥋 Nen Desativado", Color(0.7, 0.7, 0.7))
	else:
		var ja_ativa: bool = false
		if nen_system.has_method("tecnica_ativa"):
			ja_ativa = nen_system.tecnica_ativa(tec_id)
			
		if ja_ativa:
			if nen_system.has_method("desativar_tecnica"):
				nen_system.desativar_tecnica(tec_id)
			if EventBus != null:
				EventBus.emit_toast("🥋 %s Desativado" % cfg["nome"], Color(0.7, 0.7, 0.7))
		else:
			var ok: bool = false
			if nen_system.has_method("ativar_tecnica"):
				ok = nen_system.ativar_tecnica(tec_id)
			if ok and EventBus != null:
				EventBus.emit_toast("⚡ %s Ativado! (%s)" % [cfg["nome"], cfg["desc"]], cfg["cor"])
	
	_atualizar_destaques_ativos()


func _atualizar_destaques_ativos() -> void:
	if nen_system == null:
		return
	for cfg in TECNICAS_CONFIG:
		var btn: Button = tecnica_buttons.get(cfg["nome"])
		if btn == null: continue
		var tec_id: int = cfg["tecnica"]
		if tec_id != TEC_OFF and nen_system.has_method("tecnica_ativa") and nen_system.tecnica_ativa(tec_id):
			btn.modulate = Color(1.8, 1.8, 1.8, 1.0)
		else:
			btn.modulate = Color(0.8, 0.8, 0.8, 0.9)


func _animar_visibilidade(mostrar: bool) -> void:
	visible = true
	var tween = create_tween()
	var target_alpha = 1.0 if mostrar else 0.0
	tween.tween_property(self, "modulate:a", target_alpha, 0.15)
	if not mostrar:
		tween.tween_callback(_ao_ocultar_completamente)


func _ao_ocultar_completamente() -> void:
	if not is_holding_modifier:
		visible = false