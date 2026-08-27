class_name CanonQuestCatalog
extends Resource

# ============================================================
# HUNTER ONLINE - CANON QUEST CATALOG (MODO HISTÓRIA COMPLETO)
# ============================================================
#
# Campanha oficial dos 9 Arcos Canônicos de Hunter x Hunter.
# Cada missão possui múltiplos objetivos sequenciais de RPG:
# 1. Falar com personagens canônicos e receber o contexto narrativo.
# 2. Explorar marcos e áreas históricas.
# 3. Lutar e derrotar inimigos e chefes específicos da saga.
# 4. Reportar o progresso e desbloquear o próximo capítulo da lenda Hunter!
#
# ============================================================

static func obter_total_quests_do_arco(arco: int) -> int:
	match arco:
		1: return 6 # Exame Hunter
		2: return 4 # Montanha Kukuroo
		3: return 5 # Arena Celestial
		4: return 5 # Yorknew City
		5: return 5 # Greed Island
		6: return 5 # Formigas Chimera
		7: return 4 # Eleição Hunter
		8: return 4 # Continente Negro
		9: return 5 # Guerra de Sucessão Kakin
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
		# ARCO 1: EXAME HUNTER (6 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		1:
			match etapa:
				1:
					q.quest_name = "Exame Hunter 1/6: A Maratona Subterrânea de Zaban"
					q.description = "Apresente-se no túnel subterrâneo de Zaban para os primeiros 80km de maratona. Fale com Tonpa, observe o novato Nicol e converse com o ninja Hanzo e o veterano Bodoro."
					q.reward_xp = 350
					q.reward_gold = 800
					var o1 := _criar_obj_visit(&"tonpa", "Tonpa o Quebrador de Novatos")
					var o2 := _criar_obj_visit(&"nicol", "Nicol (Nº 187)")
					var o3 := _criar_obj_visit(&"hanzo", "Hanzo (Nº 294)")
					var o4 := _criar_obj_visit(&"bodoro", "Bodoro (Nº 191)")
					q.objectives = [o1, o2, o3, o4]

				2:
					q.quest_name = "Exame Hunter 2/6: Os Quatro Companheiros & Os Sabotadores"
					q.description = "Mantenha o ritmo da corrida ao lado de Gon, Killua, Leorio e Kurapika. Cuidado com o misterioso Gittarackur e derrote os candidatos sabotadores de novatos!"
					q.reward_xp = 550
					q.reward_gold = 1500
					var o1 := _criar_obj_visit(&"gon", "Gon Freecss")
					var o2 := _criar_obj_visit(&"killua", "Killua Zoldyck")
					var o3 := _criar_obj_visit(&"gittarackur", "Gittarackur (Nº 301)")
					var o4 := _criar_obj_kill(&"candidato_exame", 2)
					q.objectives = [o1, o2, o3, o4]

				3:
					q.quest_name = "Exame Hunter 3/6: O Nevoeiro do Pantanal Numere"
					q.description = "Alcance a saída do túnel e entre no Ninho dos Trapaceiros. Fale com o Examinador Satotz, com o arqueiro Pokkle, com a especialista Ponzu e extermine as feras carnívoras do pantanal."
					q.reward_xp = 800
					q.reward_gold = 2500
					var o1 := _criar_obj_visit(&"satotz", "Examinador Satotz")
					var o2 := _criar_obj_visit(&"pokkle", "Pokkle (Nº 53)")
					var o3 := _criar_obj_visit(&"ponzu", "Ponzu (Nº 246)")
					var o4 := _criar_obj_kill(&"criatura_pantanal", 3)
					q.objectives = [o1, o2, o3, o4]

				4:
					q.quest_name = "Exame Hunter 4/6: O Julgamento Sinistro de Hisoka"
					q.description = "Testemunhe a sede de sangue de Hisoka no coração da névoa. Elimine os monstros traiçoeiros do nevoeiro e sobreviva ao teste de olhar de Hisoka."
					q.reward_xp = 1100
					q.reward_gold = 4000
					var o1 := _criar_obj_kill(&"criatura_pantanal", 3)
					var o2 := _criar_obj_visit(&"hisoka", "Hisoka Morow")
					q.objectives = [o1, o2]

				5:
					q.quest_name = "Exame Hunter 5/6: Floresta Biska & Provação dos Hunters Gourmet"
					q.description = "Chegue ao acampamento da Floresta Biska e encare a 2ª Fase com Menchi e Buhara. Cace e derrote o temível Great Stamp Pig (Grande Javali Selvagem)!"
					q.reward_xp = 1500
					q.reward_gold = 6000
					var o1 := _criar_obj_visit(&"buhara", "Examinador Buhara")
					var o2 := _criar_obj_visit(&"menchi", "Examinadora Menchi")
					var o3 := _criar_obj_kill(&"great_stamp_pig", 1)
					q.objectives = [o1, o2, o3]

				6:
					q.quest_name = "Exame Hunter 6/6: Conclusão da 1ª Fase & Rumo a Kukuroo"
					q.description = "Apresente-se no Portão Final com o Examinador Satotz para receber a aprovação oficial da 1ª Fase e iniciar a jornada rumo à Montanha Kukuroo!"
					q.reward_xp = 2200
					q.reward_gold = 12000
					var o1 := _criar_obj_visit(&"satotz", "Examinador Satotz")
					q.objectives = [o1]

		# =====================================================
		# ARCO 2: MONTANHA KUKUROO (4 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		2:
			match etapa:
				1:
					q.quest_name = "Montanha Kukuroo 1/4: O Portão da Testagem"
					q.description = "Viaje até a montanha do clã Zoldyck na República de Padokia. Fale com o Guarda Zebro e treine força muscular para abrir o portão de 4 toneladas."
					q.reward_xp = 2500
					q.reward_gold = 35000
					var o1 := _criar_obj_visit(&"zebro", "Guarda Zebro")
					var o2 := _criar_obj_visit(&"portao_testagem", "Portão da Testagem (Testing Gate)")
					q.objectives = [o1, o2]

				2:
					q.quest_name = "Montanha Kukuroo 2/4: O Desafio da Mordoma Canary"
					q.description = "Avance pela alameda das árvores proibidas. Enfrente os cães de guarda Mike e convença a jovem mordoma Canary sobre os laços de amizade de Killua."
					q.reward_xp = 3500
					q.reward_gold = 50000
					var o1 := _criar_obj_kill(&"mike", 2)
					var o2 := _criar_obj_visit(&"canary", "Mordoma Canary")
					q.objectives = [o1, o2]

				3:
					q.quest_name = "Montanha Kukuroo 3/4: O Jogo da Moeda de Gotoh"
					q.description = "Entre na mansão dos mordomos. Fale com o Mordomo-Chefe Gotoh e passe em seu teste de moedas de alta velocidade."
					q.reward_xp = 4500
					q.reward_gold = 70000
					var o1 := _criar_obj_visit(&"gotoh", "Mordomo-Chefe Gotoh")
					var o2 := _criar_obj_kill(&"mordomo_combate", 3)
					q.objectives = [o1, o2]

				4:
					q.quest_name = "Montanha Kukuroo 4/4: O Pacto de Sangue com Silva"
					q.description = "Encontre Silva Zoldyck na sala do trono dos assassinos. Faça o pacto de sangue de nunca trair os amigos, resgate Killua e parta para a Arena Celestial!"
					q.reward_xp = 6000
					q.reward_gold = 100000
					var o1 := _criar_obj_visit(&"silva", "Silva Zoldyck")
					var o2 := _criar_obj_visit(&"killua", "Killua Zoldyck")
					q.objectives = [o1, o2]

		# =====================================================
		# ARCO 3: ARENA CELESTIAL (5 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		3:
			match etapa:
				1:
					q.quest_name = "Arena Celestial 1/5: A Escalada até o 200º Andar"
					q.description = "Inscreva-se na recepção da Arena Celestial e vença os combates dos primeiros 199 andares para alcançar o topo da torre."
					q.reward_xp = 5000
					q.reward_gold = 80000
					var o1 := _criar_obj_visit(&"recepcionista", "Recepcionista da Arena")
					var o2 := _criar_obj_kill(&"lutador_arena", 4)
					q.objectives = [o1, o2]

				2:
					q.quest_name = "Arena Celestial 2/5: A Iniciação de Nen de Wing"
					q.description = "A barreira de intenção assassina impede a passagem no 200º andar! Encontre o Mestre Wing e o jovem Zushi para despertar o Ten e os nós de aura."
					q.reward_xp = 7000
					q.reward_gold = 110000
					var o1 := _criar_obj_visit(&"wing", "Mestre Wing")
					var o2 := _criar_obj_visit(&"zushi", "Zushi (Discípulo Shingen-ryu)")
					q.objectives = [o1, o2]

				3:
					q.quest_name = "Arena Celestial 3/5: O Duelo dos Trapaceiros"
					q.description = "Lute nos ringues de 200 andares contra os veteranos trapaceiros Gido e Riehlvelt usando Gyo para prever suas trajetórias."
					q.reward_xp = 9000
					q.reward_gold = 150000
					var o1 := _criar_obj_kill(&"piao_gido", 3)
					var o2 := _criar_obj_kill(&"riehlvelt", 1)
					q.objectives = [o1, o2]

				4:
					q.quest_name = "Arena Celestial 4/5: O Clone de Nen de Kastro"
					q.description = "Fale com Mestre Wing sobre a ilusão do duplo e derrote Kastro no ringue principal usando a concentração de Gyo nos olhos."
					q.reward_xp = 12000
					q.reward_gold = 200000
					var o1 := _criar_obj_visit(&"wing", "Mestre Wing")
					var o2 := _criar_obj_kill(&"kastro", 1)
					q.objectives = [o1, o2]

				5:
					q.quest_name = "Arena Celestial 5/5: A Devolução da Placa a Hisoka"
					q.description = "Enfrente Hisoka no combate do 200º andar, acerte um golpe limpo em seu rosto e devolva a Placa nº 44 com orgulho de Caçador!"
					q.reward_xp = 18000
					q.reward_gold = 300000
					var o1 := _criar_obj_visit(&"hisoka", "Hisoka Morow")
					var o2 := _criar_obj_kill(&"hisoka_boss", 1)
					q.objectives = [o1, o2]

		# =====================================================
		# ARCO 4: YORKNEW CITY (5 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		4:
			match etapa:
				1:
					q.quest_name = "Yorknew City 1/5: A Noite do Leilão Subterrâneo"
					q.description = "Encontre Kurapika e a musicista Melody nos arranha-céus de Yorknew e investigue o ataque surpresa da Trupe Fantasma ao leilão."
					q.reward_xp = 15000
					q.reward_gold = 250000
					var o1 := _criar_obj_visit(&"kurapika", "Kurapika (Guarda-Costas Nostrade)")
					var o2 := _criar_obj_visit(&"melody", "Melody (Musicista Hunter)")
					var o3 := _criar_obj_kill(&"mafioso_corrompido", 4)
					q.objectives = [o1, o2, o3]

				2:
					q.quest_name = "Yorknew City 2/5: A Queda do Monstro Uvogin"
					q.description = "Siga o rastro de destruição até o deserto de Gordeau. Lute com a Trupe e use a Chain Jail de Kurapika para conter o Titã Uvogin."
					q.reward_xp = 22000
					q.reward_gold = 350000
					var o1 := _criar_obj_kill(&"uvogin", 1)
					var o2 := _criar_obj_visit(&"kurapika", "Kurapika")
					q.objectives = [o1, o2]

				3:
					q.quest_name = "Yorknew City 3/5: A Infiltração no Edifício Cemitério"
					q.description = "Infiltre-se no prédio do leilão com Gon e Killua, derrote os guardas de elite de Feitan e resgate os tesouros do leilão."
					q.reward_xp = 28000
					q.reward_gold = 450000
					var o1 := _criar_obj_visit(&"gon", "Gon Freecss")
					var o2 := _criar_obj_kill(&"clone_feitan", 3)
					q.objectives = [o1, o2]

				4:
					q.quest_name = "Yorknew City 4/5: O Apagão & A Captura de Chrollo"
					q.description = "Corte a energia da estação central, capture o líder Chrollo Lucilfer no escuro e proteja Gon e Killua da vingança de Pakunoda."
					q.reward_xp = 35000
					q.reward_gold = 600000
					var o1 := _criar_obj_visit(&"kurapika", "Kurapika")
					var o2 := _criar_obj_kill(&"pakunoda", 1)
					q.objectives = [o1, o2]

				5:
					q.quest_name = "Yorknew City 5/5: A Corrente do Julgamento"
					q.description = "Imponha a Judgement Chain no coração de Chrollo Lucilfer, proíba-o de usar Nen e encerre o pesadelo da Aranha em Yorknew!"
					q.reward_xp = 50000
					q.reward_gold = 800000
					var o1 := _criar_obj_visit(&"chrollo", "Chrollo Lucilfer")
					var o2 := _criar_obj_kill(&"chrollo_boss", 1)
					q.objectives = [o1, o2]

		# =====================================================
		# ARCO 5: GREED ISLAND (5 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		5:
			match etapa:
				1:
					q.quest_name = "Greed Island 1/5: O Console JoyStation & Antokiba"
					q.description = "Fale com o bilionário Battera, ative o jogo JoyStation com Nen e chegue à cidade inicial de Antokiba."
					q.reward_xp = 30000
					q.reward_gold = 500000
					var o1 := _criar_obj_visit(&"battera", "Bilionário Battera")
					var o2 := _criar_obj_visit(&"antokiba", "Cidade de Antokiba")
					q.objectives = [o1, o2]

				2:
					q.quest_name = "Greed Island 2/5: O Treinamento Extremo de Biscuit"
					q.description = "Encontre Biscuit Krueger nas montanhas de rochas. Realize o treino rigoroso de Ko e Shu para dominar os fundamentos definitivos."
					q.reward_xp = 42000
					q.reward_gold = 700000
					var o1 := _criar_obj_visit(&"biscuit", "Mestra Biscuit Krueger")
					var o2 := _criar_obj_kill(&"golem_pedra", 3)
					q.objectives = [o1, o2]

				3:
					q.quest_name = "Greed Island 3/5: A Caçada pelas Cartas de Bolso"
					q.description = "Derrote monstros mágicos da ilha para obter feitiços e cartas de bolso especificado raras."
					q.reward_xp = 55000
					q.reward_gold = 900000
					var o1 := _criar_obj_kill(&"monstro_greed", 4)
					var o2 := _criar_obj_visit(&"goreinu", "Goreinu")
					q.objectives = [o1, o2]

				4:
					q.quest_name = "Greed Island 4/5: O Jogo Mortal de Queimada de Razor"
					q.description = "Encontre o Game Master Razor no farol de Soufrabi. Derrote seus 6 demônios e rebata o arremesso com Gon, Killua e Hisoka!"
					q.reward_xp = 75000
					q.reward_gold = 1300000
					var o1 := _criar_obj_visit(&"razor", "Game Master Razor")
					var o2 := _criar_obj_kill(&"demonio_razor", 6)
					var o3 := _criar_obj_kill(&"razor_boss", 1)
					q.objectives = [o1, o2, o3]

				5:
					q.quest_name = "Greed Island 5/5: A Armadilha contra o Bombardeiro"
					q.description = "Derrote Genthru com a armadilha de pedras de Gon, conclua a coleção de 100 cartas do Binder e vença Greed Island!"
					q.reward_xp = 100000
					q.reward_gold = 2000000
					var o1 := _criar_obj_kill(&"genthru", 1)
					var o2 := _criar_obj_visit(&"elena_greed", "Elena (Criadora de Greed Island)")
					q.objectives = [o1, o2]

		# =====================================================
		# ARCO 6: FORMIGAS CHIMERA (5 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		6:
			match etapa:
				1:
					q.quest_name = "Formigas Chimera 1/5: A Fronteira da NGL"
					q.description = "Fale com Kite, Gon e Killua na fronteira da NGL e elimine as patrulhas de Formigas Soldado mutantes."
					q.reward_xp = 70000
					q.reward_gold = 1000000
					var o1 := _criar_obj_visit(&"kite", "Kite (Caçador de Contratos)")
					var o2 := _criar_obj_kill(&"formiga_soldado", 5)
					q.objectives = [o1, o2]

				2:
					q.quest_name = "Formigas Chimera 2/5: A Sombra Assassina de Pitou"
					q.description = "Testemunhe a aura monstruosa de Neferpitou. Resgate Killua e Gon e recue para treinar com Knuckle e Shoot."
					q.reward_xp = 95000
					q.reward_gold = 1400000
					var o1 := _criar_obj_visit(&"knuckle", "Knuckle Bine")
					var o2 := _criar_obj_visit(&"shoot", "Shoot McMahon")
					var o3 := _criar_obj_kill(&"formiga_oficial", 2)
					q.objectives = [o1, o2, o3]

				3:
					q.quest_name = "Formigas Chimera 3/5: A Seleção dos Exterminadores"
					q.description = "Encontre Morel, Knov e Netero na base de operações de Peijin e destrua as barricadas inimigas antes da invasão."
					q.reward_xp = 130000
					q.reward_gold = 2000000
					var o1 := _criar_obj_visit(&"morel", "Morel Mackernasey")
					var o2 := _criar_obj_visit(&"netero", "Presidente Isaac Netero")
					var o3 := _criar_obj_kill(&"guarda_peijin", 4)
					q.objectives = [o1, o2, o3]

				4:
					q.quest_name = "Formigas Chimera 4/5: A Invasão ao Palácio Real"
					q.description = "Invada o Palácio Real sob a Chuva de Dragões de Zeno. Lute contra Youpi Centauro e Shaiapouf nas escadarias."
					q.reward_xp = 180000
					q.reward_gold = 3000000
					var o1 := _criar_obj_kill(&"youpi", 1)
					var o2 := _criar_obj_kill(&"shaiapouf", 1)
					q.objectives = [o1, o2]

				5:
					q.quest_name = "Formigas Chimera 5/5: O Ápice da Evolução"
					q.description = "Assista ao 100-Type Guanyin Bodhisattva de Netero, derrote a projeção sanguinária de Pitou e encerre a crise Chimera!"
					q.reward_xp = 250000
					q.reward_gold = 5000000
					var o1 := _criar_obj_kill(&"neferpitou", 1)
					var o2 := _criar_obj_visit(&"meruem", "Rei Meruem")
					q.objectives = [o1, o2]

		# =====================================================
		# ARCO 7: ELEIÇÃO HUNTER (4 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		7:
			match etapa:
				1:
					q.quest_name = "Eleição Hunter 1/4: O Testamento dos 12 Zodíacos"
					q.description = "Apresente-se na sede da Associação Hunter para a leitura do testamento de Netero com Cheadle, Botobai e Pariston."
					q.reward_xp = 120000
					q.reward_gold = 2000000
					var o1 := _criar_obj_visit(&"cheadle", "Cheadle Yorkshire (Zodíaco Cão)")
					var o2 := _criar_obj_visit(&"pariston", "Pariston Hill (Vice-Presidente)")
					q.objectives = [o1, o2]

				2:
					q.quest_name = "Eleição Hunter 2/4: O Resgate de Alluka Zoldyck"
					q.description = "Ajude Killua a retirar Alluka da masmorra da mansão Zoldyck sob a vigilância das agulhas de Illumi."
					q.reward_xp = 160000
					q.reward_gold = 2800000
					var o1 := _criar_obj_visit(&"killua", "Killua Zoldyck")
					var o2 := _criar_obj_kill(&"mordomo_perseguidor", 4)
					q.objectives = [o1, o2]

				3:
					q.quest_name = "Eleição Hunter 3/4: A Emboscada de Illumi na Rodovia"
					q.description = "Elimine o exército de humanos manipulados por agulhas de Illumi e abra caminho até o auditório da Associação."
					q.reward_xp = 210000
					q.reward_gold = 3800000
					var o1 := _criar_obj_kill(&"humano_agulha", 8)
					var o2 := _criar_obj_kill(&"illumi", 1)
					q.objectives = [o1, o2]

				4:
					q.quest_name = "Eleição Hunter 4/4: O Milagre de Nanika & A Cura de Gon"
					q.description = "Leve Alluka até o hospital, assista à restauração milagrosa de Gon e participe da votação final de Leorio e Cheadle!"
					q.reward_xp = 300000
					q.reward_gold = 6000000
					var o1 := _criar_obj_visit(&"alluka", "Alluka & Nanika")
					var o2 := _criar_obj_visit(&"gon_recuperado", "Gon Freecss Recuperado")
					var o3 := _criar_obj_visit(&"leorio", "Leorio Paradinight")
					q.objectives = [o1, o2, o3]

		# =====================================================
		# ARCO 8: CONTINENTE NEGRO (4 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		8:
			match etapa:
				1:
					q.quest_name = "Continente Negro 1/4: A Declaração de Beyond Netero"
					q.description = "Fale com Beyond Netero e Ging Freecss sobre os limites do mapa mundial e prepare o recrutamento da expedição."
					q.reward_xp = 250000
					q.reward_gold = 4500000
					var o1 := _criar_obj_visit(&"beyond", "Beyond Netero")
					var o2 := _criar_obj_visit(&"ging", "Ging Freecss")
					q.objectives = [o1, o2]

				2:
					q.quest_name = "Continente Negro 2/4: A Calamidade Botânica Brion"
					q.description = "Infiltre-se nas ruínas ancestrais do Novo Mundo e derrote a arma biológica viva Brion."
					q.reward_xp = 320000
					q.reward_gold = 6000000
					var o1 := _criar_obj_kill(&"guardiao_brion", 5)
					var o2 := _criar_obj_kill(&"brion_boss", 1)
					q.objectives = [o1, o2]

				3:
					q.quest_name = "Continente Negro 3/4: O Terror de Hellbell e Ai"
					q.description = "Sobreviva ao veneno alucinógeno da Serpente Hellbell e isole a entidade gasosa Ai."
					q.reward_xp = 400000
					q.reward_gold = 8000000
					var o1 := _criar_obj_kill(&"hellbell_boss", 1)
					var o2 := _criar_obj_kill(&"ai_boss", 1)
					q.objectives = [o1, o2]

				4:
					q.quest_name = "Continente Negro 4/4: O Topo da Árvore do Mundo"
					q.description = "Escale a árvore titânica de 1.784 metros de altura e converse com Ging Freecss sobre a imensidão do universo Hunter!"
					q.reward_xp = 550000
					q.reward_gold = 12000000
					var o1 := _criar_obj_visit(&"arvore_mundo", "Topo da Árvore do Mundo")
					var o2 := _criar_obj_visit(&"ging_topo", "Ging Freecss no Topo do Mundo")
					q.objectives = [o1, o2]

		# =====================================================
		# ARCO 9: GUERRA DE SUCESSÃO DE KAKIN (5 CAPÍTULOS DE HISTÓRIA)
		# =====================================================
		9:
			match etapa:
				1:
					q.quest_name = "Guerra de Sucessão 1/5: O Embarque no Black Whale 1"
					q.description = "Apresente-se com Kurapika e a Rainha Oito no Convés 1 do navio colossal Black Whale 1 para proteger o Príncipe Woble."
					q.reward_xp = 350000
					q.reward_gold = 7000000
					var o1 := _criar_obj_visit(&"kurapika", "Kurapika")
					var o2 := _criar_obj_visit(&"rainha_oito", "Rainha Oito & Príncipe Woble")
					q.objectives = [o1, o2]

				2:
					q.quest_name = "Guerra de Sucessão 2/5: O Ritual do Vaso de Kakin"
					q.description = "Testemunhe o despertar das Bestas Parasitas de Nen dos 14 Príncipes geradas pelo Vaso Sagrado de Kakin."
					q.reward_xp = 450000
					q.reward_gold = 9000000
					var o1 := _criar_obj_visit(&"vaso_kakin", "Vaso Sagrado de Kakin")
					var o2 := _criar_obj_kill(&"besta_parasita", 3)
					q.objectives = [o1, o2]

				3:
					q.quest_name = "Guerra de Sucessão 3/5: O Massacre da Família Heil-Ly"
					q.description = "Desça aos conveses inferiores e extermine os assassinos contagiados pela seita de Nen da Máfia Heil-Ly de Morena Prudo."
					q.reward_xp = 580000
					q.reward_gold = 12000000
					var o1 := _criar_obj_visit(&"hinrigh", "Hinrigh (Família Xi-Yu)")
					var o2 := _criar_obj_kill(&"assassino_heilly", 6)
					q.objectives = [o1, o2]

				4:
					q.quest_name = "Guerra de Sucessão 4/5: O Futuro Paralelo de Tserriednich"
					q.description = "Infiltre-se nos aposentos do 4º Príncipe Tserriednich e neutralize sua Besta Parasita Facial antes que seu Zetsu Paralelo se complete."
					q.reward_xp = 750000
					q.reward_gold = 16000000
					var o1 := _criar_obj_kill(&"besta_tserriednich", 1)
					var o2 := _criar_obj_kill(&"tserriednich_boss", 1)
					q.objectives = [o1, o2]

				5:
					q.quest_name = "Guerra de Sucessão 5/5: A Caçada Final da Trupe Fantasma"
					q.description = "Encontre a Trupe Fantasma e Hisoka nos conveses profundos, derrote os líderes das facções rebeldes e torne-se o Maior Caçador da História!"
					q.reward_xp = 1000000
					q.reward_gold = 25000000
					var o1 := _criar_obj_visit(&"chrollo", "Chrollo Lucilfer")
					var o2 := _criar_obj_visit(&"hisoka", "Hisoka Morow")
					var o3 := _criar_obj_kill(&"boss_final_kakin", 1)
					q.objectives = [o1, o2, o3]

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
