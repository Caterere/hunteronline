extends SceneTree

# ==============================================================================
# HUNTER ONLINE — GERADOR DEFINITIVO DE SPRITES DE PERSONAGENS & INIMIGOS
# Conforme a Bible 16 (PIXEL_ART_STYLE_BIBLE.md) & World Production Bible
# Canvas 48x48 px, Pés em Y=42, Chibi 2.5 cabeças, Silhuetas autênticas do anime.
# ==============================================================================

const FW = 48
const FH = 48
const FEET_Y = 42

const SHADOW_COLOR = Color(0.047, 0.055, 0.098, 0.5)
const OUTLINE_BLACK = Color(0.0, 0.0, 0.0, 1.0)
const EYE_BLACK = Color(0.129, 0.067, 0.051, 1.0)

# Paleta Mestra Padrão
const SKIN_LIGHT = Color("f2cb9e")
const SKIN_SHADOW = Color("cf9e76")
const SKIN_PALE = Color("f5e8dc")
const SKIN_PALE_SHADOW = Color("d9c4b0")
const SKIN_DARK = Color("a66d48")
const SKIN_DARK_SHADOW = Color("7a4c2a")

func _init() -> void:
	print("==================================================================")
	print(" GERADOR DE SPRITES CANÔNICOS DE ANIME (HUNTER ONLINE)")
	print("==================================================================")

	var base_dir = ProjectSettings.globalize_path("res://assets/sprites/characters/")
	var dir_tool = DirAccess.open("res://assets/sprites/characters/")
	if dir_tool == null:
		DirAccess.make_dir_absolute(base_dir)

	var all_characters = [
		# --- NPCS PRINCIPAIS DO ANIME ---
		"npc_gon",
		"npc_killua",
		"npc_kurapika",
		"npc_leorio",
		"npc_hisoka",
		"npc_chrollo",
		"npc_netero",
		"npc_biscuit",
		"npc_tonpa",
		"npc_ging",
		"npc_hanzo",
		"npc_pokkle",
		"npc_ponzu",
		"npc_buhara",
		"npc_menchi",
		"npc_gittarackur",
		"npc_bodoro",
		"npc_nicol",

		# --- INIMIGOS & BOSSES CANÔNICOS ---
		"enemy_candidato_exame",
		"enemy_criatura_pantanal",
		"enemy_mordomo_zoldyck",
		"enemy_lutador_arena",
		"enemy_mafioso_yorknew",
		"enemy_bomber_greed",
		"enemy_formiga_soldado",
		"enemy_formiga_lider",
		"enemy_guarda_real",
		"enemy_boss_razor",
		"enemy_boss_meruem"
	]

	var dirs = [
		"south", "south-east", "east", "north-east",
		"north", "north-west", "west", "south-west"
	]

	for char_id in all_characters:
		var rot_dir = base_dir.path_join(char_id + "_rotations")
		DirAccess.make_dir_absolute(rot_dir)

		var sheet_8dir = Image.create(FW * 8, FH, false, Image.FORMAT_RGBA8)
		sheet_8dir.fill(Color(0, 0, 0, 0))

		for d in range(8):
			var frame_img = generate_character_frame(char_id, d)
			sheet_8dir.blit_rect(frame_img, Rect2i(0, 0, FW, FH), Vector2i(d * FW, 0))
			frame_img.save_png(rot_dir.path_join(dirs[d] + ".png"))
			if d == 0:
				frame_img.save_png(base_dir.path_join(char_id + ".png"))

		sheet_8dir.save_png(base_dir.path_join(char_id + "_8dir.png"))
		print("  [OK] Gerado: %s_8dir.png (384x48) + rotações salvas" % char_id)

	print("==================================================================")
	print(" GERAÇÃO CONCLUÍDA COM SUCESSO!")
	print("==================================================================")
	quit(0)


