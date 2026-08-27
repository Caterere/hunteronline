extends Node

# ============================================================
# HUNTER ONLINE - HATSU MANAGER (AUTOLOAD & NEN JUDGE ENGINE)
# ============================================================
#
# Gerencia a fábrica de Hatsu, o catálogo canônico, o
# Avaliador Semântico Inteligente de Juramentos (Nen Vow Engine)
# e a Engine de 10 Arquétipos Modulares com Power Budget.
#
# ============================================================


# ============================================================
# AVALIADOR INTELIGENTE DE JURAMENTOS E ARQUÉTIPOS (IA JUÍZA)
# ============================================================

func analisar_juramento_inteligente(texto_customizado: String) -> Dictionary:
	var texto: String = texto_customizado.to_lower().strip_edges()

	if texto.is_empty():
		return {
			"valido": false,
			"rejeitado": false,
			"tier": HatsuData.Tier.CONDICAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"categoria_voto": "",
			"nome_reconhecido": "Nenhum Juramento",
			"multiplicador": 1.0,
			"dificuldade": 1, "risco": 1, "severidade": 1, "frequencia": 5, "impacto": 1,
			"analise_mestre": "Escreva uma condição, sacrifício ou juramento autêntico para seu Hatsu.",
			"impacto_jogo": "Sem efeitos ou bônus adicionais."
		}

	# ------------------------------------------------------------
	# 🚫 REJEIÇÃO ATIVA DE CHEATS / RESTRIÇÕES NULAS OU ABSURDAS
	# ------------------------------------------------------------
	var kw_cheats = ["1000x", "infinito", "sem custo", "invencivel", "invencível", "matar tudo", "sem fraqueza", "sem perder nada", "sem risco"]
	for cw in kw_cheats:
		if cw in texto:
			return {
				"valido": false,
				"rejeitado": true,
				"tier": HatsuData.Tier.CONDICAO,
				"arquetipo": HatsuData.Arquetipo.SIMPLES,
				"categoria_voto": "REJEITADO",
				"nome_reconhecido": "Poder Incompatível (Cheat Recusado)",
				"multiplicador": 1.0,
				"analise_mestre": "❌ HATSU INVÁLIDO: Poder incompatível com as regras de Nen. No universo de Hunter x Hunter, poder extremo exige sacrifício ou risco equivalente. Adicione uma restrição real para liberar esse potencial.",
				"impacto_jogo": "Nenhum poder concedido. A aura exige restrições e trocas equivalentes."
			}

	var kw_triviais = [
		"de costas", "costas", "bonito", "roupa legal", "olhar para cima", "olhando pra cima",
		"piscar", "quando eu quiser", "sempre", "nada", "facil", "fácil", "nenhuma",
		"andar pra frente", "pular", "respirar"
	]
	for tw in kw_triviais:
		if tw == texto or (tw in texto and not ("não" in texto or "nao" in texto or "dano" in texto or "vida" in texto or "zetsu" in texto)):
			return {
				"valido": false,
				"rejeitado": true,
				"tier": HatsuData.Tier.CONDICAO,
				"arquetipo": HatsuData.Arquetipo.SIMPLES,
				"categoria_voto": "REJEITADO",
				"nome_reconhecido": "Voto Inválido / Insignificante",
				"multiplicador": 1.0,
				"analise_mestre": "⚠️ AVALIAÇÃO DE NEN: Esta restrição não impõe um risco, custo ou sacrifício tático real no combate para justificar um aumento de poder.",
				"impacto_jogo": "Nenhum bônus concedido. Tente impor um risco real de HP, Aura, Zetsu ou Alvo."
			}

	# ------------------------------------------------------------
	# 🎲 1. ARQUÉTIPO: ARSENAL / ROLETA (Crazy Slots de Kite)
	# ------------------------------------------------------------
	var kw_roleta = ["roleta", "arma aleatoria", "arma aleatória", "arsenal aleatorio", "sortear arma", "crazy slots", "sorteia", "não escolhe a arma", "nao escolhe a arma"]
	for kw in kw_roleta:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.ARSENAL_ROLETA, "ARSENAL_ROLETA",
				"Arsenal do Destino (Crazy Slots de Kite)",
				1.85, 3, 4, 3, 4, 3,
				"Princípio da Aleatoriedade Tática: O usuário abdica de escolher sua arma, submetendo-se à roleta de Nen. Essa imprevisibilidade concede +45% a +85% de bônus de poder a cada arma individual.",
				"🎲 Roleta de Arsenal: Sorteia armas de alto impacto (Foice, Lança, Espada, Pistola, Martelo) ao ativar."
			)

	# ------------------------------------------------------------
	# 📖 2. ARQUÉTIPO: COLEÇÃO / LIVRO (Skill Hunter de Chrollo)
	# ------------------------------------------------------------
	var kw_livro = ["livro", "coleção", "colecao", "roubar hatsu", "copiar habilidade", "guardar habilidades", "skill hunter", "armazenar hatsu", "arquivo"]
	for kw in kw_livro:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.LIVRO_COLECAO, "LIVRO_COLECAO",
				"Arquivo dos Segredos (Skill Hunter de Chrollo)",
				1.90, 4, 4, 4, 2, 5,
				"Princípio da Coleção de Nen: Permite registrar e catalogar habilidades de outros Mestres Hunters encontrados pelo mundo após cumprir 4 condições estritas.",
				"📖 Livro de Hatsu: Permite armazenar até 3 habilidades roubadas/registradas no mundo."
			)

	# ------------------------------------------------------------
	# 🌐 3. ARQUÉTIPO: TERRITÓRIO DE EN (Regras Espaciais)
	# ------------------------------------------------------------
	var kw_territorio = ["território", "territorio", "área com regras", "area com regras", "círculo no chão", "circulo no chao", "dentro da área", "dentro da area", "campo de en"]
	for kw in kw_territorio:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.TERRITORIO_EN, "TERRITORIO_EN",
				"Domínio Espacial de En (Território Absoluto)",
				1.75, 3, 3, 3, 4, 4,
				"Princípio da Soberania Territorial: Projeta um círculo de En no solo onde vigoram regras inescapáveis de velocidade e dano contínuo.",
				"🌐 Território de En: Cria zona que reduz em 60% a velocidade dos inimigos e amplifica seus golpes."
			)

	# ------------------------------------------------------------
	# 🎯 4. ARQUÉTIPO: MARCAÇÃO TÁTICA (Tag & Trigger / Countdown)
	# ------------------------------------------------------------
	var kw_marca = ["marca", "marcar", "tocar 3 vezes", "tocar tres vezes", "countdown", "detonar marca", "tag", "toque acumulado"]
	for kw in kw_marca:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.MARCA_TAG, "MARCA_TAG",
				"Marca do Veredito (Countdown / Tag de Nen)",
				1.80, 3, 3, 3, 3, 4,
				"Princípio da Detonação Retardada: Acertar golpes consecutivos planta uma bomba ou selo de Nen que detona com dano multiplicado.",
				"🎯 Marcação Tática: Requer 3 toques no alvo para liberar uma explosão de 200 de Dano."
			)

	# ------------------------------------------------------------
	# 🎲 5. ARQUÉTIPO: OBJETOS MÍSTICOS (Dado de 6 Faces)
	# ------------------------------------------------------------
	var kw_dado = ["dado", "dado de 6 faces", "rolar dado", "dados", "face 6", "jogar dado"]
	for kw in kw_dado:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.VOTO_EXTREMO, HatsuData.Arquetipo.OBJETO_DADO, "OBJETO_DADO",
				"Dado do Destino (Risky Dice de Greed Island)",
				2.10, 4, 5, 5, 2, 5,
				"Princípio da Aposta Extrema: Rolar um dado de Nen. Tirar 6 gera uma supernova destrutiva (+150%), mas tirar 1 impõe Zetsu forçado imediato!",
				"🎲 Dado de Nen: Efeitos de 1 a 6 com alta variância e risco crítico."
			)

	# ------------------------------------------------------------
	# 🪙 6. ARQUÉTIPO: MOEDA DA SORTE (Cara ou Coroa)
	# ------------------------------------------------------------
	var kw_moeda = ["moeda", "cara ou coroa", "jogar moeda", "girar moeda"]
	for kw in kw_moeda:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.CONDICAO, HatsuData.Arquetipo.OBJETO_MOEDA, "OBJETO_MOEDA",
				"Moeda dos Dois Destinos",
				1.50, 2, 2, 2, 4, 2,
				"Princípio da Dualidade de Nen: Lança uma moeda ao ar (Cara = +120 Velocidade / Coroa = Escudo de 100 Absorção).",
				"🪙 Moeda de Nen: Alterna buffs balanceados conforme a sorte do lançamento."
			)

	# ------------------------------------------------------------
	# 🃏 7. ARQUÉTIPO: CARTAS DE BARALHO (5 Naipes)
	# ------------------------------------------------------------
	var kw_cartas = ["cartas", "baralho", "naipe", "puxar carta", "carta de nen"]
	for kw in kw_cartas:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.OBJETO_CARTAS, "OBJETO_CARTAS",
				"Baralho do Arcano de Nen",
				1.70, 3, 3, 3, 4, 3,
				"Princípio do Naipe Místico: Puxa 1 de 5 cartas de baralho (Cura, Dano Crítico, Escudo, Dash ou Joker Supremo).",
				"🃏 Cartas de Nen: Libera poderes variados conforme o naipe sorteado."
			)

	# ------------------------------------------------------------
	# 🩸 8. ARQUÉTIPO: TROCA DE RECURSOS & SACRIFÍCIO
	# ------------------------------------------------------------
	var kw_troca = ["trocar hp por dano", "trocar vida por dano", "sacrificar hp", "trocar aura por velocidade", "troca vital", "troca de recursos"]
	for kw in kw_troca:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.TROCA_SACRIFICIO, "TROCA_SACRIFICIO",
				"Pacto da Troca Equivalente (Transmutação Vital)",
				1.85, 3, 4, 4, 4, 4,
				"Princípio da Conversão Biológica: Sacrifica 30% do HP para dobrar o dano durante 5 segundos decisivos.",
				"🩸 Troca Vital: Converte vida em poder ofensivo avassalador temporário."
			)

	# ------------------------------------------------------------
	# ⚔️ 9. ARQUÉTIPO: CONJURAÇÃO DE ARMA COM CARGAS
	# ------------------------------------------------------------
	var kw_arma_cargas = ["espada que fica mais forte", "arma que acumula", "arma que ganha cargas", "lâmina que acumula", "espada com almas"]
	for kw in kw_arma_cargas:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.CONJURACAO_ARMA, "CONJURACAO_ARMA",
				"Lâmina do Caçador (Conjuração com Cargas de Abate)",
				1.75, 3, 3, 3, 3, 4,
				"Princípio do Aço Espiritual: Conjura uma lâmina sólida que acumula +15% de dano por inimigo derrotado (até 10 cargas = +150%).",
				"⚔️ Arma Conjurada: Espada persistente que escala com o massacre de monstros."
			)

	# ------------------------------------------------------------
	# 🔴 10. VOTOS EXTREMOS ESPECÍFICOS (Tier 3)
	# ------------------------------------------------------------
	var kw_morte_falha = ["se errar morro", "se errar morre", "perco o hatsu", "se falhar zetsu", "cadafalso", "pacto de morte"]
	for kw in kw_morte_falha:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.VOTO_EXTREMO, HatsuData.Arquetipo.SIMPLES, "RISCO_EXTREMO",
				"Voto do Cadafalso Absoluto (Kurapika)",
				2.20, 5, 5, 5, 1, 5,
				"Princípio do Julgamento Extremo: Apostar a integridade vital concede poder supremo; errar o golpe acarreta dano severo e Zetsu forçado.",
				"🔴 Voto Extremo: +120% de Poder Final! Errar ou falhar causa 50% de auto-dano e Zetsu de 30s."
			)

	var kw_atacou_primeiro = ["atacou primeiro", "me atacou", "sofrer ataque antes", "contra o agressor", "quem me bater", "quem me atacar"]
	for kw in kw_atacou_primeiro:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.CONTRATO_DUELO, "ALVO_CONTRA_ATAQUE",
				"Voto do Retorno (Autodefesa de Nen)",
				1.75, 3, 4, 3, 3, 3,
				"Princípio da Autodefesa Absoluta: A técnica se recusa a ferir inocentes e só libera sua fúria contra quem iniciou o ataque.",
				"🟡 Juramento Sério: +75% de Poder Final contra agressores comprovados."
			)

	var kw_zetsu_pos = ["zetsu por", "depois de usar entro em zetsu", "zetsu após", "zetsu apos", "desligar os nós", "sem nen por"]
	for kw in kw_zetsu_pos:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.SIMPLES, "POS_USO_ZETSU",
				"Pacto da Exaustão (Zetsu Forçado Pós-Uso)",
				1.85, 4, 5, 5, 4, 5,
				"Princípio da Exaustão Biológica: Entrar em Zetsu forçado por 15s pós-uso anula todas as defesas em troca de impacto colossal.",
				"🟡 Juramento Sério: +85% de Poder Final! O usuário entra em Zetsu forçado por 15 segundos pós-uso."
			)

	# ------------------------------------------------------------
	# 🟢 11. JURAMENTO LIVRE VÁLIDO (Ponderado pela extensão e termos)
	# ------------------------------------------------------------
	var bonus_generico: float = clamp(1.25 + (float(texto.length()) * 0.006), 1.25, 1.45)
	return _gerar_resposta_vow(
		HatsuData.Tier.CONDICAO, HatsuData.Arquetipo.SIMPLES, "LIVRE",
		"Juramento de Resolução Pessoal",
		bonus_generico, 2, 2, 2, 3, 2,
		"Princípio de Nen: Toda restrição baseada em convicção e sacrifício fortalece o fluxo de energia.",
		"🟢 Condição: +%d%% de Poder Final concedido pelo pacto." % int((bonus_generico - 1.0) * 100)
	)


