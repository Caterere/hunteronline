class_name MultiplayerChatHUD
extends Control

# ============================================================
# HUNTER ONLINE — MULTIPLAYER CHAT HUD
# ============================================================
#
# Interface de comunicação social com suporte a canais [Geral],
# [Local] e [Party]. Compacta e recolhível com a tecla Enter.
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var vbox_log: VBoxContainer = null
var line_input: LineEdit = null
var btn_canal: Button = null
var canal_atual: String = "local"
var canais: Array[String] = ["local", "party", "geral"]


func _ready() -> void:
	custom_minimum_size = Vector2(170, 70)
	position = Vector2(8, 280)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(170, 70)
	panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(Color(0.1, 0.1, 0.15, 0.75), 2))
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 3)
	margin.add_theme_constant_override("margin_right", 3)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(160, 45)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	vbox_log = VBoxContainer.new()
	vbox_log.add_theme_constant_override("separation", 1)
	scroll.add_child(vbox_log)

	var hbox_in := HBoxContainer.new()
	hbox_in.add_theme_constant_override("separation", 2)
	vbox.add_child(hbox_in)

	btn_canal = Button.new()
	btn_canal.text = "[Local]"
	btn_canal.custom_minimum_size = Vector2(32, 14)
	btn_canal.add_theme_font_size_override("font_size", 4)
	btn_canal.pressed.connect(_alternar_canal)
	hbox_in.add_child(btn_canal)

	line_input = LineEdit.new()
	line_input.placeholder_text = "Pressione Enter para falar..."
	line_input.custom_minimum_size = Vector2(125, 14)
	line_input.add_theme_font_size_override("font_size", 4)
	line_input.text_submitted.connect(_on_mensagem_enviada)
	hbox_in.add_child(line_input)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER:
			if line_input != null:
				if line_input.has_focus():
					line_input.release_focus()
				else:
					line_input.grab_focus()


func _alternar_canal() -> void:
	var idx = canais.find(canal_atual)
	var prox = (idx + 1) % canais.size()
	canal_atual = canais[prox]
	btn_canal.text = "[%s]" % canal_atual.capitalize()


func _on_mensagem_enviada(texto: String) -> void:
	var limpo = texto.strip_edges()
	line_input.clear()
	line_input.release_focus()

	if limpo.is_empty():
		return

	adicionar_mensagem("Você", canal_atual, limpo)

	var nm = get_node_or_null("/root/NetworkManager")
	if nm != null and not nm.is_offline_singleplayer():
		nm.rpc("rpc_enviar_mensagem_chat", canal_atual, limpo)


func adicionar_mensagem(autor: String, canal: String, msg: String) -> void:
	if vbox_log == null:
		return

	var lbl := Label.new()
	lbl.text = "[%s] %s: %s" % [canal.substr(0, 1).to_upper(), autor, msg]
	lbl.add_theme_font_size_override("font_size", 4)

	var cor := HunterUIStyle.COLOR_TEXT_PRIMARY
	if canal == "party":
		cor = HunterUIStyle.COLOR_AURA_CYAN
	elif canal == "geral":
		cor = HunterUIStyle.COLOR_TEXT_GOLD
	lbl.add_theme_color_override("font_color", cor)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	vbox_log.add_child(lbl)
	if vbox_log.get_child_count() > 25:
		vbox_log.get_child(0).queue_free()
