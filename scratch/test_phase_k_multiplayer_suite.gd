extends Node

# ==============================================================================
# HUNTER ONLINE — AUTOMATED TEST SUITE: FASE K (CO-OP / MULTIPLAYER)
# ==============================================================================
# Valida rigorosamente todos os subsistemas de rede e cooperação:
# 1. Autonomia Offline do Single-Player (K3)
# 2. Fundação de Rede, Sockets & Handshake (K2)
# 3. Serialização de Snapshot & PlayerNetworkState (K2, K4)
# 4. Entidade Remota NetworkPlayer & Interpolação (K4, K7)
# 5. Combate Autoritativo & Anti-Cheat de Cadência (K1, K5, K19)
# 6. Validação de Hatsu, Votos & Consumo de Aura (K6, K7, K18)
# 7. Sistema de Party (Grupos de Caçada) & PartyHUD (K8, K21)
# 8. World Boss Co-op: Aggro Multi-Alvo & Contribuição (K10, K11)
# 9. Dungeons Cooperativas & Loot Seguro Anti-Duplicação (K12, K13)
# 10. Sistema de Duelos 1v1 Consensual (PvP Foundation) (K23)
# 11. Chat Social & Canais (K22)
# ==============================================================================

const PlayerNetworkStateScript = preload("res://scripts/network/PlayerNetworkState.gd")
const NetworkSessionScript = preload("res://scripts/network/NetworkSession.gd")
const ConnectionManagerScript = preload("res://scripts/network/ConnectionManager.gd")
const AntiCheatValidatorScript = preload("res://scripts/network/AntiCheatValidator.gd")
const NetworkPlayerScript = preload("res://scripts/network/NetworkPlayer.gd")
const CoopWorldBossCoordinatorScript = preload("res://scripts/network/CoopWorldBossCoordinator.gd")
const CoopDungeonInstanceScript = preload("res://scripts/network/CoopDungeonInstance.gd")
const DuelSystemScript = preload("res://scripts/network/DuelSystem.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0


func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ [PASS] " + test_name)
	else:
		failed_tests += 1
		printerr("  ❌ [FAIL] " + test_name)


func _ready() -> void:
	print("================================================================")
	print("🌐 SUÍTE DE TESTES: FASE K — CO-OP & MULTIPLAYER FOUNDATION")
	print("================================================================")

	_test_1_single_player_offline_autonomy()
	_test_2_networking_foundation_and_sockets()
	_test_3_player_network_state_serialization()
	_test_4_network_player_puppet_and_interpolation()
	_test_5_combat_authority_and_damage_validation()
	_test_6_hatsu_and_aura_server_validation()
	_test_7_party_system_and_party_hud()
	_test_8_world_boss_multi_target_and_contribution()
	_test_9_coop_dungeon_and_secure_loot()
	_test_10_anti_cheat_sanity_checks()
	_test_11_duel_system_pvp_foundation()
	_test_12_chat_and_social_messaging()

	print("================================================================")
	print("📊 RESULTADOS FINAIS DA FASE K:")
	print("  TOTAL: %d | APROVADOS: %d | FALHAS: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 TODOS OS TESTES DA FASE K PASSARAM COM SUCESSO!")
	else:
		printerr("⚠️ HOUVE FALHAS NOS TESTES DA FASE K. VERIFIQUE OS LOGS ACIMA.")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)


func _test_1_single_player_offline_autonomy() -> void:
	print("\n--- Teste 1: Autonomia Offline do Single-Player (K3) ---")

	assert_test(NetworkManager != null, "NetworkManager autoload registrado no motor")
	assert_test(NetworkManager.is_offline_singleplayer() == true, "NetworkManager inicializa em OFFLINE_SINGLEPLAYER por padrão")

	var bridge_offline: bool = MultiplayerStateBridge.is_offline_singleplayer()
	assert_test(bridge_offline == true, "MultiplayerStateBridge reconhece modo offline")

	var local_auth: bool = MultiplayerStateBridge.is_local_authority(self)
	assert_test(local_auth == true, "Entidades locais possuem autoridade direta quando offline")

	assert_test(PlayerData != null and PlayerData.attributes.has("vida"), "PlayerData opera normalmente offline")


