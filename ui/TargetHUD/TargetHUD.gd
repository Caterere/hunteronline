class_name TargetHUD
extends Control

# ============================================================
# HUNTER ONLINE - TARGET HUD & FEEDBACK CONTEXTUAL (FASE 10)
# ============================================================
#
# Exibe informações do alvo atualmente focado/bloqueado:
# - Nome, Nível e Indicador de Chefe (Boss Badge)
# - Barra de Vida (HP) e Barra de Postura / Stagger
# - Afinidade Canônica de Nen
# - Tags de Fraqueza, Resistência e Imunidade (via GameplayTags)
# - Badges visuais quando condições contextuais forem ativas
# ============================================================

var current_target: Node = null

var panel_container: PanelContainer
var lbl_name: Label
var lbl_affinity: Label
var hp_bar: ProgressBar
var posture_bar: ProgressBar
var tags_hbox: HBoxContainer
var status_effects_hbox: HBoxContainer
var lbl_boss_phase: Label
var lbl_hp_val: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_construir_ui()

	if EventBus != null:
		EventBus.target_changed.connect(focar_alvo)
		EventBus.target_cleared.connect(limpar_alvo)
		if EventBus.has_signal("enemy_damaged"):
			EventBus.enemy_damaged.connect(_on_enemy_damaged)
		if EventBus.has_signal("enemy_defeated"):
			EventBus.enemy_defeated.connect(func(_id, _xp, _nxp): limpar_alvo())

func _construir_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	panel_container = PanelContainer.new()
	panel_container.custom_minimum_size = Vector2(240, 52)
	panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_container.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 3))
	center.add_child(panel_container)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_container.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	# Linha 1: Nome, Nível e Afinidade
	var hbox_hdr := HBoxContainer.new()
	hbox_hdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(hbox_hdr)

	lbl_name = Label.new()
	lbl_name.text = "Inimigo"
	lbl_name.add_theme_font_size_override("font_size", 5)
	lbl_name.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	hbox_hdr.add_child(lbl_name)

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_hdr.add_child(sp)

	lbl_affinity = Label.new()
	lbl_affinity.text = "Nen: Desconhecido"
	lbl_affinity.add_theme_font_size_override("font_size", 4)
	lbl_affinity.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	hbox_hdr.add_child(lbl_affinity)

	# Linha 1.5: Badges de Boss Phase e Elite
	var hbox_phase := HBoxContainer.new()
	hbox_phase.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox_phase.add_theme_constant_override("separation", 3)
	vbox.add_child(hbox_phase)

	lbl_boss_phase = Label.new()
	lbl_boss_phase.visible = false
	lbl_boss_phase.text = "PHASE I"
	lbl_boss_phase.add_theme_font_size_override("font_size", 4)
	lbl_boss_phase.add_theme_color_override("font_color", HunterUIStyle.COLOR_HP_CRIMSON)
	hbox_phase.add_child(lbl_boss_phase)

	lbl_hp_val = Label.new()
	lbl_hp_val.text = "100 / 100"
	lbl_hp_val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_hp_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_hp_val.add_theme_font_size_override("font_size", 4)
	lbl_hp_val.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	hbox_phase.add_child(lbl_hp_val)

	# Linha 2: Barra de HP
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(0, 7)
	hp_bar.show_percentage = false
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_box(Color(0.85, 0.2, 0.2, 0.95), Color(0.9, 0.3, 0.3, 1.0), 1))
	vbox.add_child(hp_bar)

	# Linha 3: Barra de Postura (Stagger)
	posture_bar = ProgressBar.new()
	posture_bar.custom_minimum_size = Vector2(0, 4)
	posture_bar.show_percentage = false
	posture_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	posture_bar.add_theme_stylebox_override("fill", HunterUIStyle.criar_style_box(Color(0.9, 0.8, 0.2, 0.9), Color(1.0, 0.9, 0.3, 1.0), 1))
	vbox.add_child(posture_bar)

	# Linha 4: Tags de Fraqueza, Resistência e Status
	var hbox_bottom := HBoxContainer.new()
	hbox_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(hbox_bottom)

	tags_hbox = HBoxContainer.new()
	tags_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tags_hbox.add_theme_constant_override("separation", 2)
	hbox_bottom.add_child(tags_hbox)

	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_bottom.add_child(sp2)

	status_effects_hbox = HBoxContainer.new()
	status_effects_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_effects_hbox.add_theme_constant_override("separation", 2)
	hbox_bottom.add_child(status_effects_hbox)

func focar_alvo(alvo: Node) -> void:
	if alvo == null or not is_instance_valid(alvo):
		limpar_alvo()
		return

	current_target = alvo
	visible = true
	_atualizar_dados_alvo()

func limpar_alvo() -> void:
	current_target = null
	visible = false

func _on_enemy_damaged(enemy_node: Node, _cur_hp: int, _max_hp: int) -> void:
	if enemy_node == current_target or (current_target != null and enemy_node == current_target.get_parent()):
		_atualizar_dados_alvo()

func _process(_delta: float) -> void:
	if not visible or current_target == null or not is_instance_valid(current_target):
		return
	_atualizar_dados_alvo()

