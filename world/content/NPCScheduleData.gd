class_name NPCScheduleData
extends Resource

# ============================================================
# HUNTER ONLINE - NPC SCHEDULE DATA
# ============================================================
#
# Estrutura para rotinas vivas, horários e patrulhas de NPCs:
# - Local de moradia (home) e trabalho (workplace)
# - Rotas de patrulha e regiões preferidas
# - Estado atual (working, walking, resting, training)
#
# ============================================================

@export var npc_id: String = ""
@export var npc_name: String = "Cidadão"
@export var home_pos: Vector2 = Vector2.ZERO
@export var workplace_pos: Vector2 = Vector2.ZERO
@export var preferred_regions: Array = ["val_padokia"]
@export var patrol_route: Array = [] # Array de Vector2
@export var current_state: String = "resting" # working, walking, resting, training
@export var move_speed: float = 28.0
