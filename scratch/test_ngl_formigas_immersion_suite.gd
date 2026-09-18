extends Node

# ============================================================
# HUNTER ONLINE — NGL Formigas imersão (densidade + clues canônicos)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 NGL FORMIGAS IMMERSION SUITE")
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
	print("\n[1] Canon NGL early ORDEM...")
	CanonQuestCatalog._quest_cache.clear()
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(6, 1)
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(6, 4)
	var q11 = CanonQuestCatalog.obter_quest_da_etapa(6, 11)
	var q16 = CanonQuestCatalog.obter_quest_da_etapa(6, 16)
	var q18 = CanonQuestCatalog.obter_quest_da_etapa(6, 18)
	var q22 = CanonQuestCatalog.obter_quest_da_etapa(6, 22)
	var q26 = CanonQuestCatalog.obter_quest_da_etapa(6, 26)
	_ok(q1 != null and "ORDEM" in q1.description, "etapa1 ORDEM")
	_ok(q4 != null and q4.objectives[0].target_clue_id == &"fabrica_d2_gyro", "etapa4 fabrica_d2")
	_ok("ORDEM" in q4.description and "[G]" in q4.description, "etapa4 descrição Gyo")
	_ok(q11 != null and "ORDEM" in q11.description and q11.objectives[0].target_npc_id == &"netero", "etapa11 Netero")
	_ok(q16 != null and q16.objectives[0].target_clue_id == &"nascimento_rei_meruem", "etapa16 nascimento")
	_ok(q18 != null and q18.objectives[0].target_zone_id == &"fronteira_goruto", "etapa18 stealth Goruto")
	_ok(q22 != null and q22.objectives[0].target_clue_id == &"portas_knov", "etapa22 portas_knov")
	_ok(q26 != null and "ORDEM" in q26.description and q26.objectives[0].target_clue_id == &"chuva_dragoes_zeno", "etapa26 chuva")
	var obj = QuestObjective.new()
	obj.type = QuestObjective.Type.INVESTIGATE
	obj.target_clue_id = &"fabrica_d2_gyro"
	_ok("Fábrica" in obj.describe() or "Fabrica" in obj.describe() or "D2" in obj.describe(), "describe fabrica_d2")
	obj.type = QuestObjective.Type.STEALTH_PASS
	obj.target_zone_id = &"fronteira_goruto"
	_ok("Goruto" in obj.describe(), "describe fronteira_goruto")


func _test_map_density() -> void:
	print("\n[2] NGLFormigasMap densificação...")
	var MapScript = load("res://world/maps/NGLFormigasMap.gd")
	_ok(MapScript != null, "NGLFormigasMap.gd carrega")
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 6
	var mapa_off = MapScript.new()
	mapa_off.name = "NGLDensityOff"
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_off.get_node_or_null("Kite") != null, "Kite presente")
	_ok(mapa_off.get_node_or_null("Killua") != null, "Killua presente")
	_ok(mapa_off.get_node_or_null("Netero") != null, "Netero presente")
	_ok(mapa_off.get_node_or_null("Morel") != null, "Morel presente")
	_ok(mapa_off.get_node_or_null("Knuckle") != null, "Knuckle presente")
	_ok(mapa_off.get_node_or_null("Shoot") != null, "Shoot presente")
	_ok(mapa_off.get_node_or_null("Gon") != null, "Gon presente")
	_ok(mapa_off.get_node_or_null("FormigaMissao_B") != null, "Formiga missão B")
	_ok(mapa_off.get_node_or_null("GuardaPeijin_B") != null, "Guarda Peijin B")
	_ok(mapa_off.get_node_or_null("ScoutFronteiraNGL") != null, "Walker scout")
	_ok(mapa_off.get_node_or_null("InfiltradoGoruto") != null, "Walker Goruto")
	_ok(mapa_off.get_node_or_null("PropsEstruturaNGL") != null, "Props estrutura")
	_ok(mapa_off.get_node_or_null("PlacaNGLFronteira") != null, "Placa Fronteira")
	_ok(mapa_off.get_node_or_null("PlacaNGLFabrica") != null, "Placa Fábrica")
	_ok(mapa_off.get_node_or_null("ZetsuFronteiraGoruto") != null, "Zetsu Goruto")
	_ok(mapa_off.get_node_or_null("GyoFabricaD2") == null, "Sem Gyo pré-despertar")

	var kite = mapa_off.get_node_or_null("Kite")
	var fala_k := ""
	if kite != null and "fala_padrao" in kite:
		fala_k = str(kite.fala_padrao)
	_ok("ORDEM" in fala_k and "[G]" in fala_k, "Kite fala direta")

	var marcos: Dictionary = mapa_off._marcos_notificados
	_ok(marcos.has("peijin") and marcos.has("fabrica") and marcos.has("palacio"), "Marcos peijin/fabrica/palacio")

	mapa_off.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_on = MapScript.new()
	mapa_on.name = "NGLDensityOn"
	add_child(mapa_on)
	await get_tree().process_frame
	await get_tree().process_frame

	_ok(mapa_on.get_node_or_null("GyoFabricaD2") != null, "Gyo fabrica_d2")
	_ok(mapa_on.get_node_or_null("GyoNascimentoRei") != null, "Gyo nascimento_rei")
	_ok(mapa_on.get_node_or_null("GyoPortasKnov") != null, "Gyo portas_knov")
	_ok(mapa_on.get_node_or_null("GyoChuvaDragoes") != null, "Gyo chuva_dragoes")
	_ok(mapa_on.get_node_or_null("KoBarreiraFabrica") != null, "Ko fábrica")
	var netero = mapa_on.get_node_or_null("Netero")
	var fala_n := ""
	if netero != null and "fala_padrao" in netero:
		fala_n = str(netero.fala_padrao)
	_ok("ORDEM" in fala_n and "Morel" in fala_n, "Netero fala direta")
	_ok(abs(netero.position.x - 1900.0) < 50.0 if netero != null else false, "Netero em Peijin (~1900)")

	mapa_on.queue_free()
	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 1
