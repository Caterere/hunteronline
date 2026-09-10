class_name WorldDensityKit
extends Node2D

## Hunter Online — Phase 2 world density (Prompt Library §97).
## Soft olive grass / jagged dirt / bubbly canopy trees — calibrated to
## assets/reference/world_detail_grass_dirt_trees_ref.png

enum KitKind { ESTRADA, FLORESTA }

const TILESET_PHASE2 := "res://assets/sprites/tilesets/pixellab/phase2_grass_dirt_wang.png"
const TILESET_FALLBACK := "res://assets/sprites/tilesets/pixellab/calibration_grass_dirt_wang.png"

const TREE_GREEN_A := "res://assets/sprites/objects/phase2_tree_green_a.png"
const TREE_GREEN_B := "res://assets/sprites/objects/phase2_tree_green_b.png"
const TREE_AUTUMN := "res://assets/sprites/objects/phase2_tree_autumn_a.png"
const BUSH_BERRY := "res://assets/sprites/objects/phase2_bush_berry.png"
const BUSH_ROUND := "res://assets/sprites/objects/phase2_bush_round.png"
const ROCK_BOULDER := "res://assets/sprites/objects/phase2_rock_boulder.png"
const ROCK_CLUSTER := "res://assets/sprites/objects/phase2_rock_cluster.png"
const FLOWERS := "res://assets/sprites/objects/phase2_flowers_white.png"
const STUMP := "res://assets/sprites/objects/phase2_stump.png"

@export var kit_kind: KitKind = KitKind.ESTRADA


static func attach(mapa: Node2D, kind: KitKind) -> WorldDensityKit:
	if mapa == null:
		return null
	var existing := mapa.get_node_or_null("WorldDensityKit") as WorldDensityKit
	if existing != null:
		return existing
	var kit := WorldDensityKit.new()
	kit.name = "WorldDensityKit"
	kit.kit_kind = kind
	mapa.add_child(kit)
	return kit


func _ready() -> void:
	_aplicar_terreno()
	_espalhar_vegetacao()


func _tileset_path() -> String:
	if ResourceLoader.exists(TILESET_PHASE2):
		return TILESET_PHASE2
	return TILESET_FALLBACK


func _aplicar_terreno() -> void:
	var path := _tileset_path()
	if not ResourceLoader.exists(path):
		return
	var mapa := get_parent() as Node2D
	if mapa == null:
		return
	var layer: TileMapLayer = mapa.get_node_or_null("Caminhos_TileMapLayer") as TileMapLayer
	if layer == null:
		layer = mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	if layer == null:
		return
	var ts := _garantir_fonte(layer, path)
	if ts < 0:
		return

	var dirt := Vector2i(0, 0)
	var grass := Vector2i(3, 3)
	var edge_l := Vector2i(1, 0)
	var edge_r := Vector2i(0, 1)
	var edge_t := Vector2i(2, 0)
	var edge_b := Vector2i(0, 2)

	match kit_kind:
		KitKind.ESTRADA:
			# Caminho central irregular (dirt) com bordas jagged de grama
			for ty in range(4, 36):
				var wobble := int(sin(float(ty) * 0.7) * 1.5)
				var x0 := 23 + wobble
				var x1 := 26 + wobble
				for tx in range(x0, x1 + 1):
					layer.set_cell(Vector2i(tx, ty), ts, dirt)
				layer.set_cell(Vector2i(x0 - 1, ty), ts, edge_l)
				layer.set_cell(Vector2i(x1 + 1, ty), ts, edge_r)
				if ty % 4 == 0:
					layer.set_cell(Vector2i(x0 - 2, ty), ts, grass)
					layer.set_cell(Vector2i(x1 + 2, ty), ts, grass)
				# Patches laterais de terra (clareiras)
				if ty % 7 == 0:
					layer.set_cell(Vector2i(18, ty), ts, dirt)
					layer.set_cell(Vector2i(17, ty), ts, edge_l)
					layer.set_cell(Vector2i(19, ty), ts, edge_r)
					layer.set_cell(Vector2i(31, ty), ts, dirt)
					layer.set_cell(Vector2i(30, ty), ts, edge_l)
					layer.set_cell(Vector2i(32, ty), ts, edge_r)
		KitKind.FLORESTA:
			# Clareiras de terra + manchas de grama rica ao longo do mapa
			var rng := RandomNumberGenerator.new()
			rng.seed = 0xF105E57A
			for ty in range(3, 37):
				for tx in range(3, 47):
					var h: int = int(rng.randi_range(0, 100))
					if abs(tx - 25) <= 2:
						layer.set_cell(Vector2i(tx, ty), ts, dirt)
					elif abs(tx - 25) == 3:
						layer.set_cell(Vector2i(tx, ty), ts, edge_l if tx < 25 else edge_r)
					elif h < 6:
						layer.set_cell(Vector2i(tx, ty), ts, dirt)
					elif h < 10:
						layer.set_cell(Vector2i(tx, ty), ts, edge_t if (tx + ty) % 2 == 0 else edge_b)
					elif h < 18:
						layer.set_cell(Vector2i(tx, ty), ts, grass)


