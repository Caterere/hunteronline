class_name InteractionComponent
extends Area2D

# ============================================================
# HUNTER ONLINE - INTERACTION COMPONENT (RANGE AJUSTADO & ROBUSTO)
# ============================================================
#
# Componente de Interação 2D com NPCs, Portais e Objetos do Mundo.
# - Range ajustado e contido para evitar sobreposição entre NPCs próximos.
# - Suporta tecla [E] nativa e ação "interact".
# - Desativa processamento quando o jogo está pausado (em diálogos).
#
# ============================================================

signal interacted(interactor)

@export var interaction_text: String = "[E] Interagir"
@export var interaction_radius: float = 16.0

var player_inside: CharacterBody2D = null
var shape_col: CollisionShape2D = null


func _ready() -> void:
	process_mode = PROCESS_MODE_PAUSABLE
	collision_layer = 0
	collision_mask = 2 # Detecta Player (Layer 2)

	# Se não tiver CollisionShape2D filho, cria um com raio de 16px
	shape_col = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_col == null:
		shape_col = CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = interaction_radius
		shape_col.shape = circle
		add_child(shape_col)
	elif shape_col.shape is CircleShape2D:
		(shape_col.shape as CircleShape2D).radius = interaction_radius

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if player_inside == null or get_tree().paused:
		return

	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
		interacted.emit(player_inside)
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if player_inside == null or get_tree().paused:
		return

	if Input.is_action_just_pressed("interact"):
		interacted.emit(player_inside)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_inside = body as CharacterBody2D


func _on_body_exited(body: Node) -> void:
	if body == player_inside or body.is_in_group("player") or body.name == "Player":
		player_inside = null
