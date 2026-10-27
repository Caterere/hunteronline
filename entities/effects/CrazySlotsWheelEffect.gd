class_name CrazySlotsWheelEffect
extends Node2D

# ============================================================
# HUNTER ONLINE - CRAZY SLOTS WHEEL EFFECT (KAITO)
# ============================================================
#
# Manifesta o palhaço de Nen e gira a roleta (1 a 9).
# Executa a habilidade especial da arma sorteada:
# - Nº 2: Foice Gigante (Silent Waltz / Valsa Silenciosa 360°)
# - Nº 3: Clava Esmagadora (Impacto com Stun)
# - Nº 4: Rifle de Precisão (Disparo Penetrante)
#
# ============================================================

var target_player: CharacterBody2D = null
var numero_sorteado: int = 2
var tempo_animacao: float = 0.0
var finalizou_giro: bool = false


func setup(player_body: CharacterBody2D) -> void:
	target_player = player_body
	# D5-B: 3 armas (foice / clava / rifle) com pesos — foice mais comum (Silent Waltz)
	var opcoes := [2, 2, 2, 3, 3, 4] # pesos: foice 50%, clava 33%, rifle 17%
	numero_sorteado = opcoes[randi() % opcoes.size()]
	z_index = 8


func _ready() -> void:
	if target_player != null:
		global_position = target_player.global_position + Vector2(0, -28)


func _process(delta: float) -> void:
	if target_player == null or not is_instance_valid(target_player):
		queue_free()
		return

	global_position = target_player.global_position + Vector2(0, -28)
	tempo_animacao += delta

	if tempo_animacao >= 0.5 and not finalizou_giro:
		finalizou_giro = true
		_executar_golpe_arma()

	if tempo_animacao >= 1.2:
		queue_free()

	queue_redraw()


func _executar_golpe_arma() -> void:
	if target_player == null:
		return

	print("[Crazy Slots] Roleta parou no Número: ", numero_sorteado)

	match numero_sorteado:
		2: # FOICE GIGANTE — SILENT WALTZ (VALSA SILENCIOSA 360°)
			print("[Crazy Slots] Executando: Silent Waltz (Valsa Silenciosa 360°)")
			_executar_valsa_silenciosa()
		3: # CLAVA DE IMPACTO
			print("[Crazy Slots] Executando: Golpe Esmagador de Clava")
			_executar_clava_esmagadora()
		4: # RIFLE DE PRECISÃO
			print("[Crazy Slots] Executando: Tiro Penetrante de Rifle")
			_executar_tiro_rifle()


func _executar_valsa_silenciosa() -> void:
	var area := Area2D.new()
	area.name = "SilentWaltzArea"
	area.collision_layer = 1 << 3
	area.collision_mask = 1 << 4

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 160.0 # Alcance circular por quase toda a tela!
	col.shape = shape
	area.add_child(col)

	target_player.add_child(area)
	area.position = Vector2.ZERO

	# Efeito visual de corte circular 360° em expansão
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(160.0, Color(0.9, 0.95, 1.0, 0.9)) # Lâmina branca cortante
	target_player.add_child(fx)

	var dano_corte: int = int(PlayerData.attributes.get("forca", 20) * 2.2) + 60

	area.area_entered.connect(func(alvo_area: Area2D):
		var enemy: Node = alvo_area.get_parent()
		if enemy != null and enemy != target_player:
			var enemy_sys = enemy.get_node_or_null("EnemySystem")
			if enemy_sys != null:
				var dir: Vector2 = (enemy.global_position - target_player.global_position).normalized()
				enemy_sys.take_damage(dano_corte, dir, 250.0, target_player)
				print("[Silent Waltz 360°] Cortou ", enemy.name, " Dano: ", dano_corte)
	)

	var timer := target_player.get_tree().create_timer(0.3)
	await timer.timeout
	if is_instance_valid(area):
		area.queue_free()


func _executar_clava_esmagadora() -> void:
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(70.0, Color(1.0, 0.6, 0.1, 0.9))
	target_player.add_child(fx)

	var area := Area2D.new()
	area.collision_layer = 1 << 3
	area.collision_mask = 1 << 4
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 70.0
	col.shape = shape
	area.add_child(col)
	target_player.add_child(area)
	var dano_clava: int = int(PlayerData.attributes.get("forca", 20) * 1.8) + 45
	area.area_entered.connect(func(alvo_area: Area2D):
		var enemy: Node = alvo_area.get_parent()
		if enemy != null and enemy != target_player:
			var enemy_sys = enemy.get_node_or_null("EnemySystem")
			if enemy_sys != null:
				var dir: Vector2 = (enemy.global_position - target_player.global_position).normalized()
				enemy_sys.take_damage(dano_clava, dir, 280.0, target_player)
				if "stun_timer" in enemy_sys:
					enemy_sys.stun_timer = maxf(float(enemy_sys.stun_timer), 1.2)
	)
	var timer := target_player.get_tree().create_timer(0.25)
	await timer.timeout
	if is_instance_valid(area):
		area.queue_free()


func _executar_tiro_rifle() -> void:
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(40.0, Color(0.3, 0.9, 1.0, 0.9))
	target_player.add_child(fx)

	var dir: Vector2 = Vector2.RIGHT
	var combat = target_player.get_node_or_null("CombatSystem")
	if combat != null and "ultima_direcao" in combat and combat.ultima_direcao != Vector2.ZERO:
		dir = combat.ultima_direcao
	elif target_player.velocity != Vector2.ZERO:
		dir = target_player.velocity.normalized()

	var area := Area2D.new()
	area.name = "CrazySlotsRifle"
	area.collision_layer = 1 << 3
	area.collision_mask = 1 << 4
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	col.shape = shape
	area.add_child(col)
	var map_parent = target_player.get_parent() if target_player.get_parent() != null else target_player
	map_parent.add_child(area)
	area.global_position = target_player.global_position
	var dano_rifle: int = int(PlayerData.attributes.get("forca", 20) * 1.4) + 55
	area.area_entered.connect(func(alvo_area: Area2D):
		var enemy: Node = alvo_area.get_parent()
		if enemy != null and enemy != target_player:
			var enemy_sys = enemy.get_node_or_null("EnemySystem")
			if enemy_sys != null:
				enemy_sys.take_damage(dano_rifle, dir, 160.0, target_player)
	)
	var tw := area.create_tween()
	tw.tween_property(area, "global_position", area.global_position + dir * 220.0, 0.35)
	tw.tween_callback(func():
		if is_instance_valid(area):
			area.queue_free()
	)


func _draw() -> void:
	# Cabeça do palhaço com a roleta de números
	draw_circle(Vector2.ZERO, 10.0, Color(0.9, 0.2, 0.4, 0.9)) # Rosto palhaço
	draw_circle(Vector2.ZERO, 7.0, Color(1.0, 1.0, 1.0, 0.95))
	
	# Exibição do número sorteado
	var texto_num: String = str(numero_sorteado) if finalizou_giro else str(randi_range(1, 9))
	draw_string(ThemeDB.fallback_font, Vector2(-3, 3), texto_num, HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.RED)
