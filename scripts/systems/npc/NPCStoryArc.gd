class_name NPCStoryArc
extends Resource

# ============================================================
# HUNTER ONLINE — NPC STORY ARC (FASE L)
# ============================================================
#
# Estrutura declarativa para arcos narrativos de NPCs importantes.
# Permite encadear Encontro -> Missão -> Escolha -> Relacionamento -> Novo Encontro -> Consequência.
# ============================================================

@export var arc_id: StringName = &""
@export var npc_id: String = ""
@export var arc_title: String = ""
@export_multiline var synopsis: String = ""

# Estágios do Arco:
# [
#   {
#     "stage": 1,
#     "title": "Primeiro Encontro na Taverna",
#     "required_memory": "encontro_inicial",
#     "quest_id": "quest_favor_npc",
#     "choice_id": "decisao_ajudar_npc",
#     "next_encounter_scene": "res://world/maps/posto_avancado.tscn",
#     "consequences": [{"type": "reputation", "faction": "associacao_hunter", "value": 50}]
#   }
# ]
@export var stages: Array = []

@export var current_stage: int = 1
@export var is_completed: bool = false


func _init(
	p_id: StringName = &"",
	p_npc: String = "",
	p_title: String = "",
	p_synopsis: String = ""
) -> void:
	arc_id = p_id
	npc_id = p_npc
	arc_title = p_title
	synopsis = p_synopsis


func get_current_stage_data() -> Dictionary:
	for s in stages:
		if int(s.get("stage", 1)) == current_stage:
			return s
	return {}


func can_advance_stage(memory_system: Node = null) -> bool:
	if is_completed:
		return false
	var st = get_current_stage_data()
	if st.is_empty():
		return false

	var req_mem = str(st.get("required_memory", ""))
	if not req_mem.is_empty() and memory_system != null and memory_system.has_method("has_memory"):
		if not memory_system.call("has_memory", npc_id, req_mem):
			return false

	var req_choice = str(st.get("choice_id", ""))
	if not req_choice.is_empty():
		var sm = Engine.get_main_loop().root.get_node_or_null("StoryManager")
		if sm != null and sm.has_method("has_choice"):
			if not sm.call("has_choice", req_choice):
				return false

	return true


func advance_stage() -> bool:
	if is_completed:
		return false
	current_stage += 1
	if current_stage > stages.size():
		is_completed = true
		print("[NPCStoryArc] 🏆 Arco de NPC '%s' (%s) CONCLUÍDO!" % [npc_id, arc_title])
	else:
		print("[NPCStoryArc] 📜 Arco de NPC '%s' avançou para Estágio %d/%d" % [npc_id, current_stage, stages.size()])
	return true


func to_dict() -> Dictionary:
	return {
		"arc_id": String(arc_id),
		"npc_id": npc_id,
		"arc_title": arc_title,
		"synopsis": synopsis,
		"stages": stages.duplicate(true),
		"current_stage": current_stage,
		"is_completed": is_completed
	}


static func from_dict(data: Dictionary) -> Resource:
	var arc = (load("res://scripts/systems/npc/NPCStoryArc.gd") as GDScript).new()
	arc.arc_id = StringName(data.get("arc_id", ""))
	arc.npc_id = str(data.get("npc_id", ""))
	arc.arc_title = str(data.get("arc_title", ""))
	arc.synopsis = str(data.get("synopsis", ""))
	arc.stages = (data.get("stages", []) as Array).duplicate(true)
	arc.current_stage = int(data.get("current_stage", 1))
	arc.is_completed = bool(data.get("is_completed", false))
	return arc
