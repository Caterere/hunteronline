class_name HatsuDiceRollNode
extends Node2D

# ============================================================
# HUNTER ONLINE - HATSU DICE ROLL EFFECT (RISKY DICE / DADO NEN)
# ============================================================

var target_player: CharacterBody2D = null
var resultado_face: int = 6
var tempo: float = 0.0
var finalizou: bool = false
var duracao_total: float = 1.0


func setup(player: CharacterBody2D, face: int) -> void:
	target_player = player
	resultado_face = face
	z_index = 10


func _process(delta: float) -> void:
	if target_player == null or not is_instance_valid(target_player):
		queue_free()
		return

	global_position = target_player.global_position + Vector2(0, -32)
	tempo += delta

	if tempo >= 0.4 and not finalizou:
		finalizou = true

	if tempo >= duracao_total:
		queue_free()

	queue_redraw()


func _draw() -> void:
	# Desenho do Dado cúbico com rotação
	var cor_fundo := Color(0.95, 0.95, 1.0, 0.95)
	var cor_borda := Color(0.2, 0.2, 0.3, 1.0)
	var face_mostrada: int = resultado_face if finalizou else randi_range(1, 6)

	draw_rect(Rect2(-8, -8, 16, 16), cor_fundo, true)
	draw_rect(Rect2(-8, -8, 16, 16), cor_borda, false, 1.0)

	var cor_ponto := Color(0.8, 0.1, 0.1, 1.0) if face_mostrada == 1 else Color(0.1, 0.1, 0.2, 1.0)

	match face_mostrada:
		1:
			draw_circle(Vector2.ZERO, 3.0, Color.RED)
		2:
			draw_circle(Vector2(-4, -4), 2.0, cor_ponto)
			draw_circle(Vector2(4, 4), 2.0, cor_ponto)
		3:
			draw_circle(Vector2(-4, -4), 2.0, cor_ponto)
			draw_circle(Vector2.ZERO, 2.0, cor_ponto)
			draw_circle(Vector2(4, 4), 2.0, cor_ponto)
		4:
			draw_circle(Vector2(-4, -4), 2.0, cor_ponto)
			draw_circle(Vector2(4, -4), 2.0, cor_ponto)
			draw_circle(Vector2(-4, 4), 2.0, cor_ponto)
			draw_circle(Vector2(4, 4), 2.0, cor_ponto)
		5:
			draw_circle(Vector2(-4, -4), 2.0, cor_ponto)
			draw_circle(Vector2(4, -4), 2.0, cor_ponto)
			draw_circle(Vector2.ZERO, 2.0, cor_ponto)
			draw_circle(Vector2(-4, 4), 2.0, cor_ponto)
			draw_circle(Vector2(4, 4), 2.0, cor_ponto)
		6:
			draw_circle(Vector2(-4, -5), 2.0, Color(0.2, 0.8, 1.0))
			draw_circle(Vector2(4, -5), 2.0, Color(0.2, 0.8, 1.0))
			draw_circle(Vector2(-4, 0), 2.0, Color(0.2, 0.8, 1.0))
			draw_circle(Vector2(4, 0), 2.0, Color(0.2, 0.8, 1.0))
			draw_circle(Vector2(-4, 5), 2.0, Color(0.2, 0.8, 1.0))
			draw_circle(Vector2(4, 5), 2.0, Color(0.2, 0.8, 1.0))
