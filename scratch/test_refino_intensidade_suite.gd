extends SceneTree

## Suite Trilha F — Refino Intensidade 2026-11-03
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
	print("\n=== REFINO INTENSIDADE SUITE ===\n")

	var combat := _read("res://scripts/combat/CombatSystem.gd")
	_assert("HIT_PROFILE" in combat and "finisher" in combat, "HIT_PROFILE finisher")
	_assert("heavy_buffer_pendente" in combat, "heavy buffer state")
	_assert("Cancel rules" in combat or "cancel rule" in combat.to_lower(), "cancel rules documentadas")

	var player := _read("res://entities/Player/Player.gd")
	_assert("solicitar_heavy_buffer" in player, "Player enfileira heavy no finisher")

	var enemy := _read("res://scripts/systems/EnemySystem/EnemySystem.gd")
	_assert("_disparar_climax_postura" in enemy, "posture climax")
	_assert("PUNISH" in enemy or "VULNERÁVEL" in enemy, "punish toast")

	var floresta := _read("res://world/maps/FlorestaVestigiosMap.gd")
	_assert("nen_type" in floresta and "AlfaNinhoElite" in floresta, "elite Floresta com nen_type")

	var ruinas := _read("res://world/maps/DungeonRuinasZabanMap.gd")
	_assert("_juice_entrada_boss" in ruinas, "juice entrada Guardião")
	_assert("punish" in ruinas.to_lower() or "quebra guarda" in ruinas.to_lower(), "dica fase posture")

	var chatter := _read("res://scripts/story/CompanionChatter.gd")
	_assert("intervalo_minimo_s: float = 22.0" in chatter, "anti toast-spam 22s")
	_assert("quebra" in chatter.to_lower() or "finisher" in chatter.to_lower(), "chatter teach feel")

	var kit := _read("res://scripts/systems/hatsu/HatsuSignatureKit.gd")
	_assert("jajanken" in kit.to_lower() and "godspeed" in kit.to_lower(), "pipeline cobre Pedra/Godspeed")
	_assert("chain jail" in kit.to_lower(), "pipeline Chain Jail")

	var hs := _read("res://scripts/systems/HatsuSystem.gd")
	_assert("_bungee_yo_yo_to" in hs, "Bungee yo-yo self")
	_assert("GODSPEED — basics drenam aura" in hs, "Godspeed drain legível")

	var slots := _read("res://entities/effects/CrazySlotsWheelEffect.gd")
	_assert("persist_sec" in slots and "crazy_slots_arma" in slots, "CrazySlots persist flag")

	var tasks := _read("res://docs/roadmap/_history/TASKS_HOJE_2026-11-03.md")
	_assert("Trilha F" in tasks, "TASKS_HOJE existe")
	var fichas := _read("res://docs/roadmap/_history/HATSU_FICHAS_BACKLOG_2026-11-03.md")
	_assert("Indoor Fish" in fichas, "fichas backlog")

	print("\n=== RESULTADO: %d passed, %d failed ===\n" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
