class_name FlorestaVestigiosMap
extends Node2D

# ============================================================
# HUNTER ONLINE - FLORESTA DOS VESTÍGIOS (MAPA PERMANENTE CONECTADO)
# ============================================================
#
# Primeira zona selvagem conectada à Estrada Real:
# - Conexão Norte: Estrada Real de Padokia (world/maps/estrada_padokia.tscn)
# - Conexão Sul/Ruínas: Dungeon das Ruínas de Zaban (dungeon_ruinas_zaban.tscn)
# - Árvore Milenar Sagrada (Aura de Nen sob Gyo)
# - Rocha Destrutível com KO (KoObstacle)
# - Totem Ancestral de Ren (RenBeacon)
# - Feras Selvagens de Padokia (Inimigos)
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
	_criar_elementos_floresta()
	_instanciar_feras_selvagens()
	var quest_sys = get_node_or_null("/root/QuestSystem")
	if quest_sys != null and quest_sys.has_method("sincronizar_inimigos_do_mapa"):
		quest_sys.sincronizar_inimigos_do_mapa(self)


func _garantir_spawn_points() -> void:
	var wpm = get_node_or_null("/root/WorldProgressionManager")
	if get_node_or_null("SpawnFromEstrada") == null:
		var sp_est := SpawnPoint.new()
		sp_est.name = "SpawnFromEstrada"
		sp_est.spawn_id = &"from_estrada"
		sp_est.is_default_spawn = true
		sp_est.position = Vector2(400, 70)
		add_child(sp_est)
		if wpm != null and wpm.has_method("registrar_spawn_point"):
			wpm.registrar_spawn_point(sp_est)

	if get_node_or_null("SpawnFromDungeon") == null:
		var sp_dun := SpawnPoint.new()
		sp_dun.name = "SpawnFromDungeon"
		sp_dun.spawn_id = &"from_dungeon"
		sp_dun.is_default_spawn = false
		sp_dun.position = Vector2(400, 580)
		add_child(sp_dun)
		if wpm != null and wpm.has_method("registrar_spawn_point"):
			wpm.registrar_spawn_point(sp_dun)


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
		audio_mgr.tocar_bgm("forest_theme")

	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🌲 Floresta dos Vestígios — Feras & Mistérios Ancestrais")


func _posicionar_player() -> void:
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as CharacterBody2D

	if player != null:
		var wpm = get_node_or_null("/root/WorldProgressionManager")
		if wpm != null and wpm.has_method("posicionar_player_no_spawn"):
			wpm.posicionar_player_no_spawn(player)


