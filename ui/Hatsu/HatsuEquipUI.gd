class_name HatsuEquipUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - HATSU EQUIPMENT & ARCHIVE MANAGEMENT MENU
# ============================================================
#
# Permite ao jogador:
# 1. Gerenciar os 4 SLOTS ATIVOS de combate (com regras de desbloqueio em cadeia).
# 2. Navegar pelo HATSU ARCHIVE (1 a 12 slots para habilidades conhecidas).
# 3. Inspecionar a MASTERY (0 a 100) da técnica selecionada, visualizando
#    a barra de avanço, bônus de poder, eficiência de aura e badge ★ MASTERED.
# 4. Equipar/Trocar Hatsu respeitando o Switch Cooldown (estabilização de aura).
# 5. Monitorar o Cooldown de Criação (30 min) e Custo em Jenny da Forja.
#
# Abre e fecha com a tecla [H] ou via botão na HUD.
#
# ============================================================

signal menu_fechado

var slot_containers: Array[PanelContainer] = []
var grid_archive: GridContainer
var panel_inspector: PanelContainer
var lbl_afinidade_info: Label
var lbl_footer_status: Label
var btn_forjar_footer: Button

var hatsu_selecionado_id: String = ""
var _aberto_no_frame: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 25
	visible = false
	_construir_ui()


func _process(_delta: float) -> void:
	if visible:
		_atualizar_footer_timer()


func toggle_menu() -> void:
	if visible:
		fechar()
	else:
		abrir()


func abrir() -> void:
	_aberto_no_frame = true
	visible = true
	_atualizar_ui()


func fechar() -> void:
	visible = false
	menu_fechado.emit()


