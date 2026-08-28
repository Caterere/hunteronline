extends CanvasLayer

# ============================================================
# HUNTER ONLINE - PLAYER HUD PROFISSIONAL & COMPLETO
# ============================================================
#
# Interface de usuário principal durante o gameplay:
# - Card do Jogador Topo-Esquerdo com Números Precisos de HP, Aura e XP.
# - Indicador Dinâmico de Nível, Nível de Nen, Dinheiro (Jenny) e Técnica de Nen Ativa.
# - Barra de Vida de Chefe Superior (Boss Bar) com contagem numérica e porcentagem.
# - Hotbar Inferior Estilo Minecraft com 4 Slots de Hatsu (Teclas 1, 2, 3, 4).
# - Contagem e barra de Cooldown em tempo real.
# - Atalhos para Menus: [N] Nen, [C] Status, [I] Inventário, [B] Binder, [H] Hatsu.
#
# ============================================================

const WorldMinimapUI = preload("res://ui/Minimap/WorldMinimapUI.gd")
const AchievementsUI = preload("res://ui/Achievements/AchievementsUI.gd")
const NenQuickActionBarScript = preload("res://ui/hud/NenQuickActionBar.gd")

# Referências
var xp_system: XPSystem = null
var hatsu_system: HatsuSystem = null
var nen_system: NenSystem = null
var player: Node = null
var achievements_ui: AchievementsUI = null
var nen_action_bar: Control = null


# Painel Principal Topo-Esquerdo
var player_card_panel: PanelContainer
var lbl_player_header: Label
var lbl_gold: Label

var bar_hp: ProgressBar
var lbl_hp_num: Label

var bar_aura: ProgressBar
var lbl_aura_num: Label

var bar_xp: ProgressBar
var lbl_xp_num: Label

var lbl_nen_status: Label
var lbl_beast_status: Label

# Hotbar de Hatsu (Estilo Minecraft)
var hatsu_slots_container: HBoxContainer
var slot_panels: Array[PanelContainer] = []
var slot_name_labels: Array[Label] = []
var slot_cost_labels: Array[Label] = []
var slot_cd_labels: Array[Label] = []
var slot_cd_overlays: Array[ColorRect] = []
var slot_progress_bars: Array[ProgressBar] = []
var active_selected_slot: int = 0

# Menu de Equipamento de Hatsu
var hatsu_equip_ui: HatsuEquipUI = null

# Boss Bar (Topo da Tela)
var boss_bar_panel: PanelContainer
var lbl_boss_name: Label
var boss_hp_bar: ProgressBar
var lbl_boss_hp: Label

# Onboarding / Tutorial Prompt (Fase 5)
var tutorial_panel: PanelContainer = null
var lbl_tutorial: Label = null
var _pos_inicial_player: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("player_hud")

	_criar_card_jogador_top_left()
	_criar_boss_bar()
	_criar_painel_hatsu_slots()
	_criar_nen_quick_action_bar()
	_instanciar_menus_auxiliares()
	_conectar_event_bus()
	_conectar_player_e_sistemas()
	_atualizar_hud()


func _criar_nen_quick_action_bar() -> void:
	if nen_action_bar == null:
		nen_action_bar = NenQuickActionBarScript.new()
		nen_action_bar.name = "NenQuickActionBar"
		add_child(nen_action_bar)




# ============================================================
# CONSTRUÇÃO VISUAL DO CARD DO JOGADOR (TOPO ESQUERDO)
# ============================================================

