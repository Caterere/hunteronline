extends Node

# ============================================================
# HUNTER ONLINE — NETWORK MANAGER (CENTRAL CO-OP & DEDICATED SERVER)
# ============================================================
#
# Autoload Singleton mestre do subsistema de rede:
# - Coordenador de ciclo de vida do multiplayer (Offline, Host, Cliente, Servidor Dedicado)
# - Despachante de RPCs autoritativos e replicação de snapshots de mundo
# - Motor de Handshake e validação de versões (GAME, CONTENT, PROTOCOL)
# - Broadcaster & Listener de descoberta LAN / VPN (Radmin VPN)
# - Persistência no Servidor e Coordenação de IA/Combate Server-Side
# - Monitor de latência contínua (RTT / Ping)
# - Integrado com AntiCheatValidator, PartyManager e ServerStorageManager
# ============================================================

const ConnectionManagerScript = preload("res://scripts/network/ConnectionManager.gd")
const NetworkSessionScript = preload("res://scripts/network/NetworkSession.gd")
const AntiCheatValidatorScript = preload("res://scripts/network/AntiCheatValidator.gd")
const PlayerNetworkStateScript = preload("res://scripts/network/PlayerNetworkState.gd")
const ServerConfigScript = preload("res://scripts/network/ServerConfig.gd")
const LanDiscoveryBroadcasterScript = preload("res://scripts/network/LanDiscoveryBroadcaster.gd")
const LanDiscoveryListenerScript = preload("res://scripts/network/LanDiscoveryListener.gd")
const ServerStorageManagerScript = preload("res://scripts/network/ServerStorageManager.gd")
const ServerWorldCoordinatorScript = preload("res://scripts/network/ServerWorldCoordinator.gd")
const MasterServerRegistryScript = preload("res://scripts/network/MasterServerRegistry.gd")
const ContentVersionConfigScript = preload("res://scripts/core/ContentVersionConfig.gd")

enum NetworkMode {
	OFFLINE_SINGLEPLAYER,
	HOST_LISTEN,
	CLIENT_PEER,
	DEDICATED_SERVER
}

var current_mode: NetworkMode = NetworkMode.OFFLINE_SINGLEPLAYER
var local_peer_id: int = 1

var connection_manager = null
var session = null
var anti_cheat = null

# Componentes do Servidor Dedicado (Fase K-LAN)
var server_config: Variant = null # ServerConfig
var discovery_broadcaster: Variant = null # LanDiscoveryBroadcaster
var discovery_listener: Variant = null # LanDiscoveryListener
var server_storage: Variant = null # ServerStorageManager
var world_coordinator: Variant = null # ServerWorldCoordinator
var master_registry: Variant = null # MasterServerRegistry (announce ou processo registry)
var client_password_input: String = ""

# peer_id -> NetworkPlayer
var remote_players: Dictionary = {}
# net_id -> NetworkEnemyProxy
var remote_enemies: Dictionary = {}
# peer_id -> PlayerNetworkState
var last_states: Dictionary = {}
## PREREQ-2: peers desmaiados (visíveis para revive)
var _downed_peers: Dictionary = {} # peer_id -> true
var _revive_prompt_peer: int = -1
var _local_revive_channeling: bool = false

var _snapshot_timer: float = 0.0
const SNAPSHOT_INTERVAL: float = 0.05 # 20 Hz
var _ping_timer: float = 0.0
const PING_INTERVAL: float = 2.0
var _demo_enemies_seeded: bool = false
var _last_snapshot_send_msec: int = 0
var _snapshot_bytes_sent: int = 0
var _snapshot_bytes_raw: int = 0
var _snapshot_bytes_recv: int = 0
var _snapshot_packets_sent: int = 0
var _snapshot_packets_recv: int = 0
var _snapshot_sec_timer: float = 0.0
var _snapshot_bytes_sent_sec_acc: int = 0
var _snapshot_bytes_raw_sec_acc: int = 0
var _snapshot_packets_sent_sec_acc: int = 0
var _snapshot_bytes_sent_per_sec: int = 0
var _snapshot_bytes_raw_per_sec: int = 0
var _snapshot_packets_sent_per_sec: int = 0
var _snapshot_compress_hits: int = 0
var _snapshot_compress_skips: int = 0

# Sinais de Ciclo de Vida da Rede (Fase K-LAN)
signal handshake_completed(success: bool, reason: String)
signal player_joined_session(peer_id: int, player_data: Dictionary)
signal player_left_session(peer_id: int)
signal world_snapshot_received(snapshot: Dictionary)
signal combat_hits_confirmed(hits: Array)
signal chat_message_received(sender_name: String, channel: String, message: String)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	connection_manager = ConnectionManagerScript.new()
	session = NetworkSessionScript.new()
	anti_cheat = AntiCheatValidatorScript.new()

	_conectar_sinais_multiplayer()
	if not player_joined_session.is_connected(_on_player_joined_spawn_puppet):
		player_joined_session.connect(_on_player_joined_spawn_puppet)
	if not combat_hits_confirmed.is_connected(_on_combat_hits_confirmed):
		combat_hits_confirmed.connect(_on_combat_hits_confirmed)
	print("=================================")
	print("[NetworkManager] MOTOR DE REDE INICIALIZADO (MODO: OFFLINE)")
	print("=================================")


func is_offline_singleplayer() -> bool:
	return current_mode == NetworkMode.OFFLINE_SINGLEPLAYER


func is_server_authoritative() -> bool:
	return current_mode == NetworkMode.HOST_LISTEN or current_mode == NetworkMode.DEDICATED_SERVER


func is_dedicated_server() -> bool:
	return current_mode == NetworkMode.DEDICATED_SERVER


func _conectar_sinais_multiplayer() -> void:
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)
	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.connect(_on_server_disconnected)


# ============================================================
# CICLO DE CONEXÃO — HOST, CLIENTE & SERVIDOR DEDICADO
# ============================================================

func iniciar_host(porta: int = ConnectionManagerScript.PADRAO_PORTA, max_jogadores: int = 4, nome_sala: String = "Lobby de Caçada") -> Error:
	var err: Error = connection_manager.iniciar_servidor(porta, max_jogadores)
	if err != OK:
		push_error("[NetworkManager] Falha ao iniciar host na porta %d: Erro %d" % [porta, err])
		return err

	multiplayer.multiplayer_peer = connection_manager.peer
	current_mode = NetworkMode.HOST_LISTEN
	local_peer_id = 1

	session.limpar()
	session.room_name = nome_sala
	session.max_players = max_jogadores
	session.adicionar_peer(1, _obter_dados_jogador_local())

	print("[NetworkManager] 🌐 Host iniciado com sucesso na porta %d!" % porta)
	return OK


