class_name BountiesBoardUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - QUADRO DE MISSÕES E CONTRATOS DE CAÇA (BOUNTIES BOARD)
# ============================================================
#
# Interface para visualização, aceitação e resgate de recompensas
# de contratos rotativos da Associação (A5), Star Hunter, procurados e farm.
#
# ============================================================

var panel_main: PanelContainer
var vbox_content: VBoxContainer
var container_bounties: VBoxContainer
var btn_fechar: Button
var btn_atualizar: Button



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
	lbl_titulo.text = "📜 ASSOCIAÇÃO HUNTER — CONTRATOS"
	lbl_titulo.add_theme_font_size_override("font_size", 6)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_titulo)

	btn_atualizar = Button.new()
	btn_atualizar.text = "🔄 Refresh Diário"
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
	if BountySystem != null:
		BountySystem.garantir_rotacao_associacao(_obter_regiao())


func _obter_regiao() -> String:
	var regiao_id := "vale_padokia"
	if GameManager != null and not str(GameManager.current_region_id).is_empty():
		regiao_id = str(GameManager.current_region_id)
	return regiao_id


func _format_countdown(seconds: int) -> String:
	var s := maxi(0, seconds)
	var h := int(s / 3600)
	var m := int((s % 3600) / 60)
	if h > 48:
		var d := int(h / 24)
		return "%dd %02dh" % [d, h % 24]
	return "%02dh %02dm" % [h, m]


func _on_btn_atualizar_pressed() -> void:
	if BountySystem == null:
		return
	var gratis := BountySystem.refreshes_gratis_restantes() > 0
	var result: Dictionary = BountySystem.solicitar_refresh_diario(not gratis)
	_atualizar_ui()
	if EventBus != null:
		var cor := Color(0.4, 1.0, 0.4) if result.get("ok", false) else Color(1.0, 0.4, 0.4)
		EventBus.emit_toast(str(result.get("motivo", "")), cor)


func _atualizar_ui() -> void:
	for child in container_bounties.get_children():
		child.queue_free()

	_renderizar_cabecalho_rotacao()

	# 1) Star Hunter semanal
	if BountySystem != null:
		var star: Quest = BountySystem.obter_contrato_star_hunter()
		if star != null:
			_renderizar_secao("⭐ STAR HUNTER (Semanal)", Color(1.0, 0.85, 0.25))
			_renderizar_cartaz_associacao(star, true)

		# 2) Contratos diários B/A/S
		var diarios: Array[Quest] = BountySystem.obter_contratos_diarios()
		if not diarios.is_empty():
			_renderizar_secao("📅 Contratos Diários (Licença B/A/S)", Color(0.55, 0.8, 1.0))
			for q in diarios:
				_renderizar_cartaz_associacao(q, false)

		# 3) Lista Negra (bounties estáticos)
		var regiao_id := _obter_regiao()
		var bounties_lista = BountySystem.obter_contratos_por_regiao(regiao_id)
		if not bounties_lista.is_empty():
			_renderizar_secao("🎯 Lista Negra / Procurados", Color(1.0, 0.45, 0.35))
			for b in bounties_lista:
				_renderizar_cartaz_bounty(b)


func _renderizar_cabecalho_rotacao() -> void:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.09, 0.12, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.7, 0.55, 0.2)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	panel.add_theme_stylebox_override("panel", style)

	var lbl := Label.new()
	var tier := "-"
	var stars := 0
	var reset_d := "—"
	var reset_w := "—"
	var refreshes := 0
	if BountySystem != null:
		tier = BountySystem.access_tier_to_string(BountySystem.obter_access_tier_jogador())
		stars = BountySystem.obter_estrelas_hunter()
		reset_d = _format_countdown(BountySystem.obter_segundos_ate_reset_diario())
		reset_w = _format_countdown(BountySystem.obter_segundos_ate_reset_semanal())
		refreshes = BountySystem.refreshes_gratis_restantes()
	lbl.text = "Licença: %s | ★%d  ·  Reset diário: %s  ·  Semanal: %s  ·  Refresh grátis: %d" % [
		tier, stars, reset_d, reset_w, refreshes
	]
	lbl.add_theme_font_size_override("font_size", 4)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	panel.add_child(lbl)
	container_bounties.add_child(panel)


func _renderizar_secao(titulo: String, cor: Color) -> void:
	var lbl := Label.new()
	lbl.text = titulo
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", cor)
	container_bounties.add_child(lbl)


func _renderizar_cartaz_associacao(q: Quest, is_star: bool) -> void:
	var item_panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.09, 0.05, 0.92) if is_star else Color(0.06, 0.10, 0.14, 0.9)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.95, 0.75, 0.2) if is_star else Color(0.3, 0.65, 0.9)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	item_panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	item_panel.add_child(hbox)

	var tier := str(q.custom_data.get("access_tier", "B"))
	var locked := true
	var claimed := false
	var accepted := false
	if BountySystem != null:
		locked = not BountySystem.pode_aceitar_tier("A" if is_star else tier)
		if is_star:
			claimed = BountySystem.is_star_reclamado()
			accepted = BountySystem.is_star_aceito()
		else:
			claimed = BountySystem.is_contrato_diario_reclamado(q)
			accepted = BountySystem.is_contrato_diario_aceito(q)

	var mat_txt := ""
	if not q.reward_items.is_empty() and q.reward_items[0] != null:
		var rw = q.reward_items[0]
		mat_txt = "\nMaterial: %s x%d" % [str(rw.item_id), int(rw.amount)]

	var lbl := Label.new()
	var lock_txt := " 🔒" if locked else ""
	lbl.text = "%s [%s]%s\n+%d Jenny · +%d XP · Rep %d%s\n%s" % [
		q.quest_name,
		tier,
		lock_txt,
		q.reward_gold,
		q.reward_xp,
		int(q.custom_data.get("reward_rep_associacao", 0)),
		mat_txt,
		q.description
	]
	lbl.add_theme_font_size_override("font_size", 4)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var btn := Button.new()
	btn.add_theme_font_size_override("font_size", 4)
	if claimed:
		btn.text = "🏆 Concluído"
		btn.disabled = true
	elif accepted:
		btn.text = "Em Andamento"
		btn.disabled = true
	elif locked:
		btn.text = "Licença %s+" % ("★" if is_star else tier)
		btn.disabled = true
	else:
		btn.text = "Aceitar"
		var quest_ref := q
		btn.pressed.connect(func():
			if BountySystem == null:
				return
			var res: Dictionary = BountySystem.aceitar_contrato_associacao(quest_ref)
			if EventBus != null:
				var cor := Color(0.4, 1.0, 0.4) if res.get("ok", false) else Color(1.0, 0.45, 0.35)
				EventBus.emit_toast(str(res.get("motivo", "Aceito.")) if not res.get("ok", false) else "📜 Contrato aceito!", cor)
			_atualizar_ui()
		)
	hbox.add_child(btn)
	container_bounties.add_child(item_panel)


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
