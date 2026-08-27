class_name StoryCutsceneManager
extends Node

# ============================================================
# HUNTER ONLINE - STORY CUTSCENE MANAGER (CINEMATIC SEQUENCES)
# ============================================================
#
# Coordena cutscenes narrativas com múltiplos personagens utilizando
# tanto o VisualDialogueUI (caixa de diálogo cinematográfica) quanto
# balões de fala dinâmicos (SpeechBubbleNode) e movimentação em grupo.
# Focado na fidelidade épica e profunda ao mangá de Hunter x Hunter!
#
# ============================================================

static var em_cutscene: bool = false


# ------------------------------------------------------------
# ARCO 1: EXAME HUNTER — ENCONTRO DOS 4 AMIGOS NA MARATONA (TÚNEL)
# ------------------------------------------------------------
static func executar_maratona_hunter(tree: SceneTree, gon: NPC, killua: NPC, leorio: NPC, kurapika: NPC, satotz: NPC) -> void:
	if em_cutscene:
		return
		
	em_cutscene = true
	print("[Cutscene] Iniciando Sequência do Exame Hunter: Encontro dos 4 Amigos...")

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Gon Freecss (Nº 405)", "texto": "Oi! Eu sou o Gon da Ilha da Baleia! Estou fazendo o Exame Hunter para descobrir por que meu pai, o Ging, escolheu ser Hunter acima de tudo!"},
			{"falante": "Killua Zoldyck (Nº 99)", "texto": "Ei, skate não é trapaça! O examinador só mandou segui-lo. Eu sou o Killua... Fugir da minha família de assassinos parecia divertido, mas até agora tá bem fácil."},
			{"falante": "Leorio Paradinight (Nº 403)", "texto": "Ufa... argh... calem a boca, seus moleques cheios de energia! Eu sou o Leorio! Se eu virar Hunter, vou ter dinheiro pra pagar a faculdade de medicina e tratar os doentes de graça sem cobrar um centavo!"},
			{"falante": "Kurapika (Nº 404)", "texto": "Eu sou Kurapika, o último sobrevivente do Clã Kurta. Busco a Licença Hunter para caçar os assassinos da Trupe Fantasma (Genei Ryodan) e recuperar os Olhos Escarlates roubados do meu povo."},
			{"falante": "Gon Freecss (Nº 405)", "texto": "Nós 4 temos motivos diferentes, mas vamos passar juntos! Olhem, o Examinador Satotz está acelerando o passo! Mantenham o ritmo!"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			_mover_amigos_maratona(tree, gon, killua, leorio, kurapika, satotz)
		, CONNECT_ONE_SHOT)
	else:
		if gon != null and is_instance_valid(gon):
			gon.falar_balao("Oi! Eu sou o Gon Freecss! Vamos todos correr juntos até o Satotz!", 3.5, Color(0.2, 0.9, 0.4, 1.0))
			await tree.create_timer(3.5).timeout
			if is_instance_valid(gon): gon.fechar_balao_atual()
		_mover_amigos_maratona(tree, gon, killua, leorio, kurapika, satotz)


static func _mover_amigos_maratona(tree: SceneTree, gon: NPC, killua: NPC, leorio: NPC, kurapika: NPC, satotz: NPC) -> void:
	var destino_satotz := Vector2(1750, -300)
	if satotz != null and is_instance_valid(satotz):
		destino_satotz = satotz.global_position + Vector2(-60, 0)

	print("[Cutscene] O grupo começa a correr pelo túnel em direção ao Satotz!")
	if gon != null and is_instance_valid(gon): gon.andar_para(destino_satotz + Vector2(0, -20), 110.0)
	if killua != null and is_instance_valid(killua): killua.andar_para(destino_satotz + Vector2(25, -10), 120.0)
	if kurapika != null and is_instance_valid(kurapika): kurapika.andar_para(destino_satotz + Vector2(-20, 20), 105.0)
	if leorio != null and is_instance_valid(leorio): leorio.andar_para(destino_satotz + Vector2(-45, 10), 95.0)

	await tree.create_timer(2.0).timeout
	em_cutscene = false

	var hud = tree.get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🏃 Siga o grupo e alcance o Examinador Satotz no fim do túnel!")