func _criar_card_jogador_top_left() -> void:
	# Ocultar o MarginContainer original simples se existir
	var old_margin = get_node_or_null("MarginContainer")
	if old_margin:
		old_margin.visible = false

	player_card_panel = PanelContainer.new()
	player_card_panel.position = Vector2(6, 6)
	player_card_panel.custom_minimum_size = Vector2(165, 76)
	player_card_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GREEN, 3))
	add_child(player_card_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 3)
	player_card_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	# Linha 1: Nome do Jogador e Nível
	var hbox_header := HBoxContainer.new()
	vbox.add_child(hbox_header)

	lbl_player_header = Label.new()
	lbl_player_header.text = "🔰 HUNTER | LV. 1"
	lbl_player_header.add_theme_font_size_override("font_size", 4)
	lbl_player_header.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_player_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_player_header)

	lbl_gold = Label.new()
	lbl_gold.text = "💰 0 J"
	lbl_gold.add_theme_font_size_override("font_size", 4)
	lbl_gold.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD)
	hbox_header.add_child(lbl_gold)

	# Linha 2: Barra de Vida (HP) com Números
	var hp_box := _criar_barra_com_label(
		HunterUIStyle.COLOR_HP_CRIMSON,
		Color(0.2, 0.05, 0.05, 0.9),
		"❤️ HP: 100/100"
	)
	vbox.add_child(hp_box.container)
	bar_hp = hp_box.bar
	lbl_hp_num = hp_box.label

	# Linha 3: Barra de Aura (AP) com Números
	var aura_box := _criar_barra_com_label(
		HunterUIStyle.COLOR_AURA_BAR,
		Color(0.04, 0.12, 0.22, 0.9),
		"⚡ AURA: 100/100"
	)
	vbox.add_child(aura_box.container)
	bar_aura = aura_box.bar
	lbl_aura_num = aura_box.label

	# Linha 4: Barra de XP com Números
	var xp_box := _criar_barra_com_label(
		HunterUIStyle.COLOR_XP_BAR,
		Color(0.04, 0.16, 0.08, 0.9),
		"✨ XP: 0/100 (0%)"
	)
	vbox.add_child(xp_box.container)
	bar_xp = xp_box.bar
	lbl_xp_num = xp_box.label

	# Linha 5: Indicador de Técnica de Nen e Besta
	var hbox_status := HBoxContainer.new()
	hbox_status.add_theme_constant_override("separation", 4)
	vbox.add_child(hbox_status)

	lbl_nen_status = Label.new()
	lbl_nen_status.text = "🥋 Nen: Inativo [N]"
	lbl_nen_status.add_theme_font_size_override("font_size", 3)
	lbl_nen_status.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	lbl_nen_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_status.add_child(lbl_nen_status)

	lbl_beast_status = Label.new()
	lbl_beast_status.text = ""
	lbl_beast_status.add_theme_font_size_override("font_size", 3)
	lbl_beast_status.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_PURPLE)
	hbox_status.add_child(lbl_beast_status)


func _criar_barra_com_label(cor_fill: Color, cor_bg: Color, texto_inicial: String) -> Dictionary:
	var container := Control.new()
	container.custom_minimum_size = Vector2(155, 9)

	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(155, 9)
	bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar.show_percentage = false
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 100

	var st_bg := StyleBoxFlat.new()
	st_bg.bg_color = cor_bg
	st_bg.border_width_left = 1
	st_bg.border_width_top = 1
	st_bg.border_width_right = 1
	st_bg.border_width_bottom = 1
	st_bg.border_color = Color(0.2, 0.3, 0.4, 0.7)
	st_bg.corner_radius_top_left = 2
	st_bg.corner_radius_top_right = 2
	st_bg.corner_radius_bottom_right = 2
	st_bg.corner_radius_bottom_left = 2
	bar.add_theme_stylebox_override("background", st_bg)

	var st_fill := StyleBoxFlat.new()
	st_fill.bg_color = cor_fill
	st_fill.corner_radius_top_left = 2
	st_fill.corner_radius_top_right = 2
	st_fill.corner_radius_bottom_right = 2
	st_fill.corner_radius_bottom_left = 2
	bar.add_theme_stylebox_override("fill", st_fill)
	container.add_child(bar)

	var lbl := Label.new()
	lbl.text = texto_inicial
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	container.add_child(lbl)

	return {"container": container, "bar": bar, "label": lbl}


# ============================================================
# BOSS BAR (TOPO DA TELA)
# ============================================================

