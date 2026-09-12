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

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")
const WorldMinimapUI = preload("res://ui/Minimap/WorldMinimapUI.gd")
const AchievementsUI = preload("res://ui/Achievements/AchievementsUI.gd")
const NenQuickActionBarScript = preload("res://ui/hud/NenQuickActionBar.gd")
const ConditionTrackerUIScript = preload("res://ui/hud/ConditionTrackerUI.gd")

# Referências
var xp_system: XPSystem = null
var hatsu_system: HatsuSystem = null
var nen_system: NenSystem = null
var player: Node = null
var achievements_ui: AchievementsUI = null
var nen_action_bar: Control = null
var condition_tracker: ConditionTrackerUI = null


# Painel Principal Topo-Esquerdo
var player_card_panel: PanelContainer
var lbl_player_header: Label
var lbl_player_level_badge: Label
var lbl_player_affinity: Label
var lbl_sp_badge: Label
var lbl_gold: Label

var bar_hp: ProgressBar
var lbl_hp_num: Label

var bar_aura: ProgressBar
var lbl_aura_num: Label

var bar_xp: ProgressBar
var lbl_xp_num: Label

var lbl_nen_status: Label
var lbl_beast_status: Label
var hbox_conditions: HBoxContainer

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
var boss_def_bar: ProgressBar
var lbl_boss_def: Label

# Target HUD (Fase 10)
var target_hud: TargetHUD = null
var party_hud = null
var chat_hud = null

# Onboarding / Tutorial Prompt (Fase 5)
var tutorial_panel: PanelContainer = null
var lbl_tutorial: Label = null
var _pos_inicial_player: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("player_hud")

	_criar_card_jogador_top_left()
	_criar_boss_bar()
	_criar_target_hud()
	_criar_condition_tracker()
	_criar_party_hud()
	_criar_chat_hud()
	_criar_painel_hatsu_slots()
	_criar_nen_quick_action_bar()
	_instanciar_menus_auxiliares()
	_conectar_event_bus()
	_conectar_player_e_sistemas()
	if HatsuProgressionManager != null and HatsuProgressionManager.has_signal("hatsu_slots_atualizados"):
		HatsuProgressionManager.hatsu_slots_atualizados.connect(_atualizar_hatsu_slots)
	_atualizar_hud()


func _criar_condition_tracker() -> void:
	if condition_tracker == null:
		condition_tracker = ConditionTrackerUIScript.new()
		condition_tracker.name = "ConditionTrackerUI"
		# Canto inferior esquerdo — só aparece com Hatsu condicional ativo
		condition_tracker.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		condition_tracker.offset_left = 10.0
		condition_tracker.offset_top = -150.0
		condition_tracker.offset_right = 160.0
		condition_tracker.offset_bottom = -12.0
		add_child(condition_tracker)


func _criar_target_hud() -> void:
	if target_hud == null:
		target_hud = TargetHUD.new()
		target_hud.name = "TargetHUD"
		add_child(target_hud)


func _criar_nen_quick_action_bar() -> void:
	if nen_action_bar == null:
		nen_action_bar = NenQuickActionBarScript.new()
		nen_action_bar.name = "NenQuickActionBar"
		add_child(nen_action_bar)


func _criar_party_hud() -> void:
	if party_hud == null:
		var party_hud_script = load("res://ui/party/PartyHUD.gd")
		if party_hud_script != null:
			party_hud = party_hud_script.new()
			party_hud.name = "PartyHUD"
			add_child(party_hud)


func _criar_chat_hud() -> void:
	if chat_hud == null:
		var chat_hud_script = load("res://ui/chat/MultiplayerChatHUD.gd")
		if chat_hud_script != null:
			chat_hud = chat_hud_script.new()
			chat_hud.name = "MultiplayerChatHUD"
			add_child(chat_hud)






# ============================================================
# CONSTRUÇÃO VISUAL DO CARD DO JOGADOR (TOPO ESQUERDO)
# ============================================================

