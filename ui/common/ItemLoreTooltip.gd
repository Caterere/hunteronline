class_name ItemLoreTooltip
extends PanelContainer

# ============================================================
# HUNTER ONLINE - ITEM LORE TOOLTIP
# ============================================================
#
# Tooltip rico com estética madeira/pergaminho da Associação Hunter:
# - Nome, raridade, tipo, descrição
# - Stats de equipamento e trade-offs
# - Citações / origem de relíquias
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var lbl_nome: Label
var lbl_raridade: Label
var lbl_tipo: Label
var lbl_descricao: Label
var lbl_stats: Label
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
	custom_minimum_size = Vector2(168, 90)
	add_theme_stylebox_override(
		"panel",
		HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 3)
	)

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

	lbl_nome = Label.new()
	lbl_nome.add_theme_font_size_override("font_size", 6)
	lbl_nome.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	vbox.add_child(lbl_nome)

	var hbox_sub := HBoxContainer.new()
	hbox_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(hbox_sub)

	lbl_raridade = Label.new()
	lbl_raridade.add_theme_font_size_override("font_size", 4)
	hbox_sub.add_child(lbl_raridade)

	var sep := Label.new()
	sep.text = " • "
	sep.add_theme_font_size_override("font_size", 4)
	sep.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
	hbox_sub.add_child(sep)

	lbl_tipo = Label.new()
	lbl_tipo.add_theme_font_size_override("font_size", 4)
	lbl_tipo.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_CYAN)
	hbox_sub.add_child(lbl_tipo)

	lbl_descricao = Label.new()
	lbl_descricao.add_theme_font_size_override("font_size", 4)
	lbl_descricao.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	lbl_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(lbl_descricao)

	lbl_stats = Label.new()
	lbl_stats.add_theme_font_size_override("font_size", 4)
	lbl_stats.add_theme_color_override("font_color", HunterUIStyle.COLOR_REN)
	lbl_stats.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(lbl_stats)

	panel_tradeoff = PanelContainer.new()
	panel_tradeoff.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style_t := StyleBoxFlat.new()
	style_t.bg_color = Color(0.55, 0.38, 0.18, 0.55)
	style_t.border_width_left = 1
	style_t.border_color = HunterUIStyle.COLOR_GOLD
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
	lbl_tradeoff.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_tradeoff.autowrap_mode = TextServer.AUTOWRAP_WORD
	m_t.add_child(lbl_tradeoff)

	panel_lore = PanelContainer.new()
	panel_lore.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style_l := StyleBoxFlat.new()
	style_l.bg_color = Color(0.42, 0.55, 0.48, 0.45)
	style_l.border_width_left = 1
	style_l.border_color = HunterUIStyle.COLOR_BORDER_GREEN
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
	lbl_quote.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	lbl_quote.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox_l.add_child(lbl_quote)

	lbl_origem = Label.new()
	lbl_origem.add_theme_font_size_override("font_size", 3)
	lbl_origem.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
	vbox_l.add_child(lbl_origem)


func configurar_com_item(item: ItemData) -> void:
	if item == null:
		visible = false
		return

	lbl_nome.text = item.nome_item
	lbl_descricao.text = item.descricao
	lbl_descricao.visible = not item.descricao.strip_edges().is_empty()

	lbl_raridade.text = item.raridade if not item.raridade.is_empty() else "Comum"
	match item.raridade.to_lower():
		"muito raro", "reliquia":
			lbl_raridade.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
		"raro":
			lbl_raridade.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
		_:
			lbl_raridade.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)

	lbl_tipo.text = ItemExplainKit.rotulo_tipo(item)

	var stats := ItemExplainKit.formatar_stats_equipamento(item)
	if not stats.is_empty():
		lbl_stats.visible = true
		lbl_stats.text = "⚔️ %s" % stats
	else:
		lbl_stats.visible = false

	if item is EquipmentData and not (item as EquipmentData).trade_off_descricao.is_empty():
		panel_tradeoff.visible = true
		lbl_tradeoff.text = "⚖️ TRADE-OFF:\n" + (item as EquipmentData).trade_off_descricao
	else:
		panel_tradeoff.visible = false

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
