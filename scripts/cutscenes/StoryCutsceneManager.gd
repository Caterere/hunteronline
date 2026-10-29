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


## Se já há cutscene/runner ativo, invoca callback (fail-open de portal) e retorna true.
static func _ocupado_fail_open(callback_fim: Callable = Callable()) -> bool:
	if not em_cutscene and not CutsceneSequenceRunner.em_execucao:
		return false
	push_warning("[StoryCutsceneManager] Cutscene ocupada — fail-open do callback de portal.")
	if callback_fim.is_valid():
		callback_fim.call()
	return true


static func _iniciar_runner(tree: SceneTree, passos: Array[Dictionary], nome: String, callback_fim: Callable) -> bool:
	var runner = CutsceneSequenceRunner.executar(tree, passos, nome, callback_fim)
	if runner == null:
		# executar recusou — não deixar em_cutscene preso nem portal softlock
		em_cutscene = false
		if callback_fim.is_valid():
			callback_fim.call()
		return false
	return true


static func _conectar_visual_ou_callback(visual_dialogue: Node, falas: Array[Dictionary], ao_fim: Callable) -> void:
	visual_dialogue.exibir_sequencia_falas(falas)
	if visual_dialogue.has_method("when_done"):
		visual_dialogue.when_done(ao_fim)
	else:
		visual_dialogue.dialogo_concluido.connect(ao_fim, CONNECT_ONE_SHOT)


# ------------------------------------------------------------
# ARCO 1: EXAME HUNTER — ENCONTRO DOS 4 AMIGOS NA MARATONA (TÚNEL)
# ------------------------------------------------------------
static func executar_maratona_hunter(tree: SceneTree, gon: NPC, killua: NPC, leorio: NPC, kurapika: NPC, satotz: NPC) -> void:
	if em_cutscene or CutsceneSequenceRunner.em_execucao:
		return

	print("[Cutscene] Iniciando Sequência do Exame Hunter: Encontro dos 4 Amigos...")

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.2, 1.2), "duration": 0.35},
		{"type": CutsceneSequenceRunner.StepType.AUDIO_BGM, "bgm": "hashire"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Gon Freecss (Nº 405)", "text": "Oi! Eu sou o Gon da Ilha da Baleia! Estou fazendo o Exame Hunter para descobrir por que meu pai, o Ging, escolheu ser Hunter acima de tudo!"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Killua Zoldyck (Nº 99)", "text": "Ei, skate não é trapaça! O examinador só mandou segui-lo. Eu sou o Killua... Fugir da minha família de assassinos parecia divertido, mas até agora tá bem fácil."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Leorio Paradinight (Nº 403)", "text": "Ufa... argh... calem a boca, seus moleques cheios de energia! Eu sou o Leorio! Se eu virar Hunter, vou ter dinheiro pra pagar a faculdade de medicina e tratar os doentes de graça!"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Kurapika (Nº 404)", "text": "Eu sou Kurapika, o último sobrevivente do Clã Kurta. Busco a Licença Hunter para caçar a Trupe Fantasma e recuperar os Olhos Escarlates."},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_SHAKE, "intensity": 0.25, "duration": 0.2},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Gon Freecss (Nº 405)", "text": "Nós 4 temos motivos diferentes, mas vamos passar juntos! Olhem — o Examinador Satotz está acelerando! Mantenham o ritmo!"},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_maratona_amigos", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.25},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	_iniciar_runner(tree, passos, "Maratona_Encontro_Amigos", func():
		_mover_amigos_maratona(tree, gon, killua, leorio, kurapika, satotz)
	)

static func _mover_amigos_maratona(tree: SceneTree, gon: NPC, killua: NPC, leorio: NPC, kurapika: NPC, satotz: NPC) -> void:
	if tree == null:
		em_cutscene = false
		return
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
	if tree == null:
		return

	var hud = tree.get_first_node_in_group("player_hud")
	if hud != null and is_instance_valid(hud) and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🏃 Siga o grupo e alcance o Examinador Satotz no fim do túnel!")