func _gerar_resposta_vow(
	tier: HatsuData.Tier, arq: HatsuData.Arquetipo, cat: String, nome_rec: String,
	mult: float, dif: int, ris: int, sev: int, freq: int, imp: int,
	analise: String, impacto: String
) -> Dictionary:
	return {
		"valido": true,
		"rejeitado": false,
		"tier": tier,
		"arquetipo": arq,
		"categoria_voto": cat,
		"nome_reconhecido": nome_rec,
		"multiplicador": mult,
		"dificuldade": dif,
		"risco": ris,
		"severidade": sev,
		"frequencia": freq,
		"impacto": imp,
		"analise_mestre": analise,
		"impacto_jogo": impacto
	}


# ============================================================
# FÁBRICA DE HATSU (SUPORTE A TODOS OS 10 ARQUÉTIPOS)
# ============================================================

func criar_hatsu(
	nome_hatsu: String,
	categoria: HatsuData.Categoria,
	forma: HatsuData.Forma,
	condicoes: Array = [],
	objetivo: HatsuData.ObjetivoPrincipal = HatsuData.ObjetivoPrincipal.DANO,
	elemento: HatsuData.Elemento = HatsuData.Elemento.NEN_PURO,
	alvo: HatsuData.Alvo = HatsuData.Alvo.INIMIGO_UNICO,
	alcance_tipo: HatsuData.AlcanceTipo = HatsuData.AlcanceTipo.MEDIO,
	consumo_desejado: HatsuData.ConsumoDesejado = HatsuData.ConsumoDesejado.MEDIO,
	custom_vow_text: String = "",
	arquetipo: HatsuData.Arquetipo = HatsuData.Arquetipo.SIMPLES,
	cor_primaria: Color = Color(-1, -1, -1, -1),
	cor_secundaria: Color = Color(-1, -1, -1, -1),
	estilo_visual: HatsuData.EstiloVisual = HatsuData.EstiloVisual.PURO_PULSANTE
) -> HatsuData:

	var hatsu := HatsuData.new()
	hatsu.nome = nome_hatsu if not nome_hatsu.is_empty() else "Hatsu sem Nome"
	hatsu.categoria = categoria
	hatsu.forma = forma
	hatsu.objetivo = objetivo
	hatsu.elemento = elemento
	hatsu.alvo = alvo
	hatsu.alcance_tipo = alcance_tipo
	hatsu.consumo_desejado = consumo_desejado
	hatsu.arquetipo = arquetipo
	hatsu.estilo_visual = estilo_visual

	var typed_condicoes: Array[HatsuData.Condicao] = []
	for c in condicoes:
		typed_condicoes.append(c as HatsuData.Condicao)

	# Processar juramento customizado e arquétipo se presente
	if not custom_vow_text.is_empty():
		var analise: Dictionary = analisar_juramento_inteligente(custom_vow_text)
		if analise.get("valido", false):
			if not (HatsuData.Condicao.CUSTOMIZADO in typed_condicoes):
				typed_condicoes.append(HatsuData.Condicao.CUSTOMIZADO)
			hatsu.vow_custom_text = custom_vow_text
			hatsu.vow_custom_mult = float(analise.get("multiplicador", 1.30))
			hatsu.vow_custom_cat = String(analise.get("categoria_voto", "LIVRE"))
			hatsu.vow_custom_tier = analise.get("tier", HatsuData.Tier.CONDICAO)
			if hatsu.arquetipo == HatsuData.Arquetipo.SIMPLES and analise.has("arquetipo"):
				hatsu.arquetipo = analise.get("arquetipo")

			# Mapeamentos automáticos de condições canônicas
			match hatsu.vow_custom_cat:
				"ALMAS", "CONJURACAO_ARMA":
					if not (HatsuData.Condicao.ALMAS_INIMIGOS in typed_condicoes):
						typed_condicoes.append(HatsuData.Condicao.ALMAS_INIMIGOS)
				"ALVO_CONTRA_ATAQUE":
					if not (HatsuData.Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO in typed_condicoes):
						typed_condicoes.append(HatsuData.Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO)
				"POS_USO_ZETSU":
					if not (HatsuData.Condicao.ZETSU_POS_USO_15S in typed_condicoes):
						typed_condicoes.append(HatsuData.Condicao.ZETSU_POS_USO_15S)
				"RISCO_EXTREMO":
					if not (HatsuData.Condicao.PENALIDADE_MORTE_ERRO in typed_condicoes):
						typed_condicoes.append(HatsuData.Condicao.PENALIDADE_MORTE_ERRO)

	hatsu.condicoes = typed_condicoes
	_configurar_stats_base(hatsu)
	_configurar_arquetipo_padrao(hatsu)

	# Cores por Elemento ou Customizadas
	if cor_primaria.r >= 0.0:
		hatsu.cor_aura = cor_primaria
	else:
		match elemento:
			HatsuData.Elemento.ELETRICIDADE: hatsu.cor_aura = Color(0.2, 0.9, 1.0, 1.0)
			HatsuData.Elemento.FOGO: hatsu.cor_aura = Color(1.0, 0.3, 0.1, 1.0)
			HatsuData.Elemento.GELO: hatsu.cor_aura = Color(0.6, 0.9, 1.0, 1.0)
			HatsuData.Elemento.VENENO: hatsu.cor_aura = Color(0.6, 0.1, 0.8, 1.0)
			HatsuData.Elemento.SOM: hatsu.cor_aura = Color(0.9, 0.9, 0.3, 1.0)
			HatsuData.Elemento.LUZ: hatsu.cor_aura = Color(1.0, 1.0, 0.8, 1.0)
			HatsuData.Elemento.SOMBRA: hatsu.cor_aura = Color(0.2, 0.1, 0.3, 1.0)
			_: hatsu.cor_aura = Color(0.3, 0.8, 1.0, 1.0)

	if cor_secundaria.r >= 0.0:
		hatsu.cor_aura_secundaria = cor_secundaria
	else:
		hatsu.cor_aura_secundaria = Color(1.0, 1.0, 1.0, 0.9)

	# Alcances
	match alcance_tipo:
		HatsuData.AlcanceTipo.CURTO:
			hatsu.alcance = 45.0
			hatsu.raio = 40.0
		HatsuData.AlcanceTipo.MEDIO:
			hatsu.alcance = 130.0
			hatsu.raio = 65.0
		HatsuData.AlcanceTipo.LONGO:
			hatsu.alcance = 220.0
			hatsu.raio = 95.0

	return hatsu