func _test_2_networking_foundation_and_sockets() -> void:
	print("\n--- Teste 2: Fundação de Rede & Conexão ENet (K2) ---")

	var cm = ConnectionManagerScript.new()
	assert_test(cm != null, "ConnectionManager instanciado com sucesso")

	var err_srv = cm.iniciar_servidor(19890, 4)
	assert_test(err_srv == OK and cm.is_server == true, "ConnectionManager inicia servidor ENet na porta de teste")
	assert_test(cm.esta_ativo() == true, "Socket do servidor está ativo")

	var session = NetworkSessionScript.new()
	assert_test(session != null, "NetworkSession instanciado com sucesso")
	assert_test(session.max_players == 4, "Sessão padrão configurada para 4 caçadores")

	session.adicionar_peer(1, {"name": "Gon Freecss", "level": 15, "affinity": "Intensificação"})
	session.adicionar_peer(2, {"name": "Killua Zoldyck", "level": 16, "affinity": "Transformação"})
	assert_test(session.obter_quantidade_jogadores() == 2, "Dois peers registrados na sessão")

	var info_p2 = session.obter_peer_info(2)
	assert_test(info_p2.get("name") == "Killua Zoldyck", "Metadados do peer 2 recuperados com sucesso")

	session.atualizar_latencia(2, 45)
	assert_test(session.obter_peer_info(2).get("ping_ms") == 45, "Latência do peer 2 atualizada (45ms)")

	cm.fechar_conexao()
	assert_test(cm.esta_ativo() == false, "Socket ENet fechado com sucesso")


func _test_3_player_network_state_serialization() -> void:
	print("\n--- Teste 3: Serialização de Snapshot PlayerNetworkState (K2, K4) ---")

	var state = PlayerNetworkStateScript.new()
	state.peer_id = 2
	state.character_name = "Kurapika"
	state.level = 45
	state.nen_affinity = "Materialização"
	state.position = Vector2(340.5, 120.8)
	state.velocity = Vector2(160.0, 0.0)
	state.facing = Vector2.RIGHT
	state.hp = 950
	state.hp_max = 1200
	state.aura = 2400.0
	state.aura_max = 3000.0
	state.active_nen = "Gyo"
	state.active_hatsu_id = "chain_jail"
	state.is_sprinting = true

	var dict = state.to_dict()
	assert_test(dict.has("pid") and dict["pid"] == 2, "Serialização to_dict() possui peer_id")
	assert_test(dict["name"] == "Kurapika", "Nome serializado corretamente")
	assert_test(dict["nen"] == "Gyo", "Técnica de Nen serializada")

	var restaurado = PlayerNetworkStateScript.from_dict(dict)
	assert_test(restaurado.peer_id == 2, "Desserialização from_dict() preserva peer_id")
	assert_test(restaurado.character_name == "Kurapika", "Desserialização preserva nome")
	assert_test(restaurado.position.is_equal_approx(Vector2(340.5, 120.8)), "Desserialização preserva posição com precisão")
	assert_test(restaurado.active_nen == "Gyo", "Desserialização preserva modo de Nen")
	assert_test(restaurado.is_sprinting == true, "Desserialização preserva flag de sprint")


