class_name SagaTerritoryKit
extends Node2D

# ============================================================
# HUNTER ONLINE — Territórios por saga com packs comprados
# Usa world_tileset.tres + TX Stone / wood / carpet / terreno_*
# (sem PixelLab). Cada saga: base + caminho + 4 faixas distintas.
# ============================================================

const WORLD_TILESET := "res://world/tilesets/world_tileset.tres"
const LAYER_NAME := "SagaTerritoryGround"
const ROOT_NAME := "SagaTerritoryKit"
const TILE := 16

const TEX_STONE := "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Tileset Stone Ground.png"
const TEX_WOOD := "res://assets/sprites/tilesets/floors/wooden.png"
const TEX_CARPET := "res://assets/sprites/tilesets/floors/carpet.png"
const TEX_FLOORING := "res://assets/sprites/tilesets/floors/flooring.png"
const TEX_TER1 := "res://assets/sprites/tilesets/terreno/terreno_1.png"
const TEX_TER2 := "res://assets/sprites/tilesets/terreno/terreno_2.png"
const TEX_TER3 := "res://assets/sprites/tilesets/terreno/terreno_3.png"
const TEX_TER4 := "res://assets/sprites/tilesets/terreno/terreno_4.png"
const TEX_TER5 := "res://assets/sprites/tilesets/terreno/terreno_5.png"

# Sources do world_tileset.tres
const SRC_ROOM := 0
const SRC_INTERIOR := 1
const SRC_GRASS := 2
const SRC_PLAINS := 3
const SRC_WALLS := 4
const SRC_DECOR := 5
const SRC_TX_GRASS := 6
const SRC_TX_PLANT := 7
const SRC_TX_PROPS := 8
const SRC_TX_STRUCT := 9
const SRC_WATER := 10

# Sources anexados em runtime
const SRC_STONE := 20
const SRC_WOOD := 21
const SRC_CARPET := 22
const SRC_FLOORING := 23
const SRC_T1 := 24
const SRC_T2 := 25
const SRC_T3 := 26
const SRC_T4 := 27
const SRC_T5 := 28

@export var saga_id: int = 1
var _tileset: TileSet = null


static func attach(mapa: Node2D, saga: int) -> SagaTerritoryKit:
	if mapa == null:
		return null
	var existing := mapa.get_node_or_null(ROOT_NAME) as SagaTerritoryKit
	if existing != null:
		return existing
	var kit := SagaTerritoryKit.new()
	kit.name = ROOT_NAME
	kit.saga_id = clampi(saga, 1, 9)
	mapa.add_child(kit)
	return kit


func _ready() -> void:
	# Defer: parent still busy during add_child(_ready).
	call_deferred("_bootstrap_territory")


func _bootstrap_territory() -> void:
	_tileset = _build_pack_tileset()
	_paint_territory()
	_spawn_biome_banner()
	_spawn_ambient_fx()
	_apply_identity_tint()
	_try_arrival_beat()


