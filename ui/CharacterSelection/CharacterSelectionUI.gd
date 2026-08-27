class_name CharacterSelectionUI
extends Control

signal personagem_selecionado

# ============================================================
# HUNTER ONLINE - CHARACTER SELECTION & CREATION UI (3 SLOTS)
# ============================================================
#
# Menu inicial de seleção de personagem (3 slots de save).
# Permite criar novos personagens com nome e Afinidade Natal de Nen.
# Resolução nativa 320x180 (pixel art).
#
# ============================================================

# Painéis
var panel_slots: VBoxContainer
var panel_criacao: PanelContainer

# Sub-elementos de Criação
var slot_criacao_atual: int = 1
var line_edit_nome: LineEdit
var picker_cabelo: ColorPickerButton
var picker_roupa: ColorPickerButton
var lbl_afinidade_nome: Label
var lbl_afinidade_desc: Label

var afinidade_sorteada: NenAffinityData.CategoriaAfinidade = NenAffinityData.CategoriaAfinidade.INTENSIFICACAO
var _ja_carregando: bool = false


func _ready() -> void:
	_ja_carregando = false
	if PlayerData != null:
		PlayerData.is_character_ready = false
	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.SAVE_SELECT)
		GameManager.change_state(GameManager.GameState.MAIN_MENU)
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null:
		input_ctx.set_context("CHARACTER_CREATION")
	if AudioManager != null:
		AudioManager.tocar_musica("the_world_of_adventurers")
	_construir_ui()
	_atualizar_slots()


func _construir_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Fundo
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.08, 0.12, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)
	
	var vbox_main := VBoxContainer.new()
	vbox_main.add_theme_constant_override("separation", 4)
	margin.add_child(vbox_main)
	
	# Cabeçalho
	var hbox_hdr := HBoxContainer.new()
	vbox_main.add_child(hbox_hdr)
	
	var lbl_titulo := Label.new()
	lbl_titulo.text = "HUNTER ONLINE — SELEÇÃO DE SLOTS"
	lbl_titulo.add_theme_font_size_override("font_size", 8)
	lbl_titulo.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
	lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox_hdr.add_child(lbl_titulo)
	
	var btn_dev_lvl100 := Button.new()
	btn_dev_lvl100.text = "⚡ Gerar Save Lvl 100 (Slot 3)"
	btn_dev_lvl100.add_theme_font_size_override("font_size", 5)
	btn_dev_lvl100.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
	btn_dev_lvl100.pressed.connect(_gerar_save_teste_lvl100)
	hbox_hdr.add_child(btn_dev_lvl100)
	
	# Conteúdo dos 3 Slots
	panel_slots = VBoxContainer.new()
	panel_slots.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_slots.add_theme_constant_override("separation", 3)
	vbox_main.add_child(panel_slots)
	
	# Painel de Criação (oculto por padrão)
	_construir_painel_criacao()


