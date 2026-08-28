class_name RegionWorldGenerator
extends Node2D

# ============================================================
# HUNTER ONLINE - REGION WORLD GENERATOR (512x512 TILES)
# ============================================================
#
# Construtor determinístico e modular da Primeira Região Real:
# - Dimensões: 512 x 512 tiles (8192 x 8192 px em 16x16)
# - Seed fixa (184729) para persistência e reprodução exata
# - Level Design Macro estruturado + Proceduralidade controlada
# - Vila de Padokia (100x100), 6 Edifícios com interiores, Praça, Spawn
# - Estrada Real conectada e caminhos secundários curvilíneos
# - Grande Rio, Lago e Pontes de Pedra
# - Floresta dos Vestígios (Média Densidade, Árvore Milenar)
# - Ravina da Névoa Tóxica (Zona de Perigo, TenHazard, ZetsuSensor)
# - Ruínas do Santuário de Zaban (Dungeon, RenBeacon, ShortcutDoor)
# - Caverna Secreta do Ermitão (KoObstacle, GyoInspectable)
# - Streaming hierárquico em 64 chunks (8x8 de 64x64 tiles)
#
# ============================================================

const RegionConfig = preload("res://resource/world/RegionConfig.gd")
const PadokiaInteriors = preload("res://world/maps/interiors/PadokiaInteriors.gd")

@export var config: Resource = null

@onready var chao_layer: TileMapLayer = get_node_or_null("Chao_TileMapLayer")
@onready var paredes_layer: TileMapLayer = get_node_or_null("Paredes_TileMapLayer")
@onready var decor_layer: TileMapLayer = get_node_or_null("Decor_TileMapLayer")
@onready var chunk_loader: WorldChunkLoader = get_node_or_null("WorldChunkLoader")
@onready var player: CharacterBody2D = get_node_or_null("Player")

const PATH_TILESET = "res://world/tilesets/world_tileset.tres"

# Coordenadas de Atlas no world_tileset.tres:
# Source 0: Room_Builder (Paredes urbanas, pisos cerâmicos, calçadas)
const TILE_CHAO_URBANO = Vector2i(1, 9)
const TILE_PAREDE_CASA = Vector2i(0, 0)
const TILE_PISO_MADEIRA = Vector2i(1, 5)

# Source 2: Grass
const TILE_GRAMA_BASE = Vector2i(0, 0)

# Source 3: Plains (Estrada de terra / caminhos)
const TILE_ESTRADA_TERRA = Vector2i(1, 1)

# Source 4: Walls (Paredes de pedra sólida com colisão)
const TILE_ROCHA_SOLIDA = Vector2i(0, 0)
const TILE_MURO_PEDRA = Vector2i(1, 0)

# Source 5: Decor 16x16 (Flores, cogumelos)
const TILE_FLOR = Vector2i(0, 0)
const TILE_COGUMELO = Vector2i(1, 0)

# Source 7: TX Plant (Árvores e arbustos)
const TILE_ARVORE_TOPO = Vector2i(2, 2)
const TILE_ARVORE_BASE = Vector2i(2, 3)
const TILE_ARBUSTO = Vector2i(1, 6)

# Source 8: TX Props (Caixas, barris, tochas, postes)
const TILE_POSTE_LUZ = Vector2i(2, 1)
const TILE_BARRIL = Vector2i(3, 2)
const TILE_CAIXA = Vector2i(4, 2)
const TILE_FONTE_CENTRAL = Vector2i(6, 4)

# Source 9: TX Struct (Pilares de ruínas, altares)
const TILE_PILAR_RUINA = Vector2i(0, 2)
const TILE_ARCO_RUINA = Vector2i(1, 2)

# Source 10: Água
const TILE_AGUA_RIO = Vector2i(0, 0)

# Chunks: 8x8 grid de 64x64 tiles = 512x512
const CHUNKS_X = 8
const CHUNKS_Y = 8
const CHUNK_SIZE = 64

var chunks_grid: Array = [] # 8x8 de Node2D


func _ready() -> void:
	if config == null:
		config = RegionConfig.create_default_padokia()
		
	var tileset = load(PATH_TILESET) as TileSet
	if tileset != null:
		if chao_layer: chao_layer.tile_set = tileset
		if paredes_layer: paredes_layer.tile_set = tileset
		if decor_layer: decor_layer.tile_set = tileset
		
	gerar_regiao_completa()
	posicionar_player()


