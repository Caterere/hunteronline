class_name PadokiaInteriors
extends Node2D

# ============================================================
# HUNTER ONLINE - PADOKIA INTERIORS & DUNGEONS
# ============================================================
#
# Constrói e gerencia os interiores ricos e detalhados de Padokia:
# 1. Casa 1: Residência Pessoal do Caçador (Cama, Baú, Boneco DPS)
# 2. Casa 2: Residência do Ancião Erudito de Nen (Estantes, Mapas)
# 3. Casa 3: Oficina do Ferreiro / Armeiro (Forja, Bancada, Bigorna)
# 4. Casa 4: Alojamento dos Exploradores Hunter (Beliches, Suprimentos)
# 5. Loja: Empório de Suprimentos de Padokia (Balcão, Prateleiras)
# 6. Dojo: Centro de Treinamento de Nen (Tatame, Meditação, Mestre Wing)
# 7. Caverna: Caverna Secreta do Ermitão (Nascente, Baú Raro)
# 8. Dungeon: Santuário das Ruínas de Zaban (Pilares, Altar Ren, Guardião)
#
# ============================================================

enum InteriorType {
	PLAYER_HOUSE,
	SCHOLAR_HOUSE,
	BLACKSMITH_HOUSE,
	SCOUT_LODGE,
	SHOP,
	DOJO,
	HERMIT_CAVE,
	DUNGEON_SANCTUARY
}

@export var tipo_interior: InteriorType = InteriorType.PLAYER_HOUSE
@export var mapa_retorno_path: String = "res://world/maps/regiao_vale_padokia.tscn"
@export var spawn_retorno_pos: Vector2 = Vector2(1200, 4080)

@onready var chao_layer: TileMapLayer = get_node_or_null("Chao_TileMapLayer")
@onready var paredes_layer: TileMapLayer = get_node_or_null("Paredes_TileMapLayer")
@onready var decor_layer: TileMapLayer = get_node_or_null("Decor_TileMapLayer")
@onready var player: CharacterBody2D = get_node_or_null("Player")

const PATH_TILESET = "res://world/tilesets/world_tileset.tres"


func _ready() -> void:
	var tileset = load(PATH_TILESET) as TileSet
	if tileset != null:
		if chao_layer: chao_layer.tile_set = tileset
		if paredes_layer: paredes_layer.tile_set = tileset
		if decor_layer: decor_layer.tile_set = tileset
		
	_construir_interior()
	_posicionar_player()
	_tocar_audio_ambiente()


func _tocar_audio_ambiente() -> void:
	if AudioManager != null and AudioManager.has_method("tocar_bgm"):
		match tipo_interior:
			InteriorType.HERMIT_CAVE, InteriorType.DUNGEON_SANCTUARY:
				AudioManager.tocar_bgm("dungeon_theme")
			InteriorType.DOJO:
				AudioManager.tocar_bgm("training_theme")
			_:
				AudioManager.tocar_bgm("town_peace")


func _construir_interior() -> void:
	if chao_layer == null or paredes_layer == null:
		return
		
	chao_layer.clear()
	paredes_layer.clear()
	if decor_layer: decor_layer.clear()
	
	match tipo_interior:
		InteriorType.PLAYER_HOUSE:
			_gerar_sala(14, 10, Vector2i(1, 5), Vector2i(0, 0), "Residência do Caçador")
			_decorar_casa_player()
		InteriorType.SCHOLAR_HOUSE:
			_gerar_sala(12, 10, Vector2i(1, 5), Vector2i(0, 0), "Casa do Ancião Erudito")
			_decorar_casa_erudito()
		InteriorType.BLACKSMITH_HOUSE:
			_gerar_sala(12, 10, Vector2i(1, 9), Vector2i(0, 0), "Oficina do Ferreiro")
			_decorar_oficina_ferreiro()
		InteriorType.SCOUT_LODGE:
			_gerar_sala(14, 10, Vector2i(1, 5), Vector2i(0, 0), "Alojamento dos Exploradores")
			_decorar_alojamento()
		InteriorType.SHOP:
			_gerar_sala(16, 12, Vector2i(1, 9), Vector2i(0, 0), "Empório de Padokia")
			_decorar_loja()
		InteriorType.DOJO:
			_gerar_sala(18, 14, Vector2i(1, 5), Vector2i(0, 0), "Dojo de Treinamento de Nen")
			_decorar_dojo()
		InteriorType.HERMIT_CAVE:
			_gerar_sala(16, 14, Vector2i(2, 2), Vector2i(0, 0), "Caverna do Ermitão", true)
			_decorar_caverna()
		InteriorType.DUNGEON_SANCTUARY:
			_gerar_sala(24, 20, Vector2i(1, 9), Vector2i(0, 0), "Santuário das Ruínas de Zaban", true)
			_decorar_dungeon()


