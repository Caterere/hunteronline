extends NPC

# ============================================================
# HUNTER ONLINE - NPC: WING (ARCO 3 — ARENA CELESTIAL)
# ============================================================
#
# Mestre de Nen na Arena Celestial.
# Realiza o secreto Teste da Água (Water Divination Test),
# ensina Ten/Ren e oferece sessões do TrainingSystem.
#
# ============================================================

@export var quest: Quest

var modal_menu: CanvasLayer = null


func _ready() -> void:
	npc_name = "Wing"
	super()


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Wing] Interagindo com Mestre Wing...")
	if QuestSystem != null and QuestSystem.has_method("register_npc_visit"):
		QuestSystem.register_npc_visit(&"wing")

	var falas_wing: Array[Dictionary] = []
	var afinidade_nome: String = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
	var afinidade_desc: String = NenAffinityData.obter_descricao_afinidade(PlayerData.afinidade_nen)

	var etapa_atual: int = PlayerData.etapa_quest_arco if PlayerData != null else 1
	var arco_atual: int = PlayerData.arco_atual if PlayerData != null else 1

	if arco_atual == 3 and etapa_atual == 10:
		falas_wing.append({"falante": "Mestre Wing", "texto": "Para descobrir qual das 6 categorias de Nen você nasceu com, realizaremos o TESTE DA ÁGUA (Water Divination Test)!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Posicione suas mãos ao redor do copo d'água com a folha na mesa logo ao meu lado [E] e libere sua aura!"})
		_exibir_falas(falas_wing)
		return

	elif not PlayerData.despertou_nen or (arco_atual == 3 and etapa_atual == 11):
		PlayerData.despertou_nen = true
		PlayerData.aplicar_nivel_nen(1)
		PlayerData.aplicar_bonuses_afinidade()

		falas_wing.append({"falante": "Mestre Wing", "texto": "Parabéns por realizar o Teste da Água! Sua Afinidade Natal é oficialmente comprovada como: " + afinidade_nome.to_upper() + "!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": afinidade_desc})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Abrirei suavemente seus nós de aura... Sinta a energia fluir sem escapar: você despertou o TEN (Envolver)!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Durante o combate, segure [Q] para Zetsu, Gyo e En — as únicas técnicas ativas. Ten, Ren, Shu, Ko, Ken e Ryu fluem como passivas."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "O Ten envolve seu corpo como um manto protetor, reduzindo drasticamente qualquer impacto recebido."})
		PlayerData.quest_states["wing_tutorial_progresso"] = 2
		# Presente de mestre: amuleto + faixa para o loop de equipamento
		if not PlayerData.tem_item(&"amuleto_forca"):
			PlayerData.adicionar_item(&"amuleto_forca", 1)
		if not PlayerData.tem_item(&"faixa_concentracao"):
			PlayerData.adicionar_item(&"faixa_concentracao", 1)
		if TutorialManager != null and TutorialManager.has_method("disparar_tutorial_contextual"):
			TutorialManager.disparar_tutorial_contextual("nen_despertar")
		if EventBus != null:
			EventBus.emit_toast("🥋 Nen despertado! Itens: Amuleto + Faixa (pressione I).", Color(0.35, 1.0, 0.55))
		if PlayerData != null:
			PlayerData.tour_lobby_concluido = true
		if SaveManager != null:
			SaveManager.salvar_jogo()
		_exibir_falas(falas_wing)
		return

	elif arco_atual == 3 and etapa_atual == 12:
		falas_wing.append({"falante": "Mestre Wing", "texto": "Ten e Ren agora fluem como passivas no seu corpo — não precisa ativá-los. Seu foco ativo é Zetsu, Gyo e En."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Gyo concentra a visão nos pontos de aura. En expande o radar. Zetsu silencia tudo. Use [Q] só para esses três."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Venha treinar comigo quando quiser reforçar a base de forma permanente."})
		_exibir_falas(falas_wing, func(): _abrir_menu_treino())
		return

	_abrir_menu_treino()


