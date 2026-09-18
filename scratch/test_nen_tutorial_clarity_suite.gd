extends SceneTree

# Suite: Nen tutorial clarity (skill tree + Gyo/En/Zetsu)

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
	print("\n=== NEN TUTORIAL CLARITY SUITE ===\n")

	var tut := _read("res://autoload/TutorialManager.gd")
	_assert(not tut.is_empty(), "TutorialManager presente")
	_assert("nen_arvore_sp" in tut, "artigo Constelação Nen")
	_assert("nen_ativos_gyo_en_zetsu" in tut, "artigo ativos Gyo/En/Zetsu")
	_assert("once_map" in tut, "anti-spam once_map")
	_assert("\"nen_arvore\"" in tut or "'nen_arvore'" in tut, "tip nen_arvore")
	_assert("\"nen_ativos\"" in tut or "'nen_ativos'" in tut, "tip nen_ativos")
	_assert("[Z]" in tut and "[G]" in tut and "[X]" in tut, "atalhos Z/G/X no texto")
	_assert("Biscuit" in tut and "Greed Island" in tut, "gate narrativo Hatsu citado")
	_assert("sistemas_atalhos" in tut, "artigo atalhos")
	_assert("perfect_dodge_maestria" in tut, "artigo Perfect Dodge")

	var wing := _read("res://entities/npc/wing/Wing.gd")
	_assert("Nen Tree" in wing or "Constelação" in wing, "Wing explica árvore")
	_assert("[Z]" in wing and "[G]" in wing and "[X]" in wing, "Wing explica ativos")
	_assert("Biscuit" in wing, "Wing cita gate Biscuit")

	var quest := _read("res://resource/quest/PadokiaQuestCatalog.gd")
	_assert("Três passos claros" in quest, "quest principal menos vaga")
	_assert("Nen Tree" in quest or "SP" in quest, "quest menciona SP/árvore")

	var gen := _read("res://world/generator/RegionWorldGenerator.gd")
	_assert("Feirante Lena" in gen and "Aprendiz de Nen" in gen, "NPCs extras na vila")

	print("\n=== RESULTADO: %d passed, %d failed ===\n" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
