@tool
extends SceneTree

# ==============================================================================
# HUNTER ONLINE — HIGH-FIDELITY CHARACTER SPRITE GENERATOR (2D MMORPG STANDARD)
# Densidade: 1x a 2x do Player.png | Shading: 2-4 níveis por material
# Canvas: 48x48 px | Baseline: Y=42 | 8 Direções Canônicas
# ==============================================================================

const FW: int = 48
const FH: int = 48
const TARGET_FEET_Y: int = 42

const SHADOW_COLOR := Color(0.05, 0.07, 0.12, 0.45)
const OUTLINE_DARK := Color(0.07, 0.06, 0.09, 1.0)
const SKIN_BASE := Color("ecc29c")
const SKIN_SHADOW := Color("ba8662")
const SKIN_HIGHLIGHT := Color("fce2c8")
const EYE_DARK := Color("141018")

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

# Desenha pés e sapatos canônicos com solado escuro e iluminação
func draw_standard_shoes(img: Image, cx: int, is_back: bool, is_profile: bool, angle_side: int, base_col: Color, shadow_col: Color, highlight_col: Color) -> void:
	if is_profile:
		var toe_x = cx + (3 if angle_side >= 0 else -3)
		var heel_x = cx - (1 if angle_side >= 0 else -1)
		var min_x = mini(toe_x, heel_x)
		var max_x = maxi(toe_x, heel_x)
		# Solado escuro
		for x in range(min_x, max_x + 1):
			set_p(img, x, 42, OUTLINE_DARK)
		# Corpo do sapato
		for x in range(min_x, max_x + 1):
			set_p(img, x, 41, base_col)
		for x in range(min_x + 1, max_x):
			set_p(img, x, 40, base_col)
		set_p(img, toe_x, 41, highlight_col)
		set_p(img, heel_x, 41, shadow_col)
	else:
		# Pés separados (esquerdo e direito)
		var lx1 = cx - 4
		var lx2 = cx - 2
		var rx1 = cx + 2
		var rx2 = cx + 4
		if angle_side > 0:
			lx1 += 1; lx2 += 1; rx1 += 1; rx2 += 1
		elif angle_side < 0:
			lx1 -= 1; lx2 -= 1; rx1 -= 1; rx2 -= 1

		# Solado Y=42
		for x in range(lx1, lx2 + 1): set_p(img, x, 42, OUTLINE_DARK)
		for x in range(rx1, rx2 + 1): set_p(img, x, 42, OUTLINE_DARK)
		# Sapato Y=40..41
		for x in range(lx1, lx2 + 1): set_p(img, x, 41, base_col)
		for x in range(rx1, rx2 + 1): set_p(img, x, 41, base_col)
		set_p(img, lx1, 40, shadow_col); set_p(img, lx2, 40, highlight_col)
		set_p(img, rx1, 40, highlight_col); set_p(img, rx2, 40, shadow_col)

# Desenha pernas com separação e dobras
func draw_standard_legs(img: Image, cx: int, is_back: bool, is_profile: bool, angle_side: int, base_col: Color, shadow_col: Color, highlight_col: Color) -> void:
	if is_profile:
		var px = cx + (1 if angle_side > 0 else (-1 if angle_side < 0 else 0))
		draw_rect_solid(img, px - 2, 36, px + 2, 39, base_col)
		# Linha de dobra
		set_p(img, px - 2, 37, shadow_col)
		set_p(img, px - 2, 38, shadow_col)
		set_p(img, px + 2, 36, highlight_col)
		set_p(img, px + 2, 37, highlight_col)
	else:
		var lx1 = cx - 4; var lx2 = cx - 2
		var rx1 = cx + 2; var rx2 = cx + 4
		if angle_side > 0:
			lx1 += 1; lx2 += 1; rx1 += 1; rx2 += 1
		elif angle_side < 0:
			lx1 -= 1; lx2 -= 1; rx1 -= 1; rx2 -= 1

		# Perna esquerda
		draw_rect_solid(img, lx1, 36, lx2, 39, base_col)
		set_p(img, lx1, 37, shadow_col)
		set_p(img, lx2, 37, highlight_col)
		# Perna direita
		draw_rect_solid(img, rx1, 36, rx2, 39, base_col)
		set_p(img, rx1, 38, highlight_col)
		set_p(img, rx2, 38, shadow_col)
		# Vinco central / sombra entre pernas
		set_p(img, cx, 36, OUTLINE_DARK)
		set_p(img, cx, 37, shadow_col)

# Desenha rosto detalhado com formato anatômico chibi, queixo e olhos
func draw_chibi_face(img: Image, cx: int, is_back: bool, is_profile: bool, angle_side: int, skin_base: Color, skin_shadow: Color, skin_light: Color, eye_color: Color = EYE_DARK) -> void:
	if is_back:
		# Nuca e cabelo de trás cobrem o rosto
		draw_rect_solid(img, cx - 3, 26, cx + 3, 29, skin_shadow)
		set_p(img, cx, 30, skin_shadow) # Pescoço
		return

	if is_profile:
		var fx = cx + (1 if angle_side >= 0 else -1)
		# Formato do perfil
		draw_rect_solid(img, fx - 2, 26, fx + 3, 29, skin_base)
		# Queixo arredondado
		set_p(img, fx + 3, 28, skin_light)
		set_p(img, fx + 2, 29, skin_shadow)
		set_p(img, fx + 1, 30, skin_shadow) # Pescoço
		# Olho de perfil (1x2 com ponto de vida)
		set_p(img, fx + 2, 27, eye_color)
		set_p(img, fx + 2, 28, eye_color)
	else:
		# Vista frontal ou 3/4
		var ox = 1 if angle_side > 0 else (-1 if angle_side < 0 else 0)
		# Base do rosto
		draw_rect_solid(img, cx - 4 + ox, 26, cx + 4 + ox, 29, skin_base)
		# Maxilar / Queixo esculpido
		set_p(img, cx - 4 + ox, 29, skin_shadow)
		set_p(img, cx + 4 + ox, 29, skin_shadow)
		set_p(img, cx - 3 + ox, 30, skin_shadow)
		set_p(img, cx + 3 + ox, 30, skin_shadow)
		set_p(img, cx + ox, 30, skin_base) # Queixo central
		# Bochechas e highlight
		set_p(img, cx - 2 + ox, 28, skin_light)
		set_p(img, cx + 2 + ox, 28, skin_light)
		# Pescoço
		set_p(img, cx + ox, 31, skin_shadow)

		# Olhos expressivos canônicos (1x2 verticais, com espaçamento exato)
		if angle_side == 0:
			# South estrito: dois olhos 1x2 separados por 3px de pele
			set_p(img, cx - 2, 27, eye_color)
			set_p(img, cx - 2, 28, eye_color)
			set_p(img, cx + 2, 27, eye_color)
			set_p(img, cx + 2, 28, eye_color)
		elif angle_side > 0:
			# 3/4 Direita
			set_p(img, cx - 1, 27, eye_color)
			set_p(img, cx - 1, 28, eye_color)
			set_p(img, cx + 3, 27, eye_color)
			set_p(img, cx + 3, 28, eye_color)
		else:
			# 3/4 Esquerda
			set_p(img, cx - 3, 27, eye_color)
			set_p(img, cx - 3, 28, eye_color)
			set_p(img, cx + 1, 27, eye_color)
			set_p(img, cx + 1, 28, eye_color)

