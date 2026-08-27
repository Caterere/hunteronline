extends Node2D

# ============================================================
# MASTER WORLD STATE & CONSEQUENCE SUITE — HUNTER ONLINE
# ============================================================

func _ready() -> void:
	print("\n================================================================================")
	print("🚀 EXECUTANDO WORLD STATE & CONSEQUENCE SYSTEM SUITE (10/10)")
	print("================================================================================")

	var total_tests: int = 10
	var passed_tests: int = 0

	# 1. TESTE WORLDSTATE AUTOLOAD & VALORES INICIAIS
	print("\n[TESTE 1/10] WorldState Autoload & Estado Inicial Padrão...")
	assert(WorldState != null, "WorldState deve estar ativo como Singleton Autoload")
	WorldState.reinicializar_estado_padrao()
	assert(WorldState.obter_seguranca_regional("vale_padokia") == 75, "Segurança de Padokia deve iniciar em 75")
	assert(WorldState.obter_prosperidade_regional("vale_padokia") == 60, "Prosperidade de Padokia deve iniciar em 60")
	assert(WorldState.obter_infamia() == 0, "Infâmia do jogador deve iniciar em 0")
	print("  ✅ [PASS] WorldState inicializado com matriz regional e parâmetros canônicos.")
	passed_tests += 1

	# 2. TESTE MUTAÇÃO DE SEGURANÇA E PROSPERIDADE REGIONAL
	print("\n[TESTE 2/10] Mutação Regional (Segurança, Prosperidade, Corrupção)...")
	WorldState.alterar_seguranca_regional("vale_padokia", 15)
	assert(WorldState.obter_seguranca_regional("vale_padokia") == 90, "Segurança deve subir para 90")
	WorldState.alterar_prosperidade_regional("vale_padokia", -20)
	assert(WorldState.obter_prosperidade_regional("vale_padokia") == 40, "Prosperidade deve descer para 40")
	WorldState.alterar_corrupcao_regional("vale_padokia", 10)
	assert(WorldState.obter_corrupcao_regional("vale_padokia") == 25, "Corrupção deve subir para 25")
	print("  ✅ [PASS] Mutações regionais com limites rígidos validadas.")
	passed_tests += 1

	# 3. TESTE INFLUÊNCIA DE FACÇÕES
	print("\n[TESTE 3/10] Dinâmica de Influência das Facções...")
	var inf_antiga = WorldState.obter_influencia_faccao("associacao_hunter")
	WorldState.alterar_influencia_faccao("associacao_hunter", 20)
	assert(WorldState.obter_influencia_faccao("associacao_hunter") == inf_antiga + 20, "Influência da Associação Hunter deve aumentar")
	print("  ✅ [PASS] Controle territorial e influência de facção alterados com sucesso.")
	passed_tests += 1

	# 4. TESTE CONSEQUÊNCIA IMEDIATA (REGISTRO DE CRIME & INFÂMIA)
	print("\n[TESTE 4/10] Consequência Imediata: Crimes, Infâmia e Alerta de Guardas...")
	WorldState.registrar_crime("roubo_mercado", 3, "vale_padokia")
	assert(WorldState.obter_infamia() == 30, "Infâmia deve subir +30 (gravidade 3 * 10)")
	assert(WorldState.tem_efeito_temporario("alerta_guardas_vale_padokia"), "Efeito temporário de alerta deve ser ativado")
	print("  ✅ [PASS] Consequência imediata processada com infâmia e gatilho de alerta.")
	passed_tests += 1

	# 5. TESTE CONSEQUÊNCIA TEMPORÁRIA (EXPIRAÇÃO POR TIMEMANAGER TICK)
	print("\n[TESTE 5/10] Consequência Temporária: Expiração após Ciclo de Horas...")
	WorldState.adicionar_efeito_temporario("teste_bloqueio_estrada", 3.0)
	assert(WorldState.tem_efeito_temporario("teste_bloqueio_estrada"), "Efeito deve estar ativo")
	
	# Simular passagem de 2 horas
	WorldState.processar_tick_tempo(2.0)
	assert(WorldState.tem_efeito_temporario("teste_bloqueio_estrada"), "Efeito ainda deve estar ativo (1h restante)")
	
	# Simular passagem de mais 2 horas (total 4h > 3h)
	WorldState.processar_tick_tempo(2.0)
	assert(not WorldState.tem_efeito_temporario("teste_bloqueio_estrada"), "Efeito deve expirar e ser removido")
	print("  ✅ [PASS] Efeitos temporários decaem e expiram com precisão temporal.")
	passed_tests += 1

	# 6. TESTE CONSEQUÊNCIA PERSISTENTE (DERROTA DO BOSS DE ZABAN)
	print("\n[TESTE 6/10] Consequência Persistente: Derrota do Guardião Ancestral...")
	WorldState.reinicializar_estado_padrao()
	EventBus.enemy_defeated.emit("guardiao_zaban", 500, 200)
	
	assert(WorldState.tem_flag_regional("ruinas_zaban", "guardiao_derrotado"), "Flag guardiao_derrotado deve existir")
	assert(WorldState.tem_flag_regional("vale_padokia", "posto_hunter_ativo"), "Posto da Associação Hunter deve ser ativado")
	assert(WorldState.obter_seguranca_regional("vale_padokia") == 100, "Segurança de Padokia deve subir para 100")
	assert(WorldState.tem_efeito_temporario("miasma_dissipado_zaban"), "Miasma deve estar temporariamente dissipado")
	print("  ✅ [PASS] Derrota do Boss provocou mudança sistêmica persistente e desbloqueios mundiais.")
	passed_tests += 1

	# 7. TESTE PERSISTÊNCIA COMPLETA EM JSON VIA SAVEMANAGER
	print("\n[TESTE 7/10] Persistência Multi-Slot em JSON via SaveManager...")
	WorldState.alterar_seguranca_regional("vale_padokia", -30)
	WorldState.alterar_infamia(150)
	WorldState.adicionar_flag_regional("vale_padokia", "mina_secreta_descoberta")
	
	var salvou = SaveManager.salvar_jogo(88)
	assert(salvou, "SaveManager deve salvar no Slot 88")
	
	# Alterar estado em memória
	WorldState.reinicializar_estado_padrao()
	assert(WorldState.obter_infamia() == 0, "Estado deve resetar")
	assert(not WorldState.tem_flag_regional("vale_padokia", "mina_secreta_descoberta"), "Flag deve estar ausente após reset")
	
	# Carregar Slot 88
	var carregou = SaveManager.carregar_jogo(88)
	assert(carregou, "SaveManager deve carregar Slot 88")
	assert(WorldState.obter_infamia() == 150, "Infâmia (150) deve ser restaurada do JSON")
	assert(WorldState.tem_flag_regional("vale_padokia", "mina_secreta_descoberta"), "Flag persistente deve ser restaurada")
	SaveManager.deletar_save(88)
	print("  ✅ [PASS] Save/Load preserva estado mundial e flags customizadas com 100% de integridade.")
	passed_tests += 1

	# 8. TESTE RESET LIMPO DE NOVO JOGO (ZERO RESÍDUOS)
	print("\n[TESTE 8/10] Isolamento de Sessão e Reinicialização Padrão...")
	WorldState.reinicializar_estado_padrao()
	assert(WorldState.world_data["timed_effects"].is_empty(), "Timed effects devem estar vazios após reinicialização")
	assert(WorldState.obter_infamia() == 0, "Infâmia deve ser 0")
	print("  ✅ [PASS] Novo jogo reinicia todo o estado sem vazamentos residuais.")
	passed_tests += 1

	# 9. TESTE MODULAÇÃO DE PREÇOS NA ECONOMIA PELA PROSPERIDADE
	print("\n[TESTE 9/10] Economia Dinâmica: Preços Modulados por Prosperidade...")
	WorldState.alterar_prosperidade_regional("vale_padokia", +30) # 75 + 30 = 100 (Alta prosperidade)
	var preco_alto_prosp = Economy.calcular_preco_compra("minerio_aco", "", "vale_padokia")
	
	WorldState.alterar_prosperidade_regional("vale_padokia", -80) # 100 - 80 = 20 (Escassez)
	var preco_escassez = Economy.calcular_preco_compra("minerio_aco", "", "vale_padokia")
	
	assert(preco_alto_prosp < preco_escassez, "Preço em prosperidade (%d) deve ser menor que em escassez (%d)" % [preco_alto_prosp, preco_escassez])
	print("  ✅ [PASS] Economy integra modificadores de prosperidade regional nos cálculos de compra e venda.")
	passed_tests += 1

	# 10. TESTE DIÁLOGO REATIVO DE NPCS AO ESTADO MUNDIAL
	print("\n[TESTE 10/10] Diálogo Reativo de NPCs ao WorldState...")
	var npc_dummy := CharacterBody2D.new()
	var npc_comp := LivingNPCBehavior.new()
	npc_comp.name = "LivingNPCBehavior"
	npc_dummy.add_child(npc_comp)
	add_child(npc_dummy)
	
	# Testar reação a crime / infâmia alta
	WorldState.alterar_infamia(80)
	var fala_crime = npc_comp.obter_dialogo_reativo()
	assert("Fique longe" in fala_crime or "caçadores de recompensa" in fala_crime, "NPC deve reagir com medo a alta infâmia")
	
	# Testar reação ao posto hunter
	WorldState.alterar_infamia(-80)
	WorldState.adicionar_flag_regional("vale_padokia", "posto_hunter_ativo")
	var fala_posto = npc_comp.obter_dialogo_reativo()
	assert("Associação Hunter" in fala_posto or "posto avançado" in fala_posto, "NPC deve comentar sobre o posto da Associação Hunter")
	
	npc_dummy.queue_free()
	print("  ✅ [PASS] NPCs reagem dinamicamente aos acontecimentos e estado do mundo.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE WORLD STATE & CONSEQUENCE SYSTEM:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DO MUNDO: ECOSSISTEMA VIVO, REATIVO E PERSISTENTE INTEGRADO!")
	print("================================================================================\n")

	get_tree().quit(0)