func _garantir_fonte(layer: TileMapLayer, tex_path: String) -> int:
	if layer.tile_set == null:
		layer.tile_set = TileSet.new()
	var ts: TileSet = layer.tile_set
	var fname := tex_path.get_file()
	for i in ts.get_source_count():
		var sid := ts.get_source_id(i)
		var src := ts.get_source(sid)
		if src is TileSetAtlasSource:
			var atlas := src as TileSetAtlasSource
			if atlas.texture != null and str(atlas.texture.resource_path).ends_with(fname):
				return sid
	var tex: Texture2D = load(tex_path)
	if tex == null:
		return -1
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(16, 16)
	for y in range(4):
		for x in range(4):
			atlas.create_tile(Vector2i(x, y))
	var new_id := 91
	while ts.has_source(new_id):
		new_id += 1
	ts.add_source(atlas, new_id)
	return new_id


func _espalhar_vegetacao() -> void:
	if get_node_or_null("DensityProps") != null:
		return
	var root := Node2D.new()
	root.name = "DensityProps"
	add_child(root)

	match kit_kind:
		KitKind.ESTRADA:
			_layout_estrada(root)
		KitKind.FLORESTA:
			_layout_floresta(root)


func _layout_estrada(root: Node2D) -> void:
	# Bordas da estrada densas — sem bloquear o caminho central (~400x)
	var trees := [
		[Vector2(260, 140), TREE_GREEN_A],
		[Vector2(540, 160), TREE_GREEN_B],
		[Vector2(240, 260), TREE_AUTUMN],
		[Vector2(560, 300), TREE_GREEN_A],
		[Vector2(250, 400), TREE_GREEN_B],
		[Vector2(550, 420), TREE_AUTUMN],
		[Vector2(270, 500), TREE_GREEN_A],
		[Vector2(530, 520), TREE_GREEN_B],
	]
	for i in trees.size():
		var t: Array = trees[i]
		_add_prop(root, "P2Tree_%d" % i, t[0], t[1], Vector2(0, -22), true)

	var bushes := [
		[Vector2(310, 180), BUSH_BERRY],
		[Vector2(490, 200), BUSH_ROUND],
		[Vector2(300, 320), BUSH_ROUND],
		[Vector2(500, 360), BUSH_BERRY],
		[Vector2(320, 460), BUSH_BERRY],
		[Vector2(480, 480), BUSH_ROUND],
	]
	for i in bushes.size():
		var b: Array = bushes[i]
		_add_prop(root, "P2Bush_%d" % i, b[0], b[1], Vector2(0, -6), false)

	_add_prop(root, "P2Rock_0", Vector2(330, 220), ROCK_BOULDER, Vector2(0, -4), true)
	_add_prop(root, "P2Rock_1", Vector2(470, 340), ROCK_CLUSTER, Vector2(0, -4), true)
	_add_prop(root, "P2Rock_2", Vector2(340, 480), ROCK_CLUSTER, Vector2(0, -4), true)
	_add_prop(root, "P2Stump_0", Vector2(460, 240), STUMP, Vector2(0, -4), true)

	for i in 8:
		var fx := 340.0 + float(i % 4) * 40.0
		var fy := 150.0 + float(i / 4) * 180.0
		_add_prop(root, "P2Flower_%d" % i, Vector2(fx, fy), FLOWERS, Vector2(0, 0), false)


