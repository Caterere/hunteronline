class_name PartyHUD
extends Control

# ============================================================
# HUNTER ONLINE — PARTY HUD (COMPACT HUNTING PARTY FRAME)
# ============================================================
#
# Exibe os membros do grupo de caçada de forma nítida e não-intrusiva
# na resolução nativa de 640x360 pixels.
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var vbox_membros: VBoxContainer = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(100, 60)
	position = Vector2(8, 75)

	vbox_membros = VBoxContainer.new()
	vbox_membros.name = "PartyList"
	vbox_membros.add_theme_constant_override("separation", 3)
	add_child(vbox_membros)

	if PartyManager != null:
		if not PartyManager.party_dados_atualizados.is_connected(_on_party_dados_atualizados):
			PartyManager.party_dados_atualizados.connect(_on_party_dados_atualizados)
		_on_party_dados_atualizados(PartyManager.obter_membros())


func _on_party_dados_atualizados(membros: Array) -> void:
	for c in vbox_membros.get_children():
		c.queue_free()

	# Se não estiver em party ou estiver sozinho, oculta
	if membros.size() <= 1:
		visible = false
		return

	visible = true

	for m in membros:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(95, 18)
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 2))

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 3)
		margin.add_theme_constant_override("margin_right", 3)
		margin.add_theme_constant_override("margin_top", 2)
		margin.add_theme_constant_override("margin_bottom", 2)
		panel.add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 1)
		margin.add_child(vbox)

		# Linha superior: Nome + Ícone de Líder
		var hbox_top := HBoxContainer.new()
		var is_leader: bool = m.get("is_leader", false)
		if is_leader:
			var lbl_crown := Label.new()
			lbl_crown.text = "👑"
			lbl_crown.add_theme_font_size_override("font_size", 4)
			hbox_top.add_child(lbl_crown)

		var lbl_nome := Label.new()
		lbl_nome.text = "%s (Nv.%d)" % [m.get("name", "Hunter"), m.get("level", 1)]
		lbl_nome.add_theme_font_size_override("font_size", 4)
		lbl_nome.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		hbox_top.add_child(lbl_nome)
		vbox.add_child(hbox_top)

		# Barras de Vida e Aura
		var hp_bar := ProgressBar.new()
		hp_bar.custom_minimum_size = Vector2(85, 2)
		hp_bar.show_percentage = false
		hp_bar.max_value = m.get("hp_max", 100)
		hp_bar.value = m.get("hp", 100)
		vbox.add_child(hp_bar)

		vbox_membros.add_child(panel)
