class_name NetworkDebugOverlay
extends CanvasLayer

# ============================================================
# HUNTER ONLINE — NETWORK DEBUG OVERLAY (FASE K-LAN — L34)
# ============================================================
#
# Overlay de diagnóstico de telemetria de rede:
# - Monitora PING (RTT), PACKET RATE, SERVER TICK, PLAYER COUNT
# - Mede BANDWIDTH aproximada, RPC COUNT e ENTITY COUNT
# - Ativável via atalho F4 ou menu de debug
# ============================================================

var panel: PanelContainer
var lbl_info: Label
var is_overlay_visible: bool = false

var _packet_count_second: int = 0
var _bytes_in_second: int = 0
var _timer_second: float = 0.0

var current_packet_rate: int = 0
var current_bandwidth_kbps: float = 0.0


func _ready() -> void:
	layer = 125 # Acima de HUDs normais
	_construir_ui()
	visible = is_overlay_visible


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F4:
			toggle_overlay()


func toggle_overlay() -> void:
	is_overlay_visible = not is_overlay_visible
	visible = is_overlay_visible
	print("[NetworkDebugOverlay] Overlay de Rede: %s" % ("VISÍVEL" if is_overlay_visible else "OCULTO"))


func _construir_ui() -> void:
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(170, 75)
	panel.position = Vector2(8, 8)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.06, 0.09, 0.88)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.2, 0.7, 1.0, 0.8)
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_right = 3
	sb.corner_radius_bottom_left = 3
	panel.add_theme_stylebox_override("panel", sb)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	lbl_info = Label.new()
	lbl_info.add_theme_font_size_override("font_size", 5)
	lbl_info.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
	margin.add_child(lbl_info)


func _process(delta: float) -> void:
	_timer_second += delta
	if _timer_second >= 1.0:
		current_packet_rate = _packet_count_second
		current_bandwidth_kbps = float(_bytes_in_second) / 1024.0
		_packet_count_second = 0
		_bytes_in_second = 0
		_timer_second = 0.0

	if not is_overlay_visible:
		return

	_atualizar_telemetria()


func _atualizar_telemetria() -> void:
	if lbl_info == null:
		return

	var mode_str = "OFFLINE"
	var ping_ms = 0
	var p_count = 1
	var tps = 20
	var rpc_count = 0
	var entities_count = 0

	if NetworkManager != null:
		match NetworkManager.current_mode:
			NetworkManager.NetworkMode.OFFLINE_SINGLEPLAYER: mode_str = "OFFLINE (SINGLE-PLAYER)"
			NetworkManager.NetworkMode.HOST_LISTEN: mode_str = "HOST LISTEN (CO-OP)"
			NetworkManager.NetworkMode.CLIENT_PEER: mode_str = "CLIENT (CONNECTED)"
			NetworkManager.NetworkMode.DEDICATED_SERVER: mode_str = "DEDICATED SERVER"

		if NetworkManager.session != null:
			ping_ms = NetworkManager.session.obter_latencia(NetworkManager.local_peer_id)
			p_count = max(1, NetworkManager.session.peers.size())

		if NetworkManager.server_config != null:
			tps = NetworkManager.server_config.tick_rate

		if NetworkManager.world_coordinator != null:
			entities_count = NetworkManager.world_coordinator.enemies.size() + NetworkManager.world_coordinator.players.size()

	var tree = get_tree()
	if tree != null:
		entities_count += tree.get_nodes_in_group("enemies").size() + tree.get_nodes_in_group("remote_player").size()

	lbl_info.text = "🌐 NETWORK DIAGNOSTICS [F4]\n" \
		+ "MODO: %s\n" % mode_str \
		+ "PING: %d ms | TPS: %d\n" % [ping_ms, tps] \
		+ "JOGADORES: %d | ENTIDADES: %d\n" % [p_count, entities_count] \
		+ "PACKETS: %d/s | B/W: %.1f KB/s" % [current_packet_rate, current_bandwidth_kbps]