func _configurar_arquetipo_padrao(hatsu: HatsuData) -> void:
	match hatsu.arquetipo:
		HatsuData.Arquetipo.ARSENAL_ROLETA:
			hatsu.armas_roleta = [
				{"nome": "Foice Silenciosa", "dano_mult": 1.6, "cooldown": 12.0, "alcance": 75.0, "raio": 70.0, "tipo": "AREA"},
				{"nome": "Lança Perfurante", "dano_mult": 1.4, "cooldown": 8.0, "alcance": 180.0, "raio": 30.0, "tipo": "PROJETIL"},
				{"nome": "Espada de Ko", "dano_mult": 1.3, "cooldown": 4.0, "alcance": 45.0, "raio": 40.0, "tipo": "TOQUE"},
				{"nome": "Pistola de Emissão", "dano_mult": 1.1, "cooldown": 3.0, "alcance": 210.0, "raio": 25.0, "tipo": "PROJETIL"},
				{"nome": "Martelo de Impacto", "dano_mult": 1.7, "cooldown": 14.0, "alcance": 50.0, "raio": 60.0, "tipo": "TOQUE"}
			]
		HatsuData.Arquetipo.OBJETO_MOEDA:
			hatsu.moeda_cara_efeito = "VELOCIDADE"
			hatsu.moeda_coroa_efeito = "DEFESA"
		HatsuData.Arquetipo.OBJETO_CARTAS:
			hatsu.cartas_baralho = [
				{"naipe": "♥ Copas", "nome": "Cura Celular", "efeito": "CURA", "valor": 60.0},
				{"naipe": "♠ Espadas", "nome": "Lâmina Vorpal", "efeito": "DANO_CRITICO", "valor": 120.0},
				{"naipe": "♦ Ouros", "nome": "Muralha de Diamante", "efeito": "ESCUDO", "valor": 80.0},
				{"naipe": "♣ Paus", "nome": "Passo Supersônico", "efeito": "VELOCIDADE", "valor": 140.0},
				{"naipe": "★ Joker", "nome": "Truque Supremo", "efeito": "SUPREMO", "valor": 180.0}
			]
		HatsuData.Arquetipo.OBJETO_DADO:
			hatsu.dado_faces = {
				1: {"nome": "Face 1: Zetsu Forçado", "efeito": "ZETSU", "valor": 5.0},
				2: {"nome": "Face 2: Restauração Leve", "efeito": "CURA", "valor": 30.0},
				3: {"nome": "Face 3: Escudo Protetor", "efeito": "ESCUDO", "valor": 50.0},
				4: {"nome": "Face 4: Impulsão de Nen", "efeito": "VELOCIDADE", "valor": 90.0},
				5: {"nome": "Face 5: Rajada Contínua", "efeito": "DANO", "valor": 85.0},
				6: {"nome": "Face 6: Supernova Cósmica", "efeito": "SUPERNOVA", "valor": 220.0}
			}
		HatsuData.Arquetipo.TERRITORIO_EN:
			hatsu.territorio_raio = 90.0
			hatsu.territorio_regra = "DESACELERACAO"
		HatsuData.Arquetipo.MARCA_TAG:
			hatsu.marca_toques_max = 3
			hatsu.marca_efeito = "DETONACAO"
		HatsuData.Arquetipo.TROCA_SACRIFICIO:
			hatsu.troca_de = "HP"
			hatsu.troca_para = "DANO"
			hatsu.troca_taxa = 1.0


