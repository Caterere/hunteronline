extends Node

# Repro headless: maratona cutscene locks input then CAMERA_ZOOM Vector2 crashes cast.
# godot --path . --headless res://scratch/repro_maratona_stuck_cutscene.tscn

class MockPlayer extends CharacterBody2D:
	var controles_travados: bool = false
	func travar_controles(travar: bool = true) -> void:
		controles_travados = travar


func _ready() -> void:
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

	print("[REPRO] Starting maratona cutscene...")
	var gon := NPC.new()
	gon.name = "Gon"
	add_child(gon)

	StoryCutsceneManager.executar_maratona_hunter(get_tree(), gon, gon, gon, gon, gon)

	var waited := 0.0
	while waited < 2.5:
		await get_tree().process_frame
		waited += get_process_delta_time()

	print("[REPRO] AFTER: controles_travados=%s em_cutscene=%s em_execucao=%s" % [
		player.controles_travados, StoryCutsceneManager.em_cutscene, CutsceneSequenceRunner.em_execucao
	])
	# #region agent log
	var _f = FileAccess.open("/opt/cursor/logs/debug.log", FileAccess.READ_WRITE)
	if _f == null: _f = FileAccess.open("/opt/cursor/logs/debug.log", FileAccess.WRITE)
	else: _f.seek_end()
	if _f: _f.store_line(JSON.stringify({"hypothesisId":"A,C","location":"repro_maratona_stuck_cutscene.gd","message":"repro_final_state","data":{"controles_travados":player.controles_travados,"em_cutscene":StoryCutsceneManager.em_cutscene,"em_execucao":CutsceneSequenceRunner.em_execucao},"timestamp":Time.get_ticks_msec()})); _f.close()
	# #endregion
	get_tree().quit(0)