func _construir_ui() -> void:
	for c in get_children():
		c.queue_free()

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.88)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	# Painel Central Fixo (304x170)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(304, 170)
	panel.size = Vector2(304, 170)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var vbox_main := VBoxContainer.new()
	vbox_main.add_theme_constant_override("separation", 2)
	margin.add_child(vbox_main)

	# Cabeçalho
	var hbox_hdr := HBoxContainer.new()
	vbox_main.add_child(hbox_hdr)

	var lbl_title := Label.new()
	lbl_title.text = "⚡ HATSU: SLOTS ATIVOS & ARCHIVE (12)"
	lbl_title.add_theme_font_size_override("font_size", 5)
	lbl_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_hdr.add_child(lbl_title)

	var btn_fechar := Button.new()
	btn_fechar.text = "✖ Fechar [H/ESC]"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(fechar)
	hbox_hdr.add_child(btn_fechar)

	# Info de Afinidade
	lbl_afinidade_info = Label.new()
	lbl_afinidade_info.add_theme_font_size_override("font_size", 4)
	lbl_afinidade_info.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0, 1.0))
	vbox_main.add_child(lbl_afinidade_info)

	# 1. Seção Superior: 4 Slots Ativos
	var lbl_slots_hdr := Label.new()
	lbl_slots_hdr.text = "SLOTS ATIVOS DE COMBATE (Teclas 1, 2, 3, 4):"
	lbl_slots_hdr.add_theme_font_size_override("font_size", 4)
	lbl_slots_hdr.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 1.0))
	vbox_main.add_child(lbl_slots_hdr)

	var hbox_slots := HBoxContainer.new()
	hbox_slots.add_theme_constant_override("separation", 3)
	vbox_main.add_child(hbox_slots)

	slot_containers.clear()
	for i in range(4):
		var p_slot := PanelContainer.new()
		p_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p_slot.custom_minimum_size = Vector2(70, 26)
		hbox_slots.add_child(p_slot)
		slot_containers.append(p_slot)

	# 2. Seção Central Dividida: Archive Grid (Esquerda) + Inspetor de Mastery (Direita)
	var hbox_mid := HBoxContainer.new()
	hbox_mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_mid.add_theme_constant_override("separation", 4)
	vbox_main.add_child(hbox_mid)

	# Esquerda: Grid do Archive (6x2 = 12 Slots)
	var vbox_left := VBoxContainer.new()
	vbox_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_left.add_theme_constant_override("separation", 1)
	hbox_mid.add_child(vbox_left)

	var lbl_arch_hdr := Label.new()
	lbl_arch_hdr.text = "HATSU ARCHIVE (Capacidade: 12 Habilidades):"
	lbl_arch_hdr.add_theme_font_size_override("font_size", 4)
	lbl_arch_hdr.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3, 1.0))
	vbox_left.add_child(lbl_arch_hdr)

	grid_archive = GridContainer.new()
	grid_archive.columns = 4
	grid_archive.add_theme_constant_override("h_separation", 2)
	grid_archive.add_theme_constant_override("v_separation", 2)
	vbox_left.add_child(grid_archive)

	# Direita: Inspetor de Mastery do Hatsu Selecionado
	panel_inspector = PanelContainer.new()
	panel_inspector.custom_minimum_size = Vector2(120, 68)
	var st_insp := StyleBoxFlat.new()
	st_insp.bg_color = Color(0.08, 0.10, 0.15, 0.95)
	st_insp.border_width_left = 1
	st_insp.border_width_top = 1
	st_insp.border_width_right = 1
	st_insp.border_width_bottom = 1
	st_insp.border_color = Color(0.3, 0.45, 0.65, 1.0)
	st_insp.corner_radius_top_left = 3
	st_insp.corner_radius_top_right = 3
	st_insp.corner_radius_bottom_right = 3
	st_insp.corner_radius_bottom_left = 3
	panel_inspector.add_theme_stylebox_override("panel", st_insp)
	hbox_mid.add_child(panel_inspector)

	# 3. Rodapé: Cooldown de Criação & Botão de Forja
	var hbox_footer := HBoxContainer.new()
	vbox_main.add_child(hbox_footer)

	lbl_footer_status = Label.new()
	lbl_footer_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_footer_status.add_theme_font_size_override("font_size", 4)
	lbl_footer_status.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
	hbox_footer.add_child(lbl_footer_status)

	btn_forjar_footer = Button.new()
	btn_forjar_footer.text = "🔨 Forjar Novo Hatsu"
	btn_forjar_footer.add_theme_font_size_override("font_size", 4)
	btn_forjar_footer.pressed.connect(_abrir_criador_hatsu)
	hbox_footer.add_child(btn_forjar_footer)