func _criar_card_jogador_top_left() -> void:
	# Ocultar o MarginContainer original simples se existir
	var old_margin = get_node_or_null("MarginContainer")
	if old_margin:
		old_margin.visible = false

	# Raiz: header + 3 frames de barra SEPARADOS (refs Mini Medieval / Fantasy HUD)
	var root := VBoxContainer.new()
	root.name = "PlayerHudRoot"
	root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	root.offset_left = 6.0
	root.offset_top = 6.0
	root.add_theme_constant_override("separation", 2)
	add_child(root)

	player_card_panel = PanelContainer.new()
	player_card_panel.custom_minimum_size = Vector2(148, 28)
	player_card_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_licenca_hunter())
	root.add_child(player_card_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 3)
	player_card_panel.add_child(margin)

	var vbox_header := VBoxContainer.new()
	vbox_header.add_theme_constant_override("separation", 1)
	margin.add_child(vbox_header)

	var hbox_header := HBoxContainer.new()
	vbox_header.add_child(hbox_header)

	lbl_player_header = Label.new()
	lbl_player_header.text = "★ LICENÇA HUNTER"
	HunterUIStyle.aplicar_fonte_licenca(lbl_player_header, 9, HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_player_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_player_header)

	lbl_player_level_badge = Label.new()
	lbl_player_level_badge.text = "Nv.1"
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl_player_level_badge, 7, HunterUIStyle.COLOR_TEXT_PRIMARY)
	hbox_header.add_child(lbl_player_level_badge)

	lbl_gold = Label.new()
	lbl_gold.text = "💰0"
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl_gold, 7, HunterUIStyle.COLOR_TEXT_PRIMARY)
	hbox_header.add_child(lbl_gold)

	var hbox_sub := HBoxContainer.new()
	vbox_header.add_child(hbox_sub)

	lbl_player_affinity = Label.new()
	lbl_player_affinity.text = "◈ Nen: Adormecido"
	HunterUIStyle.aplicar_fonte_licenca(lbl_player_affinity, 8, HunterUIStyle.COLOR_TEXT_CYAN)
	lbl_player_affinity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_sub.add_child(lbl_player_affinity)

	lbl_sp_badge = Label.new()
	lbl_sp_badge.text = "⚡0 SP"
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl_sp_badge, 6, HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_sp_badge.visible = false
	hbox_sub.add_child(lbl_sp_badge)

	# Barras em frames separados (gap visual entre elas)
	var hp_box := _criar_barra_framed(
		"❤",
		HunterUIStyle.COLOR_HP_CRIMSON,
		"100/100"
	)
	root.add_child(hp_box.container)
	bar_hp = hp_box.bar
	lbl_hp_num = hp_box.label

	var aura_box := _criar_barra_framed(
		"⚡",
		HunterUIStyle.COLOR_AURA_BAR,
		"100/100"
	)
	root.add_child(aura_box.container)
	bar_aura = aura_box.bar
	lbl_aura_num = aura_box.label

	var xp_box := _criar_barra_framed(
		"✦",
		HunterUIStyle.COLOR_XP_BAR,
		"0/100"
	)
	root.add_child(xp_box.container)
	bar_xp = xp_box.bar
	lbl_xp_num = xp_box.label

	# Status Nen / Besta — sem painel "INATIVO [N]" no HUD principal
	lbl_nen_status = null
	lbl_beast_status = null

	hbox_conditions = HBoxContainer.new()
	hbox_conditions.add_theme_constant_override("separation", 2)
	root.add_child(hbox_conditions)


