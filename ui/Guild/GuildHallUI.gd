class_name GuildHallUI
extends CanvasLayer

# UI mínima de guilda + contratos de Nen (A6).

var lbl_guild: Label
var lbl_contracts: Label
var name_edit: LineEdit
var tag_edit: LineEdit
var oath_edit: LineEdit
var partner_edit: LineEdit


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 14
	visible = false
	_build()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	_refresh()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(340, 260)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.12, 0.97)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.85, 0.7, 0.25, 1)
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

	var title := Label.new()
	title.text = "⚜️ GUILDA DE CAÇADORES"
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.35, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	lbl_guild = Label.new()
	lbl_guild.add_theme_font_size_override("font_size", 7)
	lbl_guild.autowrap_mode = TextServer.AUTOWRAP_WORD
	root.add_child(lbl_guild)

	var create_row := HBoxContainer.new()
	root.add_child(create_row)
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Nome da guilda"
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	create_row.add_child(name_edit)
	tag_edit = LineEdit.new()
	tag_edit.placeholder_text = "TAG"
	tag_edit.custom_minimum_size = Vector2(50, 0)
	create_row.add_child(tag_edit)
	var btn_create := Button.new()
	btn_create.text = "Criar"
	btn_create.add_theme_font_size_override("font_size", 7)
	btn_create.pressed.connect(_on_create)
	create_row.add_child(btn_create)

	var bank_row := HBoxContainer.new()
	root.add_child(bank_row)
	var btn_dep := Button.new()
	btn_dep.text = "Depositar 500"
	btn_dep.add_theme_font_size_override("font_size", 7)
	btn_dep.pressed.connect(func():
		if HunterGuildSystem:
			HunterGuildSystem.deposit_bank(500)
		_refresh()
	)
	bank_row.add_child(btn_dep)
	var btn_wd := Button.new()
	btn_wd.text = "Sacar 500"
	btn_wd.add_theme_font_size_override("font_size", 7)
	btn_wd.pressed.connect(func():
		if HunterGuildSystem:
			HunterGuildSystem.withdraw_bank(500)
		_refresh()
	)
	bank_row.add_child(btn_wd)
	var btn_leave := Button.new()
	btn_leave.text = "Sair"
	btn_leave.add_theme_font_size_override("font_size", 7)
	btn_leave.pressed.connect(func():
		if HunterGuildSystem:
			HunterGuildSystem.leave_guild()
		_refresh()
	)
	bank_row.add_child(btn_leave)

	lbl_contracts = Label.new()
	lbl_contracts.add_theme_font_size_override("font_size", 7)
	lbl_contracts.autowrap_mode = TextServer.AUTOWRAP_WORD
	root.add_child(lbl_contracts)

	var oath_row := HBoxContainer.new()
	root.add_child(oath_row)
	partner_edit = LineEdit.new()
	partner_edit.placeholder_text = "ID parceiro"
	partner_edit.custom_minimum_size = Vector2(90, 0)
	oath_row.add_child(partner_edit)
	oath_edit = LineEdit.new()
	oath_edit.placeholder_text = "Juramento de Nen"
	oath_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	oath_row.add_child(oath_edit)
	var btn_oath := Button.new()
	btn_oath.text = "Assinar"
	btn_oath.add_theme_font_size_override("font_size", 7)
	btn_oath.pressed.connect(_on_oath)
	oath_row.add_child(btn_oath)

	var btn_close := Button.new()
	btn_close.text = "Fechar"
	btn_close.add_theme_font_size_override("font_size", 8)
	btn_close.pressed.connect(fechar)
	root.add_child(btn_close)


func _on_create() -> void:
	if HunterGuildSystem == null:
		return
	HunterGuildSystem.create_guild(name_edit.text, tag_edit.text)
	_refresh()


func _on_oath() -> void:
	if NenContractManager == null:
		return
	NenContractManager.propose_contract(partner_edit.text, oath_edit.text)
	_refresh()


func _refresh() -> void:
	if HunterGuildSystem != null:
		lbl_guild.text = HunterGuildSystem.summary_text()
	if NenContractManager != null:
		var lines: PackedStringArray = [NenContractManager.summary_text()]
		for c in NenContractManager.list_active():
			lines.append("· %s ↔ %s: %s" % [str(c.get("a_id", "?")), str(c.get("b_id", "?")), str(c.get("oath", ""))])
		lbl_contracts.text = "\n".join(lines)
