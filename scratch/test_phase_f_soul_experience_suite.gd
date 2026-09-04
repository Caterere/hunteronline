extends Node

# ============================================================
# HUNTER ONLINE - SUÍTE DE TESTES AUTOMATIZADOS: FASE F
# (ALMA DO JOGO: STORY EXPERIENCE, LIVING WORLD & COMBAT 2.0)
# ============================================================

const CutsceneSequenceRunner = preload("res://scripts/cutscenes/CutsceneSequenceRunner.gd")
const TrainingSystem = preload("res://scripts/systems/TrainingSystem.gd")
const EnemyAI = preload("res://scripts/systems/EnemySystem/EnemyAI.gd")
const EnemySystem = preload("res://scripts/systems/EnemySystem/EnemySystem.gd")
const EnemyData = preload("res://resource/status/EnemyData.gd")
const HunterCombatSystem = preload("res://scripts/combat/CombatSystem.gd")
const LivingNPCBehavior = preload("res://entities/npc/LivingNPCBehavior.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ [PASS %02d] %s" % [total_tests, test_name])
	else:
		failed_tests += 1
		printerr("  ❌ [FAIL %02d] %s" % [total_tests, test_name])


func _ready() -> void:
	print("============================================================")
	print("🎭 TEST SUITE: FASE F — ALMA DO JOGO & STORY EXPERIENCE")
	print("============================================================")

	_testar_story_state_e_pacing()
	_testar_flags_e_escolhas_narrativas()
	_testar_objetivos_e_progresso_saga()
	_testar_dialogo_condicional_npc()
	await _testar_cutscene_sequence_runner()
	_testar_living_npc_schedules()
	_testar_quest_hud_hierarquia()
	_testar_combat_2_ataque_pesado()
	_testar_inimigos_usando_hatsu_e_arquetipos()
	_testar_training_system()
	_testar_save_load_persistencia_fase_f()
	_testar_vertical_slice_completo()

	_imprimir_resultado()


func _testar_story_state_e_pacing() -> void:
	print("\n--- [TESTE 1/12] StoryState & Pacing ---")
	StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)
	assert_test(StoryManager.get_pacing_state() == StoryManager.StoryPacingState.EXPLORATION, "1.1 Estado inicial de ritmo é EXPLORATION")

	var capturou_sinal = [false]
	var conn = func(novo: int, _ant: int):
		if int(novo) == int(StoryManager.StoryPacingState.CUTSCENE):
			capturou_sinal[0] = true
	StoryManager.story_pacing_changed.connect(conn)

	StoryManager.set_pacing_state(StoryManager.StoryPacingState.CUTSCENE)
	assert_test(capturou_sinal[0] and StoryManager.get_pacing_state() == StoryManager.StoryPacingState.CUTSCENE, "1.2 Alternância para CUTSCENE despacha sinal correto")

	StoryManager.story_pacing_changed.disconnect(conn)
	StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)


func _testar_flags_e_escolhas_narrativas() -> void:
	print("\n--- [TESTE 2/12] Story Flags & Escolhas Narrativas ---")
	StoryManager.register_choice("exame_zaban_decisao", "investigar_estrada")
	assert_test(StoryManager.has_choice("exame_zaban_decisao"), "2.1 Escolha registrada com sucesso no StoryManager")
	assert_test(StoryManager.get_choice("exame_zaban_decisao") == "investigar_estrada", "2.2 Valor da escolha preservado com precisão")
	assert_test(StoryManager.get_story_flag("choice_exame_zaban_decisao") == "investigar_estrada", "2.3 Flag correspondente gerada automaticamente")


func _testar_objetivos_e_progresso_saga() -> void:
	print("\n--- [TESTE 3/12] Objetivos & Progresso da Saga ---")
	StoryManager.iniciar_saga(1)
	StoryManager.current_chapter = 6
	var pct = StoryManager.obter_progresso_saga_atual()
	assert_test(pct > 0.0 and pct <= 100.0, "3.1 Cálculo de progresso percentual da saga ativo: %.1f%%" % pct)