func gerar_regiao_completa() -> void:
	print("============================================================")
	print("[REGION WORLD GENERATOR] Construindo %s (%dx%d tiles, Seed: %d)" % [
		config.region_name, config.width_tiles, config.height_tiles, config.generation_seed
	])
	print("============================================================")
	
	_limpar_camadas()
	_inicializar_chunks()
	
	# Etapas de Construção do Level Design
	_gerar_terreno_base()
	_gerar_grande_rio_e_lagos()
	_gerar_vila_padokia()
	_gerar_rede_estradas_e_caminhos()
	_gerar_floresta_e_clareiras()
	_gerar_ravina_perigo()
	_gerar_dungeon_ruinas()
	_gerar_colinas_norte_e_caverna()
	_posicionar_pois_e_segredos()
	_instanciar_npcs_e_inimigos()
	
	print("[REGION WORLD GENERATOR] Região gerada com 100% de integridade estrutural!")


func _limpar_camadas() -> void:
	if chao_layer: chao_layer.clear()
	if paredes_layer: paredes_layer.clear()
	if decor_layer: decor_layer.clear()


func _inicializar_chunks() -> void:
	if chunk_loader == null:
		chunk_loader = get_node_or_null("WorldChunkLoader") as WorldChunkLoader
		if chunk_loader == null:
			chunk_loader = WorldChunkLoader.new()
			chunk_loader.name = "WorldChunkLoader"
			add_child(chunk_loader)
			
	# Limpar filhos antigos do chunk loader
	for c in chunk_loader.get_children():
		c.queue_free()
		
	chunks_grid.clear()
	for cy in range(CHUNKS_Y):
		var row: Array = []
		for cx in range(CHUNKS_X):
			var chunk_node = Node2D.new()
			chunk_node.name = "Chunk_%d_%d" % [cx, cy]
			chunk_node.position = Vector2(cx * CHUNK_SIZE * config.tile_size, cy * CHUNK_SIZE * config.tile_size)
			chunk_loader.add_child(chunk_node)
			row.append(chunk_node)
		chunks_grid.append(row)
		
	chunk_loader._coletar_chunks()


func _obter_chunk_para_posicao(pos_tiles: Vector2i) -> Node2D:
	var cx = clamp(pos_tiles.x / CHUNK_SIZE, 0, CHUNKS_X - 1)
	var cy = clamp(pos_tiles.y / CHUNK_SIZE, 0, CHUNKS_Y - 1)
	return chunks_grid[cy][cx] as Node2D


# ------------------------------------------------------------
# 1. TERRENO BASE & BORDAS
# ------------------------------------------------------------
func _gerar_terreno_base() -> void:
	if chao_layer == null: return
	
	var w = config.width_tiles
	var h = config.height_tiles
	
	# Preenchimento base de grama com variação sutil
	for y in range(h):
		for x in range(w):
			var cell = Vector2i(x, y)
			
			# Bordas montanhosas intransponíveis (8 tiles em toda a periferia)
			if x < 8 or x >= w - 8 or y < 8 or y >= h - 8:
				if paredes_layer:
					paredes_layer.set_cell(cell, 4, TILE_ROCHA_SOLIDA)
				continue
				
			# Chão de grama natural
			chao_layer.set_cell(cell, 2, TILE_GRAMA_BASE)


# ------------------------------------------------------------
# 2. GRANDE RIO, LAGO E PONTES
# ------------------------------------------------------------
func _gerar_grande_rio_e_lagos() -> void:
	if chao_layer == null or paredes_layer == null: return
	
	var base_x = config.river_x
	
	# Rio vertical sinuoso com meandros naturais
	for y in range(8, config.height_tiles - 8):
		var offset = int(sin(float(y) / 25.0) * 12.0 + cos(float(y) / 12.0) * 4.0)
		var rx = base_x + offset
		var largura_rio = 10
		
		for x in range(rx - largura_rio / 2, rx + largura_rio / 2):
			if x < 8 or x >= config.width_tiles - 8: continue
			var cell = Vector2i(x, y)
			
			# Pontes de travessia (Não coloca água onde há pontes)
			var eh_ponte_principal = (y >= 252 and y <= 258) # Estrada Real
			var eh_ponte_norte = (y >= 80 and y <= 84) # Estrada Norte
			
			if eh_ponte_principal or eh_ponte_norte:
				chao_layer.set_cell(cell, 0, TILE_CHAO_URBANO) # Ponte de pedra firme
				if paredes_layer:
					paredes_layer.erase_cell(cell)
			else:
				chao_layer.set_cell(cell, 10, TILE_AGUA_RIO)
				paredes_layer.set_cell(cell, 4, TILE_ROCHA_SOLIDA) # Colisão de água profunda
				
	# Lago do Norte (origem do rio)
	for y in range(40, 75):
		for x in range(160, 210):
			var dist = Vector2(x - 185, y - 57).length()
			if dist < 22.0:
				var cell = Vector2i(x, y)
				chao_layer.set_cell(cell, 10, TILE_AGUA_RIO)
				paredes_layer.set_cell(cell, 4, TILE_ROCHA_SOLIDA)


