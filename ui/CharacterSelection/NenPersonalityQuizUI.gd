class_name NenPersonalityQuizUI
extends Control

# ============================================================
# HUNTER ONLINE — QUESTIONÁRIO DE PERSONALIDADE (CRIAÇÃO)
# Uma pergunta por vez · seed secreta · sem revelar Nen
# ============================================================

signal quiz_concluido(scores: Dictionary, seed_str: String, answer_indices: Array)
signal quiz_cancelado

const QuizScript = preload("res://resource/nen/NenPersonalityQuiz.gd")

var _perguntas: Array[Dictionary] = []
var _indice: int = 0
var _scores: Dictionary = {}
var _respostas: Array = []
var _nome_hunter: String = "Hunter"

var _panel: PanelContainer
var _lbl_progresso: Label
var _lbl_titulo: Label
var _lbl_pergunta: Label
var _lbl_hint: Label
var _opcoes_box: VBoxContainer
var _dots_box: HBoxContainer
var _footer: HBoxContainer
var _btn_continuar: Button
var _lbl_encerramento: Label
var _fase_final: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_perguntas = QuizScript.obter_perguntas()
	_scores = QuizScript.empty_scores()
	_construir_ui()
	_mostrar_pergunta(0)


func configurar(nome_hunter: String) -> void:
	_nome_hunter = nome_hunter.strip_edges()
	if _nome_hunter.is_empty():
		_nome_hunter = "Hunter"


func _construir_ui() -> void:
	for c in get_children():
		c.queue_free()

	# Fundo madeira escura + vinheta
	var bg := ColorRect.new()
	bg.color = HunterUIStyle.COLOR_BG_NAVY
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var veil := ColorRect.new()
	veil.color = Color(0.02, 0.04, 0.06, 0.45)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(520, 360)
	_panel.add_theme_stylebox_override(
		"panel",
		HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 6)
	)
	center.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	# Cabeçalho
	var hdr := HBoxContainer.new()
	vbox.add_child(hdr)

	_lbl_titulo = Label.new()
	_lbl_titulo.text = "PERFIL DO CAÇADOR"
	_lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	HunterUIStyle.aplicar_fonte_licenca(_lbl_titulo, HunterUIStyle.FONT_SIZE_TITLE, HunterUIStyle.COLOR_GOLD_LIGHT)
	hdr.add_child(_lbl_titulo)

	_lbl_progresso = Label.new()
	_lbl_progresso.text = "1 / 5"
	HunterUIStyle.aplicar_fonte_pixel(_lbl_progresso, HunterUIStyle.FONT_SIZE_BODY, HunterUIStyle.COLOR_TEXT_CYAN)
	hdr.add_child(_lbl_progresso)

	var sep := HSeparator.new()
	sep.modulate = HunterUIStyle.COLOR_BORDER_GOLD
	vbox.add_child(sep)

	var lbl_sub := Label.new()
	lbl_sub.text = "Responda com honestidade. Sua natureza permanece em segredo até o Teste da Água."
	lbl_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	HunterUIStyle.aplicar_fonte_pixel(lbl_sub, HunterUIStyle.FONT_SIZE_SMALL, HunterUIStyle.COLOR_TEXT_SECONDARY)
	vbox.add_child(lbl_sub)

	_dots_box = HBoxContainer.new()
	_dots_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_dots_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_dots_box)
	_rebuild_dots()

	_lbl_pergunta = Label.new()
	_lbl_pergunta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_pergunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_pergunta.custom_minimum_size = Vector2(0, 48)
	HunterUIStyle.aplicar_fonte_licenca(_lbl_pergunta, HunterUIStyle.FONT_SIZE_SUBTITLE, HunterUIStyle.COLOR_TEXT_PRIMARY)
	vbox.add_child(_lbl_pergunta)

	_lbl_hint = Label.new()
	_lbl_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel(_lbl_hint, HunterUIStyle.FONT_SIZE_SMALL, HunterUIStyle.COLOR_TEXT_MUTED)
	vbox.add_child(_lbl_hint)

	_opcoes_box = VBoxContainer.new()
	_opcoes_box.add_theme_constant_override("separation", 6)
	_opcoes_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_opcoes_box)

	_lbl_encerramento = Label.new()
	_lbl_encerramento.visible = false
	_lbl_encerramento.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_encerramento.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_encerramento.custom_minimum_size = Vector2(0, 80)
	HunterUIStyle.aplicar_fonte_pixel(_lbl_encerramento, HunterUIStyle.FONT_SIZE_BODY, HunterUIStyle.COLOR_TEXT_SECONDARY)
	vbox.add_child(_lbl_encerramento)

	_footer = HBoxContainer.new()
	_footer.add_theme_constant_override("separation", 10)
	vbox.add_child(_footer)

	var btn_voltar := Button.new()
	btn_voltar.text = "← Voltar"
	btn_voltar.custom_minimum_size = Vector2(110, 28)
	HunterUIStyle.aplicar_fonte_pixel(btn_voltar, HunterUIStyle.FONT_SIZE_BODY, HunterUIStyle.COLOR_TEXT_PRIMARY)
	HunterUIStyle.aplicar_estilo_botao(btn_voltar, HunterUIStyle.COLOR_BORDER_SUBTLE)
	btn_voltar.pressed.connect(_on_voltar)
	_footer.add_child(btn_voltar)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_footer.add_child(spacer)

	_btn_continuar = Button.new()
	_btn_continuar.text = "Continuar →"
	_btn_continuar.visible = false
	_btn_continuar.custom_minimum_size = Vector2(160, 32)
	HunterUIStyle.aplicar_fonte_pixel_bold(_btn_continuar, HunterUIStyle.FONT_SIZE_BODY, HunterUIStyle.COLOR_TEXT_PRIMARY)
	HunterUIStyle.aplicar_estilo_botao(_btn_continuar, HunterUIStyle.COLOR_BORDER_GREEN)
	_btn_continuar.pressed.connect(_on_continuar)
	_footer.add_child(_btn_continuar)