func _gerar_sala(largura: int, altura: int, tile_piso: Vector2i, tile_parede: Vector2i, titulo: String, _caverna: bool = false) -> void:
	var origem = Vector2i(2, 2)
	var porta_x = largura / 2
	
	for y in range(altura):
		for x in range(largura):
			var cell = origem + Vector2i(x, y)
			
			if y == 0 or y == altura - 1 or x == 0 or x == largura - 1:
				if y == altura - 1 and (x == porta_x or x == porta_x + 1):
					chao_layer.set_cell(cell, 0, Vector2i(1, 9)) # Soleira da porta
				else:
					paredes_layer.set_cell(cell, 0, tile_parede)
			else:
				chao_layer.set_cell(cell, 0, tile_piso)
				
	_criar_gatilho_saida(Vector2((origem.x + porta_x + 0.5) * 16, (origem.y + altura - 0.5) * 16), titulo)


func _criar_gatilho_saida(pos: Vector2, nome_sala: String) -> void:
	var portal = MapTransitionArea.new()
	portal.name = "PortalSaida"
	portal.position = pos
	portal.target_scene_path = mapa_retorno_path
	portal.portal_name = "Sair de " + nome_sala
	portal.requires_e_key = true
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(32, 24)
	col.shape = box
	portal.add_child(col)
	add_child(portal)


func _decorar_casa_player() -> void:
	if decor_layer == null: return
	# Cama (canto superior esquerdo)
	decor_layer.set_cell(Vector2i(4, 4), 1, Vector2i(2, 2))
	decor_layer.set_cell(Vector2i(4, 5), 1, Vector2i(2, 3))
	# Baú pessoal
	decor_layer.set_cell(Vector2i(6, 4), 1, Vector2i(4, 2))
	# Mesa e cadeira
	decor_layer.set_cell(Vector2i(12, 4), 1, Vector2i(4, 3))
	decor_layer.set_cell(Vector2i(12, 5), 1, Vector2i(5, 3))
	_instanciar_cama_interativa(Vector2(4 * 16 + 8, 5 * 16 + 8))


func _decorar_casa_erudito() -> void:
	if decor_layer == null: return
	# Estantes de livros no fundo
	decor_layer.set_cell(Vector2i(4, 4), 1, Vector2i(6, 2))
	decor_layer.set_cell(Vector2i(5, 4), 1, Vector2i(7, 2))
	decor_layer.set_cell(Vector2i(6, 4), 1, Vector2i(6, 2))
	# Mesa com manuscritos
	decor_layer.set_cell(Vector2i(9, 6), 1, Vector2i(4, 3))


func _decorar_oficina_ferreiro() -> void:
	if decor_layer == null: return
	# Bancada e forja
	decor_layer.set_cell(Vector2i(4, 4), 1, Vector2i(8, 2))
	decor_layer.set_cell(Vector2i(5, 4), 1, Vector2i(9, 2))
	decor_layer.set_cell(Vector2i(10, 4), 1, Vector2i(8, 3))


func _decorar_alojamento() -> void:
	if decor_layer == null: return
	# Beliches
	decor_layer.set_cell(Vector2i(4, 4), 1, Vector2i(2, 2))
	decor_layer.set_cell(Vector2i(4, 7), 1, Vector2i(2, 2))
	decor_layer.set_cell(Vector2i(13, 4), 1, Vector2i(2, 2))
	# Mesa comunal no centro
	decor_layer.set_cell(Vector2i(8, 6), 1, Vector2i(4, 3))
	decor_layer.set_cell(Vector2i(9, 6), 1, Vector2i(5, 3))


