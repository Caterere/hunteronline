extends NPC

# ============================================================
# HUNTER ONLINE - PORTAL HUNTER (LANDMARK + SELETOR DE SAGAS)
# ============================================================
#
# Portal dimensional visível no Distrito Leste do Lobby.
# Abre PortalHunterUI (seleção de arco) — não é mais um "guia" NPC.
#
# ============================================================


func _ready() -> void:
	npc_name = "Portal Hunter"
	fala_padrao = "O Portal de Nen da Associação. [E] Abrir seletor de sagas."
	super()
	_aplicar_visual_portal()
	z_index = 3
	y_sort_enabled = true


func _aplicar_visual_portal() -> void:
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr == null:
		return
	var portal_tex_path := "res://assets/sprites/objects/portal_hunter_arch.png"
	if ResourceLoader.exists(portal_tex_path):
		spr.texture = load(portal_tex_path)
		spr.hframes = 1
		spr.vframes = 1
		spr.frame = 0
		spr.centered = true
		spr.position = Vector2(0, -28)
		spr.modulate = Color.WHITE
		spr.scale = Vector2(1.0, 1.0)
	elif ResourceLoader.exists("res://assets/sprites/objects/portao_padokia_arch.png"):
		spr.texture = load("res://assets/sprites/objects/portao_padokia_arch.png")
		spr.hframes = 1
		spr.vframes = 1
		spr.frame = 0
		spr.position = Vector2(0, -24)
		spr.modulate = Color(0.55, 0.85, 1.0, 1.0)
	else:
		spr.modulate = Color(0.4, 0.85, 1.0, 1.0)

	# Oculta label genérico do NPC se conflitar com o landmark
	var npc_lbl := get_node_or_null("NPCNameLabel")
	if npc_lbl != null:
		npc_lbl.visible = false
	var old_lbl := get_node_or_null("LabelNomePortal")
	if old_lbl == null:
		var lbl := Label.new()
		lbl.name = "LabelNomePortal"
		lbl.text = "⛩️ Portal Hunter\n[E] Abrir Sagas"
		lbl.position = Vector2(-55, -70)
		lbl.custom_minimum_size = Vector2(110, 20)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 6, Color(0.15, 0.85, 1.0))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		add_child(lbl)
	else:
		old_lbl.visible = true

	var inter := get_node_or_null("InteractionComponent") as InteractionComponent
	if inter != null:
		inter.interaction_text = "[E] Abrir Portal Hunter (Modo História)"
		inter.interaction_radius = 40.0


func _on_interacted(_player: CharacterBody2D) -> void:
	if QuestSystem != null and QuestSystem.has_method("register_npc_visit"):
		QuestSystem.register_npc_visit(&"portal_hunter")

	var root := get_tree().root
	var existing = root.get_node_or_null("PortalHunterUI")
	if existing != null:
		existing.queue_free()
	var scn = load("res://ui/PortalHunter/PortalHunterUI.gd")
	if scn == null:
		if EventBus != null:
			EventBus.emit_toast("Portal Hunter indisponível.", Color(1.0, 0.4, 0.4))
		return
	var ui = scn.new()
	ui.name = "PortalHunterUI"
	root.add_child(ui)
	if EventBus != null:
		EventBus.emit_toast("⛩️ Portal Hunter — escolha sua saga!", Color(0.35, 0.9, 1.0))
