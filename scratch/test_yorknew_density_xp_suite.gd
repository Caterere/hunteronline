extends Node

# ============================================================
# HUNTER ONLINE — Yorknew densificação + XP canônico (soft-cap era)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 YORKNEW DENSITY + CANON XP SCALE SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_canon_xp_scale()
	await _test_yorknew_density_gate()
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


func _test_canon_xp_scale() -> void:
	print("\n[1] Escala XP canônico por arco...")
	CanonQuestCatalog._quest_cache.clear()

	var q1 = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	var q1_end = CanonQuestCatalog.obter_quest_da_etapa(1, 24)
	var q3 = CanonQuestCatalog.obter_quest_da_etapa(3, 26)
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(4, 34)
	var q6 = CanonQuestCatalog.obter_quest_da_etapa(6, 48)
	_ok(q1 != null and q1.reward_xp <= 350, "Exam etapa1 XP escalado (<=350, got %d)" % q1.reward_xp)
	_ok(q1.reward_xp >= 50, "Exam etapa1 XP mínimo (>=50)")
	_ok(q1_end.reward_xp < 3000, "Exam final XP freado (<3000, got %d)" % q1_end.reward_xp)
	_ok(q3.reward_xp < 10000, "Arena final XP freado (<10k, got %d)" % q3.reward_xp)
	_ok(q4.reward_xp < 20000, "Yorknew final XP freado (<20k, got %d)" % q4.reward_xp)
	_ok(q6.reward_xp < 50000, "Formigas final XP freado (<50k, got %d)" % q6.reward_xp)
	_ok(
		CanonQuestCatalog.escalar_xp_narrativo(4, 60000) == 9600,
		"Helper arco4 60000→9600 (%d)" % CanonQuestCatalog.escalar_xp_narrativo(4, 60000)
	)


func _test_yorknew_density_gate() -> void:
	print("\n[2] Yorknew densificação + gate Gyo...")
	var MapScript = load("res://world/maps/YorknewCityMap.gd")
	_ok(MapScript != null, "YorknewCityMap.gd carrega")
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	var mapa_off = MapScript.new()
	mapa_off.name = "YorknewDensityOff"
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa_off.get_node_or_null("MafiosoAmbient_A") != null, "Filler MafiosoAmbient_A presente")
	_ok(mapa_off.get_node_or_null("MafiosoAmbient_D") != null, "Filler MafiosoAmbient_D presente")
	_ok(mapa_off.get_node_or_null("ZetsuBecoRuasNorte") != null, "Zetsu beco norte presente")
	_ok(mapa_off.get_node_or_null("ZetsuBecoCemiterio") != null, "Zetsu beco cemitério presente")
	_ok(mapa_off.get_node_or_null("GyoPistaLeilaoAura") == null, "Sem Gyo pré-despertar")
	_ok(mapa_off.get_node_or_null("KoCaixoteLeilao") == null, "Sem Ko Gyo-gated pré-despertar")
	mapa_off.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_on = MapScript.new()
	mapa_on.name = "YorknewDensityOn"
	add_child(mapa_on)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa_on.get_node_or_null("GyoPistaLeilaoAura") != null, "Gyo leilão após despertar")
	_ok(mapa_on.get_node_or_null("GyoPistaRuasAranha") != null, "Gyo ruas após despertar")
	_ok(mapa_on.get_node_or_null("GyoPistaCemiterioRequiem") != null, "Gyo cemitério após despertar")
	_ok(mapa_on.get_node_or_null("KoCaixoteLeilao") != null, "Ko caixote após despertar")
	_ok(mapa_on.get_node_or_null("PlacaYorkLeilao") != null, "Placa distrito leilão")
	mapa_on.queue_free()
	PlayerData.despertou_nen = false
