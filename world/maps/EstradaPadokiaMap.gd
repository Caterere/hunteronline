class_name EstradaPadokiaMap
extends Node2D

# ============================================================
# HUNTER ONLINE - ESTRADA REAL DE PADOKIA (MAPA PERMANENTE CONECTADO)
# ============================================================
#
# Primeira expansão conectada à Capital (Lobby):
# - Conexão Norte: Portão Sul do Lobby (world/lobby.tscn)
# - Conexão Sul: Entrada da Floresta dos Vestígios (floresta_vestigios.tscn)
# - Marco de Pedra da Associação Hunter
# - Guarda de Patrulha Hunter (NPC com diálogo)
# - Fogueira de Descanso de Caçador (Restaurar HP/Aura)
# - Riacho de montanha com ponte de pedra antiga
#
# ============================================================

@onready var chao_layer: TileMapLayer = get_node_or_null("Chao_TileMapLayer")
@onready var caminhos_layer: TileMapLayer = get_node_or_null("Caminhos_TileMapLayer")
@onready var estruturas_layer: TileMapLayer = get_node_or_null("Estruturas_TileMapLayer")
@onready var decor_layer: TileMapLayer = get_node_or_null("Decor_TileMapLayer")
@onready var player: CharacterBody2D = get_node_or_null("Player")


func _ready() -> void:
	_garantir_spawn_points()
	_configurar_limites_camera()
	_configurar_audio_e_hud()
	_posicionar_player()
	_criar_elementos_interativos()
	var quest_sys = get_node_or_null("/root/QuestSystem")
	if quest_sys != null and quest_sys.has_method("sincronizar_inimigos_do_mapa"):
		quest_sys.sincronizar_inimigos_do_mapa(self)


func _garantir_spawn_points() -> void:
	var wpm = get_node_or_null("/root/WorldProgressionManager")
	if get_node_or_null("SpawnFromLobby") == null:
		var sp_lobby := SpawnPoint.new()
		sp_lobby.name = "SpawnFromLobby"
		sp_lobby.spawn_id = &"from_lobby"
		sp_lobby.is_default_spawn = true
		sp_lobby.position = Vector2(400, 70)
		add_child(sp_lobby)
		if wpm != null and wpm.has_method("registrar_spawn_point"):
			wpm.registrar_spawn_point(sp_lobby)

	if get_node_or_null("SpawnFromFloresta") == null:
		var sp_flo := SpawnPoint.new()
		sp_flo.name = "SpawnFromFloresta"
		sp_flo.spawn_id = &"from_floresta"
		sp_flo.is_default_spawn = false
		sp_flo.position = Vector2(400, 580)
		add_child(sp_flo)
		if wpm != null and wpm.has_method("registrar_spawn_point"):
			wpm.registrar_spawn_point(sp_flo)


func _configurar_limites_camera() -> void:
	var pl = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if pl != null:
		var cam = pl.get_node_or_null("Camera2D") as Camera2D
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 800
			cam.limit_bottom = 640
			cam.position_smoothing_enabled = true
			cam.position_smoothing_speed = 8.0


func _configurar_audio_e_hud() -> void:
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("tocar_bgm"):
		audio_mgr.tocar_bgm("world_adventure")

	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🛣️ Estrada Real de Padokia — Rota dos Caçadores")


func _posicionar_player() -> void:
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as CharacterBody2D

	if player != null:
		var wpm = get_node_or_null("/root/WorldProgressionManager")
		if wpm != null and wpm.has_method("posicionar_player_no_spawn"):
			wpm.posicionar_player_no_spawn(player)


