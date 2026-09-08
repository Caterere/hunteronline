extends SceneTree

# ==============================================================================
# HUNTER ONLINE — GERADOR CANÔNICO DE SPRITES DE NPCS (48x48 STYLE LOCK)
# ==============================================================================

const FW = 48
const FH = 48
const TARGET_FEET_Y = 42

var player_img: Image

func get_player_idle_frame(dir_index: int) -> Image:
	var row = 0
	var flip_h = false
	match dir_index:
		0: row = 0 # South
		1: row = 0 # South-East
		2: row = 1 # East
		3: row = 2 # North-East
		4: row = 2 # North
		5: row = 2; flip_h = true # North-West
		6: row = 1; flip_h = true # West
		7: row = 0; flip_h = true # South-West

	var f = player_img.get_region(Rect2i(0, row * FH, FW, FH))
	if flip_h:
		f.flip_x()
	return f

func recolor_and_stylize(base_frame: Image, char_id: String, dir_index: int) -> Image:
	var out = Image.create(FW, FH, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))

	# Copia base do player
	for y in range(FH):
		for x in range(FW):
			out.set_pixel(x, y, base_frame.get_pixel(x, y))

	match char_id:
		"npc_discipulo_zushi":
			# ZUSHI: Cabelo preto espetado curto, Karate Gi branco, Faixa preta, Pés descalços
			var hair_col = Color("141418")
			var gi_base = Color("f4f5f8")
			var gi_shadow = Color("bfc3cf")
			var skin_light = Color("f2cb9e")
			var skin_shadow = Color("cf9e76")
			var dark_out = Color("000000")

			for y in range(FH):
				for x in range(FW):
					var p = out.get_pixel(x, y)
					if p.a < 0.1: continue
					var hex = p.to_html(false)
					if hex in ["573a23", "402717", "21110d"] and y < 30:
						out.set_pixel(x, y, hair_col)
					elif hex in ["c1ac8f"]:
						out.set_pixel(x, y, skin_light)
					elif hex in ["ac7b5d", "9a5c42"]:
						out.set_pixel(x, y, skin_shadow)
					elif hex in ["a4a8b5"]:
						out.set_pixel(x, y, gi_base)
					elif hex in ["787e97"]:
						out.set_pixel(x, y, gi_shadow)
					elif y == 37 and hex in ["2c65b5", "1d438a", "0d205e"]:
						out.set_pixel(x, y, dark_out)
					elif hex in ["2c65b5"]:
						out.set_pixel(x, y, gi_base)
					elif hex in ["1d438a", "0d205e"]:
						out.set_pixel(x, y, gi_shadow)

			if dir_index in [0, 1, 7]:
				out.set_pixel(24, 38, dark_out)

		"npc_instrutor_combate":
			# WING: Cabelo escuro, kimono verde escuro sobre camiseta branca, calça cáqui
			var hair_col = Color("1a1c22")
			var kimono_base = Color("284434")
			var kimono_shadow = Color("182c22")
			var pants_base = Color("cfbe9e")
			var pants_shadow = Color("a49474")
			var skin_light = Color("eac29a")
			var skin_shadow = Color("c49872")

			for y in range(FH):
				for x in range(FW):
					var p = out.get_pixel(x, y)
					if p.a < 0.1: continue
					var hex = p.to_html(false)
					if hex in ["573a23", "402717", "21110d"] and y < 30:
						out.set_pixel(x, y, hair_col)
					elif hex in ["c1ac8f"]:
						out.set_pixel(x, y, skin_light)
					elif hex in ["ac7b5d", "9a5c42"]:
						out.set_pixel(x, y, skin_shadow)
					elif hex in ["a4a8b5"] and x in [23, 24] and dir_index == 0:
						out.set_pixel(x, y, Color("f0f2f6")) # camiseta branca interna
					elif hex in ["a4a8b5"]:
						out.set_pixel(x, y, kimono_base)
					elif hex in ["787e97"]:
						out.set_pixel(x, y, kimono_shadow)
					elif hex in ["2c65b5"]:
						out.set_pixel(x, y, pants_base)
					elif hex in ["1d438a", "0d205e"]:
						out.set_pixel(x, y, pants_shadow)

			if dir_index == 0:
				out.set_pixel(23, 30, Color("000000")) # ponte dos óculos

		"npc_examinador_oficial":
			# SATOTZ: Cartola escura, terno lilás/lavanda, cravat branco, bengala
			var hat_col = Color("22202a")
			var suit_base = Color("7c6294")
			var suit_shadow = Color("4e3c62")
			var cravat_col = Color("f2eef8")
			var skin_light = Color("f0d6bc")
			var skin_shadow = Color("ccaa8c")
			var cane_gold = Color("d0a640")

			# Cartola
			for x in range(20, 29):
				out.set_pixel(x, 21, hat_col)
				out.set_pixel(x, 22, hat_col)
			for x in range(18, 31):
				out.set_pixel(x, 23, Color("14121a"))

			for y in range(24, FH):
				for x in range(FW):
					var p = out.get_pixel(x, y)
					if p.a < 0.1: continue
					var hex = p.to_html(false)
					if hex in ["573a23", "402717", "21110d"] and y < 30:
						out.set_pixel(x, y, Color("14121a"))
					elif hex in ["c1ac8f"]:
						out.set_pixel(x, y, skin_light)
					elif hex in ["ac7b5d", "9a5c42"]:
						out.set_pixel(x, y, skin_shadow)
					elif hex in ["a4a8b5"] and x in [23, 24] and dir_index == 0:
						out.set_pixel(x, y, cravat_col)
					elif hex in ["a4a8b5"]:
						out.set_pixel(x, y, suit_base)
					elif hex in ["787e97"]:
						out.set_pixel(x, y, suit_shadow)
					elif hex in ["2c65b5"]:
						out.set_pixel(x, y, suit_base)
					elif hex in ["1d438a", "0d205e"]:
						out.set_pixel(x, y, suit_shadow)

			if dir_index in [0, 1, 2]:
				out.set_pixel(29, 36, cane_gold)
				for cy in range(37, 43):
					out.set_pixel(29, cy, Color("14121a"))

		"npc_ferreiro_mestre":
			# FERREIRO: Cabelo castanho escuro, avental couro sobre cinza, martelo junto à mão
			var hair_col = Color("3e2818")
			var apron_base = Color("7c4824")
			var apron_shadow = Color("4e2a12")
			var tunic_gray = Color("707482")
			var skin_light = Color("d6a074")
			var skin_shadow = Color("ac744c")

			for y in range(FH):
				for x in range(FW):
					var p = out.get_pixel(x, y)
					if p.a < 0.1: continue
					var hex = p.to_html(false)
					if hex in ["573a23", "402717", "21110d"] and y < 30:
						out.set_pixel(x, y, hair_col)
					elif hex in ["c1ac8f"]:
						out.set_pixel(x, y, skin_light)
					elif hex in ["ac7b5d", "9a5c42"]:
						out.set_pixel(x, y, skin_shadow)
					elif hex in ["a4a8b5"]:
						out.set_pixel(x, y, apron_base if x in [22, 23, 24, 25] else tunic_gray)
					elif hex in ["787e97"]:
						out.set_pixel(x, y, apron_shadow)
					elif hex in ["2c65b5"]:
						out.set_pixel(x, y, apron_base if y <= 38 else Color("2a2c34"))
					elif hex in ["1d438a", "0d205e"]:
						out.set_pixel(x, y, apron_shadow if y <= 38 else Color("1c1e24"))

			if dir_index == 0:
				out.set_pixel(18, 37, tunic_gray)
				out.set_pixel(18, 38, apron_shadow)

		"npc_vendedor_mercador":
			# MERCADOR: Boina verde com pena vermelha, túnica verde, calça marrom
			var green_base = Color("3c7e42")
			var green_shadow = Color("24522a")
			var brown_strap = Color("7a4c24")
			var pants_col = Color("583c24")
			var skin_light = Color("e6b486")
			var skin_shadow = Color("bc865c")

			for y in range(FH):
				for x in range(FW):
					var p = out.get_pixel(x, y)
					if p.a < 0.1: continue
					var hex = p.to_html(false)
					if hex in ["573a23", "402717"] and y < 26:
						out.set_pixel(x, y, green_base)
					elif hex in ["573a23", "402717", "21110d"]:
						out.set_pixel(x, y, Color("482e18"))
					elif hex in ["c1ac8f"]:
						out.set_pixel(x, y, skin_light)
					elif hex in ["ac7b5d", "9a5c42"]:
						out.set_pixel(x, y, skin_shadow)
					elif hex in ["a4a8b5"]:
						out.set_pixel(x, y, brown_strap if (x + y) % 5 == 0 else green_base)
					elif hex in ["787e97"]:
						out.set_pixel(x, y, green_shadow)
					elif hex in ["2c65b5"]:
						out.set_pixel(x, y, pants_col)
					elif hex in ["1d438a", "0d205e"]:
						out.set_pixel(x, y, Color("3a2414"))

			out.set_pixel(26, 21, Color("d4342c"))

		"npc_guarda_fronteira":
			# GUARDA: Elmo de aço, tabardo azul com brasão branco, lança
			var steel_base = Color("98a4b6")
			var steel_shadow = Color("5c6676")
			var tabard_base = Color("2452a4")
			var tabard_shadow = Color("163468")
			var crest_white = Color("e8eef8")

			for y in range(22, 29):
				for x in range(18, 31):
					var p = out.get_pixel(x, y)
					if p.a > 0.1:
						out.set_pixel(x, y, steel_base if y < 27 else steel_shadow)

			if dir_index == 0:
				for x in range(21, 28):
					out.set_pixel(x, 30, Color("141820"))

			for y in range(29, FH):
				for x in range(FW):
					var p = out.get_pixel(x, y)
					if p.a < 0.1: continue
					var hex = p.to_html(false)
					if hex in ["a4a8b5"]:
						out.set_pixel(x, y, crest_white if (x in [23, 24] and dir_index == 0) else tabard_base)
					elif hex in ["787e97"]:
						out.set_pixel(x, y, tabard_shadow)
					elif hex in ["2c65b5"]:
						out.set_pixel(x, y, tabard_base)
					elif hex in ["1d438a", "0d205e"]:
						out.set_pixel(x, y, tabard_shadow)

			if dir_index in [0, 1, 2]:
				out.set_pixel(30, 18, crest_white)
				for sy in range(19, 43):
					out.set_pixel(30, sy, Color("3e2616"))

		"npc_recepcionista_elena":
			# ELENA: Cabelo castanho escuro, colete navy, camisa branca, saia navy
			var hair_col = Color("341e12")
			var vest_base = Color("1a2a56")
			var vest_shadow = Color("101a34")
			var shirt_white = Color("ffffff")
			var skin_light = Color("f6d4b6")
			var skin_shadow = Color("cda686")

			for y in range(FH):
				for x in range(FW):
					var p = out.get_pixel(x, y)
					if p.a < 0.1: continue
					var hex = p.to_html(false)
					if hex in ["573a23", "402717", "21110d"] and y < 30:
						out.set_pixel(x, y, hair_col)
					elif hex in ["c1ac8f"]:
						out.set_pixel(x, y, skin_light)
					elif hex in ["ac7b5d", "9a5c42"]:
						out.set_pixel(x, y, skin_shadow)
					elif hex in ["a4a8b5"] and x in [23, 24] and dir_index == 0:
						out.set_pixel(x, y, shirt_white)
					elif hex in ["a4a8b5"]:
						out.set_pixel(x, y, vest_base)
					elif hex in ["787e97"]:
						out.set_pixel(x, y, vest_shadow)
					elif hex in ["2c65b5"]:
						out.set_pixel(x, y, vest_base)
					elif hex in ["1d438a", "0d205e"]:
						out.set_pixel(x, y, vest_shadow)

			if dir_index == 0:
				out.set_pixel(22, 35, Color("d4aa32"))

		"npc_viajante_scout":
			# SCOUT: Bandana floresta, casaco duster marrom, calça militar
			var bandana_base = Color("44603e")
			var bandana_shadow = Color("2c3e28")
			var coat_base = Color("8a5e36")
			var coat_shadow = Color("56381e")
			var pants_field = Color("3e4a34")
			var pants_shadow = Color("263020")
			var skin_light = Color("d89e74")
			var skin_shadow = Color("ae744c")

			for y in range(FH):
				for x in range(FW):
					var p = out.get_pixel(x, y)
					if p.a < 0.1: continue
					var hex = p.to_html(false)
					if y in [24, 25, 26] and hex in ["573a23", "402717"]:
						out.set_pixel(x, y, bandana_base if y == 25 else bandana_shadow)
					elif hex in ["573a23", "402717", "21110d"] and y < 30:
						out.set_pixel(x, y, Color("342010"))
					elif hex in ["c1ac8f"]:
						out.set_pixel(x, y, skin_light)
					elif hex in ["ac7b5d", "9a5c42"]:
						out.set_pixel(x, y, skin_shadow)
					elif hex in ["a4a8b5"]:
						out.set_pixel(x, y, coat_base)
					elif hex in ["787e97"]:
						out.set_pixel(x, y, coat_shadow)
					elif hex in ["2c65b5"]:
						out.set_pixel(x, y, pants_field)
					elif hex in ["1d438a", "0d205e"]:
						out.set_pixel(x, y, pants_shadow)

	return out

