class_name MapAtmosphereDecorator
extends Node2D

# ============================================================
# HUNTER ONLINE — Densidade visual nível MMORPG (pós-pass)
# Legibilidade de pixel-MMO clássico + atmosfera HxH:
# trilhas claras, landmarks, luz ambiente, props ao longo do caminho.
# ============================================================

enum MapKind {
	FLORESTA,
	ESTRADA,
	DUNGEON,
	VALE,
	YORKNEW,
	KUKUROO,
	ARENA
}

@export var map_kind: MapKind = MapKind.FLORESTA
var _canvas: CanvasModulate = null


static func attach(mapa: Node2D, kind: MapKind) -> MapAtmosphereDecorator:
	if mapa == null:
		return null
	var existing = mapa.get_node_or_null("MapAtmosphereDecorator") as MapAtmosphereDecorator
	if existing != null:
		return existing
	var node := MapAtmosphereDecorator.new()
	node.name = "MapAtmosphereDecorator"
	node.map_kind = kind
	mapa.add_child(node)
	return node


func _ready() -> void:
	_garantir_canvas_modulate()
	match map_kind:
		MapKind.FLORESTA:
			_densificar_floresta()
		MapKind.ESTRADA:
			_densificar_estrada()
		MapKind.DUNGEON:
			_densificar_dungeon()
		MapKind.VALE:
			_densificar_vale()
		MapKind.YORKNEW:
			_densificar_yorknew()
		MapKind.KUKUROO:
			_densificar_kukuroo()
		MapKind.ARENA:
			_densificar_arena()
	_espalhar_props_landmark()
	_conectar_sinais()
	_atualizar_luz()


func _conectar_sinais() -> void:
	if EventBus != null and EventBus.has_signal("time_phase_changed"):
		if not EventBus.time_phase_changed.is_connected(_on_time_phase):
			EventBus.time_phase_changed.connect(_on_time_phase)
	if WorldStateManager != null and WorldStateManager.has_signal("clima_alterado"):
		if not WorldStateManager.clima_alterado.is_connected(_on_clima):
			WorldStateManager.clima_alterado.connect(_on_clima)


func _on_time_phase(_phase: String) -> void:
	_atualizar_luz()


func _on_clima(_c: int, _n: String) -> void:
	_atualizar_luz()


func _garantir_canvas_modulate() -> void:
	var mapa := get_parent() as Node2D
	if mapa == null:
		return
	_canvas = mapa.get_node_or_null("AmbientLightModulate") as CanvasModulate
	if _canvas == null:
		_canvas = CanvasModulate.new()
		_canvas.name = "AmbientLightModulate"
		mapa.add_child(_canvas)


func _atualizar_luz() -> void:
	if _canvas == null or not is_instance_valid(_canvas):
		return
	var cor: Color = Color.WHITE
	if TimeManager != null and TimeManager.has_method("get_ambient_light_color"):
		cor = TimeManager.get_ambient_light_color()
	if WorldStateManager != null:
		match WorldStateManager.clima_atual:
			WorldStateManager.Clima.CHUVA:
				cor = cor.lerp(Color(0.62, 0.72, 0.82), 0.35)
			WorldStateManager.Clima.NEBLINA:
				cor = cor.lerp(Color(0.78, 0.82, 0.86), 0.4)
			WorldStateManager.Clima.TEMPESTADE_AURA:
				cor = cor.lerp(Color(0.88, 0.7, 1.05), 0.3)
	var tw = create_tween()
	if tw != null:
		tw.tween_property(_canvas, "color", cor, 1.8)
	else:
		_canvas.color = cor


func _mapa() -> Node2D:
	return get_parent() as Node2D