func _criar_elementos_interativos() -> void:
	# 1. Fogueira de Descanso do Caçador (Asset Definitivo)
	if get_node_or_null("FogueiraDescanso") == null:
		var fogueira := StaticBody2D.new()
		fogueira.name = "FogueiraDescanso"
		fogueira.position = Vector2(280, 240)
		fogueira.y_sort_enabled = true

		var spr := Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture = load("res://assets/sprites/objects/fogueira_acampamento_prop.png")
		spr.position = Vector2(0, -6)
		fogueira.add_child(spr)

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(18, 10)
		col.shape = rect
		col.position = Vector2(0, 2)
		fogueira.add_child(col)

		var lbl := Label.new()
		lbl.text = "🔥 Fogueira de Caçador\n[E] Descansar"
		lbl.position = Vector2(-60, -28)
		lbl.custom_minimum_size = Vector2(120, 16)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(1.0, 0.7, 0.2))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		fogueira.add_child(lbl)

		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Descansar na Fogueira"
		inter.interaction_radius = 26.0
		inter.interacted.connect(func(_p):
			var pdata = get_tree().root.get_node_or_null("PlayerData")
			if pdata != null:
				var hp_max = pdata.attributes.get("vida_max", 100)
				var aura_max = pdata.attributes.get("aura_max", 100)
				pdata.attributes["vida"] = hp_max
				pdata.attributes["aura"] = aura_max
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🔥 Descansou na fogueira! Vida e Aura 100% restauradas.")
		)
		fogueira.add_child(inter)
		add_child(fogueira)

	# 2. Marco de Pedra da Estrada (Asset Definitivo)
	if get_node_or_null("MarcoDePedra") == null:
		var marco := StaticBody2D.new()
		marco.name = "MarcoDePedra"
		marco.position = Vector2(460, 140)
		marco.y_sort_enabled = true

		var spr := Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture = load("res://assets/sprites/objects/marco_pedra_milestone.png")
		spr.scale = Vector2(0.52, 0.52)
		spr.position = Vector2(0, -11)
		marco.add_child(spr)

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(16, 10)
		col.shape = rect
		col.position = Vector2(0, 0)
		marco.add_child(col)

		var lbl := Label.new()
		lbl.text = "🪨 Marco Hunter\n↑ Capital  ↓ Floresta"
		lbl.position = Vector2(-55, -46)
		lbl.custom_minimum_size = Vector2(110, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.9, 0.9, 0.7))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		marco.add_child(lbl)

		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Ler Marco de Pedra"
		inter.interaction_radius = 24.0
		inter.interacted.connect(func(_p):
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("📜 Placa: 'Ao Norte: Capital Hunter. Ao Sul: Floresta dos Vestígios e Ruínas Ancestrais.'")
		)
		marco.add_child(inter)
		add_child(marco)

	# 3. Portão Norte (Retorno ao Lobby / Capital)
	if get_node_or_null("PortaoNorteLobby") == null:
		var p_norte := MapTransitionArea.new()
		p_norte.name = "PortaoNorteLobby"
		p_norte.position = Vector2(400, 24)
		p_norte.portal_name = "Capital Hunter (Lobby)"
		p_norte.map_subtitle = "Retornar aos Distritos e Guilda dos Caçadores"
		p_norte.target_scene_path = "res://world/lobby.tscn"
		p_norte.target_spawn_id = &"from_world"
		p_norte.requires_e_key = true

		var col := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(48, 16)
		col.shape = box
		p_norte.add_child(col)
		add_child(p_norte)

	# 4. Portão Sul (Entrada da Floresta dos Vestígios)
	if get_node_or_null("PortaoSulFloresta") == null:
		var p_sul := MapTransitionArea.new()
		p_sul.name = "PortaoSulFloresta"
		p_sul.position = Vector2(400, 620)
		p_sul.portal_name = "Floresta dos Vestígios"
		p_sul.map_subtitle = "Zona Selvagem e Mistérios Ancestrais"
		p_sul.target_scene_path = "res://world/maps/floresta_vestigios.tscn"
		p_sul.target_spawn_id = &"from_estrada"
		p_sul.requires_e_key = true

		var col := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(48, 16)
		col.shape = box
		p_sul.add_child(col)
		add_child(p_sul)

	# 5. Guarda de Patrulha Hunter (NPC em 8 Direções Definitivo)
	if get_node_or_null("GuardaPatrulha") == null:
		var guarda := StaticBody2D.new()
		guarda.name = "GuardaPatrulha"
		guarda.position = Vector2(340, 100)
		guarda.y_sort_enabled = true

		var col := CollisionShape2D.new()
		var circ := CircleShape2D.new()
		circ.radius = 5.0
		col.shape = circ
		col.position = Vector2(0, -2)
		guarda.add_child(col)

		var spr := Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture = load("res://assets/sprites/characters/npc_guarda_fronteira_8dir.png")
		spr.hframes = 8
		spr.frame = 0 # South
		spr.scale = Vector2(1.0, 1.0)
		spr.position = Vector2(0, -18)
		guarda.add_child(spr)

		var lbl := Label.new()
		lbl.text = "Guarda Hunter\n[E] Conversar"
		lbl.position = Vector2(-45, -38)
		lbl.custom_minimum_size = Vector2(90, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.7, 0.85, 1.0))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		guarda.add_child(lbl)

		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Falar com Guarda"
		inter.interaction_radius = 26.0
		inter.interacted.connect(func(_p):
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🛡️ Guarda: 'Atenção, Hunter! Feras usam armadura de aura. Quebre a defesa delas com 2 golpes pesados ou um combo rápido de 5 fracos!'")
		)
		guarda.add_child(inter)
		add_child(guarda)

	# 6. Posto de Guarda de Fronteira (Landmark da Estrada)
	if get_node_or_null("PostoGuardaFronteira") == null:
		var posto := StaticBody2D.new()
		posto.name = "PostoGuardaFronteira"
		posto.position = Vector2(480, 80)
		posto.y_sort_enabled = true

		var spr := Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture = load("res://assets/sprites/objects/posto_guarda_watchpost.png")
		spr.position = Vector2(0, -24)
		posto.add_child(spr)

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(52, 20)
		col.shape = rect
		col.position = Vector2(0, 6)
		posto.add_child(col)

		var lbl := Label.new()
		lbl.text = "⚔️ Posto de Guarda\n[E] Inspecionar"
		lbl.position = Vector2(-60, -56)
		lbl.custom_minimum_size = Vector2(120, 16)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.8, 0.9, 1.0))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		posto.add_child(lbl)

		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Inspecionar Posto de Guarda"
		inter.interaction_radius = 32.0
		inter.interacted.connect(func(_p):
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("⚔️ Posto de Vigilância: 'Aviso de Segurança: Estrada sob patrulha da Associação. Viajantes desarmados devem permanecer próximos à fogueira.'")
		)
		posto.add_child(inter)
		add_child(posto)

	# 7. Carroça de Mercador (Landmark Comercial da Estrada)
	if get_node_or_null("CarrocaMercador") == null:
		var carroca := StaticBody2D.new()
		carroca.name = "CarrocaMercador"
		carroca.position = Vector2(240, 360)
		carroca.y_sort_enabled = true

		var spr := Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture = load("res://assets/sprites/objects/carroca_mercador_wagon.png")
		spr.position = Vector2(0, -20)
		carroca.add_child(spr)

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(46, 18)
		col.shape = rect
		col.position = Vector2(0, 4)
		carroca.add_child(col)

		var lbl := Label.new()
		lbl.text = "📦 Carroça de Carga\n[E] Inspecionar"
		lbl.position = Vector2(-65, -52)
		lbl.custom_minimum_size = Vector2(130, 16)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.95, 0.85, 0.6))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		carroca.add_child(lbl)

		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Inspecionar Carroça"
		inter.interaction_radius = 32.0
		inter.interacted.connect(func(_p):
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("📦 Carroça de Mercadores: 'Suprimentos da Associação em trânsito para os entrepostos ao sul da província.'")
		)
		carroca.add_child(inter)
		add_child(carroca)

	# 8. Batedor Viajante (NPC em 8 Direções Definitivo)
	if get_node_or_null("BatedorViajante") == null:
		var batedor := StaticBody2D.new()
		batedor.name = "BatedorViajante"
		batedor.position = Vector2(320, 240)
		batedor.y_sort_enabled = true

		var col := CollisionShape2D.new()
		var circ := CircleShape2D.new()
		circ.radius = 5.0
		col.shape = circ
		col.position = Vector2(0, -2)
		batedor.add_child(col)

		var spr := Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture = load("res://assets/sprites/characters/npc_viajante_scout_8dir.png")
		spr.hframes = 8
		spr.frame = 6 # West (olhando para a fogueira)
		spr.scale = Vector2(1.0, 1.0)
		spr.position = Vector2(0, -18)
		batedor.add_child(spr)

		var lbl := Label.new()
		lbl.text = "Batedor Viajante\n[E] Conversar"
		lbl.position = Vector2(-50, -38)
		lbl.custom_minimum_size = Vector2(100, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.85, 0.95, 0.7))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		batedor.add_child(lbl)

		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Conversar com Batedor"
		inter.interaction_radius = 26.0
		inter.interacted.connect(func(_p):
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🧭 Batedor: 'A estrada é tranquila, mas a Floresta dos Vestígios logo ao sul é perigosa. Se encontrar a Árvore Milenar Sagrada, use Gyo nos olhos para enxergar o fluxo de Nen escondido!'")
		)
		batedor.add_child(inter)
		add_child(batedor)


