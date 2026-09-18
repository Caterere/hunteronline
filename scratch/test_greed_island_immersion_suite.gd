extends Node

# ============================================================
# HUNTER ONLINE — Greed Island imersão (densidade + clues canônicos)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 GREED ISLAND IMMERSION SUITE")
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
	print("\n[1] Canon GI early ORDEM...")
	CanonQuestCatalog._quest_cache.clear()
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(5, 1)
	var q3 = CanonQuestCatalog.obter_quest_da_etapa(5, 3)
	var q6 = CanonQuestCatalog.obter_quest_da_etapa(5, 6)
	var q16 = CanonQuestCatalog.obter_quest_da_etapa(5, 16)
	var q30 = CanonQuestCatalog.obter_quest_da_etapa(5, 30)
	_ok(q1 != null and "ORDEM" in q1.description, "etapa1 ORDEM")
	_ok(q3 != null and q3.objectives[0].target_clue_id == &"livro_greed", "etapa3 livro_greed")
	_ok("ORDEM" in q3.description and "[G]" in q3.description, "etapa3 descrição Gyo")
	_ok(q6 != null and q6.objectives[0].target_clue_id == &"desfiladeiro_biscuit", "etapa6 desfiladeiro")
	_ok(q16 != null and q16.objectives[0].target_clue_id == &"explosao_bomber", "etapa16 bomber")
	_ok(q30 != null and q30.objectives[0].target_zone_id == &"armadilha_cova_gon", "etapa30 cova stealth")
	var obj = QuestObjective.new()
	obj.type = QuestObjective.Type.INVESTIGATE
	obj.target_clue_id = &"livro_greed"
	_ok("Spell Book" in obj.describe(), "describe livro_greed")


func _test_map_density() -> void:
	print("\n[2] GreedIslandMap densificação...")
	var MapScript = load("res://world/maps/GreedIslandMap.gd")
	_ok(MapScript != null, "GreedIslandMap.gd carrega")
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	var mapa_off = MapScript.new()
	mapa_off.name = "GIDensityOff"
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_off.get_node_or_null("Battera") != null, "Battera presente")
	_ok(mapa_off.get_node_or_null("Biscuit") != null, "Biscuit presente")
	_ok(mapa_off.get_node_or_null("MonstroAmbient_A") != null, "Filler monstro A")
	_ok(mapa_off.get_node_or_null("GolemAmbient_A") != null, "Filler golem A")
	_ok(mapa_off.get_node_or_null("JogadorNovatoA") != null, "Walker novato")
	_ok(mapa_off.get_node_or_null("PropsEstruturaGreed") != null, "Props estrutura")
	_ok(mapa_off.get_node_or_null("PlacaGIAntokiba") != null, "Placa Antokiba")
	_ok(mapa_off.get_node_or_null("PlacaGIDesfiladeiro") != null, "Placa Desfiladeiro")
	_ok(mapa_off.get_node_or_null("ZetsuColinasAntokiba") != null, "Zetsu colinas")
	_ok(mapa_off.get_node_or_null("ZetsuArmadilhaCovaGon") != null, "Zetsu cova Gon")
	_ok(mapa_off.get_node_or_null("GyoLivroGreed") == null, "Sem Gyo pré-despertar")

	var battera = mapa_off.get_node_or_null("Battera")
	var fala_b := ""
	if battera != null and "fala_padrao" in battera:
		fala_b = str(battera.fala_padrao)
	_ok("ORDEM" in fala_b and "Antokiba" in fala_b, "Battera fala direta")

	mapa_off.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_on = MapScript.new()
	mapa_on.name = "GIDensityOn"
	add_child(mapa_on)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_on.get_node_or_null("GyoLivroGreed") != null, "Gyo livro_greed")
	_ok(mapa_on.get_node_or_null("GyoDesfiladeiroBiscuit") != null, "Gyo desfiladeiro_biscuit")
	_ok(mapa_on.get_node_or_null("GyoExplosaoBomber") != null, "Gyo explosao_bomber")
	_ok(mapa_on.get_node_or_null("GyoQuiz100Cartas") != null, "Gyo quiz_100_cartas")
	_ok(mapa_on.get_node_or_null("KoRochaDesfiladeiro") != null, "Ko desfiladeiro")
	var biscuit = mapa_on.get_node_or_null("Biscuit")
	var fala_bi := ""
	if biscuit != null and "fala_padrao" in biscuit:
		fala_bi = str(biscuit.fala_padrao)
	_ok("ORDEM" in fala_bi and "[KO]" in fala_bi, "Biscuit fala direta")

	mapa_on.queue_free()
	PlayerData.despertou_nen = false
