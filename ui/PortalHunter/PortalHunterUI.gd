class_name PortalHunterUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - PORTAL HUNTER UI (CANVAS LAYER SCREEN MENU)
# ============================================================
#
# Interface de tela (CanvasLayer) que exibe a seleção de Sagas/Arcos
# e Dificuldade em tela cheia centralizada no viewport do jogador,
# independente da posição do personagem ou câmera no mapa.
# Resolução nativa 320x180.
#
# ============================================================

signal fechado

var selected_arc: int = 1
var selected_diff: PlayerData.Dificuldade = PlayerData.Dificuldade.NORMAL

var btn_sagas: Array[Button] = []
var btn_dificuldades: Array[Button] = []
var lbl_info_lock: Label
var lbl_subtitulo: Label

const ARC_MAPS: Dictionary = {
	1: {"nome": "Arco 1: Exame Hunter", "cena": "res://world/maps/exame_maratona.tscn"},
	2: {"nome": "Arco 2: Montanha Kukuroo", "cena": "res://world/maps/montanha_kukuroo.tscn"},
	3: {"nome": "Arco 3: Arena Celestial", "cena": "res://world/maps/arena_celestial.tscn"},
	4: {"nome": "Arco 4: Yorknew City", "cena": "res://world/maps/yorknew_city.tscn"},
	5: {"nome": "Arco 5: Greed Island", "cena": "res://world/maps/greed_island.tscn"},
	6: {"nome": "Arco 6: Formigas Chimera", "cena": "res://world/maps/ngl_formigas.tscn"},
	7: {"nome": "Arco 7: Eleição Hunter", "cena": "res://world/maps/associacao_hunter.tscn"},
	8: {"nome": "Arco 8: Continente Negro", "cena": "res://world/maps/continente_negro.tscn"},
	9: {"nome": "Arco 9: Black Whale 1", "cena": "res://world/maps/black_whale_1.tscn"}
}


func _ready() -> void:
	layer = 30
	selected_arc = PlayerData.arco_atual
	selected_diff = PlayerData.dificuldade
	_construir_ui()


