class_name HeavensArenaTowerUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - HEAVENS ARENA TOWER UI (ARENA CELESTIAL)
# ============================================================
#
# Sistema de Combate dos 200 Andares da Arena Celestial.
# Desafie lutadores de Nen, suba de andar e ganhe bolsas de Jenny.
# S2: ladder ranqueada + temporada (MMR cosmético).
#
# ============================================================

const ArenaRankedSeason = preload("res://scripts/systems/arena/ArenaRankedSeason.gd")

var panel_main: PanelContainer
var lbl_andar: Label
var lbl_oponente: Label
var lbl_premio: Label
var lbl_ranked: Label
var lbl_board: Label
var btn_desafiar: Button
var btn_ranked: Button
var btn_fila: Button

var andar_atual: int = 1
var premiação_acumulada: int = 0


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 15
	visible = false
	_construir_ui()


func abrir_torneio() -> void:
	visible = true
	get_tree().paused = true
	_atualizar_torneio()


func fechar_torneio() -> void:
	visible = false
	get_tree().paused = false


func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(320, 210)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_main.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_main.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.20, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.7, 1.0, 1.0) # Borda Azul Celestial
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel_main.add_theme_stylebox_override("panel", style)
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "🏛️ ARENA CELESTIAL — TORNEIO DE ANDARES"
	lbl_titulo.add_theme_font_size_override("font_size", 7)
	lbl_titulo.add_theme_color_override("font_color", Color(0.3, 0.8, 1, 1))
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_titulo)

	lbl_ranked = Label.new()
	lbl_ranked.add_theme_font_size_override("font_size", 4)
	lbl_ranked.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 1))
	lbl_ranked.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(lbl_ranked)

	var hbox := HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(hbox)

	var col_esq := VBoxContainer.new()
	col_esq.custom_minimum_size = Vector2(140, 0)
	hbox.add_child(col_esq)

	lbl_andar = Label.new()
	lbl_andar.text = "ANDAR ATUAL: 1º"
	lbl_andar.add_theme_font_size_override("font_size", 5)
	lbl_andar.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	col_esq.add_child(lbl_andar)

	lbl_premio = Label.new()
	lbl_premio.text = "Prêmio Acumulado: 152.000 Jenny"
	lbl_premio.add_theme_font_size_override("font_size", 4)
	col_esq.add_child(lbl_premio)

	btn_desafiar = Button.new()
	btn_desafiar.text = "⚔️ Lutar no Ringue"
	btn_desafiar.add_theme_font_size_override("font_size", 5)
	btn_desafiar.pressed.connect(_on_desafiar_pressed)
	col_esq.add_child(btn_desafiar)

	btn_ranked = Button.new()
	btn_ranked.text = "🏅 Ranqueado: OFF"
	btn_ranked.add_theme_font_size_override("font_size", 4)
	btn_ranked.pressed.connect(_on_ranked_toggle)
	col_esq.add_child(btn_ranked)

	btn_fila = Button.new()
	btn_fila.text = "🔎 Fila 1v1 (ghost)"
	btn_fila.add_theme_font_size_override("font_size", 4)
	btn_fila.pressed.connect(_on_fila_pressed)
	col_esq.add_child(btn_fila)

	var btn_sacar := Button.new()
	btn_sacar.text = "💰 Sacar Jenny Acumulado"
	btn_sacar.add_theme_font_size_override("font_size", 4)
	btn_sacar.pressed.connect(_on_sacar_pressed)
	col_esq.add_child(btn_sacar)

	var col_dir := VBoxContainer.new()
	col_dir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(col_dir)

	lbl_oponente = Label.new()
	lbl_oponente.add_theme_font_size_override("font_size", 4)
	lbl_oponente.autowrap_mode = TextServer.AUTOWRAP_WORD
	col_dir.add_child(lbl_oponente)

	lbl_board = Label.new()
	lbl_board.add_theme_font_size_override("font_size", 3)
	lbl_board.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95, 1))
	lbl_board.autowrap_mode = TextServer.AUTOWRAP_WORD
	col_dir.add_child(lbl_board)

	var btn_sair := Button.new()
	btn_sair.text = "Fechar Arena"
	btn_sair.add_theme_font_size_override("font_size", 4)
	btn_sair.pressed.connect(fechar_torneio)
	vbox.add_child(btn_sair)


