class_name GodspeedElectricEffect
extends Node2D

# ============================================================
# HUNTER ONLINE - GODSPEED (KANMURU) ELECTRIC AURA EFFECT
# ============================================================
#
# Cria uma aura elétrica com raios e faíscas dinâmicas em volta
# do personagem durante a ativação do Godspeed / Kanmuru do Killua.
# Cria também efeito de rastro/afterimage ao se movimentar.
#
# ============================================================

var duracao_total: float = 5.0
var duracao_restante: float = 5.0
var target_player: CharacterBody2D = null

var lightning_points: Array[PackedVector2Array] = []
var spark_timer: float = 0.0
var afterimage_timer: float = 0.0


func setup(player_body: CharacterBody2D, duracao: float = 5.0) -> void:
	target_player = player_body
	duracao_total = duracao
	duracao_restante = duracao
	z_index = 5


func _ready() -> void:
	_gerar_raios()


func _process(delta: float) -> void:
	if target_player == null or not is_instance_valid(target_player):
		queue_free()
		return

	global_position = target_player.global_position

	duracao_restante -= delta
	if duracao_restante <= 0.0:
		queue_free()
		return

	# Regenerar faíscas elétricas dinamicamente
	spark_timer += delta
	if spark_timer >= 0.04:
		spark_timer = 0.0
		_gerar_raios()
		queue_redraw()

	# Gerar rastro de velocidade (Afterimage) quando em movimento
	if target_player.velocity.length() > 20.0:
		afterimage_timer += delta
		if afterimage_timer >= 0.06:
			afterimage_timer = 0.0
			_criar_afterimage()


func _gerar_raios() -> void:
	lightning_points.clear()
	var num_arcs := randi_range(4, 7)
	for i in range(num_arcs):
		var angle := randf_range(0.0, TAU)
		var start_pos := Vector2(cos(angle), sin(angle)) * randf_range(4.0, 10.0)
		var end_pos := Vector2(cos(angle), sin(angle)) * randf_range(16.0, 26.0)
		
		# Ponto intermediário com desvio de raio
		var mid_pos := (start_pos + end_pos) * 0.5 + Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
		
		var line := PackedVector2Array([start_pos, mid_pos, end_pos])
		lightning_points.append(line)


func _draw() -> void:
	# Círculo de pulso elétrico
	var alpha_glow := randf_range(0.2, 0.45)
	draw_circle(Vector2(0, -6), 14.0 + randf_range(-2.0, 2.0), Color(0.1, 0.7, 1.0, alpha_glow))

	# Desenhar arcos de raios
	for line in lightning_points:
		# Linha de fundo azul ciano
		draw_polyline(line, Color(0.2, 0.8, 1.0, 0.9), 1.5)
		# Centro branco brilhante
		draw_polyline(line, Color(1.0, 1.0, 1.0, 1.0), 0.8)


func _criar_afterimage() -> void:
	if target_player == null:
		return

	var sprite_player = target_player.get_node_or_null("Sprite2D") as Sprite2D
	if sprite_player == null or sprite_player.texture == null:
		return

	var ghost := Sprite2D.new()
	ghost.texture = sprite_player.texture
	ghost.hframes = sprite_player.hframes
	ghost.vframes = sprite_player.vframes
	ghost.frame = sprite_player.frame
	ghost.flip_h = sprite_player.flip_h
	ghost.position = sprite_player.position
	ghost.global_position = target_player.global_position + sprite_player.position
	ghost.modulate = Color(0.3, 0.8, 1.0, 0.6) # Fantasma elétrico ciano
	ghost.z_index = target_player.z_index - 1

	target_player.get_parent().add_child(ghost)

	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tween.tween_callback(ghost.queue_free)