func _criar_barra_framed(titulo: String, cor_fill: Color, texto_inicial: String) -> Dictionary:
	# Compacto p/ 640×360 — afine BAR_W/H e SLOT_* se ainda não encaixar
	const BAR_W := 112.0
	const BAR_H := 22.0
	const SLOT_L := 0.36
	const SLOT_R := 0.16
	const SLOT_T := 0.38
	const SLOT_B := 0.38

	var root := Control.new()
	root.custom_minimum_size = Vector2(BAR_W, BAR_H)
	root.size = Vector2(BAR_W, BAR_H)
	root.clip_contents = true
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var fill_col := Color(0.82, 0.14, 0.22)
	if cor_fill.b > 0.55 and cor_fill.r < 0.55:
		fill_col = Color(0.18, 0.48, 0.95)
	elif cor_fill.g > 0.5 and cor_fill.r < 0.55:
		fill_col = Color(0.18, 0.72, 0.32)
	elif cor_fill.r > 0.55:
		fill_col = Color(0.82, 0.14, 0.22)

	# 1) Frame base
	var frame_tex: Texture2D = null
	if ResourceLoader.exists("res://assets/sprites/ui/hud_ornate_bar_compact.png"):
		frame_tex = load("res://assets/sprites/ui/hud_ornate_bar_compact.png")
	elif ResourceLoader.exists("res://assets/sprites/ui/hud_ornate_bar_frame_crop.png"):
		frame_tex = load("res://assets/sprites/ui/hud_ornate_bar_frame_crop.png")
	elif ResourceLoader.exists("res://assets/sprites/ui/hud_ornate_bar_frame.png"):
		frame_tex = load("res://assets/sprites/ui/hud_ornate_bar_frame.png")

	if frame_tex != null:
		var frame_spr := TextureRect.new()
		frame_spr.name = "OrnateFrame"
		frame_spr.texture = frame_tex
		frame_spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame_spr.stretch_mode = TextureRect.STRETCH_SCALE
		frame_spr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame_spr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		root.add_child(frame_spr)
	else:
		var panel := PanelContainer.new()
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_barra_frame_texturado())
		root.add_child(panel)

	# 2) Fill no slot creme — corner radius 2 p/ acompanhar o frame arredondado
	var bar_wrap := Control.new()
	bar_wrap.name = "BarSlot"
	bar_wrap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar_wrap.offset_left = BAR_W * SLOT_L
	bar_wrap.offset_top = BAR_H * SLOT_T
	bar_wrap.offset_right = -BAR_W * SLOT_R
	bar_wrap.offset_bottom = -BAR_H * SLOT_B
	bar_wrap.clip_contents = true
	root.add_child(bar_wrap)

	var bar := ProgressBar.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar.custom_minimum_size = Vector2(0, 0)
	bar.show_percentage = false
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 100
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var st_bg := StyleBoxFlat.new()
	st_bg.bg_color = Color(0.12, 0.09, 0.06, 0.85)
	st_bg.set_content_margin_all(0)
	st_bg.set_border_width_all(0)
	st_bg.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", st_bg)

	var st_fill := StyleBoxFlat.new()
	st_fill.bg_color = fill_col
	st_fill.set_content_margin_all(0)
	st_fill.set_corner_radius_all(2)
	st_fill.border_width_top = 1
	st_fill.border_width_bottom = 1
	st_fill.border_color = Color(
		clampf(fill_col.r * 1.35, 0.0, 1.0),
		clampf(fill_col.g * 1.3, 0.0, 1.0),
		clampf(fill_col.b * 1.2, 0.0, 1.0),
		1.0
	)
	bar.add_theme_stylebox_override("fill", st_fill)
	bar_wrap.add_child(bar)

	# 3) Números no slot — formato 120/122
	var lbl := Label.new()
	lbl.text = texto_inicial
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.offset_left = BAR_W * SLOT_L
	lbl.offset_top = BAR_H * (SLOT_T - 0.06)
	lbl.offset_right = -BAR_W * SLOT_R
	lbl.offset_bottom = -BAR_H * (SLOT_B - 0.06)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.clip_text = true
	lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 5, Color(0.06, 0.03, 0.02))
	lbl.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.98))
	lbl.add_theme_constant_override("outline_size", 1)
	root.add_child(lbl)

	# 4) Ícone no círculo
	var lbl_icon := Label.new()
	lbl_icon.text = titulo
	lbl_icon.set_anchors_preset(Control.PRESET_TOP_LEFT)
	lbl_icon.offset_left = 1
	lbl_icon.offset_top = BAR_H * 0.18
	lbl_icon.offset_right = BAR_W * 0.32
	lbl_icon.offset_bottom = BAR_H * 0.82
	lbl_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl_icon, 7, Color(0.95, 0.2, 0.25) if fill_col.r > 0.5 else Color(0.95, 0.9, 0.35))
	lbl_icon.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.0, 1.0))
	lbl_icon.add_theme_constant_override("outline_size", 1)
	root.add_child(lbl_icon)

	return {"container": root, "bar": bar, "label": lbl}


func _criar_barra_com_label(cor_fill: Color, cor_bg: Color, texto_inicial: String) -> Dictionary:
	# Compat: redireciona para o novo frame madeira
	return _criar_barra_framed("BAR", cor_fill, texto_inicial)


# ============================================================
# BOSS BAR (TOPO DA TELA)
# ============================================================

func _criar_boss_bar() -> void:
	boss_bar_panel = PanelContainer.new()
	boss_bar_panel.custom_minimum_size = Vector2(210, 22)
	boss_bar_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_bar_panel.offset_left = -105.0
	boss_bar_panel.offset_right = 105.0
	boss_bar_panel.offset_top = 6.0
	boss_bar_panel.visible = false
	boss_bar_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_boss_banner())
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
	HunterUIStyle.aplicar_fonte_titulo(lbl_boss_name, 13, HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_boss_name)

	var bar_box := Control.new()
	bar_box.custom_minimum_size = Vector2(196, 8)
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
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl_boss_hp, 7, HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_boss_hp.add_theme_color_override("font_shadow_color", Color.BLACK)
	bar_box.add_child(lbl_boss_hp)

	# Barra de Defesa / Guarda do Chefe
	var def_box := Control.new()
	def_box.custom_minimum_size = Vector2(196, 6)
	vbox.add_child(def_box)

	boss_def_bar = ProgressBar.new()
	boss_def_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	boss_def_bar.show_percentage = false
	boss_def_bar.add_theme_stylebox_override("background", HunterUIStyle.criar_style_progress_bg())
	boss_def_bar.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_AURA_CYAN))
	def_box.add_child(boss_def_bar)

	lbl_boss_def = Label.new()
	lbl_boss_def.text = "DEFESA"
	lbl_boss_def.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl_boss_def.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_boss_def.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl_boss_def, 6, HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_boss_def.add_theme_color_override("font_shadow_color", Color.BLACK)
	def_box.add_child(lbl_boss_def)


