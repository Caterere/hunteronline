class_name WorldFxKit
extends Node2D

## Hunter Online — Phase 5 combat FX + weather + night accents (ART_PIPELINE_CANON).

enum KitKind { ESTRADA, FLORESTA }

const FX_HIT := "res://assets/sprites/effects/phase5_fx_hit.png"
const FX_SLASH := "res://assets/sprites/effects/phase5_fx_slash.png"
const FX_AURA := "res://assets/sprites/effects/phase5_fx_nen_aura.png"
const FX_HEAL := "res://assets/sprites/effects/phase5_fx_heal.png"
const FX_DASH := "res://assets/sprites/effects/phase5_fx_dash_dust.png"
const PUDDLE := "res://assets/sprites/objects/phase5_weather_puddle.png"
const LEAF := "res://assets/sprites/objects/phase5_weather_leaf.png"
const GLOW := "res://assets/sprites/objects/phase5_night_lantern_glow.png"

@export var kit_kind: KitKind = KitKind.ESTRADA


static func attach(mapa: Node2D, kind: KitKind) -> WorldFxKit:
	if mapa == null:
		return null
	var existing := mapa.get_node_or_null("WorldFxKit") as WorldFxKit
	if existing != null:
		return existing
	var kit := WorldFxKit.new()
	kit.name = "WorldFxKit"
	kit.kit_kind = kind
	mapa.add_child(kit)
	return kit


func _ready() -> void:
	_colocar_weather()
	_colocar_night_accents()
	_colocar_fx_showcase()


func _colocar_weather() -> void:
	if get_node_or_null("Phase5Weather") != null:
		return
	var root := Node2D.new()
	root.name = "Phase5Weather"
	root.z_index = 0
	add_child(root)
	match kit_kind:
		KitKind.ESTRADA:
			_add_sprite(root, "P5Puddle_0", Vector2(320, 280), PUDDLE, Vector2.ZERO, 0.85)
			_add_sprite(root, "P5Puddle_1", Vector2(460, 420), PUDDLE, Vector2.ZERO, 0.7)
			_add_sprite(root, "P5Leaf_0", Vector2(380, 200), LEAF, Vector2(0, -4), 1.0)
			_add_sprite(root, "P5Leaf_1", Vector2(520, 340), LEAF, Vector2(0, -4), 0.9)
		KitKind.FLORESTA:
			_add_sprite(root, "P5Puddle_Clareira", Vector2(400, 300), PUDDLE, Vector2.ZERO, 0.8)
			_add_sprite(root, "P5Leaf_0", Vector2(300, 180), LEAF, Vector2(0, -4), 1.0)
			_add_sprite(root, "P5Leaf_1", Vector2(480, 240), LEAF, Vector2(0, -4), 0.95)
			_add_sprite(root, "P5Leaf_2", Vector2(360, 440), LEAF, Vector2(0, -4), 0.85)


func _colocar_night_accents() -> void:
	if get_node_or_null("Phase5Night") != null:
		return
	var root := Node2D.new()
	root.name = "Phase5Night"
	root.z_index = 2
	add_child(root)
	match kit_kind:
		KitKind.ESTRADA:
			# Near phase3 lantern / road posts
			_add_sprite(root, "P5Glow_LanternN", Vector2(300, 180), GLOW, Vector2(0, -18), 0.75)
			_add_sprite(root, "P5Glow_Arch", Vector2(400, 70), GLOW, Vector2(0, -28), 0.55)
		KitKind.FLORESTA:
			_add_sprite(root, "P5Glow_Shrine", Vector2(400, 260), GLOW, Vector2(0, -26), 0.7)
			_add_sprite(root, "P5Glow_Clareira", Vector2(520, 320), GLOW, Vector2(0, -12), 0.5)


func _colocar_fx_showcase() -> void:
	## Demo strip so Phase 5 combat art is visible in-world without fighting.
	if get_node_or_null("Phase5FxShowcase") != null:
		return
	var root := Node2D.new()
	root.name = "Phase5FxShowcase"
	root.z_index = 3
	add_child(root)
	var base := Vector2(120, 520) if kit_kind == KitKind.ESTRADA else Vector2(140, 100)
	_add_sprite(root, "P5Fx_Hit", base, FX_HIT, Vector2.ZERO, 1.0)
	_add_sprite(root, "P5Fx_Slash", base + Vector2(48, 0), FX_SLASH, Vector2.ZERO, 1.0)
	_add_sprite(root, "P5Fx_Aura", base + Vector2(108, 0), FX_AURA, Vector2.ZERO, 0.9)
	_add_sprite(root, "P5Fx_Heal", base + Vector2(168, 0), FX_HEAL, Vector2.ZERO, 1.0)
	_add_sprite(root, "P5Fx_Dash", base + Vector2(216, 0), FX_DASH, Vector2.ZERO, 1.0)


func _add_sprite(parent: Node2D, nome: String, pos: Vector2, tex_path: String, spr_off: Vector2, alpha: float) -> void:
	if not ResourceLoader.exists(tex_path):
		return
	var n := Node2D.new()
	n.name = nome
	n.position = pos
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load(tex_path)
	spr.centered = true
	spr.position = spr_off
	spr.modulate = Color(1, 1, 1, alpha)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	n.add_child(spr)
	parent.add_child(n)
