extends Node2D


@export var duration: float = 0.6
@export var move_distance: float = 25.0


@onready var label: Label = $Label


func mostrar_dano(dano: int) -> void:
	label.text = "-" + str(dano)

	var tween := create_tween()

	var posicao_final := position + Vector2(0, -move_distance)

	tween.parallel().tween_property(
		self,
		"position",
		posicao_final,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		duration
	)

	await tween.finished

	queue_free()