# ------------------------------------------------------------
# ARCO 1: ENTRADA NO PANTANAL NUMERE & AMEAÇA DE HISOKA
# ------------------------------------------------------------
static func executar_pantanal_hisoka(tree: SceneTree, satotz: NPC, hisoka: NPC, amigos: Array[NPC]) -> void:
	if em_cutscene or CutsceneSequenceRunner.em_execucao:
		return

	print("[Cutscene] Iniciando Sequência do Pantanal Numere & Hisoka...")

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.2, 1.2), "duration": 0.35},
		{"type": CutsceneSequenceRunner.StepType.AUDIO_BGM, "bgm": "scariness"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinador Satotz", "text": "Parabéns aos que resistiram à maratona. À frente: o Pantanal Numere — o Ninho dos Trapaceiros."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinador Satotz", "text": "O nevoeiro é traiçoeiro. Não se separem de mim sob hipótese alguma!"},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_SHAKE, "intensity": 0.3, "duration": 0.25},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Hisoka", "text": "No meio da névoa, ninguém ouve os gritos dos fracos. Vamos ver quem é digno..."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Kurapika", "text": "A aura daquele homem é assassina. O perigo não vem só das feras!"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Killua Zoldyck", "text": "Gon, vamos na frente! Ficar perto do Hisoka é pedir pra morrer."},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_pantanal_hisoka", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.25},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	_iniciar_runner(tree, passos, "Pantanal_Hisoka", func():
		_dispersar_amigos_pantanal(tree, amigos)
	)


static func _dispersar_amigos_pantanal(tree: SceneTree, amigos: Array[NPC]) -> void:
	if tree == null:
		em_cutscene = false
		return
	var destino_pantanal := Vector2(3400, -700)
	for i in range(amigos.size()):
		var amigo = amigos[i]
		if amigo != null and is_instance_valid(amigo):
			amigo.andar_para(destino_pantanal + Vector2(i * 35 - 50, (i % 2) * 40 - 20), 120.0)

	await tree.create_timer(2.0).timeout
	em_cutscene = false
	if tree == null:
		return

	var hud = tree.get_first_node_in_group("player_hud")
	if hud != null and is_instance_valid(hud) and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚔️ Atravesse o Pantanal Numere e derrote as criaturas do nevoeiro!")


# ------------------------------------------------------------
# ARCO 1: FLORESTA BISKA & HUNTERS GOURMET (MENCHI & BUHARA)
# ------------------------------------------------------------
static func executar_gourmet_menchi_buhara(tree: SceneTree) -> void:
	if em_cutscene or CutsceneSequenceRunner.em_execucao:
		return

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.15, 1.15), "duration": 0.3},
		{"type": CutsceneSequenceRunner.StepType.AUDIO_BGM, "bgm": "the_world_of_adventurers"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinador Buhara", "text": "Boa. Vocês chegaram. Minha prova é simples: carne de Great Stamp, fresca. Sem covardia."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinadora Menchi", "text": "E a minha não perdoa pressa. Respeito ao ingrediente. Precisão. Quem treme na floresta… reprova."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Gon Freecss", "text": "Então caçamos juntos. Killua, você lê o rastro — eu abro caminho!"},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_gourmet_menchi", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.2},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	_iniciar_runner(tree, passos, "Gourmet_Menchi", func():
		var hud = tree.get_first_node_in_group("player_hud") if tree != null else null
		if hud != null and is_instance_valid(hud) and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🐗 Cace o Grande Javali Selvagem (Great Stamp) na Floresta Biska!")
		if PlayerData != null and not PlayerData.tem_item(&"adaga_zaban"):
			PlayerData.adicionar_item(&"adaga_zaban", 1)
			if EventBus != null:
				EventBus.emit_toast("Menchi deixou uma Adaga de Zaban na mesa", Color(1.0, 0.85, 0.35))
	)


