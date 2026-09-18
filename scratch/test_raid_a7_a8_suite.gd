extends Node2D

# ============================================================
# HUNTER ONLINE — RAID DENSITY + A7 BLACKLIST + A8 GOURMET
# ============================================================

const BlacklistOpenHuntScript = preload("res://scripts/systems/blacklist/BlacklistOpenHunt.gd")

var _ok := 0
var _total := 0
var _pass := true


func _ready() -> void:
	print("================================================================================")
	print("🚀 SUÍTE RAID DENSITY + A7 OPEN HUNT + A8 GOURMET")
	print("================================================================================")
	await get_tree().process_frame
	_run()
	print("--------------------------------------------------------------------------------")
	print("RESULTADO: %d/%d" % [_ok, _total])
	if _pass:
		print("✅ RAID/A7/A8 SUITE PASSED")
		get_tree().quit(0)
	else:
		print("❌ RAID/A7/A8 SUITE FAILED")
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
	_test_raid_density()
	_test_a7_open_hunt()
	_test_a8_gourmet()


func _test_raid_density() -> void:
	print("\n[1] Raid Zaban density")
	var dungeon_src := FileAccess.get_file_as_string("res://world/maps/DungeonRuinasZabanMap.gd")
	_check("_aplicar_fase_no_boss" in dungeon_src, "fase → AI boss", "fase AI missing")
	_check("_spawn_raid_loot_ground" in dungeon_src and "LootDrop.spawn_jenny" in dungeon_src,
		"loot no chão ao clear", "ground loot missing")
	_check("_try_register_wipe" in dungeon_src and "_respawn_soft_checkpoint" in dungeon_src,
		"wipe debounce + checkpoint", "wipe soft missing")
	_check("BossIntroBanner.exibir" in dungeon_src, "BossIntroBanner static", "banner call wrong")
	_check("_dica_fase_solo" in dungeon_src and "_criar_placa_checkpoint_entrada" in dungeon_src,
		"solo tips + placa checkpoint", "solo polish missing")
	_check("_on_raid_enrage_warning" in dungeon_src and "_solo_mode" in dungeon_src,
		"enrage warning + solo mode", "enrage warn missing")

	var ai_src := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_check("aoe_circle" in ai_src and "_criar_indicador_chao_aoe" in ai_src,
		"telegraph AoE circle", "telegraph thin")
	_check("SAIA DO CÍRCULO" in ai_src and "is_boss" in ai_src,
		"telegraph solo-readable boss", "telegraph too short/unlabeled")

	var raid_src := FileAccess.get_file_as_string("res://scripts/network/RaidInstance.gd")
	_check("enrage_warning" in raid_src and "is_solo" in raid_src,
		"RaidInstance enrage_warning + is_solo", "raid solo API missing")

	var RaidCatalogScript = load("res://resource/raid/RaidCatalog.gd")
	var entry: Dictionary = RaidCatalogScript.get_raid("ruins_zaban_vertical")
	_check((entry.get("phases", []) as Array).size() >= 3, ">=3 fases no catálogo", "phases thin")

	var RaidInstanceScript = load("res://scripts/network/RaidInstance.gd")
	var raid = RaidInstanceScript.new()
	var members: Array[int] = [1]
	_check(raid.start_raid("ruins_zaban_vertical", members, entry), "start raid solo", "start fail")
	_check(raid.is_solo == true, "is_solo=true com 1 membro", "is_solo false")
	# Aviso de enrage ANTES de entrar na fase enrage por HP
	raid.enrage_seconds = 50.0
	raid.tick_enrage(0.016)
	_check(raid.enrage_warning_emitted == true, "enrage_warning emitido em <=60s", "warn missing")
	raid.update_boss_hp_ratio(0.69)
	raid.update_boss_hp_ratio(0.44)
	raid.update_boss_hp_ratio(0.19)
	_check(raid.current_phase_index >= 2, "avança 3 fases reais", "phase=%d" % raid.current_phase_index)
	raid.register_wipe()
	_check(raid.wipe_count == 1, "wipe contabilizado", "wipe fail")
	var result: Dictionary = raid.complete_raid()
	_check(not (result.get("loot", []) as Array).is_empty(), "loot no complete_raid", "no loot")