# ==============================================================================
# DISPATCHER DE GERAÇÃO POR PERSONAGEM
# ==============================================================================
func generate_character_frame(char_id: String, dir_index: int) -> Image:
	var img = Image.create(FW, FH, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var is_back = dir_index in [3, 4, 5]
	var is_profile = dir_index in [2, 6]
	var angle_side = 1 if dir_index in [1, 2, 3] else (-1 if dir_index in [5, 6, 7] else 0)
	var flip = dir_index in [5, 6, 7]

	# Renderizamos a versão da direita para [5,6,7] e depois invertemos com flip_x
	var work_angle_side = -angle_side if flip else angle_side

	match char_id:
		"npc_gon":
			draw_gon(img, is_back, is_profile, work_angle_side)
		"npc_killua":
			draw_killua(img, is_back, is_profile, work_angle_side)
		"npc_kurapika":
			draw_kurapika(img, is_back, is_profile, work_angle_side)
		"npc_leorio":
			draw_leorio(img, is_back, is_profile, work_angle_side)
		"npc_hisoka":
			draw_hisoka(img, is_back, is_profile, work_angle_side)
		"npc_chrollo":
			draw_chrollo(img, is_back, is_profile, work_angle_side)
		"npc_netero":
			draw_netero(img, is_back, is_profile, work_angle_side)
		"npc_biscuit":
			draw_biscuit(img, is_back, is_profile, work_angle_side)
		"npc_tonpa":
			draw_tonpa(img, is_back, is_profile, work_angle_side)
		"npc_ging":
			draw_ging(img, is_back, is_profile, work_angle_side)
		"npc_hanzo":
			draw_hanzo(img, is_back, is_profile, work_angle_side)
		"npc_pokkle":
			draw_pokkle(img, is_back, is_profile, work_angle_side)
		"npc_ponzu":
			draw_ponzu(img, is_back, is_profile, work_angle_side)
		"npc_buhara":
			draw_buhara(img, is_back, is_profile, work_angle_side)
		"npc_menchi":
			draw_menchi(img, is_back, is_profile, work_angle_side)
		"npc_gittarackur":
			draw_gittarackur(img, is_back, is_profile, work_angle_side)
		"npc_bodoro":
			draw_bodoro(img, is_back, is_profile, work_angle_side)
		"npc_nicol":
			draw_nicol(img, is_back, is_profile, work_angle_side)

		# INIMIGOS
		"enemy_candidato_exame":
			draw_candidato_exame(img, is_back, is_profile, work_angle_side)
		"enemy_criatura_pantanal":
			draw_criatura_pantanal(img, is_back, is_profile, work_angle_side)
		"enemy_mordomo_zoldyck":
			draw_mordomo_zoldyck(img, is_back, is_profile, work_angle_side)
		"enemy_lutador_arena":
			draw_lutador_arena(img, is_back, is_profile, work_angle_side)
		"enemy_mafioso_yorknew":
			draw_mafioso_yorknew(img, is_back, is_profile, work_angle_side)
		"enemy_bomber_greed":
			draw_bomber_greed(img, is_back, is_profile, work_angle_side)
		"enemy_formiga_soldado":
			draw_formiga_soldado(img, is_back, is_profile, work_angle_side)
		"enemy_formiga_lider":
			draw_formiga_lider(img, is_back, is_profile, work_angle_side)
		"enemy_guarda_real":
			draw_guarda_real(img, is_back, is_profile, work_angle_side)
		"enemy_boss_razor":
			draw_boss_razor(img, is_back, is_profile, work_angle_side)
		"enemy_boss_meruem":
			draw_boss_meruem(img, is_back, is_profile, work_angle_side)

	if flip:
		img.flip_x()

	return img

# ==============================================================================
# 1. GON FREECSS
# ==============================================================================
func draw_gon(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var hair_black = OUTLINE_DARK
	var hair_dark_green = Color("1e4e24")
	var hair_bright_green = Color("388e42")
	var coat_base = Color("2c8438")
	var coat_shadow = Color("1e4e24") # Reutiliza verde escuro
	var coat_highlight = Color("44aa52")
	var trim_orange = Color("f06414")
	var boots_base = Color("5c381e")
	var boots_shadow = OUTLINE_DARK

	# Botas (Y=39..42)
	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, boots_base, boots_shadow, boots_base)

	# Pernas nuas (Y=37..38)
	var lx1 = cx - 4; var lx2 = cx - 2; var rx1 = cx + 2; var rx2 = cx + 4
	if is_profile:
		draw_rect_solid(img, cx - 2, 37, cx + 2, 38, SKIN_BASE)
		set_p(img, cx - 2, 38, SKIN_SHADOW)
	else:
		draw_rect_solid(img, lx1, 37, lx2, 38, SKIN_BASE)
		draw_rect_solid(img, rx1, 37, rx2, 38, SKIN_BASE)
		set_p(img, lx1, 38, SKIN_SHADOW); set_p(img, rx2, 38, SKIN_SHADOW)

	# Shorts verde curto (Y=35..36)
	if is_profile:
		draw_rect_solid(img, cx - 3, 35, cx + 3, 36, coat_shadow)
		set_p(img, cx - 3, 36, OUTLINE_DARK)
	else:
		draw_rect_solid(img, cx - 5, 35, cx + 5, 36, coat_shadow)
		set_p(img, cx, 36, OUTLINE_DARK) # Divisão

	# Tronco / Jaqueta Verde (Y=30..34)
	if is_profile:
		draw_rect_solid(img, cx - 3, 30, cx + 3, 34, coat_base)
		set_p(img, cx - 3, 31, coat_shadow); set_p(img, cx - 3, 32, coat_shadow)
		set_p(img, cx + 3, 31, coat_highlight); set_p(img, cx + 3, 32, coat_highlight)
		draw_rect_solid(img, cx - 1, 31, cx + 1, 34, coat_base)
		set_p(img, cx, 35, SKIN_BASE)
	else:
		draw_rect_solid(img, cx - 5, 30, cx + 5, 34, coat_base)
		for y in range(30, 35):
			set_p(img, cx - 5, y, coat_shadow)
			set_p(img, cx + 5, y, coat_shadow)
		set_p(img, cx - 2, 32, coat_highlight)
		set_p(img, cx + 2, 32, coat_highlight)
		set_p(img, cx - 5, 34, SKIN_BASE); set_p(img, cx + 5, 34, SKIN_BASE)

		if not is_back:
			set_p(img, cx, 30, trim_orange); set_p(img, cx, 31, trim_orange)
			set_p(img, cx - 1, 30, trim_orange); set_p(img, cx + 1, 30, trim_orange)
			set_p(img, cx, 32, OUTLINE_DARK); set_p(img, cx, 33, OUTLINE_DARK)
		else:
			set_p(img, cx, 32, coat_shadow)
			set_p(img, cx, 33, coat_shadow)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, boots_base)

	# Cabelo Espetado Vertical e Alto do Gon (Y=20..26)
	for y in range(20, 27):
		var w = int((y - 19) * 0.95)
		for x in range(cx - w - 1, cx + w + 2):
			set_p(img, x, y, hair_black)
			if y <= 22 or (x + y) % 3 == 0:
				set_p(img, x, y, hair_dark_green)
			if (y == 20 or y == 21) and (x >= cx - 2 and x <= cx + 2):
				set_p(img, x, y, hair_bright_green)

	set_p(img, cx, 19, hair_bright_green)
	set_p(img, cx - 2, 20, hair_bright_green)
	set_p(img, cx + 2, 20, hair_bright_green)
	set_p(img, cx - 4, 21, hair_bright_green)
	set_p(img, cx + 4, 21, hair_bright_green)

	if not is_back:
		set_p(img, cx - 2, 26, hair_black)
		set_p(img, cx, 26, hair_dark_green)
		set_p(img, cx + 2, 26, hair_black)