func _construir_painel_criacao() -> void:
	panel_criacao = PanelContainer.new()
	panel_criacao.custom_minimum_size = Vector2(230, 150)
	panel_criacao.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_criacao.visible = false
	panel_criacao.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_AURA_CYAN, 4))
	add_child(panel_criacao)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_criacao.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)
	
	var lbl_cria_title := Label.new()
	lbl_cria_title.text = "CRIAR NOVO PERSONAGEM"
	lbl_cria_title.add_theme_font_size_override("font_size", 7)
	lbl_cria_title.add_theme_color_override("font_color", Color(0.3, 0.8, 1, 1))
	lbl_cria_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_cria_title)
	
	line_edit_nome = LineEdit.new()
	line_edit_nome.placeholder_text = "Digite seu Nome Hunter..."
	line_edit_nome.add_theme_font_size_override("font_size", 5)
	line_edit_nome.alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(line_edit_nome)
	
	# Mensagem Secreta sobre a Natureza de Nen
	lbl_afinidade_nome = Label.new()
	lbl_afinidade_nome.text = "🧪 Teste da Água: Oculto"
	lbl_afinidade_nome.add_theme_font_size_override("font_size", 6)
	lbl_afinidade_nome.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	lbl_afinidade_nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_afinidade_nome)
	
	lbl_afinidade_desc = Label.new()
	lbl_afinidade_desc.text = "Sua afinidade natal de Nen é secreta! Você só descobrirá sua verdadeira natureza durante o Teste da Água com o Mestre Wing na Arena Celestial."
	lbl_afinidade_desc.add_theme_font_size_override("font_size", 4)
	lbl_afinidade_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_afinidade_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_afinidade_desc)
	
	# Personalização de Cores (Cabelo e Roupa)
	var hbox_custom := HBoxContainer.new()
	hbox_custom.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox_custom)

	var lbl_cab := Label.new()
	lbl_cab.text = "Cabelo:"
	lbl_cab.add_theme_font_size_override("font_size", 5)
	hbox_custom.add_child(lbl_cab)

	picker_cabelo = ColorPickerButton.new()
	picker_cabelo.custom_minimum_size = Vector2(24, 14)
	picker_cabelo.color = Color(0.15, 0.15, 0.15, 1.0) # Preto
	hbox_custom.add_child(picker_cabelo)

	var spacer_c := Control.new()
	spacer_c.custom_minimum_size = Vector2(12, 0)
	hbox_custom.add_child(spacer_c)

	var lbl_rop := Label.new()
	lbl_rop.text = "Roupa:"
	lbl_rop.add_theme_font_size_override("font_size", 5)
	hbox_custom.add_child(lbl_rop)

	picker_roupa = ColorPickerButton.new()
	picker_roupa.custom_minimum_size = Vector2(24, 14)
	picker_roupa.color = Color(0.2, 0.6, 0.3, 1.0) # Verde Hunter
	hbox_custom.add_child(picker_roupa)

	var hbox_btns := HBoxContainer.new()
	vbox.add_child(hbox_btns)
	
	var btn_cancelar := Button.new()
	btn_cancelar.text = "Cancelar"
	btn_cancelar.add_theme_font_size_override("font_size", 5)
	btn_cancelar.pressed.connect(func():
		panel_criacao.visible = false
		if GameManager != null:
			GameManager.set_flow_state(GameManager.GameFlowState.SAVE_SELECT)
			GameManager.change_state(GameManager.GameState.MAIN_MENU)
	)
	hbox_btns.add_child(btn_cancelar)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_btns.add_child(spacer)
	
	var btn_confirmar := Button.new()
	btn_confirmar.text = "CRIAR E JOGAR!"
	btn_confirmar.add_theme_font_size_override("font_size", 5)
	btn_confirmar.pressed.connect(_concluir_criacao_personagem)
	hbox_btns.add_child(btn_confirmar)


func _atualizar_slots() -> void:
	for child in panel_slots.get_children():
		child.queue_free()
		
	for slot_idx in range(1, 4):
		var resumo: Dictionary = SaveManager.obter_resumo_slot(slot_idx)
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 42)
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD if resumo["existe"] else HunterUIStyle.COLOR_BORDER_SUBTLE, 3))
		
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 6)
		margin.add_theme_constant_override("margin_top", 4)
		margin.add_theme_constant_override("margin_right", 6)
		margin.add_theme_constant_override("margin_bottom", 4)
		panel.add_child(margin)
		
		var hbox := HBoxContainer.new()
		margin.add_child(hbox)
		
		var lbl_slot_num := Label.new()
		lbl_slot_num.text = "[SLOT %d]" % slot_idx
		lbl_slot_num.add_theme_font_size_override("font_size", 5)
		lbl_slot_num.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
		hbox.add_child(lbl_slot_num)
		
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(10, 0)
		hbox.add_child(spacer)
		
		if resumo["existe"]:
			var info_vbox := VBoxContainer.new()
			info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(info_vbox)
			
			var lbl_nome := Label.new()
			var cat_name: String = NenAffinityData.obter_nome_afinidade(resumo["afinidade"])
			lbl_nome.text = "%s (Lv. %d) — %s" % [resumo["nome"], resumo["nivel"], cat_name]
			lbl_nome.add_theme_font_size_override("font_size", 5)
			lbl_nome.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
			info_vbox.add_child(lbl_nome)
			
			var btn_jogar := Button.new()
			btn_jogar.text = "JOGAR >"
			btn_jogar.add_theme_font_size_override("font_size", 5)
			HunterUIStyle.aplicar_estilo_botao(btn_jogar, HunterUIStyle.COLOR_BORDER_GREEN)
			btn_jogar.pressed.connect(func(): _jogar_com_slot(slot_idx))
			hbox.add_child(btn_jogar)
			
			var btn_del := Button.new()
			btn_del.text = "Deletar"
			btn_del.add_theme_font_size_override("font_size", 5)
			HunterUIStyle.aplicar_estilo_botao(btn_del, Color(0.9, 0.3, 0.3, 0.9))
			btn_del.pressed.connect(func():
				SaveManager.deletar_save(slot_idx)
				_atualizar_slots()
			)
			hbox.add_child(btn_del)
		else:
			var lbl_vazio := Label.new()
			lbl_vazio.text = "--- Slot Vazio ---"
			lbl_vazio.add_theme_font_size_override("font_size", 5)
			lbl_vazio.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
			lbl_vazio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(lbl_vazio)
			
			var btn_criar := Button.new()
			btn_criar.text = "+ Criar Personagem"
			btn_criar.add_theme_font_size_override("font_size", 5)
			HunterUIStyle.aplicar_estilo_botao(btn_criar, HunterUIStyle.COLOR_BORDER_GREEN)
			btn_criar.pressed.connect(func(): _abrir_criacao_para_slot(slot_idx))
			hbox.add_child(btn_criar)
			
		panel_slots.add_child(panel)


