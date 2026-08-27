class_name DialogueTree
extends Resource

# =========================================================
# ÁRVORE DE DIÁLOGO
# =========================================================
#
# Define uma árvore completa de diálogo
# Contém múltiplos DialogueNodes conectados
#
# =========================================================


# =========================================================
# METADADOS
# =========================================================

@export_category("Metadata")

@export var tree_id: StringName = &""

@export var npc_name: String = "NPC"

@export var npc_id: StringName = &""


# =========================================================
# NÓS
# =========================================================

@export_category("Nodes")

# Dicionário: node_id → DialogueNode
@export var nodes: Dictionary = {}

# ID do nó inicial
@export var root_node_id: StringName = &""


# =========================================================
# GETTERS
# =========================================================

func get_root_node() -> DialogueNode:

	if root_node_id.is_empty():
		return null

	if not nodes.has(root_node_id):
		return null

	return nodes[root_node_id] as DialogueNode


func get_node(node_id: StringName) -> DialogueNode:

	if not nodes.has(node_id):
		return null

	return nodes[node_id] as DialogueNode


func get_npc_name() -> String:

	return npc_name


func get_npc_id() -> StringName:

	return npc_id


func is_valid() -> bool:

	if root_node_id.is_empty():
		return false

	if not nodes.has(root_node_id):
		return false

	return true


# =========================================================
# DEBUG
# =========================================================

func print_tree_structure() -> void:

	print("=================================")
	print("ÁRVORE DE DIÁLOGO: ", tree_id)
	print("NPC: ", npc_name)
	print("NÓS: ", nodes.size())

	for node_id in nodes.keys():

		var node = nodes[node_id] as DialogueNode

		print(
			"├─ [",
			node_id,
			"] ",
			node.speaker_name,
			" > ",
			node.dialogue_text.substr(0, 30) + "..."
		)

		if node.has_branches():

			for branch in node.branches:

				print(
					"│  └─ \"",
					branch.choice_text,
					"\" → [",
					branch.next_node_id,
					"]"
				)

	print("=================================")
