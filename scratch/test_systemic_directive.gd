extends Node2D

const GyoInspectable = preload("res://entities/components/GyoInspectable.gd")

var total_testes: int = 0
var testes_passaram: int = 0
var testes_falharam: int = 0

func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: DIRETRIZ SISTEMICA (NEN, INIMIGOS, MISSOES, POWER SCALE)")
	print("============================================================")

	_executar_todos_testes()

	print("============================================================")
	print("RESULTADO FINAL: %d/%d TESTES PASSARAM (%d FALHAS)" % [testes_passaram, total_testes, testes_falharam])
	print("============================================================")

	if testes_falharam == 0:
		print("🎉 TODOS OS SISTEMAS DA NOVA DIRETRIZ FORAM VALIDADOS COM SUCESSO!")
	else:
		push_error("❌ ALGUNS TESTES FALHARAM!")

	get_tree().quit(0 if testes_falharam == 0 else 1)


func assert_true(condicao: bool, mensagem: String) -> void:
	total_testes += 1
	if condicao:
		testes_passaram += 1
		print("  ✅ [PASSOU] ", mensagem)
	else:
		testes_falharam += 1
		print("  ❌ [FALHOU] ", mensagem)


func _executar_todos_testes() -> void:
	_testar_pilar_1_nen_e_gyo()
	_testar_pilar_2_inimigos_postura_e_stagger()
	_testar_pilar_2_inimigos_reacao_zetsu()
	_testar_pilar_3_missoes_regra_3_solucoes()
	_testar_pilar_3_npc_dialogos_contextuais()
	_testar_pilar_4_powerscale_e_balanceamento()


func _testar_pilar_1_nen_e_gyo() -> void:
	print("\n--- [PILAR 1: NEN E GYO INVESTIGATIVO] ---")

	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 5
	PlayerData.attributes["aura"] = 250.0
	PlayerData.attributes["aura_max"] = 250.0

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)

	var nen_sys: NenSystem = player_scn.get_node_or_null("NenSystem") as NenSystem
	assert_true(nen_sys != null, "Player possui componente NenSystem")

	var pista = GyoInspectable.new()
	pista.clue_id = &"pista_caverna"
	pista.titulo_pista = "Vestígio de Transmutação"
	pista.descricao_pista = "Aura elétrica residual deixada no chão."
	pista.requer_gyo = true
	add_child(pista)

	var res_sem_gyo = pista.inspecionar(player_scn)
	assert_true(res_sem_gyo.get("sucesso", false) == false, "Pista exige Gyo e recusa inspeção sem a técnica ativa")

	var gyo_ativou = nen_sys.ativar_tecnica(NenSystem.Tecnica.GYO)
	assert_true(gyo_ativou, "Gyo foi ativado com sucesso")
	assert_true(nen_sys.esta_em_gyo(), "Helper esta_em_gyo() retorna true")
	assert_true(pista.gyo_ativo_no_jogador == true, "GyoInspectable foi atualizado reativamente via grupo gyo_inspectable")

	var res_com_gyo = pista.inspecionar(player_scn)
	assert_true(res_com_gyo.get("sucesso", false) == true, "Inspeção com Gyo é bem sucedida e decifra a pista")

	nen_sys.desativar_tecnica(NenSystem.Tecnica.GYO)
	assert_true(not nen_sys.esta_em_gyo(), "Gyo foi desativado e estado sincronizado")

	pista.queue_free()
	player_scn.queue_free()


func _testar_pilar_2_inimigos_postura_e_stagger() -> void:
	print("\n--- [PILAR 2: INIMIGOS - POSTURA E STAGGER] ---")

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn").instantiate()
	add_child(enemy_scn)

	var enemy_sys: EnemySystem = enemy_scn.get_node_or_null("EnemySystem") as EnemySystem
	var enemy_ai: EnemyAI = enemy_scn.get_node_or_null("EnemyAI") as EnemyAI

	assert_true(enemy_sys != null, "Cena de Inimigo possui EnemySystem")
	assert_true(enemy_ai != null, "Cena de Inimigo possui EnemyAI")

	enemy_sys.health = 500
	enemy_sys.max_health = 500

	assert_true(enemy_sys.postura == 100.0, "Postura inicial do inimigo é 100")
	assert_true(enemy_sys.em_stagger == false, "Inimigo não inicia em Stagger")

	enemy_sys.take_damage(60)
	assert_true(enemy_sys.postura < 100.0, "Dano reduziu a postura do inimigo")

	enemy_sys.is_invulnerable = false
	enemy_sys.take_damage(60)
	assert_true(enemy_sys.em_stagger == true, "Inimigo entrou em estado de STAGGER ao zerar a postura")

	enemy_ai._update_state()
	assert_true(enemy_ai.current_state == EnemyAI.State.STAGGER, "EnemyAI transicionou para State.STAGGER")

	var dados_gyo = enemy_sys.obter_dados_inspecao_gyo()
	assert_true(dados_gyo.has("categoria_nen"), "EnemySystem expõe categoria_nen para Gyo")
	assert_true(dados_gyo.has("fraqueza"), "EnemySystem expõe fraqueza detectável para Gyo")
	assert_true(dados_gyo.get("em_stagger", false) == true, "Inspeção de Gyo reporta vulnerabilidade de Stagger")

	enemy_scn.queue_free()


