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
				1.30, 3, 4, 3, 4, 3,
				"Princípio da Aleatoriedade Tática: O usuário abdica de escolher sua arma, submetendo-se à roleta de Nen. Essa imprevisibilidade concede +30% de bônus balanceado a cada arma individual.",
				"🎲 Roleta de Arsenal: Sorteia armas de impacto variado (Foice, Lança, Espada, Pistola, Martelo) ao ativar."
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
				1.35, 4, 4, 4, 2, 5,
				"Princípio da Coleção de Nen: Permite registrar e catalogar habilidades de outros Mestres Hunters encontrados pelo mundo após cumprir condições estritas.",
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
				1.35, 3, 3, 3, 4, 4,
				"Princípio da Soberania Territorial: Projeta um círculo de En no solo onde vigoram regras de controle e velocidade.",
				"🌐 Território de En: Cria zona que desacelera inimigos e amplifica seus golpes."
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
				1.40, 3, 3, 3, 3, 4,
				"Princípio da Detonação Retardada: Acertar golpes consecutivos planta uma marca de Nen que detona com dano acumulado.",
				"🎯 Marcação Tática: Requer 3 toques no alvo para liberar uma explosão concentrada de Dano."
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
				1.70, 4, 5, 5, 2, 5,
				"Princípio da Aposta Extrema: Rolar um dado de Nen. Tirar 6 gera uma supernova destrutiva (+70%), mas tirar 1 impõe Zetsu forçado imediato!",
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
				1.20, 2, 2, 2, 4, 2,
				"Princípio da Dualidade de Nen: Lança uma moeda ao ar (Cara = +80 Velocidade / Coroa = Escudo de 60 Absorção).",
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
				1.30, 3, 3, 3, 4, 3,
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
				1.50, 3, 4, 4, 4, 4,
				"Princípio da Conversão Biológica: Sacrifica 25% do HP para conceder +50% de dano durante 5 segundos decisivos.",
				"🩸 Troca Vital: Converte vida em poder ofensivo temporário."
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
				1.35, 3, 3, 3, 3, 4,
				"Princípio do Aço Espiritual: Conjura uma lâmina sólida que acumula +10% de dano por inimigo derrotado (até 10 cargas = +100%).",
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
				1.80, 5, 5, 5, 1, 5,
				"Princípio do Julgamento Extremo: Apostar a integridade vital concede poder supremo; errar o golpe acarreta dano severo e Zetsu forçado.",
				"🔴 Voto Extremo: +80% de Poder Final! Errar ou falhar causa 50% de auto-dano e Zetsu de 30s."
			)

	var kw_atacou_primeiro = ["atacou primeiro", "me atacou", "sofrer ataque antes", "contra o agressor", "quem me bater", "quem me atacar"]
	for kw in kw_atacou_primeiro:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.CONTRATO_DUELO, "ALVO_CONTRA_ATAQUE",
				"Voto do Retorno (Autodefesa de Nen)",
				1.45, 3, 4, 3, 3, 3,
				"Princípio da Autodefesa Absoluta: A técnica se recusa a ferir inocentes e só libera sua fúria contra quem iniciou o ataque.",
				"🟡 Juramento Sério: +45% de Poder Final contra agressores comprovados."
			)

	var kw_zetsu_pos = ["zetsu por", "depois de usar entro em zetsu", "zetsu após", "zetsu apos", "desligar os nós", "sem nen por"]
	for kw in kw_zetsu_pos:
		if kw in texto:
			return _gerar_resposta_vow(
				HatsuData.Tier.JURAMENTO, HatsuData.Arquetipo.SIMPLES, "POS_USO_ZETSU",
				"Pacto da Exaustão (Zetsu Forçado Pós-Uso)",
				1.55, 4, 5, 5, 4, 5,
				"Princípio da Exaustão Biológica: Entrar em Zetsu forçado por 15s pós-uso anula todas as defesas em troca de impacto colossal.",
				"🟡 Juramento Sério: +55% de Poder Final! O usuário entra em Zetsu forçado por 15 segundos pós-uso."
			)

	# ------------------------------------------------------------
	# 🟢 11. JURAMENTO LIVRE VÁLIDO (Ponderado pela extensão e termos)
	# ------------------------------------------------------------
	var bonus_generico: float = clamp(1.15 + (float(texto.length()) * 0.003), 1.15, 1.30)
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
	estilo_visual: HatsuData.EstiloVisual = HatsuData.EstiloVisual.PURO_PULSANTE,
	preparation_steps: Array = [],
	sub_effects: Array = [],
	modular_restrictions: Array = [],
	parametros_conceito: Dictionary = {},
	is_storage_hatsu: bool = false,
	storage_capacity: int = 3,
	storage_duration_type: String = "PERMANENT",
	storage_usage_rule: String = "OPEN_BOOK",
	steal_conditions: Array = [],
	steal_target_type: String = "ANY"
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
	hatsu.parametros_conceito = parametros_conceito.duplicate(true)

	# Configurações de Armazenamento e Roubo de Hatsu
	hatsu.is_storage_hatsu = is_storage_hatsu or (arquetipo == HatsuData.Arquetipo.LIVRO_COLECAO)
	hatsu.storage_capacity = storage_capacity
	hatsu.storage_duration_type = storage_duration_type
	hatsu.storage_usage_rule = storage_usage_rule
	var typed_sc: Array[String] = []
	for sc in steal_conditions:
		typed_sc.append(str(sc))
	hatsu.steal_conditions = typed_sc
	hatsu.steal_target_type = steal_target_type

	var typed_condicoes: Array[HatsuData.Condicao] = []
	for c in condicoes:
		typed_condicoes.append(c as HatsuData.Condicao)

	var typed_restrictions: Array = []
	for r in modular_restrictions:
		typed_restrictions.append(r)
	hatsu.modular_restrictions = typed_restrictions

	# Processar juramento customizado e arquétipo se presente
	if not custom_vow_text.is_empty():
		var analise: Dictionary = analisar_juramento_inteligente(custom_vow_text)
		if analise.get("valido", false):
			if not (HatsuData.Condicao.CUSTOMIZADO in typed_condicoes):
				typed_condicoes.append(HatsuData.Condicao.CUSTOMIZADO)
			hatsu.vow_custom_text = custom_vow_text
			hatsu.vow_custom_mult = float(analise.get("multiplicador", 1.30))
			hatsu.vow_custom_cat = str(analise.get("categoria_voto", "LIVRE"))
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

	var typed_prep: Array[Dictionary] = []
	for p in preparation_steps:
		if p is Dictionary: typed_prep.append(p)
	hatsu.preparation_steps = typed_prep

	var typed_sub: Array[int] = []
	for s in sub_effects:
		typed_sub.append(int(s))
	hatsu.sub_effects = typed_sub

	hatsu.calcular_versatility_score()
	hatsu.calcular_functional_power()
	hatsu.calcular_limitation_credits()

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
			mult_consumo = 0.8
			hatsu.custo_aura_base = 18.0
		HatsuData.ConsumoDesejado.MEDIO:
			mult_consumo = 1.0
			hatsu.custo_aura_base = 28.0
		HatsuData.ConsumoDesejado.ALTO:
			mult_consumo = 1.35
			hatsu.custo_aura_base = 45.0

	match hatsu.objetivo:
		HatsuData.ObjetivoPrincipal.DEFESA:
			hatsu.poder_base = 35.0 * mult_consumo
			hatsu.escudo_base = hatsu.poder_base * 1.3
			hatsu.duracao = 6.0
			hatsu.cooldown_base = 6.0
			if hatsu.forma == HatsuData.Forma.PESSOAL:
				hatsu.escudo_base *= 1.2
				hatsu.cooldown_base = 5.0
			elif hatsu.forma == HatsuData.Forma.AREA:
				hatsu.raio = 65.0
				hatsu.duracao = 7.0

		HatsuData.ObjetivoPrincipal.CURA:
			hatsu.poder_base = 30.0 * mult_consumo
			hatsu.cura_base = hatsu.poder_base * 1.1
			hatsu.cooldown_base = 7.0
			hatsu.duracao = 4.0

		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			hatsu.poder_base = 25.0 * mult_consumo
			hatsu.velocidade_bonus = 100.0
			hatsu.duracao = 3.5
			hatsu.cooldown_base = 4.0
			hatsu.alcance = 140.0

		HatsuData.ObjetivoPrincipal.CONTROLE:
			hatsu.poder_base = 25.0 * mult_consumo
			hatsu.stun_duracao = 1.5
			hatsu.cooldown_base = 6.0
			hatsu.raio = 55.0

		HatsuData.ObjetivoPrincipal.SUPORTE:
			hatsu.poder_base = 25.0 * mult_consumo
			hatsu.duracao = 6.0
			hatsu.cooldown_base = 7.0

		HatsuData.ObjetivoPrincipal.DANO, _:
			match hatsu.categoria:
				HatsuData.Categoria.INTENSIFICACAO:
					match hatsu.forma:
						HatsuData.Forma.TOQUE:
							hatsu.poder_base = 50.0 * mult_consumo
							hatsu.cooldown_base = 3.2
							hatsu.alcance = 45.0
						HatsuData.Forma.PESSOAL:
							hatsu.poder_base = 35.0 * mult_consumo
							hatsu.cooldown_base = 4.5
						_:
							hatsu.poder_base = 38.0 * mult_consumo
							hatsu.cooldown_base = 3.5

				HatsuData.Categoria.TRANSFORMACAO:
					hatsu.poder_base = 35.0 * mult_consumo
					hatsu.cooldown_base = 3.2
					hatsu.duracao = 5.0

				HatsuData.Categoria.EMISSAO:
					hatsu.poder_base = 32.0 * mult_consumo
					hatsu.cooldown_base = 2.8
					hatsu.alcance = 180.0

				HatsuData.Categoria.CONJURACAO:
					hatsu.poder_base = 40.0 * mult_consumo
					hatsu.cooldown_base = 4.0
					hatsu.duracao = 7.0

				HatsuData.Categoria.MANIPULACAO:
					hatsu.poder_base = 28.0 * mult_consumo
					hatsu.cooldown_base = 3.5
					hatsu.duracao = 5.0

				HatsuData.Categoria.ESPECIALIZACAO:
					hatsu.poder_base = 42.0 * mult_consumo
					hatsu.cooldown_base = 5.5
					hatsu.duracao = 8.0


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
			h.activation_type = info.get("activation_type", HatsuData.ActivationType.INSTANT)
			h.duration_type = info.get("duration_type", HatsuData.DurationType.INSTANT)
			h.channel = info.get("channel", HatsuData.HatsuChannel.OFFENSIVE)
			h.exclusive_group = info.get("exclusive_group", "")
			h.concurrent_allowed = info.get("concurrent_allowed", true)
			h.aura_drain_per_sec = float(info.get("aura_drain_per_sec", 0.0))
			h.aura_drain_per_hit = float(info.get("aura_drain_per_hit", 0.0))
			h.skill_hunter_compatible = bool(info.get("skill_hunter_compatible", true))

			var typed_condicoes: Array[HatsuData.Condicao] = []
			for c in info.get("condicoes", []):
				typed_condicoes.append(c as HatsuData.Condicao)
			h.condicoes = typed_condicoes
			return h
	return null


