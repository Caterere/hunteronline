extends Node

## Fase 4 (Formigas) + Fase 5 (Kukuroo / Eleição / Continente / Sucessão).
## godot --headless --path . res://scratch/test_story_phase4_5_remaining_sagas_suite.tscn

const StoryChapterContractScript = preload("res://resource/quest/StoryChapterContract.gd")

var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== STORY PHASE4 FORMIGAS + PHASE5 SAGAS RESTANTES ===")
	_test_atos_dedicados()
	_test_formigas_verbos()
	_test_soft_ratios()
	_test_sensores_mapas()
	_test_cutscene_hora_zero()
	_test_contract_verb_infer()
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


func _test_atos_dedicados() -> void:
	print("-- atos dedicados 2/6/7/8/9 --")
	_assert(StoryChapterContractScript.listar_atos_saga(2).size() == 3, "Kukuroo 3 atos")
	_assert(StoryChapterContractScript.listar_atos_saga(6).size() == 5, "Formigas 5 atos")
	_assert(StoryChapterContractScript.listar_atos_saga(7).size() == 3, "Eleição 3 atos")
	_assert(StoryChapterContractScript.listar_atos_saga(8).size() == 3, "Continente 3 atos")
	_assert(StoryChapterContractScript.listar_atos_saga(9).size() == 4, "Sucessão 4 atos")
	CanonQuestCatalog._quest_cache.clear()
	var q8: Quest = CanonQuestCatalog.obter_quest_da_etapa(6, 8)
	_assert(str(q8.custom_data.get("act_id", "")).begins_with("ngl_"), "formigas act_id ngl_*")
	var qk: Quest = CanonQuestCatalog.obter_quest_da_etapa(2, 5)
	_assert(str(qk.custom_data.get("act_id", "")) == "kuku_portao", "kukuroo act portao")


func _test_formigas_verbos() -> void:
	print("-- formigas verbos --")
	CanonQuestCatalog._quest_cache.clear()
	var checks := [
		[8, QuestObjective.Type.INVESTIGATE, "ngl_aura_pitou"],
		[10, QuestObjective.Type.STEALTH_PASS, "ngl_patrulha_fronteira"],
		[12, QuestObjective.Type.PERSUASION, "morel"],
		[23, QuestObjective.Type.PERSUASION, "meruem"],
		[27, QuestObjective.Type.INVESTIGATE, "escadaria_youpi"],
		[28, QuestObjective.Type.STEALTH_PASS, "ngl_corredor_palacio"],
		[36, QuestObjective.Type.STEALTH_PASS, "ngl_vestibulo_tumba"],
		[42, QuestObjective.Type.PERSUASION, "gon"],
	]
	for c in checks:
		var q: Quest = CanonQuestCatalog.obter_quest_da_etapa(6, int(c[0]))
		_assert(q.objectives[0].type == c[1], "formigas e%d tipo" % int(c[0]))
		var tid := _obj_id(q.objectives[0])
		_assert(tid == str(c[2]), "formigas e%d id=%s" % [int(c[0]), tid])


func _obj_id(obj: QuestObjective) -> String:
	match obj.type:
		QuestObjective.Type.INVESTIGATE:
			return str(obj.target_clue_id)
		QuestObjective.Type.STEALTH_PASS:
			return str(obj.target_zone_id)
		QuestObjective.Type.KILL:
			return str(obj.enemy_type)
		QuestObjective.Type.PERSUASION, QuestObjective.Type.VISIT:
			return str(obj.target_npc_id)
		QuestObjective.Type.COLLECT:
			return str(obj.item_id)
		_:
			return ""


