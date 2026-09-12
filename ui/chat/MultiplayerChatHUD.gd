class_name MultiplayerChatHUD
extends Control

# ============================================================
# HUNTER ONLINE — MULTIPLAYER CHAT HUD
# ============================================================
#
# Chat social com canais [Local], [Party] e [Geral].
# Enter abre o campo; Enter de novo envia; Esc cancela.
# Limite: 120 caracteres. Autowrap por palavra (não por letra).
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

const MAX_CHAT_CHARS: int = 120
const MAX_LOG_LINES: int = 40
const LOG_WIDTH: float = 200.0
const LOG_HEIGHT: float = 72.0

var vbox_log: VBoxContainer = null
var scroll_log: ScrollContainer = null
var line_input: LineEdit = null
var btn_canal: Button = null
var lbl_counter: Label = null
var canal_atual: String = "local"
var canais: Array[String] = ["local", "party", "geral"]
var _chat_open: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(LOG_WIDTH + 12, LOG_HEIGHT + 28)
	anchor_left = 0.0
	anchor_top = 1.0
	anchor_right = 0.0
	anchor_bottom = 1.0
	offset_left = 8.0
	offset_top = -(LOG_HEIGHT + 40.0)
	offset_right = LOG_WIDTH + 20.0
	offset_bottom = -8.0

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		HunterUIStyle.criar_style_card_interno(Color(0.08, 0.09, 0.12, 0.82), 2)
	)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_bottom", 3)
	panel.add_child(margin)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 3)
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root_vbox)

	scroll_log = ScrollContainer.new()
	scroll_log.custom_minimum_size = Vector2(LOG_WIDTH, LOG_HEIGHT)
	scroll_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_log.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_log.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	root_vbox.add_child(scroll_log)

	vbox_log = VBoxContainer.new()
	vbox_log.add_theme_constant_override("separation", 2)
	vbox_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Largura mínima evita Label com width≈0 (autowrap 1 char por linha)
	vbox_log.custom_minimum_size = Vector2(LOG_WIDTH - 4.0, 0.0)
	scroll_log.add_child(vbox_log)

	var hbox_in := HBoxContainer.new()
	hbox_in.add_theme_constant_override("separation", 3)
	hbox_in.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(hbox_in)

	btn_canal = Button.new()
	btn_canal.text = "[Local]"
	btn_canal.custom_minimum_size = Vector2(40, 16)
	btn_canal.add_theme_font_size_override("font_size", 5)
	btn_canal.pressed.connect(_alternar_canal)
	hbox_in.add_child(btn_canal)

	line_input = LineEdit.new()
	line_input.placeholder_text = "Enter para falar (máx %d)" % MAX_CHAT_CHARS
	line_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_input.custom_minimum_size = Vector2(120, 16)
	line_input.max_length = MAX_CHAT_CHARS
	line_input.add_theme_font_size_override("font_size", 5)
	# Fechado por padrão: não rouba WASD/números do player (bug clássico de MMO HUD).
	line_input.focus_mode = Control.FOCUS_NONE
	line_input.editable = false
	line_input.text_submitted.connect(_on_mensagem_enviada)
	line_input.text_changed.connect(_on_texto_alterado)
	line_input.focus_entered.connect(_on_chat_focus_entered)
	line_input.focus_exited.connect(_on_chat_focus_exited)
	hbox_in.add_child(line_input)

	lbl_counter = Label.new()
	lbl_counter.text = "0/%d" % MAX_CHAT_CHARS
	lbl_counter.add_theme_font_size_override("font_size", 4)
	lbl_counter.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
	lbl_counter.custom_minimum_size = Vector2(28, 16)
	hbox_in.add_child(lbl_counter)

	_conectar_network_chat()


func _conectar_network_chat() -> void:
	var nm := get_node_or_null("/root/NetworkManager")
	if nm == null:
		return
	if not nm.chat_message_received.is_connected(_on_network_chat):
		nm.chat_message_received.connect(_on_network_chat)


func _exit_tree() -> void:
	var nm := get_node_or_null("/root/NetworkManager")
	if nm != null and nm.chat_message_received.is_connected(_on_network_chat):
		nm.chat_message_received.disconnect(_on_network_chat)
	_fechar_contexto_chat()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		if line_input == null:
			return
		if line_input.has_focus():
			get_viewport().set_input_as_handled()
		else:
			_abrir_chat()
			get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and _chat_open:
		_fechar_chat()
		get_viewport().set_input_as_handled()
	elif _chat_open and _eh_tecla_movimento(event.keycode):
		# Movimento fecha o chat vazio (padrão MMO) e devolve o input ao player.
		if line_input != null and line_input.text.strip_edges().is_empty():
			_fechar_chat()
			# Não marca handled → o mesmo keyframe ainda move o personagem.


