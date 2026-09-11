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
const ServerListCatalogScript = preload("res://scripts/network/ServerListCatalog.gd")
const MasterServerRegistryScript = preload("res://scripts/network/MasterServerRegistry.gd")

var line_edit_ip: LineEdit
var line_edit_port: LineEdit
var line_edit_password: LineEdit
var line_edit_registry_host: LineEdit
var line_edit_registry_port: LineEdit
var btn_connect: Button
var btn_start_server: Button
var btn_refresh_lan: Button
var btn_query_registry: Button
var btn_back: Button
var lbl_status: Label
var server_list_container: VBoxContainer
var public_list_container: VBoxContainer
var registry_list_container: VBoxContainer

var discovery_listener = null
var master_registry_client = null
var _is_connecting: bool = false


func _ready() -> void:
	_construir_ui()
	_iniciar_descoberta_lan()
	_popular_servidores_publicos()
	set_process(true)

	if NetworkManager != null:
		NetworkManager.handshake_completed.connect(_on_handshake_completed)


func _process(delta: float) -> void:
	if discovery_listener != null and discovery_listener.is_listening:
		discovery_listener.update(delta)
	if master_registry_client != null and master_registry_client.is_active:
		master_registry_client.update(delta)


func _exit_tree() -> void:
	if discovery_listener != null:
		discovery_listener.stop_listening()
	if master_registry_client != null:
		master_registry_client.stop()
		master_registry_client = null


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
	lbl_title.text = "HUNTER ONLINE — MULTIPLAYER LAN / VPN / VPS"
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
	line_edit_ip.placeholder_text = "192.168.x.x / 26.x.x.x / DNS do VPS"
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
	scroll.custom_minimum_size = Vector2(0, 70)
	col_right.add_child(scroll)

	server_list_container = VBoxContainer.new()
	server_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	server_list_container.add_theme_constant_override("separation", 3)
	scroll.add_child(server_list_container)

	var lbl_public := Label.new()
	lbl_public.text = "SERVIDORES PÚBLICOS / DNS"
	lbl_public.add_theme_font_size_override("font_size", 6)
	lbl_public.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	col_right.add_child(lbl_public)

	var scroll_pub := ScrollContainer.new()
	scroll_pub.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_pub.custom_minimum_size = Vector2(0, 70)
	col_right.add_child(scroll_pub)

	public_list_container = VBoxContainer.new()
	public_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	public_list_container.add_theme_constant_override("separation", 3)
	scroll_pub.add_child(public_list_container)

	var hbox_reg_hdr := HBoxContainer.new()
	col_right.add_child(hbox_reg_hdr)

	var lbl_reg := Label.new()
	lbl_reg.text = "MASTER REGISTRY (DINÂMICO)"
	lbl_reg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_reg.add_theme_font_size_override("font_size", 6)
	lbl_reg.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	hbox_reg_hdr.add_child(lbl_reg)

	btn_query_registry = Button.new()
	btn_query_registry.text = "Consultar"
	btn_query_registry.pressed.connect(_consultar_master_registry)
	hbox_reg_hdr.add_child(btn_query_registry)

	var hbox_reg_fields := HBoxContainer.new()
	hbox_reg_fields.add_theme_constant_override("separation", 4)
	col_right.add_child(hbox_reg_fields)

	line_edit_registry_host = LineEdit.new()
	line_edit_registry_host.text = "127.0.0.1"
	line_edit_registry_host.placeholder_text = "IP do registry"
	line_edit_registry_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_reg_fields.add_child(line_edit_registry_host)

	line_edit_registry_port = LineEdit.new()
	line_edit_registry_port.text = "7780"
	line_edit_registry_port.custom_minimum_size = Vector2(56, 0)
	hbox_reg_fields.add_child(line_edit_registry_port)

	var scroll_reg := ScrollContainer.new()
	scroll_reg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_reg.custom_minimum_size = Vector2(0, 55)
	col_right.add_child(scroll_reg)

	registry_list_container = VBoxContainer.new()
	registry_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	registry_list_container.add_theme_constant_override("separation", 3)
	scroll_reg.add_child(registry_list_container)

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


