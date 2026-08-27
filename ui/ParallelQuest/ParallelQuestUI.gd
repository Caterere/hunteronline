extends CanvasLayer

# ============================================================
# HUNTER ONLINE - PARALLEL QUEST UI (WHAT-IFs & FARM)
# ============================================================
#
# Menu visual de Missões Paralelas estilo Dragon Ball Xenoverse.
# Exibe fendas temporais por saga com histórias alternativas,
# desafios de combate de alto nível e recompensas massivas de farm.
# Resolução nativa 320x180 (pixel art).
#
# ============================================================

var panel_main: PanelContainer
var container_lista: VBoxContainer
var lbl_detalhe_titulo: Label
var lbl_detalhe_stars: Label
var lbl_detalhe_lore: Label
var lbl_detalhe_inimigos: Label
var lbl_detalhe_recompensas: Label
var btn_iniciar: Button
var lbl_bloqueio_aviso: Label

var missao_selecionada_id: int = 1
var botoes_missoes: Dictionary = {}


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 15
	visible = false
	_construir_ui()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		fechar()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	_atualizar_lista_missoes()
	_selecionar_missao(missao_selecionada_id)


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _construir_ui() -> void:
	for child in get_children():
		child.queue_free()

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.75)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(300, 164)
	panel_main.set_anchors_preset(Control.PRESET_CENTER)
	panel_main.position = Vector2(10, 8)
	panel_main.size = Vector2(300, 164)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.07, 0.12, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.8, 1.0, 0.95) # Ciano dimensional de Nen
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	panel_main.add_theme_stylebox_override("panel", style)
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 3)
	panel_main.add_child(margin)

	var vbox_root := VBoxContainer.new()
	vbox_root.add_theme_constant_override("separation", 2)
	margin.add_child(vbox_root)

	# Header Superior
	var hbox_header := HBoxContainer.new()
	vbox_root.add_child(hbox_header)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "🌌 FENDAS DIMENSIONAIS DE NEN — MISSÕES PARALELAS"
	lbl_titulo.add_theme_font_size_override("font_size", 5)
	lbl_titulo.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
	lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_titulo)

	var btn_fechar := Button.new()
	btn_fechar.text = " ✕ "
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(fechar)
	hbox_header.add_child(btn_fechar)

	# Conteúdo Principal Dividido (Esquerda: Lista / Direita: Detalhes)
	var hbox_content := HBoxContainer.new()
	hbox_content.add_theme_constant_override("separation", 4)
	hbox_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_root.add_child(hbox_content)

	# Painel Esquerdo: Lista de Missões
	var panel_lista := PanelContainer.new()
	panel_lista.custom_minimum_size = Vector2(130, 0)
	panel_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style_l := StyleBoxFlat.new()
	style_l.bg_color = Color(0.02, 0.04, 0.08, 0.9)
	style_l.border_width_left = 1
	style_l.border_width_top = 1
	style_l.border_width_right = 1
	style_l.border_width_bottom = 1
	style_l.border_color = Color(0.15, 0.35, 0.5, 0.8)
	panel_lista.add_theme_stylebox_override("panel", style_l)
	hbox_content.add_child(panel_lista)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_lista.add_child(scroll)

	container_lista = VBoxContainer.new()
	container_lista.add_theme_constant_override("separation", 1)
	container_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(container_lista)

	# Painel Direito: Detalhes da Missão
	var panel_detalhe := PanelContainer.new()
	panel_detalhe.custom_minimum_size = Vector2(150, 0)
	panel_detalhe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style_d := StyleBoxFlat.new()
	style_d.bg_color = Color(0.03, 0.05, 0.09, 0.9)
	style_d.border_width_left = 1
	style_d.border_width_top = 1
	style_d.border_width_right = 1
	style_d.border_width_bottom = 1
	style_d.border_color = Color(0.9, 0.75, 0.2, 0.8) # Dourado de Recompensa
	panel_detalhe.add_theme_stylebox_override("panel", style_d)
	hbox_content.add_child(panel_detalhe)

	var margin_d := MarginContainer.new()
	margin_d.add_theme_constant_override("margin_left", 3)
	margin_d.add_theme_constant_override("margin_top", 2)
	margin_d.add_theme_constant_override("margin_right", 3)
	margin_d.add_theme_constant_override("margin_bottom", 2)
	panel_detalhe.add_child(margin_d)

	var vbox_detalhe := VBoxContainer.new()
	vbox_detalhe.add_theme_constant_override("separation", 1)
	margin_d.add_child(vbox_detalhe)

	lbl_detalhe_titulo = Label.new()
	lbl_detalhe_titulo.text = "PQ 01: O Duelo Real do Túnel"
	lbl_detalhe_titulo.add_theme_font_size_override("font_size", 4)
	lbl_detalhe_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	lbl_detalhe_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhe.add_child(lbl_detalhe_titulo)

	lbl_detalhe_stars = Label.new()
	lbl_detalhe_stars.text = "⭐ Dificuldade: ★☆☆☆☆☆☆"
	lbl_detalhe_stars.add_theme_font_size_override("font_size", 3)
	lbl_detalhe_stars.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2, 1.0))
	vbox_detalhe.add_child(lbl_detalhe_stars)

	var sep1 := HSeparator.new()
	vbox_detalhe.add_child(sep1)

	lbl_detalhe_lore = Label.new()
	lbl_detalhe_lore.text = "Sinopse What-If..."
	lbl_detalhe_lore.add_theme_font_size_override("font_size", 3)
	lbl_detalhe_lore.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95, 1.0))
	lbl_detalhe_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_detalhe_lore.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_detalhe.add_child(lbl_detalhe_lore)

	lbl_detalhe_inimigos = Label.new()
	lbl_detalhe_inimigos.text = "⚔️ Inimigos: ..."
	lbl_detalhe_inimigos.add_theme_font_size_override("font_size", 3)
	lbl_detalhe_inimigos.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
	lbl_detalhe_inimigos.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhe.add_child(lbl_detalhe_inimigos)

	lbl_detalhe_recompensas = Label.new()
	lbl_detalhe_recompensas.text = "🎁 Recompensas: XP / Jenny / Itens"
	lbl_detalhe_recompensas.add_theme_font_size_override("font_size", 3)
	lbl_detalhe_recompensas.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
	lbl_detalhe_recompensas.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhe.add_child(lbl_detalhe_recompensas)

	lbl_bloqueio_aviso = Label.new()
	lbl_bloqueio_aviso.text = ""
	lbl_bloqueio_aviso.add_theme_font_size_override("font_size", 3)
	lbl_bloqueio_aviso.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))
	lbl_bloqueio_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhe.add_child(lbl_bloqueio_aviso)

	btn_iniciar = Button.new()
	btn_iniciar.text = "⚔️ TELETRANSPORTAR PARA A FENDA"
	btn_iniciar.add_theme_font_size_override("font_size", 4)
	btn_iniciar.custom_minimum_size = Vector2(0, 12)
	btn_iniciar.pressed.connect(_on_btn_iniciar_pressed)
	vbox_detalhe.add_child(btn_iniciar)