func iniciar_servidor_dedicado(cfg: Variant = null) -> Error:
	if cfg == null:
		cfg = ServerConfigScript.load_from_file()
	if cfg.has_method("apply_cmdline_args"):
		cfg.apply_cmdline_args()

	server_config = cfg
	var err: Error = connection_manager.iniciar_servidor(cfg.port, cfg.max_players)
	if err != OK:
		push_error("[HunterServer] ❌ Falha ao iniciar socket ENet na porta %d: Erro %d" % [cfg.port, err])
		return err

	multiplayer.multiplayer_peer = connection_manager.peer
	current_mode = NetworkMode.DEDICATED_SERVER
	local_peer_id = 1

	session.limpar()
	session.room_name = cfg.server_name
	session.max_players = cfg.max_players

	# Inicializar Storage e Coordinator no servidor
	server_storage = ServerStorageManagerScript.new(cfg.save_path)
	world_coordinator = ServerWorldCoordinatorScript.new(cfg.tick_rate, cfg.starting_map)
	world_coordinator.interest_radius_default = float(cfg.interest_radius)
	world_coordinator.use_snapshot_delta = bool(cfg.snapshot_delta)
	world_coordinator.snapshot_ready.connect(_on_server_snapshot_ready)
	if not world_coordinator.player_damaged.is_connected(_on_server_player_damaged):
		world_coordinator.player_damaged.connect(_on_server_player_damaged)
	if not world_coordinator.entity_died.is_connected(_on_server_entity_died):
		world_coordinator.entity_died.connect(_on_server_entity_died)
	if not world_coordinator.player_died.is_connected(_on_server_player_died):
		world_coordinator.player_died.connect(_on_server_player_died)
	if not world_coordinator.player_respawned.is_connected(_on_server_player_respawned):
		world_coordinator.player_respawned.connect(_on_server_player_respawned)
	if world_coordinator.has_signal("ally_revive_started") and not world_coordinator.ally_revive_started.is_connected(_on_server_ally_revive_started):
		world_coordinator.ally_revive_started.connect(_on_server_ally_revive_started)
		world_coordinator.ally_revive_progress.connect(_on_server_ally_revive_progress)
		world_coordinator.ally_revive_cancelled.connect(_on_server_ally_revive_cancelled)
		world_coordinator.ally_revive_completed.connect(_on_server_ally_revive_completed)
	world_coordinator.start_coordinator()
	_seed_demo_enemies_if_needed()

	# Iniciar Broadcaster de Descoberta LAN (desligar em VPS / host público)
	if bool(cfg.enable_lan_discovery):
		discovery_broadcaster = LanDiscoveryBroadcasterScript.new()
		discovery_broadcaster.start_broadcast(
			cfg.server_name,
			cfg.port,
			0,
			cfg.max_players,
			cfg.region,
			cfg.discovery_port
		)
	else:
		discovery_broadcaster = null
		print("[HunterServer] LAN discovery desabilitado (modo host/VPS).")

	_iniciar_master_announce_se_habilitado(cfg)

	print("\n============================================================")
	print("                HUNTER MMORPG DEDICATED SERVER              ")
	print("============================================================")
	print("Status: ONLINE")
	print("Server Name: %s" % cfg.server_name)
	print("Listening Port: %d (ENet UDP)" % cfg.port)
	print("Bind Address: %s" % cfg.bind_address)
	if not str(cfg.public_host).is_empty():
		print("Public Host: %s" % cfg.public_host)
	print("Interest Radius: %.0f px | Delta Snapshots: %s" % [cfg.interest_radius, str(cfg.snapshot_delta)])
	print("Snapshot Send: %.1f Hz | Compress: %s" % [float(cfg.snapshot_send_hz), str(cfg.snapshot_compress)])
	print("Discovery Port: %d (UDP Broadcast) [%s]" % [cfg.discovery_port, "ON" if cfg.enable_lan_discovery else "OFF"])
	if bool(cfg.enable_master_announce):
		print("Master Announce: %s:%d" % [cfg.master_registry_host, int(cfg.master_registry_port)])
	print("Max Players: %d" % cfg.max_players)
	print("Tick Rate: %d TPS" % cfg.tick_rate)
	print("Save Path: %s" % cfg.save_path)
	print("Region / Map: %s" % cfg.starting_map)
	print("Waiting for hunter connections...")
	print("============================================================\n")
	return OK


func iniciar_master_registry(listen_port: int = 7780) -> Error:
	if master_registry != null and master_registry.is_active:
		master_registry.stop()
	master_registry = MasterServerRegistryScript.new()
	var err: Error = master_registry.start_registry(listen_port)
	if err != OK:
		push_error("[NetworkManager] Falha ao iniciar Master Registry na porta %d: %d" % [listen_port, err])
		master_registry = null
	return err


func _iniciar_master_announce_se_habilitado(cfg: Variant) -> void:
	if cfg == null or not bool(cfg.enable_master_announce):
		return
	var public_host: String = str(cfg.public_host).strip_edges()
	if public_host.is_empty():
		public_host = _obter_ip_local_preferencial()
	if master_registry != null and master_registry.is_active:
		master_registry.stop()
	master_registry = MasterServerRegistryScript.new()
	var err: Error = master_registry.start_announce(
		str(cfg.master_registry_host),
		int(cfg.master_registry_port),
		str(cfg.server_name),
		public_host,
		int(cfg.port),
		session.peers.size() if session != null else 0,
		int(cfg.max_players),
		str(cfg.region),
		ContentVersionConfigScript.GAME_VERSION if ContentVersionConfigScript != null else "1.0.0"
	)
	if err != OK:
		push_warning("[HunterServer] Master announce falhou: %d" % err)
	else:
		print("[HunterServer] 📡 Anunciando no master registry %s:%d" % [cfg.master_registry_host, int(cfg.master_registry_port)])


func _obter_ip_local_preferencial() -> String:
	var addrs: PackedStringArray = IP.get_local_addresses()
	for ip in addrs:
		var s := str(ip)
		if s.begins_with("127.") or s.contains(":"):
			continue
		return s
	return "127.0.0.1"


func _atualizar_master_announce_players() -> void:
	if master_registry == null or not master_registry.is_active:
		return
	if str(master_registry.mode) != "announce":
		return
	var count: int = session.peers.size() if session != null else 0
	master_registry.update_announce_players(count)


func conectar_ao_host(ip: String = ConnectionManagerScript.PADRAO_IP, porta: int = ConnectionManagerScript.PADRAO_PORTA) -> Error:
	var err: Error = connection_manager.conectar_cliente(ip, porta)
	if err != OK:
		push_error("[NetworkManager] Falha ao conectar ao host %s:%d: Erro %d" % [ip, porta, err])
		return err

	multiplayer.multiplayer_peer = connection_manager.peer
	current_mode = NetworkMode.CLIENT_PEER
	local_peer_id = connection_manager.obter_peer_id()

	print("[NetworkManager] 🌐 Conectando ao servidor %s:%d..." % [ip, porta])
	return OK


func conectar_com_handshake(ip: String, porta: int, senha: String = "") -> Error:
	client_password_input = senha
	return conectar_ao_host(ip, porta)


func desconectar() -> void:
	if is_offline_singleplayer():
		return

	print("[NetworkManager] 🔌 Desconectando da sessão multiplayer...")
	if is_dedicated_server():
		if discovery_broadcaster != null:
			discovery_broadcaster.stop_broadcast()
			discovery_broadcaster = null
		if world_coordinator != null:
			world_coordinator.stop_coordinator()
			world_coordinator = null

	if master_registry != null:
		# Em modo registry puro, deixar o caller decidir; em announce/dedicated, parar.
		if str(master_registry.mode) == "announce" or is_dedicated_server():
			master_registry.stop()
			master_registry = null

	if discovery_listener != null:
		discovery_listener.stop_listening()

	connection_manager.fechar_conexao()
	multiplayer.multiplayer_peer = null
	current_mode = NetworkMode.OFFLINE_SINGLEPLAYER
	local_peer_id = 1

	for pid in remote_players.keys():
		var p: Node = remote_players[pid]
		if p != null and is_instance_valid(p):
			p.queue_free()
	remote_players.clear()
	_limpar_inimigos_remotos()
	last_states.clear()
	session.limpar()
	_demo_enemies_seeded = false
	_last_snapshot_send_msec = 0
	_reset_snapshot_bandwidth_counters()


func _reset_snapshot_bandwidth_counters() -> void:
	_snapshot_bytes_sent = 0
	_snapshot_bytes_raw = 0
	_snapshot_bytes_recv = 0
	_snapshot_packets_sent = 0
	_snapshot_packets_recv = 0
	_snapshot_sec_timer = 0.0
	_snapshot_bytes_sent_sec_acc = 0
	_snapshot_bytes_raw_sec_acc = 0
	_snapshot_packets_sent_sec_acc = 0
	_snapshot_bytes_sent_per_sec = 0
	_snapshot_bytes_raw_per_sec = 0
	_snapshot_packets_sent_per_sec = 0
	_snapshot_compress_hits = 0
	_snapshot_compress_skips = 0


func reset_snapshot_bandwidth_stats() -> void:
	_reset_snapshot_bandwidth_counters()


func obter_snapshot_bandwidth_stats() -> Dictionary:
	var ratio: float = 1.0
	if _snapshot_bytes_raw > 0:
		ratio = float(_snapshot_bytes_sent) / float(_snapshot_bytes_raw)
	var send_hz: float = 10.0
	if server_config != null:
		send_hz = float(server_config.snapshot_send_hz)
	return {
		"bytes_sent_total": _snapshot_bytes_sent,
		"bytes_raw_total": _snapshot_bytes_raw,
		"bytes_recv_total": _snapshot_bytes_recv,
		"packets_sent_total": _snapshot_packets_sent,
		"packets_recv_total": _snapshot_packets_recv,
		"bytes_sent_per_sec": _snapshot_bytes_sent_per_sec,
		"bytes_raw_per_sec": _snapshot_bytes_raw_per_sec,
		"packets_sent_per_sec": _snapshot_packets_sent_per_sec,
		"compress_ratio": ratio,
		"compress_hits": _snapshot_compress_hits,
		"compress_skips": _snapshot_compress_skips,
		"snapshot_send_hz": send_hz,
		"snapshot_compress": bool(server_config.snapshot_compress) if server_config != null else false
	}


