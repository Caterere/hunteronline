extends Node

# ==============================================================================
# HUNTER ONLINE — AUTOMATED TEST SUITE: FASE I (BALANCEAMENTO & ENDGAME)
# ==============================================================================
# Valida exaustivamente todos os pilares da Fase I:
# 1. Fundação Matemática (LV1 a LV1000, Power-Law, Cap 1000, Tiers do PowerScale)
# 2. Motor de Combate (Atenuação Defensiva Assintótica, Ten/Ken, Tags de Dano)
# 3. Identidade de Builds & Ryu (Brawler, Tank, Assassin, Ryu sem penalidades)
# 4. Escalonamento de Inimigos & TTK (EnemyScalingHelper, Tiers, Chefes de Sagas)
# 5. Pacing de Hatsu & Dependência em Cadeia dos 4 Slots
# 6. Chefes Secretos & Exploração Orgânica sem GPS (SecretBossManager)
# 7. Bounties de Alto Escalão, Eventos Mundiais & Conquistas de Endgame
# 8. Persistência e Integridade de Save/Load no Nível 1000 (Schema 2.3)
# ==============================================================================

const XPSystemScript = preload("res://scripts/systems/XPSystem.gd")
const EnemyScalingHelper = preload("res://resource/status/EnemyScalingHelper.gd")
const HatsuConfig = preload("res://scripts/systems/hatsu/HatsuConfig.gd")

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
	print("🥋 SUÍTE DE TESTES: FASE I — BALANCEAMENTO & ENDGAME (LV1-1000)")
	print("================================================================")

	_test_1_fundacao_matematica_lv1000()
	_test_2_combate_mitigacao_assintotica()
	_test_3_identidade_builds_e_ryu()
	_test_4_escalonamento_inimigos_e_ttk()
	_test_5_hatsu_cadeia_e_anti_farm()
	_test_6_chefes_secretos_sem_gps()
	_test_7_bounties_eventos_e_conquistas()
	_test_8_save_load_schema_2_3_lv1000()

	print("================================================================")
	print("📊 RESULTADOS FINAIS DA FASE I:")
	print("Total de Testes: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 100% DOS TESTES DA FASE I APROVADOS COM SUCESSO!")
	else:
		printerr("❌ FALHA EM TESTES DA FASE I!")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)