func _configurar_stats_base(hatsu: HatsuData) -> void:
	var mult_consumo: float = 1.0
	match hatsu.consumo_desejado:
		HatsuData.ConsumoDesejado.BAIXO:
			mult_consumo = 0.7
			hatsu.custo_aura_base = 15.0
		HatsuData.ConsumoDesejado.MEDIO:
			mult_consumo = 1.0
			hatsu.custo_aura_base = 28.0
		HatsuData.ConsumoDesejado.ALTO:
			mult_consumo = 1.45
			hatsu.custo_aura_base = 48.0

	match hatsu.objetivo:
		HatsuData.ObjetivoPrincipal.DEFESA:
			hatsu.poder_base = 50.0 * mult_consumo
			hatsu.escudo_base = hatsu.poder_base * 1.5
			hatsu.duracao = 7.0
			hatsu.cooldown_base = 6.5
			if hatsu.forma == HatsuData.Forma.PESSOAL:
				hatsu.escudo_base *= 1.3
				hatsu.cooldown_base = 5.5
			elif hatsu.forma == HatsuData.Forma.AREA:
				hatsu.raio = 70.0
				hatsu.duracao = 8.0

		HatsuData.ObjetivoPrincipal.CURA:
			hatsu.poder_base = 40.0 * mult_consumo
			hatsu.cura_base = hatsu.poder_base * 1.2
			hatsu.cooldown_base = 7.0
			hatsu.duracao = 5.0

		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			hatsu.poder_base = 30.0 * mult_consumo
			hatsu.velocidade_bonus = 140.0
			hatsu.duracao = 4.0
			hatsu.cooldown_base = 4.0
			hatsu.alcance = 150.0

		HatsuData.ObjetivoPrincipal.CONTROLE:
			hatsu.poder_base = 35.0 * mult_consumo
			hatsu.stun_duracao = 2.0
			hatsu.cooldown_base = 6.0
			hatsu.raio = 60.0

		HatsuData.ObjetivoPrincipal.SUPORTE:
			hatsu.poder_base = 35.0 * mult_consumo
			hatsu.duracao = 8.0
			hatsu.cooldown_base = 7.0

		HatsuData.ObjetivoPrincipal.DANO, _:
			match hatsu.categoria:
				HatsuData.Categoria.INTENSIFICACAO:
					match hatsu.forma:
						HatsuData.Forma.TOQUE:
							hatsu.poder_base = 60.0 * mult_consumo
							hatsu.cooldown_base = 2.5
							hatsu.alcance = 40.0
						HatsuData.Forma.PESSOAL:
							hatsu.poder_base = 40.0 * mult_consumo
							hatsu.cooldown_base = 5.0
						_:
							hatsu.poder_base = 45.0 * mult_consumo
							hatsu.cooldown_base = 3.0

				HatsuData.Categoria.TRANSFORMACAO:
					hatsu.poder_base = 45.0 * mult_consumo
					hatsu.cooldown_base = 2.8
					hatsu.duracao = 6.0

				HatsuData.Categoria.EMISSAO:
					hatsu.poder_base = 40.0 * mult_consumo
					hatsu.cooldown_base = 2.2
					hatsu.alcance = 190.0

				HatsuData.Categoria.CONJURACAO:
					hatsu.poder_base = 50.0 * mult_consumo
					hatsu.cooldown_base = 3.8
					hatsu.duracao = 8.0

				HatsuData.Categoria.MANIPULACAO:
					hatsu.poder_base = 35.0 * mult_consumo
					hatsu.cooldown_base = 3.0
					hatsu.duracao = 5.0

				HatsuData.Categoria.ESPECIALIZACAO:
					hatsu.poder_base = 55.0 * mult_consumo
					hatsu.cooldown_base = 5.5
					hatsu.duracao = 9.0


