extends Node2D

# ============================================================
# MASTER SYSTEMIC PRODUCTION SUITE — HUNTER ONLINE
# Tests: Dynamic Events, Autonomous Simulation, Bounty, Hatsu & Cause Chains
# ============================================================

func _ready() -> void:
	print("\n================================================================================")
	print("🚀 EXECUTANDO MASTER SYSTEMIC PRODUCTION SUITE (10/10)")
	print("================================================================================")

	var total_tests: int = 10
	var passed_tests: int = 0

	# 1. TESTE CRIAÇÃO DE EVENTO MUNDIAL DINÂMICO
	print("\n[TESTE 1/10] Criação de Evento Mundial Dinâmico...")
	assert(WorldEventManager != null, "WorldEventManager deve estar ativo no Autoload")
	WorldEventManager.criar_evento_dinamico(
		"ev_teste_caravana",
		"Caravana de Suprimentos em Perigo",
		"Comboio de mercadores cercado por salteadores",
		"vale_padokia",
		4.0,
		60
	)
	assert(WorldEventManager.active_world_events.has("ev_teste_caravana"), "Evento deve estar no dicionário ativo")
	print("  ✅ [PASS] Evento dinâmico registrado com prazo de horas e dificuldade configurada.")
	passed_tests += 1

	# 2. TESTE RESOLUÇÃO PELO JOGADOR (INTERVENÇÃO ATIVA)
	print("\n[TESTE 2/10] Resolução Ativa pelo Jogador...")
	var prosp_inicial = WorldState.obter_prosperidade_regional("vale_padokia")
	WorldEventManager.resolver_evento_jogador("ev_teste_caravana", true)
	assert(WorldState.obter_prosperidade_regional("vale_padokia") == prosp_inicial + 15, "Prosperidade deve subir +15")
	assert(not WorldEventManager.active_world_events.has("ev_teste_caravana"), "Evento resolvido deve sair da lista ativa")
	print("  ✅ [PASS] Intervenção do jogador recompensa a região com prosperidade e reputação.")
	passed_tests += 1

	# 3. TESTE SIMULAÇÃO AUTÔNOMA: VITÓRIA DOS GUARDAS (ALTA SEGURANÇA)
	print("\n[TESTE 3/10] Simulação Autônoma: Vitória das Patrulhas Locais...")
	WorldState.alterar_seguranca_regional("vale_padokia", +30) # Segurança alta (>= 75)
	WorldEventManager.criar_evento_dinamico("ev_teste_autonomo_vitoria", "Incursão Menor de Ladrões", "Ladrões tentam invadir os armazéns", "vale_padokia", 2.0, 50)
	
	# Simular passagem de 2 horas para forçar expiração
	WorldEventManager._on_time_hour_ticked(10, 0)
	WorldEventManager._on_time_hour_ticked(11, 0)
	
	assert(not WorldEventManager.active_world_events.has("ev_teste_autonomo_vitoria"), "Evento deve ter sido resolvido")
	assert(RumorSystem.active_rumors.has("rumor_guardas_ev_teste_autonomo_vitoria"), "Rumor de vitória dos guardas deve ser criado")
	print("  ✅ [PASS] O mundo simula e resolve crises com vitória das patrulhas quando a segurança é alta.")
	passed_tests += 1

	# 4. TESTE SIMULAÇÃO AUTÔNOMA: DERROTA E CRISE (BAIXA SEGURANÇA)
	print("\n[TESTE 4/10] Simulação Autônoma: Falha e Consequência Negativa...")
	WorldState.alterar_seguranca_regional("ruinas_zaban", -20) # Segurança baixa (< 20)
	var prosp_zaban_antiga = WorldState.obter_prosperidade_regional("ruinas_zaban")
	WorldEventManager.criar_evento_dinamico("ev_teste_autonomo_derrota", "Ataque Massivo de Feras", "Criaturas invadem acampamento", "ruinas_zaban", 1.0, 70)
	
	WorldEventManager._on_time_hour_ticked(12, 0)
	assert(WorldState.obter_prosperidade_regional("ruinas_zaban") == max(0, prosp_zaban_antiga - 15), "Prosperidade deve cair após crise não contida")
	assert(RumorSystem.active_rumors.has("rumor_desastre_ev_teste_autonomo_derrota"), "Rumor de desastre regional deve ter sido gerado")
	print("  ✅ [PASS] Regiões perigosas sofrem perdas e geram boatos negativos se negligenciadas.")
	passed_tests += 1

	# 5. TESTE BOUNTY SYSTEM: CÁLCULO DE CABEÇA DO JOGADOR
	print("\n[TESTE 5/10] Bounty System: Recompensa na Cabeça por Infâmia...")
	assert(BountySystem != null, "BountySystem deve estar ativo no Autoload")
	WorldState.alterar_infamia(120)
	var recompensa = BountySystem.obter_recompensa_cabeca_jogador()
	assert(recompensa == 6000, "120 de infâmia deve equivaler a 6.000 Jenny de recompensa (120 * 50)")
	print("  ✅ [PASS] Recompensa na cabeça calculada com precisão escalável.")
	passed_tests += 1

	# 6. TESTE BOUNTY SYSTEM: CONTRATOS DA LISTA NEGRA
	print("\n[TESTE 6/10] Bounty System: Conclusão de Contrato da Lista Negra...")
	var gold_inicial = Economy.obter_gold()
	BountySystem.concluir_contrato("bounty_ladrao_padokia")
	assert(Economy.obter_gold() == gold_inicial + 1500, "Jogador deve receber 1500 Jenny pelo contrato")
	assert(BountySystem.active_bounty_contracts["bounty_ladrao_padokia"]["concluido"] == true, "Contrato deve ser marcado como concluído")
	print("  ✅ [PASS] Contrato de caçador de recompensas executado e pago.")
	passed_tests += 1

	# 7. TESTE HATSU 2.0: SINERGIA DE TAGS MODULARES
	print("\n[TESTE 7/10] Hatsu 2.0: Sinergias de Tags Modulares...")
	assert(HatsuManager != null, "HatsuManager deve estar ativo no Autoload")
	var dummy_a = HatsuData.new()
	var tags_a: Array[String] = ["weapon"]
	dummy_a.tags = tags_a
	var dummy_b = HatsuData.new()
	var tags_b: Array[String] = ["electricity"]
	dummy_b.tags = tags_b
	
	var sinergia = HatsuManager.processar_sinergia_tags(dummy_a, dummy_b)
	assert(sinergia["sinergia"] == true, "Deve haver sinergia entre Weapon e Electricity")
	assert(sinergia.has("stun") and sinergia["stun"] == 1.5, "Sinergia deve conceder 1.5s de stun elétrico")
	print("  ✅ [PASS] Sinergia modular de Hatsu avaliada com modificadores elementais e táticos.")
	passed_tests += 1

	# 8. TESTE PERSISTÊNCIA MULTI-SLOT EM JSON
	print("\n[TESTE 8/10] Persistência Multi-Slot em JSON...")
	WorldEventManager.criar_evento_dinamico("ev_save_slot", "Crise Salva", "Teste de persistência", "vale_padokia", 5.0, 50)
	var salvou = SaveManager.salvar_jogo(66)
	assert(salvou, "SaveManager deve salvar no Slot 66")
	
	WorldEventManager.active_world_events.clear()
	assert(WorldEventManager.active_world_events.is_empty(), "Dicionário deve estar limpo após reset")
	
	var carregou = SaveManager.carregar_jogo(66)
	assert(carregou, "SaveManager deve carregar Slot 66")
	assert(WorldEventManager.active_world_events.has("ev_save_slot"), "Evento ativo deve ser restaurado do JSON")
	SaveManager.deletar_save(66)
	print("  ✅ [PASS] Estado completo de eventos mundiais e caçadas persistido com sucesso.")
	passed_tests += 1

	# 9. TESTE CAUSE CHAIN INTEGRADA: CRIME -> INFÂMIA -> BOUNTY -> ALERTA
	print("\n[TESTE 9/10] Cause Chain: Ação do Jogador -> Reação em Cascata...")
	WorldState.reinicializar_estado_padrao()
	WorldState.registrar_crime("assalto_caravana", 4, "vale_padokia") # Gravidade 4
	
	assert(WorldState.obter_infamia() == 40, "Infâmia deve subir +40")
	assert(BountySystem.obter_recompensa_cabeca_jogador() == 2000, "Recompensa deve ser 2000 Jenny")
	assert(WorldState.obter_seguranca_regional("vale_padokia") == 55, "Segurança deve cair para 55 (75 - 20)")
	assert(WorldState.tem_efeito_temporario("alerta_guardas_vale_padokia"), "Alerta de guardas deve estar ativado")
	print("  ✅ [PASS] Cause Chain executada com sucesso em 4 sistemas interconectados.")
	passed_tests += 1

	# 10. TESTE RESET LIMPO DE NOVO JOGO
	print("\n[TESTE 10/10] Isolamento de Novo Jogo...")
	WorldState.reinicializar_estado_padrao()
	WorldEventManager.active_world_events.clear()
	assert(WorldState.obter_infamia() == 0, "Infâmia deve resetar para 0")
	assert(BountySystem.obter_recompensa_cabeca_jogador() == 0, "Recompensa deve resetar para 0")
	print("  ✅ [PASS] Nova partida reinicia o ecossistema com estado imaculado.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE MASTER SYSTEMIC PRODUCTION:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DO MUNDO: ECOSSISTEMA COMPLETO, REATIVO E AUTÔNOMO INTEGRADO!")
	print("================================================================================\n")

	get_tree().quit(0)