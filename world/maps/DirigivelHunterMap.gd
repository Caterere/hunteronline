class_name DirigivelHunterMap
extends Node2D

# ============================================================
# HUNTER ONLINE — DIRIGÍVEL DA ASSOCIAÇÃO (Exame 14–15)
# ============================================================
# Deck noturno após falar com Netero no Exame. Etapa 15 = jogo da bola
# (2ª visita). Portal LESTE → Trick Tower (alçapão no Exame).
# ============================================================

func _ready() -> void:
	PlaytestVisualMode.apply_grass_floor(self, Vector2(900, 420), Color(0.35, 0.42, 0.55))
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.EXAME)
	_garantir_dialogue_ui()
	_garantir_spawn()
	_garantir_netero()
	_criar_deck_visual()
	_criar_portal_trick_tower()
	_toast_chegada()
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)


func _garantir_dialogue_ui() -> void:
	if get_tree().get_first_node_in_group("visual_dialogue_ui") != null:
		return
	var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
	if scene:
		add_child(scene.instantiate())


func _garantir_spawn() -> void:
	if get_node_or_null("SpawnFromExame") != null:
		return
	var sp := SpawnPoint.new()
	sp.name = "SpawnFromExame"
	sp.spawn_id = &"from_exame"
	sp.is_default_spawn = true
	sp.position = Vector2(120, 180)
	add_child(sp)
	var wpm = get_node_or_null("/root/WorldProgressionManager")
	if wpm != null and wpm.has_method("registrar_spawn_point"):
		wpm.registrar_spawn_point(sp)


func _garantir_netero() -> void:
	if get_node_or_null("Netero") != null:
		return
	var scn = load("res://entities/npc/netero/Netero.tscn")
	if scn == null:
		return
	var netero = scn.instantiate()
	netero.name = "Netero"
	netero.position = Vector2(320, 170)
	add_child(netero)
	if "npc_name" in netero:
		netero.npc_name = "Presidente Isaac Netero"


func _criar_deck_visual() -> void:
	if get_node_or_null("DeckLabel") != null:
		return
	var lbl := Label.new()
	lbl.name = "DeckLabel"
	lbl.text = "✈️ Dirigível Hunter — Deck Noturno\nFale com Netero · Portal LESTE → Trick Tower"
	lbl.position = Vector2(80, 40)
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	add_child(lbl)

	# Limites de câmera no deck curto
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player != null:
		var cam = player.get_node_or_null("Camera2D") as Camera2D
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 900
			cam.limit_bottom = 420


func _criar_portal_trick_tower() -> void:
	if get_node_or_null("PortalTrickTower") != null:
		return
	var portal := MapTransitionArea.new()
	portal.name = "PortalTrickTower"
	portal.position = Vector2(780, 180)
	portal.portal_name = "Topo da Trick Tower"
	portal.map_subtitle = "3ª Fase — Encontre o alçapão"
	portal.target_scene_path = "res://world/maps/exame_maratona.tscn"
	portal.target_spawn_id = &"from_dirigivel"
	portal.target_spawn_position = Vector2(5520, -20)
	portal.requires_e_key = true
	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(48, 28)
	col.shape = box
	portal.add_child(col)
	add_child(portal)


func _toast_chegada() -> void:
	if EventBus != null:
		EventBus.emit_toast("Dirigível: fale com Netero (jogo da bola), depois portal LESTE → Trick Tower.", Color(0.7, 0.85, 1.0))
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("✈️ Viagem noturna — converse com o Presidente Netero")
