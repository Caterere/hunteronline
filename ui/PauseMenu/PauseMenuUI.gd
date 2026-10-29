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

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var painel_principal: PanelContainer
var painel_audio: PanelContainer
var lbl_info_player: Label
var lbl_info_local: Label
var lbl_status_save: Label
var lbl_track_atual: Label

var btn_continuar: Button
var btn_salvar: Button
var btn_lobby: Button
var btn_jornal: Button
var btn_audio: Button
var btn_menu_principal: Button
var btn_sair_desktop: Button

var slider_master: HSlider
var slider_music: HSlider
var slider_sfx: HSlider
var slider_ambient: HSlider
var lbl_vol_master: Label
var lbl_vol_music: Label
var lbl_vol_sfx: Label
var lbl_vol_ambient: Label


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

			# Submenu de áudio aberto → volta ao pause principal
			if visible and painel_audio != null and painel_audio.visible:
				_mostrar_painel_principal()
				get_viewport().set_input_as_handled()
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
	_mostrar_painel_principal()
	visible = true
	get_tree().paused = true
	if btn_continuar != null:
		btn_continuar.grab_focus()


func fechar() -> void:
	visible = false
	_mostrar_painel_principal()
	get_tree().paused = false
	menu_fechado.emit()


func _mostrar_painel_principal() -> void:
	if painel_principal != null:
		painel_principal.visible = true
	if painel_audio != null:
		painel_audio.visible = false


func _mostrar_painel_audio() -> void:
	if painel_principal != null:
		painel_principal.visible = false
	if painel_audio != null:
		painel_audio.visible = true
		_sincronizar_sliders_audio()
		if slider_master != null:
			slider_master.grab_focus()


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
	painel_principal.custom_minimum_size = Vector2(250, 300)
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
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
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
	btn_audio = _criar_botao("🔊 Áudio / Volume", vbox, _on_audio_pressed)
	_criar_botao("✉️ Correio da Associação", vbox, _on_correio_pressed)
	_criar_botao("📋 Menu Hunter / Sistemas [TAB]", vbox, _on_hunter_menu_pressed)
	_criar_botao("🏆 Conquistas [K]", vbox, _on_conquistas_pressed)
	_criar_botao("🏰 Hall da Guilda", vbox, _on_guild_pressed)
	btn_menu_principal = _criar_botao("🚪 Salvar e Sair p/ Menu", vbox, _on_menu_principal_pressed)
	btn_sair_desktop = _criar_botao("❌ Salvar e Sair do Jogo", vbox, _on_sair_desktop_pressed)

	# 4. Status de Salvamento (Feedback)
	lbl_status_save = Label.new()
	lbl_status_save.text = ""
	lbl_status_save.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_status_save.add_theme_font_size_override("font_size", 8)
	lbl_status_save.add_theme_color_override("font_color", HunterUIStyle.COLOR_HUNTER_GREEN_LIGHT)
	vbox.add_child(lbl_status_save)

	# Painel de Áudio (submenu)
	painel_audio = PanelContainer.new()
	painel_audio.custom_minimum_size = Vector2(260, 220)
	painel_audio.visible = false
	painel_audio.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	center_container.add_child(painel_audio)
	_construir_painel_audio(painel_audio)


func _construir_painel_audio(painel: PanelContainer) -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	painel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "🔊 ÁUDIO"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_font_size_override("font_size", 11)
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	vbox.add_child(lbl_titulo)

	lbl_track_atual = Label.new()
	lbl_track_atual.text = "♪ —"
	lbl_track_atual.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_track_atual.add_theme_font_size_override("font_size", 7)
	lbl_track_atual.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
	lbl_track_atual.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_track_atual)

	var sep := HSeparator.new()
	sep.modulate = HunterUIStyle.COLOR_BORDER_SUBTLE
	vbox.add_child(sep)

	slider_master = _criar_slider_volume(vbox, "Master", "master")
	lbl_vol_master = slider_master.get_meta("value_label") as Label
	slider_music = _criar_slider_volume(vbox, "Música (OST)", "music")
	lbl_vol_music = slider_music.get_meta("value_label") as Label
	slider_sfx = _criar_slider_volume(vbox, "Efeitos (SFX)", "sfx")
	lbl_vol_sfx = slider_sfx.get_meta("value_label") as Label
	slider_ambient = _criar_slider_volume(vbox, "Ambiente", "ambient")
	lbl_vol_ambient = slider_ambient.get_meta("value_label") as Label

	_criar_botao("◀ Voltar", vbox, _mostrar_painel_principal)


func _criar_slider_volume(parent: Node, titulo: String, canal: String) -> HSlider:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 1)
	parent.add_child(row)

	var header := HBoxContainer.new()
	row.add_child(header)

	var lbl := Label.new()
	lbl.text = titulo
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	header.add_child(lbl)

	var lbl_val := Label.new()
	lbl_val.text = "100%"
	lbl_val.custom_minimum_size = Vector2(36, 0)
	lbl_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_val.add_theme_font_size_override("font_size", 8)
	lbl_val.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	header.add_child(lbl_val)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.custom_minimum_size = Vector2(0, 14)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.set_meta("value_label", lbl_val)
	slider.set_meta("canal", canal)
	slider.value_changed.connect(_on_volume_slider_changed.bind(canal, lbl_val))
	row.add_child(slider)
	return slider