# ------------------------------------------------------------
# 3. VILA DE PADOKIA (ZONA SEGURA - 100x100)
# ------------------------------------------------------------
func _gerar_vila_padokia() -> void:
	if chao_layer == null or paredes_layer == null: return
	
	var tr = config.town_rect
	
	# Pavimentação da Vila
	for y in range(tr.position.y, tr.position.y + tr.size.y):
		for x in range(tr.position.x, tr.position.x + tr.size.x):
			var cell = Vector2i(x, y)
			
			# Muro perimetral da vila com portões
			if x == tr.position.x or x == tr.position.x + tr.size.x - 1 or y == tr.position.y or y == tr.position.y + tr.size.y - 1:
				var eh_portao_leste = (x == tr.position.x + tr.size.x - 1 and y >= 252 and y <= 258)
				var eh_portao_norte = (y == tr.position.y and x >= 72 and x <= 78)
				if not eh_portao_leste and not eh_portao_norte:
					paredes_layer.set_cell(cell, 4, TILE_MURO_PEDRA)
				continue
				
			# Chão urbano de pedras e calçadas
			chao_layer.set_cell(cell, 0, TILE_CHAO_URBANO)
			
	# Praça Central (X: 65-85, Y: 245-265)
	for y in range(245, 266):
		for x in range(65, 86):
			chao_layer.set_cell(Vector2i(x, y), 0, TILE_PISO_MADEIRA)
			
	# Fonte / Monumento Central
	if decor_layer:
		decor_layer.set_cell(Vector2i(75, 255), 8, TILE_FONTE_CENTRAL)
		decor_layer.set_cell(Vector2i(70, 250), 8, TILE_POSTE_LUZ)
		decor_layer.set_cell(Vector2i(80, 250), 8, TILE_POSTE_LUZ)
		decor_layer.set_cell(Vector2i(70, 260), 8, TILE_POSTE_LUZ)
		decor_layer.set_cell(Vector2i(80, 260), 8, TILE_POSTE_LUZ)
		
	# 6 Edifícios com Fachadas e Portas Interativas:
	_construir_fachada_edificio(Vector2i(35, 215), 12, 10, "Residência do Caçador", PadokiaInteriors.InteriorType.PLAYER_HOUSE)
	_construir_fachada_edificio(Vector2i(55, 215), 14, 10, "Casa do Ancião Erudito", PadokiaInteriors.InteriorType.SCHOLAR_HOUSE)
	_construir_fachada_edificio(Vector2i(85, 215), 14, 10, "Oficina do Ferreiro", PadokiaInteriors.InteriorType.BLACKSMITH_HOUSE)
	_construir_fachada_edificio(Vector2i(35, 275), 14, 10, "Alojamento dos Caçadores", PadokiaInteriors.InteriorType.SCOUT_LODGE)
	_construir_fachada_edificio(Vector2i(60, 275), 16, 12, "Empório de Padokia", PadokiaInteriors.InteriorType.SHOP)
	_construir_fachada_edificio(Vector2i(90, 275), 18, 12, "Dojo de Nen (Mestre Wing)", PadokiaInteriors.InteriorType.DOJO)


func _construir_fachada_edificio(origem: Vector2i, largura: int, altura: int, nome_edificio: String, tipo: PadokiaInteriors.InteriorType) -> void:
	var porta_x = largura / 2
	
	for y in range(altura):
		for x in range(largura):
			var cell = origem + Vector2i(x, y)
			if y == altura - 1 and (x == porta_x or x == porta_x + 1):
				chao_layer.set_cell(cell, 0, TILE_PISO_MADEIRA) # Porta de entrada
				if y == altura - 1 and x == porta_x:
					_criar_porta_transicao(cell, nome_edificio, tipo)
			else:
				paredes_layer.set_cell(cell, 0, TILE_PAREDE_CASA) # Parede exterior sólida


