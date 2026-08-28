class_name ParallelQuestCatalog
extends Resource

# ============================================================
# HUNTER ONLINE - PARALLEL QUEST CATALOG (220 MISSÕES WHAT-IF & FARM)
# ============================================================
#
# Catálogo completo e balanceado das 220 Missões Paralelas e Secundárias:
# - Arco 1: 287º Exame Hunter (PQs 01 a 22) — 22 Missões
# - Arco 2: Montanha Kukuroo (PQs 23 a 38) — 16 Missões
# - Arco 3: Arena Celestial (PQs 39 a 62) — 24 Missões
# - Arco 4: Yorknew City (PQs 63 a 94) — 32 Missões
# - Arco 5: Greed Island (PQs 95 a 128) — 34 Missões
# - Arco 6: Formigas Chimera (PQs 129 a 170) — 42 Missões
# - Arco 7: Eleição Hunter (PQs 171 a 184) — 14 Missões
# - Arco 8: Continente Negro (PQs 185 a 200) — 16 Missões
# - Arco 9: Guerra de Sucessão Kakin (PQs 201 a 220) — 20 Missões
#
# Tiers:
# Tier 1 (1 Estrela): Nível 1–25, HP 400–4.000, XP 1.500–10.000, Gold 10k–60k
# Tier 2 (2 Estrelas): Nível 25–45, HP 4.000–15.000, XP 12.000–35.000, Gold 70k–200k
# Tier 3 (3 Estrelas): Nível 45–70, HP 15.000–50.000, XP 40.000–120.000, Gold 250k–1.2M
# Tier 4 (4 Estrelas): Nível 70–90, HP 50.000–150.000, XP 150.000–450.000, Gold 1.5M–6M
# Tier 5 (5 Estrelas): Nível 90–100, HP 150.000–400.000, XP 500.000–1.5M, Gold 8M–30M
#
# ============================================================

static var _cache_missoes: Array[Dictionary] = []


static func obter_todas_missoes() -> Array[Dictionary]:
	if not _cache_missoes.is_empty():
		return _cache_missoes

	var lista: Array[Dictionary] = []

	# =========================================================
	# ARCO 1: EXAME HUNTER (PQs 01 a 22)
	# =========================================================
	_adicionar_arco_1(lista)

	# =========================================================
	# ARCO 2: MONTANHA KUKUROO (PQs 23 a 38)
	# =========================================================
	_adicionar_arco_2(lista)

	# =========================================================
	# ARCO 3: ARENA CELESTIAL (PQs 39 a 62)
	# =========================================================
	_adicionar_arco_3(lista)

	# =========================================================
	# ARCO 4: YORKNEW CITY (PQs 63 a 94)
	# =========================================================
	_adicionar_arco_4(lista)

	# =========================================================
	# ARCO 5: GREED ISLAND (PQs 95 a 128)
	# =========================================================
	_adicionar_arco_5(lista)

	# =========================================================
	# ARCO 6: FORMIGAS CHIMERA (PQs 129 a 170)
	# =========================================================
	_adicionar_arco_6(lista)

	# =========================================================
	# ARCO 7: ELEIÇÃO HUNTER (PQs 171 a 184)
	# =========================================================
	_adicionar_arco_7(lista)

	# =========================================================
	# ARCO 8: CONTINENTE NEGRO (PQs 185 a 200)
	# =========================================================
	_adicionar_arco_8(lista)

	# =========================================================
	# ARCO 9: GUERRA DE SUCESSÃO KAKIN (PQs 201 a 220)
	# =========================================================
	_adicionar_arco_9(lista)

	_cache_missoes = lista
	return _cache_missoes


static func obter_missao_por_id(id: int) -> Dictionary:
	var todas := obter_todas_missoes()
	for m in todas:
		if m.get("id", -1) == id:
			return m
	return {}


