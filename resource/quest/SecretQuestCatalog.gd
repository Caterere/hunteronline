class_name SecretQuestCatalog
extends Resource

# ============================================================
# HUNTER ONLINE - SECRET & TERTIARY QUEST CATALOG
# ============================================================
#
# Catálogo de 10 Missões Terciárias e Ocultas do universo de
# Hunter x Hunter, com enredos densos, dilemas e recompensas secretas:
# - Componentes únicos de Hatsu
# - Títulos Lendários com efeitos visuais
# - Buffs permanentes de atributos e cartas de Greed Island
#
# ============================================================

static var _secret_cache: Dictionary = {}

static func obter_todas_missoes_secretas() -> Array[Dictionary]:
	return [
		{
			"id": "secret_kurta_vow",
			"nome": "🩸 O Juramento do Coração Kurta",
			"npc": "Kurapika",
			"lore": "Kurapika revela a dor inextinguível de carregar as memórias dos Olhos Escarlates. Ele propõe ensinar o segredo dos Juramentos de Vida ou Morte para fortalecer seu Hatsu ao limite absoluto.",
			"requisito": "Nen Lv.12+ & Falar com Kurapika",
			"recompensa_desc": "Componente Hatsu [Restrição: Vow of Judgment] & Título [⛓️ Juiz das Correntes]"
		},
		{
			"id": "secret_phantom_blood",
			"nome": "🕷️ A Trupe e o Batismo de Meteor City",
			"npc": "Chrollo Lucilfer",
			"lore": "Chrollo observa você nas sombras e propõe um teste de desapego mortal. Sobreviva à avaliação de intenção assassina da Trupe Fantasma para se tornar a 14ª Pata da Aranha.",
			"requisito": "Nen Lv.15+ & Encontrar Chrollo nos becos",
			"recompensa_desc": "Componente Hatsu [Forma: Fios de Machi] & Título [🕷️ 14º Membro da Aranha]"
		},
		{
			"id": "secret_zoldyck_lightning",
			"nome": "⚡ O Treino do Relâmpago Zoldyck",
			"npc": "Killua & Silva Zoldyck",
			"lore": "Na sala de tortura da mansão Zoldyck, Killua demonstra como transmutou sua aura em eletricidade após anos suportando choques de alta voltagem. Suporte a corrente elétrica para aprender a técnica!",
			"requisito": "Força 60+ & Defesa 60+",
			"recompensa_desc": "Componente Hatsu [Elemento: Eletricidade Narukami] & Título [⚡ Deus do Trovão]"
		},
		{
			"id": "secret_ging_cassette",
			"nome": "🧭 A Fita Cassete Esquecida de Ging",
			"npc": "Ging Freecss (Gravação)",
			"lore": "Uma fita de áudio gravada pelo lendário Ging Freecss foi esquecida no arquivo dimensional. Decodifique a mensagem com Nen para compreender a vastidão do mundo além do horizonte.",
			"requisito": "Nen Lv.8+ & Explorar Distrito Dimensional",
			"recompensa_desc": "+100.000 Nen XP & Título [🧭 Explorador do Desconhecido]"
		},
		{
			"id": "secret_gourmet_feast",
			"nome": "🍖 O Banquete das Feras Proibidas",
			"npc": "Menchi & Buhara",
			"lore": "Menchi desafia você a caçar os três ingredientes mais raros da Floresta Biska para preparar o lendário Banquete dos Caçadores de Feras.",
			"requisito": "Derrotar Great Stamp Pig & 5 Bounties",
			"recompensa_desc": "Consumível: Banquete Mágico (+500 HP Max e +200 Aura Max permanentes)"
		},
		{
			"id": "secret_razor_dodgeball",
			"nome": "🏐 A Provação da Queimada de Razor",
			"npc": "Razor (Greed Island)",
			"lore": "Na quadra mágica de Greed Island, Razor lança uma esfera de Nen a 300 km/h com 14 demônios de emissão. Concentre Ryu nas duas mãos para interceptar o saque!",
			"requisito": "Arco Greed Island & Ren Lv.5+",
			"recompensa_desc": "Carta Nº 002 [Respiração do Grande Anjo] & Título [🏐 Mestre da Queimada]"
		},
		{
			"id": "secret_illumi_needles",
			"nome": "📍 A Marionete da Morte de Illumi",
			"npc": "Illumi Zoldyck",
			"lore": "Illumi espalhou agulhas hipnóticas de manipulação. Desvie dos alvos controlados mentalmente sem sofrer um único arranhão.",
			"requisito": "Gyo Lv.5+ & Esquiva 50+",
			"recompensa_desc": "Componente Hatsu [Forma: Agulhas Hipnóticas]"
		},
		{
			"id": "secret_gotoh_coins",
			"nome": "🪙 O Jogo da Moeda Supersônica de Gotoh",
			"npc": "Gotoh",
			"lore": "O mordomo-chefe Gotoh dispara moedas com o polegar com força de projéteis de artilharia. Use Gyo para acompanhar a trajetória em alta velocidade.",
			"requisito": "Visitar Montanha Kukuroo",
			"recompensa_desc": "Acessório: [Moeda Pesada de Gotoh (+30 Força)] & Título [👁️ Olho de Águia]"
		},
		{
			"id": "secret_netero_gratitude",
			"nome": "🙏 Os 10.000 Socos de Gratidão de Netero",
			"npc": "Estátua de Isaac Netero",
			"lore": "Netero passou 2 anos nas montanhas rezando e desferindo 10.000 socos de gratidão por dia até ultrapassar a velocidade do som. Repita a disciplina diária de oração!",
			"requisito": "Orar e Meditar na Estátua de Netero",
			"recompensa_desc": "+200 Aura Máxima permanente & Efeito Visual de Aura Dourada & Título [🙏 Punho da Gratidão]"
		},
		{
			"id": "secret_hisoka_bungee",
			"nome": "🃏 O Teste da Bungee Gum de Hisoka",
			"npc": "Hisoka Morow",
			"lore": "Hisoka quer testar se sua aura possui elasticidade e viscosidade. Resista ao duelo psicológico na névoa sem recuar perante sua sede de sangue.",
			"requisito": "Enfrentar Hisoka na Torre/Lobby",
			"recompensa_desc": "Componente Hatsu [Forma: Goma Elástica Bungee Gum] & Título [🃏 Ilusionista Sádico]"
		}
	]


