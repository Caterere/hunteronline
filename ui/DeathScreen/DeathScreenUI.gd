class_name DeathScreenUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - DEATH SCREEN & GAME OVER UI
# ============================================================
#
# Interface cinematográfica de Morte e Game Over:
# - Vinheta escura com pulso avermelhado e desvanecimento de aura.
# - Mensagem dramática adaptada ao status do jogador.
# - Botões de Renascer (Respawn no ponto seguro), Retornar ao Lobby ou Menu.
# - Bloqueia inputs de gameplay enquanto ativa.
# - Resolução nativa 320x180 (Pixel Art).
#
# ============================================================

signal revivido()
signal retorno_ao_lobby()

var root_ctrl: Control
var panel_container: PanelContainer
var lbl_status_hunter: Label
var lbl_frase_morte: Label
var btn_reviver: Button
var btn_lobby: Button
var btn_menu: Button

var ja_aberto: bool = false


func _init() -> void:
	layer = 45
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir_ui()


func _ready() -> void:
	layer = 45
	process_mode = Node.PROCESS_MODE_ALWAYS
	if root_ctrl == null:
		_construir_ui()


func _construir_ui() -> void:
	# Nó raiz Control
	root_ctrl = Control.new()
	root_ctrl.name = "RootControl"
	root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root_ctrl)

	# Fundo escuro com vinheta avermelhada
	var bg := ColorRect.new()
	bg.name = "BackgroundVignette"
	bg.color = Color(0.08, 0.01, 0.02, 0.90)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_ctrl.add_child(bg)

	# Painel Centralizado
	panel_container = PanelContainer.new()
	panel_container.name = "PanelContainer"
	panel_container.custom_minimum_size = Vector2(250, 140)
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_container.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.02, 0.03, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.85, 0.15, 0.20, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel_container.add_theme_stylebox_override("panel", style)
	root_ctrl.add_child(panel_container)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel_container.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# Título de Morte
	var lbl_titulo := Label.new()
	lbl_titulo.text = "💀 VOCÊ CAIU EM COMBATE 💀"
	lbl_titulo.add_theme_font_size_override("font_size", 7)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.2, 0.25, 1.0))
	lbl_titulo.add_theme_color_override("font_shadow_color", Color.BLACK)
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_titulo)

	lbl_frase_morte = Label.new()
	lbl_frase_morte.text = "Sua aura se dissipou diante da severidade do mundo dos Caçadores..."
	lbl_frase_morte.add_theme_font_size_override("font_size", 4)
	lbl_frase_morte.add_theme_color_override("font_color", Color(0.85, 0.70, 0.70, 1.0))
	lbl_frase_morte.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_frase_morte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_frase_morte)

	# Info do Jogador
	lbl_status_hunter = Label.new()
	lbl_status_hunter.text = "Nível 1 | Nen: Inativo"
	lbl_status_hunter.add_theme_font_size_override("font_size", 4)
	lbl_status_hunter.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	lbl_status_hunter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_status_hunter)

	var lbl_dica := Label.new()
	lbl_dica.text = "💡 Dica: Use [Espaço] para esquivar no timing certo (Perfect Dodge) e utilize Ten para reduzir o dano recebido!"
	lbl_dica.add_theme_font_size_override("font_size", 3)
	lbl_dica.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0, 1.0))
	lbl_dica.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_dica)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 2)
	vbox.add_child(spacer)

	# Botões de Ação
	var hbox_btns := VBoxContainer.new()
	hbox_btns.add_theme_constant_override("separation", 2)
	vbox.add_child(hbox_btns)

	btn_reviver = Button.new()
	btn_reviver.text = "🔄 Renascer no Ponto Seguro"
	btn_reviver.add_theme_font_size_override("font_size", 5)
	btn_reviver.pressed.connect(_on_reviver_pressed)
	hbox_btns.add_child(btn_reviver)

	btn_lobby = Button.new()
	btn_lobby.text = "⛩️ Retornar ao Lobby (Hunter Plaza)"
	btn_lobby.add_theme_font_size_override("font_size", 5)
	btn_lobby.pressed.connect(_on_retornar_lobby_pressed)
	hbox_btns.add_child(btn_lobby)

	btn_menu = Button.new()
	btn_menu.text = "💾 Menu Principal"
	btn_menu.add_theme_font_size_override("font_size", 5)
	btn_menu.pressed.connect(_on_menu_principal_pressed)
	hbox_btns.add_child(btn_menu)


func exibir() -> void:
	if ja_aberto:
		return
	ja_aberto = true
	visible = true

	if root_ctrl == null:
		_construir_ui()

	# Atualizar dados do Hunter
	if lbl_status_hunter != null:
		var nivel: int = int(PlayerData.attributes.get("nivel", 1))
		var nivel_nen: int = int(PlayerData.attributes.get("nivel_nen", 0))
		var cat_nome: String = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
		lbl_status_hunter.text = "🔰 %s | Nv. %d | Nen: %s (Nv. %d)" % [PlayerData.nome_personagem, nivel, cat_nome, nivel_nen]

	# Frases dramáticas aleatórias
	if lbl_frase_morte != null:
		var frases := [
			"Sua aura se dissipou diante da severidade do mundo dos Caçadores...",
			"Mesmo os maiores Hunters conheceram o limite de suas forças antes de evoluir.",
			"A morte no Exame Hunter é real para aqueles desatentos aos perigos.",
			"Recomponha sua determinação e volte para a batalha com mais foco!"
		]
		lbl_frase_morte.text = frases[randi() % frases.size()]

	# Efeito de Fade-in suave
	if root_ctrl != null:
		root_ctrl.modulate.a = 0.0
		var tween := create_tween()
		if tween != null:
			tween.tween_property(root_ctrl, "modulate:a", 1.0, 0.4)

	# Focar no botão reviver para navegação com teclado
	if btn_reviver != null and is_inside_tree():
		btn_reviver.grab_focus()


func ocultar() -> void:
	ja_aberto = false
	if root_ctrl != null:
		var tween := create_tween()
		tween.tween_property(root_ctrl, "modulate:a", 0.0, 0.25)
		tween.tween_callback(func():
			visible = false
		)
	else:
		visible = false


func _on_reviver_pressed() -> void:
	ocultar()
	_restaurar_atributos_player()

	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("reviver"):
		player.reviver()
	elif player != null:
		var combat = player.get_node_or_null("CombatSystem") as HunterCombatSystem
		if combat != null:
			combat.reviver()

	revivido.emit()


func _on_retornar_lobby_pressed() -> void:
	ocultar()
	_restaurar_atributos_player()
	GameState.salvar_jogo()

	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("reviver"):
		player.reviver()

	retorno_ao_lobby.emit()

	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://world/lobby.tscn", "Capital dos Caçadores", "Hunter Plaza — Hub Central")
	else:
		get_tree().change_scene_to_file("res://world/lobby.tscn")


func _on_menu_principal_pressed() -> void:
	ocultar()
	_restaurar_atributos_player()
	GameState.salvar_jogo()

	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://ui/CharacterSelection/CharacterSelectionUI.tscn", "Menu Principal", "Seleção de Slots")
	else:
		get_tree().change_scene_to_file("res://ui/CharacterSelection/CharacterSelectionUI.tscn")


func _restaurar_atributos_player() -> void:
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	var aura_max: float = float(PlayerData.attributes.get("aura_max", 100.0))
	PlayerData.attributes["vida"] = hp_max
	PlayerData.attributes["aura"] = aura_max
