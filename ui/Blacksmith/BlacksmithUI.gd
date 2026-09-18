class_name BlacksmithUI
extends CanvasLayer

const NenStoneSystemScript = preload("res://scripts/systems/equipment/NenStoneSystem.gd")

const EquipmentCatalogScript = preload("res://resource/item/EquipmentCatalog.gd")

var panel_main: PanelContainer
var vbox_content: VBoxContainer
var lbl_gold: Label
var tab_container: TabContainer

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
	panel_main.custom_minimum_size = Vector2(300, 180)
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
	for item_id in EquipmentCatalogScript.ids():
		if not PlayerData.tem_item(StringName(str(item_id))):
			continue
		has_items = true
		var id_str: String = str(item_id)
		var nivel = PlayerData.inventory["equipamentos_upgrade"].get(id_str, 0)
		var btn := Button.new()
		if nivel < 10:
			var custo = 100 * (nivel + 1)
			btn.text = "%s +%d → Melhorar (%d Jenny)" % [EquipmentCatalogScript.obter_nome(id_str), nivel, custo]
			btn.pressed.connect(func():
				if Economy.remover_gold(custo):
					PlayerData.inventory["equipamentos_upgrade"][id_str] = nivel + 1
					# +1 força flat por nível de upgrade enquanto equipado
					if PlayerData.esta_equipado(id_str):
						PlayerData.adicionar_modificador(StatModifier.new(
							StringName("upg_%s" % id_str),
							&"forca",
							StatModifier.Type.FLAT,
							float(nivel + 1),
							-1.0,
							"equip_upgrade_%s" % id_str
						))
					if EventBus != null:
						EventBus.emit_toast("Forja: %s +%d" % [EquipmentCatalogScript.obter_nome(id_str), nivel + 1], Color(1.0, 0.7, 0.3))
					_atualizar_ui()
			)
		else:
			var pedra := NenStoneSystemScript.pedra_equipada(id_str)
			if pedra.is_empty():
				btn.text = "%s +10 — Encaixar Pedra Nen" % EquipmentCatalogScript.obter_nome(id_str)
				btn.pressed.connect(func(): _mostrar_menu_pedras(id_str))
			else:
				var meta := NenStoneSystemScript.obter_meta(pedra)
				btn.text = "%s +10 [%s]" % [EquipmentCatalogScript.obter_nome(id_str), str(meta.get("nome", pedra))]
				btn.pressed.connect(func():
					var rem := NenStoneSystemScript.remover(id_str)
					if bool(rem.get("ok", false)) and EventBus != null:
						EventBus.emit_toast("Pedra removida.", Color(0.8, 0.9, 1.0))
					_atualizar_ui()
				)

		btn.add_theme_font_size_override("font_size", 5)
		container.add_child(btn)

	if not has_items:
		var lbl = Label.new()
		lbl.text = "Nenhum equipamento para melhorar. Craft ou treine com mestres."
		lbl.add_theme_font_size_override("font_size", 5)
		container.add_child(lbl)


func _mostrar_menu_pedras(item_id: String) -> void:
	for stone in NenStoneSystemScript.listar_pedras():
		var sid := str(stone.get("id", ""))
		if sid.is_empty():
			continue
		var sub := Button.new()
		sub.text = "Encaixar %s" % str(stone.get("nome", sid))
		sub.add_theme_font_size_override("font_size", 4)
		sub.pressed.connect(func():
			var res := NenStoneSystemScript.encaixar(item_id, sid)
			if bool(res.get("ok", false)):
				if EventBus != null:
					EventBus.emit_toast("Pedra encaixada!", Color(0.6, 0.85, 1.0))
				if SaveManager != null:
					SaveManager.salvar_jogo()
			elif EventBus != null:
				EventBus.emit_toast("Forja: %s" % str(res.get("reason", "falhou")), Color(1.0, 0.45, 0.35))
			_atualizar_ui()
		)
		vbox_content.add_child(sub)


func _preencher_crafting(container: Control) -> void:
	for info in EquipmentCatalogScript.listar_crafts():
		var btn := Button.new()
		btn.text = "%s — %d Jenny" % [info["nome"], info["custo"]]
		btn.add_theme_font_size_override("font_size", 5)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var craft_id: String = str(info["id"])
		var custo: int = int(info["custo"])
		btn.pressed.connect(func():
			if Economy.remover_gold(custo):
				PlayerData.adicionar_item(StringName(craft_id), 1)
				if EventBus != null:
					EventBus.emit_toast("Forjou: %s (equipe em I)" % EquipmentCatalogScript.obter_nome(craft_id), Color(0.55, 0.95, 0.45))
				_atualizar_ui()
		)
		container.add_child(btn)

	# Ofertas básicas sempre disponíveis (não só craft flag)
	for extra_id in ["adaga_zaban", "colete_cacador", "escudo_leve", "anel_aura"]:
		var def: Dictionary = EquipmentCatalogScript.obter(extra_id)
		if def.is_empty():
			continue
		var custo2: int = int(def.get("preco", 200))
		var btn2 := Button.new()
		btn2.text = "%s — %d Jenny" % [str(def.get("nome", extra_id)), custo2]
		btn2.add_theme_font_size_override("font_size", 5)
		btn2.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var eid: String = extra_id
		btn2.pressed.connect(func():
			if Economy.remover_gold(custo2):
				PlayerData.adicionar_item(StringName(eid), 1)
				if EventBus != null:
					EventBus.emit_toast("Comprou: %s" % EquipmentCatalogScript.obter_nome(eid), Color(0.55, 0.95, 0.45))
				_atualizar_ui()
		)
		container.add_child(btn2)
