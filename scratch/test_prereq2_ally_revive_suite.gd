extends Node2D

## ============================================================
## PREREQ-2 — Ally revive channel (ServerWorldCoordinator)
## ============================================================

const CoordinatorScript = preload("res://scripts/network/ServerWorldCoordinator.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0


func _ready() -> void:
	print("\n================================================================")
	print("💉 SUÍTE: PREREQ-2 ALLY REVIVE (canalização 3s)")
	print("================================================================")
	_test_downed_state_and_channel()
	_test_out_of_range_and_interrupt()
	_print_summary()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)


func assert_test(cond: bool, label: String) -> void:
	total_tests += 1
	if cond:
		passed_tests += 1
		print("  ✅ %s" % label)
	else:
		failed_tests += 1
		print("  ❌ %s" % label)


func _print_summary() -> void:
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d passou | %d falhou" % [passed_tests, total_tests, failed_tests])
	print("================================================================\n")


func _make_coord() -> RefCounted:
	var coord = CoordinatorScript.new(20, "res://world/lobby.tscn")
	coord.start_coordinator()
	coord.register_player(1, {"name": "Reviver", "attributes": {"vida": 100, "vida_max": 100, "aura": 100, "aura_max": 100}}, Vector2(100, 100))
	coord.register_player(2, {"name": "Downed", "attributes": {"vida": 100, "vida_max": 100, "aura": 100, "aura_max": 100}}, Vector2(120, 100))
	return coord


func _test_downed_state_and_channel() -> void:
	print("\n[1] Desmaio + canalização completa")
	var coord = _make_coord()
	coord._matar_jogador(2, 99)
	assert_test(bool(coord.players[2].get("is_dead", false)), "P2 está desmaiado")
	assert_test(float(coord.players[2].get("respawn_timer", 0.0)) >= 10.0, "Timer de desmaio longo (>=10s)")
	assert_test(coord.players[2].has("downed_pos"), "downed_pos gravado")

	var far: Dictionary = coord.begin_ally_revive(1, 2)
	# P1 está a ~20px — deve funcionar
	var near: Dictionary = far if bool(far.get("ok", false)) else coord.begin_ally_revive(1, 2)
	assert_test(bool(near.get("ok", false)), "Revive inicia em range (%s)" % str(near.get("reason", "")))

	for _i in range(70):
		coord.tick_ally_revive_channels(0.05)

	assert_test(not bool(coord.players[2].get("is_dead", true)), "P2 revivido após ~3.5s de canal")
	assert_test(int(coord.players[2].get("hp", 0)) > 0, "P2 tem HP parcial")
	assert_test(int(coord.players[2].get("hp", 0)) < int(coord.players[2].get("hp_max", 100)), "HP parcial < max")
	coord.stop_coordinator()


func _test_out_of_range_and_interrupt() -> void:
	print("\n[2] Fora de alcance + interrupção")
	var coord = _make_coord()
	coord._matar_jogador(2, 1)
	coord.players[1]["position"] = Vector2(900, 900)
	var bad: Dictionary = coord.begin_ally_revive(1, 2)
	assert_test(not bool(bad.get("ok", true)), "Rejeita fora de alcance (%s)" % str(bad.get("reason", "")))

	coord.players[1]["position"] = Vector2(125, 100)
	var ok: Dictionary = coord.begin_ally_revive(1, 2)
	assert_test(bool(ok.get("ok", false)), "Revive inicia de novo")
	coord.cancel_ally_revive_by_reviver(1, "damaged")
	assert_test(coord._revive_channels.is_empty(), "Canal limpo após cancel")
	assert_test(bool(coord.players[2].get("is_dead", false)), "Alvo permanece desmaiado")

	# Abandonar desmaio -> respawn rápido
	assert_test(coord.request_respawn(2), "request_respawn aceito")
	assert_test(float(coord.players[2].get("respawn_timer", 1.0)) <= 0.1, "Timer colapsado para abandonar")
	coord.stop_coordinator()
