extends Node

# ==============================================================================
# HUNTER ONLINE — REGRESSION TEST SUITE: PROGRESSION, LEVEL 1000 & BASE STATS
# ==============================================================================
# Valida os 6 cenários canônicos obrigatórios da Seção 14 da PROGRESSION_BIBLE:
# 1. Test 1 — Level increases base stats (Crescimento orgânico sem SP)
# 2. Test 2 — Skill Points are independent (Independência total de Árvore e Base)
# 3. Test 3 — Level 1000 is valid (Validação exata dos alvos canônicos)
# 4. Test 4 — Level 1001 is rejected (Clamp estrito no Cap 1000)
# 5. Test 5 — Save/load preserves Level 1000 (Persistência íntegra de Nível, XP, SP, Nen, Hatsu)
# 6. Test 6 — Future saga compatibility (Registro data-driven de Saga 10+ sem alterar código)
# ==============================================================================

const XPSystemScript = preload("res://scripts/systems/XPSystem.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ [PASS] " + test_name)
	else:
		failed_tests += 1
		printerr("  ❌ [FAIL] " + test_name)

func _ready() -> void:
	print("================================================================")
	print("🥋 TEST SUITE: PROGRESSION, LEVEL 1000 & BASE STAT GROWTH")
	print("================================================================")

	_test_1_level_increases_base_stats()
	_test_2_skill_points_are_independent()
	_test_3_level_1000_is_valid()
	_test_4_level_1001_is_rejected()
	_test_5_save_load_preserves_level_1000()
	_test_6_future_saga_compatibility()

	print("================================================================")
	print("📊 RESULTADOS DA SUÍTE DE PROGRESSÃO LEVEL 1000:")
	print("Total: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 100% DOS TESTES DE PROGRESSÃO LEVEL 1000 APROVADOS COM SUCESSO!")
	else:
		printerr("❌ ALGUNS TESTES FALHARAM!")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)


# ------------------------------------------------------------------------------
# TEST 1 — Level increases base stats
# ------------------------------------------------------------------------------
func _test_1_level_increases_base_stats() -> void:
	print("\n--- [TEST 1] Level increases base stats ---")
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel(10)

	var hp_10 = PlayerData.obter_stat_calculado("vida_max")
	var forca_10 = PlayerData.obter_stat_calculado("forca")
	var defesa_10 = PlayerData.obter_stat_calculado("defesa")
	var vel_10 = PlayerData.obter_stat_calculado("velocidade")
	var aura_10 = PlayerData.obter_stat_calculado("aura_max")

	# Subir para Level 11 com 0 Skill Points investidos na árvore
	PlayerData.aplicar_nivel(11)

	var hp_11 = PlayerData.obter_stat_calculado("vida_max")
	var forca_11 = PlayerData.obter_stat_calculado("forca")
	var defesa_11 = PlayerData.obter_stat_calculado("defesa")
	var vel_11 = PlayerData.obter_stat_calculado("velocidade")
	var aura_11 = PlayerData.obter_stat_calculado("aura_max")

	var all_stats_increased = (hp_11 > hp_10) and (forca_11 > forca_10) and (defesa_11 > defesa_10) and (vel_11 > vel_10) and (aura_11 > aura_10)
	var zero_sp_spent = PlayerData.nen_skill_tree_progress.is_empty()

	assert_test(all_stats_increased, "1.1 Todos os atributos base aumentaram organicamente do Lv.10 ao Lv.11 (HP: %d->%d, Força: %d->%d, Defesa: %d->%d, Vel: %.1f->%.1f, Aura: %d->%d)" % [hp_10, hp_11, forca_10, forca_11, defesa_10, defesa_11, vel_10, vel_11, int(aura_10), int(aura_11)])
	assert_test(zero_sp_spent, "1.2 Nenhum Skill Point foi gasto na Skill Tree para obter o crescimento natural")


