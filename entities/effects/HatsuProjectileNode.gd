class_name HatsuProjectileNode
extends Area2D

# ============================================================
# HUNTER ONLINE - PROCEDURAL HATSU PROJECTILE NODE
# ============================================================
#
# Renderização 100% procedural (sem necessidade de texturas PNG)
# com suporte a 8 Estilos Visuais de Nen, cores primárias/secundárias,
# rotação, cauda de partículas e deformações dinâmicas em 60fps.
#
# ============================================================

var direcao: Vector2 = Vector2.RIGHT
var velocidade: float = 320.0
var alcance_max: float = 200.0
var distancia_percorrida: float = 0.0
var dano: int = 25
var cor_primaria: Color = Color(0.3, 0.7, 1.0, 1.0)
var cor_secundaria: Color = Color(1.0, 1.0, 1.0, 0.9)
var estilo_visual: HatsuData.EstiloVisual = HatsuData.EstiloVisual.PURO_PULSANTE
var dono: Node2D = null
var hatsu: HatsuData = null

var tempo_vivo: float = 0.0
var rastro_posicoes: Array[Vector2] = []
var max_rastro: int = 8
var rot_angle: float = 0.0


func setup(
	pos_ou_dir: Variant,
	param2: Variant = null,
	param3: Variant = null,
	param4: Variant = null,
	param5: Variant = null,
	param6: Variant = null,
	param7: Variant = null,
	param8: Variant = null
) -> void:
	# Suporte flexível para as duas assinaturas existentes no projeto
	if pos_ou_dir is Vector2 and param2 is Vector2:
		# Assinatura: (pos_inicial, dir, alcance, vel, dano, cor, criador, hatsu_ref)
		global_position = pos_ou_dir
		direcao = (param2 as Vector2).normalized()
		alcance_max = float(param3) if param3 != null else 200.0
		velocidade = float(param4) if param4 != null else 320.0
		dano = int(param5) if param5 != null else 25
		if param6 is Color:
			cor_primaria = param6
		dono = param7 as Node2D
		if param8 is HatsuData:
			hatsu = param8
			cor_primaria = hatsu.cor_aura
			cor_secundaria = hatsu.cor_aura_secundaria
			estilo_visual = hatsu.estilo_visual
	else:
		# Assinatura legada: (dir, dano, cor, hatsu_ref)
		direcao = (pos_ou_dir as Vector2).normalized()
		dano = int(param2) if param2 != null else 25
		if param3 is Color:
			cor_primaria = param3
		if param4 is HatsuData:
			hatsu = param4
			cor_primaria = hatsu.cor_aura
			cor_secundaria = hatsu.cor_aura_secundaria
			estilo_visual = hatsu.estilo_visual

	# Ajustar elemento para estilo visual automático se não especificado
	if hatsu != null:
		match hatsu.elemento:
			HatsuData.Elemento.FOGO: estilo_visual = HatsuData.EstiloVisual.CHAMAS_FOGO
			HatsuData.Elemento.ELETRICIDADE: estilo_visual = HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS
			HatsuData.Elemento.SOM: estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
			HatsuData.Elemento.SOMBRA: estilo_visual = HatsuData.EstiloVisual.NEVOA_SOMBRIAS
			_: pass

	z_index = 6
	_configurar_colisao()


func _configurar_colisao() -> void:
	collision_layer = 1 << 3 # Layer 4 (Hatsu Projectiles)
	collision_mask = 1 << 4 | 1 << 0 # Layer 5 (Enemies) + Layer 1 (World)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	add_child(shape)

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	tempo_vivo += delta
	rot_angle += delta * 15.0

	var movimento: Vector2 = direcao * velocidade * delta
	global_position += movimento
	distancia_percorrida += movimento.length()

	# Atualizar rastro
	rastro_posicoes.push_front(global_position)
	if rastro_posicoes.size() > max_rastro:
		rastro_posicoes.pop_back()

	if distancia_percorrida >= alcance_max or tempo_vivo >= 2.5:
		queue_free()
		return

	queue_redraw()