func _densificar_floresta() -> void:
	var mapa := _mapa()
	if mapa == null:
		return
	var decor: TileMapLayer = mapa.get_node_or_null("Decor_TileMapLayer") as TileMapLayer
	var caminhos: TileMapLayer = mapa.get_node_or_null("Caminhos_TileMapLayer") as TileMapLayer
	if decor == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 0xF105E57A
	for ty in range(2, 38):
		for tx in range(2, 48):
			if caminhos != null and caminhos.get_cell_source_id(Vector2i(tx, ty)) != -1:
				continue
			if decor.get_cell_source_id(Vector2i(tx, ty)) != -1:
				continue
			if abs(tx - 25) < 3 and abs(ty - 18) < 3:
				continue
			var h: int = int(rng.randi_range(0, 100))
			if h < 8 and tx % 2 == 0 and ty % 2 == 0 and tx < 47 and ty < 37:
				decor.set_cell(Vector2i(tx, ty), 5, Vector2i(1, 1))
				decor.set_cell(Vector2i(tx + 1, ty), 5, Vector2i(2, 1))
				decor.set_cell(Vector2i(tx, ty + 1), 5, Vector2i(1, 2))
				decor.set_cell(Vector2i(tx + 1, ty + 1), 5, Vector2i(2, 2))
			elif h < 14:
				decor.set_cell(Vector2i(tx, ty), 4, Vector2i(6, 4))
			elif h < 17:
				decor.set_cell(Vector2i(tx, ty), 4, Vector2i(4, 2))


func _densificar_estrada() -> void:
	var mapa := _mapa()
	if mapa == null:
		return
	var decor: TileMapLayer = mapa.get_node_or_null("Decor_TileMapLayer") as TileMapLayer
	if decor == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 0xE57ADA01
	for ty in [6, 10, 16, 24, 32]:
		if decor.get_cell_source_id(Vector2i(20, ty)) == -1:
			decor.set_cell(Vector2i(20, ty), 4, Vector2i(2, 6))
		if decor.get_cell_source_id(Vector2i(29, ty)) == -1:
			decor.set_cell(Vector2i(29, ty), 4, Vector2i(2, 6))
	for ty in range(1, 39):
		for tx in [2, 3, 4, 45, 46, 47]:
			if decor.get_cell_source_id(Vector2i(tx, ty)) != -1:
				continue
			if ty % 2 == 0 and tx % 2 == 0 and rng.randf() < 0.55 and tx < 49 and ty < 39:
				decor.set_cell(Vector2i(tx, ty), 5, Vector2i(1, 1))
				decor.set_cell(Vector2i(tx + 1, ty), 5, Vector2i(2, 1))
				decor.set_cell(Vector2i(tx, ty + 1), 5, Vector2i(1, 2))
				decor.set_cell(Vector2i(tx + 1, ty + 1), 5, Vector2i(2, 2))


func _densificar_dungeon() -> void:
	var mapa := _mapa()
	if mapa == null:
		return
	var decor: TileMapLayer = mapa.get_node_or_null("Decor_TileMapLayer") as TileMapLayer
	var paredes: TileMapLayer = mapa.get_node_or_null("Paredes_TileMapLayer") as TileMapLayer
	if decor == null:
		return
	var torches: Array[Vector2i] = [
		Vector2i(6, 18), Vector2i(33, 18), Vector2i(6, 24), Vector2i(33, 24),
		Vector2i(10, 8), Vector2i(29, 8), Vector2i(18, 16), Vector2i(22, 16),
		Vector2i(12, 26), Vector2i(27, 26)
	]
	for t in torches:
		if paredes != null and paredes.get_cell_source_id(t) != -1:
			continue
		if decor.get_cell_source_id(t) == -1:
			decor.set_cell(t, 8, Vector2i(2, 1))
	for p in [Vector2i(12, 20), Vector2i(27, 20), Vector2i(16, 8), Vector2i(24, 8)]:
		if decor.get_cell_source_id(p) == -1:
			decor.set_cell(p, 9, Vector2i(0, 2))
	for d in [Vector2i(8, 28), Vector2i(31, 28), Vector2i(14, 22), Vector2i(26, 22)]:
		if decor.get_cell_source_id(d) == -1:
			decor.set_cell(d, 8, Vector2i(4, 2))


