class_name MultiplayerMenuUI
extends Control

# ============================================================
# HUNTER ONLINE — MULTIPLAYER LAN MENU UI (FASE K-LAN)
# ============================================================
#
# Interface gráfica para conexão multiplayer:
# - Conexão Direta (IP manual para Radmin VPN / LAN / Internet)
# - Descoberta de Servidores LAN (UDP Broadcast listener)
# - Inicialização de servidor dedicado local
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")
const LanDiscoveryListenerScript = preload("res://scripts/network/LanDiscoveryListener.gd")

var line_edit_ip: LineEdit
var line_edit_port: LineEdit
var line_edit_password: LineEdit
var btn_connect: Button
var btn_start_server: Button
var btn_refresh_lan: Button
var btn_back: Button
var lbl_status: Label
var server_list_container: VBoxContainer

var discovery_listener = null
var _is_connecting: bool = false


func _ready() -> void:
	_construir_ui()
	_iniciar_descoberta_lan()
	set_process(true)

	if NetworkManager != null:
		NetworkManager.handshake_completed.connect(_on_handshake_completed)


func _process(delta: float) -> void:
	if discovery_listener != null and discovery_listener.is_listening:
		discovery_listener.update(delta)


func _exit_tree() -> void:
	if discovery_listener != null:
		discovery_listener.stop_listening()


func _construir_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Fundo escuro semi-transparente
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.07, 0.11, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 15)
	add_child(margin)

	var vbox_main := VBoxContainer.new()
	vbox_main.add_theme_constant_override("separation", 8)
	margin.add_child(vbox_main)

	# Título
	var lbl_title := Label.new()
	lbl_title.text = "HUNTER ONLINE — MULTIPLAYER LAN & VPN"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 9)
	lbl_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	vbox_main.add_child(lbl_title)

	var hbox_cols := HBoxContainer.new()
	hbox_cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_cols.add_theme_constant_override("separation", 15)
	vbox_main.add_child(hbox_cols)

	# Coluna Esquerda: Conexão Direta
	var col_left := VBoxContainer.new()
	col_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_left.add_theme_constant_override("separation", 5)
	hbox_cols.add_child(col_left)

	var lbl_direct := Label.new()
	lbl_direct.text = "CONEXÃO DIRETA (RADMIN VPN / IP)"
	lbl_direct.add_theme_font_size_override("font_size", 6)
	lbl_direct.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	col_left.add_child(lbl_direct)

	col_left.add_child(_criar_label("Endereço IP do Servidor:"))
	line_edit_ip = LineEdit.new()
	line_edit_ip.text = "127.0.0.1"
	line_edit_ip.placeholder_text = "26.x.x.x ou 192.168.x.x"
	col_left.add_child(line_edit_ip)

	col_left.add_child(_criar_label("Porta do Servidor:"))
	line_edit_port = LineEdit.new()
	line_edit_port.text = "7777"
	col_left.add_child(line_edit_port)

	col_left.add_child(_criar_label("Senha (Opcional):"))
	line_edit_password = LineEdit.new()
	line_edit_password.secret = true
	line_edit_password.placeholder_text = "Em branco se não houver"
	col_left.add_child(line_edit_password)

	btn_connect = Button.new()
	btn_connect.text = "CONECTAR AO SERVIDOR"
	HunterUIStyle.aplicar_estilo_botao(btn_connect, HunterUIStyle.COLOR_BORDER_GREEN)
	btn_connect.pressed.connect(_on_connect_pressed)
	col_left.add_child(btn_connect)

	btn_start_server = Button.new()
	btn_start_server.text = "⚡ INICIAR SERVIDOR NESTE PC"
	HunterUIStyle.aplicar_estilo_botao(btn_start_server, HunterUIStyle.COLOR_BORDER_GOLD)
	btn_start_server.pressed.connect(_on_start_server_pressed)
	col_left.add_child(btn_start_server)

	# Coluna Direita: Servidores LAN Detectados
	var col_right := VBoxContainer.new()
	col_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_right.add_theme_constant_override("separation", 5)
	hbox_cols.add_child(col_right)

	var hbox_lan_hdr := HBoxContainer.new()
	col_right.add_child(hbox_lan_hdr)

	var lbl_lan := Label.new()
	lbl_lan.text = "SERVIDORES LAN LOCAIS"
	lbl_lan.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_lan.add_theme_font_size_override("font_size", 6)
	lbl_lan.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	hbox_lan_hdr.add_child(lbl_lan)

	btn_refresh_lan = Button.new()
	btn_refresh_lan.text = "🔄 Atualizar"
	btn_refresh_lan.pressed.connect(_iniciar_descoberta_lan)
	hbox_lan_hdr.add_child(btn_refresh_lan)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_right.add_child(scroll)

	server_list_container = VBoxContainer.new()
	server_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	server_list_container.add_theme_constant_override("separation", 3)
	scroll.add_child(server_list_container)

	# Rodapé: Status & Voltar
	var hbox_footer := HBoxContainer.new()
	vbox_main.add_child(hbox_footer)

	lbl_status = Label.new()
	lbl_status.text = "Pronto para conectar."
	lbl_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_status.add_theme_font_size_override("font_size", 6)
	lbl_status.add_theme_color_override("font_color", Color.WHITE)
	hbox_footer.add_child(lbl_status)

	btn_back = Button.new()
	btn_back.text = "< VOLTAR"
	HunterUIStyle.aplicar_estilo_botao(btn_back, Color(0.8, 0.3, 0.3, 1.0))
	btn_back.pressed.connect(_on_back_pressed)
	hbox_footer.add_child(btn_back)