func _draw() -> void:
	var angle_dir: float = direcao.angle()

	match estilo_visual:
		HatsuData.EstiloVisual.CHAMAS_FOGO:
			_desenhar_chamas(angle_dir)
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
			_desenhar_relampagos()
		HatsuData.EstiloVisual.LAMINA_CORTE:
			_desenhar_lamina(angle_dir)
		HatsuData.EstiloVisual.SHURIKEN_GIRATORIO:
			_desenhar_shuriken()
		HatsuData.EstiloVisual.ANEIS_IMPACTO:
			_desenhar_aneis(angle_dir)
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS:
			_desenhar_nevoa()
		HatsuData.EstiloVisual.DRAGAO_SERPENTE:
			_desenhar_serpente(angle_dir)
		HatsuData.EstiloVisual.PURO_PULSANTE, _:
			_desenhar_orbe_puro()


func _desenhar_orbe_puro() -> void:
	var pulso: float = 1.0 + 0.15 * sin(tempo_vivo * 20.0)
	# Glow exterior
	draw_circle(Vector2.ZERO, 9.0 * pulso, Color(cor_primaria.r, cor_primaria.g, cor_primaria.b, 0.35))
	# Camada média
	draw_circle(Vector2.ZERO, 6.0 * pulso, cor_primaria)
	# Núcleo branco incandescente
	draw_circle(Vector2.ZERO, 3.0, cor_secundaria)
	# Partículas de cauda
	for i in range(1, rastro_posicoes.size()):
		var p_local = to_local(rastro_posicoes[i])
		var alpha: float = (1.0 - float(i) / float(max_rastro)) * 0.4
		var tam: float = max(1.0, 5.0 * (1.0 - float(i) / float(max_rastro)))
		draw_circle(p_local, tam, Color(cor_primaria.r, cor_primaria.g, cor_primaria.b, alpha))


func _desenhar_chamas(ang: float) -> void:
	var flicker: float = randf_range(0.85, 1.15)
	# Cauda de labareda em formato de gota/chama
	var pts := PackedVector2Array([
		Vector2(10 * flicker, 0).rotated(ang),
		Vector2(-4, -6 * flicker).rotated(ang),
		Vector2(-12 * flicker, 0).rotated(ang),
		Vector2(-4, 6 * flicker).rotated(ang)
	])
	draw_colored_polygon(pts, cor_primaria)
	# Núcleo interno
	var pts_inner := PackedVector2Array([
		Vector2(6, 0).rotated(ang),
		Vector2(-2, -3).rotated(ang),
		Vector2(-7, 0).rotated(ang),
		Vector2(-2, 3).rotated(ang)
	])
	draw_colored_polygon(pts_inner, cor_secundaria)


func _desenhar_relampagos() -> void:
	# Núcleo
	draw_circle(Vector2.ZERO, 4.0, cor_secundaria)
	# Arcos elétricos bifurcados instantâneos
	for k in range(3):
		var ang_base: float = (TAU / 3.0) * k + randf_range(-0.5, 0.5)
		var p1 = Vector2.ZERO
		var p2 = Vector2(randf_range(3, 7), randf_range(-4, 4)).rotated(ang_base)
		var p3 = Vector2(randf_range(7, 12), randf_range(-6, 6)).rotated(ang_base)
		draw_polyline(PackedVector2Array([p1, p2, p3]), cor_primaria, 1.5)
		draw_circle(p3, 1.2, cor_secundaria)


func _desenhar_lamina(ang: float) -> void:
	# Meia-lua cortante com pontas afiadas
	var pts := PackedVector2Array([
		Vector2(8, 0).rotated(ang),
		Vector2(-2, -10).rotated(ang),
		Vector2(3, -4).rotated(ang),
		Vector2(4, 0).rotated(ang),
		Vector2(3, 4).rotated(ang),
		Vector2(-2, 10).rotated(ang)
	])
	draw_colored_polygon(pts, cor_primaria)
	draw_polyline(pts, cor_secundaria, 1.2)