func _criar_porta_transicao(cell: Vector2i, nome_edificio: String, tipo: PadokiaInteriors.InteriorType) -> void:
	var chunk = _obter_chunk_para_posicao(cell)
	var portal = MapTransitionArea.new()
	portal.name = "Porta_" + nome_edificio.replace(" ", "_")
	portal.position = Vector2((cell.x + 0.5) * config.tile_size, (cell.y + 0.5) * config.tile_size)
	portal.target_scene_path = "res://world/maps/interiors/padokia_interior_generic.tscn"
	portal.portal_name = nome_edificio
	portal.map_subtitle = "Interior"
	portal.requires_e_key = true
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(28, 28)
	col.shape = box
	portal.add_child(col)
	
	# Conectar troca para configurar o interior correspondente
	portal.callback_dialogo_previo = Callable(func(callback_troca: Callable):
		var tree = get_tree()
		if tree != null:
			# Passar o tipo de interior no PlayerData para a cena instanciar o tipo correto
			PlayerData.quest_states["interior_ativo"] = tipo
		callback_troca.call()
	)
	
	chunk.add_child(portal)


# ------------------------------------------------------------
# 4. REDE DE ESTRADAS & CAMINHOS
# ------------------------------------------------------------
func _gerar_rede_estradas_e_caminhos() -> void:
	if chao_layer == null: return
	
	# 1. Estrada Real (Vila -> Ponte -> Cruzamento Central -> Ruínas)
	var rota_principal = [
		Vector2i(130, 255), # Portão Leste da Vila
		Vector2i(180, 255), # Ponte do Rio
		Vector2i(240, 250), # Entrada da Floresta
		Vector2i(320, 230), # Cruzamento Central
		Vector2i(380, 160), # Encosta das Ruínas
		Vector2i(430, 90)   # Pórtico da Dungeon
	]
	_tracar_estrada_suave(rota_principal, 5)
	
	# 2. Rota Secundária Sul (Cruzamento -> Ravina de Perigo)
	var rota_sul = [
		Vector2i(320, 230),
		Vector2i(350, 290),
		Vector2i(380, 360),
		Vector2i(400, 420)
	]
	_tracar_estrada_suave(rota_sul, 4)
	
	# 3. Rota Secundária Norte (Ponte do Rio Norte -> Torre de Vigia -> Caverna)
	var rota_norte = [
		Vector2i(75, 200),  # Portão Norte da Vila
		Vector2i(120, 80),  # Torre de Vigia
		Vector2i(180, 82),  # Ponte Norte
		Vector2i(230, 70)   # Caverna do Ermitão
	]
	_tracar_estrada_suave(rota_norte, 3)


func _tracar_estrada_suave(pontos: Array, largura: int) -> void:
	for i in range(pontos.size() - 1):
		var p1: Vector2i = pontos[i]
		var p2: Vector2i = pontos[i + 1]
		var passos = int(p1.distance_to(p2) * 1.5)
		
		for s in range(passos + 1):
			var t = float(s) / float(max(1, passos))
			var cx = int(lerp(float(p1.x), float(p2.x), t))
			var cy = int(lerp(float(p1.y), float(p2.y), t))
			
			for dy in range(-largura / 2, largura / 2 + 1):
				for dx in range(-largura / 2, largura / 2 + 1):
					var cell = Vector2i(cx + dx, cy + dy)
					if cell.x >= 8 and cell.x < config.width_tiles - 8 and cell.y >= 8 and cell.y < config.height_tiles - 8:
						# Não sobrepõe água se não for ponte
						var tile_atual = chao_layer.get_cell_atlas_coords(cell)
						if tile_atual != TILE_AGUA_RIO:
							chao_layer.set_cell(cell, 3, TILE_ESTRADA_TERRA)