func notificar_boss_status(nome: String, hp: int, max_hp: int, def_val: float = -1.0, max_def: float = -1.0, quebrada: bool = false) -> void:
	if boss_bar_panel == null: return
	boss_bar_panel.visible = true
	lbl_boss_name.text = "👑 " + nome.to_upper()
	boss_hp_bar.max_value = max(1, max_hp)
	boss_hp_bar.value = clamp(hp, 0, max_hp)
	var pct: int = int((float(hp) / float(max(1, max_hp))) * 100.0)
	lbl_boss_hp.text = "%s / %s (%d%%)" % [_formatar_numero(hp), _formatar_numero(max_hp), pct]

	if boss_def_bar != null and def_val >= 0.0 and max_def > 0.0:
		boss_def_bar.max_value = max_def
		boss_def_bar.value = clamp(def_val, 0.0, max_def)
		if quebrada or def_val <= 0.0:
			lbl_boss_def.text = "💥 DEFESA QUEBRADA! (VULNERÁVEL)"
			lbl_boss_def.modulate = Color(1.0, 0.35, 0.35, 1.0)
			boss_def_bar.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(Color(1.0, 0.25, 0.25, 0.85)))
		else:
			var pct_def: int = int((def_val / max_def) * 100.0)
			lbl_boss_def.text = "🛡️ DEFESA: %d%%" % pct_def
			lbl_boss_def.modulate = Color.WHITE
			boss_def_bar.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_progress_fill(HunterUIStyle.COLOR_AURA_CYAN))

	if hp <= 0:
		esconder_boss_bar()


func registrar_boss(es: Node) -> void:
	if es == null: return
	var e_name = es.get("enemy_name") if es.get("enemy_name") != null else "CHEFE"
	var cur_hp = es.get("health") if es.get("health") != null else 100
	var m_hp = es.get("max_health") if es.get("max_health") != null else 100
	var cur_def = float(es.get("defesa_barra_atual")) if es.get("defesa_barra_atual") != null else -1.0
	var m_def = float(es.get("defesa_barra_max")) if es.get("defesa_barra_max") != null else -1.0
	var is_brk = bool(es.get("em_defesa_quebrada")) if es.get("em_defesa_quebrada") != null else false
	notificar_boss_status(str(e_name), int(cur_hp), int(m_hp), cur_def, m_def, is_brk)

	if es.has_signal("health_changed"):
		es.health_changed.connect(func(c_hp, max_h):
			var b_cur_def = float(es.get("defesa_barra_atual")) if es.get("defesa_barra_atual") != null else -1.0
			var b_m_def = float(es.get("defesa_barra_max")) if es.get("defesa_barra_max") != null else -1.0
			var b_is_brk = bool(es.get("em_defesa_quebrada")) if es.get("em_defesa_quebrada") != null else false
			notificar_boss_status(str(e_name), int(c_hp), int(max_h), b_cur_def, b_m_def, b_is_brk)
		)
	if es.has_signal("defesa_alterada"):
		es.defesa_alterada.connect(func(c_def, m_def_val):
			var b_cur_hp = int(es.get("health")) if es.get("health") != null else 0
			var b_m_hp = int(es.get("max_health")) if es.get("max_health") != null else 100
			var b_is_brk = bool(es.get("em_defesa_quebrada")) if es.get("em_defesa_quebrada") != null else false
			notificar_boss_status(str(e_name), b_cur_hp, b_m_hp, float(c_def), float(m_def_val), b_is_brk)
		)
	if es.has_signal("defesa_quebrada"):
		es.defesa_quebrada.connect(func():
			var b_cur_hp = int(es.get("health")) if es.get("health") != null else 0
			var b_m_hp = int(es.get("max_health")) if es.get("max_health") != null else 100
			var b_m_def = float(es.get("defesa_barra_max")) if es.get("defesa_barra_max") != null else 100.0
			notificar_boss_status(str(e_name), b_cur_hp, b_m_hp, 0.0, b_m_def, true)
		)
	if es.has_signal("defesa_restaurada"):
		es.defesa_restaurada.connect(func():
			var b_cur_hp = int(es.get("health")) if es.get("health") != null else 0
			var b_m_hp = int(es.get("max_health")) if es.get("max_health") != null else 100
			var b_m_def = float(es.get("defesa_barra_max")) if es.get("defesa_barra_max") != null else 100.0
			notificar_boss_status(str(e_name), b_cur_hp, b_m_hp, b_m_def, b_m_def, false)
		)
	if es.has_signal("died"):
		es.died.connect(func(_t):
			esconder_boss_bar()
		)