# ------------------------------------------------------------
# ARCO 1 PILOTO: VOTAÇÃO MAJORITÁRIA (TRICK TOWER)
# ------------------------------------------------------------
static func executar_votacao_trick_tower(tree: SceneTree) -> void:
	if em_cutscene:
		return
	if StoryManager != null and bool(StoryManager.get_story_flag("cutscene_votacao_trick", false)):
		return
	em_cutscene = true

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.18, 1.18), "duration": 0.3},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Tonpa", "text": "Votação majoritária. Cinco votos. Os prisioneiros não brincam — e eu também não voto por sentimentalismo."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Leorio Paradinight", "text": "Então convença ele. A gente precisa da maioria — não de herói solo."},
		{
			"type": CutsceneSequenceRunner.StepType.CHOICE,
			"choice_id": "votacao_trick_tower",
			"speaker": "Votação",
			"text": "Como você aborda Tonpa?",
			"options": [
				{"id": "argumento_grupo", "text": "Apelar ao grupo: juntos saímos vivos"},
				{"id": "ameaca_leve", "text": "Pressão fria: voto contra e fica pra trás"},
				{"id": "barganha", "text": "Barganha: ajuda agora, dívida depois"},
			],
		},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Tonpa", "text": "…Tsk. Voto com vocês. Não porque confio — porque perder sozinho dói mais."},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_votacao_trick", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.2},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	_iniciar_runner(tree, passos, "Votacao_TrickTower", func():
		if QuestSystem != null and QuestSystem.has_method("register_persuasion"):
			QuestSystem.register_persuasion(&"tonpa")
		if EventBus != null:
			EventBus.emit_toast("Maioria conquistada — avance a torre", Color(0.75, 0.9, 1.0))
	)


# ------------------------------------------------------------
# ARCO 1 PILOTO: EMBARQUE ILHA ZEVIL
# ------------------------------------------------------------
static func executar_zevil_embarque(tree: SceneTree) -> void:
	if em_cutscene:
		return
	if StoryManager != null and bool(StoryManager.get_story_flag("cutscene_zevil_embarque", false)):
		return
	em_cutscene = true

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.2, 1.2), "duration": 0.35},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinador Satotz", "text": "Quarta fase: Ilha Zevil. Cada um recebe um alvo. Roubar a placa — sem anunciar a caçada ao mundo inteiro."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinador Satotz", "text": "Inspecione sua placa antes de desembarcar. Quem corre cego vira presa de quem observa."},
		{
			"type": CutsceneSequenceRunner.StepType.CHOICE,
			"choice_id": "zevil_estilo_caca",
			"speaker": "Estilo de caça",
			"text": "Como pretende jogar em Zevil?",
			"options": [
				{"id": "furtivo", "text": "Furtivo — observar antes de agir"},
				{"id": "direto", "text": "Direto — pressionar o alvo cedo"},
				{"id": "suporte", "text": "Suporte — proteger aliados e placas"},
			],
		},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_zevil_embarque", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.2},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	CutsceneSequenceRunner.executar(tree, passos, "Zevil_Embarque", func():
		em_cutscene = false
		if EventBus != null:
			EventBus.emit_toast("Inspecione a placa-alvo (GPS) antes da caçada", Color(0.85, 0.75, 1.0))
	)