func _atualizar_ui() -> void:
	if PlayerData == null:
		return

	var afinidade_nome := NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
	lbl_afinidade_info.text = "Afinidade: " + afinidade_nome + (" (100% de Eficiência em tudo!)" if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO else "")

	# 1. Atualizar 4 Slots Ativos
	for i in range(4):
		var slot_id: int = i + 1
		var p_slot := slot_containers[i]
		for c in p_slot.get_children():
			c.queue_free()

		var is_unlocked: bool = HatsuProgressionManager == null or HatsuProgressionManager.is_slot_unlocked(slot_id)
		var hatsu: HatsuData = null
		if is_unlocked:
			if HatsuProgressionManager != null:
				hatsu = HatsuProgressionManager.obter_hatsu_ativo(slot_id)
			else:
				hatsu = PlayerData.obter_hatsu_slot(i)

		var st := StyleBoxFlat.new()
		st.corner_radius_top_left = 3
		st.corner_radius_top_right = 3
		st.corner_radius_bottom_right = 3
		st.corner_radius_bottom_left = 3
		st.border_width_left = 1
		st.border_width_top = 1
		st.border_width_right = 1
		st.border_width_bottom = 1

		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.add_theme_constant_override("separation", 1)
		p_slot.add_child(vb)

		var lbl_num := Label.new()
		lbl_num.add_theme_font_size_override("font_size", 4)
		lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(lbl_num)

		var lbl_n := Label.new()
		lbl_n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		lbl_n.clip_text = true
		lbl_n.add_theme_font_size_override("font_size", 4)
		vb.add_child(lbl_n)

		if not is_unlocked:
			# ESTADO: LOCKED 🔒
			st.bg_color = Color(0.08, 0.08, 0.10, 0.95)
			st.border_color = Color(0.5, 0.25, 0.25, 0.8)
			lbl_num.text = "🔒 SLOT " + str(slot_id)
			lbl_num.add_theme_color_override("font_color", Color(0.8, 0.35, 0.35, 1.0))
			lbl_n.text = "[ BLOQUEADO ]"
			lbl_n.add_theme_color_override("font_color", Color(0.6, 0.45, 0.45, 1.0))

			var btn_req := Button.new()
			btn_req.text = "Requisitos"
			btn_req.add_theme_font_size_override("font_size", 4)
			var s_id_captured := slot_id
			btn_req.pressed.connect(func(): _mostrar_requisitos_slot(s_id_captured))
			vb.add_child(btn_req)
		elif hatsu != null:
			# ESTADO: EQUIPPED ✓
			st.bg_color = Color(0.12, 0.15, 0.22, 0.95)
			st.border_color = Color(1.0, 0.85, 0.3, 1.0)
			lbl_num.text = "✓ SLOT %d %s" % [slot_id, ("★" if hatsu.is_mastered() else "M:%d" % int(hatsu.mastery))]
			lbl_num.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))

			lbl_n.text = hatsu.nome
			lbl_n.add_theme_color_override("font_color", Color.WHITE)

			var btn_desequipar := Button.new()
			btn_desequipar.text = "Desequipar"
			btn_desequipar.add_theme_font_size_override("font_size", 4)
			var s_id_deseq := slot_id
			btn_desequipar.pressed.connect(func(): _desequipar_slot(s_id_deseq))
			vb.add_child(btn_desequipar)
		else:
			# ESTADO: UNLOCKED (Vazio)
			st.bg_color = Color(0.10, 0.16, 0.14, 0.95)
			st.border_color = Color(0.3, 0.85, 0.5, 0.9)
			lbl_num.text = "✓ SLOT " + str(slot_id)
			lbl_num.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6, 1.0))
			lbl_n.text = "[ Vazio ]"
			lbl_n.add_theme_color_override("font_color", Color(0.6, 0.85, 0.7, 1.0))

		p_slot.add_theme_stylebox_override("panel", st)

	# 2. Atualizar Grid do Archive (12 Slots)
	for c in grid_archive.get_children():
		c.queue_free()

	var arch: Array[HatsuData] = []
	if HatsuProgressionManager != null:
		arch = HatsuProgressionManager.obter_todos_hatsus_archive()
	else:
		arch = PlayerData.obter_todos_hatsus_disponiveis()

	# Se nenhum hatsu selecionado mas houver no archive, selecionar o primeiro
	if hatsu_selecionado_id.is_empty() and not arch.is_empty():
		hatsu_selecionado_id = arch[0].hatsu_id

	for i in range(HatsuConfig.MAX_ARCHIVE_SLOTS):
		var btn_slot := Button.new()
		btn_slot.custom_minimum_size = Vector2(40, 20)
		btn_slot.add_theme_font_size_override("font_size", 4)

		if i < arch.size():
			var h: HatsuData = arch[i]
			var is_sel: bool = (h.hatsu_id == hatsu_selecionado_id)
			var prefix := "★ " if h.is_mastered() else ""
			btn_slot.text = "%s[%d] %s (M:%d)" % [prefix, i + 1, h.nome.substr(0, 7), int(h.mastery)]
			if is_sel:
				btn_slot.modulate = Color(1.0, 0.9, 0.4, 1.0)
			else:
				btn_slot.modulate = Color(0.85, 0.95, 1.0, 1.0)
			var h_id_cap := h.hatsu_id
			btn_slot.pressed.connect(func(): _selecionar_hatsu_archive(h_id_cap))
		else:
			btn_slot.text = "[%d] Vazio" % (i + 1)
			btn_slot.modulate = Color(0.5, 0.5, 0.5, 0.8)
			btn_slot.disabled = true

		grid_archive.add_child(btn_slot)

	# 3. Atualizar Inspetor de Mastery
	_atualizar_inspetor()

	# 4. Atualizar Footer
	_atualizar_footer_timer()


