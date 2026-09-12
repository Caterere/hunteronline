class_name WorldPropsKit
extends Node2D

## Hunter Online — Phase 3 props (Prompt Library §30–36 / ART_PIPELINE_CANON).
## Fences, signs, crates, barrel, well, lantern along Estrada / Floresta / Yorknew / Arena.

enum KitKind { ESTRADA, FLORESTA, YORKNEW, ARENA, DUNGEON, CASA }

const FENCE := "res://assets/sprites/objects/phase3_fence_wood.png"
const FENCE_POST := "res://assets/sprites/objects/phase3_fence_wood_post.png"
const SIGN := "res://assets/sprites/objects/phase3_signpost.png"
const BARREL := "res://assets/sprites/objects/phase3_barrel.png"
const CRATE := "res://assets/sprites/objects/phase3_crate.png"
const CRATE_L := "res://assets/sprites/objects/phase3_crate_large.png"
const WELL := "res://assets/sprites/objects/phase3_well.png"
const LANTERN := "res://assets/sprites/objects/phase3_lantern_post.png"
const YORK_CRATE := "res://assets/sprites/objects/yorknew_street_crate.png"
const STALL := "res://assets/sprites/objects/lobby_stall_decor.png"
const WAGON := "res://assets/sprites/objects/carroca_mercador_wagon.png"
const ROAD_LANTERN := "res://assets/sprites/objects/hunter_road_lantern.png"
const TRAIN_POST := "res://assets/sprites/objects/arena_training_post.png"
const DUMMY := "res://assets/sprites/objects/boneco_treino_dummy.png"
const TORCH := "res://assets/sprites/objects/ruin_nen_torch.png"
const PILLAR := "res://assets/sprites/objects/phase4_landmark_ruin_pillar.png"
const CHEST := "res://assets/sprites/objects/chest_01.png"
const MONOLITH := "res://assets/sprites/objects/nen_stone_monolith.png"

@export var kit_kind: KitKind = KitKind.ESTRADA


static func attach(mapa: Node2D, kind: KitKind) -> WorldPropsKit:
	if mapa == null:
		return null
	var existing := mapa.get_node_or_null("WorldPropsKit") as WorldPropsKit
	if existing != null:
		return existing
	var kit := WorldPropsKit.new()
	kit.name = "WorldPropsKit"
	kit.kit_kind = kind
	mapa.add_child(kit)
	return kit


func _ready() -> void:
	_espalhar_props()


func _espalhar_props() -> void:
	if get_node_or_null("Phase3Props") != null:
		return
	var root := Node2D.new()
	root.name = "Phase3Props"
	add_child(root)
	match kit_kind:
		KitKind.ESTRADA:
			_layout_estrada(root)
		KitKind.FLORESTA:
			_layout_floresta(root)
		KitKind.YORKNEW:
			_layout_yorknew(root)
		KitKind.ARENA:
			_layout_arena(root)
		KitKind.DUNGEON:
			_layout_dungeon(root)
		KitKind.CASA:
			_layout_casa(root)


func _layout_estrada(root: Node2D) -> void:
	# Fence runs along path shoulders (keep center clear ~x400)
	for i in 6:
		var y := 120.0 + float(i) * 70.0
		_add_prop(root, "P3FenceL_%d" % i, Vector2(310, y), FENCE, Vector2(0, -8), true)
		_add_prop(root, "P3FenceR_%d" % i, Vector2(490, y), FENCE, Vector2(0, -8), true)
	_add_prop(root, "P3FencePost_N", Vector2(310, 90), FENCE_POST, Vector2(0, -8), true)
	_add_prop(root, "P3FencePost_S", Vector2(490, 540), FENCE_POST, Vector2(0, -8), true)

	_add_prop(root, "P3Sign_Norte", Vector2(360, 100), SIGN, Vector2(0, -18), true)
	_add_prop(root, "P3Sign_Sul", Vector2(440, 520), SIGN, Vector2(0, -18), true)

	_add_prop(root, "P3Barrel_0", Vector2(330, 280), BARREL, Vector2(0, -6), true)
	_add_prop(root, "P3Barrel_1", Vector2(325, 360), BARREL, Vector2(0, -6), true)
	_add_prop(root, "P3Barrel_2", Vector2(475, 340), BARREL, Vector2(0, -6), true)
	_add_prop(root, "P3Crate_0", Vector2(470, 260), CRATE, Vector2(0, -6), true)
	_add_prop(root, "P3Crate_1", Vector2(325, 200), CRATE, Vector2(0, -6), true)
	_add_prop(root, "P3Crate_2", Vector2(480, 450), CRATE, Vector2(0, -6), true)
	_add_prop(root, "P3CrateL_0", Vector2(470, 400), CRATE_L, Vector2(0, -6), true)
	_add_prop(root, "P3CrateL_1", Vector2(320, 440), CRATE_L, Vector2(0, -6), true)
	_add_prop(root, "P3Well_0", Vector2(520, 180), WELL, Vector2(0, -12), true)
	_add_prop(root, "P3Well_1", Vector2(280, 500), WELL, Vector2(0, -12), true)

	for i in 6:
		var y := 120.0 + float(i) * 80.0
		_add_prop(root, "P3LanternL_%d" % i, Vector2(300, y), LANTERN, Vector2(0, -18), true)
		_add_prop(root, "P3LanternR_%d" % i, Vector2(500, y), LANTERN, Vector2(0, -18), true)

	# Postes extras nas curvas / ombros (centro da estrada livre ~x400)
	_add_prop(root, "P3FencePost_MidL", Vector2(310, 320), FENCE_POST, Vector2(0, -8), true)
	_add_prop(root, "P3FencePost_MidR", Vector2(490, 320), FENCE_POST, Vector2(0, -8), true)
	_add_prop(root, "P3Sign_Camp", Vector2(350, 300), SIGN, Vector2(0, -18), true)


