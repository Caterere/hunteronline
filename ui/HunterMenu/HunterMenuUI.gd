class_name HunterMenuUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - HUNTER MENU CONSOLIDADO (HUNTER THEME UI)
# ============================================================
#
# Menu centralizado de progressão e gerenciamento do Hunter:
# - [TAB] / [C]: Abrir / Alternar
# - [Q] / [E]: Navegação rápida entre abas
# - Abas: Status | Inventário | Nen Tree | Hatsu | Licença | Facções | Aparência
# ============================================================

var tab_container: TabContainer
var panel_main: PanelContainer

# Abas
var tab_status: VBoxContainer
var tab_inv: ScrollContainer
var tab_nen: ScrollContainer
var tab_hatsu: ScrollContainer
var tab_license: VBoxContainer
var tab_factions: ScrollContainer
var tab_guide: ScrollContainer
var tab_creation: ScrollContainer

# Sub-containers de listagem
var inv_list_container: VBoxContainer
var nen_list_container: VBoxContainer
var hatsu_list_container: VBoxContainer
var factions_list_container: VBoxContainer
var guide_list_container: VBoxContainer

# Referências de Nós
var lbl_status_header: Label
var lbl_status_attrs: Label
var lbl_license_info: Label

# Elementos de Aparência & Criação
var edit_nome: LineEdit
var picker_pele: ColorPickerButton
var picker_cabelo: ColorPickerButton
var picker_roupa: ColorPickerButton
var opt_dificuldade: OptionButton
var lbl_potencial: Label
var temp_potencial: float = 1.0

var nen_system: Node = null


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir_ui()


