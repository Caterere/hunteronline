class_name CombatImpactEffect
extends Node

# ============================================================
# HUNTER ONLINE - COMBAT IMPACT & NEN VISUAL EFFECTS
# ============================================================
#
# Criação procedural e otimizada de partículas de impacto:
# - Slash Sparks: Faíscas cortantes angulares
# - Blunt Impact: Onda de choque circular e centelhas
# - Dust Kickup: Nuvem de poeira nos pés (esquiva, corrida, aterrissagem)
# - Nen Aura Burst: Pulso de energia expansivo (ativação de Hatsu/Nen)
# - Swing Arc: Arco visual de corte/golpe do atacante
# ============================================================

static func spawn_swing_arc(parent: Node, pos: Vector2, direction: Vector2 = Vector2.RIGHT, radius: float = 32.0, arc_color: Color = Color.WHITE, is_heavy: bool = false) -> void:
	if parent == null or not is_instance_valid(parent):
		return

	var root := _get_effect_root(parent)
	if root == null:
		return

	var arc_node := Node2D.new()
	arc_node.position = pos
	arc_node.rotation = direction.angle()
	root.add_child(arc_node)

	var arc_line := Line2D.new()
	arc_line.width = 4.5 if is_heavy else 2.5
	arc_line.default_color = arc_color
	arc_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	arc_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	var segments := 8
	var angle_span := 1.9 if is_heavy else 1.5
	var start_angle := -angle_span * 0.5
	for i in range(segments + 1):
		var frac := float(i) / float(segments)
		var a := start_angle + frac * angle_span
		var r := radius * (0.85 + 0.15 * sin(frac * PI))
		arc_line.add_point(Vector2(cos(a) * r, sin(a) * r))
	arc_node.add_child(arc_line)

	var tween := arc_node.create_tween()
	var dur := 0.15 if is_heavy else 0.11
	tween.tween_property(arc_line, "scale", Vector2(1.25, 1.25), dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(arc_line, "modulate:a", 0.0, dur)
	tween.tween_callback(arc_node.queue_free)


static func spawn_slash(parent: Node, pos: Vector2, direction: Vector2 = Vector2.RIGHT, aura_color: Color = Color.WHITE) -> void:
	if parent == null or not is_instance_valid(parent):
		return

	var root := _get_effect_root(parent)
	if root == null:
		return

	var slash_node := Node2D.new()
	slash_node.position = pos
	slash_node.rotation = direction.angle()
	root.add_child(slash_node)

	# Linha de corte estroboscópica (Line2D)
	var line := Line2D.new()
	line.width = 3.5
	line.default_color = aura_color
	line.add_point(Vector2(-14, 0))
	line.add_point(Vector2(24, 0))
	slash_node.add_child(line)

	# Partículas de faíscas direcionais
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 12
	particles.lifetime = 0.22
	particles.direction = Vector2(1, 0)
	particles.spread = 45.0
	particles.initial_velocity_min = 70.0
	particles.initial_velocity_max = 140.0
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.0
	particles.color = aura_color
	slash_node.add_child(particles)

	var tween := slash_node.create_tween()
	tween.tween_property(line, "scale", Vector2(1.5, 0.2), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "modulate:a", 0.0, 0.18)
	tween.tween_callback(slash_node.queue_free)


static func spawn_blunt_impact(parent: Node, pos: Vector2, force: float = 1.0, aura_color: Color = Color(1.0, 0.85, 0.3)) -> void:
	if parent == null or not is_instance_valid(parent):
		return

	var root := _get_effect_root(parent)
	if root == null:
		return

	var impact_node := Node2D.new()
	impact_node.position = pos
	root.add_child(impact_node)

	# Anel de onda de choque
	var shockwave := Line2D.new()
	shockwave.width = 2.0 * force
	shockwave.default_color = aura_color
	var segments := 16
	var radius := 6.0
	for i in range(segments + 1):
		var angle := (float(i) / float(segments)) * TAU
		shockwave.add_point(Vector2(cos(angle), sin(angle)) * radius)
	impact_node.add_child(shockwave)

	# Centelhas radiais
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = int(14 * clampf(force, 1.0, 2.5))
	particles.lifetime = 0.28
	particles.spread = 180.0
	particles.initial_velocity_min = 60.0 * force
	particles.initial_velocity_max = 130.0 * force
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.5
	particles.color = aura_color
	impact_node.add_child(particles)

	var tween := impact_node.create_tween()
	tween.tween_property(shockwave, "scale", Vector2(3.2 * force, 3.2 * force), 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(shockwave, "modulate:a", 0.0, 0.24)
	tween.tween_callback(impact_node.queue_free)


static func spawn_dust_kickup(parent: Node, pos: Vector2, velocity: Vector2 = Vector2.ZERO) -> void:
	if parent == null or not is_instance_valid(parent):
		return

	var root := _get_effect_root(parent)
	if root == null:
		return

	var dust := CPUParticles2D.new()
	dust.position = pos
	dust.emitting = true
	dust.one_shot = true
	dust.explosiveness = 0.85
	dust.amount = 8
	dust.lifetime = 0.35
	dust.spread = 60.0
	dust.direction = -velocity.normalized() if velocity != Vector2.ZERO else Vector2.UP
	dust.initial_velocity_min = 25.0
	dust.initial_velocity_max = 55.0
	dust.scale_amount_min = 2.0
	dust.scale_amount_max = 4.0
	dust.color = Color(0.82, 0.78, 0.72, 0.6)

	root.add_child(dust)

	var tween := dust.create_tween()
	tween.tween_property(dust, "modulate:a", 0.0, 0.35)
	tween.tween_callback(dust.queue_free)


static func spawn_aura_burst(parent: Node, pos: Vector2, aura_color: Color = Color(0.3, 0.8, 1.0)) -> void:
	if parent == null or not is_instance_valid(parent):
		return

	var root := _get_effect_root(parent)
	if root == null:
		return

	var burst_node := Node2D.new()
	burst_node.position = pos
	root.add_child(burst_node)

	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = 24
	particles.lifetime = 0.45
	particles.spread = 180.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 160.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.0
	particles.color = aura_color
	burst_node.add_child(particles)

	var tween := burst_node.create_tween()
	tween.tween_interval(0.48)
	tween.tween_callback(burst_node.queue_free)


static func _get_effect_root(node: Node) -> Node:
	if node.get_tree() == null:
		return null
	var cur = node.get_tree().current_scene
	if cur != null:
		return cur
	return node.get_tree().root