static func palette_for_saga(saga: int) -> Dictionary:
	match clampi(saga, 1, 9):
		1:
			return _pal(
				"287º Exame Hunter", "Túnel · Pantanal · Gourmet · Torre",
				Color(0.92, 1.02, 0.88), Color(0.75, 0.95, 0.55, 0.7), "leaves",
				Color(0.28, 0.55, 0.30), Color(0.55, 0.40, 0.18),
				{"src": SRC_GRASS, "atlas": Vector2i(0, 0)},
				{"src": SRC_PLAINS, "atlas": Vector2i(1, 1)},
				[
					# Sem WALLS/WATER (physics) — só terreno/decoração walkable
					{"src": SRC_TX_GRASS, "atlas": Vector2i(0, 0)},
					{"src": SRC_PLAINS, "atlas": Vector2i(0, 0)},
					{"src": SRC_GRASS, "atlas": Vector2i(0, 0)},
					{"src": SRC_T1, "atlas": Vector2i(0, 0)},
				]
			)
		2:
			return _pal(
				"Montanha Kukuroo", "Portão · Alameda · Mansão · Trono",
				Color(0.88, 0.92, 0.86), Color(0.70, 0.85, 0.65, 0.55), "mist",
				Color(0.30, 0.40, 0.28), Color(0.52, 0.50, 0.46),
				{"src": SRC_TX_GRASS, "atlas": Vector2i(0, 0)},
				{"src": SRC_PLAINS, "atlas": Vector2i(1, 1)},
				[
					{"src": SRC_STONE, "atlas": Vector2i(0, 0)},
					{"src": SRC_TX_GRASS, "atlas": Vector2i(0, 0)},
					{"src": SRC_T1, "atlas": Vector2i(0, 0)},
					{"src": SRC_WALLS, "atlas": Vector2i(1, 0)},
				]
			)
		3:
			return _pal(
				"Arena Celestial", "Recepção · Dojo · Andares · 200º",
				Color(1.02, 0.98, 0.90), Color(1.0, 0.85, 0.55, 0.45), "sparks",
				Color(0.72, 0.64, 0.48), Color(0.58, 0.56, 0.54),
				{"src": SRC_STONE, "atlas": Vector2i(0, 0)},
				{"src": SRC_ROOM, "atlas": Vector2i(1, 9)},
				[
					{"src": SRC_FLOORING, "atlas": Vector2i(0, 0)},
					{"src": SRC_WOOD, "atlas": Vector2i(0, 0)},
					{"src": SRC_STONE, "atlas": Vector2i(0, 0)},
					{"src": SRC_ROOM, "atlas": Vector2i(1, 5)},
				]
			)
		4:
			return _pal(
				"Yorknew City", "Leilão · Avenida · Cemitério · Trupe",
				Color(0.78, 0.82, 0.95), Color(0.55, 0.70, 1.0, 0.4), "ash",
				Color(0.22, 0.24, 0.30), Color(0.40, 0.42, 0.48),
				{"src": SRC_ROOM, "atlas": Vector2i(1, 9)},
				{"src": SRC_ROOM, "atlas": Vector2i(1, 5)},
				[
					{"src": SRC_FLOORING, "atlas": Vector2i(0, 0)},
					{"src": SRC_ROOM, "atlas": Vector2i(1, 9)},
					{"src": SRC_WALLS, "atlas": Vector2i(0, 0)},
					{"src": SRC_CARPET, "atlas": Vector2i(0, 0)},
				]
			)
		5:
			return _pal(
				"Greed Island", "Antokiba · Campo · Soufrabi · Razor",
				Color(0.90, 1.05, 0.92), Color(0.95, 0.85, 0.25, 0.65), "cards",
				Color(0.18, 0.62, 0.35), Color(0.85, 0.72, 0.22),
				{"src": SRC_TX_GRASS, "atlas": Vector2i(0, 0)},
				{"src": SRC_PLAINS, "atlas": Vector2i(1, 1)},
				[
					{"src": SRC_GRASS, "atlas": Vector2i(0, 0)},
					{"src": SRC_TX_GRASS, "atlas": Vector2i(0, 0)},
					{"src": SRC_WATER, "atlas": Vector2i(0, 0)},
					{"src": SRC_T2, "atlas": Vector2i(0, 0)},
				]
			)
		6:
			return _pal(
				"NGL / Formigas Quimera", "Fronteira · Ninho · Palácio · Meruem",
				Color(0.85, 0.95, 0.82), Color(0.45, 1.0, 0.55, 0.5), "spores",
				Color(0.16, 0.38, 0.28), Color(0.36, 0.28, 0.18),
				{"src": SRC_T3, "atlas": Vector2i(0, 0)},
				{"src": SRC_PLAINS, "atlas": Vector2i(1, 1)},
				[
					{"src": SRC_GRASS, "atlas": Vector2i(0, 0)},
					{"src": SRC_T4, "atlas": Vector2i(0, 0)},
					{"src": SRC_STONE, "atlas": Vector2i(0, 0)},
					{"src": SRC_CARPET, "atlas": Vector2i(0, 0)},
				]
			)
		7:
			return _pal(
				"Associação Hunter", "Hall · Zodíacos · Eleição · V5",
				Color(0.95, 0.97, 1.02), Color(0.70, 0.85, 1.0, 0.35), "dust",
				Color(0.70, 0.74, 0.78), Color(0.25, 0.38, 0.58),
				{"src": SRC_FLOORING, "atlas": Vector2i(0, 0)},
				{"src": SRC_CARPET, "atlas": Vector2i(0, 0)},
				[
					{"src": SRC_ROOM, "atlas": Vector2i(1, 9)},
					{"src": SRC_FLOORING, "atlas": Vector2i(0, 0)},
					{"src": SRC_WOOD, "atlas": Vector2i(0, 0)},
					{"src": SRC_CARPET, "atlas": Vector2i(0, 0)},
				]
			)
		8:
			return _pal(
				"Continente Negro", "Costa · Interior · Abismos · Guardiãs",
				Color(0.92, 0.82, 0.95), Color(0.75, 0.40, 1.0, 0.55), "void",
				Color(0.22, 0.14, 0.24), Color(0.40, 0.22, 0.20),
				{"src": SRC_T5, "atlas": Vector2i(0, 0)},
				{"src": SRC_STONE, "atlas": Vector2i(0, 0)},
				[
					{"src": SRC_T4, "atlas": Vector2i(0, 0)},
					{"src": SRC_WALLS, "atlas": Vector2i(0, 0)},
					{"src": SRC_T5, "atlas": Vector2i(0, 0)},
					{"src": SRC_STONE, "atlas": Vector2i(0, 0)},
				]
			)
		_:
			return _pal(
				"Black Whale Tier 1", "Convés · Cabines · Princesas · Trupe",
				Color(0.88, 0.90, 0.96), Color(0.60, 0.75, 1.0, 0.4), "spray",
				Color(0.40, 0.32, 0.26), Color(0.35, 0.40, 0.46),
				{"src": SRC_WOOD, "atlas": Vector2i(0, 0)},
				{"src": SRC_ROOM, "atlas": Vector2i(1, 5)},
				[
					{"src": SRC_WOOD, "atlas": Vector2i(0, 0)},
					{"src": SRC_CARPET, "atlas": Vector2i(0, 0)},
					{"src": SRC_FLOORING, "atlas": Vector2i(0, 0)},
					{"src": SRC_ROOM, "atlas": Vector2i(1, 9)},
				]
			)


