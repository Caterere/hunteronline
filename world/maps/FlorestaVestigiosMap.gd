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
	_pintar_piso_floresta()
	_configurar_limites_camera()
	_configurar_audio_e_hud()
	_posicionar_player()
	_criar_elementos_floresta()
	_instanciar_feras_selvagens()
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.FLORESTA)
	WorldDensityKit.attach(self, WorldDensityKit.KitKind.FLORESTA)
	WorldPropsKit.attach(self, WorldPropsKit.KitKind.FLORESTA)
	WorldLandmarkKit.attach(self, WorldLandmarkKit.KitKind.FLORESTA)
	WorldFxKit.attach(self, WorldFxKit.KitKind.FLORESTA)
	WorldPolishKit.attach(self, WorldPolishKit.KitKind.FLORESTA)
	if has_method("_espalhar_detalhes_clareira"):
		_espalhar_detalhes_clareira()
	var quest_sys = get_node_or_null("/root/QuestSystem")
	if quest_sys != null and quest_sys.has_method("sincronizar_inimigos_do_mapa"):
		quest_sys.sincronizar_inimigos_do_mapa(self)


func _pintar_piso_floresta() -> void:
	# Grama de floresta detalhada (PixelLab) + trilha de solo na faixa vertical
	# central, ligando a entrada da Estrada à saída sul.
	var eh_trilha := func(cx: int, _cy: int) -> bool:
		return cx >= 11 and cx <= 15
	WangFloorPainter.pintar(self, "res://world/tilesets/floresta_vestigios_tileset.tres",
		"PisoFlorestaPixelLab", -8, 0, 0, 25, 20, eh_trilha)


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




