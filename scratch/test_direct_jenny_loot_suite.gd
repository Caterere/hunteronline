extends Node

# ============================================================
# Suite: Jenny/XP direto (sem orbs no chão)
# godot --headless --path . res://scratch/test_direct_jenny_loot_suite.tscn
# ============================================================

const LootDropScript = preload("res://entities/world/LootDrop.gd")

var _pass := 0
var _fail := 0


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("=== test_direct_jenny_loot_suite ===")
	_test_static_no_area2d()
	await _test_jenny_direct_grant()
	await _test_item_direct_grant()
	_test_enemy_system_wiring()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_static_no_area2d() -> void:
	print("-- static --")
	var src := FileAccess.get_file_as_string("res://entities/world/LootDrop.gd")
	assert_test("extends RefCounted" in src, "LootDrop não é mais Area2D")
	assert_test("body_entered" not in src, "sem body_entered de pickup")
	assert_test("collision_mask" not in src, "sem collision_mask (root cause: player layer 2)")
	assert_test("Economy.adicionar_gold" in src, "Jenny via Economy.adicionar_gold")
	assert_test("PlayerData.adicionar_item" in src, "itens via PlayerData.adicionar_item")
	var enemy := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemySystem.gd")
	assert_test("sem orbs no chão" in enemy or "LOOT DIRETO" in enemy, "EnemySystem grant direto")


func _test_jenny_direct_grant() -> void:
	print("-- jenny direct --")
	if Economy == null or PlayerData == null:
		assert_test(false, "Economy/PlayerData disponíveis")
		return

	var before: int = Economy.obter_gold()
	LootDropScript.spawn_jenny(self, Vector2(40, 20), 77)
	await get_tree().process_frame
	var after: int = Economy.obter_gold()
	assert_test(after == before + 77, "Jenny +77 imediato (antes=%d depois=%d)" % [before, after])
	var leftover := 0
	for c in get_children():
		if c is Area2D:
			leftover += 1
	assert_test(leftover == 0, "nenhuma orb Area2D residual")


func _test_item_direct_grant() -> void:
	print("-- item direct --")
	if PlayerData == null:
		assert_test(false, "PlayerData disponível")
		return
	var item_id := &"pocao_hp"
	var before: int = int(PlayerData.inventory.get(item_id, 0))
	LootDropScript.spawn_item_drop(self, Vector2(10, 10), "pocao_hp")
	await get_tree().process_frame
	var after: int = int(PlayerData.inventory.get(item_id, 0))
	assert_test(after >= before + 1, "item +1 no inventário (antes=%d depois=%d)" % [before, after])


func _test_enemy_system_wiring() -> void:
	print("-- enemy wiring --")
	var src := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemySystem.gd")
	assert_test("_entregar_xp" in src, "XP continua via _entregar_xp")
	assert_test("LootDrop.spawn_jenny" in src, "Jenny via LootDrop.spawn_jenny")
	assert_test("elif qtd_gold > 0 and Economy" not in src, "sem fallback duplicado legado")