func _limpar_inimigos_remotos() -> void:
	for eid in remote_enemies.keys():
		var n: Node = remote_enemies[eid]
		if n != null and is_instance_valid(n):
			n.queue_free()
	remote_enemies.clear()


func _seed_demo_enemies_if_needed() -> void:
	if _demo_enemies_seeded or world_coordinator == null:
		return
	_demo_enemies_seeded = true
	# Inimigos de demonstração no lobby/mapa inicial para validar combate LAN.
	world_coordinator.spawn_enemy(&"lobo_nen", "Lobo de Nen", Vector2(180, 140), 180, 18, 8, false)
	world_coordinator.spawn_enemy(&"fera_padokia", "Fera de Padokia", Vector2(260, 180), 220, 22, 12, false)
	print("[HunterServer] 🐺 Inimigos demo spawnados no coordenador (2).")


# ============================================================
# CALLBACKS DO MULTIPLAYER API
# ============================================================

func _on_peer_connected(id: int) -> void:
	print("[NetworkManager] Caçador conectado no socket: Peer %d" % id)
	session.adicionar_peer(id)
	if is_server_authoritative():
		# Atualizar contador do beacon se for servidor dedicado
		if is_dedicated_server() and discovery_broadcaster != null and server_config != null:
			discovery_broadcaster.update_beacon(
				server_config.server_name,
				server_config.port,
				session.peers.size(),
				server_config.max_players,
				server_config.region
			)
		_atualizar_master_announce_players()
		rpc_id(id, "rpc_sincronizar_sessao", session.room_name, session.max_players)


func _on_peer_disconnected(id: int) -> void:
	print("[NetworkManager] Caçador desconectado do socket: Peer %d" % id)

	# Se for servidor dedicado, salvar estado do jogador e limpar coordenador
	if is_dedicated_server():
		if world_coordinator != null:
			var removed_entity = world_coordinator.unregister_player(id)
			var char_id = str(removed_entity.get("character_id", ""))
			if server_storage != null and not char_id.is_empty():
				server_storage.unload_player(char_id)

		if discovery_broadcaster != null and server_config != null:
			discovery_broadcaster.update_beacon(
				server_config.server_name,
				server_config.port,
				max(0, session.peers.size() - 1),
				server_config.max_players,
				server_config.region
			)
		if master_registry != null and master_registry.is_active and str(master_registry.mode) == "announce":
			master_registry.update_announce_players(max(0, session.peers.size() - 1))

		# Notificar todos os clientes remanescentes
		rpc("rpc_notificar_jogador_desconectado", id)

	session.remover_peer(id)
	if anti_cheat != null:
		anti_cheat.limpar_peer(id)
	remover_jogador_remoto(id)
	player_left_session.emit(id)


func _on_connected_to_server() -> void:
	local_peer_id = multiplayer.get_unique_id()
	print("[NetworkManager] ✅ Conectado com sucesso ao servidor! Nosso Peer ID: %d" % local_peer_id)

	# Enviar pacote formal de handshake
	var p_data = _obter_dados_jogador_local()
	var auth_packet: Dictionary = {
		"protocol_version": 1,
		"game_version": ContentVersionConfigScript.GAME_VERSION,
		"content_version": ContentVersionConfigScript.CONTENT_VERSION,
		"nickname": p_data.get("name", "Hunter"),
		"password": client_password_input,
		"character_id": str(PlayerData.character_id) if PlayerData != null else "hunter_%d" % local_peer_id,
		"attributes": p_data,
		"tecnica_nen_ativa": str(PlayerData.quest_states.get("tecnica_nen_ativa", "TEN")) if PlayerData != null else "TEN"
	}
	rpc_id(1, "rpc_requisitar_handshake", auth_packet)


func _on_connection_failed() -> void:
	push_warning("[NetworkManager] ❌ Falha na conexão com o servidor.")
	handshake_completed.emit(false, "Falha ao conectar no IP/Porta do servidor.")
	desconectar()


func _on_server_disconnected() -> void:
	print("[NetworkManager] ⚠️ Servidor encerrou a sessão.")
	handshake_completed.emit(false, "Servidor encerrou a conexão.")
	desconectar()


# ============================================================
# GERENCIAMENTO DE PUPPETS / JOGADORES REMOTOS
# ============================================================

func registrar_jogador_remoto(peer_id: int, puppet: Node) -> void:
	if puppet == null or peer_id == local_peer_id:
		return
	remote_players[peer_id] = puppet


func remover_jogador_remoto(peer_id: int) -> void:
	if remote_players.has(peer_id):
		var node = remote_players[peer_id]
		if node != null and is_instance_valid(node):
			node.queue_free()
		remote_players.erase(peer_id)


func obter_jogador_remoto(peer_id: int) -> Node:
	return remote_players.get(peer_id, null)


# ============================================================
# PROCESSAMENTO & SNAPSHOT DISPATCH
# ============================================================

func _physics_process(delta: float) -> void:
	# Master registry (modo registry puro ou announce) roda mesmo offline.
	if master_registry != null and master_registry.is_active:
		master_registry.update(delta)

	_atualizar_snapshot_bandwidth_janela(delta)

	if is_offline_singleplayer():
		return

	# Servidor Dedicado
	if is_dedicated_server():
		if world_coordinator != null:
			world_coordinator.tick(delta)
		if discovery_broadcaster != null:
			discovery_broadcaster.update(delta)
		return

	# Cliente ou Host de Gameplay
	_snapshot_timer += delta
	if _snapshot_timer >= SNAPSHOT_INTERVAL:
		_snapshot_timer = 0.0
		_enviar_snapshot_local()

	_ping_timer += delta
	if _ping_timer >= PING_INTERVAL:
		_ping_timer = 0.0
		if not is_server_authoritative() and connection_manager.esta_ativo():
			rpc_id(1, "rpc_ping", Time.get_ticks_msec())

	if discovery_listener != null and discovery_listener.is_listening:
		discovery_listener.update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if is_offline_singleplayer() or is_dedicated_server():
		return
	if current_mode != NetworkMode.CLIENT_PEER:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if _local_revive_channeling:
				cancelar_revive_local()
			else:
				tentar_revive_aliado_proximo()
			get_viewport().set_input_as_handled()


func _atualizar_snapshot_bandwidth_janela(delta: float) -> void:
	if _snapshot_packets_sent == 0 and _snapshot_bytes_sent == 0 and _snapshot_sec_timer <= 0.0:
		return
	_snapshot_sec_timer += delta
	if _snapshot_sec_timer < 1.0:
		return
	_snapshot_bytes_sent_per_sec = _snapshot_bytes_sent_sec_acc
	_snapshot_bytes_raw_per_sec = _snapshot_bytes_raw_sec_acc
	_snapshot_packets_sent_per_sec = _snapshot_packets_sent_sec_acc
	_snapshot_bytes_sent_sec_acc = 0
	_snapshot_bytes_raw_sec_acc = 0
	_snapshot_packets_sent_sec_acc = 0
	_snapshot_sec_timer = 0.0


func _obter_dados_jogador_local() -> Dictionary:
	var info := {
		"name": "Hunter",
		"level": 1,
		"affinity": "Intensificação",
		"hp": 100,
		"hp_max": 100,
		"aura": 100.0,
		"aura_max": 100.0
	}
	if PlayerData != null:
		info["name"] = PlayerData.nome_personagem if "nome_personagem" in PlayerData and not PlayerData.nome_personagem.is_empty() else "Hunter"
		info["level"] = int(PlayerData.attributes.get("nivel", 1))
		info["affinity"] = str(PlayerData.afinidade_primaria) if "afinidade_primaria" in PlayerData else "Intensificação"
		info["hp"] = int(PlayerData.attributes.get("vida", 100))
		info["hp_max"] = int(PlayerData.attributes.get("vida_max", 100))
		info["aura"] = float(PlayerData.attributes.get("aura", 100.0))
		info["aura_max"] = float(PlayerData.attributes.get("aura_max", 100.0))
	return info


