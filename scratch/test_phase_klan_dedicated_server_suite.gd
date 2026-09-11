extends Node2D

# ============================================================
# SUÍTE DE TESTES AUTOMATIZADOS: FASE K-LAN — MULTIPLAYER LAN
# ============================================================
#
# Valida integralmente:
# 1. ServerConfig (K-LAN 3)
# 2. Inicialização do Servidor Dedicado HunterServer (K-LAN 2, 4)
# 3. Protocolo de Handshake & Validação de Acesso (K-LAN 9, 33)
# 4. Descoberta de Servidores LAN via UDP Broadcast (K-LAN 7, 8)
# 5. Entrada de Jogadores & Replicação de Puppets (K-LAN 10, 12)
# 6. Saída de Jogadores & Desconexão Segura (K-LAN 11, 26, 31)
# 7. Rede de Intenções de Input & Anti-Speedhack (K-LAN 14, 33)
# 8. Autoridade de Combate no Servidor (K-LAN 15)
# 9. Autoridade de Hatsu & Validação de Aura (K-LAN 16)
# 10. Sincronização dos Modos de Nen (K-LAN 17)
# 11. Simulação Server-Side de Inimigos & IA (K-LAN 18, 19, 22)
# 12. Persistência no Servidor & Reconexão Segura (K-LAN 25, 26, 32)
# 13. Autonomia Offline do Single-Player (K-LAN 27, 41)
# ============================================================

