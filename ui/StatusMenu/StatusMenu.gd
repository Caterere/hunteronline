class_name StatusMenu
extends Control

# ============================================================
# HUNTER ONLINE — RPG STATUS MENU (TELA DE PERSONAGEM)
# ============================================================
#
# Tela de Personagem completa inspirada em RPGs tradicionais e HxH:
# - 3 Colunas Temáticas:
#   1. ATRIBUTOS VITAIS: HP, Aura, Força, Defesa, Velocidade com barras e valores.
#   2. PROGRESSÃO: Nível em destaque, Barra de XP, Barra de Nen XP, SP disponíveis.
#   3. LICENÇA HUNTER & LORE: Card oficial de Caçador com ID, Afinidade, Título, Facção e Segredos.
# - Botão de atalho direto para a Árvore de Habilidades de Nen [N].
# - Fechamento intuitivo via botão [X], [C] ou [Esc].
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

# Referências de compatibilidade para testes e sistemas legados
var titulo_label: Label
var level_label: Label
var hp_label: Label
var forca_label: Label
var defesa_label: Label
var aura_label: Label

var lbl_titulo_personagem: Label
var lbl_faccao: Label
var lbl_segredos: Label

# Elementos Visuais do Redesign RPG
var main_panel: PanelContainer
var bar_hp: ProgressBar
var bar_aura: ProgressBar
var bar_xp: ProgressBar
var bar_nen_xp: ProgressBar
var lbl_nivel_grande: Label
var lbl_sp_destaque: Label
var lbl_velocidade: Label
var lbl_hunter_id: Label
var lbl_afinidade_licenca: Label
var lbl_rank_licenca: Label
var btn_abrir_skill_tree: Button
var btn_fechar: Button

var xp_system: XPSystem = null


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_interface_rpg()
	xp_system = get_tree().get_first_node_in_group("xp_system") as XPSystem
	_atualizar_status()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_C or event.keycode == KEY_ESCAPE:
			alternar_menu()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_N:
			_abrir_skill_tree()
			get_viewport().set_input_as_handled()


func alternar_menu() -> void:
	visible = not visible
	if visible:
		_atualizar_status()
		if AudioManager != null and AudioManager.has_method("tocar_ui_click"):
			AudioManager.tocar_ui_click(false)


func _process(_delta: float) -> void:
	if visible:
		_atualizar_status()


func _construir_interface_rpg() -> void:
	for child in get_children():
		child.queue_free()

	# Fundo escurecido semi-transparente
	var bg_overlay := ColorRect.new()
	bg_overlay.color = Color(0.0, 0.0, 0.0, 0.65)
	bg_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg_overlay)

	# Janela Central Principal
	main_panel = PanelContainer.new()
	main_panel.name = "PanelContainer"
	main_panel.custom_minimum_size = Vector2(380, 200)
	main_panel.set_anchors_preset(Control.PRESET_CENTER)
	main_panel.offset_left = -190.0
	main_panel.offset_right = 190.0
	main_panel.offset_top = -100.0
	main_panel.offset_bottom = 100.0
	main_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	add_child(main_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	main_panel.add_child(margin)

	var vbox_main := VBoxContainer.new()
	vbox_main.add_theme_constant_override("separation", 4)
	margin.add_child(vbox_main)

	# ------------------------------------------------------------
	# 1. CABEÇALHO SUPERIOR
	# ------------------------------------------------------------
	var hbox_header := HBoxContainer.new()
	vbox_main.add_child(hbox_header)

	titulo_label = Label.new()
	titulo_label.name = "TituloLabel"
	titulo_label.text = "STATUS DO CAÇADOR"
	titulo_label.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_TITLE)
	titulo_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	titulo_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(titulo_label)

	btn_fechar = Button.new()
	btn_fechar.text = " ✕ "
	btn_fechar.custom_minimum_size = Vector2(16, 14)
	btn_fechar.add_theme_font_size_override("font_size", 6)
	HunterUIStyle.aplicar_estilo_botao(btn_fechar, HunterUIStyle.COLOR_BORDER_SUBTLE)
	btn_fechar.pressed.connect(alternar_menu)
	hbox_header.add_child(btn_fechar)

	var sep_header := HSeparator.new()
	vbox_main.add_child(sep_header)

	# ------------------------------------------------------------
	# 2. CORPO EM 3 COLUNAS (RPG THREE-PILLAR LAYOUT)
	# ------------------------------------------------------------
	var hbox_cols := HBoxContainer.new()
	hbox_cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_cols.add_theme_constant_override("separation", 6)
	vbox_main.add_child(hbox_cols)

	# COLUNA 1: ATRIBUTOS VITAIS
	_construir_coluna_vitais(hbox_cols)

	# COLUNA 2: PROGRESSÃO & MAESTRIA
	_construir_coluna_progressao(hbox_cols)

	# COLUNA 3: LICENÇA HUNTER & IDENTIDADE
	_construir_coluna_licenca(hbox_cols)

	# ------------------------------------------------------------
	# 3. RODAPÉ DE ATALHOS
	# ------------------------------------------------------------
	var lbl_footer := Label.new()
	lbl_footer.text = "⌨️ [C] Fechar  •  [N] Árvore de Habilidades de Nen  •  [Esc] Voltar ao Jogo"
	lbl_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_footer.add_theme_font_size_override("font_size", 5)
	lbl_footer.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
	vbox_main.add_child(lbl_footer)