func _construir_ui() -> void:
	# Root Fullscreen Control
	var root_control := Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	# Fundo translúcido escuro
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.04, 0.07, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(bg)

	# CenterContainer para centralização responsiva absoluta em qualquer resolução
	var center_container := CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(center_container)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(310, 175)
	panel_main.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	center_container.add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# Header com Dica de Teclas e Brasão Hunter
	var hbox_header := HBoxContainer.new()
	vbox.add_child(hbox_header)

	var lbl_title := Label.new()
	lbl_title.text = "📜 HUNTER MENU"
	lbl_title.add_theme_font_size_override("font_size", 6)
	lbl_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox_header.add_child(lbl_title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(spacer)

	var lbl_hints := Label.new()
	lbl_hints.text = "[Q/E] Abas  |  [ESC/TAB] Fechar"
	lbl_hints.add_theme_font_size_override("font_size", 4)
	lbl_hints.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_header.add_child(lbl_hints)

	# Tab Container Estilizado
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_tab_container(tab_container)
	tab_container.tab_changed.connect(func(_idx): _atualizar_aba_atual())
	vbox.add_child(tab_container)

	_criar_aba_status()
	_criar_aba_inventario()
	_criar_aba_nen()
	_criar_aba_hatsu()
	_criar_aba_licenca()
	_criar_aba_faccoes()
	_criar_aba_guia()
	_criar_aba_criacao()


func _criar_aba_status() -> void:
	tab_status = VBoxContainer.new()
	tab_status.name = "Status"
	tab_status.add_theme_constant_override("separation", 3)
	tab_container.add_child(tab_status)

	lbl_status_header = Label.new()
	lbl_status_header.add_theme_font_size_override("font_size", 4)
	lbl_status_header.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	tab_status.add_child(lbl_status_header)

	lbl_status_attrs = Label.new()
	lbl_status_attrs.add_theme_font_size_override("font_size", 4)
	lbl_status_attrs.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	tab_status.add_child(lbl_status_attrs)


func _criar_aba_inventario() -> void:
	tab_inv = ScrollContainer.new()
	tab_inv.name = "Inventário"
	tab_container.add_child(tab_inv)

	inv_list_container = VBoxContainer.new()
	inv_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inv_list_container.add_theme_constant_override("separation", 2)
	tab_inv.add_child(inv_list_container)


func _criar_aba_nen() -> void:
	tab_nen = ScrollContainer.new()
	tab_nen.name = "Nen Tree"
	tab_container.add_child(tab_nen)

	nen_list_container = VBoxContainer.new()
	nen_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nen_list_container.add_theme_constant_override("separation", 2)
	tab_nen.add_child(nen_list_container)


func _criar_aba_hatsu() -> void:
	tab_hatsu = ScrollContainer.new()
	tab_hatsu.name = "Hatsu"
	tab_container.add_child(tab_hatsu)

	hatsu_list_container = VBoxContainer.new()
	hatsu_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hatsu_list_container.add_theme_constant_override("separation", 2)
	tab_hatsu.add_child(hatsu_list_container)


func _criar_aba_licenca() -> void:
	tab_license = VBoxContainer.new()
	tab_license.name = "Licença"
	tab_license.add_theme_constant_override("separation", 4)
	tab_container.add_child(tab_license)

	lbl_license_info = Label.new()
	lbl_license_info.add_theme_font_size_override("font_size", 4)
	lbl_license_info.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	tab_license.add_child(lbl_license_info)


func _criar_aba_faccoes() -> void:
	tab_factions = ScrollContainer.new()
	tab_factions.name = "Facções"
	tab_container.add_child(tab_factions)

	factions_list_container = VBoxContainer.new()
	factions_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	factions_list_container.add_theme_constant_override("separation", 2)
	tab_factions.add_child(factions_list_container)


func _criar_aba_guia() -> void:
	tab_guide = ScrollContainer.new()
	tab_guide.name = "Guia Hunter"
	tab_container.add_child(tab_guide)

	guide_list_container = VBoxContainer.new()
	guide_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide_list_container.add_theme_constant_override("separation", 3)
	tab_guide.add_child(guide_list_container)


func _criar_aba_criacao() -> void:
	tab_creation = ScrollContainer.new()
	tab_creation.name = "Aparência"
	tab_container.add_child(tab_creation)

	var v_box := VBoxContainer.new()
	v_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v_box.add_theme_constant_override("separation", 3)
	tab_creation.add_child(v_box)

	var lbl_hdr := Label.new()
	lbl_hdr.text = "🎨 APARÊNCIA & CRIAÇÃO DE PERSONAGEM"
	lbl_hdr.add_theme_font_size_override("font_size", 5)
	lbl_hdr.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	v_box.add_child(lbl_hdr)

	# Nome
	var hbox_nome := HBoxContainer.new()
	v_box.add_child(hbox_nome)
	var lbl_n := Label.new()
	lbl_n.text = "Nome: "
	lbl_n.add_theme_font_size_override("font_size", 4)
	lbl_n.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_nome.add_child(lbl_n)
	edit_nome = LineEdit.new()
	edit_nome.placeholder_text = "Digite o nome..."
	edit_nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit_nome.add_theme_font_size_override("font_size", 4)
	hbox_nome.add_child(edit_nome)

	# Cores
	var hbox_colors := HBoxContainer.new()
	hbox_colors.add_theme_constant_override("separation", 4)
	v_box.add_child(hbox_colors)

	var lbl_pele := Label.new()
	lbl_pele.text = "Pele:"
	lbl_pele.add_theme_font_size_override("font_size", 4)
	lbl_pele.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_colors.add_child(lbl_pele)
	picker_pele = ColorPickerButton.new()
	picker_pele.color = Color(1.0, 0.88, 0.76)
	picker_pele.custom_minimum_size = Vector2(24, 12)
	hbox_colors.add_child(picker_pele)

	var lbl_cab := Label.new()
	lbl_cab.text = "Cabelo:"
	lbl_cab.add_theme_font_size_override("font_size", 4)
	lbl_cab.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_colors.add_child(lbl_cab)
	picker_cabelo = ColorPickerButton.new()
	picker_cabelo.color = Color.BLACK
	picker_cabelo.custom_minimum_size = Vector2(24, 12)
	hbox_colors.add_child(picker_cabelo)

	var lbl_rou := Label.new()
	lbl_rou.text = "Roupa:"
	lbl_rou.add_theme_font_size_override("font_size", 4)
	lbl_rou.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_colors.add_child(lbl_rou)
	picker_roupa = ColorPickerButton.new()
	picker_roupa.color = Color(0.2, 0.6, 0.3)
	picker_roupa.custom_minimum_size = Vector2(24, 12)
	hbox_colors.add_child(picker_roupa)

	# Dificuldade
	var hbox_diff := HBoxContainer.new()
	v_box.add_child(hbox_diff)
	var lbl_d := Label.new()
	lbl_d.text = "Dificuldade: "
	lbl_d.add_theme_font_size_override("font_size", 4)
	lbl_d.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_diff.add_child(lbl_d)
	opt_dificuldade = OptionButton.new()
	opt_dificuldade.add_item("Fácil")
	opt_dificuldade.add_item("Normal")
	opt_dificuldade.add_item("Difícil")
	opt_dificuldade.add_item("Muito Difícil")
	opt_dificuldade.add_item("Hunter Supremo")
	opt_dificuldade.add_theme_font_size_override("font_size", 4)
	hbox_diff.add_child(opt_dificuldade)

	# Potencial
	var hbox_pot := HBoxContainer.new()
	v_box.add_child(hbox_pot)
	lbl_potencial = Label.new()
	lbl_potencial.text = "Potencial: 100%"
	lbl_potencial.add_theme_font_size_override("font_size", 4)
	lbl_potencial.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox_pot.add_child(lbl_potencial)
	var btn_roll := Button.new()
	btn_roll.text = "🎲 Sortear Potencial"
	btn_roll.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_roll, HunterUIStyle.COLOR_BORDER_GREEN)
	btn_roll.pressed.connect(_on_roll_potencial_pressed)
	hbox_pot.add_child(btn_roll)

	# Botões de Ação
	var hbox_act := HBoxContainer.new()
	hbox_act.add_theme_constant_override("separation", 6)
	v_box.add_child(hbox_act)

	var btn_salvar := Button.new()
	btn_salvar.text = "💾 Salvar & Aplicar Visual"
	btn_salvar.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_salvar, HunterUIStyle.COLOR_BORDER_GREEN)
	btn_salvar.pressed.connect(_on_salvar_customizacao_pressed)
	hbox_act.add_child(btn_salvar)

	var btn_slots := Button.new()
	btn_slots.text = "🔄 Trocar / Novo Slot"
	btn_slots.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_slots, Color(0.9, 0.3, 0.3, 0.9))
	btn_slots.pressed.connect(_on_abrir_menu_slots_pressed)
	hbox_act.add_child(btn_slots)


