class_name QuestManager
extends Node


var active_quests: Array[Quest] = []


# =========================================================
# INICIAR QUEST
# =========================================================

func start_quest(quest: Quest) -> bool:

	if quest == null:
		return false

	if active_quests.has(quest):
		return true

	if PlayerData.is_quest_completed(quest):
		return false

	if not quest.prerequisites_met(PlayerData):
		print("PrÃ©-requisitos nÃ£o cumpridos.")
		return false

	if not PlayerData.is_quest_active(quest):
		if not PlayerData.start_quest(quest):
			return false

	if not active_quests.has(quest):
		active_quests.append(quest)

	print("Quest aceita e conectada: ", quest.quest_name)

	return true


func garantir_quest_do_arco(arco: int) -> Quest:
	# Se jÃ¡ tem quest ativa na lista, retornar
	if not active_quests.is_empty() and active_quests[0] != null:
		return active_quests[0]

	var etapa: int = PlayerData.etapa_quest_arco if PlayerData != null else 1
	var nova_quest := CanonQuestCatalog.obter_quest_da_etapa(arco, etapa)
	if nova_quest == null:
		nova_quest = CanonQuestCatalog.obter_ou_criar_quest_arco(arco)

	if nova_quest != null:
		start_quest(nova_quest)
		return nova_quest
	return null


# =========================================================
# VISITAR NPC
# =========================================================

