extends Node

# godot --headless --path . res://scratch/test_level_physical_scaling_suite.tscn
# Stats físicos sobem com nível NORMAL sem Nen; L1≈10 dmg → L10≈25 dmg.

var _pass := 0
var _fail := 0


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("\n=== test_level_physical_scaling_suite ===")
	_test_anchors_sem_nen()
	_test_playerdata_level_up_aplica()
	_test_monotone_and_endgame()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_anchors_sem_nen() -> void:
	print("-- âncoras L1/L10 sem Nen --")
	var f1 := ProgressionConfig.calcular_stat_base("forca", 1)
	var f10 := ProgressionConfig.calcular_stat_base("forca", 10)
	var h1 := ProgressionConfig.calcular_stat_base("vida_max", 1)
	var h10 := ProgressionConfig.calcular_stat_base("vida_max", 10)
	assert_test(is_equal_approx(f1, 8.0), "forca L1 = 8 (got %.2f)" % f1)
	assert_test(is_equal_approx(f10, 23.0), "forca L10 = 23 (got %.2f)" % f10)
	assert_test(is_equal_approx(h1, 60.0), "vida L1 = 60 (got %.2f)" % h1)
	assert_test(is_equal_approx(h10, 140.0), "vida L10 = 140 (got %.2f)" % h10)

	var d1 := ProgressionConfig.estimar_dano_basico_sem_nen(1)
	var d10 := ProgressionConfig.estimar_dano_basico_sem_nen(10)
	assert_test(d1 == 10, "dano básico L1 = 10 (got %d)" % d1)
	assert_test(d10 == 25, "dano básico L10 = 25 (got %d)" % d10)

	# Crescimento mínimo por nível entre 1 e 10
	var prev_f := f1
	var ok_steps := true
	for lvl in range(2, 11):
		var cur := ProgressionConfig.calcular_stat_base("forca", lvl)
		if cur <= prev_f:
			ok_steps = false
		prev_f = cur
	assert_test(ok_steps, "forca sobe a cada nível de 1→10")


func _test_playerdata_level_up_aplica() -> void:
	print("-- PlayerData aplica stats no level up (sem Nen) --")
	if PlayerData == null:
		assert_test(false, "PlayerData disponível")
		return
	PlayerData.reset()
	PlayerData.despertou_nen = false
	PlayerData.nen_affinity_revealed = false
	PlayerData.attributes["nivel_nen"] = 0
	PlayerData.aplicar_nivel(1)
	var f1: int = int(PlayerData.attributes.get("forca", 0))
	var h1: int = int(PlayerData.attributes.get("vida_max", 0))
	var a1: float = float(PlayerData.attributes.get("aura_max", -1))
	assert_test(f1 == 8, "PlayerData forca L1 = 8 (got %d)" % f1)
	assert_test(h1 == 60, "PlayerData vida L1 = 60 (got %d)" % h1)
	assert_test(a1 <= 0.01, "sem Nen → aura_max 0 (got %.1f)" % a1)

	PlayerData.aplicar_nivel(10)
	var f10: int = int(PlayerData.attributes.get("forca", 0))
	var h10: int = int(PlayerData.attributes.get("vida_max", 0))
	assert_test(f10 == 23, "PlayerData forca L10 = 23 (got %d)" % f10)
	assert_test(h10 == 140, "PlayerData vida L10 = 140 (got %d)" % h10)
	assert_test(f10 > f1 and h10 > h1, "level up sobe forca e vida sem Nen")

	# CombatEngine: dano_base 2 + forca (sem Nen)
	var dmg := CombatEngine.calcular_dano({"forca": float(f10), "dano_base": 2.0}, {"defesa": 0.0})
	assert_test(dmg == 25, "CombatEngine L10 sem Nen = 25 (got %d)" % dmg)


func _test_monotone_and_endgame() -> void:
	print("-- monótono até 1000 + alvo endgame --")
	var last_f := -1.0
	var last_h := -1.0
	var ok := true
	for lvl in [1, 10, 30, 60, 100, 250, 500, 750, 1000]:
		var f := ProgressionConfig.calcular_stat_base("forca", lvl)
		var h := ProgressionConfig.calcular_stat_base("vida_max", lvl)
		if f <= last_f or h <= last_h:
			ok = false
		last_f = f
		last_h = h
	assert_test(ok, "forca/vida monótonos nos marcos")
	assert_test(is_equal_approx(last_f, 4200.0), "forca L1000 = 4200 (got %.1f)" % last_f)
	assert_test(is_equal_approx(last_h, 45000.0), "vida L1000 = 45000 (got %.1f)" % last_h)
	# Aura continua power-law (não early-linear)
	var aura1 := ProgressionConfig.calcular_stat_base("aura_max", 1)
	assert_test(is_equal_approx(aura1, 40.0), "aura L1 base 40 (gate no PlayerData)")