# ------------------------------------------------------------------------------
# TEST 2 — Skill Points are independent
# ------------------------------------------------------------------------------
func _test_2_skill_points_are_independent() -> void:
	print("\n--- [TEST 2] Skill Points are independent ---")
	PlayerData.reset()
	PlayerData.despertou_nen = true

	# Configurar Estado A: Nível 20 com 0 SP gastos
	PlayerData.aplicar_nivel(20)
	var hp_a_20 = PlayerData.obter_stat_calculado("vida_max")
	var frc_a_20 = PlayerData.obter_stat_calculado("forca")
	var def_a_20 = PlayerData.obter_stat_calculado("defesa")
	var vel_a_20 = PlayerData.obter_stat_calculado("velocidade")
	var aur_a_20 = PlayerData.obter_stat_calculado("aura_max")

	# Subir Estado A para Nível 21
	PlayerData.aplicar_nivel(21)
	var delta_hp_a = PlayerData.obter_stat_calculado("vida_max") - hp_a_20
	var delta_frc_a = PlayerData.obter_stat_calculado("forca") - frc_a_20
	var delta_def_a = PlayerData.obter_stat_calculado("defesa") - def_a_20
	var delta_vel_a = PlayerData.obter_stat_calculado("velocidade") - vel_a_20
	var delta_aur_a = PlayerData.obter_stat_calculado("aura_max") - aur_a_20

	# Configurar Estado B: Nível 20 com Especialização (Bônus de Árvore / Modificador)
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel(20)
	
	# Simular bônus da Skill Tree de 19 pontos gastos (ex: +50 Força plana)
	var tree_mod = StatModifier.new(
		StringName("tree_bonus_strength"),
		StringName("forca"),
		StatModifier.ModifierType.FLAT_ADD,
		50.0,
		StatModifier.SourceType.PASSIVE,
		-1.0
	)
	PlayerData.adicionar_modificador(tree_mod)
	var frc_b_20 = PlayerData.obter_stat_calculado("forca")
	assert_test(frc_b_20 == (frc_a_20 + 50), "2.1 Personagem B possui bônus da Skill Tree aplicado sobre a base (%d vs %d)" % [frc_b_20, frc_a_20])

	# Subir Estado B para Nível 21
	PlayerData.aplicar_nivel(21)
	var frc_b_21 = PlayerData.obter_stat_calculado("forca")
	var delta_frc_b = frc_b_21 - frc_b_20

	assert_test(delta_frc_a == delta_frc_b, "2.2 Ganho de Força no Level Up foi idêntico em A (+%d) e B (+%d), provando independência do investimento de SP" % [delta_frc_a, delta_frc_b])
	assert_test(frc_b_21 == (PlayerData.obter_stat_base("forca") + 50), "2.3 Bônus da árvore persiste somado aditivamente sobre a nova base (%d = %d base + 50 árvore)" % [frc_b_21, PlayerData.obter_stat_base("forca")])
	
	PlayerData.remover_modificador(StringName("tree_bonus_strength"))


# ------------------------------------------------------------------------------
# TEST 3 — Level 1000 is valid
# ------------------------------------------------------------------------------
func _test_3_level_1000_is_valid() -> void:
	print("\n--- [TEST 3] Level 1000 is valid ---")
	PlayerData.reset()
	PlayerData.debug_set_level(1000, true)

	var lvl = PlayerData.attributes.get("nivel")
	var hp_max = PlayerData.obter_stat_calculado("vida_max")
	var forca = PlayerData.obter_stat_calculado("forca")
	var defesa = PlayerData.obter_stat_calculado("defesa")
	var vel = PlayerData.obter_stat_calculado("velocidade")
	var aura_max = PlayerData.obter_stat_calculado("aura_max")
	var xp_req = ProgressionConfig.calcular_xp_necessario(1000)

	var stats_finite = not is_nan(hp_max) and not is_inf(hp_max) and not is_nan(aura_max) and not is_inf(aura_max)
	var targets_matched = (hp_max == 50000) and (forca == 5000) and (defesa == 5000) and (is_equal_approx(vel, 160.0)) and (int(aura_max) == 1500000)

	assert_test(lvl == 1000, "3.1 Personagem atinge exatamente o Nível 1000 canônico")
	assert_test(stats_finite, "3.2 Todos os cálculos resultam em números finitos, sem NaN, sem Inf e sem crashes")
	assert_test(targets_matched, "3.3 Todos os atributos no Nível 1000 batem precisamente as metas da Bíblia: HP=%d (50000), Força=%d (5000), Defesa=%d (5000), Vel=%.1f (160), Aura=%d (1500000)" % [hp_max, forca, defesa, vel, int(aura_max)])
	assert_test(xp_req > 0, "3.4 XP necessário para Level 1000 é finito e positivo (%d XP)" % xp_req)