static func _pal(
	nome: String, bioma: String, tint: Color, particle: Color, fx: String,
	banner: Color, stripe: Color, base: Dictionary, path: Dictionary, bands: Array
) -> Dictionary:
	return {
		"nome": nome,
		"bioma": bioma,
		"tint": tint,
		"particle": particle,
		"fx": fx,
		"banner_color": banner,
		"stripe_color": stripe,
		"base": base,
		"path": path,
		"bands": bands,
	}


static func _build_pack_tileset() -> TileSet:
	var ts: TileSet = null
	if ResourceLoader.exists(WORLD_TILESET):
		var loaded := load(WORLD_TILESET) as TileSet
		if loaded != null:
			ts = loaded.duplicate(true)
	if ts == null:
		ts = TileSet.new()
		ts.tile_size = Vector2i(TILE, TILE)

	_ensure_atlas(ts, SRC_STONE, TEX_STONE, Vector2i(32, 32))
	_ensure_atlas(ts, SRC_WOOD, TEX_WOOD, Vector2i(16, 16))
	_ensure_atlas(ts, SRC_CARPET, TEX_CARPET, Vector2i(16, 16))
	_ensure_atlas(ts, SRC_FLOORING, TEX_FLOORING, Vector2i(16, 16))
	_ensure_atlas(ts, SRC_T1, TEX_TER1, Vector2i(16, 16))
	_ensure_atlas(ts, SRC_T2, TEX_TER2, Vector2i(16, 16))
	_ensure_atlas(ts, SRC_T3, TEX_TER3, Vector2i(16, 16))
	_ensure_atlas(ts, SRC_T4, TEX_TER4, Vector2i(16, 16))
	_ensure_atlas(ts, SRC_T5, TEX_TER5, Vector2i(16, 16))
	return ts


