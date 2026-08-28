class_name HatsuVisual
extends Node2D

# ============================================================
# HUNTER ONLINE - HATSU VISUAL RENDERER (GENERIC & MODULAR)
# ============================================================
#
# Renderizador visual genérico para habilidades Hatsu.
# Executa formatos procedurais, núcleos de aura, brilho,
# fita de rastro suave (Line2D Trail), efeitos de cast e impacto,
# e partículas leves sem impacto na lógica ou balanceamento.
#
# ============================================================

const VisualProfile = preload("res://resource/hatsu/VisualProfile.gd")

var profile: Resource = null
var trail_line: Line2D = null
var trail_points: Array[Vector2] = []
var particles_node: CPUParticles2D = null
var time_alive: float = 0.0
var visual_rotation: float = 0.0


func _ready() -> void:
	if profile == null:
		profile = VisualProfile.new()
	_configurar_componentes()


func setup(p_profile: Resource) -> void:
	if p_profile != null:
		profile = p_profile.clone()
	else:
		profile = VisualProfile.new()
	_configurar_componentes()
	queue_redraw()


func _configurar_componentes() -> void:
	if profile == null:
		return

	# 1. Configurar Rastro (Line2D)
	if profile.trail_enabled:
		if trail_line == null or not is_instance_valid(trail_line):
			trail_line = Line2D.new()
			trail_line.name = "HatsuTrail"
			trail_line.top_level = true
			trail_line.z_index = -1
			trail_line.width = profile.trail_width * profile.visual_scale
			trail_line.default_color = profile.trail_color
			
			# Gradiente suave de transparência na cauda
			var grad := Gradient.new()
			grad.colors = PackedColorArray([
				Color(profile.trail_color.r, profile.trail_color.g, profile.trail_color.b, 0.0),
				profile.trail_color
			])
			grad.offsets = PackedFloat32Array([0.0, 1.0])
			trail_line.gradient = grad
			add_child(trail_line)
	elif trail_line != null and is_instance_valid(trail_line):
		trail_line.queue_free()
		trail_line = null

	# 2. Configurar Partículas Leves (CPUParticles2D)
	if profile.particle_enabled:
		if particles_node == null or not is_instance_valid(particles_node):
			particles_node = CPUParticles2D.new()
			particles_node.name = "HatsuParticles"
			particles_node.amount = clamp(profile.particle_amount, 2, 16)
			particles_node.lifetime = profile.particle_lifetime
			particles_node.speed_scale = 1.0
			particles_node.explosiveness = 0.1
			particles_node.randomness = 0.3
			particles_node.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
			particles_node.emission_sphere_radius = 6.0 * profile.visual_scale
			particles_node.direction = Vector2.ZERO
			particles_node.spread = 180.0
			particles_node.gravity = Vector2.ZERO
			particles_node.initial_velocity_min = profile.particle_speed * 0.5
			particles_node.initial_velocity_max = profile.particle_speed
			particles_node.scale_amount_min = profile.particle_size * 0.8
			particles_node.scale_amount_max = profile.particle_size * 1.4
			particles_node.color = profile.glow_color
			add_child(particles_node)
	elif particles_node != null and is_instance_valid(particles_node):
		particles_node.queue_free()
		particles_node = null


func _process(delta: float) -> void:
	time_alive += delta
	visual_rotation += delta * 6.0

	# Atualizar Rastro
	if profile != null and profile.trail_enabled and trail_line != null and is_instance_valid(trail_line):
		trail_points.push_front(global_position)
		if trail_points.size() > profile.trail_length:
			trail_points.pop_back()

		trail_line.clear_points()
		for pt in trail_points:
			trail_line.add_point(pt)

	queue_redraw()


func _exit_tree() -> void:
	# Garantir liberação do rastro top_level sem vazamento de memória
	if trail_line != null and is_instance_valid(trail_line):
		trail_line.queue_free()
		trail_line = null


# ============================================================
# RENDERIZAÇÃO PROCEDURAL DE FORMAS DE NEN
# ============================================================

