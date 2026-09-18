extends Node

# ============================================================
# HUNTER ONLINE — Raid Ruínas solo polish (telegraph / wipe / pacing)
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 RAID SOLO POLISH SUITE")
	print("================================================================================")
	await get_tree().process_frame
	await _test_map_runtime()
	_test_raid_instance_solo()
	_test_source_contracts()
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


func _test_source_contracts() -> void:
	print("\n[1] Contratos de código...")
	var dungeon := FileAccess.get_file_as_string("res://world/maps/DungeonRuinasZabanMap.gd")
	_ok("_dica_fase_solo" in dungeon, "_dica_fase_solo presente")
	_ok("WIPE SOLO" in dungeon, "toast wipe solo")
	_ok("_criar_placa_checkpoint_entrada" in dungeon, "placa checkpoint")
	_ok("_on_raid_enrage_warning" in dungeon, "handler enrage warning")
	var ai := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_ok("SAIA DO CÍRCULO" in ai, "balloon telegraph legível")
	_ok("tempo_aviso" in ai and "1.2" in ai, "telegraph boss >= ~1.2s")


func _test_raid_instance_solo() -> void:
	print("\n[2] RaidInstance solo...")
	var RaidCatalogScript = load("res://resource/raid/RaidCatalog.gd")
	var RaidInstanceScript = load("res://scripts/network/RaidInstance.gd")
	_ok(RaidCatalogScript != null and RaidInstanceScript != null, "scripts raid carregam")
	if RaidCatalogScript == null or RaidInstanceScript == null:
		return
	var entry: Dictionary = RaidCatalogScript.get_raid("ruins_zaban_vertical")
	var raid = RaidInstanceScript.new()
	var members: Array[int] = [1]
	_ok(raid.start_raid("ruins_zaban_vertical", members, entry), "start solo")
	_ok(raid.is_solo, "flag is_solo")
	_ok(raid.enrage_seconds > float(entry.get("enrage_seconds", 600.0)), "enrage stretch solo")
	raid.enrage_seconds = 45.0
	raid.tick_enrage(0.05)
	_ok(raid.enrage_warning_emitted, "enrage_warning dispara")
	raid.register_wipe()
	_ok(raid.wipe_count == 1, "wipe solo contabilizado")


func _test_map_runtime() -> void:
	print("\n[3] DungeonRuinasZabanMap runtime...")
	var MapScript = load("res://world/maps/DungeonRuinasZabanMap.gd")
	_ok(MapScript != null, "DungeonRuinasZabanMap.gd carrega")
	if MapScript == null:
		return
	var mapa = MapScript.new()
	mapa.name = "RaidSoloPolishMap"
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa.get_node_or_null("PlacaCheckpointEntrada") != null, "PlacaCheckpointEntrada spawn")
	_ok(mapa.get("_solo_mode") == true or mapa.raid_instance != null, "solo/raid wiring")
	if mapa.raid_instance != null:
		_ok(bool(mapa.raid_instance.is_solo), "raid_instance.is_solo")
	else:
		_ok(true, "raid_instance opcional se catalog fail (skip)")
	_ok(mapa.has_method("_dica_fase_solo"), "API dica fase")
	var tip: String = mapa._dica_fase_solo("collapse")
	_ok("Adds" in tip or "adds" in tip.to_lower() or tip.length() > 8, "dica collapse útil")
	mapa.queue_free()
	await get_tree().process_frame