# ------------------------------------------------------------------------------
# 1. Fundação Matemática (LV1 a LV1000)
# ------------------------------------------------------------------------------
func _test_1_fundacao_matematica_lv1000() -> void:
	print("\n--- [BLOCO 1] Fundação Matemática & Curva de Nível 1 a 1000 ---")
	PlayerData.reset()
	PlayerData.despertou_nen = true

	# Teste 1.1: Nível 1 (Valores Base)
	PlayerData.aplicar_nivel(1)
	assert_test(PlayerData.attributes["vida_max"] == 120, "1.1 HP no Nível 1 com Intensificação é exatamente 120 (100 base)")
	assert_test(PlayerData.attributes["forca"] == 12, "1.2 Força no Nível 1 com Intensificação é exatamente 12 (10 base)")
	assert_test(PlayerData.attributes["defesa"] == 10, "1.3 Defesa Base no Nível 1 é exatamente 10")
	assert_test(is_equal_approx(PlayerData.obter_stat_calculado("velocidade"), 10.0), "1.4 Velocidade Base no Nível 1 é exatamente 10.0")

	# Teste 1.2: Crescimento Monótono em Marcos
	var marcos: Array[int] = [10, 50, 100, 250, 500, 750, 1000]
	var last_hp: float = 0.0
	var last_forca: float = 0.0
	var monotono: bool = true
	for m in marcos:
		var hp = ProgressionConfig.calcular_stat_base("vida_max", m)
		var frc = ProgressionConfig.calcular_stat_base("forca", m)
		if hp <= last_hp or frc <= last_forca:
			monotono = false
		last_hp = hp
		last_forca = frc
	assert_test(monotono, "1.5 Atributos crescem de forma estritamente monótona em todos os marcos até o 1000")

	# Teste 1.3: Nível 1000 (Ápice Absoluto)
	PlayerData.aplicar_nivel(1000)
	var hp_1000 = PlayerData.attributes["vida_max"]
	var frc_1000 = PlayerData.attributes["forca"]
	var def_1000 = PlayerData.attributes["defesa"]
	var vel_1000 = PlayerData.obter_stat_calculado("velocidade")
	var aur_1000 = PlayerData.attributes["aura_max"]

	var hp_base_1000 = ProgressionConfig.calcular_stat_base("vida_max", 1000)
	var frc_base_1000 = ProgressionConfig.calcular_stat_base("forca", 1000)
	var def_base_1000 = ProgressionConfig.calcular_stat_base("defesa", 1000)

	assert_test(hp_base_1000 == 50000.0 and hp_1000 == 60000, "1.6 HP Base no Nível 1000 é 50.000 (60.000 com afinidade Intensificação)")
	assert_test(frc_base_1000 == 5000.0 and frc_1000 == 6000, "1.7 Força Base no Nível 1000 é 5.000 (6.000 com afinidade Intensificação)")
	assert_test(def_base_1000 == 5000.0 and def_1000 == 5000, "1.8 Defesa Base no Nível 1000 é exatamente 5.000")
	assert_test(is_equal_approx(vel_1000, 160.0), "1.9 Velocidade no Nível 1000 é exatamente 160.0")
	assert_test(aur_1000 >= 1500000.0, "1.10 Aura Máxima no Nível 1000 atinge o ápice de 1.500.000+")

	# Teste 1.4: Rejeição de Level 1001
	PlayerData.aplicar_nivel(1001)
	assert_test(PlayerData.attributes["nivel"] == 1000, "1.11 Clamp estrito impede avanço para Nível 1001")

	# Teste 1.5: Tiers do PowerScale
	assert_test(PowerScale.obter_tier_por_nivel(50) == PowerScale.Tier.HUMANO, "1.12 Nível 50 é Tier HUMANO")
	assert_test(PowerScale.obter_tier_por_nivel(180) == PowerScale.Tier.HUNTER_INICIANTE, "1.13 Nível 180 é Tier HUNTER_INICIANTE")
	assert_test(PowerScale.obter_tier_por_nivel(350) == PowerScale.Tier.HUNTER_EXPERIENTE, "1.14 Nível 350 é Tier HUNTER_EXPERIENTE")
	assert_test(PowerScale.obter_tier_por_nivel(500) == PowerScale.Tier.USUARIO_NEN, "1.15 Nível 500 é Tier USUARIO_NEN")
	assert_test(PowerScale.obter_tier_por_nivel(700) == PowerScale.Tier.HUNTER_ELITE, "1.16 Nível 700 é Tier HUNTER_ELITE")
	assert_test(PowerScale.obter_tier_por_nivel(850) == PowerScale.Tier.MONSTRO, "1.17 Nível 850 é Tier MONSTRO")
	assert_test(PowerScale.obter_tier_por_nivel(1000) == PowerScale.Tier.ENDGAME, "1.18 Nível 1000 é Tier ENDGAME")


# ------------------------------------------------------------------------------
# 2. Motor de Combate (Atenuação Defensiva Assintótica)
# ------------------------------------------------------------------------------
func _test_2_combate_mitigacao_assintotica() -> void:
	print("\n--- [BLOCO 2] Motor de Combate & Mitigação Assintótica ---")

	# Teste 2.1: Defesa zero vs Defesa moderada
	var atacante: Dictionary = {"forca": 500.0, "dano_base": 100.0} # Dano bruto = 600
	var def_zero: Dictionary = {"defesa": 0.0, "nivel": 100}
	var def_alta: Dictionary = {"defesa": 1000.0, "nivel": 100}

	var d_zero: int = CombatEngine.calcular_dano(atacante, def_zero)
	var d_alta: int = CombatEngine.calcular_dano(atacante, def_alta)

	assert_test(d_zero > d_alta, "2.1 Defesa atenua dano de forma consistente (%d vs %d)" % [d_zero, d_alta])
	assert_test(d_alta > 1, "2.2 Defesa alta NÃO zera o dano nem prende em 1 de dano espúrio (Dano sofrido: %d)" % d_alta)

	# Teste 2.2: Fator Defensivo de PowerScale
	var fator_def = PowerScale.calcular_fator_defensivo(5000.0, PowerScale.Tier.ENDGAME)
	assert_test(fator_def >= 0.15 and fator_def <= 0.60, "2.3 Fator defensivo no endgame fica na faixa balanceada de 15%% a 60%% (Fator: %.2f)" % fator_def)

	# Teste 2.3: Ten Mitigation
	var def_com_ten: Dictionary = {"defesa": 500.0, "nivel": 100, "ten_ativo": true, "aura": 2000.0}
	var d_com_ten: int = CombatEngine.calcular_dano(atacante, def_com_ten)
	assert_test(d_com_ten < d_zero, "2.4 Ten absorve parcela de impacto atenuando o dano final (%d vs %d)" % [d_com_ten, d_zero])

	# Teste 2.4: Ataque com Ko (Burst)
	var d_normal: int = CombatEngine.calcular_dano(atacante, def_zero, null, false)
	var d_ko: int = CombatEngine.calcular_dano(atacante, def_zero, null, true)
	assert_test(d_ko > d_normal, "2.5 Golpe com Ko causa dano superior ao golpe normal (%d vs %d)" % [d_ko, d_normal])

	# Teste 2.5: Fraquezas e Imunidades de GameplayTags
	var def_neutra: Dictionary = {"defesa": 10.0}
	var def_imune: Dictionary = {"defesa": 10.0, "immunity_tags": ["nen"]}
	var def_fraca: Dictionary = {"defesa": 10.0, "weakness_tags": ["nen"]}
	var d_neutra: int = CombatEngine.calcular_dano(atacante, def_neutra, null, false, ["nen"])
	var d_imune: int = CombatEngine.calcular_dano(atacante, def_imune, null, false, ["nen"])
	var d_fraca: int = CombatEngine.calcular_dano(atacante, def_fraca, null, false, ["nen"])

	assert_test(d_imune == 0, "2.6 Alvo imune anula completamente o dano de sua imunidade (Dano: %d)" % d_imune)
	assert_test(d_fraca > d_neutra, "2.7 Alvo vulnerável sofre multiplicador de fraqueza (%d vs %d)" % [d_fraca, d_neutra])


