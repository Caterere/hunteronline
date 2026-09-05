class_name NPCMemorySystemClass
extends Node

# ============================================================
# HUNTER ONLINE — NPC MEMORY SYSTEM (FASE L)
# ============================================================
#
# Sistema canônico de memória episódica persistente dos NPCs:
# - Registra eventos individuais vivenciados entre o jogador e cada NPC:
#   * Ajudou / Salvou a vida do NPC
#   * Recusou pedido de auxílio ou missão
#   * Venceu ou Perdeu duelo / treino
#   * Roubou, enganou ou mentiu para o NPC
#   * Completou determinada quest ou favor pessoal
#   * Escolhas narrativas específicas tomadas perante o NPC
# - Sobrevive ao reload através da persistência atômica do SaveManager.
# ============================================================

signal memory_recorded(npc_id: String, event_id: String, payload: Dictionary)
signal memories_cleared(npc_id: String)

# Estrutura:
# memories[npc_id] = {
#     "event_id": {
#         "count": 1,
#         "first_seen": "...",
#         "last_seen": "...",
#         "payload": { ... }
#     }
# }
var memories: Dictionary = {}


func _ready() -> void:
	add_to_group("npc_memory_system")
	print("=================================")
	print("[NPCMemorySystem] MOTOR DE MEMÓRIA DE NPCS ATIVO (FASE L)")
	print("=================================")


func record_event(npc_id: String, event_id: String, payload: Dictionary = {}) -> void:
	var n_id = npc_id.strip_edges().to_lower()
	var e_id = event_id.strip_edges().to_lower()
	if n_id.is_empty() or e_id.is_empty():
		return

	if not memories.has(n_id):
		memories[n_id] = {}

	var time_now = Time.get_datetime_string_from_system()
	if memories[n_id].has(e_id):
		var entry: Dictionary = memories[n_id][e_id]
		entry["count"] = int(entry.get("count", 1)) + 1
		entry["last_seen"] = time_now
		entry["payload"].merge(payload, true)
	else:
		memories[n_id][e_id] = {
			"count": 1,
			"first_seen": time_now,
			"last_seen": time_now,
			"payload": payload.duplicate(true)
		}

	memory_recorded.emit(n_id, e_id, payload)
	print("[NPCMemorySystem] 🧠 Memória gravada para NPC '%s': [%s]" % [n_id, e_id])

	# Se houver RelationshipSystem ativo, ajustar relacionamento automaticamente
	_refletir_no_relationship_system(n_id, e_id, payload)


func has_memory(npc_id: String, event_id: String) -> bool:
	var n_id = npc_id.strip_edges().to_lower()
	var e_id = event_id.strip_edges().to_lower()
	return memories.has(n_id) and memories[n_id].has(e_id)


func get_memory(npc_id: String, event_id: String) -> Dictionary:
	var n_id = npc_id.strip_edges().to_lower()
	var e_id = event_id.strip_edges().to_lower()
	if memories.has(n_id) and memories[n_id].has(e_id):
		return memories[n_id][e_id]
	return {}


func get_memory_count(npc_id: String, event_id: String) -> int:
	var mem = get_memory(npc_id, event_id)
	return int(mem.get("count", 0))


func get_all_memories_for_npc(npc_id: String) -> Dictionary:
	var n_id = npc_id.strip_edges().to_lower()
	if memories.has(n_id):
		return memories[n_id].duplicate(true)
	return {}


func clear_npc_memories(npc_id: String) -> void:
	var n_id = npc_id.strip_edges().to_lower()
	if memories.has(n_id):
		memories.erase(n_id)
		memories_cleared.emit(n_id)


func _refletir_no_relationship_system(npc_id: String, event_id: String, payload: Dictionary) -> void:
	var rel_sys = get_node_or_null("/root/RelationshipSystem")
	if rel_sys == null or not rel_sys.has_method("modificar_relacao"):
		return

	# Reações canônicas comuns
	match event_id:
		"ajudou_npc", "salvou_vida":
			rel_sys.modificar_relacao(npc_id, 15.0, 10.0, -5.0)
		"recusou_ajuda":
			rel_sys.modificar_relacao(npc_id, -10.0, -5.0, 0.0)
		"venceu_duelo":
			rel_sys.modificar_relacao(npc_id, 0.0, 15.0, 5.0)
		"perdeu_duelo":
			rel_sys.modificar_relacao(npc_id, 5.0, -5.0, 0.0)
		"roubou_item", "mentiu_para_npc":
			rel_sys.modificar_relacao(npc_id, -25.0, -10.0, 10.0)
		"concluiu_favor":
			rel_sys.modificar_relacao(npc_id, 10.0, 5.0, 0.0)


# ============================================================
# PERSISTÊNCIA SERIALIZÁVEL
# ============================================================

func serializar() -> Dictionary:
	return {
		"version": "1.0",
		"memories": memories.duplicate(true)
	}


func deserializar(data: Dictionary) -> void:
	memories.clear()
	if data.has("memories") and data["memories"] is Dictionary:
		memories = (data["memories"] as Dictionary).duplicate(true)