func _enviar_snapshot_local() -> void:
	var player = GameManager.active_player if GameManager != null else null
	if player == null or not is_instance_valid(player):
		return

	# Cliente em servidor dedicado: autoridade é o servidor — só envia intenções.
	if current_mode == NetworkMode.CLIENT_PEER:
		var move_dir: Vector2 = player.velocity.normalized() if player.velocity != Vector2.ZERO else Vector2.ZERO
		var facing_dir: Vector2 = player._direcao_olhar if "_direcao_olhar" in player else Vector2.DOWN
		var nen_tech: String = ""
		if PlayerData != null:
			nen_tech = str(PlayerData.quest_states.get("tecnica_nen_ativa", ""))
		rpc_id(1, "rpc_enviar_intencao_input", move_dir, facing_dir, nen_tech)
		return

	var state = PlayerNetworkStateScript.new()
	state.peer_id = local_peer_id
	state.position = player.global_position
	state.velocity = player.velocity
	state.facing = player._direcao_olhar if "_direcao_olhar" in player else Vector2.DOWN
	state.is_sprinting = player.esta_em_sprint() if player.has_method("esta_em_sprint") else false
	state.animation = "walk" if player.velocity.length() > 5.0 else "idle"

	if PlayerData != null:
		state.hp = int(PlayerData.attributes.get("vida", 100))
		state.hp_max = int(PlayerData.attributes.get("vida_max", 100))
		state.aura = float(PlayerData.attributes.get("aura", 100.0))
		state.aura_max = float(PlayerData.attributes.get("aura_max", 100.0))
		state.active_nen = str(PlayerData.quest_states.get("tecnica_nen_ativa", ""))

	# Host listen / peer-to-peer legado
	rpc("rpc_receber_snapshot", state.to_dict())


# ============================================================
# RPCS DE HANDSHAKE & AUTORIZAÇÃO (K-LAN 9)
# ============================================================

@rpc("any_peer", "call_remote", "reliable")
func rpc_requisitar_handshake(auth_data: Dictionary) -> void:
	if not is_server_authoritative():
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	var g_ver = str(auth_data.get("game_version", ""))
	var passw = str(auth_data.get("password", ""))
	var nick = str(auth_data.get("nickname", "Hunter_%d" % sender_id))
	var c_id = str(auth_data.get("character_id", "hunter_%d" % sender_id))

	# 1. Validação de Versão do Jogo
	if g_ver != ContentVersionConfigScript.GAME_VERSION:
		rpc_id(sender_id, "rpc_handshake_rejeitado", "Incompatibilidade de versão: Servidor (%s) vs Cliente (%s)" % [ContentVersionConfigScript.GAME_VERSION, g_ver])
		return

	# 2. Validação de Senha (se exigida no ServerConfig)
	if server_config != null and not server_config.server_password.is_empty():
		if passw != server_config.server_password:
			rpc_id(sender_id, "rpc_handshake_rejeitado", "Senha incorreta para este servidor.")
			return

	# 3. Validação de Capacidade Máxima
	var max_cap: int = server_config.max_players if server_config != null else session.max_players
	if session.peers.size() >= max_cap:
		rpc_id(sender_id, "rpc_handshake_rejeitado", "Servidor lotado (%d/%d jogadores)." % [session.peers.size(), max_cap])
		return

	# Registro de sucesso — normalizar nickname → name para sessão/puppets
	var attrs = auth_data.get("attributes", {})
	if not (attrs is Dictionary):
		attrs = {}
	var normalized: Dictionary = auth_data.duplicate(true)
	normalized["name"] = nick
	normalized["nickname"] = nick
	normalized["character_id"] = c_id
	if attrs is Dictionary:
		normalized["level"] = int(attrs.get("nivel", attrs.get("level", 1)))
		normalized["hp"] = int(attrs.get("vida", attrs.get("hp", 100)))
		normalized["hp_max"] = int(attrs.get("vida_max", attrs.get("hp_max", 100)))
		normalized["aura"] = float(attrs.get("aura", 100.0))
		normalized["aura_max"] = float(attrs.get("aura_max", 100.0))
	session.adicionar_peer(sender_id, normalized)

	var spawn_pos := Vector2(100, 100)
	if is_dedicated_server():
		if server_storage != null:
			var saved = server_storage.load_player_state(c_id)
			if not saved.is_empty() and saved.has("position"):
				var p_arr = saved["position"]
				if p_arr is Array and p_arr.size() >= 2:
					spawn_pos = Vector2(float(p_arr[0]), float(p_arr[1]))
			else:
				server_storage.save_player_state(c_id, normalized)

		if world_coordinator != null:
			world_coordinator.register_player(sender_id, normalized, spawn_pos)

	# Preparar lista de jogadores existentes com posições reais do coordenador
	var existing: Array = []
	for pid in session.peers.keys():
		if pid != sender_id:
			var peer_pos := spawn_pos
			if world_coordinator != null and world_coordinator.players.has(pid):
				peer_pos = world_coordinator.get_player_position(pid)
			existing.append({
				"peer_id": pid,
				"info": session.obter_peer_info(pid),
				"pos": [peer_pos.x, peer_pos.y]
			})

	var s_meta: Dictionary = {
		"server_name": server_config.server_name if server_config != null else session.room_name,
		"tick_rate": server_config.tick_rate if server_config != null else 20,
		"starting_map": server_config.starting_map if server_config != null else session.current_map_path,
		"motd": server_config.motd if server_config != null else "",
		"region": server_config.region if server_config != null else "",
		"public_host": server_config.public_host if server_config != null else "",
		"interest_radius": server_config.interest_radius if server_config != null else 900.0
	}

	rpc_id(sender_id, "rpc_handshake_aceito", s_meta, spawn_pos, existing)
	rpc("rpc_notificar_jogador_conectado", sender_id, normalized, spawn_pos)
	print("[NetworkManager] 🤝 Handshake aceito com sucesso para %s (Peer %d)" % [nick, sender_id])


@rpc("authority", "call_remote", "reliable")
func rpc_handshake_aceito(server_meta: Dictionary, spawn_pos: Vector2, existing_players: Array) -> void:
	print("[NetworkManager] 🎉 Conexão autorizada pelo servidor: %s" % server_meta.get("server_name", ""))
	if server_meta.has("starting_map"):
		session.current_map_path = str(server_meta.get("starting_map", session.current_map_path))
	handshake_completed.emit(true, "")

	# Atualizar posição inicial do player local se aplicável
	var player = GameManager.active_player if GameManager != null else null
	if player != null and is_instance_valid(player):
		player.global_position = spawn_pos

	# Instanciar puppets dos jogadores pré-existentes
	for entry in existing_players:
		var pid = int(entry.get("peer_id", 0))
		var info = entry.get("info", {})
		if info is Dictionary:
			info = info.duplicate(true)
			if entry.has("pos") and entry["pos"] is Array and entry["pos"].size() >= 2:
				info["spawn_pos"] = Vector2(float(entry["pos"][0]), float(entry["pos"][1]))
		player_joined_session.emit(pid, info)


@rpc("authority", "call_remote", "reliable")
func rpc_handshake_rejeitado(motivo: String) -> void:
	push_warning("[NetworkManager] ⛔ Conexão recusada pelo servidor: %s" % motivo)
	handshake_completed.emit(false, motivo)
	desconectar()


@rpc("authority", "call_remote", "reliable")
func rpc_notificar_jogador_conectado(peer_id: int, info: Dictionary, pos: Vector2) -> void:
	if peer_id == local_peer_id:
		return
	var normalized: Dictionary = info.duplicate(true) if info is Dictionary else {}
	if not normalized.has("name"):
		normalized["name"] = normalized.get("nickname", "Hunter_%d" % peer_id)
	normalized["spawn_pos"] = pos
	print("[NetworkManager] Caçador entrou no mundo: %s (Peer %d)" % [normalized.get("name", "Hunter"), peer_id])
	session.adicionar_peer(peer_id, normalized)
	player_joined_session.emit(peer_id, normalized)


@rpc("authority", "call_remote", "reliable")
func rpc_notificar_jogador_desconectado(peer_id: int) -> void:
	if peer_id == local_peer_id:
		return
	print("[NetworkManager] Caçador saiu do mundo: Peer %d" % peer_id)
	session.remover_peer(peer_id)
	remover_jogador_remoto(peer_id)
	player_left_session.emit(peer_id)


# ============================================================
# SNAPSHOT DE MUNDO DO SERVIDOR DEDICADO
# ============================================================

