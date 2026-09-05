class_name LanDiscoveryListener
extends RefCounted

# ============================================================
# HUNTER ONLINE — LAN DISCOVERY LISTENER (FASE K-LAN)
# ============================================================
#
# Escuta beacons UDP na porta 7778 emitidos por servidores LAN.
# Descobre servidores ativos na mesma sub-rede sem necessidade
# de digitação manual de endereço IP.
# ============================================================

signal server_discovered(server_info: Dictionary)
signal server_lost(server_id: String)

var _udp: PacketPeerUDP = null
var _listen_port: int = 7778
var is_listening: bool = false

# server_key (ip:port) -> { "ip", "port", "name", "players", "max_players", "region", "last_seen_ms", "ping_ms" }
var discovered_servers: Dictionary = {}
const SERVER_TIMEOUT_SEC: float = 5.0


func start_listening(listen_port: int = 7778) -> Error:
	stop_listening()
	_listen_port = listen_port
	_udp = PacketPeerUDP.new()
	var err = _udp.bind(_listen_port, "*")
	if err != OK:
		push_warning("[LanDiscoveryListener] Falha ao vincular porta de escuta UDP %d: Erro %d" % [_listen_port, err])
		_udp = null
		return err

	is_listening = true
	discovered_servers.clear()
	return OK


func update(delta: float) -> void:
	if not is_listening or _udp == null:
		return

	# Consumir pacotes recebidos
	while _udp.get_available_packet_count() > 0:
		var packet: PackedByteArray = _udp.get_packet()
		var sender_ip: String = _udp.get_packet_ip()
		var packet_str: String = packet.get_string_from_utf8()
		_parse_beacon(sender_ip, packet_str)

	# Verificar servidores expirados (timeout após 5 segundos sem beacon)
	var now = Time.get_ticks_msec()
	var to_remove: Array = []
	for key in discovered_servers.keys():
		var s = discovered_servers[key]
		if float(now - int(s.get("last_seen_ms", 0))) / 1000.0 > SERVER_TIMEOUT_SEC:
			to_remove.append(key)

	for key in to_remove:
		discovered_servers.erase(key)
		server_lost.emit(key)


func _parse_beacon(sender_ip: String, text: String) -> void:
	if not text.begins_with("HUNTER_LAN_SERVER|"):
		return

	var parts = text.split("|")
	if parts.size() < 6:
		return

	var s_name = parts[1]
	var s_port = int(parts[2])
	var s_players = int(parts[3])
	var s_max_players = int(parts[4])
	var s_region = parts[5]
	var s_ts = int(parts[6]) if parts.size() > 6 else 0

	var key = "%s:%d" % [sender_ip, s_port]
	var now = Time.get_ticks_msec()

	var info: Dictionary = {
		"id": key,
		"ip": sender_ip,
		"port": s_port,
		"name": s_name,
		"players": s_players,
		"max_players": s_max_players,
		"region": s_region,
		"last_seen_ms": now,
		"ping_ms": max(1, now - s_ts) if s_ts > 0 else 10
	}

	var is_new: bool = not discovered_servers.has(key)
	discovered_servers[key] = info

	if is_new:
		server_discovered.emit(info)


func get_server_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for k in discovered_servers.keys():
		list.append(discovered_servers[k])
	return list


func stop_listening() -> void:
	is_listening = false
	if _udp != null:
		_udp.close()
		_udp = null
	discovered_servers.clear()
