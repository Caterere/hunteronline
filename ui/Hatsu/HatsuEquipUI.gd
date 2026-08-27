class_name HatsuEquipUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - HATSU EQUIPMENT & MANAGEMENT MENU
# ============================================================
#
# Permite ao jogador visualizar todos os seus Hatsus desbloqueados/criados,
# analisar a eficiência de Nen por categoria natal, e equipar/trocar
# habilidades livremente entre os 4 Slots (1, 2, 3, 4).
#
# Abre e fecha com a tecla [H] ou via botão na HUD.
#
# ============================================================

signal menu_fechado

var slot_containers: Array[PanelContainer] = []
var vbox_hatsus_lista: VBoxContainer
var lbl_afinidade_info: Label
var _aberto_no_frame: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 25
	visible = false
	_construir_ui()


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
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	# Painel Central Fixo (304x168)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(304, 168)
	panel.size = Vector2(304, 168)
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
	lbl_title.text = "⚡ GERENCIADOR DE HATSU (1-4)"
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

	# Seção Superior: 4 Slots Ativos
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

		var st := StyleBoxFlat.new()
		st.bg_color = Color(0.11, 0.14, 0.20, 0.95)
		st.border_width_left = 1
		st.border_width_top = 1
		st.border_width_right = 1
		st.border_width_bottom = 1
		st.border_color = Color(0.45, 0.55, 0.75, 1.0)
		st.corner_radius_top_left = 3
		st.corner_radius_top_right = 3
		st.corner_radius_bottom_right = 3
		st.corner_radius_bottom_left = 3
		p_slot.add_theme_stylebox_override("panel", st)

		hbox_slots.add_child(p_slot)
		slot_containers.append(p_slot)

	# Divisor
	var lbl_inv_hdr := Label.new()
	lbl_inv_hdr.text = "LISTA DE HABILIDADES (Clique no número 1, 2, 3 ou 4 para equipar):"
	lbl_inv_hdr.add_theme_font_size_override("font_size", 4)
	lbl_inv_hdr.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3, 1.0))
	vbox_main.add_child(lbl_inv_hdr)

	# Seção Inferior: Scroll com Lista de Hatsus
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(290, 68)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox_main.add_child(scroll)

	vbox_hatsus_lista = VBoxContainer.new()
	vbox_hatsus_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_hatsus_lista.add_theme_constant_override("separation", 2)
	scroll.add_child(vbox_hatsus_lista)

	# Rodapé com botão de Criar Hatsu
	var hbox_footer := HBoxContainer.new()
	vbox_main.add_child(hbox_footer)

	var btn_forjar := Button.new()
	btn_forjar.text = "🔨 Forjar Novo Hatsu (Juramentos & Restrições)"
	btn_forjar.add_theme_font_size_override("font_size", 4)
	btn_forjar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_forjar.pressed.connect(_abrir_criador_hatsu)
	hbox_footer.add_child(btn_forjar)