static func _ensure_atlas(ts: TileSet, source_id: int, tex_path: String, region: Vector2i) -> void:
	if ts == null or not ResourceLoader.exists(tex_path):
		return
	if ts.has_source(source_id):
		return
	var tex := load(tex_path) as Texture2D
	if tex == null:
		return
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = region
	var cols := mini(16, maxi(1, int(tex.get_width() / float(region.x))))
	var rows := mini(16, maxi(1, int(tex.get_height() / float(region.y))))
	for y in range(rows):
		for x in range(cols):
			var coords := Vector2i(x, y)
			if not atlas.has_tile(coords):
				atlas.create_tile(coords)
	ts.add_source(atlas, source_id)


static func _resolve_tile(ts: TileSet, spec: Dictionary) -> Dictionary:
	var src := int(spec.get("src", SRC_GRASS))
	var atlas: Vector2i = spec.get("atlas", Vector2i(0, 0))
	if ts != null and ts.has_source(src):
		var atlas_src := ts.get_source(src) as TileSetAtlasSource
		if atlas_src != null:
			if atlas_src.has_tile(atlas):
				return {"src": src, "atlas": atlas}
			if atlas_src.has_tile(Vector2i(0, 0)):
				return {"src": src, "atlas": Vector2i(0, 0)}
	for fb in [SRC_GRASS, SRC_PLAINS, SRC_ROOM, SRC_TX_GRASS]:
		if ts != null and ts.has_source(fb):
			return {"src": fb, "atlas": Vector2i(0, 0)}
	return {"src": 0, "atlas": Vector2i(0, 0)}


func _paint_territory() -> void:
	var mapa := get_parent() as Node2D
	if mapa == null or _tileset == null:
		return
	if get_node_or_null(LAYER_NAME) != null:
		return

	var layer := TileMapLayer.new()
	layer.name = LAYER_NAME
	layer.tile_set = _tileset
	layer.z_index = -80
	layer.y_sort_enabled = false
	# Decorativo apenas — packs com WALLS/WATER não podem prender o player.
	layer.collision_enabled = false
	layer.navigation_enabled = false
	# Filho do kit (não do mapa) — evita erro "parent busy" no add_child.
	add_child(layer)
	# Atrás de props do hub
	z_index = -80

	var chao := mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	if chao == null:
		chao = mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	if chao != null and chao.tile_set == null:
		chao.tile_set = _tileset

	var pal: Dictionary = palette_for_saga(saga_id)
	var base_t: Dictionary = _resolve_tile(_tileset, pal["base"])
	var path_t: Dictionary = _resolve_tile(_tileset, pal["path"])

	var x0 := -40
	var x1 := 420 if saga_id == 1 else 300
	var y0 := -100
	var y1 := 100

	for tx in range(x0, x1):
		for ty in range(y0, y1):
			layer.set_cell(Vector2i(tx, ty), int(base_t["src"]), base_t["atlas"])

	for tx in range(x0, x1):
		for ty in range(-3, 4):
			layer.set_cell(Vector2i(tx, ty), int(path_t["src"]), path_t["atlas"])

	var band_starts: Array[int] = [x0, 60, 130, 200, 270]
	if saga_id == 1:
		band_starts = [x0, 80, 160, 280, 360]
	var bands: Array = pal["bands"]
	for bi in range(mini(4, bands.size())):
		var xa: int = band_starts[bi]
		var xb: int = band_starts[bi + 1] if bi + 1 < band_starts.size() else x1
		var band_t: Dictionary = _resolve_tile(_tileset, bands[bi])
		for tx in range(xa, xb):
			for ty in range(y0, y1):
				if abs(ty) <= 3:
					continue
				if ((tx * 13 + ty * 7 + bi) % 10) < 7:
					layer.set_cell(Vector2i(tx, ty), int(band_t["src"]), band_t["atlas"])

	if chao != null:
		chao.modulate = Color(1, 1, 1, 1).lerp(pal["tint"], 0.2)