func _construir_ui() -> void:
	# Nó raiz Control para o CanvasLayer
	var root_control := Control.new()
	root_control.name = "RootControl"
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root_control)
	
	# Fundo Semi-transparente
	var bg_overlay := ColorRect.new()
	bg_overlay.color = Color(0, 0, 0, 0.75)
	bg_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(bg_overlay)
	
	# Painel Principal
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 170)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.10, 0.16, 0.98)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.7, 1.0, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", style)
	root_control.add_child(panel)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 3)
	margin.add_child(main_vbox)
	
	# Título
	var lbl_title := Label.new()
	lbl_title.text = "⛩️ GUIA DO PORTAL DE NEN — MODO HISTÓRIA"
	lbl_title.add_theme_font_size_override("font_size", 7)
	lbl_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(lbl_title)
	
	lbl_subtitulo = Label.new()
	lbl_subtitulo.text = "Saga Atual: Arco %d | Máximo Liberado: Arco %d" % [PlayerData.arco_atual, PlayerData.max_arco_desbloqueado]
	lbl_subtitulo.add_theme_font_size_override("font_size", 5)
	lbl_subtitulo.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 1.0))
	lbl_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(lbl_subtitulo)
	
	# Split central: Sagas à Esquerda, Dificuldade à Direita
	var hbox_content := HBoxContainer.new()
	hbox_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_content.add_theme_constant_override("separation", 6)
	main_vbox.add_child(hbox_content)
	
	# Coluna 1: Sagas (ScrollContainer com Grid)
	var vbox_sagas := VBoxContainer.new()
	vbox_sagas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_content.add_child(vbox_sagas)
	
	var lbl_saga_hdr := Label.new()
	lbl_saga_hdr.text = "Escolha a Saga:"
	lbl_saga_hdr.add_theme_font_size_override("font_size", 5)
	lbl_saga_hdr.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5, 1.0))
	vbox_sagas.add_child(lbl_saga_hdr)
	
	var scroll_sagas := ScrollContainer.new()
	scroll_sagas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_sagas.add_child(scroll_sagas)
	
	var sagas_container := VBoxContainer.new()
	sagas_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sagas_container.add_theme_constant_override("separation", 2)
	scroll_sagas.add_child(sagas_container)
	
	btn_sagas.clear()
	for arc_idx in range(1, 10):
		var arc_info: Dictionary = ARC_MAPS[arc_idx]
		var btn := Button.new()
		btn.add_theme_font_size_override("font_size", 5)
		
		var unlocked: bool = arc_idx <= PlayerData.max_arco_desbloqueado
		if unlocked:
			btn.text = arc_info["nome"]
			btn.disabled = false
		else:
			btn.text = "🔒 " + arc_info["nome"] + " (Bloqueado)"
			btn.disabled = true
			
		var current_arc_idx: int = arc_idx
		btn.pressed.connect(func(): _selecionar_arco(current_arc_idx))
		sagas_container.add_child(btn)
		btn_sagas.append(btn)
		
	# Coluna 2: Dificuldades
	var vbox_diff := VBoxContainer.new()
	vbox_diff.custom_minimum_size = Vector2(110, 0)
	hbox_content.add_child(vbox_diff)
	
	var lbl_diff_hdr := Label.new()
	lbl_diff_hdr.text = "Dificuldade:"
	lbl_diff_hdr.add_theme_font_size_override("font_size", 5)
	lbl_diff_hdr.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3, 1.0))
	vbox_diff.add_child(lbl_diff_hdr)
	
	btn_dificuldades.clear()
	var diff_names := ["Fácil", "Normal", "Difícil", "Muito Difícil", "Hunter Supremo"]
	
	for i in range(diff_names.size()):
		var btn_d := Button.new()
		var d_enum: PlayerData.Dificuldade = i as PlayerData.Dificuldade
		btn_d.add_theme_font_size_override("font_size", 5)
		
		# Dificuldades superiores só liberam ao zerar o jogo todo
		var is_locked: bool = (i >= 2) and not PlayerData.modo_historia_concluido
		if is_locked:
			btn_d.text = "🔒 " + diff_names[i]
			btn_d.disabled = true
		else:
			btn_d.text = diff_names[i]
			btn_d.disabled = false
			
		btn_d.pressed.connect(func(): _selecionar_dificuldade(d_enum))
		vbox_diff.add_child(btn_d)
		btn_dificuldades.append(btn_d)
		
	# Label de aviso sobre travas
	lbl_info_lock = Label.new()
	if not PlayerData.modo_historia_concluido:
		lbl_info_lock.text = "⚠️ Dificuldades superiores (Difícil, Supremo) são liberadas ao Zerar o Modo História!"
	else:
		lbl_info_lock.text = "✨ Modo História Zerado! Todas as dificuldades foram LIBERADAS!"
	lbl_info_lock.add_theme_font_size_override("font_size", 4)
	lbl_info_lock.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4, 1.0))
	lbl_info_lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(lbl_info_lock)
	
	# Rodapé (Botoes de Ação)
	var hbox_action := HBoxContainer.new()
	main_vbox.add_child(hbox_action)
	
	var btn_cancel := Button.new()
	btn_cancel.text = "Sair"
	btn_cancel.add_theme_font_size_override("font_size", 5)
	btn_cancel.pressed.connect(_on_cancelar)
	hbox_action.add_child(btn_cancel)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_action.add_child(spacer)
	
	var btn_travel := Button.new()
	btn_travel.text = "VIAJAR PARA A SAGA ▶"
	btn_travel.add_theme_font_size_override("font_size", 5)
	btn_travel.pressed.connect(_on_confirmar_viagem)
	hbox_action.add_child(btn_travel)
	
	_atualizar_destaques()


func _selecionar_arco(arc: int) -> void:
	selected_arc = arc
	_atualizar_destaques()


func _selecionar_dificuldade(diff: PlayerData.Dificuldade) -> void:
	selected_diff = diff
	_atualizar_destaques()


func _atualizar_destaques() -> void:
	for i in range(btn_sagas.size()):
		var arc_num: int = i + 1
		var btn: Button = btn_sagas[i]
		if arc_num == selected_arc:
			btn.modulate = Color(1.3, 1.3, 0.8, 1.0)
		else:
			btn.modulate = Color.WHITE
			
	for i in range(btn_dificuldades.size()):
		var btn: Button = btn_dificuldades[i]
		if i == int(selected_diff):
			btn.modulate = Color(0.8, 1.3, 1.3, 1.0)
		else:
			btn.modulate = Color.WHITE


func _on_cancelar() -> void:
	fechado.emit()
	queue_free()


func _on_confirmar_viagem() -> void:
	PlayerData.arco_atual = selected_arc
	PlayerData.dificuldade = selected_diff
	
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
		QuestSystem.garantir_quest_do_arco(selected_arc)

	if GameState != null:
		GameState.salvar_jogo()

	if AudioManager != null:
		AudioManager.tocar_musica_arco(selected_arc)
		
	var target_info: Dictionary = ARC_MAPS.get(selected_arc, {})
	var target_map: String = target_info.get("cena", "res://world/maps/exame_maratona.tscn")
	var target_name: String = target_info.get("nome", "Modo História")
	
	fechado.emit()
	queue_free()

	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena(target_map, target_name, "Arco %d — Campanha Principal" % selected_arc)
	else:
		get_tree().change_scene_to_file(target_map)