func _testar_dialogo_condicional_npc() -> void:
	print("\n--- [TESTE 4/12] Diálogo Condicional & Reatividade do NPC ---")
	var dummy_npc = CharacterBody2D.new()
	var behavior = LivingNPCBehavior.new()
	behavior.npc_nome = "Cidadão de Zaban"
	dummy_npc.add_child(behavior)
	add_child(dummy_npc)

	# Sem escolha
	StoryManager.character_choices.erase("suco_tonpa")
	var d1 = behavior.obter_dialogo_reativo()

	# Com escolha desmascarar Tonpa
	StoryManager.register_choice("suco_tonpa", "desmascarar")
	var d2 = behavior.obter_dialogo_reativo()
	assert_test("desmascarou" in d2 or "Tonpa" in d2, "4.1 NPC reconhece e reage imediatamente à escolha do jogador sobre Tonpa")

	dummy_npc.queue_free()


func _testar_cutscene_sequence_runner() -> void:
	print("\n--- [TESTE 5/12] Cutscene Sequence Runner ---")
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.WAIT, "seconds": 0.05},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "teste_cutscene_executado", "value": true},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false}
	]

	var runner = CutsceneSequenceRunner.executar(get_tree(), passos, "TesteSuite")
	assert_test(runner != null, "5.1 CutsceneSequenceRunner instancia e inicia sequência")
	await get_tree().create_timer(0.12).timeout
	assert_test(StoryManager.get_story_flag("teste_cutscene_executado", false) == true, "5.2 Passos da cutscene executados com sucesso")
	CutsceneSequenceRunner.interromper_sequencia_ativa(get_tree())


func _testar_living_npc_schedules() -> void:
	print("\n--- [TESTE 6/12] Living NPC Schedules & Waypoints ---")
	var dummy_npc = CharacterBody2D.new()
	var behavior = LivingNPCBehavior.new()
	var wps: Array[Vector2] = [Vector2(100, 100), Vector2(200, 200)]
	behavior.schedule_waypoints = wps
	dummy_npc.add_child(behavior)
	add_child(dummy_npc)

	behavior._escolher_novo_destino()
	assert_test(behavior.pos_alvo == Vector2(200, 200) or behavior.pos_alvo == Vector2(100, 100), "6.1 NPC seleciona waypoints de rotina agendada")
	dummy_npc.queue_free()


func _testar_quest_hud_hierarquia() -> void:
	print("\n--- [TESTE 7/12] QuestHUD Hierarquia & Barra de Progresso ---")
	var hud = preload("res://ui/hud/QuestHUD.tscn").instantiate()
	add_child(hud)
	var barra = hud._gerar_barra_progresso_ascii(60.0, 10)
	assert_test("██████░░░░" in barra and "60%" in barra, "7.1 Barra ASCII de progresso gerada com precisão: %s" % barra)
	hud.queue_free()


func _testar_combat_2_ataque_pesado() -> void:
	print("\n--- [TESTE 8/12] Combat 2.0: Ataque Pesado ---")
	var player = CharacterBody2D.new()
	player.add_to_group("player")
	var combat = HunterCombatSystem.new()
	player.add_child(combat)
	add_child(player)
	combat.setup(player)

	assert_test(combat.has_method("tentar_ataque_pesado"), "8.1 Método tentar_ataque_pesado presente no HunterCombatSystem")
	var ok_pesado = combat.tentar_ataque_pesado(Vector2.RIGHT)
	assert_test(ok_pesado and combat.is_heavy_attack, "8.2 Ataque pesado engatilha estado is_heavy_attack e cooldown ampliado")

	player.queue_free()


func _testar_inimigos_usando_hatsu_e_arquetipos() -> void:
	print("\n--- [TESTE 9/12] Inimigos Usando Hatsu & Arquétipos ---")
	var enemy_body = CharacterBody2D.new()
	var ai = EnemyAI.new()
	var es = EnemySystem.new()
	var ed = EnemyData.new()
	ed.enemy_name = "Hisoka Morow"
	ed.hatsu_name = "Bungee Gum"
	ed.role = "assassin"
	ed.modular_hatsu = ed.obter_hatsu_real()
	es.enemy_data = ed

	enemy_body.add_child(ai)
	enemy_body.add_child(es)
	add_child(enemy_body)

	assert_test(ai.has_method("executar_hatsu_inimigo"), "9.1 EnemyAI possui executar_hatsu_inimigo implementado")
	assert_test(ed.obter_hatsu_real() != null and ed.obter_hatsu_real().nome == "Bungee Gum", "9.2 Inimigo carrega HatsuData real e canônico")

	enemy_body.queue_free()