func _testar_pilar_2_inimigos_reacao_zetsu() -> void:
	print("\n--- [PILAR 2: INIMIGOS - REAÇÃO A ZETSU E REN] ---")

	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 5
	PlayerData.attributes["aura"] = 250.0
	PlayerData.attributes["aura_max"] = 250.0

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	player_scn.global_position = Vector2(100, 0)

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn").instantiate()
	add_child(enemy_scn)
	enemy_scn.global_position = Vector2(0, 0)

	var nen_sys: NenSystem = player_scn.get_node_or_null("NenSystem") as NenSystem
	var enemy_ai: EnemyAI = enemy_scn.get_node_or_null("EnemyAI") as EnemyAI

	enemy_ai.player = player_scn
	enemy_ai._update_state()
	assert_true(enemy_ai.current_state == EnemyAI.State.CHASE, "Inimigo detecta jogador normalmente a 100px (State.CHASE)")

	var zetsu_ok = nen_sys.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	assert_true(zetsu_ok, "Jogador ativou ZETSU com sucesso")
	assert_true(nen_sys.esta_em_zetsu(), "Helper esta_em_zetsu() confirma estado")

	enemy_ai._update_state()
	assert_true(enemy_ai.current_state != EnemyAI.State.CHASE, "Inimigo perde o alvo quando jogador entra em ZETSU fora do contato direto")

	nen_sys.desativar_tecnica(NenSystem.Tecnica.ZETSU)
	player_scn.queue_free()
	enemy_scn.queue_free()


func _testar_pilar_3_missoes_regra_3_solucoes() -> void:
	print("\n--- [PILAR 3: MISSÕES - REGRA DAS 3 SOLUÇÕES] ---")

	var quest := Quest.new()
	quest.quest_name = "Infiltração na Fortaleza"
	quest.completion = Quest.Completion.ANY
	quest.auto_complete = true

	var obj_kill := QuestObjective.new()
	obj_kill.type = QuestObjective.Type.KILL
	obj_kill.enemy_type = &"guarda"
	obj_kill.required_amount = 5

	var obj_stealth := QuestObjective.new()
	obj_stealth.type = QuestObjective.Type.STEALTH_PASS
	obj_stealth.target_zone_id = &"duto_ventilacao"
	obj_stealth.required_amount = 1

	var obj_gyo := QuestObjective.new()
	obj_gyo.type = QuestObjective.Type.INVESTIGATE
	obj_gyo.target_clue_id = &"chave_secreta_paredao"
	obj_gyo.required_amount = 1

	quest.objectives = [obj_kill, obj_stealth, obj_gyo]

	QuestSystem.start_quest(quest)
	assert_true(PlayerData.is_quest_active(quest), "Quest com 3 abordagens foi iniciada")

	QuestSystem.register_investigation(&"chave_secreta_paredao")

	assert_true(PlayerData.is_quest_completed(quest), "Quest foi concluída com sucesso apenas pela rota de investigação (Regra das 3 Soluções)")


