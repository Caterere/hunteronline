@tool
extends SceneTree

func _init() -> void:
	print("====================================================")
	print("[*] Integrando Tileset PixelLab no lobby_tileset.tres...")
	print("====================================================")

	var dir_path = "res://assets/sprites/tilesets/pixellab/tiles"
	var dir = DirAccess.open(dir_path)
	if dir == null:
		print("[-] Pasta de tiles do PixelLab não encontrada ainda: ", dir_path)
		quit()
		return

	var tile_files: Array[String] = []
	dir.list_dir_begin()
	var f_name = dir.get_next()
	while f_name != "":
		if not dir.current_is_dir() and f_name.ends_with(".png"):
			tile_files.append(f_name)
		f_name = dir.get_next()
	dir.list_dir_end()
	tile_files.sort()

	if tile_files.is_empty():
		print("[-] Nenhum tile PNG encontrado em: ", dir_path)
		quit()
		return

	print("[+] Encontrados %d tiles gerados pelo PixelLab." % tile_files.size())

	# Montar um atlas 4x4 de 16x16 pixels (total 64x64)
	var sheet_img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	sheet_img.fill(Color(0, 0, 0, 0))

	for idx in range(min(16, tile_files.size())):
		var tile_path = dir_path + "/" + tile_files[idx]
		var t_img = Image.load_from_file(ProjectSettings.globalize_path(tile_path))
		if t_img != null:
			var grid_x = (idx % 4) * 16
			var grid_y = int(idx / 4) * 16
			sheet_img.blit_rect(t_img, Rect2i(0, 0, 16, 16), Vector2i(grid_x, grid_y))

	var out_sheet_path = "res://assets/sprites/tilesets/pixellab/pixellab_lobby_sheet.png"
	var err_save = sheet_img.save_png(ProjectSettings.globalize_path(out_sheet_path))
	if err_save == OK:
		print("[SUCCESS] Atlas 64x64 salvo com sucesso em: ", out_sheet_path)
	else:
		print("[-] Erro ao salvar atlas: ", err_save)

	# Atualizar o lobby_tileset.tres adicionando o novo atlas PixelLab
	var tileset = load("res://world/tilesets/lobby_tileset.tres") as TileSet
	if tileset != null:
		var tex = load(out_sheet_path) as Texture2D
		if tex == null:
			# Forçar recarregamento como ImageTexture
			var itex = ImageTexture.create_from_image(sheet_img)
			tex = itex

		var source := TileSetAtlasSource.new()
		source.texture = tex
		source.texture_region_size = Vector2i(16, 16)
		for y in range(4):
			for x in range(4):
				source.create_tile(Vector2i(x, y))

		tileset.add_source(source, 20) # Source ID 20 = PixelLab MMO Grass/Plaza
		var err_ts = ResourceSaver.save(tileset, "res://world/tilesets/lobby_tileset.tres")
		if err_ts == OK:
			print("[SUCCESS] Source ID 20 (PixelLab) adicionado ao lobby_tileset.tres!")
		else:
			print("[-] Erro ao atualizar lobby_tileset.tres: ", err_ts)

	print("====================================================")
	print("[+] Concluído com sucesso!")
	print("====================================================")
	quit()