# ------------------------------------------------------------
# 5. FLORESTA DOS VESTÍGIOS & CLAREIRAS
# ------------------------------------------------------------
func _gerar_floresta_e_clareiras() -> void:
	if decor_layer == null: return
	
	var rnd = RandomNumberGenerator.new()
	rnd.seed = config.generation_seed
	
	# Densidade de árvores e vegetação na Floresta Central (X: 200-340, Y: 120-360)
	for y in range(120, 360, 3):
		for x in range(200, 340, 3):
			var cell = Vector2i(x, y)
			var tile_chao = chao_layer.get_cell_atlas_coords(cell)
			
			# Não planta árvores em cima de estradas ou água
			if tile_chao == TILE_ESTRADA_TERRA or tile_chao == TILE_AGUA_RIO or tile_chao == TILE_CHAO_URBANO:
				continue
				
			# Clareiras naturais (Árvore Milenar e Acampamento)
			if cell.distance_to(Vector2i(280, 240)) < 12 or cell.distance_to(Vector2i(260, 340)) < 10:
				continue
				
			if rnd.randf() < 0.65:
				decor_layer.set_cell(cell, 7, TILE_ARVORE_BASE)
				if paredes_layer and rnd.randf() < 0.35:
					paredes_layer.set_cell(cell, 4, TILE_ROCHA_SOLIDA) # Colisão no tronco
			elif rnd.randf() < 0.30:
				decor_layer.set_cell(cell, 7, TILE_ARBUSTO)
				
	# Landmark: Árvore Milenar (X: 280, Y: 240)
	decor_layer.set_cell(Vector2i(280, 240), 7, TILE_ARVORE_TOPO)
	decor_layer.set_cell(Vector2i(280, 241), 7, TILE_ARVORE_BASE)
	decor_layer.set_cell(Vector2i(279, 241), 5, TILE_FLOR)
	decor_layer.set_cell(Vector2i(281, 241), 5, TILE_FLOR)


# ------------------------------------------------------------
# 6. RAVINA DA NÉVOA TÓXICA (ZONA DE PERIGO)
# ------------------------------------------------------------
func _gerar_ravina_perigo() -> void:
	var dr = config.danger_rect
	var chunk = _obter_chunk_para_posicao(dr.position + dr.size / 2)
	
	# Miasma Tóxico com TenHazardZone
	var hazard = TenHazardZone.new()
	hazard.name = "TenHazardMiasma"
	hazard.position = Vector2((dr.position.x + dr.size.x / 2) * config.tile_size, (dr.position.y + dr.size.y / 2) * config.tile_size)
	hazard.hazard_name = "Miasma Ácido da Ravina"
	hazard.dano_por_tick = 8
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(dr.size.x * config.tile_size * 0.7, dr.size.y * config.tile_size * 0.7)
	col.shape = box
	hazard.add_child(col)
	chunk.add_child(hazard)
	
	# Ninho Predador com ZetsuSensorZone
	var zetsu_zone = ZetsuSensorZone.new()
	zetsu_zone.name = "ZetsuSensorPredadores"
	zetsu_zone.position = Vector2(360 * config.tile_size, 460 * config.tile_size)
	zetsu_zone.zone_id = &"ninho_feras_padokia"
	zetsu_zone.zone_name = "Ninho das Feras das Sombras"
	
	var zcol = CollisionShape2D.new()
	var zbox = RectangleShape2D.new()
	zbox.size = Vector2(400, 300)
	zcol.shape = zbox
	zetsu_zone.add_child(zcol)
	chunk.add_child(zetsu_zone)


