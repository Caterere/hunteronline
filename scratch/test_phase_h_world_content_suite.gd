extends Node2D

# ============================================================
# HUNTER ONLINE - SUÍTE COMPLETA DE TESTES: FASE H (MUNDO & CONTEÚDO)
# ============================================================

const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")
const RegionDefinitionScript = preload("res://resource/world/RegionDefinition.gd")
const LivingNPCBehaviorScript = preload("res://entities/npc/LivingNPCBehavior.gd")
const BattlePersonalityScript = preload("res://resource/personality/BattlePersonality.gd")
const BossPhaseDataScript = preload("res://resource/status/BossPhaseData.gd")
const MissionGPSIndicatorScript = preload("res://ui/hud/MissionGPSIndicator.gd")

var total_testes: int = 0
var testes_passados: int = 0

func _ready() -> void:
	print("\n============================================================")
	print("🌍 INICIANDO SUÍTE COMPLETA DE TESTES: FASE H (MUNDO & CONTEÚDO)")
	print("============================================================")

	testar_h1_world_foundation_e_transicoes()
	testar_h2_e_h5_ecologia_e_bestiario_canonico()
	testar_h3_hierarquia_e_rotinas_npcs()
	testar_h4_catalogo_quests_padokia()
	testar_h6_e_h7_boss_phases_e_personalidade()
	testar_h8_eventos_dinamicos_mundo()
	testar_h9_segredos_sem_waypoints_gps()
	testar_h10_ciclo_dia_noite_e_clima()
	testar_h12_e_h13_recompensas_e_save_load_schema()

	print("\n============================================================")
	print("📊 RESULTADO FINAL FASE H: %d / %d TESTES PASSADOS" % [testes_passados, total_testes])
	print("============================================================")
	
	get_tree().quit(0 if testes_passados == total_testes else 1)


func assert_true(cond: bool, msg: String) -> void:
	total_testes += 1
	if cond:
		testes_passados += 1
		print("  ✅ [PASS] " + msg)
	else:
		push_error("  ❌ [FAIL] " + msg)
		print("  ❌ [FAIL] " + msg)


func testar_h1_world_foundation_e_transicoes() -> void:
	print("\n[TESTE H1] World Foundation & Conexões Físicas...")
	
	# 1. Alias trocar_cena em SceneTransition
	assert_true(SceneTransition != null, "SceneTransition autoload existe.")
	assert_true(SceneTransition.has_method("mudar_cena"), "SceneTransition possui mudar_cena.")
	assert_true(SceneTransition.has_method("trocar_cena"), "SceneTransition possui alias trocar_cena compatível.")

	# 2. Tipagem em RegionDefinition
	var reg_dict: Dictionary = {
		"id": "vale_padokia",
		"display_name": "Vale de Padokia",
		"quest_ids": [&"quest_1", &"quest_2", "quest_3"]
	}
	var reg_def = RegionDefinitionScript.from_dict(reg_dict)
	assert_true(reg_def != null, "RegionDefinition.from_dict desserializou com sucesso.")
	assert_true(reg_def.quest_ids.size() == 3, "quest_ids possui 3 itens.")
	assert_true(reg_def.quest_ids[0] is String, "quest_ids converteu tipos para String sem erro.")

	# 3. Regiões canônicas registradas no WorldProgressionManager
	assert_true(WorldProgressionManager != null, "WorldProgressionManager autoload ativo.")
	assert_true(WorldProgressionManager.REGIOES.has("vale_padokia"), "Região Vale de Padokia registrada.")
	assert_true(WorldProgressionManager.REGIOES.has("dungeon_ruinas_zaban"), "Região Ruínas de Zaban registrada.")