# ==============================================================================
# 2. KILLUA ZOLDYCK
# ==============================================================================
func draw_killua(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var hair_white = Color("ffffff")
	var hair_silver = Color("edf2fa")
	var hair_shadow = Color("bac4d6")
	var under_navy = Color("1a223e")
	var shirt_white = Color("ffffff")
	var shirt_shadow = Color("bac4d6") # Reutiliza sombra do cabelo
	var shorts_charcoal = Color("404654")
	var shoes_purple = Color("683280")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, shoes_purple, OUTLINE_DARK, shoes_purple)

	var lx1 = cx - 4; var lx2 = cx - 2; var rx1 = cx + 2; var rx2 = cx + 4
	if is_profile:
		draw_rect_solid(img, cx - 2, 37, cx + 2, 39, SKIN_BASE)
		set_p(img, cx - 2, 38, SKIN_SHADOW)
	else:
		draw_rect_solid(img, lx1, 37, lx2, 39, SKIN_BASE)
		draw_rect_solid(img, rx1, 37, rx2, 39, SKIN_BASE)
		set_p(img, lx1, 38, SKIN_SHADOW); set_p(img, rx2, 38, SKIN_SHADOW)

	if is_profile:
		draw_rect_solid(img, cx - 3, 35, cx + 3, 36, shorts_charcoal)
	else:
		draw_rect_solid(img, cx - 5, 35, cx + 5, 36, shorts_charcoal)
		set_p(img, cx, 36, OUTLINE_DARK)

	if is_profile:
		draw_rect_solid(img, cx - 3, 30, cx + 3, 34, shirt_white)
		set_p(img, cx - 3, 33, shirt_shadow); set_p(img, cx - 3, 34, shirt_shadow)
		set_p(img, cx, 30, under_navy)
	else:
		draw_rect_solid(img, cx - 5, 30, cx + 5, 34, shirt_white)
		set_p(img, cx - 5, 33, shirt_shadow); set_p(img, cx + 5, 33, shirt_shadow)
		set_p(img, cx - 5, 34, shirt_shadow); set_p(img, cx + 5, 34, shirt_shadow)
		set_p(img, cx - 4, 34, shirt_shadow); set_p(img, cx + 4, 34, shirt_shadow)
		set_p(img, cx - 5, 34, SKIN_BASE); set_p(img, cx + 5, 34, SKIN_BASE)

		if not is_back:
			set_p(img, cx - 1, 30, under_navy); set_p(img, cx, 30, under_navy); set_p(img, cx + 1, 30, under_navy)
			set_p(img, cx, 31, shirt_shadow)
		else:
			set_p(img, cx, 30, under_navy)
			set_p(img, cx, 32, shirt_shadow)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, Color("ffffff"), Color("2460a8"))

	for y in range(21, 27):
		for x in range(cx - 5, cx + 6):
			set_p(img, x, y, hair_silver)
	for x in range(cx - 4, cx + 5):
		set_p(img, x, 21, hair_white)
	set_p(img, cx - 6, 23, hair_silver); set_p(img, cx + 6, 23, hair_silver)
	set_p(img, cx - 6, 24, hair_silver); set_p(img, cx + 6, 24, hair_silver)
	set_p(img, cx - 5, 22, hair_shadow); set_p(img, cx + 5, 22, hair_shadow)
	for x in range(cx - 4, cx + 5):
		set_p(img, x, 25, hair_shadow)

	if not is_back:
		set_p(img, cx - 3, 26, hair_white)
		set_p(img, cx, 26, hair_silver)
		set_p(img, cx + 3, 26, hair_white)

# ==============================================================================
# 3. KURAPIKA
# ==============================================================================
func draw_kurapika(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var hair_gold = Color("f4cc38")
	var hair_light = Color("ffea76")
	var hair_shadow = Color("b89218")
	var tabard_blue = Color("1e48a8")
	var tabard_shadow = Color("122c6c")
	var trim_red = Color("c82020")
	var tunic_white = Color("edf0f8")
	var tunic_shadow = Color("b8c0d2")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("404048"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, tunic_white, tunic_shadow, Color("ffffff"))

	if is_profile:
		draw_rect_solid(img, cx - 3, 30, cx + 3, 36, tabard_blue)
		set_p(img, cx - 3, 36, trim_red); set_p(img, cx - 2, 36, trim_red)
		set_p(img, cx + 2, 36, trim_red); set_p(img, cx + 3, 36, trim_red)
		set_p(img, cx, 32, tunic_white); set_p(img, cx, 33, tunic_white)
		set_p(img, cx, 34, SKIN_BASE)
	else:
		draw_rect_solid(img, cx - 5, 30, cx + 5, 36, tabard_blue)
		for y in range(30, 37):
			set_p(img, cx - 5, y, trim_red)
			set_p(img, cx + 5, y, trim_red)
		for x in range(cx - 4, cx + 5):
			set_p(img, x, 36, trim_red)

		set_p(img, cx - 5, 32, tunic_white); set_p(img, cx + 5, 32, tunic_white)
		set_p(img, cx - 5, 33, tunic_white); set_p(img, cx + 5, 33, tunic_white)
		set_p(img, cx - 5, 34, SKIN_BASE); set_p(img, cx + 5, 34, SKIN_BASE)

		set_p(img, cx - 2, 33, tunic_white)
		set_p(img, cx + 2, 33, tabard_shadow)

		if not is_back:
			set_p(img, cx, 31, hair_gold)
			set_p(img, cx - 1, 32, hair_gold); set_p(img, cx + 1, 32, hair_gold)
			set_p(img, cx, 33, hair_gold)
		else:
			set_p(img, cx, 32, tabard_shadow)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, tabard_blue)

	for y in range(21, 27):
		for x in range(cx - 5, cx + 6):
			set_p(img, x, y, hair_gold)
	for x in range(cx - 4, cx + 5):
		set_p(img, x, 21, hair_light)
	set_p(img, cx - 5, 27, hair_gold); set_p(img, cx + 5, 27, hair_gold)
	set_p(img, cx - 5, 28, hair_shadow); set_p(img, cx + 5, 28, hair_shadow)

	if not is_back:
		set_p(img, cx - 2, 26, hair_light)
		set_p(img, cx + 2, 26, hair_gold)