func _criar_elementos_floresta() -> void:
	# 1. Árvore Milenar Sagrada (Centro)
	if get_node_or_null("ArvoreMilenar") == null:
		var arvore := StaticBody2D.new()
		arvore.name = "ArvoreMilenar"
		arvore.position = Vector2(400, 300)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.position = Vector2(0, -24)
		spr.scale = Vector2(1.8, 1.8)
		spr.modulate = Color(0.2, 0.85, 0.35, 1.0)
		arvore.add_child(spr)

		var col := CollisionShape2D.new()
		var circ := CircleShape2D.new()
		circ.radius = 8.0
		col.shape = circ
		col.position = Vector2(0, -4)
		arvore.add_child(col)

		var lbl := Label.new()
		lbl.text = "🌳 Árvore Milenar Sagrada\n[E] Meditar com Nen"
		lbl.position = Vector2(-70, -46)
		lbl.custom_minimum_size = Vector2(140, 16)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.6, 1.0, 0.6))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		arvore.add_child(lbl)

		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Meditar sob a Árvore"
		inter.interaction_radius = 24.0
		inter.interacted.connect(func(_p):
			var pdata = get_tree().root.get_node_or_null("PlayerData")
			if pdata != null:
				var aura_max = pdata.attributes.get("aura_max", 100)
				pdata.attributes["aura"] = aura_max
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🍃 A aura da Árvore Milenar envolve seu corpo! Aura totalmente recarregada.")
		)
		arvore.add_child(inter)
		add_child(arvore)

	# 2. Herbalista da Associação (NPC de Apoio)
	if get_node_or_null("HerbalistaFloresta") == null:
		var herb := StaticBody2D.new()
		herb.name = "HerbalistaFloresta"
		herb.position = Vector2(450, 310)

		var col := CollisionShape2D.new()
		var circ := CircleShape2D.new()
		circ.radius = 5.0
		col.shape = circ
		col.position = Vector2(0, -2)
		herb.add_child(col)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.position = Vector2(0, -9)
		spr.modulate = Color(0.4, 0.9, 0.5, 1.0)
		herb.add_child(spr)

		var lbl := Label.new()
		lbl.text = "Herbalista\n[E] Conversar"
		lbl.position = Vector2(-45, -28)
		lbl.custom_minimum_size = Vector2(90, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.7, 1.0, 0.7))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		herb.add_child(lbl)

		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Falar com Herbalista"
		inter.interaction_radius = 24.0
		inter.interacted.connect(func(_p):
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🌿 Herbalista: 'As feras e sentinelas usam guarda densa. Aplique combos rápidos ou golpes fortes para quebrar a defesa e deixá-las vulneráveis!'")
		)
		herb.add_child(inter)
		add_child(herb)

	# 3. Barreira de Rocha Quebrável com KO (Bloqueando atalho)
	if get_node_or_null("KoObstacleFloresta") == null:
		var ko_obs := KoObstacle.new()
		ko_obs.name = "KoObstacleFloresta"
		ko_obs.position = Vector2(620, 260)
		ko_obs.obstacle_name = "Rocha Fraturada por Nen"

		var col := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(24, 20)
		col.shape = box
		col.position = Vector2(0, -2)
		ko_obs.add_child(col)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.position = Vector2(0, -10)
		spr.modulate = Color(0.65, 0.55, 0.45, 1.0)
		ko_obs.add_child(spr)

		add_child(ko_obs)

	# 4. Portão Norte (Retorno à Estrada Real de Padokia)
	if get_node_or_null("PortaoNorteEstrada") == null:
		var p_norte := MapTransitionArea.new()
		p_norte.name = "PortaoNorteEstrada"
		p_norte.position = Vector2(400, 24)
		p_norte.portal_name = "Estrada Real de Padokia"
		p_norte.map_subtitle = "Rota Comercial em Direção à Capital"
		p_norte.target_scene_path = "res://world/maps/estrada_padokia.tscn"
		p_norte.target_spawn_id = &"from_floresta"
		p_norte.requires_e_key = true

		var col := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(48, 16)
		col.shape = box
		p_norte.add_child(col)
		add_child(p_norte)

	# 5. Portão Sul (Dungeon das Ruínas Ancestrais de Zaban)
	if get_node_or_null("PortaoSulDungeon") == null:
		var p_sul := MapTransitionArea.new()
		p_sul.name = "PortaoSulDungeon"
		p_sul.position = Vector2(400, 620)
		p_sul.portal_name = "Ruínas de Zaban (Dungeon)"
		p_sul.map_subtitle = "Cripta Ancestral — Nível Perigoso"
		p_sul.target_scene_path = "res://world/maps/dungeon_ruinas_zaban.tscn"
		p_sul.target_spawn_id = &"entrada"
		p_sul.requires_e_key = true

		var col := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(48, 16)
		col.shape = box
		p_sul.add_child(col)
		add_child(p_sul)


func _instanciar_feras_selvagens() -> void:
	if get_node_or_null("FeraSombra1") != null:
		return

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn:
		var mobs_data = [
			{"name": "FeraSombra1", "pos": Vector2(240, 200), "id": &"slime", "label": "Besta de Sombra Ágil", "def": 100.0},
			{"name": "FeraSombra2", "pos": Vector2(560, 420), "id": &"slime", "label": "Besta de Sombra Voraz", "def": 100.0},
			{"name": "FeraSombra3", "pos": Vector2(200, 480), "id": &"slime", "label": "Besta de Sombra Feroz", "def": 100.0},
			{"name": "FeraSombra4", "pos": Vector2(600, 180), "id": &"slime", "label": "Besta de Sombra Rastreadora", "def": 100.0},
			{"name": "SentinelaRuinasEntrada", "pos": Vector2(400, 520), "id": &"sentinela_pedra", "label": "Sentinela de Pedra Ancestral", "def": 140.0}
		]
		for m in mobs_data:
			var mob = enemy_scn.instantiate()
			mob.name = m["name"]
			mob.position = m["pos"]
			add_child(mob)
			var es = mob.get_node_or_null("EnemySystem")
			if es:
				es.enemy_id = m["id"]
				es.enemy_name = m["label"]
				es.defesa_barra_max = m["def"]
				es.defesa_barra_atual = m["def"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)