func esconder_boss_bar() -> void:
	if boss_bar_panel != null:
		boss_bar_panel.visible = false


# ============================================================
# HOTBAR DE HATSU (ESTILO ACTION BAR COMPACTA)
# ============================================================

func _criar_painel_hatsu_slots() -> void:
	if hatsu_slots_container != null:
		return

	var margin_bottom := MarginContainer.new()
	margin_bottom.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	margin_bottom.offset_left = -62.0
	margin_bottom.offset_right = 62.0
	margin_bottom.offset_top = -34.0
	margin_bottom.offset_bottom = -6.0
	margin_bottom.custom_minimum_size = Vector2(124, 28)
	margin_bottom.add_theme_constant_override("margin_bottom", 0)
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
		panel.custom_minimum_size = Vector2(28, 26)
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 3))

		var slot_box := Control.new()
		slot_box.custom_minimum_size = Vector2(26, 24)
		panel.add_child(slot_box)

		# Overlay de Cooldown
		var cd_overlay := ColorRect.new()
		cd_overlay.color = Color(0.0, 0.0, 0.0, 0.72)
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
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl_num, 7, HunterUIStyle.COLOR_GOLD_LIGHT)
		lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_num)

		# Nome do Hatsu
		var lbl_name := Label.new()
		lbl_name.text = "-"
		HunterUIStyle.aplicar_fonte_licenca(lbl_name, 8, HunterUIStyle.COLOR_TEXT_PRIMARY)
		lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_name)
		slot_name_labels.append(lbl_name)

		# Custo de Aura (ex: 45 AP)
		var lbl_cost := Label.new()
		lbl_cost.text = ""
		HunterUIStyle.aplicar_fonte_pixel(lbl_cost, 6, HunterUIStyle.COLOR_AURA_CYAN)
		lbl_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_cost)
		slot_cost_labels.append(lbl_cost)

		# Texto de Cooldown (ex: 3.5s)
		var lbl_cd := Label.new()
		lbl_cd.text = ""
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl_cd, 8, HunterUIStyle.COLOR_GOLD)
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
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player != null:
			xp_system = player.get_node_or_null("XPSystem") as XPSystem
			hatsu_system = player.get_node_or_null("HatsuSystem") as HatsuSystem
			nen_system = player.get_node_or_null("NenSystem") as NenSystem

			if xp_system != null:
				if not xp_system.level_up.is_connected(_on_level_up):
					xp_system.level_up.connect(_on_level_up)
				if not xp_system.xp_changed.is_connected(_on_xp_changed):
					xp_system.xp_changed.connect(_on_xp_changed)
				if not xp_system.skill_points_changed.is_connected(_on_sp_changed):
					xp_system.skill_points_changed.connect(_on_sp_changed)

			if hatsu_system != null:
				if not hatsu_system.hatsu_falhou.is_connected(_on_hatsu_falhou):
					hatsu_system.hatsu_falhou.connect(_on_hatsu_falhou)

	if SaveManager != null and not SaveManager.jogo_carregado.is_connected(_on_save_carregado):
		SaveManager.jogo_carregado.connect(_on_save_carregado)

	if PlayerData != null and not PlayerData.nivel_alterado.is_connected(_on_level_up):
		PlayerData.nivel_alterado.connect(_on_level_up)


func _process(_delta: float) -> void:
	_conectar_player_e_sistemas()
	_atualizar_hud()


func _atualizar_hud() -> void:

	_atualizar_header_e_gold()
	_atualizar_hp()
	_atualizar_aura()
	_atualizar_xp()
	_atualizar_nen_e_besta()
	_atualizar_condicoes_combate()
	_atualizar_hatsu_slots()