# ============================================================
# MATRIZ CENTRAL DE COMPATIBILIDADE DE HATSU (COMPATIBILITY ENGINE)
# ============================================================

func can_activate(
	hatsu_alvo: HatsuData,
	active_sustained_list: Array,
	context: Dictionary = {}
) -> Dictionary:
	if hatsu_alvo == null:
		return {"allowed": false, "reason": "Habilidade inválida", "conflicting": ""}

	# 1. Zetsu Forçado ou Bloqueio de Nós de Nen
	if bool(context.get("in_zetsu", false)):
		return {"allowed": false, "reason": "❌ Em Zetsu forçado! Nós de Nen desligados.", "conflicting": "Zetsu"}
	if bool(context.get("nen_blocked", false)):
		return {"allowed": false, "reason": "❌ Nós de Nen sobreaquecidos!", "conflicting": "Sobrecarga"}

	# 2. Cooldown
	var cd_restante: float = float(context.get("cooldown", 0.0))
	if cd_restante > 0.0:
		return {"allowed": false, "reason": "⏳ Em tempo de recarga (%.1fs restantes)" % cd_restante, "conflicting": "Cooldown"}

	# 3. Custo de Aura
	var aura_atual: float = float(context.get("aura", 100.0))
	var custo_aura: float = hatsu_alvo.obter_custo_final()
	if aura_atual < custo_aura:
		return {"allowed": false, "reason": "⚡ Aura insuficiente (%d necessária)" % int(custo_aura), "conflicting": "Aura"}

	# 4. Condições e Juramentos do Hatsu
	var player_ctx: Dictionary = context.get("player_context", {})
	var target_ctx: Dictionary = context.get("target_context", {})
	var cond_check: Dictionary = hatsu_alvo.pode_usar(player_ctx, target_ctx)
	if not cond_check.get("pode", true):
		return {"allowed": false, "reason": cond_check.get("motivo", "Condição de Nen não atendida"), "conflicting": "Juramento"}

	# 5. Exclusividade e Matriz de Canais contra Habilidades Ativas
	var is_skill_hunter_override: bool = bool(context.get("is_skill_hunter_override", false))

	for active_entry in active_sustained_list:
		var active_h: HatsuData = active_entry.get("hatsu", null) if active_entry is Dictionary else active_entry as HatsuData
		if active_h == null or not is_instance_valid(active_h):
			continue

		# Regra A: Habilidade Instantânea sempre pode coexistir com Transformações e Sustentadas
		if hatsu_alvo.activation_type == HatsuData.ActivationType.INSTANT:
			continue

		# Regra B: Grupo Exclusivo idêntico (ex: "transformation_mode" entre Godspeed e Guanyin)
		if not hatsu_alvo.exclusive_group.is_empty() and hatsu_alvo.exclusive_group == active_h.exclusive_group:
			if not is_skill_hunter_override:
				return {
					"allowed": false,
					"reason": "❌ Incompatível: Outra transformação já está ativa (%s)!" % active_h.nome,
					"conflicting": active_h.nome
				}

		# Regra C: Transformação com Transformação (mesmo sem grupo explícito)
		if hatsu_alvo.activation_type == HatsuData.ActivationType.TRANSFORMATION and active_h.activation_type == HatsuData.ActivationType.TRANSFORMATION:
			if not is_skill_hunter_override and not (hatsu_alvo.concurrent_allowed and active_h.concurrent_allowed):
				return {
					"allowed": false,
					"reason": "❌ Duas transformações de Nen não podem coexistir simultaneamente (%s ativa)!" % active_h.nome,
					"conflicting": active_h.nome
				}

		# Regra D: Canal idêntico sem permissão de concorrência
		if hatsu_alvo.channel == active_h.channel and hatsu_alvo.channel != HatsuData.HatsuChannel.OFFENSIVE:
			if not (hatsu_alvo.concurrent_allowed and active_h.concurrent_allowed) and not is_skill_hunter_override:
				return {
					"allowed": false,
					"reason": "❌ Conflito de Canal de Nen com %s!" % active_h.nome,
					"conflicting": active_h.nome
				}

	return {"allowed": true, "reason": "", "conflicting": ""}


