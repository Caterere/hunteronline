extends CanvasLayer

# ============================================================
# HUNTER ONLINE - INVENTORY UI (TECLA I)
# Equipamento + ItemExplainKit (stats/lore/tooltips).
# ============================================================

const EquipmentCatalogScript = preload("res://resource/item/EquipmentCatalog.gd")
const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")
const ItemLoreTooltipScript = preload("res://ui/common/ItemLoreTooltip.gd")
const ItemExplainKitScript = preload("res://ui/common/ItemExplainKit.gd")

var panel_main: PanelContainer
var container_grid: GridContainer
var container_equip: VBoxContainer
var lbl_detalhes: Label
var item_selecionado: String = ""
var lore_tooltip: ItemLoreTooltip


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 14
	visible = false
	_construir_ui()


func alternar_inventario() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		_atualizar_inventario()
	elif lore_tooltip != null:
		lore_tooltip.esconder()


func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(480, 260)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_main.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_main.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel_main.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "INVENTÁRIO & EQUIPAMENTO"
	lbl_titulo.add_theme_font_size_override("font_size", 11)
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_titulo)

	var hbox_content := HBoxContainer.new()
	hbox_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_content.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox_content)

	container_equip = VBoxContainer.new()
	container_equip.custom_minimum_size = Vector2(140, 0)
	container_equip.add_theme_constant_override("separation", 2)
	hbox_content.add_child(container_equip)

	container_grid = GridContainer.new()
	container_grid.columns = 3
	container_grid.custom_minimum_size = Vector2(180, 0)
	container_grid.add_theme_constant_override("h_separation", 4)
	container_grid.add_theme_constant_override("v_separation", 4)
	hbox_content.add_child(container_grid)

	var detalhes_box := VBoxContainer.new()
	detalhes_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detalhes_box.add_theme_constant_override("separation", 4)
	hbox_content.add_child(detalhes_box)

	var scroll_det := ScrollContainer.new()
	scroll_det.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_det.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detalhes_box.add_child(scroll_det)

	lbl_detalhes = Label.new()
	lbl_detalhes.text = "Selecione um item para ver nome, stats, trade-offs e lore."
	lbl_detalhes.add_theme_font_size_override("font_size", 8)
	lbl_detalhes.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_detalhes.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_detalhes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_det.add_child(lbl_detalhes)

	var btn_equip := Button.new()
	btn_equip.text = "Equipar / Trocar"
	btn_equip.add_theme_font_size_override("font_size", 8)
	HunterUIStyle.aplicar_estilo_botao(btn_equip, HunterUIStyle.COLOR_BORDER_GOLD)
	btn_equip.pressed.connect(_on_equipar_selecionado)
	detalhes_box.add_child(btn_equip)

	var btn_unequip := Button.new()
	btn_unequip.text = "Desequipar slot do item"
	btn_unequip.add_theme_font_size_override("font_size", 8)
	HunterUIStyle.aplicar_estilo_botao(btn_unequip, HunterUIStyle.COLOR_BORDER_GREEN)
	btn_unequip.pressed.connect(_on_desequipar_selecionado)
	detalhes_box.add_child(btn_unequip)

	var lbl_fechar := Label.new()
	lbl_fechar.text = "[I Fechar] · Hover = tip rápido · Clique = detalhes"
	lbl_fechar.add_theme_font_size_override("font_size", 7)
	lbl_fechar.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
	lbl_fechar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_fechar)

	lore_tooltip = ItemLoreTooltipScript.new() as ItemLoreTooltip
	lore_tooltip.visible = false
	add_child(lore_tooltip)


