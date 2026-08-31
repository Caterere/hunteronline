class_name SpawnPoint
extends Marker2D

# ============================================================
# HUNTER ONLINE - SPAWN POINT COMPONENT
# ============================================================
#
# Marca e registra um ponto de nascimento/reaparecimento no mapa:
# - Identificador único de spawn (ex: "default", "from_lobby", "from_gate", "checkpoint")
# - Auto-registro no WorldProgressionManager ao entrar na árvore de cena
# - Suporte a spawn padrão e checkpoints regionais
#
# ============================================================

@export var spawn_id: StringName = &"default"
@export var is_default_spawn: bool = true
@export var is_checkpoint: bool = false
@export var display_name: String = "Ponto de Spawn"


func _enter_tree() -> void:
	add_to_group("spawn_point")


func _ready() -> void:
	var wpm = get_node_or_null("/root/WorldProgressionManager")
	if wpm != null and wpm.has_method("registrar_spawn_point"):
		wpm.registrar_spawn_point(self)
