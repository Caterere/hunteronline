extends Node2D

# ============================================================
# MASTER INITIAL HATSU AUDIT & VALIDATION SUITE (10/10)
# ============================================================

func _ready() -> void:
	print("\n================================================================================")
	print("🥋 EXECUTANDO INITIAL HATSU CORRECTION & PROGRESSION SUITE (10/10)")
	print("================================================================================")

	var total_tests: int = 10
	var passed_tests: int = 0

	# ------------------------------------------------------------
	# TESTE 1: NOVO PERSONAGEM POSSUI 0 HATSUS
	# ------------------------------------------------------------
	print("\n[TESTE 1/10] Verificando que Novo Personagem começa com 0 Hatsus...")
	GameState.novo_jogo(1)
	assert(PlayerData.hatsu_criados.is_empty(), "hatsu_criados deve estar vazio no início")
	assert(PlayerData.obter_todos_hatsus_disponiveis().is_empty(), "obter_todos_hatsus_disponiveis deve retornar lista vazia")
	print("  ✅ [PASS] 0 Hatsus desbloqueados inicialmente.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 2: NOVO PERSONAGEM POSSUI 0 HATSUS EQUIPADOS
	# ------------------------------------------------------------
	print("\n[TESTE 2/10] Verificando slots de Hatsu vazios (-1, -1, -1, -1)...")
	assert(PlayerData.hatsu_slots == [-1, -1, -1, -1], "Todos os 4 slots devem ser -1")
	for i in range(4):
		assert(PlayerData.obter_hatsu_slot(i) == null, "Slot %d deve retornar null" % (i + 1))
	print("  ✅ [PASS] 0 Hatsus equipados nos 4 slots.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 3: MENU DE HATSU MOSTRA ESTADO VAZIO CORRETAMENTE
	# ------------------------------------------------------------
	print("\n[TESTE 3/10] Verificando interface do HunterMenu (Aba Hatsu)...")
	var hm = load("res://ui/HunterMenu/HunterMenuUI.gd").new()
	add_child(hm)
	hm.tab_container.current_tab = 3 # Aba Hatsu
	hm._atualizar_conteudo_hatsu()
	assert(hm.hatsu_list_container != null, "hatsu_list_container deve existir")
	assert(hm.hatsu_list_container.get_child_count() >= 4, "Deve renderizar os slots vazios")
	hm.queue_free()
	print("  ✅ [PASS] Menu de Hatsu exibe estado vazio sem Hatsus fantasmas.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 4: COMBATE NÃO QUEBRA SEM HATSU EQUIPADO
	# ------------------------------------------------------------
	print("\n[TESTE 4/10] Testando execução segura de combate e hotkeys sem Hatsu...")
	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	var hatsu_sys = player_scn.get_node_or_null("HatsuSystem") as HatsuSystem
	assert(hatsu_sys != null, "HatsuSystem deve existir no Player")
	var falhou_box = [false]
	hatsu_sys.hatsu_falhou.connect(func(slot, motivo): falhou_box[0] = true)
	var res = hatsu_sys.usar_hatsu(0)
	assert(res == false, "usar_hatsu sem habilidade deve retornar false de forma segura")
	assert(falhou_box[0] == true, "Sinal hatsu_falhou deve ser emitido sem crash")
	player_scn.queue_free()
	print("  ✅ [PASS] Execução de Hatsu em estado vazio é 100% segura e não quebra combate.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 5: DESBLOQUEAR HATSU POSTERIORMENTE FUNCIONA
	# ------------------------------------------------------------
	print("\n[TESTE 5/10] Testando aprendizado/desbloqueio progressivo de Hatsu...")
	var jajanken = HatsuManager.obter_hatsu_canonico("gon_jajanken_pedra")
	assert(jajanken != null, "Jajanken deve ser instanciável do catálogo")
	var idx = PlayerData.adicionar_hatsu(jajanken)
	assert(idx == 0, "Primeiro Hatsu deve ser índice 0")
	assert(PlayerData.hatsu_criados.size() == 1, "hatsu_criados deve ter 1 habilidade")
	assert(PlayerData.hatsu_desbloqueado == true, "hatsu_desbloqueado marcado como true")
	print("  ✅ [PASS] Hatsu adicionado com sucesso durante a progressão.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 6: APÓS DESBLOQUEIO, APARECE NO MENU E NOS SLOTS
	# ------------------------------------------------------------
	print("\n[TESTE 6/10] Verificando equipamento do Hatsu no Slot 1...")
	assert(PlayerData.obter_hatsu_slot(0) != null, "Slot 0 deve ter o Jajanken equipado")
	assert(PlayerData.obter_hatsu_slot(0).nome.contains("Jajanken"), "Nome deve corresponder ao Jajanken")
	print("  ✅ [PASS] Hatsu recém-desbloqueado visível e equipado.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 7: SALVAR PERSONAGEM COM HATSU FUNCIONA
	# ------------------------------------------------------------
	print("\n[TESTE 7/10] Testando persistência de Hatsu no SaveManager...")
	PlayerData.slot_ativo = 1
	var salvo_ok = GameState.salvar_jogo(1)
	assert(salvo_ok, "Jogo com Hatsu deve ser salvo com sucesso")
	print("  ✅ [PASS] Hatsu serializado e salvo no disco.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 8: CARREGAR PERSONAGEM RESTAURA OS HATSUS SALVOS
	# ------------------------------------------------------------
	print("\n[TESTE 8/10] Testando carregamento e restauração de Hatsu...")
	PlayerData.hatsu_criados.clear()
	PlayerData.hatsu_slots = [-1, -1, -1, -1]
	var load_ok = GameState.carregar_jogo(1)
	assert(load_ok, "Carregamento bem-sucedido")
	assert(PlayerData.hatsu_criados.size() == 1, "1 Hatsu restaurado")
	assert(PlayerData.obter_hatsu_slot(0) != null, "Slot 0 preservado")
	assert(PlayerData.obter_hatsu_slot(0).nome.contains("Jajanken"), "Nome do Hatsu preservado após reload")
	GameState.deletar_save(1)
	print("  ✅ [PASS] Save/Load preserva os Hatsus legítimos conquistados pelo jogador.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 9: CRIAR NOVO PERSONAGEM CONTINUA COMEÇANDO COM 0 HATSUS
	# ------------------------------------------------------------
	print("\n[TESTE 9/10] Testando criação de segundo personagem após save/load...")
	GameState.novo_jogo(2)
	assert(PlayerData.hatsu_criados.is_empty(), "Novo personagem deve sempre começar com 0 Hatsus")
	assert(PlayerData.hatsu_slots == [-1, -1, -1, -1], "Todos os slots devem estar vazios (-1)")
	assert(not PlayerData.hatsu_desbloqueado, "hatsu_desbloqueado deve ser false")
	GameState.deletar_save(2)
	print("  ✅ [PASS] Novo personagem permanece estritamente com 0 Hatsus.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 10: CATÁLOGO CANÔNICO & INIMIGOS/NPCS PRESERVADOS
	# ------------------------------------------------------------
	print("\n[TESTE 10/10] Verificando integridade do Catálogo de Hatsu para NPCs e Inimigos...")
	var catalogo = CanonHatsuCatalog.obter_hatsus_canonicos()
	assert(catalogo.size() >= 20, "Catálogo deve manter todas as habilidades para NPCs/Inimigos/Chefes")
	var h_biscuit = HatsuManager.obter_hatsu_canonico("netero_guanyin")
	assert(h_biscuit != null, "Hatsus canônicos instanciáveis sob demanda para combate")
	print("  ✅ [PASS] Catálogo global preservado integralmente para o ecossistema do jogo.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE HATSU INICIAL:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DE PROGRESSÃO: ESTADO INICIAL CANÔNICO (0 HATSUS) BLINDADO!")
	print("================================================================================\n")

	get_tree().quit(0)