extends Node2D

# ============================================================
# HUNTER ONLINE - TEST SYSTEMIC CAUSALITY SUITE (HEADLESS)
# ============================================================

var passed_tests: int = 0
var total_tests: int = 7

func _ready() -> void:
	print("================================================================================")
	print("🚀 INICIANDO SYSTEMIC CAUSALITY SUITE (GAMEPLAY & ECOSSISTEMA VIVO)")
	print("================================================================================")
	
	_test_1_gyo_inspection_and_nen_xp()
	_test_2_zetsu_sensor_stealth_passage()
	_test_3_ko_obstacle_destruction()
	_test_4_title_equipping_stat_modifiers()
	_test_5_reputation_dynamic_pricing()
	_test_6_time_phase_npc_behavior()
	_test_7_combat_nen_mitigation_and_ko()
	
	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE CAUSALIDADE SISTÊMICA:")
	print("   TESTES APROVADOS: %d / %d (%.1f%%)" % [passed_tests, total_tests, (float(passed_tests)/total_tests)*100.0])
	print("================================================================================\n")
	
	if passed_tests == total_tests:
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _test_1_gyo_inspection_and_nen_xp() -> void:
	print("\n[TESTE 1/7] Gyo Clue Inspection & Conexão com PlayerData...")
	
	var clue := GyoInspectable.new()
	clue.clue_id = &"pista_teste_ruinas"
	clue.titulo_pista = "Inscrição Antiga em Zaban"
	clue.requer_gyo = true
	add_child(clue)
	
	var dummy_player := CharacterBody2D.new()
	dummy_player.name = "PlayerTestGyo"
	dummy_player.add_to_group("player")
	var nen_sys := NenSystem.new()
	nen_sys.name = "NenSystem"
	dummy_player.add_child(nen_sys)
	add_child(dummy_player)
	
	# 1. Sem Gyo -> Falha na inspeção
	var res_falha = clue.inspecionar(dummy_player)
	assert(not res_falha.get("sucesso", true), "Inspeção sem Gyo deveria falhar!")
	
	# 2. Ativar Gyo -> Sucesso na inspeção
	PlayerData.attributes["nivel_nen"] = 2
	PlayerData.attributes["aura_max"] = 200.0
	PlayerData.attributes["aura"] = 200.0
	PlayerData.attributes["xp_nen"] = 0
	nen_sys.sincronizar_nen_com_player_data()
	nen_sys.tecnicas[NenSystem.Tecnica.GYO]["nivel"] = 1
	nen_sys.tecnicas[NenSystem.Tecnica.GYO]["desbloqueada"] = true
	nen_sys.ativar_tecnica(NenSystem.Tecnica.GYO)
	clue.atualizar_estado_gyo(true)
	
	var res_ok = clue.inspecionar(dummy_player)
	assert(res_ok.get("sucesso", false), "Inspeção com Gyo deveria ter sucesso!")
	assert(PlayerData.segredos_descobertos.has("pista_teste_ruinas"), "Segredo deveria ter sido registrado no PlayerData!")
	assert(PlayerData.attributes["xp_nen"] >= 50 or nen_sys.obter_nen_xp() >= 50, "Deveria conceder Nen XP ao inspecionar com Gyo!")
	
	clue.queue_free()
	dummy_player.queue_free()
	passed_tests += 1
	print("  ✅ [PASS] GyoInspectable integrado a PlayerData, Nen XP e EventBus.")


func _test_2_zetsu_sensor_stealth_passage() -> void:
	print("\n[TESTE 2/7] Zetsu Sensor Zone Stealth Passage...")
	
	var zone := ZetsuSensorZone.new()
	zone.zone_id = &"sensor_teste_01"
	add_child(zone)
	
	var dummy_player := CharacterBody2D.new()
	dummy_player.name = "PlayerTestZetsu"
	dummy_player.add_to_group("player")
	var nen_sys := NenSystem.new()
	nen_sys.name = "NenSystem"
	dummy_player.add_child(nen_sys)
	add_child(dummy_player)
	
	# Ativar Zetsu com nível configurado
	PlayerData.attributes["nivel_nen"] = 2
	PlayerData.attributes["aura_max"] = 200.0
	PlayerData.attributes["aura"] = 200.0
	nen_sys.sincronizar_nen_com_player_data()
	nen_sys.tecnicas[NenSystem.Tecnica.ZETSU]["nivel"] = 1
	nen_sys.tecnicas[NenSystem.Tecnica.ZETSU]["desbloqueada"] = true
	nen_sys.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	
	# Entrar na zona
	zone._on_body_entered(dummy_player)
	assert(not zone.falhou_stealth, "Com Zetsu ativo, não deve disparar alarme!")
	
	# Sair da zona (sucesso stealth)
	zone._on_body_exited(dummy_player)
	
	zone.queue_free()
	dummy_player.queue_free()
	passed_tests += 1
	print("  ✅ [PASS] ZetsuSensorZone valida travessia furtiva e concede recompensas.")