func _atualizar_dados_alvo() -> void:
	if current_target == null or not is_instance_valid(current_target):
		limpar_alvo()
		return

	var enemy_sys = current_target.get_node_or_null("EnemySystem") if current_target.has_node("EnemySystem") else current_target as EnemySystem
	var enemy_data = enemy_sys.enemy_data if (enemy_sys != null and "enemy_data" in enemy_sys) else null

	# Nome e Título
	var t_name: String = "Inimigo"
	if enemy_sys != null and not enemy_sys.enemy_name.is_empty():
		t_name = enemy_sys.enemy_name
	elif enemy_data != null and not enemy_data.enemy_name.is_empty():
		t_name = enemy_data.enemy_name
	elif "name" in current_target:
		t_name = current_target.name

	var is_boss: bool = (enemy_sys != null and ("is_boss" in enemy_sys and enemy_sys.is_boss)) or (enemy_data != null and ("is_boss" in enemy_data and enemy_data.is_boss))
	var is_elite: bool = (enemy_data != null and ("is_elite" in enemy_data and enemy_data.is_elite)) or ("is_elite" in current_target and current_target.is_elite)

	# Vida
	var cur_hp: float = 100.0
	var max_hp: float = 100.0
	if enemy_sys != null:
		cur_hp = float(enemy_sys.health)
		max_hp = max(1.0, float(enemy_sys.max_health))
	elif "current_hp" in current_target and "max_hp" in current_target:
		cur_hp = float(current_target.current_hp)
		max_hp = max(1.0, float(current_target.max_hp))

	if cur_hp <= 0.0:
		limpar_alvo()
		return

	if is_boss:
		lbl_name.text = "👑 [BOSS] " + t_name
		var phase_idx: int = 1
		var enemy_ai = current_target.get_node_or_null("EnemyAI")
		if enemy_ai != null and "boss_phase_index" in enemy_ai:
			phase_idx = enemy_ai.boss_phase_index + 1
		elif enemy_data != null and not enemy_data.boss_phases.is_empty():
			var pct_hp: float = cur_hp / max_hp
			for i in range(enemy_data.boss_phases.size()):
				if pct_hp <= enemy_data.boss_phases[i].hp_threshold:
					phase_idx = i + 2
		lbl_boss_phase.text = "⚔️ FASE " + ("I" if phase_idx == 1 else "II" if phase_idx == 2 else "III")
		lbl_boss_phase.visible = true
	elif is_elite:
		lbl_name.text = "⭐ [ELITE] " + t_name
		lbl_boss_phase.text = "⭐ ELITE"
		lbl_boss_phase.visible = true
	else:
		lbl_name.text = "⚔️ " + t_name
		lbl_boss_phase.visible = false

	if lbl_hp_val != null:
		var pct_hp_val: int = int((cur_hp / max_hp) * 100.0)
		lbl_hp_val.text = "%d / %d (%d%%)" % [int(cur_hp), int(max_hp), pct_hp_val]

	hp_bar.max_value = max_hp
	hp_bar.value = cur_hp

	# Postura / Stagger
	if enemy_sys != null:
		posture_bar.max_value = enemy_sys.postura_max
		posture_bar.value = enemy_sys.postura
		posture_bar.visible = true
	else:
		posture_bar.visible = false

	# Afinidade de Nen
	if enemy_data != null and enemy_data.nen_type >= 0:
		lbl_affinity.text = "Nen: %s" % NenAffinityData.obter_nome_afinidade(enemy_data.nen_type)
	elif enemy_sys != null and not enemy_sys.categoria_nen_info.is_empty():
		lbl_affinity.text = "Nen: %s" % enemy_sys.categoria_nen_info
	else:
		lbl_affinity.text = ""

	# Atualizar Badges de Fraquezas & Resistências
	for c in tags_hbox.get_children():
		c.queue_free()

	if enemy_data != null:
		for w in enemy_data.weakness_tags:
			_adicionar_badge_tag(tags_hbox, "Fraq: " + w, Color(0.9, 0.3, 0.3, 0.9))
		for r in enemy_data.resistance_tags:
			_adicionar_badge_tag(tags_hbox, "Res: " + r, Color(0.3, 0.6, 0.9, 0.9))
		for im in enemy_data.immunity_tags:
			_adicionar_badge_tag(tags_hbox, "Imune: " + im, Color(0.8, 0.3, 0.8, 0.9))

	# Badges de Condição / Status
	for c in status_effects_hbox.get_children():
		c.queue_free()

	if enemy_sys != null and enemy_sys.em_stagger:
		_adicionar_badge_tag(status_effects_hbox, "⚡ STAGGER", Color(1.0, 0.8, 0.2, 0.9))
	if "marked" in current_target and current_target.marked:
		_adicionar_badge_tag(status_effects_hbox, "🎯 MARCADO", Color(0.9, 0.4, 0.2, 0.9))

func _adicionar_badge_tag(parent: HBoxContainer, texto: String, cor_bg: Color) -> void:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_box(cor_bg, cor_bg.lightened(0.2), 1))
	var m := MarginContainer.new()
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.add_theme_constant_override("margin_left", 3)
	m.add_theme_constant_override("margin_right", 3)
	m.add_theme_constant_override("margin_top", 1)
	m.add_theme_constant_override("margin_bottom", 1)
	p.add_child(m)
	var lbl := Label.new()
	lbl.text = texto
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	m.add_child(lbl)
	parent.add_child(p)