# ------------------------------------------------------------------------------
# TEST 4 — Level 1001 is rejected
# ------------------------------------------------------------------------------
func _test_4_level_1001_is_rejected() -> void:
	print("\n--- [TEST 4] Level 1001 is rejected ---")
	PlayerData.reset()
	PlayerData.debug_set_level(1000, true)

	# Tentativa direta 1: aplicar_nivel(1001)
	PlayerData.aplicar_nivel(1001)
	assert_test(PlayerData.attributes["nivel"] == 1000, "4.1 Tentativa de aplicar_nivel(1001) é barrada pelo clamp no Cap 1000")

	# Tentativa direta 2: debug_set_level(1500)
	PlayerData.debug_set_level(1500, true)
	assert_test(PlayerData.attributes["nivel"] == 1000, "4.2 Tentativa de debug_set_level(1500) é limitada a 1000")

	# Tentativa indireta 3: adicionar excesso de XP no XPSystem
	var xp_sys = XPSystemScript.new()
	add_child(xp_sys)
	xp_sys.sincronizar_com_player_data()
	xp_sys.adicionar_xp(999999999, "Teste Overflow")

	assert_test(xp_sys.level == 1000 and PlayerData.attributes["nivel"] == 1000, "4.3 XPSystem barra progressão além do Nível 1000 mesmo recebendo 1 bilhão de XP")
	assert_test(xp_sys.xp == xp_sys.xp_necessario(), "4.4 XP permanece cravado no limite máximo tabelado sem overflow")
	xp_sys.queue_free()


