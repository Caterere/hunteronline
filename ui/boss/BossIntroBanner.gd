class_name BossIntroBanner
extends CanvasLayer

# ============================================================
# HUNTER ONLINE — BOSS INTRO CINEMATIC BANNER
# ============================================================
#
# Apresentação dramática e imersiva ao encontrar ou engajar chefes:
# - Banner superior estilizado com bordas douradas e tipografia HxH.
# - Fanfarra orquestral dramática (AudioSynth.boss_intro).
# - Disparo dinâmico da trilha sonora correspondente do anime.
# - Zoom tático contextual na câmera do jogador para visão ampla.
# ============================================================

static func exibir(tree: SceneTree, boss_nome: String, subtitulo: String = "INIMIGO PODEROSO") -> void:
	if tree == null:
		return
	var root = tree.current_scene if tree.current_scene != null else tree.root
	if root == null:
		return

	var existente = root.get_node_or_null("BossIntroBanner")
	if existente != null:
		return

	var banner = load("res://ui/boss/BossIntroBanner.gd").new()
	banner.name = "BossIntroBanner"
	banner.layer = 120
	root.add_child(banner)
	banner._iniciar_apresentacao(boss_nome, subtitulo)


func _iniciar_apresentacao(boss_nome: String, subtitulo: String) -> void:
	if AudioManager != null:
		AudioManager.tocar_boss_intro()
		AudioManager.tocar_musica_boss(boss_nome)

	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("definir_zoom_camera"):
		player.definir_zoom_camera(Vector2(0.88, 0.88), 0.8)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.10
	panel.anchor_bottom = 0.28
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.08, 0.88)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.85, 0.3, 0.95)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var lbl_sub := Label.new()
	lbl_sub.text = subtitulo.to_upper()
	lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_sub.add_theme_font_size_override("font_size", 10)
	lbl_sub.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 0.95))
	lbl_sub.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	vbox.add_child(lbl_sub)

	var lbl_nome := Label.new()
	lbl_nome.text = boss_nome.to_upper()
	lbl_nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_nome.add_theme_font_size_override("font_size", 20)
	lbl_nome.add_theme_color_override("font_color", Color(1.0, 0.92, 0.5, 1.0))
	lbl_nome.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
	lbl_nome.add_theme_constant_override("shadow_offset_x", 2)
	lbl_nome.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(lbl_nome)

	panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(2.2)
	tw.tween_property(panel, "modulate:a", 0.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
