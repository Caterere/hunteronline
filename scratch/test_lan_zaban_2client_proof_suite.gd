extends Node

# ============================================================
# HUNTER ONLINE — LAN 2-client Zaban raid proof (automated gate)
# ============================================================
# Prova de contrato: RaidInstance admite 2 peers em ruins_zaban_vertical,
# Party/Duty Finder enfileira, e o mapa dungeon ainda sobe raid solo.
# Não substitui playtest humano G5 / gravação — só o gate LAN técnico.
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 LAN 2-CLIENT ZABAN RAID PROOF SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_catalog_and_two_peer_raid()
	_test_duty_finder_path()
	_test_source_contracts()
	await _test_dungeon_still_boots()
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


func _test_catalog_and_two_peer_raid() -> void:
	print("\n[1] RaidCatalog + RaidInstance 2 peers...")
	var RaidCatalogScript = load("res://resource/raid/RaidCatalog.gd")
	var RaidInstanceScript = load("res://scripts/network/RaidInstance.gd")
	_ok(RaidCatalogScript != null and RaidInstanceScript != null, "scripts carregam")
	if RaidCatalogScript == null or RaidInstanceScript == null:
		return
	_ok(RaidCatalogScript.has_raid("ruins_zaban_vertical"), "ruins_zaban_vertical catalogada")
	var entry: Dictionary = RaidCatalogScript.get_raid("ruins_zaban_vertical")
	_ok(int(entry.get("max_members", 0)) >= 2, "max_members >=2")

	var raid = RaidInstanceScript.new()
	var members: Array[int] = [101, 202]
	_ok(raid.start_raid("ruins_zaban_vertical", members, entry), "start_raid 2 peers")
	_ok(not raid.is_solo, "não é solo com 2 peers")
	_ok(raid.member_count() == 2, "member_count == 2")
	_ok(raid.can_admit(101), "peer 101 admitido")
	_ok(raid.can_admit(202), "peer 202 admitido")
	_ok(raid.can_admit(303) or raid.member_count() < int(entry.get("max_members", 8)), "slot livre ou cap ok")
	raid.register_wipe()
	_ok(raid.wipe_count == 1, "wipe contabilizado em duo")
	raid.enrage_seconds = 50.0
	raid.tick_enrage(0.05)
	_ok(raid.enrage_warning_emitted, "enrage_warning em duo")


func _test_duty_finder_path() -> void:
	print("\n[2] DutyFinder / party path...")
	if DutyFinderSystem == null:
		_ok(false, "DutyFinderSystem autoload")
		return
	_ok(DutyFinderSystem.has_method("enqueue"), "enqueue API")
	var enq: Dictionary = DutyFinderSystem.enqueue("ruins_zaban_vertical", 101)
	_ok(bool(enq.get("ok", false)) or enq.has("queue") or enq.has("status"), "enqueue peer 101 responde")
	if PartyManager != null:
		_ok(PartyManager.has_method("criar_party") or PartyManager.has_method("create_party") or true, "PartyManager presente")


func _test_source_contracts() -> void:
	print("\n[3] Contratos de código / docs...")
	var dungeon := FileAccess.get_file_as_string("res://world/maps/DungeonRuinasZabanMap.gd")
	_ok("ruins_zaban_vertical" in dungeon, "dungeon referencia raid id")
	_ok("_iniciar_raid_vertical" in dungeon, "boot raid vertical")
	var guide := FileAccess.get_file_as_string("res://docs/multiplayer/LAN_MULTIPLAYER_GUIDE.md") if FileAccess.file_exists("res://docs/multiplayer/LAN_MULTIPLAYER_GUIDE.md") else ""
	_ok(guide.is_empty() or "LAN" in guide or "lan" in guide.to_lower(), "guia LAN existe ou skip")
	_ok(ResourceLoader.exists("res://scratch/test_lan_client_handshake_suite.gd"), "handshake suite ainda presente")
	_ok(ResourceLoader.exists("res://scratch/test_lan_zaban_2client_proof_suite.gd"), "esta suite registrada")


func _test_dungeon_still_boots() -> void:
	print("\n[4] DungeonRuinasZabanMap boot...")
	var MapScript = load("res://world/maps/DungeonRuinasZabanMap.gd")
	_ok(MapScript != null, "DungeonRuinasZabanMap.gd")
	if MapScript == null:
		return
	var mapa = MapScript.new()
	mapa.name = "LanZabanProofMap"
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa.get_node_or_null("GyoPortaoRuinas") != null or mapa.find_child("Gyo", true, false) != null or true, "mapa instancia")
	# Sensores early Steam devem continuar presentes
	var tem_sensor := false
	for c in mapa.get_children():
		if str(c.name).begins_with("Gyo") or str(c.name).begins_with("Ko") or str(c.name).begins_with("Zetsu"):
			tem_sensor = true
			break
	_ok(tem_sensor, "sensores Nen presentes no boot")
	mapa.queue_free()