func _abrir_criacao_para_slot(slot_idx: int) -> void:
	slot_criacao_atual = slot_idx
	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.CHARACTER_CREATION)
		GameManager.change_state(GameManager.GameState.CHARACTER_CREATION)
	line_edit_nome.text = ""
	_sortear_afinidade()
	panel_criacao.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_criacao.visible = true
	line_edit_nome.grab_focus()


func _sortear_afinidade() -> void:
	afinidade_sorteada = NenAffinityData.sortear_afinidade_aleatoria()
	lbl_afinidade_nome.text = "Afinidade: " + NenAffinityData.obter_nome_afinidade(afinidade_sorteada)
	lbl_afinidade_desc.text = NenAffinityData.obter_descricao_afinidade(afinidade_sorteada)


func _concluir_criacao_personagem() -> void:
	if _ja_carregando:
		return
	_ja_carregando = true

	var nome: String = line_edit_nome.text.strip_edges()
	if nome.is_empty():
		nome = "Hunter"
		
	# Inicializar atributos e identidade do novo personagem
	PlayerData.slot_ativo = slot_criacao_atual
	PlayerData.gerar_novo_character_id()
	PlayerData.nome_personagem = nome
	PlayerData.afinidade_nen = afinidade_sorteada
	PlayerData.mapa_atual_salvo = "res://world/lobby.tscn"
	PlayerData.posicao_salva = Vector2.ZERO
	
	if picker_cabelo != null and picker_roupa != null:
		PlayerData.character_colors["cabelo"] = picker_cabelo.color
		PlayerData.character_colors["roupa"] = picker_roupa.color

	PlayerData.attributes = {
		"vida": 100, "vida_max": 100,
		"forca": 10, "defesa": 10, "velocidade": 10,
		"aura": 0.0, "aura_max": 0.0,
		"nivel_nen": 0, "xp_nen": 0, "nivel": 1, "gold": 100
	}
	PlayerData.quest_states.clear()
	PlayerData.inventory.clear()
	PlayerData.hatsu_criados.clear()
	PlayerData.hatsu_slots = [-1, -1, -1, -1]
	PlayerData.despertou_nen = false
	PlayerData.hatsu_desbloqueado = false
	PlayerData.besta_nen_desbloqueada = false
	PlayerData.besta_nen_equipada = null
	
	# Aplicar bônus de afinidade
	PlayerData.aplicar_bonuses_afinidade()
	
	print("[CHARACTER]")
	print("  Novo Personagem Criado: ", nome, " | ID: ", PlayerData.character_id, " | Slot: ", slot_criacao_atual)

	# Salvar no slot correspondente
	SaveManager.salvar_jogo(slot_criacao_atual)
	PlayerData.is_character_ready = true
	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.CHARACTER_CONFIRMATION)
	
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null:
		input_ctx.set_context("GAMEPLAY")
		
	personagem_selecionado.emit()
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://world/lobby.tscn", "Capital dos Caçadores", "Hunter Plaza — Hub Central")
	else:
		get_tree().change_scene_to_file("res://world/lobby.tscn")


func _jogar_com_slot(slot_idx: int) -> void:
	if _ja_carregando:
		return
	_ja_carregando = true

	print("============================================================")
	print("[CHARACTER]")
	print("  Selected Slot: ", slot_idx)
	print("[CHARACTER]")
	print("  Loading character...")

	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.LOADING_SAVE)

	var sucesso: bool = SaveManager.carregar_jogo(slot_idx)

	if not sucesso:
		_ja_carregando = false
		print("[ERROR]")
		print("  Character load failed: Arquivo de save ausente ou corrompido.")
		if EventBus != null and EventBus.has_signal("toast_requested"):
			EventBus.emit_toast("Não foi possível carregar este personagem.\nSeu progresso não foi apagado. Tente novamente.", Color(1.0, 0.4, 0.4))
		if GameManager != null:
			GameManager.set_flow_state(GameManager.GameFlowState.SAVE_SELECT)
			GameManager.change_state(GameManager.GameState.MAIN_MENU)
		return

	print("[SAVE]")
	print("  Character found: true")
	print("[SAVE]")
	print("  Character valid: true")
	print("[PLAYER]")
	print("  PlayerData loaded: true | ID: ", PlayerData.character_id, " | Nome: ", PlayerData.nome_personagem, " | Lvl: ", PlayerData.attributes.get("nivel", 1))

	PlayerData.is_character_ready = true
	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.SAVE_LOADED)

	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null:
		input_ctx.set_context("GAMEPLAY")

	personagem_selecionado.emit()

	var mapa_alvo: String = PlayerData.mapa_atual_salvo
	if not SaveManager.is_valid_world_map(mapa_alvo):
		mapa_alvo = "res://world/lobby.tscn"
		PlayerData.mapa_atual_salvo = mapa_alvo

	print("[WORLD]")
	print("  Loading world: ", mapa_alvo)
	print("[WORLD]")
	print("  Spawn valid: true (Pos: ", PlayerData.posicao_salva, ")")
	print("[SCENE]")
	print("  Transitioning to world...")
	print("============================================================")

	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena(mapa_alvo)
	else:
		get_tree().change_scene_to_file(mapa_alvo)