func _criar_boss_bar() -> void:
	boss_bar_panel = PanelContainer.new()
	boss_bar_panel.custom_minimum_size = Vector2(240, 24)
	boss_bar_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	boss_bar_panel.offset_left = 40.0
	boss_bar_panel.offset_right = -40.0
	boss_bar_panel.offset_top = 4.0
	boss_bar_panel.visible = false
	boss_bar_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_HP_CRIMSON, 3))
	add_child(boss_bar_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	boss_bar_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	margin.add_child(vbox)

	lbl_boss_name = Label.new()
	lbl_boss_name.text = "👑 CHEFE"
	lbl_boss_name.add_theme_font_size_override("font_size", 4)
	lbl_boss_name.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_boss_name)

	var bar_box := Control.new()
	bar_box.custom_minimum_size = Vector2(220, 8)
	vbox.add_child(bar_box)

	boss_hp_bar = ProgressBar.new()
	boss_hp_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	boss_hp_bar.show_percentage = false
	boss_hp_bar.add_theme_stylebox_override("background", HunterUIStyle.criar_style_progress_bg())
	boss_hp_bar.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_HP_CRIMSON))
	bar_box.add_child(boss_hp_bar)

	lbl_boss_hp = Label.new()
	lbl_boss_hp.text = "0 / 0"
	lbl_boss_hp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl_boss_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_boss_hp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_boss_hp.add_theme_font_size_override("font_size", 3)
	lbl_boss_hp.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_boss_hp.add_theme_color_override("font_shadow_color", Color.BLACK)
	bar_box.add_child(lbl_boss_hp)


func notificar_boss_status(nome: String, hp: int, max_hp: int) -> void:
	if boss_bar_panel == null: return
	boss_bar_panel.visible = true
	lbl_boss_name.text = "👑 " + nome.to_upper()
	boss_hp_bar.max_value = max(1, max_hp)
	boss_hp_bar.value = clamp(hp, 0, max_hp)
	var pct: int = int((float(hp) / float(max(1, max_hp))) * 100.0)
	lbl_boss_hp.text = "%s / %s (%d%%)" % [_formatar_numero(hp), _formatar_numero(max_hp), pct]
	if hp <= 0:
		esconder_boss_bar()


func esconder_boss_bar() -> void:
	if boss_bar_panel != null:
		boss_bar_panel.visible = false


# ============================================================
# HOTBAR DE HATSU (ESTILO MINECRAFT COM NÚMEROS E CUSTO)
# ============================================================

func _criar_painel_hatsu_slots() -> void:
	if hatsu_slots_container != null:
		return

	var margin_bottom := MarginContainer.new()
	margin_bottom.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	margin_bottom.position = Vector2(96, 142)
	margin_bottom.custom_minimum_size = Vector2(128, 34)
	margin_bottom.add_theme_constant_override("margin_bottom", 2)
	add_child(margin_bottom)

	hatsu_slots_container = HBoxContainer.new()
	hatsu_slots_container.add_theme_constant_override("separation", 3)
	margin_bottom.add_child(hatsu_slots_container)

	slot_panels.clear()
	slot_name_labels.clear()
	slot_cost_labels.clear()
	slot_cd_labels.clear()
	slot_cd_overlays.clear()
	slot_progress_bars.clear()

	for i in range(4):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(30, 32)
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 3))

		var slot_box := Control.new()
		slot_box.custom_minimum_size = Vector2(28, 30)
		panel.add_child(slot_box)

		# Overlay de Cooldown
		var cd_overlay := ColorRect.new()
		cd_overlay.color = Color(0.0, 0.0, 0.0, 0.7)
		cd_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cd_overlay.visible = false
		slot_box.add_child(cd_overlay)
		slot_cd_overlays.append(cd_overlay)

		var vbox := VBoxContainer.new()
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 0)
		slot_box.add_child(vbox)

		# Número do slot (1, 2, 3, 4)
		var lbl_num := Label.new()
		lbl_num.text = "[%d]" % (i + 1)
		lbl_num.add_theme_font_size_override("font_size", 3)
		lbl_num.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
		lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_num)

		# Nome do Hatsu
		var lbl_name := Label.new()
		lbl_name.text = "-"
		lbl_name.add_theme_font_size_override("font_size", 3)
		lbl_name.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_name)
		slot_name_labels.append(lbl_name)

		# Custo de Aura (ex: 45 AP)
		var lbl_cost := Label.new()
		lbl_cost.text = ""
		lbl_cost.add_theme_font_size_override("font_size", 3)
		lbl_cost.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
		lbl_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_cost)
		slot_cost_labels.append(lbl_cost)

		# Texto de Cooldown (ex: 3.5s)
		var lbl_cd := Label.new()
		lbl_cd.text = ""
		lbl_cd.add_theme_font_size_override("font_size", 4)
		lbl_cd.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD)
		lbl_cd.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_cd.visible = false
		vbox.add_child(lbl_cd)
		slot_cd_labels.append(lbl_cd)

		# Barra de Cooldown na base
		var bar := ProgressBar.new()
		bar.min_value = 0
		bar.max_value = 100
		bar.value = 0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(26, 2)
		bar.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_GOLD))
		vbox.add_child(bar)
		slot_progress_bars.append(bar)

		hatsu_slots_container.add_child(panel)
		slot_panels.append(panel)

	_atualizar_selecao_slots()