static func obter_missoes_do_arco(arco: int) -> Array[Dictionary]:
	var todas := obter_todas_missoes()
	var resultado: Array[Dictionary] = []
	for m in todas:
		if m.get("arco_requerido", 1) == arco:
			resultado.append(m)
	return resultado


static func _adicionar_arco_1(lista: Array[Dictionary]) -> void:
	# PQs 01 a 22
	var nomes_pqs_1 := [
		"O Duelo Real do Túnel", "O Banquete Sombrio de Hisoka", "A Fúria Gourmet de Menchi",
		"A Provação de Trick Tower", "A Caçada de Placas na Ilha Zevil", "O Veneno Oculto de Tonpa",
		"O Teste de Velocidade de Hanzo", "As Feras do Pântano Numere", "A Armadilha de Gás de Ponzu",
		"O Desafio Marcial de Bodoro", "O Ataque dos Sabotadores", "A Ravina dos Ovos de Águia",
		"O Enigma das Velas de Sedokan", "A Fera de Johness o Estripador", "A Emboscada de Gittarackur",
		"O Confronto Noturno do Dirigível", "A Caçada dos Competidores de Elite", "O Nevoeiro das Feras Ilusórias",
		"A Sobrevivência na Caverna das Serpentes", "O Golpe de Pesca na Floresta", "O Exame dos Três Amigos",
		"A Graduação Antecipada do Exame"
	]
	for i in range(nomes_pqs_1.size()):
		var id := i + 1
		var stars := 1 if id <= 12 else 2
		var hp_base := 450 + (id * 180)
		var forca := 15 + (id * 2)
		var def := 8 + int(id * 1.5)
		var xp := 1500 + (id * 300)
		var gold := 10000 + (id * 2500)
		
		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_1[i]],
			"saga_nome": "Exame Hunter",
			"arco_requerido": 1,
			"stars": stars,
			"subtitulo": "What-If: Exame Hunter",
			"what_if_lore": "Fenda temporal: Cenário alternativo durante a etapa do Exame Hunter envolvendo desafios e competidores reforçados!",
			"inimigos_descricao": "Competidores de Zaban e Criaturas da Prova",
			"waves": [
				{"nome": "Candidato Desafiante", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 3, "cor": Color(0.3, 0.7, 0.4)},
				{"nome": "Chefe da Prova %d" % id, "hp": hp_base * 3, "defesa": def + 6, "forca": forca + 8, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(0.9, 0.3, 0.3)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "pocao_hp", "qtd": 2}],
			"reward_materials": [{"id": "tecido_hunter", "nome": "Tecido do Exame Hunter", "qtd": 1}]
		})


static func _adicionar_arco_2(lista: Array[Dictionary]) -> void:
	# PQs 23 a 38
	var nomes_pqs_2 := [
		"Invasão dos Mordomos Zoldyck", "O Desafio de Moedas de Gotoh", "A Fúria do Cão Mike",
		"O Treino dos Pesos de 100kg", "A Guarda Secreta de Canary", "O Julgamento de Silva Zoldyck",
		"A Fuga pela Alameda das Árvores", "Os Guardas da Porta dos Invasores", "O Duelo dos Aprendizes de Mordomo",
		"A Vigilância Eletrônica de Milluki", "A Lâmina Oculta de Kikyo", "O Labirinto dos Penhascos de Kukuroo",
		"O Banquete de Sangue de Mike", "A Barreira Intransponível de Gotoh", "O Pacto de Amizade de Killua",
		"A Liberação Suprema de Padokia"
	]
	for i in range(nomes_pqs_2.size()):
		var id := 23 + i
		var stars := 2
		var hp_base := 2500 + (i * 350)
		var forca := 35 + (i * 3)
		var def := 22 + int(i * 2.0)
		var xp := 6000 + (i * 600)
		var gold := 50000 + (i * 5000)
		
		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_2[i]],
			"saga_nome": "Montanha Kukuroo",
			"arco_requerido": 2,
			"stars": stars,
			"subtitulo": "What-If: Mansão Zoldyck",
			"what_if_lore": "Fenda temporal: Conflito paralelo nos domínios do Clã Zoldyck com guardas e feras de elite!",
			"inimigos_descricao": "Mordomos de Elite e Feras Zoldyck",
			"waves": [
				{"nome": "Mordomo de Combate", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 3, "cor": Color(0.2, 0.2, 0.4)},
				{"nome": "Elite de Kukuroo", "hp": hp_base * 3, "defesa": def + 8, "forca": forca + 10, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(0.8, 0.2, 0.2)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "pocao_hp_grande", "qtd": 2}],
			"reward_materials": [{"id": "aco_zoldyck", "nome": "Liga de Aço Zoldyck", "qtd": 1}]
		})