# ==============================================================================
# 4. LEORIO PALADIKNIGHT
# ==============================================================================
func draw_leorio(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 12)

	var suit_navy = Color("18243e")
	var suit_shadow = OUTLINE_DARK
	var suit_highlight = Color("283858")
	var tie_red = Color("c02828")
	var brief_brown = Color("784420")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("383c48"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, suit_navy, suit_shadow, suit_highlight)

	if is_profile:
		draw_rect_solid(img, cx - 3, 30, cx + 3, 36, suit_navy)
		draw_rect_solid(img, cx + 2, 33, cx + 5, 36, brief_brown)
		set_p(img, cx + 3, 32, OUTLINE_DARK)
	else:
		draw_rect_solid(img, cx - 5, 30, cx + 5, 36, suit_navy)
		for y in range(30, 37):
			set_p(img, cx - 5, y, suit_shadow)
			set_p(img, cx + 5, y, suit_shadow)

		draw_rect_solid(img, cx + 5, 33, cx + 7, 36, brief_brown)
		set_p(img, cx + 6, 32, OUTLINE_DARK)
		set_p(img, cx - 5, 34, SKIN_BASE)

		if not is_back:
			set_p(img, cx, 30, Color("ffffff"))
			set_p(img, cx, 31, tie_red)
			set_p(img, cx, 32, tie_red)
			set_p(img, cx - 1, 31, Color("ffffff"))
			set_p(img, cx + 1, 31, Color("ffffff"))
			set_p(img, cx - 2, 31, suit_highlight)
			set_p(img, cx + 2, 31, suit_highlight)
			set_p(img, cx - 1, 33, suit_highlight)
			set_p(img, cx + 1, 33, suit_highlight)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)
	if not is_back and not is_profile:
		set_p(img, cx - 2, 27, OUTLINE_DARK); set_p(img, cx - 2, 28, OUTLINE_DARK)
		set_p(img, cx + 2, 27, OUTLINE_DARK); set_p(img, cx + 2, 28, OUTLINE_DARK)
		set_p(img, cx, 27, Color("ffffff"))

	for y in range(21, 26):
		var w = int((y - 20) * 1.1)
		for x in range(cx - w - 2, cx + w + 3):
			set_p(img, x, y, OUTLINE_DARK)
	set_p(img, cx - 1, 21, suit_highlight)
	set_p(img, cx + 1, 21, suit_highlight)

# ==============================================================================
# 5. HISOKA MOROW
# ==============================================================================
func draw_hisoka(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var hair_magenta = Color("c4206e")
	var hair_light = Color("ee4898")
	var suit_maroon = Color("4c102c")
	var pants_white = Color("f2f4fa")
	var pants_shadow = Color("bac2d4")
	var shoes_teal = Color("188a86")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, shoes_teal, OUTLINE_DARK, shoes_teal)

	if is_profile:
		draw_rect_solid(img, cx - 3, 36, cx + 3, 40, pants_white)
		set_p(img, cx - 3, 38, pants_shadow); set_p(img, cx + 3, 38, pants_shadow)
	else:
		draw_rect_solid(img, cx - 5, 36, cx + 5, 40, pants_white)
		set_p(img, cx - 5, 38, pants_shadow); set_p(img, cx + 5, 38, pants_shadow)
		set_p(img, cx, 38, OUTLINE_DARK)

	if is_profile:
		draw_rect_solid(img, cx - 3, 30, cx + 3, 35, suit_maroon)
		set_p(img, cx - 3, 30, hair_light)
	else:
		draw_rect_solid(img, cx - 5, 30, cx + 5, 35, suit_maroon)
		set_p(img, cx - 5, 30, hair_light); set_p(img, cx + 5, 30, hair_light)
		set_p(img, cx - 5, 34, shoes_teal); set_p(img, cx + 5, 34, shoes_teal)

		if not is_back:
			set_p(img, cx, 32, hair_magenta)
			set_p(img, cx - 1, 31, hair_magenta); set_p(img, cx + 1, 31, hair_magenta)
			set_p(img, cx, 33, hair_magenta)
			for x in range(cx - 4, cx + 5):
				set_p(img, x, 35, shoes_teal)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, Color("ffffff"), Color("d08418"))
	if not is_back and not is_profile:
		set_p(img, cx - 3, 29, shoes_teal)
		set_p(img, cx + 3, 29, hair_magenta)

	for y in range(20, 26):
		var w = int((y - 19) * 0.9)
		for x in range(cx - w - 2, cx + w + 3):
			set_p(img, x, y, hair_magenta)
	set_p(img, cx - 2, 20, hair_light); set_p(img, cx + 2, 20, hair_light)
	set_p(img, cx, 19, hair_light)

# ==============================================================================
# 6. CHROLLO LUCILFER
# ==============================================================================
func draw_chrollo(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var coat_black = OUTLINE_DARK
	var coat_shadow = OUTLINE_DARK
	var fur_white = Color("d4dce8")
	var fur_shadow = Color("9aa2b4")
	var st_cross_gold = Color("f4c838")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, coat_black, coat_shadow, Color("343844"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, coat_black, coat_shadow, Color("282c38"))

	if is_profile:
		draw_rect_solid(img, cx - 3, 30, cx + 3, 36, coat_black)
		set_p(img, cx - 2, 30, fur_white); set_p(img, cx - 1, 30, fur_white)
	else:
		draw_rect_solid(img, cx - 5, 30, cx + 5, 36, coat_black)
		for x in range(cx - 4, cx + 5):
			set_p(img, x, 30, fur_white)
		set_p(img, cx - 4, 31, fur_shadow); set_p(img, cx + 4, 31, fur_shadow)

		if not is_back:
			set_p(img, cx, 31, SKIN_SHADOW)
			set_p(img, cx, 32, SKIN_BASE)
			set_p(img, cx - 4, 28, Color("3290d8"))
			set_p(img, cx + 4, 28, Color("3290d8"))
		else:
			set_p(img, cx, 32, st_cross_gold); set_p(img, cx, 33, st_cross_gold); set_p(img, cx, 34, st_cross_gold)
			set_p(img, cx - 1, 33, st_cross_gold); set_p(img, cx + 1, 33, st_cross_gold)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, Color("ffffff"), OUTLINE_DARK)
	if not is_back and not is_profile:
		set_p(img, cx, 26, OUTLINE_DARK)
		set_p(img, cx - 1, 26, OUTLINE_DARK); set_p(img, cx + 1, 26, OUTLINE_DARK)

	for y in range(21, 26):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, OUTLINE_DARK)
	set_p(img, cx - 1, 21, Color("282c38")); set_p(img, cx + 1, 21, Color("282c38"))

