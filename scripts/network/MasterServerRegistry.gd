class_name MasterServerRegistry
extends RefCounted

# ============================================================
# HUNTER ONLINE — MASTER SERVER REGISTRY (FOUNDATION)
# ============================================================
#
# Registro dinâmico de servidores de jogo (LAN multi-host / VPS):
# - Modo REGISTRY: escuta UDP e responde QUERY com lista viva
# - Modo ANNOUNCE: game server anuncia presença periodicamente
# - Modo QUERY: cliente pede lista ao registry
#
# Protocolo texto (UTF-8):
#   ANNOUNCE|name|host|port|players|max|region|version|ts
#   HEARTBEAT|host|port|players|ts
#   QUERY
#   LIST_BEGIN
#   ENTRY|name|host|port|players|max|region|version|ts
#   LIST_END
# ============================================================

signal servers_updated(servers: Array)
signal query_failed(reason: String)

const DEFAULT_REGISTRY_PORT: int = 7780
const SERVER_TTL_SEC: float = 12.0
const ANNOUNCE_INTERVAL: float = 4.0

var mode: String = "idle" # idle | registry | announce | query
var registry_port: int = DEFAULT_REGISTRY_PORT
var registry_host: String = "127.0.0.1"

var _udp: PacketPeerUDP = null
var _timer: float = 0.0
var _announce_payload: String = ""
var _servers: Dictionary = {} # key host:port -> info dict
var _last_query_result: Array[Dictionary] = []
var is_active: bool = false


func start_registry(listen_port: int = DEFAULT_REGISTRY_PORT) -> Error:
	stop()
	mode = "registry"
	registry_port = listen_port
	_udp = PacketPeerUDP.new()
	var err := _udp.bind(listen_port, "*")
	if err != OK:
		_udp = null
		mode = "idle"
		return err
	is_active = true
	print("[MasterServerRegistry] 🛰️ Registry ouvindo UDP %d" % listen_port)
	return OK


func start_announce(
	reg_host: String,
	reg_port: int,
	server_name: String,
	public_host: String,
	game_port: int,
	players: int,
	max_players: int,
	region: String,
	version: String = "1.0.0"
) -> Error:
	stop()
	mode = "announce"
	registry_host = reg_host
	registry_port = reg_port
	_udp = PacketPeerUDP.new()
	var err := _udp.set_dest_address(registry_host, registry_port)
	if err != OK:
		push_warning("[MasterServerRegistry] dest announce falhou: %d" % err)
	_announce_payload = "ANNOUNCE|%s|%s|%d|%d|%d|%s|%s|%d" % [
		server_name, public_host, game_port, players, max_players, region, version, Time.get_ticks_msec()
	]
	is_active = true
	_timer = ANNOUNCE_INTERVAL
	_send_raw(_announce_payload)
	return OK


func update_announce_players(players: int) -> void:
	if mode != "announce" or _announce_payload.is_empty():
		return
	var parts := _announce_payload.split("|")
	if parts.size() >= 5:
		parts[4] = str(players)
		if parts.size() > 8:
			parts[8] = str(Time.get_ticks_msec())
		elif parts.size() == 8:
			parts.append(str(Time.get_ticks_msec()))
		_announce_payload = "|".join(parts)
		_send_raw(_announce_payload)
		_timer = 0.0


func query_servers(reg_host: String, reg_port: int = DEFAULT_REGISTRY_PORT) -> Error:
	# One-shot query mode (can reuse socket)
	if _udp == null or mode == "idle":
		_udp = PacketPeerUDP.new()
	mode = "query"
	registry_host = reg_host
	registry_port = reg_port
	_last_query_result.clear()
	var err := _udp.set_dest_address(registry_host, registry_port)
	if err != OK:
		query_failed.emit("dest inválido")
		return err
	is_active = true
	_send_raw("QUERY")
	return OK


func update(delta: float) -> void:
	if not is_active or _udp == null:
		return

	while _udp.get_available_packet_count() > 0:
		var packet := _udp.get_packet()
		var from_ip := _udp.get_packet_ip()
		var from_port := _udp.get_packet_port()
		var text := packet.get_string_from_utf8()
		_handle_packet(text, from_ip, from_port)

	if mode == "registry":
		_expire_servers()
	elif mode == "announce":
		_timer += delta
		if _timer >= ANNOUNCE_INTERVAL:
			_timer = 0.0
			_send_raw(_announce_payload)


