class_name TutorialOverlayUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - TUTORIAL OVERLAY & ONBOARDING UI
# ============================================================
#
# Painel flutuante elegante, responsivo e temático estilo HxH
# para instruções em tempo real, checklists de ação e tutoriais contextuais.
#
# ============================================================

var panel_card: PanelContainer
var lbl_instrutor: Label
var lbl_titulo: Label
var lbl_instrucao: Label
var lbl_meta: Label
var progress_bar: ProgressBar
var btn_skip: Button

# Modal Contextual / Confirmação
var modal_contextual: PanelContainer
var lbl_modal_titulo: Label
var lbl_modal_msg: Label
var btn_modal_ok: Button
var btn_modal_cancel: Button
var _callback_modal_ok: Callable
var _callback_modal_cancel: Callable


func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_ui()
	_conectar_tutorial_manager()
	visible = false


func _construir_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# --- PAINEL DO TUTORIAL GUIADO (TOPO DIREITO) ---
	panel_card = PanelContainer.new()
	panel_card.name = "TutorialCard"
	panel_card.custom_minimum_size = Vector2(230, 75)
	panel_card.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel_card.position = Vector2(640 - 240, 10)
	panel_card.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	root.add_child(panel_card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	panel_card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	# Header (Instrutor + Skip)
	var hbox_hdr := HBoxContainer.new()
	vbox.add_child(hbox_hdr)

	lbl_instrutor = Label.new()
	lbl_instrutor.text = "🏛️ INSTRUTOR: Elena"
	lbl_instrutor.add_theme_font_size_override("font_size", 4)
	lbl_instrutor.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_instrutor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_hdr.add_child(lbl_instrutor)

	btn_skip = Button.new()
	btn_skip.text = "⏭️ Pular"
	btn_skip.add_theme_font_size_override("font_size", 4)
	btn_skip.pressed.connect(_on_skip_pressed)
	hbox_hdr.add_child(btn_skip)

	# Título da Lição
	lbl_titulo = Label.new()
	lbl_titulo.text = "1. Movimentação Básica"
	lbl_titulo.add_theme_font_size_override("font_size", 5)
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_titulo)

	# Instrução detalhada
	lbl_instrucao = Label.new()
	lbl_instrucao.text = "Use [W, A, S, D] para caminhar."
	lbl_instrucao.add_theme_font_size_override("font_size", 4)
	lbl_instrucao.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_instrucao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_instrucao)

	# Meta / Ação
	lbl_meta = Label.new()
	lbl_meta.text = "● Caminhe pelo cenário (0/60)"
	lbl_meta.add_theme_font_size_override("font_size", 4)
	lbl_meta.add_theme_color_override("font_color", HunterUIStyle.COLOR_BORDER_GREEN)
	vbox.add_child(lbl_meta)

	# Progress Bar
	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(0, 4)
	progress_bar.show_percentage = false
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	vbox.add_child(progress_bar)

	# --- MODAL DE TUTORIAL CONTEXTUAL / CONFIRMAÇÃO ---
	_construir_modal_contextual(root)


func _construir_modal_contextual(parent: Control) -> void:
	modal_contextual = PanelContainer.new()
	modal_contextual.name = "ModalContextual"
	modal_contextual.custom_minimum_size = Vector2(280, 110)
	modal_contextual.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	modal_contextual.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_GOLD_LIGHT, 5))
	modal_contextual.visible = false
	parent.add_child(modal_contextual)

	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 8)
	m.add_theme_constant_override("margin_right", 8)
	m.add_theme_constant_override("margin_top", 6)
	m.add_theme_constant_override("margin_bottom", 6)
	modal_contextual.add_child(m)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	m.add_child(vb)

	lbl_modal_titulo = Label.new()
	lbl_modal_titulo.text = "✨ NOVO CONHECIMENTO DESBLOQUEADO!"
	lbl_modal_titulo.add_theme_font_size_override("font_size", 5)
	lbl_modal_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vb.add_child(lbl_modal_titulo)

	lbl_modal_msg = Label.new()
	lbl_modal_msg.text = "Mensagem explicativa detalhada."
	lbl_modal_msg.add_theme_font_size_override("font_size", 4)
	lbl_modal_msg.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_modal_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(lbl_modal_msg)

	var hb_btn := HBoxContainer.new()
	hb_btn.alignment = BoxContainer.ALIGNMENT_END
	hb_btn.add_theme_constant_override("separation", 4)
	vb.add_child(hb_btn)

	btn_modal_cancel = Button.new()
	btn_modal_cancel.text = "Depois"
	btn_modal_cancel.add_theme_font_size_override("font_size", 4)
	btn_modal_cancel.pressed.connect(_on_modal_cancel_pressed)
	hb_btn.add_child(btn_modal_cancel)

	btn_modal_ok = Button.new()
	btn_modal_ok.text = "Entendido"
	btn_modal_ok.add_theme_font_size_override("font_size", 4)
	btn_modal_ok.pressed.connect(_on_modal_ok_pressed)
	hb_btn.add_child(btn_modal_ok)