# ------------------------------------------------------------
# ARCO 1: ENTRADA NO PANTANAL NUMERE & AMEAÇA DE HISOKA
# ------------------------------------------------------------
static func executar_pantanal_hisoka(tree: SceneTree, satotz: NPC, hisoka: NPC, amigos: Array[NPC]) -> void:
	if em_cutscene:
		return
		
	em_cutscene = true
	print("[Cutscene] Iniciando Sequência do Pantanal Numere & Hisoka...")

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Examinador Satotz", "texto": "Parabéns aos que resistiram à maratona subterrânea. À nossa frente estende-se o Pantanal Numere — também conhecido como o 'Ninho dos Trapaceiros'."},
			{"falante": "Examinador Satotz", "texto": "O nevoeiro é denso e traiçoeiro. Macacos comedores de homens e feras ilusórias usarão truques para devorar candidatos desatentos. Não se separem de mim sob hipótese alguma!"},
			{"falante": "Hisoka", "texto": "♦ Hehe... Que interessante... No meio da névoa, ninguém vai ouvir os gritos dos fracos sendo purgados. Vamos ver quem é digno de continuar vivo... ♠"},
			{"falante": "Kurapika", "texto": "A aura daquele homem... é assassina e monstruosa! Fiquem alertas, o perigo no pantanal não vem apenas das feras!"},
			{"falante": "Killua Zoldyck", "texto": "Gon, vamos na frente! Ficar perto do Hisoka é pedir pra morrer antes da 2ª fase!"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			_dispersar_amigos_pantanal(tree, amigos)
		, CONNECT_ONE_SHOT)
	else:
		if satotz != null and is_instance_valid(satotz):
			satotz.falar_balao("Atenção no nevoeiro do Pantanal Numere! Não caiam em armadilhas!", 4.0, Color(0.6, 0.7, 0.9, 1.0))
			await tree.create_timer(4.0).timeout
			if is_instance_valid(satotz): satotz.fechar_balao_atual()
		_dispersar_amigos_pantanal(tree, amigos)


static func _dispersar_amigos_pantanal(tree: SceneTree, amigos: Array[NPC]) -> void:
	var destino_pantanal := Vector2(3400, -700)
	for i in range(amigos.size()):
		var amigo = amigos[i]
		if amigo != null and is_instance_valid(amigo):
			amigo.andar_para(destino_pantanal + Vector2(i * 35 - 50, (i % 2) * 40 - 20), 120.0)

	await tree.create_timer(2.0).timeout
	em_cutscene = false

	var hud = tree.get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚔️ Atravesse o Pantanal Numere e derrote as criaturas do nevoeiro!")