func _atualizar_selecao_slots() -> void:
	for i in range(slot_panels.size()):
		var panel = slot_panels[i]
		if i == active_selected_slot:
			panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 3))
		else:
			panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 3))


# ============================================================
# CONEXÃO COM O JOGADOR E ATUALIZAÇÃO CONTÍNUA
# ============================================================

func _conectar_player_e_sistemas() -> void:
	if player != null:
		return

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	xp_system = player.get_node_or_null("XPSystem") as XPSystem
	hatsu_system = player.get_node_or_null("HatsuSystem") as HatsuSystem
	nen_system = player.get_node_or_null("NenSystem") as NenSystem

	if xp_system != null and not xp_system.level_up.is_connected(_on_level_up):
		xp_system.level_up.connect(_on_level_up)


func _process(_delta: float) -> void:
	_conectar_player_e_sistemas()
	_atualizar_hud()


func _atualizar_hud() -> void:

	_atualizar_header_e_gold()
	_atualizar_hp()
	_atualizar_aura()
	_atualizar_xp()
	_atualizar_nen_e_besta()
	_atualizar_hatsu_slots()


func _atualizar_header_e_gold() -> void:
	if lbl_player_header:
		var nivel: int = int(PlayerData.attributes.get("nivel", 1))
		var nivel_nen: int = int(PlayerData.attributes.get("nivel_nen", 0))
		lbl_player_header.text = "🔰 NV. %d (NEN NV. %d)" % [nivel, nivel_nen]

	if lbl_gold:
		var gold: int = Economy.obter_gold()
		lbl_gold.text = "💰 %s J" % _formatar_numero(gold)


func _atualizar_hp() -> void:
	if bar_hp == null or lbl_hp_num == null: return
	var hp: int = int(PlayerData.attributes.get("vida", 100))
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	bar_hp.max_value = max(1, hp_max)
	bar_hp.value = clamp(hp, 0, hp_max)
	var pct: int = int((float(hp) / float(max(1, hp_max))) * 100.0)
	lbl_hp_num.text = "❤️ HP: %s / %s (%d%%)" % [_formatar_numero(hp), _formatar_numero(hp_max), pct]


func _atualizar_aura() -> void:
	if bar_aura == null or lbl_aura_num == null: return
	var aura: int = int(PlayerData.attributes.get("aura", 0))
	var aura_max: int = int(PlayerData.attributes.get("aura_max", 100))
	bar_aura.max_value = max(1, aura_max)
	bar_aura.value = clamp(aura, 0, aura_max)
	var pct: int = int((float(aura) / float(max(1, aura_max))) * 100.0)
	lbl_aura_num.text = "⚡ AURA: %s / %s (%d%%)" % [_formatar_numero(aura), _formatar_numero(aura_max), pct]


func _atualizar_xp() -> void:
	if bar_xp == null or lbl_xp_num == null: return
	var xp_atual: int = 0
	var xp_nec: int = 100
	if xp_system != null:
		xp_atual = xp_system.obter_xp()
		xp_nec = max(1, xp_system.obter_xp_necessario())
	else:
		xp_atual = int(PlayerData.attributes.get("xp", 0))
		xp_nec = max(1, int(PlayerData.attributes.get("xp_necessario", 100)))

	bar_xp.max_value = xp_nec
	bar_xp.value = clamp(xp_atual, 0, xp_nec)
	var pct: int = int((float(xp_atual) / float(xp_nec)) * 100.0)
	lbl_xp_num.text = "✨ XP: %s / %s (%d%%)" % [_formatar_numero(xp_atual), _formatar_numero(xp_nec), pct]