func register_npc_visit(npc_id: StringName) -> void:
	var id_str := String(npc_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		for i in range(quest.objectives.size()):
			var objective: QuestObjective = quest.objectives[i]

			if objective.type != QuestObjective.Type.VISIT:
				continue

			var target_str := String(objective.target_npc_id).to_lower()
			var target_name_str := objective.target_npc_name.to_lower()

			var corresponde: bool = (
				target_str == id_str
				or target_str in id_str
				or id_str in target_str
				or target_name_str in id_str
				or id_str in target_name_str
			)

			if not corresponde:
				continue

			var progress := PlayerData.get_quest_objective_progress(quest, i)
			if progress >= objective.required_amount:
				continue

			progress += 1
			PlayerData.set_quest_objective_progress(quest, i, progress)

			print(
				"Quest: ",
				quest.quest_name,
				" | ",
				objective.describe(),
				" ",
				progress,
				"/",
				objective.required_amount
			)

			_notificar_progresso_hud(objective, progress, quest)
			_check_completion(quest)


# =========================================================
# DERROTAR INIMIGO
# =========================================================

func register_enemy_kill(enemy_id: StringName) -> void:
	var id_str := String(enemy_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		for i in range(quest.objectives.size()):
			var objective: QuestObjective = quest.objectives[i]

			if objective.type != QuestObjective.Type.KILL:
				continue

			var enemy_target := String(objective.enemy_type).to_lower()
			var corresponde: bool = false
			if enemy_target.is_empty() or enemy_target == "any" or enemy_target == "all":
				corresponde = true
			elif enemy_target == id_str or enemy_target in id_str or id_str in enemy_target:
				corresponde = true
			else:
				var keywords = enemy_target.split("_")
				for kw in keywords:
					if kw.length() >= 4 and (kw in id_str or id_str in kw):
						corresponde = true
						break

			if not corresponde:
				continue


			var progress := PlayerData.get_quest_objective_progress(quest, i)
			if progress >= objective.required_amount:
				continue

			progress += 1
			PlayerData.set_quest_objective_progress(quest, i, progress)

			print(
				"Quest: ",
				quest.quest_name,
				" | ",
				objective.describe(),
				" ",
				progress,
				"/",
				objective.required_amount
			)

			_notificar_progresso_hud(objective, progress, quest)
			_check_completion(quest)


# =========================================================
# COLETAR ITEM
# =========================================================

func register_item_collected(
	item_id: StringName,
	amount: int = 1
) -> void:

	for quest in active_quests:

		if quest == null:
			continue

		for i in range(quest.objectives.size()):

			var objective: QuestObjective = quest.objectives[i]

			if objective.type != QuestObjective.Type.COLLECT:
				continue

			if objective.item_id != item_id:
				continue

			var progress := PlayerData.get_quest_objective_progress(
				quest,
				i
			)

			if progress >= objective.required_amount:
				continue

			progress += amount

			progress = min(
				progress,
				objective.required_amount
			)

			PlayerData.set_quest_objective_progress(
				quest,
				i,
				progress
			)

			print(
				"Quest: ",
				quest.quest_name,
				" | ",
				objective.describe(),
				" ",
				progress,
				"/",
				objective.required_amount
			)

# =========================================================
# INVESTIGAÃ‡ÃƒO COM GYO
# =========================================================

func register_investigation(clue_id: StringName) -> void:
	var id_str := String(clue_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		for i in range(quest.objectives.size()):
			var objective: QuestObjective = quest.objectives[i]
			if objective.type != QuestObjective.Type.INVESTIGATE:
				continue

			var target_str := String(objective.target_clue_id).to_lower()
			if target_str.is_empty() or target_str == id_str or id_str in target_str or target_str in id_str:
				var progress := PlayerData.get_quest_objective_progress(quest, i)
				if progress >= objective.required_amount:
					continue

				progress += 1
				PlayerData.set_quest_objective_progress(quest, i, progress)
				_notificar_progresso_hud(objective, progress, quest)
				_check_completion(quest)


# =========================================================
# FURTIVIDADE COM ZETSU
# =========================================================

func register_stealth_pass(zone_id: StringName) -> void:
	var id_str := String(zone_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		for i in range(quest.objectives.size()):
			var objective: QuestObjective = quest.objectives[i]
			if objective.type != QuestObjective.Type.STEALTH_PASS:
				continue

			var target_str := String(objective.target_zone_id).to_lower()
			if target_str.is_empty() or target_str == id_str or id_str in target_str or target_str in id_str:
				var progress := PlayerData.get_quest_objective_progress(quest, i)
				if progress >= objective.required_amount:
					continue

				progress += 1
				PlayerData.set_quest_objective_progress(quest, i, progress)
				_notificar_progresso_hud(objective, progress, quest)
				_check_completion(quest)


# =========================================================
# PERSUASÃƒO / DIÃLOGO DE ESCOLHA
# =========================================================

func register_persuasion(npc_id: StringName) -> void:
	var id_str := String(npc_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		for i in range(quest.objectives.size()):
			var objective: QuestObjective = quest.objectives[i]
			if objective.type != QuestObjective.Type.PERSUASION:
				continue

			var target_str := String(objective.target_npc_id).to_lower()
			var target_name_str := objective.target_npc_name.to_lower()
			if target_str == id_str or target_str in id_str or target_name_str in id_str or id_str in target_name_str:
				var progress := PlayerData.get_quest_objective_progress(quest, i)
				if progress >= objective.required_amount:
					continue

				progress += 1
				PlayerData.set_quest_objective_progress(quest, i, progress)
				_notificar_progresso_hud(objective, progress, quest)
				_check_completion(quest)


func _notificar_progresso_hud(obj: QuestObjective, progresso: int, quest: Quest) -> void:
	if obj == null:
		return
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		if progresso >= obj.required_amount:
			hud.exibir_notificacao("âœ¨ Requisito ConcluÃ­do: %s!" % obj.describe())
		else:
			hud.exibir_notificacao("ðŸŽ¯ Progresso: %s (%d/%d)" % [obj.describe(), progresso, obj.required_amount])



# =========================================================
# VERIFICAR CONCLUSÃƒO
# =========================================================

func _check_completion(quest: Quest) -> void:

	var completed_objectives := 0

	for i in range(quest.objectives.size()):

		var objective: QuestObjective = quest.objectives[i]

		var progress := PlayerData.get_quest_objective_progress(
			quest,
			i
		)

		if progress >= objective.required_amount:
			completed_objectives += 1


	var completed := false


	if quest.completion == Quest.Completion.ALL:

		completed = (
			completed_objectives == quest.objectives.size()
		)

	else:

		completed = completed_objectives > 0


	if completed:

		print(
			"Objetivos concluÃ­dos: ",
			quest.quest_name
		)

		if quest.auto_complete:
			complete_quest(quest)


# =========================================================
# CONCLUIR QUEST
# =========================================================

func complete_quest(quest: Quest) -> void:

	if quest == null:
		return

	if not PlayerData.is_quest_active(quest):
		return

	PlayerData.complete_quest(quest)

	_give_rewards(quest)

	active_quests.erase(quest)

	print(
		"QUEST COMPLETADA: ",
		quest.quest_name
	)

	# AvanÃ§ar para a prÃ³xima missÃ£o sequencial do arco
	if PlayerData != null:
		var total_etapas := CanonQuestCatalog.obter_total_quests_do_arco(PlayerData.arco_atual)
		if PlayerData.etapa_quest_arco < total_etapas:
			PlayerData.etapa_quest_arco += 1
			print("[QuestManager] Iniciando PrÃ³xima MissÃ£o do Arco: ", PlayerData.etapa_quest_arco, "/", total_etapas)
			var prox_quest := CanonQuestCatalog.obter_quest_da_etapa(PlayerData.arco_atual, PlayerData.etapa_quest_arco)
			if prox_quest != null:
				start_quest(prox_quest)
		else:
			print("[QuestManager] Arco ", PlayerData.arco_atual, " ConcluÃ­do com Sucesso!")
			PlayerData.etapa_quest_arco = 1
			PlayerData.avancar_arco()
			var nova_quest := CanonQuestCatalog.obter_quest_da_etapa(PlayerData.arco_atual, 1)
			if nova_quest != null:
				start_quest(nova_quest)

	if GameState != null:
		GameState.salvar_jogo()


# =========================================================
# RECOMPENSAS
# =========================================================

func _give_rewards(quest: Quest) -> void:

	if quest == null:
		return


	# =====================================================
	# XP
	# =====================================================

	if quest.reward_xp > 0:

		var player = get_tree().get_first_node_in_group("player")

		if player == null:
			print("ERRO: Player nÃ£o encontrado para entregar XP.")
		else:

			var xp_system = player.get_node_or_null("XPSystem")

			if xp_system == null:

				print(
					"ERRO: XPSystem nÃ£o encontrado no Player."
				)

			else:

				xp_system.adicionar_xp(
					quest.reward_xp,
					"Quest: " + quest.quest_name
				)

				print(
					"+",
					quest.reward_xp,
					" XP"
				)


	# =====================================================
	# GOLD
	# =====================================================

	if quest.reward_gold > 0:

		print(
			"+",
			quest.reward_gold,
			" Gold"
		)


# =========================================================
# CONSULTAS DE ESTADO E REQUISITOS (STORY GATES & GPS)
# =========================================================

func get_active_objective() -> QuestObjective:
	if active_quests.is_empty() or active_quests[0] == null:
		return null
	var q: Quest = active_quests[0]
	for i in range(q.objectives.size()):
		var obj: QuestObjective = q.objectives[i]
		if PlayerData.get_quest_objective_progress(q, i) < obj.required_amount:
			return obj
	return null


func get_active_objective_index() -> int:
	if active_quests.is_empty() or active_quests[0] == null:
		return -1
	var q: Quest = active_quests[0]
	for i in range(q.objectives.size()):
		var obj: QuestObjective = q.objectives[i]
		if PlayerData.get_quest_objective_progress(q, i) < obj.required_amount:
			return i
	return -1


func is_all_active_objectives_completed() -> bool:
	return get_active_objective() == null
