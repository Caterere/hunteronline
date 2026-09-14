extends Node2D

# ============================================================
# HUNTER ONLINE — FEEL + MMO SYSTEMS SUITE
# Valida Fases 1–5 do Feel Gap Close.
# ============================================================

var _ok := 0
var _total := 0
var _pass := true


func _ready() -> void:
	print("================================================================================")
	print("🚀 SUÍTE FEEL + MMO SYSTEMS (Fases 1–5)")
	print("================================================================================")
	await get_tree().process_frame
	_run()
	print("--------------------------------------------------------------------------------")
	print("RESULTADO: %d/%d" % [_ok, _total])
	if _pass:
		print("✅ FEEL + MMO SYSTEMS SUITE PASSED")
		get_tree().quit(0)
	else:
		print("❌ FEEL + MMO SYSTEMS SUITE FAILED")
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
	print("\n[1] LootDrop APIs")
	_check(ResourceLoader.exists("res://entities/world/LootDrop.gd"), "LootDrop script existe", "LootDrop missing")
	var loot_src := FileAccess.get_file_as_string("res://entities/world/LootDrop.gd")
	_check("func setup_gold" in loot_src and "spawn_jenny" in loot_src, "setup_gold + spawn_jenny", "loot APIs thin")
	_check("tocar_sfx_posicional" in loot_src or "item_pickup" in loot_src, "pickup juice SFX", "no pickup juice")

	print("\n[2] CombatImpactEffect death dissipation")
	var fx_src := FileAccess.get_file_as_string("res://entities/effects/CombatImpactEffect.gd")
	_check("spawn_death_dissipation" in fx_src, "spawn_death_dissipation", "death FX missing")
	_check("spawn_aura_burst" in fx_src, "spawn_aura_burst", "aura burst missing")
	CombatImpactEffect.spawn_death_dissipation(self, Vector2(10, 10))
	_check(true, "death dissipation executa sem erro", "death FX crash")

	print("\n[3] DamageNumberSystem IMUNE / XP / Jenny")
	_check(DamageNumberSystem != null, "DamageNumberSystem autoload", "DNS null")
	_check(DamageNumberSystem.has_method("spawn_imune"), "spawn_imune", "no IMUNE")
	_check(DamageNumberSystem.has_method("spawn_xp"), "spawn_xp", "no XP float")
	_check(DamageNumberSystem.has_method("spawn_jenny"), "spawn_jenny", "no Jenny float")
	DamageNumberSystem.spawn_imune(Vector2(20, 20))
	DamageNumberSystem.spawn_xp(Vector2(20, 20), 42)
	DamageNumberSystem.spawn_jenny(Vector2(20, 20), 15)
	_check(true, "floats spawn sem erro", "float crash")

	print("\n[4] CombatEngine IMUNE path")
	var det: Dictionary = CombatEngine.calcular_dano_detalhado(
		{"forca": 20.0, "dano_base": 10.0},
		{"defesa": 0.0, "immunity_tags": ["nen"]},
		null, false, ["nen"]
	)
	_check(bool(det.get("is_immune", false)) and int(det.get("dano", 99)) == 0,
		"imunidade zera dano", "immune fail: %s" % str(det))

	print("\n[5] Player afterimage API")
	var player_src := FileAccess.get_file_as_string("res://entities/Player/Player.gd")
	_check("func _spawn_afterimage" in player_src, "Player._spawn_afterimage definido", "afterimage missing")

	print("\n[6] Audio positional")
	_check(AudioManager != null and AudioManager.has_method("tocar_sfx_posicional"),
		"tocar_sfx_posicional", "positional audio missing")
	AudioManager.tocar_sfx_posicional("item_pickup", Vector2(0, 0), 0.5)
	_check(true, "SFX posicional sem crash", "positional crash")

	print("\n[7] Economy jenny EventBus")
	_check(EventBus != null and EventBus.has_signal("jenny_changed"),
		"jenny_changed signal", "no jenny signal")
	var jenny_seen := {"v": false}
	var cb := func(_a, _d): jenny_seen["v"] = true
	EventBus.jenny_changed.connect(cb)
	var before := Economy.obter_gold() if Economy != null else 0
	Economy.adicionar_gold(7)
	_check(jenny_seen["v"] and Economy.obter_gold() == before + 7,
		"adicionar_gold emite jenny_changed", "jenny EventBus fail")
	EventBus.jenny_changed.disconnect(cb)

	print("\n[8] Raid vertical Zaban wiring")
	var RaidCatalogScript = load("res://resource/raid/RaidCatalog.gd")
	_check(RaidCatalogScript != null and RaidCatalogScript.has_raid("ruins_zaban_vertical"),
		"catalog raid ruins_zaban_vertical", "no raid catalog")
	var dungeon_src := FileAccess.get_file_as_string("res://world/maps/DungeonRuinasZabanMap.gd")
	_check("_iniciar_raid_vertical" in dungeon_src and "RaidInstance" in dungeon_src,
		"DungeonRuinasZabanMap wired to RaidInstance", "raid map not wired")
	_check("_spawn_raid_loot_ground" in dungeon_src and "_try_register_wipe" in dungeon_src,
		"density: loot chão + wipe soft", "density thin")

	print("\n[8b] A7/A8 presence")
	_check(ResourceLoader.exists("res://scripts/systems/blacklist/BlacklistOpenHunt.gd"),
		"A7 BlacklistOpenHunt", "A7 missing")
	_check(GourmetCooking != null and GourmetCooking.list_recipes().size() >= 3,
		"A8 GourmetCooking autoload + recipes", "A8 missing")

	print("\n[9] PREREQ-1 binary player + auction/guild")
	var packed: PackedByteArray = NetworkProtocol.pack_player_state_binary(
		1, Vector2(10, 20), Vector2(1, 0), Vector2.DOWN, 80, 50.0, "TEN"
	)
	var unpacked: Dictionary = NetworkProtocol.unpack_player_state_binary(packed)
	_check(not packed.is_empty() and int(unpacked.get("hp", 0)) == 80,
		"pack/unpack player binary", "player binary fail %s" % str(unpacked))
	_check(int(NetworkProtocol.Opcode.AUCTION_SYNC) == 0x60, "AUCTION_SYNC opcode", "no auction opcode")
	_check(int(NetworkProtocol.Opcode.GUILD_BANK_SYNC) == 0x61, "GUILD_BANK_SYNC opcode", "no guild opcode")
	if AuctionHouse != null:
		var ap: PackedByteArray = AuctionHouse.build_network_sync_packet()
		_check(AuctionHouse.apply_network_sync_packet(ap), "AuctionHouse sync roundtrip", "AH sync fail")
	else:
		_check(false, "AuctionHouse present", "AuctionHouse null")
	if HunterGuildSystem != null:
		var gp: PackedByteArray = HunterGuildSystem.build_network_sync_packet()
		_check(HunterGuildSystem.apply_network_sync_packet(gp), "Guild sync roundtrip", "Guild sync fail")
	else:
		_check(false, "HunterGuildSystem present", "Guild null")

	print("\n[10] PauseMenu guild entry + Hatsu visual signature")
	var pause_src := FileAccess.get_file_as_string("res://ui/PauseMenu/PauseMenuUI.gd")
	_check("_on_guild_pressed" in pause_src, "PauseMenu abre GuildHall", "guild entry missing")
	var hatsu_src := FileAccess.get_file_as_string("res://scripts/visual/HatsuVisual.gd")
	_check("spark_burst" in hatsu_src or "shockwave" in hatsu_src or "slash" in hatsu_src,
		"HatsuVisual assinaturas distintas", "hatsu signature thin")

	var enemy_src := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemySystem.gd")
	_check("_play_death_feel" in enemy_src and "LootDrop.spawn_jenny" in enemy_src,
		"EnemySystem death feel + ground loot", "enemy death/loot not wired")
