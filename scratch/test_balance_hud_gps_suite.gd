extends Node

# ============================================================
# Suite: balance (stats ×0.5), toast queue, HUD scale, GPS objectives
# godot --headless --path . res://scratch/test_balance_hud_gps_suite.tscn
# ============================================================

const StoryGate = preload("res://world/components/StoryGate.gd")

var _pass := 0
var _fail := 0


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("=== test_balance_hud_gps_suite ===")
	_test_base_stats_halved()
	await _test_playerdata_reset_mirrors_base()
	await _test_toast_queue_api()
	_test_hud_scale_const()
	_test_gps_no_story_gate_while_pending()
	await _test_gps_runtime_prefers_objective()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_base_stats_halved() -> void:
	print("-- BASE_STATS --")
	assert_test(is_equal_approx(float(ProgressionConfig.BASE_STATS["vida_max"]), 50.0), "vida_max base = 50")
	assert_test(is_equal_approx(float(ProgressionConfig.BASE_STATS["forca"]), 5.0), "forca base = 5")
	assert_test(is_equal_approx(float(ProgressionConfig.BASE_STATS["defesa"]), 5.0), "defesa base = 5")
	assert_test(is_equal_approx(float(ProgressionConfig.BASE_STATS["velocidade"]), 5.0), "velocidade base = 5")
	assert_test(is_equal_approx(float(ProgressionConfig.BASE_STATS["aura_max"]), 50.0), "aura_max base = 50")
	assert_test(is_equal_approx(ProgressionConfig.calcular_stat_base("vida_max", 1), 50.0), "calcular_stat_base lvl1 vida=50")
	assert_test(is_equal_approx(ProgressionConfig.calcular_stat_base("forca", 1), 5.0), "calcular_stat_base lvl1 forca=5")
	assert_test(is_equal_approx(ProgressionConfig.calcular_stat_base("vida_max", 1000), 50000.0), "lvl1000 vida ainda 50000")


func _test_playerdata_reset_mirrors_base() -> void:
	print("-- PlayerData reset --")
	if PlayerData == null:
		assert_test(false, "PlayerData autoload")
		return
	# Emissão não altera vida/força — isola o BASE_STATS
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.EMISSAO
	PlayerData.active_modifiers.clear()
	PlayerData.attributes["nivel"] = 1
	PlayerData.recalcular_todos_atributos()
	assert_test(int(PlayerData.attributes["vida_max"]) == 50, "PlayerData vida_max lvl1 = 50")
	assert_test(int(PlayerData.attributes["forca"]) == 5, "PlayerData forca lvl1 = 5")
	await get_tree().process_frame


func _test_toast_queue_api() -> void:
	print("-- Toast queue --")
	var src := FileAccess.get_file_as_string("res://ui/hud/PlayerHUD.gd")
	assert_test("_toast_queue" in src, "PlayerHUD tem fila _toast_queue")
	assert_test("_tentar_mostrar_proximo_toast" in src, "PlayerHUD serializa toasts")
	assert_test("TOAST_DEDUPE_MS" in src, "PlayerHUD dedupe toasts")
	assert_test("HUD_SCALE" in src and "0.75" in src, "PlayerHUD HUD_SCALE 0.75")

	var hud = load("res://ui/hud/PlayerHUD.gd").new()
	add_child(hud)
	await get_tree().process_frame
	hud.exibir_notificacao("Toast A")
	hud.exibir_notificacao("Toast B")
	assert_test(hud._toast_showing or hud._toast_queue.size() >= 1, "toast em exibição ou na fila")
	assert_test(hud._toast_queue.size() <= 4, "fila limitada")
	hud.queue_free()


func _test_hud_scale_const() -> void:
	print("-- HUD scale --")
	var qsrc := FileAccess.get_file_as_string("res://ui/hud/QuestHUD.gd")
	assert_test("scale = Vector2(0.75, 0.75)" in qsrc, "QuestHUD scale 0.75")
	var nsrc := FileAccess.get_file_as_string("res://ui/hud/NenQuickActionBar.gd")
	assert_test("scale = Vector2(0.75, 0.75)" in nsrc, "NenQuickActionBar scale 0.75")
	var gsrc := FileAccess.get_file_as_string("res://ui/hud/MissionGPSIndicator.gd")
	assert_test("scale = Vector2(0.75, 0.75)" in gsrc, "MissionGPS GPS panel scale 0.75")


func _test_gps_no_story_gate_while_pending() -> void:
	print("-- GPS static --")
	var gsrc := FileAccess.get_file_as_string("res://ui/hud/MissionGPSIndicator.gd")
	assert_test("_tentar_alvo_por_marcadores_capitulo" in gsrc, "GPS usa marcadores de capítulo")
	assert_test("_tentar_alvo_por_ancora_distrito" in gsrc, "GPS usa âncora de distrito")
	assert_test("ja_no_mapa_certo" in gsrc, "GPS só roteia portal fora do mapa certo")
	var qhud := FileAccess.get_file_as_string("res://ui/hud/QuestHUD.gd")
	assert_test("Zona do Objetivo" in qhud, "QuestHUD fallback = zona do objetivo")
	var qmgr := FileAccess.get_file_as_string("res://scripts/missions/QuestManager.gd")
	assert_test("progresso < obj.required_amount" in qmgr, "QuestManager não spam de progresso parcial")


func _test_gps_runtime_prefers_objective() -> void:
	print("-- GPS runtime --")
	var cur = get_tree().current_scene
	var guia2 := Node2D.new()
	guia2.name = "GuiaCapituloSaga"
	guia2.position = Vector2(420, -120)
	cur.add_child(guia2)
	var portal2 := MapTransitionArea.new()
	portal2.name = "PortalStoryGate"
	portal2.position = Vector2(8000, 0)
	portal2.target_scene_path = "res://world/maps/montanha_kukuroo.tscn"
	portal2.story_gate = StoryGate.new(1, 24, true)
	cur.add_child(portal2)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(80, 16)
	cur.add_child(player)

	if PlayerData != null:
		PlayerData.arco_atual = 1
		PlayerData.etapa_quest_arco = 4
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
		var q = CanonQuestCatalog.obter_quest_da_etapa(1, 4)
		if q != null:
			QuestSystem.start_quest(q)

	var gps := MissionGPSIndicator.new()
	gps.name = "MissionGPSIndicatorTest"
	cur.add_child(gps)

	await get_tree().process_frame
	await get_tree().process_frame
	gps._atualizar_alvo_ativo()

	assert_test(gps.target_found, "GPS encontrou algum alvo")
	if gps.target_found:
		var apontou_portal := gps.current_target_type == "portal" and is_instance_valid(gps.current_target_node) and gps.current_target_node == portal2
		assert_test(not apontou_portal, "GPS NÃO aponta ao story_gate com objetivo pendente")
		assert_test(gps.current_target_type != "portal", "GPS tipo != portal enquanto objetivo pendente no mapa")
