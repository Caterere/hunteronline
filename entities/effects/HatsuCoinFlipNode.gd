class_name HatsuCoinFlipNode
extends Node2D

# ============================================================
# HUNTER ONLINE - HATSU COIN FLIP EFFECT (MOEDA DE NEN)
# ============================================================

var target_player: CharacterBody2D = null
var resultado_texto: String = "CARA"
var tempo: float = 0.0
var duracao_total: float = 1.0


func setup(player: CharacterBody2D, resultado: String) -> void:
	target_player = player
	resultado_texto = resultado
	z_index = 10


func _process(delta: float) -> void:
	if target_player == null or not is_instance_valid(target_player):
		queue_free()
		return

	var y_offset: float = -28.0 - (10.0 * sin(tempo * PI / duracao_total))
	global_position = target_player.global_position + Vector2(0, y_offset)
	tempo += delta
	if tempo >= duracao_total:
		queue_free()

	queue_redraw()


func _draw() -> void:
	# Moeda dourada girando
	var scale_x: float = abs(cos(tempo * 12.0))
	var cor_ouro := Color(1.0, 0.85, 0.2, 0.95)
	draw_ellipse(Vector2.ZERO, 7.0 * max(0.2, scale_x), 7.0, cor_ouro, true)
	draw_ellipse(Vector2.ZERO, 7.0 * max(0.2, scale_x), 7.0, Color(0.8, 0.5, 0.1, 1.0), false, 1.0)
	if tempo > 0.5:
		draw_string(ThemeDB.fallback_font, Vector2(-4, 3), resultado_texto.substr(0, 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color.WHITE)
