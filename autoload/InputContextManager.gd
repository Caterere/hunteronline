class_name InputContextManagerScript
extends Node

# ============================================================
# HUNTER ONLINE - INPUT CONTEXT & PRIORITY MANAGER (AUTOLOAD)
# ============================================================
#
# Gerenciador Central de Contexto de Entrada e Prioridade de Input.
#
# HIERARQUIA DE PRIORIDADE:
# 1. Godot UI / Control com foco de teclado (LineEdit, TextEdit, SpinBox)
# 2. Context-Specific UI (Criação de Personagem, Diálogo, Loja, Chat)
# 3. Gameplay Input (Movimento, Dash, Ataque, Técnicas de Nen)
# 4. Global Hotkeys (Menus, Inventário, Mapa, Jornal)
#
# ============================================================

signal context_changed(old_context: int, new_context: int)

enum Context {
	GAMEPLAY,
	LOBBY,
	CHARACTER_CREATION,
	MENU,
	DIALOGUE,
	SHOP,
	CHAT,
	PAUSED,
	CUTSCENE,
	TUTORIAL,
	TUTORIAL_MODAL
}

const CONTEXT_NAMES := {
	Context.GAMEPLAY: "GAMEPLAY",
	Context.LOBBY: "LOBBY",
	Context.CHARACTER_CREATION: "CHARACTER_CREATION",
	Context.MENU: "MENU",
	Context.DIALOGUE: "DIALOGUE",
	Context.SHOP: "SHOP",
	Context.CHAT: "CHAT",
	Context.PAUSED: "PAUSED",
	Context.CUTSCENE: "CUTSCENE",
	Context.TUTORIAL: "TUTORIAL",
	Context.TUTORIAL_MODAL: "TUTORIAL_MODAL"
}

var _current_context: Context = Context.GAMEPLAY
var _context_stack: Array[int] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("=================================")
	print("[InputContextManager] GERENCIADOR DE CONTEXTO & PRIORIDADE DE INPUT ATIVO")
	print("CONTEXTO INICIAL: ", get_context_name())
	print("=================================")


# ============================================================
# GESTÃO DE CONTEXTO
# ============================================================

func set_context(ctx_val) -> void:
	var target_ctx: Context = _parse_context(ctx_val)
	if target_ctx == _current_context:
		return
	var old = _current_context
	_current_context = target_ctx
	context_changed.emit(old, _current_context)


func get_context() -> Context:
	return _current_context


func get_context_name() -> String:
	return CONTEXT_NAMES.get(_current_context, "UNKNOWN")


func is_context(ctx_val) -> bool:
	return _current_context == _parse_context(ctx_val)


func push_context(ctx_val) -> void:
	_context_stack.append(_current_context)
	set_context(ctx_val)


func pop_context() -> void:
	if not _context_stack.is_empty():
		var prev = _context_stack.pop_back()
		set_context(prev)
	else:
		set_context(Context.GAMEPLAY)


func _parse_context(ctx_val) -> Context:
	if ctx_val is int:
		return ctx_val as Context
	elif ctx_val is String:
		var s = ctx_val.to_upper()
		for k in CONTEXT_NAMES.keys():
			if CONTEXT_NAMES[k] == s:
				return k as Context
	return Context.GAMEPLAY


# ============================================================
# CONSULTAS DE PRIORIDADE & AUTORIZAÇÃO
# ============================================================

func is_text_input_focused() -> bool:
	var vp = Engine.get_main_loop().root.get_viewport() if Engine.get_main_loop() else null
	if vp == null:
		return false
	var focus_owner = vp.gui_get_focus_owner()
	if focus_owner == null:
		return false
	
	# Checar se o controle focado é um campo de texto interativo
	if focus_owner is LineEdit or focus_owner is TextEdit or focus_owner is CodeEdit or focus_owner is SpinBox:
		return true
	return false


func get_focused_control_name() -> String:
	var vp = Engine.get_main_loop().root.get_viewport() if Engine.get_main_loop() else null
	if vp == null:
		return "None"
	var focus_owner = vp.gui_get_focus_owner()
	if focus_owner == null:
		return "None"
	return "%s (%s)" % [focus_owner.name, focus_owner.get_class()]


func is_gameplay_input_allowed() -> bool:
	# Bloqueado se um campo de texto estiver capturando teclas
	if is_text_input_focused():
		return false
		
	# Permitido em GAMEPLAY, LOBBY ou durante TUTORIAL ativo
	return _current_context in [Context.GAMEPLAY, Context.LOBBY, Context.TUTORIAL]


func is_global_hotkey_allowed() -> bool:
	# Se qualquer controle de texto estiver com foco, hotkeys NÃO podem ser consumidas!
	if is_text_input_focused():
		return false
		
	# Bloquear hotkeys globais durante criação de personagem, diálogos, lojas, chat, cutscenes e modais do tutorial
	if _current_context in [Context.CHARACTER_CREATION, Context.DIALOGUE, Context.SHOP, Context.CHAT, Context.CUTSCENE, Context.TUTORIAL_MODAL]:
		return false
		
	return true