# ------------------------------------------------------------
# ARCO 1: CLÍMAX & CONCLUSÃO DA 1ª FASE DO EXAME
# ------------------------------------------------------------
static func executar_conclusao_exame_hunter(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return

	print("[Cutscene] Conclusão da 1ª Fase do 287º Exame Hunter...")

	if QuestSystem != null:
		QuestSystem.register_npc_visit(&"satotz")

	# completar_etapa_historia → concluir_saga: só no FIM da cutscene (junto da
	# troca de cena), não no início — evita race com quest sync mid-cutscene.

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.2, 1.2), "duration": 0.35},
		{"type": CutsceneSequenceRunner.StepType.AUDIO_BGM, "bgm": "hashire"},
		{"type": CutsceneSequenceRunner.StepType.EFFECT_FX, "effect": "flash"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinador Satotz", "text": "Candidatos sobreviventes! Pantanal Numere e Floresta Biska foram superados!"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinador Satotz", "text": "Declaro ENCERRADA a 1ª Fase do 287º Exame Hunter. Resistência, técnica e determinação — comprovadas."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Gon Freecss", "text": "Passamos juntos! Mas... onde está o Killua? Ele disse que precisava voltar para casa..."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Kurapika", "text": "A família Zoldyck. A propriedade fica no pico da Montanha Kukuroo."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Leorio Paradinight", "text": "Não vamos deixar nosso amigo! Rumo a Kukuroo — abrimos aqueles portões!"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Examinador Satotz", "text": "O caminho está aberto. A verdadeira provação dos Caçadores apenas começa."},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_conclusao_exame", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.25},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	_iniciar_runner(tree, passos, "Conclusao_Exame", func():
		if PlayerData != null:
			PlayerData.completar_etapa_historia(1)
		var hud = tree.get_first_node_in_group("player_hud") if tree != null else null
		if hud != null and is_instance_valid(hud) and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏆 1ª FASE CONCLUÍDA! Rumo à Montanha Kukuroo!")
		# Licença parcial / gear de marco
		if PlayerData != null and not PlayerData.tem_item(&"colete_cacador"):
			PlayerData.adicionar_item(&"colete_cacador", 1)
			if EventBus != null:
				EventBus.emit_toast("🦺 Associação entregou: Colete de Caçador", Color(0.55, 0.95, 0.55))
		if callback_fim.is_valid():
			callback_fim.call()
	)


# ------------------------------------------------------------
# ARCO 2: MONTANHA KUKUROO (OS ASSASSINOS ZOLDYCK)
# ------------------------------------------------------------
static func executar_montanha_kukuroo_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.25, 1.25), "duration": 0.4},
		{"type": CutsceneSequenceRunner.StepType.AUDIO_BGM, "bgm": "kingdom_of_predators"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Guarda Zebro", "text": "Bem-vindos aos portões da família Zoldyck. Qualquer um que entrar pela porta lateral será devorado vivo pelo cão de guarda Mike."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Guarda Zebro", "text": "Se querem ver o jovem mestre Killua como amigos, precisam empurrar o Portão da Testagem. Cada folha pesa 2 toneladas — 4 toneladas no 1º portão!"},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_SHAKE, "intensity": 0.45, "duration": 0.35},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Gon Freecss", "text": "Nós vamos treinar com os pesos de vocês e empurrar esse portão com nossas próprias mãos!"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Mordoma Canary", "text": "...Vocês realmente são amigos do jovem Killua? Ele nunca teve ninguém para chamá-lo pelo nome sem medo... Por favor, salvem o jovem mestre da escuridão."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Silva Zoldyck", "text": "Killua... vá com seus amigos. Mas lembre-se do nosso pacto: 'Nunca traia seus companheiros'. E você sempre será meu filho... um assassino Zoldyck."},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_kukuroo_portao", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.3},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	_iniciar_runner(tree, passos, "Kukuroo_Portao", func():
		if PlayerData != null:
			PlayerData.completar_etapa_historia(2)
		if callback_fim.is_valid():
			callback_fim.call()
	)

