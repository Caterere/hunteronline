class_name HatsuProceduralFxKit
extends RefCounted

# ============================================================
# HUNTER ONLINE — FX PROCEDURAL DE HATSU (código only)
# ============================================================
# Efeitos básicos bem feitos: cast, slash, impacto, névoa,
# muralha, garras, emissão. Sem PixelLab / PNG obrigatório.
# ============================================================


static func play_estilo(parent: Node, pos: Vector2, dir: Vector2, estilo: int, cor: Color = Color(0.45, 0.85, 1.0), scale: float = 1.0) -> void:
	match estilo:
		HatsuData.EstiloVisual.CHAMAS_FOGO:
			cast_flash(parent, pos, Color(1.0, 0.45, 0.15), scale)
			impact_ring(parent, pos, Color(1.0, 0.55, 0.2), 42.0 * scale)
			ember_sparks(parent, pos, Color(1.0, 0.7, 0.25), 14)
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
			cast_flash(parent, pos, Color(0.65, 0.85, 1.0), scale)
			lightning_arcs(parent, pos, dir, Color(0.7, 0.9, 1.0), scale)
		HatsuData.EstiloVisual.LAMINA_CORTE:
			slash_arc(parent, pos, dir, Color(0.9, 0.95, 1.0), 36.0 * scale, true)
			impact_ring(parent, pos + dir * 18.0, Color(0.85, 0.9, 1.0), 22.0 * scale)
		HatsuData.EstiloVisual.SHURIKEN_GIRATORIO:
			cast_flash(parent, pos, cor, scale * 0.9)
			spin_star(parent, pos, cor, scale)
		HatsuData.EstiloVisual.ANEIS_IMPACTO:
			impact_ring(parent, pos, cor, 55.0 * scale)
			impact_ring(parent, pos, Color(cor.r, cor.g, cor.b, 0.7), 32.0 * scale)
			ember_sparks(parent, pos, cor, 10)
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS:
			mist_cloud(parent, pos, Color(0.35, 0.15, 0.45), scale)
			cast_flash(parent, pos, Color(0.5, 0.25, 0.65), scale * 0.7)
		HatsuData.EstiloVisual.DRAGAO_SERPENTE:
			cast_flash(parent, pos, Color(1.0, 0.85, 0.25), scale)
			serpent_wave(parent, pos, dir, Color(1.0, 0.82, 0.2), scale)
		_:
			# PURO_PULSANTE
			cast_flash(parent, pos, cor, scale)
			aura_orb(parent, pos, cor, scale)
			impact_ring(parent, pos, cor, 28.0 * scale)


static func play_for_hatsu(parent: Node, pos: Vector2, dir: Vector2, hatsu: HatsuData, scale: float = 1.0) -> void:
	if hatsu == null:
		cast_flash(parent, pos, Color(0.45, 0.85, 1.0), scale)
		return
	var cor: Color = hatsu.cor_aura if hatsu.cor_aura.a > 0.05 else Color(0.45, 0.85, 1.0)
	play_estilo(parent, pos, dir, int(hatsu.estilo_visual), cor, scale)
	# Camada por categoria Nen (leitura HxH)
	match hatsu.categoria:
		HatsuData.Categoria.INTENSIFICACAO:
			slash_arc(parent, pos, dir, cor, 30.0 * scale, true)
		HatsuData.Categoria.CONJURACAO:
			shield_wall(parent, pos, dir, cor, scale)
		HatsuData.Categoria.EMISSAO:
			emission_bolts(parent, pos, dir, cor, 3, scale)
		HatsuData.Categoria.MANIPULACAO:
			mist_cloud(parent, pos, cor.darkened(0.2), scale * 0.9)
		HatsuData.Categoria.TRANSFORMACAO:
			ember_sparks(parent, pos, cor, 12)
		_:
			pass