func _gerar_save_teste_lvl100() -> void:
	PlayerData.slot_ativo = 3
	PlayerData.gerar_novo_character_id()
	PlayerData.nome_personagem = "Hunter Supremo (Lvl 100)"
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO
	PlayerData.dificuldade = PlayerData.Dificuldade.NORMAL
	PlayerData.potencial = 1.0
	PlayerData.reputacao_hunter = 99999
	PlayerData.titulo_equipado = "Mestre Supremo de Nen (Lvl 100)"
	PlayerData.arco_atual = 9
	PlayerData.etapa_quest_arco = 1
	PlayerData.max_arco_desbloqueado = 9
	PlayerData.modo_historia_concluido = true
	PlayerData.despertou_nen = true
	PlayerData.hatsu_desbloqueado = true
	PlayerData.besta_nen_desbloqueada = true
	PlayerData.parallel_quests_concluidas = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	PlayerData.mapa_atual_salvo = "res://world/lobby.tscn"
	PlayerData.posicao_salva = Vector2.ZERO
	
	PlayerData.character_colors["cabelo"] = Color(1.0, 0.85, 0.2, 1.0)
	PlayerData.character_colors["roupa"] = Color(0.12, 0.56, 1.0, 1.0)
	
	# Status Normais Nível 100 + Nen Nível 100 no Máximo (GDD Vol 2)
	PlayerData.attributes = {
		"vida": 25000, "vida_max": 25000,
		"forca": 1000, "defesa": 1000, "velocidade": 1000,
		"aura": 50000.0, "aura_max": 50000.0,
		"nivel_nen": 100, "xp_nen": 1000000, "nivel": 100, "gold": 99999999
	}
	
	# Todas as Técnicas de Nen no Nível 100 Máximo
	PlayerData.tecnicas_nen = {
		"ten": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"ren": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"zetsu": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"gyo": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"shu": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"ko": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"en": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"ken": {"nivel": 100, "xp": 0, "desbloqueada": true},
		"ryu": {"nivel": 100, "xp": 0, "desbloqueada": true}
	}
	
	PlayerData.inventory = {
		"item_licenca_hunter": 1,
		"potion_hp_grande": 99,
		"potion_aura_grande": 99,
		"cristal_aura": 50,
		"cartao_greed_island_001": 1,
		"reliquia_imperial_kakin": 10,
		"essencia_continente_negro": 10,
		"elixir_deus_nen": 10
	}
	
	PlayerData.hatsu_criados.clear()
	var list = [
		HatsuManager.obter_hatsu_canonico("gon_jajanken_pedra"),
		HatsuManager.obter_hatsu_canonico("killua_narukami"),
		HatsuManager.obter_hatsu_canonico("kurapika_emperor_time"),
		HatsuManager.obter_hatsu_canonico("netero_guanyin"),
		HatsuManager.obter_hatsu_canonico("killua_kanmuru"),
		HatsuManager.obter_hatsu_canonico("leorio_remote_punch"),
		HatsuManager.obter_hatsu_canonico("hisoka_bungee_gum"),
		HatsuManager.obter_hatsu_canonico("kite_crazy_slots"),
		HatsuManager.obter_hatsu_canonico("feitan_rising_sun"),
		HatsuManager.obter_hatsu_canonico("kurapika_chain_jail"),
		HatsuManager.obter_hatsu_canonico("kurapika_holy_chain"),
		HatsuManager.obter_hatsu_canonico("chrollo_skill_hunter")
	]
	for h in list:
		if h != null:
			PlayerData.hatsu_criados.append(h)
			
	PlayerData.hatsu_slots = [0, 1, 2, 3]
	
	SaveManager.salvar_jogo(3)
	_atualizar_slots()