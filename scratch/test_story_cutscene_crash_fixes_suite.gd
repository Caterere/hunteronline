extends Node

# ============================================================
# Regressão: crashes / softlocks do modo história (cutscenes/portais)
# godot --headless --path . res://scratch/test_story_cutscene_crash_fixes_suite.tscn
# ============================================================

var _passed: int = 0
var _failed: int = 0


class MockPlayer extends CharacterBody2D:
	var controles_travados: bool = false
	func travar_controles(travar: bool = true) -> void:
		controles_travados = travar


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  PASS: ", msg)
	else:
		_failed += 1
		print("  FAIL: ", msg)


func _reset_cutscene_state() -> void:
	CutsceneSequenceRunner.interromper_sequencia_ativa(get_tree())
	StoryCutsceneManager.forcar_liberacao_cutscene()
	StoryCutsceneManager.em_cutscene = false
	CutsceneSequenceRunner.em_execucao = false
	CutsceneSequenceRunner.runner_ativo = null


func _aguardar_done(done: Array, timeout_s: float = 3.0) -> bool:
	var waited := 0.0
	while waited < timeout_s and not done[0]:
		await get_tree().process_frame
		waited += get_process_delta_time()
	return done[0]


func _ready() -> void:
	print("\n========== TEST STORY CUTSCENE CRASH FIXES ==========")
	await get_tree().process_frame
	_reset_cutscene_state()

	var player := MockPlayer.new()
	player.name = "Player"
	player.add_to_group("player")
	var cam := Camera2D.new()
	cam.name = "Camera2D"
	player.add_child(cam)
	add_child(player)

	await _test_trigger_single_advance()
	await _test_busy_portal_fail_open()
	await _test_choice_empty_options()
	await _test_move_actor_zero_speed(player)
	await _test_checkpoint_busy_does_not_stick_flag()
	await _test_visual_dialogue_when_done_token()
	await _test_runner_refuse_returns_null()
	await _test_exam_conclusao_callback_timing()
	await _test_interromper_limpa_estado(player)
	await _test_dialogue_fallback_balloon_once()

	print("========== RESULTADO: %d ok / %d fail ==========" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)


func _test_trigger_single_advance() -> void:
	print("\n[1] Runner: TRIGGER + WAIT avança uma vez e libera flags")
	_reset_cutscene_state()
	await get_tree().process_frame

	var advances: Array = [0]
	var done: Array = [false]
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.WAIT, "seconds": 0.05},
		{"type": CutsceneSequenceRunner.StepType.TRIGGER, "callable": func(): advances[0] += 1},
		{"type": CutsceneSequenceRunner.StepType.WAIT, "seconds": 0.05},
	]
	CutsceneSequenceRunner.executar(get_tree(), passos, "Test_Trigger_Once", func(): done[0] = true)
	var ok := await _aguardar_done(done, 2.0)
	_assert(ok, "sequência WAIT/TRIGGER concluiu")
	_assert(advances[0] == 1, "TRIGGER executou exatamente 1 vez")
	_assert(not CutsceneSequenceRunner.em_execucao, "runner liberado")
	_assert(not StoryCutsceneManager.em_cutscene, "em_cutscene limpo")
	_reset_cutscene_state()


func _test_dialogue_fallback_balloon_once() -> void:
	print("\n[10] Dialogue fallback (sem DialogueBox): conclui sem double-advance")
	_reset_cutscene_state()
	await get_tree().process_frame
	var advances: Array = [0]
	var done: Array = [false]
	# Sem nó no grupo dialogue_box → fallback ComicBalloon + timer 2.5s
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Test", "text": "ping"},
		{"type": CutsceneSequenceRunner.StepType.TRIGGER, "callable": func(): advances[0] += 1},
	]
	CutsceneSequenceRunner.executar(get_tree(), passos, "Test_Dialogue_Fallback", func(): done[0] = true)
	var ok := await _aguardar_done(done, 4.0)
	_assert(ok, "diálogo fallback concluiu")
	_assert(advances[0] == 1, "TRIGGER exatamente 1x após diálogo fallback")
	_reset_cutscene_state()


func _test_busy_portal_fail_open() -> void:
	print("\n[2] Portal fail-open quando cutscene ocupada")
	_reset_cutscene_state()
	StoryCutsceneManager.em_cutscene = true
	var called: Array = [false]
	StoryCutsceneManager.executar_conclusao_exame_hunter(get_tree(), func(): called[0] = true)
	await get_tree().process_frame
	_assert(called[0], "callback de portal chamado mesmo com em_cutscene=true")
	_reset_cutscene_state()


func _test_choice_empty_options() -> void:
	print("\n[3] CHOICE com options vazio não crasha")
	_reset_cutscene_state()
	await get_tree().process_frame
	var done: Array = [false]
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.CHOICE, "choice_id": "empty_test", "text": "?", "options": []},
	]
	CutsceneSequenceRunner.executar(get_tree(), passos, "Test_Choice_Empty", func(): done[0] = true)
	var ok := await _aguardar_done(done, 3.0)
	_assert(ok, "CHOICE vazio concluiu sem crash")
	_reset_cutscene_state()


