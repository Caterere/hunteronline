extends NPC

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

# ============================================================
# HUNTER ONLINE — PORTAL DA MISSÃO ATUAL (legado: Portal Hunter)
# ============================================================
#
# Landmark do Distrito Leste do Lobby.
# ANTES: abria PortalHunterUI (saga + dificuldade) — REMOVIDO.
# AGORA: despacha automaticamente para o checkpoint da missão atual
#         via StoryManager.continuar_do_checkpoint().
# ============================================================


func _ready() -> void:
	npc_name = "Portal da Missão"
	fala_padrao = "Portal oficial da Associação. [E] Ir à área da sua missão atual."
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

	var npc_lbl := get_node_or_null("NPCNameLabel")
	if npc_lbl != null:
		npc_lbl.visible = false

	var old_lbl := get_node_or_null("LabelNomePortal")
	if old_lbl == null:
		var lbl := Label.new()
		lbl.name = "LabelNomePortal"
		lbl.text = "⛩️ Portal da Missão\n[E] Continuar História"
		lbl.position = Vector2(-60, -72)
		lbl.custom_minimum_size = Vector2(120, 20)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 6, Color(0.2, 0.95, 0.75))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		add_child(lbl)
	else:
		old_lbl.text = "⛩️ Portal da Missão\n[E] Continuar História"
		old_lbl.visible = true

	var inter := get_node_or_null("InteractionComponent") as InteractionComponent
	if inter != null:
		inter.interaction_text = "[E] Continuar Missão Atual"
		inter.interaction_radius = 40.0


func _on_interacted(_player: CharacterBody2D) -> void:
	var qs = get_node_or_null("/root/QuestSystem")
	if qs != null and qs.has_method("register_npc_visit"):
		qs.register_npc_visit(&"portal_hunter")
	elif qs != null and qs.has_method("registrar_visita_npc"):
		qs.registrar_visita_npc(&"portal_hunter")
	_despachar_para_missao_atual()


func _despachar_para_missao_atual() -> void:
	var existing_ui = get_tree().root.get_node_or_null("PortalHunterUI")
	if existing_ui != null:
		existing_ui.queue_free()

	if StoryManager == null:
		if EventBus != null and EventBus.has_method("emit_toast"):
			EventBus.emit_toast("StoryManager indisponível.", Color(1.0, 0.4, 0.4))
		return

	var cp: Dictionary = {}
	if StoryManager.has_method("obter_checkpoint_ativo"):
		cp = StoryManager.obter_checkpoint_ativo()
	var nome_cp := str(cp.get("nome", "Missão Atual"))

	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("🚩 Indo para: %s" % nome_cp, Color(0.25, 0.9, 1.0))

	if StoryManager.has_method("continuar_do_checkpoint"):
		StoryManager.continuar_do_checkpoint(get_tree())
	else:
		push_error("[PortalHunter] StoryManager.continuar_do_checkpoint ausente.")
