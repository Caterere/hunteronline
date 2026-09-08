class_name DashDustPuff
extends Node2D

# ============================================================
# HUNTER ONLINE - EFEITO DE POEIRA DE PÉS (ATTACK LUNGE / DASH)
# ============================================================
#
# Cria pequenos puffs de poeira nos pés do personagem ao realizar
# o dash de ataque ou a esquiva, aumentando a sensação de tração e peso.
# ============================================================

var duracao: float = 0.20
var tempo_vida: float = 0.0
var sprite: Sprite2D = null


func setup(pos: Vector2, dir: Vector2) -> void:
	global_position = pos + Vector2(0, 3) # Pés do personagem
	z_index = -1 # Logo abaixo do sprite do jogador

	sprite = Sprite2D.new()
	var tex = load("res://assets/sprites/particles/dust_particles_01.png") as Texture2D
	if tex:
		sprite.texture = tex
		sprite.hframes = 4
		sprite.vframes = 1
		sprite.frame = 0
	sprite.scale = Vector2(0.85, 0.85)
	if dir != Vector2.ZERO:
		sprite.rotation = (-dir).angle()
	add_child(sprite)


func _process(delta: float) -> void:
	tempo_vida += delta
	if tempo_vida >= duracao:
		queue_free()
		return

	var t: float = tempo_vida / duracao
	if sprite != null:
		var frame_idx = clamp(int(t * 4.0), 0, 3)
		sprite.frame = frame_idx
		sprite.scale = Vector2.ONE * lerpf(0.75, 1.1, t)
		sprite.modulate = Color(1.0, 1.0, 1.0, (1.0 - t) * 0.85)
