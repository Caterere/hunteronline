extends NPC

# ============================================================
# HUNTER ONLINE - NPC: BISCUIT KRUEGER (ARCO 5 — GREED ISLAND)
# ============================================================
#
# Mestra de Hatsu de Shingen-ryu.
# Desbloqueia e gerencia a criação de Hatsu para o jogador
# exclusivamente após a conclusão da Saga de Greed Island.
#
# ============================================================

@export var quest: Quest

var modal_menu: CanvasLayer = null


func _ready() -> void:
	super()
	npc_name = "Biscuit"
	if quest == null:
		quest = load("res://data/quests/arco5_treino_biscuit.tres") as Quest


func _on_interacted(_player: CharacterBody2D) -> void:
	if QuestSystem != null and QuestSystem.has_method("register_npc_visit"):
		QuestSystem.register_npc_visit(&"biscuit")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")

	# CASO 1: Jogador ainda nem despertou Nen
	if PlayerData == null or not PlayerData.despertou_nen:
		if visual_dialogue != null:
			visual_dialogue.exibir_sequencia_falas([
				{"falante": "Biscuit Krueger", "texto": "Ora ora! Vejo que você ainda nem despertou seus nós de Nen!"},
				{"falante": "Biscuit Krueger", "texto": "🔒 REQUISITO: Vá falar primeiro com o Mestre Wing na Arena Celestial para realizar o Teste da Água e aprender os fundamentos (Ten e Ren) antes de vir treinar comigo!"}
			])
		return

	# CASO 2: Verificar se o Hatsu Slot 1 já está desbloqueado
	var slot1_desbloqueado: bool = false
	if HatsuProgressionManager != null:
		slot1_desbloqueado = HatsuProgressionManager.is_slot_unlocked(1)
	else:
		slot1_desbloqueado = PlayerData.hatsu_creation_unlocked or PlayerData.hatsu_desbloqueado

	if not slot1_desbloqueado:
		# Checar se cumpriu os requisitos de Greed Island
		var pode_desbloquear: bool = false
		if HatsuProgressionManager != null:
			var check: Dictionary = HatsuProgressionManager.can_unlock_slot(1)
			pode_desbloquear = check.get("can_unlock", false)
		else:
			pode_desbloquear = PlayerData.is_greed_island_concluida()

		if not pode_desbloquear:
			if visual_dialogue != null:
				visual_dialogue.exibir_sequencia_falas([
					{"falante": "Biscuit Krueger", "texto": "Ora ora! Vejo que você já conhece os fundamentos de Nen, mas ainda é como uma pedra bruta precisando de lapidação!"},
					{"falante": "Biscuit Krueger", "texto": "🔒 REQUISITO: Complete a Saga de Greed Island (Arco 5) e supere as provações para iniciar o treinamento avançado e desbloquear seu Hatsu Slot 1 comigo!"}
				])
			return

		# Cumpriu Greed Island -> Iniciação da Mestra Biscuit e Desbloqueio do Slot 1
		if HatsuProgressionManager != null:
			HatsuProgressionManager.unlock_slot(1)
		else:
			PlayerData.desbloquear_hatsu_creator()

		if visual_dialogue != null:
			visual_dialogue.exibir_sequencia_falas([
				{"falante": "Biscuit Krueger", "texto": "Excelente! Você sobreviveu e completou Greed Island! Sua aura foi forjada no calor das batalhas reais."},
				{"falante": "Biscuit Krueger", "texto": "Você provou que está pronto para manifestar sua individualidade através do Nen. Hatsu Slot 1 DESBLOQUEADO!"}
			])

	_abrir_menu_interacao()


