class_name UIManagerScript
extends Node

# ============================================================
# HUNTER ONLINE - UI MANAGER & INPUT ROUTER (AUTOLOAD)
# ============================================================
#
# Centraliza a gestão de interfaces modais e hotkeys:
# - [TAB] / [C]: Hunter Menu Consolidado (Status, Inv, Nen, Hatsu, Licença, Facções, Aparência)
# - [M]: Mapa Mundial Expandido
# - [J]: Jornal de Missões & Conhecimento
# - [Q] / [LB]: Barra Rápida de Modificador de Nen
# - [ESC]: Fechar qualquer menu aberto instantaneamente
#
# Compatibilidade retroativa garantida para atalhos legados:
# [I] -> Abre direto na aba Inventário
# [N] -> Abre direto na aba Nen Tree
# [H] -> Abre direto na aba Hatsu Forge
# [L] -> Abre direto na aba Licença
# [K] -> Abre direto na aba Conquistas do Jornal
#
# ============================================================

signal menu_aberto(nome_menu: String, aba_index: int)
signal menu_fechado(nome_menu: String)

var menu_atual_aberto: CanvasLayer = null
var nome_menu_atual: String = ""

var hunter_menu_instance: CanvasLayer = null
var journal_menu_instance: CanvasLayer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_registrar_acoes_input_padrao()
	print("=================================")
	print("[UIManager] GERENCIADOR DE INTERFACES & INPUT ATIVO")
	print("=================================")


func _registrar_acoes_input_padrao() -> void:
	_adicionar_acao_se_nao_existir("open_hunter_menu", KEY_TAB)
	_adicionar_acao_se_nao_existir("open_map_menu", KEY_M)
	_adicionar_acao_se_nao_existir("open_journal_menu", KEY_J)
	_adicionar_acao_se_nao_existir("nen_modifier", KEY_Q)
	_adicionar_acao_se_nao_existir("menu_next_tab", KEY_E)
	_adicionar_acao_se_nao_existir("menu_prev_tab", KEY_Q)


