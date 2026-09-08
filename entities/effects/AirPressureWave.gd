class_name AirPressureWave
extends Node2D

# ============================================================
# HUNTER ONLINE - ONDA DE PRESSÃO DO AR / CORTE DE VENTO
# ============================================================
#
# Efeito visual de deslocamento de ar cortante / lâmina de vácuo
# disparado durante o avanço de golpe marcial do Hunter.
#
# Características:
# - Alinhado perfeitamente nas 8 direções de ataque do jogador
# - Meia-lua cortante com núcleo de brilho puro e gradiente de aura
# - Linhas de velocidade de ar comprimido (Speed lines)
# - Micro-avanço físico no ar com desaceleração orgânica
# - Auto-remoção com queue_free() (zero memory leaks)
# ============================================================

var direcao: Vector2 = Vector2.RIGHT
var velocidade: float = 180.0
var duracao: float = 0.16
var tempo_vida: float = 0.0
var is_heavy: bool = false
var raio_arco: float = 26.0
var espessura: float = 3.5
var cor_primaria: Color = Color(1.0, 1.0, 1.0, 0.95)
var cor_secundaria: Color = Color(0.35, 0.8, 1.0, 0.6)


func setup(pos: Vector2, dir: Vector2, heavy: bool = false, cor_nen: Color = Color.TRANSPARENT) -> void:
	global_position = pos
	direcao = dir.normalized() if dir != Vector2.ZERO else Vector2.DOWN
	rotation = direcao.angle()
	is_heavy = heavy
	z_index = 4

	if is_heavy:
		raio_arco = 36.0
		espessura = 5.5
		duracao = 0.22
		velocidade = 240.0
		cor_primaria = Color(1.0, 0.98, 0.85, 1.0)
		cor_secundaria = Color(1.0, 0.65, 0.2, 0.7)
	else:
		raio_arco = 26.0
		espessura = 3.5
		duracao = 0.16
		velocidade = 180.0
		cor_primaria = Color(1.0, 1.0, 1.0, 0.95)
		cor_secundaria = Color(0.35, 0.8, 1.0, 0.6)

	if cor_nen != Color.TRANSPARENT and cor_nen.a > 0.05:
		cor_secundaria = cor_nen
		cor_secundaria.a = 0.65


func _process(delta: float) -> void:
	tempo_vida += delta
	if tempo_vida >= duracao:
		queue_free()
		return

	var progresso: float = tempo_vida / duracao

	# Deslocamento para frente com desaceleração
	global_position += direcao * (velocidade * (1.0 - progresso * 0.75) * delta)

	# Expansão sutil da onda
	var escala = lerpf(0.85, 1.30 if not is_heavy else 1.50, progresso)
	scale = Vector2(escala, escala)

	# Fade-out suave
	modulate.a = 1.0 - pow(progresso, 1.4)
	queue_redraw()


func _draw() -> void:
	# Desenhamos o arco cortante apontando para +X (o nó já está rotacionado para 'direcao.angle()')
	var pontos_arco: PackedVector2Array = []
	var pontos_interno: PackedVector2Array = []
	var segmentos: int = 14
	var angulo_abertura: float = deg_to_rad(70.0 if not is_heavy else 85.0)

	for i in range(segmentos + 1):
		var frac: float = float(i) / float(segmentos) - 0.5
		var ang: float = frac * angulo_abertura
		var fator_ponta: float = cos(frac * PI)
		var r_out: float = raio_arco + (fator_ponta * 5.0)
		var r_in: float = raio_arco - (fator_ponta * espessura)
		pontos_arco.append(Vector2(cos(ang) * r_out, sin(ang) * r_out))
		pontos_interno.append(Vector2(cos(ang) * r_in, sin(ang) * r_in))

	# Polígono de ar cortante / onda de choque translúcida
	var poligono: PackedVector2Array = []
	for p in pontos_arco:
		poligono.append(p)
	for i in range(pontos_interno.size() - 1, -1, -1):
		poligono.append(pontos_interno[i])

	if poligono.size() >= 3:
		draw_colored_polygon(poligono, cor_secundaria)

	# Linha de corte afiada no centro da lâmina
	for i in range(pontos_arco.size() - 1):
		var p1 = pontos_arco[i].lerp(pontos_interno[i], 0.45)
		var p2 = pontos_arco[i + 1].lerp(pontos_interno[i + 1], 0.45)
		draw_line(p1, p2, cor_primaria, max(1.2, espessura * 0.45), true)

	# Speed lines de corte (traços finos de pressão que acompanham o golpe)
	var prog: float = tempo_vida / duracao
	var streak_alpha: float = (1.0 - prog) * 0.8
	var cor_streak: Color = Color(cor_primaria.r, cor_primaria.g, cor_primaria.b, streak_alpha)

	var offsets_y: Array[float] = [-12.0, -5.0, 5.0, 12.0]
	if is_heavy:
		offsets_y = [-18.0, -10.0, 0.0, 10.0, 18.0]

	for y_off in offsets_y:
		var start_x: float = (raio_arco * 0.5) + abs(y_off) * 0.25
		var end_x: float = start_x + lerpf(14.0, 3.0, prog)
		draw_line(Vector2(start_x, y_off), Vector2(end_x, y_off * 1.15), cor_streak, 1.0, true)