func testar_h2_e_h5_ecologia_e_bestiario_canonico() -> void:
	print("\n[TESTE H2 & H5] Bestiário Canônico & Famílias de Inimigos...")

	assert_true(DataManager != null, "DataManager central ativo.")
	
	# Família BEAST
	var fera = DataManager.get_enemy(&"fera_floresta")
	assert_true(fera != null, "Fera da Floresta registrada no DataManager.")
	assert_true(fera.role == "bruiser", "Fera da Floresta possui arquétipo bruiser.")
	assert_true(fera.weakness_tags.has("slashing"), "Fera possui fraqueza slashing.")
	assert_true(not fera.drop_table.is_empty(), "Fera possui tabela de drop configurada.")

	var lobo = DataManager.get_enemy(&"lobo_padokia")
	assert_true(lobo != null and lobo.role == "fast", "Lobo das Planícies possui arquétipo fast.")

	var javali = DataManager.get_enemy(&"javali_espinhoso")
	assert_true(javali != null and javali.role == "tank", "Javali Espinhoso possui arquétipo tank.")

	var predador = DataManager.get_enemy(&"predador_miasma")
	assert_true(predador != null and predador.role == "ambusher", "Predador do Miasma possui arquétipo ambusher.")

	# Família ANCIENT CONSTRUCTS
	var sentinela = DataManager.get_enemy(&"sentinela_pedra")
	assert_true(sentinela != null and sentinela.role == "tank", "Sentinela de Pedra possui arquétipo tank.")
	assert_true(sentinela.weakness_tags.has("ko"), "Sentinela de Pedra possui fraqueza a Ko.")

	var guardiao_elite = DataManager.get_enemy(&"guardiao_elite")
	assert_true(guardiao_elite != null and guardiao_elite.is_elite, "Guardião de Elite é marcado como is_elite.")

	# Família HUMANOID & BANDIT
	var ladrao = DataManager.get_enemy(&"ladrao_estrada")
	assert_true(ladrao != null and ladrao.role == "fast", "Ladrão de Estrada possui arquétipo fast.")

	var arqueiro = DataManager.get_enemy(&"arqueiro_renegado")
	assert_true(arqueiro != null and arqueiro.role == "ranged", "Arqueiro Renegado possui arquétipo ranged.")

	var iniciado_nen = DataManager.get_enemy(&"iniciado_nen_sombrio")
	assert_true(iniciado_nen != null and iniciado_nen.role == "nen_user", "Iniciado de Nen possui arquétipo nen_user.")

	# Miniboss & Boss
	var quimera = DataManager.get_enemy(&"lider_matilha_quimera")
	assert_true(quimera != null and quimera.npc_tier == 3, "Líder da Matilha Quimera é Tier 3 Mini-Boss.")

	var boss = DataManager.get_enemy(&"guardiao_ancestral")
	assert_true(boss != null and boss.is_boss and boss.npc_tier == 4, "Guardião Ancestral é Tier 4 Quest Boss.")


func testar_h3_hierarquia_e_rotinas_npcs() -> void:
	print("\n[TESTE H3] Hierarquia de NPCs & Rotinas Vivas...")

	var living = LivingNPCBehaviorScript.new()
	living.npc_nome = "Mestre Wing"
	
	# Verificar enum NPCHierarchy
	assert_true(LivingNPCBehaviorScript.NPCHierarchy.has("COMMON"), "NPCHierarchy possui COMMON.")
	assert_true(LivingNPCBehaviorScript.NPCHierarchy.has("FUNCTIONAL"), "NPCHierarchy possui FUNCTIONAL.")
	assert_true(LivingNPCBehaviorScript.NPCHierarchy.has("RECURRING"), "NPCHierarchy possui RECURRING.")
	assert_true(LivingNPCBehaviorScript.NPCHierarchy.has("IMPORTANT"), "NPCHierarchy possui IMPORTANT.")
	assert_true(LivingNPCBehaviorScript.NPCHierarchy.has("STORY"), "NPCHierarchy possui STORY.")
	assert_true(LivingNPCBehaviorScript.NPCHierarchy.has("BOSS"), "NPCHierarchy possui BOSS.")

	# Mock parent CharacterBody2D para testar _ready do LivingNPCBehavior
	var mock_body = CharacterBody2D.new()
	mock_body.name = "WingBody"
	mock_body.add_child(living)
	add_child(mock_body)

	assert_true(living.hierarchy == LivingNPCBehaviorScript.NPCHierarchy.IMPORTANT, "Mestre Wing auto-resolvido como hierarquia IMPORTANT.")
	assert_true(living.npc_cargo == "Mestre de Nen", "Mestre Wing auto-resolveu cargo canônico.")

	# Diálogo reativo
	var diag = living.obter_dialogo_reativo()
	assert_true(not diag.is_empty(), "LivingNPCBehavior gerou diálogo reativo contextual.")
	mock_body.queue_free()