static func play_named(parent: Node, pos: Vector2, dir: Vector2, hatsu_nome: String, cor: Color = Color(0.5, 0.8, 1.0)) -> void:
	var n := hatsu_nome.to_lower()
	if "muralha" in n or "selo" in n:
		shield_wall(parent, pos, dir, Color(0.7, 0.55, 0.35), 1.15)
		impact_ring(parent, pos, Color(0.75, 0.6, 0.35), 70.0)
	elif "uivo" in n:
		impact_ring(parent, pos, Color(0.55, 0.35, 0.95), 110.0)
		mist_cloud(parent, pos, Color(0.45, 0.25, 0.75), 1.1)
	elif "garras" in n or "quimera" in n:
		claw_marks(parent, pos, dir, Color(0.95, 0.35, 0.28))
		slash_arc(parent, pos, dir, Color(1.0, 0.45, 0.3), 38.0, true)
	elif "sombra" in n or "drenante" in n:
		mist_cloud(parent, pos, Color(0.3, 0.08, 0.4), 1.0)
		cast_flash(parent, pos, Color(0.45, 0.15, 0.55), 0.9)
		emission_bolts(parent, pos, dir, Color(0.4, 0.15, 0.5), 1, 0.85)
	elif "ko" in n or "shu" in n or "ren" in n:
		cast_flash(parent, pos, Color(1.0, 0.8, 0.25), 1.2)
		impact_ring(parent, pos, Color(1.0, 0.75, 0.2), 48.0)
		slash_arc(parent, pos, dir, Color(1.0, 0.9, 0.4), 34.0, true)
	elif "flecha" in n or "disparo" in n or "rajada" in n:
		emission_bolts(parent, pos, dir, Color(0.4, 0.85, 1.0), 2, 1.0)
		cast_flash(parent, pos, Color(0.45, 0.9, 1.0), 0.8)
	elif "névoa" in n or "nevoa" in n or "lodo" in n or "presas" in n or "tóx" in n:
		mist_cloud(parent, pos, Color(0.45, 0.85, 0.35), 1.15)
		ember_sparks(parent, pos, Color(0.55, 0.95, 0.4), 10)
	elif "comando" in n or "besta" in n or "trupe" in n or "guarda" in n:
		cast_flash(parent, pos, Color(0.95, 0.85, 0.35), 1.2)
		impact_ring(parent, pos, Color(0.95, 0.8, 0.3), 95.0)
		aura_orb(parent, pos, Color(1.0, 0.9, 0.4), 1.2)
	elif "bungee" in n or "hisoka" in n:
		cast_flash(parent, pos, Color(1.0, 0.35, 0.75), 1.0)
		serpent_wave(parent, pos, dir, Color(1.0, 0.4, 0.75), 0.9)
	elif "flower" in n or "bomb" in n:
		impact_ring(parent, pos, Color(1.0, 0.45, 0.15), 55.0)
		ember_sparks(parent, pos, Color(1.0, 0.6, 0.2), 16)
	else:
		cast_flash(parent, pos, cor, 1.0)
		aura_orb(parent, pos, cor, 1.0)


# -------------------- primitives --------------------