func _layout_floresta(root: Node2D) -> void:
	_add_prop(root, "P3FSign_Entrada", Vector2(400, 90), SIGN, Vector2(0, -18), true)
	_add_prop(root, "P3FSign_Ruinas", Vector2(400, 540), SIGN, Vector2(0, -18), true)
	_add_prop(root, "P3FWell_Clareira", Vector2(280, 300), WELL, Vector2(0, -12), true)

	for i in 5:
		var y := 140.0 + float(i) * 80.0
		_add_prop(root, "P3FFenceL_%d" % i, Vector2(200, y), FENCE, Vector2(0, -8), true)
		_add_prop(root, "P3FFenceR_%d" % i, Vector2(600, y), FENCE, Vector2(0, -8), true)

	_add_prop(root, "P3FBarrel_0", Vector2(240, 220), BARREL, Vector2(0, -6), true)
	_add_prop(root, "P3FBarrel_1", Vector2(250, 380), BARREL, Vector2(0, -6), true)
	_add_prop(root, "P3FBarrel_2", Vector2(550, 360), BARREL, Vector2(0, -6), true)
	_add_prop(root, "P3FCrate_0", Vector2(560, 240), CRATE, Vector2(0, -6), true)
	_add_prop(root, "P3FCrate_1", Vector2(560, 280), CRATE_L, Vector2(0, -6), true)
	_add_prop(root, "P3FCrate_2", Vector2(240, 260), CRATE, Vector2(0, -6), true)
	_add_prop(root, "P3FCrate_3", Vector2(230, 450), CRATE_L, Vector2(0, -6), true)
	_add_prop(root, "P3FLantern_0", Vector2(320, 160), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FLantern_1", Vector2(480, 160), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FLantern_2", Vector2(320, 480), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FLantern_3", Vector2(480, 480), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FLantern_4", Vector2(360, 300), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FLantern_5", Vector2(440, 300), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FSign_Clareira", Vector2(360, 280), SIGN, Vector2(0, -18), true)


func _layout_yorknew(root: Node2D) -> void:
	# Avenida linear (~0..4000): calçada N/S com caixas, barris, barracas e postes.
	# Centro da rua (~y 0) fica livre para o player.
	var xs := [180.0, 420.0, 680.0, 980.0, 1280.0, 1580.0, 1880.0, 2180.0, 2480.0, 2780.0, 3080.0, 3380.0, 3680.0, 3980.0]
	for i in xs.size():
		var x: float = xs[i]
		var side_n := -95.0 if i % 2 == 0 else -115.0
		var side_s := 85.0 if i % 2 == 0 else 105.0
		_add_prop(root, "YkLanternN_%d" % i, Vector2(x, side_n), ROAD_LANTERN, Vector2(0, -18), true)
		_add_prop(root, "YkLanternS_%d" % i, Vector2(x + 40.0, side_s), ROAD_LANTERN, Vector2(0, -18), true)
		_add_prop(root, "YkCrateN_%d" % i, Vector2(x + 55.0, side_n + 25.0), YORK_CRATE, Vector2(0, -6), true)
		_add_prop(root, "YkBarrelS_%d" % i, Vector2(x - 30.0, side_s - 10.0), BARREL, Vector2(0, -6), true)
		if i % 3 == 0:
			_add_prop(root, "YkStall_%d" % i, Vector2(x + 90.0, side_n + 10.0), STALL, Vector2(0, -14), true)
		if i % 4 == 0:
			_add_prop(root, "YkWagon_%d" % i, Vector2(x - 70.0, side_s + 15.0), WAGON, Vector2(0, -12), true)
		if i % 2 == 1:
			_add_prop(root, "YkCrateL_%d" % i, Vector2(x + 20.0, side_s - 25.0), CRATE_L, Vector2(0, -6), true)
			_add_prop(root, "YkSign_%d" % i, Vector2(x - 50.0, side_n + 5.0), SIGN, Vector2(0, -18), true)
	# Marcos de distrito (reforço visual MMORPG urbano)
	_add_prop(root, "YkMarco_Leilao", Vector2(320, -130), SIGN, Vector2(0, -18), true)
	_add_prop(root, "YkMarco_Ruas", Vector2(1600, -130), SIGN, Vector2(0, -18), true)
	_add_prop(root, "YkMarco_Cem", Vector2(2700, -140), SIGN, Vector2(0, -18), true)
	_add_prop(root, "YkMarco_Trupe", Vector2(3700, -130), SIGN, Vector2(0, -18), true)


