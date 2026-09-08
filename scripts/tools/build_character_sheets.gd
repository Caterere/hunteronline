@tool
extends SceneTree

func _init() -> void:
	print("====================================================")
	print("[*] Montando Spritesheets de 8 Direções para NPCs...")
	print("====================================================")

	var characters = [
		"npc_recepcionista_elena",
		"npc_instrutor_combate",
		"npc_examinador_oficial",
		"npc_ferreiro_mestre",
		"npc_vendedor_mercador",
		"npc_discipulo_zushi",
		"npc_guarda_fronteira",
		"npc_viajante_scout"
	]

	var dirs = [
		"south",
		"south-east",
		"east",
		"north-east",
		"north",
		"north-west",
		"west",
		"south-west"
	]

	for char_name in characters:
		var rot_path = "res://assets/sprites/characters/" + char_name + "_rotations/"
		# Verificar primeiro frame para pegar dimensões
		var first_img_path = rot_path + "south.png"
		var first_img = Image.load_from_file(ProjectSettings.globalize_path(first_img_path))
		if first_img == null:
			print("[-] Erro ao carregar: ", first_img_path)
			continue

		var frame_w = first_img.get_width()
		var frame_h = first_img.get_height()
		print("[+] %s: dimensões de frame = %dx%d" % [char_name, frame_w, frame_h])

		# Criar folha com 8 colunas e 1 linha
		var sheet = Image.create(frame_w * 8, frame_h, false, Image.FORMAT_RGBA8)
		sheet.fill(Color(0, 0, 0, 0))

		for i in range(dirs.size()):
			var dir_name = dirs[i]
			var fpath = rot_path + dir_name + ".png"
			var img = Image.load_from_file(ProjectSettings.globalize_path(fpath))
			if img != null:
				sheet.blit_rect(img, Rect2i(0, 0, frame_w, frame_h), Vector2i(i * frame_w, 0))
			else:
				print("[-] Aviso: direção ausente: ", fpath)

		var out_path = "res://assets/sprites/characters/" + char_name + "_8dir.png"
		var err = sheet.save_png(ProjectSettings.globalize_path(out_path))
		if err == OK:
			print("[SUCCESS] Folha 8-direções salva em: %s (%dx%d)" % [out_path, sheet.get_width(), sheet.get_height()])
		else:
			print("[-] Erro ao salvar: ", err)

	print("====================================================")
	print("[+] Concluído com sucesso!")
	print("====================================================")
	quit()