func _on_roll_potencial_pressed() -> void:
	temp_potencial = randf_range(0.60, 1.00)
	if lbl_potencial != null:
		lbl_potencial.text = "Potencial: %.0f%%" % (temp_potencial * 100.0)


func _on_salvar_customizacao_pressed() -> void:
	if edit_nome != null and not edit_nome.text.strip_edges().is_empty():
		PlayerData.nome_personagem = edit_nome.text.strip_edges()
	
	if picker_pele != null:
		PlayerData.character_colors["pele"] = picker_pele.color
	if picker_cabelo != null:
		PlayerData.character_colors["cabelo"] = picker_cabelo.color
	if picker_roupa != null:
		PlayerData.character_colors["roupa"] = picker_roupa.color
	
	if opt_dificuldade != null:
		PlayerData.dificuldade = opt_dificuldade.selected as PlayerData.Dificuldade
	
	PlayerData.potencial = temp_potencial

	var p = get_tree().get_first_node_in_group("player")
	if p != null and p.has_method("_aplicar_customizacao_visual"):
		p._aplicar_customizacao_visual()

	if GameState != null:
		GameState.salvar_jogo()

	if EventBus != null:
		EventBus.emit_toast("✨ Aparência & Dados Salvos com Sucesso!", HunterUIStyle.COLOR_HUNTER_GREEN_LIGHT)
	
	_atualizar_conteudo_status()


