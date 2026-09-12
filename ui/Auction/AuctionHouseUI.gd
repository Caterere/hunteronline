class_name AuctionHouseUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE — UI DO LEILÃO DE YORKNEW (S1)
# ============================================================

var lbl_gold: Label
var lbl_status: Label
var browse_list: VBoxContainer
var sell_list: VBoxContainer
var mine_list: VBoxContainer
var price_spin: SpinBox
var qty_spin: SpinBox
var selected_sell_item: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 12
	visible = false
	_build_ui()
	if AuctionHouse != null and not AuctionHouse.listings_changed.is_connected(_on_listings_changed):
		AuctionHouse.listings_changed.connect(_on_listings_changed)


func abrir() -> void:
	visible = true
	get_tree().paused = true
	_refresh_all()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _on_listings_changed() -> void:
	if visible:
		_refresh_all()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 300)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.06, 0.10, 0.97)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.92, 0.72, 0.22, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	for m in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(m, 8)
	for m in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(m, 6)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 4)
	margin.add_child(root)

	var header := HBoxContainer.new()
	root.add_child(header)
	var lbl_header := Label.new()
	lbl_header.text = "🏛️ LEILÃO UNDERGROUND — YORKNEW"
	lbl_header.add_theme_font_size_override("font_size", 11)
	lbl_header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1))
	header.add_child(lbl_header)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	lbl_gold = Label.new()
	lbl_gold.add_theme_font_size_override("font_size", 9)
	lbl_gold.add_theme_color_override("font_color", Color(0.45, 0.9, 1.0, 1))
	header.add_child(lbl_gold)

	lbl_status = Label.new()
	lbl_status.add_theme_font_size_override("font_size", 7)
	lbl_status.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85, 1))
	lbl_status.autowrap_mode = TextServer.AUTOWRAP_WORD
	root.add_child(lbl_status)

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_theme_font_size_override("font_size", 8)
	tabs.tab_changed.connect(func(_i): _refresh_all())
	root.add_child(tabs)

	var tab_browse := VBoxContainer.new()
	tab_browse.name = "Comprar"
	tabs.add_child(tab_browse)
	browse_list = _make_scroll_list(tab_browse)

	var tab_sell := VBoxContainer.new()
	tab_sell.name = "Anunciar"
	tabs.add_child(tab_sell)
	var sell_controls := HBoxContainer.new()
	sell_controls.add_theme_constant_override("separation", 6)
	tab_sell.add_child(sell_controls)
	var lbl_q := Label.new()
	lbl_q.text = "Qtd"
	lbl_q.add_theme_font_size_override("font_size", 7)
	sell_controls.add_child(lbl_q)
	qty_spin = SpinBox.new()
	qty_spin.min_value = 1
	qty_spin.max_value = 99
	qty_spin.value = 1
	qty_spin.custom_minimum_size = Vector2(60, 0)
	sell_controls.add_child(qty_spin)
	var lbl_p := Label.new()
	lbl_p.text = "Preço"
	lbl_p.add_theme_font_size_override("font_size", 7)
	sell_controls.add_child(lbl_p)
	price_spin = SpinBox.new()
	price_spin.min_value = 1
	price_spin.max_value = 9999999
	price_spin.value = 200
	price_spin.custom_minimum_size = Vector2(90, 0)
	sell_controls.add_child(price_spin)
	var btn_list := Button.new()
	btn_list.text = "Listar selecionado"
	btn_list.add_theme_font_size_override("font_size", 7)
	btn_list.pressed.connect(_on_list_pressed)
	sell_controls.add_child(btn_list)
	sell_list = _make_scroll_list(tab_sell)

	var tab_mine := VBoxContainer.new()
	tab_mine.name = "Meus Anúncios"
	tabs.add_child(tab_mine)
	var payout_row := HBoxContainer.new()
	tab_mine.add_child(payout_row)
	var btn_payout := Button.new()
	btn_payout.text = "💰 Coletar vendas"
	btn_payout.add_theme_font_size_override("font_size", 7)
	btn_payout.pressed.connect(_on_collect_payout)
	payout_row.add_child(btn_payout)
	mine_list = _make_scroll_list(tab_mine)

	var btn_close := Button.new()
	btn_close.text = "Fechar Leilão"
	btn_close.add_theme_font_size_override("font_size", 8)
	btn_close.pressed.connect(fechar)
	root.add_child(btn_close)


func _make_scroll_list(parent: VBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 160)
	parent.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)
	scroll.add_child(box)
	return box


func _refresh_all() -> void:
	if Economy != null:
		lbl_gold.text = "%d Jenny" % Economy.obter_gold()
	if AuctionHouse != null:
		lbl_status.text = AuctionHouse.summary_text()
	_refresh_browse()
	_refresh_sell()
	_refresh_mine()


func _clear_box(box: VBoxContainer) -> void:
	for c in box.get_children():
		c.queue_free()