func _atualizar_header_e_gold() -> void:
	var nivel: int = 1
	if player != null and is_instance_valid(player) and player.has_method("obter_nivel"):
		nivel = player.obter_nivel()
	elif xp_system != null and is_instance_valid(xp_system):
		nivel = xp_system.obter_level()
	elif PlayerData != null:
		nivel = int(PlayerData.attributes.get("nivel", 1))

	var nome: String = PlayerData.nome_personagem if (PlayerData != null and not PlayerData.nome_personagem.is_empty()) else "Hunter"

	if lbl_player_header:
		# Cabeçalho MMORPG: nome + nível no mesmo label (suíte Nen HUD / legibilidade).
		lbl_player_header.text = "🔰 %s  ·  Nv. %d" % [nome, nivel]

	if lbl_player_level_badge:
		lbl_player_level_badge.text = "★ Nv. %d" % nivel

	# Sincronizar também o LevelLabel do MarginContainer em HUD.tscn para compatibilidade total
	var legacy_lvl = get_node_or_null("MarginContainer/VBoxContainer/LevelLabel") as Label
	if legacy_lvl != null:
		legacy_lvl.text = "Lv. %d" % nivel

	if lbl_player_affinity:
		if PlayerData.despertou_nen:
			var af_nome: String = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
			lbl_player_affinity.text = "◈ Nen: %s" % af_nome
			lbl_player_affinity.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
		else:
			lbl_player_affinity.text = "◈ Aura Adormecida"
			lbl_player_affinity.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)

	if lbl_sp_badge:
		var sp: int = PlayerData.nen_skill_points
		if sp > 0:
			if PlayerData.despertou_nen:
				lbl_sp_badge.text = "⚡ %d SP [N]" % sp
			else:
				# SP acumula desde o lv1; só gasta após despertar Nen (Arena Celestial)
				lbl_sp_badge.text = "🔒 %d SP (Arena)" % sp
			lbl_sp_badge.visible = true
		else:
			lbl_sp_badge.visible = false

	if lbl_gold:
		var gold: int = Economy.obter_gold()
		lbl_gold.text = "💰 %s J" % _formatar_numero(gold)


func _atualizar_condicoes_combate() -> void:
	if hbox_conditions == null:
		return
	for child in hbox_conditions.get_children():
		child.queue_free()

	var condicoes_ativas: Array[Dictionary] = []

	# 1. Bloodied (<35% HP)
	var hp: float = float(PlayerData.attributes.get("vida", 100))
	var hp_max: float = max(1.0, float(PlayerData.attributes.get("vida_max", 100)))
	if (hp / hp_max) < 0.35:
		condicoes_ativas.append({"nome": "🩸 Bloodied", "cor": Color(1.0, 0.25, 0.25, 0.9)})

	# 2. Em Zetsu / Furtivo
	if nen_system != null and nen_system.tecnica_ativa(NenSystem.Tecnica.ZETSU):
		condicoes_ativas.append({"nome": "🍃 Oculto (Zetsu)", "cor": Color(0.3, 0.9, 0.4, 0.9)})

	# 3. Em En
	if nen_system != null and nen_system.has_method("tecnica_ativa") and nen_system.tecnica_ativa(NenSystem.Tecnica.EN):
		condicoes_ativas.append({"nome": "🌐 Campo En", "cor": HunterUIStyle.COLOR_AURA_CYAN})

	# 4. Godspeed Ativo
	if PlayerData.quest_states.get("godspeed_ativo", false):
		condicoes_ativas.append({"nome": "⚡ Godspeed", "cor": Color(0.2, 0.95, 1.0, 1.0)})

	# 5. Guanyin Bodhisattva Ativo
	if PlayerData.quest_states.get("guanyin_bodhisattva_ativo", false):
		condicoes_ativas.append({"nome": "🙏 Bodhisattva", "cor": HunterUIStyle.COLOR_GOLD_LIGHT})

	# Pílulas compactas de status (NÃO alimentam o tracker de requisitos de Hatsu)
	for c in condicoes_ativas:
		var pill := PanelContainer.new()
		var st := StyleBoxFlat.new()
		st.bg_color = Color(c["cor"].r * 0.2, c["cor"].g * 0.2, c["cor"].b * 0.2, 0.85)
		st.border_color = c["cor"]
		st.border_width_left = 1
		st.border_width_top = 1
		st.border_width_right = 1
		st.border_width_bottom = 1
		st.corner_radius_top_left = 2
		st.corner_radius_top_right = 2
		st.corner_radius_bottom_right = 2
		st.corner_radius_bottom_left = 2
		pill.add_theme_stylebox_override("panel", st)

		var lbl := Label.new()
		lbl.text = c["nome"]
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.add_theme_color_override("font_color", c["cor"])
		pill.add_child(lbl)
		hbox_conditions.add_child(pill)

	_atualizar_tracker_requisitos_hatsu()