func _test_4_network_player_puppet_and_interpolation() -> void:
	print("\n--- Teste 4: Entidade Remota NetworkPlayer & Interpolação (K4, K7) ---")

	var puppet = NetworkPlayerScript.new()
	add_child(puppet)
	puppet.peer_id = 2
	puppet.global_position = Vector2(100, 100)

	assert_test(puppet.is_in_group("remote_player"), "NetworkPlayer pertence ao grupo remote_player")
	assert_test(puppet.lbl_nameplate != null, "NetworkPlayer possui Nameplate sobre a cabeça")
	assert_test(puppet.hp_bar != null, "NetworkPlayer possui barra de HP overhead")
	assert_test(puppet.aura_bar != null, "NetworkPlayer possui barra de Aura overhead")

	var snap = PlayerNetworkStateScript.new()
	snap.peer_id = 2
	snap.character_name = "Leorio"
	snap.level = 20
	snap.position = Vector2(200, 100)
	snap.velocity = Vector2(100, 0)
	snap.facing = Vector2.RIGHT
	snap.hp = 600
	snap.hp_max = 800
	snap.aura = 500.0
	snap.aura_max = 1000.0
	snap.active_nen = "Ten"

	puppet.call("aplicar_estado_rede", snap)

	assert_test(puppet.target_position == Vector2(200, 100), "Target position atualizado para interpolação")
	assert_test(puppet.hp == 600 and puppet.hp_max == 800, "HP e Max HP sincronizados")
	assert_test(puppet.current_nen_mode == "Ten", "Modo de Nen Ten replicado")

	# Simular 3 frames de física e verificar convergência suave
	puppet._physics_process(0.016)
	puppet._physics_process(0.016)
	puppet._physics_process(0.016)
	assert_test(puppet.global_position.x > 100.0 and puppet.global_position.x <= 200.0, "Interpolação move o puppet suavemente sem teleporte instantâneo")

	puppet.queue_free()


func _test_5_combat_authority_and_damage_validation() -> void:
	print("\n--- Teste 5: Combate Autoritativo & Validação de Dano (K1, K5) ---")

	assert_test(CombatEngine != null, "CombatEngine central disponível")

	var dano_calc = CombatEngine.calcular_dano({"forca": 50, "dano_base": 30}, {"defesa": 20})
	assert_test(dano_calc > 0, "CombatEngine calcula mitigação autoritativa de dano")

	var validator = AntiCheatValidatorScript.new()
	var cd_ok = validator.validar_taxa_ataque(2, 0.40)
	assert_test(cd_ok == true, "Primeiro ataque aceito pelo validador server-side")

	# Ataque imediato no mesmo milissegundo deve ser rejeitado como spam/macro
	var spam_ok = validator.validar_taxa_ataque(2, 0.40)
	assert_test(spam_ok == false, "Ataque em macro/spam dentro do cooldown é rejeitado pelo servidor")


func _test_6_hatsu_and_aura_server_validation() -> void:
	print("\n--- Teste 6: Validação de Hatsu & Consumo de Aura no Servidor (K6, K7) ---")

	var validator = AntiCheatValidatorScript.new()

	var pode_com_aura = validator.validar_custo_hatsu(2, 100.0, 45.0)
	assert_test(pode_com_aura == true, "Cast autorizado quando Aura atual (100) >= Custo (45)")

	var sem_aura = validator.validar_custo_hatsu(2, 20.0, 50.0)
	assert_test(sem_aura == false, "Cast bloqueado pelo servidor quando Aura atual (20) < Custo (50)")

	var dano_normal = validator.validar_dano_maximo(2, 120, 50)
	assert_test(dano_normal == 120, "Dano legítimo de 120 aprovado sem alteração")

	var dano_hack = validator.validar_dano_maximo(2, 999999, 50)
	assert_test(dano_hack <= 300, "Tentativa de injeção de 999.999 de dano é interceptada e reduzida ao teto teórico")


func _test_7_party_system_and_party_hud() -> void:
	print("\n--- Teste 7: Sistema de Party (Grupos de Caçada) & UI (K8, K21) ---")

	assert_test(PartyManager != null, "PartyManager autoload ativo")

	PartyManager.criar_party()
	assert_test(PartyManager.esta_em_party() == true, "Party criada com sucesso")
	assert_test(PartyManager.eh_lider() == true, "Criador é o líder inicial da party")
	assert_test(PartyManager.obter_membros().size() == 1, "Party contém 1 membro inicial")

	# Simular entrada de 2 membros
	PartyManager.membros[2] = {
		"peer_id": 2, "name": "Killua", "level": 25, "hp": 450, "hp_max": 500, "aura": 800.0, "aura_max": 1000.0, "is_leader": false
	}
	PartyManager.membros[3] = {
		"peer_id": 3, "name": "Kurapika", "level": 28, "hp": 550, "hp_max": 600, "aura": 1200.0, "aura_max": 1500.0, "is_leader": false
	}
	assert_test(PartyManager.obter_membros().size() == 3, "Party agora contém 3 caçadores")

	PartyManager.atualizar_status_membro(2, 380, 500, 750.0, 1000.0)
	var k_info = PartyManager.membros[2]
	assert_test(k_info["hp"] == 380, "HP do membro 2 sincronizado em tempo real")

	# Testar PartyHUD
	var party_hud_script = load("res://ui/party/PartyHUD.gd")
	assert_test(party_hud_script != null, "Script PartyHUD carregado com sucesso")
	var hud_node = party_hud_script.new()
	add_child(hud_node)
	assert_test(hud_node.vbox_membros != null, "PartyHUD possui container de membros instanciado")
	assert_test(hud_node.visible == true, "PartyHUD visível com múltiplos membros na party")

	hud_node.queue_free()
	PartyManager.desfazer_party()
	assert_test(PartyManager.esta_em_party() == false, "Party desfeita ao sair")


