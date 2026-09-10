class_name NenSensorFactory
extends RefCounted

# ============================================================
# HUNTER ONLINE — Factory de sensores Nen no mundo
# Instancia Gyo / Ko / Zetsu com colisão pronta (sem novos sistemas).
# ============================================================


static func criar_gyo(
	parent: Node,
	nome: String,
	pos: Vector2,
	clue_id: StringName,
	titulo: String,
	descricao: String,
	categoria: String = "Desconhecida",
	nivel_gyo: int = 1,
	cor: Color = Color(0.3, 0.85, 1.0, 0.9)
) -> GyoInspectable:
	if parent.get_node_or_null(nome) != null:
		return parent.get_node_or_null(nome) as GyoInspectable

	var gyo := GyoInspectable.new()
	gyo.name = nome
	gyo.position = pos
	gyo.clue_id = clue_id
	gyo.titulo_pista = titulo
	gyo.descricao_pista = descricao
	gyo.categoria_nen = categoria
	gyo.requer_gyo = true
	gyo.nivel_gyo_minimo = nivel_gyo
	gyo.cor_aura = cor

	var col := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 18.0
	col.shape = circ
	gyo.add_child(col)

	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load("res://assets/sprites/characters/player.png")
	spr.hframes = 6
	spr.vframes = 10
	spr.frame = 0
	spr.position = Vector2(0, -8)
	spr.modulate = Color(cor.r, cor.g, cor.b, 0.55)
	spr.scale = Vector2(0.55, 0.55)
	gyo.add_child(spr)

	parent.add_child(gyo)
	return gyo


static func criar_ko(
	parent: Node,
	nome: String,
	pos: Vector2,
	obstacle_name: String,
	recompensa: StringName = &""
) -> KoObstacle:
	if parent.get_node_or_null(nome) != null:
		return parent.get_node_or_null(nome) as KoObstacle

	var ko := KoObstacle.new()
	ko.name = nome
	ko.position = pos
	ko.obstacle_name = obstacle_name
	ko.item_recompensa_id = recompensa

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(28, 22)
	col.shape = box
	col.position = Vector2(0, -2)
	ko.add_child(col)

	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load("res://assets/sprites/characters/player.png")
	spr.hframes = 6
	spr.vframes = 10
	spr.frame = 0
	spr.position = Vector2(0, -10)
	spr.modulate = Color(0.62, 0.52, 0.42, 1.0)
	ko.add_child(spr)

	parent.add_child(ko)
	return ko


static func criar_zetsu(
	parent: Node,
	nome: String,
	pos: Vector2,
	zone_id: StringName,
	zone_name: String,
	area_size: Vector2 = Vector2(160, 120),
	enemy_id: StringName = &"lobo_sombras",
	enemy_name: String = "Predador Alertado"
) -> ZetsuSensorZone:
	if parent.get_node_or_null(nome) != null:
		return parent.get_node_or_null(nome) as ZetsuSensorZone

	var zone := ZetsuSensorZone.new()
	zone.name = nome
	zone.position = pos
	zone.zone_id = zone_id
	zone.zone_name = zone_name
	zone.spawn_inimigos_ao_falhar = true
	zone.enemy_id = enemy_id
	zone.enemy_name = enemy_name
	zone.mostrar_marcador = true

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = area_size
	col.shape = box
	zone.add_child(col)

	parent.add_child(zone)
	return zone