func _layout_floresta(root: Node2D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 0xDE55E57A
	var tree_pool: Array[String] = [TREE_GREEN_A, TREE_GREEN_B, TREE_AUTUMN]
	var n := 0
	for ty in range(90, 560, 70):
		for tx in [120, 180, 620, 680]:
			var path: String = tree_pool[n % tree_pool.size()]
			var jitter := Vector2(rng.randf_range(-18, 18), rng.randf_range(-12, 12))
			_add_prop(root, "P2FTree_%d" % n, Vector2(tx, ty) + jitter, path, Vector2(0, -22), true)
			n += 1
	# Interior light density (not on main path x~400)
	for i in 10:
		var x := 220.0 + float(i % 5) * 90.0
		if abs(x - 400.0) < 50.0:
			x += 80.0 if x < 400.0 else -80.0
		var y := 140.0 + float(i / 5) * 200.0 + rng.randf_range(-20, 20)
		var path2: String = tree_pool[i % tree_pool.size()]
		_add_prop(root, "P2FTreeIn_%d" % i, Vector2(x, y), path2, Vector2(0, -22), true)

	for i in 12:
		var bx := 150.0 + float(i % 6) * 100.0
		var by := 160.0 + float(i / 6) * 220.0
		if abs(bx - 400.0) < 40.0:
			continue
		var bp: String = BUSH_BERRY if i % 2 == 0 else BUSH_ROUND
		_add_prop(root, "P2FBush_%d" % i, Vector2(bx, by), bp, Vector2(0, -6), false)

	_add_prop(root, "P2FRock_0", Vector2(200, 300), ROCK_BOULDER, Vector2(0, -4), true)
	_add_prop(root, "P2FRock_1", Vector2(600, 260), ROCK_CLUSTER, Vector2(0, -4), true)
	_add_prop(root, "P2FRock_2", Vector2(240, 480), ROCK_CLUSTER, Vector2(0, -4), true)
	_add_prop(root, "P2FRock_3", Vector2(560, 500), ROCK_BOULDER, Vector2(0, -4), true)
	_add_prop(root, "P2FStump_0", Vector2(320, 200), STUMP, Vector2(0, -4), true)
	_add_prop(root, "P2FStump_1", Vector2(480, 420), STUMP, Vector2(0, -4), true)

	for i in 14:
		var fx := 160.0 + float(i % 7) * 80.0
		var fy := 120.0 + float(i / 7) * 240.0
		_add_prop(root, "P2FFlower_%d" % i, Vector2(fx, fy), FLOWERS, Vector2(0, 0), false)


func _add_prop(parent: Node2D, nome: String, pos: Vector2, tex_path: String, spr_off: Vector2, collide: bool) -> void:
	if not ResourceLoader.exists(tex_path):
		return
	var body := StaticBody2D.new()
	body.name = nome
	body.position = pos
	body.y_sort_enabled = true
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load(tex_path)
	spr.centered = true
	spr.position = spr_off
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(spr)
	if collide:
		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 6.0 if "Rock" in nome or "Stump" in nome else 8.0
		col.shape = shape
		col.position = Vector2(0, -2)
		body.add_child(col)
	parent.add_child(body)
