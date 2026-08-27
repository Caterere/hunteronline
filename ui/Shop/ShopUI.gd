class_name ShopUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - SHOP UI (PHASE 2)
# ============================================================
#
# Interface de Loja de Itens com Tabs.
#
# ============================================================

var panel_main: PanelContainer
var vbox_content: VBoxContainer
var lbl_gold: Label
var container_itens: VBoxContainer
var btn_fechar: Button
var tab_container: TabContainer

var tab_materiais: VBoxContainer
var tab_equipamentos: VBoxContainer
var tab_cosmeticos: VBoxContainer
var tab_vender: VBoxContainer

var materiais = [
	{"id": "minerio_aco", "nome": "Minério de Aço", "preco": 100, "descricao": "Material de Forja"},
	{"id": "couro_besta", "nome": "Couro de Besta", "preco": 150, "descricao": "Material de Forja"},
	{"id": "tecido_reforcado", "nome": "Tecido com Nen", "preco": 200, "descricao": "Material de Capa"},
	{"id": "cristal_aura", "nome": "Cristal de Aura", "preco": 500, "descricao": "Melhoria +1 a +10"}
]

var equipamentos = [
	{"id": "anel_concentracao", "nome": "Anel de Concentração", "preco": 400, "descricao": "+2 Força"},
	{"id": "pingente_agilidade", "nome": "Pingente de Agilidade", "preco": 400, "descricao": "+2 Velocidade"},
	{"id": "cinto_ten", "nome": "Cinto Protetor de Ten", "preco": 400, "descricao": "+2 Defesa"}
]

var cosmeticos = [
	{"id": "guia_hunter_lore", "nome": "Guia Oficial Hunter", "preco": 250, "descricao": "Colecionável"},
	{"id": "oculos_escuros", "nome": "Óculos Escuros", "preco": 150, "descricao": "Cosmético"}
]

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 12
	visible = false
	_construir_ui()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	_atualizar_loja()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(290, 165)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.16, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.9, 0.7, 0.2, 1.0)
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

	# Título e Saldo
	var hbox_header := HBoxContainer.new()
	vbox_content.add_child(hbox_header)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "LOJA DO VENDEDOR (JENNY)"
	lbl_titulo.add_theme_font_size_override("font_size", 8)
	lbl_titulo.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
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
	tab_container.tab_changed.connect(func(_tab): _atualizar_loja())
	vbox_content.add_child(tab_container)
	
	tab_materiais = VBoxContainer.new()
	tab_materiais.name = "Materiais"
	tab_container.add_child(tab_materiais)

	tab_equipamentos = VBoxContainer.new()
	tab_equipamentos.name = "Acessórios"
	tab_container.add_child(tab_equipamentos)
	
	tab_cosmeticos = VBoxContainer.new()
	tab_cosmeticos.name = "Cosméticos"
	tab_container.add_child(tab_cosmeticos)
	
	tab_vender = VBoxContainer.new()
	tab_vender.name = "Vender"
	tab_container.add_child(tab_vender)

	btn_fechar = Button.new()
	btn_fechar.text = "Fechar Loja"
	btn_fechar.add_theme_font_size_override("font_size", 5)
	btn_fechar.pressed.connect(fechar)
	vbox_content.add_child(btn_fechar)


func _atualizar_loja() -> void:
	if lbl_gold != null:
		lbl_gold.text = "Jenny: " + str(Economy.obter_gold())
		
	var aba_atual = tab_container.get_current_tab_control()
	if aba_atual == null:
		return
		
	for child in aba_atual.get_children():
		child.queue_free()
		
	if aba_atual.name == "Materiais":
		_preencher_lista(aba_atual, materiais)
	elif aba_atual.name == "Acessórios":
		_preencher_lista(aba_atual, equipamentos)
	elif aba_atual.name == "Cosméticos":
		_preencher_lista(aba_atual, cosmeticos)
	elif aba_atual.name == "Vender":
		_preencher_venda(aba_atual)


func _preencher_lista(container: Control, itens: Array) -> void:
	for info in itens:
		var preco_ajustado = Economy.calcular_preco_compra(info["id"], "associacao_hunter")
		var mod_rep = Economy.obter_modificador_preco_faccao("associacao_hunter")
		var tag_rep = ""
		if mod_rep < 1.0:
			tag_rep = " [Desconto %d%%]" % int((1.0 - mod_rep) * 100)
		elif mod_rep > 1.0:
			tag_rep = " [Sobretaxa %d%%]" % int((mod_rep - 1.0) * 100)

		var btn := Button.new()
		btn.text = "%s (%d Jenny%s) - %s" % [info["nome"], preco_ajustado, tag_rep, info["descricao"]]
		btn.add_theme_font_size_override("font_size", 5)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		btn.pressed.connect(func():
			if Economy.comprar_item(info["id"], "associacao_hunter"):
				print("[ShopUI] Comprado: ", info["nome"])
				_atualizar_loja()
		)
		container.add_child(btn)


func _preencher_venda(container: Control) -> void:
	if PlayerData.inventory.is_empty():
		var lbl = Label.new()
		lbl.text = "Inventário Vazio"
		lbl.add_theme_font_size_override("font_size", 5)
		container.add_child(lbl)
		return
		
	for item_id in PlayerData.inventory.keys():
		var qtd = PlayerData.inventory[item_id]
		if qtd <= 0: continue
		var preco_venda = 50 # Base
		var btn := Button.new()
		btn.text = "Vender %s x%d (+%d Jenny)" % [str(item_id).capitalize(), qtd, preco_venda]
		btn.add_theme_font_size_override("font_size", 5)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		btn.pressed.connect(func():
			if PlayerData.remover_item(item_id, 1):
				Economy.adicionar_gold(preco_venda)
				_atualizar_loja()
		)
		container.add_child(btn)
