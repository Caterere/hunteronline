extends Node

# ============================================================
# HUNTER ONLINE — Kukuroo densificação pós-Nen (padrão Yorknew)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 KUKUROO DENSITY (PÓS-NEN) SUITE")
	print("================================================================================")
	await get_tree().process_frame
	await _test_kukuroo_density_gate()
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


func _test_kukuroo_density_gate() -> void:
	print("\n[1] Kukuroo densificação + gate Gyo/Ko...")
	var MapScript = load("res://world/maps/MontanhaKukurooMap.gd")
	_ok(MapScript != null, "MontanhaKukurooMap.gd carrega")
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	var mapa_off = MapScript.new()
	mapa_off.name = "KukurooDensityOff"
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa_off.get_node_or_null("MordomoAmbient_A") != null, "Filler MordomoAmbient_A presente")
	_ok(mapa_off.get_node_or_null("MordomoAmbient_E") != null, "Filler MordomoAmbient_E presente")
	_ok(mapa_off.get_node_or_null("ZetsuArbustoAlameda") != null, "Zetsu arbusto alameda presente")
	_ok(mapa_off.get_node_or_null("ZetsuJardimMansao") != null, "Zetsu jardim mansão presente")
	_ok(mapa_off.get_node_or_null("ZetsuCorredorTrono") != null, "Zetsu corredor trono presente")
	_ok(mapa_off.get_node_or_null("GyoPistaPortaoAura") == null, "Sem Gyo pré-despertar")
	_ok(mapa_off.get_node_or_null("KoPedraAlameda") == null, "Sem Ko Gyo-gated pré-despertar")
	_ok(mapa_off.get_node_or_null("PlacaKukuPortao") != null, "Placa portão presente")
	_ok(mapa_off.get_node_or_null("JardineiroZoldyck") != null, "Jardineiro ambient presente")
	_ok(mapa_off.get_node_or_null("AprendizMordomo") != null, "Aprendiz ambient presente")
	_ok(mapa_off.get_node_or_null("MapAtmosphereDecorator") != null, "Atmosphere KUKUROO anexada")
	var lanterna = mapa_off.get_node_or_null("MapAtmosphereDecorator/AtmosphereProps/LanternaPedraKuku_900")
	_ok(lanterna != null, "Lanterna de pedra PixelLab (900)")
	mapa_off.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_on = MapScript.new()
	mapa_on.name = "KukurooDensityOn"
	add_child(mapa_on)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa_on.get_node_or_null("GyoPistaPortaoAura") != null, "Gyo portão após despertar")
	_ok(mapa_on.get_node_or_null("GyoPistaAlamedaMike") != null, "Gyo Mike após despertar")
	_ok(mapa_on.get_node_or_null("GyoPistaTronoSilva") != null, "Gyo trono após despertar")
	_ok(mapa_on.get_node_or_null("KoPedraAlameda") != null, "Ko pedra após despertar")
	_ok(mapa_on.get_node_or_null("PlacaKukuTrono") != null, "Placa sala do trono")

	var jard = mapa_on.get_node_or_null("JardineiroZoldyck")
	if jard != null:
		var spr = jard.get_node_or_null("Sprite2D") as Sprite2D
		var path := ""
		if spr != null and spr.texture != null:
			path = str(spr.texture.resource_path)
		_ok(not path.ends_with("player.png"), "Jardineiro sem player.png (%s)" % path)
		_ok(path.contains("mordomo_zoldyck_ambient") or path.contains("viajante"), "Jardineiro sheet ambient (%s)" % path)
	else:
		_ok(false, "Jardineiro presente no mapa pós-despertar")
		_ok(false, "Jardineiro sheet ambient")

	mapa_on.queue_free()
	PlayerData.despertou_nen = false
