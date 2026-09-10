extends Node

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []

const NPCS := [
	"npc_hisoka",
	"npc_netero",
	"npc_biscuit",
	"npc_chrollo",
	"npc_tonpa",
	"npc_ging",
	"npc_hanzo",
	"npc_menchi",
	"npc_pokkle",
	"npc_ponzu",
	"npc_battera",
	"npc_melody",
	"npc_mordoma_canary",
	"npc_mordomo_gotoh",
	"npc_silva_zoldyck",
	"npc_tsezguerra",
	"npc_buhara",
	"npc_gittarackur",
	"npc_bodoro",
	"npc_nicol",
]


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 SECONDARY CAST HYBRID STYLE LOCK SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_pipeline_meta()
	_test_geometry()
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


func _test_pipeline_meta() -> void:
	print("\n[1] Pipeline meta...")
	_ok(FileAccess.file_exists("res://scripts/tools/pixellab_regen_secondary_cast_hybrid.py"), "hybrid secondary script")
	_ok(FileAccess.file_exists("res://assets/sprites/tilesets/pixellab/secondary_cast_hybrid_stylelock.json"), "hybrid jobs json")


func _opaque_bbox(img: Image) -> Rect2i:
	var min_x := img.get_width()
	var min_y := img.get_height()
	var max_x := -1
	var max_y := -1
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.06:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _test_geometry() -> void:
	print("\n[2] Sheets + Style Lock geometry...")
	for name in NPCS:
		var sheet_path := "res://assets/sprites/characters/%s_8dir.png" % name
		var south_path := "res://assets/sprites/characters/%s_rotations/south.png" % name
		_ok(ResourceLoader.exists(sheet_path), "sheet %s" % name)
		_ok(ResourceLoader.exists(south_path), "south %s" % name)
		if not ResourceLoader.exists(south_path):
			continue
		var tex: Texture2D = load(south_path)
		_ok(tex != null and tex.get_width() == 48 and tex.get_height() == 48, "48x48 %s" % name)
		if tex == null:
			continue
		var img := tex.get_image()
		var bb := _opaque_bbox(img)
		_ok(bb.size.y >= 17 and bb.size.y <= 24, "%s height %d in 17..24" % [name, bb.size.y])
		_ok(bb.position.y + bb.size.y - 1 >= 40 and bb.position.y + bb.size.y - 1 <= 44, "%s feetY %d in 40..44" % [name, bb.position.y + bb.size.y - 1])