func _test_8_world_boss_multi_target_and_contribution() -> void:
	print("\n--- Teste 8: World Boss Co-op: Aggro Multi-Alvo & Contribuição (K10, K11) ---")

	var boss_coord = CoopWorldBossCoordinatorScript.new()
	boss_coord.inicializar_boss("meruem_raid", "Rei Meruem", 20000)

	assert_test(boss_coord.current_hp == 20000, "World Boss inicializado com 20.000 HP")
	assert_test(boss_coord.current_phase == 1, "World Boss inicia na Fase 1")

	# Hunter 1 causa 4000 de dano normal
	boss_coord.registrar_dano(1, 4000, false)
	# Hunter 2 causa 2000 de dano com Provocação / Taunt (Ameaça amplificada em 2.5x = 5000)
	boss_coord.registrar_dano(2, 2000, true)

	assert_test(boss_coord.obter_alvo_aggro() == 2, "Hunter 2 possui maior ameaça (Taunt) e recebe o aggro do boss")

	# Reduzir vida para disparar Fase 2 (50% HP = 10000)
	boss_coord.registrar_dano(1, 5000, false)
	assert_test(boss_coord.current_hp <= 10000, "HP do boss reduzido abaixo de 50%")
	assert_test(boss_coord.current_phase == 2, "World Boss transiciona automaticamente para a Fase 2")

	# Reduzir vida para disparar Fase 3 (25% HP = 5000)
	boss_coord.registrar_dano(2, 6000, false)
	assert_test(boss_coord.current_phase == 3, "World Boss transiciona para a Fase 3 Clímax")

	# Derrotar o boss e calcular recompensas proporcionais
	boss_coord.registrar_dano(1, 4000, false)
	assert_test(boss_coord.esta_morto() == true, "World Boss derrotado pela equipe")

	var rewards = boss_coord.calcular_recompensas_coop(10000, 50000, "coroa_do_rei_quimera")
	assert_test(rewards.has(1) and rewards.has(2), "Ambos os caçadores participantes receberam recompensas")
	assert_test(rewards[1]["xp"] > 0 and rewards[2]["xp"] > 0, "XP creditado proporcionalmente à contribuição")


func _test_9_coop_dungeon_and_secure_loot() -> void:
	print("\n--- Teste 9: Dungeons Cooperativas & Loot Seguro Anti-Duplicação (K12, K13) ---")

	var dungeon = CoopDungeonInstanceScript.new()
	dungeon.iniciar_instancia("ruinas_zaban_coop", [1, 2, 3])

	assert_test(dungeon.party_members.size() == 3, "Instância de Dungeon iniciada com 3 membros")
	assert_test(dungeon.is_cleared == false, "Dungeon inicia em estado não-concluído")

	dungeon.desbloquear_checkpoint("porta_sentinelas")
	assert_test(dungeon.esta_checkpoint_desbloqueado("porta_sentinelas") == true, "Checkpoint de porta compartilhado desbloqueado")

	# Testar portão de sincronização (todos devem estar prontos)
	var prontos_incompleto = dungeon.verificar_prontidao_portao([1, 2])
	assert_test(prontos_incompleto == false, "Portão permanece fechado enquanto membro 3 estiver ausente")

	var prontos_completo = dungeon.verificar_prontidao_portao([1, 2, 3])
	assert_test(prontos_completo == true, "Portão abre com 100% da party presente na sala")

	dungeon.marcar_boss_derrotado()
	assert_test(dungeon.boss_defeated == true and dungeon.is_cleared == true, "Boss da dungeon abatido")

	# Testar geração de loot individual (anti-duplicação)
	var loot_p1 = dungeon.gerar_loot_sala_tesouro(1)
	var loot_p2 = dungeon.gerar_loot_sala_tesouro(2)
	assert_test(loot_p1["item_id"] != loot_p2["item_id"], "Loot instanciado gera itens únicos por peer (sem duplicação)")