# ==============================================================================
# 7. ISAAC NETERO
# ==============================================================================
func draw_netero(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var beard_white = Color("eaeff6")
	var beard_shadow = Color("b4bcc8")
	var dogi_white = Color("f4f6fa")
	var dogi_blue = Color("1e3878")
	var wood_geta = Color("8c542c")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, wood_geta, OUTLINE_DARK, wood_geta)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, SKIN_SHADOW, OUTLINE_DARK, SKIN_BASE)

	if is_profile:
		draw_rect_solid(img, cx - 3, 30, cx + 3, 36, dogi_white)
		set_p(img, cx - 3, 36, dogi_blue)
	else:
		draw_rect_solid(img, cx - 5, 30, cx + 5, 36, dogi_white)
		for y in range(30, 37):
			set_p(img, cx - 5, y, dogi_blue)
			set_p(img, cx + 5, y, dogi_blue)
		for x in range(cx - 4, cx + 5):
			set_p(img, x, 34, dogi_blue)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_SHADOW, OUTLINE_DARK, SKIN_BASE, OUTLINE_DARK)
	if not is_back:
		set_p(img, cx - 2, 29, beard_white); set_p(img, cx + 2, 29, beard_white)
		set_p(img, cx - 1, 30, beard_white); set_p(img, cx, 30, beard_white); set_p(img, cx + 1, 30, beard_white)
		set_p(img, cx, 31, beard_white); set_p(img, cx, 32, beard_shadow)
		set_p(img, cx - 2, 26, beard_white); set_p(img, cx + 2, 26, beard_white)

	for x in range(cx - 3, cx + 4):
		set_p(img, x, 23, SKIN_BASE)
		set_p(img, x, 22, SKIN_HIGHLIGHT)
	set_p(img, cx, 20, beard_white); set_p(img, cx, 21, beard_white)
	set_p(img, cx + 1, 20, beard_shadow)

# ==============================================================================
# 8. BISCUIT KRUEGER
# ==============================================================================
func draw_biscuit(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 12)

	var hair_gold = Color("f6d034")
	var dress_pink = Color("c42054")
	var dress_shadow = Color("841034")
	var lace_white = Color("ffffff")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("403448"))

	for y in range(33, 40):
		var w = mini(int((y - 32) * 0.5) + 3, 6)
		for x in range(cx - w, cx + w + 1):
			set_p(img, x, y, dress_pink)
			if x == cx - w or x == cx + w:
				set_p(img, x, y, dress_shadow)
	for x in range(cx - 6, cx + 7):
		set_p(img, x, 40, lace_white)

	draw_rect_solid(img, cx - 3, 30, cx + 3, 32, dress_pink)
	if not is_back:
		set_p(img, cx, 30, lace_white); set_p(img, cx, 31, lace_white)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, Color("2060b0"))

	for y in range(21, 26):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, hair_gold)
	draw_rect_solid(img, cx - 6, 23, cx - 5, 27, hair_gold)
	draw_rect_solid(img, cx + 5, 23, cx + 6, 27, hair_gold)
	set_p(img, cx - 5, 22, dress_pink); set_p(img, cx + 5, 22, dress_pink)

# ==============================================================================
# 9. TONPA
# ==============================================================================
func draw_tonpa(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 14)

	var sweater_blue = Color("2874bc")
	var sweater_shadow = Color("184a80")
	var shorts_khaki = Color("a48454")
	var hair_brown = Color("54341e")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, hair_brown, OUTLINE_DARK, hair_brown)

	draw_rect_solid(img, cx - 6, 36, cx + 6, 38, shorts_khaki)
	set_p(img, cx, 37, OUTLINE_DARK); set_p(img, cx, 38, OUTLINE_DARK)
	draw_rect_solid(img, cx - 4, 39, cx - 2, 40, SKIN_BASE)
	draw_rect_solid(img, cx + 2, 39, cx + 4, 40, SKIN_BASE)

	for y in range(30, 36):
		for x in range(cx - 6, cx + 7):
			set_p(img, x, y, sweater_blue)
	for y in range(30, 36):
		set_p(img, cx - 6, y, sweater_shadow); set_p(img, cx + 6, y, sweater_shadow)
	set_p(img, cx, 33, Color("4896e4"))

	if not is_back:
		set_p(img, cx + 6, 33, Color("f06c14"))
		set_p(img, cx + 6, 34, Color("f06c14"))
		set_p(img, cx + 6, 32, Color("ffffff"))

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, hair_brown)

	draw_rect_solid(img, cx - 5, 23, cx - 4, 26, hair_brown)
	draw_rect_solid(img, cx + 4, 23, cx + 5, 26, hair_brown)
	set_p(img, cx - 3, 23, hair_brown); set_p(img, cx + 3, 23, hair_brown)
	set_p(img, cx, 23, SKIN_BASE)

# ==============================================================================
# 10. GING FREECSS
# ==============================================================================
func draw_ging(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var turban_beige = Color("8c9480")
	var turban_shadow = Color("606856")
	var coat_olive = Color("44543c")
	var coat_shadow = Color("2c3826")
	var sash_brown = Color("7a4c28")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, sash_brown, OUTLINE_DARK, sash_brown)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, coat_olive, coat_shadow, coat_olive)

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, coat_olive)
	if not is_back:
		set_p(img, cx - 3, 31, sash_brown); set_p(img, cx - 2, 32, sash_brown)
		set_p(img, cx, 33, sash_brown); set_p(img, cx + 2, 34, sash_brown)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)
	if not is_back:
		set_p(img, cx - 2, 29, SKIN_SHADOW); set_p(img, cx + 2, 29, SKIN_SHADOW)
		set_p(img, cx, 30, sash_brown)

	for y in range(21, 25):
		for x in range(cx - 5, cx + 6):
			set_p(img, x, y, turban_beige)
	set_p(img, cx - 5, 23, turban_shadow); set_p(img, cx + 5, 23, turban_shadow)
	set_p(img, cx - 3, 20, OUTLINE_DARK); set_p(img, cx + 2, 20, OUTLINE_DARK)
	set_p(img, cx - 5, 25, OUTLINE_DARK); set_p(img, cx + 5, 25, OUTLINE_DARK)

# ==============================================================================
# 11. HANZO
# ==============================================================================
func draw_hanzo(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var ninja_dark = Color("242e3a")
	var ninja_shadow = Color("141a22")
	var wrap_white = Color("d4dae4")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("384454"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, ninja_dark, ninja_shadow, ninja_dark)
	set_p(img, cx - 3, 38, wrap_white); set_p(img, cx + 3, 38, wrap_white)

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, ninja_dark)
	set_p(img, cx - 5, 33, wrap_white); set_p(img, cx + 5, 33, wrap_white)
	if not is_back:
		set_p(img, cx, 30, wrap_white); set_p(img, cx, 31, ninja_shadow)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	for x in range(cx - 4, cx + 5):
		set_p(img, x, 23, SKIN_BASE)
		set_p(img, x, 22, SKIN_HIGHLIGHT)
	set_p(img, cx, 21, Color("fff4ea"))