func obter_hatsu_canonico(id_hatsu: String) -> HatsuData:
	for info in CanonHatsuCatalog.obter_hatsus_canonicos():
		if info["id"] == id_hatsu:
			var h := HatsuData.new()
			h.nome = info.get("nome", "Hatsu")
			h.categoria = info.get("categoria", HatsuData.Categoria.INTENSIFICACAO)
			h.forma = info.get("forma", HatsuData.Forma.TOQUE)
			h.objetivo = info.get("objetivo", HatsuData.ObjetivoPrincipal.DANO)
			h.poder_base = info.get("poder_base", 50.0)
			h.cura_base = info.get("cura_base", 0.0)
			h.custo_aura_base = info.get("custo_aura", 25.0)
			h.cooldown_base = info.get("cooldown", 5.0)
			h.duracao = info.get("duracao", 0.0)
			h.alcance = info.get("alcance", 60.0)
			h.raio = info.get("raio", 50.0)

			var typed_condicoes: Array[HatsuData.Condicao] = []
			for c in info.get("condicoes", []):
				typed_condicoes.append(c as HatsuData.Condicao)
			h.condicoes = typed_condicoes
			return h
	return null


# ============================================================
# INFOS E REGRAS CONTEXTUAIS PARA UI
# ============================================================

func obter_nome_categoria(cat: HatsuData.Categoria) -> String:
	match cat:
		HatsuData.Categoria.INTENSIFICACAO: return "Intensificação (Enhancement)"
		HatsuData.Categoria.TRANSFORMACAO: return "Transformação (Transmutation)"
		HatsuData.Categoria.EMISSAO: return "Emissão (Emission)"
		HatsuData.Categoria.CONJURACAO: return "Conjuração (Conjuration)"
		HatsuData.Categoria.MANIPULACAO: return "Manipulação (Manipulation)"
		HatsuData.Categoria.ESPECIALIZACAO: return "Especialização (Specialization)"
	return "Desconhecido"


