extends Node

# ============================================================
# HUNTER ONLINE — Nen no mundo: Floresta + Ruínas (Trilha B)
# Sensores densos + quests investigativas Gyo/Ko/Zetsu
# ============================================================

const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 NEN NO MUNDO — FLORESTA + RUÍNAS (TRILHA B)")
	print("================================================================================")
	await get_tree().process_frame
	_test_catalog_quests()
	_test_objective_describe()
	_test_factory_and_ko_clue()
	await _test_floresta_runtime()
	await _test_ruinas_runtime()
	await _test_floresta_quest_flow()
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


func _test_catalog_quests() -> void:
	print("\n[1] Catálogo Padokia — quests investigativas...")
	var qf = PadokiaQuestCatalogScript.obter_quest_investigacao_floresta()
	_ok(qf != null and qf.objectives.size() == 4, "Floresta: 4 objetivos")
	_ok(qf.objectives[0].type == QuestObjective.Type.VISIT, "Floresta obj0 VISIT herbalista")
	_ok(qf.objectives[1].type == QuestObjective.Type.INVESTIGATE \
		and qf.objectives[1].target_clue_id == &"floresta_aura_raizes", "Floresta Gyo raízes")
	_ok(qf.objectives[2].target_clue_id == &"floresta_pegadas_fera", "Floresta Gyo pegadas")
	_ok(qf.objectives[3].type == QuestObjective.Type.STEALTH_PASS \
		and qf.objectives[3].target_zone_id == &"acampamento_salteadores_norte", "Floresta Zetsu norte")
	_ok("ORDEM" in qf.description and "[G]" in qf.description, "Floresta descrição direta")

	var qr = PadokiaQuestCatalogScript.obter_quest_investigacao_ruinas()
	_ok(qr != null and qr.objectives.size() == 5, "Ruínas: 5 objetivos")
	_ok(qr.objectives[0].target_npc_id == &"guia_ruinas", "Ruínas VISIT guia")
	_ok(qr.objectives[1].target_clue_id == &"zaban_selo_antecamara", "Ruínas Gyo selo")
	_ok(qr.objectives[2].target_clue_id == &"zaban_fissura_aura", "Ruínas Gyo fissura")
	_ok(qr.objectives[3].type == QuestObjective.Type.STEALTH_PASS, "Ruínas Zetsu corredor")
	_ok(qr.objectives[4].target_clue_id == &"zaban_pilar_ko", "Ruínas KO pilar")

	var todas = PadokiaQuestCatalogScript.obter_todas_quests()
	_ok(todas.size() >= 10, "Catálogo >= 10 quests (%d)" % todas.size())


func _test_objective_describe() -> void:
	print("\n[2] QuestObjective.describe legível...")
	var obj = QuestObjective.new()
	obj.type = QuestObjective.Type.INVESTIGATE
	obj.target_clue_id = &"floresta_aura_raizes"
	_ok("[G]" in obj.describe() and "Raízes" in obj.describe(), "describe raízes")
	obj.target_clue_id = &"zaban_pilar_ko"
	_ok("[KO]" in obj.describe(), "describe KO pilar")
	obj.type = QuestObjective.Type.STEALTH_PASS
	obj.target_zone_id = &"acampamento_salteadores_norte"
	_ok("[Z]" in obj.describe() and "Acampamento" in obj.describe(), "describe zetsu norte")


func _test_factory_and_ko_clue() -> void:
	print("\n[3] Factory props + Ko clue_id_on_break...")
	var factory_src := FileAccess.get_file_as_string("res://world/components/exploration/NenSensorFactory.gd")
	_ok("nen_stone_monolith" in factory_src or "phase2_rock" in factory_src, "Factory usa props reais")
	_ok("clue_id_on_break" in factory_src, "Factory passa clue_id_on_break")
	var ko_src := FileAccess.get_file_as_string("res://world/components/exploration/KoObstacle.gd")
	_ok("clue_id_on_break" in ko_src and "register_investigation" in ko_src, "KoObstacle registra investigação")

	var ko := KoObstacle.new()
	ko.name = "KoSmokeClue"
	ko.clue_id_on_break = &"zaban_pilar_ko"
	ko.obstacle_name = "Teste"
	add_child(ko)
	_ok(ko.clue_id_on_break == &"zaban_pilar_ko", "Ko export clue setável")
	ko.queue_free()


func _test_floresta_runtime() -> void:
	print("\n[4] Floresta runtime densificação...")
	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 2
	var MapScript = load("res://world/maps/FlorestaVestigiosMap.gd")
	_ok(MapScript != null, "FlorestaVestigiosMap.gd carrega")
	if MapScript == null:
		return
	var mapa = MapScript.new()
	mapa.name = "FlorestaNenWorld"
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa.get_node_or_null("HerbalistaFloresta") != null, "Herbalista NPC presente")
	_ok(mapa.get_node_or_null("GyoClueArvoreRaizes") != null, "Gyo raízes")
	_ok(mapa.get_node_or_null("GyoCluePegadasSul") != null, "Gyo pegadas")
	_ok(mapa.get_node_or_null("GyoClueFonteOculta") != null, "Gyo fonte extra")
	_ok(mapa.get_node_or_null("GyoClueTrilhaRuinas") != null, "Gyo trilha ruínas")
	_ok(mapa.get_node_or_null("ZetsuAcampamentoNorte") != null, "Zetsu norte")
	_ok(mapa.get_node_or_null("ZetsuTrilhaSul") != null, "Zetsu trilha sul")
	_ok(mapa.get_node_or_null("KoObstacleAtalhoOeste") != null, "Ko atalho oeste")
	_ok(mapa.get_node_or_null("KoObstacleClareiraSul") != null, "Ko clareira sul")

	var ko_oeste = mapa.get_node_or_null("KoObstacleAtalhoOeste") as KoObstacle
	_ok(ko_oeste != null and ko_oeste.clue_id_on_break == &"floresta_ko_atalho", "Ko oeste tem clue")

	var herb = mapa.get_node_or_null("HerbalistaFloresta")
	if herb != null and "fala_padrao" in herb:
		_ok("[G]" in str(herb.fala_padrao) and "Zetsu" in str(herb.fala_padrao), "Herbalista fala direta")
	else:
		_ok(false, "Herbalista fala direta")

	# Quest auto-start pós-despertar
	var q = PadokiaQuestCatalogScript.obter_quest_investigacao_floresta()
	_ok(PlayerData.is_quest_active(q), "Quest floresta ativa após mapa")

	mapa.queue_free()
	await get_tree().process_frame


