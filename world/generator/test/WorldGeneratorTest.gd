class_name WorldGeneratorTest
extends Node2D

# ============================================================
# HUNTER ONLINE - WORLD GENERATOR TEST PROTOTYPE
# ============================================================
#
# Protótipo mínimo e funcional para validar a esteira completa:
# Modern Interiors RPG 16x16 -> TileSet -> TileMapLayer -> Gerador -> 64x64 -> Player
#
# ============================================================

@export var map_width: int = 64
@export var map_height: int = 64
@export var tile_size: int = 16

@onready var chao_layer: TileMapLayer = get_node_or_null("Chao_TileMapLayer")
@onready var paredes_layer: TileMapLayer = get_node_or_null("Paredes_TileMapLayer")
@onready var decor_layer: TileMapLayer = get_node_or_null("Decor_TileMapLayer")
@onready var player: CharacterBody2D = get_node_or_null("Player")

const PATH_TILESET = "res://world/tilesets/modern_interiors_tileset.tres"

func _ready() -> void:
	print("============================================================")
	print("[WORLD GENERATOR]")
	print("Initializing...")
	print("============================================================")
	
	var tileset = _carregar_ou_criar_tileset()
	if tileset == null:
		push_error("[WORLD GENERATOR] Falha crítica ao carregar TileSet.")
		return
		
	print("[WORLD GENERATOR]")
	print("TileSet loaded.")
	
	_configurar_tilemap_layers(tileset)
	
	print("[WORLD GENERATOR]")
	print("Generating %dx%d map..." % [map_width, map_height])
	
	_gerar_mapa_64x64()
	
	print("[WORLD GENERATOR]")
	print("Map generated successfully.")
	
	_posicionar_player()


func _carregar_ou_criar_tileset() -> TileSet:
	if ResourceLoader.exists(PATH_TILESET):
		return load(PATH_TILESET) as TileSet
		
	# Caso o arquivo não exista no disco, constrói em tempo de execução
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	
	var path_builder = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png"
	var tex_builder = load(path_builder) as Texture2D
	if tex_builder != null:
		var src_builder = TileSetAtlasSource.new()
		src_builder.texture = tex_builder
		src_builder.texture_region_size = Vector2i(16, 16)
		for y in range(tex_builder.get_height() / 16):
			for x in range(tex_builder.get_width() / 16):
				src_builder.create_tile(Vector2i(x, y))
		tileset.add_source(src_builder, 0)
		
	var path_interiors = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Interiors_free_16x16.png"
	var tex_interiors = load(path_interiors) as Texture2D
	if tex_interiors != null:
		var src_interiors = TileSetAtlasSource.new()
		src_interiors.texture = tex_interiors
		src_interiors.texture_region_size = Vector2i(16, 16)
		for y in range(tex_interiors.get_height() / 16):
			for x in range(tex_interiors.get_width() / 16):
				src_interiors.create_tile(Vector2i(x, y))
		tileset.add_source(src_interiors, 1)
		
	return tileset


func _configurar_tilemap_layers(tileset: TileSet) -> void:
	if chao_layer != null:
		chao_layer.tile_set = tileset
	if paredes_layer != null:
		paredes_layer.tile_set = tileset
	if decor_layer != null:
		decor_layer.tile_set = tileset


func _gerar_mapa_64x64() -> void:
	if chao_layer == null:
		push_error("[WORLD GENERATOR] Chao_TileMapLayer não encontrado!")
		return
		
	chao_layer.clear()
	if paredes_layer != null:
		paredes_layer.clear()
	if decor_layer != null:
		decor_layer.clear()
		
	# Coordenadas reais de atlas comprovadas em Room_Builder_free_16x16 (Source 0):
	# - Piso de Madeira Principal: (1, 5)
	# - Piso Cerâmico / Estrada Central: (1, 9)
	# - Paredes / Bordas: (0, 0)
	var tile_chao_base = Vector2i(1, 5)
	var tile_estrada = Vector2i(1, 9)
	var tile_borda = Vector2i(0, 0)
	
	for y in range(map_height):
		for x in range(map_width):
			var pos_cell = Vector2i(x, y)
			
			# 1. Bordas do mapa (Paredes)
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				if paredes_layer != null:
					paredes_layer.set_cell(pos_cell, 0, tile_borda)
				else:
					chao_layer.set_cell(pos_cell, 0, tile_borda)
				continue
				
			# 2. Estrada / Cruz Central (Linha horizontal e vertical)
			var eh_estrada_h = (y >= 30 and y <= 33)
			var eh_estrada_v = (x >= 30 and x <= 33)
			
			if eh_estrada_h or eh_estrada_v:
				chao_layer.set_cell(pos_cell, 0, tile_estrada)
			else:
				# 3. Piso de Madeira Base
				chao_layer.set_cell(pos_cell, 0, tile_chao_base)
				
	# 4. Decorações contextuais de interiores em praças (Source 1 - Interiors)
	if decor_layer != null:
		# Colocar móveis / adereços nos 4 quadrantes
		decor_layer.set_cell(Vector2i(16, 16), 1, Vector2i(2, 2)) # Mobília quadrante 1
		decor_layer.set_cell(Vector2i(48, 16), 1, Vector2i(3, 2)) # Mobília quadrante 2
		decor_layer.set_cell(Vector2i(16, 48), 1, Vector2i(2, 3)) # Mobília quadrante 3
		decor_layer.set_cell(Vector2i(48, 48), 1, Vector2i(3, 3)) # Mobília quadrante 4


func _posicionar_player() -> void:
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as CharacterBody2D
			
	if player != null:
		# Posição central no cruzamento da estrada (32, 32)
		var spawn_pos = Vector2(32 * tile_size + 8, 32 * tile_size + 8)
		player.global_position = spawn_pos
		print("[WORLD GENERATOR]")
		print("Spawn position: ", spawn_pos)
		
		# Ajustar Câmera do Player para ter limites no mapa 64x64
		var cam: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = map_width * tile_size
			cam.limit_bottom = map_height * tile_size
