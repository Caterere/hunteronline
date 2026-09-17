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
const LOG_WIDTH: float = 260.0
const LOG_HEIGHT: float = 100.0

const COLOR_COMBAT_XP := Color(1.0, 0.92, 0.45, 1.0)
const COLOR_COMBAT_SP := Color(0.45, 0.82, 1.0, 1.0)
const COLOR_COMBAT_JENNY := Color(1.0, 0.82, 0.28, 1.0)
const COLOR_COMBAT_LOOT := Color(1.0, 0.72, 0.38, 1.0)
const COLOR_COMBAT_NEN_XP := Color(0.75, 0.55, 1.0, 1.0)

var vbox_log: VBoxContainer = null
var scroll_log: ScrollContainer = null
var line_input: LineEdit = null
var btn_canal: Button = null
var lbl_counter: Label = null
var canal_atual: String = "local"
var canais: Array[String] = ["combat", "local", "party", "geral"]
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
		HunterUIStyle.criar_style_glass_panel(HunterUIStyle.COLOR_GLASS_BORDER, 3)
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
	_conectar_combat_log()


func _conectar_combat_log() -> void:
	if EventBus == null:
		return
	if not EventBus.player_xp_gained.is_connected(_on_player_xp_gained):
		EventBus.player_xp_gained.connect(_on_player_xp_gained)
	if not EventBus.player_skill_points_gained.is_connected(_on_player_skill_points_gained):
		EventBus.player_skill_points_gained.connect(_on_player_skill_points_gained)
	if not EventBus.jenny_changed.is_connected(_on_jenny_changed):
		EventBus.jenny_changed.connect(_on_jenny_changed)
	if not EventBus.item_obtained.is_connected(_on_item_obtained):
		EventBus.item_obtained.connect(_on_item_obtained)
	if EventBus.has_signal("nen_xp_gained") and not EventBus.nen_xp_gained.is_connected(_on_nen_xp_gained):
		EventBus.nen_xp_gained.connect(_on_nen_xp_gained)


func _exit_combat_log_connections() -> void:
	if EventBus == null:
		return
	if EventBus.player_xp_gained.is_connected(_on_player_xp_gained):
		EventBus.player_xp_gained.disconnect(_on_player_xp_gained)
	if EventBus.player_skill_points_gained.is_connected(_on_player_skill_points_gained):
		EventBus.player_skill_points_gained.disconnect(_on_player_skill_points_gained)
	if EventBus.jenny_changed.is_connected(_on_jenny_changed):
		EventBus.jenny_changed.disconnect(_on_jenny_changed)
	if EventBus.item_obtained.is_connected(_on_item_obtained):
		EventBus.item_obtained.disconnect(_on_item_obtained)
	if EventBus.has_signal("nen_xp_gained") and EventBus.nen_xp_gained.is_connected(_on_nen_xp_gained):
		EventBus.nen_xp_gained.disconnect(_on_nen_xp_gained)


func _on_player_xp_gained(amount: int) -> void:
	if amount <= 0:
		return
	adicionar_sistema("Gained %d XP" % amount, COLOR_COMBAT_XP)


func _on_player_skill_points_gained(amount: int) -> void:
	if amount <= 0:
		return
	adicionar_sistema("Gained %d SP" % amount, COLOR_COMBAT_SP)


func _on_jenny_changed(_new_amount: int, delta: int) -> void:
	if delta <= 0:
		return
	adicionar_sistema("Looted Jenny x%d" % delta, COLOR_COMBAT_JENNY)


func _on_item_obtained(item_id: String, quantity: int) -> void:
	if quantity <= 0:
		return
	var label: String = _formatar_nome_item(item_id)
	adicionar_sistema("Looted %s x%d" % [label, quantity], COLOR_COMBAT_LOOT)


func _on_nen_xp_gained(amount: int, _current_xp: int) -> void:
	if amount <= 0:
		return
	adicionar_sistema("Gained %d Nen XP" % amount, COLOR_COMBAT_NEN_XP)


static func _formatar_nome_item(item_id: String) -> String:
	if Economy != null and Economy.ITEM_CATALOGO.has(item_id):
		var entry: Dictionary = Economy.ITEM_CATALOGO[item_id]
		if entry.has("nome"):
			return str(entry["nome"])
	return item_id.replace("_", " ").capitalize()


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
	_exit_combat_log_connections()
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


func _abrir_chat() -> void:
	if line_input != null:
		line_input.grab_focus()


func _fechar_chat() -> void:
	if line_input == null:
		return
	line_input.release_focus()
	line_input.clear()
	_atualizar_contador()


func _on_chat_focus_entered() -> void:
	_chat_open = true
	var icm := get_node_or_null("/root/InputContextManager")
	if icm != null and icm.has_method("push_context"):
		if icm.get_context() != icm.Context.CHAT:
			icm.push_context(icm.Context.CHAT)


func _on_chat_focus_exited() -> void:
	_chat_open = false
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
	_atualizar_filtro_log()


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
	line_input.clear()
	_atualizar_contador()
	line_input.release_focus()
	if limpo.is_empty():
		return

	var nm := get_node_or_null("/root/NetworkManager")
	if nm != null and nm.has_method("enviar_mensagem_chat") and nm.has_method("is_offline_singleplayer") and not nm.is_offline_singleplayer():
		nm.enviar_mensagem_chat(canal_atual, limpo)
	else:
		adicionar_mensagem("Você", canal_atual, limpo)


func _on_network_chat(autor: String, canal: String, msg: String) -> void:
	adicionar_mensagem(autor, canal, msg)


func adicionar_sistema(msg: String, cor: Color, canal: String = "combat") -> void:
	if vbox_log == null:
		return
	var limpo: String = msg.strip_edges()
	if limpo.is_empty():
		return
	_adicionar_linha_log(limpo, cor, canal)


func adicionar_mensagem(autor: String, canal: String, msg: String) -> void:
	if vbox_log == null:
		return
	var limpo: String = sanitizar_mensagem(msg)
	if limpo.is_empty():
		return

	var texto: String = "[%s] %s: %s" % [canal.substr(0, 1).to_upper(), autor, limpo]
	var cor: Color = HunterUIStyle.COLOR_GLASS_TEXT
	if canal == "party":
		cor = HunterUIStyle.COLOR_AURA_CYAN
	elif canal == "geral":
		cor = HunterUIStyle.COLOR_GOLD_LIGHT
	_adicionar_linha_log(texto, cor, canal)


func _adicionar_linha_log(texto: String, cor: Color, canal: String) -> void:
	var lbl := Label.new()
	lbl.text = texto
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.custom_minimum_size = Vector2(LOG_WIDTH - 8.0, 0.0)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.clip_text = false
	lbl.add_theme_color_override("font_color", cor)
	lbl.set_meta("log_canal", canal)
	lbl.visible = _linha_visivel(canal)
	vbox_log.add_child(lbl)
	while vbox_log.get_child_count() > MAX_LOG_LINES:
		var old: Node = vbox_log.get_child(0)
		vbox_log.remove_child(old)
		old.queue_free()
	call_deferred("_rolar_chat_para_fim")


func _linha_visivel(canal_linha: String) -> bool:
	if canal_atual == "combat":
		return canal_linha == "combat"
	return canal_linha == canal_atual or canal_linha == "combat"


func _atualizar_filtro_log() -> void:
	if vbox_log == null:
		return
	for child in vbox_log.get_children():
		if child is Label:
			var canal_linha: String = str(child.get_meta("log_canal", "local"))
			child.visible = _linha_visivel(canal_linha)
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
