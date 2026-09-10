class_name CalibrationArtKit
extends Node2D

## Hunter Online — Prompt Library §94 calibration kit.
## Places the first approved PixelLab batch into a small definitive map area.

const TILESET_PATH := "res://assets/sprites/tilesets/pixellab/calibration_grass_dirt_wang.png"
const TREE_A := "res://assets/sprites/objects/calibration_tree_a.png"
const TREE_B := "res://assets/sprites/objects/calibration_tree_b.png"
const BUSH_A := "res://assets/sprites/objects/calibration_bush_a.png"
const ROCK_A := "res://assets/sprites/objects/calibration_rock_a.png"
const ROCK_B := "res://assets/sprites/objects/calibration_rock_b.png"
const GROUND := "res://assets/sprites/objects/calibration_ground_details.png"
const NPC_SHEET := "res://assets/sprites/characters/npc_calibration_viajante_padokia_8dir.png"


static func attach_to_estrada(mapa: Node2D) -> CalibrationArtKit:
	if mapa == null:
		return null
	var existing := mapa.get_node_or_null("CalibrationArtKit") as CalibrationArtKit
	if existing != null:
		return existing
	var kit := CalibrationArtKit.new()
	kit.name = "CalibrationArtKit"
	mapa.add_child(kit)
	return kit


func _ready() -> void:
	_aplicar_tiles_calibracao()
	_espalhar_props()
	_criar_viajante()


func _aplicar_tiles_calibracao() -> void:
	if not ResourceLoader.exists(TILESET_PATH):
		return
	var mapa := get_parent() as Node2D
	if mapa == null:
		return
	var layer: TileMapLayer = mapa.get_node_or_null("Caminhos_TileMapLayer") as TileMapLayer
	if layer == null:
		layer = mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	if layer == null:
		return

	var ts := _garantir_tileset_fonte(layer)
	if ts < 0:
		return

	# Faixa de calibração ao longo da estrada (tiles 16px): dirt path + grass edges
	# Wang sheet 4x4 — tile (0,0) lower/dirt, (3,3) upper/grass approx from PixelLab layout.
	var dirt := Vector2i(0, 0)
	var grass := Vector2i(3, 3)
	var edge_a := Vector2i(1, 0)
	var edge_b := Vector2i(0, 1)
	for ty in range(8, 28):
		for tx in range(23, 27):
			layer.set_cell(Vector2i(tx, ty), ts, dirt)
		layer.set_cell(Vector2i(22, ty), ts, edge_a)
		layer.set_cell(Vector2i(27, ty), ts, edge_b)
		if ty % 3 == 0:
			layer.set_cell(Vector2i(21, ty), ts, grass)
			layer.set_cell(Vector2i(28, ty), ts, grass)


func _garantir_tileset_fonte(layer: TileMapLayer) -> int:
	if layer.tile_set == null:
		layer.tile_set = TileSet.new()
	var ts: TileSet = layer.tile_set
	# Reuse existing source if already registered
	for i in ts.get_source_count():
		var sid := ts.get_source_id(i)
		var src := ts.get_source(sid)
		if src is TileSetAtlasSource:
			var atlas := src as TileSetAtlasSource
			if atlas.texture != null and str(atlas.texture.resource_path).ends_with("calibration_grass_dirt_wang.png"):
				return sid
	var tex: Texture2D = load(TILESET_PATH)
	if tex == null:
		return -1
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(16, 16)
	for y in range(4):
		for x in range(4):
			atlas.create_tile(Vector2i(x, y))
	var new_id := 90
	while ts.has_source(new_id):
		new_id += 1
	ts.add_source(atlas, new_id)
	return new_id


func _espalhar_props() -> void:
	if get_node_or_null("CalibrationProps") != null:
		return
	var root := Node2D.new()
	root.name = "CalibrationProps"
	add_child(root)

	_add_prop(root, "CalTreeA_1", Vector2(300, 180), TREE_A, Vector2(0, -20))
	_add_prop(root, "CalTreeB_1", Vector2(500, 220), TREE_B, Vector2(0, -22))
	_add_prop(root, "CalTreeA_2", Vector2(280, 360), TREE_A, Vector2(0, -20))
	_add_prop(root, "CalBush_1", Vector2(330, 250), BUSH_A, Vector2(0, -6))
	_add_prop(root, "CalBush_2", Vector2(470, 310), BUSH_A, Vector2(0, -6))
	_add_prop(root, "CalRockA_1", Vector2(350, 200), ROCK_A, Vector2(0, -4))
	_add_prop(root, "CalRockB_1", Vector2(450, 280), ROCK_B, Vector2(0, -4))
	_add_prop(root, "CalGround_1", Vector2(380, 240), GROUND, Vector2(0, 0))
	_add_prop(root, "CalGround_2", Vector2(420, 340), GROUND, Vector2(0, 0))


func _add_prop(parent: Node2D, nome: String, pos: Vector2, tex_path: String, spr_off: Vector2) -> void:
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
	# Soft collision only for trees/rocks
	if "Tree" in nome or "Rock" in nome:
		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 6.0 if "Rock" in nome else 8.0
		col.shape = shape
		col.position = Vector2(0, -2)
		body.add_child(col)
	parent.add_child(body)


func _criar_viajante() -> void:
	if get_node_or_null("ViajanteCalibracao") != null:
		return
	if not ResourceLoader.exists(NPC_SHEET):
		return
	var npc := StaticBody2D.new()
	npc.name = "ViajanteCalibracao"
	npc.set("npc_name", "Viajante Calibracao Padokia")
	npc.position = Vector2(400, 260)
	npc.y_sort_enabled = true

	var col := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 6.0
	col.shape = circ
	col.position = Vector2(0, -3)
	npc.add_child(col)

	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load(NPC_SHEET)
	spr.hframes = 8
	spr.vframes = 1
	spr.frame = 0
	spr.position = Vector2(0, -17)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.add_child(spr)

	var lbl := Label.new()
	lbl.text = "Viajante\n[E] Conversar"
	lbl.position = Vector2(-40, -40)
	lbl.custom_minimum_size = Vector2(80, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.85, 0.9, 0.7))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	npc.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Falar com Viajante"
	inter.interaction_radius = 26.0
	inter.interacted.connect(_on_viajante_interact)
	npc.add_child(inter)
	add_child(npc)


func _on_viajante_interact(_p) -> void:
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(
			"🎒 Viajante: 'Essa estrada está ganhando vida… grama, terra, árvores. "
			+ "O pipeline PixelLab do Hunter Online está calibrado.'"
		)