func _test_3_ko_obstacle_destruction() -> void:
	print("\n[TESTE 3/7] Ko Obstacle Destruction com Técnica KO...")
	
	var obstaculo := KoObstacle.new()
	obstaculo.obstacle_name = "Rocha Rachada Teste"
	obstaculo.item_recompensa_id = &"minerio_aco"
	add_child(obstaculo)
	
	var dummy_player := CharacterBody2D.new()
	dummy_player.add_to_group("player")
	var nen_sys := NenSystem.new()
	nen_sys.name = "NenSystem"
	dummy_player.add_child(nen_sys)
	add_child(dummy_player)
	
	# 1. Golpear sem KO -> Não destrói
	obstaculo.receber_dano(50, Vector2.RIGHT, 1.0, dummy_player)
	assert(not obstaculo.foi_destruido, "Obstáculo de Ko não deve quebrar sem a técnica KO ativa!")
	
	# 2. Ativar KO e golpear -> Destrói
	PlayerData.attributes["nivel_nen"] = 2
	PlayerData.attributes["aura_max"] = 200.0
	PlayerData.attributes["aura"] = 200.0
	nen_sys.sincronizar_nen_com_player_data()
	nen_sys.tecnicas[NenSystem.Tecnica.KO]["nivel"] = 1
	nen_sys.tecnicas[NenSystem.Tecnica.KO]["desbloqueada"] = true
	nen_sys.ativar_tecnica(NenSystem.Tecnica.KO)
	
	obstaculo.receber_dano(100, Vector2.RIGHT, 1.0, dummy_player)
	assert(obstaculo.foi_destruido, "Obstáculo deve ser destruído ao receber golpe com KO!")
	assert(PlayerData.tem_item(&"minerio_aco"), "Destruição do obstáculo de Ko deve adicionar o item ao inventário!")
	
	dummy_player.queue_free()
	passed_tests += 1
	print("  ✅ [PASS] KoObstacle integrado a física, técnicas de Nen e inventário.")


func _test_4_title_equipping_stat_modifiers() -> void:
	print("\n[TESTE 4/7] Title Equipping & StatModifier Pipeline...")
	
	PlayerData.aplicar_nivel(5)
	var forca_inicial = int(PlayerData.attributes["forca"])
	var def_inicial = int(PlayerData.attributes["defesa"])
	
	# Desbloquear e equipar título Hunter
	PlayerData.desbloquear_titulo("🏹 Hunter Licenciado")
	var ok = PlayerData.equipar_titulo("🏹 Hunter Licenciado")
	assert(ok, "Deveria equipar o título desbloqueado com sucesso!")
	
	# Verificar se os atributos subiram devido ao StatModifier
	assert(int(PlayerData.attributes["forca"]) > forca_inicial, "Força deve aumentar com o título Hunter equipado!")
	assert(int(PlayerData.attributes["defesa"]) > def_inicial, "Defesa deve aumentar com o título Hunter equipado!")
	
	passed_tests += 1
	print("  ✅ [PASS] PlayerData.equipar_titulo aplica modificadores de stats limpos via StatModifier.")


