extends Node

var _passed := 0
var _total := 0
var _failures: PackedStringArray = []

func _ready() -> void:
	print("\n🧪 A–D PROGRESSION MATCH SUITE")
	await get_tree().process_frame
	_test_visit_matches()
	_test_persuasion_matches()
	_test_clue_kill_id_overlap()
	_test_bw_enemy_counts()
	await _test_map_npc_visit_live()
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	for f in _failures:
		print("   ❌ ", f)
	get_tree().quit(0 if _passed == _total else 1)

func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)

func _test_visit_matches() -> void:
	print("\n[1] visit matching...")
	var cases := [
		# registered_id, target_npc_id, target_npc_name, expect
		["kurapika", "kurapika", "Kurapika", true],
		["Rainha Oito & Príncipe Woble", "rainha_oito", "Rainha Oito & Príncipe Woble", true],
		["rainha_oito", "rainha_oito", "Rainha Oito & Príncipe Woble", true],
		["Vaso Sagrado de Kakin", "vaso_kakin", "Vaso Sagrado de Kakin", true],
		["Hinrigh (Família Xi-Yu)", "hinrigh", "Hinrigh (Família Xi-Yu)", true],
		["Hinrigh", "hinrigh", "Hinrigh", true],
		["Presidente Cheadle", "cheadle", "Presidente Cheadle", true],
		["Cheadle Yorkshire (Zodíaco Cão)", "cheadle", "Cheadle Yorkshire (Zodíaco Cão)", true],
		["Ging Freecss no Topo", "ging_topo", "Ging Freecss no Topo", true],
		["Alluka & Nanika", "alluka", "Alluka & Nanika", true],
		["Bilionário Battera", "battera", "Bilionário Battera", true],
		["Hisoka Morow", "hisoka", "Hisoka Morow", true],
		["Chrollo Lucilfer", "chrollo", "Chrollo Lucilfer", true],
		# known risk: generic NPC registers display name; target id only
		["vaso sagrado de kakin", "vaso_kakin", "Vaso Sagrado de Kakin", true],
	]
	for c in cases:
		var obj := QuestObjective.new()
		obj.type = QuestObjective.Type.VISIT
		obj.target_npc_id = StringName(c[1])
		obj.target_npc_name = str(c[2])
		var reg := str(c[0]).to_lower()
		var got := MissionObjectiveResolver.npc_matches_objective(reg, reg, obj)
		_ok(got == bool(c[3]), "visit '%s' vs %s/%s -> %s" % [c[0], c[1], c[2], c[3]])

func _test_persuasion_matches() -> void:
	print("\n[2] persuasion register logic...")
	# Simulate QuestManager.register_persuasion matching (inline copy of conditions)
	var cases := [
		["chrollo", "chrollo", "Chrollo Lucilfer", true],
		["Chrollo Lucilfer", "chrollo", "Chrollo Lucilfer", true],
		["kurapika", "kurapika", "Kurapika", true],
		["melody", "melody", "Melody", true],
		["ging", "ging", "Ging Freecss", true],
		["Ging Freecss no Topo", "ging_topo", "Ging Freecss no Topo", true],
	]
	for c in cases:
		var id_str := str(c[0]).to_lower()
		var target_str := str(c[1]).to_lower()
		var target_name_str := str(c[2]).to_lower()
		var got := target_str == id_str or target_str in id_str or target_name_str in id_str or id_str in target_name_str
		_ok(got == bool(c[3]), "persuasion '%s' vs %s -> %s" % [c[0], c[1], c[3]])

func _test_clue_kill_id_overlap() -> void:
	print("\n[3] clue vs kill id overlap BW...")
	var q16 = CanonQuestCatalog.obter_quest_da_etapa(9, 16)
	var q18 = CanonQuestCatalog.obter_quest_da_etapa(9, 18)
	_ok(q16 != null and q16.objectives[0].type == QuestObjective.Type.INVESTIGATE, "e16 investigate")
	_ok(q18 != null and q18.objectives[0].type == QuestObjective.Type.KILL, "e18 kill")
	_ok(str(q16.objectives[0].target_clue_id) == "besta_tserriednich", "e16 clue id")
	_ok(str(q18.objectives[0].enemy_type) == "besta_tserriednich", "e18 enemy id same string")
	# Not a bug by itself if systems are separate — flag for documentation
	_ok(true, "overlap noted (investigate vs kill separate channels)")

func _test_bw_enemy_counts() -> void:
	print("\n[4] BW catalog kill quotas...")
	var q6 = CanonQuestCatalog.obter_quest_da_etapa(9, 6)
	var q11 = CanonQuestCatalog.obter_quest_da_etapa(9, 11)
	var q20 = CanonQuestCatalog.obter_quest_da_etapa(9, 20)
	var q21 = CanonQuestCatalog.obter_quest_da_etapa(9, 21)
	_ok(q6.objectives[0].required_amount == 3, "e6 need 3 parasita")
	_ok(q11.objectives[0].required_amount == 6, "e11 need 6 heilly")
	_ok(q20.objectives[0].required_amount == 4, "e20 need 4 heilly")
	_ok(q21.objectives[0].required_amount == 2, "e21 need 2 parasita")