func obter_desc_categoria(cat: HatsuData.Categoria) -> String:
	match cat:
		HatsuData.Categoria.INTENSIFICACAO: return "Fortalece o corpo, ataques físicos e poder de cura."
		HatsuData.Categoria.TRANSFORMACAO: return "Altera a natureza da aura para eletricidade, chiclete ou lâminas."
		HatsuData.Categoria.EMISSAO: return "Projeta e sustenta a aura à distância em disparos e socos remotos."
		HatsuData.Categoria.CONJURACAO: return "Materializa armas, criaturas e objetos de Nen tangíveis."
		HatsuData.Categoria.MANIPULACAO: return "Controla objetos, agulhas, marionetes ou o corpo de inimigos."
		HatsuData.Categoria.ESPECIALIZACAO: return "Habilidades únicas fora das outras 5 categorias (roubo, olhos escarlates)."
	return ""


func obter_nome_forma_contextual(f: HatsuData.Forma, obj: HatsuData.ObjetivoPrincipal) -> String:
	match obj:
		HatsuData.ObjetivoPrincipal.DEFESA:
			match f:
				HatsuData.Forma.PESSOAL: return "1. Armadura Pessoal de Aura (Corpo)"
				HatsuData.Forma.AREA: return "2. Cúpula / Domo Protetor (Área 360°)"
				HatsuData.Forma.TOQUE: return "3. Barreira Reativa ao Contato"
				HatsuData.Forma.ZONA: return "4. Santuário Defensivo no Solo"
				_: return "Escudo Projetado"
		HatsuData.ObjetivoPrincipal.CURA:
			match f:
				HatsuData.Forma.PESSOAL: return "1. Regeneração Biológica Celular (Em Si)"
				HatsuData.Forma.AREA: return "2. Círculo Restaurador de Aura"
				HatsuData.Forma.TOQUE: return "3. Toque Curativo Instantâneo"
				_: return "Cura Pessoal"
		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			match f:
				HatsuData.Forma.PESSOAL: return "1. Dash / Impulsão Rápida de Nen"
				HatsuData.Forma.PROJETIL: return "2. Salto Dimensional / Teleporte de Emissão"
				_: return "Aceleração de Aura"
		HatsuData.ObjetivoPrincipal.CONTROLE:
			match f:
				HatsuData.Forma.PROJETIL: return "1. Disparo de Aprisionamento (Agulhas/Correntes)"
				HatsuData.Forma.AREA: return "2. Onda Sísmica / Pulso de Paralisia"
				HatsuData.Forma.ZONA: return "3. Campo Gravitacional de Nen"
				_: return "Controle Direto"
		_:
			match f:
				HatsuData.Forma.TOQUE: return "1. Golpe Direto / Toque Físico"
				HatsuData.Forma.PROJETIL: return "2. Projétil de Aura (Disparo)"
				HatsuData.Forma.AREA: return "3. Onda de Choque em Área (AoE)"
				HatsuData.Forma.PESSOAL: return "4. Modo Pessoal / Buff Corporal"
				HatsuData.Forma.ZONA: return "5. Zona Estacionária Contínua"
	return "Manifestação Padrão"


func obter_desc_elemento_contextual(el: HatsuData.Elemento, obj: HatsuData.ObjetivoPrincipal) -> String:
	match obj:
		HatsuData.ObjetivoPrincipal.DEFESA:
			match el:
				HatsuData.Elemento.NEN_PURO: return "Nen Puro: Escudo balanceado com máxima capacidade de absorção."
				HatsuData.Elemento.ELETRICIDADE: return "Eletricidade: Escudo Reativo — paralisa e dá choque em quem atacar."
				HatsuData.Elemento.FOGO: return "Fogo / Calor: Armadura Flamejante — queima e repele atacantes."
				HatsuData.Elemento.GELO: return "Gelo: Barreira Congelante — reduz drasticamente a velocidade dos agressores."
				HatsuData.Elemento.VENENO: return "Veneno: Névoa Tóxica — libera fumaça corrosiva ao absorver impactos."
				HatsuData.Elemento.SOM: return "Som: Barreira Sônica — desorienta e empurra inimigos com ondas de choque."
				HatsuData.Elemento.LUZ: return "Luz: Clarão Protetor — ofusca agressores por 1.5s."
				HatsuData.Elemento.SOMBRA: return "Sombra: Manto das Trevas — camufla e aumenta a esquiva."
		HatsuData.ObjetivoPrincipal.CURA:
			match el:
				HatsuData.Elemento.NEN_PURO: return "Nen Puro: Regeneração celular direta de pontos de vida."
				HatsuData.Elemento.LUZ: return "Luz: Purificação radiante que limpa debuffs e recupera vida."
				HatsuData.Elemento.GELO: return "Gelo: Crioterapia celular que estanca sangramentos."
				_: return "Energia de recuperação vital."
		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			match el:
				HatsuData.Elemento.ELETRICIDADE: return "Eletricidade (Kanmuru): Sobrecarga neural e velocidade da luz!"
				HatsuData.Elemento.SOM: return "Som: Dash em velocidade sônica que quebra a barreira do som."
				HatsuData.Elemento.SOMBRA: return "Sombra: Deslocamento instantâneo oculto pelas sombras."
				_: return "Impulsão concentrada de aura pura."
		_:
			match el:
				HatsuData.Elemento.NEN_PURO: return "Nen Puro: Energia crua sem fraquezas, alto impacto."
				HatsuData.Elemento.ELETRICIDADE: return "Eletricidade: Atordoa e desacelera oponentes com choques elétricos."
				HatsuData.Elemento.FOGO: return "Fogo / Calor: Dano de queimadura contínuo por 3 segundos."
				HatsuData.Elemento.GELO: return "Gelo: Reduz a velocidade e pode congelar alvos atingidos."
				HatsuData.Elemento.VENENO: return "Veneno: Dano tóxico corrosivo periódico."
				HatsuData.Elemento.SOM: return "Som / Vibração: Ondas sísmicas que ignoram parte da defesa."
				HatsuData.Elemento.LUZ: return "Luz: Clarão ofuscante com alto dano e chance de cegueira."
				HatsuData.Elemento.SOMBRA: return "Sombra: Dano furtivo e perfuração sombria."
	return "Natureza fundamental da energia."


