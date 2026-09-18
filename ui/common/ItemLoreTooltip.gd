class_name ItemLoreTooltip
extends PanelContainer

# ============================================================
# HUNTER ONLINE - ITEM LORE TOOLTIP (FASE G — TASK 6.3)
# ============================================================
#
# Componente de tooltip rico com estética canônica da Associação Hunter:
# - Nome do Item & Badge de Raridade / Relíquia Histórica
# - Painel de Trade-offs (Prós & Contras de Gameplay)
# - Citações lendárias e registros de expedição
# ============================================================

var lbl_nome: Label
var lbl_raridade: Label
var lbl_tipo: Label
var lbl_descricao: Label
var panel_tradeoff: PanelContainer
var lbl_tradeoff: Label
var panel_lore: PanelContainer
var lbl_quote: Label
var lbl_origem: Label

func _init() -> void:
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_construir_ui()


func _construir_ui() -> void:
	custom_minimum_size = Vector2(160, 90)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.07, 0.10, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.85, 0.70, 0.25, 1.0) # Dourado Hunter
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 5)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# Linha 1: Nome do Item
	lbl_nome = Label.new()
	lbl_nome.add_theme_font_size_override("font_size", 6)
	lbl_nome.add_theme_color_override("font_color", Color(1.0, 0.90, 0.35, 1.0))
	vbox.add_child(lbl_nome)

	# Linha 2: Raridade e Tipo
	var hbox_sub := HBoxContainer.new()
	hbox_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(hbox_sub)

	lbl_raridade = Label.new()
	lbl_raridade.add_theme_font_size_override("font_size", 4)
	hbox_sub.add_child(lbl_raridade)

	var sep := Label.new()
	sep.text = " • "
	sep.add_theme_font_size_override("font_size", 4)
	sep.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	hbox_sub.add_child(sep)

	lbl_tipo = Label.new()
	lbl_tipo.add_theme_font_size_override("font_size", 4)
	lbl_tipo.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	hbox_sub.add_child(lbl_tipo)

	# Linha 3: Descrição
	lbl_descricao = Label.new()
	lbl_descricao.add_theme_font_size_override("font_size", 4)
	lbl_descricao.add_theme_color_override("font_color", Color(0.85, 0.85, 0.90))
	lbl_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(lbl_descricao)

	# Seção de Trade-off (Gameplay)
	panel_tradeoff = PanelContainer.new()
	panel_tradeoff.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style_t := StyleBoxFlat.new()
	style_t.bg_color = Color(0.12, 0.08, 0.06, 0.85)
	style_t.border_width_left = 1
	style_t.border_color = Color(0.95, 0.45, 0.20, 1.0)
	panel_tradeoff.add_theme_stylebox_override("panel", style_t)
	vbox.add_child(panel_tradeoff)

	var m_t := MarginContainer.new()
	m_t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m_t.add_theme_constant_override("margin_left", 4)
	m_t.add_theme_constant_override("margin_top", 2)
	m_t.add_theme_constant_override("margin_bottom", 2)
	panel_tradeoff.add_child(m_t)

	lbl_tradeoff = Label.new()
	lbl_tradeoff.add_theme_font_size_override("font_size", 4)
	lbl_tradeoff.add_theme_color_override("font_color", Color(1.0, 0.75, 0.4))
	lbl_tradeoff.autowrap_mode = TextServer.AUTOWRAP_WORD
	m_t.add_child(lbl_tradeoff)

	# Seção de Lore e Citações Históricas
	panel_lore = PanelContainer.new()
	panel_lore.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style_l := StyleBoxFlat.new()
	style_l.bg_color = Color(0.04, 0.08, 0.10, 0.90)
	style_l.border_width_left = 1
	style_l.border_color = Color(0.3, 0.8, 1.0, 0.8)
	panel_lore.add_theme_stylebox_override("panel", style_l)
	vbox.add_child(panel_lore)

	var m_l := MarginContainer.new()
	m_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m_l.add_theme_constant_override("margin_left", 4)
	m_l.add_theme_constant_override("margin_top", 3)
	m_l.add_theme_constant_override("margin_bottom", 3)
	panel_lore.add_child(m_l)

	var vbox_l := VBoxContainer.new()
	vbox_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox_l.add_theme_constant_override("separation", 2)
	m_l.add_child(vbox_l)

	lbl_quote = Label.new()
	lbl_quote.add_theme_font_size_override("font_size", 4)
	lbl_quote.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	lbl_quote.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox_l.add_child(lbl_quote)

	lbl_origem = Label.new()
	lbl_origem.add_theme_font_size_override("font_size", 3)
	lbl_origem.add_theme_color_override("font_color", Color(0.55, 0.75, 0.85))
	vbox_l.add_child(lbl_origem)


func configurar_com_item(item: ItemData) -> void:
	if item == null:
		visible = false
		return

	lbl_nome.text = item.nome_item
	lbl_descricao.text = item.descricao

	# Raridade e cores
	lbl_raridade.text = item.raridade
	match item.raridade.to_lower():
		"muito raro", "reliquia":
			lbl_raridade.add_theme_color_override("font_color", Color(1.0, 0.80, 0.2))
		"raro":
			lbl_raridade.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
		_:
			lbl_raridade.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

	# Tipo
	lbl_tipo.text = "Equipamento" if item is EquipmentData else ("Chave" if item.tipo == 0 else "Item Especial")

	# Trade-off (se for equipamento)
	if item is EquipmentData and not item.trade_off_descricao.is_empty():
		panel_tradeoff.visible = true
		lbl_tradeoff.text = "⚖️ TRADE-OFF:\n" + item.trade_off_descricao
	else:
		panel_tradeoff.visible = false

	# Lore & Citação
	if not item.lore_quote.is_empty() or not item.lore_origin.is_empty():
		panel_lore.visible = true
		lbl_quote.text = item.lore_quote
		lbl_quote.visible = not item.lore_quote.is_empty()
		lbl_origem.text = "📜 Origem: " + item.lore_origin if not item.lore_origin.is_empty() else ""
		lbl_origem.visible = not item.lore_origin.is_empty()
	else:
		panel_lore.visible = false

	visible = true


func mostrar_na_posicao(pos_global: Vector2, item: ItemData) -> void:
	configurar_com_item(item)
	global_position = pos_global
	visible = true


func esconder() -> void:
	visible = false