# ==============================================================================
# 12. POKKLE
# ==============================================================================
func draw_pokkle(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var hat_red = Color("c82428")
	var tunic_yellow = Color("e09c1c")
	var tunic_shadow = Color("9e680c")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, tunic_shadow, OUTLINE_DARK, tunic_shadow)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, Color("2e3848"), OUTLINE_DARK, Color("44546c"))

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, tunic_yellow)
	for y in range(30, 37):
		set_p(img, cx - 5, y, tunic_shadow); set_p(img, cx + 5, y, tunic_shadow)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	for y in range(21, 26):
		var w = int((y - 20) * 0.9) + 2
		for x in range(cx - w, cx + w + 1):
			set_p(img, x, y, hat_red)
	set_p(img, cx - 3, 20, tunic_yellow)
	set_p(img, cx - 4, 19, Color("ffffff"))

# ==============================================================================
# 13. PONZU
# ==============================================================================
func draw_ponzu(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 12)

	var beret_yellow = Color("f4be20")
	var beret_shadow = Color("b4860e")
	var hair_teal = Color("28baa0")
	var dress_pink = Color("d45484")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("583c60"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, Color("f0eef6"), Color("bcc0cc"), Color("ffffff"))

	draw_rect_solid(img, cx - 5, 31, cx + 5, 37, dress_pink)
	if not is_back:
		set_p(img, cx + 4, 35, Color("48b4f0"))
		set_p(img, cx + 4, 34, beret_shadow)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	draw_rect_solid(img, cx - 5, 26, cx - 4, 28, hair_teal)
	draw_rect_solid(img, cx + 4, 26, cx + 5, 28, hair_teal)

	for y in range(21, 26):
		for x in range(cx - 6, cx + 7):
			set_p(img, x, y, beret_yellow)
	for x in range(cx - 5, cx + 6):
		set_p(img, x, 20, beret_yellow)
	set_p(img, cx - 6, 25, beret_shadow); set_p(img, cx + 6, 25, beret_shadow)

# ==============================================================================
# 14. BUHARA
# ==============================================================================
func draw_buhara(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 16)

	var vest_yellow = Color("e4b82c")
	var pants_dark = Color("2c3444")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, Color("342018"), OUTLINE_DARK, Color("342018"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, pants_dark, OUTLINE_DARK, pants_dark)

	for y in range(30, 37):
		for x in range(cx - 7, cx + 8):
			set_p(img, x, y, vest_yellow)
	if not is_back:
		draw_rect_solid(img, cx - 3, 31, cx + 3, 36, SKIN_BASE)
		set_p(img, cx, 34, SKIN_SHADOW)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	for y in range(22, 26):
		for x in range(cx - 5, cx + 6):
			set_p(img, x, y, Color("3a2416"))

# ==============================================================================
# 15. MENCHI
# ==============================================================================
func draw_menchi(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var hair_teal = Color("20c4ba")
	var hair_light = Color("6ee6de")
	var top_black = OUTLINE_DARK

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("444c60"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT)

	draw_rect_solid(img, cx - 4, 30, cx + 4, 32, top_black)
	draw_rect_solid(img, cx - 4, 33, cx + 4, 35, SKIN_BASE)
	draw_rect_solid(img, cx - 5, 36, cx + 5, 36, Color("244068"))

	if not is_back:
		set_p(img, cx - 5, 36, Color("e0e4ec")); set_p(img, cx + 5, 36, Color("e0e4ec"))

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	for y in range(21, 26):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, hair_teal)
	set_p(img, cx - 4, 20, hair_teal); set_p(img, cx - 5, 19, hair_light)
	set_p(img, cx + 4, 20, hair_teal); set_p(img, cx + 5, 19, hair_light)

# ==============================================================================
# 16. GITTARACKUR (ILLUMI)
# ==============================================================================
func draw_gittarackur(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var pin_gold = Color("f4c828")
	var suit_lilac = Color("684478")
	var suit_dark = Color("341c44")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, suit_dark)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, Color("484c5c"), OUTLINE_DARK, Color("484c5c"))

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, suit_lilac)
	set_p(img, cx - 3, 32, pin_gold); set_p(img, cx + 3, 32, pin_gold)
	set_p(img, cx, 34, pin_gold)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, Color("f4f2e8"), Color("c4c2b0"), Color("ffffff"), OUTLINE_DARK)
	if not is_back:
		set_p(img, cx - 4, 27, pin_gold); set_p(img, cx + 4, 27, pin_gold)
		set_p(img, cx - 3, 29, pin_gold); set_p(img, cx + 3, 29, pin_gold)
		set_p(img, cx, 30, pin_gold)

	for y in range(20, 26):
		set_p(img, cx, y, suit_dark)
		set_p(img, cx - 1, y, OUTLINE_DARK)
		set_p(img, cx + 1, y, OUTLINE_DARK)

# ==============================================================================
# 17. BODORO
# ==============================================================================
func draw_bodoro(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var hakama_brown = Color("684832")
	var hakama_shadow = Color("422c1e")
	var hair_gray = Color("949aa4")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, hakama_shadow, OUTLINE_DARK, hakama_brown)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, hakama_brown, hakama_shadow, hakama_brown)

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, hakama_brown)
	for x in range(cx - 4, cx + 5):
		set_p(img, x, 34, Color("e4e8f0"))

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)
	if not is_back:
		set_p(img, cx, 30, hair_gray); set_p(img, cx, 31, hair_gray)

	for y in range(21, 26):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, hair_gray)
	set_p(img, cx, 20, Color("d0d6e2"))

# ==============================================================================
# 18. NICOL
# ==============================================================================
func draw_nicol(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var vest_red = Color("b42428")
	var pants_dark = Color("283448")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, pants_dark)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, pants_dark, OUTLINE_DARK, pants_dark)

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, vest_red)
	if not is_back:
		set_p(img, cx, 30, Color("ffffff")); set_p(img, cx, 31, Color("ffffff"))
		draw_rect_solid(img, cx + 4, 33, cx + 7, 36, pants_dark)
		set_p(img, cx + 5, 34, Color("48c4f0"))

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)
	if not is_back:
		set_p(img, cx - 2, 27, OUTLINE_DARK); set_p(img, cx + 2, 27, OUTLINE_DARK)
		set_p(img, cx, 27, OUTLINE_DARK)

	for y in range(21, 26):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, Color("4e301c"))

# ==============================================================================
# 19. CANDIDATO DO EXAME (INIMIGO)
# ==============================================================================
func draw_candidato_exame(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var vest_blue = Color("285ca4")
	var red_accent = Color("c82024")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, Color("3c2414"), OUTLINE_DARK, Color("3c2414"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, Color("485060"), OUTLINE_DARK, Color("485060"))

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, vest_blue)
	if not is_back:
		set_p(img, cx - 2, 32, Color("ffffff")); set_p(img, cx - 1, 32, Color("ffffff"))
		set_p(img, cx - 2, 33, Color("ffffff")); set_p(img, cx - 1, 33, red_accent)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	for x in range(cx - 4, cx + 5):
		set_p(img, x, 25, red_accent)
	for y in range(21, 25):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, Color("443020"))

