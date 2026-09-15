extends Node

# ============================================================
# Regressão: CAMERA_ZOOM com Vector2 não pode travar o player.
# godot --headless --path . res://scratch/test_maratona_cutscene_unlock_suite.tscn
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


func _ready() -> void:
	print("\n========== TEST MARATONA CUTSCENE UNLOCK ==========")
	await get_tree().process_frame
	PlayerData.arco_atual = 1
	StoryCutsceneManager.em_cutscene = false
	CutsceneSequenceRunner.em_execucao = false
	CutsceneSequenceRunner.runner_ativo = null

	var player := MockPlayer.new()
	player.name = "Player"
	player.add_to_group("player")
	var cam := Camera2D.new()
	cam.name = "Camera2D"
	player.add_child(cam)
	add_child(player)
	await get_tree().process_frame

	# Sequência mínima espelhando o bug: lock → zoom Vector2 → unlock
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.2, 1.2), "duration": 0.05},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": 1.0, "duration": 0.05},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]
	CutsceneSequenceRunner.executar(get_tree(), passos, "Test_Zoom_Vector2_Unlock")

	var waited := 0.0
	while waited < 2.0 and (CutsceneSequenceRunner.em_execucao or player.controles_travados or StoryCutsceneManager.em_cutscene):
		await get_tree().process_frame
		waited += get_process_delta_time()

	_assert(not player.controles_travados, "controles liberados apos zoom Vector2")
	_assert(not StoryCutsceneManager.em_cutscene, "em_cutscene limpo")
	_assert(not CutsceneSequenceRunner.em_execucao, "runner finalizado")

	print("========== RESULTADO: %d ok / %d fail ==========" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)