# ------------------------------------------------------------
# ARCO 3 PILOTO: PRINCÍPIOS DE NEN (WING)
# ------------------------------------------------------------
static func executar_wing_principios_nen(tree: SceneTree) -> void:
	if em_cutscene:
		return
	if StoryManager != null and bool(StoryManager.get_story_flag("cutscene_wing_principios", false)):
		return
	em_cutscene = true

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.25, 1.25), "duration": 0.35},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Mestre Wing", "text": "Quatro princípios antes de qualquer Hatsu: Ten envolve, Zetsu silencia, Ren expande, Hatsu libera."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Mestre Wing", "text": "Ordem no dojo: Tatame (Ren) → Corredor Zetsu → Pista Gyo no 190. Sem pular."},
		{
			"type": CutsceneSequenceRunner.StepType.CHOICE,
			"choice_id": "wing_foco_treino",
			"speaker": "Foco do treino",
			"text": "O que priorizar nas próximas horas?",
			"options": [
				{"id": "ten_base", "text": "Ten — manto estável primeiro"},
				{"id": "zetsu_furtivo", "text": "Zetsu — sumir e regenerar"},
				{"id": "gyo_leitura", "text": "Gyo — ler o que os outros escondem"},
			],
		},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_wing_principios", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.2},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	CutsceneSequenceRunner.executar(tree, passos, "Wing_Principios_Nen", func():
		em_cutscene = false
		if EventBus != null:
			EventBus.emit_toast("Dojo Wing: Ren → Zetsu → Gyo (GPS)", Color(0.55, 0.95, 0.75))
	)


# ------------------------------------------------------------
# ARCO 3: ARENA CELESTIAL & O DESPERTAR DO NEN
# ------------------------------------------------------------
static func executar_arena_celestial_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.3, 1.3), "duration": 0.4},
		{"type": CutsceneSequenceRunner.StepType.AUDIO_BGM, "bgm": "legend_of_the_martial_artist"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Mestre Wing", "text": "Escutem bem. O que vocês sentiram no corredor do 200º andar foi Hatsu carregado de intenção assassina."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Mestre Wing", "text": "Sem proteção, seus corpos seriam despedaçados pela pressão de aura. É hora de despertar seus nós de Nen através do Ten!"},
		{"type": CutsceneSequenceRunner.StepType.EFFECT_FX, "effect": "flash"},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Zushi", "text": "Osu! Os 4 Grandes Princípios: Ten (Envolver), Zetsu (Silenciar), Ren (Expandir) e Hatsu (Liberar)!"},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_SHAKE, "intensity": 0.3, "duration": 0.25},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Hisoka", "text": "Finalmente vocês aprenderam a enxergar a aura com Gyo. Agora a luta pelo 200º andar será deliciosa..."},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_arena_despertar", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.3},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	_iniciar_runner(tree, passos, "Arena_Despertar_Nen", func():
		if PlayerData != null:
			PlayerData.completar_etapa_historia(3)
		if callback_fim.is_valid():
			callback_fim.call()
	)

# ------------------------------------------------------------
# ARCO 6 PILOTO: HORA ZERO / INVASÃO NGL
# ------------------------------------------------------------
static func executar_ngl_hora_zero(tree: SceneTree) -> void:
	if em_cutscene:
		return
	if StoryManager != null and bool(StoryManager.get_story_flag("cutscene_ngl_hora_zero", false)):
		return
	em_cutscene = true

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.25, 1.25), "duration": 0.35},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Morel Mackernasey", "text": "Hora Zero. Portas do Knov abertas. Sem heroísmo solo — um objetivo de cada vez."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Isaac Netero", "text": "Escadaria, Youpi, tumba. A Rosa espera no fim. Não rush."},
		{
			"type": CutsceneSequenceRunner.StepType.CHOICE,
			"choice_id": "ngl_foco_invasao",
			"speaker": "Foco da invasão",
			"text": "Onde concentrar a equipe?",
			"options": [
				{"id": "escadaria", "text": "Escadaria — isolar Youpi"},
				{"id": "fumo", "text": "Fumaça — Deep Purple no corredor"},
				{"id": "tumba", "text": "Tumba — caminho de Netero"},
			],
		},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_ngl_hora_zero", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.2},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	CutsceneSequenceRunner.executar(tree, passos, "NGL_Hora_Zero", func():
		em_cutscene = false
		if EventBus != null:
			EventBus.emit_toast("NGL: Escadaria → Corredor → Tumba (GPS)", Color(0.95, 0.45, 0.35))
	)


