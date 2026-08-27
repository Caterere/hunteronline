class_name HatsuAreaExplosionNode
extends Node2D

# ============================================================
# HUNTER ONLINE - PROCEDURAL HATSU AREA EXPLOSION NODE
# ============================================================
#
# Onda de choque e detonação de Nen 100% procedural.
# Desenha anéis de choque com expansão elástica, centelhas e núcleo.
#
# ============================================================

var raio_max: float = 60.0
var raio_atual: float = 4.0
var cor_aura: Color = Color(1.0, 0.5, 0.1, 0.9)
var cor_secundaria: Color = Color(1.0, 0.95, 0.8, 1.0)
var faíscas: Array[Dictionary] = []
var tempo_vida: float = 0.0
var duracao_total: float = 0.45


func setup(raio: float, cor: Color, cor_sec: Color = Color.WHITE) -> void:
	raio_max = raio
	cor_aura = cor
	cor_secundaria = cor_sec
	raio_atual = 4.0
	z_index = 7

	# Gerar 8 a 14 centelhas procedurais
	faíscas.clear()
	var qtd: int = randi_range(8, 14)
	for i in range(qtd):
		var ang: float = (TAU / float(qtd)) * i + randf_range(-0.2, 0.2)
		var vel: float = randf_range(raio_max * 1.5, raio_max * 2.6)
		faíscas.append({
			"pos": Vector2.ZERO,
			"vel": Vector2(cos(ang), sin(ang)) * vel,
			"tam": randf_range(1.5, 3.0)
		})


func _process(delta: float) -> void:
	tempo_vida += delta
	var progresso: float = tempo_vida / duracao_total
	raio_atual = lerp(4.0, raio_max, ease(progresso, 0.4))

	for f in faíscas:
		f["pos"] += f["vel"] * delta
		f["vel"] *= 0.91 # Atrito da aura

	if tempo_vida >= duracao_total:
		queue_free()
		return

	queue_redraw()


func _draw() -> void:
	var alpha: float = max(0.0, 1.0 - (tempo_vida / duracao_total))
	var cor_fill := Color(cor_aura.r, cor_aura.g, cor_aura.b, alpha * 0.35)
	var cor_ring := Color(cor_aura.r, cor_aura.g, cor_aura.b, alpha * 0.9)
	var cor_core := Color(cor_secundaria.r, cor_secundaria.g, cor_secundaria.b, alpha * 0.8)

	# 1. Flash do Núcleo Inicial
	if tempo_vida < 0.15:
		var r_flash = (1.0 - (tempo_vida / 0.15)) * (raio_max * 0.45)
		draw_circle(Vector2.ZERO, r_flash, cor_core)

	# 2. Onda de Choque e Cúpula Translúcida
	draw_circle(Vector2.ZERO, raio_atual, cor_fill)
	draw_arc(Vector2.ZERO, raio_atual, 0, TAU, 32, cor_ring, 2.5)

	# 3. Segundo Anel Menor
	if raio_atual > 12.0:
		draw_arc(Vector2.ZERO, raio_atual * 0.6, 0, TAU, 24, Color(cor_secundaria.r, cor_secundaria.g, cor_secundaria.b, alpha * 0.6), 1.5)

	# 4. Centelhas de Nen Projetadas
	for f in faíscas:
		draw_circle(f["pos"], f["tam"] * alpha, cor_core)
		draw_line(f["pos"], f["pos"] - f["vel"] * 0.04, cor_ring, 1.2)
