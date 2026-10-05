extends Node

# ============================================================
# HUNTER ONLINE — Steam Early Density (Exame→Ruínas) + ABC
# Valida tutorial 3-beat, sensores, loot, HatsuMoment, cutscenes,
# ORDEM secundárias e EnemyData/bioma.
# ============================================================

const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 STEAM EARLY DENSITY — TUTORIAL 3-BEAT + MAPAS + ABC")
	print("================================================================================")
	await get_tree().process_frame
	_test_catalog_tutorial()
	_test_economy_consumables()
	await _test_vale_runtime()
	await _test_estrada_runtime()
	await _test_floresta_runtime()
	await _test_ruinas_runtime()
	_test_abc_catalog_and_cutscenes()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	if not _failures.is_empty():
		for f in _failures:
			print("   ❌ ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)


func _test_catalog_tutorial() -> void:
	print("\n[1] Catálogo — Três Batidas de Nen...")
	var q = PadokiaQuestCatalogScript.obter_quest_tutorial_nen_tres_beats()
	_ok(q != null and q.objectives.size() == 4, "Tutorial: 4 objetivos")
	_ok(q.objectives[0].type == QuestObjective.Type.VISIT, "obj0 VISIT wing")
	_ok(q.objectives[1].type == QuestObjective.Type.INVESTIGATE \
		and q.objectives[1].target_clue_id == &"tutorial_nen_gyo_moinho", "obj1 Gyo moinho")
	_ok(q.objectives[2].type == QuestObjective.Type.STEALTH_PASS \
		and q.objectives[2].target_zone_id == &"vale_beco_salteadores", "obj2 Zetsu beco")
	_ok(q.objectives[3].type == QuestObjective.Type.INVESTIGATE \
		and q.objectives[3].target_clue_id == &"tutorial_nen_ko_atalho", "obj3 KO atalho")
	_ok("ORDEM" in q.description and "[G]" in q.description and "[Z]" in q.description \
		and "[KO]" in q.description, "descrição mentor direto")
	var todas = PadokiaQuestCatalogScript.obter_todas_quests()
	_ok(todas.size() >= 11, "Catálogo >= 11 quests (%d)" % todas.size())
	var nomes: PackedStringArray = []
	for qq in todas:
		nomes.append(qq.quest_name)
	_ok("Três Batidas de Nen" in nomes, "tutorial na lista completa")


func _test_economy_consumables() -> void:
	print("\n[2] Economia — Pedra de Aura / Erva (sem poção clássica no catálogo)...")
	_ok(Economy != null and Economy.ITEM_CATALOGO.has("pedra_aura"), "pedra_aura no catálogo")
	_ok(Economy.ITEM_CATALOGO.has("erva_nen"), "erva_nen no catálogo")
	_ok(Economy.ITEM_CATALOGO.has("cristal_aura"), "cristal_aura no catálogo")
	_ok(not Economy.ITEM_CATALOGO.has("pocao_vida"), "pocao_vida NÃO no catálogo loja")


func _test_vale_runtime() -> void:
	print("\n[3] Vale Padokia runtime...")
	if PlayerData != null:
		PlayerData.despertou_nen = true
	var scn = load("res://world/maps/regiao_vale_padokia.tscn")
	_ok(scn != null, "cena vale carrega")
	if scn == null:
		return
	var map = scn.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(map.get_node_or_null("PistaValeMoinho") != null or map.find_child("PistaValeMoinho", true, false) != null, "Gyo moinho plantado")
	_ok(map.get_node_or_null("KoObstacleValeAtalho") != null or map.find_child("KoObstacleValeAtalho", true, false) != null, "Ko atalho plantado")
	_ok(map.get_node_or_null("ZetsuValeBecoNorte") != null or map.find_child("ZetsuValeBecoNorte", true, false) != null, "Zetsu beco plantado")
	_ok(map.get_node_or_null("BauVilaExterior") != null or map.find_child("BauVilaExterior", true, false) != null, "Baú vila exterior")
	_ok(map.get_node_or_null("GyoGlifoVilaExterior") != null or map.find_child("GyoGlifoVilaExterior", true, false) != null, "Glifo vila exterior")
	_ok(map.get_node_or_null("HatsuMomentVale") != null or map.find_child("HatsuMomentVale", true, false) != null, "HatsuMoment vale")
	_ok(map.get_node_or_null("CkptValeWing") != null or map.find_child("CkptValeWing", true, false) != null, "Checkpoint Wing")
	var ko = map.find_child("KoObstacleValeAtalho", true, false)
	if ko != null and "clue_id_on_break" in ko:
		_ok(ko.clue_id_on_break == &"tutorial_nen_ko_atalho", "Ko clue_id tutorial")
	else:
		_ok(false, "Ko clue_id tutorial")
	map.queue_free()
	await get_tree().process_frame


func _test_estrada_runtime() -> void:
	print("\n[4] Estrada Padokia runtime...")
	var scn = load("res://world/maps/estrada_padokia.tscn")
	_ok(scn != null, "cena estrada carrega")
	if scn == null:
		return
	var map = scn.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(map.get_node_or_null("ZetsuMataLateralEstrada") != null, "Zetsu mata")
	_ok(map.get_node_or_null("KoObstaclePedregulhoPonte") != null, "Ko ponte")
	_ok(map.get_node_or_null("BauEstradaClareira") != null, "Baú clareira")
	_ok(map.get_node_or_null("AgenteAssociacaoEstrada") != null, "Walker Associação")
	_ok(map.get_node_or_null("ObservadorMafiaEstrada") != null, "Walker Máfia")
	_ok(map.get_node_or_null("PlacaDisputaRota") != null, "Placa disputa social")
	_ok(map.get_node_or_null("HatsuMomentEstrada") != null, "HatsuMoment estrada")
	map.queue_free()
	await get_tree().process_frame


func _test_floresta_runtime() -> void:
	print("\n[5] Floresta Vestígios runtime...")
	if PlayerData != null:
		PlayerData.despertou_nen = true
	var scn = load("res://world/maps/floresta_vestigios.tscn")
	_ok(scn != null, "cena floresta carrega")
	if scn == null:
		return
	var map = scn.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().process_frame
	var gyo_count := 0
	for c in map.get_children():
		if c is GyoInspectable or str(c.name).begins_with("Gyo"):
			gyo_count += 1
	_ok(gyo_count >= 8, "Floresta Gyo >= 8 (%d)" % gyo_count)
	_ok(map.get_node_or_null("GyoClueNinhoProfundo") != null, "Gyo ninho profundo")
	_ok(map.get_node_or_null("ZetsuNinhoProfundo") != null, "Zetsu ninho profundo")
	_ok(map.get_node_or_null("BauFlorestaProfunda") != null, "Baú floresta profunda")
	_ok(map.get_node_or_null("KoObstacleNinhoProfundo") != null, "Ko ninho")
	_ok(map.get_node_or_null("AlfaNinhoElite") != null, "Elite Nen puzzle Alfa")
	_ok(map.get_node_or_null("GyoClueEliteNinho") != null, "Gyo fraqueza elite")
	_ok(map.get_node_or_null("HatsuMomentFloresta") != null, "HatsuMoment floresta")
	_ok(map.get_node_or_null("CkptFlorestaNinho") != null, "Checkpoint ninho")
	map.queue_free()
	await get_tree().process_frame


func _test_ruinas_runtime() -> void:
	print("\n[6] Ruínas Zaban runtime...")
	if PlayerData != null:
		PlayerData.despertou_nen = true
	var scn = load("res://world/maps/dungeon_ruinas_zaban.tscn")
	_ok(scn != null, "cena ruínas carrega")
	if scn == null:
		return
	var map = scn.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(map.get_node_or_null("GyoCluePortaoEntrada") != null, "Gyo portão entrada")
	_ok(map.get_node_or_null("KoObstacleAntecâmara") != null, "Ko antecâmara")
	var ko = map.get_node_or_null("KoObstacleAntecâmara")
	if ko != null and "clue_id_on_break" in ko:
		_ok(ko.clue_id_on_break == &"zaban_ko_antecamara", "Ko antecâmara tem clue")
	else:
		_ok(false, "Ko antecâmara tem clue")
	_ok(map.get_node_or_null("ZetsuCorredorSentinelas") != null, "Zetsu corredor")
	_ok(map.get_node_or_null("HatsuMomentRuinas") != null, "HatsuMoment ruínas")
	_ok(map.get_node_or_null("CkptRuinasBoss") != null, "Checkpoint pré-guardião")
	map.queue_free()
	await get_tree().process_frame


func _test_abc_catalog_and_cutscenes() -> void:
	print("\n[7] ABC — ORDEM secundárias + cutscenes early...")
	var s1 = PadokiaQuestCatalogScript.obter_quest_secundaria_1()
	_ok(s1 != null and "ORDEM" in s1.description, "secundária 1 ORDEM")
	_ok(s1.objectives.size() >= 2, "secundária 1 com VISIT+KILL")
	var s2 = PadokiaQuestCatalogScript.obter_quest_secundaria_2()
	_ok(s2 != null and "ORDEM" in s2.description, "secundária 2 ORDEM")
	var desafio = PadokiaQuestCatalogScript.obter_quest_desafio_ravina()
	_ok(desafio != null and "ORDEM" in desafio.description, "desafio ravina ORDEM")
	var CkptLib = load("res://scripts/cutscenes/CheckpointCutsceneLibrary.gd")
	_ok(CkptLib != null, "CheckpointCutsceneLibrary carrega")
	if CkptLib != null:
		for id in ["exame_largada", "vale_wing_nen", "floresta_ninho", "ruinas_antes_guardiao"]:
			var passos = CkptLib.obter_passos(StringName(id))
			_ok(passos.size() >= 4, "cutscene early %s" % id)
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	_ok(q1 != null and "ORDEM" in q1.description, "Arco1 etapa1 ORDEM")
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(1, 4)
	_ok(q4 != null and "ORDEM" in q4.description, "Arco1 etapa4 ORDEM")
	if DataManager != null:
		var ids := [&"fera_floresta", &"fera_alada", &"lobo_padokia", &"javali_espinhoso", &"lobo_sombras"]
		var ok_count := 0
		for eid in ids:
			if DataManager.get_enemy(eid) != null:
				ok_count += 1
		_ok(ok_count >= 4, "bioma Padokia >=4 EnemyData (%d)" % ok_count)
		var elite = DataManager.get_enemy(&"alfa_ninho_elite")
		_ok(elite != null and elite.is_elite and not str(elite.hatsu_name).is_empty(), "alfa elite com Hatsu")
		var ge = DataManager.get_enemy(&"guardiao_elite")
		_ok(ge != null and not str(ge.hatsu_name).is_empty(), "guardião elite com Hatsu")
	else:
		_ok(false, "DataManager disponível")