# ==============================================================================
# DISPATCHER DE GERAÇÃO POR PERSONAGEM
# ==============================================================================
func generate_character_frame(char_id: String, dir_index: int) -> Image:
	var img = Image.create(FW, FH, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Mapeamento de direção:
	# 0: South, 1: South-East, 2: East, 3: North-East
	# 4: North, 5: North-West, 6: West, 7: South-West
	var is_back = dir_index in [3, 4, 5]
	var is_profile = dir_index in [1, 2, 6, 7]
	var flip = dir_index in [5, 6, 7]
	var angle_side = 1 if dir_index in [1, 2, 3] else (-1 if dir_index in [5, 6, 7] else 0)

	match char_id:
		"npc_gon":
			draw_gon(img, is_back, is_profile, angle_side)
		"npc_killua":
			draw_killua(img, is_back, is_profile, angle_side)
		"npc_kurapika":
			draw_kurapika(img, is_back, is_profile, angle_side)
		"npc_leorio":
			draw_leorio(img, is_back, is_profile, angle_side)
		"npc_hisoka":
			draw_hisoka(img, is_back, is_profile, angle_side)
		"npc_chrollo":
			draw_chrollo(img, is_back, is_profile, angle_side)
		"npc_netero":
			draw_netero(img, is_back, is_profile, angle_side)
		"npc_biscuit":
			draw_biscuit(img, is_back, is_profile, angle_side)
		"npc_tonpa":
			draw_tonpa(img, is_back, is_profile, angle_side)
		"npc_ging":
			draw_ging(img, is_back, is_profile, angle_side)
		"npc_hanzo":
			draw_hanzo(img, is_back, is_profile, angle_side)
		"npc_pokkle":
			draw_pokkle(img, is_back, is_profile, angle_side)
		"npc_ponzu":
			draw_ponzu(img, is_back, is_profile, angle_side)
		"npc_buhara":
			draw_buhara(img, is_back, is_profile, angle_side)
		"npc_menchi":
			draw_menchi(img, is_back, is_profile, angle_side)
		"npc_gittarackur":
			draw_gittarackur(img, is_back, is_profile, angle_side)
		"npc_bodoro":
			draw_bodoro(img, is_back, is_profile, angle_side)
		"npc_nicol":
			draw_nicol(img, is_back, is_profile, angle_side)

		# INIMIGOS
		"enemy_candidato_exame":
			draw_candidato_exame(img, is_back, is_profile, angle_side)
		"enemy_criatura_pantanal":
			draw_criatura_pantanal(img, is_back, is_profile, angle_side)
		"enemy_mordomo_zoldyck":
			draw_mordomo_zoldyck(img, is_back, is_profile, angle_side)
		"enemy_lutador_arena":
			draw_lutador_arena(img, is_back, is_profile, angle_side)
		"enemy_mafioso_yorknew":
			draw_mafioso_yorknew(img, is_back, is_profile, angle_side)
		"enemy_bomber_greed":
			draw_bomber_greed(img, is_back, is_profile, angle_side)
		"enemy_formiga_soldado":
			draw_formiga_soldado(img, is_back, is_profile, angle_side)
		"enemy_formiga_lider":
			draw_formiga_lider(img, is_back, is_profile, angle_side)
		"enemy_guarda_real":
			draw_guarda_real(img, is_back, is_profile, angle_side)
		"enemy_boss_razor":
			draw_boss_razor(img, is_back, is_profile, angle_side)
		"enemy_boss_meruem":
			draw_boss_meruem(img, is_back, is_profile, angle_side)

	if flip:
		img.flip_x()

	return img


# ==============================================================================
# FUNÇÕES DE DESENHO AUXILIARES (GEOMETRIA DE PIXELS)
# ==============================================================================
func set_p(img: Image, x: int, y: int, col: Color) -> void:
	if x >= 0 and x < FW and y >= 0 and y < FH:
		img.set_pixel(x, y, col)

func draw_shadow(img: Image, cx: int, w: int) -> void:
	var half = int(w / 2.0)
	for x in range(cx - half - 1, cx + half + 2):
		set_p(img, x, 42, SHADOW_COLOR)
	for x in range(cx - half, cx + half + 1):
		set_p(img, x, 41, SHADOW_COLOR)

func draw_rect_solid(img: Image, x1: int, y1: int, x2: int, y2: int, col: Color) -> void:
	for y in range(y1, y2 + 1):
		for x in range(x1, x2 + 1):
			set_p(img, x, y, col)

func draw_dot_eyes(img: Image, cx: int, y: int, angle_side: int) -> void:
	if angle_side == 0:
		set_p(img, cx - 2, y, EYE_BLACK)
		set_p(img, cx - 2, y + 1, EYE_BLACK)
		set_p(img, cx + 2, y, EYE_BLACK)
		set_p(img, cx + 2, y + 1, EYE_BLACK)
	elif angle_side > 0:
		set_p(img, cx, y, EYE_BLACK)
		set_p(img, cx, y + 1, EYE_BLACK)
		set_p(img, cx + 3, y, EYE_BLACK)
		set_p(img, cx + 3, y + 1, EYE_BLACK)


# ==============================================================================
# 1. GON FREECSS (Cabelo Alto Espetado, Jaqueta Verde, Shorts, Botas)
# ==============================================================================
func draw_gon(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var hair_dark = Color("141e14")
	var hair_green = Color("1e3d22")
	var coat_green = Color("2d7a36")
	var coat_shadow = Color("1b4e22")
	var trim_orange = Color("e65c00")
	var boots_brown = Color("5c3a21")

	# Pés e Botas (Y=39..42)
	draw_rect_solid(img, cx - 4, 39, cx - 2, 42, boots_brown)
	draw_rect_solid(img, cx + 2, 39, cx + 2 + 2, 42, boots_brown)
	set_p(img, cx - 4, 42, OUTLINE_BLACK)
	set_p(img, cx + 4, 42, OUTLINE_BLACK)

	# Pernas nuas (Y=37..38)
	draw_rect_solid(img, cx - 4, 37, cx - 2, 38, SKIN_LIGHT)
	draw_rect_solid(img, cx + 2, 37, cx + 4, 38, SKIN_LIGHT)

	# Shorts verde curto (Y=35..36)
	draw_rect_solid(img, cx - 4, 35, cx + 4, 36, coat_shadow)

	# Tronco / Jaqueta Verde (Y=30..34)
	draw_rect_solid(img, cx - 5, 30, cx + 5, 34, coat_green)
	for y in range(30, 35):
		set_p(img, cx - 5, y, coat_shadow)
		set_p(img, cx + 5, y, coat_shadow)

	if not is_back:
		# Gola e borda laranja frontal
		set_p(img, cx, 30, trim_orange)
		set_p(img, cx, 31, trim_orange)
		set_p(img, cx - 1, 30, trim_orange)
		set_p(img, cx + 1, 30, trim_orange)

	# Rosto (Y=26..29)
	if not is_back:
		draw_rect_solid(img, cx - 3, 26, cx + 3, 29, SKIN_LIGHT)
		draw_rect_solid(img, cx - 4, 27, cx - 4, 29, SKIN_SHADOW)
		draw_rect_solid(img, cx + 4, 27, cx + 4, 29, SKIN_SHADOW)
		draw_dot_eyes(img, cx, 27, angle_side)
	else:
		draw_rect_solid(img, cx - 4, 26, cx + 4, 29, hair_dark)

	# Cabelo Espetado Vertical e Alto do Gon (Y=20..25)
	for y in range(20, 26):
		var w = int((y - 19) * 0.9)
		for x in range(cx - w - 2, cx + w + 3):
			set_p(img, x, y, hair_dark)
			if (x + y) % 3 == 0:
				set_p(img, x, y, hair_green)
	# Pontas espetadas no topo
	set_p(img, cx, 20, hair_green)
	set_p(img, cx - 2, 21, hair_green)
	set_p(img, cx + 2, 21, hair_green)
	set_p(img, cx - 4, 22, hair_green)
	set_p(img, cx + 4, 22, hair_green)


# ==============================================================================
# 2. KILLUA ZOLDYCK (Cabelo Prateado Volumoso, Gola Alta Azul, T-Shirt Branca)
# ==============================================================================
func draw_killua(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var hair_silver = Color("f0f4fa")
	var hair_shadow = Color("bac2d1")
	var under_blue = Color("1c2448")
	var shirt_white = Color("e4e8f0")
	var shirt_shadow = Color("a6b0c2")
	var shorts_gray = Color("424856")
	var shoes_purple = Color("5e3575")

	# Sapatos (Y=40..42)
	draw_rect_solid(img, cx - 4, 40, cx - 2, 42, shoes_purple)
	draw_rect_solid(img, cx + 2, 40, cx + 4, 42, shoes_purple)

	# Pernas pálidas (Y=37..39)
	draw_rect_solid(img, cx - 4, 37, cx - 2, 39, SKIN_PALE)
	draw_rect_solid(img, cx + 2, 37, cx + 4, 39, SKIN_PALE)

	# Bermuda cinza (Y=35..36)
	draw_rect_solid(img, cx - 4, 35, cx + 4, 36, shorts_gray)

	# Camiseta solta branca sobre gola alta azul (Y=30..34)
	draw_rect_solid(img, cx - 5, 30, cx + 5, 34, shirt_white)
	set_p(img, cx - 5, 34, shirt_shadow)
	set_p(img, cx + 5, 34, shirt_shadow)
	# Gola alta visível
	set_p(img, cx - 1, 30, under_blue)
	set_p(img, cx, 30, under_blue)
	set_p(img, cx + 1, 30, under_blue)

	# Rosto (Y=26..29)
	if not is_back:
		draw_rect_solid(img, cx - 3, 26, cx + 3, 29, SKIN_PALE)
		draw_dot_eyes(img, cx, 27, angle_side)
	else:
		draw_rect_solid(img, cx - 4, 26, cx + 4, 29, hair_shadow)

	# Cabelo Desfiado e Volumoso de Killua (Y=21..27)
	for y in range(21, 27):
		for x in range(cx - 5, cx + 6):
			set_p(img, x, y, hair_silver)
	# Mechas desfiadas laterais e topo
	set_p(img, cx - 6, 24, hair_silver)
	set_p(img, cx + 6, 24, hair_silver)
	set_p(img, cx - 4, 21, hair_shadow)
	set_p(img, cx + 4, 21, hair_shadow)
	set_p(img, cx - 2, 21, hair_silver)
	set_p(img, cx + 2, 21, hair_silver)


# ==============================================================================
# 3. KURAPIKA (Cabelo Loiro Liso Médio, Tabardo Kurta Azul e Vermelho)
# ==============================================================================
func draw_kurapika(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var hair_gold = Color("f5c842")
	var hair_shadow = Color("b89020")
	var tabard_blue = Color("1e4a9e")
	var tabard_shadow = Color("122c60")
	var trim_red = Color("c42424")
	var tunic_white = Color("edf0f8")

	# Sapatos chineses planos (Y=41..42)
	draw_rect_solid(img, cx - 3, 41, cx - 1, 42, Color("1a1a1a"))
	draw_rect_solid(img, cx + 1, 41, cx + 3, 42, Color("1a1a1a"))

	# Calça branca comprida da túnica (Y=37..40)
	draw_rect_solid(img, cx - 4, 37, cx + 4, 40, tunic_white)

	# Tabardo cerimonial azul com acabamento vermelho (Y=30..36)
	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, tabard_blue)
	for y in range(30, 37):
		set_p(img, cx - 5, y, trim_red)
		set_p(img, cx + 5, y, trim_red)
	for x in range(cx - 5, cx + 6):
		set_p(img, x, 36, trim_red)
		set_p(img, x, 30, trim_red)

	# Rosto (Y=26..29)
	if not is_back:
		draw_rect_solid(img, cx - 3, 26, cx + 3, 29, SKIN_LIGHT)
		draw_dot_eyes(img, cx, 27, angle_side)
	else:
		draw_rect_solid(img, cx - 4, 26, cx + 4, 29, hair_shadow)

	# Cabelo Loiro Médio Liso até os ombros (Y=22..28)
	for y in range(22, 28):
		for x in range(cx - 5, cx + 6):
			set_p(img, x, y, hair_gold)
	# Franja reta e pontas nos ombros
	for y in range(25, 29):
		set_p(img, cx - 5, y, hair_gold)
		set_p(img, cx + 5, y, hair_gold)
		set_p(img, cx - 4, y, hair_shadow)
		set_p(img, cx + 4, y, hair_shadow)


# ==============================================================================
# 4. LEORIO (Alto, Terno Azul Escuro, Gravata Vermelha, Óculos, Maleta)
# ==============================================================================
func draw_leorio(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var suit_navy = Color("141c2c")
	var suit_shadow = Color("0a0e18")
	var tie_red = Color("b31b1b")
	var hair_dark = Color("1a1a1e")
	var case_brown = Color("5c3016")

	# Sapatos sociais (Y=41..42)
	draw_rect_solid(img, cx - 3, 41, cx - 1, 42, Color("08080a"))
	draw_rect_solid(img, cx + 1, 41, cx + 3, 42, Color("08080a"))

	# Pernas longas de terno (Y=35..40)
	draw_rect_solid(img, cx - 4, 35, cx - 1, 40, suit_navy)
	draw_rect_solid(img, cx + 1, 35, cx + 4, 40, suit_navy)
	set_p(img, cx, 36, suit_shadow)

	# Paletó social (Y=29..34)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 34, suit_navy)
	if not is_back:
		# Camisa branca interna e gravata
		set_p(img, cx - 1, 29, Color.WHITE)
		set_p(img, cx, 29, tie_red)
		set_p(img, cx + 1, 29, Color.WHITE)
		set_p(img, cx, 30, tie_red)
		set_p(img, cx, 31, tie_red)

	# Maleta de couro na mão direita
	if not is_profile:
		draw_rect_solid(img, cx + 6, 33, cx + 8, 37, case_brown)
		set_p(img, cx + 7, 32, Color("2e160a")) # alça

	# Rosto adulto (Y=25..28)
	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
		# Óculos escuros redondos minúsculos
		set_p(img, cx - 2, 26, Color("0a0a0c"))
		set_p(img, cx + 2, 26, Color("0a0a0c"))
		set_p(img, cx, 26, Color("202024"))
	else:
		draw_rect_solid(img, cx - 4, 25, cx + 4, 28, hair_dark)

	# Cabelo curto escovado para cima (Y=21..24)
	draw_rect_solid(img, cx - 4, 22, cx + 4, 24, hair_dark)
	for x in range(cx - 3, cx + 4, 2):
		set_p(img, x, 21, hair_dark)


# ==============================================================================
# 5. HISOKA MOROW (Cabelo Magenta para Cima, Traje Curinga, Marcas Faciais)
# ==============================================================================
func draw_hisoka(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var hair_magenta = Color("cf1d6e")
	var hair_shadow = Color("850e44")
	var vest_maroon = Color("5c1432")
	var pants_white = Color("f0f2f8")
	var boots_teal = Color("0e757a")

	# Sapatos pontudos com curvatura (Y=40..42)
	draw_rect_solid(img, cx - 4, 40, cx - 1, 42, boots_teal)
	draw_rect_solid(img, cx + 1, 40, cx + 4, 42, boots_teal)
	set_p(img, cx - 5, 42, boots_teal)
	set_p(img, cx + 5, 42, boots_teal)

	# Calça bufante branca (Y=34..39)
	draw_rect_solid(img, cx - 5, 34, cx + 5, 39, pants_white)
	set_p(img, cx - 5, 39, Color("9aa2b4"))
	set_p(img, cx + 5, 39, Color("9aa2b4"))

	# Colete cropped com detalhes de cartas (Y=29..33)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 33, vest_maroon)
	if not is_back:
		# Símbolo no peito
		set_p(img, cx, 31, Color("e01b4c"))

	# Rosto pálido e maquiagem (Y=25..28)
	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_PALE)
		draw_dot_eyes(img, cx, 26, angle_side)
		# Lágrima ciano na bochecha esquerda, estrela bordô na direita
		set_p(img, cx - 2, 28, Color("00e5ff"))
		set_p(img, cx + 2, 28, Color("cf1d6e"))
	else:
		draw_rect_solid(img, cx - 4, 25, cx + 4, 28, hair_shadow)

	# Cabelo Magenta arqueado para trás e espetado para cima (Y=20..24)
	for y in range(20, 25):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, hair_magenta)
	set_p(img, cx - 1, 19, hair_magenta)
	set_p(img, cx + 1, 19, hair_magenta)
	set_p(img, cx + 3, 20, hair_shadow)


# ==============================================================================
# 6. CHROLLO LUCILFER (Sobretudo com Gola de Pele, Cabelo Lambido, Cruz)
# ==============================================================================
func draw_chrollo(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var coat_black = Color("161220")
	var coat_shadow = Color("0d0a14")
	var fur_white = Color("e8eaf2")
	var fur_shadow = Color("9aa0b4")
	var hair_black = Color("101014")

	# Sapatos (Y=41..42)
	draw_rect_solid(img, cx - 3, 41, cx + 3, 42, Color("08080a"))

	# Sobretudo comprido até o tornozelo (Y=32..40)
	draw_rect_solid(img, cx - 5, 32, cx + 5, 40, coat_black)
	set_p(img, cx - 5, 40, coat_shadow)
	set_p(img, cx + 5, 40, coat_shadow)

	if is_back:
		# Cruz de São Pedro nas costas
		for y in range(33, 38): set_p(img, cx, y, Color.WHITE)
		for x in range(cx - 2, cx + 3): set_p(img, x, 34, Color.WHITE)

	# Gola de pele volumosa branca nos ombros (Y=29..31)
	draw_rect_solid(img, cx - 6, 29, cx + 6, 31, fur_white)
	set_p(img, cx - 6, 31, fur_shadow)
	set_p(img, cx + 6, 31, fur_shadow)

	# Rosto (Y=25..28)
	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_PALE)
		draw_dot_eyes(img, cx, 26, angle_side)
		# Tatuagem de cruz na testa / faixa
		set_p(img, cx, 25, Color("2a203a"))
	else:
		draw_rect_solid(img, cx - 4, 25, cx + 4, 28, hair_black)

	# Cabelo Preto Penteado para Trás (Y=22..25)
	draw_rect_solid(img, cx - 4, 22, cx + 4, 25, hair_black)


# ==============================================================================
# 7. ISAAC NETERO (Careca com Coque Samurai, Barba Pontuda Branca, Gi Haori)
# ==============================================================================
func draw_netero(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var gi_white = Color("edf0f6")
	var gi_navy = Color("142240")
	var hair_white = Color("e0e4ee")

	# Sandálias geta (Y=41..42)
	draw_rect_solid(img, cx - 3, 41, cx - 1, 42, Color("3e2a18"))
	draw_rect_solid(img, cx + 1, 41, cx + 3, 42, Color("3e2a18"))

	# Calça larga de artes marciais (Y=35..40)
	draw_rect_solid(img, cx - 5, 35, cx + 5, 40, gi_navy)

	# Túnica haori sem mangas (Y=29..34)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 34, gi_white)
	set_p(img, cx - 5, 30, gi_navy)
	set_p(img, cx + 5, 30, gi_navy)
	# Símbolo no peito
	if not is_back:
		set_p(img, cx, 31, Color("b81c1c"))

	# Rosto enrugado idoso e orelhas compridas (Y=25..28)
	draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_SHADOW)
	set_p(img, cx - 4, 27, SKIN_SHADOW) # orelha alongada
	set_p(img, cx + 4, 27, SKIN_SHADOW)
	if not is_back:
		draw_dot_eyes(img, cx, 26, angle_side)
		# Barba comprida e cavanhaque branco
		set_p(img, cx, 29, hair_white)
		set_p(img, cx, 30, hair_white)

	# Cabeça careca com coque samurai no topo (Y=21..24)
	draw_rect_solid(img, cx - 3, 23, cx + 3, 24, SKIN_SHADOW)
	# Coque branco no alto da cabeça
	set_p(img, cx, 21, hair_white)
	set_p(img, cx, 22, hair_white)


# ==============================================================================
# 8. BISCUIT KRUEGER (Maria-chiquinha dupla loira, Vestido Vitoriano Rosa)
# ==============================================================================
func draw_biscuit(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var dress_pink = Color("d4336c")
	var dress_shadow = Color("941846")
	var frill_white = Color("ffffff")
	var hair_blonde = Color("fad14b")
	var ribbon_red = Color("b3102c")

	# Sapatinhos de boneca (Y=41..42)
	draw_rect_solid(img, cx - 3, 41, cx - 1, 42, dress_shadow)
	draw_rect_solid(img, cx + 1, 41, cx + 3, 42, dress_shadow)

	# Vestido Rodado Vitoriano Rosa com Babados (Y=33..40)
	for y in range(33, 41):
		var w = int((y - 32) * 0.8) + 2
		draw_rect_solid(img, cx - w, y, cx + w, y, dress_pink)
	# Barra de babados brancos
	for x in range(cx - 6, cx + 7):
		set_p(img, x, 40, frill_white)

	# Tronco do vestido com avental branco (Y=29..32)
	draw_rect_solid(img, cx - 4, 29, cx + 4, 32, dress_pink)
	if not is_back:
		set_p(img, cx - 1, 30, frill_white)
		set_p(img, cx, 30, frill_white)
		set_p(img, cx + 1, 30, frill_white)

	# Rosto meigo (Y=25..28)
	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
		draw_dot_eyes(img, cx, 26, angle_side)
	else:
		draw_rect_solid(img, cx - 4, 25, cx + 4, 28, hair_blonde)

	# Cabelo Loiro e Marias-Chiquinhas Encaracoladas (Y=21..28)
	draw_rect_solid(img, cx - 3, 22, cx + 3, 24, hair_blonde)
	# Laços vermelhos
	set_p(img, cx - 5, 23, ribbon_red)
	set_p(img, cx + 5, 23, ribbon_red)
	# Chiquinhas volumosas caindo nas laterais
	for y in range(23, 29):
		set_p(img, cx - 6, y, hair_blonde)
		set_p(img, cx + 6, y, hair_blonde)


# ==============================================================================
# 9. TONPA (Corpo Rotundo / Barriga Saliente, Camisa Azul, Shorts, Suco)
# ==============================================================================
func draw_tonpa(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 14) # Sombra maior para corpo largo

	var shirt_blue = Color("3892c9")
	var shirt_shadow = Color("1e5c82")
	var shorts_tan = Color("a68a64")
	var hair_brown = Color("422616")
	var juice_orange = Color("f07018")

	# Sapatos (Y=41..42)
	draw_rect_solid(img, cx - 4, 41, cx - 2, 42, Color("2a1a10"))
	draw_rect_solid(img, cx + 2, 41, cx + 4, 42, Color("2a1a10"))

	# Pernas grossas e curtas (Y=38..40)
	draw_rect_solid(img, cx - 5, 38, cx - 2, 40, SKIN_LIGHT)
	draw_rect_solid(img, cx + 2, 38, cx + 5, 40, SKIN_LIGHT)

	# Bermuda cáqui larga (Y=35..37)
	draw_rect_solid(img, cx - 6, 35, cx + 6, 37, shorts_tan)

	# Tronco Redondo e Barrigudo (Y=29..34, largura 14 a 16px!)
	for y in range(29, 35):
		var bw = 6 if y in [29, 34] else 7
		draw_rect_solid(img, cx - bw, y, cx + bw, y, shirt_blue)
	for y in range(30, 35):
		set_p(img, cx - 7, y, shirt_shadow)
		set_p(img, cx + 7, y, shirt_shadow)

	# Lata de suco de laranja na mão
	if not is_profile:
		draw_rect_solid(img, cx + 7, 32, cx + 8, 35, juice_orange)
		set_p(img, cx + 7, 31, Color.WHITE) # anel da lata

	# Rosto bochechudo (Y=25..28)
	if not is_back:
		draw_rect_solid(img, cx - 4, 25, cx + 4, 28, SKIN_LIGHT)
		draw_dot_eyes(img, cx, 26, angle_side)
		# Nariz largo característico
		set_p(img, cx, 27, SKIN_SHADOW)
	else:
		draw_rect_solid(img, cx - 5, 25, cx + 5, 28, hair_brown)

	# Cabelo ralo e calvície no topo (Y=23..25)
	set_p(img, cx - 5, 24, hair_brown)
	set_p(img, cx - 4, 23, hair_brown)
	set_p(img, cx + 4, 23, hair_brown)
	set_p(img, cx + 5, 24, hair_brown)


# ==============================================================================
# 10. GING FREECSS (Turbante Bege, Barba por Fazer, Poncho Terroso)
# ==============================================================================
func draw_ging(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var turban_beige = Color("d1ba94")
	var turban_shadow = Color("9c8662")
	var robe_olive = Color("4b5936")
	var robe_shadow = Color("303b22")
	var hair_black = Color("141416")

	# Botas de viagem (Y=40..42)
	draw_rect_solid(img, cx - 4, 40, cx - 1, 42, Color("3d2614"))
	draw_rect_solid(img, cx + 1, 40, cx + 4, 42, Color("3d2614"))

	# Calça de andarilho (Y=36..39)
	draw_rect_solid(img, cx - 4, 36, cx + 4, 39, robe_shadow)

	# Poncho e túnica em camadas (Y=29..35)
	draw_rect_solid(img, cx - 6, 29, cx + 6, 35, robe_olive)
	for y in range(30, 36):
		set_p(img, cx - 6, y, robe_shadow)
		set_p(img, cx + 6, y, robe_shadow)

	# Rosto com barba por fazer (Y=25..28)
	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
		draw_dot_eyes(img, cx, 26, angle_side)
		set_p(img, cx - 1, 28, hair_black) # barba rala
		set_p(img, cx, 28, hair_black)
		set_p(img, cx + 1, 28, hair_black)
	else:
		draw_rect_solid(img, cx - 4, 25, cx + 4, 28, hair_black)

	# Turbante volumoso bege na cabeça (Y=21..24)
	draw_rect_solid(img, cx - 5, 22, cx + 5, 24, turban_beige)
	set_p(img, cx - 5, 24, turban_shadow)
	set_p(img, cx + 5, 24, turban_shadow)
	# Mechas desgrenhadas saindo do turbante
	set_p(img, cx - 4, 21, hair_black)
	set_p(img, cx + 4, 21, hair_black)


# ==============================================================================
# 11. HANZO (Ninja Careca com Faixa, Traje Shinobi Cinza-Escuro)
# ==============================================================================
func draw_hanzo(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var shinobi_dark = Color("242830")
	var shinobi_wrap = Color("606878")

	draw_rect_solid(img, cx - 3, 40, cx - 1, 42, shinobi_dark)
	draw_rect_solid(img, cx + 1, 40, cx + 3, 42, shinobi_dark)

	# Ataduras nas pernas (Y=36..39)
	draw_rect_solid(img, cx - 4, 36, cx + 4, 39, shinobi_wrap)

	# Traje ninja (Y=29..35)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 35, shinobi_dark)
	if not is_back:
		set_p(img, cx, 31, shinobi_wrap)

	# Rosto determinado e cabeça raspada (Y=23..28)
	draw_rect_solid(img, cx - 3, 23, cx + 3, 28, SKIN_LIGHT)
	if not is_back:
		draw_dot_eyes(img, cx, 26, angle_side)

	# Faixa ninja na testa (Y=24)
	for x in range(cx - 4, cx + 5):
		set_p(img, x, 24, shinobi_dark)


# ==============================================================================
# 12. POKKLE (Boina Alaranjada de Arqueiro, Túnica Verde)
# ==============================================================================
func draw_pokkle(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var hat_orange = Color("e65c00")
	var tunic_green = Color("2d7838")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("4a2810"))
	draw_rect_solid(img, cx - 4, 36, cx + 4, 39, Color("205028"))
	draw_rect_solid(img, cx - 5, 29, cx + 5, 35, tunic_green)

	# Boina alaranjada volumosa (Y=21..24)
	draw_rect_solid(img, cx - 6, 22, cx + 6, 24, hat_orange)
	set_p(img, cx - 1, 21, hat_orange)
	set_p(img, cx + 1, 21, hat_orange)

	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
		draw_dot_eyes(img, cx, 26, angle_side)


# ==============================================================================
# 13. PONZU (Chapéu Puffy Amarelo Gigante de Apicultora, Capa Marrom)
# ==============================================================================
func draw_ponzu(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var hat_yellow = Color("e0a81d")
	var cape_brown = Color("6b3d18")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("2a1a0c"))
	draw_rect_solid(img, cx - 4, 36, cx + 4, 39, Color("c2881b"))
	draw_rect_solid(img, cx - 5, 29, cx + 5, 35, cape_brown)

	# Chapéu de abelhas enorme e bojudo (Y=20..24, largura 14px!)
	draw_rect_solid(img, cx - 7, 21, cx + 7, 24, hat_yellow)
	draw_rect_solid(img, cx - 5, 20, cx + 5, 21, hat_yellow)

	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
		draw_dot_eyes(img, cx, 26, angle_side)


# ==============================================================================
# 14. BUHARA (Gigante Massivo, Grande Barriga Nua, Colete Aberto, Shorts Amarelo)
# ==============================================================================
func draw_buhara(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 16) # Sombra massiva

	var vest_dark = Color("2e1a12")
	var shorts_yellow = Color("d9a820")

	# Pés gigantes (Y=41..42)
	draw_rect_solid(img, cx - 5, 41, cx - 2, 42, Color("1a1008"))
	draw_rect_solid(img, cx + 2, 41, cx + 5, 42, Color("1a1008"))

	# Pernas grossas (Y=38..40)
	draw_rect_solid(img, cx - 6, 38, cx - 2, 40, SKIN_DARK)
	draw_rect_solid(img, cx + 2, 38, cx + 6, 40, SKIN_DARK)

	# Shorts amarelo largo (Y=34..37)
	draw_rect_solid(img, cx - 7, 34, cx + 7, 37, shorts_yellow)

	# Torso Gigante com Grande Barriga Nua no Centro (Y=28..33, largura 16px!)
	draw_rect_solid(img, cx - 8, 28, cx + 8, 33, SKIN_DARK)
	# Colete aberto nas bordas
	for y in range(28, 34):
		set_p(img, cx - 8, y, vest_dark)
		set_p(img, cx - 7, y, vest_dark)
		set_p(img, cx + 7, y, vest_dark)
		set_p(img, cx + 8, y, vest_dark)

	# Cabeça (Y=24..27)
	draw_rect_solid(img, cx - 4, 24, cx + 4, 27, SKIN_DARK)
	if not is_back:
		draw_dot_eyes(img, cx, 25, angle_side)
	# Cabelo castanho curto no topo
	draw_rect_solid(img, cx - 4, 22, cx + 4, 24, Color("341c0e"))


# ==============================================================================
# 15. MENCHI (Chifres Duplos Ciano/Turquesa, Top Cropped, Facas na Cintura)
# ==============================================================================
func draw_menchi(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var hair_cyan = Color("0fb8b0")
	var hair_shadow = Color("0a6b66")
	var crop_black = Color("1a1a1a")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("141414"))
	draw_rect_solid(img, cx - 4, 36, cx + 4, 39, crop_black)

	# Abdômen exposto e top cropped (Y=30..35)
	draw_rect_solid(img, cx - 4, 33, cx + 4, 35, SKIN_LIGHT)
	draw_rect_solid(img, cx - 4, 30, cx + 4, 32, crop_black)

	# Facas de chef na cintura
	set_p(img, cx - 5, 34, Color.WHITE)
	set_p(img, cx + 5, 34, Color.WHITE)

	# Rosto (Y=25..28)
	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
		draw_dot_eyes(img, cx, 26, angle_side)
	else:
		draw_rect_solid(img, cx - 4, 25, cx + 4, 28, hair_shadow)

	# Cabelo Turquesa com Chifres/Drills Verticais no Topo (Y=20..25)
	draw_rect_solid(img, cx - 4, 23, cx + 4, 25, hair_cyan)
	# Chifres verticais duplos
	for y in range(20, 24):
		set_p(img, cx - 3, y, hair_cyan)
		set_p(img, cx + 3, y, hair_cyan)


# ==============================================================================
# 16. GITTARACKUR / ILLUMI (Rígido, Pinos Metálicos Dourados no Crânio)
# ==============================================================================
func draw_gittarackur(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 9)

	var suit_green = Color("234226")
	var pin_gold = Color("f0c020")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("101812"))
	draw_rect_solid(img, cx - 4, 35, cx + 4, 39, suit_green)
	draw_rect_solid(img, cx - 4, 29, cx + 4, 34, suit_green)

	# Pinos na roupa
	set_p(img, cx - 2, 31, pin_gold)
	set_p(img, cx + 2, 31, pin_gold)
	set_p(img, cx, 33, pin_gold)

	# Cabeça com múltiplos pinos espetados (Y=23..28)
	draw_rect_solid(img, cx - 3, 24, cx + 3, 28, SKIN_PALE)
	if not is_back:
		# Olhos vazados circulares bizarros
		set_p(img, cx - 2, 26, Color.BLACK)
		set_p(img, cx + 2, 26, Color.BLACK)
	# Pinos dourados no crânio saindo em várias direções
	set_p(img, cx - 4, 24, pin_gold)
	set_p(img, cx + 4, 24, pin_gold)
	set_p(img, cx - 2, 22, pin_gold)
	set_p(img, cx + 2, 22, pin_gold)
	set_p(img, cx, 21, pin_gold)


# ==============================================================================
# 17. BODORO (Guerreiro Antigo, Cabelo Grisalho Amarrado, Armadura Gi)
# ==============================================================================
func draw_bodoro(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var armor_brown = Color("5e3c20")
	var gi_gray = Color("788090")
	var hair_gray = Color("bcc0cc")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("20140a"))
	draw_rect_solid(img, cx - 4, 35, cx + 4, 39, gi_gray)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 34, gi_gray)
	# Placas de armadura no peito
	draw_rect_solid(img, cx - 4, 30, cx + 4, 32, armor_brown)

	# Rosto severo e cabelo grisalho amarrado
	draw_rect_solid(img, cx - 3, 24, cx + 3, 28, SKIN_DARK)
	if not is_back:
		draw_dot_eyes(img, cx, 26, angle_side)
	draw_rect_solid(img, cx - 4, 22, cx + 4, 24, hair_gray)
	set_p(img, cx, 21, hair_gray)


# ==============================================================================
# 18. NICOL (Estudante com Óculos, Colete Amarelo, Laptop nas Mãos)
# ==============================================================================
func draw_nicol(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var vest_yellow = Color("d9a418")
	var pants_navy = Color("1c2b48")
	var laptop_gray = Color("626875")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("141416"))
	draw_rect_solid(img, cx - 4, 35, cx + 4, 39, pants_navy)
	draw_rect_solid(img, cx - 4, 29, cx + 4, 34, vest_yellow)

	# Laptop segurado com as duas mãos
	if not is_back:
		draw_rect_solid(img, cx - 3, 32, cx + 3, 34, laptop_gray)
		set_p(img, cx, 33, Color.WHITE) # tela brilhando

	# Rosto com óculos redondos
	draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
	if not is_back:
		set_p(img, cx - 2, 26, Color.BLACK)
		set_p(img, cx + 2, 26, Color.BLACK)
		set_p(img, cx, 26, Color("707070"))
	draw_rect_solid(img, cx - 4, 23, cx + 4, 24, Color("3a2414"))


# ==============================================================================
# 19. INIMIGO: CANDIDATO DO EXAME (Bandana, Colete, Faca de Combate)
# ==============================================================================
func draw_candidato_exame(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var bandana_red = Color("b81c1c")
	var vest_leather = Color("5c381c")
	var pants_dark = Color("283038")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("1a1410"))
	draw_rect_solid(img, cx - 4, 35, cx + 4, 39, pants_dark)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 34, vest_leather)
	set_p(img, cx + 6, 33, Color.WHITE) # adaga

	draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
	if not is_back:
		draw_dot_eyes(img, cx, 26, angle_side)
	# Bandana vermelha na testa
	for x in range(cx - 4, cx + 5): set_p(img, x, 24, bandana_red)


# ==============================================================================
# 20. INIMIGO: CRIATURA DO PANTANAL (Macaco do Pantanal de Numere, Peludo)
# ==============================================================================
func draw_criatura_pantanal(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 13)

	var fur_brown = Color("5c2c14")
	var fur_shadow = Color("381808")
	var claws_white = Color("e0e0d0")

	# Garras e patas traseiras baixas (postura recurvada/agachada)
	draw_rect_solid(img, cx - 5, 39, cx - 2, 42, fur_shadow)
	draw_rect_solid(img, cx + 2, 39, cx + 5, 42, fur_shadow)
	set_p(img, cx - 5, 42, claws_white)
	set_p(img, cx + 5, 42, claws_white)

	# Corpo peludo e corcunda (Y=30..39, largura 14px)
	draw_rect_solid(img, cx - 6, 30, cx + 6, 38, fur_brown)
	# Braços longos pendendo até o chão com garras
	for y in range(32, 41):
		set_p(img, cx - 7, y, fur_brown)
		set_p(img, cx + 7, y, fur_brown)
	set_p(img, cx - 7, 41, claws_white)
	set_p(img, cx + 7, 41, claws_white)

	# Cabeça de besta primata (Y=24..29)
	draw_rect_solid(img, cx - 4, 25, cx + 4, 29, fur_shadow)
	if not is_back:
		# Olhos amarelos brilhantes de besta
		set_p(img, cx - 2, 26, Color("ffd000"))
		set_p(img, cx + 2, 26, Color("ffd000"))
		set_p(img, cx, 28, Color("cc2020")) # focinho/boca


# ==============================================================================
# 21. INIMIGO: MORDOMO ZOLDYCK (Terno Preto Formal, Luvas Brancas, Moeda)
# ==============================================================================
func draw_mordomo_zoldyck(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var suit_black = Color("141416")
	var shirt_white = Color.WHITE

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("080808"))
	draw_rect_solid(img, cx - 4, 35, cx + 4, 39, suit_black)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 34, suit_black)
	if not is_back:
		set_p(img, cx, 29, shirt_white)
		set_p(img, cx, 30, shirt_white)
		# Luva branca e moeda brilhando
		set_p(img, cx + 6, 33, shirt_white)
		set_p(img, cx + 6, 32, Color("ffd700"))

	draw_rect_solid(img, cx - 3, 24, cx + 3, 28, SKIN_LIGHT)
	if not is_back:
		set_p(img, cx - 2, 26, Color.BLACK)
		set_p(img, cx + 2, 26, Color.BLACK)
	draw_rect_solid(img, cx - 4, 22, cx + 4, 24, suit_black)


# ==============================================================================
# 22. INIMIGO: LUTADOR DA ARENA (Faixas nas Mãos, Calção de Boxe/Muay Thai)
# ==============================================================================
func draw_lutador_arena(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var trunks_red = Color("b81c1c")
	var wraps_white = Color("f0f0f0")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("141414"))
	draw_rect_solid(img, cx - 4, 37, cx + 4, 39, SKIN_LIGHT)
	draw_rect_solid(img, cx - 5, 34, cx + 5, 36, trunks_red)
	# Tronco musculoso nu
	draw_rect_solid(img, cx - 5, 29, cx + 5, 33, SKIN_LIGHT)
	# Ataduras nos punhos
	set_p(img, cx - 6, 32, wraps_white)
	set_p(img, cx + 6, 32, wraps_white)

	draw_rect_solid(img, cx - 3, 24, cx + 3, 28, SKIN_LIGHT)
	if not is_back:
		draw_dot_eyes(img, cx, 26, angle_side)
	draw_rect_solid(img, cx - 4, 22, cx + 4, 24, Color("20140a"))


# ==============================================================================
# 23. INIMIGO: MAFIOSO DE YORKNEW (Sobretudo Pinstripe, Chapéu Fedora, Pistola)
# ==============================================================================
func draw_mafioso_yorknew(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var suit_gray = Color("282c34")
	var fedora_black = Color("16181c")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("0c0c0e"))
	draw_rect_solid(img, cx - 4, 35, cx + 4, 39, suit_gray)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 34, suit_gray)
	set_p(img, cx + 6, 33, Color("101010")) # arma na mão

	# Chapéu fedora elegante com aba larga (Y=21..24)
	draw_rect_solid(img, cx - 6, 23, cx + 6, 24, fedora_black)
	draw_rect_solid(img, cx - 4, 21, cx + 4, 22, fedora_black)
	set_p(img, cx, 23, Color("b81c1c")) # fita vermelha no chapéu

	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_LIGHT)
		draw_dot_eyes(img, cx, 26, angle_side)


