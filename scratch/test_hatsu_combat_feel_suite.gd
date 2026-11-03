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
	_assert("func play_intensity_pipeline" in kit, "pipeline cast→impact→residual")
	_assert("_spawn_chain_visual" in kit, "corrente visual Jail/Judgement")
	_assert("_spawn_residual_crater" in kit, "residual crater Pedra")

	var fidelity := _read("res://scripts/systems/hatsu/CanonFidelityKit.gd")
	_assert("is_jajanken_pedra" in fidelity, "detector Pedra")
	_assert("is_jajanken_papel" in fidelity, "detector Papel")
	_assert("is_jajanken_tesoura" in fidelity, "detector Tesoura")
	_assert("is_godspeed" in fidelity, "detector Godspeed")
	_assert("is_crazy_slots" in fidelity, "detector Crazy Slots")

	_assert("play_intensity_pipeline" in hs, "HatsuSystem chama pipeline")
	_assert("_bungee_pull_self" in hs or "puxa self" in hs, "Bungee toolkit self")
	_assert("persistir_arma" in _read("res://entities/effects/CrazySlotsWheelEffect.gd"), "CrazySlots arma persiste")

	var combat := _read("res://scripts/combat/CombatSystem.gd")
	_assert("HIT_PROFILE" in combat, "perfis hit1/2/finisher/heavy")
	_assert("solicitar_heavy_buffer" in combat, "cancel rule heavy buffer")
	_assert("cancelar_ataque_para_hatsu" in combat, "cancel rule Hatsu")
	_assert("godspeed_ativo" in combat, "Godspeed amarrado aos basics")

	var enemy := _read("res://scripts/systems/EnemySystem/EnemySystem.gd")
	_assert("_disparar_climax_postura" in enemy, "vitória de postura climax")

	var ai := _read("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_assert("_cor_telegraph_afinidade" in ai, "telegraph por afinidade")

	var story := _read("res://autoload/StoryManager.gd")
	_assert("Biscuit" in story and "Greed Island concluída" in story, "toast GI→Biscuit")

	var bisc := _read("res://entities/npc/biscuit/Biscuit.gd")
	_assert("hatsu_desbloqueio" in bisc, "Biscuit dispara tip de desbloqueio")

	var data := _read("res://resource/hatsu/HatsuData.gd")
	_assert("obter_tempo_conjuracao_final" in data, "tempo de conjuração existe")

	var density := _read("res://world/components/exploration/MidLateDensityKit.gd")
	_assert("_play_hatsu_moment_juice" in density, "Hatsu moment juice cast→residual")

	print("\n=== RESULTADO: %d passed, %d failed ===\n" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