func _espalhar_detalhes_clareira() -> void:
	if get_node_or_null("DetalhesClareira") != null:
		return
	var root := Node2D.new()
	root.name = "DetalhesClareira"
	add_child(root)
	var props := [
		{"n": "ArbustoA", "pos": Vector2(180, 220), "tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "sc": Vector2(1.0, 1.0)},
		{"n": "ArbustoB", "pos": Vector2(520, 260), "tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "sc": Vector2(0.9, 0.9)},
		{"n": "ArbustoC", "pos": Vector2(300, 420), "tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "sc": Vector2(1.05, 1.05)},
		{"n": "MarcoSul", "pos": Vector2(440, 480), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png", "sc": Vector2(1.0, 1.0)},
		{"n": "LanternaClareiraExtra", "pos": Vector2(260, 340), "tex": "res://assets/sprites/objects/hunter_road_lantern.png", "sc": Vector2(1.0, 1.0)},
	]
	for p in props:
		var n := Node2D.new()
		n.name = p["n"]
		n.position = p["pos"]
		n.z_index = 1
		var spr := Sprite2D.new()
		spr.centered = true
		spr.position = Vector2(0, -8)
		spr.scale = p["sc"]
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if ResourceLoader.exists(p["tex"]):
			spr.texture = load(p["tex"])
		n.add_child(spr)
		root.add_child(n)

func _criar_elementos_floresta() -> void:
	# 1. Árvore Milenar Sagrada (Centro)
	if get_node_or_null("ArvoreMilenar") == null:
		var arvore := StaticBody2D.new()
		arvore.name = "ArvoreMilenar"
		arvore.position = Vector2(400, 300)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/objects/nen_stone_monolith.png")
		spr.centered = true
		spr.position = Vector2(0, -28)
		spr.scale = Vector2(1.35, 1.55)
		spr.modulate = Color(0.45, 0.95, 0.55, 1.0)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
		if ResourceLoader.exists("res://assets/sprites/characters/npc_herbalista_floresta_8dir.png"):
			spr.texture = load("res://assets/sprites/characters/npc_herbalista_floresta_8dir.png")
			spr.hframes = 8
			spr.vframes = 1
			spr.frame = 0
		else:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
		spr.position = Vector2(0, -17)
		spr.modulate = Color.WHITE
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
		spr.texture = load("res://assets/sprites/objects/nen_stone_monolith.png")
		spr.centered = true
		spr.position = Vector2(0, -14)
		spr.scale = Vector2(0.85, 0.7)
		spr.modulate = Color(0.7, 0.62, 0.5, 1.0)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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

	_instanciar_sensores_nen_floresta()
	_instanciar_baus_clareira()


func _instanciar_baus_clareira() -> void:
	# Clareiras periféricas (Quality Gap B): consumíveis Poção / Pedra de Aura
	_spawna_bau_clareira(
		"BauClareiraOeste",
		Vector2(100, 260),
		"Baú da Clareira Oeste",
		[
			{"id": &"pocao_vida", "qtd": 2},
			{"id": &"elixir_aura", "qtd": 1}
		]
	)
	_spawna_bau_clareira(
		"BauClareiraLeste",
		Vector2(680, 300),
		"Baú da Clareira Leste",
		[
			{"id": &"pocao_vida", "qtd": 1},
			{"id": &"elixir_aura", "qtd": 2}
		]
	)
	_spawna_bau_clareira(
		"BauClareiraSul",
		Vector2(320, 560),
		"Baú da Clareira Sul",
		[
			{"id": &"elixir_aura", "qtd": 1},
			{"id": &"pocao_vida", "qtd": 1}
		]
	)


func _spawna_bau_clareira(nome: String, pos: Vector2, titulo: String, loot: Array) -> void:
	if get_node_or_null(nome) != null:
		return
	var bau := Area2D.new()
	bau.name = nome
	bau.position = pos
	bau.collision_layer = 0
	bau.collision_mask = 0

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(28, 28)
	col.shape = box
	bau.add_child(col)

	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	if ResourceLoader.exists("res://assets/sprites/objects/nen_stone_monolith.png"):
		spr.texture = load("res://assets/sprites/objects/nen_stone_monolith.png")
		spr.scale = Vector2(0.35, 0.28)
		spr.modulate = Color(0.95, 0.8, 0.35, 1.0)
		spr.position = Vector2(0, -8)
	bau.add_child(spr)

	var lbl := Label.new()
	lbl.text = "📦 %s" % titulo
	lbl.position = Vector2(-55, -36)
	lbl.custom_minimum_size = Vector2(110, 12)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 6, Color(0.95, 0.88, 0.55))
	bau.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Abrir %s" % titulo
	inter.interaction_radius = 28.0
	inter.interacted.connect(func(_p):
		_abrir_bau_clareira(bau, titulo, loot)
	)
	bau.add_child(inter)
	add_child(bau)


func _abrir_bau_clareira(bau_node: Node, titulo: String, loot: Array) -> void:
	if bau_node == null or not is_instance_valid(bau_node):
		return
	var partes: PackedStringArray = []
	if PlayerData != null:
		for entry in loot:
			var id: StringName = entry.get("id", &"")
			var qtd: int = int(entry.get("qtd", 1))
			if id.is_empty() or qtd <= 0:
				continue
			PlayerData.adicionar_item(id, qtd)
			partes.append("%dx %s" % [qtd, str(id)])
	var resumo := ", ".join(partes) if not partes.is_empty() else "nada"
	if EventBus != null:
		EventBus.emit_toast("✨ %s: %s" % [titulo, resumo], Color(0.35, 1.0, 0.55))
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("📦 Você abriu [%s] e encontrou: %s" % [titulo, resumo])
	bau_node.queue_free()


func _instanciar_sensores_nen_floresta() -> void:
	# Gyo só após despertar Nen (Arena Celestial / Wing) — Zetsu/Ko permanecem exploráveis
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoClueArvoreRaizes", Vector2(360, 280),
			&"floresta_aura_raizes", "Raízes Pulsantes de Nen",
			"As raízes da Árvore Milenar vibram com aura antiga. Alguém treinou Intensificação aqui recentemente.",
			"Intensificação", 1, Color(0.35, 1.0, 0.55, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoCluePegadasSul", Vector2(460, 500),
			&"floresta_pegadas_fera", "Pegadas de Aura Predatória",
			"Rastros de aura se dirigem às Ruínas de Zaban. A presa — ou o caçador — passou há pouco.",
			"Emissão", 1, Color(0.95, 0.55, 0.25, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoClueMarcaTotem", Vector2(180, 340),
			&"floresta_marca_totem", "Marca Ritual Esquecida",
			"Um selo rudimentar de Nen foi gravado na pedra musgosa. Exige foco de Gyo para ler o padrão.",
			"Conjuração", 2, Color(0.55, 0.7, 1.0, 0.9)
		)

	# Segunda rocha KO bloqueando baú/atalho oeste
	NenSensorFactory.criar_ko(
		self, "KoObstacleAtalhoOeste", Vector2(120, 220),
		"Rocha Rachada do Atalho Oeste", &"pocao_aura"
	)

	# Acampamentos de salteadores / predadores com Zetsu
	NenSensorFactory.criar_zetsu(
		self, "ZetsuAcampamentoNorte", Vector2(280, 140),
		&"acampamento_salteadores_norte", "Acampamento de Salteadores",
		Vector2(140, 100),
		&"candidato_exame", "Salteador Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuClareiraLeste", Vector2(620, 380),
		&"clareira_predadores_leste", "Clareira de Predadores Sensíveis",
		Vector2(150, 110),
		&"lobo_sombras", "Fera das Sombras Alertada"
	)


func _instanciar_feras_selvagens() -> void:
	if get_node_or_null("FeraSombra1") != null:
		return

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn:
		var mobs_data = [
			{"name": "FeraSombra1", "pos": Vector2(240, 200), "id": &"lobo_sombras", "label": "Besta de Sombra Ágil", "def": 100.0, "role": "fast", "tint": Color(0.75, 0.9, 1.0)},
			{"name": "FeraSombra2", "pos": Vector2(560, 420), "id": &"lobo_sombras", "label": "Besta de Sombra Voraz", "def": 110.0, "role": "bruiser", "tint": Color(0.85, 0.7, 1.0)},
			{"name": "FeraSombra3", "pos": Vector2(200, 480), "id": &"lobo_sombras", "label": "Lobo das Sombras", "def": 85.0, "role": "fast", "tint": Color.WHITE},
			{"name": "FeraSombra4", "pos": Vector2(600, 180), "id": &"fera_alada", "label": "Fera Alada Emboscadora", "def": 95.0, "role": "ambusher", "tint": Color.WHITE},
			{"name": "SentinelaRuinasEntrada", "pos": Vector2(400, 520), "id": &"sentinela_pedra", "label": "Sentinela de Pedra Ancestral", "def": 140.0, "role": "tank", "tint": Color(0.7, 0.7, 0.65)}
		]
		for m in mobs_data:
			var mob = enemy_scn.instantiate()
			mob.name = m["name"]
			mob.position = m["pos"]
			var es = mob.get_node_or_null("EnemySystem")
			if es:
				es.enemy_id = m["id"]
				es.enemy_name = m["label"]
				es.defesa_barra_max = m["def"]
				es.defesa_barra_atual = m["def"]
			add_child(mob)
			var spr = mob.get_node_or_null("Sprite2D") as Sprite2D
			if spr != null and m.has("tint"):
				spr.modulate = m["tint"]
			if es:
				if es.enemy_data != null:
					es.enemy_data = es.enemy_data.duplicate(true)
					es.enemy_data.role = m.get("role", "bruiser")
					es.enemy_data.enemy_name = m["label"]
				# Reaplica sheet caso _ready tenha corrido antes do id (fallback seguro)
				if es.has_method("_vincular_textura_inimigo"):
					es._vincular_textura_inimigo()
				var ai = mob.get_node_or_null("EnemyAI") as EnemyAI
				if ai != null:
					match String(m.get("role", "bruiser")):
						"fast":
							ai.move_speed = 118.0
							ai.detection_range = 280.0
							ai.attack_cooldown = 0.95
						"ambusher":
							ai.move_speed = 102.0
							ai.detection_range = 200.0
							ai.attack_cooldown = 1.05
						"tank":
							ai.move_speed = 62.0
							ai.detection_range = 220.0
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)