func _popular_servidores_publicos() -> void:
	if public_list_container == null:
		return
	for child in public_list_container.get_children():
		child.queue_free()

	var servers: Array = ServerListCatalogScript.load_servers()
	if servers.is_empty():
		var lbl := Label.new()
		lbl.text = "Nenhum servidor em config/server_list.json"
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		public_list_container.add_child(lbl)
		return

	for info in servers:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 30)
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GREEN, 3))
		public_list_container.add_child(panel)

		var hbox := HBoxContainer.new()
		panel.add_child(hbox)

		var lbl_srv := Label.new()
		var notes: String = str(info.get("notes", ""))
		lbl_srv.text = "%s | %s:%d%s" % [
			info.get("name", "Server"),
			info.get("host", "127.0.0.1"),
			int(info.get("port", 7777)),
			(" — " + notes) if not notes.is_empty() else ""
		]
		lbl_srv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_srv.add_theme_font_size_override("font_size", 5)
		hbox.add_child(lbl_srv)

		var btn_join := Button.new()
		btn_join.text = "USAR"
		HunterUIStyle.aplicar_estilo_botao(btn_join, HunterUIStyle.COLOR_BORDER_GREEN)
		var host: String = str(info.get("host", "127.0.0.1"))
		var port: int = int(info.get("port", 7777))
		btn_join.pressed.connect(func():
			line_edit_ip.text = host
			line_edit_port.text = str(port)
			_atualizar_label_status("Selecionado: %s:%d" % [host, port], Color(0.5, 1.0, 0.7))
		)
		hbox.add_child(btn_join)


func _consultar_master_registry() -> void:
	var host: String = line_edit_registry_host.text.strip_edges() if line_edit_registry_host != null else "127.0.0.1"
	var port: int = int(line_edit_registry_port.text.strip_edges()) if line_edit_registry_port != null else 7780
	if host.is_empty():
		host = "127.0.0.1"
	if port <= 0:
		port = 7780

	if master_registry_client == null:
		master_registry_client = MasterServerRegistryScript.new()
		master_registry_client.servers_updated.connect(_on_master_servers_updated)
		master_registry_client.query_failed.connect(_on_master_query_failed)

	_limpar_lista_registry("Consultando registry %s:%d..." % [host, port])
	_atualizar_label_status("Consultando master registry %s:%d..." % [host, port], Color(0.5, 0.9, 1.0))
	var err: Error = master_registry_client.query_servers(host, port)
	if err != OK:
		_atualizar_label_status("Falha ao consultar registry: %d" % err, Color(1.0, 0.3, 0.3))


func _limpar_lista_registry(msg: String = "Nenhum servidor no registry...") -> void:
	if registry_list_container == null:
		return
	for child in registry_list_container.get_children():
		child.queue_free()
	var lbl := Label.new()
	lbl.name = "EmptyRegistryLabel"
	lbl.text = msg
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
	registry_list_container.add_child(lbl)


func _on_master_query_failed(reason: String) -> void:
	_atualizar_label_status("Registry: %s" % reason, Color(1.0, 0.4, 0.3))
	_limpar_lista_registry("Consulta falhou: %s" % reason)


func _on_master_servers_updated(servers: Array) -> void:
	if registry_list_container == null:
		return
	for child in registry_list_container.get_children():
		child.queue_free()

	if servers.is_empty():
		_limpar_lista_registry("Registry respondeu sem servidores vivos.")
		_atualizar_label_status("Registry vazio.", Color(1.0, 0.8, 0.3))
		return

	_atualizar_label_status("Registry: %d servidor(es)" % servers.size(), Color(0.4, 1.0, 0.6))
	for info in servers:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 30)
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 3))
		registry_list_container.add_child(panel)

		var hbox := HBoxContainer.new()
		panel.add_child(hbox)

		var lbl_srv := Label.new()
		lbl_srv.text = "%s | %s:%d | %d/%d | %s" % [
			info.get("name", "Server"),
			info.get("host", "127.0.0.1"),
			int(info.get("port", 7777)),
			int(info.get("players", 0)),
			int(info.get("max_players", 16)),
			info.get("region", "")
		]
		lbl_srv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_srv.add_theme_font_size_override("font_size", 5)
		hbox.add_child(lbl_srv)

		var btn_join := Button.new()
		btn_join.text = "USAR"
		HunterUIStyle.aplicar_estilo_botao(btn_join, HunterUIStyle.COLOR_BORDER_GREEN)
		var host: String = str(info.get("host", "127.0.0.1"))
		var port: int = int(info.get("port", 7777))
		btn_join.pressed.connect(func():
			line_edit_ip.text = host
			line_edit_port.text = str(port)
			_atualizar_label_status("Selecionado via registry: %s:%d" % [host, port], Color(0.5, 1.0, 0.7))
		)
		hbox.add_child(btn_join)


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
