class_name State extends Node

signal transition_requested(new_state_name: String)

var state_machine: StateMachine
var player: CharacterBody2D

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_frame(delta: float) -> void:
	pass

func process_physics(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
func get_state_name() -> String:
	return name