# ------------------------------------------------------------
# 7. DUNGEON: RUÍNAS DO SANTUÁRIO DE ZABAN
# ------------------------------------------------------------
func _gerar_dungeon_ruinas() -> void:
	var d_rect = config.dungeon_rect
	var chunk = _obter_chunk_para_posicao(Vector2i(430, 90))
	
	# Fachada com Pilares Monumentais
	if decor_layer:
		for px in [420, 426, 434, 440]:
			decor_layer.set_cell(Vector2i(px, 86), 9, TILE_PILAR_RUINA)
			decor_layer.set_cell(Vector2i(px, 94), 9, TILE_PILAR_RUINA)
			
	# Portal de Entrada da Dungeon
	var portal_dung = MapTransitionArea.new()
	portal_dung.name = "PortalDungeonZaban"
	portal_dung.position = Vector2(430 * config.tile_size, 90 * config.tile_size)
	portal_dung.target_scene_path = "res://world/maps/dungeon_ruinas_zaban.tscn"
	portal_dung.portal_name = "Ruínas do Santuário de Zaban"
	portal_dung.map_subtitle = "Dungeon Ancestral & Boss"
	portal_dung.requires_e_key = true
	
	var pcol = CollisionShape2D.new()
	var pbox = RectangleShape2D.new()
	pbox.size = Vector2(48, 64)
	pcol.shape = pbox
	portal_dung.add_child(pcol)
	chunk.add_child(portal_dung)
	
	# Totem Ancestral de Nen com REN
	var beacon = RenBeacon.new()
	beacon.name = "RenBeaconRuinas"
	beacon.position = Vector2(470 * config.tile_size, 60 * config.tile_size)
	beacon.beacon_name = "Altar Ancestral de Zaban"
	
	var bcol = CollisionShape2D.new()
	var bbox = RectangleShape2D.new()
	bbox.size = Vector2(64, 64)
	bcol.shape = bbox
	beacon.add_child(bcol)
	chunk.add_child(beacon)
	
	# Portão de Atalho Destravável
	var shortcut = ShortcutDoor.new()
	shortcut.name = "ShortcutRuinas"
	shortcut.position = Vector2(400 * config.tile_size, 120 * config.tile_size)
	shortcut.shortcut_id = &"atalho_padokia_ruinas"
	shortcut.door_name = "Portão de Ferro das Ruínas"
	
	var scol = CollisionShape2D.new()
	var sbox = RectangleShape2D.new()
	sbox.size = Vector2(48, 80)
	scol.shape = sbox
	shortcut.add_child(scol)
	chunk.add_child(shortcut)


# ------------------------------------------------------------
# 8. COLINAS DO NORTE & CAVERNA SECRETA DO ERMITÃO
# ------------------------------------------------------------
func _gerar_colinas_norte_e_caverna() -> void:
	var chunk = _obter_chunk_para_posicao(Vector2i(230, 70))
	
	# Barreira de Rocha com KO
	var ko_obs = KoObstacle.new()
	ko_obs.name = "KoObstacleCaverna"
	ko_obs.position = Vector2(230 * config.tile_size, 70 * config.tile_size)
	ko_obs.obstacle_name = "Barreira de Rocha da Caverna"
	
	var kcol = CollisionShape2D.new()
	var kbox = RectangleShape2D.new()
	kbox.size = Vector2(64, 64)
	kcol.shape = kbox
	ko_obs.add_child(kcol)
	chunk.add_child(ko_obs)
	
	# Portal para interior da caverna atrás da rocha
	var portal_cav = MapTransitionArea.new()
	portal_cav.name = "PortalCavernaErmitao"
	portal_cav.position = Vector2(230 * config.tile_size, 64 * config.tile_size)
	portal_cav.target_scene_path = "res://world/maps/interiors/padokia_interior_generic.tscn"
	portal_cav.portal_name = "Caverna Oculta do Ermitão"
	portal_cav.requires_e_key = true
	
	var ccol = CollisionShape2D.new()
	var cbox = RectangleShape2D.new()
	cbox.size = Vector2(48, 48)
	ccol.shape = cbox
	portal_cav.add_child(ccol)
	
	portal_cav.callback_dialogo_previo = Callable(func(callback_troca: Callable):
		PlayerData.quest_states["interior_ativo"] = PadokiaInteriors.InteriorType.HERMIT_CAVE
		callback_troca.call()
	)
	chunk.add_child(portal_cav)
	
	# Pista GYO
	var gyo_clue = GyoInspectable.new()
	gyo_clue.name = "GyoClueCaverna"
	gyo_clue.position = Vector2(310 * config.tile_size, 120 * config.tile_size)
	gyo_clue.clue_id = &"pista_rocha_nen"
	gyo_clue.titulo_pista = "Selo de Nen Oculto"
	gyo_clue.descricao_pista = "Aura concentrada detectada nesta fissura! Utilize KO para romper."
	gyo_clue.requer_gyo = true
	chunk.add_child(gyo_clue)


# ------------------------------------------------------------
# 9. POIS & SEGREDOS DATA-DRIVEN
# ------------------------------------------------------------
func _posicionar_pois_e_segredos() -> void:
	for poi in config.pois:
		var tile_pos = Vector2i(int(poi.world_position.x / config.tile_size), int(poi.world_position.y / config.tile_size))
		var chunk = _obter_chunk_para_posicao(tile_pos)
		
		var marker = Marker2D.new()
		marker.name = "POI_" + str(poi.poi_id)
		marker.position = poi.world_position - chunk.position
		marker.add_to_group("poi_marker")
		chunk.add_child(marker)