func _atualizar_tracker_requisitos_hatsu() -> void:
	## Tracker inferior-esquerdo: só quando um Hatsu com condições/juramentos está em uso.
	if condition_tracker == null:
		return

	var hatsu_ativo: Resource = _obter_hatsu_condicional_ativo()
	if hatsu_ativo == null:
		if condition_tracker.has_method("limpar"):
			condition_tracker.limpar()
		else:
			condition_tracker.visible = false
		return

	var contexto: Dictionary = {}
	if CombatEngine != null and CombatEngine.has_method("construir_contexto_combate"):
		var player_ref = get_tree().get_first_node_in_group("player") if get_tree() != null else null
		contexto = CombatEngine.construir_contexto_combate(player_ref)

	if condition_tracker.has_method("rastrear_hatsu"):
		condition_tracker.rastrear_hatsu(hatsu_ativo, contexto)
	else:
		condition_tracker.visible = false


func _obter_hatsu_condicional_ativo() -> Resource:
	if PlayerData == null or not PlayerData.hatsu_desbloqueado:
		return null

	var candidatos: Array = []
	if HatsuManager != null and HatsuManager.has_method("obter_hatsus_ativos_sustentados"):
		candidatos = HatsuManager.obter_hatsus_ativos_sustentados()
	elif PlayerData.has_method("obter_hatsu_slot"):
		for i in range(4):
			var h = PlayerData.obter_hatsu_slot(i)
			if h != null:
				candidatos.append(h)

	for hatsu in candidatos:
		if hatsu == null:
			continue
		var tem_cond := false
		if "gameplay_conditions" in hatsu and hatsu.gameplay_conditions is Array and not hatsu.gameplay_conditions.is_empty():
			tem_cond = true
		elif "conditions" in hatsu and hatsu.conditions is Array and not hatsu.conditions.is_empty():
			tem_cond = true
		elif "condicoes" in hatsu and hatsu.condicoes is Array and not hatsu.condicoes.is_empty():
			tem_cond = true
		elif "modular_conditions" in hatsu and hatsu.modular_conditions is Array and not hatsu.modular_conditions.is_empty():
			tem_cond = true
		if tem_cond:
			return hatsu
	return null



func _atualizar_hp() -> void:
	if bar_hp == null or lbl_hp_num == null: return
	var hp: int = int(PlayerData.attributes.get("vida", 100))
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	bar_hp.max_value = max(1, hp_max)
	bar_hp.value = clamp(hp, 0, hp_max)
	lbl_hp_num.text = "%s/%s" % [_formatar_numero(hp), _formatar_numero(hp_max)]

	var legacy_hp = get_node_or_null("MarginContainer/VBoxContainer/HPBar") as ProgressBar
	if legacy_hp != null:
		legacy_hp.max_value = bar_hp.max_value
		legacy_hp.value = bar_hp.value


func _atualizar_aura() -> void:
	if bar_aura == null or lbl_aura_num == null: return
	var aura: int = int(PlayerData.attributes.get("aura", 0))
	var aura_max: int = int(PlayerData.attributes.get("aura_max", 100))
	bar_aura.max_value = max(1, aura_max)
	bar_aura.value = clamp(aura, 0, aura_max)
	lbl_aura_num.text = "%s/%s" % [_formatar_numero(aura), _formatar_numero(aura_max)]

	var legacy_aura = get_node_or_null("MarginContainer/VBoxContainer/AuraBar") as ProgressBar
	if legacy_aura != null:
		legacy_aura.max_value = bar_aura.max_value
		legacy_aura.value = bar_aura.value