func _on_server_snapshot_ready(_snapshot: Dictionary) -> void:
	if not is_server_authoritative() or world_coordinator == null:
		return

	# Cap de taxa de envio (ticks de simulação podem ser mais altos)
	var send_hz: float = 10.0
	if server_config != null:
		send_hz = maxf(1.0, float(server_config.snapshot_send_hz))
	var min_interval_ms: float = 1000.0 / send_hz
	var now_ms: int = Time.get_ticks_msec()
	if _last_snapshot_send_msec > 0 and float(now_ms - _last_snapshot_send_msec) < min_interval_ms:
		return
	_last_snapshot_send_msec = now_ms

	# Dedicated: snapshot por peer (AoI + delta). Host listen: broadcast full.
	if is_dedicated_server():
		var radius: float = float(server_config.interest_radius) if server_config != null else 900.0
		for peer_id in session.peers.keys():
			var peer_snap: Dictionary = world_coordinator.build_interest_snapshot(int(peer_id), radius)
			# Evita enviar pacote vazio (sem mudanças) em modo delta
			if not bool(peer_snap.get("full", false)):
				var has_data: bool = (
					(peer_snap.get("players", []) as Array).size() > 0
					or (peer_snap.get("enemies", []) as Array).size() > 0
					or (peer_snap.get("removed_players", []) as Array).size() > 0
					or (peer_snap.get("removed_enemies", []) as Array).size() > 0
				)
				if not has_data:
					continue
			_enviar_snapshot_para_peer(int(peer_id), peer_snap)
	else:
		_enviar_snapshot_para_peer(0, world_coordinator.build_world_snapshot())


func _enviar_snapshot_para_peer(peer_id: int, snap: Dictionary) -> void:
	var use_compress: bool = server_config != null and bool(server_config.snapshot_compress)
	var min_bytes: int = int(server_config.snapshot_compress_min_bytes) if server_config != null else 256
	var payload_size: int = 0
	var raw_size: int = 0

	if use_compress:
		var raw: PackedByteArray = var_to_bytes(snap)
		raw_size = raw.size()
		_snapshot_bytes_raw += raw_size
		_snapshot_bytes_raw_sec_acc += raw_size
		if raw_size >= min_bytes:
			var compressed: PackedByteArray = raw.compress(FileAccess.COMPRESSION_DEFLATE)
			# Só envia comprimido se valer a pena
			if compressed.size() > 0 and compressed.size() < raw_size:
				payload_size = compressed.size()
				_snapshot_bytes_sent += payload_size
				_snapshot_bytes_sent_sec_acc += payload_size
				_snapshot_packets_sent += 1
				_snapshot_packets_sent_sec_acc += 1
				_snapshot_compress_hits += 1
				if peer_id > 0:
					rpc_id(peer_id, "rpc_receber_snapshot_mundo_comprimido", compressed)
				else:
					rpc("rpc_receber_snapshot_mundo_comprimido", compressed)
				return
		_snapshot_compress_skips += 1
		payload_size = raw_size
		_snapshot_bytes_sent += payload_size
		_snapshot_bytes_sent_sec_acc += payload_size
		_snapshot_packets_sent += 1
		_snapshot_packets_sent_sec_acc += 1
		if peer_id > 0:
			rpc_id(peer_id, "rpc_receber_snapshot_mundo", snap)
		else:
			rpc("rpc_receber_snapshot_mundo", snap)
		return

	raw_size = var_to_bytes(snap).size()
	payload_size = raw_size
	_snapshot_bytes_raw += raw_size
	_snapshot_bytes_raw_sec_acc += raw_size
	_snapshot_bytes_sent += payload_size
	_snapshot_bytes_sent_sec_acc += payload_size
	_snapshot_packets_sent += 1
	_snapshot_packets_sent_sec_acc += 1
	_snapshot_compress_skips += 1
	if peer_id > 0:
		rpc_id(peer_id, "rpc_receber_snapshot_mundo", snap)
	else:
		rpc("rpc_receber_snapshot_mundo", snap)


@rpc("authority", "call_local", "unreliable_ordered")
func rpc_receber_snapshot_mundo_comprimido(payload: PackedByteArray) -> void:
	if payload.is_empty():
		return
	_snapshot_bytes_recv += payload.size()
	_snapshot_packets_recv += 1
	var raw: PackedByteArray = payload.decompress_dynamic(-1, FileAccess.COMPRESSION_DEFLATE)
	if raw.is_empty():
		push_warning("[NetworkManager] Falha ao descomprimir snapshot de mundo")
		return
	var snap = bytes_to_var(raw)
	if snap is Dictionary:
		_aplicar_snapshot_mundo(snap)


@rpc("authority", "call_local", "unreliable_ordered")
func rpc_receber_snapshot_mundo(snapshot: Dictionary) -> void:
	_snapshot_bytes_recv += var_to_bytes(snapshot).size()
	_snapshot_packets_recv += 1
	_aplicar_snapshot_mundo(snapshot)


func _aplicar_snapshot_mundo(snapshot: Dictionary) -> void:
	world_snapshot_received.emit(snapshot)

	var is_full: bool = bool(snapshot.get("full", true))

	# Remoções (delta / saiu do AoI)
	var rem_p = snapshot.get("removed_players", [])
	if rem_p is Array:
		for pid_v in rem_p:
			var pid: int = int(pid_v)
			if pid != local_peer_id:
				remover_jogador_remoto(pid)
	var rem_e = snapshot.get("removed_enemies", [])
	if rem_e is Array:
		for eid_v in rem_e:
			var eid: int = int(eid_v)
			if remote_enemies.has(eid):
				var n = remote_enemies[eid]
				if n != null and is_instance_valid(n):
					n.queue_free()
				remote_enemies.erase(eid)

	# Atualizar puppets de outros jogadores (cria se ainda não existir)
	var players_arr = snapshot.get("players", [])
	var seen_players: Dictionary = {}
	if players_arr is Array:
		for p_data in players_arr:
			var pid = int(p_data.get("id", 0))
			seen_players[pid] = true
			if pid == local_peer_id:
				_reconciliar_jogador_local(p_data)
				continue
			if not remote_players.has(pid):
				var spawn_info := {
					"name": session.obter_peer_info(pid).get("name", "Hunter_%d" % pid),
					"spawn_pos": Vector2(float(p_data.get("px", 0.0)), float(p_data.get("py", 0.0)))
				}
				_spawn_puppet_for_peer(pid, spawn_info)
			var puppet = remote_players.get(pid, null)
			if puppet != null and puppet.has_method("aplicar_estado_snapshot"):
				puppet.aplicar_estado_snapshot(p_data)

	_sincronizar_inimigos_remotos(snapshot.get("enemies", []), is_full, seen_players)


func _sincronizar_inimigos_remotos(enemies_arr: Variant, is_full: bool = true, _seen_players: Dictionary = {}) -> void:
	if is_dedicated_server():
		return
	if not (enemies_arr is Array):
		return

	var alive_ids: Dictionary = {}
	for e_data in enemies_arr:
		if not (e_data is Dictionary):
			continue
		var eid: int = int(e_data.get("id", 0))
		if eid <= 0:
			continue
		alive_ids[eid] = true
		if not remote_enemies.has(eid):
			_spawn_enemy_proxy(eid, e_data)
		var proxy = remote_enemies.get(eid, null)
		if proxy != null and is_instance_valid(proxy) and proxy.has_method("aplicar_estado_snapshot"):
			proxy.aplicar_estado_snapshot(e_data)

	# Em snapshot full, despawn proxies ausentes. Em delta, remoções vêm em removed_enemies.
	if is_full:
		var to_remove: Array = []
		for eid in remote_enemies.keys():
			if not alive_ids.has(eid):
				to_remove.append(eid)
		for eid in to_remove:
			var n = remote_enemies[eid]
			if n != null and is_instance_valid(n):
				n.queue_free()
			remote_enemies.erase(eid)


func _spawn_enemy_proxy(net_id: int, data: Dictionary) -> void:
	if remote_enemies.has(net_id) or is_dedicated_server():
		return
	var scene = get_tree().current_scene if get_tree() != null else null
	if scene == null:
		return
	var proxy_script = load("res://scripts/network/NetworkEnemyProxy.gd")
	if proxy_script == null:
		return
	var proxy = proxy_script.new()
	proxy.net_id = net_id
	proxy.name = "RemoteEnemy_%d" % net_id
	proxy.display_name = str(data.get("name", "Beast"))
	proxy.enemy_id = str(data.get("enemy_id", ""))
	proxy.is_boss = bool(data.get("boss", false))
	proxy.hp = int(data.get("hp", 100))
	proxy.hp_max = int(data.get("hp_max", 100))
	var pos := Vector2(float(data.get("px", 0.0)), float(data.get("py", 0.0)))
	proxy.global_position = pos
	proxy.target_position = pos
	scene.add_child(proxy)
	remote_enemies[net_id] = proxy
	print("[NetworkManager] 🐺 Proxy de inimigo spawnado: %s (net %d)" % [proxy.display_name, net_id])


