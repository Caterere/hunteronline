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
var tab_nen: Control
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
	panel_main.custom_minimum_size = Vector2(460, 260)
	panel_main.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	center_container.add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# Header com Dica de Teclas e Brasão Hunter
	var hbox_header := HBoxContainer.new()
	vbox.add_child(hbox_header)

	var lbl_title := Label.new()
	lbl_title.text = "📜 HUNTER MENU"
	lbl_title.add_theme_font_size_override("font_size", 11)
	lbl_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hbox_header.add_child(lbl_title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(spacer)

	var lbl_hints := Label.new()
	lbl_hints.text = "[Q/E] Abas  |  [ESC/TAB] Fechar"
	lbl_hints.add_theme_font_size_override("font_size", 8)
	lbl_hints.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_header.add_child(lbl_hints)

	# Tab Container Estilizado
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_theme_font_size_override("font_size", 8)
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
	lbl_status_header.add_theme_font_size_override("font_size", 9)
	lbl_status_header.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	tab_status.add_child(lbl_status_header)

	lbl_status_attrs = Label.new()
	lbl_status_attrs.add_theme_font_size_override("font_size", 8)
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


var nen_skill_tree_ui_instance: NenSkillTreeUI = null

func _criar_aba_nen() -> void:
	tab_nen = PanelContainer.new()
	tab_nen.name = "Nen Tree"
	tab_nen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_nen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var st_empty := StyleBoxEmpty.new()
	tab_nen.add_theme_stylebox_override("panel", st_empty)
	tab_container.add_child(tab_nen)

	nen_list_container = VBoxContainer.new()
	nen_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nen_list_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_nen.add_child(nen_list_container)

	nen_skill_tree_ui_instance = NenSkillTreeUI.new()
	nen_skill_tree_ui_instance.name = "NenSkillTreeUIComponent"
	nen_list_container.add_child(nen_skill_tree_ui_instance)


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
	if nen_skill_tree_ui_instance != null:
		nen_skill_tree_ui_instance._atualizar_exibicao()
		return

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

	# 1. Info de Afinidade do Personagem
	var afinidade_nome := NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
	var lbl_af := Label.new()
	lbl_af.text = "🧪 Afinidade Natal: %s%s" % [
		afinidade_nome,
		" (100% de Eficiência em todas as categorias)" if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO else ""
	]
	lbl_af.add_theme_font_size_override("font_size", 4)
	lbl_af.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	hatsu_list_container.add_child(lbl_af)

	# 2. Seção: 4 Slots de Combate Ativos
	var lbl_slots_hdr := Label.new()
	lbl_slots_hdr.text = "⚡ SLOTS ATIVOS DE COMBATE (Teclas 1, 2, 3, 4):"
	lbl_slots_hdr.add_theme_font_size_override("font_size", 4)
	lbl_slots_hdr.add_theme_color_override("font_color", HunterUIStyle.COLOR_BORDER_GREEN)
	hatsu_list_container.add_child(lbl_slots_hdr)

	var hbox_slots := HBoxContainer.new()
	hbox_slots.add_theme_constant_override("separation", 3)
	hatsu_list_container.add_child(hbox_slots)

	for i in range(4):
		var slot_id: int = i + 1
		var is_unlocked: bool = HatsuProgressionManager == null or HatsuProgressionManager.is_slot_unlocked(slot_id)
		var h: HatsuData = PlayerData.obter_hatsu_slot(i) if is_unlocked else null

		var p_slot := PanelContainer.new()
		p_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p_slot.custom_minimum_size = Vector2(100, 32)
		
		var m_s := MarginContainer.new()
		m_s.add_theme_constant_override("margin_left", 3)
		m_s.add_theme_constant_override("margin_right", 3)
		m_s.add_theme_constant_override("margin_top", 2)
		m_s.add_theme_constant_override("margin_bottom", 2)
		p_slot.add_child(m_s)

		var vb_s := VBoxContainer.new()
		vb_s.alignment = BoxContainer.ALIGNMENT_CENTER
		vb_s.add_theme_constant_override("separation", 1)
		m_s.add_child(vb_s)

		var lbl_num := Label.new()
		lbl_num.add_theme_font_size_override("font_size", 4)
		lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb_s.add_child(lbl_num)

		var lbl_nome_h := Label.new()
		lbl_nome_h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_nome_h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_nome_h.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		lbl_nome_h.clip_text = true
		lbl_nome_h.add_theme_font_size_override("font_size", 4)
		vb_s.add_child(lbl_nome_h)

		if not is_unlocked:
			p_slot.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(Color(0.5, 0.2, 0.2, 0.8), 2))
			lbl_num.text = "🔒 [SLOT %d]" % slot_id
			lbl_num.add_theme_color_override("font_color", Color(0.8, 0.35, 0.35, 1.0))
			lbl_nome_h.text = "[ BLOQUEADO ]"
			lbl_nome_h.add_theme_color_override("font_color", Color(0.6, 0.45, 0.45, 1.0))

			var btn_req := Button.new()
			btn_req.text = "Requisitos"
			btn_req.add_theme_font_size_override("font_size", 3)
			var s_id_captured := slot_id
			btn_req.pressed.connect(func(): _mostrar_requisitos_slot_menu(s_id_captured))
			vb_s.add_child(btn_req)
		elif h != null:
			p_slot.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 2))
			lbl_num.text = "✓ [SLOT %d]" % slot_id
			lbl_num.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
			lbl_nome_h.text = h.nome
			lbl_nome_h.add_theme_color_override("font_color", Color.WHITE)

			var hbox_s_info := HBoxContainer.new()
			hbox_s_info.alignment = BoxContainer.ALIGNMENT_CENTER
			vb_s.add_child(hbox_s_info)

			var lbl_cost := Label.new()
			lbl_cost.text = "%d AP" % int(h.obter_custo_final())
			lbl_cost.add_theme_font_size_override("font_size", 3)
			lbl_cost.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
			hbox_s_info.add_child(lbl_cost)

			var btn_deseq := Button.new()
			btn_deseq.text = "Desequipar"
			btn_deseq.add_theme_font_size_override("font_size", 3)
			var cur_slot = i
			btn_deseq.pressed.connect(func(): _desequipar_slot_hatsu(cur_slot))
			vb_s.add_child(btn_deseq)
		else:
			p_slot.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(Color(0.2, 0.6, 0.35, 0.8), 2))
			lbl_num.text = "✓ [SLOT %d]" % slot_id
			lbl_num.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6, 1.0))
			lbl_nome_h.text = "[ Vazio ]"
			lbl_nome_h.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)

		hbox_slots.add_child(p_slot)

	# Separador
	var sep := HSeparator.new()
	hatsu_list_container.add_child(sep)

	# 3. Seção: Inventário de Todos os Hatsus Criados/Disponíveis
	var todos_hatsus: Array[HatsuData] = PlayerData.obter_todos_hatsus_disponiveis()
	var max_arch: int = HatsuConfig.MAX_ARCHIVE_SLOTS if ClassDB.class_exists(&"HatsuConfig") or true else 12

	var lbl_inv_hdr := Label.new()
	lbl_inv_hdr.text = "🎒 HATSU ARCHIVE (%d / %d habilidades):" % [todos_hatsus.size(), max_arch]
	lbl_inv_hdr.add_theme_font_size_override("font_size", 4)
	lbl_inv_hdr.add_theme_color_override("font_color", HunterUIStyle.COLOR_ACCENT_ORANGE)
	hatsu_list_container.add_child(lbl_inv_hdr)

	if todos_hatsus.is_empty():
		var p_aviso := PanelContainer.new()
		p_aviso.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_vazio())
		var lbl_aviso := Label.new()
		lbl_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_aviso.add_theme_font_size_override("font_size", 4)
		lbl_aviso.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
		lbl_aviso.text = "🔒 Nenhum Hatsu Forjado ainda!\nClique no botão abaixo para forjar seu primeiro Hatsu com o sistema de Juramentos & Restrições."
		p_aviso.add_child(lbl_aviso)
		hatsu_list_container.add_child(p_aviso)
	else:
		for hatsu_idx in range(todos_hatsus.size()):
			var hatsu := todos_hatsus[hatsu_idx]
			var ef: float = NenAffinityData.calcular_eficiencia_categoria(PlayerData.afinidade_nen, hatsu.categoria)

			var p_item := PanelContainer.new()
			p_item.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_item_inventario(false))
			hatsu_list_container.add_child(p_item)

			var hb_row := HBoxContainer.new()
			hb_row.add_theme_constant_override("separation", 2)
			p_item.add_child(hb_row)

			var vb_info := VBoxContainer.new()
			vb_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vb_info.add_theme_constant_override("separation", 0)
			hb_row.add_child(vb_info)

			var lbl_hn := Label.new()
			var star := "★ " if hatsu.is_mastered() else "⚡ "
			lbl_hn.text = "%s%s  [%s]  (Mastery: %d/100)" % [star, hatsu.nome, HatsuManager.obter_nome_categoria(hatsu.categoria), int(hatsu.mastery)]
			lbl_hn.add_theme_font_size_override("font_size", 4)
			lbl_hn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2) if hatsu.is_mastered() else HunterUIStyle.COLOR_AURA_CYAN)
			vb_info.add_child(lbl_hn)

			var obj_tag: String = "Dano"
			var poder_txt: String = "%d Poder" % int(hatsu.obter_poder_final())
			match hatsu.objetivo:
				HatsuData.ObjetivoPrincipal.DEFESA:
					obj_tag = "Defesa"
					poder_txt = "%d Escudo" % int(hatsu.obter_poder_final())
				HatsuData.ObjetivoPrincipal.CURA:
					obj_tag = "Cura"
					poder_txt = "%d Cura" % int(hatsu.obter_poder_final())
				HatsuData.ObjetivoPrincipal.MOBILIDADE:
					obj_tag = "Mobilidade"
					poder_txt = "Dash"
				HatsuData.ObjetivoPrincipal.CONTROLE:
					obj_tag = "Controle"
					poder_txt = "Stun"

			var extra_tag: String = ""
			if HatsuData.Condicao.ALMAS_INIMIGOS in hatsu.condicoes or hatsu.vow_custom_cat == "ALMAS":
				extra_tag = " | 💀 %d Almas" % hatsu.almas_acumuladas

			var lbl_stats := Label.new()
			lbl_stats.text = "[%s] %d%% Efic. | %d AP | %.1fs CD | %s%s" % [
				obj_tag,
				int(ef * 100),
				int(hatsu.obter_custo_final()),
				hatsu.obter_cooldown_final(),
				poder_txt,
				extra_tag
			]
			lbl_stats.add_theme_font_size_override("font_size", 3)
			lbl_stats.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
			vb_info.add_child(lbl_stats)

			# Botões de Equipamento Rápido (1, 2, 3, 4)
			var hb_btns := HBoxContainer.new()
			hb_btns.alignment = BoxContainer.ALIGNMENT_CENTER
			hb_btns.add_theme_constant_override("separation", 2)
			hb_row.add_child(hb_btns)

			var lbl_eq_prompt := Label.new()
			lbl_eq_prompt.text = "Equipar:"
			lbl_eq_prompt.add_theme_font_size_override("font_size", 3)
			lbl_eq_prompt.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
			hb_btns.add_child(lbl_eq_prompt)

			for s_idx in range(4):
				var s_id: int = s_idx + 1
				var is_slot_active: bool = HatsuProgressionManager == null or HatsuProgressionManager.is_slot_unlocked(s_id)
				var btn_eq := Button.new()
				btn_eq.text = str(s_id)
				btn_eq.custom_minimum_size = Vector2(16, 14)
				btn_eq.add_theme_font_size_override("font_size", 3)
				btn_eq.disabled = not is_slot_active
				if not is_slot_active:
					btn_eq.tooltip_text = "Hatsu Slot %d bloqueado" % s_id

				var h_index = hatsu_idx
				var target_slot = s_idx
				btn_eq.pressed.connect(func(): _equipar_hatsu_no_slot(h_index, target_slot))
				hb_btns.add_child(btn_eq)

	# 4. Rodapé: Botão de Forjar Novo Hatsu
	var sep_footer := HSeparator.new()
	hatsu_list_container.add_child(sep_footer)

	var btn_forjar := Button.new()
	btn_forjar.text = "🔨 Forjar Novo Hatsu (Juramentos & Restrições)"
	btn_forjar.add_theme_font_size_override("font_size", 4)
	btn_forjar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	HunterUIStyle.aplicar_estilo_botao(btn_forjar, HunterUIStyle.COLOR_BORDER_GOLD)
	btn_forjar.pressed.connect(_abrir_criador_hatsu)
	hatsu_list_container.add_child(btn_forjar)


