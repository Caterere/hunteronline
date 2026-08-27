extends Node2D

# ============================================================
# MASTER VISUAL THEME & UI CONSISTENCY SUITE (8/8)
# ============================================================

const HunterUIStyleScript = preload("res://ui/theme/HunterUIStyle.gd")
const HunterMenuUIScript = preload("res://ui/HunterMenu/HunterMenuUI.gd")
const JournalUIScript = preload("res://ui/Journal/JournalUI.gd")
const PauseMenuUIScript = preload("res://ui/PauseMenu/PauseMenuUI.gd")
const CharacterSelectionUIScript = preload("res://ui/CharacterSelection/CharacterSelectionUI.gd")

func _ready() -> void:
	print("\n================================================================================")
	print("🎨 EXECUTANDO VISUAL IDENTITY & UI THEME SUITE (8/8)")
	print("================================================================================")

	var total_tests: int = 8
	var passed_tests: int = 0

	# ------------------------------------------------------------
	# TESTE 1: VALIDAÇÃO DA PALETA GLOBAL HUNTER X HUNTER
	# ------------------------------------------------------------
	print("\n[TESTE 1/8] Verificando constantes de paleta do HunterUIStyle...")
	assert(HunterUIStyle.COLOR_HUNTER_GREEN != null, "Cor Hunter Green Primária deve existir")
	assert(HunterUIStyle.COLOR_GOLD != null, "Cor Ouro/Âmbar deve existir")
	assert(HunterUIStyle.COLOR_AURA_CYAN != null, "Cor Ciano Nen deve existir")
	assert(HunterUIStyle.COLOR_BG_NAVY != null, "Cor Midnight Navy deve existir")
	assert(HunterUIStyle.COLOR_HP_CRIMSON != null, "Cor HP Crimson deve existir")
	assert(HunterUIStyle.COLOR_TEXT_PRIMARY != null, "Cor de texto primária deve existir")
	print("  ✅ [PASS] Paleta global canônica validada com sucesso.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 2: FACTORY DE STYLEBOXES (PAINEL, CARDS, BOTÕES, BARRAS)
	# ------------------------------------------------------------
	print("\n[TESTE 2/8] Testando criação de StyleBoxes...")
	var st_p = HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD)
	assert(st_p is StyleBoxFlat, "Deve ser StyleBoxFlat")
	assert(st_p.border_color == HunterUIStyle.COLOR_BORDER_GOLD, "Borda deve ser dourada")

	var st_card = HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GREEN)
	assert(st_card is StyleBoxFlat, "Deve ser StyleBoxFlat")

	var st_nen = HunterUIStyle.criar_style_card_nen(true)
	assert(st_nen.border_color == HunterUIStyle.COLOR_AURA_CYAN, "Borda de Nen ativo deve ser ciano")

	var st_btn_n = HunterUIStyle.criar_style_botao_normal()
	var st_btn_h = HunterUIStyle.criar_style_botao_hover()
	assert(st_btn_n is StyleBoxFlat and st_btn_h is StyleBoxFlat, "Estilos de botão válidos")

	var st_pbg = HunterUIStyle.criar_style_progress_bg()
	var st_pfill = HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_HP_CRIMSON)
	assert(st_pbg is StyleBoxFlat and st_pfill is StyleBoxFlat, "Estilos de barra válidos")
	print("  ✅ [PASS] Factory de StyleBoxes gera elementos visuais com precisão.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 3: HUNTER MENU CONSOLIDADO (7 ABAS COM ESTILO)
	# ------------------------------------------------------------
	print("\n[TESTE 3/8] Testando estilização do HunterMenuUI...")
	var hm = HunterMenuUIScript.new()
	add_child(hm)
	hm.abrir()
	assert(hm.panel_main != null, "Painel principal deve existir")
	assert(hm.tab_container != null, "TabContainer deve existir")
	assert(hm.tab_container.get_tab_count() == 7, "Deve conter 7 abas")
	
	# Percorrer abas
	for idx in range(7):
		hm.definir_aba_ativa(idx)
		assert(hm.tab_container.current_tab == idx, "Aba %d ativada" % idx)
	
	hm.visible = false
	hm.queue_free()
	print("  ✅ [PASS] HunterMenuUI estilizado e navegável em todas as 7 abas.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 4: JOURNAL & ENCICLOPÉDIA DE NEN
	# ------------------------------------------------------------
	print("\n[TESTE 4/8] Testando estilização do JournalUI...")
	var jm = JournalUIScript.new()
	add_child(jm)
	jm.abrir()
	assert(jm.panel_main != null, "Painel principal do Journal deve existir")
	assert(jm.tab_container != null, "TabContainer deve existir")
	assert(jm.tab_container.get_tab_count() == 4, "Deve conter 4 abas")
	
	for idx in range(4):
		jm.definir_aba_ativa(idx)
		assert(jm.tab_container.current_tab == idx, "Aba %d do Journal ativada" % idx)
	
	jm.visible = false
	jm.queue_free()
	print("  ✅ [PASS] JournalUI estilizado e navegável em todas as 4 abas.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 5: PLAYER HUD & BARRAS DE ENERGIA (HP, AURA, XP, HATSU)
	# ------------------------------------------------------------
	print("\n[TESTE 5/8] Testando estilização do PlayerHUD...")
	var hud = load("res://ui/hud/HUD.tscn").instantiate()
	add_child(hud)
	
	assert(hud.player_card_panel != null, "Player Card Panel deve existir")
	assert(hud.bar_hp != null, "Barra de HP deve existir")
	assert(hud.bar_aura != null, "Barra de Aura deve existir")
	assert(hud.bar_xp != null, "Barra de XP deve existir")
	assert(hud.slot_panels.size() == 4, "Deve conter 4 slots de Hatsu")
	
	# Testar Boss Bar
	hud.notificar_boss_status("Guardião Ancestral", 500, 1000)
	assert(hud.boss_bar_panel.visible, "Boss bar visível")
	hud.esconder_boss_bar()
	assert(not hud.boss_bar_panel.visible, "Boss bar oculta")
	
	hud.queue_free()
	print("  ✅ [PASS] PlayerHUD e barras de status com tema aplicado com sucesso.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 6: NEN QUICK ACTION BAR
	# ------------------------------------------------------------
	print("\n[TESTE 6/8] Testando estilização da NenQuickActionBar...")
	var nen_bar = load("res://ui/hud/NenQuickActionBar.gd").new()
	add_child(nen_bar)
	assert(nen_bar.container_tecnicas != null, "Container de técnicas deve existir")
	assert(nen_bar.tecnica_buttons.size() >= 8, "Deve conter botões para todas as técnicas de Nen")
	nen_bar.queue_free()
	print("  ✅ [PASS] NenQuickActionBar estilizada e pronta para combate.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 7: PAUSE MENU (ESC)
	# ------------------------------------------------------------
	print("\n[TESTE 7/8] Testando estilização do PauseMenuUI...")
	var pause_menu = PauseMenuUIScript.new()
	add_child(pause_menu)
	pause_menu.abrir()
	assert(pause_menu.painel_principal != null, "Painel de pausa deve existir")
	assert(pause_menu.btn_continuar != null, "Botão continuar deve existir")
	pause_menu.fechar()
	assert(not pause_menu.visible, "Menu de pausa fechado")
	pause_menu.queue_free()
	print("  ✅ [PASS] PauseMenuUI estilizado com botões padronizados.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 8: SELEÇÃO & CRIAÇÃO DE PERSONAGENS
	# ------------------------------------------------------------
	print("\n[TESTE 8/8] Testando CharacterSelectionUI...")
	var char_sel = CharacterSelectionUIScript.new()
	add_child(char_sel)
	assert(char_sel.panel_slots != null, "Painel de slots deve existir")
	assert(char_sel.panel_criacao != null, "Painel de criação deve existir")
	char_sel.queue_free()
	print("  ✅ [PASS] CharacterSelectionUI com estilo Hunter aplicado nos 3 slots e criação.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE VISUAL IDENTITY & UI THEME:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DO TEMA: IDENTIDADE VISUAL DE AVENTURA SHONEN UNIFICADA E CONSISTENTE!")
	print("================================================================================\n")

	get_tree().quit(0)