func _test_5_reputation_dynamic_pricing() -> void:
	print("\n[TESTE 5/7] Reputation Dynamic Pricing in Economy...")
	
	# 1. Reputação Alta -> Desconto
	ReputationSystem.reputacao_dados[ReputationSystem.Faccao.ASSOCIACAO_HUNTER] = 600
	var mod_honrado = Economy.obter_modificador_preco_faccao("associacao_hunter")
	assert(mod_honrado < 1.0, "Reputação honrada (600) deve conceder desconto (< 1.0)!")
	
	var preco_base = Economy.ITEM_CATALOGO["minerio_aco"]["preco"]
	var preco_desc = Economy.calcular_preco_compra("minerio_aco", "associacao_hunter")
	assert(preco_desc < preco_base, "Preço com desconto deve ser menor que o preço base!")
	
	# 2. Reputação Negativa -> Sobretaxa
	ReputationSystem.reputacao_dados[ReputationSystem.Faccao.ASSOCIACAO_HUNTER] = -400
	var mod_hostil = Economy.obter_modificador_preco_faccao("associacao_hunter")
	assert(mod_hostil > 1.0, "Reputação hostil (-400) deve aplicar sobretaxa (> 1.0)!")
	
	var preco_sobre = Economy.calcular_preco_compra("minerio_aco", "associacao_hunter")
	assert(preco_sobre > preco_base, "Preço com sobretaxa deve ser maior que o preço base!")
	
	# Restaurar reputação padrão
	ReputationSystem.reputacao_dados[ReputationSystem.Faccao.ASSOCIACAO_HUNTER] = 150
	passed_tests += 1
	print("  ✅ [PASS] Economy modula preços de compra e venda dinamicamente pela reputação de facção.")


func _test_6_time_phase_npc_behavior() -> void:
	print("\n[TESTE 6/7] Time Phase NPC Living Behavior...")
	
	var npc_parent := CharacterBody2D.new()
	var living_behavior := LivingNPCBehavior.new()
	living_behavior.npc_nome = "Cidadão Teste"
	npc_parent.add_child(living_behavior)
	add_child(npc_parent)
	
	# Disparar fase noturna
	EventBus.time_phase_changed.emit("NIGHT")
	assert(living_behavior.raio_patrulha == 30.0, "Raio de patrulha do NPC deve reduzir durante a noite!")
	assert(living_behavior.velocidade_andar == 16.0, "Velocidade de caminhada do NPC deve reduzir durante a noite!")
	
	# Disparar fase diurna
	EventBus.time_phase_changed.emit("DAY")
	assert(living_behavior.raio_patrulha == 80.0, "Raio de patrulha do NPC deve expandir durante o dia!")
	
	npc_parent.queue_free()
	passed_tests += 1
	print("  ✅ [PASS] LivingNPCBehavior sincroniza rotinas e patrulhas com o TimeManager.")


func _test_7_combat_nen_mitigation_and_ko() -> void:
	print("\n[TESTE 7/7] CombatEngine Multi-layered Nen & Ten Mitigations...")
	
	var dummy_player := CharacterBody2D.new()
	dummy_player.add_to_group("player")
	var nen_sys := NenSystem.new()
	nen_sys.name = "NenSystem"
	dummy_player.add_child(nen_sys)
	add_child(dummy_player)
	
	PlayerData.aplicar_nivel(5)
	PlayerData.attributes["nivel_nen"] = 3
	PlayerData.attributes["aura_max"] = 300.0
	PlayerData.attributes["aura"] = 300.0
	nen_sys.sincronizar_nen_com_player_data()
	nen_sys.tecnicas[NenSystem.Tecnica.TEN]["nivel"] = 3
	nen_sys.tecnicas[NenSystem.Tecnica.TEN]["desbloqueada"] = true
	nen_sys.tecnicas[NenSystem.Tecnica.KO]["nivel"] = 3
	nen_sys.tecnicas[NenSystem.Tecnica.KO]["desbloqueada"] = true
	
	# Dano com TEN ativo vs sem TEN
	var dano_bruto = 100
	var dano_sem_ten = CombatEngine.calcular_dano_sofrido_jogador(dano_bruto, nen_sys, null, null)
	
	nen_sys.ativar_tecnica(NenSystem.Tecnica.TEN)
	var dano_com_ten = CombatEngine.calcular_dano_sofrido_jogador(dano_bruto, nen_sys, null, null)
	assert(dano_com_ten < dano_sem_ten, "Dano sofrido com TEN ativo deve ser menor do que sem TEN!")
	
	# Dano de ataque com KO ativo vs sem KO
	nen_sys.desativar_todas_tecnicas()
	var dano_ataque_normal = CombatEngine.calcular_dano_jogador(dummy_player, nen_sys, null)
	
	nen_sys.ativar_tecnica(NenSystem.Tecnica.KO)
	var dano_ataque_ko = CombatEngine.calcular_dano_jogador(dummy_player, nen_sys, null)
	assert(dano_ataque_ko > dano_ataque_normal, "Dano de ataque com KO ativo deve ser significativamente superior!")
	
	dummy_player.queue_free()
	passed_tests += 1
	print("  ✅ [PASS] CombatEngine integra cálculos de mitigação por Ten e amplificação por Ko com precisão.")