# ============================================================
# MECÂNICA DE ROUBO DE HATSU (CHROLLO / SKILL HUNTER)
# ============================================================

func processar_roubo_hatsu(
	book: HatsuBookData,
	enemy_info: Dictionary,
	condicoes_cumpridas: Array[String] = []
) -> Dictionary:
	if book == null:
		return {"sucesso": false, "motivo": "Grimório não disponível"}

	var nome_alvo: String = enemy_info.get("nome", "Inimigo")
	var hatsu_alvo: HatsuData = enemy_info.get("hatsu", null)
	if hatsu_alvo == null:
		return {"sucesso": false, "motivo": "%s não possui um Hatsu roubável!" % nome_alvo}

	# Validar restrições de aquisição do livro
	for req in book.restricoes_aquisicao:
		if not (req in condicoes_cumpridas):
			match req:
				"OBSERVAR_USO": return {"sucesso": false, "motivo": "Condição pendente: Você precisa ver o Hatsu sendo usado em combate!"}
				"DESCOBRIR_REGRAS": return {"sucesso": false, "motivo": "Condição pendente: Você precisa descobrir o nome e regras da técnica!"}
				"TOQUE_FISICO": return {"sucesso": false, "motivo": "Condição pendente: Requer tocar a palma da mão na capa do livro e no oponente!"}
				"RITUAL_TEMPO": return {"sucesso": false, "motivo": "Condição pendente: O tempo do ritual expirou!"}

	var nova_pagina: Dictionary = {
		"id": "stolen_" + hatsu_alvo.nome.to_lower().replace(" ", "_"),
		"nome": hatsu_alvo.nome,
		"categoria": hatsu_alvo.categoria,
		"usuario_original": nome_alvo,
		"descricao": "Hatsu roubado de %s e selado nas páginas do livro." % nome_alvo,
		"tags": hatsu_alvo.tags.duplicate() if not hatsu_alvo.tags.is_empty() else ["stolen"],
		"status_descoberta": "COMPLETO",
		"condicoes_descobertas": ["Habilidade roubada via Skill Hunter"],
		"eficiencia_base": 1.0,
		"hatsu_ref": hatsu_alvo
	}

	var adicionou = book.adicionar_pagina(nova_pagina)
	if not adicionou:
		return {"sucesso": false, "motivo": "O Grimório está com a capacidade máxima de páginas cheia!"}

	return {
		"sucesso": true,
		"motivo": "✨ HABILIDADE ROUBADA COM SUCESSO: %s foi adicionado ao Livro!" % hatsu_alvo.nome,
		"pagina": nova_pagina
	}


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