# ------------------------------------------------------------------------------
# 3. Identidade de Builds & Ryu
# ------------------------------------------------------------------------------
func _test_3_identidade_builds_e_ryu() -> void:
	print("\n--- [BLOCO 3] Identidade de Builds & Especialização de Ryu ---")
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel(500)

	var st = PlayerData.obter_skill_tree()
	assert_test(st != null, "3.1 NenSkillTree runtime engine acessível via PlayerData")

	# Teste 3.1: Ryu Ofensivo
	PlayerData.nen_skill_points = 500
	st.node_levels["shu_1"] = 1 # Pré-requisito de Ryu desbloqueado
	var def_antes = PlayerData.obter_stat_calculado("defesa")
	var ok_of = st.investir_ponto("ryu_ofensivo")
	assert_test(ok_of, "3.2 Ryu Ofensivo investido com sucesso")
	assert_test(PlayerData.nen_ryu_caminho == "ofensivo", "3.3 Caminho de Ryu registrado como ofensivo")

	var def_depois = PlayerData.obter_stat_calculado("defesa")
	assert_test(def_depois >= def_antes, "3.4 Ryu Ofensivo NÃO penaliza a defesa (%d >= %d)" % [int(def_depois), int(def_antes)])

	# Teste 3.2: Exclusividade mútua de Ryu
	var ok_def = st.investir_ponto("ryu_defensivo")
	assert_test(not ok_def, "3.5 Tentativa de investir em Ryu Defensivo com caminho Ofensivo ativo é bloqueada")

	# Teste 3.3: Respec Total com 100% de reembolso
	var pontos_antes = PlayerData.nen_skill_points
	var devolvidos = st.resetar_arvore()
	assert_test(devolvidos > 0, "3.6 Respec resgatou pontos investidos (%d pontos)" % devolvidos)
	assert_test(PlayerData.nen_ryu_caminho == "", "3.7 Caminho de Ryu limpo após respec")

	# Teste 3.4: Ryu Defensivo pós-respec
	st.node_levels["shu_1"] = 1 # Pré-requisito restaurado pós-respec
	var frc_antes = PlayerData.obter_stat_calculado("forca")
	var ok_def2 = st.investir_ponto("ryu_defensivo")
	assert_test(ok_def2, "3.8 Ryu Defensivo investido com sucesso após respec")
	assert_test(PlayerData.nen_ryu_caminho == "defensivo", "3.9 Caminho registrado como defensivo")

	var frc_depois = PlayerData.obter_stat_calculado("forca")
	assert_test(frc_depois >= frc_antes, "3.10 Ryu Defensivo NÃO penaliza a força (%d >= %d)" % [int(frc_depois), int(frc_antes)])


