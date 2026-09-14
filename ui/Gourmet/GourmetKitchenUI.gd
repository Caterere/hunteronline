class_name GourmetKitchenUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE — A8 GOURMET KITCHEN UI
# ============================================================
#
# Cozinha leve: receitas, writs diários, consumir comida.
# Não compete com árvore de Nen (buffs temporários só).
#
# ============================================================

var panel_main: PanelContainer
var vbox_content: VBoxContainer
var tab_container: TabContainer
var lbl_status: Label


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 12
	visible = false
	_construir_ui()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	if GourmetCooking != null:
		GourmetCooking.garantir_writs_diarios()
	_atualizar_ui()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(300, 180)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.11, 0.09, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.85, 0.55, 0.25, 1.0)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	panel_main.add_theme_stylebox_override("panel", style)
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_main.add_child(margin)

	vbox_content = VBoxContainer.new()
	vbox_content.add_theme_constant_override("separation", 3)
	margin.add_child(vbox_content)

	var hbox_header := HBoxContainer.new()
	vbox_content.add_child(hbox_header)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "COZINHA GOURMET"
	lbl_titulo.add_theme_font_size_override("font_size", 8)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.7, 0.35, 1))
	hbox_header.add_child(lbl_titulo)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(spacer)

	lbl_status = Label.new()
	lbl_status.add_theme_font_size_override("font_size", 5)
	lbl_status.add_theme_color_override("font_color", Color(0.7, 0.9, 0.6, 1))
	hbox_header.add_child(lbl_status)

	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_theme_font_size_override("font_size", 6)
	tab_container.tab_changed.connect(func(_tab): _atualizar_ui())
	vbox_content.add_child(tab_container)

	var tab_cook := VBoxContainer.new()
	tab_cook.name = "Receitas"
	tab_container.add_child(tab_cook)

	var tab_food := VBoxContainer.new()
	tab_food.name = "Comer"
	tab_container.add_child(tab_food)

	var tab_writ := VBoxContainer.new()
	tab_writ.name = "Writs"
	tab_container.add_child(tab_writ)

	var btn_fechar := Button.new()
	btn_fechar.text = "Sair da Cozinha"
	btn_fechar.add_theme_font_size_override("font_size", 5)
	btn_fechar.pressed.connect(fechar)
	vbox_content.add_child(btn_fechar)


func _atualizar_ui() -> void:
	if GourmetCooking == null:
		if lbl_status:
			lbl_status.text = "Sistema offline"
		return
	if lbl_status:
		var gold := Economy.obter_gold() if Economy != null else 0
		lbl_status.text = "Jenny: %d" % gold

	var aba = tab_container.get_current_tab_control()
	for child in aba.get_children():
		child.queue_free()

	match aba.name:
		"Receitas":
			_preencher_receitas(aba)
		"Comer":
			_preencher_comida(aba)
		"Writs":
			_preencher_writs(aba)


func _preencher_receitas(container: Control) -> void:
	for r in GourmetCooking.list_recipes():
		var row := HBoxContainer.new()
		container.add_child(row)
		var ings: Array = []
		for k in r.get("ingredientes", {}).keys():
			ings.append("%dx %s" % [int(r["ingredientes"][k]), k])
		var lbl := Label.new()
		lbl.text = "%s\n%s · %d Jenny · buff %.0fs" % [
			str(r.get("nome")),
			", ".join(ings),
			int(r.get("jenny_custo", 0)),
			float(r.get("buff", {}).get("duration", 0))
		]
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		var btn := Button.new()
		btn.text = "Cozinhar"
		btn.add_theme_font_size_override("font_size", 4)
		var rid := str(r.get("id"))
		btn.pressed.connect(func():
			var res: Dictionary = GourmetCooking.cozinhar(rid)
			if EventBus != null and not bool(res.get("ok", false)):
				EventBus.emit_toast(str(res.get("erro", "Falha")), Color(1.0, 0.4, 0.4))
			_atualizar_ui()
		)
		row.add_child(btn)


func _preencher_comida(container: Control) -> void:
	var any := false
	for food_id in GourmetCooking.FOOD_CATALOG.keys():
		var have := 0
		if PlayerData != null:
			have = int(PlayerData.inventory.get(StringName(food_id), PlayerData.inventory.get(food_id, 0)))
		if have <= 0:
			continue
		any = true
		var row := HBoxContainer.new()
		container.add_child(row)
		var meta: Dictionary = GourmetCooking.FOOD_CATALOG[food_id]
		var lbl := Label.new()
		lbl.text = "%s x%d" % [str(meta.get("nome", food_id)), have]
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		var btn := Button.new()
		btn.text = "Consumir"
		btn.add_theme_font_size_override("font_size", 4)
		var fid := str(food_id)
		btn.pressed.connect(func():
			GourmetCooking.consumir_comida(fid)
			_atualizar_ui()
		)
		row.add_child(btn)
	if not any:
		var empty := Label.new()
		empty.text = "Nenhuma comida no inventário. Cozinhe na aba Receitas."
		empty.add_theme_font_size_override("font_size", 5)
		container.add_child(empty)


func _preencher_writs(container: Control) -> void:
	for w in GourmetCooking.obter_writs():
		var lbl := Label.new()
		lbl.text = "📜 %s\n+%d Jenny · +%d XP Gourmet" % [
			str(w.get("titulo")),
			int(w.get("jenny", 0)),
			int(w.get("gourmet_xp", 0))
		]
		lbl.add_theme_font_size_override("font_size", 5)
		container.add_child(lbl)
	var hint := Label.new()
	hint.text = "Colete erva_nen / carne_javali no mundo; writs completam sozinhos."
	hint.add_theme_font_size_override("font_size", 4)
	hint.add_theme_color_override("font_color", Color(0.7, 0.75, 0.65))
	container.add_child(hint)