static func _adicionar_arco_3(lista: Array[Dictionary]) -> void:
	# PQs 39 a 62
	var nomes_pqs_3 := [
		"O Batismo do 200º Andar", "O Balé dos 50 Piões de Gido", "A Cadeira Supersônica de Riehlvelt",
		"O Tigre Duplo de Kastro", "O Duelo Sangrento de Hisoka", "O Teste de Água de Mestre Wing",
		"A Fúria de Zushi Shingen-ryu", "A Barreira dos Mestres de Andar", "O Torneio Relâmpago do Andar 100",
		"Os Trapaceiros dos Andares 150", "O Despertar do Ten Supremo", "O Encontro dos Refinadores de Ren",
		"A Batalha das Projeções de Nen", "O Ringue Lotado da Meia-Noite", "A Dança das Cartas Cortantes",
		"O Treinamento Ocular de Gyo", "A Muralha de Aura do Mestre de Andar", "O Desafio do Punho de Tigre",
		"O Combate Noturno no Topo da Torre", "O Clímax do 200º Andar", "O Retorno do Trapaceiro Sadaso",
		"A Luta de Exibição de Hisoka", "A Iniciação de Nen Avançada", "A Consagração do Mestre da Torre"
	]
	for i in range(nomes_pqs_3.size()):
		var id := 39 + i
		var stars := 2 if i < 12 else 3
		var hp_base := 5000 + (i * 550)
		var forca := 55 + (i * 3)
		var def := 35 + int(i * 2.5)
		var xp := 15000 + (i * 900)
		var gold := 120000 + (i * 10000)
		
		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_3[i]],
			"saga_nome": "Arena Celestial",
			"arco_requerido": 3,
			"stars": stars,
			"subtitulo": "What-If: 200º Andar",
			"what_if_lore": "Fenda temporal: Torneio supremo e lutadores de Nen dos andares mais altos da Arena Celestial!",
			"inimigos_descricao": "Lutadores de Nen e Mestres de Andar",
			"waves": [
				{"nome": "Lutador do 200º Andar", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 3, "cor": Color(0.6, 0.4, 0.8)},
				{"nome": "Campeão da Arena", "hp": hp_base * 3, "defesa": def + 10, "forca": forca + 12, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(1.0, 0.3, 0.6)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "fragmento_nen", "qtd": 2}],
			"reward_materials": [{"id": "placa_arena", "nome": "Medalha de Mestre da Arena", "qtd": 1}]
		})


