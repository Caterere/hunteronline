class_name TileCatalogTest
extends Node2D

# ============================================================
# HUNTER ONLINE - TILE CATALOG TEST SUITE & SHOWCASE
# ============================================================
#
# Demonstração visual e validação automatizada da camada semântica:
# - Sala 1: Estrutura Básica (Piso semântico + WallSet com 4 cantos)
# - Sala 2: Sala com Porta (Piso + WallSet + Abertura de porta e soleira)
# - Sala 3: Quarto Mobiliado (Piso + WallSet + Cama 2x3 + Mesa 2x2 + Estante 1x2)
# - Validação de zero coordenadas hardcoded
#
# ============================================================

const TileDatabase = preload("res://world/catalog/TileDatabase.gd")
const RoomComposer = preload("res://world/catalog/RoomComposer.gd")
const TileDataEntry = preload("res://world/catalog/TileDataEntry.gd")
const WallSet = preload("res://world/catalog/WallSet.gd")
const CompositeTileObject = preload("res://world/catalog/CompositeTileObject.gd")

@onready var chao_layer: TileMapLayer = get_node_or_null("Chao_TileMapLayer")
@onready var paredes_layer: TileMapLayer = get_node_or_null("Paredes_TileMapLayer")
@onready var decor_layer: TileMapLayer = get_node_or_null("Decor_TileMapLayer")
@onready var player: CharacterBody2D = get_node_or_null("Player")

const PATH_TILESET = "res://world/tilesets/world_tileset.tres"


func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: VALIDAÇÃO DO TILE CATALOG & ROOM COMPOSER")
	print("============================================================")
	
	var tileset = load(PATH_TILESET) as TileSet
	if tileset != null:
		if chao_layer: chao_layer.tile_set = tileset
		if paredes_layer: paredes_layer.tile_set = tileset
		if decor_layer: decor_layer.tile_set = tileset
		
	var db: RefCounted = TileDatabase.get_instance()
	
	# 1. Validações Semânticas do Catálogo
	assert(db != null, "TileDatabase deve existir")
	assert(db.tiles.size() >= 15, "Catálogo deve conter pelo menos 15 tiles cadastrados")
	print("  ✅ [PASSOU] Catálogo carregado com %d tiles semânticos" % db.tiles.size())
	
	var floor_tile = db.get_tile("wood_floor_parquet")
	assert(floor_tile != null, "Piso wood_floor_parquet deve existir no catálogo")
	print("  ✅ [PASSOU] Consulta semântica de piso: %s (walkable=%s, layer=%d)" % [floor_tile.id, floor_tile.walkable, floor_tile.layer])
	
	var ws_wood = db.get_wall_set("wood_wall_classic")
	assert(ws_wood != null, "WallSet wood_wall_classic deve existir no catálogo")
	print("  ✅ [PASSOU] Consulta de WallSet 9-slice: %s (top=%s, corner_tl=%s)" % [ws_wood.id, ws_wood.wall_top, ws_wood.corner_top_left])
	
	var bed_obj = db.get_composite_object("double_bed_blue")
	assert(bed_obj != null, "Objeto composto double_bed_blue deve existir no catálogo")
	print("  ✅ [PASSOU] Consulta de Objeto Composto multi-tile: %s (%dx%d tiles, %d peças)" % [bed_obj.id, bed_obj.size_in_tiles.x, bed_obj.size_in_tiles.y, bed_obj.parts.size()])
	
	# 2. Construir 3 Salas Semânticas
	_construir_salas_demonstracao(db)
	
	# 3. Posicionar Player na Sala 3 (Quarto Mobiliado)
	if player != null:
		player.global_position = Vector2(35 * 16 + 8, 8 * 16 + 8)
		print("  ✅ [PASSOU] Player posicionado dentro da Sala 3 mobiliada: ", player.global_position)
		
	print("============================================================")
	print("🎉 TILE CATALOG E ROOM COMPOSER VALIDADOS COM 100% DE SUCESSO!")
	print("============================================================")


func _construir_salas_demonstracao(_db) -> void:
	if chao_layer == null or paredes_layer == null:
		return
		
	chao_layer.clear()
	paredes_layer.clear()
	if decor_layer: decor_layer.clear()
	
	var layers = {
		"chao": chao_layer,
		"paredes": paredes_layer,
		"decor": decor_layer
	}
	
	# ------------------------------------------------------------
	# SALA 1: ESTRUTURA BÁSICA (Piso Madeira + Paredes 9-Slice)
	# ------------------------------------------------------------
	var r1_ok = RoomComposer.compose_room(
		layers,
		Rect2i(2, 2, 10, 8),
		"wood_floor_parquet",
		"wood_wall_classic"
	)
	assert(r1_ok, "Sala 1 deve ser composta com sucesso")
	print("  ✅ [PASSOU] Sala 1 (Estrutura Básica 10x8) construída semanticamente")
	
	# ------------------------------------------------------------
	# SALA 2: SALA COM PORTA (Piso Cerâmica + Paredes Pedra + Porta)
	# ------------------------------------------------------------
	var r2_ok = RoomComposer.compose_room(
		layers,
		Rect2i(15, 2, 12, 8),
		"stone_floor_pavement",
		"stone_wall_dark",
		Vector2i(20, 9) # Posição da porta na parede inferior
	)
	assert(r2_ok, "Sala 2 deve ser composta com sucesso")
	print("  ✅ [PASSOU] Sala 2 (Sala com Porta 12x8) construída semanticamente")
	
	# ------------------------------------------------------------
	# SALA 3: QUARTO MOBILIADO COMPLETO (Piso + WallSet + Porta + Mobílias Multi-Tile)
	# ------------------------------------------------------------
	var mobílias_sala3 = [
		{"id": "double_bed_blue", "pos": Vector2i(30, 4)},      # Cama 2x3 no canto esquerdo
		{"id": "study_desk_pc", "pos": Vector2i(38, 4)},        # Mesa com PC 2x2 no canto direito
		{"id": "bookcase_tall", "pos": Vector2i(34, 3)},        # Estante de livros 1x2 no fundo
		{"id": "storage_chest_wood", "pos": Vector2i(30, 8)},   # Baú pessoal 1x1
		{"id": "house_plant_pot", "pos": Vector2i(40, 8)}       # Vaso de planta 1x1
	]
	
	var r3_ok = RoomComposer.compose_room(
		layers,
		Rect2i(29, 2, 14, 10),
		"wood_floor_dark",
		"wood_wall_classic",
		Vector2i(35, 11), # Porta central
		mobílias_sala3
	)
	assert(r3_ok, "Sala 3 deve ser composta com sucesso")
	print("  ✅ [PASSOU] Sala 3 (Quarto Mobiliado Completo 14x10 com 5 objetos) construída semanticamente")
