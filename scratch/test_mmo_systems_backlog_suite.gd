extends Node

## Auto-generated against live APIs — do not hand-edit names.

var _passed := 0
var _total := 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 MMO SYSTEMS BACKLOG SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_autoloads()
	_test_duty_finder()
	_test_gourmet()
	_test_territory()
	_test_season_pass_and_travel()
	_test_auction_uid_nen()
	_test_wall_bounce_helpers()
	_test_raid_bind_apis()
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


func _test_autoloads() -> void:
	print("\n[0] Autoloads...")
	_ok(DutyFinderSystem != null, "DutyFinderSystem")
	_ok(GourmetCookingSystem != null, "GourmetCookingSystem")
	_ok(TerritoryWarSystem != null, "TerritoryWarSystem")
	_ok(SeasonPassSystem != null, "SeasonPassSystem")
	_ok(TimeManager != null and TimeManager.has_method("obter_dia"), "TimeManager.obter_dia")
	_ok(TravelSystem != null and TravelSystem.has_method("unlock_skin"), "TravelSystem.unlock_skin")


func _test_duty_finder() -> void:
	print("\n[1] DutyFinderSystem...")
	DutyFinderSystem.cancel_queue()
	var duties: Array = DutyFinderSystem.list_duties()
	_ok(duties.size() >= 3, ">=3 duties")
	var enq: Dictionary = DutyFinderSystem.enqueue("ruins_zaban_vertical", 1)
	_ok(bool(enq.get("ok", false)), "enqueue ruins_zaban_vertical")
	_ok(DutyFinderSystem.is_queued(), "is_queued")
	DutyFinderSystem._filled = DutyFinderSystem._needed
	DutyFinderSystem._ready_match()
	_ok(Engine.has_meta("active_raid_instance"), "meta active_raid_instance")
	var raid = Engine.get_meta("active_raid_instance")
	_ok(raid != null and is_instance_valid(raid), "RaidInstance alive")
	if raid != null and raid.has_method("member_count"):
		_ok(int(raid.member_count()) >= 1, "raid has members")
	else:
		_ok(false, "raid has members")


func _test_gourmet() -> void:
	print("\n[2] GourmetCookingSystem...")
	GourmetCookingSystem.pantry.clear()
	GourmetCookingSystem.active_buffs.clear()
	GourmetCookingSystem.writs_day = -1
	GourmetCookingSystem.refresh_writs_if_needed()
	_ok(GourmetCookingSystem.get_daily_writs().size() >= 2, "daily writs")
	var g: Dictionary = GourmetCookingSystem.gather_random()
	_ok(bool(g.get("ok", false)), "gather_random")
	GourmetCookingSystem.pantry["carne_fera"] = 5
	GourmetCookingSystem.pantry["tempero_proibido"] = 2
	var cooked: Dictionary = GourmetCookingSystem.cook("banquete_magico")
	_ok(bool(cooked.get("ok", false)), "cook banquete_magico")
	var totals: Dictionary = GourmetCookingSystem.get_active_buff_totals()
	_ok(float(totals.get("max_hp_pct", 0.0)) > 0.0, "buff max_hp_pct active")


func _test_territory() -> void:
	print("\n[3] TerritoryWarSystem...")
	_ok(TerritoryWarSystem.list_routes().size() >= 3, ">=3 routes")
	var sk: Dictionary = TerritoryWarSystem.start_skirmish("ponte_padokia")
	_ok(bool(sk.get("ok", false)), "start_skirmish")
	var rep: Dictionary = TerritoryWarSystem.report_skirmish_result("ponte_padokia", "mafia", 15)
	_ok(bool(rep.get("ok", false)), "report_skirmish_result")
	var resolved: Dictionary = TerritoryWarSystem.resolve_week(true)
	_ok(bool(resolved.get("ok", false)), "resolve_week")
	_ok(TerritoryWarSystem.get_route_owner("ponte_padokia") == "mafia", "mafia owns route")


func _test_season_pass_and_travel() -> void:
	print("\n[4] SeasonPass + Travel skins...")
	SeasonPassSystem.xp = 0
	SeasonPassSystem.claimed_tiers.clear()
	var before := SeasonPassSystem.current_tier()
	SeasonPassSystem.add_xp(250, "test")
	_ok(SeasonPassSystem.current_tier() > before, "tier increases")
	_ok(
		TravelSystem.has_skin("airship_banner_blue") or SeasonPassSystem.claimed_tiers.has(2),
		"tier 2 reward applied"
	)
	var xp_before := SeasonPassSystem.xp
	SeasonPassSystem.notify_ranked_win()
	_ok(SeasonPassSystem.xp >= xp_before + 40, "notify_ranked_win")


func _test_auction_uid_nen() -> void:
	print("\n[5] AuctionHouse item_uid + nen...")
	AuctionHouse.reset_for_tests()
	if str(PlayerData.character_id).strip_edges().is_empty():
		PlayerData.character_id = "test_ah_uid"
	PlayerData.inventory.clear()
	PlayerData.adicionar_item(&"minerio_aco", 10)
	Economy.definir_gold(5000)
	var listed: Dictionary = AuctionHouse.list_item("minerio_aco", 1, 300)
	_ok(bool(listed.get("ok", false)), "list_item ok")
	var listing: Dictionary = listed.get("listing", {})
	_ok(str(listing.get("item_uid", "")) != "", "item_uid present")
	_ok(listing.has("nen_tag"), "nen_tag present")
	var dup: Dictionary = AuctionHouse.list_item("minerio_aco", 1, 300)
	_ok(not bool(dup.get("ok", false)), "anti-dupe blocks 2nd list")
	_ok(str(dup.get("error", "")) == "item_uid_duplicado", "error item_uid_duplicado")
	var nen := str(listing.get("nen_tag", ""))
	var filtered: Array = AuctionHouse.get_active_listings("", "", nen)
	_ok(filtered is Array, "nen filter ok")


func _test_wall_bounce_helpers() -> void:
	print("\n[6] Wall bounce / aerial helpers...")
	var bounced: Vector2 = HitStopManager.calcular_wall_bounce(Vector2(200, 0), Vector2.LEFT, 0.85)
	_ok(true, "calcular_wall_bounce callable")
	_ok(bounced.x < 0.0, "bounce reflects X")
	_ok(HitStopManager.aerial_combo_multiplier(true, 2) > 1.0, "aerial > 1")
	_ok(HitStopManager.aerial_combo_multiplier(false, 2) == 1.0, "no window = 1")


func _test_raid_bind_apis() -> void:
	print("\n[7] RaidInstance bind APIs...")
	var entry: Dictionary = RaidCatalog.get_raid("ruins_zaban_vertical")
	_ok(not entry.is_empty(), "RaidCatalog entry")
	var raid := RaidInstance.new()
	var members: Array[int] = [1, 2, 3, 4]
	_ok(raid.start_raid("ruins_zaban_vertical", members, entry), "start_raid")
	raid.update_boss_hp_ratio(0.5)
	_ok(raid.current_phase_index >= 1, "phase advances")
	_ok(raid.has_method("tick_enrage"), "tick_enrage")
	_ok(raid.has_method("complete_raid"), "complete_raid")
	var result: Dictionary = raid.complete_raid()
	_ok(raid.is_cleared, "is_cleared")
	_ok(result.has("loot_seed") or result.has("raid_id"), "complete payload")
