extends CanvasLayer

# ============================================================
# HUNTER ONLINE - VISUAL DIALOGUE UI & SPEECH BALLOONS
# ============================================================
#
# Interface de Balão de Fala e Caixa de Diálogo Visual estilo RPG.
# Conectada à cena VisualDialogueUI.tscn.
#
# ============================================================

signal dialogo_concluido()

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

@onready var lbl_falante: Label = $ControlContainer/MarginContainer/PanelContainer/MarginContent/VBoxContainer/SpeakerLabel
@onready var lbl_texto: Label = $ControlContainer/MarginContainer/PanelContainer/MarginContent/VBoxContainer/TextLabel
@onready var lbl_indicador: Label = $ControlContainer/MarginContainer/PanelContainer/MarginContent/VBoxContainer/IndicatorLabel

var fila_dialogos: Array[Dictionary] = []
var texto_completo: String = ""
var indice_caractere: int = 0
var tempo_digitacao: float = 0.0
var imprimindo: bool = false
var _aberto_no_frame_atual: bool = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	add_to_group("visual_dialogue_ui")
	layer = 20
	visible = false

	var panel = get_node_or_null("ControlContainer/MarginContainer/PanelContainer")
	if panel != null:
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	if lbl_falante != null:
		lbl_falante.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	if lbl_texto != null:
		lbl_texto.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	if lbl_indicador != null:
		lbl_indicador.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_E or event.keycode == KEY_SPACE)):
		if _aberto_no_frame_atual:
			_aberto_no_frame_atual = false
			get_viewport().set_input_as_handled()
			return

		get_viewport().set_input_as_handled()
		_avancar_dialogo()


func exibir_fala(nome_falante: String, texto: String) -> void:
	exibir_sequencia_falas([{"falante": nome_falante, "texto": texto}])


func exibir_sequencia_falas(lista_falas: Array) -> void:
	fila_dialogos.clear()
	for item in lista_falas:
		if item is Dictionary:
			fila_dialogos.append(item)
		elif item is String:
			fila_dialogos.append({"falante": "NPC", "texto": item})

	_aberto_no_frame_atual = true
	visible = true
	if get_tree() != null:
		get_tree().paused = true
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null:
		input_ctx.push_context("DIALOGUE")
	_mostrar_proxima_fala()


func _mostrar_proxima_fala() -> void:
	if fila_dialogos.is_empty():
		_fechar_dialogo()
		return

	var dados: Dictionary = fila_dialogos.pop_front()
	var falante: String = str(dados.get("falante", "NPC"))
	texto_completo = str(dados.get("texto", ""))

	if lbl_falante != null:
		lbl_falante.text = "💬 " + falante.to_upper()

	if lbl_texto != null:
		lbl_texto.text = ""

	indice_caractere = 0
	imprimindo = true

	if lbl_indicador != null:
		lbl_indicador.visible = false


func _process(delta: float) -> void:
	if not visible or not imprimindo:
		return

	tempo_digitacao += delta
	if tempo_digitacao >= 0.015: # Digitação fluida
		tempo_digitacao = 0.0
		if indice_caractere < texto_completo.length():
			indice_caractere += 1
			if lbl_texto != null:
				lbl_texto.text = texto_completo.left(indice_caractere)
		else:
			imprimindo = false
			if lbl_indicador != null:
				lbl_indicador.visible = true


func _avancar_dialogo() -> void:
	if imprimindo:
		if lbl_texto != null:
			lbl_texto.text = texto_completo
		imprimindo = false
		if lbl_indicador != null:
			lbl_indicador.visible = true
	else:
		_mostrar_proxima_fala()


func _fechar_dialogo() -> void:
	visible = false
	if get_tree() != null:
		get_tree().paused = false
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null:
		input_ctx.pop_context()
	dialogo_concluido.emit()