static func _adicionar_arco_4(lista: Array[Dictionary]) -> void:
	# PQs 63 a 94
	var nomes_pqs_4 := [
		"O Julgamento de Uvogin", "A Tempestade de Fogo de Feitan", "O Vácuo Mortal de Shizuku",
		"O Réquiem da Trupe Fantasma", "A Caçada dos Guarda-Costas Nostrade", "A Melodia Noturna de Melody",
		"O Deserto de Gordeau sob Ataque", "As Feras das Sombras (Inju)", "O Massacre do Edifício Cemitério",
		"O Apagão na Estação de Yorknew", "A Troca de Reféns no Aeroporto", "A Vingança de Pakunoda",
		"O Livro Secreto de Chrollo", "A Batalha dos 10 Padrinhos da Máfia", "Os Fios Cortantes de Machi",
		"A Espada Iai de Nobunaga", "A Força Titânica de Phinks", "A Metralhadora de Franklin",
		"A Farsa dos Corpos de Kortopi", "A Prisão da Corrente de Kurapika", "A Caçada Noturna nas Avenidas",
		"O Leilão Clandestino Sob Fogo", "A Fuga do Balão de Gás", "O Encontro Secreto com Hisoka",
		"O Golpe nos Cofres Subterrâneos", "A Vingança do Clã Kurta", "A Sombra dos Assassinos Zoldyck",
		"O Duelo no Prédio em Chamas", "A Caverna Abandonada da Aranha", "A Sentença da Corrente Sagrada",
		"A Aliança de Leorio e Melody", "O Fim do Réquiem de Yorknew"
	]
	for i in range(nomes_pqs_4.size()):
		var id := 63 + i
		var stars := 3
		var hp_base := 12000 + (i * 900)
		var forca := 80 + (i * 4)
		var def := 50 + int(i * 3.0)
		var xp := 35000 + (i * 1300)
		var gold := 350000 + (i * 18000)
		
		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_4[i]],
			"saga_nome": "Yorknew City",
			"arco_requerido": 4,
			"stars": stars,
			"subtitulo": "What-If: Trupe Fantasma",
			"what_if_lore": "Fenda temporal: Confronto violento pelas ruas e prédios de Yorknew contra a Aranha e a Máfia!",
			"inimigos_descricao": "Membros da Aranha e Soldados da Máfia",
			"waves": [
				{"nome": "Guarda Mafioso Corrompido", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 4, "cor": Color(0.3, 0.3, 0.3)},
				{"nome": "Executor da Aranha", "hp": hp_base * 3, "defesa": def + 12, "forca": forca + 15, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(0.9, 0.1, 0.1)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "pocao_hp_grande", "qtd": 3}],
			"reward_materials": [{"id": "tecido_reforcado", "nome": "Tecido com Fibras de Nen", "qtd": 2}]
		})


static func _adicionar_arco_5(lista: Array[Dictionary]) -> void:
	# PQs 95 a 128
	var nomes_pqs_5 := [
		"O Treinamento Físico de Biscuit", "A Queimada Mortal de Razor", "O Terror Explosivo de Genthru",
		"O Duelo de Feitiços de Greed", "A Caçada pelas 100 Cartas", "Os 14 Demônios de Soufrabi",
		"O Desafio do Farol de Razor", "A Força Oculta dos Yo-yos de Killua", "O Jajanken Perfeito de Gon",
		"A Aliança de Tsezguerra e Goreinu", "Os Monstros Mágicos das Montanhas", "A Batalha de Antokiba",
		"O Enigma da Faixa de Praia", "A Fortaleza dos Bandidos de JoyStation", "O Torneio de Cartas Designadas",
		"A Farsa de Hisoka na Ilha", "O Sopro do Arcanjo Supremo", "A Fuga dos Feitiços de Roubo",
		"A Verdadeira Forma de Biscuit Krueger", "A Mina Explosiva de Sub e Bara", "O Ringue de Cimento da Queimada",
		"A Defesa com Bungee Gum", "A Caçada ao Dragão da Montanha", "O Desafio do Castelo de Conclusão",
		"A Floresta das Cartas de Bolso", "O Golpe de Ko na Rocha Maciça", "A Batalha dos Veteranos de Battera",
		"O Resgate das Cartas Secretas", "A Armadilha de Pedra de Gon", "O Voo Dimensional com Accompany",
		"O Encontro com os Criadores de Greed", "A Vitória das 100 Cartas", "O Desafio dos Piratas de Soufrabi",
		"A Glória Final do JoyStation"
	]
	for i in range(nomes_pqs_5.size()):
		var id := 95 + i
		var stars := 3 if i < 18 else 4
		var hp_base := 25000 + (i * 1400)
		var forca := 120 + (i * 5)
		var def := 75 + int(i * 3.5)
		var xp := 75000 + (i * 2200)
		var gold := 900000 + (i * 45000)
		
		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_5[i]],
			"saga_nome": "Greed Island",
			"arco_requerido": 5,
			"stars": stars,
			"subtitulo": "What-If: Greed Island",
			"what_if_lore": "Fenda temporal: Batalhas intensas na ilha virtual envolvendo feitiços, monstros mágicos e os criadores do jogo!",
			"inimigos_descricao": "Criaturas Mágicas e Mestres de Jogo",
			"waves": [
				{"nome": "Demônio de Greed", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 4, "cor": Color(0.2, 0.6, 0.8)},
				{"nome": "Chefe da Ilha JoyStation", "hp": hp_base * 3, "defesa": def + 15, "forca": forca + 18, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(1.0, 0.5, 0.1)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "cristal_aura", "qtd": 2}],
			"reward_materials": [{"id": "carta_magica", "nome": "Fragmento de Carta de Greed", "qtd": 2}]
		})


