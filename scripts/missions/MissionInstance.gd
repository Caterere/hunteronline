class_name MissionInstance
extends RefCounted

# ============================================================
# HUNTER ONLINE — MISSION INSTANCE & ENTITY LIFECYCLE
# ============================================================
#
# Isola o ciclo de vida e estado de execução de uma missão:
# - Gerencia as entidades instanciadas exclusivamente para a missão.
# - Rastreia o progresso de objetivos e condições em tempo de execução.
# - Executa limpeza atômica (cleanup) ao reiniciar ou cancelar a missão,
#   evitando entidades órfãs contaminando novas tentativas no mapa.
# ============================================================

enum MissionState {
	LOCKED,
	ACTIVE,
	COMPLETED,
	FAILED
}

var quest: Quest = null
var arc_id: int = 1
var etapa_id: int = 1
var state: MissionState = MissionState.ACTIVE

var spawned_entities: Array[Node] = []
var objective_progress: Dictionary = {}
var mission_timer: float = 0.0


func _init(p_quest: Quest, p_arc: int = 1, p_etapa: int = 1) -> void:
	quest = p_quest
	arc_id = p_arc
	etapa_id = p_etapa
	state = MissionState.ACTIVE
	spawned_entities.clear()
	objective_progress.clear()

	if quest != null:
		for i in range(quest.objectives.size()):
			objective_progress[i] = 0


func register_spawned_entity(entity: Node) -> void:
	if entity != null and not spawned_entities.has(entity):
		spawned_entities.append(entity)


func unregister_spawned_entity(entity: Node) -> void:
	spawned_entities.erase(entity)


func get_progress(objective_idx: int) -> int:
	return objective_progress.get(objective_idx, 0)


func set_progress(objective_idx: int, amount: int) -> void:
	objective_progress[objective_idx] = amount


func add_progress(objective_idx: int, delta: int = 1) -> int:
	var cur: int = get_progress(objective_idx)
	var novo: int = cur + delta
	objective_progress[objective_idx] = novo
	return novo


func is_objective_completed(objective_idx: int) -> bool:
	if quest == null or objective_idx < 0 or objective_idx >= quest.objectives.size():
		return false
	var obj: QuestObjective = quest.objectives[objective_idx]
	return get_progress(objective_idx) >= obj.required_amount


func is_all_objectives_completed() -> bool:
	if quest == null or quest.objectives.is_empty():
		return true
	for i in range(quest.objectives.size()):
		if not is_objective_completed(i):
			return false
	return true


func complete() -> void:
	state = MissionState.COMPLETED
	cleanup()


func fail() -> void:
	state = MissionState.FAILED
	cleanup()


func cleanup() -> void:
	for node in spawned_entities:
		if is_instance_valid(node):
			node.queue_free()
	spawned_entities.clear()
