extends Node

# ============================================================
# HUNTER ONLINE — Session A–D final smoke (Yorknew → Black Whale)
# Valida ORDEM nas sagas mid/late + mapas carregam com densidade mínima.
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 SESSION A–D FINAL SMOKE — Yorknew → Black Whale")
	print("================================================================================")
	await get_tree().process_frame
	_test_ordem_coverage()
	await _test_maps_smoke()
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


func _test_ordem_coverage() -> void:
	print("\n[1] ORDEM coverage arco 4–9...")
	CanonQuestCatalog._quest_cache.clear()
	var totals := {4: 34, 5: 36, 6: 48, 7: 20, 8: 22, 9: 26}
	for arco in totals.keys():
		var maxe: int = int(totals[arco])
		var with_ordem := 0
		var missing: PackedStringArray = []
		for e in range(1, maxe + 1):
			var q = CanonQuestCatalog.obter_quest_da_etapa(int(arco), e)
			if q != null and "ORDEM" in str(q.description):
				with_ordem += 1
			else:
				missing.append("%d/%d" % [arco, e])
		# Mid/late sagas densificadas nesta sessão → 100% ORDEM.
		var min_pct := 1.0
		var ok_pct := float(with_ordem) / float(maxe) >= min_pct
		_ok(ok_pct, "arco %d ORDEM %d/%d" % [arco, with_ordem, maxe])
		if not missing.is_empty():
			print("     missing: ", ", ".join(missing))

	# Spot-check clues canônicos mid/late
	var checks := [
		[4, 2, &"antiguidade_mercado"],
		[5, 3, &"livro_greed"],
		[6, 4, &"fabrica_d2_gyro"],
		[7, 6, &"cela_alluka"],
		[8, 5, &"mapa_lago_mobius"],
		[9, 4, &"primeiro_assassinato_kakin"],
		[9, 15, &"aposentos_tserriednich"],
	]
	for c in checks:
		var q = CanonQuestCatalog.obter_quest_da_etapa(int(c[0]), int(c[1]))
		var ok := false
		if q != null and not q.objectives.is_empty():
			var obj = q.objectives[0]
			ok = obj.target_clue_id == c[2] or obj.target_zone_id == c[2]
		_ok(ok, "arco%d etapa%d clue/zone %s" % [c[0], c[1], str(c[2])])


func _test_maps_smoke() -> void:
	print("\n[2] Mapas mid/late carregam + densidade mínima...")
	var specs := [
		{"script": "res://world/maps/YorknewCityMap.gd", "nodes": ["Kurapika"], "name": "Yorknew"},
		{"script": "res://world/maps/GreedIslandMap.gd", "nodes": ["Battera", "Biscuit"], "name": "GreedIsland"},
		{"script": "res://world/maps/NGLFormigasMap.gd", "nodes": ["Morel"], "name": "NGL"},
		{"script": "res://world/maps/AssociacaoHunterMap.gd", "nodes": ["Cheadle", "Alluka"], "name": "Associacao"},
		{"script": "res://world/maps/ContinenteNegroMap.gd", "nodes": ["Beyond", "GingTopo"], "name": "Continente"},
		{"script": "res://world/maps/BlackWhale1Map.gd", "nodes": ["Kurapika", "Hisoka", "Cheadle", "ZetsuAposentosTserriednich"], "name": "BlackWhale"},
	]
	PlayerData.despertou_nen = true
	for s in specs:
		var MapScript = load(s["script"])
		_ok(MapScript != null, "%s script carrega" % s["name"])
		if MapScript == null:
			continue
		PlayerData.arco_atual = _arco_for(s["name"])
		var mapa = MapScript.new()
		mapa.name = "Smoke_%s" % s["name"]
		add_child(mapa)
		await get_tree().process_frame
		await get_tree().process_frame
		for n in s["nodes"]:
			_ok(mapa.get_node_or_null(n) != null, "%s tem %s" % [s["name"], n])
		mapa.queue_free()
		await get_tree().process_frame
	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 1


func _arco_for(nome: String) -> int:
	match nome:
		"Yorknew":
			return 4
		"GreedIsland":
			return 5
		"NGL":
			return 6
		"Associacao":
			return 7
		"Continente":
			return 8
		"BlackWhale":
			return 9
		_:
			return 1