func _equipar_hatsu_no_slot(hatsu_index: int, slot: int) -> void:
	var slot_id: int = slot + 1
	if HatsuProgressionManager != null and not HatsuProgressionManager.can_equip_to_slot(slot_id, hatsu_index):
		_mostrar_requisitos_slot_menu(slot_id)
		return

	PlayerData.equipar_hatsu(slot, hatsu_index)
	_atualizar_conteudo_hatsu()
	if GameState != null:
		GameState.salvar_jogo()
	if EventBus != null:
		var h_nome = PlayerData.hatsu_criados[hatsu_index].nome if hatsu_index < PlayerData.hatsu_criados.size() else "Hatsu"
		EventBus.emit_toast("⚡ %s equipado no Slot %d!" % [h_nome, slot + 1], HunterUIStyle.COLOR_AURA_CYAN)


func _desequipar_slot_hatsu(slot: int) -> void:
	PlayerData.desequipar_hatsu(slot)
	_atualizar_conteudo_hatsu()
	if GameState != null:
		GameState.salvar_jogo()
	if EventBus != null:
		EventBus.emit_toast("Desequipado do Slot %d." % (slot + 1), HunterUIStyle.COLOR_TEXT_SECONDARY)


func _abrir_criador_hatsu() -> void:
	if HatsuProgressionManager != null and not HatsuProgressionManager.can_create_hatsu():
		_mostrar_requisitos_slot_menu(1)
		return

	if UIManager != null:
		UIManager.fechar_menu_atual()
	
	var root = get_tree().root
	var creation_ui = root.get_node_or_null("HatsuCreationUI") as HatsuCreationUI
	if creation_ui != null:
		creation_ui.abrir()
	else:
		var scn_creation = load("res://ui/Hatsu/HatsuCreationUI.gd")
		if scn_creation:
			var new_ui = scn_creation.new()
			new_ui.name = "HatsuCreationUI"
			root.add_child(new_ui)
			new_ui.abrir()


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
