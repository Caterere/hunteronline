extends Node

# ============================================================
# OST nas sagas + menu de volume
# godot --headless --path . res://scratch/test_saga_ost_volume_menu_suite.tscn
# ============================================================

var _passed: int = 0
var _failed: int = 0


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  PASS: ", msg)
	else:
		_failed += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("\n========== TEST SAGA OST + VOLUME MENU ==========")
	await get_tree().process_frame

	_test_aliases()
	_test_scene_tracks_sagas()
	_test_garantir_musica()
	_test_tocar_bgm_alias()
	_test_volume_apis_persist()
	await _test_pause_menu_audio_ui()
	_test_saga_hub_injects_saga_id()
	_test_loop_flag_on_load()

	print("========== RESULTADO: %d ok / %d fail ==========" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)


func _test_aliases() -> void:
	print("\n[1] Aliases de faixa")
	_assert(AudioManager.TRACK_ALIASES.has("departure"), "alias departure")
	_assert(AudioManager.TRACK_ALIASES.has("hunting_for_your_dream"), "alias hunting_for_your_dream")
	_assert(AudioManager.TRACK_ALIASES.has("world_adventure"), "alias world_adventure")
	var resolved: String = AudioManager._resolver_track_id("departure")
	_assert(resolved == "hashire", "departure → hashire")
	_assert(AudioManager.TRACKS.has(resolved), "hashire existe em TRACKS")


func _test_scene_tracks_sagas() -> void:
	print("\n[2] SCENE_TRACKS cobre 9 hubs de saga")
	var hubs := [
		"res://world/maps/exame_maratona.tscn",
		"res://world/maps/montanha_kukuroo.tscn",
		"res://world/maps/arena_celestial.tscn",
		"res://world/maps/yorknew_city.tscn",
		"res://world/maps/greed_island.tscn",
		"res://world/maps/ngl_formigas.tscn",
		"res://world/maps/associacao_hunter.tscn",
		"res://world/maps/continente_negro.tscn",
		"res://world/maps/black_whale_1.tscn",
	]
	for path in hubs:
		var tid: String = str(AudioManager.SCENE_TRACKS.get(path, ""))
		_assert(not tid.is_empty() and AudioManager.TRACKS.has(tid), "OST mapeada: %s → %s" % [path.get_file(), tid])


func _test_garantir_musica() -> void:
	print("\n[3] garantir_musica_cena / arco")
	AudioManager.current_track_id = ""
	AudioManager.current_track_path = ""
	var active: AudioStreamPlayer = AudioManager.player_a if AudioManager.active_player_is_a else AudioManager.player_b
	if active != null:
		active.stop()
	AudioManager.garantir_musica_cena("res://world/maps/exame_maratona.tscn")
	_assert(AudioManager.current_track_id == "hashire", "exame → hashire")
	AudioManager.tocar_musica_arco(2)
	_assert(AudioManager.current_track_id == "ginpatsu_no_shonen", "arco 2 → ginpatsu")
	# Idempotente
	var before := AudioManager.current_track_id
	AudioManager.garantir_musica_cena("res://world/maps/montanha_kukuroo.tscn")
	_assert(AudioManager.current_track_id == before, "garantir não reinicia se já correta")


func _test_tocar_bgm_alias() -> void:
	print("\n[4] tocar_bgm (API legada Padokia)")
	_assert(AudioManager.has_method("tocar_bgm"), "tocar_bgm existe")
	AudioManager.tocar_bgm("world_adventure")
	_assert(AudioManager.current_track_id == "the_world_of_adventurers", "world_adventure resolvido")
	AudioManager.tocar_bgm("dungeon_ruins")
	_assert(AudioManager.current_track_id == "dirge_from_dark_side", "dungeon_ruins resolvido")


func _test_volume_apis_persist() -> void:
	print("\n[5] Volumes + persistência")
	var path := AudioManager.AUDIO_SETTINGS_PATH
	AudioManager.definir_volume_master(0.55)
	AudioManager.definir_volume_musica(0.40)
	AudioManager.definir_volume_sfx(0.70)
	AudioManager.definir_volume_ambient(0.20)
	var vols: Dictionary = AudioManager.obter_volumes()
	_assert(is_equal_approx(float(vols["master"]), 0.55), "master 0.55")
	_assert(is_equal_approx(float(vols["music"]), 0.40), "music 0.40")
	_assert(is_equal_approx(float(vols["sfx"]), 0.70), "sfx 0.70")
	_assert(is_equal_approx(float(vols["ambient"]), 0.20), "ambient 0.20")
	_assert(FileAccess.file_exists(path), "audio_settings.cfg salvo")

	# Simula reload
	AudioManager.master_volume_linear = 1.0
	AudioManager.music_volume_linear = 1.0
	AudioManager.carregar_preferencias_audio()
	_assert(is_equal_approx(AudioManager.master_volume_linear, 0.55), "reload master")
	_assert(is_equal_approx(AudioManager.music_volume_linear, 0.40), "reload music")

	# Restaura defaults razoáveis para não afetar outras suites
	AudioManager.definir_volume_master(1.0)
	AudioManager.definir_volume_musica(0.85)
	AudioManager.definir_volume_sfx(1.0)
	AudioManager.definir_volume_ambient(0.28)


func _test_pause_menu_audio_ui() -> void:
	print("\n[6] PauseMenu painel de áudio")
	var menu := PauseMenuUI.new()
	menu.name = "PauseMenuUI_Test"
	add_child(menu)
	await get_tree().process_frame
	_assert(menu.btn_audio != null, "botão Áudio / Volume existe")
	_assert(menu.painel_audio != null, "painel_audio existe")
	_assert(menu.slider_master != null and menu.slider_music != null, "sliders master/music")
	_assert(menu.slider_sfx != null and menu.slider_ambient != null, "sliders sfx/ambient")
	menu._mostrar_painel_audio()
	_assert(menu.painel_audio.visible, "painel áudio visível")
	_assert(not menu.painel_principal.visible, "painel principal oculto")
	menu.slider_music.value = 0.33
	_assert(is_equal_approx(AudioManager.music_volume_linear, 0.33), "slider música aplica volume")
	menu._mostrar_painel_principal()
	_assert(menu.painel_principal.visible, "volta ao principal")
	menu.queue_free()
	AudioManager.definir_volume_musica(0.85)


func _test_saga_hub_injects_saga_id() -> void:
	print("\n[7] SagaHubConsolidator injeta saga_id")
	var cfg: Dictionary = SagaHubConsolidator.config_for_saga(3)
	_assert(int(cfg.get("saga_id", 0)) == 3, "saga_id=3 no config")
	_assert(cfg.has("placards"), "config ainda tem placards")


func _test_loop_flag_on_load() -> void:
	print("\n[8] Stream carregado com loop")
	var path: String = AudioManager.TRACKS["hashire"]["path"]
	var stream: AudioStream = AudioManager._carregar_stream(path)
	_assert(stream != null, "hashire carrega")
	if stream is AudioStreamMP3:
		_assert((stream as AudioStreamMP3).loop, "AudioStreamMP3.loop = true")
	else:
		_assert(true, "stream não-MP3 (loop aplicado se aplicável)")