func _construir_coluna_vitais(parent: Control) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 3))
	parent.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	var lbl_sec := Label.new()
	lbl_sec.text = "❤️ ATRIBUTOS DE COMBATE"
	lbl_sec.add_theme_font_size_override("font_size", 6)
	lbl_sec.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	vbox.add_child(lbl_sec)

	# HP Bar
	hp_label = Label.new()
	hp_label.name = "HPLabel"
	hp_label.text = "HP: 100 / 100"
	hp_label.add_theme_font_size_override("font_size", 5)
	hp_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_HP_CRIMSON)
	vbox.add_child(hp_label)

	bar_hp = ProgressBar.new()
	bar_hp.custom_minimum_size = Vector2(0, 6)
	bar_hp.show_percentage = false
	bar_hp.add_theme_stylebox_override("background", HunterUIStyle.criar_style_progress_bg())
	bar_hp.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_HP_CRIMSON))
	vbox.add_child(bar_hp)

	# Aura Bar
	aura_label = Label.new()
	aura_label.name = "AuraLabel"
	aura_label.text = "Aura: 100 / 100"
	aura_label.add_theme_font_size_override("font_size", 5)
	aura_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(aura_label)

	bar_aura = ProgressBar.new()
	bar_aura.custom_minimum_size = Vector2(0, 6)
	bar_aura.show_percentage = false
	bar_aura.add_theme_stylebox_override("background", HunterUIStyle.criar_style_progress_bg())
	bar_aura.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_AURA_BAR))
	vbox.add_child(bar_aura)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Força
	forca_label = Label.new()
	forca_label.name = "ForcaLabel"
	forca_label.text = "⚔️ Força: 10"
	forca_label.add_theme_font_size_override("font_size", 6)
	forca_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_REN)
	vbox.add_child(forca_label)

	# Defesa
	defesa_label = Label.new()
	defesa_label.name = "DefesaLabel"
	defesa_label.text = "🛡️ Defesa: 10"
	defesa_label.add_theme_font_size_override("font_size", 6)
	defesa_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEN)
	vbox.add_child(defesa_label)

	# Velocidade
	lbl_velocidade = Label.new()
	lbl_velocidade.text = "🏃 Velocidade: 64 px/s"
	lbl_velocidade.add_theme_font_size_override("font_size", 6)
	lbl_velocidade.add_theme_color_override("font_color", HunterUIStyle.COLOR_ZETSU)
	vbox.add_child(lbl_velocidade)