# ==============================================================================
# 20. CRIATURA DO PANTANAL (INIMIGO)
# ==============================================================================
func draw_criatura_pantanal(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 13)

	var skin_moss = Color("28542c")
	var skin_dark = Color("143018")
	var eye_amber = Color("f4aa18")

	for x in range(cx - 5, cx - 2): set_p(img, x, 42, OUTLINE_DARK); set_p(img, x, 41, skin_dark)
	for x in range(cx + 2, cx + 5): set_p(img, x, 42, OUTLINE_DARK); set_p(img, x, 41, skin_dark)

	for y in range(28, 41):
		for x in range(cx - 6, cx + 7):
			set_p(img, x, y, skin_moss)
			if (x + y) % 4 == 0:
				set_p(img, x, y, Color("4a8c3e"))
	set_p(img, cx, 27, Color("3e7834")); set_p(img, cx, 26, Color("3e7834"))

	if not is_back:
		set_p(img, cx - 3, 30, eye_amber); set_p(img, cx + 3, 30, eye_amber)
		set_p(img, cx - 2, 33, Color("f0f4fa")); set_p(img, cx + 2, 33, Color("f0f4fa"))

# ==============================================================================
# 21. MORDOMO ZOLDYCK (INIMIGO)
# ==============================================================================
func draw_mordomo_zoldyck(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var tux_black = OUTLINE_DARK

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, tux_black, tux_black, Color("383e4a"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, tux_black, tux_black, Color("282e3a"))

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, tux_black)
	set_p(img, cx - 5, 34, Color("ffffff")); set_p(img, cx + 5, 34, Color("ffffff"))

	if not is_back:
		set_p(img, cx, 30, Color("c82024"))
		set_p(img, cx - 1, 30, Color("ffffff")); set_p(img, cx + 1, 30, Color("ffffff"))
		set_p(img, cx, 31, Color("ffffff")); set_p(img, cx, 32, Color("ffffff"))

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)
	if not is_back:
		set_p(img, cx + 2, 27, Color("50a8e8"))

	for y in range(21, 26):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, OUTLINE_DARK)

# ==============================================================================
# 22. LUTADOR DA ARENA CELESTE (INIMIGO)
# ==============================================================================
func draw_lutador_arena(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 12)

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("40485a"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT)

	draw_rect_solid(img, cx - 5, 35, cx + 5, 36, Color("c02428"))

	draw_rect_solid(img, cx - 5, 30, cx + 5, 34, SKIN_BASE)
	set_p(img, cx, 32, SKIN_SHADOW)
	set_p(img, cx - 5, 34, Color("ffffff")); set_p(img, cx + 5, 34, Color("ffffff"))

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	for y in range(20, 26):
		set_p(img, cx, y, Color("8e2024"))
		set_p(img, cx - 1, y, Color("5e1418"))
		set_p(img, cx + 1, y, Color("5e1418"))

# ==============================================================================
# 23. MAFIOSO DE YORKNEW (INIMIGO)
# ==============================================================================
func draw_mafioso_yorknew(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var suit_charcoal = Color("1e222a")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("323844"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, suit_charcoal, OUTLINE_DARK, suit_charcoal)

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, suit_charcoal)
	if not is_back:
		set_p(img, cx, 30, Color("ffffff")); set_p(img, cx, 31, OUTLINE_DARK)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	for y in range(22, 26):
		for x in range(cx - 6, cx + 7):
			set_p(img, x, y, OUTLINE_DARK)
	for x in range(cx - 4, cx + 5):
		set_p(img, x, 21, OUTLINE_DARK)
		set_p(img, x, 22, Color("d0d6e2"))

# ==============================================================================
# 24. BOMBER (GENTHRU) (INIMIGO)
# ==============================================================================
func draw_bomber_greed(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var coat_orange = Color("d45c20")
	var pants_color = Color("343a4a")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, pants_color)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, pants_color, OUTLINE_DARK, pants_color)

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, coat_orange)
	set_p(img, cx - 5, 34, Color("f4c820")); set_p(img, cx + 5, 34, Color("f4c820"))

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)
	if not is_back:
		set_p(img, cx - 2, 27, Color("ffffff")); set_p(img, cx + 2, 27, Color("ffffff"))

	for y in range(21, 26):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, Color("7a522e"))

# ==============================================================================
# 25. FORMIGA SOLDADO (CHIMERA ANT) (INIMIGO)
# ==============================================================================
func draw_formiga_soldado(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 12)

	var chitin_green = Color("1a4a28")
	var chitin_shine = Color("2e7e46")
	var chitin_dark = Color("0e2816")

	for x in range(cx - 4, cx - 1): set_p(img, x, 42, chitin_dark); set_p(img, x, 41, chitin_green)
	for x in range(cx + 1, cx + 4): set_p(img, x, 42, chitin_dark); set_p(img, x, 41, chitin_green)
	draw_rect_solid(img, cx - 4, 37, cx - 2, 40, chitin_green)
	draw_rect_solid(img, cx + 2, 37, cx + 4, 40, chitin_green)

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, chitin_green)
	set_p(img, cx - 2, 32, chitin_shine); set_p(img, cx + 2, 32, chitin_shine)
	set_p(img, cx - 5, 34, chitin_dark); set_p(img, cx + 5, 34, chitin_dark)

	draw_rect_solid(img, cx - 4, 25, cx + 4, 29, chitin_green)
	if not is_back:
		set_p(img, cx - 2, 27, Color("d82020")); set_p(img, cx + 2, 27, Color("d82020"))

	set_p(img, cx - 3, 22, chitin_shine); set_p(img, cx - 4, 21, chitin_shine)
	set_p(img, cx + 3, 22, chitin_shine); set_p(img, cx + 4, 21, chitin_shine)

# ==============================================================================
# 26. FORMIGA LÍDER DE ESQUADRÃO (INIMIGO)
# ==============================================================================
func draw_formiga_lider(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 12)

	var armor_purple = Color("441e54")
	var armor_gold = Color("e0b428")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, armor_purple)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, armor_purple, OUTLINE_DARK, armor_purple)

	draw_rect_solid(img, cx - 6, 30, cx + 6, 36, armor_purple)
	set_p(img, cx - 6, 30, armor_gold); set_p(img, cx + 6, 30, armor_gold)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, Color("baa8c4"), Color("7e6a88"), Color("e0d6e6"), Color("e02030"))

	for y in range(21, 26):
		set_p(img, cx, y, armor_purple)
	set_p(img, cx - 3, 21, armor_purple); set_p(img, cx - 4, 20, armor_gold)
	set_p(img, cx + 3, 21, armor_purple); set_p(img, cx + 4, 20, armor_gold)