static func _adicionar_arco_6(lista: Array[Dictionary]) -> void:
	# PQs 129 a 170
	var nomes_pqs_6 := [
		"A Fúria de Neferpitou", "A Fumaça Impenetrável de Morel", "O Juros do A.P.R. de Knuckle",
		"O Voo das Mãos de Shoot", "A Velocidade Divina de Killua (Godspeed)", "A Explosão Vulcânica de Youpi",
		"A Ilusão Fotônica de Shaiapouf", "O Buda Dourado de Netero", "A Mão Zero do Presidente",
		"O Juramento Supremo de Gon Adulto", "O Rei Meruem no Auge", "A Patrulha Noturna de NGL",
		"A Fábrica Clandestina de Gyro", "O Crazy Slots Mortal de Kite", "A Inseminação de Nen no Ninho",
		"A Batalha das Escadarias do Palácio", "A Chuva de Dragões de Zeno", "O Esconderijo Dimensional de Knov",
		"A Fuga pela Fronteira de Peijin", "O Ataque dos Esquadrões Quimera", "A Fera Alada de Rammot",
		"O Confronto no Subsolo da Tumba", "A Rosa Pobre Nuclear", "O Gungi no Escuro com Komugi",
		"A Redenção das Formigas Humanas", "A Invasão das Formigas Soldado", "O Rugido de Youpi Centauro",
		"O Casulo de Fumaça Espiritual", "A Caçada às Marionetes de Pitou", "A Vingança pelos Caçadores Caídos",
		"O Impacto do Jajanken Titânico", "A Defesa do Hospital de Peijin", "A Guarda Real Unida",
		"O Confronto das Três Guardas", "A Barreira de En de Neferpitou", "O Banquete Carnívoro da Rainha",
		"A Emboscada na Floresta de NGL", "A Luz Fotônica do Rei Ressuscitado", "O Teste de Determinação de Morel",
		"O Resgate de Gon nos Braços de Killua", "O Desfecho Trágico da Colmeia", "A Lenda Suprema dos Exterminadores"
	]
	for i in range(nomes_pqs_6.size()):
		var id := 129 + i
		var stars := 4 if i < 25 else 5
		var hp_base := 55000 + (i * 2500)
		var forca := 180 + (i * 6)
		var def := 110 + int(i * 4.0)
		var xp := 150000 + (i * 4800)
		var gold := 2500000 + (i * 110000)
		
		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_6[i]],
			"saga_nome": "Formigas Chimera",
			"arco_requerido": 6,
			"stars": stars,
			"subtitulo": "What-If: Formigas Chimera",
			"what_if_lore": "Fenda temporal: Batalhas catastróficas contra o exército de Formigas Quimera e a Guarda Real!",
			"inimigos_descricao": "Formigas Quimera e Guardas Reais",
			"waves": [
				{"nome": "Formiga Quimera de Elite", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 4, "cor": Color(0.8, 0.2, 0.5)},
				{"nome": "Comandante Quimera", "hp": hp_base * 3, "defesa": def + 20, "forca": forca + 25, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(0.9, 0.1, 0.3)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "cristal_aura", "qtd": 3}],
			"reward_materials": [{"id": "exoesqueleto_quimera", "nome": "Carapaça de Formiga Quimera", "qtd": 2}]
		})


