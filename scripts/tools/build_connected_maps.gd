@tool
extends SceneTree

func _init() -> void:
	print("[*] Iniciando construcao dos Mapas Conectados Permanentes...")
	var tileset = load("res://world/tilesets/lobby_tileset.tres") as TileSet
	if tileset == null:
		print("[-] Erro: lobby_tileset.tres nao encontrado!")
		quit()
		return

	var player_scn = load("res://entities/Player/Player.tscn") as PackedScene
	var hud_scn = load("res://ui/hud/HUD.tscn") as PackedScene
	var estrada_script = load("res://world/maps/EstradaPadokiaMap.gd")
	var floresta_script = load("res://world/maps/FlorestaVestigiosMap.gd")

	# ============================================================
	# 1. CONSTRUÇÃO DE ESTRADA REAL DE PADOKIA (estrada_padokia.tscn)
	# ============================================================
	print("[*] Gerando Estrada Real de Padokia...")
	var estrada = Node2D.new()
	estrada.name = "EstradaPadokiaMap"
	estrada.set_script(estrada_script)

	var est_chao = TileMapLayer.new()
	est_chao.name = "Chao_TileMapLayer"
	est_chao.tile_set = tileset
	est_chao.z_index = -12
	estrada.add_child(est_chao)
	est_chao.owner = estrada

	var est_caminhos = TileMapLayer.new()
	est_caminhos.name = "Caminhos_TileMapLayer"
	est_caminhos.tile_set = tileset
	est_caminhos.z_index = -10
	estrada.add_child(est_caminhos)
	est_caminhos.owner = estrada

	var est_estruturas = TileMapLayer.new()
	est_estruturas.name = "Estruturas_TileMapLayer"
	est_estruturas.tile_set = tileset
	est_estruturas.z_index = 0
	estrada.add_child(est_estruturas)
	est_estruturas.owner = estrada

	var est_decor = TileMapLayer.new()
	est_decor.name = "Decor_TileMapLayer"
	est_decor.tile_set = tileset
	est_decor.z_index = 2
	estrada.add_child(est_decor)
	est_decor.owner = estrada

	# Dimensões: 50x40 tiles (800x640 px)
	# Preencher terreno base de grama
	for ty in range(0, 40):
		for tx in range(0, 50):
			var gx = 1 + (abs(tx * 3 + ty * 7) % 3)
			var gy = 1 + (abs(tx * 5 + ty * 11) % 3)
			est_chao.set_cell(Vector2i(tx, ty), 0, Vector2i(gx, gy))

	# Estrada Real Central (Norte a Sul, colunas 22 a 27)
	for ty in range(0, 40):
		for tx in range(22, 28):
			var sx = 1 + (abs(tx + ty * 3) % 2)
			var sy = 1 + (abs(tx * 2 + ty) % 2)
			est_caminhos.set_cell(Vector2i(tx, ty), 1, Vector2i(sx, sy))
		# Guias laterais da estrada de pedra
		est_caminhos.set_cell(Vector2i(21, ty), 1, Vector2i(0, 1))
		est_caminhos.set_cell(Vector2i(28, ty), 1, Vector2i(3, 1))

	# Ramal Oeste para o Acampamento da Fogueira (ty: 14..16, tx: 12..21)
	for ty in range(14, 17):
		for tx in range(14, 22):
			est_caminhos.set_cell(Vector2i(tx, ty), 1, Vector2i(1, 1))

	# Torre de Guarda ao Norte (tx: 12, ty: 2, 8x16)
	for cy in range(16):
		for cx in range(8):
			est_estruturas.set_cell(Vector2i(12 + cx, 2 + cy), 14, Vector2i(cx, cy))

	# Postes de Luz ao longo da Estrada Real
	for py in [4, 12, 20, 28, 36]:
		est_decor.set_cell(Vector2i(20, py), 4, Vector2i(2, 6))
		est_decor.set_cell(Vector2i(29, py), 4, Vector2i(2, 6))

	# Bosques densos nas bordas Leste e Oeste
	for ty in range(0, 40, 3):
		# Floresta Oeste
		for tx in [1, 5, 8]:
			est_decor.set_cell(Vector2i(tx, ty), 5, Vector2i(1, 1))
			est_decor.set_cell(Vector2i(tx + 1, ty), 5, Vector2i(2, 1))
			est_decor.set_cell(Vector2i(tx, ty + 1), 5, Vector2i(1, 2))
			est_decor.set_cell(Vector2i(tx + 1, ty + 1), 5, Vector2i(2, 2))
		# Floresta Leste
		for tx in [32, 36, 42, 46]:
			est_decor.set_cell(Vector2i(tx, ty), 5, Vector2i(1, 1))
			est_decor.set_cell(Vector2i(tx + 1, ty), 5, Vector2i(2, 1))
			est_decor.set_cell(Vector2i(tx, ty + 1), 5, Vector2i(1, 2))
			est_decor.set_cell(Vector2i(tx + 1, ty + 1), 5, Vector2i(2, 2))

	# Spawn Points
	var sp_lobby := Marker2D.new()
	sp_lobby.set_script(load("res://entities/world/SpawnPoint.gd"))
	sp_lobby.name = "SpawnFromLobby"
	sp_lobby.set("spawn_id", &"from_lobby")
	sp_lobby.set("is_default_spawn", true)
	sp_lobby.position = Vector2(400, 70)
	estrada.add_child(sp_lobby)
	sp_lobby.owner = estrada

	var sp_floresta := Marker2D.new()
	sp_floresta.set_script(load("res://entities/world/SpawnPoint.gd"))
	sp_floresta.name = "SpawnFromFloresta"
	sp_floresta.set("spawn_id", &"from_floresta")
	sp_floresta.set("is_default_spawn", false)
	sp_floresta.position = Vector2(400, 560)
	estrada.add_child(sp_floresta)
	sp_floresta.owner = estrada

	# HUD
	if hud_scn:
		var hud = hud_scn.instantiate()
		estrada.add_child(hud)
		hud.owner = estrada

	# Player
	if player_scn:
		var pl = player_scn.instantiate()
		pl.position = Vector2(400, 70)
		var cam = Camera2D.new()
		cam.name = "Camera2D"
		cam.position_smoothing_enabled = true
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 800
		cam.limit_bottom = 640
		pl.add_child(cam)
		cam.owner = pl
		estrada.add_child(pl)
		pl.owner = estrada

	var p_estrada = PackedScene.new()
	var err_pack1 = p_estrada.pack(estrada)
	if err_pack1 == OK:
		var err_save1 = ResourceSaver.save(p_estrada, "res://world/maps/estrada_padokia.tscn")
		print("[SUCCESS] estrada_padokia.tscn salva com sucesso! (code: %d)" % err_save1)
	else:
		print("[-] Erro ao empacotar estrada_padokia: ", err_pack1)
	estrada.free()

	# ============================================================
	# 2. CONSTRUÇÃO DE FLORESTA DOS VESTÍGIOS (floresta_vestigios.tscn)
	# ============================================================
	print("[*] Gerando Floresta dos Vestígios...")
	var floresta = Node2D.new()
	floresta.name = "FlorestaVestigiosMap"
	floresta.set_script(floresta_script)

	var flo_chao = TileMapLayer.new()
	flo_chao.name = "Chao_TileMapLayer"
	flo_chao.tile_set = tileset
	flo_chao.z_index = -12
	floresta.add_child(flo_chao)
	flo_chao.owner = floresta

	var flo_caminhos = TileMapLayer.new()
	flo_caminhos.name = "Caminhos_TileMapLayer"
	flo_caminhos.tile_set = tileset
	flo_caminhos.z_index = -10
	floresta.add_child(flo_caminhos)
	flo_caminhos.owner = floresta

	var flo_estruturas = TileMapLayer.new()
	flo_estruturas.name = "Estruturas_TileMapLayer"
	flo_estruturas.tile_set = tileset
	flo_estruturas.z_index = 0
	floresta.add_child(flo_estruturas)
	flo_estruturas.owner = floresta

	var flo_decor = TileMapLayer.new()
	flo_decor.name = "Decor_TileMapLayer"
	flo_decor.tile_set = tileset
	flo_decor.z_index = 2
	floresta.add_child(flo_decor)
	flo_decor.owner = floresta

	# Preencher terreno base de grama de floresta
	for ty in range(0, 40):
		for tx in range(0, 50):
			var gx = 1 + (abs(tx * 7 + ty * 13) % 3)
			var gy = 1 + (abs(tx * 11 + ty * 3) % 3)
			flo_chao.set_cell(Vector2i(tx, ty), 0, Vector2i(gx, gy))

	# Trilha da Floresta sinuosa conectando Norte a Sul
	for ty in range(0, 40):
		var offset = int(sin(float(ty) / 4.0) * 4.0)
		for tx in range(22 + offset, 27 + offset):
			flo_caminhos.set_cell(Vector2i(tx, ty), 1, Vector2i(1, 1))

	# Trilha Leste para a Barreira KO e Santuario Antigo
	for tx in range(28, 42):
		for ty in range(15, 18):
			flo_caminhos.set_cell(Vector2i(tx, ty), 1, Vector2i(1, 1))

	# Pilares Antigos e Ruínas de Zaban ao Sul (tx: 18..32, ty: 32..38)
	for cy in range(6):
		for cx in range(8):
			flo_estruturas.set_cell(Vector2i(14 + cx, 30 + cy), 13, Vector2i(cx, cy))
			flo_estruturas.set_cell(Vector2i(28 + cx, 30 + cy), 13, Vector2i(cx, cy))

	# Bordas Densas de Floresta Antiga (Árvores gigantes)
	for ty in range(0, 40, 2):
		for tx in [0, 3, 6, 9, 40, 43, 46]:
			flo_decor.set_cell(Vector2i(tx, ty), 5, Vector2i(1, 1))
			flo_decor.set_cell(Vector2i(tx + 1, ty), 5, Vector2i(2, 1))
			flo_decor.set_cell(Vector2i(tx, ty + 1), 5, Vector2i(1, 2))
			flo_decor.set_cell(Vector2i(tx + 1, ty + 1), 5, Vector2i(2, 2))

	# Arbustos e pedras místicas espalhadas
	for px in [15, 20, 30, 35]:
		for py in [8, 18, 25]:
			flo_decor.set_cell(Vector2i(px, py), 4, Vector2i(6, 4))

	# Spawn Points
	var sp_estrada := Marker2D.new()
	sp_estrada.set_script(load("res://entities/world/SpawnPoint.gd"))
	sp_estrada.name = "SpawnFromEstrada"
	sp_estrada.set("spawn_id", &"from_estrada")
	sp_estrada.set("is_default_spawn", true)
	sp_estrada.position = Vector2(400, 70)
	floresta.add_child(sp_estrada)
	sp_estrada.owner = floresta

	var sp_dungeon := Marker2D.new()
	sp_dungeon.set_script(load("res://entities/world/SpawnPoint.gd"))
	sp_dungeon.name = "SpawnFromDungeon"
	sp_dungeon.set("spawn_id", &"from_dungeon")
	sp_dungeon.set("is_default_spawn", false)
	sp_dungeon.position = Vector2(400, 560)
	floresta.add_child(sp_dungeon)
	sp_dungeon.owner = floresta

	# HUD
	if hud_scn:
		var hud = hud_scn.instantiate()
		floresta.add_child(hud)
		hud.owner = floresta

	# Player
	if player_scn:
		var pl = player_scn.instantiate()
		pl.position = Vector2(400, 70)
		var cam = Camera2D.new()
		cam.name = "Camera2D"
		cam.position_smoothing_enabled = true
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 800
		cam.limit_bottom = 640
		pl.add_child(cam)
		cam.owner = pl
		floresta.add_child(pl)
		pl.owner = floresta

	var p_floresta = PackedScene.new()
	var err_pack2 = p_floresta.pack(floresta)
	if err_pack2 == OK:
		var err_save2 = ResourceSaver.save(p_floresta, "res://world/maps/floresta_vestigios.tscn")
		print("[SUCCESS] floresta_vestigios.tscn salva com sucesso! (code: %d)" % err_save2)
	else:
		print("[-] Erro ao empacotar floresta_vestigios: ", err_pack2)
	floresta.free()

	print("[*] Conclusao da construcao dos Mapas Conectados!")
	quit()
