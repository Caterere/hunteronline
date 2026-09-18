extends Node

# ============================================================
# HUNTER ONLINE — Associação / Alluka imersão (arco 7)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 ASSOCIACAO / ALLUKA IMMERSION SUITE")
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
	print("\n[1] Canon Associação ORDEM...")
	CanonQuestCatalog._quest_cache.clear()
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(7, 1)
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(7, 4)
	var q6 = CanonQuestCatalog.obter_quest_da_etapa(7, 6)
	var q7 = CanonQuestCatalog.obter_quest_da_etapa(7, 7)
	var q10 = CanonQuestCatalog.obter_quest_da_etapa(7, 10)
	var q12 = CanonQuestCatalog.obter_quest_da_etapa(7, 12)
	var q16 = CanonQuestCatalog.obter_quest_da_etapa(7, 16)
	var q17 = CanonQuestCatalog.obter_quest_da_etapa(7, 17)
	var q20 = CanonQuestCatalog.obter_quest_da_etapa(7, 20)
	_ok(q1 != null and "ORDEM" in q1.description, "etapa1 ORDEM")
	_ok(q4 != null and "ORDEM" in q4.description and q4.objectives[0].target_npc_id == &"leorio", "etapa4 Leorio")
	_ok(q6 != null and q6.objectives[0].target_clue_id == &"cela_alluka", "etapa6 cela_alluka")
	_ok("ORDEM" in q6.description and "[G]" in q6.description, "etapa6 descrição Gyo")
	_ok(q7 != null and "ORDEM" in q7.description and q7.objectives[0].target_npc_id == &"alluka", "etapa7 Alluka")
	_ok(q10 != null and "ORDEM" in q10.description and q10.objectives[0].enemy_type == &"mordomo_perseguidor", "etapa10 mordomos")
	_ok(q12 != null and "ORDEM" in q12.description and q12.objectives[0].enemy_type == &"illumi", "etapa12 Illumi")
	_ok(q16 != null and "ORDEM" in q16.description and q16.objectives[0].target_npc_id == &"alluka", "etapa16 milagre")
	_ok(q17 != null and q17.objectives[0].target_npc_id == &"gon_recuperado", "etapa17 gon_recuperado")
	_ok(q20 != null and "ORDEM" in q20.description and "Portal" in q20.description, "etapa20 despedida")
	var obj = QuestObjective.new()
	obj.type = QuestObjective.Type.INVESTIGATE
	obj.target_clue_id = &"cela_alluka"
	_ok("Cela" in obj.describe() or "Alluka" in obj.describe(), "describe cela_alluka")


func _test_map_density() -> void:
	print("\n[2] AssociacaoHunterMap densificação...")
	var MapScript = load("res://world/maps/AssociacaoHunterMap.gd")
	_ok(MapScript != null, "AssociacaoHunterMap.gd carrega")
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 7
	var mapa_off = MapScript.new()
	mapa_off.name = "AssocDensityOff"
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_off.get_node_or_null("Cheadle") != null, "Cheadle presente")
	_ok(mapa_off.get_node_or_null("Pariston") != null, "Pariston presente")
	_ok(mapa_off.get_node_or_null("Leorio") != null, "Leorio presente")
	_ok(mapa_off.get_node_or_null("Killua") != null or mapa_off.get_node_or_null("KilluaAlluka") != null, "Killua presente")
	_ok(mapa_off.get_node_or_null("Alluka") != null, "Alluka presente")
	_ok(mapa_off.get_node_or_null("GonRecuperado") != null, "GonRecuperado presente")
	_ok(mapa_off.get_node_or_null("MordomoMissao_C") != null, "Mordomo missão C")
	_ok(mapa_off.get_node_or_null("NeedleMissao_C") != null, "Needle missão C")
	_ok(mapa_off.get_node_or_null("ZodiacoAmbientA") != null, "Walker Zodíaco")
	_ok(mapa_off.get_node_or_null("GuardaCela") != null, "Walker cela")
	_ok(mapa_off.get_node_or_null("MotoristaRodovia") != null, "Walker rodovia")
	_ok(mapa_off.get_node_or_null("PropsEstruturaAssociacao") != null, "Props estrutura")
	_ok(mapa_off.get_node_or_null("PlacaAssocAuditorio") != null, "Placa Auditório")
	_ok(mapa_off.get_node_or_null("PlacaAssocCela") != null, "Placa Cela")
	_ok(mapa_off.get_node_or_null("ZetsuRodoviaIllumi") != null, "Zetsu rodovia")
	_ok(mapa_off.get_node_or_null("GyoCelaAlluka") == null, "Sem Gyo pré-despertar")

	var cheadle = mapa_off.get_node_or_null("Cheadle")
	var fala_c := ""
	if cheadle != null and "fala_padrao" in cheadle:
		fala_c = str(cheadle.fala_padrao)
	_ok("ORDEM" in fala_c and "Pariston" in fala_c, "Cheadle fala direta")

	var leorio = mapa_off.get_node_or_null("Leorio")
	_ok(leorio != null and abs(leorio.position.x - 1400.0) < 80.0, "Leorio no Hospital (~1400)")

	var illumi = mapa_off.get_node_or_null("IllumiInimigo")
	_ok(illumi != null and abs(illumi.position.x - 3100.0) < 80.0, "Illumi na Rodovia (~3100)")

	var gon = mapa_off.get_node_or_null("GonRecuperado")
	var fala_g := ""
	var nome_g := ""
	if gon != null:
		if "fala_padrao" in gon:
			fala_g = str(gon.fala_padrao)
		if "npc_name" in gon:
			nome_g = str(gon.npc_name)
	_ok("ORDEM" in fala_g and "Recuperado" in nome_g, "Gon recuperado fala/id")

	var marcos: Dictionary = mapa_off._marcos_notificados
	_ok(marcos.has("masmorra") and marcos.has("rodovia") and marcos.has("tribuna"), "Marcos masmorra/rodovia/tribuna")

	mapa_off.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_on = MapScript.new()
	mapa_on.name = "AssocDensityOn"
	add_child(mapa_on)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_on.get_node_or_null("GyoCelaAlluka") != null, "Gyo cela_alluka")
	_ok(mapa_on.get_node_or_null("GyoUtiGon") != null, "Gyo UTI Gon")
	_ok(mapa_on.get_node_or_null("GyoPlenario") != null, "Gyo plenário")
	_ok(mapa_on.get_node_or_null("KoGradeCela") != null, "Ko cela")
	var alluka = mapa_on.get_node_or_null("Alluka")
	var fala_a := ""
	if alluka != null and "fala_padrao" in alluka:
		fala_a = str(alluka.fala_padrao)
	_ok("ORDEM" in fala_a and "Nanika" in fala_a, "Alluka fala direta")

	mapa_on.queue_free()
	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 1