func get_server_list() -> Array[Dictionary]:
	if mode == "query":
		return _last_query_result.duplicate(true)
	var out: Array[Dictionary] = []
	for k in _servers.keys():
		out.append(_servers[k])
	return out


func stop() -> void:
	is_active = false
	mode = "idle"
	_announce_payload = ""
	_servers.clear()
	if _udp != null:
		_udp.close()
		_udp = null


func _send_raw(text: String) -> void:
	if _udp == null or text.is_empty():
		return
	_udp.put_packet(text.to_utf8_buffer())


func _handle_packet(text: String, from_ip: String, from_port: int) -> void:
	if text.begins_with("ANNOUNCE|") or text.begins_with("HEARTBEAT|"):
		if mode != "registry":
			return
		_ingest_announce(text, from_ip)
	elif text == "QUERY":
		if mode != "registry":
			return
		_reply_list(from_ip, from_port)
	elif text == "LIST_BEGIN":
		if mode == "query":
			_last_query_result.clear()
	elif text.begins_with("ENTRY|"):
		if mode == "query":
			var info := _parse_entry(text)
			if not info.is_empty():
				_last_query_result.append(info)
	elif text == "LIST_END":
		if mode == "query":
			servers_updated.emit(get_server_list())
			is_active = false


func _ingest_announce(text: String, from_ip: String) -> void:
	var parts := text.split("|")
	if parts.size() < 6:
		return
	var s_name := parts[1]
	var host := parts[2]
	if host.is_empty() or host == "0.0.0.0" or host == "*":
		host = from_ip
	var port := int(parts[3])
	var players := int(parts[4])
	var max_p := int(parts[5]) if parts.size() > 5 else 16
	var region := parts[6] if parts.size() > 6 else ""
	var version := parts[7] if parts.size() > 7 else ""
	var key := "%s:%d" % [host, port]
	_servers[key] = {
		"id": key,
		"name": s_name,
		"host": host,
		"port": port,
		"players": players,
		"max_players": max_p,
		"region": region,
		"version": version,
		"last_seen_ms": Time.get_ticks_msec(),
		"source": "master"
	}
	servers_updated.emit(get_server_list())


func _parse_entry(text: String) -> Dictionary:
	var parts := text.split("|")
	if parts.size() < 6:
		return {}
	return {
		"id": "%s:%s" % [parts[2], parts[3]],
		"name": parts[1],
		"host": parts[2],
		"port": int(parts[3]),
		"players": int(parts[4]),
		"max_players": int(parts[5]),
		"region": parts[6] if parts.size() > 6 else "",
		"version": parts[7] if parts.size() > 7 else "",
		"source": "master"
	}


func _reply_list(to_ip: String, to_port: int) -> void:
	if _udp == null:
		return
	_udp.set_dest_address(to_ip, to_port)
	_udp.put_packet("LIST_BEGIN".to_utf8_buffer())
	for k in _servers.keys():
		var s: Dictionary = _servers[k]
		var line := "ENTRY|%s|%s|%d|%d|%d|%s|%s|%d" % [
			s.get("name", "Server"),
			s.get("host", ""),
			int(s.get("port", 7777)),
			int(s.get("players", 0)),
			int(s.get("max_players", 16)),
			s.get("region", ""),
			s.get("version", ""),
			Time.get_ticks_msec()
		]
		_udp.put_packet(line.to_utf8_buffer())
	_udp.put_packet("LIST_END".to_utf8_buffer())


func _expire_servers() -> void:
	var now := Time.get_ticks_msec()
	var to_del: Array = []
	for k in _servers.keys():
		var age := float(now - int(_servers[k].get("last_seen_ms", now))) / 1000.0
		if age > SERVER_TTL_SEC:
			to_del.append(k)
	for k in to_del:
		_servers.erase(k)
	if not to_del.is_empty():
		servers_updated.emit(get_server_list())
