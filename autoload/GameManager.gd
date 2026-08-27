extends Node

# ============================================================
# HUNTER ONLINE - GAME MANAGER (LIFECYCLE COORDINATOR)
# ============================================================
#
# Gerenciador mestre do ciclo de vida e estado global do jogo:
# - Estados de execução (BOOT, MENU, CRIACAO, JOGO, PAUSE, CUTSCENE, GAME_OVER)
# - Registro do nó do jogador ativo
# - Controle de pausa, salvamento automático e tempo de sessão
# - Transições seguras de cenas
#
# ============================================================

enum GameState {
	BOOT = 0,
	MAIN_MENU = 1,
	CHARACTER_CREATION = 2,
	IN_GAME = 3,
	PAUSED = 4,
	CUTSCENE = 5,
	GAME_OVER = 6
}

enum GameFlowState {
	BOOT = 0,
	MAIN_MENU = 1,
	SAVE_SELECT = 2,
	CHARACTER_CREATION = 3,
	CHARACTER_CONFIRMATION = 4,
	LOADING_SAVE = 5,
	SAVE_LOADED = 6,
	TUTORIAL = 7,
	STORY_INTRO = 8,
	LOBBY = 9,
	WORLD = 10
}

signal game_state_changed(previous_state: int, new_state: int)
signal flow_state_changed(previous_flow: int, new_flow: int)
signal game_paused(is_paused: bool)

var current_state: int = GameState.BOOT
var previous_state: int = GameState.BOOT
var flow_state: int = GameFlowState.BOOT

var active_player: Node2D = null
var current_region_id: String = "val_padokia"
var current_region_name: String = "Vale de Padokia"
var session_play_time: float = 0.0
var is_game_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("=================================")
	print("[GameManager] GERENCIADOR DE JOGO ATIVO")
	print("=================================")
	set_flow_state(GameFlowState.BOOT)


func _process(delta: float) -> void:
	if current_state == GameState.IN_GAME:
		session_play_time += delta


# ------------------------------------------------------------
# 1. CONTROLE DE ESTADOS DE GAMEPLAY E FLUXO DE INICIALIZAÇÃO
# ------------------------------------------------------------
func change_state(new_state: int) -> void:
	if current_state == new_state:
		return
		
	previous_state = current_state
	current_state = new_state
	print("[GameManager] Estado alterado: %s -> %s" % [_state_to_string(previous_state), _state_to_string(current_state)])
	game_state_changed.emit(previous_state, current_state)


func set_flow_state(new_flow: int) -> void:
	if flow_state == new_flow:
		return
	var old_flow = flow_state
	flow_state = new_flow
	print("[GAME FLOW] %s" % _flow_to_string(new_flow))
	flow_state_changed.emit(old_flow, new_flow)


func can_enter_lobby() -> bool:
	if PlayerData == null or not PlayerData.is_character_ready:
		return false
	if flow_state not in [GameFlowState.CHARACTER_CONFIRMATION, GameFlowState.SAVE_LOADED, GameFlowState.TUTORIAL, GameFlowState.STORY_INTRO, GameFlowState.LOBBY, GameFlowState.WORLD]:
		return false
	return true


func _state_to_string(state: int) -> String:
	match state:
		GameState.BOOT: return "BOOT"
		GameState.MAIN_MENU: return "MAIN_MENU"
		GameState.CHARACTER_CREATION: return "CHARACTER_CREATION"
		GameState.IN_GAME: return "IN_GAME"
		GameState.PAUSED: return "PAUSED"
		GameState.CUTSCENE: return "CUTSCENE"
		GameState.GAME_OVER: return "GAME_OVER"
		_: return "UNKNOWN"


func _flow_to_string(flow: int) -> String:
	match flow:
		GameFlowState.BOOT: return "BOOT"
		GameFlowState.MAIN_MENU: return "MAIN_MENU"
		GameFlowState.SAVE_SELECT: return "SAVE_SELECT"
		GameFlowState.CHARACTER_CREATION: return "CHARACTER_CREATION"
		GameFlowState.CHARACTER_CONFIRMATION: return "CHARACTER_CONFIRMATION"
		GameFlowState.LOADING_SAVE: return "LOADING_SAVE"
		GameFlowState.SAVE_LOADED: return "SAVE_LOADED"
		GameFlowState.TUTORIAL: return "TUTORIAL"
		GameFlowState.STORY_INTRO: return "STORY_INTRO"
		GameFlowState.LOBBY: return "LOBBY"
		GameFlowState.WORLD: return "WORLD"
		_: return "UNKNOWN"


# ------------------------------------------------------------
# 2. CONTROLE DO JOGADOR
# ------------------------------------------------------------
func register_player(player_node: Node2D) -> void:
	active_player = player_node
	if EventBus:
		EventBus.player_spawned.emit(player_node)
	print("[GameManager] Jogador ativo registrado: ", player_node.name)


func get_player() -> Node2D:
	if active_player == null or not is_instance_valid(active_player):
		active_player = get_tree().get_first_node_in_group("player") as Node2D
	return active_player


# ------------------------------------------------------------
# 3. PAUSE & RESUME
# ------------------------------------------------------------
func toggle_pause() -> void:
	set_paused(not is_game_paused)


func set_paused(paused: bool) -> void:
	is_game_paused = paused
	get_tree().paused = paused
	
	if paused:
		change_state(GameState.PAUSED)
	else:
		change_state(GameState.IN_GAME)
		
	game_paused.emit(paused)
	print("[GameManager] Jogo %s" % ("PAUSADO" if paused else "DESPAUSADO"))


# ------------------------------------------------------------
# 4. SALVAMENTO E PERSISTÊNCIA
# ------------------------------------------------------------
func trigger_save() -> bool:
	if SaveManager != null and SaveManager.has_method("salvar_jogo"):
		var sucesso = SaveManager.salvar_jogo()
		if EventBus:
			EventBus.emit_toast("Jogo Salvo com Sucesso!", Color(0.4, 1.0, 0.4))
		return sucesso
	return false
