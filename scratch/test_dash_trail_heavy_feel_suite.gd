extends Node
## Dash = afterimage trail; heavy R-click = no AirPressureWave / blunt ball.


var _passed := 0
var _total := 0


func _ready() -> void:
	print("\n🧪 DASH TRAIL + HEAVY ATTACK FEEL")
	await get_tree().process_frame
	_test_source()
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	get_tree().quit(0 if _passed == _total else 1)


func _ok(c: bool, label: String) -> void:
	_total += 1
	if c:
		_passed += 1
		print("  ✅ ", label)
	else:
		print("  ❌ ", label)


func _test_source() -> void:
	var src := FileAccess.get_file_as_string("res://entities/Player/Player.gd")
	_ok(not src.is_empty(), "Player.gd legível")
	_ok(src.find("_atualizar_dash_trail") >= 0, "trail de dash durante esquiva")
	_ok(src.find("DASH_TRAIL_INTERVAL") >= 0, "intervalo do rastro residual")
	_ok(src.find("_gerar_efeito_corte_ar(direcao_ataque, true)") < 0, "golpe pesado sem AirPressureWave(true)")
	_ok(src.find("_gerar_efeito_poeira_passos(dir)") < 0 or src.find("_dash_trail_accum = 0.0") >= 0, "dash prioriza rastro residual")
	var combat := FileAccess.get_file_as_string("res://scripts/combat/CombatSystem.gd")
	_ok(combat.find("spawn_slash(enemy, target_pos, ultima_direcao, Color(1.0, 0.9, 0.45))") >= 0, "heavy hit usa slash")
	_ok(combat.find("spawn_blunt_impact(enemy, target_pos, 1.8") < 0, "heavy hit sem blunt ball")
	_ok(combat.find("spawn_dust_kickup(owner_body, owner_body.global_position, direcao_esquiva") < 0, "esquiva sem dust kickup")
