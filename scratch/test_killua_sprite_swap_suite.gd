extends Node

# godot --headless --path . res://scratch/test_killua_sprite_swap_suite.tscn

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
	print("=== test_killua_sprite_swap_suite ===")
	assert_test(ResourceLoader.exists("res://assets/sprites/characters/npc_killua.png"), "npc_killua.png exists")
	assert_test(ResourceLoader.exists("res://assets/sprites/characters/npc_killua_8dir.png"), "npc_killua_8dir.png exists")
	var tex8: Texture2D = load("res://assets/sprites/characters/npc_killua_8dir.png")
	assert_test(tex8 != null, "8dir loads")
	if tex8 != null:
		assert_test(tex8.get_width() == 384 and tex8.get_height() == 48, "8dir is 384x48")
	var tex1: Texture2D = load("res://assets/sprites/characters/npc_killua.png")
	assert_test(tex1 != null and tex1.get_width() == 48 and tex1.get_height() == 48, "single is 48x48")

	var scn = load("res://entities/npc/killua/Killua.tscn")
	assert_test(scn != null, "Killua.tscn loads")
	var node = scn.instantiate()
	add_child(node)
	await get_tree().process_frame
	var spr: Sprite2D = node.get_node_or_null("Sprite2D")
	assert_test(spr != null, "Killua has Sprite2D")
	if spr != null:
		assert_test(spr.hframes == 8, "Killua Sprite2D hframes=8")
		assert_test(spr.texture != null, "Killua texture assigned")
		if spr.texture != null:
			assert_test(str(spr.texture.resource_path).ends_with("npc_killua_8dir.png"), "uses npc_killua_8dir.png")

	assert_test(FileAccess.file_exists("res://assets/sprites/characters/creator_variants/player_variant_hair_killua.png"), "hair variant asset")
	assert_test(FileAccess.file_exists("res://assets/sprites/characters/creator_variants/player_variant_outfit_hunter.png"), "outfit variant asset")
	var db_src := FileAccess.get_file_as_string("res://entities/character_creator/CharacterAssetDatabase.gd")
	assert_test("hair_killua_spiky_02" in db_src, "new hair id registered")
	assert_test("player_variant_outfit_hunter.png" in db_src, "outfit preview registered")

	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)