func _adicionar_acao_se_nao_existir(action_name: StringName, default_key: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		var ev := InputEventKey.new()
		ev.physical_keycode = default_key
		InputMap.action_add_event(action_name, ev)


func obter_hunter_menu() -> CanvasLayer:
	if hunter_menu_instance == null:
		var scn_hunter = load("res://ui/HunterMenu/HunterMenuUI.gd")
		if scn_hunter != null:
			hunter_menu_instance = scn_hunter.new()
			hunter_menu_instance.name = "HunterMenuUI"
			add_child(hunter_menu_instance)
	return hunter_menu_instance


func obter_journal_menu() -> CanvasLayer:
	if journal_menu_instance == null:
		var scn_journal = load("res://ui/Journal/JournalUI.gd")
		if scn_journal != null:
			journal_menu_instance = scn_journal.new()
			journal_menu_instance.name = "JournalUI"
			add_child(journal_menu_instance)
	return journal_menu_instance


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	# ESC fecha qualquer menu aberto instantaneamente
	if event.keycode == KEY_ESCAPE:
		if menu_atual_aberto != null and menu_atual_aberto.visible:
			fechar_menu_atual()
			get_viewport().set_input_as_handled()
			return

	# Checagem central de autorização de hotkeys via InputContextManager
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null and not input_ctx.is_global_hotkey_allowed():
		return

	# Ações Principais de Abertura / Alternância
	if event.is_action_pressed("open_hunter_menu") or event.keycode == KEY_TAB:
		alternar_hunter_menu(0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("open_map_menu") or event.keycode == KEY_M:
		alternar_map_menu(0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("open_journal_menu") or event.keycode == KEY_J:
		alternar_journal_menu(0)
		get_viewport().set_input_as_handled()

	# Compatibilidade Retroativa
	elif event.keycode == KEY_C:
		alternar_hunter_menu(0) # Status
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_I:
		alternar_hunter_menu(1) # Inventário
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_N:
		alternar_hunter_menu(2) # Nen Tree
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_H:
		alternar_hunter_menu(3) # Hatsu Forge
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_L:
		alternar_hunter_menu(4) # Licença Hunter
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_K:
		alternar_journal_menu(3) # Conquistas
		get_viewport().set_input_as_handled()


func alternar_hunter_menu(aba_index: int = 0) -> void:
	var hm = obter_hunter_menu()
	if hm == null:
		return
	if hm.visible:
		if hm.tab_container != null and hm.tab_container.current_tab == aba_index:
			fechar_menu_atual()
		else:
			hm.definir_aba_ativa(aba_index)
	else:
		abrir_menu(hm, "HUNTER_MENU", aba_index)


func alternar_map_menu(aba_index: int = 0) -> void:
	var minimap_ui = get_tree().get_first_node_in_group("world_minimap_ui")
	if minimap_ui != null and minimap_ui.has_method("toggle_full_map"):
		minimap_ui.toggle_full_map()
	else:
		var root_minimap = get_tree().root.get_node_or_null("WorldMinimapUI")
		if root_minimap != null and root_minimap.has_method("toggle_full_map"):
			root_minimap.toggle_full_map()


func alternar_journal_menu(aba_index: int = 0) -> void:
	var jm = obter_journal_menu()
	if jm == null:
		return
	if jm.visible:
		if jm.tab_container != null and jm.tab_container.current_tab == aba_index:
			fechar_menu_atual()
		else:
			jm.definir_aba_ativa(aba_index)
	else:
		abrir_menu(jm, "JOURNAL_MENU", aba_index)


func abrir_menu(menu_node: CanvasLayer, nome: String, aba_index: int = 0) -> void:
	if menu_node == null:
		return
	# Fechar menu anterior se houver
	if menu_atual_aberto != null and menu_atual_aberto != menu_node:
		menu_atual_aberto.visible = false
		if menu_atual_aberto.has_method("ao_fechar"):
			menu_atual_aberto.ao_fechar()

	menu_atual_aberto = menu_node
	nome_menu_atual = nome
	menu_node.visible = true
	if DisplayServer.get_name() != "headless":
		get_tree().paused = true

	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null:
		input_ctx.push_context("MENU")

	if menu_node.has_method("definir_aba_ativa"):
		menu_node.definir_aba_ativa(aba_index)
	elif menu_node.has_method("abrir"):
		menu_node.abrir()

	menu_aberto.emit(nome, aba_index)
	if EventBus != null:
		EventBus.menu_opened.emit(nome)


func fechar_menu_atual() -> void:
	if menu_atual_aberto != null:
		var nome = nome_menu_atual
		menu_atual_aberto.visible = false
		if menu_atual_aberto.has_method("ao_fechar"):
			menu_atual_aberto.ao_fechar()
		menu_atual_aberto = null
		nome_menu_atual = ""
		get_tree().paused = false

		var input_ctx = get_node_or_null("/root/InputContextManager")
		if input_ctx != null:
			input_ctx.pop_context()

		menu_fechado.emit(nome)
		if EventBus != null:
			EventBus.menu_closed.emit(nome)


# ============================================================
# SINGLE SOURCE OF TRUTH MENU MANAGEMENT API
# ============================================================

func open_menu(menu_node: CanvasLayer, nome: String = "", aba_index: int = 0) -> void:
	abrir_menu(menu_node, nome if not nome.is_empty() else menu_node.name, aba_index)


func close_menu(menu_node: CanvasLayer = null) -> void:
	if menu_node == null or menu_node == menu_atual_aberto:
		fechar_menu_atual()
	elif menu_node != null:
		menu_node.visible = false
		if menu_node.has_method("ao_fechar"):
			menu_node.ao_fechar()


func close_all_menus() -> void:
	fechar_menu_atual()
	if hunter_menu_instance != null:
		hunter_menu_instance.visible = false
	if journal_menu_instance != null:
		journal_menu_instance.visible = false


func is_menu_open(menu_node: CanvasLayer = null) -> bool:
	if menu_node != null:
		return menu_node.visible
	return menu_atual_aberto != null and menu_atual_aberto.visible


func toggle_menu(menu_node: CanvasLayer, nome: String = "", aba_index: int = 0) -> void:
	if is_menu_open(menu_node):
		close_menu(menu_node)
	else:
		open_menu(menu_node, nome, aba_index)