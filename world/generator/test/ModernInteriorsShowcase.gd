class_name ModernInteriorsShowcase
extends Node2D

# ============================================================
# HUNTER ONLINE - MODERN INTERIORS SHOWCASE
# ============================================================
#
# Demonstração visual organizada por categorias:
# 1. PISOS E CARPETES (Floors)
# 2. PAREDES E ESTRUTURAS (Walls & Windows)
# 3. SALA MOBILIADA DE TESTE (Living Room & Office)
# 4. QUARTO DE DESCANSO DO HUNTER (Bedroom & Bed)
# 5. COZINHA E SUPRIMENTOS (Kitchen & Food)
#
# ============================================================

@onready var chao_layer: TileMapLayer = get_node_or_null("Chao_TileMapLayer")
@onready var paredes_layer: TileMapLayer = get_node_or_null("Paredes_TileMapLayer")
@onready var decor_layer: TileMapLayer = get_node_or_null("Decor_TileMapLayer")
@onready var player: CharacterBody2D = get_node_or_null("Player")

const PATH_TILESET = "res://world/tilesets/modern_interiors_tileset.tres"

func _ready() -> void:
	print("============================================================")
	print("[MODERN INTERIORS SHOWCASE]")
	print("Iniciando vitrine de demonstração visual...")
	print("============================================================")
	
	var tileset = load(PATH_TILESET) as TileSet
	if tileset == null:
		push_error("Falha ao carregar modern_interiors_tileset.tres")
		return
		
	if chao_layer: chao_layer.tile_set = tileset
	if paredes_layer: paredes_layer.tile_set = tileset
	if decor_layer: decor_layer.tile_set = tileset
	
	_construir_vitrine()
	_posicionar_player()


func _construir_vitrine() -> void:
	if chao_layer == null or paredes_layer == null or decor_layer == null:
		return
		
	chao_layer.clear()
	paredes_layer.clear()
	decor_layer.clear()
	
	# Construir Sala Modelo de Demonstração (12 x 10 tiles)
	var origem = Vector2i(4, 4)
	var largura = 12
	var altura = 10
	
	for y in range(altura):
		for x in range(largura):
			var cell = origem + Vector2i(x, y)
			
			# Paredes de contorno
			if y == 0 or y == altura - 1 or x == 0 or x == largura - 1:
				if not (y == altura - 1 and (x == 5 or x == 6)): # Porta de entrada
					paredes_layer.set_cell(cell, 0, Vector2i(0, 0))
				else:
					chao_layer.set_cell(cell, 0, Vector2i(1, 9)) # Soleira da porta
			else:
				# Piso de madeira nobre
				chao_layer.set_cell(cell, 0, Vector2i(1, 5))
				
	# Mobílias no interior da sala modelo:
	# Cama no canto superior esquerdo
	decor_layer.set_cell(origem + Vector2i(2, 2), 1, Vector2i(2, 2))
	decor_layer.set_cell(origem + Vector2i(2, 3), 1, Vector2i(2, 3))
	
	# Mesa e computador no canto superior direito
	decor_layer.set_cell(origem + Vector2i(8, 2), 1, Vector2i(4, 2))
	decor_layer.set_cell(origem + Vector2i(9, 2), 1, Vector2i(5, 2))
	decor_layer.set_cell(origem + Vector2i(8, 3), 1, Vector2i(4, 3))
	
	# Tapete central
	chao_layer.set_cell(origem + Vector2i(5, 4), 0, Vector2i(1, 9))
	chao_layer.set_cell(origem + Vector2i(6, 4), 0, Vector2i(1, 9))
	chao_layer.set_cell(origem + Vector2i(5, 5), 0, Vector2i(1, 9))
	chao_layer.set_cell(origem + Vector2i(6, 5), 0, Vector2i(1, 9))
	
	print("[MODERN INTERIORS SHOWCASE] Sala modelo construída com sucesso!")


func _posicionar_player() -> void:
	if player != null:
		player.global_position = Vector2(9 * 16 + 8, 12 * 16 + 8)
		print("[MODERN INTERIORS SHOWCASE] Player posicionado na entrada da sala modelo.")