func _conectar_tutorial_manager() -> void:
	if TutorialManager != null:
		TutorialManager.etapa_iniciada.connect(_on_etapa_iniciada)
		TutorialManager.etapa_progresso.connect(_on_etapa_progresso)
		TutorialManager.etapa_concluida.connect(_on_etapa_concluida)
		TutorialManager.tutorial_finalizado.connect(_on_tutorial_finalizado)
		TutorialManager.tutorial_pulado.connect(_on_tutorial_pulado)
		TutorialManager.tutorial_contextual_disparado.connect(_on_tutorial_contextual)


func _on_etapa_iniciada(etapa_id: String, titulo: String, instrutor: String, instrucao: String) -> void:
	visible = true
	panel_card.visible = true
	lbl_instrutor.text = "🏛️ " + instrutor
	lbl_titulo.text = titulo
	lbl_instrucao.text = instrucao
	
	match etapa_id:
		"introducao":
			lbl_meta.text = "● Fale com a Recepcionista Elena [E]"
		"movimento":
			lbl_meta.text = "● Caminhe pelo saguão [WASD]: (0/50)"
		"interacao":
			lbl_meta.text = "● Aproxime-se e fale com Elena [E]"
		"menus":
			lbl_meta.text = "● Abra o Hunter Menu [TAB]"
		"inventario":
			lbl_meta.text = "● Acesse a aba Inventário [I]"
		"combate":
			lbl_meta.text = "● Desfira 3 socos rápidos [J/Botão Esq]: (0/3)"
		"status":
			lbl_meta.text = "● Acesse a aba Status [C]"
		"nen_conceito":
			lbl_meta.text = "● Fale com Elena [E] sobre Aura e Nen"
		"conclusao":
			lbl_meta.text = "✅ Siga para o Portal Hunter a Leste!"
		_:
			lbl_meta.text = "● Em andamento..."
	progress_bar.value = 0.0


func _on_etapa_progresso(_etapa_id: String, atual: float, meta: float, texto_acao: String) -> void:
	var pct: float = (atual / max(1.0, meta)) * 100.0
	progress_bar.value = pct
	lbl_meta.text = "● %s (%.0f/%.0f)" % [texto_acao, atual, meta]


func _on_etapa_concluida(_etapa_id: String, _conhecimento: String) -> void:
	progress_bar.value = 100.0
	lbl_meta.text = "✅ Concluído!"


func _on_tutorial_finalizado() -> void:
	panel_card.visible = false
	visible = false


func _on_tutorial_pulado() -> void:
	panel_card.visible = false
	visible = false


func _on_skip_pressed() -> void:
	_exibir_confirmacao_skip()


func _exibir_confirmacao_skip() -> void:
	lbl_modal_titulo.text = "⚠️ Pular Treinamento Inicial?"
	lbl_modal_msg.text = "Tem certeza que deseja pular o tutorial?\nTodos os fundamentos serão registrados no Guia Hunter do menu [TAB]."
	btn_modal_cancel.text = "Não, Continuar"
	btn_modal_ok.text = "Sim, Pular"
	_callback_modal_ok = func():
		modal_contextual.visible = false
		if TutorialManager != null:
			TutorialManager.pular_tutorial()
	_callback_modal_cancel = func():
		modal_contextual.visible = false
	modal_contextual.visible = true


func _on_tutorial_contextual(_tipo: String, titulo: String, msg: String) -> void:
	lbl_modal_titulo.text = titulo
	lbl_modal_msg.text = msg
	btn_modal_cancel.text = "Depois"
	btn_modal_ok.text = "Entendido"
	_callback_modal_ok = func(): modal_contextual.visible = false
	_callback_modal_cancel = func(): modal_contextual.visible = false
	modal_contextual.visible = true


func _on_modal_ok_pressed() -> void:
	if _callback_modal_ok.is_valid():
		_callback_modal_ok.call()
	else:
		modal_contextual.visible = false


func _on_modal_cancel_pressed() -> void:
	if _callback_modal_cancel.is_valid():
		_callback_modal_cancel.call()
	else:
		modal_contextual.visible = false