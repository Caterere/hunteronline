extends Node

var _ok_count := 0
var _total := 0


func _ready() -> void:
	print("\n================================================================")
	print("🎯 SUÍTE B10: DUTY FINDER")
	print("================================================================")
	_check(DutyFinderSystem != null, "autoload DutyFinderSystem")
	var duties := DutyFinderSystem.listar_duties()
	_check(duties.size() >= 3, "catálogo com dungeon/raid/arena")
	DutyFinderSystem.fill_with_stubs = true
	DutyFinderSystem.sair_fila()
	var join := DutyFinderSystem.entrar_fila("dungeon_zaban", ["tank"])
	_check(bool(join.get("ok", false)), "entrar na fila dungeon")
	_check(DutyFinderSystem.state == DutyFinderSystem.QueueState.MATCHED, "match stub preenchido")
	_check(DutyFinderSystem.last_match.get("party", []).size() == 4, "party size 4")
	var confirm := DutyFinderSystem.confirmar_match()
	_check(bool(confirm.get("ok", false)), "confirmar match")
	_check(DutyFinderSystem.state == DutyFinderSystem.QueueState.IDLE, "volta para IDLE")
	var raid := DutyFinderSystem.entrar_fila("raid_ruins_8", ["dps"])
	_check(bool(raid.get("ok", false)), "fila raid 8")
	_check(DutyFinderSystem.last_match.get("party", []).size() == 8, "raid party 8")
	DutyFinderSystem.sair_fila()
	_check(not DutyFinderSystem.esta_na_fila(), "saiu da fila")
	var data := DutyFinderSystem.salvar_dados()
	DutyFinderSystem.carregar_dados(data)
	_check(data.has("fill_with_stubs"), "persistência serializa")
	print("\nRESULTADO: %d/%d" % [_ok_count, _total])
	if _ok_count == _total:
		print("✅ B10 DUTY FINDER SUITE PASSED")
	else:
		printerr("❌ B10 DUTY FINDER SUITE FAILED")
	get_tree().quit(0 if _ok_count == _total else 1)


func _check(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_ok_count += 1
		print("  ✅ [PASS] ", label)
	else:
		print("  ❌ [FAIL] ", label)