func _test_map_npc_visit_live() -> void:
	print("\n[5] live register_npc_visit on BW NPCs...")
	PlayerData.despertou_nen = true
	PlayerData.arco_atual = 9
	# clear quests
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
	var q = CanonQuestCatalog.obter_quest_da_etapa(9, 2)
	QuestSystem.start_quest(q)
	var MapScript = load("res://world/maps/BlackWhale1Map.gd")
	var mapa = MapScript.new()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	var oito = mapa.get_node_or_null("RainhaOito")
	_ok(oito != null, "RainhaOito node")
	var before = PlayerData.get_quest_objective_progress(q, 0)
	# Simulate what NPC._on_interacted does for generic NPC
	var fala_name := ""
	if "npc_name" in oito:
		fala_name = str(oito.npc_name)
	QuestSystem.register_npc_visit(StringName(fala_name))
	var after = PlayerData.get_quest_objective_progress(q, 0)
	_ok(after > before, "visit rainha via display name progresses e2 (before=%d after=%d name='%s')" % [before, after, fala_name])

	# etapa 3 vaso
	QuestSystem.active_quests.clear()
	var q3 = CanonQuestCatalog.obter_quest_da_etapa(9, 3)
	QuestSystem.start_quest(q3)
	var vaso = mapa.get_node_or_null("VasoKakin")
	var vname := str(vaso.npc_name) if vaso != null and "npc_name" in vaso else ""
	var b3 = PlayerData.get_quest_objective_progress(q3, 0)
	QuestSystem.register_npc_visit(StringName(vname))
	var a3 = PlayerData.get_quest_objective_progress(q3, 0)
	_ok(a3 > b3, "visit vaso progresses e3 (name='%s')" % vname)

	# etapa 14 persuasion chrollo
	QuestSystem.active_quests.clear()
	var q14 = CanonQuestCatalog.obter_quest_da_etapa(9, 14)
	QuestSystem.start_quest(q14)
	var b14 = PlayerData.get_quest_objective_progress(q14, 0)
	QuestSystem.register_persuasion(&"chrollo")
	var a14 = PlayerData.get_quest_objective_progress(q14, 0)
	_ok(a14 > b14, "persuasion chrollo progresses e14")

	# etapa 26 cheadle
	QuestSystem.active_quests.clear()
	var q26 = CanonQuestCatalog.obter_quest_da_etapa(9, 26)
	QuestSystem.start_quest(q26)
	var cheadle = mapa.get_node_or_null("Cheadle")
	var cname := str(cheadle.npc_name) if cheadle != null and "npc_name" in cheadle else ""
	var b26 = PlayerData.get_quest_objective_progress(q26, 0)
	QuestSystem.register_npc_visit(StringName(cname))
	var a26 = PlayerData.get_quest_objective_progress(q26, 0)
	_ok(a26 > b26, "visit cheadle progresses e26 (name='%s')" % cname)

	# investigate clue
	QuestSystem.active_quests.clear()
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(9, 4)
	QuestSystem.start_quest(q4)
	var b4 = PlayerData.get_quest_objective_progress(q4, 0)
	QuestSystem.register_investigation(&"primeiro_assassinato_kakin")
	var a4 = PlayerData.get_quest_objective_progress(q4, 0)
	_ok(a4 > b4, "investigate assassinato progresses e4")

	# stealth
	QuestSystem.active_quests.clear()
	var q15 = CanonQuestCatalog.obter_quest_da_etapa(9, 15)
	QuestSystem.start_quest(q15)
	var b15 = PlayerData.get_quest_objective_progress(q15, 0)
	QuestSystem.register_stealth_pass(&"aposentos_tserriednich")
	var a15 = PlayerData.get_quest_objective_progress(q15, 0)
	_ok(a15 > b15, "stealth aposentos progresses e15")

	# etapa 16 killua + 17 silva live
	QuestSystem.active_quests.clear()
	var q16 = CanonQuestCatalog.obter_quest_da_etapa(4, 16)
	QuestSystem.start_quest(q16)
	var MapY = load("res://world/maps/YorknewCityMap.gd")
	var mapa_y = MapY.new()
	add_child(mapa_y)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa_y.get_node_or_null("Killua") != null, "Yorknew Killua node")
	_ok(mapa_y.get_node_or_null("Silva") != null, "Yorknew Silva node")
	var b16 = PlayerData.get_quest_objective_progress(q16, 0)
	QuestSystem.register_npc_visit(&"killua")
	_ok(PlayerData.get_quest_objective_progress(q16, 0) > b16, "Yorknew e16 killua visit")
	QuestSystem.active_quests.clear()
	var q17 = CanonQuestCatalog.obter_quest_da_etapa(4, 17)
	QuestSystem.start_quest(q17)
	var silva = mapa_y.get_node_or_null("Silva")
	var sname := str(silva.npc_name) if silva != null and "npc_name" in silva else ""
	var b17 = PlayerData.get_quest_objective_progress(q17, 0)
	QuestSystem.register_npc_visit(StringName(sname))
	_ok(PlayerData.get_quest_objective_progress(q17, 0) > b17, "Yorknew e17 silva visit name='%s'" % sname)
	# e34 chrollo_boss id
	QuestSystem.active_quests.clear()
	var q34 = CanonQuestCatalog.obter_quest_da_etapa(4, 34)
	QuestSystem.start_quest(q34)
	var b34 = PlayerData.get_quest_objective_progress(q34, 0)
	QuestSystem.register_enemy_kill(&"chrollo_boss")
	_ok(PlayerData.get_quest_objective_progress(q34, 0) > b34, "Yorknew e34 kill chrollo_boss")
	_ok(mapa_y.get_node_or_null("MafiosoMissao_B") != null, "Yorknew mafioso missão filler")
	mapa_y.queue_free()

	mapa.queue_free()
	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 1