func _atualizar_nen_e_besta() -> void:
	if lbl_nen_status:
		var ativa_nome := "Inativo [N]"
		if nen_system != null:
			if nen_system.tecnica_ativa(NenSystem.Tecnica.KO):
				ativa_nome = "KO (+75% Dano / Guard Break)"
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.GYO):
				ativa_nome = "GYO (+35% Crítico / Visão)"
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.TEN):
				ativa_nome = "TEN (Defesa +40%)"
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.ZETSU):
				ativa_nome = "ZETSU (Regen + Furtivo x3)"
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.REN):
				ativa_nome = "REN (Alcance Ampliado)"
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.SHU):
				ativa_nome = "SHU (Revestimento de Arma)"
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.EN):
				ativa_nome = "EN (Percepção Total)"
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.KEN):
				ativa_nome = "KEN (Blindagem Geral)"
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.RYU):
				var mod_str: String = "ATAQUE 80/20" if nen_system.modulo_ryu == NenSystem.ModuloRyu.ATAQUE else "DEFESA 20/80"
				ativa_nome = "RYU (%s [Tab])" % mod_str
		lbl_nen_status.text = "🥋 %s" % ativa_nome

	if lbl_beast_status:
		if PlayerData.besta_nen_desbloqueada and PlayerData.besta_nen_equipada != null:
			var nome_b: String = PlayerData.besta_nen_equipada.nome_besta
			lbl_beast_status.text = "🐉 %s" % [nome_b.left(8)]
		else:
			lbl_beast_status.text = ""


# ============================================================
# SISTEMA DE NOTIFICAÇÕES & BANNERS ANIMADOS
# ============================================================

func _conectar_event_bus() -> void:
	if EventBus == null:
		return
	if not EventBus.toast_requested.is_connected(_exibir_toast_banner):
		EventBus.toast_requested.connect(_exibir_toast_banner)


func _exibir_toast_banner(mensagem: String, cor_borda: Color = Color.WHITE) -> void:
	var banner := PanelContainer.new()
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.position = Vector2(160, -35)
	banner.custom_minimum_size = Vector2(320, 26)
	banner.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(cor_borda, 3))
	add_child(banner)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	banner.add_child(margin)

	var lbl := Label.new()
	lbl.text = mensagem
	lbl.add_theme_font_size_override("font_size", 4)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(lbl)

	if AudioManager != null:
		AudioManager.tocar_ui_click(true)

	var tween := banner.create_tween()
	tween.tween_property(banner, "position:y", 20.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.2)
	tween.tween_property(banner, "position:y", -35.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(banner.queue_free)


func _atualizar_hatsu_slots() -> void:
	if slot_name_labels.size() < 4 or slot_progress_bars.size() < 4:
		return

	for i in range(4):
		var hatsu: HatsuData = PlayerData.obter_hatsu_slot(i)
		var cd_atual: float = 0.0
		var cd_max: float = 0.0
		var st: int = 1 # SlotState.READY por padrão

		if hatsu_system != null:
			if i < hatsu_system.slot_cooldowns.size():
				cd_atual = hatsu_system.slot_cooldowns[i]
				cd_max = hatsu_system.slot_cooldowns_max[i]
			if i < hatsu_system.slot_states.size():
				st = int(hatsu_system.slot_states[i])

		if hatsu != null:
			slot_name_labels[i].text = hatsu.nome.left(6)
			if st == 3: # SlotState.ACTIVE
				slot_name_labels[i].add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
				slot_panels[i].add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_GOLD, 3))
			elif st == 5: # SlotState.DISABLED
				slot_name_labels[i].add_theme_color_override("font_color", Color(0.8, 0.4, 0.4, 0.8))
				slot_panels[i].add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(Color(0.8, 0.2, 0.2, 0.8), 3))
			else:
				slot_name_labels[i].add_theme_color_override("font_color", Color.WHITE)
				if i != active_selected_slot:
					slot_panels[i].add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 3))

			if i < slot_cost_labels.size():
				if st == 3: # ACTIVE
					slot_cost_labels[i].text = "⚡ATIVO"
					slot_cost_labels[i].add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
					slot_cost_labels[i].visible = true
				elif st == 5: # DISABLED
					slot_cost_labels[i].text = "🔒BLOQ"
					slot_cost_labels[i].add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
					slot_cost_labels[i].visible = true
				else:
					slot_cost_labels[i].text = "%d AP" % int(hatsu.obter_custo_final())
					slot_cost_labels[i].add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
					slot_cost_labels[i].visible = (cd_atual <= 0.0)
		else:
			slot_name_labels[i].text = "-"
			slot_name_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
			if i < slot_cost_labels.size():
				slot_cost_labels[i].text = ""

		# Atualizar Cooldown
		if cd_atual > 0.0 and cd_max > 0.0:
			slot_progress_bars[i].value = (cd_atual / cd_max) * 100.0
			slot_progress_bars[i].visible = true
			if i < slot_cd_overlays.size(): slot_cd_overlays[i].visible = true
			if i < slot_cd_labels.size():
				slot_cd_labels[i].text = "%.1fs" % cd_atual
				slot_cd_labels[i].visible = true
				slot_name_labels[i].visible = false
		else:
			slot_progress_bars[i].value = 0.0
			slot_progress_bars[i].visible = false
			if i < slot_cd_overlays.size(): slot_cd_overlays[i].visible = (st == 5)
			if i < slot_cd_labels.size():
				slot_cd_labels[i].visible = false
				slot_name_labels[i].visible = true


