extends Node

## Runner Node que executa as asserções estáticas do clarity audit.

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


func _ready() -> void:
	await get_tree().process_frame
	print("\n=== CLARITY AUDIT FIXES SUITE ===\n")

	print("[1] ItemExplainKit exists & API")
	var kit_src := _read("res://ui/common/ItemExplainKit.gd")
	_assert(not kit_src.is_empty(), "ItemExplainKit.gd presente")
	_assert("resolver_item" in kit_src, "API resolver_item")
	_assert("formatar_detalhes" in kit_src, "API formatar_detalhes")

	print("\n[2] Inventory + HunterMenu wiring")
	var inv := _read("res://ui/inventory/InventoryUI.gd")
	_assert("ItemExplainKit" in inv, "InventoryUI usa ItemExplainKit")
	_assert("ItemLoreTooltip" in inv, "InventoryUI usa ItemLoreTooltip")

	print("\n[3] TutorialManager articles")
	var tut := _read("res://autoload/TutorialManager.gd")
	_assert("CATALOGO_CONHECIMENTOS" in tut, "catálogo de conhecimentos")
	_assert("disparar_tutorial_contextual" in tut, "API tutorial contextual")

	print("\n[4] CombatSystem Perfect Dodge")
	var combat := _read("res://scripts/combat/CombatSystem.gd")
	_assert("perfect_dodge" in combat, "dispara tip perfect_dodge")

	print("\n[5] XPSystem level-up clarity")
	var xp := _read("res://scripts/systems/XPSystem.gd")
	_assert("delta_txt" in xp or "partes_delta" in xp, "deltas de atributos")
	_assert("toast_msg" in xp and "SP" in xp, "toast com SP")

	print("\n[6] ComicBalloon tema Hunter")
	var ball := _read("res://scripts/ui/ComicBalloon.gd")
	_assert("HunterUIStyle" in ball, "usa HunterUIStyle")
	_assert("0.74, 0.64, 0.44" in ball, "default pergaminho")

	print("\n[7] PauseMenu + NenTree")
	var pause := _read("res://ui/PauseMenu/PauseMenuUI.gd")
	_assert("Sistemas" in pause, "botão sistemas")
	_assert("Conquistas" in pause, "botão conquistas")

	print("\n=== RESULTADO: %d passed, %d failed ===" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)