# ------------------------------------------------------------
# ARCO 4: YORKNEW CITY & A TRUPE FANTASMA (GENEI RYODAN)
# ------------------------------------------------------------
static func executar_yorknew_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui") if tree != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Kurapika", "texto": "Minhas correntes foram forjadas sob um Juramento de Sangue (Vow & Limitation). A Corrente do Julgamento só pode ser usada contra os 13 membros da Trupe Fantasma."},
			{"falante": "Kurapika", "texto": "Se eu violar essa regra contra qualquer outra pessoa, a lâmina de Nen perfurará meu próprio coração instantaneamente."},
			{"falante": "Chrollo Lucilfer", "texto": "A Aranha não morrerá mesmo se a cabeça for decepada. Nossos membros continuarão marchando... Uvogin, toque o Réquiem que preparamos para você."},
			{"falante": "Gon Freecss", "texto": "Kurapika! Nós não vamos deixar você carregar o peso dessa escuridão sozinho!"}
		]
		_conectar_visual_ou_callback(visual_dialogue, falas, func():
			if PlayerData != null:
				PlayerData.completar_etapa_historia(4)
			em_cutscene = false
			if callback_fim.is_valid():
				callback_fim.call()
		)
	else:
		em_cutscene = false
		if callback_fim.is_valid():
			callback_fim.call()


# ------------------------------------------------------------
# ARCO 5 PILOTO: BISCUIT — KO SOB PRESSÃO
# ------------------------------------------------------------
static func executar_biscuit_pressao_ko(tree: SceneTree) -> void:
	if em_cutscene:
		return
	if StoryManager != null and bool(StoryManager.get_story_flag("cutscene_biscuit_ko", false)):
		return
	em_cutscene = true

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.2, 1.2), "duration": 0.3},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Biscuit Krueger", "text": "Ko não é força bruta — é recusa de desperdiçar um único fio de aura."},
		{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Biscuit Krueger", "text": "Desfiladeiro → Colinas Shu → Trace Ken → Quiz Ryu. Um de cada vez. Sem Bomber ainda."},
		{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "cutscene_biscuit_ko", "value": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.2},
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false},
	]

	CutsceneSequenceRunner.executar(tree, passos, "Biscuit_Pressao_Ko", func():
		em_cutscene = false
		if EventBus != null:
			EventBus.emit_toast("GI: Ko → Shu → Ken → Ryu (GPS)", Color(0.95, 0.75, 0.4))
	)


# ------------------------------------------------------------
# ARCO 5: GREED ISLAND & O TREINO DE BISCUIT KRUEGER
# ------------------------------------------------------------
static func executar_greed_island_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui") if tree != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Biscuit Krueger", "texto": "Parem de choramingar! Vocês dois são diamantes brutos, mas as técnicas de combate de vocês estão cheias de frestas!"},
			{"falante": "Biscuit Krueger", "texto": "Vamos treinar 'Ken' e 'Ryu' escavando rochas e mantendo 80% de aura nos punhos enquanto desviam de projéteis em alta velocidade!"},
			{"falante": "Razor (Game Master)", "texto": "Ging me disse que um dia o filho dele viria até aqui... Preparem-se para receber meu saque com 100% de Nen na quadra de queimada!"},
			{"falante": "Genthru (O Bomber)", "texto": "Liberem as cartas de feitiço número 000 a 099 ou transformarei todos vocês em cinzas com o 'Little Flower'!"}
		]
		_conectar_visual_ou_callback(visual_dialogue, falas, func():
			if PlayerData != null:
				PlayerData.desbloquear_hatsu_creator()
				PlayerData.completar_etapa_historia(5)
			em_cutscene = false
			if callback_fim.is_valid():
				callback_fim.call()
		)
	else:
		em_cutscene = false
		if callback_fim.is_valid():
			callback_fim.call()


