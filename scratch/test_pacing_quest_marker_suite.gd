extends SceneTree

var _passed: int = 0
var _failed: int = 0


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  ✅ PASS: ", msg)
	else:
		_failed += 1
		print("  ❌ FAIL: ", msg)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _initialize() -> void:
	print("\n=== PACING + QUEST MARKER SUITE ===\n")
	var player := _read("res://entities/Player/Player.gd")
	_assert("_move_speed: float = 112.0" in player, "player walk base 112")
	_assert("148.0" in player, "sprint ~148")
	var dodge := _read("res://entities/Player/states/Dodge.gd")
	_assert("270.0" in dodge, "dodge 270")
	var ai := _read("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_assert("move_speed: float = 58.0" in ai, "enemy move 58")
	_assert("attack_cooldown: float = 1.55" in ai, "enemy CD 1.55")

	var marker := _read("res://entities/npc/QuestMarkerBillboard.gd")
	_assert("class_name QuestMarkerBillboard" in marker, "QuestMarkerBillboard existe")
	_assert("Kind.OBJECTIVE" in marker, "kind objective")
	var npc := _read("res://entities/npc/NPC.gd")
	_assert("QuestMarkerBillboard" in npc, "NPC usa marcador")
	var qm := _read("res://scripts/missions/QuestManager.gd")
	_assert("obter_estado_marcador_npc" in qm, "API marcador quest")

	var tut := _read("res://autoload/TutorialManager.gd")
	_assert("um objetivo de cada vez" in tut.to_lower() or "UMA coisa por vez" in tut, "Elena direta")
	var wing := _read("res://entities/npc/wing/Wing.gd")
	_assert("NESTA ordem" in wing or "um objetivo" in wing.to_lower(), "Wing direto")

	var kit := _read("res://scripts/systems/hatsu/HatsuSignatureKit.gd")
	_assert("INTENSIFICACAO" in kit and "EMISSAO" in kit and "MANIPULACAO" in kit, "telegraph por afinidade")

	print("\n=== RESULTADO: %d passed, %d failed ===\n" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
