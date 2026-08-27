class_name HatsuTerritoryZoneNode
extends Node2D

# ============================================================
# HUNTER ONLINE - HATSU TERRITORY ZONE (EN & REGRAS ESPACIAIS)
# ============================================================
#
# Cria um círculo de En no solo com regras absolutas:
# - Desacelera inimigos em 60% dentro do domínio.
# - Causa dano periódico de Nen.
# - Amplifica os ataques do usuário.
#
# ============================================================

var raio: float = 85.0
var cor_aura: Color = Color(0.3, 0.7, 1.0, 0.7)
var duracao_restante: float = 7.0
var regra_tipo: String = "DESACELERACAO"
var dono: Node2D = null
var dano_tick: int = 15
var timer_tick: float = 0.0
var area_en: Area2D = null


func setup(r: float, cor: Color, dur: float, regra: String, criador: Node2D, poder: float) -> void:
	raio = r
	cor_aura = cor
	duracao_restante = dur
	regra_tipo = regra
	dono = criador
	dano_tick = max(5, int(poder * 0.25))
	z_index = 2


func _ready() -> void:
	# Area2D de colisão do território
	area_en = Area2D.new()
	area_en.name = "TerritoryArea"
	area_en.collision_layer = 1 << 3
	area_en.collision_mask = 1 << 4

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = raio
	col.shape = shape
	area_en.add_child(col)
	add_child(area_en)


func _process(delta: float) -> void:
	duracao_restante -= delta
	if duracao_restante <= 0.0:
		queue_free()
		return

	# Aplicar regras a cada 0.6s nos inimigos dentro da área
	timer_tick += delta
	if timer_tick >= 0.6:
		timer_tick = 0.0
		_aplicar_regras_territorio()

	queue_redraw()


func _aplicar_regras_territorio() -> void:
	if not is_instance_valid(area_en): return

	var overlapping_areas = area_en.get_overlapping_areas()
	for a in overlapping_areas:
		var enemy = a.get_parent()
		if enemy != null and enemy != dono and is_instance_valid(enemy):
			var es = enemy.get_node_or_null("EnemySystem")
			if es != null and es.has_method("take_damage"):
				var dir = (enemy.global_position - global_position).normalized()
				es.take_damage(dano_tick, dir, 20.0, dono)
				# Desaceleração
				if "speed" in enemy:
					enemy.velocity *= 0.4


func _draw() -> void:
	# Cúpula de En no chão translúcida com borda de Nen
	var alpha_pulse: float = 0.25 + 0.15 * sin(Time.get_ticks_msec() * 0.005)
	var cor_fill = Color(cor_aura.r, cor_aura.g, cor_aura.b, alpha_pulse)
	draw_circle(Vector2.ZERO, raio, cor_fill)
	draw_arc(Vector2.ZERO, raio, 0, TAU, 32, cor_aura, 1.5)
	draw_arc(Vector2.ZERO, raio * 0.65, 0, TAU, 24, Color(cor_aura.r, cor_aura.g, cor_aura.b, 0.4), 1.0)