func _atualizar_xp() -> void:
	if bar_xp == null or lbl_xp_num == null: return
	var nivel: int = int(PlayerData.attributes.get("nivel", 1))
	if player != null and is_instance_valid(player) and player.has_method("obter_nivel"):
		nivel = player.obter_nivel()

	var xp_atual: int = 0
	var xp_nec: int = 100
	if xp_system != null and is_instance_valid(xp_system):
		xp_atual = xp_system.obter_xp()
		xp_nec = max(1, xp_system.obter_xp_necessario())
	else:
		xp_atual = int(PlayerData.attributes.get("xp", 0))
		xp_nec = max(1, ProgressionConfig.calcular_xp_necessario(nivel))

	if nivel >= ProgressionConfig.MAX_LEVEL:
		bar_xp.max_value = xp_nec
		bar_xp.value = xp_nec
		lbl_xp_num.text = "MAX"
	else:
		bar_xp.max_value = xp_nec
		bar_xp.value = clamp(xp_atual, 0, xp_nec)
		lbl_xp_num.text = "%s/%s" % [_formatar_numero(xp_atual), _formatar_numero(xp_nec)]

	var legacy_xp = get_node_or_null("MarginContainer/VBoxContainer/XPBar") as ProgressBar
	if legacy_xp != null:
		legacy_xp.max_value = bar_xp.max_value
		legacy_xp.value = bar_xp.value


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
	if AudioManager != null:
		AudioManager.tocar_ui_click(true)
	exibir_notificacao(mensagem)


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

		var is_unlocked: bool = HatsuProgressionManager == null or HatsuProgressionManager.is_slot_unlocked(i + 1)
		if not is_unlocked:
			slot_name_labels[i].text = "🔒"
			slot_name_labels[i].add_theme_color_override("font_color", Color(0.6, 0.35, 0.35, 0.8))
			slot_panels[i].add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(Color(0.35, 0.15, 0.15, 0.5), 3))
			if i < slot_cost_labels.size():
				slot_cost_labels[i].visible = false
		elif hatsu != null:
			var prefix: String = "★" if hatsu.is_mastered() else ""
			slot_name_labels[i].text = prefix + hatsu.nome.left(6 - prefix.length())
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
					slot_cost_labels[i].text = "0/1 COND"
					slot_cost_labels[i].add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
					slot_cost_labels[i].visible = true
				else:
					var ap_custo: int = int(hatsu.obter_custo_final())
					if cd_atual <= 0.0:
						slot_cost_labels[i].text = "PRONTO (%d)" % ap_custo
						slot_cost_labels[i].add_theme_color_override("font_color", Color(0.4, 1.0, 0.65))
					else:
						slot_cost_labels[i].text = "%d AP" % ap_custo
						slot_cost_labels[i].add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
					slot_cost_labels[i].visible = (cd_atual <= 0.0)
		else:
			slot_name_labels[i].text = "-"
			slot_name_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
			if i < slot_cost_labels.size():
				slot_cost_labels[i].text = ""
			slot_panels[i].add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 3))

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




func _on_hatsu_falhou(slot: int, motivo: String) -> void:
	if AudioManager != null:
		AudioManager.tocar_ui_error()

	if slot >= 0 and slot < slot_panels.size():
		var panel = slot_panels[slot]
		var orig_pos_x: float = panel.position.x
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(Color(1.0, 0.2, 0.2, 0.95), 3))
		var tw = panel.create_tween()
		tw.tween_property(panel, "position:x", orig_pos_x - 3.0, 0.04)
		tw.tween_property(panel, "position:x", orig_pos_x + 3.0, 0.04)
		tw.tween_property(panel, "position:x", orig_pos_x, 0.04)
		tw.chain().tween_callback(func():
			if is_instance_valid(panel):
				_atualizar_selecao_slots()
		)

	exibir_notificacao("⚠️ %s" % motivo)


func _on_level_up(new_level: int) -> void:
	print("HUD: LEVEL UP -> ", new_level)
	exibir_notificacao("✨ NÍVEL UP! Você alcançou o Nível %d!" % new_level)
	_atualizar_hud()


func _on_xp_changed(_cur_xp: int, _req_xp: int) -> void:
	_atualizar_xp()


func _on_sp_changed(_sp: int) -> void:
	_atualizar_header_e_gold()


func _on_save_carregado(_slot: int) -> void:
	_atualizar_hud()


var _notif_stack_container: VBoxContainer = null


func _garantir_notif_stack() -> VBoxContainer:
	if _notif_stack_container != null and is_instance_valid(_notif_stack_container):
		return _notif_stack_container

	var root_ctrl := Control.new()
	root_ctrl.name = "NotificationRoot"
	root_ctrl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ctrl)

	_notif_stack_container = VBoxContainer.new()
	_notif_stack_container.name = "NotificationStack"
	_notif_stack_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_notif_stack_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_notif_stack_container.custom_minimum_size = Vector2(240, 0)
	_notif_stack_container.offset_top = 8.0
	_notif_stack_container.offset_left = -120.0
	_notif_stack_container.offset_right = 120.0
	_notif_stack_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_notif_stack_container.add_theme_constant_override("separation", 3)
	root_ctrl.add_child(_notif_stack_container)
	return _notif_stack_container


func exibir_notificacao(texto: String) -> void:
	var container := _garantir_notif_stack()
	if container == null:
		return

	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = Vector2(225, 18)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.12, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.95, 0.8, 0.25, 0.95)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	panel.add_child(margin)

	var notif := Label.new()
	notif.text = texto
	notif.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notif.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notif.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notif.add_theme_font_size_override("font_size", 6)
	notif.add_theme_color_override("font_color", Color(1.0, 0.92, 0.5, 1.0))
	notif.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	notif.add_theme_constant_override("shadow_offset_x", 1)
	notif.add_theme_constant_override("shadow_offset_y", 1)
	margin.add_child(notif)

	container.add_child(panel)
	panel.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	tween.tween_interval(3.2)
	tween.tween_property(panel, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(func():
		if is_instance_valid(panel):
			panel.queue_free()
	)