func _atualizar_torneio() -> void:
	# Unifica progresso UI ↔ torre real
	var ui_andar: int = int(PlayerData.attributes.get("andar_arena", 1))
	var torre_andar: int = int(PlayerData.torre_andar_atual) if PlayerData != null else 1
	andar_atual = maxi(1, maxi(ui_andar, torre_andar))
	PlayerData.attributes["andar_arena"] = andar_atual
	PlayerData.torre_andar_atual = andar_atual

	lbl_andar.text = "ANDAR ATUAL: %dº" % andar_atual

	var valor_premio: int = andar_atual * 800 + 2000
	lbl_premio.text = "Prêmio do Andar: %d Jenny" % valor_premio

	ArenaRankedSeason.ensure_season()
	lbl_ranked.text = ArenaRankedSeason.summary_text()
	btn_ranked.text = "🏅 Ranqueado: ON" if ArenaRankedSeason.is_ranked_mode() else "🏅 Ranqueado: OFF"
	lbl_board.text = "TOP TEMPORADA\n" + ArenaRankedSeason.leaderboard_text(5)

	var pending := ArenaRankedSeason.get_pending_opponent()
	if not pending.is_empty():
		lbl_oponente.text = "FILA: %s\nMMR rival: %d (%s)\nAndar %d\n\nVitórias ranqueadas só mexem em MMR/título — sem power creep." % [
			str(pending.get("name", "Rival")),
			int(pending.get("mmr", 1000)),
			str(pending.get("kind", "?")),
			int(pending.get("floor", andar_atual)),
		]
	elif andar_atual < 50:
		lbl_oponente.text = "OPONENTE: Gladiador Iniciante\nESTILO: Artes Marciais Físicas (Sem Nen)\n\nVitórias nos andares iniciais rendem Jenny e prática de combate."
	elif andar_atual < 200:
		lbl_oponente.text = "OPONENTE: Lutador de Elite do 100º Andar\nESTILO: Nen Básico (Ten / Ren / Gyo)\n\nAtenção: Oponentes deste andar usam aura para reforçar ataques!"
	else:
		lbl_oponente.text = "OPONENTE: MESTRE DE ANDAR (Hisoka / Kastro)\nESTILO: Hatsu Avançado (Bungee Gum / Clones de Nen)\n\nO topo da Arena Celestial exige o uso magistral do seu Hatsu!"


func _on_ranked_toggle() -> void:
	var next := not ArenaRankedSeason.is_ranked_mode()
	ArenaRankedSeason.set_ranked_mode(next)
	_atualizar_torneio()


func _on_fila_pressed() -> void:
	ArenaRankedSeason.set_ranked_mode(true)
	ArenaRankedSeason.join_queue(andar_atual)
	_atualizar_torneio()


func _on_desafiar_pressed() -> void:
	# Entra no ringue real (CelestialTowerArena) — sem vitória automática
	_atualizar_torneio()
	if ArenaRankedSeason.is_ranked_mode():
		# Garante oponente pendente para o report pós-vitória
		if ArenaRankedSeason.get_pending_opponent().is_empty():
			ArenaRankedSeason.join_queue(andar_atual)
	PlayerData.attributes["torre_cena_retorno"] = "res://world/maps/arena_celestial.tscn"
	fechar_torneio()
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena(
			"res://world/maps/CelestialTowerArena.tscn",
			"Torre Celestial",
			"Ringue — Andar %d" % andar_atual
		)
	else:
		get_tree().change_scene_to_file("res://world/maps/CelestialTowerArena.tscn")


func _on_sacar_pressed() -> void:
	fechar_torneio()
