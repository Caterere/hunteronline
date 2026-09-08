@tool
extends SceneTree

func _init() -> void:
	print("[*] Iniciando geração da cena do Lobby MMORPG com TileMapLayers...")
	var tileset = load("res://world/tilesets/lobby_tileset.tres") as TileSet
	if tileset == null:
		print("[-] Erro: lobby_tileset.tres não encontrado!")
		quit()
		return

	# Carregar a cena existente do lobby
	var scn = load("res://world/lobby.tscn") as PackedScene
	if scn == null:
		print("[-] Erro: world/lobby.tscn não encontrado!")
		quit()
		return

	var lobby = scn.instantiate()

	# Remover plano antigo ChaoGramaLobby se existir na árvore salva
	var old_chao = lobby.get_node_or_null("ChaoGramaLobby")
	if old_chao != null:
		old_chao.free()

	# 1. Obter ou criar camadas de TileMapLayer
	var chao_layer: TileMapLayer = lobby.get_node_or_null("Chao_TileMapLayer")
	if chao_layer == null:
		chao_layer = TileMapLayer.new()
		chao_layer.name = "Chao_TileMapLayer"
		chao_layer.z_index = -12
		lobby.add_child(chao_layer)
		chao_layer.owner = lobby

	var caminhos_layer: TileMapLayer = lobby.get_node_or_null("Caminhos_TileMapLayer")
	if caminhos_layer == null:
		caminhos_layer = TileMapLayer.new()
		caminhos_layer.name = "Caminhos_TileMapLayer"
		caminhos_layer.z_index = -10
		lobby.add_child(caminhos_layer)
		caminhos_layer.owner = lobby

	var praca_layer: TileMapLayer = lobby.get_node_or_null("Praca_TileMapLayer")
	if praca_layer == null:
		praca_layer = TileMapLayer.new()
		praca_layer.name = "Praca_TileMapLayer"
		praca_layer.z_index = -8
		lobby.add_child(praca_layer)
		praca_layer.owner = lobby

	var estruturas_layer: TileMapLayer = lobby.get_node_or_null("Estruturas_TileMapLayer")
	if estruturas_layer == null:
		estruturas_layer = TileMapLayer.new()
		estruturas_layer.name = "Estruturas_TileMapLayer"
		estruturas_layer.z_index = 0
		lobby.add_child(estruturas_layer)
		estruturas_layer.owner = lobby

	var decor_layer: TileMapLayer = lobby.get_node_or_null("Decor_TileMapLayer")
	if decor_layer == null:
		decor_layer = TileMapLayer.new()
		decor_layer.name = "Decor_TileMapLayer"
		decor_layer.z_index = 2
		lobby.add_child(decor_layer)
		decor_layer.owner = lobby

	chao_layer.tile_set = tileset
	caminhos_layer.tile_set = tileset
	praca_layer.tile_set = tileset
	estruturas_layer.tile_set = tileset
	decor_layer.tile_set = tileset

	chao_layer.clear()
	caminhos_layer.clear()
	praca_layer.clear()
	estruturas_layer.clear()
	decor_layer.clear()

	# Configurações de Dimensão (em tiles de 16x16)
	# Área total: x de -80 a 105 (aprox -1280px a 1680px), y de -50 a 45 (aprox -800px a 720px)
	var min_tx = -80
	var max_tx = 105
	var min_ty = -50
	var max_ty = 45

	print("[*] Preenchendo terreno base de grama MMORPG com variações...")
	# 1. CAMADA 1: TERRENO BASE DE GRAMA (Source ID 0)
	for ty in range(min_ty, max_ty + 1):
		for tx in range(min_tx, max_tx + 1):
			# Variação sutil de grama (tiles 1:1, 2:1, 1:2, 2:2)
			var gx = 1 + (abs((tx * 7 + ty * 13)) % 3)
			var gy = 1 + (abs((tx * 11 + ty * 5)) % 3)
			chao_layer.set_cell(Vector2i(tx, ty), 0, Vector2i(gx, gy))

	print("[*] Construindo Praça Central e Estradas de Pedra...")
	# 2. CAMADA 2: PRAÇA CENTRAL (Raio de 18 tiles em volta de 0,0)
	# Source ID 1 (TX Tileset Stone Ground.png)
	for ty in range(-16, 17):
		for tx in range(-16, 17):
			var dist = sqrt(float(tx * tx + ty * ty))
			if dist <= 14.5:
				var sx = 1 + (abs(tx * 3 + ty * 7) % 2)
				var sy = 1 + (abs(tx * 5 + ty * 2) % 2)
				praca_layer.set_cell(Vector2i(tx, ty), 1, Vector2i(sx, sy))
			elif dist <= 16.0:
				# Borda da praça
				praca_layer.set_cell(Vector2i(tx, ty), 1, Vector2i(0, 0))

	# 3. CAMADA 2: GRANDES AVENIDAS MMORPG (Largura de 5 tiles)
	# Estrada Norte (Praça até Distrito dos Mestres em y = -40, x de -2 a 2)
	for ty in range(-45, -14):
		for tx in range(-2, 3):
			var sx = 1 + (abs(tx + ty * 3) % 2)
			var sy = 1 + (abs(tx * 2 + ty) % 2)
			caminhos_layer.set_cell(Vector2i(tx, ty), 1, Vector2i(sx, sy))
		# Guias laterais da estrada
		caminhos_layer.set_cell(Vector2i(-3, ty), 1, Vector2i(0, 1))
		caminhos_layer.set_cell(Vector2i(3, ty), 1, Vector2i(3, 1))

	# Estrada Sul (Praça até Portão do Mundo Exterior em y = 30)
	for ty in range(15, 35):
		for tx in range(-2, 3):
			var sx = 1 + (abs(tx + ty * 3) % 2)
			var sy = 1 + (abs(tx * 2 + ty) % 2)
			caminhos_layer.set_cell(Vector2i(tx, ty), 1, Vector2i(sx, sy))
		caminhos_layer.set_cell(Vector2i(-3, ty), 1, Vector2i(0, 1))
		caminhos_layer.set_cell(Vector2i(3, ty), 1, Vector2i(3, 1))

	# Estrada Oeste (Praça até Distrito Comercial x = -40 a -65, y de -2 a 2)
	for tx in range(-70, -14):
		for ty in range(-2, 3):
			var sx = 1 + (abs(tx * 3 + ty) % 2)
			var sy = 1 + (abs(tx + ty * 2) % 2)
			caminhos_layer.set_cell(Vector2i(tx, ty), 1, Vector2i(sx, sy))
		caminhos_layer.set_cell(Vector2i(tx, -3), 1, Vector2i(1, 0))
		caminhos_layer.set_cell(Vector2i(tx, 3), 1, Vector2i(1, 3))

	# Estrada Leste (Praça até Distrito Dimensional x = 15 a 90, y de -2 a 2)
	for tx in range(15, 95):
		for ty in range(-2, 3):
			var sx = 1 + (abs(tx * 3 + ty) % 2)
			var sy = 1 + (abs(tx + ty * 2) % 2)
			caminhos_layer.set_cell(Vector2i(tx, ty), 1, Vector2i(sx, sy))
		caminhos_layer.set_cell(Vector2i(tx, -3), 1, Vector2i(1, 0))
		caminhos_layer.set_cell(Vector2i(tx, 3), 1, Vector2i(1, 3))

	# Ramificação Nordeste para o Distrito dos Mestres (de x=25 a 70, y=-40)
	for tx in range(25, 75):
		for ty in range(-42, -38):
			caminhos_layer.set_cell(Vector2i(tx, ty), 1, Vector2i(1, 1))

	# Ramificação Sudeste para o Distrito Dimensional (de x=35 a 75, y=28)
	for tx in range(35, 75):
		for ty in range(26, 30):
			caminhos_layer.set_cell(Vector2i(tx, ty), 1, Vector2i(1, 1))

	print("[*] Inserindo edificações dos Distritos...")
	# 4. EDIFICAÇÕES DOS DISTRITOS
	# Função auxiliar para estampar edifícios completos
	var estampar_edificio = func(layer: TileMapLayer, source_id: int, origin_tx: int, origin_ty: int, cols: int, rows: int):
		for cy in range(rows):
			for cx in range(cols):
				layer.set_cell(Vector2i(origin_tx + cx, origin_ty + cy), source_id, Vector2i(cx, cy))

	# A. Distrito Norte - Dojo dos Mestres de Nen (Quartel/Dojo Source 12, 12x16 tiles) em x=20, y=-52
	estampar_edificio.call(estruturas_layer, 12, 20, -54, 12, 16)
	# Monastério dos Mestres em x=50, y=-56 (Source 10, 12x20 tiles)
	estampar_edificio.call(estruturas_layer, 10, 50, -58, 12, 20)

	# B. Distrito Oeste - Forja e Comércio
	# Arquearia/Oficina do Ferreiro em x=-45, y=-25 (Source 13, 12x16 tiles)
	estampar_edificio.call(estruturas_layer, 13, -48, -25, 12, 16)
	# Armazém do Mercador em x=-45, y=10 (Source 12, 12x16 tiles)
	estampar_edificio.call(estruturas_layer, 12, -48, 8, 12, 16)
	# Bairro Residencial - Casa do Caçador em x=-70, y=-10 (Source 16, 8x12 tiles)
	estampar_edificio.call(estruturas_layer, 16, -72, -10, 8, 12)
	# Casas Adicionais dos Cidadãos
	estampar_edificio.call(estruturas_layer, 15, -72, 8, 8, 10)
	estampar_edificio.call(estruturas_layer, 17, -72, -26, 8, 10)

	# C. Distrito Leste - Santuário Dimensional & Torre Celestial
	# Grande Monastério Dimensional em x=45, y=20 (Source 10, 12x20 tiles)
	estampar_edificio.call(estruturas_layer, 10, 42, 18, 12, 20)
	# Fachada da Torre Celestial em x=82, y=-10 (Source 11 Castelo, 20x16 tiles)
	estampar_edificio.call(estruturas_layer, 11, 80, -10, 20, 16)
	# Torre Alta Adjacente em x=72, y=-18 (Source 14 Torre, 8x16 tiles)
	estampar_edificio.call(estruturas_layer, 14, 72, -18, 8, 16)

	# D. Sul - Portão Principal da Associação Hunter (Source 11 Castelo / Muralhas)
	estampar_edificio.call(estruturas_layer, 14, -15, 26, 8, 16)
	estampar_edificio.call(estruturas_layer, 14, 7, 26, 8, 16)

	print("[*] Inserindo decorações (Postes, Fontes, Bancos, Árvores)...")
	# 5. DECORAÇÕES E PROPS
	# Postes de Luz ao longo das avenidas (Source 4 TX Props)
	# Avenidas Norte e Sul
	for y_lane in [-36, -26, -16, 18, 28]:
		decor_layer.set_cell(Vector2i(-4, y_lane), 4, Vector2i(2, 6))
		decor_layer.set_cell(Vector2i(4, y_lane), 4, Vector2i(2, 6))

	# Avenidas Oeste e Leste
	for x_lane in [-60, -45, -30, 20, 35, 50, 65]:
		decor_layer.set_cell(Vector2i(x_lane, -4), 4, Vector2i(2, 6))
		decor_layer.set_cell(Vector2i(x_lane, 4), 4, Vector2i(2, 6))

	# Árvores frondosas contornando a praça e avenidas (Source 5 TX Plant)
	# Árvores ocupam aprox 3x3 tiles
	var pos_arvores = [
		Vector2i(-12, -12), Vector2i(12, -12), Vector2i(-12, 12), Vector2i(12, 12),
		Vector2i(-20, -6), Vector2i(-20, 6), Vector2i(20, -6), Vector2i(20, 6),
		Vector2i(-8, -25), Vector2i(8, -25), Vector2i(-8, 22), Vector2i(8, 22),
		Vector2i(-32, -12), Vector2i(-32, 12), Vector2i(32, -12), Vector2i(32, 12),
		Vector2i(60, -6), Vector2i(60, 6), Vector2i(-58, -18), Vector2i(-58, 18)
	]
	for p in pos_arvores:
		# Árvore 2x3 tiles
		decor_layer.set_cell(p, 5, Vector2i(1, 1))
		decor_layer.set_cell(p + Vector2i(1, 0), 5, Vector2i(2, 1))
		decor_layer.set_cell(p + Vector2i(0, 1), 5, Vector2i(1, 2))
		decor_layer.set_cell(p + Vector2i(1, 1), 5, Vector2i(2, 2))

	# Bancos de pedra na Praça Central
	decor_layer.set_cell(Vector2i(-6, -6), 4, Vector2i(4, 2))
	decor_layer.set_cell(Vector2i(6, -6), 4, Vector2i(4, 2))
	decor_layer.set_cell(Vector2i(-6, 6), 4, Vector2i(4, 2))
	decor_layer.set_cell(Vector2i(6, 6), 4, Vector2i(4, 2))

	# Estandartes e Caixotes no Distrito Comercial
	decor_layer.set_cell(Vector2i(-38, -1), 4, Vector2i(6, 4))
	decor_layer.set_cell(Vector2i(-38, 1), 4, Vector2i(6, 5))
	decor_layer.set_cell(Vector2i(-52, -2), 4, Vector2i(7, 4))

	# Salvar a cena do lobby atualizada
	var pack_err = scn.pack(lobby)
	if pack_err == OK:
		var save_err = ResourceSaver.save(scn, "res://world/lobby.tscn")
		if save_err == OK:
			print("[SUCCESS] world/lobby.tscn atualizado e salvo com sucesso!")
		else:
			print("[-] Erro ao salvar world/lobby.tscn: ", save_err)
	else:
		print("[-] Erro ao empacotar lobby scene: ", pack_err)

	lobby.free()
	quit()
