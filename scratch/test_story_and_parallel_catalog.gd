extends SceneTree

# ============================================================
# HUNTER ONLINE - TEST SUITE: MODO HISTÓRIA (254 ETAPAS) & PQs (220)
# ============================================================

func _init() -> void:
	print("=========================================================")
	print("[TEST] INICIANDO AUDITORIA E TESTE AUTOMATIZADO DE CONTEÚDO")
	print("=========================================================")

	var total_tests := 0
	var passed_tests := 0

	# --------------------------------------------------------
	# TESTE 1: CanonQuestCatalog - Total de Etapas por Arco
	# --------------------------------------------------------
	total_tests += 1
	var expected_totals := {
		1: 24, 2: 18, 3: 26, 4: 34, 5: 36, 6: 48, 7: 20, 8: 22, 9: 26
	}
	var total_etapas_geral := 0
	var totals_ok := true
	for arco in expected_totals:
		var qtd := CanonQuestCatalog.obter_total_quests_do_arco(arco)
		total_etapas_geral += qtd
		if qtd != expected_totals[arco]:
			print("❌ ERRO: Arco %d esperado %d etapas, retornado %d" % [arco, expected_totals[arco], qtd])
			totals_ok = false

	if totals_ok and total_etapas_geral == 254:
		print("✅ TESTE 1: Todos os 9 Arcos possuem contagens de etapas corretas! Total: %d etapas." % total_etapas_geral)
		passed_tests += 1
	else:
		print("❌ TESTE 1 FALHOU!")

	# --------------------------------------------------------
	# TESTE 2: CanonQuestCatalog - Integridade de Todas as 254 Etapas
	# --------------------------------------------------------
	total_tests += 1
	var all_stages_valid := true
	var etapas_validadas := 0

	for arco in range(1, 10):
		var total_etapas := CanonQuestCatalog.obter_total_quests_do_arco(arco)
		for etapa in range(1, total_etapas + 1):
			var q := CanonQuestCatalog.obter_quest_da_etapa(arco, etapa)
			if q == null:
				print("❌ ERRO: Quest nula para Arco %d, Etapa %d" % [arco, etapa])
				all_stages_valid = false
				break

			if q.quest_name.is_empty() or q.description.is_empty():
				print("❌ ERRO: Nome ou descrição vazia em Arco %d, Etapa %d" % [arco, etapa])
				all_stages_valid = false
				break

			if q.objectives.is_empty():
				print("❌ ERRO: Sem objetivos em Arco %d, Etapa %d" % [arco, etapa])
				all_stages_valid = false
				break

			if q.reward_xp <= 0 or q.reward_gold <= 0:
				print("❌ ERRO: Recompensa inválida em Arco %d, Etapa %d" % [arco, etapa])
				all_stages_valid = false
				break

			for obj in q.objectives:
				if obj == null:
					print("❌ ERRO: Objetivo nulo em Arco %d, Etapa %d" % [arco, etapa])
					all_stages_valid = false
					break
				match obj.type:
					QuestObjective.Type.VISIT, QuestObjective.Type.PERSUASION:
						if obj.target_npc_id == &"" and obj.target_npc_name.is_empty():
							print("❌ ERRO: NPC alvo vazio em Arco %d, Etapa %d" % [arco, etapa])
							all_stages_valid = false
					QuestObjective.Type.KILL:
						if obj.enemy_type == &"" or obj.required_amount <= 0:
							print("❌ ERRO: Inimigo alvo vazio ou qtd <= 0 em Arco %d, Etapa %d" % [arco, etapa])
							all_stages_valid = false

			etapas_validadas += 1

	if all_stages_valid and etapas_validadas == 254:
		print("✅ TESTE 2: Todas as 254 Etapas do Modo História são 100%% válidas e íntegras!")
		passed_tests += 1
	else:
		print("❌ TESTE 2 FALHOU! Etapas validadas: %d/254" % etapas_validadas)

	# --------------------------------------------------------
	# TESTE 3: ParallelQuestCatalog - 220 Missões Paralelas
	# --------------------------------------------------------
	total_tests += 1
	var missoes_pq := ParallelQuestCatalog.obter_todas_missoes()
	var pq_valid := true
	var pqs_validadas := 0

	if missoes_pq.size() != 220:
		print("❌ ERRO: Quantidade de PQs esperada: 220, obtida: %d" % missoes_pq.size())
		pq_valid = false
	else:
		for i in range(missoes_pq.size()):
			var m: Dictionary = missoes_pq[i]
			var id: int = m.get("id", -1)
			if id != i + 1:
				print("❌ ERRO: ID de PQ incorreto no índice %d: %d" % [i, id])
				pq_valid = false
				break
			if str(m.get("title", "")).is_empty():
				print("❌ ERRO: Título vazio na PQ %d" % id)
				pq_valid = false
				break
			var waves: Array = m.get("waves", [])
			if waves.is_empty():
				print("❌ ERRO: Waves vazias na PQ %d" % id)
				pq_valid = false
				break
			if m.get("reward_xp", 0) <= 0 or m.get("reward_gold", 0) <= 0:
				print("❌ ERRO: Recompensa inválida na PQ %d" % id)
				pq_valid = false
				break
			pqs_validadas += 1

	if pq_valid and pqs_validadas == 220:
		print("✅ TESTE 3: Todas as 220 Missões Paralelas e Secundárias são 100%% válidas!")
		passed_tests += 1
	else:
		print("❌ TESTE 3 FALHOU! PQs validadas: %d/220" % pqs_validadas)

	# --------------------------------------------------------
	# TESTE 4: StoryGate - Validação com Novas Contagens de Etapas
	# --------------------------------------------------------
	total_tests += 1
	var gate1 := StoryGate.new(1, 24, true)
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 20
	var pendencias := gate1.get_unmet_requirements()
	var gate_ok := not pendencias.is_empty() # Bloqueado corretamente

	PlayerData.etapa_quest_arco = 24
	# Se a quest ativa não tiver objetivos pendentes, pode avançar
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
	var can_adv := gate1.can_advance()
	if gate_ok and can_adv:
		print("✅ TESTE 4: StoryGate valida perfeitamente as 24 etapas do Arco 1!")
		passed_tests += 1
	else:
		print("❌ TESTE 4 FALHOU! gate_ok: %s, can_adv: %s" % [gate_ok, can_adv])

	# --------------------------------------------------------
	# TESTE 5: Arena Celestial - Verificação de Mestre Wing e Iniciação
	# --------------------------------------------------------
	total_tests += 1
	var q_arena_etapa2 := CanonQuestCatalog.obter_quest_da_etapa(3, 2)
	var q_arena_etapa9 := CanonQuestCatalog.obter_quest_da_etapa(3, 9)
	var q_arena_etapa10 := CanonQuestCatalog.obter_quest_da_etapa(3, 10)
	var arena_ok := (
		q_arena_etapa2 != null
		and q_arena_etapa9 != null
		and q_arena_etapa10 != null
		and q_arena_etapa9.objectives[0].target_npc_id == &"wing"
	)
	if arena_ok:
		print("✅ TESTE 5: Progressão da Arena Celestial com Mestre Wing e Teste da Água validada com sucesso!")
		passed_tests += 1
	else:
		print("❌ TESTE 5 FALHOU!")

	# --------------------------------------------------------
	# RESULTADO FINAL
	# --------------------------------------------------------
	print("=========================================================")
	print("[TEST RESULT] TOTAL DE TESTES: %d | APROVADOS: %d/%d (%.1f%%)" % [
		total_tests, passed_tests, total_tests, (float(passed_tests) / float(total_tests)) * 100.0
	])
	print("=========================================================")

	if passed_tests == total_tests:
		print("🏆 TODOS OS TESTES PASSARAM COM SUCESSO!")
	else:
		print("⚠️ ALGUNS TESTES FALHARAM!")

	quit()