static func _adicionar_arco_7(lista: Array[Dictionary]) -> void:
	# PQs 171 a 184
	var nomes_pqs_7 := [
		"O Testamento dos 12 Zodíacos", "A Conspiração de Pariston Hill", "A Masmorra de Alluka Zoldyck",
		"O Poder Milagroso de Nanika", "A Perseguição de Illumi na Rodovia", "O Exército de Homens-Agulha",
		"O Soco Teleportado de Leorio", "A Votação Presidencial da Sede", "A Cura de Gon no Hospital",
		"A Fuga de Killua e Alluka", "A Sabotagem dos Dirigíveis Hunter", "O Debate dos Zodíacos",
		"A Eleição da 13ª Presidente Cheadle", "A Despedida dos Quatro Companheiros"
	]
	for i in range(nomes_pqs_7.size()):
		var id := 171 + i
		var stars := 4
		var hp_base := 85000 + (i * 3500)
		var forca := 240 + (i * 7)
		var def := 150 + int(i * 5.0)
		var xp := 250000 + (i * 14000)
		var gold := 4000000 + (i * 350000)
		
		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_7[i]],
			"saga_nome": "Eleição Hunter",
			"arco_requerido": 7,
			"stars": stars,
			"subtitulo": "What-If: Associação Hunter",
			"what_if_lore": "Fenda temporal: Conflito político e emboscadas de assassinos durante a eleição dos Zodíacos!",
			"inimigos_descricao": "Agentes Manipulados e Assassinos de Illumi",
			"waves": [
				{"nome": "Homem-Agulha Manipulado", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 6, "cor": Color(0.4, 0.4, 0.4)},
				{"nome": "Agente de Elite dos Zodíacos", "hp": hp_base * 3, "defesa": def + 22, "forca": forca + 28, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(0.2, 0.5, 0.9)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "cristal_aura", "qtd": 4}],
			"reward_materials": [{"id": "agulha_illumi", "nome": "Agulha de Nen de Illumi", "qtd": 2}]
		})


static func _adicionar_arco_8(lista: Array[Dictionary]) -> void:
	# PQs 185 a 200
	var nomes_pqs_8 := [
		"A Expedição Proibida de Beyond", "As Calamidades do Continente Negro", "A Calamidade Botânica Brion",
		"O Veneno Homicida de Hellbell", "A Entidade Gasosa Ai", "A Doença Zobae da Imortalidade",
		"A Besta Papu que Alimenta Desejos", "A Árvore do Mundo de 1.784 Metros", "O Diálogo Filosófico de Ging",
		"O Lago Mobius e os Guardiões", "O Ninho das Feras Continentais", "A Tempestade do Novo Mundo",
		"A Caçada ao Arroz Nitro Ancestral", "A Escalada Acima das Nuvens", "O Mapa dos Horizontes Infinitos",
		"A Herança Lendária de Don Freecss"
	]
	for i in range(nomes_pqs_8.size()):
		var id := 185 + i
		var stars := 5
		var hp_base := 140000 + (i * 6500)
		var forca := 320 + (i * 10)
		var def := 210 + int(i * 7.0)
		var xp := 450000 + (i * 22000)
		var gold := 7000000 + (i * 500000)
		
		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_8[i]],
			"saga_nome": "Continente Negro",
			"arco_requerido": 8,
			"stars": stars,
			"subtitulo": "What-If: Continente Negro",
			"what_if_lore": "Fenda temporal: Sobrevivência extrema contra as 5 Grandes Calamidades além do mundo conhecido!",
			"inimigos_descricao": "Calamidades Ancestrais e Guardiões de Brion",
			"waves": [
				{"nome": "Guardião Ancestral do Continente", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 4, "cor": Color(0.1, 0.7, 0.4)},
				{"nome": "Calamidade Suprema", "hp": hp_base * 3, "defesa": def + 30, "forca": forca + 35, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(0.9, 0.8, 0.1)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "cristal_aura", "qtd": 5}],
			"reward_materials": [{"id": "semente_nitro", "nome": "Semente de Arroz Nitro Ancestral", "qtd": 2}]
		})


