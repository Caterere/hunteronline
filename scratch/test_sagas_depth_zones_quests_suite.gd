extends SceneTree

var _ok := 0
var _fail := 0

func _initialize() -> void:
	print("🚀 SUÍTE SAGAS DEPTH — zonas + exame + quests")
	_check_district_kit()
	_check_chapter_binder()
	_check_hub_wiring()
	_check_exame_density()
	_check_catalog_quests()
	print("============================================================")
	print("✅ PASSED: %d | ❌ FAILED: %d" % [_ok, _fail])
	quit(0 if _fail == 0 else 1)

func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✓ ", msg)
	else:
		_fail += 1
		print("  ✗ ", msg)

func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	return f.get_as_text() if f else ""

func _check_district_kit() -> void:
	print("-- SagaDistrictKit --")
	var src := _read("res://world/components/SagaDistrictKit.gd")
	_assert("class_name SagaDistrictKit" in src, "class_name")
	_assert("static func densify_saga" in src, "densify_saga")
	_assert("warp_name" in src and "warp_target" in src, "warps internos zona secundária")
	for sid in range(1, 10):
		_assert(("\t\t%d:" % sid) in src, "distritos saga %d" % sid)
	_assert("_spawn_nen_sensors_for_saga" in src or "_spawn_nen_sensors" in src, "sensores Nen")

func _check_chapter_binder() -> void:
	print("-- SagaChapterBinder --")
	var src := _read("res://world/components/SagaChapterBinder.gd")
	_assert("class_name SagaChapterBinder" in src, "class_name")
	_assert("static func bind_hub" in src, "bind_hub")
	_assert("garantir_quest_do_arco" in src, "garante quest do arco")
	_assert("PlacaObjetivoCapitulo" in src, "placa objetivo capítulo")
	_assert("GuiaCapituloSaga" in src, "NPC guia do capítulo")
	_assert("CanonQuestCatalog.obter_quest_da_etapa" in src, "liga CanonQuestCatalog")

func _check_hub_wiring() -> void:
	print("-- Hub wiring --")
	var hubs := {
		"ExameMaratonaMap.gd": 1,
		"MontanhaKukurooMap.gd": 2,
		"ArenaCelestialMap.gd": 3,
		"YorknewCityMap.gd": 4,
		"GreedIslandMap.gd": 5,
		"NGLFormigasMap.gd": 6,
		"AssociacaoHunterMap.gd": 7,
		"ContinenteNegroMap.gd": 8,
		"BlackWhale1Map.gd": 9,
	}
	for fname in hubs.keys():
		var arco: int = hubs[fname]
		var src := _read("res://world/maps/%s" % fname)
		_assert("SagaDistrictKit.densify_saga(self, %d)" % arco in src, "%s districts" % fname)
		_assert("SagaChapterBinder.bind_hub(self, %d)" % arco in src, "%s chapter binder" % fname)
		_assert("garantir_quest_do_arco" in src or "SagaChapterBinder" in src, "%s quest path" % fname)

func _check_exame_density() -> void:
	print("-- Exame densify --")
	var src := _read("res://world/maps/ExameMaratonaMap.gd")
	_assert("_densificar_zonas_exame" in src, "hook densify local exame")
	_assert("_garantir_quest_ativa" in src, "exame garante quest")
	_assert("SagaDistrictKit.densify_saga(self, 1)" in src, "exame usa district kit")
	var kit := _read("res://world/components/SagaDistrictKit.gd")
	_assert("Zona A — Túnel" in kit or "Túnel de Zaban" in kit, "distrito túnel")
	_assert("Pantanal" in kit or "pantanal" in kit.to_lower(), "distrito pantanal secundário")
	_assert("Gourmet" in kit, "distrito gourmet secundário")

func _check_catalog_quests() -> void:
	print("-- Canon quests 9 sagas --")
	var src := _read("res://resource/quest/CanonQuestCatalog.gd")
	var expected := {1: 24, 2: 18, 3: 26, 4: 34, 5: 36, 6: 48, 7: 20, 8: 22, 9: 26}
	for arco in expected.keys():
		_assert(("%d: return %d" % [arco, int(expected[arco])]) in src or ("\t\t%d: return %d" % [arco, int(expected[arco])]) in src,
			"arco %d tem %d capítulos" % [arco, int(expected[arco])])
