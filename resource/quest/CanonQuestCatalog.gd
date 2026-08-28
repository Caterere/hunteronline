class_name CanonQuestCatalog
extends Resource

# ============================================================
# HUNTER ONLINE - CANON QUEST CATALOG (MODO HISTÓRIA COMPLETO - 254 ETAPAS)
# ============================================================
#
# Campanha oficial dos 9 Arcos Canônicos de Hunter x Hunter.
# Cada saga possui de 18 a 48 etapas com duração de 45 min a 2 horas:
# - Arco 1: 287º Exame Hunter (24 etapas)
# - Arco 2: Montanha Kukuroo (18 etapas)
# - Arco 3: Arena Celestial (26 etapas)
# - Arco 4: Yorknew City (34 etapas)
# - Arco 5: Greed Island (36 etapas)
# - Arco 6: Formigas Chimera (48 etapas)
# - Arco 7: Eleição Hunter (20 etapas)
# - Arco 8: Continente Negro (22 etapas)
# - Arco 9: Guerra de Sucessão Kakin (26 etapas)
#
# ============================================================

static func obter_total_quests_do_arco(arco: int) -> int:
	match arco:
		1: return 24 # 287º Exame Hunter
		2: return 18 # Montanha Kukuroo
		3: return 26 # Arena Celestial
		4: return 34 # Yorknew City
		5: return 36 # Greed Island
		6: return 48 # Formigas Chimera
		7: return 20 # Eleição Hunter & Alluka
		8: return 22 # Continente Negro & Árvore do Mundo
		9: return 26 # Guerra de Sucessão Kakin & Black Whale 1
		_: return 1


static var _quest_cache: Dictionary = {}


static func obter_ou_criar_quest_arco(arco: int) -> Quest:
	var etapa_atual: int = 1
	if PlayerData != null:
		etapa_atual = max(1, PlayerData.etapa_quest_arco)
	return obter_quest_da_etapa(arco, etapa_atual)