# ------------------------------------------------------------------------------
# 4. Escalonamento de Inimigos & TTK
# ------------------------------------------------------------------------------
func _test_4_escalonamento_inimigos_e_ttk() -> void:
	print("\n--- [BLOCO 4] Escalonamento de Inimigos & TTK ---")

	# Teste 4.1: EnemyScalingHelper nos 4 Brackets
	var mob_early = EnemyScalingHelper.calcular_atributos_inimigo(20, "bruiser", false, false, 1)
	var mob_mid = EnemyScalingHelper.calcular_atributos_inimigo(150, "fast", false, false, 1)
	var mob_late = EnemyScalingHelper.calcular_atributos_inimigo(550, "tank", false, false, 1)
	var mob_end = EnemyScalingHelper.calcular_atributos_inimigo(900, "boss", true, false, 4)

	assert_test(mob_early["max_health"] > 0 and mob_early["strength"] > 0, "4.1 Mob Early (Lv 20) possui atributos válidos (HP: %d, Str: %d)" % [mob_early["max_health"], mob_early["strength"]])
	assert_test(mob_mid["max_health"] > mob_early["max_health"], "4.2 Mob Mid (Lv 150) tem HP superior a Early (%d > %d)" % [mob_mid["max_health"], mob_early["max_health"]])
	assert_test(mob_late["max_health"] > mob_mid["max_health"], "4.3 Mob Late (Lv 550) tem HP superior a Mid (%d > %d)" % [mob_late["max_health"], mob_mid["max_health"]])
	assert_test(mob_end["max_health"] > mob_late["max_health"], "4.4 Boss Endgame (Lv 900) tem HP superior a Late (%d > %d)" % [mob_end["max_health"], mob_late["max_health"]])

	# Teste 4.2: Validação dos recursos de Chefes Reescalonados
	var hisoka_res = load("res://resource/status/enemies/boss_hisoka.tres") as EnemyData
	assert_test(hisoka_res != null and hisoka_res.level == 180, "4.5 Boss Hisoka calibrado para Nível 180 (Saga 3)")
	assert_test(hisoka_res.max_health >= 50000, "4.6 Boss Hisoka possui HP compatível com batalha épica (%d HP)" % hisoka_res.max_health)

	var meruem_res = load("res://resource/status/enemies/boss_meruem.tres") as EnemyData
	assert_test(meruem_res != null and meruem_res.level == 700, "4.7 Boss Meruem calibrado para Nível 700 (Saga 6 Climax)")
	assert_test(meruem_res.max_health >= 300000, "4.8 Boss Meruem possui HP monumental (%d HP)" % meruem_res.max_health)

	var black_whale_res = load("res://resource/status/enemies/guarda_black_whale.tres") as EnemyData
	assert_test(black_whale_res != null and black_whale_res.level >= 880, "4.9 Guarda Black Whale calibrado para Nível 880+ (%d)" % black_whale_res.level)

	var nen_beast_res = load("res://resource/status/enemies/nen_beast_principe.tres") as EnemyData
	assert_test(nen_beast_res != null and nen_beast_res.level >= 900, "4.10 Besta de Nen do Príncipe calibrada para Nível 900+ (%d)" % nen_beast_res.level)


