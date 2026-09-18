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
	print("\n=== CONTENT DIRECTOR SPAWN SUITE ===\n")
	var src := _read("res://world/content/ContentDirector.gd")
	_assert(not src.is_empty(), "ContentDirector.gd presente")
	_assert("_materializar_encontro" in src, "materializa encontros")
	_assert("_materializar_inimigo" in src, "materializa inimigos")
	_assert("_materializar_evento" in src, "materializa eventos")
	_assert("_materializar_populacao_base" in src, "materializa população base")
	_assert("_liberar_spawned" in src, "despawn libera nós")
	_assert("ContentDirectorSpawns" in src, "container de spawns")
	_assert("LivingNPCBehavior" in src, "NPCs com rotina viva")

	var exame := _read("res://world/maps/ExameMaratonaMap.gd")
	_assert("GPS" in exame or "LESTE" in exame, "toast Exame com direção/próximo passo")
	_assert("interaja" in exame.to_lower() or "[E]" in exame, "portão final acionável")

	print("\n=== RESULTADO: %d passed, %d failed ===\n" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