func _atualizar_lista_missoes() -> void:
	for child in container_lista.get_children():
		container_lista.remove_child(child)
		child.queue_free()
	botoes_missoes.clear()

	var missoes := ParallelQuestCatalog.obter_todas_missoes()
	var max_arco := PlayerData.max_arco_desbloqueado

	for m in missoes:
		var id: int = m.get("id", 1)
		var titulo: String = m.get("title", "PQ")
		var stars: int = m.get("stars", 1)
		var req_arco: int = m.get("arco_requerido", 1)
		var desbloqueada: bool = max_arco >= req_arco
		var concluida: bool = PlayerData.parallel_quests_concluidas.has(id)

		var btn := Button.new()
		var prefixo := ""
		if concluida:
			prefixo = "⭐ [OK] "
		elif desbloqueada:
			prefixo = "🔓 "
		else:
			prefixo = "🔒 "

		var star_str := ""
		for s in range(stars): star_str += "★"

		btn.text = "%s%s (%s)" % [prefixo, titulo, star_str]
		btn.add_theme_font_size_override("font_size", 3)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 10)

		if not desbloqueada:
			btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.8))
		elif concluida:
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
		else:
			btn.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))

		var cur_id = id
		btn.pressed.connect(func(): _selecionar_missao(cur_id))
		container_lista.add_child(btn)
		botoes_missoes[id] = btn


func _selecionar_missao(id: int) -> void:
	missao_selecionada_id = id
	var m := ParallelQuestCatalog.obter_missao_por_id(id)
	if m.is_empty():
		return

	var max_arco := PlayerData.max_arco_desbloqueado
	var req_arco: int = m.get("arco_requerido", 1)
	var desbloqueada: bool = max_arco >= req_arco
	var concluida: bool = PlayerData.parallel_quests_concluidas.has(id)

	var stars_count: int = m.get("stars", 1)
	var star_str := ""
	for s in range(stars_count): star_str += "★"
	for s in range(7 - stars_count): star_str += "☆"

	lbl_detalhe_titulo.text = m.get("title", "Missão Paralela")
	lbl_detalhe_stars.text = "Dificuldade: %s | Saga %s (Arco %d)" % [star_str, m.get("saga_nome", ""), req_arco]

	lbl_detalhe_lore.text = "📖 " + m.get("what_if_lore", "")
	lbl_detalhe_inimigos.text = "⚔️ Inimigos: " + m.get("inimigos_descricao", "")

	var xp: int = m.get("reward_xp", 1000)
	var gold: int = m.get("reward_gold", 5000)
	var items: Array = m.get("reward_items", [])
	var item_str := ""
	for it in items:
		item_str += "+%dx %s  " % [it.get("qtd", 1), String(it.get("id", "")).capitalize()]

	lbl_detalhe_recompensas.text = "🎁 XP: %d | Jenny: %d\n🎒 Drops: %s" % [xp, gold, item_str]

	if not desbloqueada:
		lbl_bloqueio_aviso.text = "🔒 Bloqueado: Avance até o Arco %d (%s) no Modo História." % [req_arco, m.get("saga_nome", "")]
		btn_iniciar.disabled = true
		btn_iniciar.text = "🔒 FENDA TEMPORAL BLOQUEADA"
	else:
		lbl_bloqueio_aviso.text = "✅ Status: " + ("Concluída com Sucesso!" if concluida else "Disponível para Desafio!")
		btn_iniciar.disabled = false
		btn_iniciar.text = "⚔️ ENTRAR NA FENDA TEMPORAL"


func _on_btn_iniciar_pressed() -> void:
	PlayerData.missao_paralela_ativa_id = missao_selecionada_id
	fechar()
	print("[ParallelQuestUI] Teletransportando para a Arena da Missão Paralela PQ: ", missao_selecionada_id)
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://world/maps/parallel_quest_arena.tscn", "Fenda Temporal de Chrono", "Missão Paralela PQ #%02d" % missao_selecionada_id)
	else:
		get_tree().change_scene_to_file("res://world/maps/parallel_quest_arena.tscn")