func _densificar_vale() -> void:
	var mapa := _mapa()
	if mapa == null:
		return
	var decor: TileMapLayer = mapa.get_node_or_null("Decor_TileMapLayer") as TileMapLayer
	if decor == null:
		return
	for tx in range(140, 400, 18):
		var cell := Vector2i(tx, 258)
		if decor.get_cell_source_id(cell) == -1:
			decor.set_cell(cell, 8, Vector2i(2, 1))
		var cell2 := Vector2i(tx, 262)
		if decor.get_cell_source_id(cell2) == -1:
			decor.set_cell(cell2, 8, Vector2i(2, 1))
	for tx in range(95, 120, 2):
		for ty in range(248, 268, 2):
			if decor.get_cell_source_id(Vector2i(tx, ty)) == -1 and ((tx + ty) % 5 == 0):
				decor.set_cell(Vector2i(tx, ty), 5, Vector2i(0, 0))


func _garantir_decor_layer() -> TileMapLayer:
	var mapa := _mapa()
	if mapa == null:
		return null
	var decor: TileMapLayer = mapa.get_node_or_null("Decor_TileMapLayer") as TileMapLayer
	if decor != null:
		return decor
	var chao: TileMapLayer = mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	decor = TileMapLayer.new()
	decor.name = "Decor_TileMapLayer"
	decor.z_index = 1
	if chao != null and chao.tile_set != null:
		decor.tile_set = chao.tile_set
	elif ResourceLoader.exists("res://world/tilesets/world_tileset.tres"):
		decor.tile_set = load("res://world/tilesets/world_tileset.tres")
	mapa.add_child(decor)
	return decor


func _densificar_yorknew() -> void:
	# Metrópole noturna: calçada urbana + postes + caixas de rua
	var mapa := _mapa()
	if mapa == null:
		return
	var chao: TileMapLayer = mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	var decor := _garantir_decor_layer()
	var rng := RandomNumberGenerator.new()
	rng.seed = 0x40C4E44
	# Cobertura ao longo do eixo X do mapa linear (~0..4300 px → tiles 16px)
	for tx in range(-20, 280):
		for ty in range(-90, 90):
			if chao != null and chao.get_cell_source_id(Vector2i(tx, ty)) == -1:
				chao.set_cell(Vector2i(tx, ty), 0, Vector2i(1, 9))
			# Faixa central de avenida
			if abs(ty) <= 3 and chao != null:
				chao.set_cell(Vector2i(tx, ty), 0, Vector2i(1, 5))
	if decor == null:
		return
	for tx in range(-10, 270, 8):
		for ty in [-40, -20, 20, 40]:
			var c := Vector2i(tx, ty)
			if decor.get_cell_source_id(c) == -1:
				decor.set_cell(c, 8, Vector2i(2, 1)) # poste
		if rng.randf() < 0.35:
			var b := Vector2i(tx + 2, rng.randi_range(-12, 12))
			if decor.get_cell_source_id(b) == -1:
				decor.set_cell(b, 8, Vector2i(4, 2)) # caixa
		if rng.randf() < 0.25:
			var r := Vector2i(tx + 3, rng.randi_range(-30, 30))
			if decor.get_cell_source_id(r) == -1:
				decor.set_cell(r, 8, Vector2i(3, 2)) # barril


func _densificar_kukuroo() -> void:
	# Montanha Zoldyck: grama + alameda + árvores densas
	var mapa := _mapa()
	if mapa == null:
		return
	var chao: TileMapLayer = mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	var decor := _garantir_decor_layer()
	var rng := RandomNumberGenerator.new()
	rng.seed = 0x4C4C400
	for tx in range(-20, 280):
		for ty in range(-90, 90):
			if chao != null and chao.get_cell_source_id(Vector2i(tx, ty)) == -1:
				chao.set_cell(Vector2i(tx, ty), 2, Vector2i(0, 0))
			if abs(ty) <= 2 and chao != null:
				chao.set_cell(Vector2i(tx, ty), 3, Vector2i(1, 1)) # caminho terra
	if decor == null:
		return
	for tx in range(-10, 270, 3):
		for ty in range(-80, 80, 3):
			if abs(ty) <= 4:
				continue
			if decor.get_cell_source_id(Vector2i(tx, ty)) != -1:
				continue
			var h: int = int(rng.randi_range(0, 100))
			if h < 18 and tx < 269 and ty < 79:
				decor.set_cell(Vector2i(tx, ty), 7, Vector2i(2, 2))
				decor.set_cell(Vector2i(tx, ty + 1), 7, Vector2i(2, 3))
			elif h < 28:
				decor.set_cell(Vector2i(tx, ty), 7, Vector2i(1, 6))
			elif h < 32:
				decor.set_cell(Vector2i(tx, ty), 5, Vector2i(0, 0))