func _testar_pilar_3_npc_dialogos_contextuais() -> void:
	print("\n--- [PILAR 3: NPCS E DIÁLOGOS CONTEXTUAIS] ---")

	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 5
	PlayerData.attributes["aura"] = 250.0
	PlayerData.attributes["aura_max"] = 250.0

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	var nen_sys: NenSystem = player_scn.get_node_or_null("NenSystem") as NenSystem

	var npc := NPC.new()
	npc.npc_name = "Wing"
	npc.fala_padrao = "Continue treinando seus fundamentos de Nen."
	add_child(npc)

	# 1. Fala Normal
	PlayerData.attributes["vida"] = 100
	PlayerData.attributes["vida_max"] = 100
	var fala_normal = npc.obter_fala_contextual(player_scn)
	assert_true(fala_normal == npc.fala_padrao, "NPC entrega fala padrão quando jogador está em estado normal")

	# 2. Reação a Ferimento Grave (HP < 30%)
	PlayerData.attributes["vida"] = 20
	var fala_ferido = npc.obter_fala_contextual(player_scn)
	assert_true("ferido" in fala_ferido.to_lower() or "sangrando" in fala_ferido.to_lower(), "NPC reage contextualmente quando o jogador está gravemente ferido")

	# 3. Reação a Ren
	PlayerData.attributes["vida"] = 100
	var ren_ok = nen_sys.ativar_tecnica(NenSystem.Tecnica.REN)
	assert_true(ren_ok, "Ren ativado com sucesso para teste de diálogo")
	var fala_ren = npc.obter_fala_contextual(player_scn)
	assert_true("pressão" in fala_ren.to_lower() or "aura" in fala_ren.to_lower(), "NPC reconhece e comenta sobre a pressão de Ren ativa no jogador")
	nen_sys.desativar_tecnica(NenSystem.Tecnica.REN)

	# 4. Reação a Zetsu
	var zetsu_ok = nen_sys.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	assert_true(zetsu_ok, "Zetsu ativado com sucesso para teste de diálogo")
	var fala_zetsu = npc.obter_fala_contextual(player_scn)
	assert_true("sombra" in fala_zetsu.to_lower() or "zetsu" in fala_zetsu.to_lower(), "NPC reconhece aproximação furtiva em Zetsu")
	nen_sys.desativar_tecnica(NenSystem.Tecnica.ZETSU)

	player_scn.queue_free()
	npc.queue_free()


func _testar_pilar_4_powerscale_e_balanceamento() -> void:
	print("\n--- [PILAR 4: POWER SCALE & BALANCEAMENTO DE NÚMEROS] ---")

	# 1. Tiers por Nível
	assert_true(PowerScale.obter_tier_por_nivel(5) == PowerScale.Tier.HUMANO, "Nível 5 mapeado para Tier.HUMANO")
	assert_true(PowerScale.obter_tier_por_nivel(50) == PowerScale.Tier.USUARIO_NEN, "Nível 50 mapeado para Tier.USUARIO_NEN")
	assert_true(PowerScale.obter_tier_por_nivel(99) == PowerScale.Tier.ENDGAME, "Nível 99 mapeado para Tier.ENDGAME")

	# 2. Curva de Defesa Adaptativa (K_tier)
	var fat_def_inicio = PowerScale.calcular_fator_defensivo(5.0, PowerScale.Tier.HUMANO)
	assert_true(is_equal_approx(fat_def_inicio, 0.50), "Defesa 5 no Tier 0 (K=5) resulta em 50% de redução")

	var fat_def_endgame = PowerScale.calcular_fator_defensivo(1500000.0, PowerScale.Tier.ENDGAME)
	assert_true(is_equal_approx(fat_def_endgame, 0.50), "Defesa 1.5M no Tier 6 (K=1.5M) resulta em 50% de redução sem quebrar fórmulas")

	# 3. Escalonamento Dinâmico de Hatsu
	var dano_hatsu_inicio = PowerScale.calcular_dano_hatsu(10.0, 100.0, 1.4, 0.4, 0.6)
	assert_true(dano_hatsu_inicio > 0.0, "Dano de Hatsu inicial calculado dinamicamente: %.1f" % dano_hatsu_inicio)

	var dano_hatsu_endgame = PowerScale.calcular_dano_hatsu(2500000.0, 500000000.0, 1.4, 0.4, 0.6)
	assert_true(dano_hatsu_endgame > 100000000.0, "Dano de Hatsu endgame atinge escala colossal de dezenas de milhões: %.1f" % dano_hatsu_endgame)

	# 4. Cálculo de TTK
	var hp_inimigo_10s = PowerScale.calcular_hp_por_ttk(PowerScale.Tier.USUARIO_NEN, 10.0)
	assert_true(hp_inimigo_10s == 35000, "HP para TTK de 10s no Tier 3 calculado exatamente como 35.000 HP")

	# 5. Formatação de Números
	assert_true(PowerScale.formatar_numero(50000000.0) == "50.0M", "Formatação de 50.000.000 exibe '50.0M'")
	assert_true(PowerScale.formatar_numero(500.0) == "500", "Formatação de 500 exibe '500'")
	assert_true(PowerScale.formatar_numero_completo(1839427) == "1.839.427", "Formatação completa exibe '1.839.427' com pontos")
