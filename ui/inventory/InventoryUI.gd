extends CanvasLayer

# ============================================================
# HUNTER ONLINE - INVENTORY UI (TECLA I)
# ============================================================
#
# Menu visual de Inventário do Jogador.
# Exibe itens com nome, stats, trade-offs e lore via ItemExplainKit.
# Resolução nativa 320x180 (pixel art).
#
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")
const ItemLoreTooltipScript = preload("res://ui/common/ItemLoreTooltip.gd")

var panel_main: PanelContainer
var container_grid: GridContainer
var lbl_detalhes: Label
var lore_tooltip: ItemLoreTooltip
var _item_selecionado_id: String = ""


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
	panel_main.custom_minimum_size = Vector2(440, 240)
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
	lbl_titulo.text = "🎒 INVENTÁRIO HUNTER"
	lbl_titulo.add_theme_font_size_override("font_size", 11)
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_titulo)

	var hbox_content := HBoxContainer.new()
	hbox_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_content.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox_content)

	container_grid = GridContainer.new()
	container_grid.columns = 4
	container_grid.custom_minimum_size = Vector2(220, 0)
	container_grid.add_theme_constant_override("h_separation", 4)
	container_grid.add_theme_constant_override("v_separation", 4)
	hbox_content.add_child(container_grid)

	var scroll_det := ScrollContainer.new()
	scroll_det.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_det.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_content.add_child(scroll_det)

	lbl_detalhes = Label.new()
	lbl_detalhes.text = "Selecione um item para ver nome, stats, trade-offs e lore."
	lbl_detalhes.add_theme_font_size_override("font_size", 8)
	lbl_detalhes.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_detalhes.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_detalhes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_det.add_child(lbl_detalhes)

	var lbl_fechar := Label.new()
	lbl_fechar.text = "[Pressione I para Fechar] · Passe o mouse para tip rápido"
	lbl_fechar.add_theme_font_size_override("font_size", 7)
	lbl_fechar.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
	lbl_fechar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_fechar)

	lore_tooltip = ItemLoreTooltipScript.new() as ItemLoreTooltip
	lore_tooltip.visible = false
	add_child(lore_tooltip)


func _atualizar_inventario() -> void:
	if container_grid == null:
		return

	for child in container_grid.get_children():
		child.queue_free()

	var inv: Dictionary = PlayerData.inventory
	if inv.is_empty():
		lbl_detalhes.text = "Seu alforje de inventário está vazio."
		_item_selecionado_id = ""
		return

	var primeiro_id: String = ""
	for item_id in inv.keys():
		var qtd: int = int(inv[item_id])
		if qtd <= 0:
			continue
		var sid := str(item_id)
		if primeiro_id.is_empty():
			primeiro_id = sid
		var item: ItemData = ItemExplainKit.resolver_item(sid)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(48, 24)
		btn.text = ItemExplainKit.rotulo_botao(sid, qtd, item)
		btn.tooltip_text = ItemExplainKit.nome_exibicao(sid, item)
		btn.add_theme_font_size_override("font_size", 7)
		HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_GREEN)

		btn.pressed.connect(_on_item_pressed.bind(sid, qtd))
		btn.mouse_entered.connect(_on_item_hover.bind(sid, btn))
		btn.mouse_exited.connect(_on_item_unhover)
		container_grid.add_child(btn)

	if not _item_selecionado_id.is_empty() and inv.has(_item_selecionado_id):
		_mostrar_detalhes(_item_selecionado_id, int(inv[_item_selecionado_id]))
	elif not primeiro_id.is_empty():
		_mostrar_detalhes(primeiro_id, int(inv[primeiro_id]))


func _on_item_pressed(item_id: String, qtd: int) -> void:
	_mostrar_detalhes(item_id, qtd)


func _mostrar_detalhes(item_id: String, qtd: int) -> void:
	_item_selecionado_id = item_id
	lbl_detalhes.text = ItemExplainKit.formatar_detalhes(item_id, qtd)


func _on_item_hover(item_id: String, btn: Control) -> void:
	if lore_tooltip == null:
		return
	var item: ItemData = ItemExplainKit.resolver_item(item_id)
	if item == null:
		lore_tooltip.esconder()
		return
	var pos := btn.get_global_rect().position + Vector2(0, btn.size.y + 2)
	lore_tooltip.mostrar_na_posicao(pos, item)


func _on_item_unhover() -> void:
	if lore_tooltip != null:
		lore_tooltip.esconder()
