class_name PauseMenuUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - PAUSE / ESC MENU (SALVAR & SAIR)
# ============================================================
#
# Menu global de pausa e opcoes acionado pela tecla [ESC].
# Permite ao jogador:
# 1. Continuar o jogo (despausar).
# 2. Salvar o jogo no estado atual (mapa, coordenadas, atributos).
# 3. Salvar e voltar com seguranca para a Capital (Lobby).
# 4. Acessar o Jornal de Missoes.
# 5. Salvar e sair para a Selecao de Personagens (Menu Principal).
# 6. Salvar e fechar o jogo (Desktop).
#
# Resolucao nativa: 320x180 (pixel art).
# ============================================================

signal menu_fechado

var painel_principal: PanelContainer
var lbl_info_player: Label
var lbl_info_local: Label
var lbl_status_save: Label

var btn_continuar: Button
var btn_salvar: Button
var btn_lobby: Button
var btn_jornal: Button
var btn_menu_principal: Button
var btn_sair_desktop: Button


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			# Se outros submenus prioritarios estiverem abertos, nao interfere
			var journal = get_tree().root.get_node_or_null("QuestJournalUI")
			if journal != null and journal.visible:
				return

			var achiv = get_tree().root.get_node_or_null("AchievementsUI")
			if achiv != null and achiv.visible:
				return

			# Alternar Pause Menu
			if visible:
				fechar()
			else:
				abrir()


func abrir() -> void:
	# Nao pausar em menus principais como Selecao de Personagens
	var cur_scn = get_tree().current_scene
	if cur_scn != null:
		var p = cur_scn.scene_file_path.to_lower()
		if "characterselection" in p or "charactercreation" in p:
			return

	_atualizar_informacoes()
	visible = true
	get_tree().paused = true
	if btn_continuar != null:
		btn_continuar.grab_focus()


func fechar() -> void:
	visible = false
	get_tree().paused = false
	menu_fechado.emit()


func _construir_ui() -> void:
	for c in get_children():
		c.queue_free()

	var root_control := Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	# Fundo Escurecido com Blur/Opacidade
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.75)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(bg)

	var center_container := CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(center_container)

	# Painel Centralizado
	painel_principal = PanelContainer.new()
	painel_principal.custom_minimum_size = Vector2(250, 230)
	painel_principal.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	center_container.add_child(painel_principal)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	painel_principal.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# 1. Titulo do Menu
	var lbl_titulo := Label.new()
	lbl_titulo.text = "⏸️ JOGO PAUSADO"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_font_size_override("font_size", 11)
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_titulo.add_theme_color_override("font_shadow_color", Color.BLACK)
	vbox.add_child(lbl_titulo)

	# 2. Informacoes do Personagem e Local
	lbl_info_player = Label.new()
	lbl_info_player.text = "👤 Hunter (Lv. 1)"
	lbl_info_player.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_info_player.add_theme_font_size_override("font_size", 9)
	lbl_info_player.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	vbox.add_child(lbl_info_player)

	lbl_info_local = Label.new()
	lbl_info_local.text = "📍 Local: Capital dos Hunters"
	lbl_info_local.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_info_local.add_theme_font_size_override("font_size", 8)
	lbl_info_local.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_info_local)

	# Linha Divisoria
	var sep := HSeparator.new()
	sep.modulate = HunterUIStyle.COLOR_BORDER_SUBTLE
	vbox.add_child(sep)

	# 3. Botoes de Acao
	btn_continuar = _criar_botao("▶️ Continuar Jogo", vbox, _on_continuar_pressed)
	btn_salvar = _criar_botao("💾 Salvar Jogo", vbox, _on_salvar_pressed)
	btn_lobby = _criar_botao("🏛️ Salvar e Voltar ao Lobby", vbox, _on_lobby_pressed)
	btn_jornal = _criar_botao("📜 Jornal de Missoes [J]", vbox, _on_jornal_pressed)
	btn_menu_principal = _criar_botao("🚪 Salvar e Sair p/ Menu", vbox, _on_menu_principal_pressed)
	btn_sair_desktop = _criar_botao("❌ Salvar e Sair do Jogo", vbox, _on_sair_desktop_pressed)

	# 4. Status de Salvamento (Feedback)
	lbl_status_save = Label.new()
	lbl_status_save.text = ""
	lbl_status_save.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_status_save.add_theme_font_size_override("font_size", 8)
	lbl_status_save.add_theme_color_override("font_color", HunterUIStyle.COLOR_HUNTER_GREEN_LIGHT)
	vbox.add_child(lbl_status_save)