func _on_combat_hits_confirmed(hits: Array) -> void:
	if is_dedicated_server():
		return
	for hit in hits:
		if not (hit is Dictionary):
			continue
		var eid: int = int(hit.get("net_id", 0))
		var proxy = remote_enemies.get(eid, null)
		if proxy == null or not is_instance_valid(proxy):
			continue
		if proxy.has_method("aplicar_hit_confirmado"):
			proxy.aplicar_hit_confirmado(
				int(hit.get("damage", 0)),
				int(hit.get("hp_remaining", 0)),
				bool(hit.get("is_dead", false))
			)
		if bool(hit.get("is_dead", false)):
			remote_enemies.erase(eid)


func _on_server_player_damaged(peer_id: int, damage: int, source_net_id: int, hp_remaining: int, knockback_dir: Vector2) -> void:
	if not is_dedicated_server():
		return
	rpc_id(peer_id, "rpc_aplicar_dano_jogador", damage, source_net_id, hp_remaining, knockback_dir)


func _on_server_entity_died(net_id: int, killer_peer_id: int, rewards: Dictionary) -> void:
	if not is_dedicated_server():
		return
	if killer_peer_id <= 0:
		return
	rpc_id(killer_peer_id, "rpc_recompensa_kill", net_id, rewards)
	# Também avisa todos para VFX de morte do proxy (se ainda existir)
	rpc("rpc_notificar_inimigo_morto", net_id)


@rpc("authority", "call_remote", "reliable")
func rpc_aplicar_dano_jogador(damage: int, source_net_id: int, hp_remaining: int, knockback_dir: Vector2) -> void:
	if is_dedicated_server():
		return
	if PlayerData != null:
		PlayerData.attributes["vida"] = max(0, hp_remaining)
	var player = GameManager.active_player if GameManager != null else null
	if player != null and is_instance_valid(player):
		if player.has_method("receber_dano_rede"):
			player.receber_dano_rede(damage, knockback_dir, source_net_id)
		elif player.has_method("_aplicar_hit_flash"):
			player._aplicar_hit_flash()
		if EventBus != null:
			var hp_max: int = int(PlayerData.attributes.get("vida_max", 100)) if PlayerData != null else 100
			EventBus.player_damaged.emit(hp_remaining, hp_max, damage)
			EventBus.emit_camera_shake(0.30, 0.18)
	if AudioManager != null:
		AudioManager.tocar_hurt()
	print("[NetworkManager] 💥 Dano rede: -%d HP restante %d (src %d)" % [damage, hp_remaining, source_net_id])
	# Morte local é disparada por rpc_jogador_morreu (autoridade do servidor)


func _on_server_player_died(peer_id: int, source_net_id: int) -> void:
	if not is_dedicated_server():
		return
	var death_pos := Vector2.ZERO
	if world_coordinator != null and world_coordinator.players.has(peer_id):
		var p: Dictionary = world_coordinator.players[peer_id]
		death_pos = p.get("downed_pos", p.get("position", Vector2.ZERO)) as Vector2
	rpc_id(peer_id, "rpc_jogador_morreu", source_net_id)
	# Notifica outros clientes com posição do corpo (para prompt [E] e range)
	rpc("rpc_notificar_jogador_estado", peer_id, true, death_pos)


func _on_server_player_respawned(peer_id: int, spawn_pos: Vector2, hp: int, aura: float) -> void:
	if not is_dedicated_server():
		return
	rpc_id(peer_id, "rpc_jogador_respawnou", spawn_pos, hp, aura)
	rpc("rpc_notificar_jogador_estado", peer_id, false, spawn_pos)


@rpc("authority", "call_remote", "reliable")
func rpc_jogador_morreu(source_net_id: int) -> void:
	if is_dedicated_server():
		return
	if PlayerData != null:
		PlayerData.attributes["vida"] = 0
	var player = GameManager.active_player if GameManager != null else null
	if player != null and is_instance_valid(player):
		if player.has_method("travar_controles"):
			player.travar_controles(true)
		var combat = player.get_node_or_null("CombatSystem")
		if combat != null and combat.has_method("morrer"):
			# Evita tela de morte offline duplicada se já estiver morto; usa caminho rede
			if combat.has_method("morrer_rede"):
				combat.morrer_rede()
			else:
				combat.estado = combat.Estado.MORTO
				combat.player_morreu.emit()
	if EventBus != null:
		EventBus.player_died.emit()
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("☠️ Você desmaiou! Aguarde revive aliado ([E]) ou renasça no spawn. (src %d)" % source_net_id)
	print("[NetworkManager] ☠️ Morte/desmaio de rede confirmado (src %d)" % source_net_id)


@rpc("authority", "call_remote", "reliable")
func rpc_jogador_respawnou(spawn_pos: Vector2, hp: int, aura: float) -> void:
	if is_dedicated_server():
		return
	_local_revive_channeling = false
	_revive_prompt_peer = -1
	if PlayerData != null:
		PlayerData.attributes["vida"] = hp
		PlayerData.attributes["aura"] = aura
	var player = GameManager.active_player if GameManager != null else null
	if player != null and is_instance_valid(player):
		if player.has_method("reviver"):
			player.reviver(spawn_pos)
		else:
			player.global_position = spawn_pos
		# Fecha DeathScreen se estiver aberta
		var death_ui = get_tree().root.get_node_or_null("DeathScreenUI") if get_tree() != null else null
		if death_ui != null and death_ui.has_method("esconder"):
			death_ui.esconder()
		elif death_ui != null:
			death_ui.visible = false
			death_ui.queue_free()
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("✨ Em pé novamente! HP/Aura restaurados.")
	print("[NetworkManager] ✨ Respawn/revive de rede em %s (HP %d)" % [str(spawn_pos), hp])


@rpc("any_peer", "call_remote", "reliable")
func rpc_solicitar_respawn() -> void:
	if not is_dedicated_server() or world_coordinator == null:
		return
	var sender_id: int = multiplayer.get_remote_sender_id()
	world_coordinator.request_respawn(sender_id)


@rpc("authority", "call_local", "reliable")
func rpc_notificar_jogador_estado(peer_id: int, is_dead: bool, pos: Vector2) -> void:
	if peer_id == local_peer_id:
		return
	if is_dead:
		_downed_peers[peer_id] = true
	else:
		_downed_peers.erase(peer_id)
	var puppet = remote_players.get(peer_id, null)
	if puppet == null or not is_instance_valid(puppet):
		return
	if puppet.has_method("set_downed"):
		puppet.set_downed(is_dead, pos)
	elif is_dead:
		puppet.modulate = Color(0.5, 0.5, 0.5, 0.55)
		if pos != Vector2.ZERO:
			puppet.global_position = pos
	else:
		puppet.modulate = Color.WHITE
		if pos != Vector2.ZERO:
			puppet.global_position = pos
			if "target_position" in puppet:
				puppet.target_position = pos


## Cliente pede respawn antecipado (botão Renascer / abandonar desmaio).
func solicitar_respawn() -> void:
	if current_mode != NetworkMode.CLIENT_PEER:
		return
	rpc_id(1, "rpc_solicitar_respawn")


# ============================================================
# PREREQ-2 — REVIVE DE ALIADOS
# ============================================================


func _on_server_ally_revive_started(reviver_id: int, target_id: int) -> void:
	if not is_dedicated_server():
		return
	rpc("rpc_ally_revive_started", reviver_id, target_id)


func _on_server_ally_revive_progress(reviver_id: int, target_id: int, progress_01: float) -> void:
	if not is_dedicated_server():
		return
	rpc("rpc_ally_revive_progress", reviver_id, target_id, progress_01)


func _on_server_ally_revive_cancelled(reviver_id: int, target_id: int, reason: String) -> void:
	if not is_dedicated_server():
		return
	rpc("rpc_ally_revive_cancelled", reviver_id, target_id, reason)


func _on_server_ally_revive_completed(target_id: int, pos: Vector2, hp: int, aura: float) -> void:
	if not is_dedicated_server():
		return
	# player_respawned já notifica restauração; este RPC é feedback explícito de revive
	rpc("rpc_ally_revive_completed", target_id, pos, hp, aura)


@rpc("any_peer", "call_remote", "reliable")
func rpc_solicitar_revive_aliado(target_peer_id: int) -> void:
	if not is_dedicated_server() or world_coordinator == null:
		return
	var sender_id: int = multiplayer.get_remote_sender_id()
	var result: Dictionary = world_coordinator.begin_ally_revive(sender_id, target_peer_id)
	if not bool(result.get("ok", false)):
		rpc_id(sender_id, "rpc_ally_revive_rejected", target_peer_id, str(result.get("reason", "fail")))


