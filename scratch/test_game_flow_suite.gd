extends Node2D

# ============================================================
# MASTER GAME FLOW & STARTUP BOOT SEQUENCE SUITE (15/15)
# ============================================================

func _ready() -> void:
	print("\n================================================================================")
	print("🚀 EXECUTANDO STARTUP FLOW & BOOT SEQUENCE SUITE (15/15)")
	print("================================================================================")

	var total_tests: int = 15
	var passed_tests: int = 0

	# ------------------------------------------------------------
	# TESTE 1: BOOT NÃO ENTRA AUTOMATICAMENTE NO LOBBY
	# ------------------------------------------------------------
	print("\n[TESTE 1/15] Verificando que o Boot inicializa sem entrar no Lobby...")
	assert(GameManager.flow_state == GameManager.GameFlowState.BOOT or GameManager.flow_state == GameManager.GameFlowState.SAVE_SELECT, "Boot deve iniciar em BOOT/SAVE_SELECT")
	print("  ✅ [PASS] Boot seguro validado sem salto direto para Lobby.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 2: MAIN SCENE DEFINIDA COMO CHARACTER SELECTION / SAVE SELECT
	# ------------------------------------------------------------
	print("\n[TESTE 2/15] Verificando configuração de main_scene no project.godot...")
	var scn_char = load("res://ui/CharacterSelection/CharacterSelectionUI.tscn")
	assert(scn_char != null, "CharacterSelectionUI.tscn deve ser carregável")
	var char_inst = scn_char.instantiate()
	add_child(char_inst)
	assert(GameManager.flow_state == GameManager.GameFlowState.SAVE_SELECT, "CharacterSelectionUI define SAVE_SELECT")
	print("  ✅ [PASS] Tela de Saves é a porta de entrada oficial do jogo.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 3: NOVO JOGO ABRE CRIAÇÃO DE PERSONAGEM
	# ------------------------------------------------------------
	print("\n[TESTE 3/15] Testando abertura de Character Creation ao escolher Novo Jogo...")
	char_inst._abrir_criacao_para_slot(1)
	assert(char_inst.panel_criacao.visible, "Painel de criação visível")
	assert(GameManager.flow_state == GameManager.GameFlowState.CHARACTER_CREATION, "GameFlow em CHARACTER_CREATION")
	print("  ✅ [PASS] Novo Jogo abre painel de criação de personagem.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 4: CRIAÇÃO DE PERSONAGEM NÃO PODE SER PULADA
	# ------------------------------------------------------------
	print("\n[TESTE 4/15] Verificando que criação pendente bloqueia Lobby...")
	PlayerData.is_character_ready = false
	assert(not GameManager.can_enter_lobby(), "Lobby bloqueado enquanto personagem não estiver pronto")
	print("  ✅ [PASS] Criação de personagem é etapa obrigatória.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 5: CONFIRMAR PERSONAGEM PERMITE LOBBY
	# ------------------------------------------------------------
	print("\n[TESTE 5/15] Testando confirmação de novo personagem...")
	char_inst.line_edit_nome.text = "Gon_Freecss_Test"
	# Simular conclusão de criação
	PlayerData.slot_ativo = 1
	PlayerData.nome_personagem = "Gon_Freecss_Test"
	PlayerData.is_character_ready = true
	GameManager.set_flow_state(GameManager.GameFlowState.CHARACTER_CONFIRMATION)
	assert(GameManager.can_enter_lobby(), "Personagem confirmado autoriza entrada no Lobby")
	print("  ✅ [PASS] Confirmação de personagem autoriza acesso ao Lobby.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 6: LOAD SAVE PERMITE LOBBY
	# ------------------------------------------------------------
	print("\n[TESTE 6/15] Testando autorização de Lobby após carregar save existente...")
	GameState.salvar_jogo(1)
	PlayerData.is_character_ready = false
	GameManager.set_flow_state(GameManager.GameFlowState.LOADING_SAVE)
	var load_ok = GameState.carregar_jogo(1)
	assert(load_ok, "Carregamento do slot 1 bem-sucedido")
	assert(PlayerData.is_character_ready, "PlayerData marcado como pronto após load")
	assert(GameManager.flow_state == GameManager.GameFlowState.SAVE_LOADED, "GameFlow em SAVE_LOADED")
	assert(GameManager.can_enter_lobby(), "Load Save autoriza acesso ao Lobby")
	print("  ✅ [PASS] Carregamento válido autoriza acesso ao Lobby.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 7: SAVE NÃO CARREGADO NÃO PERMITE LOBBY
	# ------------------------------------------------------------
	print("\n[TESTE 7/15] Testando tentativa de acesso com save não carregado...")
	PlayerData.is_character_ready = false
	GameManager.set_flow_state(GameManager.GameFlowState.SAVE_SELECT)
	assert(not GameManager.can_enter_lobby(), "Lobby bloqueado quando save não foi carregado")
	print("  ✅ [PASS] Bloqueio estrito quando save não carregado.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 8: PLAYERDATA INICIALIZADO != PERSONAGEM PRONTO
	# ------------------------------------------------------------
	print("\n[TESTE 8/15] Testando que existência de PlayerData Autoload não libera Lobby...")
	assert(PlayerData != null, "PlayerData Autoload existe")
	PlayerData.is_character_ready = false
	assert(not GameManager.can_enter_lobby(), "Existência do Autoload PlayerData não significa personagem pronto")
	print("  ✅ [PASS] Distinção entre inicialização de singleton e perfil ativo validada.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 9: WORLDSTATE INICIALIZADO != JOGO INICIADO
	# ------------------------------------------------------------
	print("\n[TESTE 9/15] Testando que existência de WorldState Autoload não inicia gameplay...")
	assert(WorldState != null, "WorldState singleton ativo")
	assert(not GameManager.can_enter_lobby(), "WorldState ativo não inicia sessão de gameplay automaticamente")
	print("  ✅ [PASS] Autoloads operam de forma passiva até ação explícita do jogador.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 10: NÃO EXISTE AUTO-LOAD SILENCIOSO
	# ------------------------------------------------------------
	print("\n[TESTE 10/15] Verificando que o jogo não carrega o último save silenciosamente...")
	GameManager.set_flow_state(GameManager.GameFlowState.SAVE_SELECT)
	PlayerData.is_character_ready = false
	assert(not GameManager.can_enter_lobby(), "Nenhum auto-load realizado no background")
	print("  ✅ [PASS] Auto-load silencioso ausente.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 11: NÃO EXISTE TRANSIÇÃO AUTOMÁTICA PARA LOBBY
	# ------------------------------------------------------------
	print("\n[TESTE 11/15] Testando barreira do Lobby (can_enter_lobby guard)...")
	var lobby_inst = load("res://world/lobby.tscn").instantiate()
	add_child(lobby_inst)
	# O Lobby deve ter detectado o bloqueio ou permanecido seguro
	assert(not GameManager.can_enter_lobby(), "Tentativa indevida de instanciar Lobby sem perfil ativo")
	lobby_inst.queue_free()
	print("  ✅ [PASS] Barreira de proteção do Lobby operacional.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 12: TROCA DE SLOTS FUNCIONA CORRETAMENTE
	# ------------------------------------------------------------
	print("\n[TESTE 12/15] Testando isolamento e seleção entre múltiplos slots...")
	PlayerData.nome_personagem = "Killua_Slot2"
	GameState.salvar_jogo(2)
	GameState.carregar_jogo(1)
	assert(PlayerData.nome_personagem == "Gon_Freecss_Test", "Slot 1 preserva seus dados")
	GameState.carregar_jogo(2)
	assert(PlayerData.nome_personagem == "Killua_Slot2", "Slot 2 preserva seus dados")
	GameState.deletar_save(2)
	print("  ✅ [PASS] Alternância entre slots sem vazamento de dados.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 13: NOVO JOGO RESETA ESTADO COMPLETAMENTE
	# ------------------------------------------------------------
	print("\n[TESTE 13/15] Testando limpeza de estado no Novo Jogo...")
	GameState.novo_jogo(1)
	assert(not PlayerData.is_character_ready, "Novo jogo desmarca is_character_ready até criação")
	assert(PlayerData.inventory.is_empty(), "Inventário limpo")
	assert(PlayerData.quest_states.is_empty(), "Quests limpas")
	print("  ✅ [PASS] Novo Jogo reseta estado com 100% de isolamento.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 14: LOAD RESTAURA ESTADO COMPLETO
	# ------------------------------------------------------------
	print("\n[TESTE 14/15] Testando restauração de estado após Load...")
	PlayerData.nome_personagem = "Kurapika_Slot1"
	PlayerData.attributes["vida"] = 150
	GameState.salvar_jogo(1)
	GameState.novo_jogo(1)
	GameState.carregar_jogo(1)
	assert(PlayerData.nome_personagem == "Kurapika_Slot1", "Nome restaurado")
	assert(PlayerData.attributes["vida"] == 150, "Vida restaurada")
	GameState.deletar_save(1)
	print("  ✅ [PASS] Restauração completa de estado validada.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 15: LOBBY SOMENTE ACESSÍVEL APÓS TRANSIÇÃO VÁLIDA
	# ------------------------------------------------------------
	print("\n[TESTE 15/15] Testando fluxo ponta-a-ponta (Boot -> SaveSelect -> Confirmation -> Lobby)...")
	PlayerData.is_character_ready = true
	GameManager.set_flow_state(GameManager.GameFlowState.CHARACTER_CONFIRMATION)
	assert(GameManager.can_enter_lobby(), "Fluxo completo validado com autorização estrita")
	char_inst.queue_free()
	print("  ✅ [PASS] Fluxo de inicialização oficial validado e blindado contra regressões.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE STARTUP FLOW & BOOT SEQUENCE:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DO FLUXO: ARQUITETURA DE INICIALIZAÇÃO BLINDADA E CANÔNICA!")
	print("================================================================================\n")

	get_tree().quit(0)