# ------------------------------------------------------------------------------
# 5. Pacing de Hatsu & Dependência em Cadeia
# ------------------------------------------------------------------------------
func _test_5_hatsu_cadeia_e_anti_farm() -> void:
	print("\n--- [BLOCO 5] Pacing de Hatsu & Anti-Farm ---")
	PlayerData.reset()

	assert_test(not HatsuProgressionManager.is_slot_unlocked(1), "5.1 Slot 1 inicia bloqueado antes de Greed Island")
	assert_test(not HatsuProgressionManager.is_slot_unlocked(2), "5.2 Slot 2 inicia bloqueado")

	# Tentativa de bypass por nível alto sem Greed Island
	PlayerData.aplicar_nivel(1000)
	HatsuProgressionManager.check_and_unlock_slots()
	assert_test(not HatsuProgressionManager.is_slot_unlocked(1), "5.3 Slot 1 permanece bloqueado no Nv 1000 sem concluir Greed Island")
	assert_test(not HatsuProgressionManager.is_slot_unlocked(2), "5.4 Slot 2 bloqueado por falta de Slot 1 (Dependência em cadeia)")

	# Concluir Greed Island e desbloquear Slot 1
	PlayerData.modo_historia_concluido = true
	PlayerData.arco_atual = 6
	var ok_s1 = HatsuProgressionManager.unlock_slot(1)
	assert_test(ok_s1 and HatsuProgressionManager.is_slot_unlocked(1), "5.5 Slot 1 desbloqueado após iniciação com Biscuit")

	# Agora com Nv 1000 e Slot 1, os próximos slots devem liberar progressivamente
	HatsuProgressionManager.check_and_unlock_slots()
	assert_test(HatsuProgressionManager.is_slot_unlocked(2), "5.6 Slot 2 desbloqueado (Slot 1 + Nível >= 600)")
	assert_test(HatsuProgressionManager.is_slot_unlocked(3), "5.7 Slot 3 desbloqueado (Slot 2 + Nível >= 800)")
	assert_test(HatsuProgressionManager.is_slot_unlocked(4), "5.8 Slot 4 desbloqueado (Slot 3 + Nível >= 1000)")

	# Teste de Anti-Farm Delta Level (delta >= 30 concede 0 XP de Maestria)
	var anti_farm_30 = HatsuConfig.calcular_penalidade_anti_farm(100, 50) # delta = 50 >= 30
	assert_test(anti_farm_30 == 0.0, "5.9 Anti-farm anula ganho (fator 0.0) contra inimigos 30+ níveis abaixo")

	var anti_farm_justo = HatsuConfig.calcular_penalidade_anti_farm(100, 95) # delta = 5 <= 10
	assert_test(anti_farm_justo == 1.0, "5.10 Combate equilibrado mantém 100% (fator 1.0) do ganho de maestria")


# ------------------------------------------------------------------------------
# 6. Chefes Secretos & Exploração Orgânica sem GPS
# ------------------------------------------------------------------------------
func _test_6_chefes_secretos_sem_gps() -> void:
	print("\n--- [BLOCO 6] Chefes Secretos & Exploração sem GPS ---")
	assert_test(SecretBossManager != null, "6.1 SecretBossManager autoload ativo e acessível")

	# Teste 6.1: Catálogo de Chefes Secretos
	var catalogo = SecretBossManager.SECRET_BOSS_CATALOG
	assert_test(catalogo.has("maha_zoldyck_sombra"), "6.2 Sombra de Maha Zoldyck registrada no catálogo")
	assert_test(catalogo.has("calamidade_brion_esporo"), "6.3 Calamidade de Brion registrada no catálogo")
	assert_test(catalogo.has("mestre_shingen_ancestral"), "6.4 Mestre Shingen Ancestral registrado no catálogo")

	# Teste 6.2: Avaliação de Requisitos de Maha Zoldyck
	# Sem Gyo: Rejeitado
	var ctx_sem_gyo: Dictionary = {"regiao": "montanha_kukuroo", "gyo_ativo": false}
	assert_test(not SecretBossManager.avaliar_despertar("maha_zoldyck_sombra", ctx_sem_gyo), "6.5 Maha Zoldyck rejeita despertar sem Gyo ativo")

	# Com Gyo mas sem item requerido: Rejeitado
	var ctx_com_gyo: Dictionary = {"regiao": "montanha_kukuroo", "gyo_ativo": true}
	PlayerData.inventory.clear()
	assert_test(not SecretBossManager.avaliar_despertar("maha_zoldyck_sombra", ctx_com_gyo), "6.6 Maha Zoldyck rejeita sem a relíquia ancestral no inventário")

	# Com Gyo e item: Aprovado!
	PlayerData.inventory["reliquia_cacador_antigo"] = 1
	assert_test(SecretBossManager.avaliar_despertar("maha_zoldyck_sombra", ctx_com_gyo), "6.7 Maha Zoldyck desperta com Gyo e Relíquia na Montanha Kukuroo")

	# Teste 6.3: Geração de dados de Chefe Secreto
	var dados_maha = SecretBossManager.criar_dados_chefe_secreto("maha_zoldyck_sombra")
	assert_test(dados_maha != null and dados_maha.level == 920, "6.8 Chefe Secreto criado com Nível 920 escalonado")
	assert_test(dados_maha.is_boss and dados_maha.max_health > 100000, "6.9 Chefe Secreto configurado como Boss com HP de alto impacto (%d HP)" % dados_maha.max_health)