static func cast_flash(parent: Node, pos: Vector2, cor: Color, scale: float = 1.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	var n := _FxNode.new()
	n.mode = "cast"
	n.cor = cor
	n.scale_fx = scale
	n.duration = 0.32
	n.z_index = 22
	_attach(root, n, pos)


static func impact_ring(parent: Node, pos: Vector2, cor: Color, raio: float = 40.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	# Reusa explosão já polida + anel custom
	var boom := HatsuAreaExplosionNode.new()
	boom.setup(raio, cor, Color(1, 1, 1, 0.95))
	_attach(root, boom, pos)
	var n := _FxNode.new()
	n.mode = "ring"
	n.cor = cor
	n.radius = raio
	n.duration = 0.38
	n.z_index = 21
	_attach(root, n, pos)


static func slash_arc(parent: Node, pos: Vector2, dir: Vector2, cor: Color, radius: float = 34.0, heavy: bool = false) -> void:
	CombatImpactEffect.spawn_swing_arc(parent, pos, dir if dir != Vector2.ZERO else Vector2.RIGHT, radius, cor, heavy)
	CombatImpactEffect.spawn_slash(parent, pos, dir if dir != Vector2.ZERO else Vector2.RIGHT, cor)


static func aura_orb(parent: Node, pos: Vector2, cor: Color, scale: float = 1.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	var n := _FxNode.new()
	n.mode = "orb"
	n.cor = cor
	n.scale_fx = scale
	n.duration = 0.45
	n.z_index = 20
	_attach(root, n, pos)


static func mist_cloud(parent: Node, pos: Vector2, cor: Color, scale: float = 1.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	var n := _FxNode.new()
	n.mode = "mist"
	n.cor = cor
	n.scale_fx = scale
	n.duration = 0.7
	n.z_index = 18
	_attach(root, n, pos)
	# Partículas suaves
	var p := CPUParticles2D.new()
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 0.55
	p.amount = 18
	p.lifetime = 0.55
	p.spread = 180.0
	p.initial_velocity_min = 18.0 * scale
	p.initial_velocity_max = 48.0 * scale
	p.scale_amount_min = 2.5 * scale
	p.scale_amount_max = 5.5 * scale
	p.color = Color(cor.r, cor.g, cor.b, 0.55)
	p.gravity = Vector2(0, -12)
	root.add_child(p)
	p.global_position = pos
	var tw := p.create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(p.queue_free)


static func shield_wall(parent: Node, pos: Vector2, dir: Vector2, cor: Color, scale: float = 1.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	var n := _FxNode.new()
	n.mode = "shield"
	n.cor = cor
	n.dir = dir if dir != Vector2.ZERO else Vector2.RIGHT
	n.scale_fx = scale
	n.duration = 0.55
	n.z_index = 19
	_attach(root, n, pos)


static func claw_marks(parent: Node, pos: Vector2, dir: Vector2, cor: Color) -> void:
	var root := _root(parent)
	if root == null:
		return
	var n := _FxNode.new()
	n.mode = "claws"
	n.cor = cor
	n.dir = dir if dir != Vector2.ZERO else Vector2.RIGHT
	n.duration = 0.28
	n.z_index = 23
	_attach(root, n, pos)


static func emission_bolts(parent: Node, pos: Vector2, dir: Vector2, cor: Color, count: int = 2, scale: float = 1.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	var base := dir if dir != Vector2.ZERO else Vector2.RIGHT
	for i in range(maxi(1, count)):
		var ang := base.angle() + (float(i) - float(count - 1) * 0.5) * 0.18
		var d := Vector2.from_angle(ang)
		var h := HatsuData.new()
		h.nome = "Aura Bolt"
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = cor
		var proj := HatsuProjectileNode.new()
		proj.setup(pos, d, 90.0 * scale, 260.0, 0, cor, null, h)
		# Visual only — sem dano (dono null / dano 0)
		proj.dano = 0
		root.add_child(proj)
		proj.global_position = pos


static func ember_sparks(parent: Node, pos: Vector2, cor: Color, amount: int = 12) -> void:
	var root := _root(parent)
	if root == null:
		return
	var p := CPUParticles2D.new()
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = clampi(amount, 4, 24)
	p.lifetime = 0.35
	p.spread = 180.0
	p.initial_velocity_min = 50.0
	p.initial_velocity_max = 120.0
	p.scale_amount_min = 1.2
	p.scale_amount_max = 2.8
	p.color = cor
	p.gravity = Vector2(0, 40)
	root.add_child(p)
	p.global_position = pos
	var tw := p.create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(p.queue_free)


static func lightning_arcs(parent: Node, pos: Vector2, dir: Vector2, cor: Color, scale: float = 1.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	var n := _FxNode.new()
	n.mode = "lightning"
	n.cor = cor
	n.dir = dir if dir != Vector2.ZERO else Vector2.RIGHT
	n.scale_fx = scale
	n.duration = 0.28
	n.z_index = 24
	_attach(root, n, pos)


static func spin_star(parent: Node, pos: Vector2, cor: Color, scale: float = 1.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	var n := _FxNode.new()
	n.mode = "star"
	n.cor = cor
	n.scale_fx = scale
	n.duration = 0.4
	n.z_index = 22
	_attach(root, n, pos)


static func serpent_wave(parent: Node, pos: Vector2, dir: Vector2, cor: Color, scale: float = 1.0) -> void:
	var root := _root(parent)
	if root == null:
		return
	var n := _FxNode.new()
	n.mode = "serpent"
	n.cor = cor
	n.dir = dir if dir != Vector2.ZERO else Vector2.RIGHT
	n.scale_fx = scale
	n.duration = 0.5
	n.z_index = 21
	_attach(root, n, pos)


static func _root(parent: Node) -> Node:
	if parent == null or not is_instance_valid(parent):
		return null
	# Em cenas de teste / demos, preferir o próprio parent Node2D
	if parent is Node2D or parent is Control:
		return parent
	if parent.get_tree() == null:
		return parent
	var cur = parent.get_tree().current_scene
	if cur != null:
		return cur
	return parent.get_tree().root


static func _attach(root: Node, node: Node2D, pos: Vector2) -> void:
	root.add_child(node)
	node.global_position = pos


## Nó de desenho procedural compartilhado.
class _FxNode extends Node2D:
	var mode: String = "cast"
	var cor: Color = Color(0.45, 0.85, 1.0)
	var dir: Vector2 = Vector2.RIGHT
	var scale_fx: float = 1.0
	var radius: float = 40.0
	var duration: float = 0.4
	var t: float = 0.0

	func _process(delta: float) -> void:
		t += delta
		if t >= duration:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var p: float = clampf(t / maxf(0.001, duration), 0.0, 1.0)
		var a: float = 1.0 - p
		match mode:
			"cast":
				_draw_cast(p, a)
			"orb":
				_draw_orb(p, a)
			"ring":
				_draw_ring(p, a)
			"mist":
				_draw_mist(p, a)
			"shield":
				_draw_shield(p, a)
			"claws":
				_draw_claws(p, a)
			"lightning":
				_draw_lightning(p, a)
			"star":
				_draw_star(p, a)
			"serpent":
				_draw_serpent(p, a)

	func _draw_cast(p: float, a: float) -> void:
		var r := (8.0 + 28.0 * ease(p, 0.35)) * scale_fx
		draw_circle(Vector2.ZERO, r * 0.35, Color(1, 1, 1, a * 0.85))
		draw_circle(Vector2.ZERO, r, Color(cor.r, cor.g, cor.b, a * 0.35))
		draw_arc(Vector2.ZERO, r * 1.15, 0, TAU, 28, Color(cor.r, cor.g, cor.b, a * 0.9), 2.2)
		# cruz de aura
		var arm := r * 0.9
		draw_line(Vector2(-arm, 0), Vector2(arm, 0), Color(cor.r, cor.g, cor.b, a * 0.55), 1.5)
		draw_line(Vector2(0, -arm), Vector2(0, arm), Color(cor.r, cor.g, cor.b, a * 0.55), 1.5)

	func _draw_orb(p: float, a: float) -> void:
		var pulse := 1.0 + 0.15 * sin(t * 18.0)
		var r := 12.0 * scale_fx * pulse * (1.0 - p * 0.3)
		draw_circle(Vector2.ZERO, r * 1.6, Color(cor.r, cor.g, cor.b, a * 0.2))
		draw_circle(Vector2.ZERO, r, Color(cor.r, cor.g, cor.b, a * 0.7))
		draw_circle(Vector2.ZERO, r * 0.45, Color(1, 1, 1, a * 0.9))

	func _draw_ring(p: float, a: float) -> void:
		var r := lerpf(6.0, radius, ease(p, 0.4))
		draw_arc(Vector2.ZERO, r, 0, TAU, 36, Color(cor.r, cor.g, cor.b, a * 0.95), 2.8)
		draw_arc(Vector2.ZERO, r * 0.72, 0, TAU, 28, Color(1, 1, 1, a * 0.45), 1.4)

	func _draw_mist(p: float, a: float) -> void:
		for i in range(6):
			var ang := float(i) / 6.0 * TAU + t * 1.5
			var dist := (10.0 + 22.0 * p) * scale_fx
			var cpos := Vector2(cos(ang), sin(ang)) * dist
			var rr := (8.0 + float(i % 3) * 3.0) * scale_fx * (1.0 - p * 0.4)
			draw_circle(cpos, rr, Color(cor.r, cor.g, cor.b, a * 0.28))
		draw_circle(Vector2.ZERO, 14.0 * scale_fx, Color(cor.r, cor.g, cor.b, a * 0.22))

	func _draw_shield(p: float, a: float) -> void:
		var forward := dir.normalized()
		var side := Vector2(-forward.y, forward.x)
		var w := 28.0 * scale_fx
		var h := 36.0 * scale_fx * (0.7 + 0.3 * (1.0 - p))
		var pts := PackedVector2Array([
			forward * 8.0 * scale_fx + side * (-w),
			forward * 8.0 * scale_fx + side * w,
			forward * (8.0 * scale_fx + h * 0.15) + side * (w * 0.75),
			forward * (8.0 * scale_fx + h * 0.15) + side * (-w * 0.75),
		])
		draw_colored_polygon(pts, Color(cor.r, cor.g, cor.b, a * 0.35))
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color(cor.r, cor.g, cor.b, a * 0.95), 2.4, true)
		draw_arc(forward * 10.0 * scale_fx, 16.0 * scale_fx, 0, TAU, 20, Color(1, 1, 1, a * 0.5), 1.5)

	func _draw_claws(p: float, a: float) -> void:
		var forward := dir.normalized()
		var side := Vector2(-forward.y, forward.x)
		for i in range(3):
			var off := (float(i) - 1.0) * 7.5
			var start := side * off - forward * 6.0
			var end := side * off * 0.6 + forward * (28.0 + 10.0 * (1.0 - p))
			draw_line(start, end, Color(cor.r, cor.g, cor.b, a), 2.6)
			draw_line(start + side * 1.2, end + side * 0.5, Color(1, 1, 1, a * 0.55), 1.1)

	func _draw_lightning(p: float, a: float) -> void:
		var forward := dir.normalized()
		var tip := forward * (40.0 * scale_fx)
		var mid1 := forward * 14.0 + Vector2(-forward.y, forward.x) * 8.0
		var mid2 := forward * 26.0 + Vector2(-forward.y, forward.x) * -7.0
		draw_line(Vector2.ZERO, mid1, Color(cor.r, cor.g, cor.b, a), 2.2)
		draw_line(mid1, mid2, Color(1, 1, 1, a), 1.8)
		draw_line(mid2, tip, Color(cor.r, cor.g, cor.b, a), 2.0)
		draw_circle(tip, 3.0, Color(1, 1, 1, a))

	func _draw_star(p: float, a: float) -> void:
		var rot := t * 14.0
		var r := 14.0 * scale_fx * (1.0 + 0.2 * sin(t * 20.0))
		for i in range(4):
			var ang := rot + float(i) * PI * 0.5
			var tip := Vector2(cos(ang), sin(ang)) * r
			draw_line(-tip * 0.3, tip, Color(cor.r, cor.g, cor.b, a), 2.0)
		draw_circle(Vector2.ZERO, 4.0, Color(1, 1, 1, a * 0.9))

	func _draw_serpent(p: float, a: float) -> void:
		var forward := dir.normalized()
		var side := Vector2(-forward.y, forward.x)
		var pts := PackedVector2Array()
		for i in range(8):
			var frac := float(i) / 7.0
			var along := forward * (frac * 48.0 * scale_fx)
			var wave := side * sin(frac * PI * 2.0 + t * 10.0) * (8.0 * scale_fx)
			pts.append(along + wave)
		if pts.size() >= 2:
			draw_polyline(pts, Color(cor.r, cor.g, cor.b, a * 0.95), 3.0, true)
			draw_polyline(pts, Color(1, 1, 1, a * 0.4), 1.2, true)
		draw_circle(pts[pts.size() - 1] if pts.size() > 0 else Vector2.ZERO, 4.5, Color(1, 1, 1, a))
