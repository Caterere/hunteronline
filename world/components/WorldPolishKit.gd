class_name WorldPolishKit
extends Node2D

## Hunter Online — Phase 6 map polish + environmental storytelling + secrets.

enum KitKind { ESTRADA, FLORESTA }

const STORY_CAMP := "res://assets/sprites/objects/phase6_story_abandoned_camp.png"
const STORY_CART := "res://assets/sprites/objects/phase6_story_broken_cart.png"
const STORY_SCUFFLE := "res://assets/sprites/objects/phase6_story_scuffle_mark.png"
const STORY_BANNER := "res://assets/sprites/objects/phase6_story_torn_banner.png"
const STORY_WEAPON := "res://assets/sprites/objects/phase6_story_broken_weapon.png"
const SECRET_STUMP := "res://assets/sprites/objects/phase6_secret_hollow_stump.png"
const SECRET_ROCK := "res://assets/sprites/objects/phase6_secret_false_rock.png"
const SECRET_GLINT := "res://assets/sprites/objects/phase6_secret_glint.png"
const SECRET_MARKER := "res://assets/sprites/objects/phase6_secret_trail_marker.png"
const POLISH_CRACK := "res://assets/sprites/objects/phase6_polish_path_crack.png"
const POLISH_MOSS := "res://assets/sprites/objects/phase6_polish_moss_patch.png"
const POLISH_FENCE := "res://assets/sprites/objects/phase6_polish_fence_ruin.png"

@export var kit_kind: KitKind = KitKind.ESTRADA


static func attach(mapa: Node2D, kind: KitKind) -> WorldPolishKit:
	if mapa == null:
		return null
	var existing := mapa.get_node_or_null("WorldPolishKit") as WorldPolishKit
	if existing != null:
		return existing
	var kit := WorldPolishKit.new()
	kit.name = "WorldPolishKit"
	kit.kit_kind = kind
	mapa.add_child(kit)
	return kit


func _ready() -> void:
	_colocar_polish()
	_colocar_storytelling()
	_colocar_secrets()


func _colocar_polish() -> void:
	if get_node_or_null("Phase6Polish") != null:
		return
	var root := Node2D.new()
	root.name = "Phase6Polish"
	root.z_index = -1
	add_child(root)
	match kit_kind:
		KitKind.ESTRADA:
			_add_sprite(root, "P6Crack_0", Vector2(340, 240), POLISH_CRACK, Vector2.ZERO, 0.9)
			_add_sprite(root, "P6Crack_1", Vector2(480, 380), POLISH_CRACK, Vector2.ZERO, 0.75)
			_add_sprite(root, "P6Moss_0", Vector2(270, 310), POLISH_MOSS, Vector2.ZERO, 0.85)
			_add_sprite(root, "P6Fence_Ruin", Vector2(560, 220), POLISH_FENCE, Vector2(0, -8), 1.0)
		KitKind.FLORESTA:
			_add_sprite(root, "P6Crack_Clareira", Vector2(420, 320), POLISH_CRACK, Vector2.ZERO, 0.8)
			_add_sprite(root, "P6Moss_0", Vector2(300, 200), POLISH_MOSS, Vector2.ZERO, 0.9)
			_add_sprite(root, "P6Moss_1", Vector2(510, 450), POLISH_MOSS, Vector2.ZERO, 0.8)
			_add_sprite(root, "P6Fence_Ruin", Vector2(220, 360), POLISH_FENCE, Vector2(0, -8), 1.0)


func _colocar_storytelling() -> void:
	if get_node_or_null("Phase6Story") != null:
		return
	var root := Node2D.new()
	root.name = "Phase6Story"
	root.z_index = 0
	add_child(root)
	match kit_kind:
		KitKind.ESTRADA:
			_add_sprite(root, "P6Camp", Vector2(240, 430), STORY_CAMP, Vector2(0, -10), 1.0, true)
			_add_sprite(root, "P6Cart", Vector2(600, 300), STORY_CART, Vector2(0, -12), 1.0, true)
			_add_sprite(root, "P6Scuffle", Vector2(390, 250), STORY_SCUFFLE, Vector2.ZERO, 0.85)
			_add_sprite(root, "P6Banner", Vector2(450, 140), STORY_BANNER, Vector2(0, -14), 1.0, true)
			_add_sprite(root, "P6Weapon", Vector2(520, 400), STORY_WEAPON, Vector2.ZERO, 0.95)
		KitKind.FLORESTA:
			_add_sprite(root, "P6Camp", Vector2(260, 420), STORY_CAMP, Vector2(0, -10), 1.0, true)
			_add_sprite(root, "P6Scuffle", Vector2(440, 300), STORY_SCUFFLE, Vector2.ZERO, 0.85)
			_add_sprite(root, "P6Banner", Vector2(340, 160), STORY_BANNER, Vector2(0, -14), 1.0, true)
			_add_sprite(root, "P6Weapon", Vector2(560, 380), STORY_WEAPON, Vector2.ZERO, 0.95)
			_add_sprite(root, "P6Cart", Vector2(180, 240), STORY_CART, Vector2(0, -12), 0.9, true)


func _colocar_secrets() -> void:
	if get_node_or_null("Phase6Secrets") != null:
		return
	var root := Node2D.new()
	root.name = "Phase6Secrets"
	root.z_index = 1
	add_child(root)
	match kit_kind:
		KitKind.ESTRADA:
			_add_sprite(root, "P6Secret_Stump", Vector2(200, 180), SECRET_STUMP, Vector2(0, -6), 1.0, true)
			_add_sprite(root, "P6Secret_Rock", Vector2(620, 460), SECRET_ROCK, Vector2(0, -4), 1.0, true)
			_add_sprite(root, "P6Secret_Marker", Vector2(330, 360), SECRET_MARKER, Vector2.ZERO, 0.9)
			_add_sprite(root, "P6Secret_Glint", Vector2(205, 170), SECRET_GLINT, Vector2(0, -10), 0.85)
		KitKind.FLORESTA:
			_add_sprite(root, "P6Secret_Stump", Vector2(500, 180), SECRET_STUMP, Vector2(0, -6), 1.0, true)
			_add_sprite(root, "P6Secret_Rock", Vector2(240, 500), SECRET_ROCK, Vector2(0, -4), 1.0, true)
			_add_sprite(root, "P6Secret_Marker", Vector2(380, 400), SECRET_MARKER, Vector2.ZERO, 0.9)
			_add_sprite(root, "P6Secret_Glint", Vector2(505, 170), SECRET_GLINT, Vector2(0, -10), 0.85)
			_add_sprite(root, "P6Secret_Marker2", Vector2(560, 280), SECRET_MARKER, Vector2.ZERO, 0.75)


func _add_sprite(
	parent: Node2D,
	nome: String,
	pos: Vector2,
	tex_path: String,
	spr_off: Vector2,
	alpha: float,
	y_sort: bool = false
) -> void:
	if not ResourceLoader.exists(tex_path):
		return
	var n := Node2D.new()
	n.name = nome
	n.position = pos
	n.y_sort_enabled = y_sort
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load(tex_path)
	spr.centered = true
	spr.position = spr_off
	spr.modulate = Color(1, 1, 1, alpha)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	n.add_child(spr)
	parent.add_child(n)