func _densificar_arena() -> void:
	# Corredor da Arena Celestial: piso de pedra + postes + equipamentos de treino
	var mapa := _mapa()
	if mapa == null:
		return
	var chao: TileMapLayer = mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	var decor := _garantir_decor_layer()
	var rng := RandomNumberGenerator.new()
	rng.seed = 0xA4E4A01
	for tx in range(-20, 280):
		for ty in range(-90, 90):
			if chao != null and chao.get_cell_source_id(Vector2i(tx, ty)) == -1:
				chao.set_cell(Vector2i(tx, ty), 0, Vector2i(1, 9))
			if abs(ty) <= 3 and chao != null:
				chao.set_cell(Vector2i(tx, ty), 0, Vector2i(1, 5))
	if decor == null:
		return
	for tx in range(-10, 270, 7):
		for ty in [-36, -18, 18, 36]:
			var c := Vector2i(tx, ty)
			if decor.get_cell_source_id(c) == -1:
				decor.set_cell(c, 8, Vector2i(2, 1))
		if rng.randf() < 0.4:
			var b := Vector2i(tx + 2, rng.randi_range(-14, 14))
			if decor.get_cell_source_id(b) == -1:
				decor.set_cell(b, 8, Vector2i(4, 2))


func _espalhar_props_landmark() -> void:
	if get_node_or_null("AtmosphereProps") != null:
		return
	var root := Node2D.new()
	root.name = "AtmosphereProps"
	add_child(root)

	match map_kind:
		MapKind.FLORESTA:
			_add_prop_sprite(root, "MonolitoNenOeste", Vector2(140, 360), "res://assets/sprites/objects/nen_stone_monolith.png", Color(0.55, 0.9, 1.0), Vector2(0.9, 0.9))
			_add_prop_sprite(root, "MonolitoNenSul", Vector2(520, 520), "res://assets/sprites/objects/nen_stone_monolith.png", Color(0.7, 1.0, 0.85), Vector2(0.85, 0.85))
			_add_prop_sprite(root, "LanternaClareira", Vector2(300, 200), "res://assets/sprites/objects/hunter_road_lantern.png", Color.WHITE, Vector2(1, 1))
			_add_prop_sprite(root, "ArbustoClareiraA", Vector2(220, 260), "res://assets/sprites/objects/lobby_bush_flowers_decor.png", Color(0.8, 1.0, 0.75), Vector2(1.0, 1.0))
			_add_prop_sprite(root, "ArbustoClareiraB", Vector2(480, 340), "res://assets/sprites/objects/lobby_bush_flowers_decor.png", Color(0.75, 0.95, 0.7), Vector2(0.9, 0.9))
			_add_prop_sprite(root, "MarcoPedraSul", Vector2(560, 420), "res://assets/sprites/objects/marco_pedra_milestone.png", Color.WHITE, Vector2(0.95, 0.95))
			_add_point_light(root, Vector2(300, 190), Color(1.0, 0.85, 0.55), 1.2)
			_add_point_light(root, Vector2(400, 290), Color(0.45, 1.0, 0.7), 1.4)
		MapKind.ESTRADA:
			_add_prop_sprite(root, "MarcoNenAssoc", Vector2(360, 200), "res://assets/sprites/objects/nen_stone_monolith.png", Color(0.9, 0.95, 1.0), Vector2(1.0, 1.0))
			for ly in [120.0, 280.0, 440.0]:
				_add_prop_sprite(root, "LanternaE_%d" % int(ly), Vector2(340, ly), "res://assets/sprites/objects/hunter_road_lantern.png", Color.WHITE, Vector2(1, 1))
				_add_prop_sprite(root, "LanternaD_%d" % int(ly), Vector2(460, ly), "res://assets/sprites/objects/hunter_road_lantern.png", Color.WHITE, Vector2(1, 1))
				_add_point_light(root, Vector2(340, ly - 10), Color(1.0, 0.8, 0.5), 1.1)
				_add_point_light(root, Vector2(460, ly - 10), Color(1.0, 0.8, 0.5), 1.1)
		MapKind.DUNGEON:
			for p in [Vector2(120, 300), Vector2(520, 300), Vector2(160, 180), Vector2(480, 180), Vector2(320, 260)]:
				_add_prop_sprite(root, "TochaRuinas_%d_%d" % [int(p.x), int(p.y)], p, "res://assets/sprites/objects/ruin_nen_torch.png", Color(0.7, 1.0, 0.75), Vector2(1, 1))
				_add_point_light(root, p + Vector2(0, -12), Color(0.35, 1.0, 0.55), 1.3)
			_add_prop_sprite(root, "MonolitoBoss", Vector2(320, 80), "res://assets/sprites/objects/nen_stone_monolith.png", Color(1.0, 0.75, 0.35), Vector2(1.1, 1.1))
		MapKind.VALE:
			_add_prop_sprite(root, "MonolitoVila", Vector2(105 * 16, 255 * 16), "res://assets/sprites/objects/nen_stone_monolith.png", Color.WHITE, Vector2(1.2, 1.2))
			_add_point_light(root, Vector2(105 * 16, 250 * 16), Color(0.5, 0.9, 1.0), 1.6)
		MapKind.YORKNEW:
			for x in [400.0, 1200.0, 2000.0, 2800.0, 3600.0]:
				_add_prop_sprite(root, "PosteYork_%d" % int(x), Vector2(x, -80), "res://assets/sprites/objects/hunter_road_lantern.png", Color(0.85, 0.9, 1.0), Vector2(1.1, 1.1))
				_add_prop_sprite(root, "PosteYorkS_%d" % int(x), Vector2(x, 120), "res://assets/sprites/objects/hunter_road_lantern.png", Color(0.85, 0.9, 1.0), Vector2(1.1, 1.1))
				_add_point_light(root, Vector2(x, -90), Color(0.55, 0.7, 1.0), 1.35)
				_add_point_light(root, Vector2(x, 110), Color(1.0, 0.55, 0.35), 1.2)
			_add_prop_sprite(root, "MarcoLeilao", Vector2(200, 0), "res://assets/sprites/objects/nen_stone_monolith.png", Color(0.7, 0.85, 1.0), Vector2(1.15, 1.15))
			_add_prop_sprite(root, "MarcoAranha", Vector2(3800, -40), "res://assets/sprites/objects/nen_stone_monolith.png", Color(0.95, 0.45, 0.55), Vector2(1.2, 1.2))
		MapKind.KUKUROO:
			_add_prop_sprite(root, "PortaoTesteProp", Vector2(120, 0), "res://assets/sprites/objects/portao_padokia_arch.png", Color(0.85, 0.88, 0.8), Vector2(1.0, 1.0))
			_add_prop_sprite(root, "MarcoPedraPortao", Vector2(280, 40), "res://assets/sprites/objects/marco_pedra_milestone.png", Color.WHITE, Vector2(1.0, 1.0))
			for x in [600.0, 1000.0, 1400.0, 1800.0, 2200.0, 2600.0, 3000.0, 3400.0]:
				_add_prop_sprite(root, "TochaAlameda_%d" % int(x), Vector2(x, -60), "res://assets/sprites/objects/ruin_nen_torch.png", Color(0.9, 1.0, 0.85), Vector2(1, 1))
				_add_prop_sprite(root, "LanternaAlameda_%d" % int(x), Vector2(x, 90), "res://assets/sprites/objects/hunter_road_lantern.png", Color(0.95, 1.0, 0.9), Vector2(1, 1))
				_add_point_light(root, Vector2(x, -70), Color(0.45, 1.0, 0.55), 1.25)
				_add_point_light(root, Vector2(x, 80), Color(1.0, 0.85, 0.55), 1.1)
			for x in [800.0, 1600.0, 2400.0, 3200.0]:
				_add_prop_sprite(root, "ArbustoAlameda_%d" % int(x), Vector2(x, -100), "res://assets/sprites/objects/lobby_bush_flowers_decor.png", Color(0.75, 0.9, 0.7), Vector2(0.9, 0.9))
				_add_prop_sprite(root, "ArbustoAlamedaS_%d" % int(x), Vector2(x + 40, 110), "res://assets/sprites/objects/lobby_bush_flowers_decor.png", Color(0.7, 0.85, 0.65), Vector2(0.85, 0.85))
			_add_prop_sprite(root, "MarcoMansao", Vector2(2500, 40), "res://assets/sprites/objects/nen_stone_monolith.png", Color(0.55, 0.7, 0.95), Vector2(1.25, 1.25))
			_add_prop_sprite(root, "MarcoTrono", Vector2(3400, -40), "res://assets/sprites/objects/nen_stone_monolith.png", Color(0.7, 0.55, 0.9), Vector2(1.3, 1.3))
		MapKind.ARENA:
			for x in [300.0, 700.0, 1100.0, 1500.0, 1900.0, 2300.0, 2700.0, 3100.0, 3500.0]:
				_add_prop_sprite(root, "LanternaArenaN_%d" % int(x), Vector2(x, -90), "res://assets/sprites/objects/hunter_road_lantern.png", Color(0.95, 0.9, 1.0), Vector2(1.1, 1.1))
				_add_prop_sprite(root, "LanternaArenaS_%d" % int(x), Vector2(x, 110), "res://assets/sprites/objects/hunter_road_lantern.png", Color(0.95, 0.9, 1.0), Vector2(1.1, 1.1))
				_add_point_light(root, Vector2(x, -100), Color(0.7, 0.8, 1.0), 1.3)
				_add_point_light(root, Vector2(x, 100), Color(1.0, 0.7, 0.45), 1.15)
			for x in [900.0, 1300.0, 1700.0, 2100.0, 2600.0]:
				_add_prop_sprite(root, "BonecoTreino_%d" % int(x), Vector2(x, 70), "res://assets/sprites/objects/boneco_treino_dummy.png", Color.WHITE, Vector2(1.0, 1.0))
			_add_prop_sprite(root, "MarcoRecepcao", Vector2(160, 0), "res://assets/sprites/objects/marco_pedra_milestone.png", Color.WHITE, Vector2(1.1, 1.1))
			_add_prop_sprite(root, "MonolitoDojo", Vector2(1100, -40), "res://assets/sprites/objects/nen_stone_monolith.png", Color(0.65, 0.9, 1.0), Vector2(1.15, 1.15))
			_add_prop_sprite(root, "MonolitoTopo", Vector2(3400, -20), "res://assets/sprites/objects/nen_stone_monolith.png", Color(1.0, 0.55, 0.7), Vector2(1.25, 1.25))


func _add_prop_sprite(parent: Node2D, nome: String, pos: Vector2, tex_path: String, modulate: Color, scale: Vector2) -> void:
	var n := Node2D.new()
	n.name = nome
	n.position = pos
	n.z_index = 1
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.centered = true
	spr.position = Vector2(0, -8)
	spr.modulate = modulate
	spr.scale = scale
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if ResourceLoader.exists(tex_path):
		spr.texture = load(tex_path)
	else:
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.modulate = modulate * Color(0.85, 0.95, 1.0, 0.95)
	n.add_child(spr)
	parent.add_child(n)


func _add_point_light(parent: Node2D, pos: Vector2, cor: Color, tex_scale: float) -> void:
	var light := PointLight2D.new()
	light.position = pos
	light.color = cor
	light.energy = 0.9
	light.texture_scale = tex_scale
	var grad := GradientTexture2D.new()
	grad.width = 64
	grad.height = 64
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.5)
	grad.fill_to = Vector2(0.5, 0.0)
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	grad.gradient = g
	light.texture = grad
	light.blend_mode = Light2D.BLEND_MODE_ADD
	parent.add_child(light)