func _test_move_actor_zero_speed(player: MockPlayer) -> void:
	print("\n[4] MOVE_ACTOR speed=0 não softlocka (fallback speed)")
	_reset_cutscene_state()
	await get_tree().process_frame
	player.global_position = Vector2.ZERO
	var done: Array = [false]
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.MOVE_ACTOR, "is_player": true, "target": Vector2(20, 0), "speed": 0.0, "wait": true},
	]
	CutsceneSequenceRunner.executar(get_tree(), passos, "Test_Move_ZeroSpeed", func(): done[0] = true)
	var ok := await _aguardar_done(done, 3.0)
	_assert(ok, "MOVE_ACTOR speed=0 concluiu em <3s (sem await infinito)")
	_reset_cutscene_state()


func _test_checkpoint_busy_does_not_stick_flag() -> void:
	print("\n[5] CheckpointCutsceneLibrary não prende em_cutscene se busy")
	_reset_cutscene_state()
	CutsceneSequenceRunner.em_execucao = true
	StoryCutsceneManager.em_cutscene = false

	CheckpointCutsceneLibrary.executar(get_tree(), &"exame_largada")
	await get_tree().process_frame
	_assert(not StoryCutsceneManager.em_cutscene, "em_cutscene NÃO ficou preso após checkpoint busy")
	_reset_cutscene_state()


func _test_visual_dialogue_when_done_token() -> void:
	print("\n[6] VisualDialogueUI.when_done ignora geração antiga")
	var ui_res = load("res://ui/dialogue/VisualDialogueUI.tscn")
	if ui_res == null:
		_assert(false, "VisualDialogueUI.tscn carregável")
		return
	var ui = ui_res.instantiate()
	add_child(ui)
	await get_tree().process_frame

	var calls_a: Array = [0]
	var calls_b: Array = [0]
	ui.exibir_sequencia_falas([{"falante": "A", "texto": "primeira"}])
	ui.when_done(func(): calls_a[0] += 1)
	ui.exibir_sequencia_falas([{"falante": "B", "texto": "segunda"}])
	ui.when_done(func(): calls_b[0] += 1)
	ui.fila_dialogos.clear()
	ui._fechar_dialogo()
	await get_tree().process_frame
	_assert(calls_a[0] == 0, "listener da geração antiga NÃO disparou")
	_assert(calls_b[0] == 1, "listener da geração atual disparou 1x")
	ui.queue_free()
	if get_tree() != null:
		get_tree().paused = false


func _test_runner_refuse_returns_null() -> void:
	print("\n[7] executar() recusa segunda sequência com null")
	_reset_cutscene_state()
	await get_tree().process_frame
	var done1: Array = [false]
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.WAIT, "seconds": 0.25},
	]
	var r1 = CutsceneSequenceRunner.executar(get_tree(), passos, "First", func(): done1[0] = true)
	var r2 = CutsceneSequenceRunner.executar(get_tree(), [{"type": CutsceneSequenceRunner.StepType.WAIT, "seconds": 0.05}], "Second")
	_assert(r1 != null, "primeira sequência iniciou")
	_assert(r2 == null, "segunda sequência recusada (null)")
	var ok := await _aguardar_done(done1, 2.0)
	_assert(ok, "primeira sequência concluiu")
	_reset_cutscene_state()


func _test_exam_conclusao_callback_timing() -> void:
	print("\n[8] Conclusão exame: saga estável mid-cutscene stub")
	_reset_cutscene_state()
	await get_tree().process_frame
	if StoryManager != null:
		StoryManager.current_saga = 1
		StoryManager.current_chapter = 1
	if PlayerData != null:
		PlayerData.arco_atual = 1

	var saga_antes: int = StoryManager.current_saga if StoryManager != null else 1
	var done: Array = [false]
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.WAIT, "seconds": 0.1},
	]
	CutsceneSequenceRunner.executar(get_tree(), passos, "Stub_Exam_Timing", func():
		done[0] = true
	)
	await get_tree().process_frame
	var saga_mid: int = StoryManager.current_saga if StoryManager != null else 1
	_assert(saga_mid == saga_antes, "saga não mudou no meio da cutscene stub")
	var ok := await _aguardar_done(done, 2.0)
	_assert(ok, "stub concluiu")
	_reset_cutscene_state()


func _test_interromper_limpa_estado(player: MockPlayer) -> void:
	print("\n[9] interromper_sequencia_ativa libera input e flags")
	_reset_cutscene_state()
	await get_tree().process_frame
	player.controles_travados = false
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.WAIT, "seconds": 5.0},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]
	CutsceneSequenceRunner.executar(get_tree(), passos, "Test_Interrupt")
	await get_tree().process_frame
	await get_tree().process_frame
	_assert(player.controles_travados, "controles travados durante cutscene")
	CutsceneSequenceRunner.interromper_sequencia_ativa(get_tree())
	await get_tree().process_frame
	_assert(not player.controles_travados, "controles liberados após interromper")
	_assert(not CutsceneSequenceRunner.em_execucao, "em_execucao limpo")
	_assert(not StoryCutsceneManager.em_cutscene, "em_cutscene limpo")
	_reset_cutscene_state()
