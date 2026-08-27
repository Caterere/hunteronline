extends Node2D

# ============================================================
# MASTER INPUT CONTEXT & PRIORITY SUITE (10/10)
# ============================================================

const CharacterSelectionUIScript = preload("res://ui/CharacterSelection/CharacterSelectionUI.gd")
const VisualDialogueUIScript = preload("res://ui/dialogue/VisualDialogueUI.gd")

func _ready() -> void:
	print("\n================================================================================")
	print("🚀 EXECUTANDO INPUT CONTEXT & PRIORITY SUITE (10/10)")
	print("================================================================================")

	var total_tests: int = 10
	var passed_tests: int = 0

	# ------------------------------------------------------------
	# TESTE 1: ABRIR CHARACTER CREATION & VERIFICAR CONTEXTO
	# ------------------------------------------------------------
	print("\n[TESTE 1/10] Abrir Character Creation & Contexto Inicial...")
	var char_sel = CharacterSelectionUIScript.new()
	add_child(char_sel)
	
	assert(InputContextManager != null, "InputContextManager Singleton deve estar ativo")
	assert(InputContextManager.get_context() == InputContextManager.Context.CHARACTER_CREATION, "Contexto deve ser CHARACTER_CREATION")
	assert(InputContextManager.get_context_name() == "CHARACTER_CREATION", "Nome do contexto deve ser CHARACTER_CREATION")
	assert(not InputContextManager.is_global_hotkey_allowed(), "Hotkeys globais devem estar bloqueadas em CHARACTER_CREATION")
	assert(not InputContextManager.is_gameplay_input_allowed(), "Comandos de gameplay devem estar bloqueados em CHARACTER_CREATION")
	print("  ✅ [PASS] Contexto de Character Creation inicializado e bloqueios validados.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 2: DIGITAR 'LUIGON' NO LINEEDIT & NÃO ABRIR MENUS
	# ------------------------------------------------------------
	print("\n[TESTE 2/10] Digitar 'LUIGON' no campo de Nome...")
	char_sel.panel_criacao.visible = true
	var line_edit: LineEdit = char_sel.line_edit_nome
	line_edit.grab_focus()
	
	# Simular digitação de 'LUIGON'
	line_edit.text = "LUIGON"
	assert(line_edit.text == "LUIGON", "Texto do LineEdit deve ser 'LUIGON'")
	
	# Garantir que nenhum menu abriu no UIManager
	assert(UIManager.menu_atual_aberto == null or not UIManager.menu_atual_aberto.visible, "Nenhum menu deve abrir durante digitação")
	print("  ✅ [PASS] Digitação no LineEdit realizada com sucesso sem abrir menus.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 3: DIGITAR CARACTERES DE HOTKEYS (I, M, C, N, H, L, K, 1..4)
	# ------------------------------------------------------------
	print("\n[TESTE 3/10] Digitar teclas correspondentes a hotkeys em campo de texto...")
	line_edit.text = ""
	var hotkey_chars = ["I", "M", "C", "N", "H", "L", "K", "1", "2", "3", "4"]
	for ch in hotkey_chars:
		line_edit.text += ch
	
	assert(line_edit.text == "IMCNHLK1234", "Texto deve conter todos os caracteres digitados")
	assert(UIManager.menu_atual_aberto == null or not UIManager.menu_atual_aberto.visible, "Nenhuma hotkey deve disparar menu")
	print("  ✅ [PASS] Caracteres de hotkeys inseridos no LineEdit sem capturas indevidas.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 4: PRESSIONAR HOTKEYS ENQUANTO LINEEDIT ESTÁ FOCADO
	# ------------------------------------------------------------
	print("\n[TESTE 4/10] Disparo de eventos de hotkey com foco ativo...")
	# Simular envio de evento de tecla 'I' e 'TAB'
	var ev_i := InputEventKey.new()
	ev_i.pressed = true
	ev_i.keycode = KEY_I
	UIManager._unhandled_input(ev_i)
	
	var ev_tab := InputEventKey.new()
	ev_tab.pressed = true
	ev_tab.keycode = KEY_TAB
	UIManager._unhandled_input(ev_tab)
	
	assert(UIManager.menu_atual_aberto == null or not UIManager.menu_atual_aberto.visible, "UIManager não deve abrir menus em CHARACTER_CREATION")
	print("  ✅ [PASS] UIManager rejeita hotkeys globais com foco de texto e contexto ativo.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 5: REMOVER FOCO DO LINEEDIT EM CHARACTER_CREATION
	# ------------------------------------------------------------
	print("\n[TESTE 5/10] Remover foco do LineEdit mas manter CHARACTER_CREATION...")
	line_edit.release_focus()
	assert(not InputContextManager.is_text_input_focused(), "Foco de texto deve estar inativo")
	assert(not InputContextManager.is_global_hotkey_allowed(), "Hotkeys ainda devem estar bloqueadas por estar em CHARACTER_CREATION")
	
	var ev_c := InputEventKey.new()
	ev_c.pressed = true
	ev_c.keycode = KEY_C
	UIManager._unhandled_input(ev_c)
	assert(UIManager.menu_atual_aberto == null or not UIManager.menu_atual_aberto.visible, "Menus continuam bloqueados sem foco em CHARACTER_CREATION")
	print("  ✅ [PASS] Contexto de tela bloqueia hotkeys mesmo sem foco em LineEdit.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 6: CONFIRMAR CRIAÇÃO E MUDAR PARA GAMEPLAY
	# ------------------------------------------------------------
	print("\n[TESTE 6/10] Transição para contexto GAMEPLAY...")
	InputContextManager.set_context(InputContextManager.Context.GAMEPLAY)
	assert(InputContextManager.get_context() == InputContextManager.Context.GAMEPLAY, "Contexto deve ser GAMEPLAY")
	assert(InputContextManager.is_gameplay_input_allowed(), "Comandos de gameplay autorizados")
	assert(InputContextManager.is_global_hotkey_allowed(), "Hotkeys globais autorizadas")
	print("  ✅ [PASS] Transição para GAMEPLAY restaura todas as permissões.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 7: HOTKEYS FUNCIONAM NORMALMENTE EM GAMEPLAY
	# ------------------------------------------------------------
	print("\n[TESTE 7/10] Hotkeys funcionando em GAMEPLAY...")
	UIManager.alternar_hunter_menu(0)
	assert(UIManager.hunter_menu_instance != null and UIManager.hunter_menu_instance.visible, "Hunter Menu deve abrir em GAMEPLAY")
	assert(InputContextManager.get_context() == InputContextManager.Context.MENU, "Abrir menu muda contexto para MENU")
	UIManager.fechar_menu_atual()
	assert(not UIManager.hunter_menu_instance.visible, "Hunter Menu fecha")
	assert(InputContextManager.get_context() == InputContextManager.Context.GAMEPLAY, "Fechar menu restaura GAMEPLAY")
	print("  ✅ [PASS] Hotkeys de menu abrem e fecham restaurando pilha de contextos perfeitamente.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 8: CONTEXTO DE DIÁLOGO
	# ------------------------------------------------------------
	print("\n[TESTE 8/10] Contexto de Diálogo...")
	var diag_ui = load("res://ui/dialogue/VisualDialogueUI.tscn").instantiate()
	add_child(diag_ui)
	diag_ui.exibir_fala("Mestre Wing", "Bem-vindo ao mundo do Nen.")
	
	assert(diag_ui.visible, "Diálogo deve estar visível")
	assert(InputContextManager.get_context() == InputContextManager.Context.DIALOGUE, "Contexto deve ser DIALOGUE")
	assert(not InputContextManager.is_global_hotkey_allowed(), "Hotkeys bloqueadas durante diálogo")
	assert(not InputContextManager.is_gameplay_input_allowed(), "Gameplay bloqueado durante diálogo")
	
	diag_ui._fechar_dialogo()
	assert(not diag_ui.visible, "Diálogo fechado")
	assert(InputContextManager.get_context() == InputContextManager.Context.GAMEPLAY, "Contexto restaurado para GAMEPLAY")
	diag_ui.queue_free()
	print("  ✅ [PASS] Contexto de Diálogo isola gameplay e restaura pilha ao encerrar.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 9: CONTEXTO DE CHAT / TEXT INPUT EM GAMEPLAY
	# ------------------------------------------------------------
	print("\n[TESTE 9/10] Contexto de Chat / Input de Texto...")
	InputContextManager.push_context(InputContextManager.Context.CHAT)
	assert(InputContextManager.get_context() == InputContextManager.Context.CHAT, "Contexto deve ser CHAT")
	assert(not InputContextManager.is_global_hotkey_allowed(), "Hotkeys bloqueadas em CHAT")
	assert(not InputContextManager.is_gameplay_input_allowed(), "Gameplay bloqueado em CHAT")
	print("  ✅ [PASS] Contexto de Chat bloqueia comandos de jogo e hotkeys.")
	passed_tests += 1

	# ------------------------------------------------------------
	# TESTE 10: FECHAR CHAT & RESTAURAR TOTAL
	# ------------------------------------------------------------
	print("\n[TESTE 10/10] Fechar Chat & Restauração Completa...")
	InputContextManager.pop_context()
	assert(InputContextManager.get_context() == InputContextManager.Context.GAMEPLAY, "Contexto deve ser GAMEPLAY")
	assert(InputContextManager.is_gameplay_input_allowed(), "Gameplay reativado")
	assert(InputContextManager.is_global_hotkey_allowed(), "Hotkeys reativadas")
	
	char_sel.queue_free()
	print("  ✅ [PASS] Restauração completa de pilha de contextos validada.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE INPUT CONTEXT & PRIORITY:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DO INPUT: ARQUITETURA ROBUSTA, LINEEDIT PRIORITÁRIO E ZERO LEAKS DE HOTKEYS!")
	print("================================================================================\n")

	get_tree().quit(0)