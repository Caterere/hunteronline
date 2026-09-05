extends Node2D

# ============================================================
# SUÍTE DE TESTES AUTOMATIZADOS: FASE L — LIVE CONTENT & NOVAS SAGAS
# ============================================================
#
# Valida integralmente:
# 1. SagaDefinition & Chapter System (Data-Driven Story)
# 2. Story Gating Evaluator (Requisitos multicritério sem hardcode)
# 3. Branching & Escolhas Narrativas
# 4. NPC Memory System (Gravação episódica persistente)
# 5. NPC Story Arcs (Histórias individuais de NPCs)
# 6. Region Packages & Travel System (Conexão e rotas de mundo)
# 7. Live Events & Conteúdo Temporário (Ciclo de vida e recompensas)
# 8. Boss Pipeline Declarativo (BossDefinition e EnemySystem)
# 9. Coleções & Códex do Caçador (Exploração e 8 categorias)
# 10. Content Validator (Detecção de erros e integridade)
# 11. Save Compatibility & Migração (v2.3 -> v2.4 Schema)
# 12. Test Saga Integration (L37)
# ============================================================

const ChapterDefinitionScript = preload("res://resource/saga/ChapterDefinition.gd")
const SagaDefinitionScript = preload("res://resource/saga/SagaDefinition.gd")
const StoryGatingEvaluatorScript = preload("res://scripts/systems/story/StoryGatingEvaluator.gd")
const NPCStoryArcScript = preload("res://scripts/systems/npc/NPCStoryArc.gd")
const RegionPackageScript = preload("res://resource/region/RegionPackage.gd")
const BossDefinitionScript = preload("res://resource/boss/BossDefinition.gd")
const LiveEventDefinitionScript = preload("res://resource/events/LiveEventDefinition.gd")
const ContentValidatorScript = preload("res://scripts/systems/content/ContentValidator.gd")
const ContentVersionConfigScript = preload("res://scripts/core/ContentVersionConfig.gd")
const TestSagaBuilderScript = preload("res://data/sagas/saga_expedicao_selva/TestSagaBuilder.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0


func _ready() -> void:
	print("\n================================================================")
	print("🌿 SUÍTE DE TESTES: FASE L — LIVE CONTENT & NOVAS SAGAS")
	print("================================================================")

	_test_1_saga_and_chapter_definitions()
	_test_2_story_gating_evaluator()
	_test_3_branching_and_narrative_choices()
	_test_4_npc_memory_system()
	_test_5_npc_story_arcs()
	_test_6_region_packages_and_travel()
	_test_7_live_events_and_temporary_content()
	_test_8_boss_pipeline_and_enemy_system()
	_test_9_hunter_collections_codex()
	_test_10_content_validator()
	_test_11_save_compatibility_and_migration()
	_test_12_test_saga_integration()

	_imprimir_resultado_final()


func assert_test(cond: bool, msg: String) -> void:
	total_tests += 1
	if cond:
		passed_tests += 1
		print("  ✅ [PASS] %s" % msg)
	else:
		failed_tests += 1
		push_error("  ❌ [FAIL] %s" % msg)


# ============================================================
# TESTE 1: SAGA & CHAPTER DEFINITIONS (L1, L2, L3)
# ============================================================
func _test_1_saga_and_chapter_definitions() -> void:
	print("\n--- Teste 1: SagaDefinition & Chapter System (L1, L2, L3) ---")

	var cap = ChapterDefinitionScript.new(1, "O Despertar da Floresta", "Início da jornada na mata.", "quest_etapa_1")
	cap.side_quest_ids = ["side_erva_rara"]
	cap.rewards = {"xp": 1200, "gold": 2500}
	cap.gating_requirements = [{"type": "level", "value": 15}]

	assert_test(cap.chapter_index == 1, "ChapterDefinition inicializa com índice correto")
	assert_test(cap.title == "O Despertar da Floresta", "ChapterDefinition preserva título")
	assert_test(cap.main_quest_id == "quest_etapa_1", "ChapterDefinition preserva main_quest_id")

	var cap_dict = cap.to_dict()
	var cap_restored = ChapterDefinitionScript.from_dict(cap_dict)
	assert_test(cap_restored.title == cap.title, "ChapterDefinition serializa e desserializa perfeitamente")
	assert_test(cap_restored.rewards.get("xp") == 1200, "Recompensas do capítulo preservadas no to_dict/from_dict")

	var saga: Variant = SagaDefinitionScript.new(&"saga_teste_expansao", 11, "Expansão Vale das Sombras", "Arco especial.", Vector2i(30, 80))
	(saga as Variant).add_chapter(cap)
	assert_test((saga as Variant).get_total_chapters() == 1, "SagaDefinition registra capítulos dinamicamente")
	assert_test((saga as Variant).get_chapter(1) != null, "Capítulo 1 recuperado com sucesso")

	if StoryManager != null:
		StoryManager.registrar_saga_definition(saga)
		assert_test(StoryManager.obter_saga_definition(&"saga_teste_expansao") != null, "StoryManager registra SagaDefinition modular")
		assert_test(StoryManager.tem_saga(11) == true, "StoryManager reconhece ordem numérica da nova saga")


# ============================================================
# TESTE 2: STORY GATING EVALUATOR (L4)
# ============================================================
func _test_2_story_gating_evaluator() -> void:
	print("\n--- Teste 2: Story Gating Evaluator (L4) ---")

	PlayerData.attributes["nivel"] = 35
	var cond_lvl = {"type": "level", "value": 30}
	var res_lvl = StoryGatingEvaluatorScript.evaluate_condition(cond_lvl)
	assert_test(res_lvl.get("passed") == true, "Gating de Nível: Nv. 35 atende requisito de Nv. 30")

	var cond_lvl_fail = {"type": "level", "value": 50}
	var res_lvl_fail = StoryGatingEvaluatorScript.evaluate_condition(cond_lvl_fail)
	assert_test(res_lvl_fail.get("passed") == false, "Gating de Nível: Nv. 35 rejeita requisito de Nv. 50")

	PlayerData.quest_states["arco1_etapa1"] = 3
	var cond_q = {"type": "quest_completed", "value": "arco1_etapa1"}
	assert_test(StoryGatingEvaluatorScript.evaluate_condition(cond_q).get("passed") == true, "Gating de Missão: Conclusão reconhecida")

	var cond_q_fail = {"type": "quest_completed", "value": "missao_inexistente"}
	assert_test(StoryGatingEvaluatorScript.evaluate_condition(cond_q_fail).get("passed") == false, "Gating de Missão: Missão incompleta rejeitada")

	var multi_conds = [
		{"type": "level", "value": 25},
		{"type": "quest_completed", "value": "arco1_etapa1"}
	]
	var res_multi = StoryGatingEvaluatorScript.evaluate_all(multi_conds)
	assert_test(res_multi.get("passed") == true, "Gating Multicritério aprovado quando todas as condições são satisfeitas")


# ============================================================
# TESTE 3: BRANCHING & ESCOLHAS NARRATIVAS (L5)
# ============================================================
func _test_3_branching_and_narrative_choices() -> void:
	print("\n--- Teste 3: Branching & Escolhas Narrativas (L5) ---")

	if StoryManager != null:
		StoryManager.register_choice("dilema_selva", "poupar_lobo")
		assert_test(StoryManager.has_choice("dilema_selva") == true, "Escolha narrativa registrada no StoryManager")
		assert_test(StoryManager.get_choice("dilema_selva") == "poupar_lobo", "Opção de escolha recuperada corretamente")

		var cond_choice = {"type": "choice", "choice_id": "dilema_selva", "value": "poupar_lobo"}
		assert_test(StoryGatingEvaluatorScript.evaluate_condition(cond_choice).get("passed") == true, "StoryGating reconhece escolha 'poupar_lobo'")

		var cond_choice_alt = {"type": "choice", "choice_id": "dilema_selva", "value": "eliminar_lobo"}
		assert_test(StoryGatingEvaluatorScript.evaluate_condition(cond_choice_alt).get("passed") == false, "StoryGating bloqueia rota alternativa não escolhida")


# ============================================================
# TESTE 4: NPC MEMORY SYSTEM (L6)
# ============================================================
func _test_4_npc_memory_system() -> void:
	print("\n--- Teste 4: NPC Memory System (L6) ---")

	var mem_sys = get_node_or_null("/root/NPCMemorySystem")
	assert_test(mem_sys != null, "NPCMemorySystem autoload ativo no motor")

	if mem_sys != null:
		mem_sys.clear_npc_memories("kane")
		assert_test(mem_sys.has_memory("kane", "ajudou_com_remedios") == false, "Memória inicial limpa")

		mem_sys.record_event("kane", "ajudou_com_remedios", {"local": "posto_avancado"})
		assert_test(mem_sys.has_memory("kane", "ajudou_com_remedios") == true, "Memória 'ajudou_com_remedios' gravada com sucesso")
		assert_test(mem_sys.get_memory_count("kane", "ajudou_com_remedios") == 1, "Contagem de memórias igual a 1")

		mem_sys.record_event("kane", "ajudou_com_remedios")
		assert_test(mem_sys.get_memory_count("kane", "ajudou_com_remedios") == 2, "Contagem incremental de repetição de evento mantida")

		var saved_mem = mem_sys.serializar()
		assert_test(saved_mem.has("memories"), "Serialização de memórias contém dicionário principal")

		mem_sys.clear_npc_memories("kane")
		assert_test(mem_sys.has_memory("kane", "ajudou_com_remedios") == false, "Memória limpa temporariamente")

		mem_sys.deserializar(saved_mem)
		assert_test(mem_sys.has_memory("kane", "ajudou_com_remedios") == true, "Memórias restauradas fielmente após deserializar()")


# ============================================================
# TESTE 5: NPC STORY ARCS (L7)
# ============================================================
func _test_5_npc_story_arcs() -> void:
	print("\n--- Teste 5: NPC Story Arcs (L7) ---")

	var arc: Variant = NPCStoryArcScript.new(&"arco_kane_redencao", "kane", "O Passado Sombrio de Kane", "Kane busca redenção.")
	arc.stages = [
		{
			"stage": 1,
			"title": "Primeiro Contato",
			"required_memory": "ajudou_com_remedios"
		},
		{
			"stage": 2,
			"title": "O Duelo Secreto",
			"required_memory": "venceu_duelo"
		}
	]

	var mem_sys = get_node_or_null("/root/NPCMemorySystem")
	assert_test(arc.current_stage == 1, "Arco de NPC inicia no estágio 1")
	assert_test(arc.call("can_advance_stage", mem_sys) == true, "Pode avançar estágio 1 pois memória 'ajudou_com_remedios' existe")

	arc.call("advance_stage")
	assert_test(arc.current_stage == 2, "Arco de NPC avançou para estágio 2")
	assert_test(arc.call("can_advance_stage", mem_sys) == false, "Bloqueado avanço do estágio 2 pois 'venceu_duelo' ainda não ocorreu")

	if mem_sys != null:
		mem_sys.record_event("kane", "venceu_duelo")
	assert_test(arc.call("can_advance_stage", mem_sys) == true, "Desbloqueado avanço após registrar memória 'venceu_duelo'")

	arc.call("advance_stage")
	assert_test(arc.is_completed == true, "Arco de NPC marcado como concluído com sucesso")


# ============================================================
# TESTE 6: REGION PACKAGES & TRAVEL (L8, L9, L10, L11)
# ============================================================
func _test_6_region_packages_and_travel() -> void:
	print("\n--- Teste 6: Region Packages & Travel System (L8, L9, L10, L11) ---")

	var pkg = TestSagaBuilderScript.build_test_region()
	assert_test(pkg.region_id == &"selva_misteriosa", "RegionPackage possui ID correto")
	assert_test(pkg.danger_level == RegionPackageScript.DangerLevel.MEDIUM, "DangerLevel configurado como MEDIUM")
	assert_test(pkg.points_of_interest.size() == 3, "Pontos de interesse catalogados (3 POIs)")
	assert_test(pkg.secrets.size() == 1, "Segredo desvelado sem GPS catalogado")

	var travel_sys = get_node_or_null("/root/TravelSystem")
	assert_test(travel_sys != null, "TravelSystem autoload ativo no motor")

	if travel_sys != null:
		travel_sys.register_region_package(pkg)
		assert_test(travel_sys.get_region_package(&"selva_misteriosa") != null, "Pacote de região recuperado pelo TravelSystem")

		var routes = travel_sys.get_available_routes_from(&"selva_misteriosa")
		assert_test(routes.size() >= 1, "Rotas de viagem encontradas a partir da selva")


# ============================================================
# TESTE 7: LIVE EVENTS & TEMPORARY CONTENT (L12, L13, L15)
# ============================================================
func _test_7_live_events_and_temporary_content() -> void:
	print("\n--- Teste 7: Live Events & Conteúdo Temporário (L12, L13, L15) ---")

	var ev_def = TestSagaBuilderScript.build_test_live_event()
	var live_mgr = get_node_or_null("/root/LiveEventManager")
	assert_test(live_mgr != null, "LiveEventManager autoload ativo no motor")

	if live_mgr != null:
		var started = live_mgr.start_live_event(ev_def)
		assert_test(started == true, "LiveEvent iniciado com sucesso no LiveEventManager")
		assert_test(live_mgr.is_event_active(&"migracao_predadores_selva") == true, "Evento reconhecido como ativo")

		# Avançar hora para simular passagem de tempo
		live_mgr._on_time_hour_ticked(10, 0)
		var active_evs = live_mgr.get_active_events_in_region(&"selva_misteriosa")
		assert_test(active_evs.size() >= 1, "Evento recuperado para a região alvo")
		assert_test(float(active_evs[0].get("remaining_hours")) == 3.0, "Tempo restante do evento decrementou de 4h para 3h")

		# Concluir evento
		var comp_res = live_mgr.complete_live_event(&"migracao_predadores_selva", "player")
		assert_test(comp_res.get("success") == true, "Evento concluído com premiação individual")
		assert_test(live_mgr.is_event_active(&"migracao_predadores_selva") == false, "Evento removido da lista de ativos após conclusão")


# ============================================================
# TESTE 8: BOSS PIPELINE & ENEMY SYSTEM (L17, L18)
# ============================================================
func _test_8_boss_pipeline_and_enemy_system() -> void:
	print("\n--- Teste 8: Boss Pipeline Declarativo (L17, L18) ---")

	var boss_def = TestSagaBuilderScript.build_test_boss()
	assert_test(boss_def.boss_id == &"gorila_rei_nen", "BossDefinition possui ID correto")
	assert_test(boss_def.phases.size() == 2, "BossDefinition possui 2 fases configuradas")
	assert_test(boss_def.loot_table.size() == 2, "Tabela de loot do chefe possui 2 drops")

	var dummy_enemy := CharacterBody2D.new()
	var es := EnemySystem.new()
	dummy_enemy.add_child(es)
	add_child(dummy_enemy)

	es.setup_from_boss_definition(boss_def)
	assert_test(es.is_boss == true, "EnemySystem reconhece status de chefe")
	assert_test(es.enemy_name == "Gorila Rei de Nen", "Nome do chefe aplicado com sucesso")
	assert_test(es.max_health >= 25000, "HP máximo de chefe aplicado (>= 25.000)")
	assert_test(es.defense >= 175, "Defesa de chefe aplicada (>= 175)")

	dummy_enemy.queue_free()


# ============================================================
# TESTE 9: HUNTER COLLECTIONS CÓDEX (L21)
# ============================================================
func _test_9_hunter_collections_codex() -> void:
	print("\n--- Teste 9: Coleções & Códex do Caçador (L21) ---")

	var col_mgr = get_node_or_null("/root/CollectionManager")
	assert_test(col_mgr != null, "CollectionManager autoload ativo no motor")

	if col_mgr != null:
		var disc_h = col_mgr.register_discovery("hatsu", "impacto_selvagem")
		assert_test(disc_h == true, "Descoberta de Hatsu registrada no Códex")
		assert_test(col_mgr.has_discovered("hatsu", "impacto_selvagem") == true, "Hatsu consultado como descoberto")

		var disc_dup = col_mgr.register_discovery("hatsu", "impacto_selvagem")
		assert_test(disc_dup == false, "Descoberta duplicada ignorada com sucesso")

		col_mgr.register_discovery("regions", "selva_misteriosa")
		col_mgr.register_discovery("secrets", "bau_secreto_pedra_lua")
		assert_test(col_mgr.get_category_count("secrets") >= 1, "Categoria secrets possui descobertas registradas")
		assert_test(col_mgr.get_total_discoveries() >= 3, "Total global de descobertas incrementado")


# ============================================================
# TESTE 10: CONTENT VALIDATOR (L24)
# ============================================================
func _test_10_content_validator() -> void:
	print("\n--- Teste 10: Content Validator (L24) ---")

	var valid_saga = TestSagaBuilderScript.build_test_saga()
	var val_res = ContentValidatorScript.validate_saga(valid_saga)
	assert_test(val_res.get("valid") == true, "Saga de Teste passa 100% na validação de conteúdo")
	assert_test((val_res.get("errors") as Array).is_empty(), "Zero erros impeditivos na saga de teste")

	# Testar detecção de erro com saga propositalmente inválida
	var invalid_saga = SagaDefinitionScript.new(&"", 0, "", "")
	var inv_res = ContentValidatorScript.validate_saga(invalid_saga)
	assert_test(inv_res.get("valid") == false, "Validador rejeita saga com ID vazio")
	assert_test((inv_res.get("errors") as Array).size() >= 1, "Erros impeditivos reportados pelo validador")

	var boss_val = ContentValidatorScript.validate_boss(TestSagaBuilderScript.build_test_boss())
	assert_test(boss_val.get("valid") == true, "BossDefinition passa na validação de integridade")


# ============================================================
# TESTE 11: SAVE COMPATIBILITY & MIGRATION (L25, L26, L38)
# ============================================================
func _test_11_save_compatibility_and_migration() -> void:
	print("\n--- Teste 11: Compatibilidade de Saves & Migração v2.3 -> v2.4 (L25, L26, L38) ---")

	var ver_info = ContentVersionConfigScript.get_version_info()
	assert_test(ver_info.get("save_version") == "2.4", "Versão canônica de save atualizada para 2.4")
	assert_test(ver_info.get("content_version") == "1.2.0", "Versão canônica de conteúdo definida como 1.2.0")

	# Simular Save Legado v2.3
	var legacy_save: Dictionary = {
		"version": "2.3",
		"nome_personagem": "Gon Freecss",
		"attributes": {"nivel": 45, "vida": 3500},
		"gold": 50000,
		"story_data": {"current_saga": 3, "current_chapter": 8}
	}

	var migrated = ContentVersionConfigScript.migrate_save_data(legacy_save)
	assert_test(migrated.get("version") == "2.4", "Save migrado automaticamente para a versão 2.4")
	assert_test(migrated.has("collections"), "Migração injetou estrutura 'collections'")
	assert_test(migrated.has("npc_memories"), "Migração injetou estrutura 'npc_memories'")
	assert_test(migrated.has("live_events"), "Migração injetou estrutura 'live_events'")
	assert_test(migrated.has("unlocked_routes"), "Migração injetou estrutura 'unlocked_routes'")
	assert_test(migrated["attributes"]["nivel"] == 45, "Nível e atributos do personagem intactos após migração")
	assert_test(migrated["gold"] == 50000, "Ouro do jogador preservado integralmente")


# ============================================================
# TESTE 12: TEST SAGA INTEGRATION (L37)
# ============================================================
func _test_12_test_saga_integration() -> void:
	print("\n--- Teste 12: Integração Completa da Saga de Teste (L37) ---")

	var saga = TestSagaBuilderScript.build_test_saga()
	assert_test(saga.saga_id == &"expedicao_selva", "Saga Teste identificada como 'expedicao_selva'")
	assert_test(saga.chapters.size() == 3, "Saga possui 3 capítulos principais")

	if StoryManager != null:
		StoryManager.registrar_saga_definition(saga)
		var check_cap1 = StoryManager.avaliar_gating_capitulo(&"expedicao_selva", 1)
		assert_test(check_cap1.get("passed") == true, "Capítulo 1 desbloqueado (Nv 35 >= 20)")

	var reg = TestSagaBuilderScript.build_test_region()
	assert_test(reg.scene_path.begins_with("res://world/maps/"), "Região aponta para cena legítima de mapa")

	var hatsu = TestSagaBuilderScript.build_test_hatsu()
	assert_test(hatsu.hatsu_id == "impacto_selvagem", "Hatsu declarativo da saga montado com sucesso")
	assert_test(hatsu.poder_base == 280.0, "Dano base do Hatsu configurado corretamente")


func _imprimir_resultado_final() -> void:
	print("\n================================================================")
	print("📊 RESULTADOS FINAIS DA FASE L:")
	print("  TOTAL: %d | APROVADOS: %d | FALHAS: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 TODOS OS TESTES DA FASE L PASSARAM COM SUCESSO!")
	else:
		push_error("⚠️ ALGUNS TESTES DA FASE L FALHARAM!")

	# Encerrar imediatamente o processo headless
	get_tree().quit(0 if failed_tests == 0 else 1)