func _construir_coluna_progressao(parent: Control) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 3))
	parent.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	var lbl_sec := Label.new()
	lbl_sec.text = "⭐ EVOLUÇÃO & MAESTRIA"
	lbl_sec.add_theme_font_size_override("font_size", 6)
	lbl_sec.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	vbox.add_child(lbl_sec)

	lbl_nivel_grande = Label.new()
	lbl_nivel_grande.text = "NV. 1"
	lbl_nivel_grande.add_theme_font_size_override("font_size", 10)
	lbl_nivel_grande.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_nivel_grande.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_nivel_grande)

	# Nível XP
	level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "XP: 0 / 100"
	level_label.add_theme_font_size_override("font_size", 5)
	level_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_XP_BAR)
	vbox.add_child(level_label)

	bar_xp = ProgressBar.new()
	bar_xp.custom_minimum_size = Vector2(0, 6)
	bar_xp.show_percentage = false
	bar_xp.add_theme_stylebox_override("background", HunterUIStyle.criar_style_progress_bg())
	bar_xp.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_XP_BAR))
	vbox.add_child(bar_xp)

	# Nen XP
	var lbl_nen_xp_title := Label.new()
	lbl_nen_xp_title.text = "Maestria de Nen (Nen XP)"
	lbl_nen_xp_title.add_theme_font_size_override("font_size", 5)
	lbl_nen_xp_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_NEN_XP_BAR)
	vbox.add_child(lbl_nen_xp_title)

	bar_nen_xp = ProgressBar.new()
	bar_nen_xp.custom_minimum_size = Vector2(0, 6)
	bar_nen_xp.show_percentage = false
	bar_nen_xp.add_theme_stylebox_override("background", HunterUIStyle.criar_style_progress_bg())
	bar_nen_xp.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_NEN_XP_BAR))
	vbox.add_child(bar_nen_xp)

	# SP Destaque
	lbl_sp_destaque = Label.new()
	lbl_sp_destaque.text = "⚡ 0 SP DISPONÍVEIS"
	lbl_sp_destaque.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_sp_destaque.add_theme_font_size_override("font_size", 6)
	lbl_sp_destaque.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vbox.add_child(lbl_sp_destaque)

	btn_abrir_skill_tree = Button.new()
	btn_abrir_skill_tree.text = "🥋 Árvore de Nen [N]"
	btn_abrir_skill_tree.custom_minimum_size = Vector2(0, 18)
	btn_abrir_skill_tree.add_theme_font_size_override("font_size", 5)
	HunterUIStyle.aplicar_estilo_botao(btn_abrir_skill_tree, HunterUIStyle.COLOR_BORDER_GOLD)
	btn_abrir_skill_tree.pressed.connect(_abrir_skill_tree)
	vbox.add_child(btn_abrir_skill_tree)


func _construir_coluna_licenca(parent: Control) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_licenca_hunter())
	parent.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	var lbl_sec := Label.new()
	lbl_sec.text = "📜 LICENÇA HUNTER"
	lbl_sec.add_theme_font_size_override("font_size", 6)
	lbl_sec.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_sec.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_sec)

	lbl_hunter_id = Label.new()
	lbl_hunter_id.text = "ID: #HXR-0001"
	lbl_hunter_id.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hunter_id.add_theme_font_size_override("font_size", 5)
	lbl_hunter_id.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	vbox.add_child(lbl_hunter_id)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Título Equipado
	lbl_titulo_personagem = Label.new()
	lbl_titulo_personagem.text = "[Sem Título]"
	lbl_titulo_personagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo_personagem.add_theme_font_size_override("font_size", 5)
	lbl_titulo_personagem.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	vbox.add_child(lbl_titulo_personagem)

	# Afinidade de Nen
	lbl_afinidade_licenca = Label.new()
	lbl_afinidade_licenca.text = "Afinidade: Oculta"
	lbl_afinidade_licenca.add_theme_font_size_override("font_size", 5)
	lbl_afinidade_licenca.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_afinidade_licenca)

	# Facção e Rank
	lbl_faccao = Label.new()
	lbl_faccao.name = "FaccaoLabel"
	lbl_faccao.text = "Facção: Independente"
	lbl_faccao.add_theme_font_size_override("font_size", 5)
	lbl_faccao.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	vbox.add_child(lbl_faccao)

	# Segredos Descobertos
	lbl_segredos = Label.new()
	lbl_segredos.name = "SegredosLabel"
	lbl_segredos.text = "Segredos: 0 / 10 Ocultos"
	lbl_segredos.add_theme_font_size_override("font_size", 5)
	lbl_segredos.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_PURPLE)
	vbox.add_child(lbl_segredos)