func _init():
	var p_path = ProjectSettings.globalize_path("res://assets/sprites/characters/player.png")
	player_img = Image.load_from_file(p_path)

	var npcs = [
		"npc_discipulo_zushi",
		"npc_instrutor_combate",
		"npc_examinador_oficial",
		"npc_ferreiro_mestre",
		"npc_vendedor_mercador",
		"npc_guarda_fronteira",
		"npc_recepcionista_elena",
		"npc_viajante_scout"
	]

	var dirs = [
		"south", "south-east", "east", "north-east",
		"north", "north-west", "west", "south-west"
	]

	var base_dir = ProjectSettings.globalize_path("res://assets/sprites/characters/")

	for npc_id in npcs:
		var sheet_8dir = Image.create(FW * 8, FH, false, Image.FORMAT_RGBA8)
		sheet_8dir.fill(Color(0, 0, 0, 0))
		var rot_dir = base_dir.path_join(npc_id + "_rotations")

		for d in range(8):
			var player_base_frame = get_player_idle_frame(d)
			var stylized = recolor_and_stylize(player_base_frame, npc_id, d)
			sheet_8dir.blit_rect(stylized, Rect2i(0, 0, FW, FH), Vector2i(d * FW, 0))
			stylized.save_png(rot_dir.path_join(dirs[d] + ".png"))
			if d == 0:
				stylized.save_png(base_dir.path_join(npc_id + ".png"))

		sheet_8dir.save_png(base_dir.path_join(npc_id + "_8dir.png"))
		print("    ✓ Salvo: %s_8dir.png" % npc_id)

	quit(0)