func _on_abrir_menu_slots_pressed() -> void:
	if GameState != null:
		GameState.salvar_jogo()
	if UIManager != null:
		UIManager.fechar_menu_atual()
	get_tree().change_scene_to_file("res://ui/CharacterSelection/CharacterSelectionUI.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null and input_ctx.is_text_input_focused():
		return

	if event.keycode == KEY_E or event.is_action_pressed("menu_next_tab"):
		if tab_container != null and tab_container.get_tab_count() > 0:
			var next = (tab_container.current_tab + 1) % tab_container.get_tab_count()
			definir_aba_ativa(next)
			get_viewport().set_input_as_handled()
	elif event.keycode == KEY_Q or event.is_action_pressed("menu_prev_tab"):
		if tab_container != null and tab_container.get_tab_count() > 0:
			var prev = (tab_container.current_tab - 1 + tab_container.get_tab_count()) % tab_container.get_tab_count()
			definir_aba_ativa(prev)
			get_viewport().set_input_as_handled()


func definir_aba_ativa(aba_index: int) -> void:
	if tab_container != null and aba_index >= 0 and aba_index < tab_container.get_tab_count():
		tab_container.current_tab = aba_index
		_atualizar_aba_atual()


func _atualizar_aba_atual() -> void:
	if not visible:
		return

	var cur = tab_container.get_current_tab_control()
	if cur == null:
		return

	match cur.name:
		"Status":
			_atualizar_conteudo_status()
			if TutorialManager != null:
				TutorialManager.notificar_aba_status_aberta()
		"Inventário":
			_atualizar_conteudo_inventario()
			if TutorialManager != null:
				TutorialManager.notificar_aba_inventario_aberta()
		"Nen Tree":
			_atualizar_conteudo_nen()
		"Hatsu":
			_atualizar_conteudo_hatsu()
		"Licença":
			_atualizar_conteudo_licenca()
		"Facções":
			_atualizar_conteudo_faccoes()
		"Guia Hunter":
			_atualizar_conteudo_guia()
		"Aparência":
			_atualizar_conteudo_criacao()


func _atualizar_conteudo_criacao() -> void:
	if edit_nome != null:
		edit_nome.text = PlayerData.nome_personagem
	if picker_pele != null:
		picker_pele.color = PlayerData.character_colors.get("pele", Color.WHITE)
	if picker_cabelo != null:
		picker_cabelo.color = PlayerData.character_colors.get("cabelo", Color.BLACK)
	if picker_roupa != null:
		picker_roupa.color = PlayerData.character_colors.get("roupa", Color(0.2, 0.6, 0.3))
	if opt_dificuldade != null:
		opt_dificuldade.selected = int(PlayerData.dificuldade)
	temp_potencial = PlayerData.potencial
	if lbl_potencial != null:
		lbl_potencial.text = "Potencial: %.0f%%" % (temp_potencial * 100.0)


func _atualizar_conteudo_status() -> void:
	if lbl_status_header == null or lbl_status_attrs == null:
		return
	var nome_p = PlayerData.nome_personagem
	var tit = PlayerData.titulo_equipado
	var tit_str = " [%s]" % tit if not tit.is_empty() else ""
	var lvl = int(PlayerData.attributes.get("nivel", 1))
	var af = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
	lbl_status_header.text = "👤 %s%s | Nível %d | Afinidade: %s" % [nome_p, tit_str, lvl, af]

	var hp = int(PlayerData.attributes.get("vida", 100))
	var hp_max = int(PlayerData.attributes.get("vida_max", 100))
	var aura = int(PlayerData.attributes.get("aura", 0))
	var aura_max = int(PlayerData.attributes.get("aura_max", 100))
	var forca = int(PlayerData.attributes.get("forca", 10))
	var def = int(PlayerData.attributes.get("defesa", 10))
	var vel = int(PlayerData.attributes.get("velocidade", 10))
	var gold = Economy.obter_gold()

	lbl_status_attrs.text = (
		"❤️ Vida: %d / %d\n" +
		"⚡ Aura: %d / %d\n" +
		"⚔️ Força: %d\n" +
		"🛡️ Defesa: %d\n" +
		"👟 Velocidade: %d\n" +
		"💰 Jenny: %d\n" +
		"🔍 Segredos Descobertos: %d"
	) % [hp, hp_max, aura, aura_max, forca, def, vel, gold, PlayerData.segredos_descobertos.size()]


func _atualizar_conteudo_inventario() -> void:
	if inv_list_container == null:
		return
	for c in inv_list_container.get_children():
		c.queue_free()

	if PlayerData.inventory.is_empty():
		var lbl = Label.new()
		lbl.text = "📦 Inventário Vazio"
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
		inv_list_container.add_child(lbl)
		return

	for item_id in PlayerData.inventory.keys():
		var qtd = PlayerData.inventory[item_id]
		if qtd <= 0: continue
		var p_item := PanelContainer.new()
		p_item.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 2))
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		p_item.add_child(m)

		var hbox := HBoxContainer.new()
		m.add_child(hbox)

		var lbl := Label.new()
		lbl.text = "• %s" % str(item_id).capitalize()
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)

		var lbl_q := Label.new()
		lbl_q.text = "x%d" % qtd
		lbl_q.add_theme_font_size_override("font_size", 4)
		lbl_q.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
		hbox.add_child(lbl_q)

		inv_list_container.add_child(p_item)