func _atualizar_status() -> void:
	if xp_system == null:
		xp_system = get_tree().get_first_node_in_group("xp_system") as XPSystem

	if PlayerData == null:
		return

	var nivel: int = int(PlayerData.attributes.get("nivel", 1))
	var nome: String = PlayerData.nome_personagem if not PlayerData.nome_personagem.is_empty() else "Hunter"

	if titulo_label != null:
		titulo_label.text = "STATUS DO CAÇADOR — %s" % nome.to_upper()

	if lbl_nivel_grande != null:
		lbl_nivel_grande.text = "NV. %d" % nivel

	# XP do Personagem
	var xp_atual: int = 0
	var xp_nec: int = 100
	if xp_system != null:
		xp_atual = xp_system.obter_xp()
		xp_nec = max(1, xp_system.obter_xp_necessario())
	else:
		xp_atual = int(PlayerData.attributes.get("xp", 0))
		xp_nec = max(1, int(PlayerData.attributes.get("xp_necessario", 100)))

	if level_label != null:
		if nivel >= ProgressionConfig.MAX_LEVEL:
			level_label.text = "XP: MÁXIMO (Cap Nv. %d)" % ProgressionConfig.MAX_LEVEL
		else:
			var pct_xp: int = int((float(xp_atual) / float(xp_nec)) * 100.0)
			level_label.text = "XP: %d / %d (%d%%)" % [xp_atual, xp_nec, pct_xp]

	if bar_xp != null:
		bar_xp.max_value = xp_nec
		bar_xp.value = xp_nec if nivel >= ProgressionConfig.MAX_LEVEL else clamp(xp_atual, 0, xp_nec)

	# HP
	var hp: int = int(PlayerData.attributes.get("vida", 100))
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	if hp_label != null:
		var pct_hp: int = int((float(hp) / float(max(1, hp_max))) * 100.0)
		hp_label.text = "HP: %d / %d (%d%%)" % [hp, hp_max, pct_hp]
	if bar_hp != null:
		bar_hp.max_value = max(1, hp_max)
		bar_hp.value = clamp(hp, 0, hp_max)

	# Força & Defesa
	var forca: int = int(PlayerData.attributes.get("forca", 10))
	if forca_label != null:
		forca_label.text = "⚔️ Força: %d" % forca

	var defesa: int = int(PlayerData.attributes.get("defesa", 10))
	if defesa_label != null:
		defesa_label.text = "🛡️ Defesa: %d" % defesa

	# Velocidade
	if lbl_velocidade != null:
		var vel: int = int(PlayerData.attributes.get("velocidade", 64))
		lbl_velocidade.text = "🏃 Velocidade: %d px/s" % vel

	# Aura e SP
	var aura: int = int(PlayerData.attributes.get("aura", 100))
	var aura_max: int = int(PlayerData.attributes.get("aura_max", 100))
	var sp: int = PlayerData.nen_skill_points

	if aura_label != null:
		var pct_aura: int = int((float(aura) / float(max(1, aura_max))) * 100.0)
		aura_label.text = "Aura: %d / %d (⚡ %d SP)" % [aura, aura_max, sp]

	if bar_aura != null:
		bar_aura.max_value = max(1, aura_max)
		bar_aura.value = clamp(aura, 0, aura_max)

	# Nen XP
	var xp_nen: int = int(PlayerData.attributes.get("xp_nen", 0))
	var nen_xp_nec: int = 100
	if bar_nen_xp != null:
		bar_nen_xp.max_value = nen_xp_nec
		bar_nen_xp.value = clamp(xp_nen, 0, nen_xp_nec)

	if lbl_sp_destaque != null:
		lbl_sp_destaque.text = "⚡ %d PONTOS DE NEN (SP)" % sp

	# Licença Hunter
	if lbl_hunter_id != null:
		var slot_idx: int = PlayerData.slot_selecionado if "slot_selecionado" in PlayerData else 1
		lbl_hunter_id.text = "LICENÇA HUNTER #HX%04d" % slot_idx

	if lbl_titulo_personagem != null:
		var tit = PlayerData.titulo_equipado if not PlayerData.titulo_equipado.is_empty() else "Caçador Iniciante"
		lbl_titulo_personagem.text = "[%s]" % tit

	if lbl_afinidade_licenca != null:
		if PlayerData.despertou_nen:
			var af_nome: String = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
			lbl_afinidade_licenca.text = "Afinidade: %s" % af_nome
			lbl_afinidade_licenca.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
		else:
			lbl_afinidade_licenca.text = "Afinidade: Oculta (Adormecida)"
			lbl_afinidade_licenca.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)

	if lbl_faccao != null:
		var faccao_txt: String = FactionManager.obter_nome_faccao_atual() if FactionManager else "Independente"
		var rank_txt: String = FactionManager.obter_nome_rank_atual() if FactionManager else "Sem Rank"
		lbl_faccao.text = "Facção: %s (%s)" % [faccao_txt, rank_txt]

	if lbl_segredos != null:
		var seg_count: int = PlayerData.segredos_descobertos.size() if "segredos_descobertos" in PlayerData else 0
		lbl_segredos.text = "🔍 Segredos: %d / 10 Descobertos" % seg_count


func _abrir_skill_tree() -> void:
	alternar_menu()
	var menu_ui = get_tree().get_first_node_in_group("hunter_menu")
	if menu_ui != null and menu_ui.has_method("abrir_aba"):
		menu_ui.abrir_aba("Nen Tree")
	elif EventBus != null:
		EventBus.emit_toast("Pressione [N] para abrir a Árvore de Nen", HunterUIStyle.COLOR_GOLD_LIGHT)