func _eh_tecla_movimento(keycode: int) -> bool:
	return keycode in [
		KEY_W, KEY_A, KEY_S, KEY_D,
		KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT,
	]


func _abrir_chat() -> void:
	if line_input == null:
		return
	line_input.focus_mode = Control.FOCUS_ALL
	line_input.editable = true
	line_input.grab_focus()


func _fechar_chat() -> void:
	if line_input == null:
		return
	line_input.release_focus()
	line_input.clear()
	line_input.editable = false
	line_input.focus_mode = Control.FOCUS_NONE
	_chat_open = false
	_fechar_contexto_chat()
	_atualizar_contador()


func _on_chat_focus_entered() -> void:
	_chat_open = true
	var icm := get_node_or_null("/root/InputContextManager")
	if icm != null and icm.has_method("push_context"):
		if icm.get_context() != icm.Context.CHAT:
			icm.push_context(icm.Context.CHAT)


func _on_chat_focus_exited() -> void:
	_chat_open = false
	if line_input != null:
		line_input.editable = false
		line_input.focus_mode = Control.FOCUS_NONE
	_fechar_contexto_chat()


func _fechar_contexto_chat() -> void:
	var icm := get_node_or_null("/root/InputContextManager")
	if icm == null:
		return
	if icm.get_context() == icm.Context.CHAT:
		icm.pop_context()


func _alternar_canal() -> void:
	var idx: int = canais.find(canal_atual)
	canal_atual = canais[(idx + 1) % canais.size()]
	btn_canal.text = "[%s]" % canal_atual.capitalize()


func _on_texto_alterado(_t: String) -> void:
	_atualizar_contador()


func _atualizar_contador() -> void:
	if lbl_counter == null or line_input == null:
		return
	var n: int = line_input.text.length()
	lbl_counter.text = "%d/%d" % [n, MAX_CHAT_CHARS]
	if n >= MAX_CHAT_CHARS:
		lbl_counter.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	else:
		lbl_counter.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))


func _on_mensagem_enviada(texto: String) -> void:
	var limpo: String = sanitizar_mensagem(texto)
	# Sempre fecha o campo após Enter (evita WASD/números vazarem no LineEdit).
	_fechar_chat()
	if limpo.is_empty():
		return

	var nm := get_node_or_null("/root/NetworkManager")
	if nm != null and nm.has_method("enviar_mensagem_chat") and nm.has_method("is_offline_singleplayer") and not nm.is_offline_singleplayer():
		nm.enviar_mensagem_chat(canal_atual, limpo)
	else:
		adicionar_mensagem("Você", canal_atual, limpo)


func _on_network_chat(autor: String, canal: String, msg: String) -> void:
	adicionar_mensagem(autor, canal, msg)


func adicionar_mensagem(autor: String, canal: String, msg: String) -> void:
	if vbox_log == null:
		return
	var limpo: String = sanitizar_mensagem(msg)
	if limpo.is_empty():
		return

	var lbl := Label.new()
	lbl.text = "[%s] %s: %s" % [canal.substr(0, 1).to_upper(), autor, limpo]
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.custom_minimum_size = Vector2(LOG_WIDTH - 8.0, 0.0)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.clip_text = false

	var cor: Color = HunterUIStyle.COLOR_TEXT_PRIMARY
	if canal == "party":
		cor = HunterUIStyle.COLOR_AURA_CYAN
	elif canal == "geral":
		cor = HunterUIStyle.COLOR_TEXT_GOLD
	lbl.add_theme_color_override("font_color", cor)

	vbox_log.add_child(lbl)
	while vbox_log.get_child_count() > MAX_LOG_LINES:
		var old: Node = vbox_log.get_child(0)
		vbox_log.remove_child(old)
		old.queue_free()

	call_deferred("_rolar_chat_para_fim")


func _rolar_chat_para_fim() -> void:
	if scroll_log == null:
		return
	var bar := scroll_log.get_v_scroll_bar()
	if bar != null:
		scroll_log.scroll_vertical = int(bar.max_value)


static func sanitizar_mensagem(texto: String) -> String:
	var limpo: String = texto.strip_edges()
	limpo = limpo.replace("\n", " ").replace("\r", " ").replace("\t", " ")
	while limpo.contains("  "):
		limpo = limpo.replace("  ", " ")
	if limpo.length() > MAX_CHAT_CHARS:
		limpo = limpo.substr(0, MAX_CHAT_CHARS)
	return limpo