# ------------------------------------------------------------
# ARCO 1: FLORESTA BISKA & HUNTERS GOURMET (MENCHI & BUHARA)
# ------------------------------------------------------------
static func executar_gourmet_menchi_buhara(tree: SceneTree) -> void:
	if em_cutscene:
		return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Examinador Buhara", "texto": "Bons candidatos! O meu menu para a 2ª Fase é carne assada de Great Stamp Pig!"},
			{"falante": "Examinadora Menchi", "texto": "Cozinhar é a arte suprema de colocar a vida em risco para extrair o melhor sabor do mundo. Se a carne estiver mal preparada ou se demonstrarem covardia, todos serão reprovados!"},
			{"falante": "Gon Freecss", "texto": "Eu e o Killua vamos caçar os javalis gigantes na floresta! Vamos nessa!"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			em_cutscene = false
			var hud = tree.get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🐗 Cace o Grande Javali Selvagem (Great Stamp) na Floresta Biska!")
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false


# ------------------------------------------------------------
# ARCO 1: CLÍMAX & CONCLUSÃO DA 1ª FASE DO EXAME
# ------------------------------------------------------------
static func executar_conclusao_exame_hunter(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene:
		return

	em_cutscene = true
	print("[Cutscene] 🏆 Conclusão da 1ª Fase do 287º Exame Hunter...")

	if QuestSystem != null:
		QuestSystem.register_npc_visit(&"satotz")

	PlayerData.completar_etapa_historia(1)

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Examinador Satotz", "texto": "Atenção a todos os candidatos sobreviventes! O nevoeiro do Pantanal Numere e as provações da Floresta Biska foram superadas!"},
			{"falante": "Examinador Satotz", "texto": "Declaro oficialmente ENCERRADA a 1ª Fase do 287º Exame Hunter! Vocês provaram ter resistência física, técnica e determinação inabalável."},
			{"falante": "Gon Freecss", "texto": "Nós conseguimos passar juntos! Mas... onde está o Killua? Ele me disse que precisava voltar para a sua casa antes da próxima fase..."},
			{"falante": "Kurapika", "texto": "A família do Killua... os infames assassinos Zoldyck. A propriedade deles fica no pico da temida Montanha Kukuroo."},
			{"falante": "Leorio Paradinight", "texto": "Não vamos deixar nosso amigo para trás! Vamos até a Montanha Kukuroo abrir aqueles portões gigantes e resgatar o Killua!"},
			{"falante": "Examinador Satotz", "texto": "O caminho para a Montanha Kukuroo está aberto. Preparem-se... a verdadeira provação dos Caçadores está apenas começando!"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			em_cutscene = false
			var hud = tree.get_first_node_in_group("player_hud")
			if hud != null and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🏆 1ª FASE CONCLUÍDA! Rumo à Montanha Kukuroo!")
			if callback_fim.is_valid():
				callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		await tree.create_timer(1.0).timeout
		em_cutscene = false
		if callback_fim.is_valid():
			callback_fim.call()


# ------------------------------------------------------------
# ARCO 2: MONTANHA KUKUROO (OS ASSASSINOS ZOLDYCK)
# ------------------------------------------------------------
static func executar_montanha_kukuroo_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene: return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Guarda Zebro", "texto": "Bem-vindos aos portões da família Zoldyck. Qualquer um que entrar pela porta lateral será devorado vivo pelo cão de guarda Mike."},
			{"falante": "Guarda Zebro", "texto": "Se querem ver o jovem mestre Killua como amigos, precisão empurrar o Portão da Testagem. Cada folha pesa 2 toneladas — um total de 4 toneladas no 1º portão!"},
			{"falante": "Gon Freecss", "texto": "Nós vamos treinar com os pesos de vocês e empurrar esse portão com nossas próprias mãos!"},
			{"falante": "Mordoma Canary", "texto": "...Vocês realmente são amigos do jovem Killua? Ele nunca teve ninguém para chamá-lo pelo nome sem medo... Por favor, salvem o jovem mestre da escuridão."},
			{"falante": "Silva Zoldyck", "texto": "Killua... vá com seus amigos. Mas lembre-se do nosso pacto de sangue: 'Nunca traia seus companheiros'. E você sempre será o meu filho... um assassino Zoldyck."}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.completar_etapa_historia(2)
			em_cutscene = false
			if callback_fim.is_valid(): callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false
		if callback_fim.is_valid(): callback_fim.call()


# ------------------------------------------------------------
# ARCO 3: ARENA CELESTIAL & O DESPERTAR DO NEN
# ------------------------------------------------------------
static func executar_arena_celestial_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene: return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Mestre Wing", "texto": "Escutem bem, Gon, Killua e jovem Hunter. O que vocês sentiram no corredor do 200º andar foi 'Hatsu' carregado de intenção assassina."},
			{"falante": "Mestre Wing", "texto": "Se passassem por aquela linha sem proteção, seus corpos seriam despedaçados pela pressão de aura. É hora de despertar seus nós de Nen através do 'Ten'!"},
			{"falante": "Zushi", "texto": "Osu! Os 4 Grandes Princípios são Ten (Envolver), Zetsu (Silenciar), Ren (Expandir) e Hatsu (Liberar)!"},
			{"falante": "Hisoka", "texto": "♦ Hehe... Finalmente vocês aprenderam a enxergar a aura com Gyo. Agora sim a luta pelo 200º andar será deliciosa... ♠"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.completar_etapa_historia(3)
			em_cutscene = false
			if callback_fim.is_valid(): callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false
		if callback_fim.is_valid(): callback_fim.call()


# ------------------------------------------------------------
# ARCO 4: YORKNEW CITY & A TRUPE FANTASMA (GENEI RYODAN)
# ------------------------------------------------------------
static func executar_yorknew_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene: return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Kurapika", "texto": "Minhas correntes foram forjadas sob um Juramento de Sangue (Vow & Limitation). A Corrente do Julgamento só pode ser usada contra os 13 membros da Trupe Fantasma."},
			{"falante": "Kurapika", "texto": "Se eu violar essa regra contra qualquer outra pessoa, a lâmina de Nen perfurará meu próprio coração instantaneamente."},
			{"falante": "Chrollo Lucilfer", "texto": "A Aranha não morrerá mesmo se a cabeça for decepada. Nossos membros continuarão marchando... Uvogin, toque o Réquiem que preparamos para você."},
			{"falante": "Gon Freecss", "texto": "Kurapika! Nós não vamos deixar você carregar o peso dessa escuridão sozinho!"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.completar_etapa_historia(4)
			em_cutscene = false
			if callback_fim.is_valid(): callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false
		if callback_fim.is_valid(): callback_fim.call()


# ------------------------------------------------------------
# ARCO 5: GREED ISLAND & O TREINO DE BISCUIT KRUEGER
# ------------------------------------------------------------
static func executar_greed_island_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene: return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Biscuit Krueger", "texto": "Parem de choramingar! Vocês dois são diamantes brutos, mas as técnicas de combate de vocês estão cheias de frestas!"},
			{"falante": "Biscuit Krueger", "texto": "Vamos treinar 'Ken' e 'Ryu' escavando rochas e mantendo 80% de aura nos punhos enquanto desviam de projéteis em alta velocidade!"},
			{"falante": "Razor (Game Master)", "texto": "Ging me disse que um dia o filho dele viria até aqui... Preparem-se para receber meu saque com 100% de Nen na quadra de queimada!"},
			{"falante": "Genthru (O Bomber)", "texto": "Liberem as cartas de feitiço número 000 a 099 ou transformarei todos vocês em cinzas com o 'Little Flower'!"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.completar_etapa_historia(5)
			em_cutscene = false
			if callback_fim.is_valid(): callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false
		if callback_fim.is_valid(): callback_fim.call()


# ------------------------------------------------------------
# ARCO 6: FORMIGAS CHIMERA (NGL & O REI MERUEM)
# ------------------------------------------------------------
static func executar_chimera_ant_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene: return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Kite", "texto": "Gon, Killua... se sentirem qualquer presença anormal na floresta de NGL, fujam imediatamente. A Rainha das Formigas Chimera deu à luz a predadores que devoram usuários de Nen."},
			{"falante": "Neferpitou", "texto": "Nya... Minha aura é tão agradável assim? Eu acho que sou muito forte..."},
			{"falante": "Presidente Netero", "texto": "Meruem... Você não sabe nada sobre a malícia infinita que reside no fundo do coração humano. 'Guanyin Bodhisattva de 100 Tipos: Mão Zero'!"},
			{"falante": "Rei Meruem", "texto": "Komugi... você ainda está aí? Segure minha mão... só mais um pouco..."}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.completar_etapa_historia(6)
			em_cutscene = false
			if callback_fim.is_valid(): callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false
		if callback_fim.is_valid(): callback_fim.call()


# ------------------------------------------------------------
# ARCO 7: ELEIÇÃO DO 13º PRESIDENTE HUNTER & ALLUKA
# ------------------------------------------------------------
static func executar_eleicao_hunter_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene: return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Ging Freecss", "texto": "O velho Netero nos deixou uma regra clara: todos os Hunters registrados devem votar para escolher o 13º Presidente. Não venham me encher o saco."},
			{"falante": "Leorio Paradinight", "texto": "Ging! Como você tem coragem de ficar sentado aqui enquanto o Gon está em coma no hospital entre a vida e a morte?! TOMA ESSE SOCO TELEPORTADO!"},
			{"falante": "Killua Zoldyck", "texto": "Nanika... por favor, cure o Gon! Eu prometo que vou te proteger para sempre, Alluka!"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.completar_etapa_historia(7)
			em_cutscene = false
			if callback_fim.is_valid(): callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false
		if callback_fim.is_valid(): callback_fim.call()


# ------------------------------------------------------------
# ARCO 8: EXPEDIÇÃO AO CONTINENTE NEGRO
# ------------------------------------------------------------
static func executar_continente_negro_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene: return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Beyond Netero", "texto": "O mundo conhecido é apenas uma pequena poça dentro do Lago Mobius! Além dos limites repousa o Continente Negro — terra das 5 Grandes Calamidades e dos recursos lendários!"},
			{"falante": "Ging Freecss", "texto": "O segredo de ser Hunter é procurar o que está além do horizonte. Aquilo que você quer não é o objetivo final, mas os companheiros e histórias que encontra pelo caminho."}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.completar_etapa_historia(8)
			em_cutscene = false
			if callback_fim.is_valid(): callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false
		if callback_fim.is_valid(): callback_fim.call()


# ------------------------------------------------------------
# ARCO 9: GUERRA DE SUCESSÃO DE KAKIN & BALEIA NEGRA 1
# ------------------------------------------------------------
static func executar_guerra_sucessao_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if em_cutscene: return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Kurapika", "texto": "O Ritual da Urna Sagrada concedeu Bestas de Nen Parasitárias aos 14 Príncipes de Kakin. A bordo do navio Baleia Negra 1, uma guerra de assassinato e estratégias psicológicas começou."},
			{"falante": "Príncipe Tserriednich", "texto": "Nen... que poder fascinante. Minha Besta Guardiã e meu Hatsu do Futuro Paralelo me tornarão o governante supremo deste mundo."}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.completar_etapa_historia(9)
			em_cutscene = false
			if callback_fim.is_valid(): callback_fim.call()
		, CONNECT_ONE_SHOT)
	else:
		em_cutscene = false
		if callback_fim.is_valid(): callback_fim.call()


# ------------------------------------------------------------
# TOUR DO LOBBY (HUNTER PLAZA)
# ------------------------------------------------------------
static func executar_tour_lobby_cutscene(tree: SceneTree, elena: NPC, _player: CharacterBody2D) -> void:
	if em_cutscene:
		return

	em_cutscene = true
	print("[Cutscene] Iniciando Apresentação e Tour Guiado do Lobby com Recepcionista Elena...")

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui")
	var falas: Array[Dictionary] = [
		{"falante": "Recepcionista Elena", "texto": "Olá, novo Caçador! Seja muito bem-vindo à Capital dos Caçadores (Hunter Plaza)!"},
		{"falante": "Recepcionista Elena", "texto": "Antes de iniciar suas missões, vou apresentar todos os distritos e mestres desta cidade para você!"},
		{"falante": "Recepcionista Elena", "texto": "🏛️ PRAÇA CENTRAL: Aqui ao lado fica a Estátua do Presidente Netero para bênçãos diárias e o Quadro de Procurados."},
		{"falante": "Recepcionista Elena", "texto": "🥋 AO NORTE (Distrito dos Mestres): Mestre Wing (Nen), Zushi, Biscuit Krueger (Hatsu e Juramentos) e o Mestre de Troca de Categoria de Nen!"},
		{"falante": "Recepcionista Elena", "texto": "⚒️ A OESTE (Distrito Comercial): O Ferreiro de Armaduras, o Comerciante de Suprimentos e a sua Casa Pessoal de Caçador."},
		{"falante": "Recepcionista Elena", "texto": "🏯 A LESTE (Distrito Dimensional): A famosa Torre Celestial de 200 andares, o Examinador Chrono (50 Missões Paralelas) e o Santuário de Bestas de Nen!"},
		{"falante": "Recepcionista Elena", "texto": "⛩️ PORTAL HUNTER: E logo a leste fica o Portal Dimensional do Modo História! É lá que você começa sua campanha do 287º Exame Hunter!"},
		{"falante": "Recepcionista Elena", "texto": "Siga a seta guia do GPS até o Portal Hunter a leste para iniciar sua lenda! Boa sorte, Hunter!"}
	]

	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			PlayerData.tour_lobby_concluido = true
			em_cutscene = false
			var hud = tree.get_first_node_in_group("player_hud")
			if hud != null and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("👉 Novo Objetivo: Siga até o Portal Hunter a Leste!")
		, CONNECT_ONE_SHOT)
	else:
		if elena != null and is_instance_valid(elena):
			elena.falar_balao("Bem-vindo à Associação Hunter! Siga até o Portal Hunter a leste para iniciar o Exame Hunter!", 4.5, Color(1.0, 0.85, 0.3, 1.0))
			await tree.create_timer(4.5).timeout
			if is_instance_valid(elena): elena.fechar_balao_atual()
		PlayerData.tour_lobby_concluido = true
		em_cutscene = false


static func forcar_liberacao_cutscene() -> void:
	em_cutscene = false
	print("[StoryCutsceneManager] Estado de cutscene destravado com sucesso.")