func _formatar_numero(val: int) -> String:
	if val >= 1000000:
		return "%.1fM" % (float(val) / 1000000.0)
	elif val >= 10000:
		return "%.1fk" % (float(val) / 1000.0)
	elif val >= 1000:
		return "%.1fk" % (float(val) / 1000.0)
	return "%d" % val


func _unhandled_input(event: InputEvent) -> void:
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null and not input_ctx.is_global_hotkey_allowed():
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			active_selected_slot = (active_selected_slot - 1 + 4) % 4
			_atualizar_selecao_slots()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			active_selected_slot = (active_selected_slot + 1) % 4
			_atualizar_selecao_slots()
			get_viewport().set_input_as_handled()

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			active_selected_slot = 0
			_atualizar_selecao_slots()
		elif event.keycode == KEY_2:
			active_selected_slot = 1
			_atualizar_selecao_slots()
		elif event.keycode == KEY_3:
			active_selected_slot = 2
			_atualizar_selecao_slots()
		elif event.keycode == KEY_4:
			active_selected_slot = 3
			_atualizar_selecao_slots()


func _instanciar_menus_auxiliares() -> void:
	var m_ui := get_tree().root.get_node_or_null("WorldMinimapUI")
	if m_ui == null:
		var mini := WorldMinimapUI.new()
		mini.name = "WorldMinimapUI"
		get_tree().root.call_deferred("add_child", mini)

	var gps := get_tree().root.get_node_or_null("MissionGPSIndicator")
	if gps == null:
		var new_gps := MissionGPSIndicator.new()
		new_gps.name = "MissionGPSIndicator"
		get_tree().root.call_deferred("add_child", new_gps)

	var p_ui := get_tree().root.get_node_or_null("PauseMenuUI")
	if p_ui == null:
		var scn_pause = load("res://ui/PauseMenu/PauseMenuUI.gd")
		if scn_pause:
			var pause_menu = scn_pause.new()
			pause_menu.name = "PauseMenuUI"
			get_tree().root.call_deferred("add_child", pause_menu)




func _on_level_up(new_level: int) -> void:
	print("HUD: LEVEL UP -> ", new_level)
	exibir_notificacao("✨ NÍVEL UP! Você alcançou o Nível %d!" % new_level)
	_atualizar_hud()


func exibir_notificacao(texto: String) -> void:
	var notif := Label.new()
	notif.text = texto
	notif.position = Vector2(80, 22)
	notif.custom_minimum_size = Vector2(160, 14)
	notif.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notif.add_theme_font_size_override("font_size", 4)
	notif.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	notif.add_theme_color_override("font_shadow_color", Color.BLACK)
	add_child(notif)
	
	var tween := create_tween()
	tween.tween_property(notif, "position:y", 16.0, 0.3)
	tween.tween_interval(2.2)
	tween.tween_property(notif, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(func():
		if is_instance_valid(notif):
			notif.queue_free()
	)
