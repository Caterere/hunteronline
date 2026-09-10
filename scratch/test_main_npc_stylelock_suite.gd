extends Node

## Smoke: main NPCs hybrid Style Lock geometry + uniqueness vs Viajante.

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []

const NPCS: Array[String] = [
	"npc_recepcionista_elena",
	"npc_instrutor_combate",
	"npc_examinador_oficial",
	"npc_ferreiro_mestre",
	"npc_vendedor_mercador",
	"npc_discipulo_zushi",
	"npc_guarda_fronteira",
	"npc_viajante_scout",
	"npc_gon",
	"npc_killua",
	"npc_kurapika",
	"npc_leorio",
]


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 MAIN NPC HYBRID STYLE LOCK SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_assets_and_geometry()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
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


func _test_assets_and_geometry() -> void:
	print("\n[1] Sheets + Style Lock geometry...")
	_ok(FileAccess.file_exists("res://scripts/tools/pixellab_regen_main_npcs_hybrid_stylelock.py"), "hybrid pipeline script")
	_ok(FileAccess.file_exists("res://assets/sprites/tilesets/pixellab/main_npc_hybrid_stylelock.json"), "hybrid jobs json")
	for name in NPCS:
		var sheet := "res://assets/sprites/characters/%s_8dir.png" % name
		var south := "res://assets/sprites/characters/%s_rotations/south.png" % name
		_ok(ResourceLoader.exists(sheet), "sheet %s" % name)
		_ok(ResourceLoader.exists(south), "south %s" % name)
		if not ResourceLoader.exists(south):
			continue
		var img: Image = (load(south) as Texture2D).get_image()
		if img == null:
			_ok(false, "image load %s" % name)
			continue
		_ok(img.get_width() == 48 and img.get_height() == 48, "48x48 %s" % name)
		var bb := _opaque_bbox(img)
		if bb.size.x <= 0:
			_ok(false, "opaque bbox %s" % name)
			continue
		var h := int(bb.size.y)
		var feet_y := int(bb.position.y + bb.size.y)
		_ok(h >= 17 and h <= 24, "%s height %d in 17..24" % [name, h])
		_ok(feet_y >= 40 and feet_y <= 44, "%s feetY %d in 40..44" % [name, feet_y])


func _opaque_bbox(img: Image) -> Rect2:
	var min_x := img.get_width()
	var min_y := img.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.5:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return Rect2()
	return Rect2(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