func _desenhar_shuriken() -> void:
	# Shuriken de 4 pontas girando
	var pts := PackedVector2Array([
		Vector2(0, -9).rotated(rot_angle),
		Vector2(2, -2).rotated(rot_angle),
		Vector2(9, 0).rotated(rot_angle),
		Vector2(2, 2).rotated(rot_angle),
		Vector2(0, 9).rotated(rot_angle),
		Vector2(-2, 2).rotated(rot_angle),
		Vector2(-9, 0).rotated(rot_angle),
		Vector2(-2, -2).rotated(rot_angle)
	])
	draw_colored_polygon(pts, cor_primaria)
	draw_circle(Vector2.ZERO, 3.0, cor_secundaria)


func _desenhar_aneis(ang: float) -> void:
	var osc: float = sin(tempo_vivo * 15.0) * 2.0
	draw_arc(Vector2.ZERO, 6.0 + osc, ang - 1.2, ang + 1.2, 16, cor_primaria, 2.0)
	draw_arc(Vector2.ZERO, 10.0 + osc, ang - 0.9, ang + 0.9, 16, Color(cor_primaria.r, cor_primaria.g, cor_primaria.b, 0.6), 1.5)
	draw_circle(Vector2.ZERO, 3.0, cor_secundaria)


func _desenhar_nevoa() -> void:
	# Vórtice de fumaça escura
	draw_circle(Vector2.ZERO, 8.0, Color(cor_primaria.r * 0.5, cor_primaria.g * 0.5, cor_primaria.b * 0.5, 0.8))
	for i in range(4):
		var p_off = Vector2(cos(rot_angle * 0.5 + i * 1.5) * 6.0, sin(rot_angle * 0.5 + i * 1.5) * 6.0)
		draw_circle(p_off, 3.0, Color(cor_primaria.r, cor_primaria.g, cor_primaria.b, 0.4))
	draw_circle(Vector2.ZERO, 2.5, cor_secundaria)


func _desenhar_serpente(ang: float) -> void:
	# Cabeça de dragão/serpente
	var pts_head := PackedVector2Array([
		Vector2(10, 0).rotated(ang),
		Vector2(0, -6).rotated(ang),
		Vector2(-6, 0).rotated(ang),
		Vector2(0, 6).rotated(ang)
	])
	draw_colored_polygon(pts_head, cor_primaria)
	draw_circle(Vector2(4, -2).rotated(ang), 1.5, cor_secundaria) # Olho
	draw_circle(Vector2(4, 2).rotated(ang), 1.5, cor_secundaria)

	# Corpo serpentino ondulante
	for i in range(1, rastro_posicoes.size()):
		var p_local = to_local(rastro_posicoes[i])
		var ondula: Vector2 = Vector2(-direcao.y, direcao.x) * sin(tempo_vivo * 18.0 + float(i) * 0.8) * 3.0
		var alpha: float = (1.0 - float(i) / float(max_rastro)) * 0.6
		var r_body: float = max(1.0, 5.0 * (1.0 - float(i) / float(max_rastro)))
		draw_circle(p_local + ondula, r_body, Color(cor_primaria.r, cor_primaria.g, cor_primaria.b, alpha))


# ============================================================
# COLISÃO E DANO
# ============================================================

func _on_body_entered(body: Node) -> void:
	if body == dono or (dono != null and body.is_in_group("player") and dono.is_in_group("player")):
		return

	_aplicar_impacto(body)


func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy != null and enemy != dono and is_instance_valid(enemy):
		if enemy.is_in_group("enemies") or (area.owner != null and area.owner.is_in_group("enemies")):
			_aplicar_impacto(enemy)


func _aplicar_impacto(alvo: Node) -> void:
	var enemy_sys = alvo.get_node_or_null("EnemySystem")
	if enemy_sys == null and alvo.get_parent() != null:
		enemy_sys = alvo.get_parent().get_node_or_null("EnemySystem")

	if enemy_sys != null and enemy_sys.has_method("take_damage"):
		var dir_impacto: Vector2 = direcao
		enemy_sys.take_damage(dano, dir_impacto, 140.0, dono)
		print("[Hatsu Projétil] Atingiu: ", alvo.name, " Dano: ", dano)
	elif alvo.has_method("receber_dano"):
		alvo.receber_dano(dano)

	# Instanciar explosão de impacto procedural
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(28.0, cor_primaria)
	fx.global_position = global_position
	if get_parent() != null:
		get_parent().add_child(fx)

	queue_free()