@rpc("any_peer", "call_remote", "reliable")
func rpc_cancelar_revive_aliado() -> void:
	if not is_dedicated_server() or world_coordinator == null:
		return
	var sender_id: int = multiplayer.get_remote_sender_id()
	world_coordinator.cancel_ally_revive_by_reviver(sender_id, "cancelled")


@rpc("authority", "call_remote", "reliable")
func rpc_ally_revive_started(reviver_id: int, target_id: int) -> void:
	if is_dedicated_server():
		return
	if reviver_id == local_peer_id:
		_local_revive_channeling = true
		_revive_prompt_peer = target_id
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("💉 Canalizando revive... (3s)")


@rpc("authority", "call_remote", "reliable")
func rpc_ally_revive_progress(reviver_id: int, target_id: int, progress_01: float) -> void:
	if is_dedicated_server():
		return
	if reviver_id == local_peer_id or target_id == local_peer_id:
		# HUD leve via toast a cada ~33%
		if EventBus != null and EventBus.has_method("emit_toast") and int(progress_01 * 100.0) % 34 == 0:
			EventBus.emit_toast("💉 Revive %d%%" % int(progress_01 * 100.0))


@rpc("authority", "call_remote", "reliable")
func rpc_ally_revive_cancelled(reviver_id: int, _target_id: int, reason: String) -> void:
	if is_dedicated_server():
		return
	if reviver_id == local_peer_id:
		_local_revive_channeling = false
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("💉 Revive cancelado (%s)" % reason)


@rpc("authority", "call_remote", "reliable")
func rpc_ally_revive_completed(target_id: int, _pos: Vector2, _hp: int, _aura: float) -> void:
	if is_dedicated_server():
		return
	_local_revive_channeling = false
	_downed_peers.erase(target_id)
	if PartyManager != null and PartyManager.has_method("definir_membro_desmaiado"):
		PartyManager.definir_membro_desmaiado(target_id, false)
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("✨ Aliado revivido!" if target_id != local_peer_id else "✨ Você foi revivido por um aliado!")


@rpc("authority", "call_remote", "reliable")
func rpc_ally_revive_rejected(_target_id: int, reason: String) -> void:
	if is_dedicated_server():
		return
	_local_revive_channeling = false
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("💉 Não foi possível reviver (%s)" % reason)


## Cliente: tenta reviver o aliado caído mais próximo (tecla E / interact).
func tentar_revive_aliado_proximo() -> void:
	if current_mode != NetworkMode.CLIENT_PEER:
		return
	if _local_revive_channeling:
		return
	var player = GameManager.active_player if GameManager != null else null
	if player == null or not is_instance_valid(player):
		return
	var best_id: int = -1
	var best_dist: float = 72.0
	var origin: Vector2 = player.global_position
	for pid in _downed_peers.keys():
		var puppet = remote_players.get(int(pid), null)
		if puppet == null or not is_instance_valid(puppet):
			continue
		var d: float = origin.distance_to(puppet.global_position)
		if d <= best_dist:
			best_dist = d
			best_id = int(pid)
	if best_id < 0:
		if EventBus != null and EventBus.has_method("emit_toast"):
			EventBus.emit_toast("💉 Nenhum aliado caído por perto")
		return
	_revive_prompt_peer = best_id
	rpc_id(1, "rpc_solicitar_revive_aliado", best_id)


func cancelar_revive_local() -> void:
	if current_mode != NetworkMode.CLIENT_PEER:
		return
	if not _local_revive_channeling:
		return
	rpc_id(1, "rpc_cancelar_revive_aliado")
	_local_revive_channeling = false


@rpc("authority", "call_remote", "reliable")
func rpc_recompensa_kill(net_id: int, rewards: Dictionary) -> void:
	if is_dedicated_server():
		return
	var xp_amt: int = int(rewards.get("xp", 0))
	var xp_nen: int = int(rewards.get("xp_nen", 0))
	var gold_amt: int = int(rewards.get("gold", 0))
	var enemy_name: String = str(rewards.get("enemy_name", "Inimigo"))

	var player = GameManager.active_player if GameManager != null else null
	var xp_sys = null
	if player != null:
		xp_sys = player.get_node_or_null("XPSystem")
	if xp_sys == null and get_tree() != null:
		xp_sys = get_tree().get_first_node_in_group("xp_system")
	if xp_sys != null and xp_sys.has_method("adicionar_xp") and xp_amt > 0:
		xp_sys.adicionar_xp(xp_amt)
	if xp_sys != null and xp_sys.has_method("adicionar_xp_nen") and xp_nen > 0:
		xp_sys.adicionar_xp_nen(xp_nen)

	if gold_amt > 0:
		if Economy != null and Economy.has_method("adicionar_gold"):
			Economy.adicionar_gold(gold_amt)
		elif PlayerData != null and PlayerData.has_method("adicionar_gold"):
			PlayerData.adicionar_gold(gold_amt)

	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("☠️ %s derrotado! +%d XP / +%d Jenny" % [enemy_name, xp_amt, gold_amt])
	print("[NetworkManager] 🎁 Recompensa kill net %d: XP %d / NenXP %d / Jenny %d" % [net_id, xp_amt, xp_nen, gold_amt])


@rpc("authority", "call_local", "reliable")
func rpc_notificar_inimigo_morto(net_id: int) -> void:
	if is_dedicated_server():
		return
	if remote_enemies.has(net_id):
		var proxy = remote_enemies[net_id]
		if proxy != null and is_instance_valid(proxy):
			if proxy.has_method("aplicar_hit_confirmado"):
				proxy.aplicar_hit_confirmado(0, 0, true)
			else:
				proxy.queue_free()
		remote_enemies.erase(net_id)


func _reconciliar_jogador_local(p_data: Dictionary) -> void:
	var player = GameManager.active_player if GameManager != null else null
	if player == null or not is_instance_valid(player):
		return
	var server_pos := Vector2(float(p_data.get("px", player.global_position.x)), float(p_data.get("py", player.global_position.y)))
	var dist: float = player.global_position.distance_to(server_pos)
	# Soft snap se desvio for grande (anti-desync); leve lerp se pequeno
	if dist > 64.0:
		player.global_position = server_pos
		player.velocity = Vector2.ZERO
	elif dist > 8.0:
		player.global_position = player.global_position.lerp(server_pos, 0.35)

	# HP autoritativo do snapshot (evita drift visual)
	if PlayerData != null and p_data.has("hp"):
		var server_hp: int = int(p_data.get("hp", PlayerData.attributes.get("vida", 100)))
		var local_hp: int = int(PlayerData.attributes.get("vida", 100))
		if abs(server_hp - local_hp) > 0:
			PlayerData.attributes["vida"] = server_hp


func _on_player_joined_spawn_puppet(peer_id: int, player_data: Dictionary) -> void:
	if peer_id == local_peer_id or is_dedicated_server():
		return
	_spawn_puppet_for_peer(peer_id, player_data)


func _spawn_puppet_for_peer(peer_id: int, info: Dictionary = {}) -> void:
	if peer_id == local_peer_id or remote_players.has(peer_id):
		return
	var scene = get_tree().current_scene if get_tree() != null else null
	if scene == null:
		return

	var puppet_script = load("res://scripts/network/NetworkPlayer.gd")
	if puppet_script == null:
		return
	var puppet = puppet_script.new()
	puppet.peer_id = peer_id
	puppet.name = "RemotePlayer_%d" % peer_id
	var display_name: String = str(info.get("name", info.get("nickname", "Hunter_%d" % peer_id)))
	puppet.character_name = display_name
	if info.has("spawn_pos") and info["spawn_pos"] is Vector2:
		puppet.global_position = info["spawn_pos"]
		puppet.target_position = info["spawn_pos"]
	elif info.has("pos") and info["pos"] is Array and info["pos"].size() >= 2:
		var pos := Vector2(float(info["pos"][0]), float(info["pos"][1]))
		puppet.global_position = pos
		puppet.target_position = pos

	scene.add_child(puppet)
	registrar_jogador_remoto(peer_id, puppet)
	print("[NetworkManager] 🎭 Puppet remoto spawnado: %s (Peer %d)" % [display_name, peer_id])


func obter_mapa_sessao() -> String:
	if server_config != null and not str(server_config.starting_map).is_empty():
		return server_config.starting_map
	return session.current_map_path if session != null else "res://world/lobby.tscn"