func _selecionar_hatsu_archive(hid: String) -> void:
	hatsu_selecionado_id = hid
	_atualizar_ui()


func _atualizar_inspetor() -> void:
	for c in panel_inspector.get_children():
		c.queue_free()

	var h: HatsuData = null
	if HatsuProgressionManager != null:
		h = HatsuProgressionManager.obter_hatsu_archive_por_id(hatsu_selecionado_id)
	else:
		h = PlayerData.obter_hatsu_por_id(hatsu_selecionado_id)

	if h == null:
		var lbl_empty := Label.new()
		lbl_empty.text = "Selecione um Hatsu no Archive para inspecionar sua maestria."
		lbl_empty.add_theme_font_size_override("font_size", 4)
		lbl_empty.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		lbl_empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel_inspector.add_child(lbl_empty)
		return

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 3)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_right", 3)
	margin.add_theme_constant_override("margin_bottom", 2)
	panel_inspector.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 1)
	margin.add_child(vb)

	# Título & Badge
	var lbl_nome := Label.new()
	lbl_nome.text = ("★ MASTERED " if h.is_mastered() else "") + h.nome
	lbl_nome.add_theme_font_size_override("font_size", 4)
	lbl_nome.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2) if h.is_mastered() else Color(0.4, 0.95, 1.0))
	vb.add_child(lbl_nome)

	# Mastery Progress
	var lbl_m_val := Label.new()
	lbl_m_val.text = "Mastery: %d / 100" % int(h.mastery)
	lbl_m_val.add_theme_font_size_override("font_size", 4)
	lbl_m_val.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	vb.add_child(lbl_m_val)

	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(100, 4)
	bar.max_value = 100.0
	bar.value = h.mastery
	bar.show_percentage = false
	vb.add_child(bar)

	# Escala de Poder e Eficiência
	var p_ratio: int = int(h.obter_multiplicador_mastery() * 100)
	var eff_bonus: int = int((1.0 - h.obter_reducao_custo_mastery()) * 100)
	var cd_bonus: int = int((1.0 - h.obter_reducao_cooldown_mastery()) * 100)
	var rng_bonus: int = int((h.obter_bonus_alcance_mastery() - 1.0) * 100)

	var lbl_stats := Label.new()
	lbl_stats.text = "Poder: %d%%\nAura: -%d%% | CD: -%d%% | Alc: +%d%%" % [p_ratio, eff_bonus, cd_bonus, rng_bonus]
	lbl_stats.add_theme_font_size_override("font_size", 4)
	lbl_stats.add_theme_color_override("font_color", Color(0.8, 0.9, 0.85))
	vb.add_child(lbl_stats)

	# Botões de Equipar no Slot 1..4
	var hb_eq := HBoxContainer.new()
	hb_eq.add_theme_constant_override("separation", 1)
	vb.add_child(hb_eq)

	var lbl_eq := Label.new()
	lbl_eq.text = "Equipar:"
	lbl_eq.add_theme_font_size_override("font_size", 4)
	hb_eq.add_child(lbl_eq)

	for sid in range(1, 5):
		var btn_s := Button.new()
		btn_s.text = str(sid)
		btn_s.custom_minimum_size = Vector2(14, 12)
		btn_s.add_theme_font_size_override("font_size", 4)
		var check_eq: Dictionary = HatsuProgressionManager.can_equip_to_slot(sid, h.hatsu_id) if HatsuProgressionManager != null else {"can_equip": true}
		btn_s.disabled = not check_eq.get("can_equip", false)
		if not check_eq.get("can_equip", false):
			btn_s.tooltip_text = check_eq.get("message", "Bloqueado")

		var target_sid := sid
		var target_hid := h.hatsu_id
		btn_s.pressed.connect(func(): _equipar_hatsu_no_slot(target_sid, target_hid))
		hb_eq.add_child(btn_s)


