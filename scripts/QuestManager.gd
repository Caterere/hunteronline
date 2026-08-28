class_name QuestManager
extends Node

signal objective_activated(quest: Quest, objective_index: int, objective: QuestObjective)
signal enemies_synchronized(objective_desc: String, required: int, alive: int, spawned: int)

var active_quests: Array[Quest] = []

# Registro de pontos de spawn e âncoras para reconciliação de inimigos de missão
var _mission_spawn_registry: Array[Dictionary] = []

# Métricas de Telemetria
var total_reconciliations_triggered: int = 0
var total_mission_enemies_respawned: int = 0


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
		print("Pré-requisitos não cumpridos.")
		return false

	if not PlayerData.is_quest_active(quest):
		if not PlayerData.start_quest(quest):
			return false

	if not active_quests.has(quest):
		active_quests.append(quest)

	print("Quest aceita e conectada: ", quest.quest_name)

	# Sincronizar os inimigos do mapa com base no novo objetivo ativo
	sincronizar_inimigos_do_mapa()

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
# UTILITÁRIO DE OBJETIVO ATIVO
# =========================================================

func _obter_active_objective_idx(quest: Quest) -> int:
	if quest == null:
		return -1
	for i in range(quest.objectives.size()):
		var obj: QuestObjective = quest.objectives[i]
		if PlayerData.get_quest_objective_progress(quest, i) < obj.required_amount:
			return i
	return -1


# =========================================================
# VISITAR NPC
# =========================================================