func _item_name(item_id: String) -> String:
	if Economy != null and Economy.ITEM_CATALOGO.has(item_id):
		return str(Economy.ITEM_CATALOGO[item_id].get("nome", item_id))
	return item_id


func _refresh_browse() -> void:
	_clear_box(browse_list)
	if AuctionHouse == null:
		return
	var my_id := str(PlayerData.character_id) if PlayerData != null else ""
	for row in AuctionHouse.get_active_listings():
		var line := HBoxContainer.new()
		var item_id := str(row.get("item_id", ""))
		var lbl := Label.new()
		lbl.text = "%s x%d · %d Jenny · %s · %s" % [
			_item_name(item_id),
			int(row.get("qty", 1)),
			int(row.get("price", 0)),
			str(row.get("rarity", "?")),
			str(row.get("seller_name", "?")),
		]
		lbl.add_theme_font_size_override("font_size", 7)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(lbl)
		var lid := str(row.get("listing_id", ""))
		var mine := str(row.get("seller_id", "")) == my_id and not my_id.is_empty()
		var btn := Button.new()
		btn.text = "Seu" if mine else "Comprar"
		btn.disabled = mine
		btn.add_theme_font_size_override("font_size", 7)
		btn.pressed.connect(_on_buy.bind(lid))
		line.add_child(btn)
		browse_list.add_child(line)


func _refresh_sell() -> void:
	_clear_box(sell_list)
	if PlayerData == null:
		return
	for item_id in PlayerData.inventory.keys():
		var qty := int(PlayerData.inventory[item_id])
		if qty <= 0:
			continue
		var id_str := str(item_id)
		var btn := Button.new()
		btn.text = "%s x%d%s" % [_item_name(id_str), qty, " ◀" if selected_sell_item == id_str else ""]
		btn.add_theme_font_size_override("font_size", 7)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_select_sell.bind(id_str, qty))
		sell_list.add_child(btn)


func _on_select_sell(id_str: String, qty: int) -> void:
	selected_sell_item = id_str
	qty_spin.max_value = maxi(1, qty)
	qty_spin.value = mini(qty_spin.value, qty)
	if Economy != null and Economy.ITEM_CATALOGO.has(id_str):
		price_spin.value = int(Economy.ITEM_CATALOGO[id_str].get("preco", 100))
	_refresh_sell()


func _refresh_mine() -> void:
	_clear_box(mine_list)
	if AuctionHouse == null:
		return
	var info := Label.new()
	info.text = "Payout pendente: %d Jenny" % AuctionHouse.get_pending_payout()
	info.add_theme_font_size_override("font_size", 7)
	mine_list.add_child(info)
	for row in AuctionHouse.get_my_listings():
		var line := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "%s x%d · %d Jenny · taxa paga %d" % [
			_item_name(str(row.get("item_id", ""))),
			int(row.get("qty", 1)),
			int(row.get("price", 0)),
			int(row.get("fee_paid", 0)),
		]
		lbl.add_theme_font_size_override("font_size", 7)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(lbl)
		var btn := Button.new()
		btn.text = "Cancelar"
		btn.add_theme_font_size_override("font_size", 7)
		btn.pressed.connect(_on_cancel.bind(str(row.get("listing_id", ""))))
		line.add_child(btn)
		mine_list.add_child(line)


func _on_buy(listing_id: String) -> void:
	var res: Dictionary = AuctionHouse.buy_listing(listing_id)
	if bool(res.get("ok", false)):
		lbl_status.text = "Comprou %s x%d por %d Jenny" % [
			str(res.get("name", "")), int(res.get("qty", 1)), int(res.get("price", 0))
		]
	else:
		lbl_status.text = "Falha: %s" % str(res.get("error", "?"))
	_refresh_all()


func _on_list_pressed() -> void:
	if selected_sell_item.is_empty():
		lbl_status.text = "Selecione um item do inventário."
		return
	var res: Dictionary = AuctionHouse.list_item(
		selected_sell_item, int(qty_spin.value), int(price_spin.value)
	)
	if bool(res.get("ok", false)):
		lbl_status.text = "Anunciado! Taxa %d Jenny (escrow ativo)." % int(res.get("fee", 0))
		selected_sell_item = ""
	else:
		lbl_status.text = "Falha ao anunciar: %s" % str(res.get("error", "?"))
	_refresh_all()


func _on_cancel(listing_id: String) -> void:
	var res: Dictionary = AuctionHouse.cancel_listing(listing_id)
	lbl_status.text = "Cancelado." if bool(res.get("ok", false)) else "Falha: %s" % str(res.get("error", "?"))
	_refresh_all()


func _on_collect_payout() -> void:
	var res: Dictionary = AuctionHouse.collect_payout()
	if bool(res.get("ok", false)):
		lbl_status.text = "Coletou %d Jenny das vendas." % int(res.get("amount", 0))
	else:
		lbl_status.text = "Sem payout pendente."
	_refresh_all()
