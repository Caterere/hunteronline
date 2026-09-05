class_name CharacterVisualDatabase
extends RefCounted

# ============================================================
# HUNTER ONLINE — CANONICAL CHARACTER VISUAL DATABASE
# ============================================================
#
# Centraliza a identidade visual, paletas de cores, insígnias,
# frases icônicas e geração de retratos pixel-art para os
# 10 personagens centrais canônicos de Hunter x Hunter.
#
# ============================================================

static var _portrait_cache: Dictionary = {}

const CHARACTERS: Dictionary = {
	"gon": {
		"id": "gon",
		"nome": "Gon Freecss",
		"titulo": "O Menino da Ilha da Baleia",
		"afinidade": "Intensificação",
		"frase_iconica": "Primeiro vem a pedra... Jajanken!",
		"cor_aura": Color(1.0, 0.65, 0.1, 1.0), # Âmbar/Laranja vivo
		"cor_primaria": Color(0.18, 0.65, 0.22, 1.0), # Verde jaqueta
		"cor_secundaria": Color(0.85, 0.45, 0.1, 1.0), # Laranja botas/detalhes
		"cor_pele": Color(0.96, 0.78, 0.62, 1.0),
		"cor_cabelo": Color(0.1, 0.1, 0.1, 1.0), # Preto espetado com pontas esverdeadas
		"cor_cabelo_destaque": Color(0.15, 0.45, 0.2, 1.0),
		"estilo_cabelo": "spiky_vertical",
		"tracos_faciais": ["olhos_castanhos_amplos", "expressao_determinada"],
		"vestimenta": "jaqueta_verde_e_shorts",
		"acessorios": ["vara_de_pescar", "mochila_viagem"]
	},
	"killua": {
		"id": "killua",
		"nome": "Killua Zoldyck",
		"titulo": "Herdeiro da Família Zoldyck",
		"afinidade": "Transformação",
		"frase_iconica": "Não se mexa. Se você der um passo, eu arranco seu coração.",
		"cor_aura": Color(0.3, 0.75, 1.0, 1.0), # Azul elétrico / relâmpago
		"cor_primaria": Color(0.2, 0.25, 0.45, 1.0), # Azul meia-noite / gola alta
		"cor_secundaria": Color(0.9, 0.9, 0.95, 1.0), # Branco camiseta
		"cor_pele": Color(0.98, 0.85, 0.8, 1.0), # Pele pálida Zoldyck
		"cor_cabelo": Color(0.92, 0.92, 0.96, 1.0), # Cabelo prateado ondulado
		"cor_cabelo_destaque": Color(0.75, 0.8, 0.95, 1.0),
		"estilo_cabelo": "spiky_fluffy_silver",
		"tracos_faciais": ["olhos_azuis_felinos", "olhar_assassino_oculto"],
		"vestimenta": "gola_alta_azul_shorts",
		"acessorios": ["ioio_nen_50kg", "skate_amarelo"]
	},
	"kurapika": {
		"id": "kurapika",
		"nome": "Kurapika",
		"titulo": "Último Sobrevivente do Clã Kurta",
		"afinidade": "Conjurador / Especialista (Olhos Escarlates)",
		"frase_iconica": "A morte não me amedronta. O que temo é que minha raiva se apague com o tempo.",
		"cor_aura": Color(0.85, 0.2, 0.25, 1.0), # Vermelho Escarlate / Dourado
		"cor_primaria": Color(0.15, 0.35, 0.7, 1.0), # Azul túnica Kurta
		"cor_secundaria": Color(0.95, 0.8, 0.2, 1.0), # Dourado bordas
		"cor_pele": Color(0.96, 0.82, 0.72, 1.0),
		"cor_cabelo": Color(0.95, 0.82, 0.3, 1.0), # Loiro médio elegante
		"cor_cabelo_destaque": Color(1.0, 0.92, 0.55, 1.0),
		"estilo_cabelo": "blonde_bob_bangs",
		"tracos_faciais": ["olhos_escarlates_brilhantes", "expressao_solene"],
		"vestimenta": "tabardo_kurta_tradicional",
		"acessorios": ["correntes_cinco_dedos", "brinco_rubi"]
	},
	"leorio": {
		"id": "leorio",
		"nome": "Leorio Paradinight",
		"titulo": "O Médico de Coração Nobre",
		"afinidade": "Emissão",
		"frase_iconica": "Eu quero ser médico! E dinheiro compra vidas onde eu venho!",
		"cor_aura": Color(0.95, 0.6, 0.2, 1.0), # Âmbar caloroso
		"cor_primaria": Color(0.12, 0.16, 0.3, 1.0), # Terno azul marinho
		"cor_secundaria": Color(0.85, 0.2, 0.25, 1.0), # Gravata vermelha
		"cor_pele": Color(0.94, 0.76, 0.6, 1.0),
		"cor_cabelo": Color(0.12, 0.1, 0.1, 1.0), # Preto cortado curto militar
		"cor_cabelo_destaque": Color(0.25, 0.22, 0.2, 1.0),
		"estilo_cabelo": "short_crop_sideburns",
		"tracos_faciais": ["oculos_escuros_redondos", "cavanhaque_sutil"],
		"vestimenta": "terno_formal_duas_pecas",
		"acessorios": ["maleta_medica_couro", "canivete_cirurgico"]
	},
	"hisoka": {
		"id": "hisoka",
		"nome": "Hisoka Morow",
		"titulo": "O Mágico Ceifador",
		"afinidade": "Transformação",
		"frase_iconica": "Minha aura possui as propriedades da borracha e do chiclete. Bungee Gum!",
		"cor_aura": Color(0.92, 0.2, 0.65, 1.0), # Rosa Bungee Gum / Magenta
		"cor_primaria": Color(0.88, 0.3, 0.6, 1.0), # Magenta baralho
		"cor_secundaria": Color(0.15, 0.75, 0.75, 1.0), # Ciano detalhes naipes
		"cor_pele": Color(0.97, 0.88, 0.82, 1.0), # Tez de palhaço pálida
		"cor_cabelo": Color(0.85, 0.2, 0.45, 1.0), # Vermelho magenta penteado para cima
		"cor_cabelo_destaque": Color(1.0, 0.45, 0.7, 1.0),
		"estilo_cabelo": "slicked_back_horns",
		"tracos_faciais": ["estrela_marrom_rosto", "lagrima_azul_rosto", "sorriso_cinico"],
		"vestimenta": "traje_bobocorte_naipes",
		"acessorios": ["cartas_nen_afiadas", "bungee_gum_tether"]
	},
	"biscuit": {
		"id": "biscuit",
		"nome": "Biscuit Krueger",
		"titulo": "Mestra Estrela Dupla de Shingen-ryu",
		"afinidade": "Transformação",
		"frase_iconica": "Não me julgue pelo meu visual de garotinha... Tenho 57 anos e vou moer você!",
		"cor_aura": Color(0.3, 0.65, 1.0, 1.0), # Safira límpida
		"cor_primaria": Color(0.9, 0.35, 0.5, 1.0), # Vestido rosa boneca
		"cor_secundaria": Color(0.98, 0.98, 0.98, 1.0), # Babados brancos
		"cor_pele": Color(0.97, 0.84, 0.75, 1.0),
		"cor_cabelo": Color(0.98, 0.85, 0.35, 1.0), # Loiro ouro em duas tranças
		"cor_cabelo_destaque": Color(1.0, 0.95, 0.6, 1.0),
		"estilo_cabelo": "twin_pigtails_ribbons",
		"tracos_faciais": ["olhos_azuis_grandes", "expressao_autoritaria"],
		"vestimenta": "vestido_vitoriano_rosa",
		"acessorios": ["lacre_shingen_ryu", "locao_magica_piano"]
	},
	"wing": {
		"id": "wing",
		"nome": "Wing",
		"titulo": "Mestre Dedicado de Nen",
		"afinidade": "Intensificação",
		"frase_iconica": "O Nen reflete a mente. Não se apresse em alcançar o fruto antes de regar as raízes.",
		"cor_aura": Color(0.7, 0.85, 1.0, 1.0), # Azul suave e calmo
		"cor_primaria": Color(0.95, 0.95, 0.95, 1.0), # Camisa branca desleixada
		"cor_secundaria": Color(0.25, 0.3, 0.35, 1.0), # Calça grafite
		"cor_pele": Color(0.95, 0.8, 0.68, 1.0),
		"cor_cabelo": Color(0.15, 0.15, 0.15, 1.0), # Cabelo bagunçado preto
		"cor_cabelo_destaque": Color(0.3, 0.3, 0.3, 1.0),
		"estilo_cabelo": "messy_uncombed_black",
		"tracos_faciais": ["oculos_tortos", "olhar_afetuoso_rigido"],
		"vestimenta": "camisa_fora_da_calca",
		"acessorios": ["livro_principios_nen", "fita_iniciacao_dedo"]
	},
	"razor": {
		"id": "razor",
		"nome": "Razor",
		"titulo": "Game Master & Carrasco de Greed Island",
		"afinidade": "Emissão",
		"frase_iconica": "Não segure nada. Eu recebo tudo o que vocês têm!",
		"cor_aura": Color(0.9, 0.15, 0.15, 1.0), # Vermelho canhão intenso
		"cor_primaria": Color(0.6, 0.12, 0.12, 1.0), # Regata vinho carmesim
		"cor_secundaria": Color(0.85, 0.85, 0.85, 1.0), # Faixa branca
		"cor_pele": Color(0.88, 0.68, 0.52, 1.0), # Pele bronzeada de atleta
		"cor_cabelo": Color(0.1, 0.08, 0.08, 1.0), # Raspado escuro
		"cor_cabelo_destaque": Color(0.2, 0.18, 0.18, 1.0),
		"estilo_cabelo": "buzzcut_athletic",
		"tracos_faciais": ["mandibula_quadrada", "olhar_penetrante"],
		"vestimenta": "regata_volei_g_i",
		"acessorios": ["bola_volei_nen_pesada", "anel_game_master"]
	},
	"chrollo": {
		"id": "chrollo",
		"nome": "Chrollo Lucilfer",
		"titulo": "Líder da Trupe Fantasma (Genei Ryodan)",
		"afinidade": "Especialização",
		"frase_iconica": "A Aranha não para quando a cabeça é cortada. Outra perna assume o comando.",
		"cor_aura": Color(0.4, 0.15, 0.6, 1.0), # Púrpura sombrio / obsidiana
		"cor_primaria": Color(0.1, 0.1, 0.14, 1.0), # Sobretudo de couro escuro
		"cor_secundaria": Color(0.85, 0.85, 0.9, 1.0), # Pelo branco na gola
		"cor_pele": Color(0.96, 0.84, 0.76, 1.0),
		"cor_cabelo": Color(0.08, 0.08, 0.1, 1.0), # Preto escorrido / para trás
		"cor_cabelo_destaque": Color(0.2, 0.2, 0.28, 1.0),
		"estilo_cabelo": "slick_black_or_bandaged",
		"tracos_faciais": ["cruz_testa_tatuada", "olhar_vazio_filosofico"],
		"vestimenta": "sobretudo_aranha_cruz_costas",
		"acessorios": ["livro_skill_hunter", "brincos_esfera_azul"]
	},
	"meruem": {
		"id": "meruem",
		"nome": "Rei Meruem",
		"titulo": "O Ápice da Evolução das Formigas Quimera",
		"afinidade": "Especialização Absoluta",
		"frase_iconica": "Vocês, humanos, alguma vez pouparam a vida de um porco ou vaca que suplicou por misericórdia?",
		"cor_aura": Color(0.3, 0.95, 0.45, 1.0), # Verde radiante transcendental
		"cor_primaria": Color(0.25, 0.65, 0.4, 1.0), # Carapaça verde esmeralda
		"cor_secundaria": Color(0.4, 0.18, 0.55, 1.0), # Segmentos e ferrão roxo
		"cor_pele": Color(0.55, 0.85, 0.65, 1.0), # Tez quimera esverdeada
		"cor_cabelo": Color(0.18, 0.45, 0.3, 1.0), # Elmo / crista quimera
		"cor_cabelo_destaque": Color(0.3, 0.7, 0.45, 1.0),
		"estilo_cabelo": "chimeric_helmet_crown",
		"tracos_faciais": ["olhar_soberano", "orelhas_alongadas_ant", "sem_pupila_humana"],
		"vestimenta": "carapaca_natural_placas",
		"acessorios": ["cauda_com_ferrao_pesado", "tabuleiro_gungi"]
	}
}