func register_npc_visit(npc_id: StringName) -> void:
	var id_str := String(npc_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		var active_idx := _obter_active_objective_idx(quest)
		if active_idx == -1:
			continue

		var objective: QuestObjective = quest.objectives[active_idx]
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

		var progress := PlayerData.get_quest_objective_progress(quest, active_idx)
		if progress >= objective.required_amount:
			continue

		progress += 1
		PlayerData.set_quest_objective_progress(quest, active_idx, progress)

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

		if progress >= objective.required_amount:
			sincronizar_inimigos_do_mapa()


# =========================================================
# DERROTAR INIMIGO
# =========================================================

func register_enemy_kill(enemy_id: StringName) -> void:
	for quest in active_quests:
		if quest == null:
			continue

		# Localizar o objetivo ativo atual da quest
		var active_idx := _obter_active_objective_idx(quest)
		if active_idx == -1:
			continue

		var objective: QuestObjective = quest.objectives[active_idx]

		if objective.type != QuestObjective.Type.KILL:
			continue

		if not _enemy_id_corresponde(objective.enemy_type, enemy_id):
			continue

		var progress := PlayerData.get_quest_objective_progress(quest, active_idx)
		if progress >= objective.required_amount:
			continue

		progress += 1
		PlayerData.set_quest_objective_progress(quest, active_idx, progress)

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

		# Se completou o objetivo atual, sincronizar mapa para o próximo conjunto
		if progress >= objective.required_amount:
			sincronizar_inimigos_do_mapa()


# =========================================================
# COLETAR ITEM
# =========================================================

func register_item_collected(
	item_id: StringName,
	amount: int = 1
) -> void:
	var id_str := String(item_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		var active_idx := _obter_active_objective_idx(quest)
		if active_idx == -1:
			continue

		var objective: QuestObjective = quest.objectives[active_idx]
		if objective.type != QuestObjective.Type.COLLECT:
			continue

		var target_str := String(objective.item_id).to_lower()
		if target_str != id_str and target_str not in id_str and id_str not in target_str:
			continue

		var progress := PlayerData.get_quest_objective_progress(quest, active_idx)
		if progress >= objective.required_amount:
			continue

		progress += amount
		progress = min(progress, objective.required_amount)
		PlayerData.set_quest_objective_progress(quest, active_idx, progress)

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

		if progress >= objective.required_amount:
			sincronizar_inimigos_do_mapa()


# =========================================================
# INVESTIGAÇÃO COM GYO
# =========================================================

func register_investigation(clue_id: StringName) -> void:
	var id_str := String(clue_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		var active_idx := _obter_active_objective_idx(quest)
		if active_idx == -1:
			continue

		var objective: QuestObjective = quest.objectives[active_idx]
		if objective.type != QuestObjective.Type.INVESTIGATE:
			continue

		var target_str := String(objective.target_clue_id).to_lower()
		if target_str.is_empty() or target_str == id_str or id_str in target_str or target_str in id_str:
			var progress := PlayerData.get_quest_objective_progress(quest, active_idx)
			if progress >= objective.required_amount:
				continue

			progress += 1
			PlayerData.set_quest_objective_progress(quest, active_idx, progress)
			_notificar_progresso_hud(objective, progress, quest)
			_check_completion(quest)

			if progress >= objective.required_amount:
				sincronizar_inimigos_do_mapa()


# =========================================================
# FURTIVIDADE COM ZETSU
# =========================================================

func register_stealth_pass(zone_id: StringName) -> void:
	var id_str := String(zone_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		var active_idx := _obter_active_objective_idx(quest)
		if active_idx == -1:
			continue

		var objective: QuestObjective = quest.objectives[active_idx]
		if objective.type != QuestObjective.Type.STEALTH_PASS:
			continue

		var target_str := String(objective.target_zone_id).to_lower()
		if target_str.is_empty() or target_str == id_str or id_str in target_str or target_str in id_str:
			var progress := PlayerData.get_quest_objective_progress(quest, active_idx)
			if progress >= objective.required_amount:
				continue

			progress += 1
			PlayerData.set_quest_objective_progress(quest, active_idx, progress)
			_notificar_progresso_hud(objective, progress, quest)
			_check_completion(quest)

			if progress >= objective.required_amount:
				sincronizar_inimigos_do_mapa()


# =========================================================
# PERSUASÃO / DIÁLOGO DE ESCOLHA
# =========================================================

func register_persuasion(npc_id: StringName) -> void:
	var id_str := String(npc_id).to_lower()

	for quest in active_quests:
		if quest == null:
			continue

		var active_idx := _obter_active_objective_idx(quest)
		if active_idx == -1:
			continue

		var objective: QuestObjective = quest.objectives[active_idx]
		if objective.type != QuestObjective.Type.PERSUASION:
			continue

		var target_str := String(objective.target_npc_id).to_lower()
		var target_name_str := objective.target_npc_name.to_lower()
		if target_str == id_str or target_str in id_str or target_name_str in id_str or id_str in target_name_str:
			var progress := PlayerData.get_quest_objective_progress(quest, active_idx)
			if progress >= objective.required_amount:
				continue

			progress += 1
			PlayerData.set_quest_objective_progress(quest, active_idx, progress)
			_notificar_progresso_hud(objective, progress, quest)
			_check_completion(quest)

			if progress >= objective.required_amount:
				sincronizar_inimigos_do_mapa()


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

	# Avançar para a próxima missão sequencial do arco
	if PlayerData != null:
		var total_etapas := CanonQuestCatalog.obter_total_quests_do_arco(PlayerData.arco_atual)
		if PlayerData.etapa_quest_arco < total_etapas:
			PlayerData.etapa_quest_arco += 1
			print("[QuestManager] Iniciando Próxima Missão do Arco: ", PlayerData.etapa_quest_arco, "/", total_etapas)
			var prox_quest := CanonQuestCatalog.obter_quest_da_etapa(PlayerData.arco_atual, PlayerData.etapa_quest_arco)
			if prox_quest != null:
				start_quest(prox_quest)
		else:
			print("[QuestManager] Todas as ", total_etapas, " etapas do Arco ", PlayerData.arco_atual, " foram Concluídas com Sucesso!")
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud != null and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🏆 Saga Concluída! Dirija-se ao Portal de Transição para o próximo Arco.")

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


# =========================================================
# HELPER DE CORRESPONDÊNCIA DE ENEMY ID
# =========================================================

func _enemy_id_corresponde(target: StringName, actual: StringName) -> bool:
	var target_str := String(target).to_lower()
	var actual_str := String(actual).to_lower()

	if target_str.is_empty() or target_str == "any" or target_str == "all" or target_str == "inimigo" or target_str == "monstro":
		return true
	if target_str == actual_str or target_str in actual_str or actual_str in target_str:
		return true

	var keywords := target_str.split("_")
	for kw in keywords:
		if kw.length() >= 4 and (kw in actual_str or actual_str in kw):
			return true

	return false


# =========================================================
# VALIDAÇÃO DE INIMIGO PARA OBJETIVO ATIVO
# =========================================================

func is_enemy_valid_for_active_objective(enemy_id: StringName, enemy_system = null) -> bool:
	# Inimigos normais de mundo (não marcados como de missão) são sempre válidos para combate
	if enemy_system != null and not enemy_system.is_mission_enemy:
		return true

	if enemy_system != null and enemy_system.is_mission_enemy:
		if enemy_system.quest_arc > 0 and PlayerData != null and PlayerData.arco_atual != enemy_system.quest_arc:
			return false
		if enemy_system.quest_etapa > 0 and PlayerData != null and PlayerData.etapa_quest_arco != enemy_system.quest_etapa:
			return false

	# Verificar nas quests ativas se há um objetivo ativo do tipo KILL compatível
	for quest in active_quests:
		if quest == null:
			continue

		var active_idx := -1
		for i in range(quest.objectives.size()):
			var obj: QuestObjective = quest.objectives[i]
			if PlayerData.get_quest_objective_progress(quest, i) < obj.required_amount:
				active_idx = i
				break

		if active_idx == -1:
			continue

		var objective: QuestObjective = quest.objectives[active_idx]

		# Se o inimigo define um índice de objetivo específico e não coincide com o ativo
		if enemy_system != null and enemy_system.quest_objective_index >= 0:
			if enemy_system.quest_objective_index != active_idx:
				continue

		if objective.type == QuestObjective.Type.KILL:
			if _enemy_id_corresponde(objective.enemy_type, enemy_id):
				return true

	return false


# =========================================================
# REGISTRO DE SPAWN DE MISSÃO
# =========================================================

func registrar_spawn_posicao_missao(enemy_id: StringName, pos: Vector2, arc: int = 0, etapa: int = 0, obj_idx: int = -1, enemy_data_res: Resource = null, enemy_name: String = "") -> void:
	for entry in _mission_spawn_registry:
		if entry["enemy_id"] == enemy_id and entry["pos"] == pos and entry["arc"] == arc and entry["etapa"] == etapa:
			return

	_mission_spawn_registry.append({
		"enemy_id": enemy_id,
		"pos": pos,
		"arc": arc,
		"etapa": etapa,
		"obj_idx": obj_idx,
		"enemy_data": enemy_data_res,
		"enemy_name": enemy_name
	})


func limpar_registro_spawns() -> void:
	_mission_spawn_registry.clear()


func _registrar_spawn_automatico(es: EnemySystem) -> void:
	if es == null or es.enemy_body == null or not is_instance_valid(es.enemy_body):
		return

	var pos = es.spawn_position_origin if es.spawn_position_origin != Vector2.ZERO else es.enemy_body.global_position
	registrar_spawn_posicao_missao(
		es.enemy_id,
		pos,
		es.quest_arc,
		es.quest_etapa,
		es.quest_objective_index,
		es.enemy_data,
		es.enemy_name
	)


# =========================================================
# SINCRONIZAÇÃO E RECONCILIAÇÃO DE INIMIGOS NO MAPA
# =========================================================

func sincronizar_inimigos_do_mapa(map_node: Node = null) -> void:
	var tree := get_tree()
	if tree == null:
		return

	var enemies_in_tree: Array[Node] = tree.get_nodes_in_group("enemy_systems")

	for node in enemies_in_tree:
		var es := node as EnemySystem
		if es == null or not is_instance_valid(es):
			continue

		if es.is_mission_enemy:
			var is_valid: bool = is_enemy_valid_for_active_objective(es.enemy_id, es)
			es.ativar_inimigo_missao(is_valid)

			if es.spawn_position_origin == Vector2.ZERO and es.enemy_body != null:
				es.spawn_position_origin = es.enemy_body.global_position

			_registrar_spawn_automatico(es)

	sincronizar_inimigos_do_objetivo(map_node)


func sincronizar_inimigos_do_objetivo(map_node: Node = null) -> void:
	var tree := get_tree()
	if tree == null:
		return

	if active_quests.is_empty() or active_quests[0] == null:
		return

	var q: Quest = active_quests[0]
	var active_idx: int = get_active_objective_index()
	if active_idx < 0 or active_idx >= q.objectives.size():
		return

	var obj: QuestObjective = q.objectives[active_idx]
	if obj == null or obj.type != QuestObjective.Type.KILL:
		return

	var progress: int = PlayerData.get_quest_objective_progress(q, active_idx)
	var needed: int = maxi(0, obj.required_amount - progress)
	if needed <= 0:
		return

	# Contar quantos inimigos vivos e ativos já existem na cena
	var vivos: int = 0
	var enemy_systems: Array[Node] = tree.get_nodes_in_group("enemy_systems")
	for node in enemy_systems:
		var es := node as EnemySystem
		if es != null and is_instance_valid(es) and es.is_alive() and es.enemy_body != null and is_instance_valid(es.enemy_body) and es.enemy_body.visible:
			if _enemy_id_corresponde(obj.enemy_type, es.enemy_id):
				vivos += 1

	if vivos < needed:
		var faltantes: int = needed - vivos
		_instanciar_inimigos_reconciliacao(obj, active_idx, faltantes, map_node)
	else:
		enemies_synchronized.emit(obj.describe(), needed, vivos, 0)


func _instanciar_inimigos_reconciliacao(obj: QuestObjective, obj_idx: int, quantidade: int, map_node: Node = null) -> void:
	var target_parent = map_node
	if target_parent == null:
		var tree := get_tree()
		target_parent = tree.current_scene if tree != null else null
	if target_parent == null:
		return

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn == null:
		push_error("[QuestManager] Erro: Enemy.tscn não pôde ser carregado para reconciliação!")
		return

	var cur_arc: int = PlayerData.arco_atual if PlayerData != null else 0
	var cur_etapa: int = PlayerData.etapa_quest_arco if PlayerData != null else 0

	# Buscar posições registradas para esta etapa/inimigo
	var posicoes_candidatas: Array[Vector2] = []
	var template_data: Resource = null
	var template_nome: String = ""

	for entry in _mission_spawn_registry:
		if _enemy_id_corresponde(obj.enemy_type, entry["enemy_id"]):
			if entry["arc"] == 0 or entry["arc"] == cur_arc:
				if entry["etapa"] == 0 or entry["etapa"] == cur_etapa:
					posicoes_candidatas.append(entry["pos"])
					if template_data == null and entry["enemy_data"] != null:
						template_data = entry["enemy_data"]
					if template_nome.is_empty() and not entry["enemy_name"].is_empty():
						template_nome = entry["enemy_name"]

	# Posição fallback caso nenhuma tenha sido registrada
	var player = get_tree().get_first_node_in_group("player")
	var fallback_base: Vector2 = (player.global_position + Vector2(80, 0)) if player != null else Vector2(200, 200)

	var spawnados: int = 0
	for i in range(quantidade):
		var spawn_pos: Vector2 = fallback_base + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		if not posicoes_candidatas.is_empty():
			spawn_pos = posicoes_candidatas[i % posicoes_candidatas.size()] + Vector2(randf_range(-10, 10), randf_range(-10, 10))

		var enemy_inst = enemy_scn.instantiate() as CharacterBody2D
		enemy_inst.name = "MissionEnemy_%s_%d_%d" % [String(obj.enemy_type), obj_idx, Time.get_ticks_msec() + i]
		enemy_inst.position = spawn_pos
		target_parent.add_child(enemy_inst)

		var es: EnemySystem = enemy_inst.get_node_or_null("EnemySystem") as EnemySystem
		if es != null:
			es.enemy_id = obj.enemy_type
			es.enemy_name = template_nome if not template_nome.is_empty() else String(obj.enemy_type).replace("_", " ").capitalize()
			es.is_mission_enemy = true
			es.quest_arc = cur_arc
			es.quest_etapa = cur_etapa
			es.quest_objective_index = obj_idx
			es.spawn_position_origin = spawn_pos
			if template_data != null:
				es.enemy_data = template_data
			if not es.died.is_connected(register_enemy_kill):
				es.died.connect(register_enemy_kill)
			es.ativar_inimigo_missao(true)

		spawnados += 1

	total_reconciliations_triggered += 1
	total_mission_enemies_respawned += spawnados
	print("============================================================")
	print("[QuestManager] 🔄 RECONCILIAÇÃO / RESPAWN ORIENTADO A ESTADO:")
	print("  Objetivo: ", obj.describe())
	print("  Inimigos Reconciliados: ", spawnados, " de '", obj.enemy_type, "'")
	print("============================================================")
	enemies_synchronized.emit(obj.describe(), obj.required_amount, obj.required_amount, spawnados)


# =========================================================
# TELEMETRIA E DIAGNÓSTICO DE MISSÕES
# =========================================================

func obter_debug_telemetria_missoes() -> Dictionary:
	var q: Quest = active_quests[0] if not active_quests.is_empty() and active_quests[0] != null else null
	var obj: QuestObjective = get_active_objective()
	var obj_idx: int = get_active_objective_index()

	var req: int = obj.required_amount if obj != null else 0
	var prog: int = PlayerData.get_quest_objective_progress(q, obj_idx) if (q != null and obj_idx >= 0) else 0

	var vivos: int = 0
	if obj != null and obj.type == QuestObjective.Type.KILL:
		var tree := get_tree()
		if tree != null:
			for node in tree.get_nodes_in_group("enemy_systems"):
				var es := node as EnemySystem
				if es != null and is_instance_valid(es) and es.is_alive() and es.enemy_body != null and es.enemy_body.visible:
					if _enemy_id_corresponde(obj.enemy_type, es.enemy_id):
						vivos += 1

	return {
		"quest_name": q.quest_name if q != null else "Nenhuma",
		"active_objective": obj.describe() if obj != null else "Nenhum",
		"objective_type": QuestObjective.Type.keys()[obj.type] if obj != null else "NONE",
		"required_amount": req,
		"current_progress": prog,
		"matching_enemies_alive": vivos,
		"missing_enemies": maxi(0, req - prog - vivos),
		"total_reconciliations": total_reconciliations_triggered,
		"total_respawned": total_mission_enemies_respawned
	}
