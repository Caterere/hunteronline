class_name CutsceneSequenceRunner
extends Node

# ============================================================
# HUNTER ONLINE - CUTSCENE SEQUENCE RUNNER (MOTOR DE CENAS)
# ============================================================
#
# Motor data-driven reutilizável para execução de sequências narrativas,
# cutscenes, diálogos cinematográficos, micro-scenes e transições.
#
# Passos Suportados:
# - LOCK_INPUT: Trava/destrava controles do jogador.
# - MOVE_ACTOR: Movimenta qualquer ator (NPC/Player) até um ponto.
# - FACE_ACTOR: Faz um ator olhar para outro nó ou direção.
# - CAMERA_FOCUS: Foca e suaviza a câmera em um ator ou ponto.
# - CAMERA_ZOOM: Aplica zoom dramático (ex: 1.25x close-up).
# - CAMERA_SHAKE: Dispara tremor de tela via EventBus.
# - DIALOGUE: Exibe fala via DialogueBox ou ComicBalloon.
# - CHOICE: Oferece ramificações de escolha com feedback.
# - PLAY_ANIMATION: Toca animação específica em AnimationPlayer/Tree.
# - WAIT: Pausa com respiro cinematográfico.
# - AUDIO_SFX / AUDIO_BGM: Toca efeitos ou troca trilha sonora.
# - EFFECT_FX: Efeito visual, manga card ou flash.
# - SET_FLAG: Registra flag no StoryManager/WorldState.
# - TRIGGER: Executa um Callable arbitrário.
#
# ============================================================

enum StepType {
	LOCK_INPUT,
	MOVE_ACTOR,
	FACE_ACTOR,
	CAMERA_FOCUS,
	CAMERA_ZOOM,
	CAMERA_SHAKE,
	DIALOGUE,
	CHOICE,
	PLAY_ANIMATION,
	WAIT,
	AUDIO_SFX,
	AUDIO_BGM,
	EFFECT_FX,
	SET_FLAG,
	TRIGGER
}

static var em_execucao: bool = false
static var runner_ativo: CutsceneSequenceRunner = null

signal sequencia_iniciada(nome: String)
signal sequencia_concluida(nome: String)
signal passo_concluido(indice: int)

var _steps: Array[Dictionary] = []
var _current_step_idx: int = 0
var _nome_sequencia: String = ""
var _callback_fim: Callable = Callable()
var _player_cache: CharacterBody2D = null
var _camera_original_zoom: Vector2 = Vector2.ONE
var _camera_cache: Camera2D = null


static func interromper_sequencia_ativa(tree: SceneTree = null) -> void:
	if runner_ativo != null and is_instance_valid(runner_ativo):
		var target_tree: SceneTree = tree if tree != null else runner_ativo.get_tree()
		if target_tree != null:
			runner_ativo._finalizar(target_tree)
		else:
			runner_ativo.queue_free()
			runner_ativo = null
			em_execucao = false


static func executar(tree: SceneTree, steps: Array[Dictionary], nome: String = "Cutscene", callback_fim: Callable = Callable()) -> Node:
	if em_execucao and runner_ativo != null and is_instance_valid(runner_ativo):
		push_warning("[CutsceneSequenceRunner] Já há uma sequência em execução: %s" % runner_ativo._nome_sequencia)
		return runner_ativo

	var root = tree.current_scene if tree.current_scene != null else tree.root
	var script_ref = load("res://scripts/cutscenes/CutsceneSequenceRunner.gd") as GDScript
	var runner: Node = script_ref.new()
	runner.name = "CutsceneRunner_" + str(randi() % 1000)
	root.add_child(runner)
	runner._iniciar(tree, steps, nome, callback_fim)
	return runner


