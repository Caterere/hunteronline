extends Node

# ============================================================
# HUNTER ONLINE — Continente Negro imersão (arco 8)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 CONTINENTE NEGRO IMMERSION SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_canon_ordem()
	await _test_map_density()
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


func _test_canon_ordem() -> void:
	print("\n[1] Canon Continente Negro ORDEM...")
	CanonQuestCatalog._quest_cache.clear()
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(8, 1)
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(8, 4)
	var q5 = CanonQuestCatalog.obter_quest_da_etapa(8, 5)
	var q6 = CanonQuestCatalog.obter_quest_da_etapa(8, 6)
	var q8 = CanonQuestCatalog.obter_quest_da_etapa(8, 8)
	var q11 = CanonQuestCatalog.obter_quest_da_etapa(8, 11)
	var q15 = CanonQuestCatalog.obter_quest_da_etapa(8, 15)
	var q18 = CanonQuestCatalog.obter_quest_da_etapa(8, 18)
	var q21 = CanonQuestCatalog.obter_quest_da_etapa(8, 21)
	var q22 = CanonQuestCatalog.obter_quest_da_etapa(8, 22)
	_ok(q1 != null and "ORDEM" in q1.description, "etapa1 ORDEM")
	_ok(q4 != null and q4.objectives[0].type == QuestObjective.Type.PERSUASION, "etapa4 persuasion Ging")
	_ok(q5 != null and q5.objectives[0].target_clue_id == &"mapa_lago_mobius", "etapa5 mapa_lago")
	_ok("ORDEM" in q5.description and "[G]" in q5.description, "etapa5 descrição Gyo")
	_ok(q6 != null and q6.objectives[0].target_zone_id == &"aguas_proibidas", "etapa6 águas stealth")
	_ok(q8 != null and q8.objectives[0].target_clue_id == &"ruinas_botanicas", "etapa8 ruínas")
	_ok(q11 != null and q11.objectives[0].target_zone_id == &"caverna_hellbell", "etapa11 hellbell stealth")
	_ok(q15 != null and "ORDEM" in q15.description and q15.objectives[0].target_npc_id == &"arvore_mundo", "etapa15 árvore")
	_ok(q18 != null and q18.objectives[0].target_npc_id == &"ging_topo", "etapa18 ging_topo")
	_ok(q21 != null and q21.objectives[0].target_clue_id == &"horizonte_infinito", "etapa21 horizonte")
	_ok(q22 != null and "ORDEM" in q22.description and "Portal" in q22.description, "etapa22 convite")
	var obj = QuestObjective.new()
	obj.type = QuestObjective.Type.INVESTIGATE
	obj.target_clue_id = &"mapa_lago_mobius"
	_ok("Mobius" in obj.describe() or "Lago" in obj.describe(), "describe mapa_lago")
	obj.type = QuestObjective.Type.STEALTH_PASS
	obj.target_zone_id = &"aguas_proibidas"
	_ok("Águas" in obj.describe() or "Aguas" in obj.describe() or "Proibidas" in obj.describe(), "describe águas")


func _test_map_density() -> void:
	print("\n[2] ContinenteNegroMap densificação...")
	var MapScript = load("res://world/maps/ContinenteNegroMap.gd")
	_ok(MapScript != null, "ContinenteNegroMap.gd carrega")
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 8
	var mapa_off = MapScript.new()
	mapa_off.name = "CNDensityOff"
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_off.get_node_or_null("Beyond") != null, "Beyond presente")
	_ok(mapa_off.get_node_or_null("Cheadle") != null, "Cheadle presente")
	_ok(mapa_off.get_node_or_null("Ging") != null, "Ging presente")
	_ok(mapa_off.get_node_or_null("ArvoreMundo") != null, "Árvore presente")
	_ok(mapa_off.get_node_or_null("GingTopo") != null, "GingTopo presente")
	_ok(mapa_off.get_node_or_null("BrionMissao_B") != null, "Brion missão B")
	_ok(mapa_off.get_node_or_null("FeraAlada_A") != null, "Fera alada A")
	_ok(mapa_off.get_node_or_null("MercenarioExpedicao") != null, "Walker mercenário")
	_ok(mapa_off.get_node_or_null("BotanicoRuinas") != null, "Walker botânico")
	_ok(mapa_off.get_node_or_null("ObservadorTopo") != null, "Walker topo")
	_ok(mapa_off.get_node_or_null("PropsEstruturaContinente") != null, "Props estrutura")
	_ok(mapa_off.get_node_or_null("PlacaCNAcampamento") != null, "Placa Acampamento")
	_ok(mapa_off.get_node_or_null("PlacaCNRuinas") != null, "Placa Ruínas")
	_ok(mapa_off.get_node_or_null("ZetsuAguasProibidas") != null, "Zetsu águas")
	_ok(mapa_off.get_node_or_null("ZetsuCavernaHellbell") != null, "Zetsu hellbell")
	_ok(mapa_off.get_node_or_null("GyoMapaLagoMobius") == null, "Sem Gyo pré-despertar")

	var beyond = mapa_off.get_node_or_null("Beyond")
	var fala_b := ""
	if beyond != null and "fala_padrao" in beyond:
		fala_b = str(beyond.fala_padrao)
	_ok("ORDEM" in fala_b and "Ging" in fala_b, "Beyond fala direta")

	var ging_topo = mapa_off.get_node_or_null("GingTopo")
	var nome_gt := ""
	var fala_gt := ""
	if ging_topo != null:
		if "npc_name" in ging_topo:
			nome_gt = str(ging_topo.npc_name)
		if "fala_padrao" in ging_topo:
			fala_gt = str(ging_topo.fala_padrao)
	_ok("Topo" in nome_gt and "ORDEM" in fala_gt, "GingTopo id/fala")

	var marcos: Dictionary = mapa_off._marcos_notificados
	_ok(marcos.has("costa") and marcos.has("ruinas") and marcos.has("topo"), "Marcos costa/ruínas/topo")

	mapa_off.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_on = MapScript.new()
	mapa_on.name = "CNDensityOn"
	add_child(mapa_on)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_on.get_node_or_null("GyoMapaLagoMobius") != null, "Gyo mapa_lago")
	_ok(mapa_on.get_node_or_null("GyoRuinasBotanicas") != null, "Gyo ruínas")
	_ok(mapa_on.get_node_or_null("GyoHorizonteInfinito") != null, "Gyo horizonte")
	_ok(mapa_on.get_node_or_null("KoRaizSelada") != null, "Ko raiz")
	var ging = mapa_on.get_node_or_null("Ging")
	var fala_g := ""
	if ging != null and "fala_padrao" in ging:
		fala_g = str(ging.fala_padrao)
	_ok("ORDEM" in fala_g and "Mobius" in fala_g, "Ging fala direta")

	mapa_on.queue_free()
	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 1