# ------------------------------------------------------------
# ARCO 6: FORMIGAS CHIMERA (NGL & O REI MERUEM)
# ------------------------------------------------------------
static func executar_chimera_ant_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui") if tree != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Kite", "texto": "Gon, Killua... se sentirem qualquer presença anormal na floresta de NGL, fujam imediatamente. A Rainha das Formigas Chimera deu à luz a predadores que devoram usuários de Nen."},
			{"falante": "Neferpitou", "texto": "Nya... Minha aura é tão agradável assim? Eu acho que sou muito forte..."},
			{"falante": "Presidente Netero", "texto": "Meruem... Você não sabe nada sobre a malícia infinita que reside no fundo do coração humano. 'Guanyin Bodhisattva de 100 Tipos: Mão Zero'!"},
			{"falante": "Rei Meruem", "texto": "Komugi... você ainda está aí? Segure minha mão... só mais um pouco..."}
		]
		_conectar_visual_ou_callback(visual_dialogue, falas, func():
			if PlayerData != null:
				PlayerData.completar_etapa_historia(6)
			em_cutscene = false
			if callback_fim.is_valid():
				callback_fim.call()
		)
	else:
		em_cutscene = false
		if callback_fim.is_valid():
			callback_fim.call()


# ------------------------------------------------------------
# ARCO 7: ELEIÇÃO DO 13º PRESIDENTE HUNTER & ALLUKA
# ------------------------------------------------------------
static func executar_eleicao_hunter_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui") if tree != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Ging Freecss", "texto": "O velho Netero nos deixou uma regra clara: todos os Hunters registrados devem votar para escolher o 13º Presidente. Não venham me encher o saco."},
			{"falante": "Leorio Paradinight", "texto": "Ging! Como você tem coragem de ficar sentado aqui enquanto o Gon está em coma no hospital entre a vida e a morte?! TOMA ESSE SOCO TELEPORTADO!"},
			{"falante": "Killua Zoldyck", "texto": "Nanika... por favor, cure o Gon! Eu prometo que vou te proteger para sempre, Alluka!"}
		]
		_conectar_visual_ou_callback(visual_dialogue, falas, func():
			if PlayerData != null:
				PlayerData.completar_etapa_historia(7)
			em_cutscene = false
			if callback_fim.is_valid():
				callback_fim.call()
		)
	else:
		em_cutscene = false
		if callback_fim.is_valid():
			callback_fim.call()


# ------------------------------------------------------------
# ARCO 8: EXPEDIÇÃO AO CONTINENTE NEGRO
# ------------------------------------------------------------
static func executar_continente_negro_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui") if tree != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Beyond Netero", "texto": "O mundo conhecido é apenas uma pequena poça dentro do Lago Mobius! Além dos limites repousa o Continente Negro — terra das 5 Grandes Calamidades e dos recursos lendários!"},
			{"falante": "Ging Freecss", "texto": "O segredo de ser Hunter é procurar o que está além do horizonte. Aquilo que você quer não é o objetivo final, mas os companheiros e histórias que encontra pelo caminho."}
		]
		_conectar_visual_ou_callback(visual_dialogue, falas, func():
			if PlayerData != null:
				PlayerData.completar_etapa_historia(8)
			em_cutscene = false
			if callback_fim.is_valid():
				callback_fim.call()
		)
	else:
		em_cutscene = false
		if callback_fim.is_valid():
			callback_fim.call()


# ------------------------------------------------------------
# ARCO 9: GUERRA DE SUCESSÃO DE KAKIN & BALEIA NEGRA 1
# ------------------------------------------------------------
static func executar_guerra_sucessao_cutscene(tree: SceneTree, callback_fim: Callable = Callable()) -> void:
	if _ocupado_fail_open(callback_fim):
		return
	em_cutscene = true

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui") if tree != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Kurapika", "texto": "O Ritual da Urna Sagrada concedeu Bestas de Nen Parasitárias aos 14 Príncipes de Kakin. A bordo do navio Baleia Negra 1, uma guerra de assassinato e estratégias psicológicas começou."},
			{"falante": "Príncipe Tserriednich", "texto": "Nen... que poder fascinante. Minha Besta Guardiã e meu Hatsu do Futuro Paralelo me tornarão o governante supremo deste mundo."}
		]
		_conectar_visual_ou_callback(visual_dialogue, falas, func():
			if PlayerData != null:
				PlayerData.completar_etapa_historia(9)
			em_cutscene = false
			if callback_fim.is_valid():
				callback_fim.call()
		)
	else:
		em_cutscene = false
		if callback_fim.is_valid():
			callback_fim.call()