func _draw() -> void:
	if profile == null:
		return

	var v_scale: float = profile.visual_scale
	var intensity: float = profile.glow_intensity
	var p_color: Color = profile.primary_color
	var s_color: Color = profile.secondary_color
	var c_color: Color = profile.core_color
	var g_color: Color = profile.glow_color

	# Cor do Halo com intensidade
	var halo_color := Color(g_color.r, g_color.g, g_color.b, clamp(g_color.a * intensity * 0.5, 0.0, 1.0))
	var body_color := Color(p_color.r, p_color.g, p_color.b, clamp(p_color.a, 0.0, 1.0))

	match profile.shape:
		VisualProfile.VisualShape.SPHERE:
			# Halo externo + Corpo primário + Núcleo brilhante
			draw_circle(Vector2.ZERO, 9.0 * v_scale, halo_color)
			draw_circle(Vector2.ZERO, 6.0 * v_scale, body_color)
			draw_circle(Vector2.ZERO, 2.5 * v_scale, c_color)

		VisualProfile.VisualShape.CIRCLE, VisualProfile.VisualShape.RING:
			# Anel de choque vazado
			draw_arc(Vector2.ZERO, 8.0 * v_scale, 0.0, TAU, 32, halo_color, 4.0 * v_scale)
			draw_arc(Vector2.ZERO, 6.5 * v_scale, 0.0, TAU, 32, body_color, 2.0 * v_scale)
			draw_circle(Vector2.ZERO, 2.0 * v_scale, c_color)

		VisualProfile.VisualShape.BEAM, VisualProfile.VisualShape.LINE:
			# Feixe horizontal orientado
			var len_beam: float = 30.0 * v_scale
			var start_pt := Vector2(-len_beam * 0.5, 0)
			var end_pt := Vector2(len_beam * 0.5, 0)
			draw_line(start_pt, end_pt, halo_color, 8.0 * v_scale)
			draw_line(start_pt, end_pt, body_color, 4.0 * v_scale)
			draw_line(start_pt, end_pt, c_color, 1.5 * v_scale)

		VisualProfile.VisualShape.RAY:
			# Arco elétrico com zigue-zague
			var pts: PackedVector2Array = PackedVector2Array([
				Vector2(-12, 0) * v_scale,
				Vector2(-4, -5 + sin(time_alive * 20.0) * 3) * v_scale,
				Vector2(4, 5 - sin(time_alive * 20.0) * 3) * v_scale,
				Vector2(12, 0) * v_scale
			])
			draw_polyline(pts, halo_color, 5.0 * v_scale)
			draw_polyline(pts, body_color, 2.5 * v_scale)
			draw_polyline(pts, c_color, 1.0 * v_scale)

		VisualProfile.VisualShape.BLADE:
			# Lâmina / Meia-lua cortante
			var blade_pts: PackedVector2Array = PackedVector2Array([
				Vector2(-8, -12) * v_scale,
				Vector2(6, 0) * v_scale,
				Vector2(-8, 12) * v_scale,
				Vector2(-2, 0) * v_scale
			])
			draw_colored_polygon(blade_pts, body_color)
			draw_polyline(blade_pts, halo_color, 2.0 * v_scale)
			draw_circle(Vector2(2, 0) * v_scale, 2.0 * v_scale, c_color)

		VisualProfile.VisualShape.DISC:
			# Disco rotativo
			draw_set_transform(Vector2.ZERO, visual_rotation, Vector2(1, 0.5) * v_scale)
			draw_circle(Vector2.ZERO, 8.0, halo_color)
			draw_circle(Vector2.ZERO, 6.0, body_color)
			draw_circle(Vector2.ZERO, 2.0, c_color)
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

		VisualProfile.VisualShape.CONE:
			# Cone de dispersão
			var cone_pts: PackedVector2Array = PackedVector2Array([
				Vector2.ZERO,
				Vector2(16, -9) * v_scale,
				Vector2(16, 9) * v_scale
			])
			draw_colored_polygon(cone_pts, halo_color)
			draw_polyline(cone_pts, body_color, 2.0 * v_scale)
			draw_circle(Vector2.ZERO, 3.0 * v_scale, c_color)

		VisualProfile.VisualShape.AURA, _:
			# Miasma / Aura envolvente pulsante
			var pulse: float = 1.0 + (sin(time_alive * 8.0) * 0.15)
			draw_circle(Vector2.ZERO, 10.0 * v_scale * pulse, halo_color)
			draw_circle(Vector2.ZERO, 6.5 * v_scale, body_color)
			draw_circle(Vector2.ZERO, 3.0 * v_scale, c_color)


# ============================================================
# EFEITOS INSTANTÂNEOS DE CAST E IMPACTO (ESTÁTICOS)
# ============================================================

static func spawn_cast_effect(pos: Vector2, p: Resource, parent: Node) -> Node2D:
	if parent == null or p == null or p.cast_effect == "none":
		return null

	var fx := Node2D.new()
	fx.name = "CastEffectFX"
	fx.global_position = pos
	fx.z_index = 1

	var cor_glow: Color = p.glow_color
	var cor_core: Color = p.core_color
	var v_scale: float = p.visual_scale

	fx.draw.connect(func():
		fx.draw_circle(Vector2.ZERO, 14.0 * v_scale, Color(cor_glow.r, cor_glow.g, cor_glow.b, 0.6))
		fx.draw_circle(Vector2.ZERO, 7.0 * v_scale, cor_core)
	)

	parent.add_child(fx)
	fx.queue_redraw()

	var tween := fx.create_tween()
	tween.tween_property(fx, "scale", Vector2(1.8, 1.8), 0.15)
	tween.parallel().tween_property(fx, "modulate:a", 0.0, 0.15)
	tween.tween_callback(fx.queue_free)
	return fx


static func spawn_impact_effect(pos: Vector2, p: Resource, parent: Node) -> Node2D:
	if parent == null or p == null or p.impact_effect == "none":
		return null

	var fx := Node2D.new()
	fx.name = "ImpactEffectFX"
	fx.global_position = pos
	fx.z_index = 1

	var cor_prim: Color = p.primary_color
	var cor_glow: Color = p.glow_color
	var v_scale: float = p.visual_scale

	fx.draw.connect(func():
		fx.draw_arc(Vector2.ZERO, 18.0 * v_scale, 0.0, TAU, 32, cor_glow, 3.0)
		fx.draw_circle(Vector2.ZERO, 8.0 * v_scale, Color(cor_prim.r, cor_prim.g, cor_prim.b, 0.7))
	)

	parent.add_child(fx)
	fx.queue_redraw()

	var tween := fx.create_tween()
	tween.tween_property(fx, "scale", Vector2(2.2, 2.2), 0.22)
	tween.parallel().tween_property(fx, "modulate:a", 0.0, 0.22)
	tween.tween_callback(fx.queue_free)
	return fx