func _criar_label(txt: String) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", 5)
	l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
	return l


func _iniciar_descoberta_lan() -> void:
	if discovery_listener == null:
		discovery_listener = LanDiscoveryListenerScript.new()
		discovery_listener.server_discovered.connect(_on_server_discovered)

	discovery_listener.start_listening(7778)
	_limpar_lista_servidores()
	_atualizar_label_status("Procurando servidores na rede local...")


func _limpar_lista_servidores() -> void:
	for child in server_list_container.get_children():
		child.queue_free()

	var lbl_empty := Label.new()
	lbl_empty.name = "EmptyLabel"
	lbl_empty.text = "Nenhum servidor LAN detectado ainda...\n(Para Radmin VPN, use Conexão Direta ao lado)"
	lbl_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_empty.add_theme_font_size_override("font_size", 5)
	lbl_empty.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
	server_list_container.add_child(lbl_empty)


func _on_server_discovered(info: Dictionary) -> void:
	var empty = server_list_container.get_node_or_null("EmptyLabel")
	if empty != null:
		empty.queue_free()

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 32)
	panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 3))
	server_list_container.add_child(panel)

	var hbox := HBoxContainer.new()
	panel.add_child(hbox)

	var lbl_srv := Label.new()
	lbl_srv.text = "%s (%s:%d) | %d/%d Jogadores | %dms" % [
		info.get("name", "Hunter Server"),
		info.get("ip", "127.0.0.1"),
		int(info.get("port", 7777)),
		int(info.get("players", 0)),
		int(info.get("max_players", 16)),
		int(info.get("ping_ms", 15))
	]
	lbl_srv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_srv.add_theme_font_size_override("font_size", 5)
	hbox.add_child(lbl_srv)

	var btn_join := Button.new()
	btn_join.text = "ENTRAR"
	HunterUIStyle.aplicar_estilo_botao(btn_join, HunterUIStyle.COLOR_BORDER_GREEN)
	btn_join.pressed.connect(func():
		line_edit_ip.text = str(info.get("ip", "127.0.0.1"))
		line_edit_port.text = str(info.get("port", 7777))
		_on_connect_pressed()
	)
	hbox.add_child(btn_join)


func _on_connect_pressed() -> void:
	if _is_connecting:
		return
	_is_connecting = true

	var ip: String = line_edit_ip.text.strip_edges()
	var port: int = int(line_edit_port.text.strip_edges())
	var pwd: String = line_edit_password.text.strip_edges()

	if ip.is_empty():
		ip = "127.0.0.1"
	if port <= 0:
		port = 7777

	_atualizar_label_status("Conectando a %s:%d..." % [ip, port], Color(1.0, 0.8, 0.2))
	btn_connect.disabled = true

	var err = NetworkManager.conectar_com_handshake(ip, port, pwd)
	if err != OK:
		_is_connecting = false
		btn_connect.disabled = false
		_atualizar_label_status("Erro ao abrir socket de cliente: %d" % err, Color(1.0, 0.3, 0.3))


func _on_start_server_pressed() -> void:
	_atualizar_label_status("Iniciando Servidor Dedicado... (este PC nao joga — use outro cliente / script separado)", Color(0.2, 0.8, 1.0))
	var err = NetworkManager.iniciar_servidor_dedicado()
	if err == OK:
		var porta: int = 7777
		if NetworkManager.server_config != null:
			porta = int(NetworkManager.server_config.port)
		_atualizar_label_status("Servidor Online na porta %d. Prefira ./iniciar_servidor_lan.sh + cliente em outro PC." % porta, Color(0.3, 1.0, 0.5))
		btn_start_server.disabled = true
		btn_connect.disabled = true
	else:
		_atualizar_label_status("Erro ao iniciar servidor: %d" % err, Color(1.0, 0.3, 0.3))


func _on_handshake_completed(success: bool, reason: String) -> void:
	_is_connecting = false
	btn_connect.disabled = false

	if success:
		_atualizar_label_status("Conexão autorizada! Entrando no mundo...", Color(0.3, 1.0, 0.5))
		var map_path := "res://world/lobby.tscn"
		if NetworkManager != null and NetworkManager.has_method("obter_mapa_sessao"):
			map_path = NetworkManager.obter_mapa_sessao()
		var trans = get_node_or_null("/root/SceneTransition")
		if trans != null and trans.has_method("mudar_cena"):
			trans.mudar_cena(map_path, "Capital dos Caçadores", "Sessão Co-op LAN")
		else:
			get_tree().change_scene_to_file(map_path)
	else:
		_atualizar_label_status("Conexão falhou: %s" % reason, Color(1.0, 0.3, 0.3))


func _atualizar_label_status(msg: String, col: Color = Color.WHITE) -> void:
	if lbl_status != null:
		lbl_status.text = msg
		lbl_status.add_theme_color_override("font_color", col)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/CharacterSelection/CharacterSelectionUI.tscn")
