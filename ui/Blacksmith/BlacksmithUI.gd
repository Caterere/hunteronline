class_name BlacksmithUI
extends CanvasLayer

var panel_main: PanelContainer
var vbox_content: VBoxContainer
var lbl_gold: Label
var tab_container: TabContainer

var crafts = [
	{"id": "espada_aco", "nome": "Espada de Aço", "custo": 500, "ingredientes": "10x Minério"},
	{"id": "armadura_ferro", "nome": "Armadura de Ferro", "custo": 800, "ingredientes": "15x Minério"}
]

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 12
	visible = false
	_construir_ui()

func abrir() -> void:
	visible = true
	get_tree().paused = true
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
	panel_main.custom_minimum_size = Vector2(280, 160)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.16, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.6, 0.3, 0.1, 1.0)
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
	lbl_titulo.text = "FORJA DO FERREIRO"
	lbl_titulo.add_theme_font_size_override("font_size", 8)
	lbl_titulo.add_theme_color_override("font_color", Color(1, 0.5, 0.2, 1))
	hbox_header.add_child(lbl_titulo)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(spacer)

	lbl_gold = Label.new()
	lbl_gold.add_theme_font_size_override("font_size", 6)
	lbl_gold.add_theme_color_override("font_color", Color(0.4, 0.9, 1, 1))
	hbox_header.add_child(lbl_gold)
	
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_theme_font_size_override("font_size", 6)
	tab_container.tab_changed.connect(func(_tab): _atualizar_ui())
	vbox_content.add_child(tab_container)
	
	var tab_upg = VBoxContainer.new()
	tab_upg.name = "Melhorar Equipamento"
	tab_container.add_child(tab_upg)
	
	var tab_craft = VBoxContainer.new()
	tab_craft.name = "Crafting"
	tab_container.add_child(tab_craft)

	var btn_fechar = Button.new()
	btn_fechar.text = "Sair da Forja"
	btn_fechar.add_theme_font_size_override("font_size", 5)
	btn_fechar.pressed.connect(fechar)
	vbox_content.add_child(btn_fechar)

func _atualizar_ui() -> void:
	if lbl_gold != null:
		lbl_gold.text = "Jenny: " + str(Economy.obter_gold())
		
	var aba_atual = tab_container.get_current_tab_control()
	for child in aba_atual.get_children():
		child.queue_free()
		
	if aba_atual.name == "Melhorar Equipamento":
		_preencher_upgrade(aba_atual)
	elif aba_atual.name == "Crafting":
		_preencher_crafting(aba_atual)

func _preencher_upgrade(container: Control) -> void:
	if not PlayerData.inventory.has("equipamentos_upgrade"):
		PlayerData.inventory["equipamentos_upgrade"] = {}
		
	var has_items = false
	if PlayerData.inventory.has("itens"):
		for item_id in PlayerData.inventory["itens"].keys():
			if "espada" in item_id or "armadura" in item_id: # placeholder check
				has_items = true
				var nivel = PlayerData.inventory["equipamentos_upgrade"].get(item_id, 0)
				var btn := Button.new()
				if nivel < 10:
					var custo = 100 * (nivel + 1)
					btn.text = "%s +%d -> Melhorar por %d Jenny" % [item_id, nivel, custo]
					btn.pressed.connect(func():
						if Economy.remover_gold(custo):
							PlayerData.inventory["equipamentos_upgrade"][item_id] = nivel + 1
							print("Upgrade efetuado no item ", item_id, " para +", nivel+1)
							_atualizar_ui()
					)
				else:
					btn.text = "%s +10 (MÁXIMO)" % item_id
					btn.disabled = true
				
				btn.add_theme_font_size_override("font_size", 5)
				container.add_child(btn)
	
	if not has_items:
		var lbl = Label.new()
		lbl.text = "Nenhum equipamento para melhorar."
		lbl.add_theme_font_size_override("font_size", 5)
		container.add_child(lbl)

func _preencher_crafting(container: Control) -> void:
	for info in crafts:
		var btn := Button.new()
		btn.text = "%s - Custo: %d Jenny | Req: %s" % [info["nome"], info["custo"], info["ingredientes"]]
		btn.add_theme_font_size_override("font_size", 5)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		btn.pressed.connect(func():
			if Economy.remover_gold(info["custo"]):
				if not PlayerData.inventory.has("itens"):
					PlayerData.inventory["itens"] = {}
				PlayerData.inventory["itens"][info["id"]] = PlayerData.inventory["itens"].get(info["id"], 0) + 1
				print("Craftado ", info["nome"])
				_atualizar_ui()
		)
		container.add_child(btn)