func _layout_arena(root: Node2D) -> void:
	# Corredor de treino: postes, dummies e caixas nas laterais.
	for i in 8:
		var x := 200.0 + float(i) * 220.0
		_add_prop(root, "ArPostN_%d" % i, Vector2(x, -90), TRAIN_POST, Vector2(0, -16), true)
		_add_prop(root, "ArPostS_%d" % i, Vector2(x + 60.0, 100), TRAIN_POST, Vector2(0, -16), true)
		if i % 2 == 0:
			_add_prop(root, "ArDummy_%d" % i, Vector2(x + 110.0, -40), DUMMY, Vector2(0, -10), true)
		_add_prop(root, "ArCrate_%d" % i, Vector2(x - 40.0, 70), CRATE, Vector2(0, -6), true)
		_add_prop(root, "ArBarrel_%d" % i, Vector2(x + 140.0, 55), BARREL, Vector2(0, -6), true)
		_add_prop(root, "ArLantern_%d" % i, Vector2(x + 30.0, -110), ROAD_LANTERN, Vector2(0, -18), true)


func _layout_dungeon(root: Node2D) -> void:
	# Corredor de ruínas / porão de navio: tochas, pilares, baús e caixotes.
	for i in 10:
		var x := 140.0 + float(i) * 180.0
		_add_prop(root, "DgTorchN_%d" % i, Vector2(x, -80), TORCH, Vector2(0, -14), true)
		_add_prop(root, "DgTorchS_%d" % i, Vector2(x + 50.0, 100), TORCH, Vector2(0, -14), true)
		if i % 2 == 0:
			_add_prop(root, "DgPillar_%d" % i, Vector2(x + 90.0, -30), PILLAR, Vector2(0, -20), true)
		_add_prop(root, "DgCrate_%d" % i, Vector2(x - 35.0, 70), CRATE, Vector2(0, -6), true)
		_add_prop(root, "DgBarrel_%d" % i, Vector2(x + 130.0, 55), BARREL, Vector2(0, -6), true)
		if i % 3 == 0:
			_add_prop(root, "DgChest_%d" % i, Vector2(x + 20.0, -55), CHEST, Vector2(0, -8), true)
	_add_prop(root, "DgMonolith_Boss", Vector2(960, -40), MONOLITH, Vector2(0, -18), true)
	_add_prop(root, "DgSign_Warn", Vector2(280, -110), SIGN, Vector2(0, -18), true)


func _layout_casa(root: Node2D) -> void:
	# Interior de base de caçador (MMORPG 2D): cantos ocupados, centro livre p/ circulação.
	_add_prop(root, "CasaLantern_NW", Vector2(48, 36), LANTERN, Vector2(0, -14), false)
	_add_prop(root, "CasaLantern_NE", Vector2(312, 36), LANTERN, Vector2(0, -14), false)
	_add_prop(root, "CasaLantern_SW", Vector2(48, 188), LANTERN, Vector2(0, -14), false)
	_add_prop(root, "CasaLantern_SE", Vector2(312, 188), LANTERN, Vector2(0, -14), false)
	_add_prop(root, "CasaCrate_A", Vector2(64, 96), CRATE, Vector2(0, -6), true)
	_add_prop(root, "CasaCrate_B", Vector2(86, 108), CRATE, Vector2(0, -6), true)
	_add_prop(root, "CasaCrateL", Vector2(290, 100), CRATE_L, Vector2(0, -6), true)
	_add_prop(root, "CasaBarrel_A", Vector2(70, 160), BARREL, Vector2(0, -6), true)
	_add_prop(root, "CasaBarrel_B", Vector2(300, 160), BARREL, Vector2(0, -6), true)
	_add_prop(root, "CasaChest", Vector2(200, 52), CHEST, Vector2(0, -8), true)
	_add_prop(root, "CasaDummy", Vector2(240, 150), DUMMY, Vector2(0, -10), true)
	_add_prop(root, "CasaTrainPost", Vector2(160, 150), TRAIN_POST, Vector2(0, -16), true)
	_add_prop(root, "CasaSign_Rules", Vector2(120, 44), SIGN, Vector2(0, -18), false)
	_add_prop(root, "CasaCrate_C", Vector2(280, 56), CRATE, Vector2(0, -6), true)
	_add_prop(root, "CasaBarrel_C", Vector2(52, 56), BARREL, Vector2(0, -6), true)


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
		shape.radius = 5.0 if ("Barrel" in nome or "Crate" in nome or "Fence" in nome) else 7.0
		col.shape = shape
		col.position = Vector2(0, -2)
		body.add_child(col)
	parent.add_child(body)
