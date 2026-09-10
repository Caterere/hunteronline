class_name WorldLandmarkKit
extends Node2D

## Hunter Online — Phase 4 landmarks + ambient NPC/enemy (ART_PIPELINE_CANON).

enum KitKind { ESTRADA, FLORESTA }

const ARCH := "res://assets/sprites/objects/phase4_landmark_hunter_arch.png"
const SHRINE := "res://assets/sprites/objects/phase4_landmark_nen_shrine.png"
const PILLAR := "res://assets/sprites/objects/phase4_landmark_ruin_pillar.png"
const GUARD_SHEET := "res://assets/sprites/characters/npc_phase4_guarda_estrada_8dir.png"
const BEAST_SHEET := "res://assets/sprites/characters/enemy_phase4_fera_padokia_8dir.png"

@export var kit_kind: KitKind = KitKind.ESTRADA


static func attach(mapa: Node2D, kind: KitKind) -> WorldLandmarkKit:
	if mapa == null:
		return null
	var existing := mapa.get_node_or_null("WorldLandmarkKit") as WorldLandmarkKit
	if existing != null:
		return existing
	var kit := WorldLandmarkKit.new()
	kit.name = "WorldLandmarkKit"
	kit.kit_kind = kind
	mapa.add_child(kit)
	return kit


func _ready() -> void:
	_colocar_landmarks()
	_colocar_npc_ambient()
	_colocar_enemy_ambient()


func _colocar_landmarks() -> void:
	if get_node_or_null("Phase4Landmarks") != null:
		return
	var root := Node2D.new()
	root.name = "Phase4Landmarks"
	add_child(root)
	match kit_kind:
		KitKind.ESTRADA:
			_add_prop(root, "P4Arch_Norte", Vector2(400, 80), ARCH, Vector2(0, -24), true, 10.0)
			_add_prop(root, "P4Pillar_Oeste", Vector2(260, 300), PILLAR, Vector2(0, -22), true, 7.0)
			_add_prop(root, "P4Shrine_Leste", Vector2(540, 360), SHRINE, Vector2(0, -22), true, 8.0)
		KitKind.FLORESTA:
			_add_prop(root, "P4Shrine_Centro", Vector2(400, 280), SHRINE, Vector2(0, -22), true, 8.0)
			_add_prop(root, "P4Pillar_Norte", Vector2(280, 140), PILLAR, Vector2(0, -22), true, 7.0)
			_add_prop(root, "P4Pillar_Sul", Vector2(520, 460), PILLAR, Vector2(0, -22), true, 7.0)
			_add_prop(root, "P4Arch_Sul", Vector2(400, 560), ARCH, Vector2(0, -24), true, 10.0)


func _colocar_npc_ambient() -> void:
	if kit_kind != KitKind.ESTRADA:
		return
	if get_node_or_null("GuardaEstradaAmbient") != null:
		return
	if not ResourceLoader.exists(GUARD_SHEET):
		return
	var npc := StaticBody2D.new()
	npc.name = "GuardaEstradaAmbient"
	npc.set("npc_name", "Guarda Estrada Padokia")
	npc.position = Vector2(370, 160)
	npc.y_sort_enabled = true

	var col := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 6.0
	col.shape = circ
	col.position = Vector2(0, -3)
	npc.add_child(col)

	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load(GUARD_SHEET)
	spr.hframes = 8
	spr.vframes = 1
	spr.frame = 0
	spr.position = Vector2(0, -17)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.add_child(spr)

	var lbl := Label.new()
	lbl.text = "Guarda\n[E] Conversar"
	lbl.position = Vector2(-36, -40)
	lbl.custom_minimum_size = Vector2(72, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.75, 0.85, 1.0))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	npc.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Falar com Guarda da Estrada"
	inter.interaction_radius = 26.0
	inter.interacted.connect(_on_guarda_interact)
	npc.add_child(inter)
	add_child(npc)


func _colocar_enemy_ambient() -> void:
	if kit_kind != KitKind.FLORESTA:
		return
	if get_node_or_null("FeraPadokiaAmbient") != null:
		return
	if not ResourceLoader.exists(BEAST_SHEET):
		return
	# Visual ambient marker (not a full EnemySystem spawn) — shows Phase 4 enemy art in-world.
	var node := Node2D.new()
	node.name = "FeraPadokiaAmbient"
	node.position = Vector2(520, 320)
	node.z_index = 1
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load(BEAST_SHEET)
	spr.hframes = 8
	spr.vframes = 1
	spr.frame = 0
	spr.position = Vector2(0, -14)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(spr)
	var lbl := Label.new()
	lbl.text = "Fera de Padokia"
	lbl.position = Vector2(-40, -36)
	lbl.custom_minimum_size = Vector2(80, 12)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 6, Color(1.0, 0.7, 0.55))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	node.add_child(lbl)
	add_child(node)


func _on_guarda_interact(_p) -> void:
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(
			"🛡️ Guarda: 'O arco da Associação marca a rota. Na floresta, o santuário de Nen "
			+ "ainda pulsa — e as feras sentem isso.'"
		)


func _add_prop(parent: Node2D, nome: String, pos: Vector2, tex_path: String, spr_off: Vector2, collide: bool, radius: float) -> void:
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
		shape.radius = radius
		col.shape = shape
		col.position = Vector2(0, -2)
		body.add_child(col)
	parent.add_child(body)