func _test_soft_ratios() -> void:
	print("-- soft ratios --")
	var targets := {
		2: {"hard_min": 5, "streak_max": 5},
		6: {"hard_min": 12, "streak_max": 7},
		7: {"hard_min": 6, "streak_max": 5},
		8: {"hard_min": 9, "streak_max": 5},
		9: {"hard_min": 10, "streak_max": 5},
	}
	for arco in targets.keys():
		CanonQuestCatalog._quest_cache.clear()
		var total: int = int(StoryChapterContractScript.TOTAIS_POR_ARCO.get(arco, 1))
		var soft := 0
		var hard := 0
		var streak := 0
		var max_streak := 0
		for e in range(1, total + 1):
			var q: Quest = CanonQuestCatalog.obter_quest_da_etapa(int(arco), e)
			if StoryChapterContractScript.eh_soft_only(q):
				soft += 1
				streak += 1
				max_streak = maxi(max_streak, streak)
			else:
				hard += 1
				streak = 0
		var t: Dictionary = targets[arco]
		_assert(hard >= int(t["hard_min"]), "arco %d hard >= %d (got %d)" % [arco, int(t["hard_min"]), hard])
		_assert(max_streak <= int(t["streak_max"]), "arco %d streak <= %d (got %d)" % [arco, int(t["streak_max"]), max_streak])
		print("  arco%d soft=%d hard=%d max_streak=%d" % [arco, soft, hard, max_streak])


func _test_sensores_mapas() -> void:
	print("-- sensores mapas --")
	var ngl := FileAccess.get_file_as_string("res://world/maps/NGLFormigasMap.gd")
	_assert("ngl_aura_pitou" in ngl and "ngl_patrulha_fronteira" in ngl, "NGL sensores pitou/patrulha")
	_assert("ngl_corredor_palacio" in ngl and "ngl_vestibulo_tumba" in ngl, "NGL sensores palacio/tumba")
	_assert("executar_ngl_hora_zero" in ngl, "NGL dispara hora zero")
	var kuku := FileAccess.get_file_as_string("res://world/maps/MontanhaKukurooMap.gd")
	_assert("kukuroo_portao_aura" in kuku and "kukuroo_corredor_trono" in kuku, "Kukuroo sensores")
	var assoc := FileAccess.get_file_as_string("res://world/maps/AssociacaoHunterMap.gd")
	_assert("uti_gon_associacao" in assoc and "assoc_rodovia_illumi" in assoc, "Assoc sensores")
	var cn := FileAccess.get_file_as_string("res://world/maps/ContinenteNegroMap.gd")
	_assert("cn_copa_intermediaria" in cn and "cn_nitro_rice_aura" in cn, "CN sensores")
	var bw := FileAccess.get_file_as_string("res://world/maps/BlackWhale1Map.gd")
	_assert("bw_armazem_profundo" in bw and "bw_marca_bungee" in bw, "BW sensores")


func _test_cutscene_hora_zero() -> void:
	print("-- cutscenes --")
	var scm := FileAccess.get_file_as_string("res://scripts/cutscenes/StoryCutsceneManager.gd")
	_assert("executar_ngl_hora_zero" in scm, "cutscene ngl hora zero")
	var ckpt := FileAccess.get_file_as_string("res://scripts/cutscenes/CheckpointCutsceneLibrary.gd")
	_assert("ngl_hora_zero" in ckpt, "checkpoint ngl_hora_zero")


func _test_contract_verb_infer() -> void:
	print("-- verb infer --")
	CanonQuestCatalog._quest_cache.clear()
	var q: Quest = CanonQuestCatalog.obter_quest_da_etapa(6, 10)
	_assert(q.custom_data.get("playable_verb", "") == "stealth", "e10 verb stealth (infer)")
	var q2: Quest = CanonQuestCatalog.obter_quest_da_etapa(7, 9)
	_assert(q2.custom_data.get("playable_verb", "") == "stealth", "ele9 verb stealth")
	var q3: Quest = CanonQuestCatalog.obter_quest_da_etapa(9, 12)
	_assert(q3.custom_data.get("playable_verb", "") == "stealth", "bw12 verb stealth")