# ============================================================
# SISTEMA DE LIVRO DE HATSU (GRIMÓRIO & RESTRICTION ENGINE)
# ============================================================

func avaliar_balanceamento_livro(config: Dictionary) -> Dictionary:
	var capacidade: int = int(config.get("capacidade", 10))
	var permite_marcador: bool = bool(config.get("permite_marcador", true))
	var roubo_combate: bool = bool(config.get("roubo_combate", true))
	var manter_indef: bool = bool(config.get("manter_indefinidamente", true))

	var restricoes_aq: Array = config.get("restricoes_aquisicao", [])
	var restricoes_uso: Array = config.get("restricoes_uso", [])
	var restricoes_ris: Array = config.get("restricoes_risco", [])

	# 1. Hatsu Power (Custo das Capacidades)
	var h_power: int = 20
	if capacidade > 5: h_power += (capacidade - 5) * 3
	if roubo_combate: h_power += 25
	if manter_indef: h_power += 20
	if permite_marcador: h_power += 45

	# 2. Restriction Power (Poder das Restrições)
	var r_power: int = 0
	for r in restricoes_aq:
		match r:
			"OBSERVAR_USO": r_power += 20
			"DESCOBRIR_REGRAS": r_power += 25
			"TOQUE_FISICO": r_power += 30
			"RITUAL_TEMPO": r_power += 20
			_: r_power += 15

	for r in restricoes_uso:
		match r:
			"MANTER_LIVRO_ABERTO": r_power += 25
			"PROIBICAO_REN_DUPLO": r_power += 35
			"ZETSU_POS_USO": r_power += 40
			"UNICA_VEZ_DIA": r_power += 45
			_: r_power += 15

	for r in restricoes_ris:
		match r:
			"MORTE_USUARIO_REMOVE": r_power += 20
			"FALHA_CAUSA_DANO_HP": r_power += 35
			"FALHA_PERDE_HABILIDADE": r_power += 40
			_: r_power += 15

	var balance_score: int = r_power - h_power

	if balance_score < -50:
		return {
			"aprovado": false,
			"rejeitado": true,
			"hatsu_power": h_power,
			"restriction_power": r_power,
			"balance_score": balance_score,
			"eficiencia_global": 0.0,
			"mensagem": "❌ REJEITADO: Essa configuração ultrapassa o limite de poder permitido para este Hatsu. Adicione restrições ou reduza suas capacidades (ex: diminua capacidade de páginas ou remova marcador duplo)."
		}

	var ef_global: float = 1.0
	var status_text: String = "100% de Eficiência Plena"
	if balance_score >= 0:
		ef_global = 1.0
		status_text = "Equilíbrio Perfeito (100% de Eficiência)"
	elif balance_score >= -25:
		ef_global = clamp(1.0 + float(balance_score) * 0.012, 0.70, 0.95)
		status_text = "Versão Equilibrada Parcial (%d%% de Eficiência, custo de aura +25%%)" % int(ef_global * 100)
	else:
		ef_global = clamp(0.70 + float(balance_score + 25) * 0.015, 0.30, 0.65)
		status_text = "Versão Restrita Pesada (%d%% de Eficiência, cooldown elevado)" % int(ef_global * 100)

	return {
		"aprovado": true,
		"rejeitado": false,
		"hatsu_power": h_power,
		"restriction_power": r_power,
		"balance_score": balance_score,
		"eficiencia_global": ef_global,
		"mensagem": "✅ Grimório Aprovado! " + status_text
	}


func criar_livro_hatsu(
	nome: String,
	capacidade: int = 10,
	permite_marcador: bool = true,
	restricoes_aq: Array[String] = [],
	restricoes_uso: Array[String] = [],
	restricoes_ris: Array[String] = []
) -> HatsuBookData:
	var book := HatsuBookData.new()
	book.nome_livro = nome if not nome.is_empty() else "Arquivo de Hatsu"
	book.capacidade_maxima = capacidade
	book.permite_marcador_duplo = permite_marcador
	book.restricoes_aquisicao = restricoes_aq
	book.restricoes_uso = restricoes_uso
	book.restricoes_risco = restricoes_ris
	book.calcular_balanco()

	# Popular com 2 páginas canônicas de exemplo
	var catalogo = obter_catalogo_hatsus_mundo()
	if catalogo.size() >= 2:
		book.adicionar_pagina(catalogo[0]) # Palma do Despertar (Wing)
		book.adicionar_pagina(catalogo[1]) # Chain Prison (Incompleto)
	return book