static func obter_quest_da_etapa(arco: int, etapa: int) -> Quest:
	var chave: String = "%d_%d" % [arco, etapa]
	if _quest_cache.has(chave) and _quest_cache[chave] != null:
		return _quest_cache[chave]

	var q := Quest.new()
	q.resource_path = "res://data/quests/arco%d_etapa%d.tres" % [arco, etapa]
	q.completion = Quest.Completion.ALL
	q.auto_complete = true

	match arco:
		# =====================================================
		# ARCO 1: 287º EXAME HUNTER (24 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		1:
			match etapa:
				1:
					q.quest_name = "Exame Hunter 1/24: Apresentação em Zaban"
					q.description = "Apresente-se no túnel subterrâneo de Zaban para o 287º Exame Hunter. Fale com Tonpa, o Quebrador de Novatos."
					q.reward_xp = 350
					q.reward_gold = 800
					q.objectives = [_criar_obj_visit(&"tonpa", "Tonpa o Quebrador de Novatos")]

				2:
					q.quest_name = "Exame Hunter 2/24: A Maratona dos 80km"
					q.description = "Observe os concorrentes veteranos no túnel escuro: o ninja Hanzo, o novato Nicol e o mestre marcial Bodoro."
					q.reward_xp = 400
					q.reward_gold = 1000
					q.objectives = [_criar_obj_visit(&"nicol", "Nicol (Nº 187)"), _criar_obj_visit(&"hanzo", "Hanzo (Nº 294)"), _criar_obj_visit(&"bodoro", "Bodoro (Nº 191)")]

				3:
					q.quest_name = "Exame Hunter 3/24: O Ritmo dos Quatro Companheiros"
					q.description = "Mantenha o ritmo da corrida com Gon, Killua em seu skate, Leorio e Kurapika."
					q.reward_xp = 450
					q.reward_gold = 1200
					q.objectives = [_criar_obj_visit(&"gon", "Gon Freecss"), _criar_obj_visit(&"killua", "Killua Zoldyck"), _criar_obj_visit(&"gittarackur", "Gittarackur (Nº 301)")]

				4:
					q.quest_name = "Exame Hunter 4/24: Os Sabotadores de Novatos"
					q.description = "Alguns candidatos desonestos tentam derrubar os participantes exaustos. Derrote os sabotadores do túnel!"
					q.reward_xp = 550
					q.reward_gold = 1500
					q.objectives = [_criar_obj_kill(&"candidato_exame", 2)]

				5:
					q.quest_name = "Exame Hunter 5/24: A Saída do Túnel de Zaban"
					q.description = "Alcance as escadarias que levam à saída do túnel subterrâneo e apresente-se perante o Examinador Satotz."
					q.reward_xp = 600
					q.reward_gold = 1800
					q.objectives = [_criar_obj_visit(&"satotz", "Examinador Satotz")]

				6:
					q.quest_name = "Exame Hunter 6/24: O Nevoeiro do Pantanal Numere"
					q.description = "Chegue ao temido 'Ninho dos Trapaceiros'. Fale com o arqueiro Pokkle e a especialista Ponzu."
					q.reward_xp = 700
					q.reward_gold = 2000
					q.objectives = [_criar_obj_visit(&"pokkle", "Pokkle (Nº 53)"), _criar_obj_visit(&"ponzu", "Ponzu (Nº 246)")]

				7:
					q.quest_name = "Exame Hunter 7/24: O Macaco Farsante"
					q.description = "Um homem ferido com rosto de macaco tenta enganar os candidatos dizendo que Satotz é um monstro. Investigue a farsa!"
					q.reward_xp = 750
					q.reward_gold = 2200
					q.objectives = [_criar_obj_investigate(&"farsa_macaco")]

				8:
					q.quest_name = "Exame Hunter 8/24: Feras Carnívoras do Nevoeiro"
					q.description = "Elimine os monstros traiçoeiros do nevoeiro do Pantanal Numere que atacam a retaguarda."
					q.reward_xp = 800
					q.reward_gold = 2500
					q.objectives = [_criar_obj_kill(&"criatura_pantanal", 3)]

				9:
					q.quest_name = "Exame Hunter 9/24: O Julgamento Sinistro de Hisoka"
					q.description = "Testemunhe a sede de sangue de Hisoka Morow no coração da névoa eliminando candidatos fracos."
					q.reward_xp = 900
					q.reward_gold = 3000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka Morow")]

				10:
					q.quest_name = "Exame Hunter 10/24: A Provação de Coragem"
					q.description = "Sobreviva ao teste de olhar e presença assassina de Hisoka no nevoeiro denso."
					q.reward_xp = 1000
					q.reward_gold = 3500
					q.objectives = [_criar_obj_kill(&"criatura_pantanal", 2)]

				11:
					q.quest_name = "Exame Hunter 11/24: Acampamento da Floresta Biska"
					q.description = "Chegue ao portão da Floresta Biska e apresente-se aos Examinadores Gourmet da 2ª Fase."
					q.reward_xp = 1100
					q.reward_gold = 4000
					q.objectives = [_criar_obj_visit(&"buhara", "Examinador Buhara"), _criar_obj_visit(&"menchi", "Examinadora Menchi")]

				12:
					q.quest_name = "Exame Hunter 12/24: A Caçada ao Great Stamp Pig"
					q.description = "Rastreie e cace o temível Grande Javali Selvagem (Great Stamp Pig) na floresta!"
					q.reward_xp = 1300
					q.reward_gold = 5000
					q.objectives = [_criar_obj_kill(&"great_stamp_pig", 1)]

				13:
					q.quest_name = "Exame Hunter 13/24: O Veredito Gourmet na Ravina"
					q.description = "Colete ovos de águia-aranha descendo nas teias da ravina profunda com a aprovação de Menchi."
					q.reward_xp = 1400
					q.reward_gold = 5500
					q.objectives = [_criar_obj_collect(&"ovo_aguia", 1)]

				14:
					q.quest_name = "Exame Hunter 14/24: Viagem Noturna no Dirigível"
					q.description = "Descanse no dirigível oficial da Associação Hunter e converse com o Presidente Isaac Netero."
					q.reward_xp = 1500
					q.reward_gold = 6000
					q.objectives = [_criar_obj_visit(&"netero", "Presidente Isaac Netero")]

				15:
					q.quest_name = "Exame Hunter 15/24: O Jogo da Bola de Netero"
					q.description = "Tente tirar a bola das mãos do Presidente Netero em um teste amigável de velocidade e reflexos."
					q.reward_xp = 1600
					q.reward_gold = 6500
					q.objectives = [_criar_obj_visit(&"netero", "Presidente Isaac Netero")]

				16:
					q.quest_name = "Exame Hunter 16/24: O Topo da Trick Tower"
					q.description = "Aterrisse no topo da Torre dos Truques (3ª Fase) e encontre o alçapão secreto de descida."
					q.reward_xp = 1700
					q.reward_gold = 7000
					q.objectives = [_criar_obj_investigate(&"alcapao_trick_tower")]

				17:
					q.quest_name = "Exame Hunter 17/24: A Votação Majoritária"
					q.description = "Enfrente os prisioneiros condenados da torre no ringue de votação majoritária com Gon e Leorio."
					q.reward_xp = 1800
					q.reward_gold = 7500
					q.objectives = [_criar_obj_visit(&"tonpa", "Tonpa (Companheiro de Voto)")]

				18:
					q.quest_name = "Exame Hunter 18/24: O Blefe da Vela de Sedokan"
					q.description = "Vença a disputa psicológica de queima de velas contra o prisioneiro pirômano Sedokan."
					q.reward_xp = 1900
					q.reward_gold = 8000
					q.objectives = [_criar_obj_investigate(&"vela_sedokan")]

				19:
					q.quest_name = "Exame Hunter 19/24: O Terror de Johness o Estripador"
					q.description = "Testemunhe Killua arrancando o coração do assassino Johness em um piscar de olhos e avance pela base da torre."
					q.reward_xp = 2000
					q.reward_gold = 9000
					q.objectives = [_criar_obj_kill(&"candidato_exame", 2)]

				20:
					q.quest_name = "Exame Hunter 20/24: Embarque para a Ilha Zevil"
					q.description = "Sorteie a placa alvo da 4ª Fase no navio cargueiro e prepare a caçada nas florestas da Ilha Zevil."
					q.reward_xp = 2100
					q.reward_gold = 9500
					q.objectives = [_criar_obj_visit(&"satotz", "Examinador Satotz")]

				21:
					q.quest_name = "Exame Hunter 21/24: A Caçada de Placas na Floresta"
					q.description = "Rastreie e obtenha as placas de identificação necessárias derrotando competidores veteranos na ilha."
					q.reward_xp = 2200
					q.reward_gold = 10000
					q.objectives = [_criar_obj_kill(&"candidato_exame", 3)]

				22:
					q.quest_name = "Exame Hunter 22/24: O Bote Perfeito em Hisoka"
					q.description = "Aproveite o momento exato em que Hisoka ataca outro candidato para roubar a Placa nº 44 com a vara de pesca!"
					q.reward_xp = 2300
					q.reward_gold = 11000
					q.objectives = [_criar_obj_stealth(&"zona_hisoka_zevil")]

				23:
					q.quest_name = "Exame Hunter 23/24: A Caverna Venenosa de Ponzu"
					q.description = "Infiltre-se na caverna cheia de cobras venenosas para resgatar Leorio e Ponzu usando sonífero de gás."
					q.reward_xp = 2400
					q.reward_gold = 11500
					q.objectives = [_criar_obj_visit(&"ponzu", "Ponzu")]

				24:
					q.quest_name = "Exame Hunter 24/24: A Prova Final & Rumo a Kukuroo"
					q.description = "Conclua o torneio final do Exame Hunter, receba a Licença Hunter oficial e parta para resgatar Killua na Montanha Kukuroo!"
					q.reward_xp = 3000
					q.reward_gold = 15000
					q.objectives = [_criar_obj_visit(&"satotz", "Examinador Satotz")]

		# =====================================================
		# ARCO 2: MONTANHA KUKUROO (18 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		2:
			match etapa:
				1:
					q.quest_name = "Montanha Kukuroo 1/18: A República de Padokia"
					q.description = "Chegue à cidade turística de Dentora na República de Padokia para obter informações sobre a montanha dos assassinos."
					q.reward_xp = 2200
					q.reward_gold = 15000
					q.objectives = [_criar_obj_visit(&"guia_turismo", "Guia de Turismo de Padokia")]

				2:
					q.quest_name = "Montanha Kukuroo 2/18: O Ônibus Turístico da Montanha"
					q.description = "Pegue o ônibus panorâmico e viaje até os limites da floresta do vulcão adormecido da família Zoldyck."
					q.reward_xp = 2400
					q.reward_gold = 18000
					q.objectives = [_criar_obj_visit(&"zebro", "Guarda Zebro")]

				3:
					q.quest_name = "Montanha Kukuroo 3/18: A Guarita do Guarda Zebro"
					q.description = "Fale com o porteiro Zebro e descubra o perigo da porta lateral de invasores devorados pelo cão Mike."
					q.reward_xp = 2600
					q.reward_gold = 20000
					q.objectives = [_criar_obj_visit(&"zebro", "Guarda Zebro")]

				4:
					q.quest_name = "Montanha Kukuroo 4/18: O Dormitório dos Pesos de 50kg"
					q.description = "Entre no alojamento dos empregados e treine utilizando xícaras, chinelos e portas pesando dezenas de quilos."
					q.reward_xp = 2800
					q.reward_gold = 22000
					q.objectives = [_criar_obj_investigate(&"pesos_zebro")]

				5:
					q.quest_name = "Montanha Kukuroo 5/18: O Portão da Testagem (4 Toneladas)"
					q.description = "Reúna toda a sua força muscular e empurre a primeira folha de ferro do Portão da Testagem (Testing Gate)!"
					q.reward_xp = 3200
					q.reward_gold = 26000
					q.objectives = [_criar_obj_visit(&"portao_testagem", "Portão da Testagem (Testing Gate)")]

				6:
					q.quest_name = "Montanha Kukuroo 6/18: A Alameda dos Cães de Caça"
					q.description = "Caminhe pela alameda das árvores gigantescas sob a vigilância aterradora do cão Mike."
					q.reward_xp = 3400
					q.reward_gold = 28000
					q.objectives = [_criar_obj_stealth(&"alameda_mike")]

				7:
					q.quest_name = "Montanha Kukuroo 7/18: As Feras de Guarda Zoldyck"
					q.description = "Neutralize os cães de guarda de apoio de Mike que patrulham a trilha florestal."
					q.reward_xp = 3600
					q.reward_gold = 30000
					q.objectives = [_criar_obj_kill(&"mike", 2)]

				8:
					q.quest_name = "Montanha Kukuroo 8/18: A Barreira da Mordoma Canary"
					q.description = "Encontre a jovem mordoma aprendiz Canary protegendo o caminho com seu bastão de ferro."
					q.reward_xp = 3800
					q.reward_gold = 32000
					q.objectives = [_criar_obj_visit(&"canary", "Mordoma Canary")]

				9:
					q.quest_name = "Montanha Kukuroo 9/18: O Teste de Determinação de Canary"
					q.description = "Resista aos golpes velozes de bastão de Canary demonstrando que não recuará diante da dor."
					q.reward_xp = 4000
					q.reward_gold = 35000
					q.objectives = [_criar_obj_persuasion(&"canary", "Mordoma Canary")]

				10:
					q.quest_name = "Montanha Kukuroo 10/18: O Apelo dos Laços de Amizade"
					q.description = "Convença Canary de que Gon, Leorio e Kurapika vieram resgatar Killua como amigos verdadeiros."
					q.reward_xp = 4200
					q.reward_gold = 38000
					q.objectives = [_criar_obj_visit(&"canary", "Mordoma Canary")]

				11:
					q.quest_name = "Montanha Kukuroo 11/18: A Intromissão de Kikyo e Milluki"
					q.description = "Kikyo Zoldyck dispara projéteis atordoantes de longe. Proteja Canary e avance até a mansão dos mordomos."
					q.reward_xp = 4400
					q.reward_gold = 40000
					q.objectives = [_criar_obj_stealth(&"mansao_mordomos")]

				12:
					q.quest_name = "Montanha Kukuroo 12/18: A Recepção de Gotoh"
					q.description = "Apresente-se na elegante sala de espera da Mansão dos Mordomos com o Mordomo-Chefe Gotoh."
					q.reward_xp = 4600
					q.reward_gold = 42000
					q.objectives = [_criar_obj_visit(&"gotoh", "Mordomo-Chefe Gotoh")]

				13:
					q.quest_name = "Montanha Kukuroo 13/18: O Jogo das Moedas de Alta Velocidade"
					q.description = "Participe do teste de visão dinâmica de Gotoh adivinhando em qual mão a moeda de ouro está escondida."
					q.reward_xp = 4800
					q.reward_gold = 45000
					q.objectives = [_criar_obj_investigate(&"jogo_moeda_gotoh")]

				14:
					q.quest_name = "Montanha Kukuroo 14/18: A Guarda de Elite dos Mordomos"
					q.description = "Enfrente 3 mordomos de combate Zoldyck em um teste formal de reflexos e técnica marcial."
					q.reward_xp = 5000
					q.reward_gold = 48000
					q.objectives = [_criar_obj_kill(&"mordomo_combate", 3)]

				15:
					q.quest_name = "Montanha Kukuroo 15/18: As Escadarias do Castelo Central"
					q.description = "Suba as imensas escadarias de pedra da mansão principal rumo à câmara do chefe da família."
					q.reward_xp = 5200
					q.reward_gold = 50000
					q.objectives = [_criar_obj_visit(&"silva", "Silva Zoldyck")]

				16:
					q.quest_name = "Montanha Kukuroo 16/18: A Sala do Trono dos Assassinos"
					q.description = "Audiência solene com Silva Zoldyck na imensa câmara de pedra dos assassinos profissionais."
					q.reward_xp = 5400
					q.reward_gold = 55000
					q.objectives = [_criar_obj_visit(&"silva", "Silva Zoldyck")]

				17:
					q.quest_name = "Montanha Kukuroo 17/18: O Pacto de Sangue de Silva"
					q.description = "Fazer o juramento sagrado com Silva Zoldyck: 'Nunca traia os seus companheiros'."
					q.reward_xp = 5600
					q.reward_gold = 60000
					q.objectives = [_criar_obj_persuasion(&"silva", "Silva Zoldyck")]

				18:
					q.quest_name = "Montanha Kukuroo 18/18: O Resgate de Killua & Rumo à Arena"
					q.description = "Encontre Killua Zoldyck liberto, reúna o quarteto e parta com Gon rumo aos 200 andares da Arena Celestial!"
					q.reward_xp = 6500
					q.reward_gold = 70000
					q.objectives = [_criar_obj_visit(&"killua", "Killua Zoldyck")]

		# =====================================================
		# ARCO 3: ARENA CELESTIAL (26 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		3:
			match etapa:
				1:
					q.quest_name = "Arena Celestial 1/26: A Inscrição na Recepção"
					q.description = "Chegue ao saguão térreo da Arena Celestial e faça seu registro oficial de combate na recepção."
					q.reward_xp = 4500
					q.reward_gold = 40000
					q.objectives = [_criar_obj_visit(&"recepcionista", "Recepcionista da Arena")]

				2:
					q.quest_name = "Arena Celestial 2/26: O Primeiro Desafio do Andar 1"
					q.description = "Vença a luta de teste preliminar do Andar 1 contra o primeiro lutador desafiante."
					q.reward_xp = 4800
					q.reward_gold = 45000
					q.objectives = [_criar_obj_kill(&"lutador_arena", 1)]

				3:
					q.quest_name = "Arena Celestial 3/26: A Escalada aos Andares 50"
					q.description = "Avance pelas lutas da divisão intermediária derrotando o 2º lutador veterano."
					q.reward_xp = 5200
					q.reward_gold = 50000
					q.objectives = [_criar_obj_kill(&"lutador_arena", 1)]

				4:
					q.quest_name = "Arena Celestial 4/26: O Ritmo dos Andares 100"
					q.description = "Consiga vitórias consecutivas nos andares 100 derrotando o 3º lutador de elite."
					q.reward_xp = 5600
					q.reward_gold = 55000
					q.objectives = [_criar_obj_kill(&"lutador_arena", 1)]

				5:
					q.quest_name = "Arena Celestial 5/26: O Campeão dos Andares 190"
					q.description = "Derrote o 4º lutador campeão dos andares inferiores para conquistar o direito de subir ao 200º andar!"
					q.reward_xp = 6000
					q.reward_gold = 60000
					q.objectives = [_criar_obj_kill(&"lutador_arena", 1)]

				6:
					q.quest_name = "Arena Celestial 6/26: O Elevador do 200º Andar"
					q.description = "Pegue o elevador de alta velocidade até o saguão do 200º andar onde residem os Mestres de Andar."
					q.reward_xp = 6200
					q.reward_gold = 65000
					q.objectives = [_criar_obj_visit(&"recepcionista", "Recepcionista do 200º Andar")]

				7:
					q.quest_name = "Arena Celestial 7/26: A Parede de Intenção Assassina"
					q.description = "Sinta a barreira colossal de Hatsu assassino emitida por Hisoka que impede a passagem dos desprotegidos."
					q.reward_xp = 6500
					q.reward_gold = 70000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka Morow")]

				8:
					q.quest_name = "Arena Celestial 8/26: O Encontro com Zushi"
					q.description = "Conheça o jovem praticante de Shingen-ryu Zushi nos corredores de treinamento."
					q.reward_xp = 6800
					q.reward_gold = 75000
					q.objectives = [_criar_obj_visit(&"zushi", "Zushi (Discípulo Shingen-ryu)")]

				9:
					q.quest_name = "Arena Celestial 9/26: A Apresentação de Mestre Wing"
					q.description = "Visite os aposentos de Mestre Wing para aprender a verdadeira natureza oculta do mundo: o NEN."
					q.reward_xp = 7200
					q.reward_gold = 80000
					q.objectives = [_criar_obj_visit(&"wing", "Mestre Wing")]

				10:
					q.quest_name = "Arena Celestial 10/26: O Teste da Água (Water Divination)"
					q.description = "Posicione as mãos ao redor do copo d'água com a folha e descubra sua Categoria Secreta de Afinidade!"
					q.reward_xp = 7600
					q.reward_gold = 85000
					q.objectives = [_criar_obj_investigate(&"teste_agua_wing")]

				11:
					q.quest_name = "Arena Celestial 11/26: O Despertar do Ten (Envolver)"
					q.description = "Abra os nós de aura do corpo com o fluxo suave de Wing e aprenda a manter o manto protetor de Ten."
					q.reward_xp = 8000
					q.reward_gold = 90000
					q.objectives = [_criar_obj_visit(&"wing", "Mestre Wing")]

				12:
					q.quest_name = "Arena Celestial 12/26: O Treinamento do Ren (Expandir)"
					q.description = "Expanda exponencialmente o volume de aura liberado para fortalecer ataques e pressão física."
					q.reward_xp = 8400
					q.reward_gold = 95000
					q.objectives = [_criar_obj_visit(&"wing", "Mestre Wing")]

				13:
					q.quest_name = "Arena Celestial 13/26: O Silenciamento com Zetsu"
					q.description = "Feche todos os nós de aura simultaneamente para regenerar vida e ocultar sua presença térmica."
					q.reward_xp = 8800
					q.reward_gold = 100000
					q.objectives = [_criar_obj_visit(&"wing", "Mestre Wing")]

				14:
					q.quest_name = "Arena Celestial 14/26: A Concentração com Gyo nos Olhos"
					q.description = "Concentre aura nos olhos para enxergar objetos, armadilhas e projeções invisíveis de Nen."
					q.reward_xp = 9200
					q.reward_gold = 105000
					q.objectives = [_criar_obj_visit(&"wing", "Mestre Wing")]

				15:
					q.quest_name = "Arena Celestial 15/26: Ultrapassando a Linha de Hisoka"
					q.description = "Caminhe com seu Ten ativo através da barreira assassina de Hisoka e alcance o balcão de registro às 23:59!"
					q.reward_xp = 9600
					q.reward_gold = 110000
					q.objectives = [_criar_obj_stealth(&"barreira_hisoka_200")]

				16:
					q.quest_name = "Arena Celestial 16/26: O Registro no 200º Andar"
					q.description = "Assine oficialmente sua inscrição na divisão dos 200 andares da Arena Celestial."
					q.reward_xp = 10000
					q.reward_gold = 120000
					q.objectives = [_criar_obj_visit(&"recepcionista", "Recepcionista da Arena")]

				17:
					q.quest_name = "Arena Celestial 17/26: O Batismo dos Trapaceiros"
					q.description = "Conheça os veteranos Gido, Riehlvelt e Sadaso que usam truques para conseguir vitórias fáceis de novatos."
					q.reward_xp = 10500
					q.reward_gold = 125000
					q.objectives = [_criar_obj_visit(&"zushi", "Zushi")]

				18:
					q.quest_name = "Arena Celestial 18/26: A Dança dos Piões de Gido"
					q.description = "Derrote os 3 piões de Nen energizados de Gido usando Gyo para prever suas trajetórias rotatórias!"
					q.reward_xp = 11000
					q.reward_gold = 135000
					q.objectives = [_criar_obj_kill(&"piao_gido", 3)]

				19:
					q.quest_name = "Arena Celestial 19/26: A Cadeira Elétrica de Riehlvelt"
					q.description = "Derrote Riehlvelt no ringue principal superando seus chicotes elétricos 'Song of Defense'!"
					q.reward_xp = 11500
					q.reward_gold = 145000
					q.objectives = [_criar_obj_kill(&"riehlvelt", 1)]

				20:
					q.quest_name = "Arena Celestial 20/26: A Consulta Tática de Kastro"
					q.description = "Fale com Mestre Wing sobre a ilusão do clone do tigre voraz de Kastro."
					q.reward_xp = 12000
					q.reward_gold = 155000
					q.objectives = [_criar_obj_visit(&"wing", "Mestre Wing")]

				21:
					q.quest_name = "Arena Celestial 21/26: O Punho da Mordida do Tigre"
					q.description = "Enfrente o Mestre Kastro no ringue central lotado da Arena Celestial."
					q.reward_xp = 12500
					q.reward_gold = 165000
					q.objectives = [_criar_obj_kill(&"kastro", 1)]

				22:
					q.quest_name = "Arena Celestial 22/26: A Queda do Clone de Nen"
					q.description = "Use Gyo para focar na poeira nos pés de Kastro e derrote o clone de Nen em definitivo!"
					q.reward_xp = 13000
					q.reward_gold = 180000
					q.objectives = [_criar_obj_visit(&"wing", "Mestre Wing")]

				23:
					q.quest_name = "Arena Celestial 23/26: A Preparação para o Clímax"
					q.description = "Revise todas as estratégias de combate e controle de aura com Zushi e Killua antes de enfrentar Hisoka."
					q.reward_xp = 13500
					q.reward_gold = 190000
					q.objectives = [_criar_obj_visit(&"zushi", "Zushi")]

				24:
					q.quest_name = "Arena Celestial 24/26: O Duelo Prometido com Hisoka"
					q.description = "Entre no ringue principal do 200º andar diante de milhares de espectadores contra Hisoka Morow!"
					q.reward_xp = 14500
					q.reward_gold = 220000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka Morow")]

				25:
					q.quest_name = "Arena Celestial 25/26: A Devolução da Placa nº 44"
					q.description = "Acerte o golpe limpo de Nen no rosto de Hisoka no ringue, devolva a placa nº 44 e vença o combate!"
					q.reward_xp = 16000
					q.reward_gold = 260000
					q.objectives = [_criar_obj_kill(&"hisoka_boss", 1)]

				26:
					q.quest_name = "Arena Celestial 26/26: O Reconhecimento de Mestre Wing"
					q.description = "Receba os parabéns de Wing por dominar os fundamentos do Nen e parta rumo ao grande leilão de Yorknew City!"
					q.reward_xp = 18000
					q.reward_gold = 300000
					q.objectives = [_criar_obj_visit(&"wing", "Mestre Wing")]

		# =====================================================
		# ARCO 4: YORKNEW CITY (34 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		4:
			match etapa:
				1:
					q.quest_name = "Yorknew City 1/34: A Chegada à Metrópole"
					q.description = "Encontre Leorio no centro comercial de Yorknew City e planejem como levantar fundos para o leilão."
					q.reward_xp = 14000
					q.reward_gold = 200000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio Paradinight")]

				2:
					q.quest_name = "Yorknew City 2/34: A Arte da Pechincha no Mercado"
					q.description = "Aprenda a avaliar antiguidades e tesouros de Nen usando Gyo para detectar auras em objetos antigos."
					q.reward_xp = 15000
					q.reward_gold = 220000
					q.objectives = [_criar_obj_investigate(&"antiguidade_mercado")]

				3:
					q.quest_name = "Yorknew City 3/34: O Contrato dos Guarda-Costas Nostrade"
					q.description = "Apresente-se na comitiva de guarda-costas da família Nostrade com Kurapika."
					q.reward_xp = 16000
					q.reward_gold = 240000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika (Guarda-Costas Nostrade)")]

				4:
					q.quest_name = "Yorknew City 4/34: A Melodia do Coração de Melody"
					q.description = "Converse com Melody sobre o poder de sua flauta e o rastreamento do ritmo cardíaco humano."
					q.reward_xp = 17000
					q.reward_gold = 260000
					q.objectives = [_criar_obj_visit(&"melody", "Melody (Musicista Hunter)")]

				5:
					q.quest_name = "Yorknew City 5/34: Mafiosos Corrompidos da Noite"
					q.description = "Derrote 4 mafiosos corrompidos que tentam extorquir comerciantes nas docas do leilão."
					q.reward_xp = 18500
					q.reward_gold = 280000
					q.objectives = [_criar_obj_kill(&"mafioso_corrompido", 4)]

				6:
					q.quest_name = "Yorknew City 6/34: A Noite do Leilão Subterrâneo"
					q.description = "Infiltre-se no prédio do leilão clandestino onde os tesouros do mundo todo estão expostos."
					q.reward_xp = 20000
					q.reward_gold = 300000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				7:
					q.quest_name = "Yorknew City 7/34: O Ataque Sombra da Trupe Fantasma"
					q.description = "A Trupe Fantasma invade o leilão, elimina os mafiosos e rouba todo o cofre de tesouros!"
					q.reward_xp = 21000
					q.reward_gold = 320000
					q.objectives = [_criar_obj_investigate(&"cofre_vazio_leilao")]

				8:
					q.quest_name = "Yorknew City 8/34: A Perseguição ao Balão de Fuga"
					q.description = "Siga o rastro de fuga da Trupe Fantasma através do céu noturno até o Deserto de Gordeau."
					q.reward_xp = 22000
					q.reward_gold = 350000
					q.objectives = [_criar_obj_stealth(&"deserto_gordeau")]

				9:
					q.quest_name = "Yorknew City 9/34: A Fúria do Titã Uvogin"
					q.description = "Testemunhe Uvogin aniquilando os membros das Feras das Sombras (Inju) com um soco Big Bang Impact."
					q.reward_xp = 24000
					q.reward_gold = 380000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				10:
					q.quest_name = "Yorknew City 10/34: O Duelo das Correntes de Kurapika"
					q.description = "Enfrente Uvogin no deserto aberto usando as correntes forjadas sob juramento de sangue."
					q.reward_xp = 26000
					q.reward_gold = 420000
					q.objectives = [_criar_obj_kill(&"uvogin", 1)]

				11:
					q.quest_name = "Yorknew City 11/34: A Prisão da Corrente (Chain Jail)"
					q.description = "Aprisione o gigante Uvogin em estado forçado de Zetsu com a Chain Jail inquebrável."
					q.reward_xp = 28000
					q.reward_gold = 450000
					q.objectives = [_criar_obj_persuasion(&"kurapika", "Kurapika")]

				12:
					q.quest_name = "Yorknew City 12/34: O Juramento do Coração Kurta"
					q.description = "Mantenha o voto de não utilizar as correntes contra ninguém fora os 13 membros da Aranha."
					q.reward_xp = 29000
					q.reward_gold = 480000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				13:
					q.quest_name = "Yorknew City 13/34: O Réquiem de Chrollo Lucilfer"
					q.description = "Chrollo comanda o massacre orquestrado no centro financeiro de Yorknew como tributo fúnebre a Uvogin."
					q.reward_xp = 30000
					q.reward_gold = 500000
					q.objectives = [_criar_obj_investigate(&"requiem_chrollo")]

				14:
					q.quest_name = "Yorknew City 14/34: Rastreando as Aranhas com Gon e Killua"
					q.description = "Use Zetsu absoluto para seguir Nobunaga e Machi através das vielas escuras sem ser detectado."
					q.reward_xp = 31000
					q.reward_gold = 520000
					q.objectives = [_criar_obj_visit(&"gon", "Gon Freecss")]

				15:
					q.quest_name = "Yorknew City 15/34: A Emboscada no Galpão Abandonado"
					q.description = "Escapar da armadilha de linhas de Nen de Machi e das espadas de Nobunaga."
					q.reward_xp = 32000
					q.reward_gold = 550000
					q.objectives = [_criar_obj_stealth(&"galpao_machinobunaga")]

				16:
					q.quest_name = "Yorknew City 16/34: A Fuga das Paredes de Pedra"
					q.description = "Gon e Killua quebram as paredes laterais do cativeiro com os punhos para despistar a guarda da Trupe."
					q.reward_xp = 33000
					q.reward_gold = 570000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				17:
					q.quest_name = "Yorknew City 17/34: A Chegada dos Assassinos Zoldyck"
					q.description = "Os 10 Padrinhos da Máfia contratam Zeno e Silva Zoldyck para caçar e eliminar Chrollo Lucilfer."
					q.reward_xp = 34000
					q.reward_gold = 600000
					q.objectives = [_criar_obj_visit(&"silva", "Silva Zoldyck")]

				18:
					q.quest_name = "Yorknew City 18/34: A Infiltração no Edifício Cemitério"
					q.description = "Derrote 3 clones de combate e guardas de elite de Feitan e Phinks no prédio central."
					q.reward_xp = 36000
					q.reward_gold = 640000
					q.objectives = [_criar_obj_kill(&"clone_feitan", 3)]

				19:
					q.quest_name = "Yorknew City 19/34: A Farsa dos Corpos Copiados"
					q.description = "Descubra que os corpos mortos da Trupe Fantasma são cópias de Nen geradas pelo Gallery Fake de Kortopi."
					q.reward_xp = 37000
					q.reward_gold = 660000
					q.objectives = [_criar_obj_investigate(&"copia_kortopi")]

				20:
					q.quest_name = "Yorknew City 20/34: O Hotel Beitacle"
					q.description = "Rastreie o hotel onde Chrollo, Pakunoda e Kortopi estão reunidos em segredo."
					q.reward_xp = 38000
					q.reward_gold = 680000
					q.objectives = [_criar_obj_visit(&"melody", "Melody")]

				21:
					q.quest_name = "Yorknew City 21/34: O Plano do Apagão Central"
					q.description = "Corte os cabos de alta tensão da subestação de Yorknew exatamente às 19:00:00."
					q.reward_xp = 39000
					q.reward_gold = 700000
					q.objectives = [_criar_obj_stealth(&"apagao_yorknew")]

				22:
					q.quest_name = "Yorknew City 22/34: A Captura do Líder Chrollo"
					q.description = "No escuro absoluto de 2 segundos, Kurapika captura Chrollo Lucilfer e o joga no carro em alta velocidade."
					q.reward_xp = 41000
					q.reward_gold = 730000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				23:
					q.quest_name = "Yorknew City 23/34: A Contenção de Pakunoda"
					q.description = "Derrote Pakunoda antes que ela dispare suas balas de memórias Memory Bomb nos aliados."
					q.reward_xp = 43000
					q.reward_gold = 760000
					q.objectives = [_criar_obj_kill(&"pakunoda", 1)]

				24:
					q.quest_name = "Yorknew City 24/34: A Negociação de Reféns"
					q.description = "Estabeleça as condições da troca: Gon e Killua pela vida do líder Chrollo."
					q.reward_xp = 44000
					q.reward_gold = 780000
					q.objectives = [_criar_obj_persuasion(&"melody", "Melody")]

				25:
					q.quest_name = "Yorknew City 25/34: O Encontro no Aeroporto de Lingon"
					q.description = "Conduza a comitiva com Kurapika até a pista de pouso isolada para a troca final."
					q.reward_xp = 45000
					q.reward_gold = 800000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				26:
					q.quest_name = "Yorknew City 26/34: A Corrente do Julgamento no Líder"
					q.description = "Imponha a Judgement Chain no coração de Chrollo Lucilfer, proibindo-o de usar Nen ou falar com a Trupe!"
					q.reward_xp = 47000
					q.reward_gold = 840000
					q.objectives = [_criar_obj_visit(&"chrollo", "Chrollo Lucilfer")]

				27:
					q.quest_name = "Yorknew City 27/34: O Julgamento de Pakunoda"
					q.description = "Imponha a regra de silêncio a Pakunoda para garantir a libertação segura de Gon e Killua."
					q.reward_xp = 48000
					q.reward_gold = 860000
					q.objectives = [_criar_obj_visit(&"melody", "Melody")]

				28:
					q.quest_name = "Yorknew City 28/34: A Troca Completa de Reféns"
					q.description = "Resgate Gon e Killua sãos e salvos na pista enquanto Chrollo é levado para o deserto."
					q.reward_xp = 49000
					q.reward_gold = 880000
					q.objectives = [_criar_obj_visit(&"gon", "Gon Freecss")]

				29:
					q.quest_name = "Yorknew City 29/34: O Último Sacrifício de Pakunoda"
					q.description = "Pakunoda dispara suas memórias nos companheiros da Aranha e aceita a lâmina no coração com honra."
					q.reward_xp = 50000
					q.reward_gold = 900000
					q.objectives = [_criar_obj_investigate(&"memoria_pakunoda")]

				30:
					q.quest_name = "Yorknew City 30/34: O Leilão Oficial de Greed Island"
					q.description = "Apresente-se no grande leilão da Southernpiece Auction House para acompanhar os lances do jogo de Ging."
					q.reward_xp = 52000
					q.reward_gold = 940000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio")]

				31:
					q.quest_name = "Yorknew City 31/34: O Contrato do Bilionário Battera"
					q.description = "Fale com o bilionário Battera e inscreva-se no teste para ser um dos jogadores contratados."
					q.reward_xp = 53000
					q.reward_gold = 960000
					q.objectives = [_criar_obj_visit(&"battera", "Bilionário Battera")]

				32:
					q.quest_name = "Yorknew City 32/34: O Teste de Hatsu de Tsezguerra"
					q.description = "Demonstre sua liberação de Nen (Ren) perante o caçador de 1 estrela Tsezguerra para conquistar a vaga."
					q.reward_xp = 55000
					q.reward_gold = 1000000
					q.objectives = [_criar_obj_persuasion(&"tsezguerra", "Tsezguerra (Hunter de 1 Estrela)")]

				33:
					q.quest_name = "Yorknew City 33/34: A Mensagem Oculta de Ging"
					q.description = "Escute a fita cassete gravada por Ging deixada na caixa de metal da Ilha da Baleia."
					q.reward_xp = 56000
					q.reward_gold = 1050000
					q.objectives = [_criar_obj_investigate(&"fita_ging")]

				34:
					q.quest_name = "Yorknew City 34/34: A Batalha Final contra a Sombra de Chrollo"
					q.description = "Derrote a projeção final de Chrollo Lucilfer no esconderijo e parta com o console para Greed Island!"
					q.reward_xp = 60000
					q.reward_gold = 1200000
					q.objectives = [_criar_obj_kill(&"chrollo_boss", 1)]

		# =====================================================
		# ARCO 5: GREED ISLAND (36 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		5:
			match etapa:
				1:
					q.quest_name = "Greed Island 1/36: A Inserção no Console JoyStation"
					q.description = "Fale com Battera, ative o jogo com fluxo de Nen no Memory Card e transporte-se para Greed Island!"
					q.reward_xp = 35000
					q.reward_gold = 600000
					q.objectives = [_criar_obj_visit(&"battera", "Bilionário Battera")]

				2:
					q.quest_name = "Greed Island 2/36: A Cidade Inicial de Antokiba"
					q.description = "Chegue à praça central de Antokiba e conheça as regras do torneio mensal da ilha."
					q.reward_xp = 38000
					q.reward_gold = 650000
					q.objectives = [_criar_obj_visit(&"antokiba", "Quadro de Antokiba")]

				3:
					q.quest_name = "Greed Island 3/36: O Livro de Magia (Spell Book)"
					q.description = "Aprenda os comandos 'Book' para invocar seu fichário de 100 cartas e 'Gain' para materializar itens."
					q.reward_xp = 40000
					q.reward_gold = 700000
					q.objectives = [_criar_obj_investigate(&"livro_greed")]

				4:
					q.quest_name = "Greed Island 4/36: O Primeiro Feitiço de Rastreio"
					q.description = "Derrote bandidos novatos nas colinas de Antokiba e obtenha a carta de feitiço 'Trace'."
					q.reward_xp = 42000
					q.reward_gold = 750000
					q.objectives = [_criar_obj_kill(&"monstro_greed", 2)]

				5:
					q.quest_name = "Greed Island 5/36: O Encontro com Biscuit Krueger"
					q.description = "Encontre a mestra Biscuit Krueger nas montanhas rochosas e aceite seu regime de treino infernal."
					q.reward_xp = 45000
					q.reward_gold = 800000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				6:
					q.quest_name = "Greed Island 6/36: O Treino no Desfiladeiro de Pedras"
					q.description = "Escave o desfiladeiro maciço usando pás comuns sem usar Nen para fortalecer os músculos."
					q.reward_xp = 48000
					q.reward_gold = 850000
					q.objectives = [_criar_obj_investigate(&"desfiladeiro_biscuit")]

				7:
					q.quest_name = "Greed Island 7/36: O Domínio do Ko (Concentração Total)"
					q.description = "Concentre 100% de toda a sua aura em um único punho para quebrar rochas com um golpe."
					q.reward_xp = 50000
					q.reward_gold = 900000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				8:
					q.quest_name = "Greed Island 8/36: Os Golens de Rocha"
					q.description = "Derrote 3 Golens de Pedra maciços utilizando a força pura de impacto do Ko concentrado."
					q.reward_xp = 53000
					q.reward_gold = 950000
					q.objectives = [_criar_obj_kill(&"golem_pedra", 3)]

				9:
					q.quest_name = "Greed Island 9/36: O Domínio do Shu (Extensão de Aura)"
					q.description = "Aprenda a envolver pás, pás de ferro e espadas com sua aura para torná-las indestrutíveis."
					q.reward_xp = 56000
					q.reward_gold = 1000000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				10:
					q.quest_name = "Greed Island 10/36: O Domínio do Ken (Armadura Contínua)"
					q.description = "Mantenha o estado de Ren defensivo fortificado por 3 horas seguidas sob ataque de pedras."
					q.reward_xp = 58000
					q.reward_gold = 1050000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				11:
					q.quest_name = "Greed Island 11/36: O Domínio do Ryu (Distribuição Dinâmica)"
					q.description = "Aprenda a alternar instantaneamente a proporção de aura entre ataque e defesa (70/30, 80/20)."
					q.reward_xp = 60000
					q.reward_gold = 1100000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				12:
					q.quest_name = "Greed Island 12/36: O Nascimento do Hatsu Jajanken"
					q.description = "Gon desenvolve seu golpe supremo: Pedra (Reforço), Tesoura (Transformação) e Papel (Emissão)."
					q.reward_xp = 62000
					q.reward_gold = 1150000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				13:
					q.quest_name = "Greed Island 13/36: A Eletricidade Pura de Killua"
					q.description = "Killua programa descargas elétricas em suas mãos e empunha dois Yo-yos de liga especial de 50kg."
					q.reward_xp = 64000
					q.reward_gold = 1200000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				14:
					q.quest_name = "Greed Island 14/36: A Caçada de Monstros Mágicos"
					q.description = "Derrote 4 criaturas mágicas da ilha para coletar cartas de bolso com monstros raros."
					q.reward_xp = 66000
					q.reward_gold = 1250000
					q.objectives = [_criar_obj_kill(&"monstro_greed", 4)]

				15:
					q.quest_name = "Greed Island 15/36: A Aliança com Tsezguerra"
					q.description = "Encontre o veterano Tsezguerra e combinem táticas para proteger o fichário dos ataques de feitiço."
					q.reward_xp = 68000
					q.reward_gold = 1300000
					q.objectives = [_criar_obj_visit(&"tsezguerra", "Tsezguerra")]

				16:
					q.quest_name = "Greed Island 16/36: A Ameaça do Bomber Genthru"
					q.description = "Genthru revela ser o assassino 'Bomber' e explode os aliados para roubar 95 cartas do fichário."
					q.reward_xp = 70000
					q.reward_gold = 1350000
					q.objectives = [_criar_obj_investigate(&"explosao_bomber")]

				17:
					q.quest_name = "Greed Island 17/36: O Pacto com Goreinu"
					q.description = "Una forças com Goreinu e seus Gorilas de Nen Branco e Preto para disputar a carta nº 002."
					q.reward_xp = 72000
					q.reward_gold = 1400000
					q.objectives = [_criar_obj_visit(&"goreinu", "Goreinu")]

				18:
					q.quest_name = "Greed Island 18/36: O Encontro com Hisoka em Greed Island"
					q.description = "Encontre Hisoka relaxando no lago sob o pseudônimo de Chrollo e recrute-o para a partida."
					q.reward_xp = 75000
					q.reward_gold = 1450000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka Morow")]

				19:
					q.quest_name = "Greed Island 19/36: A Cidade Portuária de Soufrabi"
					q.description = "Viaje até o litoral de Soufrabi onde piratas condenados guardam o Litoral do Mar."
					q.reward_xp = 78000
					q.reward_gold = 1500000
					q.objectives = [_criar_obj_visit(&"razor", "Game Master Razor")]

				20:
					q.quest_name = "Greed Island 20/36: O Ginásio do Game Master Razor"
					q.description = "Apresente-se no ginásio do condenado Razor, criador dos feitiços de emissão do jogo."
					q.reward_xp = 80000
					q.reward_gold = 1550000
					q.objectives = [_criar_obj_visit(&"razor", "Game Master Razor")]

				21:
					q.quest_name = "Greed Island 21/36: Os 14 Demônios de Nen de Razor"
					q.description = "Derrote 6 demônios de Nen emitidos por Razor na primeira rodada do torneio de esportes."
					q.reward_xp = 85000
					q.reward_gold = 1650000
					q.objectives = [_criar_obj_kill(&"demonio_razor", 6)]

				22:
					q.quest_name = "Greed Island 22/36: A Equipe de Queimada Mortal"
					q.description = "Monte o time de 8 jogadores com Gon, Killua, Hisoka, Biscuit e Goreinu na quadra central."
					q.reward_xp = 88000
					q.reward_gold = 1700000
					q.objectives = [_criar_obj_visit(&"goreinu", "Goreinu")]

				23:
					q.quest_name = "Greed Island 23/36: O Saque Supersônico de Razor"
					q.description = "Defenda o arremesso de Nen de Razor que quebra o piso do ginásio e nocauteia os defensores."
					q.reward_xp = 92000
					q.reward_gold = 1800000
					q.objectives = [_criar_obj_visit(&"biscuit", "Biscuit")]

				24:
					q.quest_name = "Greed Island 24/36: O Sacrifício das Mãos de Killua"
					q.description = "Killua segura a bola com as mãos em carne viva para que Gon possa carregar 100% de Jajanken!"
					q.reward_xp = 96000
					q.reward_gold = 1900000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				25:
					q.quest_name = "Greed Island 25/36: O Arremesso Triplo contra Razor"
					q.description = "Combine o Jajanken de Gon, a Bungee Gum de Hisoka e derrote o Game Master Razor Boss!"
					q.reward_xp = 105000
					q.reward_gold = 2200000
					q.objectives = [_criar_obj_kill(&"razor_boss", 1)]

				26:
					q.quest_name = "Greed Island 26/36: A Conquista da Carta 002 (Litoral do Mar)"
					q.description = "Receba a carta de espaço designado nº 002 e ouça de Razor como Ging era orgulhoso do filho."
					q.reward_xp = 110000
					q.reward_gold = 2300000
					q.objectives = [_criar_obj_visit(&"razor", "Game Master Razor")]

				27:
					q.quest_name = "Greed Island 27/36: A Estratégia contra o Trio Bomber"
					q.description = "Dividir o grupo em 3 frentes para isolar Genthru, Sub e Bara nas montanhas áridas."
					q.reward_xp = 115000
					q.reward_gold = 2400000
					q.objectives = [_criar_obj_visit(&"biscuit", "Biscuit")]

				28:
					q.quest_name = "Greed Island 28/36: A Verdadeira Força de Biscuit"
					q.description = "Biscuit assume sua forma colossal de 2,10m e nocauteia o assassino Bara com um único golpe."
					q.reward_xp = 120000
					q.reward_gold = 2500000
					q.objectives = [_criar_obj_kill(&"monstro_greed", 2)]

				29:
					q.quest_name = "Greed Island 29/36: A Armadilha Elétrica de Killua"
					q.description = "Killua neutraliza Sub usando a condução elétrica de seus dois Yo-yos de 50kg nas pernas."
					q.reward_xp = 125000
					q.reward_gold = 2600000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				30:
					q.quest_name = "Greed Island 30/36: A Cova de Pedra de Gon"
					q.description = "Atrair Genthru para a vala de pedra cavada antecipadamente com pás de Nen."
					q.reward_xp = 130000
					q.reward_gold = 2700000
					q.objectives = [_criar_obj_stealth(&"armadilha_cova_gon")]

				31:
					q.quest_name = "Greed Island 31/36: O Jajanken Decisivo contra Genthru"
					q.description = "Derrote o Bomber supremo Genthru com um Jajanken colossal vindo do alto da cova!"
					q.reward_xp = 145000
					q.reward_gold = 3000000
					q.objectives = [_criar_obj_kill(&"genthru", 1)]

				32:
					q.quest_name = "Greed Island 32/36: O Sopro do Arcanjo (Carta 017)"
					q.description = "Materialize a carta mágica de cura 'Breath of Archangel' e cure as mãos e ferimentos de todos."
					q.reward_xp = 150000
					q.reward_gold = 3200000
					q.objectives = [_criar_obj_visit(&"goreinu", "Goreinu")]

				33:
					q.quest_name = "Greed Island 33/36: O Quiz das 100 Cartas"
					q.description = "Responda corretamente às perguntas sobre a história e mecânicas das 100 cartas do jogo."
					q.reward_xp = 155000
					q.reward_gold = 3400000
					q.objectives = [_criar_obj_investigate(&"quiz_100_cartas")]

				34:
					q.quest_name = "Greed Island 34/36: O Castelo Final da Vitória"
					q.description = "Apresente-se no castelo de premiação com Elena e os criadores do jogo perante fogos de artifício."
					q.reward_xp = 160000
					q.reward_gold = 3600000
					q.objectives = [_criar_obj_visit(&"elena_greed", "Elena (Criadora de Greed Island)")]

				35:
					q.quest_name = "Greed Island 35/36: As Três Cartas para o Mundo Real"
					q.description = "Selecione o colar Blue Planet para Biscuit, e o feitiço 'Accompany' camuflado dentro da caixa."
					q.reward_xp = 170000
					q.reward_gold = 4000000
					q.objectives = [_criar_obj_visit(&"elena_greed", "Elena")]

				36:
					q.quest_name = "Greed Island 36/36: O Voo com Accompany até Nigg"
					q.description = "Grite 'Accompany to Nigg!' e voe pelos céus rumo ao encontro com o misterioso Caçador!"
					q.reward_xp = 180000
					q.reward_gold = 4500000
					q.objectives = [_criar_obj_visit(&"elena_greed", "Elena")]

		# =====================================================
		# ARCO 6: FORMIGAS CHIMERA (48 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		6:
			match etapa:
				1:
					q.quest_name = "Formigas Chimera 1/48: O Encontro na Floresta com Kite"
					q.description = "Desembarque na fronteira da NGL (Neo-Green Life) e reencontre o experiente Caçador de Contratos Kite."
					q.reward_xp = 70000
					q.reward_gold = 1000000
					q.objectives = [_criar_obj_visit(&"kite", "Kite (Caçador de Contratos)")]

				2:
					q.quest_name = "Formigas Chimera 2/48: A Roleta do Crazy Slots"
					q.description = "Observe a foice e o rifle de Nen imprevisíveis do palhaço falante Crazy Slots de Kite."
					q.reward_xp = 75000
					q.reward_gold = 1100000
					q.objectives = [_criar_obj_visit(&"kite", "Kite")]

				3:
					q.quest_name = "Formigas Chimera 3/48: Patrulhas de Formigas Soldado"
					q.description = "Elimine 5 formigas soldado mutantes que atacam os postos avançados da floresta."
					q.reward_xp = 80000
					q.reward_gold = 1200000
					q.objectives = [_criar_obj_kill(&"formiga_soldado", 5)]

				4:
					q.quest_name = "Formigas Chimera 4/48: A Fábrica Clandestina de D2"
					q.description = "Investigue o laboratório subterrâneo onde o tirano Gyro produzia a droga ilícita D2."
					q.reward_xp = 85000
					q.reward_gold = 1300000
					q.objectives = [_criar_obj_investigate(&"fabrica_d2_gyro")]

				5:
					q.quest_name = "Formigas Chimera 5/48: A Emboscada da Formiga Rammot"
					q.description = "Derrote Rammot, a formiga híbrida com penas que despertou aura após ser golpeada."
					q.reward_xp = 90000
					q.reward_gold = 1400000
					q.objectives = [_criar_obj_kill(&"formiga_oficial", 2)]

				6:
					q.quest_name = "Formigas Chimera 6/48: A Inseminação de Nen no Formigueiro"
					q.description = "Descubra que as formigas oficiais começaram a abrir os nós de aura de todo o exército da Rainha."
					q.reward_xp = 95000
					q.reward_gold = 1500000
					q.objectives = [_criar_obj_visit(&"kite", "Kite")]

				7:
					q.quest_name = "Formigas Chimera 7/48: O Avanço pelas Colinas de NGL"
					q.description = "Derrote esquadrões de formigas soldado em direção à árvore-castelo do ninho principal."
					q.reward_xp = 100000
					q.reward_gold = 1600000
					q.objectives = [_criar_obj_kill(&"formiga_soldado", 4)]

				8:
					q.quest_name = "Formigas Chimera 8/48: A Aura Monstruosa de Neferpitou"
					q.description = "Sinta a intenção assassina avermelhada da Guarda Real Neferpitou emanando do ninho."
					q.reward_xp = 105000
					q.reward_gold = 1700000
					q.objectives = [_criar_obj_visit(&"kite", "Kite")]

				9:
					q.quest_name = "Formigas Chimera 9/48: O Sacrifício Heróico de Kite"
					q.description = "Kite perde o braço para repelir o salto supersônico de Pitou e manda os garotos fugirem."
					q.reward_xp = 110000
					q.reward_gold = 1800000
					q.objectives = [_criar_obj_visit(&"kite", "Kite")]

				10:
					q.quest_name = "Formigas Chimera 10/48: A Fuga Desesperada de Killua"
					q.description = "Killua nocauteia Gon à força e corre em disparada até a fronteira para salvar sua vida."
					q.reward_xp = 115000
					q.reward_gold = 1900000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				11:
					q.quest_name = "Formigas Chimera 11/48: A Chegada da Tropa de Extermínio"
					q.description = "Encontre o Presidente Isaac Netero, Morel e Knov na base militar de Peijin."
					q.reward_xp = 120000
					q.reward_gold = 2000000
					q.objectives = [_criar_obj_visit(&"netero", "Presidente Isaac Netero")]

				12:
					q.quest_name = "Formigas Chimera 12/48: A Provação de Morel e Knov"
					q.description = "Demonstre sua resolução inabalável perante o cachimbo de Morel e as portas de Knov."
					q.reward_xp = 125000
					q.reward_gold = 2100000
					q.objectives = [_criar_obj_visit(&"morel", "Morel Mackernasey")]

				13:
					q.quest_name = "Formigas Chimera 13/48: Os Discípulos Knuckle e Shoot"
					q.description = "Aceite o desafio dos amuletos de madeira contra os discípulos de Morel para ganhar o direito de retornar."
					q.reward_xp = 130000
					q.reward_gold = 2200000
					q.objectives = [_criar_obj_visit(&"knuckle", "Knuckle Bine"), _criar_obj_visit(&"shoot", "Shoot McMahon")]

				14:
					q.quest_name = "Formigas Chimera 14/48: O Hatsu A.P.R. (Hakoware) de Knuckle"
					q.description = "Compreenda a mecânica de empréstimo de aura com juros de 10% e declaração de falência de Nen."
					q.reward_xp = 135000
					q.reward_gold = 2300000
					q.objectives = [_criar_obj_visit(&"knuckle", "Knuckle Bine")]

				15:
					q.quest_name = "Formigas Chimera 15/48: O Hotel Rafflesia de Shoot"
					q.description = "Enfrente as três mãos flutuantes e a gaiola dimensional de Shoot em combate de alta agilidade."
					q.reward_xp = 140000
					q.reward_gold = 2400000
					q.objectives = [_criar_obj_visit(&"shoot", "Shoot McMahon")]

				16:
					q.quest_name = "Formigas Chimera 16/48: O Nascimento Prematuro de Meruem"
					q.description = "O Rei das Formigas Meruem rasga o ventre da Rainha e parte para a República de Goruto Oriental."
					q.reward_xp = 145000
					q.reward_gold = 2500000
					q.objectives = [_criar_obj_investigate(&"nascimento_rei_meruem")]

				17:
					q.quest_name = "Formigas Chimera 17/48: O Resgate no Ninho da Rainha"
					q.description = "Morel e os médicos encontram a Rainha moribunda e resgatam o embrião da pequena irmã do Rei."
					q.reward_xp = 150000
					q.reward_gold = 2600000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

				18:
					q.quest_name = "Formigas Chimera 18/48: Infiltração em Goruto Oriental"
					q.description = "Cruze a fronteira fortificada de Goruto Oriental sob estado de vigilância marcial absoluta."
					q.reward_xp = 155000
					q.reward_gold = 2700000
					q.objectives = [_criar_obj_stealth(&"fronteira_goruto")]

				19:
					q.quest_name = "Formigas Chimera 19/48: A Seleção Humana de Peijin"
					q.description = "Elimine 4 guardas de Peijin hipnotizados para salvar milhares de civis que marcham rumo ao palácio."
					q.reward_xp = 160000
					q.reward_gold = 2800000
					q.objectives = [_criar_obj_kill(&"guarda_peijin", 4)]

				20:
					q.quest_name = "Formigas Chimera 20/48: A Remoção da Agulha de Illumi"
					q.description = "Killua arranca a agulha de manipulação cravada em seu cérebro e liberta sua mente do medo!"
					q.reward_xp = 165000
					q.reward_gold = 2900000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				21:
					q.quest_name = "Formigas Chimera 21/48: O Desenvolvimento do Godspeed (Kanmuru)"
					q.description = "Killua programa descargas elétricas em seus nervos reflexos para se mover na velocidade do relâmpago."
					q.reward_xp = 170000
					q.reward_gold = 3000000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				22:
					q.quest_name = "Formigas Chimera 22/48: O Hide and Seek (4ª Dimensão) de Knov"
					q.description = "Crie portas dimensionais secretas conectadas aos cômodos sob o piso do Palácio Real de Peijin."
					q.reward_xp = 175000
					q.reward_gold = 3100000
					q.objectives = [_criar_obj_investigate(&"portas_knov")]

				23:
					q.quest_name = "Formigas Chimera 23/48: A Partida de Gungi de Komugi"
					q.description = "Observe o Rei Meruem jogando Gungi dia e noite nos aposentos reais contra a jovem cega Komugi."
					q.reward_xp = 180000
					q.reward_gold = 3200000
					q.objectives = [_criar_obj_visit(&"meruem", "Rei Meruem")]

				24:
					q.quest_name = "Formigas Chimera 24/48: A Contagem Regressiva da Invasão"
					q.description = "Reúna Gon, Killua, Knuckle, Shoot, Morel e Meleoron nas portas dimensionais para a hora zero."
					q.reward_xp = 185000
					q.reward_gold = 3300000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				25:
					q.quest_name = "Formigas Chimera 25/48: A Hora Zero (00:00:00)"
					q.description = "Emerja das portas no saguão central do palácio no exato instante em que o ataque aéreo tem início!"
					q.reward_xp = 190000
					q.reward_gold = 3400000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

				26:
					q.quest_name = "Formigas Chimera 26/48: A Chuva de Dragões (Dragon Dive)"
					q.description = "Testemunhe milhares de flechas colossais de Nen de Zeno Zoldyck destruindo o teto do palácio."
					q.reward_xp = 195000
					q.reward_gold = 3500000
					q.objectives = [_criar_obj_investigate(&"chuva_dragoes_zeno")]

				27:
					q.quest_name = "Formigas Chimera 27/48: O Encontro nas Escadarias Centrais"
					q.description = "Depare-se com o titã Menthuthuyoupi transformando seu corpo em carapaça bélica no topo da escada."
					q.reward_xp = 200000
					q.reward_gold = 3600000
					q.objectives = [_criar_obj_visit(&"shoot", "Shoot")]

				28:
					q.quest_name = "Formigas Chimera 28/48: A Fumaça Deep Purple de Morel"
					q.description = "Morel cria uma prisão de fumaça impenetrável para isolar o líder espiritual Shaiapouf."
					q.reward_xp = 205000
					q.reward_gold = 3700000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

				29:
					q.quest_name = "Formigas Chimera 29/48: O Ataque Frenético de Shoot e Knuckle"
					q.description = "Shoot voa sobre sua gaiola e Knuckle ativa o A.P.R. desferindo o primeiro golpe em Youpi."
					q.reward_xp = 210000
					q.reward_gold = 3800000
					q.objectives = [_criar_obj_visit(&"knuckle", "Knuckle")]

				30:
					q.quest_name = "Formigas Chimera 30/48: A Fúria Vulcânica de Youpi"
					q.description = "Youpi aprende a canalizar sua cólera descontrolada em canhões de pura destruição explosiva."
					q.reward_xp = 215000
					q.reward_gold = 3900000
					q.objectives = [_criar_obj_visit(&"knuckle", "Knuckle")]

				31:
					q.quest_name = "Formigas Chimera 31/48: A Intervenção do Relâmpago de Killua"
					q.description = "Killua ativa Kanmuru (Godspeed) e paralisa Youpi no ar com uma sequência fulminante de raios!"
					q.reward_xp = 220000
					q.reward_gold = 4000000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				32:
					q.quest_name = "Formigas Chimera 32/48: A Derrota de Menthuthuyoupi"
					q.description = "Neutralize o guerreiro supremo da Guarda Real Youpi no pátio dos escombros!"
					q.reward_xp = 230000
					q.reward_gold = 4200000
					q.objectives = [_criar_obj_kill(&"youpi", 1)]

				33:
					q.quest_name = "Formigas Chimera 33/48: O Casulo Espiritual de Shaiapouf"
					q.description = "Derrote os clones microscópicos do conspirador Shaiapouf que tentam assassinar Komugi!"
					q.reward_xp = 235000
					q.reward_gold = 4400000
					q.objectives = [_criar_obj_kill(&"shaiapouf", 1)]

				34:
					q.quest_name = "Formigas Chimera 34/48: A Sala de Operação do Dr. Blythe"
					q.description = "Gon entra no quarto real e encontra Neferpitou chorando enquanto opera o corpo ferido de Komugi."
					q.reward_xp = 240000
					q.reward_gold = 4600000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				35:
					q.quest_name = "Formigas Chimera 35/48: A Espera Sombria de Gon"
					q.description = "Gon senta-se de braços cruzados sob um fluxo de aura negra, dando a Pitou 1 hora para salvar a garota."
					q.reward_xp = 245000
					q.reward_gold = 4800000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				36:
					q.quest_name = "Formigas Chimera 36/48: O Voo de Netero e Meruem até a Tumba"
					q.description = "Netero conduz o Rei Meruem de dirigível até a tumba desértica usada para testes de armas nucleares."
					q.reward_xp = 250000
					q.reward_gold = 5000000
					q.objectives = [_criar_obj_visit(&"netero", "Presidente Isaac Netero")]

				37:
					q.quest_name = "Formigas Chimera 37/48: O Guanyin Bodhisattva de 100 Tipos"
					q.description = "Testemunhe Netero invocando a estátua dourada e desferindo milhares de palmas na velocidade do som!"
					q.reward_xp = 260000
					q.reward_gold = 5200000
					q.objectives = [_criar_obj_investigate(&"buda_guanyin_netero")]

				38:
					q.quest_name = "Formigas Chimera 38/48: A Mão Zero de Netero"
					q.description = "Netero reúne toda a sua energia vital e dispara um raio estonteante de Nen pelas costas do Buda."
					q.reward_xp = 270000
					q.reward_gold = 5500000
					q.objectives = [_criar_obj_visit(&"netero", "Presidente Isaac Netero")]

				39:
					q.quest_name = "Formigas Chimera 39/48: A Rosa Pobre (Poor Man's Rose)"
					q.description = "Netero para seu coração com os dedos e detona a ogiva venenosa em miniatura sob a terra."
					q.reward_xp = 280000
					q.reward_gold = 5800000
					q.objectives = [_criar_obj_investigate(&"explosao_rosa_pobre")]

				40:
					q.quest_name = "Formigas Chimera 40/48: A Marcha Fúnebre até Peijin"
					q.description = "Pitou encerra a cirurgia de Komugi e marcha ao lado de Gon até o local onde Kite foi mantido."
					q.reward_xp = 285000
					q.reward_gold = 6000000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				41:
					q.quest_name = "Formigas Chimera 41/48: A Verdade Irreparável sobre Kite"
					q.description = "Pitou ativa suas marionetes e declara: 'A alma daquele homem já se foi... Eu terei que te matar agora'."
					q.reward_xp = 290000
					q.reward_gold = 6200000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				42:
					q.quest_name = "Formigas Chimera 42/48: O Juramento Supremo de Gon (Gon Adulto)"
					q.description = "'Não me importo se este for o meu fim... Vou usar tudo o que um dia teria!'. O corpo de Gon transmuta-se em poder absoluto!"
					q.reward_xp = 310000
					q.reward_gold = 6500000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				43:
					q.quest_name = "Formigas Chimera 43/48: O Jajanken da Aniquilação de Pitou"
					q.description = "Derrote Neferpitou com impactos colossais de Jajanken que fazem a floresta inteira tremer!"
					q.reward_xp = 330000
					q.reward_gold = 7000000
					q.objectives = [_criar_obj_kill(&"neferpitou", 1)]

				44:
					q.quest_name = "Formigas Chimera 44/48: A Chegada em Lágrimas de Killua"
					q.description = "Killua chega ao campo de batalha devastado e encontra o corpo calcinado de Gon desmoronando."
					q.reward_xp = 340000
					q.reward_gold = 7200000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				45:
					q.quest_name = "Formigas Chimera 45/48: O En Fotônico do Rei Ressuscitado"
					q.description = "Meruem retorna ao palácio banhado em luz fotônica procurando a memória de seu amor no escuro."
					q.reward_xp = 350000
					q.reward_gold = 7500000
					q.objectives = [_criar_obj_visit(&"meruem", "Rei Meruem")]

				46:
					q.quest_name = "Formigas Chimera 46/48: A Redenção dos Sobreviventes"
					q.description = "Welfin e as formigas que recuperaram memórias humanas encontram refúgio na cidade de Meteor City."
					q.reward_xp = 360000
					q.reward_gold = 7800000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

				47:
					q.quest_name = "Formigas Chimera 47/48: A Última Partida de Gungi no Escuro"
					q.description = "Testemunhe o abraço final de Meruem e Komugi enquanto a escuridão os acolhe em repouso eterno."
					q.reward_xp = 380000
					q.reward_gold = 8000000
					q.objectives = [_criar_obj_visit(&"meruem", "Rei Meruem")]

				48:
					q.quest_name = "Formigas Chimera 48/48: A Evacuação Geral & O Coma de Gon"
					q.description = "Conclua a evacuação do continente e transporte Gon em suporte vital crítico para a sede da Associação Hunter."
					q.reward_xp = 400000
					q.reward_gold = 9000000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

		# =====================================================
		# ARCO 7: ELEIÇÃO HUNTER & ALLUKA (20 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		7:
			match etapa:
				1:
					q.quest_name = "Eleição Hunter 1/20: A Sede da Associação Hunter"
					q.description = "Apresente-se no auditório principal da sede para a leitura do testamento oficial de Netero."
					q.reward_xp = 120000
					q.reward_gold = 2000000
					q.objectives = [_criar_obj_visit(&"cheadle", "Cheadle Yorkshire (Zodíaco Cão)")]

				2:
					q.quest_name = "Eleição Hunter 2/20: O Testamento dos 12 Zodíacos"
					q.description = "Cheadle e Botobai apresentam as regras deixadas por Netero: quórum mínimo de 95% de todos os Caçadores."
					q.reward_xp = 130000
					q.reward_gold = 2100000
					q.objectives = [_criar_obj_visit(&"cheadle", "Cheadle Yorkshire")]

				3:
					q.quest_name = "Eleição Hunter 3/20: O Jogo Político de Pariston Hill"
					q.description = "Converse com o Vice-Presidente Pariston e descubra suas artimanhas teatrais para sabotar a eleição."
					q.reward_xp = 140000
					q.reward_gold = 2300000
					q.objectives = [_criar_obj_visit(&"pariston", "Pariston Hill (Vice-Presidente)")]

				4:
					q.quest_name = "Eleição Hunter 4/20: O Quarto de UTI no Hospital Hunter"
					q.description = "Visite o leito onde Gon repousa sob suporte vital máximo entre a vida e a morte."
					q.reward_xp = 150000
					q.reward_gold = 2500000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio Paradinight")]

				5:
					q.quest_name = "Eleição Hunter 5/20: A Decisão Proibida de Killua"
					q.description = "Killua retorna em segredo à Montanha Kukuroo para resgatar sua irmã mais nova Alluka."
					q.reward_xp = 160000
					q.reward_gold = 2700000
					q.objectives = [_criar_obj_visit(&"killua", "Killua Zoldyck")]

				6:
					q.quest_name = "Eleição Hunter 6/20: A Masmorra Subterrânea de Alluka"
					q.description = "Penetre nos cofres de segurança máxima nos porões mais profundos da mansão Zoldyck."
					q.reward_xp = 170000
					q.reward_gold = 2900000
					q.objectives = [_criar_obj_investigate(&"cela_alluka")]

				7:
					q.quest_name = "Eleição Hunter 7/20: As Regras dos Desejos de Nanika"
					q.description = "Compreenda a mecânica dos 3 pedidos recusados e o poder de realizar qualquer milagre impossível."
					q.reward_xp = 180000
					q.reward_gold = 3100000
					q.objectives = [_criar_obj_visit(&"alluka", "Alluka & Nanika")]

				8:
					q.quest_name = "Eleição Hunter 8/20: O Resgate nos Braços de Killua"
					q.description = "Killua abraça Alluka, assume a custódia da irmã e parte em direção ao hospital da capital."
					q.reward_xp = 190000
					q.reward_gold = 3300000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				9:
					q.quest_name = "Eleição Hunter 9/20: A Emboscada de Illumi e Hisoka"
					q.description = "Illumi tenta eliminar Alluka por considerá-la uma ameaça cósmica à família Zoldyck."
					q.reward_xp = 200000
					q.reward_gold = 3500000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				10:
					q.quest_name = "Eleição Hunter 10/20: Mordomos Perseguidores na Rodovia"
					q.description = "Derrote 4 mordomos manipulados pelas agulhas de Illumi para abrir a rota da ambulância."
					q.reward_xp = 210000
					q.reward_gold = 3700000
					q.objectives = [_criar_obj_kill(&"mordomo_perseguidor", 4)]

				11:
					q.quest_name = "Eleição Hunter 11/20: O Exército de Homens-Agulha"
					q.description = "Elimine 8 humanos manipulados por agulhas hipnóticas de Illumi que cercam a rodovia expressa."
					q.reward_xp = 225000
					q.reward_gold = 4000000
					q.objectives = [_criar_obj_kill(&"humano_agulha", 8)]

				12:
					q.quest_name = "Eleição Hunter 12/20: O Confronto contra Illumi"
					q.description = "Vença Illumi Zoldyck Boss na rodovia noturna e garanta a passagem até o hospital!"
					q.reward_xp = 240000
					q.reward_gold = 4300000
					q.objectives = [_criar_obj_kill(&"illumi", 1)]

				13:
					q.quest_name = "Eleição Hunter 13/20: A 4ª Rodada da Votação Eleitoral"
					q.description = "Acompanhe o debate acalorado dos Zodíacos no auditório enquanto Ging assiste de braços cruzados."
					q.reward_xp = 250000
					q.reward_gold = 4500000
					q.objectives = [_criar_obj_visit(&"cheadle", "Cheadle")]

				14:
					q.quest_name = "Eleição Hunter 14/20: O Soco Teleportado de Leorio"
					q.description = "Leorio desfere o soco de emissão de Nen que atravessa a mesa do plenário e acerta o rosto de Ging!"
					q.reward_xp = 260000
					q.reward_gold = 4800000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio Paradinight")]

				15:
					q.quest_name = "Eleição Hunter 15/20: Leorio Lidera a Eleição"
					q.description = "O discurso apaixonado de Leorio sobre salvar Gon emociona todos os Caçadores e o coloca em 1º lugar."
					q.reward_xp = 270000
					q.reward_gold = 5000000
					q.objectives = [_criar_obj_visit(&"cheadle", "Cheadle")]

				16:
					q.quest_name = "Eleição Hunter 16/20: O Milagre de Nanika no Hospital"
					q.description = "Alluka segura a mão esquelética de Gon e Nanika liberta uma coluna de luz branca que rasga o céu da cidade!"
					q.reward_xp = 290000
					q.reward_gold = 5500000
					q.objectives = [_criar_obj_visit(&"alluka", "Alluka & Nanika")]

				17:
					q.quest_name = "Eleição Hunter 17/20: A Entrada Triunfal de Gon Curado"
					q.description = "Gon entra caminhando alegremente pelas portas do auditório lotado no meio da apuração dos votos!"
					q.reward_xp = 310000
					q.reward_gold = 6000000
					q.objectives = [_criar_obj_visit(&"gon_recuperado", "Gon Freecss Recuperado")]

				18:
					q.quest_name = "Eleição Hunter 18/20: O Abraço em Lágrimas de Leorio e Gon"
					q.description = "Leorio corre pelo palco e ergue Gon nos braços sob aplausos e choro de todos os Caçadores."
					q.reward_xp = 330000
					q.reward_gold = 6500000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio")]

				19:
					q.quest_name = "Eleição Hunter 19/20: A Eleição da 13ª Presidente Cheadle"
					q.description = "Pariston renuncia ao cargo e nomeia Cheadle Yorkshire como a 13ª Presidente oficial da Associação."
					q.reward_xp = 350000
					q.reward_gold = 7000000
					q.objectives = [_criar_obj_visit(&"cheadle", "Presidente Cheadle")]

				20:
					q.quest_name = "Eleição Hunter 20/20: A Despedida de Killua e Alluka"
					q.description = "Killua promete viajar o mundo protegendo Alluka e se despede de Gon com um sorriso de companheirismo."
					q.reward_xp = 380000
					q.reward_gold = 8000000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

		# =====================================================
		# ARCO 8: CONTINENTE NEGRO (22 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		8:
			match etapa:
				1:
					q.quest_name = "Continente Negro 1/22: A Declaração Global de Beyond Netero"
					q.description = "Assista ao manifesto público de Beyond Netero desafiando as nações do V5 a cruzar os limites do mundo."
					q.reward_xp = 240000
					q.reward_gold = 4000000
					q.objectives = [_criar_obj_visit(&"beyond", "Beyond Netero")]

				2:
					q.quest_name = "Continente Negro 2/22: Os Novos Zodíacos: Kurapika e Leorio"
					q.description = "Kurapika e Leorio assumem oficialmente os assentos de Rato e Javali na mesa dos Zodíacos."
					q.reward_xp = 250000
					q.reward_gold = 4300000
					q.objectives = [_criar_obj_visit(&"cheadle", "Presidente Cheadle")]

				3:
					q.quest_name = "Continente Negro 3/22: O Acampamento de Recrutamento de Ging"
					q.description = "Encontre Ging Freecss no acampamento da expedição e junte-se ao grupo de elite do Novo Mundo."
					q.reward_xp = 265000
					q.reward_gold = 4600000
					q.objectives = [_criar_obj_visit(&"ging", "Ging Freecss")]

				4:
					q.quest_name = "Continente Negro 4/22: O Teste de Nen dos Mercenários"
					q.description = "Demonstre seu refinamento de Ten e Ren perante os especialistas de combate de Beyond."
					q.reward_xp = 280000
					q.reward_gold = 4900000
					q.objectives = [_criar_obj_persuasion(&"ging", "Ging Freecss")]

				5:
					q.quest_name = "Continente Negro 5/22: O Mapa Secreto do Lago Mobius"
					q.description = "Analise o mapa ancestral revelando que o mundo humano é apenas uma pequena lagoa cercada por gigantes."
					q.reward_xp = 295000
					q.reward_gold = 5200000
					q.objectives = [_criar_obj_investigate(&"mapa_lago_mobius")]

				6:
					q.quest_name = "Continente Negro 6/22: A Travessia das Águas Proibidas"
					q.description = "Navegue pelas correntes marítimas tempestuosas sob ataque de feras marinhas titânicas."
					q.reward_xp = 310000
					q.reward_gold = 5500000
					q.objectives = [_criar_obj_stealth(&"aguas_proibidas")]

				7:
					q.quest_name = "Continente Negro 7/22: O Desembarque na Costa Selvagem"
					q.description = "Fixe a bandeira da Associação na praia ancestral e estabeleça o perímetro de defesa do acampamento."
					q.reward_xp = 325000
					q.reward_gold = 5800000
					q.objectives = [_criar_obj_visit(&"beyond", "Beyond Netero")]

				8:
					q.quest_name = "Continente Negro 8/22: As Ruínas Botânicas Ancestrais"
					q.description = "Infiltre-se nos templos da antiga civilização vegetal onde repousam sementes de longevidade."
					q.reward_xp = 340000
					q.reward_gold = 6100000
					q.objectives = [_criar_obj_investigate(&"ruinas_botanicas")]

				9:
					q.quest_name = "Continente Negro 9/22: Os Guardiões Botânicos de Brion"
					q.description = "Derrote 5 guardiões botânicos de Brion que emergem das raízes milenares."
					q.reward_xp = 360000
					q.reward_gold = 6500000
					q.objectives = [_criar_obj_kill(&"guardiao_brion", 5)]

				10:
					q.quest_name = "Continente Negro 10/22: A Calamidade Brion (A Arma Botânica)"
					q.description = "Enfrente a Calamidade Brion com sua cabeça esférica vegetal destruidora de exércitos!"
					q.reward_xp = 380000
					q.reward_gold = 7000000
					q.objectives = [_criar_obj_kill(&"brion_boss", 1)]

				11:
					q.quest_name = "Continente Negro 11/22: O Veneno Sonoro da Serpente Hellbell"
					q.description = "Proteja sua mente da melodia alucinógena que induz à loucura homicida instantânea."
					q.reward_xp = 400000
					q.reward_gold = 7500000
					q.objectives = [_criar_obj_stealth(&"caverna_hellbell")]

				12:
					q.quest_name = "Continente Negro 12/22: A Batalha contra a Serpente Hellbell"
					q.description = "Derrote a Serpente das Duas Caudas Hellbell Boss com ataques de longo alcance de Ren!"
					q.reward_xp = 425000
					q.reward_gold = 8000000
					q.objectives = [_criar_obj_kill(&"hellbell_boss", 1)]

				13:
					q.quest_name = "Continente Negro 13/22: A Forma Gasosa da Entidade Ai"
					q.description = "Isole a névoa dos desejos co-dependentes da Entidade Ai antes que ela drene a aura dos cientistas."
					q.reward_xp = 450000
					q.reward_gold = 8500000
					q.objectives = [_criar_obj_kill(&"ai_boss", 1)]

				14:
					q.quest_name = "Continente Negro 14/22: A Coleta do Arroz Nitro"
					q.description = "Colete amostras das sementes de Nitro Rice que prolongam a vida humana em séculos."
					q.reward_xp = 470000
					q.reward_gold = 9000000
					q.objectives = [_criar_obj_collect(&"nitro_rice", 1)]

				15:
					q.quest_name = "Continente Negro 15/22: As Raízes Continentais da Árvore do Mundo"
					q.description = "Alcance a base da colossal Árvore do Mundo que se alimenta de magma do centro da terra."
					q.reward_xp = 490000
					q.reward_gold = 9500000
					q.objectives = [_criar_obj_visit(&"arvore_mundo", "Árvore do Mundo")]

				16:
					q.quest_name = "Continente Negro 16/22: As Feras Aladas da Copa Intermediária"
					q.description = "Derrote 4 feras aladas gigantescas que nidificam nos galhos intermediários a 800m de altura."
					q.reward_xp = 510000
					q.reward_gold = 10000000
					q.objectives = [_criar_obj_kill(&"guardiao_brion", 4)]

				17:
					q.quest_name = "Continente Negro 17/22: A Escalada dos 1.784 Metros"
					q.description = "Escale o tronco titânico acima da camada de nuvens sob ventos congelantes de alta altitude."
					q.reward_xp = 530000
					q.reward_gold = 10500000
					q.objectives = [_criar_obj_visit(&"arvore_mundo", "Árvore do Mundo")]

				18:
					q.quest_name = "Continente Negro 18/22: O Ninho Gigante da Copa"
					q.description = "Alcance a plataforma do ninho de criaturas lendárias no cume mais alto da árvore."
					q.reward_xp = 550000
					q.reward_gold = 11000000
					q.objectives = [_criar_obj_visit(&"ging_topo", "Ging Freecss no Topo")]

				19:
					q.quest_name = "Continente Negro 19/22: O Reencontro no Topo do Mundo"
					q.description = "Sente-se sob a brisa infinita com Ging Freecss e contemplem a curvatura do planeta."
					q.reward_xp = 575000
					q.reward_gold = 11500000
					q.objectives = [_criar_obj_visit(&"ging_topo", "Ging Freecss no Topo")]

				20:
					q.quest_name = "Continente Negro 20/22: A Filosofia do Verdadeiro Caçador"
					q.description = "Ging explica que o verdadeiro tesouro não é o destino final, mas os companheiros e histórias do caminho."
					q.reward_xp = 600000
					q.reward_gold = 12000000
					q.objectives = [_criar_obj_persuasion(&"ging_topo", "Ging Freecss no Topo")]

				21:
					q.quest_name = "Continente Negro 21/22: O Horizonte Sem Fim"
					q.description = "Ging aponta para as terras infinitas além do Lago Mobius que aguardam as próximas gerações."
					q.reward_xp = 625000
					q.reward_gold = 12500000
					q.objectives = [_criar_obj_investigate(&"horizonte_infinito")]

				22:
					q.quest_name = "Continente Negro 22/22: O Convite Real de Kakin"
					q.description = "Receba a convocação de emergência de Kurapika para embarcar na viagem real do navio Black Whale 1!"
					q.reward_xp = 650000
					q.reward_gold = 13000000
					q.objectives = [_criar_obj_visit(&"ging_topo", "Ging Freecss no Topo")]

		# =====================================================
		# ARCO 9: GUERRA DE SUCESSÃO DE KAKIN (26 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		9:
			match etapa:
				1:
					q.quest_name = "Guerra de Sucessão 1/26: O Embarque no Black Whale 1"
					q.description = "Apresente-se com Kurapika e a comitiva real no Convés 1 do navio colossal Black Whale 1."
					q.reward_xp = 350000
					q.reward_gold = 7000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				2:
					q.quest_name = "Guerra de Sucessão 2/26: Os Aposentos 1014 da Rainha Oito"
					q.description = "Estabeleça o perímetro blindado de defesa para a Rainha Oito e o bebê Príncipe Woble."
					q.reward_xp = 370000
					q.reward_gold = 7500000
					q.objectives = [_criar_obj_visit(&"rainha_oito", "Rainha Oito & Príncipe Woble")]

				3:
					q.quest_name = "Guerra de Sucessão 3/26: O Ritual do Vaso Sagrado de Kakin"
					q.description = "Examine o Vaso Sagrado ancestral que concedeu Bestas Parasitas de Nen aos 14 Príncipes."
					q.reward_xp = 390000
					q.reward_gold = 8000000
					q.objectives = [_criar_obj_visit(&"vaso_kakin", "Vaso Sagrado de Kakin")]

				4:
					q.quest_name = "Guerra de Sucessão 4/26: O Primeiro Assassinato a Bordo"
					q.description = "Investigue o assassinato silencioso dos guardas de honra eliminados por Nen invisível."
					q.reward_xp = 410000
					q.reward_gold = 8500000
					q.objectives = [_criar_obj_investigate(&"primeiro_assassinato_kakin")]

				5:
					q.quest_name = "Guerra de Sucessão 5/26: O Stealth Dolphin de Kurapika"
					q.description = "Use o golfinho de Nen do Emperor Time para analisar as auras das Bestas Guardiãs com Gyo."
					q.reward_xp = 430000
					q.reward_gold = 9000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				6:
					q.quest_name = "Guerra de Sucessão 6/26: As Bestas Parasitas Rebeldes"
					q.description = "Derrote 3 Bestas Parasitas Guardiãs que invadem os corredores do 1º Convés Real."
					q.reward_xp = 450000
					q.reward_gold = 9500000
					q.objectives = [_criar_obj_kill(&"besta_parasita", 3)]

				7:
					q.quest_name = "Guerra de Sucessão 7/26: A Aula de Nen nos Aposentos Reais"
					q.description = "Auxilie Kurapika a treinar os guardas reais nos fundamentos de Ten para equilibrar as defesas."
					q.reward_xp = 475000
					q.reward_gold = 10000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				8:
					q.quest_name = "Guerra de Sucessão 8/26: Os Conveses Intermediários da Máfia"
					q.description = "Desça aos conveses 3 e 4 onde as três famílias da Máfia de Kakin controlam os armazéns."
					q.reward_xp = 500000
					q.reward_gold = 10500000
					q.objectives = [_criar_obj_visit(&"hinrigh", "Hinrigh (Família Xi-Yu)")]

				9:
					q.quest_name = "Guerra de Sucessão 9/26: A Aliança com Hinrigh Biganduffno"
					q.description = "Conheça o Hatsu Biohazard de Hinrigh que transforma armas e algemas em animais vivos."
					q.reward_xp = 525000
					q.reward_gold = 11000000
					q.objectives = [_criar_obj_visit(&"hinrigh", "Hinrigh")]

				10:
					q.quest_name = "Guerra de Sucessão 10/26: O Contágio de Morena Prudo"
					q.description = "Descubra a seita de assassinos nivelados por sangue da família mafiosa Heil-Ly."
					q.reward_xp = 550000
					q.reward_gold = 11500000
					q.objectives = [_criar_obj_investigate(&"seita_heilly")]

				11:
					q.quest_name = "Guerra de Sucessão 11/26: O Massacre da Família Heil-Ly"
					q.description = "Elimine 6 assassinos contagiados por Nen da seita Heil-Ly nos conveses inferiores."
					q.reward_xp = 580000
					q.reward_gold = 12000000
					q.objectives = [_criar_obj_kill(&"assassino_heilly", 6)]

				12:
					q.quest_name = "Guerra de Sucessão 12/26: A Caçada da Trupe Fantasma no Navio"
					q.description = "Chrollo Lucilfer, Feitan, Phinks e Nobunaga vasculham os conveses profundos caçando Hisoka."
					q.reward_xp = 600000
					q.reward_gold = 12500000
					q.objectives = [_criar_obj_visit(&"chrollo", "Chrollo Lucilfer")]

				13:
					q.quest_name = "Guerra de Sucessão 13/26: As Pistas de Sangue de Hisoka"
					q.description = "Encontre as marcas de goma elástica deixadas por Hisoka nos armazéns do Convés 5."
					q.reward_xp = 625000
					q.reward_gold = 13000000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka Morow")]

				14:
					q.quest_name = "Guerra de Sucessão 14/26: A Trégua Provisória com a Trupe"
					q.description = "Negocie uma trégua de não-agressão temporária com a Trupe Fantasma nos armazéns escuros."
					q.reward_xp = 650000
					q.reward_gold = 13500000
					q.objectives = [_criar_obj_persuasion(&"chrollo", "Chrollo Lucilfer")]

				15:
					q.quest_name = "Guerra de Sucessão 15/26: Os Aposentos do 4º Príncipe Tserriednich"
					q.description = "Infiltre-se no salão de arte sombria do sádico 4º Príncipe Tserriednich Hui Guo Rou."
					q.reward_xp = 680000
					q.reward_gold = 14000000
					q.objectives = [_criar_obj_stealth(&"aposentos_tserriednich")]

				16:
					q.quest_name = "Guerra de Sucessão 16/26: O Despertar da Besta de Dupla Face"
					q.description = "Sinta a aura fétida e colossal da Besta Guardiã de Tserriednich com rosto de mulher e patas de cavalo."
					q.reward_xp = 710000
					q.reward_gold = 14500000
					q.objectives = [_criar_obj_investigate(&"besta_tserriednich")]

				17:
					q.quest_name = "Guerra de Sucessão 17/26: O Zetsu do Futuro Paralelo"
					q.description = "Compreenda o Hatsu temporal que permite a Tserriednich ver e alterar os próximos 10 segundos!"
					q.reward_xp = 740000
					q.reward_gold = 15000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				18:
					q.quest_name = "Guerra de Sucessão 18/26: O Combate contra a Besta Facial"
					q.description = "Derrote a Besta Guardiã de Tserriednich antes que sua saliva contagiosa marque Kurapika!"
					q.reward_xp = 770000
					q.reward_gold = 16000000
					q.objectives = [_criar_obj_kill(&"besta_tserriednich", 1)]

				19:
					q.quest_name = "Guerra de Sucessão 19/26: O Confronto com o Príncipe Tserriednich"
					q.description = "Derrote o Príncipe Tserriednich Boss superando suas ilusões temporais com ataque coordenado de Ren!"
					q.reward_xp = 820000
					q.reward_gold = 17000000
					q.objectives = [_criar_obj_kill(&"tserriednich_boss", 1)]

				20:
					q.quest_name = "Guerra de Sucessão 20/26: A Revolta dos Soldados do Convés 3"
					q.description = "Contenha a rebelião armada dos guardas militares rebeldes no salão de festas do navio."
					q.reward_xp = 850000
					q.reward_gold = 18000000
					q.objectives = [_criar_obj_kill(&"assassino_heilly", 4)]

				21:
					q.quest_name = "Guerra de Sucessão 21/26: A Batalha dos Conveses Profundos"
					q.description = "Elimine os monstros de Nen invocados pelos traidores nos armazéns de combustível."
					q.reward_xp = 880000
					q.reward_gold = 19000000
					q.objectives = [_criar_obj_kill(&"besta_parasita", 2)]

				22:
					q.quest_name = "Guerra de Sucessão 22/26: O Duelo de Titãs nos Conveses"
					q.description = "Testemunhe o confronto magistral entre Chrollo Lucilfer e Hisoka Morow nos armazéns inferiores!"
					q.reward_xp = 910000
					q.reward_gold = 20000000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka")]

				23:
					q.quest_name = "Guerra de Sucessão 23/26: A Proteção do Príncipe Woble"
					q.description = "Garantir a integridade física da Rainha Oito e do pequeno Príncipe Woble na câmara blindada."
					q.reward_xp = 940000
					q.reward_gold = 21000000
					q.objectives = [_criar_obj_visit(&"rainha_oito", "Rainha Oito")]

				24:
					q.quest_name = "Guerra de Sucessão 24/26: O Comandante da Conspiração de Kakin"
					q.description = "Derrote o Boss Final da Conspiração Imperial de Kakin nos conveses de comando!"
					q.reward_xp = 1000000
					q.reward_gold = 25000000
					q.objectives = [_criar_obj_kill(&"boss_final_kakin", 1)]

				25:
					q.quest_name = "Guerra de Sucessão 25/26: A Estabilização do Black Whale 1"
					q.description = "Restaure a ordem a bordo do navio e assegure a rota pacífica rumo ao Novo Mundo."
					q.reward_xp = 1050000
					q.reward_gold = 27000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				26:
					q.quest_name = "Guerra de Sucessão 26/26: A Consagração do Maior Caçador da História"
					q.description = "Retorne vitorioso à Capital dos Caçadores com a Licença Hunter Suprema e o título de Maior Caçador da História!"
					q.reward_xp = 1200000
					q.reward_gold = 30000000
					q.objectives = [_criar_obj_visit(&"cheadle", "Presidente Cheadle")]

	_quest_cache[chave] = q
	return q


static func _criar_obj_visit(npc_id: StringName, npc_nome: String) -> QuestObjective:
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.VISIT
	obj.target_npc_id = npc_id
	obj.target_npc_name = npc_nome
	obj.required_amount = 1
	return obj


static func _criar_obj_kill(enemy_id: StringName, qtd: int) -> QuestObjective:
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.KILL
	obj.enemy_type = enemy_id
	obj.required_amount = qtd
	return obj


static func _criar_obj_collect(item_id: StringName, qtd: int) -> QuestObjective:
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.COLLECT
	obj.item_id = item_id
	obj.required_amount = qtd
	return obj


static func _criar_obj_investigate(clue_id: StringName) -> QuestObjective:
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.INVESTIGATE
	obj.target_clue_id = clue_id
	obj.required_amount = 1
	return obj


static func _criar_obj_stealth(zone_id: StringName) -> QuestObjective:
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.STEALTH_PASS
	obj.target_zone_id = zone_id
	obj.required_amount = 1
	return obj


static func _criar_obj_persuasion(npc_id: StringName, npc_nome: String) -> QuestObjective:
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.PERSUASION
	obj.target_npc_id = npc_id
	obj.target_npc_name = npc_nome
	obj.required_amount = 1
	return obj