func _atualizar_conteudo_nen() -> void:
	if nen_list_container == null:
		return
	for c in nen_list_container.get_children():
		c.queue_free()

	var p = get_tree().get_first_node_in_group("player")
	if p != null:
		nen_system = p.get_node_or_null("NenSystem")

	var tecs = [
		{"tec": 0, "nome": "TEN (Manto Protetor)"},
		{"tec": 1, "nome": "REN (Emissão de Potência)"},
		{"tec": 2, "nome": "ZETSU (Ocultação & Regeneração)"},
		{"tec": 3, "nome": "GYO (Foco & Visão de Aura)"},
		{"tec": 5, "nome": "KO (Concentração Máxima)"},
		{"tec": 6, "nome": "EN (Raio de Detecção)"},
		{"tec": 7, "nome": "KEN (Blindagem Geral)"},
		{"tec": 8, "nome": "RYU (Fluxo Dinâmico)"},
		{"tec": 4, "nome": "SHU (Revestimento de Objetos)"}
	]

	for t in tecs:
		var tec_id: int = t["tec"]
		var lvl: int = 1
		var ativa: bool = false
		if nen_system != null:
			if nen_system.has_method("obter_nivel_tecnica"):
				lvl = nen_system.obter_nivel_tecnica(tec_id)
			if nen_system.has_method("tecnica_ativa"):
				ativa = nen_system.tecnica_ativa(tec_id)

		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_nen(ativa))
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		card.add_child(m)

		var hbox := HBoxContainer.new()
		m.add_child(hbox)

		var lbl := Label.new()
		lbl.text = "🥋 %s [Lv. %d]" % [t["nome"], lvl]
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN if ativa else HunterUIStyle.COLOR_TEXT_PRIMARY)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)

		if ativa:
			var lbl_atv := Label.new()
			lbl_atv.text = "⚡ ATIVA"
			lbl_atv.add_theme_font_size_override("font_size", 3)
			lbl_atv.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
			hbox.add_child(lbl_atv)

		nen_list_container.add_child(card)