func _atualizar_ui() -> void:
	var afinidade_nome := NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
	lbl_afinidade_info.text = "Afinidade: " + afinidade_nome + (" (100% de Eficiência em tudo!)" if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO else "")

	# Atualizar 4 Slots Superiores
	for i in range(4):
		var p_slot := slot_containers[i]
		for c in p_slot.get_children():
			c.queue_free()

		var hatsu: HatsuData = PlayerData.obter_hatsu_slot(i)
		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.add_theme_constant_override("separation", 1)
		p_slot.add_child(vb)

		var lbl_num := Label.new()
		lbl_num.text = "SLOT " + str(i + 1)
		lbl_num.add_theme_font_size_override("font_size", 4)
		lbl_num.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
		lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(lbl_num)

		var lbl_n := Label.new()
		lbl_n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		lbl_n.clip_text = true
		lbl_n.add_theme_font_size_override("font_size", 4)

		if hatsu != null:
			var display_nome := hatsu.nome
			if display_nome.contains("Guanyin"):
				display_nome = "100-Type Guanyin"
			lbl_n.text = display_nome
			lbl_n.add_theme_color_override("font_color", Color.WHITE)
			vb.add_child(lbl_n)

			var btn_desequipar := Button.new()
			btn_desequipar.text = "Desequipar"
			btn_desequipar.add_theme_font_size_override("font_size", 4)
			var current_slot = i
			btn_desequipar.pressed.connect(func(): _desequipar_slot(current_slot))
			vb.add_child(btn_desequipar)
		else:
			lbl_n.text = "[ Vazio ]"
			lbl_n.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
			vb.add_child(lbl_n)

	# Atualizar Lista de Hatsus
	for c in vbox_hatsus_lista.get_children():
		c.queue_free()

	# Obter todos os Hatsus do jogador
	var todos_hatsus: Array[HatsuData] = PlayerData.obter_todos_hatsus_disponiveis()

	if todos_hatsus.is_empty():
		var lbl_empty := Label.new()
		lbl_empty.text = "Nenhum Hatsu forjado ainda. Clique no botão abaixo para criar seu primeiro Hatsu!"
		lbl_empty.add_theme_font_size_override("font_size", 4)
		lbl_empty.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
		vbox_hatsus_lista.add_child(lbl_empty)
		return

	for hatsu_idx in range(todos_hatsus.size()):
		var hatsu := todos_hatsus[hatsu_idx]
		var ef: float = NenAffinityData.calcular_eficiencia_categoria(PlayerData.afinidade_nen, hatsu.categoria)

		var p_item := PanelContainer.new()
		p_item.custom_minimum_size = Vector2(286, 22)
		var st_item := StyleBoxFlat.new()
		st_item.bg_color = Color(0.10, 0.12, 0.18, 0.95)
		st_item.border_width_bottom = 1
		st_item.border_color = Color(0.2, 0.25, 0.35, 1.0)
		p_item.add_theme_stylebox_override("panel", st_item)
		vbox_hatsus_lista.add_child(p_item)

		var hb_row := HBoxContainer.new()
		hb_row.add_theme_constant_override("separation", 2)
		p_item.add_child(hb_row)

		var vb_info := VBoxContainer.new()
		vb_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb_info.add_theme_constant_override("separation", 0)
		hb_row.add_child(vb_info)

		var lbl_hn := Label.new()
		lbl_hn.text = hatsu.nome + " [" + HatsuManager.obter_nome_categoria(hatsu.categoria) + "]"
		lbl_hn.add_theme_font_size_override("font_size", 4)
		lbl_hn.add_theme_color_override("font_color", Color(0.4, 0.95, 1.0, 1.0))
		lbl_hn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
		lbl_stats.text = "[%s] %d%% Efic. | %d Aura | %.1fs CD | %s%s" % [
			obj_tag,
			int(ef * 100),
			int(hatsu.obter_custo_final()),
			hatsu.obter_cooldown_final(),
			poder_txt,
			extra_tag
		]
		lbl_stats.add_theme_font_size_override("font_size", 4)
		lbl_stats.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 1.0))
		vb_info.add_child(lbl_stats)

		# Botões de Equipar nos Slots 1, 2, 3, 4
		var hb_btns := HBoxContainer.new()
		hb_btns.add_theme_constant_override("separation", 1)
		hb_row.add_child(hb_btns)

		for s_idx in range(4):
			var btn_eq := Button.new()
			btn_eq.text = str(s_idx + 1)
			btn_eq.custom_minimum_size = Vector2(16, 16)
			btn_eq.add_theme_font_size_override("font_size", 4)
			var h_index = hatsu_idx
			var target_slot = s_idx
			btn_eq.pressed.connect(func(): _equipar_hatsu_slot(h_index, target_slot))
			hb_btns.add_child(btn_eq)


func _equipar_hatsu_slot(hatsu_index: int, slot: int) -> void:
	PlayerData.equipar_hatsu(slot, hatsu_index)
	_atualizar_ui()
	print("[HatsuEquipUI] Equipou Hatsu index ", hatsu_index, " no Slot ", slot)


func _desequipar_slot(slot: int) -> void:
	PlayerData.desequipar_hatsu(slot)
	_atualizar_ui()
	print("[HatsuEquipUI] Desequipou Slot ", slot)


func _abrir_criador_hatsu() -> void:
	fechar()
	var creation_ui := get_tree().root.get_node_or_null("HatsuCreationUI") as HatsuCreationUI
	if creation_ui != null:
		creation_ui.abrir()
	else:
		var new_ui := HatsuCreationUI.new()
		new_ui.name = "HatsuCreationUI"
		get_tree().root.add_child(new_ui)
		new_ui.abrir()