# ==============================================================================
# 24. INIMIGO: BOMBER (GENTHRU) (Óculos Retangulares, Mãos em Brasa)
# ==============================================================================
func draw_bomber_greed(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var coat_tan = Color("8c6c48")
	var hair_blond = Color("e0be34")
	var spark_orange = Color("ff6000")

	draw_rect_solid(img, cx - 3, 40, cx + 3, 42, Color("1a140a"))
	draw_rect_solid(img, cx - 4, 35, cx + 4, 39, Color("202430"))
	draw_rect_solid(img, cx - 5, 29, cx + 5, 34, coat_tan)

	# Mãos estendidas com centelha de Little Flower
	set_p(img, cx - 6, 32, spark_orange)
	set_p(img, cx + 6, 32, spark_orange)

	draw_rect_solid(img, cx - 3, 24, cx + 3, 28, SKIN_LIGHT)
	if not is_back:
		# Óculos retangulares
		set_p(img, cx - 2, 26, Color.BLACK)
		set_p(img, cx - 1, 26, Color.BLACK)
		set_p(img, cx + 1, 26, Color.BLACK)
		set_p(img, cx + 2, 26, Color.BLACK)
	draw_rect_solid(img, cx - 4, 22, cx + 4, 24, hair_blond)


# ==============================================================================
# 25. INIMIGO: FORMIGA SOLDADO (Carapaça Quitina Verde/Azul, Antenas, Garras)
# ==============================================================================
func draw_formiga_soldado(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 12)

	var chitin_green = Color("1e4a32")
	var chitin_shadow = Color("0f291a")
	var eye_purple = Color("8a1890")

	# Pernas articuladas insetóides (Y=38..42)
	draw_rect_solid(img, cx - 5, 38, cx - 2, 42, chitin_shadow)
	draw_rect_solid(img, cx + 2, 38, cx + 5, 42, chitin_shadow)

	# Tórax e abdômen segmentado (Y=29..37)
	draw_rect_solid(img, cx - 6, 29, cx + 6, 37, chitin_green)
	# Garras em pinça
	set_p(img, cx - 7, 33, chitin_shadow)
	set_p(img, cx - 8, 34, chitin_shadow)
	set_p(img, cx + 7, 33, chitin_shadow)
	set_p(img, cx + 8, 34, chitin_shadow)

	# Cabeça de formiga com olhos compostos e antenas (Y=21..28)
	draw_rect_solid(img, cx - 4, 24, cx + 4, 28, chitin_shadow)
	if not is_back:
		set_p(img, cx - 3, 26, eye_purple)
		set_p(img, cx + 3, 26, eye_purple)
	# Antenas pontudas no topo
	set_p(img, cx - 3, 21, chitin_green)
	set_p(img, cx - 2, 22, chitin_green)
	set_p(img, cx + 3, 21, chitin_green)
	set_p(img, cx + 2, 22, chitin_green)


# ==============================================================================
# 26. INIMIGO: FORMIGA LÍDER DE ESQUADRÃO (Bípede Ameaçador com Chifres e Aura)
# ==============================================================================
func draw_formiga_lider(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 13)

	var armor_dark = Color("382040")
	var flesh_violet = Color("5c3866")
	var horn_gold = Color("d49c18")

	draw_rect_solid(img, cx - 4, 38, cx + 4, 42, Color("1c0e20"))
	draw_rect_solid(img, cx - 6, 30, cx + 6, 37, flesh_violet)
	draw_rect_solid(img, cx - 5, 30, cx + 5, 33, armor_dark)

	# Cabeça ameaçadora com chifres curvados (Y=21..28)
	draw_rect_solid(img, cx - 4, 24, cx + 4, 28, armor_dark)
	if not is_back:
		set_p(img, cx - 2, 26, Color("ff2020"))
		set_p(img, cx + 2, 26, Color("ff2020"))
	# Chifres
	set_p(img, cx - 5, 21, horn_gold)
	set_p(img, cx - 4, 22, horn_gold)
	set_p(img, cx + 5, 21, horn_gold)
	set_p(img, cx + 4, 22, horn_gold)


# ==============================================================================
# 27. GUARDA REAL (NEFERPITOU) (Orelhas de Gato, Cabelo Ondulado Branco, Casaco Azul)
# ==============================================================================
func draw_guarda_real(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 10)

	var coat_navy = Color("142444")
	var hair_white = Color("f0f2fa")
	var hair_shadow = Color("bac2d6")

	# Meias até o joelho e sapatos (Y=38..42)
	draw_rect_solid(img, cx - 3, 38, cx + 3, 42, Color("1a1a24"))

	# Casaco azul com botões dourados (Y=29..37)
	draw_rect_solid(img, cx - 5, 29, cx + 5, 37, coat_navy)
	if not is_back:
		set_p(img, cx, 31, Color("ffd700"))
		set_p(img, cx, 34, Color("ffd700"))

	# Rosto felino expressivo (Y=25..28)
	if not is_back:
		draw_rect_solid(img, cx - 3, 25, cx + 3, 28, SKIN_PALE)
		# Olhos vermelhos felinos
		set_p(img, cx - 2, 26, Color("c81830"))
		set_p(img, cx + 2, 26, Color("c81830"))
	else:
		draw_rect_solid(img, cx - 4, 25, cx + 4, 28, hair_shadow)

	# Cabelo Branco Ondulado (Y=22..27)
	draw_rect_solid(img, cx - 5, 23, cx + 5, 27, hair_white)
	# Orelhas de Gato pontudas no topo (Y=20..22)
	set_p(img, cx - 4, 20, hair_white)
	set_p(img, cx - 3, 21, hair_white)
	set_p(img, cx - 3, 22, Color("ff99bb")) # interior rosa da orelha
	set_p(img, cx + 4, 20, hair_white)
	set_p(img, cx + 3, 21, hair_white)
	set_p(img, cx + 3, 22, Color("ff99bb"))


# ==============================================================================
# 28. BOSS RAZOR (Ombros Largos Musculosos, Regata Vermelha, Bola de Aura Vermelha)
# ==============================================================================
func draw_boss_razor(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 15)

	var tank_red = Color("a61e1e")
	var tank_shadow = Color("701010")
	var shorts_gray = Color("384048")
	var ball_red = Color("e61818")

	draw_rect_solid(img, cx - 4, 40, cx + 4, 42, Color("14161a"))
	draw_rect_solid(img, cx - 5, 35, cx + 5, 39, shorts_gray)

	# Tronco Musculoso e Largo (Y=28..34, largura 15px!)
	draw_rect_solid(img, cx - 7, 28, cx + 7, 34, SKIN_DARK)
	draw_rect_solid(img, cx - 5, 28, cx + 5, 34, tank_red)
	set_p(img, cx - 5, 34, tank_shadow)
	set_p(img, cx + 5, 34, tank_shadow)

	# Bola de Vôlei de Aura de Nen Vermelha na mão (mantendo dentro de 17px)
	draw_rect_solid(img, cx + 6, 30, cx + 8, 33, ball_red)
	set_p(img, cx + 7, 31, Color.WHITE) # brilho central de Nen

	# Rosto imponente e cabelo raspado (Y=23..27)
	draw_rect_solid(img, cx - 4, 24, cx + 4, 27, SKIN_DARK)
	if not is_back:
		draw_dot_eyes(img, cx, 25, angle_side)
	draw_rect_solid(img, cx - 4, 22, cx + 4, 23, Color("20140a"))


# ==============================================================================
# 29. BOSS MERUEM (O Rei das Formigas: Carapaça Verde, Elmo, Cauda Poderosa)
# ==============================================================================
func draw_boss_meruem(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 14)

	var skin_jade = Color("2e7a52")
	var skin_shadow = Color("1a4a30")
	var helm_purple = Color("281830")
	var helm_shadow = Color("160c1c")

	# Pés fortes (Y=40..42)
	draw_rect_solid(img, cx - 4, 40, cx + 4, 42, skin_shadow)

	# Pernas e abdômen atlético (Y=34..39)
	draw_rect_solid(img, cx - 5, 34, cx + 5, 39, skin_jade)

	# Cauda Grossa com Ferrão saindo atrás (Y=33..41)
	if is_profile or is_back:
		var tail_side = -1 if angle_side >= 0 else 1
		for y in range(35, 42):
			set_p(img, cx + (tail_side * 7), y, skin_shadow)
		# Ferrão grosso no final da cauda
		draw_rect_solid(img, cx + (tail_side * 8), 40, cx + (tail_side * 9), 42, helm_purple)

	# Tronco imponente (Y=28..33)
	draw_rect_solid(img, cx - 6, 28, cx + 6, 33, skin_jade)
	for y in range(29, 34):
		set_p(img, cx - 6, y, skin_shadow)
		set_p(img, cx + 6, y, skin_shadow)

	# Rosto majestoso (Y=24..27)
	draw_rect_solid(img, cx - 3, 24, cx + 3, 27, skin_jade)
	if not is_back:
		# Olhos roxos penetrantes
		set_p(img, cx - 2, 25, Color("9920aa"))
		set_p(img, cx + 2, 25, Color("9920aa"))

	# Elmo natural de carapaça no topo da cabeça (Y=20..24)
	draw_rect_solid(img, cx - 5, 21, cx + 5, 24, helm_purple)
	set_p(img, cx - 5, 24, helm_shadow)
	set_p(img, cx + 5, 24, helm_shadow)
	set_p(img, cx - 1, 20, helm_purple)
	set_p(img, cx + 1, 20, helm_purple)
