extends Node

# ============================================================
# HUNTER ONLINE — Black Whale / Sucessão imersão (arco 9)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 BLACK WHALE IMMERSION SUITE")
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
	print("\n[1] Canon Black Whale ORDEM...")
	CanonQuestCatalog._quest_cache.clear()
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(9, 1)
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(9, 4)
	var q10 = CanonQuestCatalog.obter_quest_da_etapa(9, 10)
	var q14 = CanonQuestCatalog.obter_quest_da_etapa(9, 14)
	var q15 = CanonQuestCatalog.obter_quest_da_etapa(9, 15)
	var q16 = CanonQuestCatalog.obter_quest_da_etapa(9, 16)
	var q22 = CanonQuestCatalog.obter_quest_da_etapa(9, 22)
	var q26 = CanonQuestCatalog.obter_quest_da_etapa(9, 26)
	_ok(q1 != null and "ORDEM" in q1.description, "etapa1 ORDEM")
	_ok(q4 != null and q4.objectives[0].target_clue_id == &"primeiro_assassinato_kakin", "etapa4 assassinato")
	_ok("ORDEM" in q4.description and "[G]" in q4.description, "etapa4 descrição Gyo")
	_ok(q10 != null and q10.objectives[0].target_clue_id == &"seita_heilly", "etapa10 seita")
	_ok(q14 != null and q14.objectives[0].type == QuestObjective.Type.PERSUASION, "etapa14 persuasion Chrollo")
	_ok(q15 != null and q15.objectives[0].target_zone_id == &"aposentos_tserriednich", "etapa15 stealth")
	_ok("ORDEM" in q15.description and "[Z]" in q15.description, "etapa15 descrição Zetsu")
	_ok(q16 != null and q16.objectives[0].target_clue_id == &"besta_tserriednich", "etapa16 besta")
	_ok(q22 != null and q22.objectives[0].target_npc_id == &"hisoka", "etapa22 hisoka")
	_ok(q26 != null and "ORDEM" in q26.description and "Portal" in q26.description, "etapa26 consagração")
	var obj = QuestObjective.new()
	obj.type = QuestObjective.Type.INVESTIGATE
	obj.target_clue_id = &"primeiro_assassinato_kakin"
	_ok("Assassinato" in obj.describe() or "assassinato" in obj.describe().to_lower(), "describe assassinato")
	obj.target_clue_id = &"seita_heilly"
	_ok("Heil" in obj.describe() or "Seita" in obj.describe(), "describe seita")
	obj.type = QuestObjective.Type.STEALTH_PASS
	obj.target_zone_id = &"aposentos_tserriednich"
	_ok("Tserriednich" in obj.describe() or "Aposentos" in obj.describe(), "describe aposentos")


func _test_map_density() -> void:
	print("\n[2] BlackWhale1Map densificação...")
	var MapScript = load("res://world/maps/BlackWhale1Map.gd")
	_ok(MapScript != null, "BlackWhale1Map.gd carrega")
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 9
	var mapa_off = MapScript.new()
	mapa_off.name = "BWDensityOff"
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_off.get_node_or_null("Kurapika") != null, "Kurapika presente")
	_ok(mapa_off.get_node_or_null("RainhaOito") != null, "RainhaOito presente")
	_ok(mapa_off.get_node_or_null("VasoKakin") != null, "VasoKakin presente")
	_ok(mapa_off.get_node_or_null("Hinrigh") != null, "Hinrigh presente")
	_ok(mapa_off.get_node_or_null("Hisoka") != null, "Hisoka presente")
	_ok(mapa_off.get_node_or_null("Chrollo") != null, "Chrollo presente")
	_ok(mapa_off.get_node_or_null("Cheadle") != null, "Cheadle presente")
	_ok(mapa_off.get_node_or_null("ParasitaMissao_B") != null, "Parasita missão B")
	_ok(mapa_off.get_node_or_null("HeillyMissao_B") != null, "Heil-Ly missão B")
	_ok(mapa_off.get_node_or_null("RevoltaMissao_A") != null, "Revolta missão A")
	_ok(mapa_off.get_node_or_null("GuardaConvés1") != null, "Walker guarda")
	_ok(mapa_off.get_node_or_null("ScoutAposentos") != null, "Walker aposentos")
	_ok(mapa_off.get_node_or_null("OficialComando") != null, "Walker comando")
	_ok(mapa_off.get_node_or_null("PropsEstruturaBlackWhale") != null, "Props estrutura")
	_ok(mapa_off.get_node_or_null("PlacaBWConves1") != null, "Placa Convés 1")
	_ok(mapa_off.get_node_or_null("PlacaBWAposentos") != null, "Placa Aposentos")
	_ok(mapa_off.get_node_or_null("ZetsuAposentosTserriednich") != null, "Zetsu aposentos")
	_ok(mapa_off.get_node_or_null("GyoPrimeiroAssassinato") == null, "Sem Gyo pré-despertar")

	var kura = mapa_off.get_node_or_null("Kurapika")
	var fala_k := ""
	if kura != null and "fala_padrao" in kura:
		fala_k = str(kura.fala_padrao)
	_ok("ORDEM" in fala_k and "Rainha" in fala_k, "Kurapika fala direta")

	var cheadle = mapa_off.get_node_or_null("Cheadle")
	var fala_c := ""
	if cheadle != null and "fala_padrao" in cheadle:
		fala_c = str(cheadle.fala_padrao)
	_ok("ORDEM" in fala_c and ("Consagração" in fala_c or "Portal" in fala_c), "Cheadle fala direta")

	var marcos: Dictionary = mapa_off._marcos_notificados
	_ok(marcos.has("conves_1") and marcos.has("aposentos") and marcos.has("porao"), "Marcos conves/aposentos/porao")

	mapa_off.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_on = MapScript.new()
	mapa_on.name = "BWDensityOn"
	add_child(mapa_on)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_on.get_node_or_null("GyoPrimeiroAssassinato") != null, "Gyo assassinato")
	_ok(mapa_on.get_node_or_null("GyoSeitaHeilLy") != null, "Gyo seita")
	_ok(mapa_on.get_node_or_null("GyoBestaTserriednich") != null, "Gyo besta")
	_ok(mapa_on.get_node_or_null("KoPortaCegada") != null, "Ko porta")
	var hinrigh = mapa_on.get_node_or_null("Hinrigh")
	var fala_h := ""
	if hinrigh != null and "fala_padrao" in hinrigh:
		fala_h = str(hinrigh.fala_padrao)
	_ok("ORDEM" in fala_h and "Heil" in fala_h, "Hinrigh fala direta")

	mapa_on.queue_free()
	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 1