func obter_catalogo_hatsus_mundo() -> Array[Dictionary]:
	return [
		{
			"id": "wing_palma_nen",
			"nome": "Palma do Despertar",
			"categoria": HatsuData.Categoria.INTENSIFICACAO,
			"usuario_original": "Mestre Wing",
			"descricao": "Toque de Nen que estimula os nós biológicos do alvo restaurando vitalidade.",
			"tags": ["touch", "heal", "stamina"],
			"status_descoberta": "COMPLETO",
			"condicoes_descobertas": ["Requer contato físico direto com a palma da mão"],
			"eficiencia_base": 1.0,
			"hatsu_ref": criar_hatsu("Palma do Despertar", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE, [], HatsuData.ObjetivoPrincipal.CURA)
		},
		{
			"id": "kurapika_chain_prison",
			"nome": "Chain Prison (Corrente do Aprisionamento)",
			"categoria": HatsuData.Categoria.CONJURACAO,
			"usuario_original": "Kurapika",
			"descricao": "Corrente materializada inquebrável que envolve o alvo forçando Zetsu absoluto.",
			"tags": ["weapon", "restraint", "zetsu_lock"],
			"status_descoberta": "INCOMPLETO",
			"condicoes_descobertas": ["??? (Requer investigar a ligação com a Aranha)"],
			"eficiencia_base": 0.40,
			"hatsu_ref": criar_hatsu("Chain Prison", HatsuData.Categoria.CONJURACAO, HatsuData.Forma.TOQUE, [HatsuData.Condicao.ALVO_ELITE_BOSS], HatsuData.ObjetivoPrincipal.CONTROLE)
		},
		{
			"id": "killua_narukami",
			"nome": "Narukami (Raio Fulminante)",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"usuario_original": "Killua Zoldyck",
			"descricao": "Disparo elétrico que corta o ar a velocidade hipersônica eletrocutando oponentes.",
			"tags": ["electricity", "projectile", "stun"],
			"status_descoberta": "COMPLETO",
			"condicoes_descobertas": ["Requer carregar aura elétrica prévia"],
			"eficiencia_base": 1.0,
			"hatsu_ref": criar_hatsu("Narukami", HatsuData.Categoria.TRANSFORMACAO, HatsuData.Forma.PROJETIL, [], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.ELETRICIDADE)
		},
		{
			"id": "feitan_pain_packer",
			"nome": "Pain Packer (Sol Escaldante)",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"usuario_original": "Feitan Portor",
			"descricao": "Converte a dor física e dano sofrido em uma miniatura de sol que incinera tudo ao redor.",
			"tags": ["fire", "heat", "area", "retaliation"],
			"status_descoberta": "INCOMPLETO",
			"condicoes_descobertas": ["Requer sofrer ferimentos graves antes de poder conjurar a armadura"],
			"eficiencia_base": 0.40,
			"hatsu_ref": criar_hatsu("Pain Packer", HatsuData.Categoria.TRANSFORMACAO, HatsuData.Forma.AREA, [HatsuData.Condicao.DOR_ACUMULADA], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.FOGO)
		},
		{
			"id": "knuckle_hakoware",
			"nome": "Hakoware (Falência de Nen)",
			"categoria": HatsuData.Categoria.EMISSAO,
			"usuario_original": "Knuckle Bine",
			"descricao": "Empresta aura ao oponente através de Potclean, cobrando 10% de juros até a falência total.",
			"tags": ["interest", "debt", "zetsu_lock", "creature"],
			"status_descoberta": "COMPLETO",
			"condicoes_descobertas": ["Manter distância dentro do raio de En do Potclean"],
			"eficiencia_base": 1.0,
			"hatsu_ref": criar_hatsu("Hakoware", HatsuData.Categoria.EMISSAO, HatsuData.Forma.TOQUE, [], HatsuData.ObjetivoPrincipal.CONTROLE)
		},
		{
			"id": "machi_nen_threads",
			"nome": "Linhas de Nen",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"usuario_original": "Machi Komacine",
			"descricao": "Fios de aura ultra-resistentes para sutura celular instantânea ou imobilização de alvos.",
			"tags": ["thread", "restraint", "heal"],
			"status_descoberta": "COMPLETO",
			"condicoes_descobertas": ["Quanto mais longa a linha, menor sua resistência à tração"],
			"eficiencia_base": 1.0,
			"hatsu_ref": criar_hatsu("Linhas de Nen", HatsuData.Categoria.TRANSFORMACAO, HatsuData.Forma.TOQUE, [], HatsuData.ObjetivoPrincipal.SUPORTE)
		}
	]


func processar_sinergia_tags(hatsu_a: HatsuData, hatsu_b: HatsuData) -> Dictionary:
	if hatsu_a == null or hatsu_b == null:
		return {"sinergia": false}

	var tags_a: Array[String] = hatsu_a.tags
	var tags_b: Array[String] = hatsu_b.tags
	var todas_tags := tags_a + tags_b

	# Sinergia 1: Arma + Eletricidade (Arma Eletrificada com Stun)
	if "weapon" in todas_tags and "electricity" in todas_tags:
		return {
			"sinergia": true,
			"nome": "⚔️⚡ Lâmina Eletrificada",
			"stun": 1.5,
			"dano_bonus": 1.35,
			"cor_sinergia": Color(0.2, 0.9, 1.0),
			"desc": "Golpe armado conduz corrente elétrica aplicando choque paralisante de 1.5s (+35% Dano)!"
		}

	# Sinergia 2: Teleporte + Marcação (Salto Dimensional Marcado)
	if "teleport" in todas_tags and "mark" in todas_tags:
		return {
			"sinergia": true,
			"nome": "🌀🎯 Salto Dimensional Marcado",
			"teleport_marcado": true,
			"dano_bonus": 1.40,
			"cor_sinergia": Color(0.8, 0.2, 1.0),
			"desc": "Teleporta instantaneamente para trás do alvo marcado em qualquer distância!"
		}

	# Sinergia 3: Fogo + Projétil (Míssil Incendiário)
	if "fire" in todas_tags and "projectile" in todas_tags:
		return {
			"sinergia": true,
			"nome": "🔥💥 Míssil Incendiário de Nen",
			"area_fogo": true,
			"dano_bonus": 1.45,
			"cor_sinergia": Color(1.0, 0.3, 0.1),
			"desc": "Disparo explode em labaredas deixando poças de fogo contínuo no solo!"
		}

	# Sinergia 4: Escudo + Zetsu Lock / Supressão (Muralha Pacificadora)
	if "shield" in todas_tags and "zetsu_lock" in todas_tags:
		return {
			"sinergia": true,
			"nome": "🛡️🚫 Muralha Pacificadora",
			"bloqueia_nen": true,
			"dano_bonus": 1.20,
			"cor_sinergia": Color(0.9, 0.8, 0.3),
			"desc": "O escudo absorve impactos e desliga temporariamente o Ren dos inimigos próximos!"
		}

	return {
		"sinergia": true,
		"nome": "✨ Fusão Harmônica de Nen",
		"dano_bonus": 1.20,
		"cor_sinergia": Color(1.0, 1.0, 1.0),
		"desc": "Duplo disparo combinado com ressonância de aura (+20% Dano)."
	}
