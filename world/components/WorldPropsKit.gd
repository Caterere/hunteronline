class_name WorldPropsKit
extends Node2D

## Hunter Online — Phase 3 props (Prompt Library §30–36 / ART_PIPELINE_CANON).
## Fences, signs, crates, barrel, well, lantern along Estrada / Floresta.

enum KitKind { ESTRADA, FLORESTA }

const FENCE := "res://assets/sprites/objects/phase3_fence_wood.png"
const FENCE_POST := "res://assets/sprites/objects/phase3_fence_wood_post.png"
const SIGN := "res://assets/sprites/objects/phase3_signpost.png"
const BARREL := "res://assets/sprites/objects/phase3_barrel.png"
const CRATE := "res://assets/sprites/objects/phase3_crate.png"
const CRATE_L := "res://assets/sprites/objects/phase3_crate_large.png"
const WELL := "res://assets/sprites/objects/phase3_well.png"
const LANTERN := "res://assets/sprites/objects/phase3_lantern_post.png"

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
	_add_prop(root, "P3Crate_0", Vector2(470, 260), CRATE, Vector2(0, -6), true)
	_add_prop(root, "P3CrateL_0", Vector2(470, 400), CRATE_L, Vector2(0, -6), true)
	_add_prop(root, "P3Well_0", Vector2(520, 180), WELL, Vector2(0, -12), true)

	for i in 4:
		var y := 140.0 + float(i) * 110.0
		_add_prop(root, "P3LanternL_%d" % i, Vector2(300, y), LANTERN, Vector2(0, -18), true)
		_add_prop(root, "P3LanternR_%d" % i, Vector2(500, y), LANTERN, Vector2(0, -18), true)


func _layout_floresta(root: Node2D) -> void:
	_add_prop(root, "P3FSign_Entrada", Vector2(400, 90), SIGN, Vector2(0, -18), true)
	_add_prop(root, "P3FSign_Ruinas", Vector2(400, 540), SIGN, Vector2(0, -18), true)
	_add_prop(root, "P3FWell_Clareira", Vector2(280, 300), WELL, Vector2(0, -12), true)

	for i in 5:
		var y := 140.0 + float(i) * 80.0
		_add_prop(root, "P3FFenceL_%d" % i, Vector2(200, y), FENCE, Vector2(0, -8), true)
		_add_prop(root, "P3FFenceR_%d" % i, Vector2(600, y), FENCE, Vector2(0, -8), true)

	_add_prop(root, "P3FBarrel_0", Vector2(240, 220), BARREL, Vector2(0, -6), true)
	_add_prop(root, "P3FCrate_0", Vector2(560, 240), CRATE, Vector2(0, -6), true)
	_add_prop(root, "P3FCrate_1", Vector2(560, 280), CRATE_L, Vector2(0, -6), true)
	_add_prop(root, "P3FLantern_0", Vector2(320, 160), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FLantern_1", Vector2(480, 160), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FLantern_2", Vector2(320, 480), LANTERN, Vector2(0, -18), true)
	_add_prop(root, "P3FLantern_3", Vector2(480, 480), LANTERN, Vector2(0, -18), true)


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
