extends Node

## Fase 0 (contrato) + piloto Exame Hunter.
## godot --headless --path . res://scratch/test_story_phase0_exame_piloto_suite.tscn

const StoryChapterContractScript = preload("res://resource/quest/StoryChapterContract.gd")
const TonpaExameDialogueFactoryScript = preload("res://data/dialogues/TonpaExameDialogueFactory.gd")

var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== STORY PHASE0 + EXAME PILOTO ===")
	_test_contract_schema()
	_test_exame_atos_e_verbos()
	_test_exame_soft_ratio_melhor()
	_test_tonpa_dialogue_factory()
	_test_cutscenes_piloto()
	_test_mapa_sensores()
	_test_story_bible_counts()
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


func _test_contract_schema() -> void:
	print("-- contrato schema --")
	CanonQuestCatalog._quest_cache.clear()
	var q: Quest = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	_assert(q != null, "quest 1/1 existe")
	_assert(q.custom_data.get("contract_version", "") == "phase0", "contract_version phase0")
	_assert(str(q.custom_data.get("act_id", "")).begins_with("exame_"), "act_id exame_*")
	_assert(q.custom_data.has("narrative_role"), "narrative_role presente")
	_assert(q.custom_data.has("playable_verb"), "playable_verb presente")
	var atos: Array = StoryChapterContractScript.listar_atos_saga(1)
	_assert(atos.size() == 7, "Exame tem 7 atos (%d)" % atos.size())
	# Todas as 9 sagas recebem metadado
	for arco in range(1, 10):
		CanonQuestCatalog._quest_cache.clear()
		var qx: Quest = CanonQuestCatalog.obter_quest_da_etapa(arco, 1)
		_assert(qx.custom_data.get("contract_version", "") == "phase0", "arco %d etapa1 tem contrato" % arco)


func _test_exame_atos_e_verbos() -> void:
	print("-- exame atos/verbos piloto --")
	CanonQuestCatalog._quest_cache.clear()
	var q1: Quest = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	_assert(q1.objectives[0].type == QuestObjective.Type.PERSUASION, "etapa1 persuasion (Tonpa)")
	var q17: Quest = CanonQuestCatalog.obter_quest_da_etapa(1, 17)
	_assert(q17.objectives[0].type == QuestObjective.Type.PERSUASION, "etapa17 persuasion")
	var q20: Quest = CanonQuestCatalog.obter_quest_da_etapa(1, 20)
	_assert(q20.objectives.size() >= 2, "etapa20 visit+investigate")
	_assert(q20.custom_data.get("act_id", "") == "exame_zevil", "etapa20 ato zevil")
	var q23: Quest = CanonQuestCatalog.obter_quest_da_etapa(1, 23)
	var has_stealth := false
	for o in q23.objectives:
		if o.type == QuestObjective.Type.STEALTH_PASS:
			has_stealth = true
	_assert(has_stealth, "etapa23 inclui stealth caverna_ponzu")
	var q24: Quest = CanonQuestCatalog.obter_quest_da_etapa(1, 24)
	_assert(q24.custom_data.get("narrative_role", "") == "climax", "etapa24 climax")
	_assert(q24.objectives.size() >= 2, "etapa24 kill+visit")


func _test_exame_soft_ratio_melhor() -> void:
	print("-- soft ratio exame --")
	CanonQuestCatalog._quest_cache.clear()
	var soft := 0
	var hard := 0
	var streak := 0
	var max_streak := 0
	for e in range(1, 25):
		var q: Quest = CanonQuestCatalog.obter_quest_da_etapa(1, e)
		if StoryChapterContractScript.eh_soft_only(q):
			soft += 1
			streak += 1
			max_streak = maxi(max_streak, streak)
		else:
			hard += 1
			streak = 0
	_assert(hard >= 10, "exame hard >= 10 (got %d)" % hard)
	_assert(soft <= 14, "exame soft <= 14 (got %d)" % soft)
	_assert(max_streak <= 5, "max soft streak <= 5 (got %d)" % max_streak)
	print("  soft=%d hard=%d max_streak=%d" % [soft, hard, max_streak])


func _test_tonpa_dialogue_factory() -> void:
	print("-- tonpa dialogue tree --")
	var tree: DialogueTree = TonpaExameDialogueFactoryScript.criar()
	_assert(tree != null and tree.is_valid(), "TonpaExameDialogueFactory.is_valid")
	_assert(tree.tree_id == &"tonpa_exame_intro", "tree_id")
	_assert(tree.nodes.size() >= 4, "nós >= 4")
	var root: DialogueNode = tree.get_root_node()
	_assert(root != null and root.has_branches(), "root com escolhas")
	_assert(root.branches.size() >= 3, "3 opções na intro")


func _test_cutscenes_piloto() -> void:
	print("-- cutscenes piloto --")
	var scm := FileAccess.get_file_as_string("res://scripts/cutscenes/StoryCutsceneManager.gd")
	_assert("executar_votacao_trick_tower" in scm, "cutscene votação Trick Tower")
	_assert("executar_zevil_embarque" in scm, "cutscene embarque Zevil")
	_assert("executar_gourmet_menchi_buhara" in scm, "cutscene gourmet")
	var menchi := FileAccess.get_file_as_string("res://entities/npc/gourmet/Menchi.gd")
	_assert("executar_gourmet_menchi_buhara" in menchi, "Menchi dispara gourmet")
	var satotz := FileAccess.get_file_as_string("res://entities/npc/satotz/Satotz.gd")
	_assert("executar_zevil_embarque" in satotz, "Satotz dispara zevil")
	var tonpa := FileAccess.get_file_as_string("res://entities/npc/tonpa/Tonpa.gd")
	_assert("TonpaExameDialogueFactory" in tonpa, "Tonpa usa DialogueFactory")
	_assert("executar_votacao_trick_tower" in tonpa, "Tonpa dispara votação")
	var ckpt := FileAccess.get_file_as_string("res://scripts/cutscenes/CheckpointCutsceneLibrary.gd")
	_assert("exame_trick_tower" in ckpt and "exame_zevil" in ckpt, "checkpoints trick/zevil")


func _test_mapa_sensores() -> void:
	print("-- mapa sensores --")
	var src := FileAccess.get_file_as_string("res://world/maps/ExameMaratonaMap.gd")
	_assert("placa_zevil" in src, "sensor placa_zevil")
	_assert("caverna_ponzu" in src, "sensor caverna_ponzu")
	_assert("quest_etapa = 24" in src or ", 1, 24," in src, "spawn etapa 24 registrado")


func _test_story_bible_counts() -> void:
	print("-- story bible sync --")
	var bible := FileAccess.get_file_as_string("res://docs/bibles/STORY_BIBLE.md")
	_assert("(34 Etapas)" in bible, "bible arco4 = 34")
	_assert("(36 Etapas)" in bible, "bible arco5 = 36")
	_assert("(48 Etapas)" in bible, "bible arco6 = 48")
	_assert("(20 Etapas)" in bible, "bible arco7 = 20")
	_assert("(22 Etapas)" in bible, "bible arco8 = 22")
	_assert("StoryChapterContract" in bible, "bible menciona contrato")
	_assert("254" in bible, "bible menciona total 254")
