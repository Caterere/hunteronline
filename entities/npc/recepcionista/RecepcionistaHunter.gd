class_name RecepcionistaHunterNPC
extends NPC

# ============================================================
# HUNTER ONLINE - NPC: RECEPCIONISTA DA ASSOCIAÇÃO HUNTER
# ============================================================
#
# Instrutora Oficial de Onboarding, Tutorial Guiado e Guia da Cidade.
# Desacoplada: consulta o TutorialManager e atua como voz diegética.
#
# ============================================================


var _interacao_em_processamento: bool = false


func _ready() -> void:
	npc_name = "Recepcionista Elena"
	fala_padrao = "Olá, Hunter! Bem-vindo à Cidade Central da Associação!"
	super()


func _on_interacted(_player: CharacterBody2D) -> void:
	if _interacao_em_processamento:
		return

	QuestSystem.register_npc_visit(&"recepcionista_elena")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")

	# --- 1. MODO TUTORIAL GUIADO ---
	if not PlayerData.tutorial_concluido:
		_processar_interacao_tutorial(visual_dialogue)
		return

	# --- 2. APRESENTAÇÃO DO LOBBY & MODO HISTÓRIA (PORTAL HUNTER) ---
	if not PlayerData.tour_lobby_concluido:
		StoryCutsceneManager.executar_tour_lobby_cutscene(get_tree(), self, _player)
		return

	# --- 3. DIÁLOGO PADRÃO DE SERVIÇO HUNTER ---
	if visual_dialogue != null:
		_interacao_em_processamento = true
		var falas: Array[Dictionary] = [
			{"falante": "Recepcionista Elena", "texto": "Olá novamente, %s! Como vão seus preparativos de Caçador?" % PlayerData.nome_personagem},
			{"falante": "Recepcionista Elena", "texto": "Lembre-se: você pode consultar o Guia Hunter na aba de Conhecimentos do menu [TAB] a qualquer momento!"},
			{"falante": "Recepcionista Elena", "texto": "Para avançar na história principal, dirija-se ao Portal Hunter no Distrito Dimensional a Leste."}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		visual_dialogue.dialogo_concluido.connect(func():
			_interacao_em_processamento = false
		, CONNECT_ONE_SHOT)
	else:
		falar_balao("Boa sorte em sua jornada Hunter!", 3.0, Color(1.0, 0.85, 0.3, 1.0))


func _processar_interacao_tutorial(visual_dialogue: CanvasLayer) -> void:
	if TutorialManager == null:
		return

	if not TutorialManager.em_tutorial:
		TutorialManager.iniciar_tutorial_inicial()

	var etapa = TutorialManager.etapa_atual
	var falas: Array[Dictionary] = TutorialManager.obter_dialogo_elena()
	_interacao_em_processamento = true

	# Watchdog de resiliência: garante destravamento seguro mesmo se a UI falhar
	get_tree().create_timer(4.0).timeout.connect(func():
		_interacao_em_processamento = false
	)

	match etapa:
		TutorialManager.Step.INTRODUCAO:
			if visual_dialogue != null:
				visual_dialogue.exibir_sequencia_falas(falas)
				visual_dialogue.dialogo_concluido.connect(func():
					_interacao_em_processamento = false
					if TutorialManager.em_tutorial and TutorialManager.etapa_atual == TutorialManager.Step.INTRODUCAO:
						TutorialManager.concluir_etapa_atual("Apresentação Elena")
				, CONNECT_ONE_SHOT)
			else:
				_interacao_em_processamento = false
				TutorialManager.concluir_etapa_atual("Apresentação Elena")

		TutorialManager.Step.INTERACAO:
			if visual_dialogue != null:
				visual_dialogue.exibir_sequencia_falas(falas)
				visual_dialogue.dialogo_concluido.connect(func():
					_interacao_em_processamento = false
					if TutorialManager.em_tutorial and TutorialManager.etapa_atual == TutorialManager.Step.INTERACAO:
						TutorialManager.concluir_etapa_atual("Interação Elena")
				, CONNECT_ONE_SHOT)
			else:
				_interacao_em_processamento = false
				TutorialManager.concluir_etapa_atual("Interação Elena")

		TutorialManager.Step.NEN_CONCEITO:
			if visual_dialogue != null:
				visual_dialogue.exibir_sequencia_falas(falas)
				visual_dialogue.dialogo_concluido.connect(func():
					_interacao_em_processamento = false
					if TutorialManager.em_tutorial and TutorialManager.etapa_atual == TutorialManager.Step.NEN_CONCEITO:
						TutorialManager.concluir_etapa_atual("Teoria Nen Elena")
						Economy.adicionar_gold(500)
				, CONNECT_ONE_SHOT)
			else:
				_interacao_em_processamento = false
				TutorialManager.concluir_etapa_atual("Teoria Nen Elena")
				Economy.adicionar_gold(500)

		_:
			# Etapas de Ação do Jogador (Movimento, Menus, Inventário, Combate, Status):
			# Elena fornece lembrete sem prender o jogador em loop
			var lembrete: String = TutorialManager.obter_fala_lembrete_elena()
			if visual_dialogue != null:
				visual_dialogue.exibir_fala("Recepcionista Elena", lembrete)
				visual_dialogue.dialogo_concluido.connect(func():
					_interacao_em_processamento = false
				, CONNECT_ONE_SHOT)
			else:
				_interacao_em_processamento = false
				falar_balao(lembrete, 3.0, Color(1.0, 0.9, 0.4, 1.0))