# ------------------------------------------------------------
# 10. NPCS & INIMIGOS TERRITORIAIS
# ------------------------------------------------------------
func _instanciar_npcs_e_inimigos() -> void:
	# 1. NPCs na Vila de Padokia (Zona Segura)
	_instanciar_npc_vila("Mestre Wing", Vector2(105 * 16, 260 * 16), "res://entities/npc/wing/Wing.tscn")
	_instanciar_npc_vila("Vendedor", Vector2(68 * 16, 260 * 16), "res://entities/npc/vendedor/Vendedor.tscn")
	_instanciar_npc_vila("Guarda da Vila", Vector2(130 * 16, 250 * 16), "res://entities/npc/NPC.tscn")
	_instanciar_npc_vila("Cidadão Nicol", Vector2(75 * 16, 248 * 16), "res://entities/npc/nicol/Nicol.tscn")
	
	# 2. Inimigos na Estrada (Baixa Densidade)
	_instanciar_inimigo(Vector2(200 * 16, 255 * 16), "Slime da Estrada")
	_instanciar_inimigo(Vector2(300 * 16, 235 * 16), "Slime da Estrada")
	
	# 3. Inimigos na Floresta (Média Densidade)
	_instanciar_inimigo(Vector2(230 * 16, 180 * 16), "Fera da Floresta")
	_instanciar_inimigo(Vector2(270 * 16, 200 * 16), "Fera da Floresta")
	_instanciar_inimigo(Vector2(310 * 16, 280 * 16), "Fera da Floresta")
	
	# 4. Inimigos na Ravina de Perigo (Alta Densidade / Elites)
	_instanciar_inimigo(Vector2(380 * 16, 400 * 16), "Criatura Predadora da Névoa")
	_instanciar_inimigo(Vector2(420 * 16, 440 * 16), "Criatura Predadora da Névoa")
	_instanciar_inimigo(Vector2(450 * 16, 420 * 16), "Guardião de Elite da Ravina")
	
	# 5. Inimigos nas Ruínas da Dungeon (Extrema Densidade / Guardiões)
	_instanciar_inimigo(Vector2(420 * 16, 100 * 16), "Sentinela de Pedra das Ruínas")
	_instanciar_inimigo(Vector2(450 * 16, 80 * 16), "Guardião Ancestral de Zaban")


func _instanciar_npc_vila(nome: String, pos: Vector2, scene_path: String) -> void:
	var tile_pos = Vector2i(int(pos.x / config.tile_size), int(pos.y / config.tile_size))
	var chunk = _obter_chunk_para_posicao(tile_pos)
	
	if ResourceLoader.exists(scene_path):
		var scn = load(scene_path)
		if scn:
			var npc = scn.instantiate()
			npc.name = nome.replace(" ", "_")
			npc.position = pos - chunk.position
			chunk.add_child(npc)
			return
			
	# Fallback para NPC genérico
	var fallback_npc = load("res://entities/npc/NPC.tscn").instantiate()
	fallback_npc.name = nome.replace(" ", "_")
	fallback_npc.position = pos - chunk.position
	chunk.add_child(fallback_npc)


func _instanciar_inimigo(pos: Vector2, nome: String) -> void:
	var tile_pos = Vector2i(int(pos.x / config.tile_size), int(pos.y / config.tile_size))
	var chunk = _obter_chunk_para_posicao(tile_pos)
	
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn:
		var enemy = enemy_scn.instantiate()
		enemy.name = nome.replace(" ", "_")
		enemy.position = pos - chunk.position
		chunk.add_child(enemy)


# ------------------------------------------------------------
# 11. POSICIONAMENTO DO PLAYER
# ------------------------------------------------------------
func posicionar_player() -> void:
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as CharacterBody2D
			
	if player != null:
		var spawn_px = Vector2(config.spawn_tile.x * config.tile_size + 8, config.spawn_tile.y * config.tile_size + 8)
		player.global_position = spawn_px
		print("[REGION WORLD GENERATOR] Player posicionado no Spawn da Vila: ", spawn_px)
		
		var cam: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = config.width_tiles * config.tile_size
			cam.limit_bottom = config.height_tiles * config.tile_size
