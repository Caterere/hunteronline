extends Node2D

const RaidCatalogScript = preload("res://resource/raid/RaidCatalog.gd")
const RaidInstanceScript = preload("res://scripts/network/RaidInstance.gd")

var _ok := 0
var _total := 0
var _pass := true


func _ready() -> void:
	print("================================================================================")
	print("🚀 SUÍTE S3: RAID 8 HUNTERS — VERTICAL RUÍNAS")
	print("================================================================================")
	await get_tree().process_frame
	_run()
	print("--------------------------------------------------------------------------------")
	print("RESULTADO: %d/%d" % [_ok, _total])
	if _pass:
		print("✅ S3 RAID 8 HUNTERS SUITE PASSED")
		get_tree().quit(0)
	else:
		print("❌ S3 RAID 8 HUNTERS SUITE FAILED")
		get_tree().quit(1)


func _check(c: bool, ok: String, fail: String) -> void:
	_total += 1
	if c:
		_ok += 1
		print("  ✅ [PASS] %s" % ok)
	else:
		_pass = false
		print("  ❌ [FAIL] %s" % fail)


func _run() -> void:
	print("\n[1] PartyManager raid cap")
	_check(PartyManager != null, "PartyManager ativo", "PartyManager null")
	_check(PartyManager.obter_max_membros() == 4, "Cap mundo = 4", "cap=%d" % PartyManager.obter_max_membros())
	PartyManager.entrar_modo_raid()
	_check(PartyManager.party_mode == "raid", "Modo raid ativo", "mode=%s" % PartyManager.party_mode)
	_check(PartyManager.obter_max_membros() == 8, "Cap raid = 8", "cap=%d" % PartyManager.obter_max_membros())
	PartyManager.sair_modo_raid()
	_check(PartyManager.obter_max_membros() == 4, "Volta cap mundo = 4", "cap fail")

	print("\n[2] RaidCatalog vertical Zaban")
	_check(RaidCatalogScript.has_raid("ruins_zaban_vertical"), "Raid Ruínas catalogada", "missing catalog")
	var entry: Dictionary = RaidCatalogScript.get_raid("ruins_zaban_vertical")
	_check(int(entry.get("max_members", 0)) == 8, "Catalog max_members=8", "max=%s" % str(entry.get("max_members")))
	_check((entry.get("phases", []) as Array).size() >= 3, ">=3 fases", "phases thin")

	print("\n[3] RaidInstance lifecycle")
	var raid := RaidInstanceScript.new()
	var members: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8]
	_check(raid.start_raid("ruins_zaban_vertical", members, entry), "start_raid 8 ok", "start failed")
	_check(raid.member_count() == 8, "8 membros na instância", "count=%d" % raid.member_count())
	_check(not raid.can_admit(9), "Recusa 9º hunter", "admitiu 9")
	_check(raid.can_admit(1), "Membro existente ok", "can_admit self fail")

	raid.update_boss_hp_ratio(0.69)
	_check(raid.current_phase_index >= 1, "Avança fase em 70% HP", "phase=%d" % raid.current_phase_index)
	raid.update_boss_hp_ratio(0.19)
	_check(raid.enrage_active, "Enrage ao cruzar 20%", "enrage false")
	raid.tick_enrage(9999.0)
	_check(raid.enrage_active, "Enrage timer esgotado mantém flag", "enrage cleared wrongly")

	raid.register_wipe()
	_check(raid.wipe_count == 1, "Wipe contabilizado", "wipes=%d" % raid.wipe_count)
	var result: Dictionary = raid.complete_raid()
	_check(raid.is_cleared, "Raid cleared", "not cleared")
	_check((result.get("loot", []) as Array).size() == 8, "Loot por hunter (8)", "loot size fail")

	print("\n[4] Reject oversized raid start")
	var fat: Array[int] = [1,2,3,4,5,6,7,8,9]
	var raid2 := RaidInstanceScript.new()
	_check(not raid2.start_raid("ruins_zaban_vertical", fat, entry), "Rejeita 9 membros", "aceitou 9")