# ------------------------------------------------------------------------------
# 7. Bounties de Alto Escalão, Eventos & Conquistas
# ------------------------------------------------------------------------------
func _test_7_bounties_eventos_e_conquistas() -> void:
	print("\n--- [BLOCO 7] Bounties, Eventos & Conquistas de Endgame ---")

	# Teste 7.1: Contratos de Bounties de Alto Escalão
	assert_test(BountySystem != null, "7.1 BountySystem ativo")
	assert_test(BountySystem.active_bounty_contracts.has("bounty_assassino_heilly"), "7.2 Contrato Rank A da Família Heil-Ly disponível no Black Whale")
	assert_test(BountySystem.active_bounty_contracts.has("bounty_calamidade_parasita"), "7.3 Contrato Rank S da Calamidade disponível no Continente Negro")

	var c_s = BountySystem.active_bounty_contracts["bounty_calamidade_parasita"]
	assert_test(c_s["nivel_alvo"] >= 950 and c_s["recompensa_jenny"] >= 100000000, "7.4 Contrato Rank S tem nível 950+ e recompensa de 100M+ Jenny")

	# Teste 7.2: Eventos Mundiais de Calamidade
	assert_test(WorldEventManager != null, "7.5 WorldEventManager ativo")
	WorldEventManager.iniciar_evento_calamidade_continente_negro()
	assert_test(WorldEventManager.active_world_events.has("evento_calamidade_continente_negro"), "7.6 Evento de Calamidade do Continente Negro gerado com sucesso")

	# Teste 7.3: Conquistas de Cap 1000 e Endgame
	assert_test(AchievementSystem != null, "7.7 AchievementSystem ativo")
	var cat_ach = AchievementSystem.CONQUISTAS_CATALOGO
	assert_test(cat_ach.has("mestre_dos_marcos_500"), "7.8 Conquista Nível 500 catalogada")
	assert_test(cat_ach.has("mestre_dos_marcos_750"), "7.9 Conquista Nível 750 catalogada")
	assert_test(cat_ach.has("apice_absoluto_1000"), "7.10 Conquista Platina Nível 1000 catalogada")
	assert_test(cat_ach.has("chefe_secreto_derrotado"), "7.11 Conquista de Chefe Secreto catalogada")
	assert_test(cat_ach.has("mestre_dos_4_hatsus"), "7.12 Conquista de 4 Slots de Hatsu catalogada")


# ------------------------------------------------------------------------------
# 8. Persistência e Integridade de Save/Load no Nível 1000 (Schema 2.3)
# ------------------------------------------------------------------------------
func _test_8_save_load_schema_2_3_lv1000() -> void:
	print("\n--- [BLOCO 8] Persistência & Integridade no Nível 1000 (Schema 2.3) ---")
	var slot_teste: int = 8

	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel(1000)
	PlayerData.nome_personagem = "Gon Adulto Teste"
	PlayerData.registrar_estatistica("chefes_secretos_derrotados", 2)
	SecretBossManager.registrar_pista_descoberta("pista_maha_zoldyck")

	# Salvar jogo no slot de teste
	var salvo = SaveManager.salvar_jogo(slot_teste)
	assert_test(salvo, "8.1 Jogo salvo atomicamente no Nível 1000 no slot %d" % slot_teste)

	# Resetar memória para simular reinício de sessão limpa
	PlayerData.reset()
	assert_test(PlayerData.attributes["nivel"] == 1, "8.2 Estado do PlayerData resetado para Nível 1")

	# Carregar jogo
	var carregado = SaveManager.carregar_jogo(slot_teste)
	assert_test(carregado, "8.3 Jogo carregado com sucesso do slot %d" % slot_teste)

	assert_test(PlayerData.attributes["nivel"] == 1000, "8.4 Nível 1000 restaurado com fidelidade absoluta")
	assert_test(PlayerData.attributes["vida_max"] == 61200, "8.5 HP 61.200 restaurado perfeitamente (50k base + 20% Intensificador + 2% Nexus Central)")
	assert_test(PlayerData.attributes["forca"] == 6000, "8.6 Força 6.000 restaurada (5.000 base + bônus de afinidade)")
	assert_test(PlayerData.attributes["defesa"] == 5000, "8.7 Defesa 5.000 restaurada")
	assert_test(SecretBossManager.pistas_descobertas.has("pista_maha_zoldyck"), "8.8 Pistas de chefes secretos preservadas no Schema 2.3")

	# Limpar slot de teste
	SaveManager.deletar_save(slot_teste)
	assert_test(not SaveManager.existe_save_no_slot(slot_teste), "8.9 Arquivo de teste limpo com sucesso")