func _spawn_biome_banner() -> void:
	if get_node_or_null("BiomeBanner") != null:
		return
	var pal: Dictionary = palette_for_saga(saga_id)
	var root := Node2D.new()
	root.name = "BiomeBanner"
	root.z_index = 40
	root.position = Vector2(80, -220)
	add_child(root)

	var bg := Polygon2D.new()
	bg.name = "BannerBg"
	var bc: Color = pal["banner_color"]
	bg.color = Color(bc.r, bc.g, bc.b, 0.82)
	bg.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(420, 0), Vector2(420, 54), Vector2(0, 54)
	])
	root.add_child(bg)

	var stripe := Polygon2D.new()
	stripe.name = "BannerStripe"
	stripe.color = pal["stripe_color"]
	stripe.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(10, 0), Vector2(10, 54), Vector2(0, 54)
	])
	root.add_child(stripe)

	var label := Label.new()
	label.name = "BannerLabel"
	label.text = "%s\n%s" % [str(pal["nome"]), str(pal["bioma"])]
	label.position = Vector2(18, 6)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.95, 0.97, 0.92))
	root.add_child(label)


func _spawn_ambient_fx() -> void:
	if get_node_or_null("AmbientFx") != null:
		return
	var pal: Dictionary = palette_for_saga(saga_id)
	var root := Node2D.new()
	root.name = "AmbientFx"
	root.z_index = 5
	add_child(root)

	var particles := CPUParticles2D.new()
	particles.name = "TerritoryParticles"
	particles.position = Vector2(1200, -40)
	particles.amount = 28
	particles.lifetime = 4.5
	particles.preprocess = 2.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(1800, 80)
	particles.direction = Vector2(0.15, 1)
	particles.spread = 40.0
	particles.gravity = Vector2(0, 12)
	particles.initial_velocity_min = 8.0
	particles.initial_velocity_max = 28.0
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.5
	particles.color = pal["particle"]
	match str(pal["fx"]):
		"leaves":
			particles.gravity = Vector2(8, 18)
		"mist":
			particles.gravity = Vector2(4, 2)
			particles.initial_velocity_max = 12.0
		"sparks":
			particles.gravity = Vector2(0, -6)
			particles.color = Color(1.0, 0.75, 0.35, 0.55)
		"ash":
			particles.gravity = Vector2(6, 10)
		"cards":
			particles.gravity = Vector2(10, 4)
			particles.amount = 36
		"spores":
			particles.gravity = Vector2(0, -4)
		"void":
			particles.gravity = Vector2(0, -8)
			particles.amount = 40
		"spray":
			particles.gravity = Vector2(-20, 6)
			particles.emission_rect_extents = Vector2(2000, 40)
		_:
			pass
	root.add_child(particles)


func _apply_identity_tint() -> void:
	var mapa := get_parent() as Node2D
	if mapa == null:
		return
	var pal: Dictionary = palette_for_saga(saga_id)
	var canvas := mapa.get_node_or_null("AmbientLightModulate") as CanvasModulate
	if canvas != null:
		canvas.color = canvas.color.lerp(pal["tint"], 0.35)


func _try_arrival_beat() -> void:
	var mapa := get_parent() as Node2D
	if mapa == null or bool(mapa.get_meta("saga_arrival_played", false)):
		return
	var tree := get_tree()
	# Em suites headless (-s) current_scene é null — só loga identidade.
	if tree == null or tree.current_scene == null:
		return
	mapa.set_meta("saga_arrival_played", true)
	var pal: Dictionary = palette_for_saga(saga_id)
	print("[SagaTerritoryKit] Chegada: %s — %s" % [str(pal["nome"]), str(pal["bioma"])])