func _rebuild_dots() -> void:
	for c in _dots_box.get_children():
		c.queue_free()
	for i in range(_perguntas.size()):
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(14, 14)
		var style := StyleBoxFlat.new()
		style.corner_radius_top_left = 7
		style.corner_radius_top_right = 7
		style.corner_radius_bottom_right = 7
		style.corner_radius_bottom_left = 7
		if i < _respostas.size():
			style.bg_color = HunterUIStyle.COLOR_HUNTER_GREEN_LIGHT
			style.border_color = HunterUIStyle.COLOR_BORDER_GREEN
		elif i == _indice and not _fase_final:
			style.bg_color = HunterUIStyle.COLOR_GOLD_LIGHT
			style.border_color = HunterUIStyle.COLOR_BORDER_GOLD
		else:
			style.bg_color = HunterUIStyle.COLOR_PANEL_SLOT
			style.border_color = HunterUIStyle.COLOR_BORDER_SUBTLE
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		dot.add_theme_stylebox_override("panel", style)
		_dots_box.add_child(dot)


func _mostrar_pergunta(idx: int) -> void:
	_fase_final = false
	_indice = clampi(idx, 0, _perguntas.size() - 1)
	_btn_continuar.visible = false
	_lbl_encerramento.visible = false
	_opcoes_box.visible = true
	_lbl_pergunta.visible = true
	_lbl_hint.visible = true

	var q: Dictionary = _perguntas[_indice]
	_lbl_progresso.text = "%d / %d" % [_indice + 1, _perguntas.size()]
	_lbl_titulo.text = "PERFIL DO CAÇADOR"
	_lbl_pergunta.text = str(q.get("prompt", ""))
	_lbl_hint.text = str(q.get("hint", ""))
	_rebuild_dots()
	_popular_opcoes(q)


func _popular_opcoes(q: Dictionary) -> void:
	for c in _opcoes_box.get_children():
		c.queue_free()

	var options: Array = q.get("options", [])
	for i in range(options.size()):
		var opt: Dictionary = options[i]
		var btn := Button.new()
		btn.text = str(opt.get("text", ""))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		HunterUIStyle.aplicar_fonte_pixel(btn, HunterUIStyle.FONT_SIZE_BODY, HunterUIStyle.COLOR_TEXT_PRIMARY)
		HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_CYAN)
		var idx := i
		btn.pressed.connect(func(): _responder(idx))
		_opcoes_box.add_child(btn)


func _responder(option_index: int) -> void:
	if _fase_final:
		return
	var q: Dictionary = _perguntas[_indice]
	var options: Array = q.get("options", [])
	if option_index < 0 or option_index >= options.size():
		return

	# Se voltou e responde de novo, reconstrói scores a partir das respostas.
	if _respostas.size() > _indice:
		_respostas[_indice] = option_index
		_respostas = _respostas.slice(0, _indice + 1)
		_recalcular_scores()
	else:
		var opt: Dictionary = options[option_index]
		QuizScript.aplicar_pesos(_scores, opt.get("weights", {}))
		_respostas.append(option_index)

	if AudioManager != null and AudioManager.has_method("tocar_sfx_tipo"):
		AudioManager.tocar_sfx_tipo("ui_click")

	if _indice + 1 < _perguntas.size():
		_mostrar_pergunta(_indice + 1)
	else:
		_mostrar_encerramento()


func _mostrar_encerramento() -> void:
	_fase_final = true
	_opcoes_box.visible = false
	_lbl_pergunta.visible = false
	_lbl_hint.visible = false
	_lbl_encerramento.visible = true
	_btn_continuar.visible = true
	_lbl_progresso.text = "Pronto"
	_lbl_titulo.text = "PERFIL REGISTRADO"
	_lbl_encerramento.text = (
		"Seu perfil de personalidade foi selado, %s.\n\n"
		+ "A natureza da sua aura permanece em segredo.\n"
		+ "Somente o Teste da Água com o Mestre Wing revelará sua afinidade natal."
	) % _nome_hunter
	_rebuild_dots()


func _on_voltar() -> void:
	if _fase_final:
		# Reabre a última pergunta para permitir trocar a 5ª resposta.
		if not _respostas.is_empty():
			_respostas.pop_back()
		_recalcular_scores()
		_mostrar_pergunta(_perguntas.size() - 1)
		return

	if _indice <= 0:
		quiz_cancelado.emit()
		queue_free()
		return

	# Volta uma pergunta e remove a resposta correspondente.
	var destino := _indice - 1
	if _respostas.size() > destino:
		_respostas = _respostas.slice(0, destino)
	_recalcular_scores()
	_mostrar_pergunta(destino)


func _recalcular_scores() -> void:
	_scores = QuizScript.empty_scores()
	for qi in range(_respostas.size()):
		var prev_q: Dictionary = _perguntas[qi]
		var prev_opts: Array = prev_q.get("options", [])
		var ri: int = int(_respostas[qi])
		if ri >= 0 and ri < prev_opts.size():
			QuizScript.aplicar_pesos(_scores, prev_opts[ri].get("weights", {}))


func _on_continuar() -> void:
	if not _fase_final:
		return
	var seed_str: String = QuizScript.gerar_seed(_nome_hunter, _respostas)
	quiz_concluido.emit(_scores.duplicate(true), seed_str, _respostas.duplicate())
	queue_free()