func _abrir_menu_interacao() -> void:
	if modal_menu != null and is_instance_valid(modal_menu):
		modal_menu.queue_free()

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
	panel.custom_minimum_size = Vector2(280, 190)
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

	# Cabeçalho
	var lbl_titulo := Label.new()
	lbl_titulo.text = "🥋 BISCUIT KRUEGER — MESTRA DE NEN"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_font_size_override("font_size", 10)
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_titulo.add_theme_color_override("font_shadow_color", Color.BLACK)
	vbox.add_child(lbl_titulo)

	var lbl_sub := Label.new()
	lbl_sub.text = "Mestra de Shingen-ryu (Greed Island)"
	lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_sub.add_theme_font_size_override("font_size", 8)
	lbl_sub.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_sub)

	var sep := HSeparator.new()
	sep.modulate = HunterUIStyle.COLOR_BORDER_SUBTLE
	vbox.add_child(sep)

	# Botões de Opção
	_criar_botao("💬 Conversar (Filosofia de Nen)", vbox, _on_opcao_conversar)
	_criar_botao("🥋 Treinar (Fundamentos de Ken & Ryu)", vbox, _on_opcao_treinar)
	_criar_botao("✨ Aprender / Criar Hatsu", vbox, _on_opcao_criar_hatsu)
	_criar_botao("❌ Fechar [ESC]", vbox, _fechar_menu_interacao)


func _criar_botao(texto: String, parent: Node, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = texto
	btn.add_theme_font_size_override("font_size", 8)
	btn.custom_minimum_size = Vector2(0, 22)
	HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_GREEN)
	btn.pressed.connect(callback)
	parent.add_child(btn)
	return btn


func _fechar_menu_interacao() -> void:
	if modal_menu != null and is_instance_valid(modal_menu):
		modal_menu.queue_free()
		modal_menu = null
	if get_tree() != null:
		get_tree().paused = false


func _on_opcao_conversar() -> void:
	_fechar_menu_interacao()
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui") if get_tree() != null else null
	if visual_dialogue != null:
		visual_dialogue.exibir_sequencia_falas([
			{"falante": "Biscuit Krueger", "texto": "O Hatsu reflete sua alma e seus desejos mais profundos. Não copie outros Hunters, forje algo que ressoe com seu espírito e com sua afinidade natal!"},
			{"falante": "Biscuit Krueger", "texto": "Lembre-se: quanto mais severas forem suas restrições e juramentos de Nen (Vows), mais avassalador será o seu poder em combate!"}
		])


func _on_opcao_treinar() -> void:
	_fechar_menu_interacao()
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui") if get_tree() != null else null
	if visual_dialogue != null:
		visual_dialogue.exibir_sequencia_falas([
			{"falante": "Biscuit Krueger", "texto": "Ken e Ryu são os pilares para sustentar seu Hatsu em combate!"},
			{"falante": "Biscuit Krueger", "texto": "Ken é a união perfeita de Ten e Ren ao redor de todo o corpo para defesa máxima. Ryu é a distribuição percentual instantânea de aura (como 70% no ataque e 30% na defesa). Pratique sempre!"}
		])


func _on_opcao_criar_hatsu() -> void:
	_fechar_menu_interacao()
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui") if get_tree() != null else null
	if visual_dialogue != null:
		visual_dialogue.exibir_sequencia_falas([
			{"falante": "Biscuit Krueger", "texto": "Então você finalmente está pronto para começar a desenvolver seu próprio Hatsu. Vamos forjar sua técnica definitiva!"}
		])
		await visual_dialogue.dialogo_concluido

	_abrir_hatsu_creator()


func _abrir_hatsu_creator() -> void:
	print("[BISCUIT] Opening Hatsu Creator")
	var root_node = get_tree().root if get_tree() != null else null
	var creation_ui: HatsuCreationUI = null

	if root_node != null:
		creation_ui = root_node.get_node_or_null("HatsuCreationUI") as HatsuCreationUI

	if creation_ui == null:
		creation_ui = get_node_or_null("HatsuCreationUI") as HatsuCreationUI

	if creation_ui == null:
		var scn_creation = load("res://ui/Hatsu/HatsuCreationUI.gd")
		if scn_creation:
			creation_ui = scn_creation.new()
			creation_ui.name = "HatsuCreationUI"
			add_child(creation_ui)

	if creation_ui != null and creation_ui.has_method("abrir"):
		creation_ui.abrir()
