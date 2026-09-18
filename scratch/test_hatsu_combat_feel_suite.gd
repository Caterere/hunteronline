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
	print("\n=== HATSU COMBAT FEEL SUITE ===\n")
	var hs := _read("res://scripts/systems/HatsuSystem.gd")
	_assert("await owner_body.get_tree().create_timer" in hs, "canalização await")
	_assert("SlotState.ACTIVATING" in hs, "estado ACTIVATING")
	_assert("telegraph_cast" in hs, "telegraph no cast")
	_assert("_aplicar_feel_impacto_hatsu" in hs, "feel de impacto")
	_assert("HitStopManager" in hs, "hitstop wired")
	_assert("enemy_sys.take_damage" in hs, "take_damage ainda existe no helper")
	# helper must call take_damage, not recurse
	_assert("func _aplicar_feel_impacto_hatsu" in hs and hs.count("_aplicar_feel_impacto_hatsu(enemy_sys, dano, direcao, forca, hatsu)") <= 1, "sem recursão no helper")

	var kit := _read("res://scripts/systems/hatsu/HatsuSignatureKit.gd")
	_assert("func telegraph_cast" in kit, "API telegraph_cast pública")

	var story := _read("res://autoload/StoryManager.gd")
	_assert("Biscuit" in story and "Greed Island concluída" in story, "toast GI→Biscuit")

	var bisc := _read("res://entities/npc/biscuit/Biscuit.gd")
	_assert("hatsu_desbloqueio" in bisc, "Biscuit dispara tip de desbloqueio")

	var data := _read("res://resource/hatsu/HatsuData.gd")
	_assert("obter_tempo_conjuracao_final" in data, "tempo de conjuração existe")

	print("\n=== RESULTADO: %d passed, %d failed ===\n" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