func _criar_botao(texto: String, parent: Node, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = texto
	btn.add_theme_font_size_override("font_size", 8)
	btn.custom_minimum_size = Vector2(0, 20)
	HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_GREEN)
	btn.pressed.connect(callback)
	parent.add_child(btn)
	return btn


func _atualizar_informacoes() -> void:
	if PlayerData == null:
		return

	var nivel: int = int(PlayerData.attributes.get("nivel", 1))
	var cat_name: String = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
	lbl_info_player.text = "👤 %s (Lv. %d) — %s" % [PlayerData.nome_personagem, nivel, cat_name]

	var scn = get_tree().current_scene
	var local_nome = "Capital dos Hunters (Lobby)"
	if scn != null:
		var path_str = scn.scene_file_path.to_lower()
		if "exame" in path_str or "maratona" in path_str:
			local_nome = "Tunel Subterraneo (Exame Hunter 1/6)"
		elif "kukuroo" in path_str:
			local_nome = "Montanha Kukuroo (Arco 2)"
		elif "celestial" in path_str:
			local_nome = "Arena Celestial (Arco 3)"
		elif "yorknew" in path_str:
			local_nome = "Yorknew City (Arco 4)"
		elif "greed" in path_str:
			local_nome = "Greed Island (Arco 5)"
		elif "ngl" in path_str or "chimera" in path_str:
			local_nome = "NGL / Formigas Chimera (Arco 6)"
		elif "house" in path_str:
			local_nome = "Casa Pessoal do Cacador"
		elif "parallel" in path_str:
			local_nome = "Fenda Dimensional (Missao Paralela)"

	lbl_info_local.text = "📍 %s | Slot %d" % [local_nome, PlayerData.slot_ativo]
	lbl_status_save.text = ""


func _on_continuar_pressed() -> void:
	fechar()


func _on_salvar_pressed() -> void:
	if GameState != null:
		GameState.salvar_jogo(PlayerData.slot_ativo)
		lbl_status_save.text = "✨ Jogo Salvo com Sucesso!"
		lbl_status_save.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))

		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud != null and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("💾 Progresso Salvo no Slot %d!" % PlayerData.slot_ativo)


func _on_lobby_pressed() -> void:
	if GameState != null:
		GameState.salvar_jogo(PlayerData.slot_ativo)
	fechar()
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://world/lobby.tscn", "Capital dos Caçadores", "Hunter Plaza — Hub Central")
	else:
		get_tree().change_scene_to_file("res://world/lobby.tscn")


func _on_jornal_pressed() -> void:
	fechar()
	var journal = get_tree().root.get_node_or_null("QuestJournalUI")
	if journal != null and journal.has_method("abrir"):
		journal.abrir()


func _on_menu_principal_pressed() -> void:
	if GameState != null:
		GameState.salvar_jogo(PlayerData.slot_ativo)
	fechar()
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://ui/CharacterSelection/CharacterSelectionUI.tscn", "Menu Principal", "Seleção de Slots")
	else:
		get_tree().change_scene_to_file("res://ui/CharacterSelection/CharacterSelectionUI.tscn")


func _on_sair_desktop_pressed() -> void:
	if GameState != null:
		GameState.salvar_jogo(PlayerData.slot_ativo)
	get_tree().quit()
