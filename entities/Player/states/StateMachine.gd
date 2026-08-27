class_name StateMachine
extends Node

@export var initial_state: State
@export var actor: CharacterBody2D

var current_state: State
var previous_state: State

var states: Dictionary = {}


func _ready() -> void:

	_register_states()

	if initial_state:
		change_state(initial_state.name)


func _register_states() -> void:

	for child in get_children():

		if child is State:

			states[child.name] = child

			child.state_machine = self
			child.player = actor

			child.transition_requested.connect(_on_transition_requested)


func _process(delta: float) -> void:

	if current_state:
		current_state.process_frame(delta)


func _physics_process(delta: float) -> void:

	if current_state:
		current_state.process_physics(delta)


func _input(event: InputEvent) -> void:

	if current_state:
		current_state.handle_input(event)


func change_state(new_state_name: String) -> void:

	if !states.has(new_state_name):

		push_error("Estado '%s' não existe." % new_state_name)
		return

	var new_state: State = states[new_state_name]

	# Evita trocar para o mesmo estado
	if current_state == new_state:
		return

	if current_state:
		current_state.exit()

	previous_state = current_state
	current_state = new_state

	current_state.enter()


func is_in_state(state_name: String) -> bool:

	if current_state == null:
		return false

	return current_state.name == state_name


func return_previous_state():

	if previous_state:
		change_state(previous_state.name)


func _on_transition_requested(new_state_name: String):

	change_state(new_state_name)