static func criar_quest_secreta(id_secret: String) -> Quest:
	if _secret_cache.has(id_secret) and _secret_cache[id_secret] != null:
		return _secret_cache[id_secret]
		
	var q := Quest.new()
	q.resource_path = "res://data/quests/secret_%s.tres" % id_secret
	q.completion = Quest.Completion.ALL
	q.auto_complete = true
	
	match id_secret:
		"secret_kurta_vow":
			q.quest_name = "🩸 O Juramento do Coração Kurta"
			q.description = "Encontre Kurapika, ouça a tragédia do Clã Kurta e faça o voto espiritual de restrição para multiplicar a potência do seu Hatsu contra chefes do mal."
			q.reward_xp = 25000
			q.reward_gold = 50000
			var o1 := _criar_obj_visit(&"kurapika", "Kurapika (Olhos Escarlates)")
			q.objectives = [o1]
			
		"secret_phantom_blood":
			q.quest_name = "🕷️ A Trupe e o Batismo de Meteor City"
			q.description = "Encontre Chrollo Lucilfer no esconderijo sombrio. Supere o teste de sangue e audácia para receber a bênção da Aranha Imperial."
			q.reward_xp = 35000
			q.reward_gold = 100000
			var o1 := _criar_obj_visit(&"chrollo", "Chrollo Lucilfer (Líder da Trupe)")
			q.objectives = [o1]
			
		"secret_zoldyck_lightning":
			q.quest_name = "⚡ O Treino do Relâmpago Zoldyck"
			q.description = "Visite a Mansão Zoldyck e suporte as descargas de alta voltagem de Killua e Silva para absorver a transmutação elétrica."
			q.reward_xp = 30000
			q.reward_gold = 60000
			var o1 := _criar_obj_visit(&"killua", "Killua Zoldyck")
			q.objectives = [o1]
			
		"secret_ging_cassette":
			q.quest_name = "🧭 A Fita Cassete Esquecida de Ging"
			q.description = "Encontre a gravação secreta de Ging Freecss no Distrito Dimensional e decifre sua mensagem sobre o Continente Negro."
			q.reward_xp = 100000
			q.reward_gold = 200000
			var o1 := _criar_obj_visit(&"portal_hunter", "Arquivo Dimensional de Ging")
			q.objectives = [o1]
			
		"secret_gourmet_feast":
			q.quest_name = "🍖 O Banquete das Feras Proibidas"
			q.description = "Entregue a carne de 3 feras raras para Menchi e Buhara e prepare o Banquete Mágico de Caçadores."
			q.reward_xp = 20000
			q.reward_gold = 40000
			var o1 := _criar_obj_visit(&"menchi", "Examinadora Menchi")
			var o2 := _criar_obj_visit(&"buhara", "Examinador Buhara")
			q.objectives = [o1, o2]
			
		"secret_gotoh_coins":
			q.quest_name = "🪙 O Jogo da Moeda Supersônica de Gotoh"
			q.description = "Fale com o Mordomo-Chefe Gotoh na entrada da propriedade e passe em seu teste de rastreamento de projéteis com Gyo."
			q.reward_xp = 15000
			q.reward_gold = 30000
			var o1 := _criar_obj_visit(&"gotoh", "Mordomo Gotoh")
			q.objectives = [o1]
			
		_:
			q.quest_name = "Missão Secreta Oculta"
			q.description = "Investigue os mistérios do mundo de Hunter x Hunter."
			q.reward_xp = 10000
			q.reward_gold = 20000
			q.objectives = []
			
	_secret_cache[id_secret] = q
	return q


static func _criar_obj_visit(npc_id: StringName, npc_name: String) -> QuestObjective:
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.VISIT
	obj.target_npc_id = npc_id
	obj.target_npc_name = npc_name
	obj.required_amount = 1
	return obj
