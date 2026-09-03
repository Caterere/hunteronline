class_name StoryGate
extends RefCounted

# ============================================================
# HUNTER ONLINE - STORY GATE & REQUISITOS DE PROGRESSÃO NARRATIVA
# ============================================================
#
# Sistema modular e genérico de validação de requisitos de história:
# - Verifica se arcos, etapas de quest, objetivos e abates foram cumpridos
# - Bloqueia transições indevidas de mapa (anti-bypass)
# - Retorna explicações ricas e detalhadas das pendências para a UI
# - Suporta requisitos de Quest, Inimigos Derrotados, NPCs e Custom Callables
#
# ============================================================

enum GateType {
	ARC_STAGE_MIN,        # Exige arco X e etapa mínima Y
	QUEST_COMPLETED,      # Exige que uma quest específica esteja concluída
	OBJECTIVES_COMPLETED, # Exige que todos os objetivos da quest ativa estejam concluídos
	CUSTOM_REQUIREMENTS   # Validação por lista customizada ou Callable
}

# Propriedades de Requisito
var required_arc: int = 1
var required_stage_min: int = 1
var required_all_arc_stages: bool = false
var required_quest_id: String = ""
var required_objective_id: String = ""
var required_kills: Dictionary = {} # { "enemy_id": required_count }
var custom_validator: Callable = Callable()

var gate_title: String = "Passagem Bloqueada"
var default_locked_message: String = "Você ainda não concluiu todos os objetivos obrigatórios para avançar."


func _init(p_arc: int = 1, p_stage_min: int = 1, p_all_stages: bool = false) -> void:
	required_arc = p_arc
	required_stage_min = p_stage_min
	required_all_arc_stages = p_all_stages


# ============================================================
# VALIDAÇÃO PRINCIPAL
# ============================================================

func can_advance() -> bool:
	return get_unmet_requirements().is_empty()


func get_unmet_requirements() -> Array[String]:
	var pendencias: Array[String] = []

	if StoryManager != null:
		return StoryManager.obter_pendencias_gate(required_arc, required_stage_min, required_all_arc_stages)
	elif PlayerData != null:
		# Fallback legado
		if PlayerData.arco_atual < required_arc:
			pendencias.append("Necessário alcançar o Arco %d da História" % required_arc)
			return pendencias
		if PlayerData.arco_atual > required_arc:
			return pendencias
		if required_all_arc_stages:
			var total_etapas = CanonQuestCatalog.obter_total_quests_do_arco(required_arc)
			if PlayerData.etapa_quest_arco < total_etapas:
				pendencias.append("Conclua todas as %d fases do Arco %d (Progresso atual: %d/%d)" % [
					total_etapas, required_arc, PlayerData.etapa_quest_arco, total_etapas
				])
		elif required_stage_min > 1 and PlayerData.etapa_quest_arco < required_stage_min:
			pendencias.append("Conclua a Etapa %d do Arco %d (Progresso atual: %d/%d)" % [
				required_stage_min, required_arc, PlayerData.etapa_quest_arco, required_stage_min
			])

	# 3. Validação de Objetivos da Quest Ativa Atual
	if QuestSystem != null and not QuestSystem.active_quests.is_empty():
		var q: Quest = QuestSystem.active_quests[0]
		if q != null:
			for i in range(q.objectives.size()):
				var obj: QuestObjective = q.objectives[i]
				var prog: int = PlayerData.get_quest_objective_progress(q, i)
				if prog < obj.required_amount:
					var faltam: int = obj.required_amount - prog
					match obj.type:
						QuestObjective.Type.KILL:
							var nome_e := str(obj.enemy_type).replace("_", " ").capitalize()
							if nome_e.is_empty(): nome_e = "Criaturas"
							pendencias.append("Derrotar %s (%d/%d — Faltam %d)" % [
								nome_e, prog, obj.required_amount, faltam
							])
						QuestObjective.Type.VISIT:
							var nome_npc := obj.target_npc_name if not obj.target_npc_name.is_empty() else str(obj.target_npc_id).capitalize()
							pendencias.append("Falar com %s" % nome_npc)
						QuestObjective.Type.COLLECT:
							var nome_item := str(obj.item_id).replace("_", " ").capitalize()
							pendencias.append("Coletar %s (%d/%d)" % [nome_item, prog, obj.required_amount])
						_:
							pendencias.append("%s (%d/%d)" % [obj.describe(), prog, obj.required_amount])

	# 4. Validação de Kills Requeridas Específicas
	for enemy_id in required_kills.keys():
		var req_count: int = int(required_kills[enemy_id])
		var current_count: int = _obter_kills_do_inimigo(enemy_id)
		if current_count < req_count:
			var faltam: int = req_count - current_count
			pendencias.append("Derrotar %s (%d/%d — Faltam %d)" % [
				str(enemy_id).replace("_", " ").capitalize(), current_count, req_count, faltam
			])

	# 5. Validação Customizada por Callable
	if custom_validator.is_valid():
		var res = custom_validator.call()
		if res is String and not res.is_empty():
			pendencias.append(res)
		elif res is bool and not res:
			pendencias.append("Condição especial da área não atendida")

	return pendencias


func get_formatted_rejection_dialogue() -> Array[Dictionary]:
	var falas: Array[Dictionary] = []
	var pendencias := get_unmet_requirements()

	falas.append({
		"falante": "⛩️ " + gate_title.to_upper(),
		"texto": "A passagem está selada pelas regras do Exame Hunter! Você não pode avançar sem cumprir todos os requisitos obrigatórios desta área."
	})

	var lista_str: String = "OBJETIVOS PENDENTES:\n"
	for p in pendencias:
		lista_str += "• " + p + "\n"

	falas.append({
		"falante": "⛩️ REQUISITOS NECESSÁRIOS",
		"texto": lista_str.strip_edges()
	})

	return falas


func _obter_kills_do_inimigo(enemy_id: String) -> int:
	if PlayerData == null:
		return 0
	# Verificar se há contagem na quest ativa
	if QuestSystem != null and not QuestSystem.active_quests.is_empty():
		var q: Quest = QuestSystem.active_quests[0]
		for i in range(q.objectives.size()):
			var obj: QuestObjective = q.objectives[i]
			if obj.type == QuestObjective.Type.KILL and str(obj.enemy_type).to_lower() == enemy_id.to_lower():
				return PlayerData.get_quest_objective_progress(q, i)

	return PlayerData.quest_states.get("kills_" + enemy_id.to_lower(), 0)