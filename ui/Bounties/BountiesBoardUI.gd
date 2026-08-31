class_name BountiesBoardUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - QUADRO DE MISSÕES E CONTRATOS DE CAÇA (BOUNTIES BOARD)
# ============================================================
#
# Interface para visualização, aceitação e resgate de recompensas
# de contratos de caça, procurados e radiant quests de farm.
#
# ============================================================

const RadiantQuestGeneratorScript = preload("res://resource/quest/RadiantQuestGenerator.gd")

var panel_main: PanelContainer
var vbox_content: VBoxContainer
var container_bounties: VBoxContainer
var btn_fechar: Button
var btn_atualizar: Button

var radiant_quests: Array[Quest] = []


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 15
	visible = false
	_construir_ui()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	_gerar_ou_atualizar_contratos()
	_atualizar_ui()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(320, 190)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.14, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 2
	style.border_color = Color(0.9, 0.6, 0.2, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel_main.add_theme_stylebox_override("panel", style)
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel_main.add_child(margin)

	vbox_content = VBoxContainer.new()
	vbox_content.add_theme_constant_override("separation", 4)
	margin.add_child(vbox_content)

	var hbox_header := HBoxContainer.new()
	vbox_content.add_child(hbox_header)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "📜 QUADRO DE CONTRATOS & CAÇADAS"
	lbl_titulo.add_theme_font_size_override("font_size", 6)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_titulo)

	btn_atualizar = Button.new()
	btn_atualizar.text = "🔄 Novos Contratos"
	btn_atualizar.add_theme_font_size_override("font_size", 4)
	btn_atualizar.pressed.connect(_on_btn_atualizar_pressed)
	hbox_header.add_child(btn_atualizar)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(300, 130)
	vbox_content.add_child(scroll)

	container_bounties = VBoxContainer.new()
	container_bounties.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container_bounties.add_theme_constant_override("separation", 3)
	scroll.add_child(container_bounties)

	btn_fechar = Button.new()
	btn_fechar.text = "✖️ Fechar Quadro"
	btn_fechar.add_theme_font_size_override("font_size", 5)
	btn_fechar.pressed.connect(fechar)
	vbox_content.add_child(btn_fechar)


func _gerar_ou_atualizar_contratos() -> void:
	if radiant_quests.is_empty():
		var regiao_id = "vale_padokia"
		if GameManager != null and not GameManager.current_region_id.is_empty():
			regiao_id = GameManager.current_region_id
		var p_lvl = 1
		if PlayerData != null and PlayerData.attributes.has("level"):
			p_lvl = PlayerData.attributes["level"]
		radiant_quests = RadiantQuestGeneratorScript.gerar_pool_radiant_quests(regiao_id, p_lvl, 4)


func _on_btn_atualizar_pressed() -> void:
	var regiao_id = "vale_padokia"
	if GameManager != null and not GameManager.current_region_id.is_empty():
		regiao_id = GameManager.current_region_id
	var p_lvl = 1
	if PlayerData != null and PlayerData.attributes.has("level"):
		p_lvl = PlayerData.attributes["level"]
	radiant_quests = RadiantQuestGeneratorScript.gerar_pool_radiant_quests(regiao_id, p_lvl, 4)
	_atualizar_ui()
	if EventBus != null and EventBus.has_signal("toast_requested"):
		EventBus.emit_toast("📜 Novos contratos afixados no quadro!", Color(1.0, 0.8, 0.2))


func _atualizar_ui() -> void:
	for child in container_bounties.get_children():
		child.queue_free()

	# 1. Contratos Dinâmicos do BountySystem
	if BountySystem != null:
		var regiao_id = "vale_padokia"
		if GameManager != null and not GameManager.current_region_id.is_empty():
			regiao_id = GameManager.current_region_id
		var bounties_lista = BountySystem.obter_contratos_por_regiao(regiao_id)
		for b in bounties_lista:
			_renderizar_cartaz_bounty(b)

	# 2. Quests de Caça e Coleta do RadiantQuestGenerator
	for q in radiant_quests:
		_renderizar_cartaz_radiant_quest(q)


func _renderizar_cartaz_bounty(b: Dictionary) -> void:
	var item_panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.08, 0.08, 0.9)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.8, 0.3, 0.3)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	item_panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	item_panel.add_child(hbox)

	var lbl := Label.new()
	lbl.text = "🎯 [PROCURADO] %s (Nv. %d)\nRecompensa: +%d Jenny\n%s" % [
		b["nome_alvo"],
		b.get("nivel_alvo", 1),
		b["recompensa_jenny"],
		b["descricao"]
	]
	lbl.add_theme_font_size_override("font_size", 4)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var btn := Button.new()
	btn.add_theme_font_size_override("font_size", 4)
	if b.get("concluido", false):
		btn.text = "✅ Concluído"
		btn.disabled = true
	elif b.get("aceito", false):
		btn.text = "⚔️ Caçando..."
		btn.disabled = true
	else:
		btn.text = "Aceitar Contrato"
		btn.pressed.connect(func():
			if BountySystem != null:
				BountySystem.aceitar_contrato(b["id"])
				_atualizar_ui()
		)
	hbox.add_child(btn)
	container_bounties.add_child(item_panel)


func _renderizar_cartaz_radiant_quest(q: Quest) -> void:
	var item_panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.10, 0.14, 0.9)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.6, 0.8)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	item_panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	item_panel.add_child(hbox)

	var ja_ativa = false
	var ja_concluida = false
	if QuestSystem != null:
		ja_ativa = QuestSystem.is_quest_active(q)
	if PlayerData != null:
		ja_concluida = PlayerData.is_quest_completed(q)

	var lbl := Label.new()
	lbl.text = "%s (Nv. Mín %d)\nRecompensa: +%d Gold, +%d XP\n%s" % [
		q.quest_name,
		q.min_level,
		q.reward_gold,
		q.reward_xp,
		q.description
	]
	lbl.add_theme_font_size_override("font_size", 4)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var btn := Button.new()
	btn.add_theme_font_size_override("font_size", 4)
	if ja_concluida:
		btn.text = "🏆 Concluído"
		btn.disabled = true
	elif ja_ativa:
		btn.text = "Em Andamento"
		btn.disabled = true
	else:
		btn.text = "Aceitar Missão"
		btn.pressed.connect(func():
			if QuestSystem != null:
				QuestSystem.start_quest(q)
				if EventBus != null and EventBus.has_signal("toast_requested"):
					EventBus.emit_toast("📜 Missão Aceita: %s!" % q.quest_name, Color(0.4, 1.0, 0.4))
				_atualizar_ui()
		)
	hbox.add_child(btn)
	container_bounties.add_child(item_panel)