func _test_ruinas_runtime() -> void:
	print("\n[5] Ruínas runtime densificação...")
	PlayerData.despertou_nen = true
	# Limpa quest residual
	var qr_clear = PadokiaQuestCatalogScript.obter_quest_investigacao_ruinas()
	if PlayerData.has_method("_get_quest_id"):
		PlayerData.quest_states.erase(PlayerData._get_quest_id(qr_clear))
	if QuestSystem != null:
		for aq in QuestSystem.active_quests.duplicate():
			if aq != null and aq.quest_name == qr_clear.quest_name:
				QuestSystem.active_quests.erase(aq)

	var MapScript = load("res://world/maps/DungeonRuinasZabanMap.gd")
	_ok(MapScript != null, "DungeonRuinasZabanMap.gd carrega")
	if MapScript == null:
		return
	var mapa = MapScript.new()
	mapa.name = "RuinasNenWorld"
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa.get_node_or_null("GuiaRuinas") != null, "Guia das Ruínas presente")
	_ok(mapa.get_node_or_null("GyoClueAntecâmara") != null, "Gyo antecâmara")
	_ok(mapa.get_node_or_null("GyoClueCamaraBoss") != null, "Gyo câmara")
	_ok(mapa.get_node_or_null("GyoCluePortaoEntrada") != null, "Gyo portão")
	_ok(mapa.get_node_or_null("ZetsuCorredorSentinelas") != null, "Zetsu corredor")
	_ok(mapa.get_node_or_null("ZetsuCamaraLateral") != null, "Zetsu câmara lateral")
	var ko = mapa.get_node_or_null("KoObstacleCamaraLateral") as KoObstacle
	_ok(ko != null and ko.clue_id_on_break == &"zaban_pilar_ko", "Ko pilar com clue quest")

	var guia = mapa.get_node_or_null("GuiaRuinas")
	if guia != null and "fala_padrao" in guia:
		_ok("[KO]" in str(guia.fala_padrao) and "[G]" in str(guia.fala_padrao), "Guia fala direta")
	else:
		_ok(false, "Guia fala direta")

	var qr = PadokiaQuestCatalogScript.obter_quest_investigacao_ruinas()
	_ok(PlayerData.is_quest_active(qr), "Quest ruínas ativa após mapa")

	mapa.queue_free()
	await get_tree().process_frame


func _test_floresta_quest_flow() -> void:
	print("\n[6] Fluxo investigativo Floresta (VISIT → Gyo → Gyo → Zetsu)...")
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
	PlayerData.quest_states.clear()
	PlayerData.segredos_descobertos.clear()
	PlayerData.despertou_nen = true

	var q = PadokiaQuestCatalogScript.obter_quest_investigacao_floresta()
	QuestSystem.start_quest(q)
	_ok(PlayerData.is_quest_active(q), "Quest iniciada limpa")

	# Antes do VISIT, Gyo não deve avançar objetivo ativo (ainda é VISIT)
	QuestSystem.register_investigation(&"floresta_aura_raizes")
	_ok(PlayerData.get_quest_objective_progress(q, 1) == 0, "Gyo bloqueado até VISIT")

	QuestSystem.register_npc_visit(&"herbalista")
	_ok(PlayerData.get_quest_objective_progress(q, 0) >= 1, "VISIT herbalista ok")

	QuestSystem.register_investigation(&"floresta_aura_raizes")
	_ok(PlayerData.get_quest_objective_progress(q, 1) >= 1, "Gyo raízes ok")

	QuestSystem.register_investigation(&"floresta_pegadas_fera")
	_ok(PlayerData.get_quest_objective_progress(q, 2) >= 1, "Gyo pegadas ok")

	QuestSystem.register_stealth_pass(&"acampamento_salteadores_norte")
	_ok(PlayerData.get_quest_objective_progress(q, 3) >= 1, "Zetsu norte ok")

	# Ruínas KO clue
	var qr = PadokiaQuestCatalogScript.obter_quest_investigacao_ruinas()
	QuestSystem.start_quest(qr)
	QuestSystem.register_npc_visit(&"guia_ruinas")
	QuestSystem.register_investigation(&"zaban_selo_antecamara")
	QuestSystem.register_investigation(&"zaban_fissura_aura")
	QuestSystem.register_stealth_pass(&"zaban_corredor_sentinelas")
	QuestSystem.register_investigation(&"zaban_pilar_ko")
	_ok(PlayerData.get_quest_objective_progress(qr, 4) >= 1, "KO pilar registra investigação")