func testar_h4_catalogo_quests_padokia() -> void:
	print("\n[TESTE H4] Catálogo de Quests de Padokia & Variedade...")

	var quests = PadokiaQuestCatalogScript.obter_todas_quests()
	assert_true(quests.size() == 7, "PadokiaQuestCatalog possui 7 quests no total.")

	var q_princ = PadokiaQuestCatalogScript.obter_quest_principal()
	assert_true(q_princ.objectives.size() == 3, "Quest Principal possui 3 objetivos encadeados.")
	assert_true(q_princ.objectives[0].type == QuestObjective.Type.VISIT, "Objetivo 1 é VISIT (Wing).")
	assert_true(q_princ.objectives[1].enemy_type == &"fera_floresta", "Objetivo 2 caça fera_floresta.")
	assert_true(q_princ.objectives[2].enemy_type == &"guardiao_ancestral", "Objetivo 3 derrota guardiao_ancestral.")

	var q_sec1 = PadokiaQuestCatalogScript.obter_quest_secundaria_1()
	assert_true(q_sec1.turn_in_npc_key == &"vendedor", "Quest secundária 1 entrega no Vendedor.")

	var q_sec2 = PadokiaQuestCatalogScript.obter_quest_secundaria_2()
	assert_true(q_sec2.objectives[0].enemy_type == &"sentinela_pedra", "Quest secundária 2 caça sentinela_pedra.")

	var q_estrada = PadokiaQuestCatalogScript.obter_quest_secundaria_estrada()
	assert_true(q_estrada.objectives[0].enemy_type == &"ladrao_estrada", "Quest da estrada combate ladrao_estrada.")

	var q_ravina = PadokiaQuestCatalogScript.obter_quest_desafio_ravina()
	assert_true(q_ravina.objectives[0].enemy_type == &"predador_miasma", "Quest desafio combate predador_miasma.")

	var q_sec_rocha = PadokiaQuestCatalogScript.obter_quest_secreta()
	assert_true(q_sec_rocha.is_secret, "Quest secreta da rocha possui flag is_secret = true.")
	assert_true(q_sec_rocha.objectives[0].type == QuestObjective.Type.INVESTIGATE, "Quest da rocha é INVESTIGATE.")

	var q_sec_altar = PadokiaQuestCatalogScript.obter_quest_secreta_altar()
	assert_true(q_sec_altar.is_secret, "Quest secreta do altar possui flag is_secret = true.")


func testar_h6_e_h7_boss_phases_e_personalidade() -> void:
	print("\n[TESTE H6 & H7] Fases de Chefe & Personalidades de Combate...")

	var boss = DataManager.get_enemy(&"guardiao_ancestral")
	assert_true(boss.boss_phases.size() >= 2, "Guardião Ancestral possui pelo menos 2 fases configuradas.")
	
	var p2 = boss.boss_phases[0] as BossPhaseData
	assert_true(p2.phase_index == 2, "Fase 2 tem index 2.")
	assert_true(p2.hp_threshold == 0.50, "Fase 2 dispara em 50% HP.")
	assert_true(p2.mechanic == BossPhaseData.MecanicaFase.INVOCAR_MINIONS, "Fase 2 mecânica é INVOCAR_MINIONS.")

	var p3 = boss.boss_phases[1] as BossPhaseData
	assert_true(p3.phase_index == 3, "Fase 3 tem index 3.")
	assert_true(p3.hp_threshold == 0.25, "Fase 3 dispara em 25% HP.")
	assert_true(p3.mechanic == BossPhaseData.MecanicaFase.AOE_BURST, "Fase 3 mecânica é AOE_BURST.")

	assert_true(boss.battle_personality != null, "Guardião Ancestral possui BattlePersonality vinculado.")
	assert_true(not boss.battle_personality.obter_intro().is_empty(), "Boss possui fala de introdução.")
	assert_true(not boss.battle_personality.obter_derrota().is_empty(), "Boss possui fala de derrota.")

	var quimera = DataManager.get_enemy(&"lider_matilha_quimera")
	assert_true(quimera.battle_personality != null, "Líder Quimera possui BattlePersonality bestial.")