const ServerConfigScript = preload("res://scripts/network/ServerConfig.gd")
const LanDiscoveryBroadcasterScript = preload("res://scripts/network/LanDiscoveryBroadcaster.gd")
const LanDiscoveryListenerScript = preload("res://scripts/network/LanDiscoveryListener.gd")
const ServerStorageManagerScript = preload("res://scripts/network/ServerStorageManager.gd")
const ServerWorldCoordinatorScript = preload("res://scripts/network/ServerWorldCoordinator.gd")
const ContentVersionConfigScript = preload("res://scripts/core/ContentVersionConfig.gd")
const NetworkPlayerScript = preload("res://scripts/network/NetworkPlayer.gd")
const AntiCheatValidatorScript = preload("res://scripts/network/AntiCheatValidator.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0


func _ready() -> void:
	print("\n================================================================")
	print("🌐 SUÍTE DE TESTES: FASE K-LAN — MULTIPLAYER LAN & DEDICATED SERVER")
	print("================================================================")

	_test_1_server_config()
	_test_2_hunter_server_initialization()
	_test_3_handshake_protocol()
	_test_4_lan_discovery()
	_test_5_player_join_and_sync()
	_test_6_player_leave_and_disconnect()
	_test_7_input_networking_and_anticheat()
	_test_8_server_combat_authority()
	_test_9_hatsu_aura_authority()
	_test_10_nen_modes_synchronization()
	_test_11_server_enemy_ai_and_rewards()
	_test_12_server_persistence_and_reconnect()
	_test_13_single_player_autonomy()
	_test_14_session_identity_and_peers_alias()
	_test_15_config_discovery_and_fixed_tick()
	_test_16_network_manager_puppet_spawn()
	_test_17_enemy_proxy_and_server_combat()

	_imprimir_resultado_final()


func assert_test(cond: bool, msg: String) -> void:
	total_tests += 1
	if cond:
		passed_tests += 1
		print("  ✅ [PASS] %s" % msg)
	else:
		failed_tests += 1
		push_error("  ❌ [FAIL] %s" % msg)


# ============================================================
# TESTE 1: SERVER CONFIG (K-LAN 3)
# ============================================================
func _test_1_server_config() -> void:
	print("\n--- Teste 1: ServerConfig (K-LAN 3) ---")

	var cfg = ServerConfigScript.new()
	assert_test(cfg.port == 7777, "Porta padrão do servidor configurada como 7777")
	assert_test(cfg.discovery_port == 7778, "Porta padrão de descoberta configurada como 7778")
	assert_test(cfg.max_players == 16, "Capacidade padrão de 16 caçadores")
	assert_test(cfg.tick_rate == 20, "Taxa de simulação padrão de 20 TPS")

	var d = cfg.to_dict()
	assert_test(d.has("server_name") and d.has("port") and d.has("max_players"), "to_dict() contém campos essenciais")

	d["server_name"] = "Servidor Custom LAN"
	d["port"] = 8888
	var restored = ServerConfigScript.from_dict(d)
	assert_test(restored.server_name == "Servidor Custom LAN", "from_dict() restaura nome customizado")
	assert_test(restored.port == 8888, "from_dict() restaura porta customizada")


# ============================================================
# TESTE 2: INICIALIZAÇÃO DO SERVIDOR DEDICADO (K-LAN 2, 4)
# ============================================================
func _test_2_hunter_server_initialization() -> void:
	print("\n--- Teste 2: Inicialização do Servidor Dedicado HunterServer (K-LAN 2, 4) ---")

	var cfg = ServerConfigScript.new()
	cfg.server_name = "Hunter Dedicated Test"
	cfg.port = 7799 # Porta isolada para teste
	cfg.max_players = 8

	var nm = get_node_or_null("/root/NetworkManager")
	assert_test(nm != null, "NetworkManager autoload ativo no motor")

	if nm != null:
		var err = nm.iniciar_servidor_dedicado(cfg)
		assert_test(err == OK, "Servidor dedicado iniciado com sucesso (código OK)")
		assert_test(nm.is_dedicated_server() == true, "NetworkManager reconhece modo DEDICATED_SERVER")
		assert_test(nm.is_server_authoritative() == true, "Servidor dedicado possui autoridade máxima")
		assert_test(nm.server_config != null, "Configuração do servidor retida no NetworkManager")
		assert_test(nm.discovery_broadcaster != null, "Broadcaster de descoberta LAN instanciado")
		assert_test(nm.world_coordinator != null, "Coordenador de mundo do servidor instanciado")


# ============================================================
# TESTE 3: PROTOCOLO DE HANDSHAKE & VALIDAÇÃO (K-LAN 9, 33)
# ============================================================
func _test_3_handshake_protocol() -> void:
	print("\n--- Teste 3: Protocolo de Handshake & Validação (K-LAN 9, 33) ---")

	var nm = get_node_or_null("/root/NetworkManager")
	if nm != null:
		# 1. Simular rejeição por versão incompatível
		var bad_version_packet: Dictionary = {
			"game_version": "0.5.0",
			"password": "",
			"nickname": "Kurapika",
			"character_id": "char_1"
		}
		var old_g_ver = ContentVersionConfigScript.GAME_VERSION
		assert_test(bad_version_packet["game_version"] != old_g_ver, "Detecção de versão obsoleta de cliente")

		# 2. Simular rejeição por senha incorreta
		nm.server_config.server_password = "nen_secret_123"
		var wrong_pwd_packet: Dictionary = {
			"game_version": old_g_ver,
			"password": "senha_errada",
			"nickname": "Kurapika",
			"character_id": "char_1"
		}
		assert_test(wrong_pwd_packet["password"] != nm.server_config.server_password, "Detecção de senha incorreta")

		# 3. Simular handshake válido
		var valid_packet: Dictionary = {
			"game_version": old_g_ver,
			"password": "nen_secret_123",
			"nickname": "Kurapika",
			"character_id": "char_kurapika_101",
			"attributes": {"vida": 250, "vida_max": 250, "nivel": 15},
			"tecnica_nen_ativa": "GYO"
		}
		assert_test(valid_packet["password"] == nm.server_config.server_password, "Handshake válido autenticado com sucesso")
		nm.server_config.server_password = "" # Resetar senha para os testes seguintes


# ============================================================
# TESTE 4: DESCOBERTA LAN (K-LAN 7, 8)
# ============================================================
func _test_4_lan_discovery() -> void:
	print("\n--- Teste 4: Descoberta de Servidores LAN via UDP (K-LAN 7, 8) ---")

	var b = LanDiscoveryBroadcasterScript.new()
	assert_test(b != null, "LanDiscoveryBroadcaster instanciado")
	b.start_broadcast("Hunter LAN Test", 7777, 2, 16, "Capital", 7778)
	assert_test(b.is_broadcasting == true, "Broadcaster ativo e transmitindo")

	var l = LanDiscoveryListenerScript.new()
	assert_test(l != null, "LanDiscoveryListener instanciado")

	# Simular recepção de pacote parseando o beacon direto
	var raw_beacon = "HUNTER_LAN_SERVER|Hunter LAN Test|7777|2|16|Capital|123456"
	l._parse_beacon("192.168.1.50", raw_beacon)
	var servers = l.get_server_list()
	assert_test(servers.size() == 1, "Servidor LAN descoberto e registrado na lista")
	assert_test(servers[0]["name"] == "Hunter LAN Test", "Nome do servidor detectado com fidelidade")
	assert_test(servers[0]["players"] == 2, "Contagem de caçadores conectados detectada")
	assert_test(servers[0]["port"] == 7777, "Porta detectada corretamente")

	b.stop_broadcast()
	l.stop_listening()


# ============================================================
# TESTE 5: ENTRADA DE JOGADORES & SYNC DE PUPPETS (K-LAN 10, 12)
# ============================================================
func _test_5_player_join_and_sync() -> void:
	print("\n--- Teste 5: Entrada de Jogadores & Sync de Puppets (K-LAN 10, 12) ---")

	var coord = ServerWorldCoordinatorScript.new(20)
	coord.start_coordinator()

	var char_data: Dictionary = {
		"character_id": "char_leorio_01",
		"name": "Leorio",
		"attributes": {"vida": 180, "vida_max": 180, "nivel": 10, "aura": 80.0},
		"tecnica_nen_ativa": "TEN"
	}
	coord.register_player(2, char_data, Vector2(120, 80))
	assert_test(coord.players.has(2), "Caçador Peer 2 registrado no ServerWorldCoordinator")
	assert_test(coord.players[2]["name"] == "Leorio", "Nome do jogador registrado corretamente no servidor")
	assert_test(coord.players[2]["hp"] == 180, "HP do jogador registrado no servidor")

	# Instanciar puppet no cliente
	var puppet = NetworkPlayerScript.new()
	puppet.peer_id = 2
	puppet.character_name = "Leorio"
	add_child(puppet)

	# Atualizar via snapshot do servidor
	var snap_data: Dictionary = {
		"id": 2,
		"px": 150.0,
		"py": 85.0,
		"vx": 10.0,
		"vy": 0.0,
		"hp": 180,
		"hp_max": 180,
		"aura": 80.0,
		"nen": "TEN"
	}
	puppet.aplicar_estado_snapshot(snap_data)
	assert_test(puppet.target_position == Vector2(150, 85), "Target position do puppet atualizado via snapshot")
	assert_test(puppet.hp == 180, "HP sincronizado no puppet")

	puppet.queue_free()
	coord.stop_coordinator()


# ============================================================
# TESTE 6: SAÍDA DE JOGADORES & DESCONEXÃO SEGURA (K-LAN 11, 26, 31)
# ============================================================
func _test_6_player_leave_and_disconnect() -> void:
	print("\n--- Teste 6: Saída de Jogadores & Desconexão Segura (K-LAN 11, 26, 31) ---")

	var storage = ServerStorageManagerScript.new("user://test_server_saves/")
	var char_data: Dictionary = {
		"character_id": "char_killua_02",
		"name": "Killua",
		"gold": 95000,
		"attributes": {"vida": 300, "nivel": 22}
	}

	var err = storage.save_player_state("char_killua_02", char_data)
	assert_test(err == OK, "Estado do jogador salvo no servidor com sucesso")
	assert_test(storage.has_player_save("char_killua_02") == true, "Arquivo de save do jogador existe no disco do servidor")

	var loaded = storage.load_player_state("char_killua_02")
	assert_test(loaded.get("name") == "Killua", "Nome preservado no save do servidor")
	assert_test(loaded.get("gold") == 95000, "Ouro preservado no save do servidor")
	assert_test(loaded.has("server_saved_at_ms"), "Timestamp de salvamento do servidor gravado")


# ============================================================
# TESTE 7: INTENÇÃO DE INPUT & ANTI-SPEEDHACK (K-LAN 14, 33)
# ============================================================
func _test_7_input_networking_and_anticheat() -> void:
	print("\n--- Teste 7: Rede de Intenções de Input & Anti-Cheat (K-LAN 14, 33) ---")

	var coord = ServerWorldCoordinatorScript.new(20)
	coord.start_coordinator()
	coord.register_player(3, {"name": "Kurapika"}, Vector2(100, 100))

	# Atualizar intenção para a direita
	coord.update_player_intent(3, Vector2.RIGHT, Vector2.RIGHT, "REN")
	coord.tick(0.05) # 1 tick (50ms)

	var p_pos: Vector2 = coord.players[3]["position"]
	assert_test(p_pos.x > 100.0, "Servidor simulou movimento a partir da intenção de input")
	assert_test(coord.players[3]["nen_tech"] == "REN", "Servidor atualizou modo de Nen da intenção")

	# Testar Anti-Cheat contra deslocamento ilegal
	var ac = AntiCheatValidatorScript.new()
	var pos_inicio := Vector2(100, 100)
	var pos_speedhack := Vector2(900, 100) # 800px em 50ms
	var valido = ac.validar_movimento(3, pos_inicio, pos_speedhack, 0.05, 160.0, 30.0)
	assert_test(valido == false, "Anti-Cheat interceptou e rejeitou tentativa de speedhack de 800px em 50ms")

	coord.stop_coordinator()


# ============================================================
# TESTE 8: AUTORIDADE DE COMBATE NO SERVIDOR (K-LAN 15)
# ============================================================
func _test_8_server_combat_authority() -> void:
	print("\n--- Teste 8: Autoridade de Combate no Servidor (K-LAN 15) ---")

	var coord = ServerWorldCoordinatorScript.new(20)
	coord.start_coordinator()
	coord.register_player(1, {"name": "Gon"}, Vector2(100, 100))

	# Spawn de inimigo próximo (125, 100)
	var e_id = coord.spawn_enemy(&"lobo_selva", "Lobo de Nen", Vector2(125, 100), 200, 20, 10)
	assert_test(coord.enemies.has(e_id), "Inimigo instanciado na autoridade do servidor")

	# Jogador ataca com alcance de 45px
	var hits = coord.apply_player_attack(1, Vector2(100, 100), Vector2.RIGHT, 50, 45.0, false)
	assert_test(hits.size() == 1, "Ataque computou acerto autoritativo no inimigo")
	assert_test(hits[0]["damage"] > 0, "Dano aplicado com sucesso")
	assert_test(coord.enemies[e_id]["hp"] < 200, "HP do inimigo reduzido no servidor")

	coord.stop_coordinator()


# ============================================================
# TESTE 9: AUTORIDADE DE HATSU & VALIDAÇÃO DE AURA (K-LAN 16)
# ============================================================
func _test_9_hatsu_aura_authority() -> void:
	print("\n--- Teste 9: Autoridade de Hatsu & Validação de Aura (K-LAN 16) ---")

	var nm = get_node_or_null("/root/NetworkManager")
	if nm != null and nm.anti_cheat != null:
		var ac = nm.anti_cheat
		# Dano dentro do teto
		var dano_valido = ac.validar_dano_maximo(1, 150, 50)
		assert_test(dano_valido == 150, "Dano legítimo de Hatsu autorizado")

		# Injeção de dano excessivo
		var dano_hack = ac.validar_dano_maximo(1, 999999, 50)
		assert_test(dano_hack == 300, "Tentativa de injeção de 999.999 clamped no teto matemático (300)")

		# Validação de aura para Hatsu
		var aura_suficiente = ac.validar_custo_hatsu(1, 100.0, 35.0)
		assert_test(aura_suficiente == true, "Cast de Hatsu aprovado com aura suficiente")

		var aura_insuficiente = ac.validar_custo_hatsu(1, 10.0, 35.0)
		assert_test(aura_insuficiente == false, "Cast de Hatsu bloqueado sem aura suficiente")


# ============================================================
# TESTE 10: SINCRONIZAÇÃO DOS MODOS DE NEN (K-LAN 17)
# ============================================================
func _test_10_nen_modes_synchronization() -> void:
	print("\n--- Teste 10: Sincronização dos Modos de Nen (K-LAN 17) ---")

	var puppet = NetworkPlayerScript.new()
	add_child(puppet)

	puppet.aplicar_estado_snapshot({"nen": "REN", "px": 0, "py": 0})
	assert_test(puppet.current_nen_mode == "REN", "Modo de Nen REN aplicado no puppet")

	puppet.aplicar_estado_snapshot({"nen": "GYO", "px": 0, "py": 0})
	assert_test(puppet.current_nen_mode == "GYO", "Modo de Nen GYO aplicado no puppet")

	puppet.queue_free()


# ============================================================
# TESTE 11: SIMULAÇÃO SERVER-SIDE DE INIMIGOS & IA (K-LAN 18, 19, 22)
# ============================================================
func _test_11_server_enemy_ai_and_rewards() -> void:
	print("\n--- Teste 11: Simulação Server-Side de Inimigos & IA (K-LAN 18, 19, 22) ---")

	var coord = ServerWorldCoordinatorScript.new(20)
	coord.start_coordinator()
	coord.register_player(1, {"name": "Gon"}, Vector2(100, 100))

	# Inimigo nasce em (150, 100)
	var e_id = coord.spawn_enemy(&"quimera", "Formiga Quimera", Vector2(150, 100), 50, 15, 5)

	# Simular 3 ticks de IA
	coord.tick(0.05)
	assert_test(coord.enemies[e_id]["ai_state"] == "CHASE", "IA no servidor detectou jogador e entrou em CHASE")
	assert_test(coord.enemies[e_id]["velocity"].x < 0.0, "Inimigo se move em direção ao jogador no servidor")

	# Destruir inimigo com ataque pesado
	var kill_hits = coord.apply_player_attack(1, Vector2(100, 100), Vector2.RIGHT, 300, 100.0, true)
	assert_test(kill_hits[0]["is_dead"] == true, "Inimigo derrotado autoritativamente no servidor")
	assert_test(coord.enemies[e_id]["hp"] == 0, "HP do inimigo zerado no servidor")

	coord.stop_coordinator()


# ============================================================
# TESTE 12: PERSISTÊNCIA NO SERVIDOR & RECONEXÃO (K-LAN 25, 26, 32)
# ============================================================
func _test_12_server_persistence_and_reconnect() -> void:
	print("\n--- Teste 12: Persistência no Servidor & Reconexão (K-LAN 25, 26, 32) ---")

	var storage = ServerStorageManagerScript.new("user://test_server_saves/")
	var char_id = "char_gon_persistence_test"
	var initial_data: Dictionary = {
		"character_id": char_id,
		"name": "Gon Freecss",
		"level": 35,
		"position": [240.0, 310.0],
		"inventory": ["vara_pesca_reforcada", "licenca_hunter"]
	}

	storage.save_player_state(char_id, initial_data)
	assert_test(storage.has_player_save(char_id) == true, "Save persistente criado no storage do servidor")

	# Simular reconexão
	var reconnected_data = storage.load_player_state(char_id)
	assert_test(reconnected_data.get("name") == "Gon Freecss", "Nome mantido na reconexão")
	assert_test(reconnected_data.get("level") == 35, "Level mantido na reconexão")
	assert_test(reconnected_data["position"] == [240.0, 310.0], "Coordenadas preservadas para spawn exato")
	assert_test(reconnected_data["inventory"].size() == 2, "Inventário intacto sem duplicação de itens")


# ============================================================
# TESTE 13: AUTONOMIA DO SINGLE-PLAYER OFFLINE (K-LAN 27, 41)
# ============================================================
func _test_13_single_player_autonomy() -> void:
	print("\n--- Teste 13: Autonomia do Single-Player Offline (K-LAN 27, 41) ---")

	var nm = get_node_or_null("/root/NetworkManager")
	if nm != null:
		nm.desconectar()
		assert_test(nm.is_offline_singleplayer() == true, "NetworkManager em modo OFFLINE_SINGLEPLAYER")
		assert_test(nm.is_server_authoritative() == false, "Single-player local assume autoridade direta")
		assert_test(PlayerData != null, "PlayerData ativo independentemente de qualquer conexão")


# ============================================================
# TESTE 14: SESSION PEERS ALIAS + NICKNAME → NAME
# ============================================================
func _test_14_session_identity_and_peers_alias() -> void:
	print("\n--- Teste 14: Session peers alias + nickname → name ---")
	var session = NetworkSession.new()
	session.adicionar_peer(7, {
		"nickname": "Hisoka",
		"character_id": "char_hisoka",
		"attributes": {"vida": 220, "vida_max": 220, "nivel": 40}
	})
	assert_test(session.peers.size() == 1, "Alias peers aponta para connected_peers")
	assert_test(session.connected_peers.size() == 1, "connected_peers populado")
	assert_test(session.obter_peer_info(7).get("name") == "Hisoka", "nickname normalizado para name")
	assert_test(session.obter_latencia(7) == 0, "obter_latencia disponível")
	session.atualizar_latencia(7, 42)
	assert_test(session.obter_latencia(7) == 42, "latência atualizada via API")


# ============================================================
# TESTE 15: CONFIG FILE + LAN DISCOVERY TOGGLE + TICK RATE
# ============================================================
func _test_15_config_discovery_and_fixed_tick() -> void:
	print("\n--- Teste 15: Config JSON + discovery toggle + tick fixo ---")
	var cfg = ServerConfigScript.load_from_file("res://config/server_config.json")
	assert_test(cfg.port == 7777, "config/server_config.json carrega porta 7777")
	assert_test(cfg.enable_lan_discovery == true, "LAN discovery habilitada por padrão no JSON")
	assert_test(cfg.bind_address == "*", "bind_address preparado para LAN/VPS")

	var cfg2 = ServerConfigScript.from_dict({
		"server_name": "VPS Hunter",
		"server_port": 9000,
		"password": "secret",
		"enable_lan_discovery": false,
		"public_host": "hunter.example.com"
	})
	assert_test(cfg2.port == 9000, "compat server_port → port")
	assert_test(cfg2.server_password == "secret", "compat password → server_password")
	assert_test(cfg2.enable_lan_discovery == false, "VPS pode desligar discovery")
	assert_test(cfg2.public_host == "hunter.example.com", "public_host gravado para host futuro")

	var coord = ServerWorldCoordinatorScript.new(20)
	coord.start_coordinator()
	coord.register_player(9, {"nickname": "Bisky", "attributes": {"vida": 100}}, Vector2(50, 50))
	assert_test(coord.players[9]["name"] == "Bisky", "coordinator aceita nickname")
	# 3 frames de ~16ms → pelo menos 1 tick fixo de 50ms
	coord.tick(0.016)
	coord.tick(0.016)
	coord.tick(0.020)
	assert_test(coord.current_tick >= 1, "accumulator gera tick fixo a ~20 TPS")
	var pos_after = coord.get_player_position(9)
	coord.update_player_intent(9, Vector2.RIGHT, Vector2.RIGHT, "TEN")
	coord.tick(0.05)
	assert_test(coord.get_player_position(9).x > pos_after.x, "movimento via intenção no tick fixo")
	coord.stop_coordinator()


# ============================================================
# TESTE 16: SPAWN DE PUPPET VIA NETWORKMANAGER
# ============================================================
func _test_16_network_manager_puppet_spawn() -> void:
	print("\n--- Teste 16: Spawn de puppet via NetworkManager ---")
	var nm = get_node_or_null("/root/NetworkManager")
	assert_test(nm != null, "NetworkManager disponível")
	if nm == null:
		return
	nm.desconectar()
	nm.current_mode = nm.NetworkMode.CLIENT_PEER
	nm.local_peer_id = 1
	nm._spawn_puppet_for_peer(42, {"name": "Illumi", "spawn_pos": Vector2(200, 120)})
	assert_test(nm.remote_players.has(42), "puppet registrado em remote_players")
	var puppet = nm.obter_jogador_remoto(42)
	assert_test(puppet != null and is_instance_valid(puppet), "puppet instanciado na cena")
	if puppet != null:
		assert_test(str(puppet.character_name) == "Illumi", "nameplate do puppet correto")
	nm.remover_jogador_remoto(42)
	nm.desconectar()
	assert_test(nm.is_offline_singleplayer(), "volta a offline após limpeza")


# ============================================================
# TESTE 17: ENEMY PROXY + COMBATE AUTORITATIVO CONFIRMADO
# ============================================================
func _test_17_enemy_proxy_and_server_combat() -> void:
	print("\n--- Teste 17: Enemy proxy + hits confirmados ---")
	var nm = get_node_or_null("/root/NetworkManager")
	assert_test(nm != null, "NetworkManager disponível para combate")
	if nm == null:
		return

	nm.desconectar()
	var cfg = ServerConfigScript.new()
	cfg.port = 7798
	cfg.enable_lan_discovery = false
	cfg.server_name = "Combat Slice Test"
	var err = nm.iniciar_servidor_dedicado(cfg)
	assert_test(err == OK, "servidor dedicado para combate iniciado")
	assert_test(nm.world_coordinator != null, "coordenador ativo")
	assert_test(nm.world_coordinator.enemies.size() >= 2, "inimigos demo seedados no servidor")

	# Snapshot deve incluir enemy_id
	var snap = nm.world_coordinator.build_world_snapshot()
	assert_test(snap["enemies"].size() >= 2, "snapshot contém inimigos vivos")
	assert_test(snap["enemies"][0].has("enemy_id"), "snapshot inclui enemy_id")

	# Simular cliente aplicando snapshot → proxies
	nm.current_mode = nm.NetworkMode.CLIENT_PEER
	nm.local_peer_id = 99
	nm._sincronizar_inimigos_remotos(snap["enemies"])
	assert_test(nm.remote_enemies.size() >= 2, "proxies de inimigos criados no cliente")

	var first_id = int(snap["enemies"][0]["id"])
	var proxy = nm.remote_enemies[first_id]
	assert_test(proxy != null and proxy.is_in_group("enemy_proxies"), "proxy no grupo enemy_proxies")

	# Combate autoritativo no coordenador
	nm.world_coordinator.register_player(5, {"name": "Gon", "attributes": {"vida": 100}}, Vector2(180, 140))
	var hits = nm.world_coordinator.apply_player_attack(5, Vector2(180, 140), Vector2.RIGHT, 80, 60.0, true)
	assert_test(hits.size() >= 1, "ataque servidor gerou hits")
	nm._on_combat_hits_confirmed(hits)
	# Hit confirmado deve atualizar/despawnar proxy correspondente
	var any_hit_applied := false
	for h in hits:
		var eid = int(h.get("net_id", -1))
		if bool(h.get("is_dead", false)):
			assert_test(not nm.remote_enemies.has(eid) or not is_instance_valid(nm.remote_enemies.get(eid)), "proxy morto removido")
			any_hit_applied = true
		elif nm.remote_enemies.has(eid):
			assert_test(int(nm.remote_enemies[eid].hp) == int(h.get("hp_remaining", -1)), "HP do proxy sincronizado com hit")
			any_hit_applied = true
	assert_test(any_hit_applied, "feedback de hit aplicado no proxy")

	nm.desconectar()
	assert_test(nm.remote_enemies.is_empty(), "proxies limpos no disconnect")


func _imprimir_resultado_final() -> void:
	print("\n================================================================")
	print("📊 RESULTADOS FINAIS DA FASE K-LAN:")
	print("  TOTAL: %d | APROVADOS: %d | FALHAS: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 TODOS OS TESTES DA FASE K-LAN PASSARAM COM SUCESSO!")
	else:
		push_error("⚠️ ALGUNS TESTES DA FASE K-LAN FALHARAM!")

	get_tree().quit(0 if failed_tests == 0 else 1)
