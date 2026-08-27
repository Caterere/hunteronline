class_name GuanyinBodhisattvaEffect
extends Node2D

# ============================================================
# HUNTER ONLINE - 100-TYPE GUANYIN BODHISATTVA (NETERO)
# ============================================================
#
# Manifesta a estátua dourada da Deusa Guanyin atrás do personagem.
# Enquanto ativa (12s), desfere ataques ultrassônicos de palmas douradas
# com alcance por toda a tela frontal.
#
# ============================================================

var target_player: CharacterBody2D = null
var duracao_total: float = 12.0
var duracao_restante: float = 12.0
var palm_attack_timer: float = 0.0


func setup(player_body: CharacterBody2D, duracao: float = 12.0) -> void:
	target_player = player_body
	duracao_total = duracao
	duracao_restante = duracao
	z_index = 6


func _process(delta: float) -> void:
	if target_player == null or not is_instance_valid(target_player):
		queue_free()
		return

	global_position = target_player.global_position

	duracao_restante -= delta
	if duracao_restante <= 0.0:
		queue_free()
		return

	# Ataques automáticos de palmas douradas contra inimigos no alcance
	palm_attack_timer += delta
	if palm_attack_timer >= 0.35: # Ritmo ultrassônico (várias palmas)
		palm_attack_timer = 0.0
		_desferir_palma_guanyin()
		queue_redraw()


func _desferir_palma_guanyin() -> void:
	if target_player == null:
		return

	var enemies = target_player.get_tree().get_nodes_in_group("enemy")
	var alvo_proximo: CharacterBody2D = null
	var menor_dist: float = 240.0

	for e in enemies:
		if e is CharacterBody2D and is_instance_valid(e):
			var d: float = target_player.global_position.distance_to(e.global_position)
			if d < menor_dist:
				menor_dist = d
				alvo_proximo = e

	if alvo_proximo != null:
		var dir: Vector2 = (alvo_proximo.global_position - target_player.global_position).normalized()
		var dano_palma: int = int(PlayerData.attributes.get("forca", 20) * 1.6) + 40
		var enemy_sys = alvo_proximo.get_node_or_null("EnemySystem")
		if enemy_sys != null:
			enemy_sys.take_damage(dano_palma, dir, 220.0, target_player)
			print("[Guanyin Bodhisattva] Palma Esmagadora em ", alvo_proximo.name, " Dano: ", dano_palma)


func _draw() -> void:
	# Resplendor e estátua dourada da Deusa Guanyin atrás do usuário
	var alpha_glow := randf_range(0.3, 0.6)
	
	# Aura dourada divina
	draw_circle(Vector2(0, -18), 24.0, Color(1.0, 0.85, 0.2, alpha_glow * 0.5))
	draw_circle(Vector2(0, -18), 16.0, Color(1.0, 0.95, 0.4, alpha_glow * 0.7))

	# Múltiplos braços dourados abertos em leque
	var num_bracos := 12
	for i in range(num_bracos):
		var angle := -PI * 0.8 + (i * (PI * 1.6 / (num_bracos - 1)))
		var arm_start := Vector2(0, -18)
		var arm_end := arm_start + Vector2(cos(angle), sin(angle)) * 28.0
		draw_line(arm_start, arm_end, Color(1.0, 0.8, 0.2, 0.85), 2.0)
		draw_circle(arm_end, 3.5, Color(1.0, 0.95, 0.5, 0.9)) # Mão / Palma dourada