func _test_a7_open_hunt() -> void:
	print("\n[2] A7 Blacklist open hunt")
	_check(ResourceLoader.exists("res://scripts/systems/blacklist/BlacklistOpenHunt.gd"),
		"BlacklistOpenHunt existe", "A7 script missing")
	var hunts: Array = BlacklistOpenHuntScript.list_open_hunts()
	_check(hunts.size() >= 2, ">=2 open hunts catalogadas", "catalog thin")
	_check(BlacklistOpenHuntScript.is_open_hunt("bounty_cacador_renegado_zaban"),
		"Karkov marcado open_hunt", "karkov not open")
	_check(BountySystem != null and bool(BountySystem.active_bounty_contracts.get("bounty_cacador_renegado_zaban", {}).get("open_hunt", false)),
		"BountySystem open_hunt flag", "bounty flag missing")

	BlacklistOpenHuntScript.active_hunts.clear()
	var res: Dictionary = BlacklistOpenHuntScript.iniciar_caca("bounty_cacador_renegado_zaban", self)
	_check(bool(res.get("ok", false)), "iniciar_caca Karkov ok", "start fail: %s" % str(res))
	_check(BlacklistOpenHuntScript.active_hunts.has("bounty_cacador_renegado_zaban"),
		"caça ativa registrada", "active missing")
	var coord = res.get("coordinator")
	_check(coord != null and coord.has_method("registrar_dano"), "coordinator threat API", "coord missing")
	if coord != null:
		coord.registrar_dano(1, 500, false)
		var rewards: Dictionary = coord.calcular_recompensas_coop(4000, 150000, "licenca_hunter")
		_check(rewards.has(1), "loot por contribuição peer 1", "contrib loot fail")
	BlacklistOpenHuntScript.limpar_caca("bounty_cacador_renegado_zaban")
	_check(not BlacklistOpenHuntScript.active_hunts.has("bounty_cacador_renegado_zaban"),
		"limpar_caca limpa estado", "cleanup fail")

	var board_src := FileAccess.get_file_as_string("res://ui/Bounties/BountiesBoardUI.gd")
	_check("Iniciar Caça Aberta" in board_src and "BlacklistOpenHunt.iniciar_caca" in board_src,
		"BountiesBoardUI wire open hunt", "board not wired")


func _test_a8_gourmet() -> void:
	print("\n[3] A8 Gourmet life skills")
	_check(GourmetCooking != null, "GourmetCooking autoload", "autoload missing")
	_check(GourmetCooking.list_recipes().size() >= 3, ">=3 receitas", "recipes thin")
	_check(ResourceLoader.exists("res://ui/Gourmet/GourmetKitchenUI.gd"),
		"GourmetKitchenUI existe", "kitchen UI missing")

	if FactionManager != null:
		FactionManager.faccao_atual = "gourmet"
	if PlayerData != null:
		PlayerData.faccao_atual = "gourmet"
		PlayerData.adicionar_item(&"carne_javali", 5)
		PlayerData.adicionar_item(&"erva_nen", 5)
	if Economy != null:
		Economy.adicionar_gold(500)

	GourmetCooking.garantir_writs_diarios(true)
	_check(GourmetCooking.obter_writs().size() >= 2, "writs diários", "writs missing")

	var cook: Dictionary = GourmetCooking.cozinhar("ensopado_javali")
	_check(bool(cook.get("ok", false)), "cozinhar ensopado", "cook fail: %s" % str(cook))
	var food_id := str(cook.get("food_id", "food_ensopado_javali"))
	var eat: Dictionary = GourmetCooking.consumir_comida(food_id)
	_check(bool(eat.get("ok", false)), "consumir comida buff", "eat fail: %s" % str(eat))
	_check(str(eat.get("stat", "")) != "", "buff stat aplicado", "no buff stat")

	GourmetCooking.coletar_ingrediente("erva_nen", 3)
	var save_d: Dictionary = GourmetCooking.salvar_dados()
	_check(save_d.has("writ_day"), "salvar_dados gourmet", "save thin")
	GourmetCooking.carregar_dados(save_d)
	_check(true, "carregar_dados gourmet", "load crash")

	var menchi_src := FileAccess.get_file_as_string("res://entities/npc/gourmet/Menchi.gd")
	_check("_abrir_cozinha" in menchi_src and "GourmetKitchenUI" in menchi_src,
		"Menchi abre cozinha", "Menchi not wired")

	_check("gourmet" in FileAccess.get_file_as_string("res://autoload/GourmetCooking.gd"),
		"source gourmet (não compete Nen)", "source wrong")
