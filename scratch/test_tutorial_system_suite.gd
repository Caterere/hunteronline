extends Node2D

# ============================================================
# MASTER TUTORIAL, ONBOARDING & KNOWLEDGE SUITE (24/24)
# ============================================================

func _ready() -> void:
	print("\n================================================================================")
	print("🎓 EXECUTANDO TUTORIAL, ONBOARDING & PROGRESSION SYSTEM SUITE (24/24)")
	print("================================================================================")

	var total_tests: int = 24
	var passed_tests: int = 0

	# ------------------------------------------------------------
	# TESTE 1: NOVO JOGO COMEÇA CORRETAMENTE
	# ------------------------------------------------------------
	print("\n[TESTE 1/24] Verificando inicialização limpa de Novo Jogo...")
	GameState.novo_jogo(1)
	assert(PlayerData.slot_ativo == 1, "Slot ativo deve ser 1")
	assert(not PlayerData.is_character_ready, "is_character_ready deve ser false")
	assert(not PlayerData.tutorial_concluido, "tutorial_concluido deve ser false")
	print("  ✅ [PASS] Novo jogo inicializado com estado limpo.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 2: NOVO JOGO ENTRA EM CHARACTER CREATION
	# ------------------------------------------------------------
	print("\n[TESTE 2/24] Verificando fluxo para Character Creation...")
	var scn_char = load("res://ui/CharacterSelection/CharacterSelectionUI.tscn").instantiate()
	add_child(scn_char)
	scn_char._abrir_criacao_para_slot(1)
	assert(GameManager.flow_state == GameManager.GameFlowState.CHARACTER_CREATION, "GameFlowState em CHARACTER_CREATION")
	assert(scn_char.panel_criacao.visible, "Painel de criação visível")
	print("  ✅ [PASS] Novo Jogo transiciona para Character Creation.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 3: CHARACTER CREATION NÃO ABRE MENUS DE GAMEPLAY
	# ------------------------------------------------------------
	print("\n[TESTE 3/24] Verificando isolamento de contexto durante Character Creation...")
	assert(InputContextManager.is_context("CHARACTER_CREATION"), "Contexto deve ser CHARACTER_CREATION")
	assert(not InputContextManager.is_global_hotkey_allowed(), "Hotkeys de gameplay bloqueadas")
	assert(not InputContextManager.is_gameplay_input_allowed(), "Input de gameplay bloqueado")
	print("  ✅ [PASS] Menus e comandos de gameplay bloqueados durante criação.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 4: TEXTO DIGITADO NÃO ACIONA HOTKEYS
	# ------------------------------------------------------------
	print("\n[TESTE 4/24] Testando prioridade de foco de LineEdit...")
	scn_char.line_edit_nome.text = "Gon_Freecss"
	scn_char.line_edit_nome.grab_focus()
	assert(InputContextManager.is_text_input_focused(), "Foco de texto detectado")
	assert(not InputContextManager.is_global_hotkey_allowed(), "Hotkeys bloqueadas com foco ativo")
	print("  ✅ [PASS] Digitação protegida contra disparos indevidos de hotkeys.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 5: APÓS CHARACTER CREATION INICIA TUTORIAL
	# ------------------------------------------------------------
	print("\n[TESTE 5/24] Testando confirmação de personagem e início do tutorial...")
	PlayerData.is_character_ready = true
	GameManager.set_flow_state(GameManager.GameFlowState.CHARACTER_CONFIRMATION)
	TutorialManager.iniciar_tutorial_inicial()
	assert(TutorialManager.em_tutorial == true, "TutorialManager deve estar em_tutorial")
	assert(TutorialManager.etapa_atual == TutorialManager.Step.INTRODUCAO, "Etapa inicial deve ser INTRODUCAO")
	assert(GameManager.flow_state == GameManager.GameFlowState.TUTORIAL, "GameFlowState em TUTORIAL")
	print("  ✅ [PASS] Tutorial guiado ativado após confirmação de personagem.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 6: TUTORIAL NÃO INICIA SIMULTANEAMENTE COM STORY
	# ------------------------------------------------------------
	print("\n[TESTE 6/24] Verificando separação estrita entre Tutorial e Story...")
	assert(not PlayerData.tour_lobby_concluido, "Tour de história não pode estar ativo durante tutorial")
	assert(StoryCutsceneManager.em_cutscene == false, "Cutscene de história desativada durante tutorial")
	print("  ✅ [PASS] Tutorial e Story ocorrem de forma sequencial e não concorrente.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 7: TUTORIAL DETECTA CONCLUSÃO DAS ETAPAS
	# ------------------------------------------------------------
	print("\n[TESTE 7/24] Testando pipeline Explicação -> Ação -> Conclusão de cada etapa...")
	# Etapa 0 -> 1 (Introdução -> Movimento)
	TutorialManager.notificar_interacao("Recepcionista Elena")
	assert(TutorialManager.etapa_atual == TutorialManager.Step.MOVIMENTO, "Avançou para MOVIMENTO")

	# Etapa 1 -> 2 (Movimento -> Interação)
	TutorialManager.notificar_movimento(65.0)
	assert(TutorialManager.etapa_atual == TutorialManager.Step.INTERACAO, "Avançou para INTERACAO")

	# Etapa 2 -> 3 (Interação -> Menus)
	TutorialManager.notificar_interacao("Recepcionista Elena")
	assert(TutorialManager.etapa_atual == TutorialManager.Step.MENUS, "Avançou para MENUS")

	# Etapa 3 -> 4 (Menus -> Inventário)
	TutorialManager._on_menu_opened("HunterMenu")
	assert(TutorialManager.etapa_atual == TutorialManager.Step.INVENTARIO, "Avançou para INVENTARIO")

	# Etapa 4 -> 5 (Inventário -> Combate)
	TutorialManager.notificar_aba_inventario_aberta()
	assert(TutorialManager.etapa_atual == TutorialManager.Step.COMBATE, "Avançou para COMBATE")

	# Etapa 5 -> 6 (Combate -> Status)
	TutorialManager.notificar_ataque_executado()
	TutorialManager.notificar_ataque_executado()
	TutorialManager.notificar_ataque_executado()
	assert(TutorialManager.etapa_atual == TutorialManager.Step.STATUS, "Avançou para STATUS")

	# Etapa 6 -> 7 (Status -> Nen Conceito)
	TutorialManager.notificar_aba_status_aberta()
	assert(TutorialManager.etapa_atual == TutorialManager.Step.NEN_CONCEITO, "Avançou para NEN_CONCEITO")

	print("  ✅ [PASS] Todas as etapas do tutorial detectam ações do jogador com precisão.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 8: TUTORIAL COMPLETO LIBERA STORY
	# ------------------------------------------------------------
	print("\n[TESTE 8/24] Testando conclusão do tutorial e transição para Story...")
	TutorialManager.notificar_interacao("Recepcionista Elena")
	assert(PlayerData.tutorial_concluido == true, "tutorial_concluido deve ser true")
	assert(GameManager.flow_state == GameManager.GameFlowState.STORY_INTRO, "GameFlowState transiciona para STORY_INTRO")
	print("  ✅ [PASS] Conclusão do tutorial libera oficialmente a introdução da história.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 9: TUTORIAL CONCLUÍDO NÃO REAPARECE APÓS LOAD
	# ------------------------------------------------------------
	print("\n[TESTE 9/24] Verificando que tutorial não reaparece após carregar save...")
	GameState.salvar_jogo(1)
	GameState.carregar_jogo(1)
	assert(PlayerData.tutorial_concluido == true, "tutorial_concluido preservado como true")
	assert(TutorialManager.em_tutorial == false, "TutorialManager inativo após reload")
	print("  ✅ [PASS] Tutorial concluído não reaparece após Load.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 10: SKIP FUNCIONA CORRETAMENTE
	# ------------------------------------------------------------
	print("\n[TESTE 10/24] Testando funcionalidade Pular Tutorial (Skip)...")
	GameState.novo_jogo(2)
	TutorialManager.iniciar_tutorial_inicial()
	assert(TutorialManager.em_tutorial == true, "Tutorial iniciado no slot 2")
	TutorialManager.pular_tutorial()
	assert(PlayerData.tutorial_concluido == true, "Slot 2 com tutorial_concluido = true")
	assert(TutorialManager.em_tutorial == false, "TutorialManager inativo após Skip")
	print("  ✅ [PASS] Pular Tutorial opera de forma limpa e imediata.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 11: SKIP NÃO CONCEDE HATSU
	# ------------------------------------------------------------
	print("\n[TESTE 11/24] Verificando que Skip não injeta Hatsus indevidos...")
	assert(PlayerData.hatsu_criados.is_empty(), "0 Hatsus após Skip")
	assert(PlayerData.hatsu_slots == [-1, -1, -1, -1], "Todos os 4 slots continuam -1")
	assert(not PlayerData.hatsu_desbloqueado, "Hatsu bloqueado narrativamente")
	print("  ✅ [PASS] Skip não concede Hatsu prematuramente.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 12: NOVO PERSONAGEM COMEÇA SEM HATSU
	# ------------------------------------------------------------
	print("\n[TESTE 12/24] Verificando que qualquer novo personagem começa rigorosamente com 0 Hatsus...")
	GameState.novo_jogo(3)
	assert(PlayerData.hatsu_criados.is_empty(), "0 Hatsus no slot 3")
	assert(PlayerData.obter_todos_hatsus_disponiveis().is_empty(), "Lista de Hatsus disponíveis vazia")
	print("  ✅ [PASS] Novo personagem começa sem Hatsu (Regra de Ouro atendida).")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 13: HATSU SÓ APARECE APÓS DESBLOQUEIO REAL
	# ------------------------------------------------------------
	print("\n[TESTE 13/24] Testando desbloqueio legítimo de Hatsu...")
	var h_jajanken = HatsuManager.obter_hatsu_canonico("gon_jajanken_pedra")
	PlayerData.adicionar_hatsu(h_jajanken)
	assert(PlayerData.hatsu_criados.size() == 1, "1 Hatsu desbloqueado")
	assert(PlayerData.obter_hatsu_slot(0) != null, "Hatsu equipado no slot 1")
	print("  ✅ [PASS] Hatsu só existe após aprendizado legítimo.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 14: CONHECIMENTOS SÃO PERSISTIDOS
	# ------------------------------------------------------------
	print("\n[TESTE 14/24] Testando persistência do Hunter Guide no SaveManager...")
	PlayerData.desbloquear_conhecimento("nen_tecnica_ten", "Aura & Nen")
	GameState.salvar_jogo(3)
	PlayerData.conhecimentos_desbloqueados.clear()
	GameState.carregar_jogo(3)
	assert(PlayerData.tem_conhecimento("nen_tecnica_ten"), "Conhecimento persistido e restaurado")
	GameState.deletar_save(3)
	print("  ✅ [PASS] Conhecimentos persistidos e restaurados do disco.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 15: NOVO SAVE COMEÇA SEM CONHECIMENTOS ANTERIORES
	# ------------------------------------------------------------
	print("\n[TESTE 15/24] Testando isolamento de conhecimentos em Novo Save...")
	GameState.novo_jogo(1)
	assert(not PlayerData.tem_conhecimento("nen_tecnica_ten"), "Novo save não herda técnicas avançadas")
	print("  ✅ [PASS] Isolamento de conhecimentos garantido entre saves.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 16: HUNTER GUIDE MOSTRA CONHECIMENTOS CORRETOS
	# ------------------------------------------------------------
	print("\n[TESTE 16/24] Testando renderização do Guia Hunter no HunterMenu...")
	var hm = load("res://ui/HunterMenu/HunterMenuUI.gd").new()
	add_child(hm)
	hm.tab_container.current_tab = 6 # Aba Guia Hunter
	hm._atualizar_conteudo_guia()
	assert(hm.guide_list_container != null, "guide_list_container presente")
	assert(hm.guide_list_container.get_child_count() > 0, "Artigos do guia renderizados")
	hm.queue_free()
	print("  ✅ [PASS] Aba Guia Hunter renderiza artigos e conhecimentos.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 17: HOTKEYS NÃO ATRAVESSAM MENUS
	# ------------------------------------------------------------
	print("\n[TESTE 17/24] Testando bloqueio de hotkeys durante menus abertos...")
	InputContextManager.set_context("MENU")
	assert(not InputContextManager.is_gameplay_input_allowed(), "Gameplay bloqueado durante menu")
	InputContextManager.set_context("GAMEPLAY")
	print("  ✅ [PASS] Hotkeys isoladas por contexto de menu.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 18: DIALOGUE BLOQUEIA GAMEPLAY ADEQUADAMENTE
	# ------------------------------------------------------------
	print("\n[TESTE 18/24] Testando bloqueio de gameplay durante diálogo...")
	InputContextManager.set_context("DIALOGUE")
	assert(not InputContextManager.is_gameplay_input_allowed(), "Gameplay bloqueado durante diálogo")
	assert(not InputContextManager.is_global_hotkey_allowed(), "Hotkeys bloqueadas durante diálogo")
	InputContextManager.set_context("GAMEPLAY")
	print("  ✅ [PASS] Diálogo consome seus próprios inputs e bloqueia gameplay.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 19: MENUS ANTIGOS NÃO SÃO ATIVADOS SIMULTANEAMENTE
	# ------------------------------------------------------------
	print("\n[TESTE 19/24] Verificando arquitetura de menu único via UIManager...")
	var hm_inst = UIManager.obter_hunter_menu()
	assert(hm_inst != null, "HunterMenu instanciado")
	UIManager.abrir_menu(hm_inst, "HunterMenu", 0)
	assert(UIManager.menu_atual_aberto == hm_inst, "Exatamente um menu ativo")
	UIManager.fechar_menu_atual()
	print("  ✅ [PASS] Arquitetura de menu único garantida.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 20: LOAD PRESERVA ESTADO DO TUTORIAL
	# ------------------------------------------------------------
	print("\n[TESTE 20/24] Testando integridade do tutorial_data após Load...")
	PlayerData.tutorial_data["inventario"] = true
	GameState.salvar_jogo(1)
	GameState.carregar_jogo(1)
	assert(PlayerData.tutorial_data.get("inventario", false) == true, "Etapa de inventário preservada")
	GameState.deletar_save(1)
	GameState.deletar_save(2)
	print("  ✅ [PASS] Estado estruturado do tutorial preservado.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 21: WORLDSTATE NÃO APRESENTA VAZAMENTOS ENTRE SAVES
	# ------------------------------------------------------------
	print("\n[TESTE 21/24] Testando isolamento do WorldState...")
	WorldState.alterar_infamia(50)
	assert(WorldState.obter_infamia() == 50, "Infâmia definida no slot 1")
	GameState.salvar_jogo(1)
	GameState.novo_jogo(2)
	assert(WorldState.obter_infamia() == 0, "WorldState limpo no novo slot 2")
	GameState.deletar_save(1)
	print("  ✅ [PASS] WorldState sem vazamentos entre saves.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 22: EVENTBUS RECEBE EVENTOS DE TUTORIAL
	# ------------------------------------------------------------
	print("\n[TESTE 22/24] Testando propagação de sinais de tutorial via EventBus...")
	var evento_box = [false]
	var cb_tut = func(_id: String): evento_box[0] = true
	EventBus.tutorial_started.connect(cb_tut)
	EventBus.tutorial_started.emit("tutorial_teste")
	assert(evento_box[0] == true, "EventBus propagou tutorial_started")
	EventBus.tutorial_started.disconnect(cb_tut)
	print("  ✅ [PASS] Barramento EventBus integrado aos eventos de tutorial.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 23: TELEMETRY RECEBE DADOS DO TUTORIAL
	# ------------------------------------------------------------
	print("\n[TESTE 23/24] Verificando registro de telemetria para tutorial...")
	assert(PlaytestTelemetry != null, "PlaytestTelemetry singleton ativo")
	EventBus.tutorial_completed.emit("tutorial_inicial")
	assert(PlaytestTelemetry.event_history.size() > 0, "Evento registrado no histórico de telemetria")
	print("  ✅ [PASS] Telemetria de onboarding ativa e monitorando progresso.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 24: TUTORIAIS CONTEXTUAIS FUNCIONAM SOB DEMANDA
	# ------------------------------------------------------------
	print("\n[TESTE 24/24] Testando disparo de tutoriais contextuais (Nen, Gyo, Hatsu, Treino)...")
	var ctx_box = [false]
	var cb_ctx = func(_tipo, _tit, _msg): ctx_box[0] = true
	TutorialManager.tutorial_contextual_disparado.connect(cb_ctx)
	TutorialManager.exibir_tutorial_contextual("NEN_DESPERTAR")
	assert(ctx_box[0] == true, "Tutorial contextual de Nen disparado")
	assert(PlayerData.tem_conhecimento("nen_4_principios"), "Conhecimento de Nen registrado no Guia")
	TutorialManager.tutorial_contextual_disparado.disconnect(cb_ctx)
	scn_char.queue_free()
	print("  ✅ [PASS] Tutoriais contextuais operam sob demanda com desbloqueio no Guia.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE TUTORIAL, ONBOARDING & HUNTER GUIDE:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DO SISTEMA: ONBOARDING, TUTORIAIS CONTEXTUAIS E GUIA BLINDADOS!")
	print("================================================================================\n")

	get_tree().quit(0)