func _decorar_loja() -> void:
	if decor_layer == null: return
	# Balcão de atendimento
	for x in range(5, 13):
		decor_layer.set_cell(Vector2i(x, 6), 1, Vector2i(3, 2))
	# Prateleiras no fundo
	for x in range(4, 14):
		decor_layer.set_cell(Vector2i(x, 4), 1, Vector2i(6, 2))


func _decorar_dojo() -> void:
	if decor_layer == null: return
	# Tatame central
	for y in range(6, 12):
		for x in range(6, 14):
			chao_layer.set_cell(Vector2i(x, y), 0, Vector2i(1, 9))
	# Altar de treino no topo
	decor_layer.set_cell(Vector2i(10, 4), 1, Vector2i(8, 2))
	decor_layer.set_cell(Vector2i(11, 4), 1, Vector2i(9, 2))


func _decorar_caverna() -> void:
	if decor_layer == null: return
	# Pedras e nascente
	decor_layer.set_cell(Vector2i(5, 5), 8, Vector2i(2, 2))
	decor_layer.set_cell(Vector2i(12, 5), 8, Vector2i(3, 2))
	# Baú secreto no fundo
	_instanciar_bau_recompensa(Vector2(9 * 16 + 8, 5 * 16 + 8), "Tesouro Antigo do Ermitão")


func _decorar_dungeon() -> void:
	if decor_layer == null: return
	# Pilares monumentais
	decor_layer.set_cell(Vector2i(6, 6), 9, Vector2i(0, 0))
	decor_layer.set_cell(Vector2i(19, 6), 9, Vector2i(0, 0))
	decor_layer.set_cell(Vector2i(6, 15), 9, Vector2i(0, 0))
	decor_layer.set_cell(Vector2i(19, 15), 9, Vector2i(0, 0))
	
	# Altar central com RenBeacon
	_instanciar_ren_beacon(Vector2(13 * 16, 8 * 16))
	# Baú lendário do chefe
	_instanciar_bau_recompensa(Vector2(13 * 16, 5 * 16), "Relíquia Ancestral de Zaban")


func _instanciar_cama_interativa(pos: Vector2) -> void:
	var inter = InteractionComponent.new()
	inter.name = "CamaDescanso"
	inter.interaction_text = "🛏️ [E] Descansar (Restaura HP & Aura 100%)"
	inter.interaction_radius = 24.0
	inter.position = pos
	inter.interacted.connect(func(_p):
		PlayerData.attributes["vida"] = PlayerData.attributes.get("vida_max", 100)
		PlayerData.attributes["aura"] = PlayerData.attributes.get("aura_max", 100)
		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🛏️ Descanso concluído! HP & Aura completamente restaurados.")
	)
	add_child(inter)


func _instanciar_bau_recompensa(pos: Vector2, nome_bau: String) -> void:
	var inter = InteractionComponent.new()
	inter.name = "BauRecompensa"
	inter.interaction_text = "📦 [E] Abrir " + nome_bau
	inter.interaction_radius = 24.0
	inter.position = pos
	inter.interacted.connect(func(_p):
		PlayerData.adicionar_jenny(500)
		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🎉 Você abriu [%s] e recebeu 500 Jenny!" % nome_bau)
	)
	add_child(inter)


func _instanciar_ren_beacon(pos: Vector2) -> void:
	var beacon = RenBeacon.new()
	beacon.name = "RenBeaconDungeon"
	beacon.position = pos
	beacon.beacon_name = "Altar das Ruínas de Zaban"
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(48, 48)
	col.shape = box
	beacon.add_child(col)
	add_child(beacon)


func _posicionar_player() -> void:
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as CharacterBody2D
			
	if player != null:
		var spawn_pos = Vector2(7 * 16 + 8, 8 * 16 + 8)
		player.global_position = spawn_pos
		var cam: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 32 * 16
			cam.limit_bottom = 26 * 16
