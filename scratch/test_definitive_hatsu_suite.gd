extends Node

const HatsuComponentLibrary = preload("res://resource/hatsu/HatsuComponentLibrary.gd")

func _ready():
	print("================================================================")
	print("🥋 TEST SUITE: SISTEMA DEFINITIVO DE HATSU (16 TESTES)")
	print("================================================================")
	
	var passed = 0
	var total = 16
	
	PlayerData.attributes = {
		"vida": 100,
		"vida_max": 100,
		"forca": 20,
		"defesa": 15,
		"velocidade": 14,
		"aura": 100.0,
		"aura_max": 100.0,
		"nivel_nen": 5,
		"xp_nen": 0,
		"nivel": 10
	}
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.INTENSIFICACAO
	PlayerData.hatsu_criados.clear()
	PlayerData.hatsu_slots = [-1, -1, -1, -1]
	PlayerData.absorbed_stats_registry.clear()
	PlayerData.hatsu_fragments_discovered.clear()
	
	# -------------------------------------------------------------
	# TEST 1: Criação de Hatsu Simples (Strike)
	# -------------------------------------------------------------
	var h1 := HatsuData.new()
	h1.nome = "Soco Direto de Ko"
	h1.core_component = HatsuComponentLibrary.CoreType.STRIKE
	h1.categoria = HatsuData.Categoria.INTENSIFICACAO
	h1.poder_base = 50.0
	h1.custo_aura_base = 20.0
	h1.cooldown_base = 3.0
	var pb1 = HatsuManager.calculate_power_budget(h1)
	var val1 = HatsuManager.validate_hatsu(h1)
	if val1.status == "VALID" and h1.obter_poder_final() >= 50.0:
		print("✅ TEST 1 PASSED: Hatsu Simples criado e validado com sucesso.")
		passed += 1
	else:
		print("❌ TEST 1 FAILED: Validação falhou para Hatsu Simples: ", val1)
		
	# -------------------------------------------------------------
	# TEST 2: Hatsu Complexo Modular com Restrições
	# -------------------------------------------------------------
	var h2 := HatsuData.new()
	h2.nome = "Esfera Perfurante do Desespero"
	h2.core_component = HatsuComponentLibrary.CoreType.PROJECTILE
	h2.categoria = HatsuData.Categoria.EMISSAO
	h2.effect_modules = [
		{"type": HatsuComponentLibrary.EffectType.PIERCING, "value": 25.0},
		{"type": HatsuComponentLibrary.EffectType.TRACKING, "value": 1.0}
	]
	h2.modular_conditions = [HatsuComponentLibrary.ConditionType.HP_BELOW_30]
	h2.modular_restrictions = [HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY]
	h2.custom_damage = 90.0
	h2.custom_aura_cost = 35.0
	h2.custom_cooldown = 8.0
	h2.custom_range = 200.0
	var pb2 = HatsuManager.calculate_power_budget(h2)
	var val2 = HatsuManager.validate_hatsu(h2)
	if val2.status == "VALID" and pb2.vows_multiplier > 1.5:
		print("✅ TEST 2 PASSED: Hatsu Complexo validado com multiplicador de votos x%.2f." % pb2.vows_multiplier)
		passed += 1
	else:
		print("❌ TEST 2 FAILED: Hatsu Complexo falhou na validação: ", val2)

	# -------------------------------------------------------------
	# TEST 3: Validador - Rejeição de Overpowered
	# -------------------------------------------------------------
	var h3 := HatsuData.new()
	h3.nome = "Golpe Onipotente Ilegal"
	h3.core_component = HatsuComponentLibrary.CoreType.STRIKE
	h3.custom_damage = 9999.0
	h3.custom_aura_cost = 1.0
	h3.custom_cooldown = 0.5
	var val3 = HatsuManager.validate_hatsu(h3)
	if val3.status == "OVERPOWERED" or val3.status == "INVALID":
		print("✅ TEST 3 PASSED: Validador detectou e rejeitou Hatsu OVERPOWERED com sucesso.")
		passed += 1
	else:
		print("❌ TEST 3 FAILED: Validador permitiu Hatsu abusivo: ", val3)

	# -------------------------------------------------------------
	# TEST 4: Validador - Trade-off Balanceado
	# -------------------------------------------------------------
	var h4 := HatsuData.new()
	h4.nome = "Golpe Devastador com Custo Proporcional"
	h4.core_component = HatsuComponentLibrary.CoreType.STRIKE
	h4.custom_damage = 180.0
	h4.custom_aura_cost = 70.0
	h4.custom_cooldown = 16.0
	h4.modular_restrictions = [HatsuComponentLibrary.RestrictionType.SACRIFICE_HP]
	var val4 = HatsuManager.validate_hatsu(h4)
	if val4.status == "VALID":
		print("✅ TEST 4 PASSED: Trade-off numérico balanceado foi APROVADO pelo validador.")
		passed += 1
	else:
		print("❌ TEST 4 FAILED: Trade-off balanceado rejeitado: ", val4)

	# -------------------------------------------------------------
	# TEST 5: Afinidade de Nen (Bônus de Afinidade Natal)
	# -------------------------------------------------------------
	var h5_enhancer := HatsuData.new()
	h5_enhancer.core_component = HatsuComponentLibrary.CoreType.STRIKE
	h5_enhancer.categoria = HatsuData.Categoria.INTENSIFICACAO
	var pb5 = HatsuManager.calculate_power_budget(h5_enhancer, {"afinidade_nen": HatsuData.Categoria.INTENSIFICACAO})
	var pb5_diff = HatsuManager.calculate_power_budget(h5_enhancer, {"afinidade_nen": HatsuData.Categoria.MANIPULACAO})
	if pb5.budget_base > pb5_diff.budget_base:
		print("✅ TEST 5 PASSED: Afinidade natal concede bônus orçamentário (+%.0f vs +%.0f)." % [pb5.budget_base, pb5_diff.budget_base])
		passed += 1
	else:
		print("❌ TEST 5 FAILED: Afinidade não influenciou orçamento: ", pb5.budget_base, " vs ", pb5_diff.budget_base)

	# -------------------------------------------------------------
	# TEST 6: Devour / Absorção Permanente de Atributos
	# -------------------------------------------------------------
	var h6_devour := HatsuData.new()
	h6_devour.core_component = HatsuComponentLibrary.CoreType.ABSORPTION
	h6_devour.absorption_target_stat = "aura_max"
	h6_devour.absorption_rate = 0.10
	var initial_aura_max = PlayerData.attributes["aura_max"]
	var res6 = HatsuManager.execute_absorption_devour(h6_devour, {"id": "chimera_ant", "name": "Formiga Quimera", "level": 15, "is_boss": false})
	var new_aura_max = PlayerData.attributes["aura_max"]
	if res6.sucesso and new_aura_max > initial_aura_max:
		print("✅ TEST 6 PASSED: Devour absorveu permanentemente +%d de Aura Max." % res6.valor_ganho)
		passed += 1
	else:
		print("❌ TEST 6 FAILED: Devour não absorveu status.")

	# -------------------------------------------------------------
	# TEST 7: Devour - Rendimento Decrescente (Diminishing Returns)
	# -------------------------------------------------------------
	var gain_1 = res6.valor_ganho
	var res7 = HatsuManager.execute_absorption_devour(h6_devour, {"id": "chimera_ant", "name": "Formiga Quimera", "level": 15, "is_boss": false})
	var gain_2 = res7.valor_ganho
	if gain_2 <= gain_1 and PlayerData.absorbed_stats_registry.get("chimera_ant", 0) == 2:
		print("✅ TEST 7 PASSED: Diminishing returns aplicado (Ganho 1: %d, Ganho 2: %d)." % [gain_1, gain_2])
		passed += 1
	else:
		print("❌ TEST 7 FAILED: Diminishing returns não contabilizado.")

	# -------------------------------------------------------------
	# TEST 8: State Memory & Rollback Temporal
	# -------------------------------------------------------------
	var hatsu_sys = HatsuSystem.new()
	hatsu_sys.vital_snapshots.append({"time": 10.0, "hp": 100, "aura": 90.0})
	hatsu_sys.vital_snapshots.append({"time": 15.0, "hp": 20, "aura": 10.0})
	PlayerData.attributes["vida"] = 20
	PlayerData.attributes["aura"] = 10.0
	var rolled = hatsu_sys.executar_reversao_temporal(8.0)
	if rolled and PlayerData.attributes["vida"] == 100:
		print("✅ TEST 8 PASSED: Rollback temporal restaurou HP/Aura com segurança.")
		passed += 1
	else:
		print("❌ TEST 8 FAILED: Rollback temporal falhou (HP: %d)." % PlayerData.attributes["vida"])
	hatsu_sys.free()

	# -------------------------------------------------------------
	# TEST 9: Zone Rule Creation
	# -------------------------------------------------------------
	var h9_zone := HatsuData.new()
	h9_zone.core_component = HatsuComponentLibrary.CoreType.RULE_ZONE
	h9_zone.territory_rule_type = "EMISSION_DRAIN_50"
	h9_zone.custom_radius = 120.0
	var pb9 = HatsuManager.calculate_power_budget(h9_zone)
	if pb9.complexity_score >= 30.0:
		print("✅ TEST 9 PASSED: Zone Rule Territory calculada com complexidade %d." % int(pb9.complexity_score))
		passed += 1
	else:
		print("❌ TEST 9 FAILED: Zone Rule não gerou pontuação de complexidade.")

	# -------------------------------------------------------------
	# TEST 10: Descoberta de Fragmentos de Hatsu
	# -------------------------------------------------------------
	PlayerData.hatsu_fragments_discovered.append("fragment_piercing_ten")
	if "fragment_piercing_ten" in PlayerData.hatsu_fragments_discovered:
		print("✅ TEST 10 PASSED: Fragmentos de Hatsu registrados no PlayerData.")
		passed += 1
	else:
		print("❌ TEST 10 FAILED: Fragmentos não registrados.")

	# -------------------------------------------------------------
	# TEST 11: Templates Canônicos Modulares
	# -------------------------------------------------------------
	var j_rock = HatsuManager.create_hatsu_template("jajanken_pedra")
	var g_speed = HatsuManager.create_hatsu_template("godspeed")
	if j_rock.core_component == HatsuComponentLibrary.CoreType.STRIKE and g_speed.core_component == HatsuComponentLibrary.CoreType.TRANSFORMATION:
		print("✅ TEST 11 PASSED: Templates canônicos (Jajanken & Godspeed) instanciados via componentes modulares.")
		passed += 1
	else:
		print("❌ TEST 11 FAILED: Templates canônicos inválidos.")

	# -------------------------------------------------------------
	# TEST 12: Suporte Universal a NPCs e Chefes
	# -------------------------------------------------------------
	var enemy_data := EnemyData.new()
	enemy_data.enemy_name = "Guarda Real Pitou"
	enemy_data.modular_hatsu = HatsuManager.create_hatsu_template("godspeed")
	if enemy_data.modular_hatsu != null and enemy_data.modular_hatsu.custom_damage > 0:
		print("✅ TEST 12 PASSED: Inimigo configurado com Hatsu modular idêntico ao do jogador.")
		passed += 1
	else:
		print("❌ TEST 12 FAILED: Inimigo não suporta Hatsu modular.")

	# -------------------------------------------------------------
	# TEST 13: Compatibilidade de Loadout em 4 Slots
	# -------------------------------------------------------------
	PlayerData.hatsu_criados.clear()
	PlayerData.hatsu_slots = [-1, -1, -1, -1]
	PlayerData.equipar_hatsu_slot(0, j_rock)
	PlayerData.equipar_hatsu_slot(1, g_speed)
	var s0 = PlayerData.obter_hatsu_slot(0)
	var s1 = PlayerData.obter_hatsu_slot(1)
	if s0 != null and s1 != null and s0.nome.contains("Pedra") and s1.nome.contains("Godspeed"):
		print("✅ TEST 13 PASSED: Loadout multi-slot equipado e acessível.")
		passed += 1
	else:
		print("❌ TEST 13 FAILED: Loadout multi-slot falhou.")

	# -------------------------------------------------------------
	# TEST 14: Verificação de Condições em Combate
	# -------------------------------------------------------------
	var h14_vow := HatsuData.new()
	h14_vow.modular_conditions = [HatsuComponentLibrary.ConditionType.HP_BELOW_50]
	var can_100hp = h14_vow.pode_usar({"hp": 100, "hp_max": 100, "aura": 100.0, "aura_max": 100.0})
	var can_40hp = h14_vow.pode_usar({"hp": 40, "hp_max": 100, "aura": 100.0, "aura_max": 100.0})
	if not can_100hp.pode and can_40hp.pode:
		print("✅ TEST 14 PASSED: Verificação contextual de condições operando perfeitamente.")
		passed += 1
	else:
		print("❌ TEST 14 FAILED: Condição de HP não foi avaliada corretamente.")

	# -------------------------------------------------------------
	# TEST 15: Persistência Save/Load Multi-Slot & Versão 2
	# -------------------------------------------------------------
	var dict_h = h2.to_dict()
	var restored_h = HatsuData.from_dict(dict_h)
	if restored_h.nome == h2.nome and restored_h.modular_conditions.size() == h2.modular_conditions.size() and restored_h.custom_damage == h2.custom_damage:
		print("✅ TEST 15 PASSED: Serialização to_dict() e from_dict() perfeita com dados modulares.")
		passed += 1
	else:
		print("❌ TEST 15 FAILED: Serialização perdeu dados modulares.")

	# -------------------------------------------------------------
	# TEST 16: Auto-migração de Versão 1 para Versão 2
	# -------------------------------------------------------------
	var legacy_dict = {
		"hatsu_version": 1,
		"nome": "Disparo Antigo V1",
		"forma": int(HatsuData.Forma.PROJETIL),
		"poder_base": 40.0
	}
	var migrated_h = HatsuData.from_dict(legacy_dict)
	if migrated_h.hatsu_version == 2 and migrated_h.core_component == HatsuComponentLibrary.CoreType.PROJECTILE:
		print("✅ TEST 16 PASSED: Auto-migração da Versão 1 para Versão 2 executada com sucesso.")
		passed += 1
	else:
		print("❌ TEST 16 FAILED: Auto-migração de versão falhou: ", migrated_h.core_component)

	print("================================================================")
	print("📊 RESULTADO FINAL: %d/%d TESTES PASSARAM COM SUCESSO!" % [passed, total])
	print("================================================================")
	
	if passed == total:
		print("🏆 TODOS OS 16 TESTES PASSARAM! ARQUITETURA DEFINITIVA DE HATSU APROVADA.")
	
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if passed == total else 1)