static func _adicionar_arco_9(lista: Array[Dictionary]) -> void:
	# PQs 201 a 220
	var nomes_pqs_9 := [
		"O Embarque no Navio Black Whale 1", "O Ritual da Urna Sagrada de Kakin", "O Stealth Dolphin de Kurapika",
		"A Besta Guardiã de Tserriednich", "O Zetsu dos 10 Segundos no Futuro", "A Seita Mafiosa de Morena Prudo",
		"O Hatsu Biohazard de Hinrigh", "A Caçada da Trupe Fantasma no Convés 5", "O Rastro de Goma de Hisoka",
		"A Proteção da Rainha Oito e Woble", "A Batalha dos Conveses de Carga", "O Massacre da Família Heil-Ly",
		"O Duelo da Trupe nos Porões", "A Revolta Militar dos Guardas Reais", "A Besta Parasita de Dupla Face",
		"O Emperor Time com Todas as Correntes", "A Conspiração do Trono Imperial de Kakin", "A Salvação do Príncipe Herdeiro",
		"A Batalha dos Mestres de Nen no Oceano", "O Boss Rush Supremo: A Lenda Imortal Hunter"
	]
	for i in range(nomes_pqs_9.size()):
		var id := 201 + i
		var stars := 5
		var hp_base := 220000 + (i * 9000)
		var forca := 420 + (i * 12)
		var def := 280 + int(i * 8.0)
		var xp := 700000 + (i * 40000)
		var gold := 12000000 + (i * 900000)
		
		# Boss Rush Supremo (PQ 220)
		if id == 220:
			hp_base = 400000
			forca = 750
			def = 450
			xp = 1500000
			gold = 30000000

		lista.append({
			"id": id,
			"title": "PQ %02d: %s" % [id, nomes_pqs_9[i]],
			"saga_nome": "Guerra de Sucessão Kakin",
			"arco_requerido": 9,
			"stars": stars,
			"subtitulo": "What-If: Black Whale 1",
			"what_if_lore": "Fenda temporal: Guerra mortal de sucessão real, bestas parasitas e duelo final entre lendas!",
			"inimigos_descricao": "Bestas Parasitas e Assassinos de Elite",
			"waves": [
				{"nome": "Assassino de Kakin", "hp": hp_base, "defesa": def, "forca": forca, "xp": int(xp * 0.4), "count": 4, "cor": Color(0.7, 0.1, 0.7)},
				{"nome": "Besta Guardiã de Nen", "hp": hp_base * 3, "defesa": def + 35, "forca": forca + 40, "xp": int(xp * 0.6), "count": 1, "is_boss": true, "cor": Color(0.9, 0.1, 0.1)}
			],
			"reward_xp": xp,
			"reward_gold": gold,
			"reward_items": [{"id": "cristal_aura", "qtd": 5}],
			"reward_materials": [{"id": "ouro_kakin", "nome": "Barra de Ouro Imperial de Kakin", "qtd": 3}]
		})