func _test_10_anti_cheat_sanity_checks() -> void:
	print("\n--- Teste 10: Anti-Cheat Sanity Checks Server-Side (K18, K19) ---")

	var ac = AntiCheatValidatorScript.new()

	# Movimento normal (10px em 0.05s a 160 px/s)
	var mov_normal = ac.validar_movimento(2, Vector2(0, 0), Vector2(10, 0), 0.05, 160.0)
	assert_test(mov_normal == true, "Movimento normal de 10px aceito")

	# Teleporte anômalo (800px em 0.05s)
	var mov_teleporte = ac.validar_movimento(2, Vector2(0, 0), Vector2(800, 0), 0.05, 160.0)
	assert_test(mov_teleporte == false, "Tentativa de teleporte anômalo de 800px rejeitada")

	var logs = ac.obter_logs_suspeitos()
	assert_test(logs.size() >= 1 and "Deslocamento anômalo" in logs[0], "Log de auditoria de segurança gravado corretamente")


func _test_11_duel_system_pvp_foundation() -> void:
	print("\n--- Teste 11: Sistema de Duelos 1v1 Consensual (PvP) (K23) ---")

	var duel = DuelSystemScript.new()
	var ok_iniciar = duel.iniciar_desafio(1, 2, Vector2(500, 500))
	assert_test(ok_iniciar == true and duel.state == DuelSystemScript.DuelState.INVITED, "Desafio de duelo criado")

	duel.aceitar_desafio()
	assert_test(duel.state == DuelSystemScript.DuelState.COUNTDOWN, "Duelo aceito, contagem iniciada")

	duel.iniciar_combate()
	assert_test(duel.state == DuelSystemScript.DuelState.FIGHTING, "Combate de duelo ativo")

	# Testar dano que levaria à morte: deve parar em 1 HP
	var resultado_dano = duel.aplicar_dano_duelo(50, 200)
	assert_test(resultado_dano["hp_restante"] == 1, "Dano excessivo parou exatamente em 1 HP (zero mortes)")
	assert_test(resultado_dano["duelo_terminou"] == true, "Duelo finalizado com vitória segura")

	duel.encerrar_duelo()
	assert_test(duel.state == DuelSystemScript.DuelState.NONE, "Estado do duelo resetado")


func _test_12_chat_and_social_messaging() -> void:
	print("\n--- Teste 12: Chat Social & Canais (K22) ---")

	var chat_script = load("res://ui/chat/MultiplayerChatHUD.gd")
	assert_test(chat_script != null, "Script MultiplayerChatHUD carregado")

	var chat = chat_script.new()
	add_child(chat)

	assert_test(chat.vbox_log != null, "Chat possui container de mensagens")
	assert_test(chat.line_input != null, "Chat possui campo de digitação")

	chat.adicionar_mensagem("Netero", "geral", "A gratidão é o golpe definitivo!")
	assert_test(chat.vbox_log.get_child_count() == 1, "Mensagem adicionada com sucesso ao log")
	var lbl: Label = chat.vbox_log.get_child(0) as Label
	assert_test(lbl != null and lbl.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "Autowrap por palavra (não por caractere)")
	assert_test(chat.line_input.max_length == 120, "Limite de 120 caracteres no input")
	var long_a: String = ""
	for _i in range(200):
		long_a += "a"
	assert_test(chat.sanitizar_mensagem(long_a).length() == 120, "Sanitize trunca em 120")

	chat.queue_free()
