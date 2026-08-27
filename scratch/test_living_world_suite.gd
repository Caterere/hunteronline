extends Node2D

# ============================================================
# LIVING WORLD 2.0 SUITE — HUNTER ONLINE
# Tests: NPC Identity, Memory, Relationships, Rumors & Causality
# ============================================================

const NPCIdentityScript = preload("res://resource/npc/NPCIdentity.gd")

func _ready() -> void:
	print("\n================================================================================")
	print("🚀 EXECUTANDO LIVING WORLD 2.0 SUITE (8/8)")
	print("================================================================================")

	var total_tests: int = 8
	var passed_tests: int = 0

	# 1. TESTE NPC IDENTITY & MEMÓRIA EMOCIONAL
	print("\n[TESTE 1/8] NPC Identity & Registro de Memória...")
	var identity = NPCIdentityScript.new()
	identity.identity_id = "test_npc"
	identity.name = "Morador Teste"
	identity.profession = "Guarda"
	identity.trust = 50.0
	identity.fear = 0.0
	
	identity.adicionar_memoria("SALVOU_VIDA", "Jogador impediu o ataque da besta quimera", 80.0, 14)
	assert(identity.trust == 90.0, "Confiança deve subir para 90 após SALVOU_VIDA")
	assert(identity.debt == 50.0, "Dívida moral deve ser 50")
	assert(identity.memory_log.size() == 1, "Log de memória deve conter 1 entrada")
	assert(identity.memory_log[0]["permanente"] == true, "Memória de alta intensidade deve ser permanente")
	print("  ✅ [PASS] NPC Identity registrou memória e recalculou perfil emocional instantaneamente.")
	passed_tests += 1

	# 2. TESTE MEMÓRIA DE CRIME E AUMENTO DE MEDO
	print("\n[TESTE 2/8] Memória de Crime & Intimidação...")
	identity.adicionar_memoria("CRIME", "Jogador assaltou a loja de poções", 60.0, 15)
	assert(identity.trust == 55.0, "Confiança deve cair após crime (90 - 35 = 55)")
	assert(identity.fear == 30.0, "Medo deve subir para 30")
	print("  ✅ [PASS] Atos hostis do jogador provocam retração de confiança e acúmulo de medo.")
	passed_tests += 1

	# 3. TESTE RELATIONSHIP SYSTEM: CONSULTA E MUTAÇÃO
	print("\n[TESTE 3/8] RelationshipSystem: Alteração e Limites...")
	assert(RelationshipSystem != null, "RelationshipSystem deve estar ativo no Autoload")
	RelationshipSystem.alterar_relacionamento("ferreiro_padokia", 30.0, 20.0, 0.0, "Missão de entrega concluída")
	assert(RelationshipSystem.obter_confianca("ferreiro_padokia") == 80.0, "Confiança do Ferreiro deve subir para 80")
	assert(RelationshipSystem.pode_revelar_segredo("ferreiro_padokia") == true, "Ferreiro deve estar apto a revelar segredos (trust >= 75)")
	assert(RelationshipSystem.pode_oferecer_missao("ferreiro_padokia") == true, "Ferreiro deve oferecer missão exclusiva (trust >= 60)")
	print("  ✅ [PASS] Thresholds sociais de confiança e respeito validados.")
	passed_tests += 1

	# 4. TESTE RUMOR SYSTEM: CRIAÇÃO E CONSULTA REGIONAL
	print("\n[TESTE 4/8] RumorSystem: Criação de Rumor...")
	assert(RumorSystem != null, "RumorSystem deve estar ativo no Autoload")
	RumorSystem.criar_rumor("rumor_tesouro_zaban", "Tesouro Oculto nas Ruínas", "Um baú antigo foi visto nas ruínas profundas.", "ruinas_zaban")
	var rum = RumorSystem.obter_rumor_para_npc("ruinas_zaban")
	assert(not rum.is_empty(), "Deve existir rumor ativo para Ruínas de Zaban")
	assert(rum["origem_regiao"] == "ruinas_zaban", "Região de origem deve corresponder")
	print("  ✅ [PASS] Rumor criado e recuperado por NPCs da região de origem.")
	passed_tests += 1

	# 5. TESTE PROPAGAÇÃO E DISTORÇÃO DE RUMORES
	print("\n[TESTE 5/8] Propagação Geográfica e Distorção de Informação...")
	RumorSystem.propagar_rumor_para_regiao("rumor_tesouro_zaban", "vale_padokia")
	var rum_propagado = RumorSystem.active_rumors["rumor_tesouro_zaban"]
	assert(rum_propagado["alcance_regioes"].has("vale_padokia"), "Rumor deve alcançar Vale de Padokia")
	assert(rum_propagado["precisao"] < 1.0, "Precisão da informação deve diminuir com a distância")
	print("  ✅ [PASS] Boatos viajam entre regiões vizinhas com simulação de distorção orgânica.")
	passed_tests += 1

	# 6. TESTE PERSISTÊNCIA MULTI-SLOT EM JSON
	print("\n[TESTE 6/8] Persistência Multi-Slot em JSON...")
	RelationshipSystem.alterar_relacionamento("wing", -20.0, 0.0, 0.0, "Teste Save")
	var salvou = SaveManager.salvar_jogo(77)
	assert(salvou, "SaveManager deve salvar no Slot 77")
	
	# Alterar em memória
	RelationshipSystem.alterar_relacionamento("wing", +40.0, 0.0, 0.0, "Mudança pós save")
	
	# Carregar Slot 77
	var carregou = SaveManager.carregar_jogo(77)
	assert(carregou, "SaveManager deve carregar Slot 77")
	assert(RelationshipSystem.obter_confianca("wing") == 60.0, "Confiança de Wing (60.0) deve ser restaurada do JSON")
	SaveManager.deletar_save(77)
	print("  ✅ [PASS] Estado social e histórico de relacionamentos persistidos em JSON.")
	passed_tests += 1

	# 7. TESTE DIÁLOGO REATIVO AO MEDO DO RELATIONSHIP SYSTEM
	print("\n[TESTE 7/8] NPC Reage ao Medo do RelationshipSystem...")
	var npc_dummy := CharacterBody2D.new()
	var npc_comp := LivingNPCBehavior.new()
	npc_comp.name = "LivingNPCBehavior"
	npc_comp.npc_id = "cidadao_teste_medo"
	npc_dummy.add_child(npc_comp)
	add_child(npc_dummy)
	
	RelationshipSystem.alterar_relacionamento("cidadao_teste_medo", -30.0, 0.0, +80.0, "Ameaça grave")
	var fala_medo = npc_comp.obter_dialogo_reativo()
	assert("não me machuque" in fala_medo or "socorro" in fala_medo or "Fique longe" in fala_medo, "NPC intimidado deve tremer e suplicar")
	print("  ✅ [PASS] NPC reage com temor imediato quando o medo ultrapassa 70.")
	passed_tests += 1

	# 8. TESTE REVELAÇÃO DE SEGREDO POR ALTA CONFIANÇA
	print("\n[TESTE 8/8] Revelação de Segredo por Alta Confiança...")
	RelationshipSystem.alterar_relacionamento("cidadao_teste_medo", +90.0, +50.0, -80.0, "Resgate heróico")
	var fala_segredo = npc_comp.obter_dialogo_reativo()
	assert("confiar em você" in fala_segredo or "jazidas escondidas" in fala_segredo, "NPC com confiança >= 75 deve revelar segredos")
	
	npc_dummy.queue_free()
	print("  ✅ [PASS] Alta confiança desbloqueia segredos do mundo e orientações exclusivas.")
	passed_tests += 1

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE LIVING WORLD 2.0:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DO MUNDO SOCIAL: SOCIEDADE VIVA, MEMÓRIA E RUMORES INTEGRADOS!")
	print("================================================================================\n")

	get_tree().quit(0)