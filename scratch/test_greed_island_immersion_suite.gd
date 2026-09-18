extends Node

# ============================================================
# HUNTER ONLINE — Greed Island imersão (early + mid/late)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 GREED ISLAND IMMERSION SUITE (early + mid/late)")
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
	print("\n[1] Canon GI ORDEM early + mid/late...")
	CanonQuestCatalog._quest_cache.clear()
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(5, 1)
	var q3 = CanonQuestCatalog.obter_quest_da_etapa(5, 3)
	var q6 = CanonQuestCatalog.obter_quest_da_etapa(5, 6)
	var q9 = CanonQuestCatalog.obter_quest_da_etapa(5, 9)
	var q13 = CanonQuestCatalog.obter_quest_da_etapa(5, 13)
	var q16 = CanonQuestCatalog.obter_quest_da_etapa(5, 16)
	var q18 = CanonQuestCatalog.obter_quest_da_etapa(5, 18)
	var q21 = CanonQuestCatalog.obter_quest_da_etapa(5, 21)
	var q30 = CanonQuestCatalog.obter_quest_da_etapa(5, 30)
	var q33 = CanonQuestCatalog.obter_quest_da_etapa(5, 33)
	var q36 = CanonQuestCatalog.obter_quest_da_etapa(5, 36)
	_ok(q1 != null and "ORDEM" in q1.description, "etapa1 ORDEM")
	_ok(q3 != null and q3.objectives[0].target_clue_id == &"livro_greed", "etapa3 livro_greed")
	_ok("ORDEM" in q3.description and "[G]" in q3.description, "etapa3 descrição Gyo")
	_ok(q6 != null and q6.objectives[0].target_clue_id == &"desfiladeiro_biscuit", "etapa6 desfiladeiro")
	_ok(q9 != null and "ORDEM" in q9.description and "Shu" in q9.description, "etapa9 Shu ORDEM")
	_ok(q13 != null and "ORDEM" in q13.description and q13.objectives[0].target_npc_id == &"killua", "etapa13 Killua ORDEM")
	_ok(q16 != null and q16.objectives[0].target_clue_id == &"explosao_bomber", "etapa16 bomber")
	_ok(q18 != null and "ORDEM" in q18.description and q18.objectives[0].target_npc_id == &"hisoka", "etapa18 Hisoka ORDEM")
	_ok(q21 != null and "ORDEM" in q21.description and q21.objectives[0].enemy_type == &"demonio_razor", "etapa21 demônios ORDEM")
	_ok(q30 != null and q30.objectives[0].target_zone_id == &"armadilha_cova_gon", "etapa30 cova stealth")
	_ok(q33 != null and "ORDEM" in q33.description and "[G]" in q33.description, "etapa33 quiz ORDEM")
	_ok(q36 != null and "ORDEM" in q36.description and "Accompany" in q36.description, "etapa36 Accompany ORDEM")
	var obj = QuestObjective.new()
	obj.type = QuestObjective.Type.INVESTIGATE
	obj.target_clue_id = &"livro_greed"
	_ok("Spell Book" in obj.describe(), "describe livro_greed")
	obj.target_clue_id = &"ginasio_razor"
	_ok("Ginásio" in obj.describe(), "describe ginasio_razor")


