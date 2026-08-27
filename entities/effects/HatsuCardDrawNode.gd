class_name HatsuCardDrawNode
extends Node2D

# ============================================================
# HUNTER ONLINE - HATSU CARD DRAW EFFECT (BARALHO DE NEN)
# ============================================================

var target_player: CharacterBody2D = null
var naipe_texto: String = "♠ Espadas"
var tempo: float = 0.0
var duracao_total: float = 1.0


func setup(player: CharacterBody2D, naipe: String) -> void:
	target_player = player
	naipe_texto = naipe
	z_index = 10


func _process(delta: float) -> void:
	if target_player == null or not is_instance_valid(target_player):
		queue_free()
		return

	global_position = target_player.global_position + Vector2(0, -30)
	tempo += delta
	if tempo >= duracao_total:
		queue_free()

	queue_redraw()


func _draw() -> void:
	# Carta retangular flutuante
	var cor_fundo := Color(0.98, 0.98, 0.98, 0.95)
	draw_rect(Rect2(-7, -10, 14, 20), cor_fundo, true)
	draw_rect(Rect2(-7, -10, 14, 20), Color(0.2, 0.4, 0.9, 1.0), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(-5, 3), naipe_texto.substr(0, 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.RED if ("♥" in naipe_texto or "♦" in naipe_texto) else Color.BLACK)