# ------------------------------------------------------------
# TOUR DO LOBBY (HUNTER PLAZA)
# ------------------------------------------------------------
static func executar_tour_lobby_cutscene(tree: SceneTree, elena: NPC, _player: CharacterBody2D) -> void:
	if em_cutscene:
		return

	em_cutscene = true
	print("[Cutscene] Iniciando Apresentação e Tour Guiado do Lobby com Recepcionista Elena...")

	var visual_dialogue = tree.get_first_node_in_group("visual_dialogue_ui") if tree != null else null
	var falas: Array[Dictionary] = [
		{"falante": "Recepcionista Elena", "texto": "Olá, novo Caçador! Seja muito bem-vindo à Capital dos Caçadores (Hunter Plaza)!"},
		{"falante": "Recepcionista Elena", "texto": "Antes de iniciar suas missões, vou apresentar os distritos — e o primeiro passo obrigatório: despertar seu Nen!"},
		{"falante": "Recepcionista Elena", "texto": "🥋 AO NORTE (Distrito dos Mestres): Vá falar com Mestre Wing AGORA. Ele abre seus nós de aura e ensina Ten. Sem isso, o resto fica incompleto."},
		{"falante": "Recepcionista Elena", "texto": "🏛️ PRAÇA CENTRAL: Estátua do Presidente Netero (bênçãos) e o Quadro de Procurados."},
		{"falante": "Recepcionista Elena", "texto": "⚒️ A OESTE (Distrito Comercial): Ferreiro, Comerciante e sua Casa Pessoal."},
		{"falante": "Recepcionista Elena", "texto": "🏯 A LESTE: Torre Celestial e Examinador Chrono. A história continua com o Guia da História na praça."},
		{"falante": "Recepcionista Elena", "texto": "🍪 Biscuit Krueger (Hatsu/Juramentos) só libera forja de Hatsu mais adiante na saga — não no início."},
		{"falante": "Recepcionista Elena", "texto": "👉 GPS: primeiro Mestre Wing (norte). Depois do despertar, fale com o Guia da História na praça. Boa sorte!"}
	]

	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		_conectar_visual_ou_callback(visual_dialogue, falas, func():
			if PlayerData != null:
				PlayerData.tour_lobby_concluido = true
			em_cutscene = false
			var hud = tree.get_first_node_in_group("player_hud") if tree != null else null
			if hud != null and is_instance_valid(hud) and hud.has_method("exibir_notificacao"):
				if PlayerData != null and not PlayerData.despertou_nen:
					hud.exibir_notificacao("👉 Novo Objetivo: Fale com Mestre Wing ao norte!")
				else:
					hud.exibir_notificacao("👉 Novo Objetivo: Fale com o Guia da História na praça!")
		)
	else:
		if elena != null and is_instance_valid(elena):
			elena.falar_balao("Vá ao norte: fale com Mestre Wing para despertar seu Nen!", 4.5, Color(0.35, 1.0, 0.55, 1.0))
			if tree != null:
				await tree.create_timer(4.5).timeout
			if is_instance_valid(elena):
				elena.fechar_balao_atual()
		if PlayerData != null:
			PlayerData.tour_lobby_concluido = true
		em_cutscene = false


static func forcar_liberacao_cutscene() -> void:
	em_cutscene = false
	CutsceneSequenceRunner.em_execucao = false
	CutsceneSequenceRunner.runner_ativo = null
	print("[StoryCutsceneManager] Estado de cutscene destravado com sucesso.")