func _atualizar_conteudo_hatsu() -> void:
	if hatsu_list_container == null:
		return
	for c in hatsu_list_container.get_children():
		c.queue_free()

	if PlayerData.hatsu_criados.is_empty():
		var p_aviso := PanelContainer.new()
		p_aviso.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 2))
		var m_aviso := MarginContainer.new()
		m_aviso.add_theme_constant_override("margin_left", 4)
		m_aviso.add_theme_constant_override("margin_right", 4)
		m_aviso.add_theme_constant_override("margin_top", 4)
		m_aviso.add_theme_constant_override("margin_bottom", 4)
		p_aviso.add_child(m_aviso)
		var lbl_aviso := Label.new()
		lbl_aviso.text = "🔒 Nenhum Hatsu Desbloqueado\nVocê ainda não manifestou uma técnica de Hatsu própria.\nAvance na jornada e treine com Mestres de Nen."
		lbl_aviso.add_theme_font_size_override("font_size", 4)
		lbl_aviso.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
		lbl_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		m_aviso.add_child(lbl_aviso)
		hatsu_list_container.add_child(p_aviso)

	for i in range(4):
		var h: HatsuData = PlayerData.obter_hatsu_slot(i)
		var p_slot := PanelContainer.new()
		p_slot.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GREEN if h != null else HunterUIStyle.COLOR_BORDER_SUBTLE, 2))
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		p_slot.add_child(m)

		var hbox := HBoxContainer.new()
		m.add_child(hbox)

		var lbl := Label.new()
		if h != null:
			lbl.text = "Slot [%d]: %s" % [i + 1, h.nome]
			lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		else:
			lbl.text = "Slot [%d]: Vazio" % [i + 1]
			lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)

		if h != null:
			var lbl_c := Label.new()
			lbl_c.text = "%d AP" % int(h.obter_custo_final())
			lbl_c.add_theme_font_size_override("font_size", 3)
			lbl_c.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
			hbox.add_child(lbl_c)

		hatsu_list_container.add_child(p_slot)


func _atualizar_conteudo_licenca() -> void:
	if lbl_license_info == null:
		return
	var tem = PlayerData.tem_item(StringName("licenca_hunter"))
	if tem:
		lbl_license_info.text = (
			"🏆 LICENÇA HUNTER OFICIAL\n\n" +
			"Portador: %s\n" +
			"Status: Caçador Licenciado de 1 Estrela\n" +
			"Benefícios: Acesso irrestrito a 95%% dos países e redes de informação confidenciais."
		) % PlayerData.nome_personagem
		lbl_license_info.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	else:
		lbl_license_info.text = (
			"🔒 LICENÇA NÃO OBTIDA\n\n" +
			"Derrote o Guardião Ancestral das Ruínas de Zaban ou complete o Exame Hunter para obter sua licença."
		)
		lbl_license_info.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)


func _atualizar_conteudo_faccoes() -> void:
	if factions_list_container == null:
		return
	for c in factions_list_container.get_children():
		c.queue_free()

	if ReputationSystem == null:
		return

	var faccoes = [
		{"id": "associacao_hunter", "nome": "Associação Hunter"},
		{"id": "mafia", "nome": "Máfia / Submundo"},
		{"id": "civis", "nome": "Civis & Cidades"},
		{"id": "mercadores", "nome": "Mercadores & Lojas"},
		{"id": "criminosos", "nome": "Criminosos & Fugitivos"}
	]

	for f in faccoes:
		var rep = ReputationSystem.obter_reputacao_str(f["id"])
		var status_str = "Neutro"
		var cor_status = HunterUIStyle.COLOR_GOLD_LIGHT
		if rep >= 500:
			status_str = "Honrado (+20% Desconto na Loja)"
			cor_status = HunterUIStyle.COLOR_HUNTER_GREEN_LIGHT
		elif rep >= 200:
			status_str = "Amigável (+10% Desconto)"
			cor_status = HunterUIStyle.COLOR_HUNTER_GREEN
		elif rep <= -200:
			status_str = "Hostil (Caçadores de Recompensa Alertas)"
			cor_status = HunterUIStyle.COLOR_HP_CRIMSON

		var p_fac := PanelContainer.new()
		p_fac.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 2))
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		p_fac.add_child(m)

		var hbox := HBoxContainer.new()
		m.add_child(hbox)

		var lbl := Label.new()
		lbl.text = "🏛️ %s: %d" % [f["nome"], rep]
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)

		var lbl_s := Label.new()
		lbl_s.text = status_str
		lbl_s.add_theme_font_size_override("font_size", 3)
		lbl_s.add_theme_color_override("font_color", cor_status)
		hbox.add_child(lbl_s)

		factions_list_container.add_child(p_fac)