func _on_volume_slider_changed(value: float, canal: String, lbl_val: Label) -> void:
	if lbl_val != null:
		lbl_val.text = "%d%%" % int(round(value * 100.0))
	if AudioManager == null:
		return
	match canal:
		"master":
			AudioManager.definir_volume_master(value)
		"music":
			AudioManager.definir_volume_musica(value)
		"sfx":
			AudioManager.definir_volume_sfx(value)
		"ambient":
			AudioManager.definir_volume_ambient(value)


func _sincronizar_sliders_audio() -> void:
	if AudioManager == null:
		return
	var vols: Dictionary = AudioManager.obter_volumes() if AudioManager.has_method("obter_volumes") else {}
	_aplicar_slider(slider_master, lbl_vol_master, float(vols.get("master", 1.0)))
	_aplicar_slider(slider_music, lbl_vol_music, float(vols.get("music", 0.85)))
	_aplicar_slider(slider_sfx, lbl_vol_sfx, float(vols.get("sfx", 1.0)))
	_aplicar_slider(slider_ambient, lbl_vol_ambient, float(vols.get("ambient", 0.28)))
	if lbl_track_atual != null:
		var nome := "—"
		if AudioManager.has_method("obter_nome_musica_atual"):
			nome = str(AudioManager.obter_nome_musica_atual())
			if nome.is_empty():
				nome = "—"
		lbl_track_atual.text = "♪ %s" % nome


func _aplicar_slider(slider: HSlider, lbl: Label, value: float) -> void:
	if slider == null:
		return
	slider.set_value_no_signal(clamp(value, 0.0, 1.0))
	if lbl != null:
		lbl.text = "%d%%" % int(round(value * 100.0))


func _on_audio_pressed() -> void:
	_mostrar_painel_audio()


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
	var cat_name: String = PlayerData.obter_nome_afinidade_exibivel()
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
	if SaveManager != null:
		SaveManager.salvar_jogo(PlayerData.slot_ativo)
		lbl_status_save.text = "✨ Jogo Salvo com Sucesso!"
		lbl_status_save.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))

		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud != null and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("💾 Progresso Salvo no Slot %d!" % PlayerData.slot_ativo)


func _on_lobby_pressed() -> void:
	if SaveManager != null:
		SaveManager.salvar_jogo(PlayerData.slot_ativo)
	fechar()
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://world/lobby.tscn", "Capital dos Caçadores", "Hunter Plaza — Hub Central")
	else:
		get_tree().change_scene_to_file("res://world/lobby.tscn")


func _on_jornal_pressed() -> void:
	fechar()
	var journal = QuestJournalUI.obter_ou_criar(get_tree())
	if journal != null and journal.has_method("abrir"):
		journal.abrir()


func _on_correio_pressed() -> void:
	fechar()
	_abrir_correio_associacao()


static func _abrir_correio_associacao() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var existing = tree.root.get_node_or_null("AssociationMailUI")
	if existing == null:
		var scn = load("res://ui/Mail/AssociationMailUI.tscn")
		if scn == null:
			return
		existing = scn.instantiate()
		existing.name = "AssociationMailUI"
		tree.root.add_child(existing)
	if existing.has_method("abrir"):
		existing.abrir()
	elif "visible" in existing:
		existing.visible = true


func _on_hunter_menu_pressed() -> void:
	fechar()
	if TutorialManager != null and TutorialManager.has_method("disparar_tutorial_contextual"):
		TutorialManager.disparar_tutorial_contextual("sistemas")
	var menu = get_tree().root.get_node_or_null("HunterMenuUI")
	if menu == null:
		menu = get_tree().get_first_node_in_group("hunter_menu")
	if menu != null:
		if menu.has_method("abrir"):
			menu.abrir()
		elif menu.has_method("alternar"):
			menu.alternar()
		elif "visible" in menu:
			menu.visible = true
	elif EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("Abra o Menu Hunter com [TAB] — Status, Inventário, Nen, Hatsu e Guia.", Color(0.95, 0.85, 0.4))


func _on_conquistas_pressed() -> void:
	fechar()
	var achiv = get_tree().root.get_node_or_null("AchievementsUI")
	if achiv == null:
		achiv = get_tree().get_first_node_in_group("achievements_ui")
	if achiv != null and achiv.has_method("toggle_menu"):
		if not achiv.visible:
			achiv.toggle_menu()
	elif EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("Conquistas: tecla [K]", Color(0.95, 0.85, 0.4))


func _on_guild_pressed() -> void:
	fechar()
	var existing = get_tree().root.get_node_or_null("GuildHallUI")
	if existing == null:
		var GuildHallScript = load("res://ui/Guild/GuildHallUI.gd")
		if GuildHallScript == null:
			return
		existing = GuildHallScript.new()
		existing.name = "GuildHallUI"
		get_tree().root.add_child(existing)
	if existing.has_method("abrir"):
		existing.abrir()


func _on_menu_principal_pressed() -> void:
	if SaveManager != null:
		SaveManager.salvar_jogo(PlayerData.slot_ativo)
	fechar()
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://ui/CharacterSelection/CharacterSelectionUI.tscn", "Menu Principal", "Seleção de Slots")
	else:
		get_tree().change_scene_to_file("res://ui/CharacterSelection/CharacterSelectionUI.tscn")


func _on_sair_desktop_pressed() -> void:
	if SaveManager != null:
		SaveManager.salvar_jogo(PlayerData.slot_ativo)
	get_tree().quit()