func testar_h8_eventos_dinamicos_mundo() -> void:
	print("\n[TESTE H8] World Events & Resolução de Crises...")

	assert_true(WorldEventManager != null, "WorldEventManager ativo.")
	WorldEventManager.iniciar_evento_invasao_feras("vale_padokia")
	assert_true(WorldEventManager.active_world_events.has("evento_invasao_feras_vale_padokia"), "Evento de Invasão de Feras ativado.")

	WorldEventManager.iniciar_evento_mercador_apuros("vale_padokia")
	assert_true(WorldEventManager.active_world_events.has("evento_mercador_apuros_vale_padokia"), "Evento de Mercador em Apuros ativado.")

	# Resolução pelo jogador
	WorldEventManager.resolver_evento_jogador("evento_invasao_feras_vale_padokia", true)
	assert_true(not WorldEventManager.active_world_events.has("evento_invasao_feras_vale_padokia"), "Evento resolvido com sucesso pelo jogador.")


func testar_h9_segredos_sem_waypoints_gps() -> void:
	print("\n[TESTE H9] Segredos sem Waypoints no GPS...")

	var gps = MissionGPSIndicatorScript.new()
	add_child(gps)

	var q_secreta = PadokiaQuestCatalogScript.obter_quest_secreta()
	assert_true(q_secreta.is_secret, "Quest secreta confirmada.")

	# Se a quest ativa for secreta, o GPS desativa waypoints automáticos
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
		QuestSystem.active_quests.append(q_secreta)
		gps._atualizar_alvo_ativo()
		assert_true(gps.target_found == false, "GPS NÃO apontou seta para objetivo de quest secreta (exploração orgânica pura).")

	gps.queue_free()


func testar_h10_ciclo_dia_noite_e_clima() -> void:
	print("\n[TESTE H10] Integração Dia/Noite & Clima...")

	assert_true(TimeManager != null, "TimeManager ativo.")
	TimeManager.set_time(12, 0)
	assert_true(TimeManager.current_phase == TimeManager.TimePhase.DAY, "12:00 é DAY.")
	var cor_dia = TimeManager.get_ambient_light_color()
	assert_true(cor_dia == Color.WHITE, "Luz do dia é branca pura.")

	TimeManager.set_time(22, 0)
	assert_true(TimeManager.current_phase == TimeManager.TimePhase.NIGHT, "22:00 é NIGHT.")
	var cor_noite = TimeManager.get_ambient_light_color()
	assert_true(cor_noite.b > cor_noite.r, "Luz da noite possui tom azulado suave.")

	assert_true(WorldStateManager != null, "WorldStateManager ativo.")
	WorldStateManager.definir_clima(WorldStateManager.Clima.CHUVA)
	assert_true(WorldStateManager.obter_clima_atual() == WorldStateManager.Clima.CHUVA, "Clima alterado para CHUVA.")
	WorldStateManager.definir_clima(WorldStateManager.Clima.LIMPO)


func testar_h12_e_h13_recompensas_e_save_load_schema() -> void:
	print("\n[TESTE H12 & H13] Recompensas, Economia & Persistência Save/Load Schema 2.3...")

	assert_true(SaveManager != null, "SaveManager ativo.")
	assert_true(SaveManager.SAVE_VERSION == "2.3", "SAVE_VERSION atualizada para 2.3.")

	# Salvar no slot temporário de teste 9
	TimeManager.set_time(19, 30)
	WorldStateManager.definir_clima(WorldStateManager.Clima.NEBLINA)
	
	var salvou = SaveManager.salvar_jogo(9)
	assert_true(salvou, "Jogo salvo no Slot 9.")

	# Alterar estado em memória
	TimeManager.set_time(10, 0)
	WorldStateManager.definir_clima(WorldStateManager.Clima.LIMPO)

	# Carregar do slot 9
	var carregou = SaveManager.carregar_jogo(9)
	assert_true(carregou, "Jogo carregado do Slot 9.")

	# Validar restauração de tempo e clima
	assert_true(TimeManager.current_hour == 19 and TimeManager.current_minute == 30, "TimeManager restaurado com sucesso (19:30).")
	assert_true(WorldStateManager.clima_atual == WorldStateManager.Clima.NEBLINA, "WorldStateManager restaurado com sucesso (NEBLINA).")

	# Limpeza
	SaveManager.deletar_save(9)
