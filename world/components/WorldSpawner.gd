class_name WorldSpawner
extends Node2D

# ============================================================
# HUNTER ONLINE — WORLD SPAWNER & ENTITY LIFECYCLE MANAGER
# ============================================================
#
# Gerencia o ciclo de vida e renascimento de criaturas do mundo:
# - Separa explicitamente World Spawns (renascem periodicamente) de
#   Mission Spawns (vinculados ao ciclo de vida da instância de missão).
# - Monitora morte, inicia timer de respawn e recria a entidade com vida cheia.
# - Suporta raio de dispersão (spawn_radius) e dados canônicos (EnemyData).
# ============================================================

signal entity_spawned(entity: CharacterBody2D)
signal entity_died(entity: CharacterBody2D)
signal respawn_timer_started(delay: float)

@export_category("Spawner Configuration")
@export var enemy_data: EnemyData = null
@export var enemy_scene: PackedScene = preload("res://scripts/systems/EnemySystem/Enemy.tscn")
@export var respawn_delay: float = 20.0
@export var auto_spawn_on_ready: bool = true
@export var spawn_radius: float = 0.0

@export_category("Mission Bindings (Optional)")
@export var is_mission_spawner: bool = false
@export var quest_arc: int = 0
@export var quest_etapa: int = 0
@export var enemy_id_override: StringName = &""
@export var enemy_custom_name: String = ""

var current_entity: CharacterBody2D = null
var _respawn_timer: Timer = null
var _is_destroyed: bool = false


func _ready() -> void:
	add_to_group("world_spawners")
	_configurar_timer()
	if auto_spawn_on_ready:
		call_deferred("spawn_entity")


func _configurar_timer() -> void:
	_respawn_timer = Timer.new()
	_respawn_timer.name = "RespawnTimer"
	_respawn_timer.one_shot = true
	_respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	add_child(_respawn_timer)


func spawn_entity() -> CharacterBody2D:
	if _is_destroyed or not is_inside_tree():
		return null

	if current_entity != null and is_instance_valid(current_entity):
		return current_entity

	if enemy_scene == null:
		push_warning("[WorldSpawner] 'enemy_scene' é nulo em: %s" % name)
		return null

	var entity: CharacterBody2D = enemy_scene.instantiate() as CharacterBody2D
	if entity == null:
		return null

	# Posicionamento com raio opcional
	var spawn_pos: Vector2 = global_position
	if spawn_radius > 0.0:
		var angulo := randf() * TAU
		var dist := randf() * spawn_radius
		spawn_pos += Vector2(cos(angulo), sin(angulo)) * dist
	entity.global_position = spawn_pos

	# Configurar EnemySystem na entidade
	var es: EnemySystem = entity.get_node_or_null("EnemySystem") as EnemySystem
	if es != null:
		es.spawner_ref = self
		es.spawn_position_origin = spawn_pos
		if enemy_data != null:
			es.enemy_data = enemy_data
		if not enemy_id_override.is_empty():
			es.enemy_id = enemy_id_override
		if not enemy_custom_name.is_empty():
			es.enemy_name = enemy_custom_name
		if is_mission_spawner:
			es.is_mission_enemy = true
			es.quest_arc = quest_arc
			es.quest_etapa = quest_etapa

	entity.add_to_group("enemies")
	entity.add_to_group("enemy")

	current_entity = entity
	get_parent().add_child(entity)

	entity_spawned.emit(entity)
	return entity


func on_spawned_died(entity: Node) -> void:
	if entity == current_entity:
		current_entity = null

	entity_died.emit(entity as CharacterBody2D)

	# Se for spawner de missão única, não renasce automaticamente
	if is_mission_spawner:
		return

	# Iniciar timer de renascimento de mundo livre
	if respawn_delay > 0.0 and _respawn_timer != null and not _is_destroyed:
		respawn_timer_started.emit(respawn_delay)
		_respawn_timer.start(respawn_delay)


func _on_respawn_timer_timeout() -> void:
	if not _is_destroyed and (current_entity == null or not is_instance_valid(current_entity)):
		spawn_entity()


func forcar_respawn_imediato() -> void:
	if _respawn_timer != null and not _respawn_timer.is_stopped():
		_respawn_timer.stop()
	if current_entity != null and is_instance_valid(current_entity):
		current_entity.queue_free()
		current_entity = null
	spawn_entity()


func cleanup() -> void:
	_is_destroyed = true
	if _respawn_timer != null:
		_respawn_timer.stop()
	if current_entity != null and is_instance_valid(current_entity):
		current_entity.queue_free()
		current_entity = null