# ------------------------------------------------------------------------------
# TEST 5 — Save/load preserves Level 1000
# ------------------------------------------------------------------------------
func _test_5_save_load_preserves_level_1000() -> void:
	print("\n--- [TEST 5] Save/load preserves Level 1000 ---")
	var test_slot: int = 9

	PlayerData.reset()
	PlayerData.debug_set_level(1000, true)
	PlayerData.nome_personagem = "Hunter Supremo Nv1000"
	PlayerData.nen_skill_points = 999

	# Configurar maestria de técnicas de Nen e criar um Hatsu
	PlayerData.tecnicas_nen["ten"]["nivel"] = 100
	PlayerData.tecnicas_nen["ren"]["nivel"] = 100
	PlayerData.tecnicas_nen["en"]["nivel"] = 100

	var test_hatsu = HatsuData.new()
	test_hatsu.nome = "Impacto Máximo de Teste"
	test_hatsu.afinidade_principal = NenAffinityData.CategoriaAfinidade.REFORCO
	test_hatsu.custo_aura = 2500.0
	test_hatsu.dano_base = 15000
	PlayerData.hatsu_criados.append(test_hatsu)
	PlayerData.hatsu_slots[0] = 0

	# Salvar no slot de teste
	var save_success = SaveManager.salvar_jogo(test_slot)
	assert_test(save_success, "5.1 Jogo salvo com sucesso no slot de teste %d" % test_slot)

	# Resetar PlayerData simulando nova sessão
	PlayerData.reset()
	assert_test(PlayerData.attributes["nivel"] == 1, "5.2 PlayerData resetado para Nível 1 antes de carregar")

	# Carregar jogo do slot de teste
	var load_success = SaveManager.carregar_jogo(test_slot)
	assert_test(load_success, "5.3 Save do slot %d carregado com sucesso" % test_slot)

	# Validar integridade após load
	var loaded_lvl = PlayerData.attributes.get("nivel")
	var loaded_hp = PlayerData.obter_stat_calculado("vida_max")
	var loaded_forca = PlayerData.obter_stat_calculado("forca")
	var loaded_defesa = PlayerData.obter_stat_calculado("defesa")
	var loaded_vel = PlayerData.obter_stat_calculado("velocidade")
	var loaded_aura = PlayerData.obter_stat_calculado("aura_max")
	var loaded_sp = PlayerData.nen_skill_points
	var loaded_ten = PlayerData.tecnicas_nen.get("ten", {}).get("nivel", 0)
	var loaded_hatsu_ok = (PlayerData.hatsu_criados.size() > 0 and PlayerData.hatsu_criados[0].nome == "Impacto Máximo de Teste")

	assert_test(loaded_lvl == 1000, "5.4 Nível 1000 restaurado com fidelidade absoluta")
	assert_test(loaded_hp == 50000 and loaded_forca == 5000 and loaded_defesa == 5000 and is_equal_approx(loaded_vel, 160.0) and int(loaded_aura) == 1500000, "5.5 Todos os atributos Nv.1000 recalculados identicamente aos alvos pré-save")
	assert_test(loaded_sp == 999, "5.6 Nen Skill Points (999) preservados integralmente")
	assert_test(loaded_ten == 100, "5.7 Maestria de Nen preservada no Nível 100")
	assert_test(loaded_hatsu_ok, "5.8 Hatsu criado e slot restaurados corretamente")

	# Limpeza do arquivo de teste
	SaveManager.deletar_save(test_slot)
	PlayerData.reset()


# ------------------------------------------------------------------------------
# TEST 6 — Future saga compatibility
# ------------------------------------------------------------------------------
func _test_6_future_saga_compatibility() -> void:
	print("\n--- [TEST 6] Future saga compatibility ---")

	# Registrar mock Saga 10 sem nenhuma alteração no código de progressão
	var mock_saga_id = 10
	var mock_saga_nome = "Expedição além do Lago Mobius (Continente Sombrio II)"
	var mock_lvl_min = 850
	var mock_lvl_max = 1000
	var mock_caps = 12

	StoryManager.registrar_saga(mock_saga_id, mock_saga_nome, mock_lvl_min, mock_lvl_max, mock_caps)

	# 1. Verificar registro bem sucedido
	assert_test(StoryManager.tem_saga(mock_saga_id), "6.1 Saga 10 registrada com sucesso na tabela de dados dinâmicos do StoryManager")

	# 2. Verificar faixa de nível configurada
	var faixa = StoryManager.obter_faixa_nivel_saga(mock_saga_id)
	assert_test(faixa.x == mock_lvl_min and faixa.y == mock_lvl_max, "6.2 Faixa de nível da Saga 10 definida corretamente como %d–%d" % [faixa.x, faixa.y])

	# 3. Jogador nível 849 NÃO pode acessar requisitos da Saga 10
	var can_access_849 = StoryManager.jogador_atende_nivel_saga(mock_saga_id, 849)
	assert_test(not can_access_849, "6.3 Jogador no Nível 849 é impedido de acessar conteúdo da Saga 10 (mínimo %d)" % mock_lvl_min)

	# 4. Jogador nível 850 pode acessar
	var can_access_850 = StoryManager.jogador_atende_nivel_saga(mock_saga_id, 850)
	assert_test(can_access_850, "6.4 Jogador no Nível 850 tem acesso concedido à Saga 10")

	# 5. Jogador nível 1000 pode acessar
	var can_access_1000 = StoryManager.jogador_atende_nivel_saga(mock_saga_id, 1000)
	assert_test(can_access_1000, "6.5 Jogador no Nível 1000 tem acesso pleno à Saga 10 sem quebra de compatibilidade")