func _atualizar_inventario() -> void:
	if container_grid == null or container_equip == null:
		return

	for child in container_grid.get_children():
		child.queue_free()
	for child in container_equip.get_children():
		child.queue_free()

	var lbl_eq := Label.new()
	lbl_eq.text = "SLOTS"
	lbl_eq.add_theme_font_size_override("font_size", 8)
	lbl_eq.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	container_equip.add_child(lbl_eq)

	for slot in EquipmentCatalogScript.SLOTS:
		var item_id: String = PlayerData.obter_equipado(String(slot))
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(130, 20)
		if item_id.is_empty():
			btn.text = "%s: —" % String(slot)
		else:
			btn.text = "%s: %s" % [String(slot), EquipmentCatalogScript.obter_nome(item_id).left(12)]
		btn.add_theme_font_size_override("font_size", 7)
		HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_GOLD)
		var sid: String = item_id
		btn.pressed.connect(func():
			if sid.is_empty():
				lbl_detalhes.text = "Slot %s vazio." % String(slot)
				item_selecionado = ""
			else:
				_selecionar_item(sid)
		)
		container_equip.add_child(btn)

	var inv: Dictionary = PlayerData.inventory
	var tem_algo := false
	for item_id in inv.keys():
		var raw = inv[item_id]
		if typeof(raw) != TYPE_INT and typeof(raw) != TYPE_FLOAT:
			continue
		var qtd: int = int(raw)
		if qtd <= 0:
			continue
		tem_algo = true
		var id_str: String = str(item_id)
		var item = ItemExplainKitScript.resolver_item(id_str)
		var btn2 := Button.new()
		btn2.custom_minimum_size = Vector2(52, 24)
		btn2.text = ItemExplainKitScript.rotulo_botao(id_str, qtd, item)
		if EquipmentCatalogScript.eh_equipamento(id_str) and PlayerData.esta_equipado(id_str):
			btn2.text = "*" + btn2.text
		btn2.tooltip_text = ItemExplainKitScript.nome_exibicao(id_str, item)
		btn2.add_theme_font_size_override("font_size", 7)
		HunterUIStyle.aplicar_estilo_botao(btn2, HunterUIStyle.COLOR_BORDER_GREEN)
		btn2.pressed.connect(func(): _selecionar_item(id_str))
		btn2.mouse_entered.connect(_on_item_hover.bind(id_str, btn2))
		btn2.mouse_exited.connect(_on_item_unhover)
		container_grid.add_child(btn2)

	if not tem_algo:
		lbl_detalhes.text = "Alforje vazio. Derrote inimigos, complete quests ou fale com mestres."


func _selecionar_item(item_id: String) -> void:
	item_selecionado = item_id
	var qtd: int = PlayerData.obter_item_quantidade(StringName(item_id))
	var explained: String = ItemExplainKitScript.formatar_detalhes(item_id, qtd)
	if EquipmentCatalogScript.eh_equipamento(item_id):
		var eq_flag: String = " [EQUIPADO]" if PlayerData.esta_equipado(item_id) else ""
		lbl_detalhes.text = explained + eq_flag
	else:
		lbl_detalhes.text = explained


func _on_equipar_selecionado() -> void:
	if item_selecionado.is_empty():
		lbl_detalhes.text = "Selecione um equipamento primeiro."
		return
	var res: Dictionary = PlayerData.equipar_item(item_selecionado)
	lbl_detalhes.text = str(res.get("mensagem", ""))
	if EquipmentCatalogScript.eh_equipamento(item_selecionado):
		lbl_detalhes.text += "\n\n" + ItemExplainKitScript.formatar_detalhes(
			item_selecionado,
			PlayerData.obter_item_quantidade(StringName(item_selecionado))
		)
	_atualizar_inventario()


func _on_desequipar_selecionado() -> void:
	if item_selecionado.is_empty() or not EquipmentCatalogScript.eh_equipamento(item_selecionado):
		lbl_detalhes.text = "Selecione um equipamento equipado."
		return
	var slot: String = String(EquipmentCatalogScript.obter_slot(item_selecionado))
	var res: Dictionary = PlayerData.desequipar_slot(slot)
	lbl_detalhes.text = str(res.get("mensagem", ""))
	_atualizar_inventario()


func _on_item_hover(item_id: String, btn: Control) -> void:
	if lore_tooltip == null:
		return
	var item = ItemExplainKitScript.resolver_item(item_id)
	if item == null:
		lore_tooltip.esconder()
		return
	var pos := btn.get_global_rect().position + Vector2(0, btn.size.y + 2)
	lore_tooltip.mostrar_na_posicao(pos, item)


func _on_item_unhover() -> void:
	if lore_tooltip != null:
		lore_tooltip.esconder()