func _exibir_falas(falas: Array[Dictionary], ao_fim: Callable = Callable()) -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		visual_dialogue.exibir_sequencia_falas(falas)
		if ao_fim.is_valid():
			visual_dialogue.dialogo_concluido.connect(ao_fim, CONNECT_ONE_SHOT)


func _abrir_menu_treino() -> void:
	if modal_menu != null and is_instance_valid(modal_menu):
		modal_menu.queue_free()

	var ts: TrainingSystem = TrainingSystem.obter_ou_criar(get_tree())
	modal_menu = CanvasLayer.new()
	modal_menu.layer = 25
	modal_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(modal_menu)
	if get_tree() != null:
		get_tree().paused = true

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_menu.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_menu.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 200)
	panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "🥋 MESTRE WING — DOJO"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_font_size_override("font_size", 10)
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vbox.add_child(lbl_titulo)

	var lbl_sub := Label.new()
	lbl_sub.text = "Fundamentos de Nen e condicionamento"
	lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_sub.add_theme_font_size_override("font_size", 8)
	lbl_sub.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_sub)

	var sep := HSeparator.new()
	sep.modulate = HunterUIStyle.COLOR_BORDER_SUBTLE
	vbox.add_child(sep)

	_criar_botao("💬 Conselhos de Nen", vbox, _on_opcao_conversar)

	var treinos: Array[String] = []
	if ts != null:
		treinos = ts.listar_treinos_do_instrutor("wing")
	# Sempre oferecer o treino físico do dojo no hub/arena
	if not treinos.has("fortalecimento_fisico"):
		treinos.append("fortalecimento_fisico")

	for treino_id in treinos:
		var dados: Dictionary = TrainingSystem.CATALOGO_TREINOS.get(treino_id, {})
		var nome: String = str(dados.get("nome", treino_id))
		var ja: bool = ts != null and ts.ja_concluiu_treino(treino_id)
		var label_btn: String = ("✅ " if ja else "🥋 ") + nome
		var tid: String = treino_id
		_criar_botao(label_btn, vbox, func(): _iniciar_treino(tid), ja)

	_criar_botao("❌ Fechar [ESC]", vbox, _fechar_menu)


func _criar_botao(texto: String, parent: Node, callback: Callable, disabled: bool = false) -> Button:
	var btn := Button.new()
	btn.text = texto
	btn.disabled = disabled
	btn.add_theme_font_size_override("font_size", 8)
	btn.custom_minimum_size = Vector2(0, 22)
	HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_GREEN)
	btn.pressed.connect(callback)
	parent.add_child(btn)
	return btn


func _fechar_menu() -> void:
	if modal_menu != null and is_instance_valid(modal_menu):
		modal_menu.queue_free()
		modal_menu = null
	if get_tree() != null:
		get_tree().paused = false


func _on_opcao_conversar() -> void:
	_fechar_menu()
	_exibir_falas([
		{"falante": "Mestre Wing", "texto": "Ativas: Zetsu, Gyo e En — segure [Q]. Ten, Ren, Shu, Ko, Ken e Ryu são passivas (Árvore [N] e combate)."},
		{"falante": "Mestre Wing", "texto": "Equipe uma arma em [I] para o Shu revestir a lâmina. Treine comigo para ganhos permanentes."},
	])


func _iniciar_treino(treino_id: String) -> void:
	_fechar_menu()
	var ts: TrainingSystem = TrainingSystem.obter_ou_criar(get_tree())
	if ts == null:
		return
	var resultado: Dictionary = ts.executar_sessao_treino(treino_id, get_tree())
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		return
	if resultado.get("sucesso", false):
		visual_dialogue.exibir_sequencia_falas([
			{"falante": "Mestre Wing", "texto": "Sessão concluída: %s." % str(resultado.get("treino", ""))},
			{"falante": "Mestre Wing", "texto": "Seu corpo reteve o aprendizado: %s. Isso é permanente." % str(resultado.get("recompensa", ""))},
		])
	else:
		visual_dialogue.exibir_sequencia_falas([
			{"falante": "Mestre Wing", "texto": str(resultado.get("mensagem", "Ainda não é hora deste treino."))},
		])