func _atualizar_conteudo_guia() -> void:
	if guide_list_container == null:
		return
	for c in guide_list_container.get_children():
		c.queue_free()

	if TutorialManager == null:
		return

	var catalogo = TutorialManager.obter_catalogo_completo()
	var total_artigos = catalogo.size()
	var descobertos = PlayerData.conhecimentos_desbloqueados.size() if PlayerData != null else 0

	# Header Geral
	var p_hdr := PanelContainer.new()
	p_hdr.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 2))
	var m_hdr := MarginContainer.new()
	m_hdr.add_theme_constant_override("margin_left", 6)
	m_hdr.add_theme_constant_override("margin_right", 6)
	m_hdr.add_theme_constant_override("margin_top", 4)
	m_hdr.add_theme_constant_override("margin_bottom", 4)
	p_hdr.add_child(m_hdr)

	var vb_hdr := VBoxContainer.new()
	m_hdr.add_child(vb_hdr)

	var lbl_gh := Label.new()
	lbl_gh.text = "📖 GUIA HUNTER & ENCICLOPÉDIA DE NEN"
	lbl_gh.add_theme_font_size_override("font_size", 5)
	lbl_gh.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vb_hdr.add_child(lbl_gh)

	var lbl_sub := Label.new()
	lbl_sub.text = "Conhecimentos Descobertos: %d / %d" % [descobertos, total_artigos]
	lbl_sub.add_theme_font_size_override("font_size", 4)
	lbl_sub.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vb_hdr.add_child(lbl_sub)
	guide_list_container.add_child(p_hdr)

	# Agrupar por Categorias
	var categorias: Array[String] = ["Mundo", "Combate", "Atributos", "Aura & Nen", "Hatsu", "Facções & Sistemas", "Sistemas"]
	for cat in categorias:
		var artigos_cat: Array[Dictionary] = []
		for id in catalogo.keys():
			var item = catalogo[id]
			if item.get("categoria", "") == cat:
				var item_copy = item.duplicate()
				item_copy["id"] = id
				artigos_cat.append(item_copy)

		if artigos_cat.is_empty():
			continue

		var lbl_cat_title := Label.new()
		lbl_cat_title.text = "▼ %s" % cat.to_upper()
		lbl_cat_title.add_theme_font_size_override("font_size", 4)
		lbl_cat_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
		guide_list_container.add_child(lbl_cat_title)

		for art in artigos_cat:
			var id_art = art["id"]
			var desbloqueado = PlayerData.tem_conhecimento(id_art) if PlayerData != null else false

			var p_art := PanelContainer.new()
			p_art.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GREEN if desbloqueado else HunterUIStyle.COLOR_BORDER_SUBTLE, 2))
			var m_art := MarginContainer.new()
			m_art.add_theme_constant_override("margin_left", 4)
			m_art.add_theme_constant_override("margin_right", 4)
			m_art.add_theme_constant_override("margin_top", 3)
			m_art.add_theme_constant_override("margin_bottom", 3)
			p_art.add_child(m_art)

			var vb_art := VBoxContainer.new()
			vb_art.add_theme_constant_override("separation", 2)
			m_art.add_child(vb_art)

			var lbl_t := Label.new()
			if desbloqueado:
				lbl_t.text = "%s %s" % [art.get("icone", "📄"), art.get("titulo", "Artigo")]
				lbl_t.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
			else:
				lbl_t.text = "🔒 Conhecimento Oculto (%s)" % art.get("titulo", "???")
				lbl_t.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
			lbl_t.add_theme_font_size_override("font_size", 4)
			vb_art.add_child(lbl_t)

			if desbloqueado:
				var lbl_c := Label.new()
				lbl_c.text = art.get("conteudo", "")
				lbl_c.add_theme_font_size_override("font_size", 3)
				lbl_c.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
				lbl_c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				vb_art.add_child(lbl_c)

			guide_list_container.add_child(p_art)


func abrir() -> void:
	visible = true
	_atualizar_aba_atual()
	if TutorialManager != null:
		TutorialManager.notificar_menu_aberto("HunterMenu")
