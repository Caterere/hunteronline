extends Node

## MMORPG evolution Phase 1 — rich maps, PD juice, mastery real, chests, DNS, HUD
## godot --headless --path . res://scratch/test_mmorpg_evolution_phase1_suite.tscn

var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== mmorpg evolution phase1 ===")
	_test_playtest_default_off()
	_test_pd_juice()
	_test_damage_number_ssot()
	_test_chest_sprites()
	await _test_mastery_moment()
	_test_hud_scale()
	print("=== RESULT: %d pass / %d fail ===" % [_ok, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✅ ", msg)
	else:
		_fail += 1
		print("  ❌ ", msg)


func _test_playtest_default_off() -> void:
	_assert(PlaytestVisualMode.ENABLED_DEFAULT == false, "ENABLED_DEFAULT false")
	_assert(not PlaytestVisualMode.is_enabled(), "is_enabled false sem setting")


func _test_pd_juice() -> void:
	var combat := FileAccess.get_file_as_string("res://scripts/combat/CombatSystem.gd")
	_assert("spawn_aura_burst" in combat and "_executar_perfect_dodge" in combat, "PD chama aura_burst")
	_assert("spawn_dust_kickup" in combat, "PD chama dust_kickup")
	_assert("spawn_perfect_dodge" in combat, "PD chama DamageNumberSystem.spawn_perfect_dodge")
	_assert(DamageNumberSystem.has_method("spawn_perfect_dodge"), "API spawn_perfect_dodge")


func _test_damage_number_ssot() -> void:
	var esys := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemySystem.gd")
	_assert("DamageNumberSystem.spawn_dano" in esys, "EnemySystem usa DamageNumberSystem")
	var dns := FileAccess.get_file_as_string("res://autoload/DamageNumberSystem.gd")
	_assert("EnemySystem" in dns and "SSOT" in dns, "DNS pula EnemySystem no combat_hit_landed")


func _test_chest_sprites() -> void:
	_assert(ResourceLoader.exists(MidLateDensityKit.PATH_CHEST_WOOD), "chest_01.png")
	_assert(ResourceLoader.exists(MidLateDensityKit.PATH_CHEST_GOLD), "chest_02.png")
	var kit := FileAccess.get_file_as_string("res://world/components/exploration/MidLateDensityKit.gd")
	_assert("PATH_CHEST_WOOD" in kit and "_aplicar_sprite_bau" in kit, "kit aplica sprite bau")
	_assert("nen_stone_monolith" in kit, "fallback monolith preservado")
	var floresta := FileAccess.get_file_as_string("res://world/maps/FlorestaVestigiosMap.gd")
	_assert("MidLateDensityKitScript.spawna_bau" in floresta, "Floresta delega baús ao kit")
	var ruinas := FileAccess.get_file_as_string("res://world/maps/DungeonRuinasZabanMap.gd")
	_assert("_aplicar_sprite_bau" in ruinas, "Ruínas baú dourado com sprite")


func _test_mastery_moment() -> void:
	var kit := FileAccess.get_file_as_string("res://world/components/exploration/MidLateDensityKit.gd")
	_assert('attributes["hatsu_mastery"]' not in kit, "sem atributo fantasma hatsu_mastery")
	_assert('PlayerData.attributes["hatsu_mastery"]' not in kit, "sem escrita no contador fantasma")
	_assert("_conceder_mastery_real_momento" in kit, "mastery real no momento Hatsu")

	# Bypass forge lock (Greed/Biscuit) — injeta Hatsu direto no archive local
	PlayerData.hatsu_criados.clear()
	PlayerData.hatsu_slots = [-1, -1, -1, -1]
	var h := HatsuData.new()
	h.hatsu_id = "test_moment_hatsu"
	h.nome = "Eco Teste"
	h.mastery = 0.0
	h.mastery_xp = 0.0
	PlayerData.hatsu_criados.append(h)
	PlayerData.hatsu_slots[0] = 0

	var msg: String = MidLateDensityKit._conceder_mastery_real_momento()
	_assert(not msg.is_empty(), "mensagem mastery não vazia")
	_assert(int(h.mastery) >= 10, "momento concede ~+10 mastery (got %d)" % int(h.mastery))
	await get_tree().process_frame


func _test_hud_scale() -> void:
	var q := FileAccess.get_file_as_string("res://ui/hud/QuestHUD.gd")
	_assert("1.0" in q, "QuestHUD 1.0")
	var g := FileAccess.get_file_as_string("res://ui/hud/MissionGPSIndicator.gd")
	_assert("1.0" in g, "GPS 1.0")
