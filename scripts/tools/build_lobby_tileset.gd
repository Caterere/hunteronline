@tool
extends SceneTree

func _init() -> void:
	print("[*] Iniciando geração do lobby_tileset.tres com colisões aprimoradas...")
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1) # Layer 1 (Cenário / Paredes)

	var textures_info = [
		{"id": 0, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Tileset Grass.png", "cols": 16, "rows": 16, "solid": false},
		{"id": 1, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Tileset Stone Ground.png", "cols": 16, "rows": 16, "solid": false},
		{"id": 2, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Tileset Wall.png", "cols": 32, "rows": 32, "solid": true},
		{"id": 3, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Struct.png", "cols": 32, "rows": 32, "solid": false},
		{"id": 4, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Props.png", "cols": 32, "rows": 32, "solid": false},
		{"id": 5, "path": "res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Plant.png", "cols": 32, "rows": 32, "solid": false},
	]

	var poly_full = PackedVector2Array([
		Vector2(-8, -8),
		Vector2(8, -8),
		Vector2(8, 8),
		Vector2(-8, 8)
	])

	for info in textures_info:
		var tex = load(info["path"]) as Texture2D
		if tex == null:
			print("[-] Falha ao carregar textura: ", info["path"])
			continue

		var source := TileSetAtlasSource.new()
		source.texture = tex
		source.texture_region_size = Vector2i(16, 16)

		for y in range(info["rows"]):
			for x in range(info["cols"]):
				source.create_tile(Vector2i(x, y))

		tileset.add_source(source, info["id"])

		if info["solid"]:
			for y in range(info["rows"]):
				for x in range(info["cols"]):
					var coords := Vector2i(x, y)
					var tile_data = source.get_tile_data(coords, 0)
					if tile_data != null and tile_data.get_collision_polygons_count(0) == 0:
						tile_data.add_collision_polygon(0)
						tile_data.set_collision_polygon_points(0, 0, poly_full)

		print("[+] Fonte adicionada ao TileSet: ", info["path"], " (ID: ", info["id"], ")")

	# Configurar colisão de footprint em Props (Postes e Bancos) no Source 4
	var src_props: TileSetAtlasSource = tileset.get_source(4) as TileSetAtlasSource
	if src_props != null:
		# Poste de luz (2, 6) - base nos pés do poste
		var td_poste = src_props.get_tile_data(Vector2i(2, 6), 0)
		if td_poste != null:
			var poly_lamp = PackedVector2Array([Vector2(-3, 3), Vector2(3, 3), Vector2(3, 8), Vector2(-3, 8)])
			td_poste.add_collision_polygon(0)
			td_poste.set_collision_polygon_points(0, 0, poly_lamp)

		# Banco de pedra (4, 2)
		var td_banco = src_props.get_tile_data(Vector2i(4, 2), 0)
		if td_banco != null:
			var poly_bench = PackedVector2Array([Vector2(-7, 2), Vector2(7, 2), Vector2(7, 8), Vector2(-7, 8)])
			td_banco.add_collision_polygon(0)
			td_banco.set_collision_polygon_points(0, 0, poly_bench)

	# Configurar colisão de tronco no Source 5 (Árvores)
	var src_plant: TileSetAtlasSource = tileset.get_source(5) as TileSetAtlasSource
	if src_plant != null:
		# Tronco de árvore na base (1, 2) e (2, 2)
		var poly_trunk = PackedVector2Array([Vector2(-5, 0), Vector2(5, 0), Vector2(5, 8), Vector2(-5, 8)])
		for coord in [Vector2i(1, 2), Vector2i(2, 2)]:
			var td_trunk = src_plant.get_tile_data(coord, 0)
			if td_trunk != null:
				td_trunk.add_collision_polygon(0)
				td_trunk.set_collision_polygon_points(0, 0, poly_trunk)

	# Polígono de Footprint para Alicerces de Construções (altura 10px na base inferior)
	var poly_footprint = PackedVector2Array([
		Vector2(-8, -2),
		Vector2(8, -2),
		Vector2(8, 8),
		Vector2(-8, 8)
	])

	# Edificações: especificação rigorosa da linha de contato real com o solo
	var construcoes_info = [
		{"id": 10, "path": "res://assets/sprites/tilesets/construcoes/monasterio.png", "cols": 12, "rows": 20, "base_row": 18},
		{"id": 11, "path": "res://assets/sprites/tilesets/construcoes/castelo.png", "cols": 20, "rows": 16, "base_row": 14},
		{"id": 12, "path": "res://assets/sprites/tilesets/construcoes/quartel.png", "cols": 12, "rows": 16, "base_row": 14},
		{"id": 13, "path": "res://assets/sprites/tilesets/construcoes/arquearia.png", "cols": 12, "rows": 16, "base_row": 14},
		{"id": 14, "path": "res://assets/sprites/tilesets/construcoes/torre.png", "cols": 8, "rows": 16, "base_row": 13},
		{"id": 15, "path": "res://assets/sprites/tilesets/construcoes/casa_1.png", "cols": 8, "rows": 12, "base_row": 10},
		{"id": 16, "path": "res://assets/sprites/tilesets/construcoes/casa_2.png", "cols": 8, "rows": 12, "base_row": 10},
		{"id": 17, "path": "res://assets/sprites/tilesets/construcoes/casa_3.png", "cols": 8, "rows": 12, "base_row": 10},
	]

	for c in construcoes_info:
		if ResourceLoader.exists(c["path"]):
			var tex = load(c["path"]) as Texture2D
			if tex != null:
				var source := TileSetAtlasSource.new()
				source.texture = tex
				source.texture_region_size = Vector2i(16, 16)
				for y in range(c["rows"]):
					for x in range(c["cols"]):
						source.create_tile(Vector2i(x, y))

				tileset.add_source(source, c["id"])

				# Adiciona colisão física APENAS na linha de alicerce real onde a estrutura encontra o chão
				var brow: int = c["base_row"]
				for x in range(c["cols"]):
					var coords := Vector2i(x, brow)
					var tile_data = source.get_tile_data(coords, 0)
					if tile_data != null and tile_data.get_collision_polygons_count(0) == 0:
						tile_data.add_collision_polygon(0)
						tile_data.set_collision_polygon_points(0, 0, poly_footprint)

				print("[+] Construção configurada com footprint em Y=%d: %s (ID: %d)" % [brow, c["path"].get_file(), c["id"]])

	# Source 20: Atlas PixelLab (Wang tileset de transição grama/praça)
	var pixellab_sheet = "res://assets/sprites/tilesets/pixellab/pixellab_lobby_sheet.png"
	if ResourceLoader.exists(pixellab_sheet):
		var pl_tex = load(pixellab_sheet) as Texture2D
		if pl_tex != null:
			var pl_src := TileSetAtlasSource.new()
			pl_src.texture = pl_tex
			pl_src.texture_region_size = Vector2i(16, 16)
			for py in range(4):
				for px in range(4):
					pl_src.create_tile(Vector2i(px, py))
			tileset.add_source(pl_src, 20)
			print("[+] Source 20 (PixelLab) integrado com sucesso!")

	var err = ResourceSaver.save(tileset, "res://world/tilesets/lobby_tileset.tres")
	if err == OK:
		print("[SUCCESS] lobby_tileset.tres gerado com colisões de footprint precisas!")
	else:
		print("[-] Erro ao salvar lobby_tileset.tres: ", err)

	quit()