static func obter_dados_visuais(personagem_id: String) -> Dictionary:
	var id_limpo: String = personagem_id.to_lower().strip_edges()
	if CHARACTERS.has(id_limpo):
		return CHARACTERS[id_limpo]
	for k in CHARACTERS.keys():
		if id_limpo.contains(k):
			return CHARACTERS[k]
	return CHARACTERS["gon"]


static func obter_retrato(personagem_id: String) -> Texture2D:
	var id_limpo: String = personagem_id.to_lower().strip_edges()
	var char_data := obter_dados_visuais(id_limpo)
	var real_id: String = char_data.get("id", "gon")

	if _portrait_cache.has(real_id):
		return _portrait_cache[real_id]

	var tex := _gerar_textura_retrato_pixel_art(char_data)
	_portrait_cache[real_id] = tex
	return tex


static func _gerar_textura_retrato_pixel_art(data: Dictionary) -> ImageTexture:
	# Gera um retrato 32x32 de alta fidelidade com iluminação, paleta canônica e detalhes distintivos
	var w: int = 32
	var h: int = 32
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)

	var cor_bg: Color = Color(0.08, 0.1, 0.14, 1.0)
	var cor_moldura: Color = data.get("cor_aura", Color.GOLD)
	var cor_pele: Color = data.get("cor_pele", Color(0.95, 0.8, 0.65))
	var cor_pele_sombra: Color = cor_pele.darkened(0.25)
	var cor_cabelo: Color = data.get("cor_cabelo", Color.BLACK)
	var cor_cabelo_luz: Color = data.get("cor_cabelo_destaque", cor_cabelo.lightened(0.3))
	var cor_roupa: Color = data.get("cor_primaria", Color.GRAY)
	var cor_sec: Color = data.get("cor_secundaria", Color.WHITE)
	var char_id: String = data.get("id", "")

	# 1. Fundo Gradiente com Aura Rim
	for y in range(h):
		for x in range(w):
			var dist_borda: float = min(min(x, w - 1 - x), min(y, h - 1 - y))
			if dist_borda == 0:
				img.set_pixel(x, y, cor_moldura.darkened(0.4))
			elif dist_borda == 1:
				img.set_pixel(x, y, cor_moldura)
			else:
				var aura_influence: float = clamp((float(x + y) / float(w + h)) * 0.3, 0.0, 0.4)
				img.set_pixel(x, y, cor_bg.lerp(cor_moldura, aura_influence))

	# 2. Silhueta de Roupas / Ombros (Linhas 23 a 30)
	for y in range(23, 31):
		var largura_ombros: int = 10 + (y - 23) * 2
		var start_x: int = clamp(16 - largura_ombros / 2, 2, 30)
		var end_x: int = clamp(16 + largura_ombros / 2, 2, 30)
		for x in range(start_x, end_x):
			var c_roupa = cor_roupa
			if (x == 15 or x == 16) and y >= 25:
				c_roupa = cor_sec # Gravata, zíper ou gola
			elif x == start_x or x == end_x - 1:
				c_roupa = cor_roupa.darkened(0.3)
			img.set_pixel(x, y, c_roupa)

	# 3. Pescoço (Linhas 20 a 23, Colunas 14 a 18)
	for y in range(20, 24):
		for x in range(14, 19):
			img.set_pixel(x, y, cor_pele_sombra)

	# 4. Rosto / Cabeça Base (Linhas 10 a 20, Colunas 10 a 22)
	for y in range(10, 21):
		var semi_largura: int = 5
		if y >= 11 and y <= 17:
			semi_largura = 6
		elif y == 20:
			semi_largura = 3 # Queixo afinado
		var rx1: int = 16 - semi_largura
		var rx2: int = 16 + semi_largura
		for x in range(rx1, rx2 + 1):
			var c_p = cor_pele
			if x <= rx1 + 1 or y >= 19:
				c_p = cor_pele_sombra
			img.set_pixel(x, y, c_p)

	# 5. Cabelo Específico por Personagem
	match char_id:
		"gon":
			for y in range(2, 11):
				for x in range(9, 24):
					if (x % 3 == 0 or y < 6) and (x >= 16 - (10 - y) and x <= 16 + (10 - y)):
						img.set_pixel(x, y, cor_cabelo)
						if y <= 4:
							img.set_pixel(x, y, cor_cabelo_luz)
		"killua":
			for y in range(3, 14):
				for x in range(7, 26):
					var dist: float = Vector2(x - 16, y - 10).length()
					if dist < 8.5:
						img.set_pixel(x, y, cor_cabelo)
						if y < 8 or (x % 2 == 0 and y == 13):
							img.set_pixel(x, y, cor_cabelo_luz)
		"kurapika":
			for y in range(4, 21):
				for x in range(8, 25):
					if y <= 11 or x <= 10 or x >= 22:
						img.set_pixel(x, y, cor_cabelo)
						if y < 8:
							img.set_pixel(x, y, cor_cabelo_luz)
		"hisoka":
			for y in range(2, 11):
				for x in range(10, 23):
					if x < 13 or x > 19 or y > 5:
						img.set_pixel(x, y, cor_cabelo)
						if y < 5:
							img.set_pixel(x, y, cor_cabelo_luz)
		"chrollo":
			for y in range(4, 12):
				for x in range(9, 24):
					img.set_pixel(x, y, cor_cabelo)
			# Cruz de São Pedro na testa
			img.set_pixel(16, 12, Color.WHITE)
			img.set_pixel(16, 13, Color.WHITE)
			img.set_pixel(16, 14, Color.WHITE)
			img.set_pixel(15, 13, Color.WHITE)
			img.set_pixel(17, 13, Color.WHITE)
		"meruem":
			for y in range(3, 11):
				for x in range(8, 25):
					img.set_pixel(x, y, cor_cabelo)
					if y <= 6:
						img.set_pixel(x, y, cor_cabelo_luz)
			img.set_pixel(7, 14, cor_cabelo)
			img.set_pixel(8, 14, cor_cabelo)
			img.set_pixel(24, 14, cor_cabelo)
			img.set_pixel(25, 14, cor_cabelo)
		_:
			for y in range(4, 11):
				for x in range(9, 24):
					img.set_pixel(x, y, cor_cabelo)
					if y < 7:
						img.set_pixel(x, y, cor_cabelo_luz)

	# 6. Olhos e Expressões Faciais Canônicas
	if char_id == "kurapika":
		img.set_pixel(13, 14, Color(1.0, 0.1, 0.2, 1.0))
		img.set_pixel(14, 14, Color(0.7, 0.0, 0.1, 1.0))
		img.set_pixel(18, 14, Color(1.0, 0.1, 0.2, 1.0))
		img.set_pixel(19, 14, Color(0.7, 0.0, 0.1, 1.0))
	elif char_id == "killua":
		img.set_pixel(13, 14, Color(0.2, 0.6, 1.0, 1.0))
		img.set_pixel(14, 14, Color(0.1, 0.3, 0.7, 1.0))
		img.set_pixel(18, 14, Color(0.2, 0.6, 1.0, 1.0))
		img.set_pixel(19, 14, Color(0.1, 0.3, 0.7, 1.0))
	elif char_id == "leorio":
		img.set_pixel(13, 14, Color.BLACK)
		img.set_pixel(14, 14, Color.BLACK)
		img.set_pixel(18, 14, Color.BLACK)
		img.set_pixel(19, 14, Color.BLACK)
		img.set_pixel(13, 13, Color(0.4, 0.4, 0.5, 1.0))
		img.set_pixel(18, 13, Color(0.4, 0.4, 0.5, 1.0))
		img.set_pixel(15, 14, Color.BLACK)
		img.set_pixel(16, 14, Color.BLACK)
		img.set_pixel(17, 14, Color.BLACK)
	elif char_id == "hisoka":
		img.set_pixel(13, 14, Color(0.9, 0.7, 0.1, 1.0))
		img.set_pixel(19, 14, Color(0.9, 0.7, 0.1, 1.0))
		img.set_pixel(20, 16, Color(0.9, 0.1, 0.5, 1.0))
		img.set_pixel(19, 16, Color(0.9, 0.1, 0.5, 1.0))
		img.set_pixel(12, 16, Color(0.1, 0.8, 0.9, 1.0))
		img.set_pixel(12, 17, Color(0.1, 0.8, 0.9, 1.0))
	elif char_id == "meruem":
		img.set_pixel(13, 14, Color(0.6, 0.1, 0.8, 1.0))
		img.set_pixel(14, 14, Color(0.3, 0.05, 0.4, 1.0))
		img.set_pixel(18, 14, Color(0.6, 0.1, 0.8, 1.0))
		img.set_pixel(19, 14, Color(0.3, 0.05, 0.4, 1.0))
	else:
		img.set_pixel(13, 14, Color(0.15, 0.1, 0.1, 1.0))
		img.set_pixel(14, 14, Color(0.3, 0.2, 0.2, 1.0))
		img.set_pixel(18, 14, Color(0.15, 0.1, 0.1, 1.0))
		img.set_pixel(19, 14, Color(0.3, 0.2, 0.2, 1.0))

	# Boca sutil
	img.set_pixel(16, 18, cor_pele_sombra.darkened(0.2))

	return ImageTexture.create_from_image(img)
