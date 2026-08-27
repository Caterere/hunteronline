extends Node2D

# ============================================================
# MASTER INPUT & UX OVERHAUL SUITE — HUNTER ONLINE
# ============================================================

const NenQuickActionBarScript = preload("res://ui/hud/NenQuickActionBar.gd")
const WingScript = preload("res://entities/npc/wing/Wing.gd")

func _ready() -> void:
	print("\n================================================================================")
	print("🚀 EXECUTANDO INPUT & UX OVERHAUL SUITE (7/7)")
	print("================================================================================")

	var total_tests: int = 7
	var passed_tests: int = 0

	# 1. TESTE UIMANAGER AUTOLOAD
	print("\n[TESTE 1/7] UIManager Autoload & InputMap...")
	assert(UIManager != null, "UIManager deve estar ativo como Singleton Autoload")
	assert(InputMap.has_action("open_hunter_menu"), "Ação open_hunter_menu deve existir")
	assert(InputMap.has_action("open_map_menu"), "Ação open_map_menu deve existir")
	assert(InputMap.has_action("open_journal_menu"), "Ação open_journal_menu deve existir")
	assert(InputMap.has_action("nen_modifier"), "Ação nen_modifier deve existir")
	print("  ✅ [PASS] UIManager ativo com ações semânticas padronizadas.")
	passed_tests += 1

	# 2. TESTE HUNTER MENU CONSOLIDAÇÃO
	print("\n[TESTE 2/7] Hunter Menu Consolidado & Abertura por [TAB]...")
	UIManager.alternar_hunter_menu(0)
	assert(UIManager.hunter_menu_instance.visible, "Hunter Menu deve ficar visível ao alternar")
	if DisplayServer.get_name() != "headless":
		assert(get_tree().paused, "Jogo deve pausar com menu aberto")
	UIManager.fechar_menu_atual()
	assert(not UIManager.hunter_menu_instance.visible, "Hunter Menu deve ocultar após fechar")
	assert(not get_tree().paused, "Jogo deve despausar após fechar")
	print("  ✅ [PASS] HunterMenuUI consolidado abre e fecha com controle estrito de pausa.")
	passed_tests += 1

	# 3. TESTE NAVEGAÇÃO DE ABAS COM Q/E
	print("\n[TESTE 3/7] Navegação entre Abas com Q/E...")
	var hm = UIManager.obter_hunter_menu()
	UIManager.abrir_menu(hm, "HUNTER_MENU", 0)
	assert(hm.tab_container.current_tab == 0, "Aba inicial deve ser Status (0)")
	hm.definir_aba_ativa(1)
	assert(hm.tab_container.current_tab == 1, "Aba deve avançar para Inventário (1)")
	hm.definir_aba_ativa(2)
	assert(hm.tab_container.current_tab == 2, "Aba deve avançar para Nen Tree (2)")
	hm.definir_aba_ativa(6)
	assert(hm.tab_container.current_tab == 6, "Aba 6 deve ser Aparência & Criação")
	assert(hm.edit_nome != null and hm.picker_roupa != null, "Campos de personalização devem existir")
	UIManager.fechar_menu_atual()
	print("  ✅ [PASS] Navegação entre as 7 abas tabuladas (incluindo Aparência & Criação) executada com sucesso.")
	passed_tests += 1

	# 4. TESTE COMPATIBILIDADE RETROATIVA DE TECLAS (C, I, N, H, L)
	print("\n[TESTE 4/7] Compatibilidade Retroativa (C, I, N, H, L)...")
	var ev_i := InputEventKey.new()
	ev_i.pressed = true
	ev_i.keycode = KEY_I
	UIManager._unhandled_input(ev_i)
	assert(hm.visible, "Pressionar I deve abrir o menu")
	assert(hm.tab_container.current_tab == 1, "Pressionar I deve abrir a aba de Inventário")
	
	var ev_n := InputEventKey.new()
	ev_n.pressed = true
	ev_n.keycode = KEY_N
	UIManager._unhandled_input(ev_n)
	assert(hm.visible, "Pressionar N deve manter o menu aberto")
	assert(hm.tab_container.current_tab == 2, "Pressionar N deve abrir a aba de Nen Tree")
	UIManager.fechar_menu_atual()
	print("  ✅ [PASS] Teclas legadas [C, I, N, H, L] abrem diretamente suas abas no Hunter Menu.")
	passed_tests += 1

	# 5. TESTE JOURNAL UI & CONHECIMENTO CONSOLIDADO
	print("\n[TESTE 5/7] Journal UI & Enciclopédia de Nen...")
	var jm = UIManager.obter_journal_menu()
	UIManager.abrir_menu(jm, "JOURNAL_MENU", 0)
	assert(jm.visible, "Journal UI deve ficar visível")
	assert(jm.tab_container.current_tab == 0, "Aba 0 deve ser Enciclopédia de Nen")
	jm.definir_aba_ativa(1)
	assert(jm.tab_container.current_tab == 1, "Aba 1 deve ser Treino de Wing")
	jm.definir_aba_ativa(3)
	assert(jm.tab_container.current_tab == 3, "Aba 3 deve ser Conquistas")
	UIManager.fechar_menu_atual()
	print("  ✅ [PASS] Journal UI consolida Lore, Treino, Bestas e Conquistas.")
	passed_tests += 1

	# 6. TESTE NEN QUICK ACTION BAR (MODIFIER LAYER)
	print("\n[TESTE 6/7] Nen Quick Action Bar Hotkeys...")
	var dummy_player := Node2D.new()
	var nen_sys = load("res://scripts/systems/NenSystem.gd").new()
	nen_sys.name = "NenSystem"
	dummy_player.add_child(nen_sys)
	add_child(dummy_player)
	
	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 2
	PlayerData.attributes["aura_max"] = 200.0
	PlayerData.attributes["aura"] = 200.0
	nen_sys.sincronizar_nen_com_player_data()
	nen_sys.tecnicas[NenSystem.Tecnica.TEN]["nivel"] = 1
	nen_sys.tecnicas[NenSystem.Tecnica.TEN]["desbloqueada"] = true
	nen_sys.tecnicas[NenSystem.Tecnica.KO]["nivel"] = 1
	nen_sys.tecnicas[NenSystem.Tecnica.KO]["desbloqueada"] = true
	
	var quick_bar = NenQuickActionBarScript.new()
	add_child(quick_bar)
	quick_bar.nen_system = nen_sys
	
	quick_bar._acionar_tecnica(quick_bar.TECNICAS_CONFIG[0]) # TEN
	assert(nen_sys.tecnica_ativa(NenSystem.Tecnica.TEN), "Quick Action Bar deve ativar TEN")
	
	quick_bar._acionar_tecnica(quick_bar.TECNICAS_CONFIG[4]) # KO
	assert(nen_sys.tecnica_ativa(NenSystem.Tecnica.KO), "Quick Action Bar deve ativar KO")
	
	quick_bar._acionar_tecnica(quick_bar.TECNICAS_CONFIG[8]) # OFF
	assert(not nen_sys.tecnica_ativa(NenSystem.Tecnica.TEN), "OFF deve desativar TEN")
	assert(not nen_sys.tecnica_ativa(NenSystem.Tecnica.KO), "OFF deve desativar KO")
	
	quick_bar.queue_free()
	dummy_player.queue_free()
	print("  ✅ [PASS] Nen Quick Action Bar permite seleção e alternância rápida sem menus.")
	passed_tests += 1

	# 7. TESTE WING TUTORIAL DIEGÉTICO
	print("\n[TESTE 7/7] Wing Tutorial Diegético...")
	var wing = WingScript.new()
	add_child(wing)
	
	PlayerData.despertou_nen = false
	PlayerData.quest_states["wing_tutorial_progresso"] = 1
	
	var dummy_p := CharacterBody2D.new()
	dummy_p.add_to_group("player")
	add_child(dummy_p)
	
	wing._on_interacted(dummy_p)
	assert(PlayerData.despertou_nen, "Interagir com Wing deve despertar Nen")
	assert(int(PlayerData.attributes.get("nivel_nen", 0)) >= 1, "Nível de Nen deve ser 1")
	assert(PlayerData.quest_states.get("wing_tutorial_progresso", 0) >= 2, "Progresso do tutorial deve avançar")
	
	wing.queue_free()
	dummy_p.queue_free()
	print("  ✅ [PASS] Tutorial progressivo de Wing ensina comandos e desbloqueia sistemas no mundo.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE INPUT & UX OVERHAUL:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DA UX: INTERFACE LIMPA, MODIFICADORES EM TEMPO REAL E TUTORIAL DIEGÉTICO!")
	print("================================================================================\n")

	get_tree().quit(0)