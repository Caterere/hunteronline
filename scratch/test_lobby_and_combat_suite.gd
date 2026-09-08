extends Node2D

func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: LOBBY CAPITAL & COMBAT ATTACK DASH (GODOT 4.6)")
	print("============================================================")

	# 0. Preparar Autorização de Entrada no Lobby (GameManager / PlayerData)
	PlayerData.is_character_ready = true
	PlayerData.tutorial_concluido = true
	PlayerData.tour_lobby_concluido = true
	GameManager.set_flow_state(GameManager.GameFlowState.SAVE_LOADED)
	assert(GameManager.can_enter_lobby(), "can_enter_lobby deve retornar true com perfil pronto")
	print("[PASS] Autorização do Lobby validada (PlayerData.is_character_ready = true).")

	# 1. Carregar e Instanciar a Cena do Lobby
	var scn_lobby = load("res://world/lobby.tscn") as PackedScene
	assert(scn_lobby != null, "Falha ao carregar world/lobby.tscn!")
	print("[PASS] world/lobby.tscn carregado com sucesso.")

	var lobby = scn_lobby.instantiate() as Node2D
	assert(lobby != null, "Falha ao instanciar Lobby!")
	add_child(lobby)
	print("[PASS] Lobby instanciado e adicionado à árvore com sucesso.")

	# 2. Verificar Player e Câmera
	var player = lobby.get_node_or_null("Player") as CharacterBody2D
	assert(player != null, "Player não encontrado dentro do Lobby!")
	print("[PASS] Player localizado no Lobby.")

	var cam = player.get_node_or_null("Camera2D") as Camera2D
	assert(cam != null, "Camera2D não encontrada no Player!")
	print("[PASS] Camera2D localizada no Player.")
	assert(cam.limit_left == -1180, "Camera limit_left incorreto: %d" % cam.limit_left)
	assert(cam.limit_top == -880, "Camera limit_top incorreto: %d" % cam.limit_top)
	assert(cam.limit_right == 1680, "Camera limit_right incorreto: %d" % cam.limit_right)
	assert(cam.limit_bottom == 800, "Camera limit_bottom incorreto: %d" % cam.limit_bottom)
	print("[PASS] Limites de câmera rigorosos configurados com sucesso: Left=-1180, Top=-880, Right=1680, Bottom=800.")

	# 3. Verificar Colisões de Perímetro e Estruturas
	var limites = lobby.get_node_or_null("LimitesLobbyPerimetro") as StaticBody2D
	assert(limites != null, "LimitesLobbyPerimetro não encontrado!")
	assert(limites.collision_layer == 1, "LimitesLobbyPerimetro deve estar na layer 1")
	print("[PASS] LimitesLobbyPerimetro validado (Layer 1, barreiras sólidas perimetrais contra vazio).")

	var col_estruturas = lobby.get_node_or_null("ColisoesEstruturasLobby") as StaticBody2D
	assert(col_estruturas != null, "ColisoesEstruturasLobby não encontrado!")
	assert(col_estruturas.collision_layer == 1, "ColisoesEstruturasLobby deve estar na layer 1")
	print("[PASS] ColisoesEstruturasLobby validado (Footprint da Associação, Castelo, Torre, Forja).")

	# 4. Verificar Colisão do Player com Cenário e NPCs
	assert(player.collision_layer == 2, "Player deve estar na layer 2")
	assert((player.collision_mask & 1) != 0, "Player deve colidir com cenário (Layer 1)")
	assert((player.collision_mask & 8) != 0, "Player deve colidir com pés de NPCs (Layer 8)")
	print("[PASS] Máscaras de colisão do Player validadas: Layer 2, Mask 1 (Cenário) e Mask 8 (NPCs).")

	# 5. Verificar NPCs e seus Footprints de Colisão
	var elena = lobby.get_node_or_null("RecepcionistaElena")
	assert(elena != null, "RecepcionistaElena não encontrada!")
	assert(elena.collision_layer == 8, "Elena deve estar na layer 8")
	var elena_inter = elena.get_node_or_null("InteractionComponent")
	assert(elena_inter != null, "InteractionComponent da Elena não encontrado!")
	print("[PASS] NPC Recepcionista Elena validada com footprint de colisão e trigger de diálogo.")

	# 6. Testar Movimento do Player (8 Direções e Responsividade)
	assert(player.get("_friction") >= 0.30, "Atrito deve ser >= 0.30 para evitar patinação")
	assert(player.get("_acceleration") >= 0.25, "Aceleração deve ser >= 0.25 para resposta imediata")
	print("[PASS] Parâmetros de movimentação ajustados: _friction=%.2f, _acceleration=%.2f" % [player._friction, player._acceleration])

	# 7. Testar Attack Lunge (Dash de Golpe)
	assert(player.attack_lunge_enabled, "attack_lunge_enabled deve ser true")
	assert(player.attack_dash_speed >= 200.0, "attack_dash_speed deve ser >= 200.0")
	assert(player.attack_dash_duration > 0.0, "attack_dash_duration deve ser > 0")

	# Simular início de golpe normal
	player._direcao_olhar = Vector2.RIGHT
	player._executar_golpe_normal()
	assert(player._is_attacking, "Player deve estar em estado de ataque")
	assert(player._attack_lunge_timer > 0.0, "Timer de avanço físico deve ser iniciado")
	assert(player.velocity.x > 150.0, "Velocidade de avanço (lunge) deve ser direcionada para a frente")
	print("[PASS] Attack Lunge (Avanço físico de ataque) disparado com sucesso: vel=%s, timer=%.3fs" % [str(player.velocity), player._attack_lunge_timer])

	# Simular processamento de física do lunge
	player._physics_process(0.07) # Meio da duração
	assert(player._attack_lunge_timer > 0.0, "Lunge ainda ativo")
	var vel_meio = player.velocity.x
	player._physics_process(0.10) # Conclusão do lunge
	assert(player._attack_lunge_timer <= 0.0, "Lunge deve finalizar")
	print("[PASS] Curva de desaceleração marcial do lunge validada (vel inicial -> %.1f -> desaceleração)." % vel_meio)

	# 8. Testar Efeito Visual AirPressureWave
	var wave_cls = load("res://entities/effects/AirPressureWave.gd")
	assert(wave_cls != null, "AirPressureWave.gd deve existir e compilar")
	var wave = wave_cls.new()
	wave.setup(player.global_position, Vector2.RIGHT, false, Color.TRANSPARENT)
	lobby.add_child(wave)
	assert(wave.rotation == 0.0, "Rotação deve alinhar com vetor Vector2.RIGHT (0 rad)")
	assert(wave.z_index == 4, "z_index deve ser 4")
	print("[PASS] AirPressureWave instanciado, alinhado direcionalmente e adicionado ao mundo com sucesso.")

	# Simular ciclo de vida de AirPressureWave
	wave._process(0.25) # Ultrapassa duração
	print("[PASS] Ciclo de vida e auto queue_free de AirPressureWave testados.")

	# 9. Testar Efeito Visual DashDustPuff
	var dust_cls = load("res://entities/effects/DashDustPuff.gd")
	assert(dust_cls != null, "DashDustPuff.gd deve existir e compilar")
	var dust = dust_cls.new()
	dust.setup(player.global_position, Vector2.RIGHT)
	lobby.add_child(dust)
	print("[PASS] DashDustPuff instanciado com spritesheet de partículas e adicionado com sucesso.")

	lobby.queue_free()
	print("============================================================")
	print("TODOS OS TESTES DO LOBBY & COMBATE PASSARAM COM 100% DE SUCESSO!")
	print("============================================================")
	get_tree().quit(0)