func _equipar_hatsu_no_slot(slot_id: int, hid: String) -> void:
	if HatsuProgressionManager != null:
		var check: Dictionary = HatsuProgressionManager.can_equip_to_slot(slot_id, hid)
		if not check.get("can_equip", false):
			if EventBus != null and EventBus.has_signal("toast_enviado"):
				EventBus.emit_toast(str(check.get("message", "Não é possível equipar.")), Color(1.0, 0.4, 0.4))
			return
		HatsuProgressionManager.equipar_hatsu(slot_id, hid)
	else:
		PlayerData.equipar_hatsu(slot_id - 1, 0)

	_atualizar_ui()


func _desequipar_slot(slot_id: int) -> void:
	if HatsuProgressionManager != null:
		HatsuProgressionManager.desequipar_hatsu(slot_id)
	else:
		PlayerData.desequipar_hatsu(slot_id - 1)
	_atualizar_ui()


func _atualizar_footer_timer() -> void:
	if lbl_footer_status == null or btn_forjar_footer == null:
		return

	if HatsuProgressionManager == null:
		lbl_footer_status.text = "Forja de Hatsu disponível."
		return

	var check: Dictionary = HatsuProgressionManager.can_create_hatsu()
	var cur_arch: int = int(check.get("archive_count", 0))
	var max_arch: int = int(check.get("archive_max", 12))
	var cost: int = int(check.get("cost_jenny", 5000))
	var rem_sec: int = int(check.get("remaining_seconds", 0))

	if not check.get("can_create", false):
		if check.get("reason") == "SLOT_LOCKED":
			lbl_footer_status.text = "🔒 Requer conclusão de Greed Island e treino com Biscuit."
			btn_forjar_footer.disabled = true
		elif check.get("reason") == "COOLDOWN":
			lbl_footer_status.text = "⏳ Cooldown de Criação: %s | Custo: %d Jenny" % [_formatar_tempo(rem_sec), cost]
			btn_forjar_footer.disabled = true
		elif check.get("reason") == "ARCHIVE_FULL":
			lbl_footer_status.text = "⚠️ Archive Cheio (%d/%d Hatsus). Exclua um antigo." % [cur_arch, max_arch]
			btn_forjar_footer.disabled = true
		elif check.get("reason") == "INSUFFICIENT_JENNY":
			lbl_footer_status.text = "💰 Custo: %d Jenny (Saldo Insuficiente) | Archive: %d/%d" % [cost, cur_arch, max_arch]
			btn_forjar_footer.disabled = true
		else:
			lbl_footer_status.text = "Forja indisponível."
			btn_forjar_footer.disabled = true
	else:
		lbl_footer_status.text = "✅ Pronto para Forjar | Custo: %d Jenny | Archive: %d/%d" % [cost, cur_arch, max_arch]
		btn_forjar_footer.disabled = false


func _formatar_tempo(segundos: int) -> String:
	var m: int = segundos / 60
	var s: int = segundos % 60
	return "%02d:%02d" % [m, s]