func _iniciar(tree: SceneTree, steps: Array[Dictionary], nome: String, callback_fim: Callable) -> void:
	em_execucao = true
	runner_ativo = self
	_steps = steps
	_current_step_idx = 0
	_nome_sequencia = nome
	_callback_fim = callback_fim

	var players = tree.get_nodes_in_group("player")
	if not players.is_empty():
		_player_cache = players[0] as CharacterBody2D
		_camera_cache = _player_cache.get_node_or_null("Camera2D") as Camera2D
		if _camera_cache != null:
			_camera_original_zoom = _camera_cache.zoom

	if StoryManager != null:
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.CUTSCENE)

	StoryCutsceneManager.em_cutscene = true
	sequencia_iniciada.emit(_nome_sequencia)
	print("[CutsceneSequenceRunner] 🎬 INICIANDO SEQUÊNCIA: %s (%d passos)" % [_nome_sequencia, _steps.size()])

	_executar_proximo_passo(tree)


func _executar_proximo_passo(tree: SceneTree) -> void:
	if _current_step_idx >= _steps.size():
		_finalizar(tree)
		return

	var step: Dictionary = _steps[_current_step_idx]
	var tipo: int = int(step.get("type", StepType.WAIT))

	match tipo:
		StepType.LOCK_INPUT:
			var travar: bool = bool(step.get("lock", true))
			if _player_cache != null and _player_cache.has_method("travar_controles"):
				_player_cache.travar_controles(travar)
			_avancar(tree)

		StepType.MOVE_ACTOR:
			var actor: Node2D = step.get("actor", null) as Node2D
			if actor == null and step.get("is_player", false):
				actor = _player_cache
			var target_pos: Vector2 = step.get("target", Vector2.ZERO)
			var spd: float = float(step.get("speed", 100.0))
			var wait_finish: bool = bool(step.get("wait", true))

			if actor != null and is_instance_valid(actor):
				if actor.has_method("andar_para"):
					actor.andar_para(target_pos, spd)
				elif actor is CharacterBody2D:
					# Suporte direto a interpolação ou velocidade direta
					var tween = create_tween()
					var dist = actor.global_position.distance_to(target_pos)
					var duracao = max(0.1, dist / spd)
					tween.tween_property(actor, "global_position", target_pos, duracao)
					if wait_finish:
						await tween.finished
						_avancar(tree)
						return

				if wait_finish:
					var dist = actor.global_position.distance_to(target_pos)
					var duracao = max(0.1, dist / spd)
					await tree.create_timer(duracao).timeout
			_avancar(tree)

		StepType.FACE_ACTOR:
			var actor: Node2D = step.get("actor", null) as Node2D
			if actor == null and step.get("is_player", false):
				actor = _player_cache
			var target = step.get("target", null)
			if actor != null and is_instance_valid(actor):
				var target_pos: Vector2 = Vector2.ZERO
				if target is Node2D and is_instance_valid(target):
					target_pos = target.global_position
				elif target is Vector2:
					target_pos = target
				var dir = (target_pos - actor.global_position).normalized()
				if actor.has_method("definir_direcao_olhar"):
					actor.definir_direcao_olhar(dir)
				elif "direction" in actor:
					actor.direction = dir
			_avancar(tree)

		StepType.CAMERA_FOCUS:
			var target = step.get("target", null)
			var duracao: float = float(step.get("duration", 0.8))
			if _camera_cache != null:
				var pos_final = Vector2.ZERO
				if target is Node2D and is_instance_valid(target):
					pos_final = target.global_position
				elif target is Vector2:
					pos_final = target
				elif _player_cache != null:
					pos_final = _player_cache.global_position

				var tween = create_tween()
				tween.tween_property(_camera_cache, "global_position", pos_final, duracao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				await tween.finished
			_avancar(tree)

		StepType.CAMERA_ZOOM:
			var zoom_val: float = float(step.get("zoom", 1.2))
			var duracao: float = float(step.get("duration", 0.5))
			if _camera_cache != null:
				var tween = create_tween()
				tween.tween_property(_camera_cache, "zoom", Vector2(zoom_val, zoom_val), duracao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				await tween.finished
			_avancar(tree)

		StepType.CAMERA_SHAKE:
			var forca: float = float(step.get("intensity", 0.4))
			var duracao: float = float(step.get("duration", 0.3))
			if EventBus != null:
				EventBus.emit_camera_shake(forca, duracao)
			_avancar(tree)

		StepType.DIALOGUE:
			var speaker: String = str(step.get("speaker", "Narrador"))
			var text: String = str(step.get("text", ""))
			var bubble_target: Node2D = step.get("actor", null) as Node2D
			var tempo_auto: float = float(step.get("auto_advance_seconds", 0.0))

			var visual_diag = tree.get_first_node_in_group("visual_dialogue_ui")
			var diag_box = tree.get_first_node_in_group("dialogue_box") as DialogueBox

			if bubble_target != null and is_instance_valid(bubble_target) and step.get("use_bubble", false):
				var ComicBalloon = load("res://scripts/ui/ComicBalloon.gd")
				if ComicBalloon != null:
					ComicBalloon.mostrar(bubble_target, text, max(2.0, tempo_auto if tempo_auto > 0 else 3.0), -40.0)
					if tempo_auto > 0:
						await tree.create_timer(tempo_auto).timeout
						_avancar(tree)
						return

			if diag_box != null:
				diag_box.show_dialogue(speaker, text)
				if tempo_auto > 0:
					await tree.create_timer(tempo_auto).timeout
					diag_box.hide()
					_avancar(tree)
				else:
					# Avança ao clicar ou apertar interact
					_esperar_confirmacao_dialogo(tree, diag_box)
			elif visual_diag != null and visual_diag.has_method("exibir_sequencia_falas"):
				var falas: Array[Dictionary] = [{"falante": speaker, "texto": text}]
				visual_diag.exibir_sequencia_falas(falas)
				visual_diag.dialogo_concluido.connect(func(): _avancar(tree), CONNECT_ONE_SHOT)
			else:
				var ComicBalloon = load("res://scripts/ui/ComicBalloon.gd")
				if _player_cache != null and ComicBalloon != null:
					ComicBalloon.mostrar(_player_cache, "[%s]: %s" % [speaker, text], 3.0, -45.0)
				await tree.create_timer(2.5).timeout
				_avancar(tree)

		StepType.CHOICE:
			var choice_id: String = str(step.get("choice_id", "default_choice"))
			var speaker: String = str(step.get("speaker", "Decisão"))
			var prompt_text: String = str(step.get("text", "O que você decide fazer?"))
			var options: Array = step.get("options", ["Prosseguir"])

			var diag_box = tree.get_first_node_in_group("dialogue_box") as DialogueBox
			if diag_box != null:
				var branches: Array[DialogueBranch] = []
				for opt in options:
					var opt_text: String = opt if opt is String else opt.get("text", "Opção")
					var opt_id: String = opt.get("id", opt_text) if opt is Dictionary else opt_text
					var branch := DialogueBranch.new()
					branch.choice_text = opt_text
					branch.next_node_id = opt_id
					branches.append(branch)

				diag_box.show_dialogue(speaker, prompt_text)
				diag_box.show_choices(branches)

				var diag_sys = tree.get_first_node_in_group("dialogue_system") as DialogueSystem
				if diag_sys != null:
					var choice_conn: Callable
					choice_conn = func(branch_chosen: DialogueBranch):
						if diag_sys.dialogue_choice_made.is_connected(choice_conn):
							diag_sys.dialogue_choice_made.disconnect(choice_conn)
						var selected_val = branch_chosen.next_node_id
						if StoryManager != null:
							StoryManager.register_choice(choice_id, selected_val)
						diag_box.hide()
						_avancar(tree)
					diag_sys.dialogue_choice_made.connect(choice_conn)
				else:
					await tree.create_timer(2.0).timeout
					if StoryManager != null:
						StoryManager.register_choice(choice_id, "default")
					diag_box.hide()
					_avancar(tree)
			else:
				if StoryManager != null:
					StoryManager.register_choice(choice_id, "default")
				_avancar(tree)

		StepType.PLAY_ANIMATION:
			var actor = step.get("actor", _player_cache)
			var anim: String = str(step.get("animation", "idle"))
			if actor != null and is_instance_valid(actor):
				var anim_tree = actor.get_node_or_null("AnimationTree") as AnimationTree
				if anim_tree != null:
					var sm = anim_tree["parameters/playback"]
					if sm != null and sm.has_method("travel"):
						sm.travel(anim)
				var anim_player = actor.get_node_or_null("AnimationPlayer") as AnimationPlayer
				if anim_player != null and anim_player.has_animation(anim):
					anim_player.play(anim)
			_avancar(tree)

		StepType.WAIT:
			var secs: float = float(step.get("seconds", 1.0))
			await tree.create_timer(secs).timeout
			_avancar(tree)

		StepType.AUDIO_SFX:
			var sfx: String = str(step.get("sfx", ""))
			if AudioManager != null and not sfx.is_empty():
				if sfx.begins_with("res://"):
					AudioManager.tocar_sfx_path(sfx)
				else:
					AudioManager.tocar_sfx_tipo(sfx)
			_avancar(tree)

		StepType.AUDIO_BGM:
			var bgm: String = str(step.get("bgm", ""))
			if AudioManager != null:
				AudioManager.tocar_musica(bgm)
			_avancar(tree)

		StepType.EFFECT_FX:
			var fx_type: String = str(step.get("effect", "flash"))
			match fx_type:
				"flash":
					var hud = tree.get_first_node_in_group("player_hud")
					if hud != null and hud.has_method("piscar_tela"):
						hud.piscar_tela(Color.WHITE, 0.2)
				"manga_card":
					var char_id: String = str(step.get("character", "hisoka"))
					if CinematicManager != null:
						CinematicManager.apresentar_personagem_manga(char_id)
			_avancar(tree)

		StepType.SET_FLAG:
			var flg: String = str(step.get("flag", ""))
			var val: Variant = step.get("value", true)
			if StoryManager != null and not flg.is_empty():
				StoryManager.set_story_flag(flg, val)
			_avancar(tree)

		StepType.TRIGGER:
			var callb = step.get("callable", Callable())
			if callb is Callable and callb.is_valid():
				callb.call()
			_avancar(tree)


func _esperar_confirmacao_dialogo(tree: SceneTree, diag_box: DialogueBox) -> void:
	var process_check: Node = Node.new()
	process_check.name = "DialogueAwaitHelper"
	add_child(process_check)

	var timer_cooldown: float = 0.3
	process_check.set_process(true)
	
	var cleanup := func():
		if is_instance_valid(process_check):
			process_check.queue_free()
		diag_box.hide()
		_avancar(tree)

	# Timeout de segurança para nunca travar a cena
	var max_timer = tree.create_timer(8.0)
	max_timer.timeout.connect(func():
		if is_instance_valid(process_check):
			cleanup.call()
	)

	# Listener de input
	var check_call = func(_delta):
		timer_cooldown -= _delta
		if timer_cooldown <= 0.0:
			if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("attack") or Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				cleanup.call()

	process_check.set_script(null)
	process_check.process_mode = Node.PROCESS_MODE_ALWAYS
	# Conexão segura via frame de renderização
	var frame_conn: Callable
	frame_conn = func():
		if not is_instance_valid(process_check):
			return
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
			tree.process_frame.disconnect(frame_conn)
			cleanup.call()
	tree.process_frame.connect(frame_conn)


func _avancar(tree: SceneTree) -> void:
	passo_concluido.emit(_current_step_idx)
	_current_step_idx += 1
	_executar_proximo_passo(tree)


func _finalizar(tree: SceneTree) -> void:
	print("[CutsceneSequenceRunner] 🏁 SEQUÊNCIA CONCLUÍDA: %s" % _nome_sequencia)

	# Restaurar câmera original suavemente
	if _camera_cache != null and is_instance_valid(_camera_cache):
		var tween = create_tween()
		tween.tween_property(_camera_cache, "zoom", _camera_original_zoom, 0.4)
		if _player_cache != null and is_instance_valid(_player_cache):
			_camera_cache.position = Vector2.ZERO

	# Restaurar controles do jogador
	if _player_cache != null and is_instance_valid(_player_cache) and _player_cache.has_method("travar_controles"):
		_player_cache.travar_controles(false)

	# Restaurar estado da história para exploração
	if StoryManager != null:
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)

	StoryCutsceneManager.em_cutscene = false
	em_execucao = false
	runner_ativo = null

	sequencia_concluida.emit(_nome_sequencia)

	if _callback_fim.is_valid():
		_callback_fim.call()

	queue_free()
