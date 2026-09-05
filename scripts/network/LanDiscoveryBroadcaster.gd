class_name LanDiscoveryBroadcaster
extends RefCounted

# ============================================================
# HUNTER ONLINE — LAN DISCOVERY BROADCASTER (FASE K-LAN)
# ============================================================
#
# Emite beacons UDP periódicos na rede local (255.255.255.255)
# para que clientes em LAN / Wi-Fi encontrem o servidor automaticamente.
# ============================================================

const BEACON_INTERVAL: float = 1.5

var _udp: PacketPeerUDP = null
var _discovery_port: int = 7778
var _timer: float = 0.0
var is_broadcasting: bool = false
var _beacon_message: String = ""


func start_broadcast(
	server_name: String,
	game_port: int,
	players: int,
	max_players: int,
	region: String,
	discovery_port: int = 7778
) -> Error:
	stop_broadcast()
	_discovery_port = discovery_port
	_udp = PacketPeerUDP.new()
	_udp.set_broadcast_enabled(true)
	var err = _udp.set_dest_address("255.255.255.255", _discovery_port)
	if err != OK:
		push_warning("[LanDiscoveryBroadcaster] Falha ao configurar endereço de broadcast: Erro %d" % err)

	update_beacon(server_name, game_port, players, max_players, region)
	is_broadcasting = true
	_timer = BEACON_INTERVAL
	send_beacon()
	return OK


func update_beacon(
	server_name: String,
	game_port: int,
	players: int,
	max_players: int,
	region: String
) -> void:
	# Protocolo de Beacon: HUNTER_LAN_SERVER|server_name|port|players|max_players|region|timestamp
	_beacon_message = "HUNTER_LAN_SERVER|%s|%d|%d|%d|%s|%d" % [
		server_name,
		game_port,
		players,
		max_players,
		region,
		Time.get_ticks_msec()
	]


func update(delta: float) -> void:
	if not is_broadcasting or _udp == null:
		return

	_timer += delta
	if _timer >= BEACON_INTERVAL:
		_timer = 0.0
		send_beacon()


func send_beacon() -> void:
	if _udp == null or _beacon_message.is_empty():
		return

	var packet: PackedByteArray = _beacon_message.to_utf8_buffer()
	_udp.put_packet(packet)


func stop_broadcast() -> void:
	is_broadcasting = false
	if _udp != null:
		_udp.close()
		_udp = null