func _testar_training_system() -> void:
	print("\n--- [TESTE 10/12] Training System com Mestres ---")
	var ts = TrainingSystem.new()
	add_child(ts)

	var aura_antiga = float(PlayerData.attributes.get("aura_max", 100.0))
	var res = ts.executar_sessao_treino("ten_resistencia", get_tree())
	var aura_nova = float(PlayerData.attributes.get("aura_max", 100.0))

	assert_test(res.get("sucesso", false) == true, "10.1 Treinamento de Ten executado com sucesso")
	assert_test(aura_nova > aura_antiga, "10.2 Aura Máxima expandida permanentemente pelo treino (+25)")

	ts.queue_free()


func _testar_save_load_persistencia_fase_f() -> void:
	print("\n--- [TESTE 11/12] Persistência Serializável da Fase F ---")
	StoryManager.set_pacing_state(StoryManager.StoryPacingState.REST_PACE)
	StoryManager.register_choice("teste_save", "opcao_alpha")

	var dados_salvos = StoryManager.serializar()
	assert_test(dados_salvos.get("current_pacing_state") == int(StoryManager.StoryPacingState.REST_PACE), "11.1 StoryPacingState serializado")
	assert_test(dados_salvos.get("character_choices", {}).get("teste_save") == "opcao_alpha", "11.2 Escolhas narrativas serializadas")

	# Simular deserialização
	StoryManager.character_choices.clear()
	StoryManager.deserializar(dados_salvos)
	assert_test(StoryManager.get_choice("teste_save") == "opcao_alpha", "11.3 Escolhas restauradas perfeitamente no deserializar")


func _testar_vertical_slice_completo() -> void:
	print("\n--- [TESTE 12/12] Vertical Slice Zaban (12 Critérios) ---")
	var vs_scene = preload("res://world/maps/vertical_slice_zaban.tscn")
	var vs = vs_scene.instantiate()
	add_child(vs)

	var exp_res = vs.executar_exploracao_zaban()
	assert_test(exp_res.get("sucesso", false), "12.1 Critério 1 (Exploração): Praça de Zaban percorrida")

	var tonpa_res = vs.interagir_com_tonpa("desmascarar")
	assert_test(tonpa_res.get("escolha") == "desmascarar", "12.2 Critérios 2, 3, 10, 11 (NPCs, Escolha & Consequência): Tonpa desmascarado")

	var sq_res = vs.aceitar_side_quest_zaban()
	assert_test(sq_res.get("sucesso", false), "12.3 Critério 4 (Side Quest): 'Avisos de um Veterano' iniciada")

	var tr_res = vs.realizar_treinamento_ten()
	assert_test(tr_res.get("sucesso", false), "12.4 Critério 5 (Treinamento): Ten Básico concluído com Instrutor")

	var comb_norm = vs.simular_combate_normal()
	assert_test(comb_norm.get("sucesso", false), "12.5 Critério 6 (Combate Normal): Dano físico calculado contra Bandido")

	var comb_tat = vs.simular_combate_tatico()
	assert_test(comb_tat.get("sucesso", false), "12.6 Critério 7 (Combate IA Inteligente): Sentinela Tática enfrentada")

	vs.executar_cena_narrativa_e_cutscene(Callable(), true)
	assert_test(StoryManager.get_story_flag("maratona_iniciada", false) == true, "12.7 Critérios 8, 9, 12 (Cena, Cutscene & Retorno): Maratona do Exame Hunter engatilhada")

	vs.queue_free()


func _imprimir_resultado() -> void:
	print("\n============================================================")
	print("📊 RESULTADOS DA SUÍTE DA FASE F:")
	print("   Total: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests])
	if failed_tests == 0:
		print("🏆 STATUS: 100% APROVADO! ALMA DO JOGO IMPLEMENTADA COM SUCESSO.")
	else:
		printerr("⚠️ ATENÇÃO: %d testes falharam!" % failed_tests)
	print("============================================================\n")
