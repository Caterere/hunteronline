extends CanvasLayer

# ============================================================
# HUNTER ONLINE - LIVRO DE CARTAS DE GREED ISLAND (BINDER UI)
# ============================================================
#
# Livro oficial de 100 Cartas de Bolso Especificado de Greed Island.
# - Rastreia todas as cartas colecionáveis obtidas em Missões e Arcos.
# - Concede bônus de status permanentes à medida que o livro é preenchido.
# - Tecla de Atalho: [B] ou aberto via Inventário/Menu.
#
# ============================================================

var panel_main: PanelContainer
var grid_cartas: GridContainer
var lbl_progresso: Label
var lbl_bonus: Label
var btn_fechar: Button

static var cartas_catalogo = [
	{"num": "000", "id": "carta_000", "nome": "Aliança dos Caçadores", "rank": "SS", "bonus": "+25% Força e Defesa"},
	{"num": "001", "id": "carta_001", "nome": "Sopro Secreto do Arcanjo", "rank": "SS", "bonus": "Regenera +50 HP por segundo"},
	{"num": "002", "id": "carta_002", "nome": "Diamante do Arco-Íris", "rank": "S", "bonus": "+30% Ganho de Jenny"},
	{"num": "003", "id": "carta_003", "nome": "Anel de Ouro Real", "rank": "S", "bonus": "+20% Defesa Mágica de Nen"},
	{"num": "017", "id": "carta_017", "nome": "Castelo do Sol Nascente", "rank": "A", "bonus": "+15% Dano de Hatsu"},
	{"num": "025", "id": "carta_025", "nome": "Dado do Risco e da Sorte", "rank": "A", "bonus": "+25% Taxa de Acerto Crítico"},
	{"num": "050", "id": "carta_050", "nome": "Fada da Floresta Densa", "rank": "B", "bonus": "+15 Velocidade de Movimento"},
	{"num": "075", "id": "carta_075", "nome": "Água Sagrada de Dion", "rank": "B", "bonus": "+200 Aura Máxima"},
	{"num": "084", "id": "carta_084", "nome": "Chave da Verdade Oculta", "rank": "A", "bonus": "+10% Chance de Drop Raro"},
	{"num": "099", "id": "carta_099", "nome": "Bênção da Fada da Fortuna", "rank": "S", "bonus": "+20% Ganho de XP de Nen"}
]


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 15
	visible = false
	_construir_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		var input_ctx = get_node_or_null("/root/InputContextManager")
		if input_ctx != null and not input_ctx.is_global_hotkey_allowed():
			return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B or (event.keycode == KEY_ESCAPE and visible):
			alternar()


func alternar() -> void:
	if visible:
		fechar()
	else:
		abrir()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	_atualizar_ui()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.05, 0.08, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(280, 160)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_main.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_AURA_CYAN, 4))
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
	lbl_titulo.text = "📖 LIVRO DE CARTAS — GREED ISLAND (BINDER)"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_font_size_override("font_size", 5)
	lbl_titulo.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
	vbox.add_child(lbl_titulo)

	lbl_progresso = Label.new()
	lbl_progresso.text = "Progresso da Coleção: 0 / 100 Cartas Obtidas"
	lbl_progresso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_progresso.add_theme_font_size_override("font_size", 4)
	lbl_progresso.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	vbox.add_child(lbl_progresso)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(260, 90)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	grid_cartas = GridContainer.new()
	grid_cartas.columns = 2
	grid_cartas.add_theme_constant_override("h_separation", 4)
	grid_cartas.add_theme_constant_override("v_separation", 3)
	grid_cartas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid_cartas)

	var hbox_foot := HBoxContainer.new()
	vbox.add_child(hbox_foot)

	lbl_bonus = Label.new()
	lbl_bonus.text = "Bônus Ativos: Nenhum"
	lbl_bonus.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_bonus.add_theme_font_size_override("font_size", 3)
	lbl_bonus.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6, 1.0))
	hbox_foot.add_child(lbl_bonus)

	btn_fechar = Button.new()
	btn_fechar.text = "Fechar [B]"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(fechar)
	hbox_foot.add_child(btn_fechar)


func _atualizar_ui() -> void:
	for c in grid_cartas.get_children():
		c.queue_free()

	var obtidas_count: int = 0

	for carta in cartas_catalogo:
		var c_id: String = carta["id"]
		var possui: bool = PlayerData.tem_item(StringName(c_id))
		if possui:
			obtidas_count += 1

		var card_panel := PanelContainer.new()
		card_panel.custom_minimum_size = Vector2(125, 24)

		var c_style := StyleBoxFlat.new()
		c_style.bg_color = Color(0.12, 0.18, 0.26, 0.95) if possui else Color(0.06, 0.08, 0.12, 0.8)
		c_style.border_width_left = 1
		c_style.border_width_top = 1
		c_style.border_width_right = 1
		c_style.border_width_bottom = 1
		c_style.border_color = Color(0.4, 0.8, 1.0, 0.9) if possui else Color(0.3, 0.3, 0.4, 0.5)
		c_style.corner_radius_top_left = 2
		c_style.corner_radius_top_right = 2
		c_style.corner_radius_bottom_right = 2
		c_style.corner_radius_bottom_left = 2
		card_panel.add_theme_stylebox_override("panel", c_style)

		var c_box := VBoxContainer.new()
		c_box.add_theme_constant_override("separation", 1)
		card_panel.add_child(c_box)

		var lbl_c_title := Label.new()
		if possui:
			lbl_c_title.text = "#%s: %s (Rank %s)" % [carta["num"], carta["nome"], carta["rank"]]
			lbl_c_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
		else:
			lbl_c_title.text = "#%s: [NÃO OBTIDA]" % carta["num"]
			lbl_c_title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
		lbl_c_title.add_theme_font_size_override("font_size", 4)
		c_box.add_child(lbl_c_title)

		var lbl_c_desc := Label.new()
		lbl_c_desc.text = "Efeito: " + carta["bonus"] if possui else "Obtenha em Missões Paralelas e Chefes"
		lbl_c_desc.add_theme_font_size_override("font_size", 3)
		lbl_c_desc.add_theme_color_override("font_color", Color(0.4, 1.0, 0.7, 1.0) if possui else Color(0.4, 0.4, 0.4, 1.0))
		c_box.add_child(lbl_c_desc)

		grid_cartas.add_child(card_panel)

	if lbl_progresso != null:
		lbl_progresso.text = "Progresso da Coleção: %d / %d Cartas Desbloqueadas" % [obtidas_count, cartas_catalogo.size()]

	if lbl_bonus != null:
		lbl_bonus.text = "Bônus de Colecionador Ativo: +%d%% em Todos os Atributos" % (obtidas_count * 3)
