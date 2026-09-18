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
					q.description = "ORDEM: Fale com Leorio no leilão. Yorknew é longa — um objetivo de cada vez. Depois: [G] antiguidades do mercado."
					q.reward_xp = 14000
					q.reward_gold = 200000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio Paradinight")]

				2:
					q.quest_name = "Yorknew City 2/34: A Arte da Pechincha no Mercado"
					q.description = "ORDEM: Ative [G] Gyo e inspecione a Antiguidade do Mercado (pista no distrito do leilão). Sem Gyo, não pechinche."
					q.reward_xp = 15000
					q.reward_gold = 220000
					q.objectives = [_criar_obj_investigate(&"antiguidade_mercado")]

				3:
					q.quest_name = "Yorknew City 3/34: O Contrato dos Guarda-Costas Nostrade"
					q.description = "ORDEM: Fale com Kurapika (comitiva Nostrade). Próximo será Melody — não pule."
					q.reward_xp = 16000
					q.reward_gold = 240000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika (Guarda-Costas Nostrade)")]

				4:
					q.quest_name = "Yorknew City 4/34: A Melodia do Coração de Melody"
					q.description = "ORDEM: Fale com Melody. Depois o GPS marca mafiosos nas docas — caminhe, não rush."
					q.reward_xp = 17000
					q.reward_gold = 260000
					q.objectives = [_criar_obj_visit(&"melody", "Melody (Musicista Hunter)")]

				5:
					q.quest_name = "Yorknew City 5/34: Mafiosos Corrompidos da Noite"
					q.description = "ORDEM: Derrote 4 mafiosos corrompidos (GPS). Use espaço de combate / Hatsu. Depois volte ao leilão com Kurapika."
					q.reward_xp = 18500
					q.reward_gold = 280000
					q.objectives = [_criar_obj_kill(&"mafioso_corrompido", 4)]

				6:
					q.quest_name = "Yorknew City 6/34: A Noite do Leilão Subterrâneo"
					q.description = "ORDEM: Fale com Kurapika e infiltre o leilão. Yorknew alonga daqui — distritos seguintes pedem caminhada."
					q.reward_xp = 20000
					q.reward_gold = 300000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				7:
					q.quest_name = "Yorknew City 7/34: O Ataque Sombra da Trupe Fantasma"
					q.description = "ORDEM: [G] Inspecione o Cofre Vazio do Leilão — a Trupe já passou. Depois siga o GPS (sem confrontar fora de ordem)."
					q.reward_xp = 21000
					q.reward_gold = 320000
					q.objectives = [_criar_obj_investigate(&"cofre_vazio_leilao")]

				8:
					q.quest_name = "Yorknew City 8/34: A Perseguição ao Balão de Fuga"
					q.description = "ORDEM: Siga o GPS pela avenida (longa caminhada). Use [Z] nos becos se o marcador pedir. Sem rush."
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
					q.description = "ORDEM: [G] Inspecione a Marca do Réquiem (Cemitério/Trupe). Depois GPS — Yorknew continua longa."
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
					q.description = "ORDEM: [Z] Atravesse a Subestação do Apagão em Zetsu (zona marcada). Sem Zetsu = emboscada."
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
					q.description = "ORDEM: Fale com Battera. GI é longa — um objetivo de cada vez. Depois: Quadro de Antokiba."
					q.reward_xp = 35000
					q.reward_gold = 600000
					q.objectives = [_criar_obj_visit(&"battera", "Bilionário Battera")]

				2:
					q.quest_name = "Greed Island 2/36: A Cidade Inicial de Antokiba"
					q.description = "ORDEM: Fale com o Quadro de Antokiba (regras). Depois [G] no Spell Book."
					q.reward_xp = 38000
					q.reward_gold = 650000
					q.objectives = [_criar_obj_visit(&"antokiba", "Quadro de Antokiba")]

				3:
					q.quest_name = "Greed Island 3/36: O Livro de Magia (Spell Book)"
					q.description = "ORDEM: Ative [G] Gyo e inspecione o Spell Book em Antokiba. Sem Book, não caçe cartas."
					q.reward_xp = 40000
					q.reward_gold = 700000
					q.objectives = [_criar_obj_investigate(&"livro_greed")]

				4:
					q.quest_name = "Greed Island 4/36: O Primeiro Feitiço de Rastreio"
					q.description = "ORDEM: Derrote 2 monstros mágicos (GPS nas colinas). Use espaço de combate. Depois vá ao Desfiladeiro (Biscuit)."
					q.reward_xp = 42000
					q.reward_gold = 750000
					q.objectives = [_criar_obj_kill(&"monstro_greed", 2)]

				5:
					q.quest_name = "Greed Island 5/36: O Encontro com Biscuit Krueger"
					q.description = "ORDEM: Caminhe até o Desfiladeiro e fale com Biscuit. Treino longo começa agora — sem pular."
					q.reward_xp = 45000
					q.reward_gold = 800000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				6:
					q.quest_name = "Greed Island 6/36: O Treino no Desfiladeiro de Pedras"
					q.description = "ORDEM: [G] Inspecione o Desfiladeiro de Pedras. Depois [KO] nas rochas quando Biscuit pedir."
					q.reward_xp = 48000
					q.reward_gold = 850000
					q.objectives = [_criar_obj_investigate(&"desfiladeiro_biscuit")]

				7:
					q.quest_name = "Greed Island 7/36: O Domínio do Ko (Concentração Total)"
					q.description = "ORDEM: Fale com Biscuit e treine Ko. Quebre rochas com concentração — um exercício."
					q.reward_xp = 50000
					q.reward_gold = 900000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				8:
					q.quest_name = "Greed Island 8/36: Os Golens de Rocha"
					q.description = "ORDEM: Derrote 3 Golens de Pedra (GPS). Use Ko/espaço de combate. Depois volte a Biscuit (Shu)."
					q.reward_xp = 53000
					q.reward_gold = 950000
					q.objectives = [_criar_obj_kill(&"golem_pedra", 3)]

				9:
					q.quest_name = "Greed Island 9/36: O Domínio do Shu (Extensão de Aura)"
					q.description = "ORDEM: Fale com Biscuit e treine Shu (envolver armas com aura). Um exercício. Depois Ken."
					q.reward_xp = 56000
					q.reward_gold = 1000000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				10:
					q.quest_name = "Greed Island 10/36: O Domínio do Ken (Armadura Contínua)"
					q.description = "ORDEM: Fale com Biscuit e mantenha Ken sob pressão. Sem pular. Depois Ryu."
					q.reward_xp = 58000
					q.reward_gold = 1050000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				11:
					q.quest_name = "Greed Island 11/36: O Domínio do Ryu (Distribuição Dinâmica)"
					q.description = "ORDEM: Fale com Biscuit e treine Ryu (70/30, 80/20). Depois nasce o Hatsu."
					q.reward_xp = 60000
					q.reward_gold = 1100000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				12:
					q.quest_name = "Greed Island 12/36: O Nascimento do Hatsu Jajanken"
					q.description = "ORDEM: Fale com Biscuit — finalize o ciclo de treino. Hatsu completo só após zerar GI."
					q.reward_xp = 62000
					q.reward_gold = 1150000
					q.objectives = [_criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")]

				13:
					q.quest_name = "Greed Island 13/36: A Eletricidade Pura de Killua"
					q.description = "ORDEM: Fale com Killua no Desfiladeiro (Yo-yos / eletricidade). Depois caça de monstros (GPS)."
					q.reward_xp = 64000
					q.reward_gold = 1200000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				14:
					q.quest_name = "Greed Island 14/36: A Caçada de Monstros Mágicos"
					q.description = "ORDEM: Derrote 4 monstros mágicos (GPS nas colinas). Espaço de combate. Depois Tsezguerra."
					q.reward_xp = 66000
					q.reward_gold = 1250000
					q.objectives = [_criar_obj_kill(&"monstro_greed", 4)]

				15:
					q.quest_name = "Greed Island 15/36: A Aliança com Tsezguerra"
					q.description = "ORDEM: Fale com Tsezguerra (aliança). Proteja o Book. Depois [G] marca do Bomber."
					q.reward_xp = 68000
					q.reward_gold = 1300000
					q.objectives = [_criar_obj_visit(&"tsezguerra", "Tsezguerra")]

				16:
					q.quest_name = "Greed Island 16/36: A Ameaça do Bomber Genthru"
					q.description = "ORDEM: [G] Inspecione a Marca da Explosão do Bomber. Proteja o Book — depois GPS (Goreinu)."
					q.reward_xp = 70000
					q.reward_gold = 1350000
					q.objectives = [_criar_obj_investigate(&"explosao_bomber")]

				17:
					q.quest_name = "Greed Island 17/36: O Pacto com Goreinu"
					q.description = "ORDEM: Fale com Goreinu em Soufrabi. Depois Hisoka no lago. [Z] no porto se o GPS pedir."
					q.reward_xp = 72000
					q.reward_gold = 1400000
					q.objectives = [_criar_obj_visit(&"goreinu", "Goreinu")]

				18:
					q.quest_name = "Greed Island 18/36: O Encontro com Hisoka em Greed Island"
					q.description = "ORDEM: Fale com Hisoka (lago / Soufrabi) e recrute-o. Depois vá ao ginásio de Razor."
					q.reward_xp = 75000
					q.reward_gold = 1450000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka Morow")]

				19:
					q.quest_name = "Greed Island 19/36: A Cidade Portuária de Soufrabi"
					q.description = "ORDEM: Fale com Razor no porto/ginásio. Sem rush — demônios e queimada vêm depois."
					q.reward_xp = 78000
					q.reward_gold = 1500000
					q.objectives = [_criar_obj_visit(&"razor", "Game Master Razor")]

				20:
					q.quest_name = "Greed Island 20/36: O Ginásio do Game Master Razor"
					q.description = "ORDEM: Apresente-se a Razor no ginásio. Depois derrote os demônios de Nen (GPS)."
					q.reward_xp = 80000
					q.reward_gold = 1550000
					q.objectives = [_criar_obj_visit(&"razor", "Game Master Razor")]

				21:
					q.quest_name = "Greed Island 21/36: Os 14 Demônios de Nen de Razor"
					q.description = "ORDEM: Derrote 6 demônios de Nen (GPS no ginásio). Espaço de combate. Depois monte o time."
					q.reward_xp = 85000
					q.reward_gold = 1650000
					q.objectives = [_criar_obj_kill(&"demonio_razor", 6)]

				22:
					q.quest_name = "Greed Island 22/36: A Equipe de Queimada Mortal"
					q.description = "ORDEM: Fale com Goreinu e feche o time da queimada. Um passo — sem rush no saque."
					q.reward_xp = 88000
					q.reward_gold = 1700000
					q.objectives = [_criar_obj_visit(&"goreinu", "Goreinu")]

				23:
					q.quest_name = "Greed Island 23/36: O Saque Supersônico de Razor"
					q.description = "ORDEM: Fale com Biscuit antes do saque. Defenda com Ryu — depois Killua segura a bola."
					q.reward_xp = 92000
					q.reward_gold = 1800000
					q.objectives = [_criar_obj_visit(&"biscuit", "Biscuit")]

				24:
					q.quest_name = "Greed Island 24/36: O Sacrifício das Mãos de Killua"
					q.description = "ORDEM: Fale com Killua (mãos / Yo-yos). Depois derrote Razor Boss (GPS)."
					q.reward_xp = 96000
					q.reward_gold = 1900000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				25:
					q.quest_name = "Greed Island 25/36: O Arremesso Triplo contra Razor"
					q.description = "ORDEM: Derrote o Game Master Razor Boss (GPS). Espaço de combate. Depois receba a Carta 002."
					q.reward_xp = 105000
					q.reward_gold = 2200000
					q.objectives = [_criar_obj_kill(&"razor_boss", 1)]

				26:
					q.quest_name = "Greed Island 26/36: A Conquista da Carta 002 (Litoral do Mar)"
					q.description = "ORDEM: Fale com Razor e receba a Carta 002. Depois Biscuit (estratégia Bomber)."
					q.reward_xp = 110000
					q.reward_gold = 2300000
					q.objectives = [_criar_obj_visit(&"razor", "Game Master Razor")]

				27:
					q.quest_name = "Greed Island 27/36: A Estratégia contra o Trio Bomber"
					q.description = "ORDEM: Fale com Biscuit — plano em 3 frentes. Depois combate / Killua / Cova."
					q.reward_xp = 115000
					q.reward_gold = 2400000
					q.objectives = [_criar_obj_visit(&"biscuit", "Biscuit")]

				28:
					q.quest_name = "Greed Island 28/36: A Verdadeira Força de Biscuit"
					q.description = "ORDEM: Derrote 2 subordinados do Bomber (GPS no corredor). Depois Killua (armadilha elétrica)."
					q.reward_xp = 120000
					q.reward_gold = 2500000
					q.objectives = [_criar_obj_kill(&"monstro_greed", 2)]

				29:
					q.quest_name = "Greed Island 29/36: A Armadilha Elétrica de Killua"
					q.description = "ORDEM: Fale com Killua (neutralizar Sub). Depois [Z] na Cova-Armadilha."
					q.reward_xp = 125000
					q.reward_gold = 2600000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				30:
					q.quest_name = "Greed Island 30/36: A Cova de Pedra de Gon"
					q.description = "ORDEM: [Z] Atravesse a Cova-Armadilha em Zetsu. Sem Zetsu = Bomber alerta. Depois GPS (Genthru)."
					q.reward_xp = 130000
					q.reward_gold = 2700000
					q.objectives = [_criar_obj_stealth(&"armadilha_cova_gon")]

				31:
					q.quest_name = "Greed Island 31/36: O Jajanken Decisivo contra Genthru"
					q.description = "ORDEM: Derrote Genthru Bomber (GPS). Espaço de combate. Depois cura / Goreinu."
					q.reward_xp = 145000
					q.reward_gold = 3000000
					q.objectives = [_criar_obj_kill(&"genthru", 1)]

				32:
					q.quest_name = "Greed Island 32/36: O Sopro do Arcanjo (Carta 017)"
					q.description = "ORDEM: Fale com Goreinu (Carta 017 / cura). Depois [G] Quiz das 100 cartas no Castelo."
					q.reward_xp = 150000
					q.reward_gold = 3200000
					q.objectives = [_criar_obj_visit(&"goreinu", "Goreinu")]

				33:
					q.quest_name = "Greed Island 33/36: O Quiz das 100 Cartas"
					q.description = "ORDEM: [G] Inspecione o Altar das 100 Cartas. Depois fale com Elena no castelo."
					q.reward_xp = 155000
					q.reward_gold = 3400000
					q.objectives = [_criar_obj_investigate(&"quiz_100_cartas")]

				34:
					q.quest_name = "Greed Island 34/36: O Castelo Final da Vitória"
					q.description = "ORDEM: Fale com Elena no castelo. Depois escolha as três cartas (Accompany)."
					q.reward_xp = 160000
					q.reward_gold = 3600000
					q.objectives = [_criar_obj_visit(&"elena_greed", "Elena (Criadora de Greed Island)")]

				35:
					q.quest_name = "Greed Island 35/36: As Três Cartas para o Mundo Real"
					q.description = "ORDEM: Fale com Elena — selecione Accompany (e Blue Planet). Depois voo final."
					q.reward_xp = 170000
					q.reward_gold = 4000000
					q.objectives = [_criar_obj_visit(&"elena_greed", "Elena")]

				36:
					q.quest_name = "Greed Island 36/36: O Voo com Accompany até Nigg"
					q.description = "ORDEM: Fale com Elena e use Accompany. Portal NGL só após esta etapa. Sem rush."
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
					q.description = "ORDEM: Fale com Kite na fronteira NGL. Formigas depois — um objetivo de cada vez."
					q.reward_xp = 70000
					q.reward_gold = 1000000
					q.objectives = [_criar_obj_visit(&"kite", "Kite (Caçador de Contratos)")]

				2:
					q.quest_name = "Formigas Chimera 2/48: A Roleta do Crazy Slots"
					q.description = "ORDEM: Fale com Kite de novo (Crazy Slots). Depois derrote formigas soldado (GPS)."
					q.reward_xp = 75000
					q.reward_gold = 1100000
					q.objectives = [_criar_obj_visit(&"kite", "Kite")]

				3:
					q.quest_name = "Formigas Chimera 3/48: Patrulhas de Formigas Soldado"
					q.description = "ORDEM: Derrote 5 formigas soldado (GPS). Espaço de combate. Depois [G] Fábrica D2."
					q.reward_xp = 80000
					q.reward_gold = 1200000
					q.objectives = [_criar_obj_kill(&"formiga_soldado", 5)]

				4:
					q.quest_name = "Formigas Chimera 4/48: A Fábrica Clandestina de D2"
					q.description = "ORDEM: [G] Inspecione a Fábrica D2 de Gyro. Depois Rammot (GPS)."
					q.reward_xp = 85000
					q.reward_gold = 1300000
					q.objectives = [_criar_obj_investigate(&"fabrica_d2_gyro")]

				5:
					q.quest_name = "Formigas Chimera 5/48: A Emboscada da Formiga Rammot"
					q.description = "ORDEM: Derrote 2 formigas oficiais / Rammot (GPS). Depois volte a Kite."
					q.reward_xp = 90000
					q.reward_gold = 1400000
					q.objectives = [_criar_obj_kill(&"formiga_oficial", 2)]

				6:
					q.quest_name = "Formigas Chimera 6/48: A Inseminação de Nen no Formigueiro"
					q.description = "ORDEM: Fale com Kite — oficiais abriram nós de aura. Depois colinas (GPS)."
					q.reward_xp = 95000
					q.reward_gold = 1500000
					q.objectives = [_criar_obj_visit(&"kite", "Kite")]

				7:
					q.quest_name = "Formigas Chimera 7/48: O Avanço pelas Colinas de NGL"
					q.description = "ORDEM: Derrote 4 formigas nas colinas (GPS). Sem rush ao ninho."
					q.reward_xp = 100000
					q.reward_gold = 1600000
					q.objectives = [_criar_obj_kill(&"formiga_soldado", 4)]

				8:
					q.quest_name = "Formigas Chimera 8/48: A Aura Monstruosa de Neferpitou"
					q.description = "ORDEM: Fale com Kite — sinta a aura de Pitou. Prepare fuga. Sem atacar a Guarda Real ainda."
					q.reward_xp = 105000
					q.reward_gold = 1700000
					q.objectives = [_criar_obj_visit(&"kite", "Kite")]

				9:
					q.quest_name = "Formigas Chimera 9/48: O Sacrifício Heróico de Kite"
					q.description = "ORDEM: Fale com Kite (último aviso). Depois Killua cobre a fuga — GPS."
					q.reward_xp = 110000
					q.reward_gold = 1800000
					q.objectives = [_criar_obj_visit(&"kite", "Kite")]

				10:
					q.quest_name = "Formigas Chimera 10/48: A Fuga Desesperada de Killua"
					q.description = "ORDEM: Fale com Killua na fronteira e fuja. Depois base Peijin (Netero)."
					q.reward_xp = 115000
					q.reward_gold = 1900000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				11:
					q.quest_name = "Formigas Chimera 11/48: A Chegada da Tropa de Extermínio"
					q.description = "ORDEM: Fale com Netero na base Peijin. Depois Morel. Um mentor de cada vez."
					q.reward_xp = 120000
					q.reward_gold = 2000000
					q.objectives = [_criar_obj_visit(&"netero", "Presidente Isaac Netero")]

				12:
					q.quest_name = "Formigas Chimera 12/48: A Provação de Morel e Knov"
					q.description = "ORDEM: Fale com Morel e prove resolução. Depois Knuckle e Shoot."
					q.reward_xp = 125000
					q.reward_gold = 2100000
					q.objectives = [_criar_obj_visit(&"morel", "Morel Mackernasey")]

				13:
					q.quest_name = "Formigas Chimera 13/48: Os Discípulos Knuckle e Shoot"
					q.description = "ORDEM: Fale com Knuckle e Shoot (amuletos). Sem pular — GPS."
					q.reward_xp = 130000
					q.reward_gold = 2200000
					q.objectives = [_criar_obj_visit(&"knuckle", "Knuckle Bine"), _criar_obj_visit(&"shoot", "Shoot McMahon")]

				14:
					q.quest_name = "Formigas Chimera 14/48: O Hatsu A.P.R. (Hakoware) de Knuckle"
					q.description = "ORDEM: Fale com Knuckle — entenda A.P.R. / juros. Depois Shoot (Rafflesia)."
					q.reward_xp = 135000
					q.reward_gold = 2300000
					q.objectives = [_criar_obj_visit(&"knuckle", "Knuckle Bine")]

				15:
					q.quest_name = "Formigas Chimera 15/48: O Hotel Rafflesia de Shoot"
					q.description = "ORDEM: Fale com Shoot (mãos flutuantes). Depois [G] nascimento do Rei."
					q.reward_xp = 140000
					q.reward_gold = 2400000
					q.objectives = [_criar_obj_visit(&"shoot", "Shoot McMahon")]

				16:
					q.quest_name = "Formigas Chimera 16/48: O Nascimento Prematuro de Meruem"
					q.description = "ORDEM: [G] Inspecione o Vestígio do Nascimento do Rei. Depois Morel no ninho."
					q.reward_xp = 145000
					q.reward_gold = 2500000
					q.objectives = [_criar_obj_investigate(&"nascimento_rei_meruem")]

				17:
					q.quest_name = "Formigas Chimera 17/48: O Resgate no Ninho da Rainha"
					q.description = "ORDEM: Fale com Morel (resgate). Depois [Z] Fronteira Goruto."
					q.reward_xp = 150000
					q.reward_gold = 2600000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

				18:
					q.quest_name = "Formigas Chimera 18/48: Infiltração em Goruto Oriental"
					q.description = "ORDEM: [Z] Atravesse a Fronteira Goruto em Zetsu. Sem Zetsu = alerta. Depois guardas Peijin."
					q.reward_xp = 155000
					q.reward_gold = 2700000
					q.objectives = [_criar_obj_stealth(&"fronteira_goruto")]

				19:
					q.quest_name = "Formigas Chimera 19/48: A Seleção Humana de Peijin"
					q.description = "ORDEM: Derrote 4 guardas de Peijin (GPS). Espaço de combate. Depois Killua (agulha)."
					q.reward_xp = 160000
					q.reward_gold = 2800000
					q.objectives = [_criar_obj_kill(&"guarda_peijin", 4)]

				20:
					q.quest_name = "Formigas Chimera 20/48: A Remoção da Agulha de Illumi"
					q.description = "ORDEM: Fale com Killua — remova a agulha. Depois Godspeed."
					q.reward_xp = 165000
					q.reward_gold = 2900000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				21:
					q.quest_name = "Formigas Chimera 21/48: O Desenvolvimento do Godspeed (Kanmuru)"
					q.description = "ORDEM: Fale com Killua (Godspeed). Depois [G] Portas do Knov."
					q.reward_xp = 170000
					q.reward_gold = 3000000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				22:
					q.quest_name = "Formigas Chimera 22/48: O Hide and Seek (4ª Dimensão) de Knov"
					q.description = "ORDEM: [G] Inspecione as Portas Dimensionais de Knov. Depois Meruem / Gungi."
					q.reward_xp = 175000
					q.reward_gold = 3100000
					q.objectives = [_criar_obj_investigate(&"portas_knov")]

				23:
					q.quest_name = "Formigas Chimera 23/48: A Partida de Gungi de Komugi"
					q.description = "ORDEM: Fale com Meruem (Gungi). Não ataque fora da etapa. Depois reunião (Gon)."
					q.reward_xp = 180000
					q.reward_gold = 3200000
					q.objectives = [_criar_obj_visit(&"meruem", "Rei Meruem")]

				24:
					q.quest_name = "Formigas Chimera 24/48: A Contagem Regressiva da Invasão"
					q.description = "ORDEM: Fale com Gon e feche a equipe. Hora Zero depois — GPS."
					q.reward_xp = 185000
					q.reward_gold = 3300000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				25:
					q.quest_name = "Formigas Chimera 25/48: A Hora Zero (00:00:00)"
					q.description = "ORDEM: Fale com Morel na Hora Zero. Depois [G] Chuva de Dragões."
					q.reward_xp = 190000
					q.reward_gold = 3400000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

				26:
					q.quest_name = "Formigas Chimera 26/48: A Chuva de Dragões (Dragon Dive)"
					q.description = "ORDEM: [G] Inspecione as Marcas da Chuva de Dragões. Depois Youpi / escadas (GPS)."
					q.reward_xp = 195000
					q.reward_gold = 3500000
					q.objectives = [_criar_obj_investigate(&"chuva_dragoes_zeno")]

				27:
					q.quest_name = "Formigas Chimera 27/48: O Encontro nas Escadarias Centrais"
					q.description = "ORDEM: Fale com Shoot na escadaria. Youpi à frente — GPS um passo. Sem rush."
					q.reward_xp = 200000
					q.reward_gold = 3600000
					q.objectives = [_criar_obj_visit(&"shoot", "Shoot")]

				28:
					q.quest_name = "Formigas Chimera 28/48: A Fumaça Deep Purple de Morel"
					q.description = "ORDEM: Fale com Morel — Deep Purple isola Pouf. Depois Knuckle (Youpi)."
					q.reward_xp = 205000
					q.reward_gold = 3700000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

				29:
					q.quest_name = "Formigas Chimera 29/48: O Ataque Frenético de Shoot e Knuckle"
					q.description = "ORDEM: Fale com Knuckle — A.P.R. no Youpi. Depois fúria / Killua (GPS)."
					q.reward_xp = 210000
					q.reward_gold = 3800000
					q.objectives = [_criar_obj_visit(&"knuckle", "Knuckle")]

				30:
					q.quest_name = "Formigas Chimera 30/48: A Fúria Vulcânica de Youpi"
					q.description = "ORDEM: Fale com Knuckle — aguente a fúria. Depois Killua (Godspeed)."
					q.reward_xp = 215000
					q.reward_gold = 3900000
					q.objectives = [_criar_obj_visit(&"knuckle", "Knuckle")]

				31:
					q.quest_name = "Formigas Chimera 31/48: A Intervenção do Relâmpago de Killua"
					q.description = "ORDEM: Fale com Killua (Kanmuru). Depois derrote Youpi (GPS)."
					q.reward_xp = 220000
					q.reward_gold = 4000000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				32:
					q.quest_name = "Formigas Chimera 32/48: A Derrota de Menthuthuyoupi"
					q.description = "ORDEM: Derrote Youpi (GPS na escadaria). Espaço de combate. Depois Pouf."
					q.reward_xp = 230000
					q.reward_gold = 4200000
					q.objectives = [_criar_obj_kill(&"youpi", 1)]

				33:
					q.quest_name = "Formigas Chimera 33/48: O Casulo Espiritual de Shaiapouf"
					q.description = "ORDEM: Derrote Shaiapouf (GPS). Proteja Komugi. Depois Gon / Blythe."
					q.reward_xp = 235000
					q.reward_gold = 4400000
					q.objectives = [_criar_obj_kill(&"shaiapouf", 1)]

				34:
					q.quest_name = "Formigas Chimera 34/48: A Sala de Operação do Dr. Blythe"
					q.description = "ORDEM: Fale com Gon — Pitou opera Komugi. Espere. Sem atacar ainda."
					q.reward_xp = 240000
					q.reward_gold = 4600000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				35:
					q.quest_name = "Formigas Chimera 35/48: A Espera Sombria de Gon"
					q.description = "ORDEM: Fale com Gon — aguarde a cirurgia. Depois Netero / tumba (GPS)."
					q.reward_xp = 245000
					q.reward_gold = 4800000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				36:
					q.quest_name = "Formigas Chimera 36/48: O Voo de Netero e Meruem até a Tumba"
					q.description = "ORDEM: Fale com Netero — tumba nuclear. Depois [G] Guanyin."
					q.reward_xp = 250000
					q.reward_gold = 5000000
					q.objectives = [_criar_obj_visit(&"netero", "Presidente Isaac Netero")]

				37:
					q.quest_name = "Formigas Chimera 37/48: O Guanyin Bodhisattva de 100 Tipos"
					q.description = "ORDEM: [G] Inspecione o Guanyin Bodhisattva. Depois fale com Netero (Mão Zero)."
					q.reward_xp = 260000
					q.reward_gold = 5200000
					q.objectives = [_criar_obj_investigate(&"buda_guanyin_netero")]

				38:
					q.quest_name = "Formigas Chimera 38/48: A Mão Zero de Netero"
					q.description = "ORDEM: Fale com Netero — Mão Zero. Depois [G] Rosa Pobre."
					q.reward_xp = 270000
					q.reward_gold = 5500000
					q.objectives = [_criar_obj_visit(&"netero", "Presidente Isaac Netero")]

				39:
					q.quest_name = "Formigas Chimera 39/48: A Rosa Pobre (Poor Man's Rose)"
					q.description = "ORDEM: [G] Inspecione a Rosa Pobre. Depois Gon / marcha até Pitou (GPS)."
					q.reward_xp = 280000
					q.reward_gold = 5800000
					q.objectives = [_criar_obj_investigate(&"explosao_rosa_pobre")]

				40:
					q.quest_name = "Formigas Chimera 40/48: A Marcha Fúnebre até Peijin"
					q.description = "ORDEM: Fale com Gon — marcha com Pitou. Depois a verdade sobre Kite."
					q.reward_xp = 285000
					q.reward_gold = 6000000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				41:
					q.quest_name = "Formigas Chimera 41/48: A Verdade Irreparável sobre Kite"
					q.description = "ORDEM: Fale com Gon — Kite se foi. Depois juramento (Gon Adulto)."
					q.reward_xp = 290000
					q.reward_gold = 6200000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				42:
					q.quest_name = "Formigas Chimera 42/48: O Juramento Supremo de Gon (Gon Adulto)"
					q.description = "ORDEM: Fale com Gon — juramento. Depois derrote Neferpitou (GPS)."
					q.reward_xp = 310000
					q.reward_gold = 6500000
					q.objectives = [_criar_obj_visit(&"gon", "Gon")]

				43:
					q.quest_name = "Formigas Chimera 43/48: O Jajanken da Aniquilação de Pitou"
					q.description = "ORDEM: Derrote Neferpitou (GPS). Espaço de combate. Depois Killua."
					q.reward_xp = 330000
					q.reward_gold = 7000000
					q.objectives = [_criar_obj_kill(&"neferpitou", 1)]

				44:
					q.quest_name = "Formigas Chimera 44/48: A Chegada em Lágrimas de Killua"
					q.description = "ORDEM: Fale com Killua no campo. Depois Meruem (En fotônico)."
					q.reward_xp = 340000
					q.reward_gold = 7200000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				45:
					q.quest_name = "Formigas Chimera 45/48: O En Fotônico do Rei Ressuscitado"
					q.description = "ORDEM: Fale com Meruem — En fotônico / memória. Depois Morel (sobreviventes)."
					q.reward_xp = 350000
					q.reward_gold = 7500000
					q.objectives = [_criar_obj_visit(&"meruem", "Rei Meruem")]

				46:
					q.quest_name = "Formigas Chimera 46/48: A Redenção dos Sobreviventes"
					q.description = "ORDEM: Fale com Morel — sobreviventes. Depois última partida de Gungi."
					q.reward_xp = 360000
					q.reward_gold = 7800000
					q.objectives = [_criar_obj_visit(&"morel", "Morel")]

				47:
					q.quest_name = "Formigas Chimera 47/48: A Última Partida de Gungi no Escuro"
					q.description = "ORDEM: Fale com Meruem — última partida. Depois evacuação (Morel)."
					q.reward_xp = 380000
					q.reward_gold = 8000000
					q.objectives = [_criar_obj_visit(&"meruem", "Rei Meruem")]

				48:
					q.quest_name = "Formigas Chimera 48/48: A Evacuação Geral & O Coma de Gon"
					q.description = "ORDEM: Fale com Morel — evacue. Portal Associação abre. Sem rush no coma de Gon."
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
					q.description = "ORDEM: Fale com Cheadle no auditório (testamento). Depois regras / Pariston. Sem rush."
					q.reward_xp = 120000
					q.reward_gold = 2000000
					q.objectives = [_criar_obj_visit(&"cheadle", "Cheadle Yorkshire (Zodíaco Cão)")]

				2:
					q.quest_name = "Eleição Hunter 2/20: O Testamento dos 12 Zodíacos"
					q.description = "ORDEM: Fale com Cheadle de novo (quórum 95%). Depois Pariston (jogo político)."
					q.reward_xp = 130000
					q.reward_gold = 2100000
					q.objectives = [_criar_obj_visit(&"cheadle", "Cheadle Yorkshire")]

				3:
					q.quest_name = "Eleição Hunter 3/20: O Jogo Político de Pariston Hill"
					q.description = "ORDEM: Fale com Pariston. Depois Hospital — Leorio / Gon UTI (GPS)."
					q.reward_xp = 140000
					q.reward_gold = 2300000
					q.objectives = [_criar_obj_visit(&"pariston", "Pariston Hill (Vice-Presidente)")]

				4:
					q.quest_name = "Eleição Hunter 4/20: O Quarto de UTI no Hospital Hunter"
					q.description = "ORDEM: Fale com Leorio na UTI. Depois Killua (resgate Alluka)."
					q.reward_xp = 150000
					q.reward_gold = 2500000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio Paradinight")]

				5:
					q.quest_name = "Eleição Hunter 5/20: A Decisão Proibida de Killua"
					q.description = "ORDEM: Fale com Killua — ele vai buscar Alluka. Depois [G] Cela."
					q.reward_xp = 160000
					q.reward_gold = 2700000
					q.objectives = [_criar_obj_visit(&"killua", "Killua Zoldyck")]

				6:
					q.quest_name = "Eleição Hunter 6/20: A Masmorra Subterrânea de Alluka"
					q.description = "ORDEM: [G] Inspecione a Cela / Cofre de Alluka. Depois fale com Alluka (regras)."
					q.reward_xp = 170000
					q.reward_gold = 2900000
					q.objectives = [_criar_obj_investigate(&"cela_alluka")]

				7:
					q.quest_name = "Eleição Hunter 7/20: As Regras dos Desejos de Nanika"
					q.description = "ORDEM: Fale com Alluka & Nanika (3 recusas). Depois Killua assume custódia."
					q.reward_xp = 180000
					q.reward_gold = 3100000
					q.objectives = [_criar_obj_visit(&"alluka", "Alluka & Nanika")]

				8:
					q.quest_name = "Eleição Hunter 8/20: O Resgate nos Braços de Killua"
					q.description = "ORDEM: Fale com Killua — partida ao hospital. Depois emboscada (GPS)."
					q.reward_xp = 190000
					q.reward_gold = 3300000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				9:
					q.quest_name = "Eleição Hunter 9/20: A Emboscada de Illumi e Hisoka"
					q.description = "ORDEM: Fale com Killua na rodovia. Depois mordomos perseguidores (GPS)."
					q.reward_xp = 200000
					q.reward_gold = 3500000
					q.objectives = [_criar_obj_visit(&"killua", "Killua")]

				10:
					q.quest_name = "Eleição Hunter 10/20: Mordomos Perseguidores na Rodovia"
					q.description = "ORDEM: Derrote 4 mordomos perseguidores (GPS). Espaço de combate. Depois Homens-Agulha."
					q.reward_xp = 210000
					q.reward_gold = 3700000
					q.objectives = [_criar_obj_kill(&"mordomo_perseguidor", 4)]

				11:
					q.quest_name = "Eleição Hunter 11/20: O Exército de Homens-Agulha"
					q.description = "ORDEM: Derrote 8 Homens-Agulha (GPS na rodovia). Depois Illumi Boss."
					q.reward_xp = 225000
					q.reward_gold = 4000000
					q.objectives = [_criar_obj_kill(&"humano_agulha", 8)]

				12:
					q.quest_name = "Eleição Hunter 12/20: O Confronto contra Illumi"
					q.description = "ORDEM: Derrote Illumi (GPS). Espaço de combate. Depois volte ao auditório (Cheadle)."
					q.reward_xp = 240000
					q.reward_gold = 4300000
					q.objectives = [_criar_obj_kill(&"illumi", 1)]

				13:
					q.quest_name = "Eleição Hunter 13/20: A 4ª Rodada da Votação Eleitoral"
					q.description = "ORDEM: Fale com Cheadle no plenário. Depois Leorio (soco teleportado)."
					q.reward_xp = 250000
					q.reward_gold = 4500000
					q.objectives = [_criar_obj_visit(&"cheadle", "Cheadle")]

				14:
					q.quest_name = "Eleição Hunter 14/20: O Soco Teleportado de Leorio"
					q.description = "ORDEM: Fale com Leorio — discurso / soco. Depois Cheadle (liderança)."
					q.reward_xp = 260000
					q.reward_gold = 4800000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio Paradinight")]

				15:
					q.quest_name = "Eleição Hunter 15/20: Leorio Lidera a Eleição"
					q.description = "ORDEM: Fale com Cheadle — Leorio em 1º. Depois Alluka / milagre no hospital."
					q.reward_xp = 270000
					q.reward_gold = 5000000
					q.objectives = [_criar_obj_visit(&"cheadle", "Cheadle")]

				16:
					q.quest_name = "Eleição Hunter 16/20: O Milagre de Nanika no Hospital"
					q.description = "ORDEM: Fale com Alluka & Nanika — cure Gon. Depois Gon recuperado na tribuna."
					q.reward_xp = 290000
					q.reward_gold = 5500000
					q.objectives = [_criar_obj_visit(&"alluka", "Alluka & Nanika")]

				17:
					q.quest_name = "Eleição Hunter 17/20: A Entrada Triunfal de Gon Curado"
					q.description = "ORDEM: Fale com Gon Freecss Recuperado na tribuna. Depois Leorio (abraço)."
					q.reward_xp = 310000
					q.reward_gold = 6000000
					q.objectives = [_criar_obj_visit(&"gon_recuperado", "Gon Freecss Recuperado")]

				18:
					q.quest_name = "Eleição Hunter 18/20: O Abraço em Lágrimas de Leorio e Gon"
					q.description = "ORDEM: Fale com Leorio no palco. Depois Cheadle (13ª Presidente)."
					q.reward_xp = 330000
					q.reward_gold = 6500000
					q.objectives = [_criar_obj_visit(&"leorio", "Leorio")]

				19:
					q.quest_name = "Eleição Hunter 19/20: A Eleição da 13ª Presidente Cheadle"
					q.description = "ORDEM: Fale com Cheadle — 13ª Presidente. Depois despedida Killua/Alluka."
					q.reward_xp = 350000
					q.reward_gold = 7000000
					q.objectives = [_criar_obj_visit(&"cheadle", "Presidente Cheadle")]

				20:
					q.quest_name = "Eleição Hunter 20/20: A Despedida de Killua e Alluka"
					q.description = "ORDEM: Fale com Killua — despedida. Portal Continente Negro só após esta etapa."
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
					q.description = "ORDEM: Fale com Beyond no acampamento (manifesto). Depois Cheadle. Sem rush."
					q.reward_xp = 240000
					q.reward_gold = 4000000
					q.objectives = [_criar_obj_visit(&"beyond", "Beyond Netero")]

				2:
					q.quest_name = "Continente Negro 2/22: Os Novos Zodíacos: Kurapika e Leorio"
					q.description = "ORDEM: Fale com Cheadle (Zodíacos). Depois Ging no acampamento."
					q.reward_xp = 250000
					q.reward_gold = 4300000
					q.objectives = [_criar_obj_visit(&"cheadle", "Presidente Cheadle")]

				3:
					q.quest_name = "Continente Negro 3/22: O Acampamento de Recrutamento de Ging"
					q.description = "ORDEM: Fale com Ging — junte-se à expedição. Depois teste Nen."
					q.reward_xp = 265000
					q.reward_gold = 4600000
					q.objectives = [_criar_obj_visit(&"ging", "Ging Freecss")]

				4:
					q.quest_name = "Continente Negro 4/22: O Teste de Nen dos Mercenários"
					q.description = "ORDEM: Convença / teste Nen com Ging. Depois [G] Lago Mobius."
					q.reward_xp = 280000
					q.reward_gold = 4900000
					q.objectives = [_criar_obj_persuasion(&"ging", "Ging Freecss")]

				5:
					q.quest_name = "Continente Negro 5/22: O Mapa Secreto do Lago Mobius"
					q.description = "ORDEM: [G] Inspecione o Mapa do Lago Mobius. Depois [Z] Águas Proibidas."
					q.reward_xp = 295000
					q.reward_gold = 5200000
					q.objectives = [_criar_obj_investigate(&"mapa_lago_mobius")]

				6:
					q.quest_name = "Continente Negro 6/22: A Travessia das Águas Proibidas"
					q.description = "ORDEM: [Z] Atravesse as Águas Proibidas em Zetsu. Sem Zetsu = feras. Depois Beyond."
					q.reward_xp = 310000
					q.reward_gold = 5500000
					q.objectives = [_criar_obj_stealth(&"aguas_proibidas")]

				7:
					q.quest_name = "Continente Negro 7/22: O Desembarque na Costa Selvagem"
					q.description = "ORDEM: Fale com Beyond no desembarque. Depois [G] Ruínas Botânicas."
					q.reward_xp = 325000
					q.reward_gold = 5800000
					q.objectives = [_criar_obj_visit(&"beyond", "Beyond Netero")]

				8:
					q.quest_name = "Continente Negro 8/22: As Ruínas Botânicas Ancestrais"
					q.description = "ORDEM: [G] Inspecione as Ruínas Botânicas. Depois guardiões de Brion (GPS)."
					q.reward_xp = 340000
					q.reward_gold = 6100000
					q.objectives = [_criar_obj_investigate(&"ruinas_botanicas")]

				9:
					q.quest_name = "Continente Negro 9/22: Os Guardiões Botânicos de Brion"
					q.description = "ORDEM: Derrote 5 guardiões de Brion (GPS). Espaço de combate. Depois Brion Boss."
					q.reward_xp = 360000
					q.reward_gold = 6500000
					q.objectives = [_criar_obj_kill(&"guardiao_brion", 5)]

				10:
					q.quest_name = "Continente Negro 10/22: A Calamidade Brion (A Arma Botânica)"
					q.description = "ORDEM: Derrote Brion Boss (GPS). Depois [Z] Caverna Hellbell."
					q.reward_xp = 380000
					q.reward_gold = 7000000
					q.objectives = [_criar_obj_kill(&"brion_boss", 1)]

				11:
					q.quest_name = "Continente Negro 11/22: O Veneno Sonoro da Serpente Hellbell"
					q.description = "ORDEM: [Z] Atravesse a Caverna Hellbell em Zetsu. Depois Hellbell Boss."
					q.reward_xp = 400000
					q.reward_gold = 7500000
					q.objectives = [_criar_obj_stealth(&"caverna_hellbell")]

				12:
					q.quest_name = "Continente Negro 12/22: A Batalha contra a Serpente Hellbell"
					q.description = "ORDEM: Derrote Hellbell Boss (GPS). Espaço de combate. Depois Entidade Ai."
					q.reward_xp = 425000
					q.reward_gold = 8000000
					q.objectives = [_criar_obj_kill(&"hellbell_boss", 1)]

				13:
					q.quest_name = "Continente Negro 13/22: A Forma Gasosa da Entidade Ai"
					q.description = "ORDEM: Derrote a Entidade Ai (GPS). Depois Nitro Rice / Árvore."
					q.reward_xp = 450000
					q.reward_gold = 8500000
					q.objectives = [_criar_obj_kill(&"ai_boss", 1)]

				14:
					q.quest_name = "Continente Negro 14/22: A Coleta do Arroz Nitro"
					q.description = "ORDEM: Colete Nitro Rice (GPS). Depois fale com a Árvore do Mundo."
					q.reward_xp = 470000
					q.reward_gold = 9000000
					q.objectives = [_criar_obj_collect(&"nitro_rice", 1)]

				15:
					q.quest_name = "Continente Negro 15/22: As Raízes Continentais da Árvore do Mundo"
					q.description = "ORDEM: Fale com a Árvore do Mundo (base). Depois feras aladas (GPS)."
					q.reward_xp = 490000
					q.reward_gold = 9500000
					q.objectives = [_criar_obj_visit(&"arvore_mundo", "Árvore do Mundo")]

				16:
					q.quest_name = "Continente Negro 16/22: As Feras Aladas da Copa Intermediária"
					q.description = "ORDEM: Derrote 4 feras aladas (GPS). Depois escale até o topo."
					q.reward_xp = 510000
					q.reward_gold = 10000000
					q.objectives = [_criar_obj_kill(&"guardiao_brion", 4)]

				17:
					q.quest_name = "Continente Negro 17/22: A Escalada dos 1.784 Metros"
					q.description = "ORDEM: Fale com a Árvore de novo (escalada). Depois Ging no topo."
					q.reward_xp = 530000
					q.reward_gold = 10500000
					q.objectives = [_criar_obj_visit(&"arvore_mundo", "Árvore do Mundo")]

				18:
					q.quest_name = "Continente Negro 18/22: O Ninho Gigante da Copa"
					q.description = "ORDEM: Fale com Ging Freecss no Topo. Depois reencontro / filosofia."
					q.reward_xp = 550000
					q.reward_gold = 11000000
					q.objectives = [_criar_obj_visit(&"ging_topo", "Ging Freecss no Topo")]

				19:
					q.quest_name = "Continente Negro 19/22: O Reencontro no Topo do Mundo"
					q.description = "ORDEM: Fale com Ging no Topo de novo. Depois filosofia do Caçador."
					q.reward_xp = 575000
					q.reward_gold = 11500000
					q.objectives = [_criar_obj_visit(&"ging_topo", "Ging Freecss no Topo")]

				20:
					q.quest_name = "Continente Negro 20/22: A Filosofia do Verdadeiro Caçador"
					q.description = "ORDEM: Convença / ouça Ging no Topo. Depois [G] Horizonte Sem Fim."
					q.reward_xp = 600000
					q.reward_gold = 12000000
					q.objectives = [_criar_obj_persuasion(&"ging_topo", "Ging Freecss no Topo")]

				21:
					q.quest_name = "Continente Negro 21/22: O Horizonte Sem Fim"
					q.description = "ORDEM: [G] Inspecione o Horizonte Sem Fim. Depois convite Kakin (Ging)."
					q.reward_xp = 625000
					q.reward_gold = 12500000
					q.objectives = [_criar_obj_investigate(&"horizonte_infinito")]

				22:
					q.quest_name = "Continente Negro 22/22: O Convite Real de Kakin"
					q.description = "ORDEM: Fale com Ging no Topo — convite Black Whale. Portal só após esta etapa."
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
					q.description = "ORDEM: Fale com Kurapika no Convés 1. Black Whale é longo — um objetivo de cada vez. Depois: Rainha Oito."
					q.reward_xp = 350000
					q.reward_gold = 7000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				2:
					q.quest_name = "Guerra de Sucessão 2/26: Os Aposentos 1014 da Rainha Oito"
					q.description = "ORDEM: Fale com a Rainha Oito & Woble. Estabeleça o perímetro. Depois: Vaso Sagrado."
					q.reward_xp = 370000
					q.reward_gold = 7500000
					q.objectives = [_criar_obj_visit(&"rainha_oito", "Rainha Oito & Príncipe Woble")]

				3:
					q.quest_name = "Guerra de Sucessão 3/26: O Ritual do Vaso Sagrado de Kakin"
					q.description = "ORDEM: Examine o Vaso Sagrado. Depois [G] primeiro assassinato no corredor."
					q.reward_xp = 390000
					q.reward_gold = 8000000
					q.objectives = [_criar_obj_visit(&"vaso_kakin", "Vaso Sagrado de Kakin")]

				4:
					q.quest_name = "Guerra de Sucessão 4/26: O Primeiro Assassinato a Bordo"
					q.description = "ORDEM: Ative [G] Gyo e inspecione o Primeiro Assassinato a Bordo. Sem Gyo, não vê a aura."
					q.reward_xp = 410000
					q.reward_gold = 8500000
					q.objectives = [_criar_obj_investigate(&"primeiro_assassinato_kakin")]

				5:
					q.quest_name = "Guerra de Sucessão 5/26: O Stealth Dolphin de Kurapika"
					q.description = "ORDEM: Fale com Kurapika (Stealth Dolphin / Emperor Time). Depois GPS: bestas parasitárias."
					q.reward_xp = 430000
					q.reward_gold = 9000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				6:
					q.quest_name = "Guerra de Sucessão 6/26: As Bestas Parasitas Rebeldes"
					q.description = "ORDEM: Derrote 3 Bestas Parasitas (GPS no Convés 1). Espaço de combate. Depois aula de Nen."
					q.reward_xp = 450000
					q.reward_gold = 9500000
					q.objectives = [_criar_obj_kill(&"besta_parasita", 3)]

				7:
					q.quest_name = "Guerra de Sucessão 7/26: A Aula de Nen nos Aposentos Reais"
					q.description = "ORDEM: Fale com Kurapika (treino Ten dos guardas). Depois desça à Máfia (Hinrigh)."
					q.reward_xp = 475000
					q.reward_gold = 10000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				8:
					q.quest_name = "Guerra de Sucessão 8/26: Os Conveses Intermediários da Máfia"
					q.description = "ORDEM: Caminhe aos conveses 3–4 e fale com Hinrigh (Xi-Yu). Sem rush."
					q.reward_xp = 500000
					q.reward_gold = 10500000
					q.objectives = [_criar_obj_visit(&"hinrigh", "Hinrigh (Família Xi-Yu)")]

				9:
					q.quest_name = "Guerra de Sucessão 9/26: A Aliança com Hinrigh Biganduffno"
					q.description = "ORDEM: Fale com Hinrigh (Biohazard). Depois [G] seita Heil-Ly."
					q.reward_xp = 525000
					q.reward_gold = 11000000
					q.objectives = [_criar_obj_visit(&"hinrigh", "Hinrigh")]

				10:
					q.quest_name = "Guerra de Sucessão 10/26: O Contágio de Morena Prudo"
					q.description = "ORDEM: Ative [G] Gyo e inspecione o Contágio da Seita Heil-Ly. Depois GPS: 6 assassinos."
					q.reward_xp = 550000
					q.reward_gold = 11500000
					q.objectives = [_criar_obj_investigate(&"seita_heilly")]

				11:
					q.quest_name = "Guerra de Sucessão 11/26: O Massacre da Família Heil-Ly"
					q.description = "ORDEM: Derrote 6 assassinos Heil-Ly (GPS). Um de cada vez. Depois Trupe / Chrollo."
					q.reward_xp = 580000
					q.reward_gold = 12000000
					q.objectives = [_criar_obj_kill(&"assassino_heilly", 6)]

				12:
					q.quest_name = "Guerra de Sucessão 12/26: A Caçada da Trupe Fantasma no Navio"
					q.description = "ORDEM: Fale com Chrollo nos conveses profundos. Depois Hisoka (marcas de goma)."
					q.reward_xp = 600000
					q.reward_gold = 12500000
					q.objectives = [_criar_obj_visit(&"chrollo", "Chrollo Lucilfer")]

				13:
					q.quest_name = "Guerra de Sucessão 13/26: As Pistas de Sangue de Hisoka"
					q.description = "ORDEM: Fale com Hisoka (Bungee Gum). Depois volte a Chrollo para negociar trégua."
					q.reward_xp = 625000
					q.reward_gold = 13000000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka Morow")]

				14:
					q.quest_name = "Guerra de Sucessão 14/26: A Trégua Provisória com a Trupe"
					q.description = "ORDEM: Negocie trégua com Chrollo (persuadir). Depois [Z] aposentos Tserriednich."
					q.reward_xp = 650000
					q.reward_gold = 13500000
					q.objectives = [_criar_obj_persuasion(&"chrollo", "Chrollo Lucilfer")]

				15:
					q.quest_name = "Guerra de Sucessão 15/26: Os Aposentos do 4º Príncipe Tserriednich"
					q.description = "ORDEM: [Z] Atravesse os Aposentos de Tserriednich em Zetsu. Sem Zetsu = sentinelas."
					q.reward_xp = 680000
					q.reward_gold = 14000000
					q.objectives = [_criar_obj_stealth(&"aposentos_tserriednich")]

				16:
					q.quest_name = "Guerra de Sucessão 16/26: O Despertar da Besta de Dupla Face"
					q.description = "ORDEM: Ative [G] Gyo e sinta a Aura da Besta de Dupla Face. Depois Kurapika (futuro paralelo)."
					q.reward_xp = 710000
					q.reward_gold = 14500000
					q.objectives = [_criar_obj_investigate(&"besta_tserriednich")]

				17:
					q.quest_name = "Guerra de Sucessão 17/26: O Zetsu do Futuro Paralelo"
					q.description = "ORDEM: Fale com Kurapika — Hatsu temporal de Tserriednich. Depois GPS: Besta Facial."
					q.reward_xp = 740000
					q.reward_gold = 15000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				18:
					q.quest_name = "Guerra de Sucessão 18/26: O Combate contra a Besta Facial"
					q.description = "ORDEM: Derrote a Besta Guardiã de Tserriednich (GPS). Espaço de combate. Depois o Príncipe."
					q.reward_xp = 770000
					q.reward_gold = 16000000
					q.objectives = [_criar_obj_kill(&"besta_tserriednich", 1)]

				19:
					q.quest_name = "Guerra de Sucessão 19/26: O Confronto com o Príncipe Tserriednich"
					q.description = "ORDEM: Derrote Tserriednich Boss (GPS). Ren coordenado. Depois revolta no Convés 3."
					q.reward_xp = 820000
					q.reward_gold = 17000000
					q.objectives = [_criar_obj_kill(&"tserriednich_boss", 1)]

				20:
					q.quest_name = "Guerra de Sucessão 20/26: A Revolta dos Soldados do Convés 3"
					q.description = "ORDEM: Derrote 4 guardas rebeldes (GPS Convés 3). Sem rush. Depois profundos."
					q.reward_xp = 850000
					q.reward_gold = 18000000
					q.objectives = [_criar_obj_kill(&"assassino_heilly", 4)]

				21:
					q.quest_name = "Guerra de Sucessão 21/26: A Batalha dos Conveses Profundos"
					q.description = "ORDEM: Derrote 2 parasitas nos armazéns (GPS). Depois testemunhe Hisoka vs Chrollo."
					q.reward_xp = 880000
					q.reward_gold = 19000000
					q.objectives = [_criar_obj_kill(&"besta_parasita", 2)]

				22:
					q.quest_name = "Guerra de Sucessão 22/26: O Duelo de Titãs nos Conveses"
					q.description = "ORDEM: Fale com Hisoka no duelo dos profundos. Depois proteja Woble (Rainha Oito)."
					q.reward_xp = 910000
					q.reward_gold = 20000000
					q.objectives = [_criar_obj_visit(&"hisoka", "Hisoka")]

				23:
					q.quest_name = "Guerra de Sucessão 23/26: A Proteção do Príncipe Woble"
					q.description = "ORDEM: Fale com a Rainha Oito — garanta Woble. Depois Boss da conspiração (GPS)."
					q.reward_xp = 940000
					q.reward_gold = 21000000
					q.objectives = [_criar_obj_visit(&"rainha_oito", "Rainha Oito")]

				24:
					q.quest_name = "Guerra de Sucessão 24/26: O Comandante da Conspiração de Kakin"
					q.description = "ORDEM: Derrote o Boss Final da Conspiração (GPS comando). Depois Kurapika (estabilização)."
					q.reward_xp = 1000000
					q.reward_gold = 25000000
					q.objectives = [_criar_obj_kill(&"boss_final_kakin", 1)]

				25:
					q.quest_name = "Guerra de Sucessão 25/26: A Estabilização do Black Whale 1"
					q.description = "ORDEM: Fale com Kurapika — restaure a ordem a bordo. Depois Cheadle (consagração)."
					q.reward_xp = 1050000
					q.reward_gold = 27000000
					q.objectives = [_criar_obj_visit(&"kurapika", "Kurapika")]

				26:
					q.quest_name = "Guerra de Sucessão 26/26: A Consagração do Maior Caçador da História"
					q.description = "ORDEM: Fale com Presidente Cheadle — consagração. Portal Lobby após esta etapa. História 100%."
					q.reward_xp = 1200000
					q.reward_gold = 30000000
					q.objectives = [_criar_obj_visit(&"cheadle", "Presidente Cheadle")]

	_quest_cache[chave] = q
	# Escala narrativa alinhada aos soft-max por saga (ProgressionConfig).
	# Valores brutos históricos eram de outra curva; o fator evita saltos de dezenas de níveis.
	q.reward_xp = escalar_xp_narrativo(arco, q.reward_xp)
	q.reward_gold = escalar_jenny_narrativo(arco, q.reward_gold)
	return q


## Reduz XP canônico para acompanhar soft-caps: Exam~25, Arena~60, Yorknew~85, GI~130, Formigas~230, fim~350.
static func escalar_xp_narrativo(arco: int, xp_bruto: int) -> int:
	var fator: float = 1.0
	match arco:
		1: fator = 0.70   # Exam — leve freio
		2: fator = 0.45   # Kukuroo
		3: fator = 0.28   # Arena Celestial
		4: fator = 0.16   # Yorknew
		5: fator = 0.09   # Greed Island
		6: fator = 0.055  # Formigas Chimera
		7: fator = 0.045  # Eleição
		8: fator = 0.035  # Continente Negro
		9: fator = 0.028  # Sucessão Kakin
		_: fator = 0.05
	return maxi(50, int(round(float(xp_bruto) * fator)))


## Freia Jenny canônico early/mid para alinhar com loja (30–500) e sink de Hatsu (5k).
static func escalar_jenny_narrativo(arco: int, jenny_bruto: int) -> int:
	var fator: float = 1.0
	match arco:
		1: fator = 0.40   # Exam — freio forte (loot + baús ainda somam)
		2: fator = 0.32   # Kukuroo
		3: fator = 0.22   # Arena Celestial
		4: fator = 0.15   # Yorknew
		5: fator = 0.10   # Greed Island
		6: fator = 0.07   # Formigas Chimera
		7: fator = 0.055  # Eleição
		8: fator = 0.04   # Continente Negro
		9: fator = 0.032  # Sucessão Kakin
		_: fator = 0.05
	return maxi(40, int(round(float(jenny_bruto) * fator)))


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