# ============================================================
# INTENÇÃO DE INPUT & COMBATE AUTORITATIVO (K-LAN 14 & 15)
# ============================================================

@rpc("any_peer", "call_remote", "unreliable_ordered")
func rpc_enviar_intencao_input(move_dir: Vector2, facing: Vector2, nen_tech: String) -> void:
	if not is_server_authoritative():
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	if is_dedicated_server() and world_coordinator != null:
		world_coordinator.update_player_intent(sender_id, move_dir, facing, nen_tech)


@rpc("any_peer", "call_remote", "reliable")
func rpc_solicitar_ataque_servidor(pos_origem: Vector2, direcao: Vector2, is_heavy: bool) -> void:
	if not is_server_authoritative():
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	var cd_nom: float = 0.50 if is_heavy else 0.30
	if anti_cheat != null and not anti_cheat.validar_taxa_ataque(sender_id, cd_nom):
		return

	if is_dedicated_server() and world_coordinator != null:
		var hits = world_coordinator.apply_player_attack(sender_id, pos_origem, direcao, 40, 45.0, is_heavy)
		if not hits.is_empty():
			rpc("rpc_confirmar_acertos_combate", hits)


@rpc("authority", "call_local", "reliable")
func rpc_confirmar_acertos_combate(hits: Array) -> void:
	combat_hits_confirmed.emit(hits)


# ============================================================
# RPCS LEGADOS PRESERVADOS (COMPATIBILIDADE FASE K)
# ============================================================

@rpc("any_peer", "call_local", "unreliable_ordered")
func rpc_receber_snapshot(data: Dictionary) -> void:
	var state = PlayerNetworkStateScript.from_dict(data)
	var pid: int = state.peer_id

	if pid == local_peer_id:
		return

	if is_server_authoritative() and anti_cheat != null:
		var anterior = last_states.get(pid, null)
		if anterior != null:
			var dt: float = float(state.timestamp_ms - anterior.timestamp_ms) / 1000.0
			var valido = anti_cheat.validar_movimento(pid, anterior.position, state.position, dt, 160.0, 50.0)
			if not valido:
				rpc_id(pid, "rpc_corrigir_posicao", anterior.position)
				return

	last_states[pid] = state

	if remote_players.has(pid):
		var remote_node = remote_players[pid]
		if remote_node != null and remote_node.has_method("aplicar_estado_rede"):
			remote_node.aplicar_estado_rede(state)
	else:
		_instanciar_puppet_remoto(state)


func _instanciar_puppet_remoto(state) -> void:
	var puppet_scn = load("res://scripts/network/NetworkPlayer.gd")
	if puppet_scn == null:
		return
	var puppet = puppet_scn.new()
	puppet.peer_id = state.peer_id
	puppet.name = "RemotePlayer_%d" % state.peer_id
	puppet.global_position = state.position

	var root = get_tree().current_scene if get_tree() != null else null
	if root != null:
		root.add_child(puppet)
		registrar_jogador_remoto(state.peer_id, puppet)
		puppet.aplicar_estado_rede(state)


@rpc("any_peer", "call_remote", "reliable")
func rpc_registrar_novo_jogador(info: Dictionary) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	session.adicionar_peer(sender_id, info)
	print("[NetworkManager] Novo caçador registrado no servidor: %s (Peer %d)" % [info.get("name", ""), sender_id])


@rpc("authority", "call_remote", "reliable")
func rpc_sincronizar_sessao(room_name: String, max_p: int) -> void:
	session.room_name = room_name
	session.max_players = max_p
	print("[NetworkManager] Sessão sincronizada pelo host: %s (Max: %d)" % [room_name, max_p])


@rpc("authority", "call_remote", "reliable")
func rpc_corrigir_posicao(pos_valida: Vector2) -> void:
	var player = GameManager.active_player if GameManager != null else null
	if player != null and is_instance_valid(player):
		player.global_position = pos_valida
		player.velocity = Vector2.ZERO
		print("[NetworkManager] ⚠️ Posição corrigida pelo servidor (reconciliação).")


@rpc("any_peer", "call_local", "reliable")
func rpc_requisitar_ataque(pos_origem: Vector2, direcao: Vector2, combo_step: int, is_heavy: bool) -> void:
	if not is_server_authoritative():
		return

	var sender_id: int = multiplayer.get_remote_sender_id() if multiplayer.has_multiplayer_peer() else local_peer_id
	if sender_id == 0:
		sender_id = local_peer_id

	var cd_nom: float = 0.50 if is_heavy else 0.30
	if anti_cheat != null and not anti_cheat.validar_taxa_ataque(sender_id, cd_nom):
		return

	rpc("rpc_executar_efeito_ataque", sender_id, pos_origem, direcao, combo_step, is_heavy)


@rpc("authority", "call_local", "reliable")
func rpc_executar_efeito_ataque(origem_id: int, pos: Vector2, dir: Vector2, combo_step: int, is_heavy: bool) -> void:
	var cor := Color(1.0, 0.8, 0.2) if is_heavy else Color.WHITE
	var raio: float = 42.0 if is_heavy else 32.0

	var root = get_tree().current_scene if get_tree() != null else null
	if root != null and CombatImpactEffect != null:
		CombatImpactEffect.spawn_swing_arc(root, pos, dir, raio, cor, is_heavy)


@rpc("any_peer", "call_local", "reliable")
func rpc_requisitar_hatsu(slot_index: int, direcao: Vector2) -> void:
	if not is_server_authoritative():
		return

	var sender_id: int = multiplayer.get_remote_sender_id() if multiplayer.has_multiplayer_peer() else local_peer_id
	if sender_id == 0:
		sender_id = local_peer_id

	rpc("rpc_confirmar_hatsu", sender_id, slot_index, direcao)


@rpc("authority", "call_local", "reliable")
func rpc_confirmar_hatsu(caster_id: int, slot_index: int, direcao: Vector2) -> void:
	if AudioManager != null:
		AudioManager.tocar_hatsu_categoria("enhancer")
	print("[NetworkManager] Hatsu Slot %d ativado pelo Peer %d!" % [slot_index, caster_id])


@rpc("any_peer", "call_local", "reliable")
func rpc_enviar_mensagem_chat(canal: String, mensagem: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id() if multiplayer.has_multiplayer_peer() else local_peer_id
	if sender_id == 0:
		sender_id = local_peer_id

	var canal_limpo: String = _sanitizar_canal_chat(canal)
	var msg_limpa: String = _sanitizar_mensagem_chat(mensagem)
	if msg_limpa.is_empty():
		return

	var sender_info = session.obter_peer_info(sender_id) if session != null else {}
	var nome: String = str(sender_info.get("name", "Hunter_%d" % sender_id))
	if nome.is_empty():
		nome = "Hunter_%d" % sender_id

	chat_message_received.emit(nome, canal_limpo, msg_limpa)


func enviar_mensagem_chat(canal: String, mensagem: String) -> void:
	var canal_limpo: String = _sanitizar_canal_chat(canal)
	var msg_limpa: String = _sanitizar_mensagem_chat(mensagem)
	if msg_limpa.is_empty():
		return
	if is_offline_singleplayer() or not multiplayer.has_multiplayer_peer():
		var nome := "Você"
		if PlayerData != null and "nome_personagem" in PlayerData and not str(PlayerData.nome_personagem).is_empty():
			nome = str(PlayerData.nome_personagem)
		chat_message_received.emit(nome, canal_limpo, msg_limpa)
		return
	rpc("rpc_enviar_mensagem_chat", canal_limpo, msg_limpa)


func _sanitizar_canal_chat(canal: String) -> String:
	var c := canal.strip_edges().to_lower()
	if c in ["local", "party", "geral"]:
		return c
	return "local"


func _sanitizar_mensagem_chat(mensagem: String) -> String:
	const MAX_CHARS := 120
	var limpo := mensagem.strip_edges()
	limpo = limpo.replace("\n", " ").replace("\r", " ").replace("\t", " ")
	while limpo.contains("  "):
		limpo = limpo.replace("  ", " ")
	if limpo.length() > MAX_CHARS:
		limpo = limpo.substr(0, MAX_CHARS)
	return limpo


@rpc("any_peer", "call_local", "unreliable")
func rpc_ping(origem_ts: int) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "rpc_pong", origem_ts)


@rpc("any_peer", "call_local", "unreliable")
func rpc_pong(origem_ts: int) -> void:
	var rtt: int = Time.get_ticks_msec() - origem_ts
	session.atualizar_latencia(local_peer_id, rtt)
