extends SceneTree

var _passed := 0
var _failed := 0


func _initialize() -> void:
	print("🚀 SUÍTE SAGAS SOLID CONSOLIDATION")
	_test_catalog()
	_test_story_checkpoints()
	_test_atmosphere_kinds()
	_test_consolidator_presets()
	_test_hub_wiring()
	_test_node_name_alignment()
	print("============================================================")
	print("✅ PASSED: %d | ❌ FAILED: %d" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)


func _ok(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  ✓ ", msg)
	else:
		_failed += 1
		print("  ✗ ", msg)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _test_catalog() -> void:
	print("-- SagaModuleCatalog --")
	var src := _read("res://world/sagas/SagaModuleCatalog.gd")
	var expected := {1: 24, 2: 18, 3: 26, 4: 34, 5: 36, 6: 48, 7: 20, 8: 22, 9: 26}
	for sid in expected.keys():
		_ok(('\"capitulos_total\": %d' % int(expected[sid])) in src, "saga %d capitulos_total=%d" % [sid, int(expected[sid])])
	for h in [
		"exame_maratona.tscn", "montanha_kukuroo.tscn", "arena_celestial.tscn",
		"yorknew_city.tscn", "greed_island.tscn", "ngl_formigas.tscn",
		"associacao_hunter.tscn", "continente_negro.tscn", "black_whale_1.tscn"
	]:
		_ok(h in src, "catalog hub %s" % h)


func _test_story_checkpoints() -> void:
	print("-- StoryManager checkpoints 7-9 --")
	var src := _read("res://autoload/StoryManager.gd")
	for k in ["associacao_hunter_auditorio", "continente_negro_acampamento", "black_whale_conves1"]:
		_ok(('&\"%s\"' % k) in src, "checkpoint %s" % k)
	_ok("associacao_hunter_auditorio" in src and "7:" in src, "fallback saga 7 presente")
	_ok("continente_negro_acampamento" in src and "8:" in src, "fallback saga 8 presente")
	_ok("black_whale_conves1" in src and "9:" in src, "fallback saga 9 presente")


func _test_atmosphere_kinds() -> void:
	print("-- MapAtmosphereDecorator kinds --")
	var src := _read("res://world/components/MapAtmosphereDecorator.gd")
	for k in ["EXAME", "GREED", "NGL", "ASSOC", "CONTINENTE", "WHALE"]:
		_ok(k in src, "enum/uso %s" % k)
	for fn in ["_densificar_exame", "_densificar_greed", "_densificar_ngl", "_densificar_assoc", "_densificar_continente", "_densificar_whale"]:
		_ok(("func %s()" % fn) in src, "helper %s" % fn)


func _test_consolidator_presets() -> void:
	print("-- SagaHubConsolidator presets --")
	var src := _read("res://world/components/SagaHubConsolidator.gd")
	_ok("static func densify_hub" in src, "densify_hub")
	_ok("static func config_for_saga" in src, "config_for_saga")
	var body := src.get_slice("config_for_saga", 1)
	for sid in range(1, 10):
		_ok(("%d:" % sid) in body, "preset saga %d" % sid)
	_ok("RazorInimigo" in src and "MeruemRei" in src and "CamillaCatInimiga" in src, "bosses chave GI/NGL/BW")
	_ok("PakunodaInimiga" in src and "ChrolloBossInimigo" in src, "bosses Yorknew extras")
	_ok("YoupiInimigo" in src and "ShaiapoufInimigo" in src, "guarda real NGL")


func _test_hub_wiring() -> void:
	print("-- Hub wiring --")
	var hubs := {
		"ExameMaratonaMap.gd": [1, "EXAME"],
		"MontanhaKukurooMap.gd": [2, "KUKUROO"],
		"ArenaCelestialMap.gd": [3, "ARENA"],
		"YorknewCityMap.gd": [4, "YORKNEW"],
		"GreedIslandMap.gd": [5, "GREED"],
		"NGLFormigasMap.gd": [6, "NGL"],
		"AssociacaoHunterMap.gd": [7, "ASSOC"],
		"ContinenteNegroMap.gd": [8, "CONTINENTE"],
		"BlackWhale1Map.gd": [9, "WHALE"],
	}
	for fname in hubs.keys():
		var sid: int = hubs[fname][0]
		var kind: String = hubs[fname][1]
		var src := _read("res://world/maps/%s" % fname)
		_ok(("MapAtmosphereDecorator.MapKind.%s" % kind) in src, "%s atmosphere %s" % [fname, kind])
		_ok(("config_for_saga(%d)" % sid) in src, "%s consolidator saga %d" % [fname, sid])


func _test_node_name_alignment() -> void:
	print("-- Node name alignment --")
	var york := _read("res://world/maps/YorknewCityMap.gd")
	_ok("&\"nobunaga\"" in york, "Nobunaga id corrigido")
	_ok("ChrolloBossInimigo" in york, "Chrollo boss separado")
	var greed := _read("res://world/maps/GreedIslandMap.gd")
	_ok("RazorInimigo" in greed, "Greed usa RazorInimigo (cena)")
	var ngl := _read("res://world/maps/NGLFormigasMap.gd")
	_ok("MeruemRei" in ngl, "NGL configura MeruemRei")
	var assoc := _read("res://world/maps/AssociacaoHunterMap.gd")
	_ok("NeedleMan2" in assoc or "AgenteIlicito2" in assoc, "Assoc densifica agentes")