func _abrir_criador_hatsu() -> void:
	if HatsuProgressionManager != null:
		var check: Dictionary = HatsuProgressionManager.can_create_hatsu()
		if not check.get("can_create", false):
			if EventBus != null and EventBus.has_signal("toast_enviado"):
				EventBus.emit_toast(str(check.get("message", "Forja indisponível.")), Color(1.0, 0.4, 0.4))
			return

	fechar()
	var creation_ui := get_tree().root.get_node_or_null("HatsuCreationUI") as HatsuCreationUI
	if creation_ui != null:
		creation_ui.abrir()
	else:
		var new_ui := HatsuCreationUI.new()
		new_ui.name = "HatsuCreationUI"
		get_tree().root.add_child(new_ui)
		new_ui.abrir()


func _mostrar_requisitos_slot(slot_id: int) -> void:
	var diag: Dictionary = {}
	if HatsuProgressionManager != null:
		diag = HatsuProgressionManager.can_unlock_slot(slot_id)
	else:
		diag = {
			"can_unlock": false,
			"required_level": 600 if slot_id == 2 else (800 if slot_id == 3 else 1000),
			"current_level": PlayerData.attributes.get("nivel", 1) if PlayerData != null else 1,
			"required_slot": slot_id - 1,
			"previous_slot_unlocked": false,
			"story_completed": false
		}

	var modal := CanvasLayer.new()
	modal.layer = 35
	add_child(modal)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(240, 140)
	panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	var lbl_t := Label.new()
	lbl_t.text = "🔒 HATSU SLOT %d" % slot_id
	lbl_t.add_theme_font_size_override("font_size", 5)
	lbl_t.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	lbl_t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_t)

	var lbl_reqs := Label.new()
	lbl_reqs.text = "REQUISITOS DE DOMÍNIO:"
	lbl_reqs.add_theme_font_size_override("font_size", 4)
	lbl_reqs.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0, 1.0))
	vbox.add_child(lbl_reqs)

	if slot_id == 1:
		var gi_ok: bool = bool(diag.get("story_completed", false))
		var lbl_gi := Label.new()
		lbl_gi.text = "%s Concluir Saga de Greed Island (Arco 5)" % ("✓" if gi_ok else "✗")
		lbl_gi.add_theme_font_size_override("font_size", 4)
		lbl_gi.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4) if gi_ok else Color(1.0, 0.4, 0.4))
		vbox.add_child(lbl_gi)
	else:
		var prev_ok: bool = bool(diag.get("previous_slot_unlocked", false))
		var lbl_prev := Label.new()
		lbl_prev.text = "%s Hatsu Slot %d Desbloqueado" % [("✓" if prev_ok else "✗"), slot_id - 1]
		lbl_prev.add_theme_font_size_override("font_size", 4)
		lbl_prev.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4) if prev_ok else Color(1.0, 0.4, 0.4))
		vbox.add_child(lbl_prev)

	var req_lvl: int = int(diag.get("required_level", 0))
	var cur_lvl: int = int(diag.get("current_level", 1))
	if req_lvl > 0:
		var lvl_ok: bool = cur_lvl >= req_lvl
		var lbl_lvl := Label.new()
		lbl_lvl.text = "%s Nível %d (Seu Nível: %d)" % [("✓" if lvl_ok else "✗"), req_lvl, cur_lvl]
		lbl_lvl.add_theme_font_size_override("font_size", 4)
		lbl_lvl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4) if lvl_ok else Color(1.0, 0.4, 0.4))
		vbox.add_child(lbl_lvl)

	var lbl_status := Label.new()
	lbl_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_status.add_theme_font_size_override("font_size", 4)
	if slot_id == 1:
		lbl_status.text = "Conclua Greed Island e treine com Biscuit Krueger para manifestar seu primeiro Hatsu."
	else:
		lbl_status.text = "Continue sua evolução para desbloquear este slot."
	lbl_status.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(lbl_status)

	var btn_ok := Button.new()
	btn_ok.text = "Entendido"
	btn_ok.add_theme_font_size_override("font_size", 4)
	btn_ok.pressed.connect(func(): modal.queue_free())
	vbox.add_child(btn_ok)
