extends Node

## Fase 2 (Arena/Nen) + Fase 3 (Yorknew + GI).
## godot --headless --path . res://scratch/test_story_phase2_3_arena_yorknew_gi_suite.tscn

const StoryChapterContractScript = preload("res://resource/quest/StoryChapterContract.gd")
const StoryNenGateScript = preload("res://scripts/story/StoryNenGate.gd")

var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== STORY PHASE2 ARENA/NEN + PHASE3 YORKNEW/GI ===")
	_test_contract_arcs_3_5()
	_test_arena_verbos_e_sensores()
	_test_arena_soft_ratio()
	_test_yorknew_gi_verbos()
	_test_yorknew_gi_soft_ratio()
	_test_wing_biscuit_wiring()
	_test_training_catalog()
	_test_cutscenes_fase23()
	_test_nen_gate_api()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [_ok, _ok + _fail, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  OK ", msg)
	else:
		_fail += 1
		print("  FAIL ", msg)


func _test_contract_arcs_3_5() -> void:
	print("-- contrato arcos 3–5 --")
	var atos3: Array = StoryChapterContractScript.listar_atos_saga(3)
	_assert(atos3.size() == 5, "Arena tem 5 atos (%d)" % atos3.size())
	_assert(str(atos3[2].get("act_id", "")) == "arena_nen", "ato arena_nen")
	var atos4: Array = StoryChapterContractScript.listar_atos_saga(4)
	_assert(atos4.size() == 4, "Yorknew tem 4 atos (%d)" % atos4.size())
	var atos5: Array = StoryChapterContractScript.listar_atos_saga(5)
	_assert(atos5.size() == 5, "GI tem 5 atos (%d)" % atos5.size())

	CanonQuestCatalog._quest_cache.clear()
	var q11: Quest = CanonQuestCatalog.obter_quest_da_etapa(3, 11)
	_assert(q11.custom_data.get("contract_version", "") == "phase0", "contrato version")
	_assert(q11.custom_data.get("act_id", "") == "arena_nen", "etapa11 act arena_nen")
	_assert(q11.custom_data.get("playable_verb", "") == "visit", "etapa11 visit Ten")

	var q13: Quest = CanonQuestCatalog.obter_quest_da_etapa(3, 13)
	_assert(q13.custom_data.get("playable_verb", "") == "stealth", "etapa13 stealth")
	var q7: Quest = CanonQuestCatalog.obter_quest_da_etapa(3, 7)
	_assert(q7.custom_data.get("playable_verb", "") == "stealth", "etapa7 soft-break stealth")


func _test_arena_verbos_e_sensores() -> void:
	print("-- arena verbos/sensores --")
	CanonQuestCatalog._quest_cache.clear()
	var checks := [
		[12, QuestObjective.Type.INVESTIGATE, "arena_dojo_wing"],
		[13, QuestObjective.Type.STEALTH_PASS, "treino_zetsu_arena"],
		[14, QuestObjective.Type.INVESTIGATE, "arena_pista_gyo"],
		[22, QuestObjective.Type.INVESTIGATE, "poeira_kastro"],
		[23, QuestObjective.Type.KILL, "lutador_arena"],
		[24, QuestObjective.Type.PERSUASION, "hisoka"],
		[7, QuestObjective.Type.STEALTH_PASS, "arena_corredor_medio"],
	]
	for c in checks:
		var q: Quest = CanonQuestCatalog.obter_quest_da_etapa(3, int(c[0]))
		_assert(q.objectives.size() >= 1, "arena etapa %d tem obj" % int(c[0]))
		_assert(q.objectives[0].type == c[1], "arena etapa %d tipo ok" % int(c[0]))
		var tid := ""
		match q.objectives[0].type:
			QuestObjective.Type.INVESTIGATE:
				tid = str(q.objectives[0].target_clue_id)
			QuestObjective.Type.STEALTH_PASS:
				tid = str(q.objectives[0].target_zone_id)
			QuestObjective.Type.KILL:
				tid = str(q.objectives[0].enemy_type)
			QuestObjective.Type.PERSUASION:
				tid = str(q.objectives[0].target_npc_id)
			_:
				tid = ""
		_assert(tid == str(c[2]), "arena etapa %d id=%s" % [int(c[0]), tid])

	var mapa := FileAccess.get_file_as_string("res://world/maps/ArenaCelestialMap.gd")
	_assert("treino_zetsu_arena" in mapa, "mapa tem treino_zetsu_arena")
	_assert("arena_pista_gyo" in mapa, "mapa tem arena_pista_gyo")
	_assert("poeira_kastro" in mapa, "mapa tem poeira_kastro")
	_assert("arena_dojo_wing" in mapa, "mapa tem arena_dojo_wing")


func _test_arena_soft_ratio() -> void:
	print("-- soft ratio arena --")
	CanonQuestCatalog._quest_cache.clear()
	var soft := 0
	var hard := 0
	var streak := 0
	var max_streak := 0
	for e in range(1, 27):
		var q: Quest = CanonQuestCatalog.obter_quest_da_etapa(3, e)
		if StoryChapterContractScript.eh_soft_only(q):
			soft += 1
			streak += 1
			max_streak = maxi(max_streak, streak)
		else:
			hard += 1
			streak = 0
	_assert(hard >= 10, "arena hard >= 10 (got %d)" % hard)
	_assert(soft <= 16, "arena soft <= 16 (got %d)" % soft)
	_assert(max_streak <= 5, "arena max soft streak <= 5 (got %d)" % max_streak)
	print("  soft=%d hard=%d max_streak=%d" % [soft, hard, max_streak])


func _test_yorknew_gi_verbos() -> void:
	print("-- yorknew/gi verbos --")
	CanonQuestCatalog._quest_cache.clear()
	var y25: Quest = CanonQuestCatalog.obter_quest_da_etapa(4, 25)
	_assert(y25.objectives[0].type == QuestObjective.Type.STEALTH_PASS, "york 25 stealth")
	_assert(str(y25.objectives[0].target_zone_id) == "yorknew_docas_leilao", "york 25 docas")
	var y26: Quest = CanonQuestCatalog.obter_quest_da_etapa(4, 26)
	_assert(y26.objectives[0].type == QuestObjective.Type.PERSUASION, "york 26 persuasion chrollo")
	var y28: Quest = CanonQuestCatalog.obter_quest_da_etapa(4, 28)
	_assert(str(y28.objectives[0].target_clue_id) == "yorknew_hotel_beitacle", "york 28 hotel")
	var y30: Quest = CanonQuestCatalog.obter_quest_da_etapa(4, 30)
	_assert(str(y30.objectives[0].target_clue_id) == "yorknew_leilao_aura", "york 30 leilao")
	var y31: Quest = CanonQuestCatalog.obter_quest_da_etapa(4, 31)
	_assert(y31.objectives[0].type == QuestObjective.Type.PERSUASION, "york 31 persuasion battera")

	var g7: Quest = CanonQuestCatalog.obter_quest_da_etapa(5, 7)
	_assert(str(g7.objectives[0].target_clue_id) == "greed_ko_desfiladeiro", "gi 7 ko")
	var g9: Quest = CanonQuestCatalog.obter_quest_da_etapa(5, 9)
	_assert(g9.objectives[0].type == QuestObjective.Type.STEALTH_PASS, "gi 9 stealth")
	var g11: Quest = CanonQuestCatalog.obter_quest_da_etapa(5, 11)
	_assert(str(g11.objectives[0].target_clue_id) == "quiz_100_cartas", "gi 11 quiz")
	var g15: Quest = CanonQuestCatalog.obter_quest_da_etapa(5, 15)
	_assert(g15.objectives[0].type == QuestObjective.Type.PERSUASION, "gi 15 tsezguerra")
	var g17: Quest = CanonQuestCatalog.obter_quest_da_etapa(5, 17)
	_assert(str(g17.objectives[0].target_zone_id) == "greed_corredor_soufrabi", "gi 17 soufrabi")
	var g19: Quest = CanonQuestCatalog.obter_quest_da_etapa(5, 19)
	_assert(str(g19.objectives[0].target_clue_id) == "ginasio_razor", "gi 19 razor")

	var york := FileAccess.get_file_as_string("res://world/maps/YorknewCityMap.gd")
	_assert("yorknew_docas_leilao" in york and "yorknew_hotel_beitacle" in york, "york sensores")
	var gi := FileAccess.get_file_as_string("res://world/maps/GreedIslandMap.gd")
	_assert("greed_ko_desfiladeiro" in gi and "greed_colinas_furtivas" in gi, "gi sensores")
	_assert("quiz_100_cartas" in gi and "ginasio_razor" in gi, "gi quiz/razor")


func _test_yorknew_gi_soft_ratio() -> void:
	print("-- soft ratio yorknew/gi --")
	for arco_total in [[4, 34], [5, 36]]:
		var arco: int = int(arco_total[0])
		var total: int = int(arco_total[1])
		CanonQuestCatalog._quest_cache.clear()
		var soft := 0
		var hard := 0
		var streak := 0
		var max_streak := 0
		for e in range(1, total + 1):
			var q: Quest = CanonQuestCatalog.obter_quest_da_etapa(arco, e)
			if StoryChapterContractScript.eh_soft_only(q):
				soft += 1
				streak += 1
				max_streak = maxi(max_streak, streak)
			else:
				hard += 1
				streak = 0
		_assert(hard >= 8, "arco %d hard >= 8 (got %d)" % [arco, hard])
		_assert(max_streak <= 8, "arco %d max soft streak <= 8 (got %d)" % [arco, max_streak])
		print("  arco%d soft=%d hard=%d max_streak=%d" % [arco, soft, hard, max_streak])


func _test_wing_biscuit_wiring() -> void:
	print("-- wing/biscuit wiring --")
	var wing := FileAccess.get_file_as_string("res://entities/npc/wing/Wing.gd")
	_assert("StoryNenGateScript" in wing, "Wing usa StoryNenGate")
	_assert("executar_wing_principios_nen" in wing, "Wing dispara cutscene princípios")
	_assert("ren_basico_wing" in wing, "Wing conclui ren_basico")
	_assert("etapa_atual == 13" in wing and "etapa_atual == 14" in wing, "Wing etapas 13/14")
	var hisoka := FileAccess.get_file_as_string("res://entities/npc/hisoka/Hisoka.gd")
	_assert("register_persuasion" in hisoka, "Hisoka persuasion")
	_assert("etapa == 24" in hisoka, "Hisoka duelo etapa 24")
	var biscuit := FileAccess.get_file_as_string("res://entities/npc/biscuit/Biscuit.gd")
	_assert("StoryNenGateScript" in biscuit, "Biscuit usa StoryNenGate")
	_assert("ko_basico_biscuit" in biscuit, "Biscuit ko_basico")
	_assert("executar_biscuit_pressao_ko" in biscuit, "Biscuit cutscene ko")
	_assert("_tratar_treino_gi" in biscuit, "Biscuit treino GI")


func _test_training_catalog() -> void:
	print("-- training catalog --")
	_assert(TrainingSystem.CATALOGO_TREINOS.has("ren_basico_wing"), "catalogo ren_basico_wing")
	_assert(TrainingSystem.CATALOGO_TREINOS.has("ko_basico_biscuit"), "catalogo ko_basico_biscuit")
	_assert(int(TrainingSystem.CATALOGO_TREINOS["ren_basico_wing"].get("requisito_nivel", 99)) <= 1, "ren_basico lvl1")
	_assert(int(TrainingSystem.CATALOGO_TREINOS["ko_basico_biscuit"].get("requisito_nivel", 99)) <= 1, "ko_basico lvl1")


func _test_cutscenes_fase23() -> void:
	print("-- cutscenes fase2/3 --")
	var scm := FileAccess.get_file_as_string("res://scripts/cutscenes/StoryCutsceneManager.gd")
	_assert("executar_wing_principios_nen" in scm, "cutscene wing princípios")
	_assert("executar_biscuit_pressao_ko" in scm, "cutscene biscuit ko")
	var ckpt := FileAccess.get_file_as_string("res://scripts/cutscenes/CheckpointCutsceneLibrary.gd")
	_assert("arena_wing_principios" in ckpt, "checkpoint wing princípios")
	_assert("greed_biscuit_ko" in ckpt, "checkpoint biscuit ko")


func _test_nen_gate_api() -> void:
	print("-- StoryNenGate API --")
	_assert(StoryNenGateScript != null, "StoryNenGate preload")
	var src := FileAccess.get_file_as_string("res://scripts/story/StoryNenGate.gd")
	_assert("static func garantir_tecnica" in src, "garantir_tecnica")
	_assert("static func garantir_pacote_wing" in src, "garantir_pacote_wing")
	_assert("static func garantir_pacote_biscuit" in src, "garantir_pacote_biscuit")
	_assert("tecnicas_nen" in src, "persiste tecnicas_nen")