func _test_map_density() -> void:
	print("\n[2] GreedIslandMap densificação early + mid/late...")
	var MapScript = load("res://world/maps/GreedIslandMap.gd")
	_ok(MapScript != null, "GreedIslandMap.gd carrega")
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 5
	var mapa_off = MapScript.new()
	mapa_off.name = "GIDensityOff"
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_off.get_node_or_null("Battera") != null, "Battera presente")
	_ok(mapa_off.get_node_or_null("Biscuit") != null, "Biscuit presente")
	_ok(mapa_off.get_node_or_null("Killua") != null, "Killua mid presente")
	_ok(mapa_off.get_node_or_null("Hisoka") != null, "Hisoka mid presente")
	_ok(mapa_off.get_node_or_null("Tsezguerra") != null, "Tsezguerra presente")
	_ok(mapa_off.get_node_or_null("MonstroAmbient_A") != null, "Filler monstro A")
	_ok(mapa_off.get_node_or_null("GolemAmbient_A") != null, "Filler golem A")
	_ok(mapa_off.get_node_or_null("DemonioMissao_B") != null, "Demônio missão B")
	_ok(mapa_off.get_node_or_null("GolemMissao_B") != null, "Golem missão B")
	_ok(mapa_off.get_node_or_null("JogadorNovatoA") != null, "Walker novato")
	_ok(mapa_off.get_node_or_null("AliadoTsez") != null, "Walker aliança")
	_ok(mapa_off.get_node_or_null("ScoutBomberTrail") != null, "Walker bomber")
	_ok(mapa_off.get_node_or_null("PropsEstruturaGreed") != null, "Props estrutura")
	_ok(mapa_off.get_node_or_null("PlacaGIAntokiba") != null, "Placa Antokiba")
	_ok(mapa_off.get_node_or_null("PlacaGIDesfiladeiro") != null, "Placa Desfiladeiro")
	_ok(mapa_off.get_node_or_null("PlacaGIBomber") != null, "Placa Bomber")
	_ok(mapa_off.get_node_or_null("PlacaGIAlianca") != null, "Placa Aliança")
	_ok(mapa_off.get_node_or_null("ZetsuColinasAntokiba") != null, "Zetsu colinas")
	_ok(mapa_off.get_node_or_null("ZetsuArmadilhaCovaGon") != null, "Zetsu cova Gon")
	_ok(mapa_off.get_node_or_null("ZetsuGinasioVestibulo") != null, "Zetsu ginásio")
	_ok(mapa_off.get_node_or_null("GyoLivroGreed") == null, "Sem Gyo pré-despertar")

	var battera = mapa_off.get_node_or_null("Battera")
	var fala_b := ""
	if battera != null and "fala_padrao" in battera:
		fala_b = str(battera.fala_padrao)
	_ok("ORDEM" in fala_b and "Antokiba" in fala_b, "Battera fala direta")

	var razor = mapa_off.get_node_or_null("Razor")
	var fala_r := ""
	if razor != null and "fala_padrao" in razor:
		fala_r = str(razor.fala_padrao)
	_ok("ORDEM" in fala_r and "002" in fala_r, "Razor fala mid/late")

	var marcos: Dictionary = mapa_off._marcos_notificados
	_ok(marcos.has("ginasio") and marcos.has("bomber") and marcos.has("alianca"), "Marcos mid/late (ginasio/bomber/aliança)")

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
	_ok(mapa_on.get_node_or_null("GyoPortoSoufrabi") != null, "Gyo porto_soufrabi")
	_ok(mapa_on.get_node_or_null("GyoGinasioRazor") != null, "Gyo ginasio_razor")
	_ok(mapa_on.get_node_or_null("GyoCarta002") != null, "Gyo carta_002")
	_ok(mapa_on.get_node_or_null("GyoSoproArcanjo") != null, "Gyo sopro_arcanjo")
	_ok(mapa_on.get_node_or_null("GyoQuiz100Cartas") != null, "Gyo quiz_100_cartas")
	_ok(mapa_on.get_node_or_null("KoRochaDesfiladeiro") != null, "Ko desfiladeiro")
	_ok(mapa_on.get_node_or_null("KoRochaBomber") != null, "Ko bomber mid/late")
	var biscuit = mapa_on.get_node_or_null("Biscuit")
	var fala_bi := ""
	if biscuit != null and "fala_padrao" in biscuit:
		fala_bi = str(biscuit.fala_padrao)
	_ok("ORDEM" in fala_bi and "[KO]" in fala_bi, "Biscuit fala direta")
	var killua = mapa_on.get_node_or_null("Killua")
	var fala_k := ""
	if killua != null and "fala_padrao" in killua:
		fala_k = str(killua.fala_padrao)
	_ok("ORDEM" in fala_k and "Cova" in fala_k, "Killua fala mid/late")

	mapa_on.queue_free()
	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 1