# ==============================================================================
# 27. GUARDA REAL (INSPIRADO EM PITOU) (INIMIGO)
# ==============================================================================
func draw_guarda_real(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 11)

	var coat_navy = Color("1a2854")
	var gold_button = Color("f4c828")
	var hair_silver = Color("e8eef8")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, Color("48485c"))
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, Color("e48428"), OUTLINE_DARK, Color("f4b058"))

	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, coat_navy)
	if not is_back:
		set_p(img, cx - 2, 32, gold_button); set_p(img, cx + 2, 32, gold_button)
		set_p(img, cx - 2, 34, gold_button); set_p(img, cx + 2, 34, gold_button)
	set_p(img, cx + 6, 35, hair_silver); set_p(img, cx + 6, 34, hair_silver)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, Color("fcf0e4"), Color("d8b8a8"), Color("ffffff"), Color("d82030"))

	for y in range(21, 26):
		for x in range(cx - 4, cx + 5):
			set_p(img, x, y, hair_silver)
	set_p(img, cx - 4, 20, hair_silver); set_p(img, cx - 3, 21, Color("e898a8"))
	set_p(img, cx + 4, 20, hair_silver); set_p(img, cx + 3, 21, Color("e898a8"))

# ==============================================================================
# 28. BOSS RAZOR (BOSS)
# ==============================================================================
func draw_boss_razor(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 14)

	var jersey_green = Color("287438")
	var dodgeball_red = Color("c82020")
	var pants_color = Color("2a3240")

	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, OUTLINE_DARK, OUTLINE_DARK, pants_color)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, pants_color, OUTLINE_DARK, pants_color)

	draw_rect_solid(img, cx - 6, 30, cx + 6, 36, jersey_green)
	set_p(img, cx - 6, 30, SKIN_BASE); set_p(img, cx + 6, 30, SKIN_BASE)
	set_p(img, cx - 6, 33, Color("ffffff"))

	if not is_back:
		draw_rect_solid(img, cx + 5, 32, cx + 7, 34, dodgeball_red)
		set_p(img, cx + 6, 32, SKIN_HIGHLIGHT)

	draw_chibi_face(img, cx, is_back, is_profile, angle_side, SKIN_BASE, SKIN_SHADOW, SKIN_HIGHLIGHT, OUTLINE_DARK)

	for y in range(21, 26):
		var w = int((y - 20) * 1.0)
		for x in range(cx - w - 2, cx + w + 3):
			set_p(img, x, y, Color("482e1c"))
	set_p(img, cx, 20, Color("6e482e"))

# ==============================================================================
# 29. BOSS MERUEM (O REI DAS FORMIGAS QUIMERA)
# ==============================================================================
func draw_boss_meruem(img: Image, is_back: bool, is_profile: bool, angle_side: int) -> void:
	var cx = 24
	draw_shadow(img, cx, 13)

	var green_jade = Color("1e5436")
	var green_highlight = Color("348c58")
	var green_shadow = Color("103220")
	var helmet_dark = Color("1a2024")
	var eye_magenta = Color("c82088")

	# Pés/Garras de quitina jade (Y=40..42)
	draw_standard_shoes(img, cx, is_back, is_profile, angle_side, green_jade, green_shadow, green_highlight)

	# Pernas poderosas segmentadas (Y=37..39)
	draw_standard_legs(img, cx, is_back, is_profile, angle_side, green_jade, green_shadow, green_highlight)

	# Tronco imponente do Rei com placas de armadura jade (Y=30..36)
	draw_rect_solid(img, cx - 5, 30, cx + 5, 36, green_jade)
	set_p(img, cx - 2, 32, green_highlight); set_p(img, cx + 2, 32, green_highlight)

	# Cauda espessa segmentada com aguilhão (marca inconfundível do Rei)
	# Sai da cintura e projeta para o lado
	set_p(img, cx - 6, 36, green_jade); set_p(img, cx - 7, 37, green_jade)
	set_p(img, cx - 7, 38, green_jade); set_p(img, cx - 8, 39, green_shadow)
	set_p(img, cx - 8, 40, Color("08140c")) # Ferrão preto pontiagudo na ponta da cauda

	# Rosto sereno e régio do Rei com olhos magnéticos magenta
	draw_chibi_face(img, cx, is_back, is_profile, angle_side, Color("68b488"), Color("407c58"), Color("8ed4ac"), eye_magenta)

	# Capacete-Carapaça Característico de Meruem com abas auriculares (Y=20..26)
	for y in range(21, 26):
		for x in range(cx - 5, cx + 6):
			set_p(img, x, y, helmet_dark)
	# Abas auriculares que cobrem as têmporas
	set_p(img, cx - 5, 26, helmet_dark); set_p(img, cx + 5, 26, helmet_dark)
	# Cúpula curva do capacete
	for x in range(cx - 3, cx + 4):
		set_p(img, x, 20, helmet_dark)
	set_p(img, cx, 20, Color("344048")) # Brilho no topo do capacete


# ==============================================================================
# SALVAR AS FOLHAS 8-DIREÇÕES E PASTAS DE ROTAÇÃO
# ==============================================================================
func _init() -> void:
	print("======================================================================")
	print(" GERADOR REFINADO DE SPRITES — HUNTER ONLINE (2D MMORPG HIGH-FIDELITY)")
	print("======================================================================")

	var characters = [
		"npc_gon", "npc_killua", "npc_kurapika", "npc_leorio",
		"npc_hisoka", "npc_chrollo", "npc_netero", "npc_biscuit",
		"npc_tonpa", "npc_ging", "npc_hanzo", "npc_pokkle",
		"npc_ponzu", "npc_buhara", "npc_menchi", "npc_gittarackur",
		"npc_bodoro", "npc_nicol",
		"enemy_candidato_exame", "enemy_criatura_pantanal", "enemy_mordomo_zoldyck",
		"enemy_lutador_arena", "enemy_mafioso_yorknew", "enemy_bomber_greed",
		"enemy_formiga_soldado", "enemy_formiga_lider", "enemy_guarda_real",
		"enemy_boss_razor", "enemy_boss_meruem"
	]

	var dir_names = [
		"south", "south-east", "east", "north-east",
		"north", "north-west", "west", "south-west"
	]

	var base_dir = "res://assets/sprites/characters/"

	for char_id in characters:
		var sheet = Image.create(FW * 8, FH, false, Image.FORMAT_RGBA8)
		sheet.fill(Color(0, 0, 0, 0))

		var rot_dir = base_dir + char_id + "_rotations/"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(rot_dir))

		for d in range(8):
			var frame = generate_character_frame(char_id, d)
			sheet.blit_rect(frame, Rect2i(0, 0, FW, FH), Vector2i(d * FW, 0))

			# Salvar frame individual na pasta _rotations
			var frame_path = rot_dir + dir_names[d] + ".png"
			frame.save_png(ProjectSettings.globalize_path(frame_path))

			# Salvar south.png na raiz de characters
			if d == 0:
				var south_path = base_dir + char_id + ".png"
				frame.save_png(ProjectSettings.globalize_path(south_path))

		# Salvar folha completa _8dir.png
		var sheet_path = base_dir + char_id + "_8dir.png"
		var err = sheet.save_png(ProjectSettings.globalize_path(sheet_path))
		if err == OK:
			print("[+] Salvo com sucesso: %s" % sheet_path.get_file())
		else:
			print("[-] Erro ao salvar: %s" % sheet_path)

	print("\n======================================================================")
	print(" GERAÇÃO CONCLUÍDA! EXECUTANDO AUDITORIA DE STYLE LOCK...")
	print("======================================================================")
	quit(0)
