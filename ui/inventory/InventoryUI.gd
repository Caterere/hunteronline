extends CanvasLayer

# ============================================================
# HUNTER ONLINE - INVENTORY UI (TECLA I)
# ============================================================
#
# Menu visual de Inventário do Jogador.
# Exibe itens coletados (Licença Hunter, Plaquetas, Poções, Elixires).
# Resolução nativa 320x180 (pixel art).
#
# ============================================================

var panel_main: PanelContainer
var container_grid: GridContainer
var lbl_detalhes: Label


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

	# Cabeçalho
	var lbl_titulo := Label.new()
	lbl_titulo.text = "🎒 INVENTÁRIO HUNTER"
	lbl_titulo.add_theme_font_size_override("font_size", 11)
	lbl_titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.25, 1))
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_titulo)

	var hbox_content := HBoxContainer.new()
	hbox_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_content.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox_content)

	# Grid de Slots de Itens (Esq)
	container_grid = GridContainer.new()
	container_grid.columns = 4
	container_grid.custom_minimum_size = Vector2(220, 0)
	container_grid.add_theme_constant_override("h_separation", 4)
	container_grid.add_theme_constant_override("v_separation", 4)
	hbox_content.add_child(container_grid)

	# Detalhes do Item Selecionado (Dir)
	lbl_detalhes = Label.new()
	lbl_detalhes.text = "Selecione um item para ver detalhes."
	lbl_detalhes.add_theme_font_size_override("font_size", 8)
	lbl_detalhes.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_detalhes.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_detalhes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_content.add_child(lbl_detalhes)

	var lbl_fechar := Label.new()
	lbl_fechar.text = "[Pressione I para Fechar]"
	lbl_fechar.add_theme_font_size_override("font_size", 8)
	lbl_fechar.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7, 1))
	lbl_fechar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_fechar)


func _atualizar_inventario() -> void:
	if container_grid == null:
		return

	for child in container_grid.get_children():
		child.queue_free()

	var inv: Dictionary = PlayerData.inventory
	if inv.is_empty():
		lbl_detalhes.text = "Seu alforje de inventário está vazio."
		return

	for item_id in inv.keys():
		var qtd: int = inv[item_id]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(48, 24)
		btn.text = "%s x%d" % [item_id.left(6), qtd]
		btn.add_theme_font_size_override("font_size", 8)
		HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_GREEN)

		btn.pressed.connect(func():
			lbl_detalhes.text = "📦 Item: %s\n📊 Quantidade: %d" % [item_id.to_upper(), qtd]
		)

		container_grid.add_child(btn)