# ============================================================
# AQUISIÇÃO REAL & ROUBO DE HATSU (SKILL HUNTER ENGINE)
# ============================================================

func tentar_roubar_hatsu(usuario: Node, alvo: Node, hatsu_roubo: HatsuData, context: Dictionary = {}) -> Dictionary:
	if hatsu_roubo == null:
		return {"sucesso": false, "mensagem": "Hatsu de roubo inválido"}

	if alvo == null or not is_instance_valid(alvo):
		return {"sucesso": false, "mensagem": "Nenhum alvo selecionado para roubo"}

	# 1. Obter Hatsu real do alvo
	var alvo_hatsu: HatsuData = null
	var alvo_nome: String = alvo.name

	if alvo.has_node("EnemySystem"):
		var es = alvo.get_node("EnemySystem")
		if es.has_method("obter_hatsu_real"):
			alvo_hatsu = es.obter_hatsu_real()
		elif es.enemy_data != null and es.enemy_data.has_method("obter_hatsu_real"):
			alvo_hatsu = es.enemy_data.obter_hatsu_real()
		alvo_nome = es.enemy_name if not es.enemy_name.is_empty() else alvo.name
	elif alvo.has_method("obter_hatsu_slot"):
		alvo_hatsu = alvo.obter_hatsu_slot(0)
	elif alvo is CharacterBody2D and alvo.get_parent() != null and alvo.get_parent().has_node("EnemySystem"):
		var es2 = alvo.get_parent().get_node("EnemySystem")
		alvo_hatsu = es2.obter_hatsu_real()
		alvo_nome = es2.enemy_name

	if alvo_hatsu == null:
		return {"sucesso": false, "mensagem": "O alvo '%s' não possui nenhuma técnica de Nen para ser roubada!" % alvo_nome}

	# 2. Verificar Condições e Requisitos de Roubo configurados no Hatsu
	var condicoes_roubo = hatsu_roubo.steal_conditions
	var dist: float = 999.0
	if usuario is Node2D and alvo is Node2D:
		dist = usuario.global_position.distance_to(alvo.global_position)
	elif context.has("distance"):
		dist = float(context["distance"])

	for sc in condicoes_roubo:
		match str(sc):
			"TOUCH_REQUIRED":
				if dist > 55.0 and not context.get("toque_realizado", false):
					return {"sucesso": false, "mensagem": "Falha: Requer toque físico direto (Distância: %dpx > 55px)" % int(dist)}
			"OBSERVE_GYO":
				var viu: bool = context.get("observou_gyo", false) or context.get("gyo_ativo", false)
				if not viu:
					return {"sucesso": false, "mensagem": "Falha: É necessário testemunhar o Hatsu do oponente usando Gyo!"}
			"TARGET_EXPLAINS":
				var explicou: bool = context.get("alvo_explicou", false) or context.get("interrogado", false) or context.get("stagger", false)
				if not explicou:
					return {"sucesso": false, "mensagem": "Falha: O oponente precisa revelar ou explicar sua técnica!"}
			"TARGET_DEFEATED":
				var derrotado: bool = context.get("alvo_derrotado", false) or (alvo.has_node("EnemySystem") and alvo.get_node("EnemySystem").health <= 0)
				if not derrotado:
					return {"sucesso": false, "mensagem": "Falha: A técnica só pode ser extraída com o alvo derrotado!"}

	# 3. Criar cópia profunda do Hatsu original preservando todas as definições
	var hatsu_copiado: HatsuData = alvo_hatsu.duplicate(true)
	hatsu_copiado.usuario_original = alvo_nome
	hatsu_copiado.is_custom_created = false

	# 4. Determinar usos restantes conforme regra do livro
	var remaining_uses: int = -1
	if hatsu_roubo.storage_duration_type == "CHARGES":
		remaining_uses = 3
	elif hatsu_roubo.storage_duration_type == "TIMED":
		remaining_uses = 5

	# 5. Adicionar ao armazenamento do jogador
	var cap: int = hatsu_roubo.storage_capacity if hatsu_roubo.storage_capacity > 0 else 5
	var res_storage = PlayerData.adicionar_hatsu_armazenado(hatsu_copiado, alvo_nome, remaining_uses, cap)

	if not res_storage.get("sucesso", false):
		return {"sucesso": false, "mensagem": res_storage.get("mensagem", "Falha ao armazenar")}

	print("[HatsuManager] 🌟 ROUBO DE HATSU BEM-SUCEDIDO: %s capturou '%s' de %s!" % [usuario.name, hatsu_copiado.nome, alvo_nome])
	return {
		"sucesso": true,
		"mensagem": "📖 Hatsu Roubado: %s (%s)!" % [hatsu_copiado.nome, HatsuManager.obter_nome_categoria(hatsu_copiado.categoria)],
		"hatsu_roubado": hatsu_copiado,
		"alvo_nome": alvo_nome
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


# ============================================================
# MOTOR DE POWER BUDGET & SCORES (DEFINITIVE HATSU ENGINE)
# ============================================================

func calculate_power_budget(hatsu: HatsuData, player_context: Dictionary = {}) -> Dictionary:
	if hatsu == null:
		return {
			"budget_base": 100.0, "vows_multiplier": 1.0, "total_budget": 100.0,
			"budget_consumed": 50.0, "power_score": 50.0, "complexity_score": 10.0,
			"risk_score": 10.0, "efficiency_score": 50.0,
			"functional_power": 50.0, "limitation_credits": 50.0, "versatility_score": 10.0,
			"condition_credits": 0.0, "restriction_credits": 0.0, "vow_credits": 0.0, "preparation_credits": 0.0
		}

	var nivel: int = int(player_context.get("nivel", PlayerData.attributes.get("nivel", 1)))
	var nivel_nen: int = int(player_context.get("nivel_nen", PlayerData.attributes.get("nivel_nen", 1)))
	var afinidade_jogador = player_context.get("afinidade_nen", PlayerData.afinidade_nen)
	var afinidade_mult: float = 1.25 if afinidade_jogador == hatsu.categoria else (1.40 if afinidade_jogador == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO else 1.0)

	# 1. Orçamento Base
	var budget_base: float = 100.0 * (1.0 + (float(nivel - 1) * 0.04) + (float(nivel_nen) * 0.06)) * afinidade_mult

	# 2. Multiplicador de Votos, Condições, Restrições e Consequências
	var vows_multiplier: float = hatsu.obter_multiplicador_poder()
	var total_budget: float = budget_base * vows_multiplier

	# 3. Hatsu Creator v1.5 — Demanda Funcional vs Créditos de Limitação
	var functional_power: float = hatsu.calcular_functional_power()
	var limitation_credits: float = hatsu.calcular_limitation_credits()
	var versatility_score: float = hatsu.calcular_versatility_score()
	var credit_deficit: float = hatsu.credit_deficit

	# Orçamento Consumido pelos Parâmetros
	var core_info = HatsuComponentLibrary.get_core_info(hatsu.core_component as HatsuComponentLibrary.CoreType)
	var core_weight: float = float(core_info.get("budget_weight", 1.0))
	var budget_consumed: float = functional_power * core_weight

	# 4. Avaliação de Pontuações (Scores)
	var dmg: float = hatsu.custom_damage if hatsu.custom_damage > 0.0 else hatsu.poder_base
	var power_score: float = clamp((dmg / 120.0) * 100.0, 10.0, 350.0)
	var complexity_score: float = clamp(versatility_score, 10.0, 100.0)
	var risk_score: float = clamp((vows_multiplier - 1.0) * 80.0, 5.0, 100.0)
	var efficiency_score: float = clamp((limitation_credits / max(1.0, functional_power)) * 100.0, 10.0, 100.0)

	hatsu.power_score = power_score
	hatsu.complexity_score = complexity_score
	hatsu.risk_score = risk_score
	hatsu.efficiency_score = efficiency_score

	return {
		"budget_base": budget_base,
		"vows_multiplier": vows_multiplier,
		"total_budget": total_budget,
		"budget_consumed": budget_consumed,
		"power_score": power_score,
		"complexity_score": complexity_score,
		"risk_score": risk_score,
		"efficiency_score": efficiency_score,
		"functional_power": functional_power,
		"limitation_credits": limitation_credits,
		"versatility_score": versatility_score,
		"required_credits": functional_power,
		"available_credits": limitation_credits,
		"credit_deficit": credit_deficit,
		"condition_credits": hatsu.condition_credits,
		"restriction_credits": hatsu.restriction_credits,
		"vow_credits": hatsu.vow_credits,
		"preparation_credits": hatsu.preparation_credits
	}


# ============================================================
# VALIDADOR INTELIGENTE DE HATSU (HATSU VALIDATOR)
# ============================================================

func validate_hatsu(hatsu: HatsuData, player_context: Dictionary = {}) -> Dictionary:
	if hatsu == null:
		return {"status": "INVALID", "reason": "Definição de Hatsu vazia.", "excess_power": 0.0, "credit_deficit": 0.0, "sugestoes": []}

	var cd: float = hatsu.custom_cooldown if hatsu.custom_cooldown > 0.0 else hatsu.cooldown_base
	var cost: float = hatsu.custom_aura_cost if hatsu.custom_aura_cost > 0.0 else hatsu.custo_aura_base

	# Verificações de limites ilegais
	if cd < 0.2 and cost < 5.0:
		return {
			"status": "INVALID",
			"reason": "❌ Inválido: Cooldown e Custo de Aura excessivamente baixos. A lei de Nen exige compensação de esforço.",
			"excess_power": 999.0,
			"credit_deficit": 999.0,
			"sugestoes": obter_sugestoes_balanceamento(hatsu)
		}

	var pb = calculate_power_budget(hatsu, player_context)
	var functional_power: float = float(pb.get("functional_power", 50.0))
	var limitation_credits: float = float(pb.get("limitation_credits", 50.0))
	var deficit: float = float(pb.get("credit_deficit", max(0.0, functional_power - limitation_credits)))

	# Se a Demanda Funcional exceder os Créditos (Déficit > 0)
	if deficit > 0.0:
		return {
			"status": "OVERPOWERED",
			"reason": "⚠️ Déficit de Limitações: A demanda da técnica (%d pts) excede as limitações pagas (%d pts) em %d créditos. Adicione condições, restrições ou passos de preparação." % [int(functional_power), int(limitation_credits), int(deficit)],
			"excess_power": deficit,
			"credit_deficit": deficit,
			"required_credits": functional_power,
			"available_credits": limitation_credits,
			"functional_power": functional_power,
			"limitation_credits": limitation_credits,
			"sugestoes": obter_sugestoes_balanceamento(hatsu)
		}

	if limitation_credits > (functional_power * 2.2):
		return {
			"status": "INEFFICIENT",
			"reason": "💡 Super Limitado: Você impôs muitas restrições severas (%d créditos para %d de demanda)! Você tem créditos de sobra." % [int(limitation_credits), int(functional_power)],
			"excess_power": 0.0,
			"credit_deficit": 0.0,
			"required_credits": functional_power,
			"available_credits": limitation_credits,
			"functional_power": functional_power,
			"limitation_credits": limitation_credits,
			"sugestoes": []
		}

	return {
		"status": "VALID",
		"reason": "✨ Técnica 100% Equilibrada: As limitações pagam perfeitamente pelo poder funcional do Hatsu (Déficit: 0).",
		"excess_power": 0.0,
		"credit_deficit": 0.0,
		"required_credits": functional_power,
		"available_credits": limitation_credits,
		"functional_power": functional_power,
		"limitation_credits": limitation_credits,
		"sugestoes": []
	}


func obter_sugestoes_balanceamento(hatsu: HatsuData) -> Array[Dictionary]:
	var sugestoes: Array[Dictionary] = []
	if hatsu == null: return sugestoes

	var cd: float = hatsu.custom_cooldown if hatsu.custom_cooldown > 0.0 else hatsu.cooldown_base
	var cost: float = hatsu.custom_aura_cost if hatsu.custom_aura_cost > 0.0 else hatsu.custo_aura_base

	# 1. Sugerir Condições
	if not (HatsuData.Condicao.HP_ABAIXO_50 in hatsu.condicoes):
		sugestoes.append({"tipo": "CONDICAO", "texto": "[+] Adicionar Condição: Vida < 50% (+20 pts de crédito)", "acao": "adicionar_condicao", "valor": HatsuData.Condicao.HP_ABAIXO_50})
	if not (HatsuData.Condicao.CURTO_ALCANCE_EXTREMO in hatsu.condicoes) and hatsu.forma == HatsuData.Forma.TOQUE:
		sugestoes.append({"tipo": "CONDICAO", "texto": "[+] Adicionar Condição: Toque Físico Obrigatório (+25 pts de crédito)", "acao": "adicionar_condicao", "valor": HatsuData.Condicao.CURTO_ALCANCE_EXTREMO})

	# 2. Sugerir Restrições
	if not (HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU in hatsu.modular_restrictions):
		sugestoes.append({"tipo": "RESTRICAO", "texto": "[+] Adicionar Restrição: Travar outros 3 Hatsus (+30 pts de crédito)", "acao": "adicionar_restricao", "valor": HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU})
	if not (HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE in hatsu.modular_restrictions) and hatsu.duracao > 3.0:
		sugestoes.append({"tipo": "RESTRICAO", "texto": "[+] Adicionar Restrição: Ficar Imóvel durante o golpe (+40 pts de crédito)", "acao": "adicionar_restricao", "valor": HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE})

	# 3. Sugerir Passo de Preparação (Preparation Chain)
	if hatsu.preparation_steps.size() < 3:
		sugestoes.append({"tipo": "PREPARACAO", "texto": "[+] Adicionar Passo de Preparação Prévia (+25 pts de crédito)", "acao": "adicionar_passo_preparacao", "valor": "Passo tático prévio"})

	# 4. Sugerir Ajuste de Cooldown ou Custo
	if cd < 6.0:
		sugestoes.append({"tipo": "COOLDOWN", "texto": "[+] Aumentar Cooldown para 10.0s (+20 pts de crédito)", "acao": "ajustar_cooldown", "valor": 10.0})
	if cost < 35.0:
		sugestoes.append({"tipo": "AURA", "texto": "[+] Aumentar Consumo de Aura para 50 (+20 pts de crédito)", "acao": "ajustar_custo", "valor": 50.0})

	return sugestoes


# ============================================================
# MOTOR DE DEVOUR & ABSORÇÃO DE STATUS COM DIMINISHING RETURNS
# ============================================================

func execute_absorption_devour(
	hatsu: HatsuData,
	enemy_info: Dictionary,
	_player_context: Dictionary = {}
) -> Dictionary:
	if hatsu == null:
		return {"sucesso": false, "motivo": "Hatsu de absorção inválido"}

	var target_stat: String = hatsu.absorption_target_stat if not hatsu.absorption_target_stat.is_empty() else "aura_max"
	var enemy_id: String = str(enemy_info.get("enemy_id", enemy_info.get("id", "enemy")))
	var enemy_name: String = str(enemy_info.get("name", enemy_info.get("enemy_name", "Inimigo")))
	var enemy_level: int = int(enemy_info.get("level", 1))
	var is_boss: bool = bool(enemy_info.get("is_boss", false))

	# 1. Obter contagem de absorções anteriores para Diminishing Returns
	var registry: Dictionary = PlayerData.absorbed_stats_registry
	var times_absorbed: int = int(registry.get(enemy_id, 0))

	# 2. Calcular multiplicador de rendimento decrescente: 1.0 / (1.0 + 0.15 * N)
	var diminishing_mult: float = 1.0 / (1.0 + (0.15 * float(times_absorbed)))
	var boss_mult: float = 2.5 if is_boss else 1.0
	var rate: float = hatsu.absorption_rate if hatsu.absorption_rate > 0.0 else 0.05

	# 3. Ganho base proporcional ao nível e tipo do alvo
	var base_stat_pool: float = float(enemy_level * 10) if target_stat == "aura_max" else float(enemy_level * 2)
	var stat_gain: int = max(1, int(round(base_stat_pool * rate * diminishing_mult * boss_mult)))

	# 4. Registrar absorção permanente no PlayerData
	registry[enemy_id] = times_absorbed + 1
	PlayerData.absorbed_stats_registry = registry

	var cur_val = PlayerData.attributes.get(target_stat, 10)
	PlayerData.attributes[target_stat] = cur_val + stat_gain
	PlayerData.recalcular_todos_atributos()

	var msg = "🧬 PREDADOR: Absorveu +%d de %s de %s (Absorção #%d, Eficiência: %d%%)" % [
		stat_gain, target_stat.to_upper(), enemy_name, times_absorbed + 1, int(diminishing_mult * 100)
	]
	print("[Hatsu Devour Engine] ", msg)

	return {
		"sucesso": true,
		"stat_modificado": target_stat,
		"valor_ganho": stat_gain,
		"times_absorbed": times_absorbed + 1,
		"mensagem": msg
	}


# ============================================================
# CRIADOR DE TEMPLATES CANÔNICOS MODULARES DATA-DRIVEN
# ============================================================

func create_hatsu_template(template_id: String) -> HatsuData:
	var h := HatsuData.new()
	h.is_custom_created = false
	h.hatsu_version = 2

	match template_id.to_lower():
		"jajanken_pedra", "gon_jajanken_pedra":
			h.nome = "Jajanken: Pedra (Rock)"
			h.categoria = HatsuData.Categoria.INTENSIFICACAO
			h.core_component = HatsuComponentLibrary.CoreType.STRIKE
			h.forma = HatsuData.Forma.TOQUE
			h.objetivo = HatsuData.ObjetivoPrincipal.DANO
			h.activation_type = HatsuData.ActivationType.CHARGED
			h.modular_conditions = [HatsuComponentLibrary.ConditionType.STATIONARY_CHANNEL]
			h.modular_restrictions = [HatsuComponentLibrary.RestrictionType.CANNOT_DODGE]
			h.custom_damage = 150.0
			h.custom_aura_cost = 45.0
			h.custom_cooldown = 14.0
			h.custom_range = 40.0
			h.tags = ["impact", "heavy", "charged"]
			h.usuario_original = "Gon Freecss"

		"jajanken_tesoura", "gon_jajanken_tesoura":
			h.nome = "Jajanken: Tesoura (Scissors)"
			h.categoria = HatsuData.Categoria.TRANSFORMACAO
			h.core_component = HatsuComponentLibrary.CoreType.STRIKE
			h.forma = HatsuData.Forma.TOQUE
			h.objetivo = HatsuData.ObjetivoPrincipal.DANO
			h.activation_type = HatsuData.ActivationType.INSTANT
			h.effect_modules = [{"type": HatsuComponentLibrary.EffectType.PIERCING, "value": 30.0}]
			h.custom_damage = 85.0
			h.custom_aura_cost = 28.0
			h.custom_cooldown = 8.0
			h.custom_range = 50.0
			h.tags = ["blade", "slash", "piercing"]
			h.usuario_original = "Gon Freecss"

		"jajanken_papel", "gon_jajanken_papel":
			h.nome = "Jajanken: Papel (Paper)"
			h.categoria = HatsuData.Categoria.EMISSAO
			h.core_component = HatsuComponentLibrary.CoreType.PROJECTILE
			h.forma = HatsuData.Forma.PROJETIL
			h.objetivo = HatsuData.ObjetivoPrincipal.DANO
			h.activation_type = HatsuData.ActivationType.INSTANT
			h.custom_damage = 65.0
			h.custom_aura_cost = 22.0
			h.custom_cooldown = 6.0
			h.custom_range = 180.0
			h.tags = ["projectile", "ranged"]
			h.usuario_original = "Gon Freecss"

		"godspeed", "killua_kanmuru":
			h.nome = "Godspeed (Kanmuru)"
			h.categoria = HatsuData.Categoria.TRANSFORMACAO
			h.core_component = HatsuComponentLibrary.CoreType.TRANSFORMATION
			h.forma = HatsuData.Forma.PESSOAL
			h.objetivo = HatsuData.ObjetivoPrincipal.MOBILIDADE
			h.activation_type = HatsuData.ActivationType.TRANSFORMATION
			h.duration_type = HatsuData.DurationType.TIMED
			h.channel = HatsuData.HatsuChannel.TRANSFORMATION
			h.exclusive_group = "transformation_mode"
			h.concurrent_allowed = false
			h.aura_drain_per_sec = 2.0
			h.aura_drain_per_hit = 12.0
			h.custom_damage = 65.0
			h.custom_duration = 10.0
			h.custom_aura_cost = 35.0
			h.custom_cooldown = 15.0
			h.effect_modules = [{"type": HatsuComponentLibrary.EffectType.STAT_MOD, "param": "velocidade", "value": 100.0}]
			h.tags = ["electricity", "speed", "transformation"]
			h.usuario_original = "Killua Zoldyck"

		"netero_guanyin", "guanyin":
			h.nome = "100-Type Guanyin Bodhisattva"
			h.categoria = HatsuData.Categoria.CONJURACAO
			h.core_component = HatsuComponentLibrary.CoreType.SUMMON
			h.forma = HatsuData.Forma.PESSOAL
			h.objetivo = HatsuData.ObjetivoPrincipal.DANO
			h.activation_type = HatsuData.ActivationType.TRANSFORMATION
			h.duration_type = HatsuData.DurationType.TIMED
			h.channel = HatsuData.HatsuChannel.TRANSFORMATION
			h.exclusive_group = "transformation_mode"
			h.concurrent_allowed = false
			h.modular_conditions = [HatsuComponentLibrary.ConditionType.STATIONARY_CHANNEL]
			h.aura_drain_per_sec = 3.0
			h.aura_drain_per_hit = 20.0
			h.custom_damage = 100.0
			h.custom_duration = 12.0
			h.custom_aura_cost = 40.0
			h.custom_cooldown = 18.0
			h.tags = ["summon", "barrage", "prayer"]
			h.usuario_original = "Isaac Netero"

		"predador_vital", "devour_template":
			h.nome = "Banquete do Predador (Devour)"
			h.categoria = HatsuData.Categoria.ESPECIALIZACAO
			h.core_component = HatsuComponentLibrary.CoreType.ABSORPTION
			h.forma = HatsuData.Forma.TOQUE
			h.objetivo = HatsuData.ObjetivoPrincipal.SUPORTE
			h.activation_type = HatsuData.ActivationType.INSTANT
			h.modular_conditions = [HatsuComponentLibrary.ConditionType.ENEMY_DEFEATED, HatsuComponentLibrary.ConditionType.SOLO_COMBAT]
			h.modular_restrictions = [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED]
			h.modular_drawbacks = [HatsuComponentLibrary.DrawbackType.AURA_REGEN_LOCKED_10S]
			h.absorption_target_stat = "aura_max"
			h.absorption_rate = 0.06
			h.custom_aura_cost = 50.0
			h.custom_cooldown = 20.0
			h.tags = ["absorption", "devour", "permanent_growth"]
			h.usuario_original = "Especialista Predador"

		"ultima_chance", "rollback_template":
			h.nome = "Última Chance (Reversão Vital)"
			h.categoria = HatsuData.Categoria.ESPECIALIZACAO
			h.core_component = HatsuComponentLibrary.CoreType.MEMORY_ROLLBACK
			h.forma = HatsuData.Forma.PESSOAL
			h.objetivo = HatsuData.ObjetivoPrincipal.DEFESA
			h.activation_type = HatsuData.ActivationType.SUSTAINED
			h.duration_type = HatsuData.DurationType.TIMED
			h.modular_conditions = [HatsuComponentLibrary.ConditionType.HP_BELOW_20]
			h.modular_restrictions = [HatsuComponentLibrary.RestrictionType.ONCE_PER_COMBAT]
			h.rollback_seconds = 6.0
			h.custom_duration = 10.0
			h.custom_aura_cost = 60.0
			h.custom_cooldown = 30.0
			h.tags = ["temporal", "rollback", "safety"]
			h.usuario_original = "Especialista do Tempo"

		_:
			# Fallback padrão
			h.nome = template_id.capitalize()
			h.core_component = HatsuComponentLibrary.CoreType.STRIKE
			h.poder_base = 50.0
			h.custo_aura_base = 25.0
			h.cooldown_base = 4.0

	calculate_power_budget(h)
	return h
