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
var client_password_input: String = ""

# peer_id -> NetworkPlayer
var remote_players: Dictionary = {}
# peer_id -> PlayerNetworkState
var last_states: Dictionary = {}

var _snapshot_timer: float = 0.0
const SNAPSHOT_INTERVAL: float = 0.05 # 20 Hz
var _ping_timer: float = 0.0
const PING_INTERVAL: float = 2.0

# Sinais de Ciclo de Vida da Rede (Fase K-LAN)
signal handshake_completed(success: bool, reason: String)
signal player_joined_session(peer_id: int, player_data: Dictionary)
signal player_left_session(peer_id: int)
signal world_snapshot_received(snapshot: Dictionary)
signal combat_hits_confirmed(hits: Array)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	connection_manager = ConnectionManagerScript.new()
	session = NetworkSessionScript.new()
	anti_cheat = AntiCheatValidatorScript.new()

	_conectar_sinais_multiplayer()
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
	world_coordinator.snapshot_ready.connect(_on_server_snapshot_ready)
	world_coordinator.start_coordinator()

	# Iniciar Broadcaster de Descoberta LAN
	discovery_broadcaster = LanDiscoveryBroadcasterScript.new()
	discovery_broadcaster.start_broadcast(
		cfg.server_name,
		cfg.port,
		0,
		cfg.max_players,
		cfg.region,
		cfg.discovery_port
	)

	print("\n============================================================")
	print("                HUNTER MMORPG DEDICATED SERVER              ")
	print("============================================================")
	print("Status: ONLINE")
	print("Server Name: %s" % cfg.server_name)
	print("Listening Port: %d (ENet UDP)" % cfg.port)
	print("Discovery Port: %d (UDP Broadcast)" % cfg.discovery_port)
	print("Max Players: %d" % cfg.max_players)
	print("Tick Rate: %d TPS" % cfg.tick_rate)
	print("Save Path: %s" % cfg.save_path)
	print("Region / Map: %s" % cfg.starting_map)
	print("Waiting for hunter connections...")
	print("============================================================\n")
	return OK


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
		if world_coordinator != null:
			world_coordinator.stop_coordinator()

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
	last_states.clear()
	session.limpar()


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

	# Enviar via RPC não-confiável e ordenado para todos os peers
	rpc("rpc_receber_snapshot", state.to_dict())

	# Se estiver conectado a um servidor dedicado, enviar intenção de input
	if current_mode == NetworkMode.CLIENT_PEER:
		var move_dir: Vector2 = player.velocity.normalized() if player.velocity != Vector2.ZERO else Vector2.ZERO
		var facing_dir: Vector2 = player._direcao_olhar if "_direcao_olhar" in player else Vector2.DOWN
		var nen_tech: String = state.active_nen
		rpc_id(1, "rpc_enviar_intencao_input", move_dir, facing_dir, nen_tech)


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

	# Registro de sucesso
	session.adicionar_peer(sender_id, auth_data)

	var spawn_pos := Vector2(100, 100)
	if is_dedicated_server():
		if server_storage != null:
			var saved = server_storage.load_player_state(c_id)
			if not saved.is_empty() and saved.has("position"):
				var p_arr = saved["position"]
				if p_arr is Array and p_arr.size() >= 2:
					spawn_pos = Vector2(float(p_arr[0]), float(p_arr[1]))
			else:
				server_storage.save_player_state(c_id, auth_data)

		if world_coordinator != null:
			world_coordinator.register_player(sender_id, auth_data, spawn_pos)

	# Preparar lista de jogadores existentes
	var existing: Array = []
	for pid in session.peers.keys():
		if pid != sender_id:
			existing.append({
				"peer_id": pid,
				"info": session.obter_peer_info(pid),
				"pos": [spawn_pos.x, spawn_pos.y]
			})

	var s_meta: Dictionary = {
		"server_name": server_config.server_name if server_config != null else session.room_name,
		"tick_rate": server_config.tick_rate if server_config != null else 20
	}

	rpc_id(sender_id, "rpc_handshake_aceito", s_meta, spawn_pos, existing)
	rpc("rpc_notificar_jogador_conectado", sender_id, auth_data, spawn_pos)
	print("[NetworkManager] 🤝 Handshake aceito com sucesso para %s (Peer %d)" % [nick, sender_id])


@rpc("authority", "call_remote", "reliable")
func rpc_handshake_aceito(server_meta: Dictionary, spawn_pos: Vector2, existing_players: Array) -> void:
	print("[NetworkManager] 🎉 Conexão autorizada pelo servidor: %s" % server_meta.get("server_name", ""))
	handshake_completed.emit(true, "")

	# Atualizar posição inicial do player local se aplicável
	var player = GameManager.active_player if GameManager != null else null
	if player != null and is_instance_valid(player):
		player.global_position = spawn_pos

	# Instanciar puppets dos jogadores pré-existentes
	for entry in existing_players:
		var pid = int(entry.get("peer_id", 0))
		var info = entry.get("info", {})
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
	print("[NetworkManager] Caçador entrou no mundo: %s (Peer %d)" % [info.get("name", "Hunter"), peer_id])
	session.adicionar_peer(peer_id, info)
	player_joined_session.emit(peer_id, info)


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

func _on_server_snapshot_ready(snapshot: Dictionary) -> void:
	if is_server_authoritative():
		rpc("rpc_receber_snapshot_mundo", snapshot)


@rpc("authority", "call_local", "unreliable_ordered")
func rpc_receber_snapshot_mundo(snapshot: Dictionary) -> void:
	world_snapshot_received.emit(snapshot)

	# Atualizar puppets de outros jogadores
	var players_arr = snapshot.get("players", [])
	if players_arr is Array:
		for p_data in players_arr:
			var pid = int(p_data.get("id", 0))
			if pid == local_peer_id:
				continue
			if remote_players.has(pid):
				var puppet = remote_players[pid]
				if puppet != null and puppet.has_method("aplicar_estado_snapshot"):
					puppet.aplicar_estado_snapshot(p_data)


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

	var sender_info = session.obter_peer_info(sender_id)
	var nome: String = sender_info.get("name", "Hunter_%d" % sender_id)

	EventBus.emit_toast("[%s] %s: %s" % [canal.to_upper(), nome, mensagem])


@rpc("any_peer", "call_local", "unreliable")
func rpc_ping(origem_ts: int) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "rpc_pong", origem_ts)


@rpc("any_peer", "call_local", "unreliable")
func rpc_pong(origem_ts: int) -> void:
	var rtt: int = Time.get_ticks_msec() - origem_ts
	session.atualizar_latencia(local_peer_id, rtt)
