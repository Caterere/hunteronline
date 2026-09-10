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

const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")
const ESCOLTA_ZONA_RAIO := 140.0
const ESCOLTA_FORA_ZONA_MAX_S := 8.0

var _emboscada_escolta_feita: bool = false
var _disputa_ponte_ativa: bool = false
var _escolta_jogador_na_zona: bool = true
var _escolta_tempo_fora_zona: float = 0.0
var _escolta_falhou: bool = false


func _ready() -> void:
	_garantir_spawn_points()
	_configurar_limites_camera()
	_configurar_audio_e_hud()
	_posicionar_player()
	_criar_elementos_interativos()
	_criar_zona_protecao_escolta()
	_criar_grande_ponte()
	_conectar_ciclo_noturno()
	if not tree_exiting.is_connected(_on_estrada_tree_exiting):
		tree_exiting.connect(_on_estrada_tree_exiting)
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.ESTRADA)
	CalibrationArtKit.attach_to_estrada(self)
	var quest_sys = get_node_or_null("/root/QuestSystem")
	if quest_sys != null and quest_sys.has_method("sincronizar_inimigos_do_mapa"):
		quest_sys.sincronizar_inimigos_do_mapa(self)
	# Se já for noite ao entrar, tenta emboscada / disputa
	call_deferred("_avaliar_eventos_temporais")


func _process(delta: float) -> void:
	_atualizar_vigilancia_escolta(delta)


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
		inter.interacted.connect(_on_guarda_interact)
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
				if _escolta_ativa():
					hud.exibir_notificacao("📦 Caravana sob escolta — Aguarde a noite; salteadores atacam após o crepúsculo.")
				else:
					hud.exibir_notificacao("📦 Carroça de Mercadores: 'Suprimentos da Associação em trânsito. Fale com o Guarda para aceitar a escolta noturna.'")
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



# ============================================================
# ESCOLTA NOTURNA + DISPUTA DE FACÇÃO (GRANDE PONTE)
# ============================================================


func _criar_zona_protecao_escolta() -> void:
	if get_node_or_null("ZonaProtecaoEscolta") != null:
		return
	var carroca = get_node_or_null("CarrocaMercador")
	var zona := Area2D.new()
	zona.name = "ZonaProtecaoEscolta"
	zona.position = carroca.position if carroca != null else Vector2(240, 360)
	zona.collision_layer = 0
	zona.collision_mask = 2
	zona.monitoring = true
	var col := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = ESCOLTA_ZONA_RAIO
	col.shape = circ
	zona.add_child(col)
	zona.body_entered.connect(_on_zona_escolta_entered)
	zona.body_exited.connect(_on_zona_escolta_exited)
	add_child(zona)


func _on_zona_escolta_entered(body: Node) -> void:
	if body != null and (body.is_in_group("player") or body.name == "Player"):
		_escolta_jogador_na_zona = true
		_escolta_tempo_fora_zona = 0.0


func _on_zona_escolta_exited(body: Node) -> void:
	if body != null and (body.is_in_group("player") or body.name == "Player"):
		_escolta_jogador_na_zona = false


func _eh_noite_ou_crepusculo() -> bool:
	if TimeManager == null or not TimeManager.has_method("get_phase_name"):
		return false
	var fase_u := str(TimeManager.get_phase_name()).to_upper()
	return fase_u == "NIGHT" or fase_u == "NOITE" or fase_u == "DUSK" or fase_u == "CREPUSCULO" or fase_u == "EVENING"


func _atualizar_vigilancia_escolta(delta: float) -> void:
	if _escolta_falhou or not _escolta_ativa() or not _emboscada_escolta_feita:
		return
	if not _eh_noite_ou_crepusculo():
		_escolta_tempo_fora_zona = 0.0
		return
	if _escolta_jogador_na_zona:
		_escolta_tempo_fora_zona = 0.0
		return
	_escolta_tempo_fora_zona += delta
	if _escolta_tempo_fora_zona >= ESCOLTA_FORA_ZONA_MAX_S:
		_falhar_escolta("Você se afastou demais da caravana. A escolta falhou!")


func _on_estrada_tree_exiting() -> void:
	if _escolta_falhou or not _escolta_ativa():
		return
	if _eh_noite_ou_crepusculo():
		_falhar_escolta("Você abandonou a caravana à noite. A escolta falhou!")


func _falhar_escolta(mensagem: String) -> void:
	if _escolta_falhou:
		return
	_escolta_falhou = true
	var q = PadokiaQuestCatalogScript.obter_quest_secundaria_estrada()
	if QuestSystem != null and QuestSystem.has_method("fail_quest"):
		QuestSystem.fail_quest(q)
	elif PlayerData != null and PlayerData.has_method("fail_quest"):
		PlayerData.fail_quest(q)
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("💀 %s" % mensagem)
	if EventBus != null:
		EventBus.emit_toast("💀 Escolta falhou!", Color(1.0, 0.35, 0.35))


func _conectar_ciclo_noturno() -> void:
	if EventBus != null and EventBus.has_signal("time_phase_changed"):
		if not EventBus.time_phase_changed.is_connected(_on_time_phase_estrada):
			EventBus.time_phase_changed.connect(_on_time_phase_estrada)


func _on_time_phase_estrada(phase_name: String) -> void:
	_avaliar_eventos_temporais(phase_name)


func _avaliar_eventos_temporais(phase_name: String = "") -> void:
	var fase := phase_name
	if fase.is_empty() and TimeManager != null and TimeManager.has_method("get_phase_name"):
		fase = TimeManager.get_phase_name()
	var fase_u := fase.to_upper()
	var eh_noite := fase_u == "NIGHT" or fase_u == "NOITE"
	var eh_crepusculo := fase_u == "DUSK" or fase_u == "CREPUSCULO" or fase_u == "EVENING"

	if eh_noite or eh_crepusculo:
		_tentar_emboscada_escolta()
	if eh_noite:
		_tentar_disputa_faccao_ponte()


func _escolta_ativa() -> bool:
	if QuestSystem == null or PlayerData == null:
		return false
	var q = PadokiaQuestCatalogScript.obter_quest_secundaria_estrada()
	return PlayerData.is_quest_active(q) and not PlayerData.is_quest_completed(q)


func _on_guarda_interact(_p: Node) -> void:
	var hud = get_tree().get_first_node_in_group("player_hud")
	var q = PadokiaQuestCatalogScript.obter_quest_secundaria_estrada()
	if QuestSystem != null and PlayerData != null:
		if not PlayerData.is_quest_active(q) and not PlayerData.is_quest_completed(q):
			QuestSystem.start_quest(q)
			QuestSystem.register_npc_visit(&"guarda_patrulha")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🛡️ Guarda: Aceite a escolta! Após o anoitecer, salteadores atacam a carroça. Derrote 2 deles!")
			return
		elif PlayerData.is_quest_active(q):
			QuestSystem.register_npc_visit(&"guarda_patrulha")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🛡️ Guarda: A caravana aguarda. Fique perto da carroça quando a noite cair.")
			return
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🛡️ Guarda: Atenção, Hunter! Feras usam armadura de aura. Quebre a defesa com golpes pesados!")


func _tentar_emboscada_escolta() -> void:
	if _emboscada_escolta_feita:
		return
	if not _escolta_ativa():
		return
	if get_node_or_null("EmboscadaSalteadores") != null:
		_emboscada_escolta_feita = true
		return

	_emboscada_escolta_feita = true
	var root := Node2D.new()
	root.name = "EmboscadaSalteadores"
	add_child(root)

	var posicoes := [Vector2(200, 340), Vector2(280, 400)]
	for i in range(2):
		_spawn_inimigo_estrada(root, "SalteadorEscolta_%d" % i, posicoes[i], &"ladrao_estrada", "Salteador da Estrada")

	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚔️ EMBOSCADA NOTURNA! Fique perto da carroça e derrote os salteadores!")
	if EventBus != null:
		EventBus.emit_toast("⚔️ Emboscada na Caravana Real — proteja a zona!", Color(1.0, 0.45, 0.25))
	if WorldEventManager != null and WorldEventManager.has_method("iniciar_evento_mercador_apuros"):
		WorldEventManager.iniciar_evento_mercador_apuros("estrada_padokia")


func _criar_grande_ponte() -> void:
	if get_node_or_null("GrandePontePedra") != null:
		return
	var ponte := StaticBody2D.new()
	ponte.name = "GrandePontePedra"
	ponte.position = Vector2(400, 420)
	ponte.y_sort_enabled = true

	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	if ResourceLoader.exists("res://assets/sprites/objects/nen_stone_monolith.png"):
		spr.texture = load("res://assets/sprites/objects/nen_stone_monolith.png")
		spr.modulate = Color(0.75, 0.78, 0.85, 1.0)
		spr.position = Vector2(0, -16)
	elif ResourceLoader.exists("res://assets/sprites/objects/marco_pedra_milestone.png"):
		spr.texture = load("res://assets/sprites/objects/marco_pedra_milestone.png")
		spr.scale = Vector2(0.7, 0.55)
		spr.position = Vector2(0, -10)
	ponte.add_child(spr)

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(80, 14)
	col.shape = rect
	col.position = Vector2(0, 4)
	ponte.add_child(col)

	var lbl := Label.new()
	lbl.text = "🌉 Grande Ponte de Pedra\nAssociação × Salteadores"
	lbl.position = Vector2(-70, -40)
	lbl.custom_minimum_size = Vector2(140, 16)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.85, 0.9, 1.0))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	ponte.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Inspecionar Grande Ponte"
	inter.interaction_radius = 36.0
	inter.interacted.connect(func(_p):
		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌉 Ponte: Zona de disputa. À noite, a Associação e salteadores se enfrentam pelo controle da rota.")
		_tentar_disputa_faccao_ponte(true)
	)
	ponte.add_child(inter)
	add_child(ponte)


func _tentar_disputa_faccao_ponte(forcar: bool = false) -> void:
	if get_node_or_null("DisputaFaccaoPonte") != null:
		return
	if not forcar:
		if PlayerData != null and PlayerData.quest_states.get("disputa_ponte_vista_hoje", false):
			return

	_disputa_ponte_ativa = true
	if PlayerData != null:
		PlayerData.quest_states["disputa_ponte_vista_hoje"] = true

	var root := Node2D.new()
	root.name = "DisputaFaccaoPonte"
	add_child(root)

	var aliado := StaticBody2D.new()
	aliado.name = "GuardaAssociacaoPonte"
	aliado.position = Vector2(360, 400)
	var spr_a := Sprite2D.new()
	spr_a.texture = load("res://assets/sprites/characters/npc_guarda_fronteira_8dir.png")
	spr_a.hframes = 8
	spr_a.frame = 2
	spr_a.position = Vector2(0, -17)
	aliado.add_child(spr_a)
	var lbl_a := Label.new()
	lbl_a.text = "🏛️ Guarda Associação"
	lbl_a.position = Vector2(-50, -34)
	lbl_a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl_a, 6, Color(0.55, 0.85, 1.0))
	aliado.add_child(lbl_a)
	root.add_child(aliado)

	_spawn_inimigo_estrada(root, "SalteadorPonte_0", Vector2(440, 400), &"ladrao_estrada", "Salteador da Ponte")
	_spawn_inimigo_estrada(root, "SalteadorPonte_1", Vector2(460, 440), &"ladrao_estrada", "Salteador da Ponte")

	if WorldEventManager != null and WorldEventManager.has_method("criar_evento_dinamico"):
		WorldEventManager.criar_evento_dinamico(
			"evento_disputa_ponte_estrada_padokia",
			"Disputa Territorial na Grande Ponte",
			"A Associação Hunter e salteadores duelam pelo controle da rota comercial.",
			"estrada_padokia",
			5.0,
			40
		)

	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚔️ DISPUTA NA PONTE! Ajude a Associação a expulsar os salteadores!")
	if EventBus != null:
		EventBus.emit_toast("⚔️ Disputa: Associação vs Salteadores", Color(0.95, 0.75, 0.25))


func _spawn_inimigo_estrada(parent: Node, nome: String, pos: Vector2, e_id: StringName, e_nome: String) -> void:
	if parent.get_node_or_null(nome) != null:
		return
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn == null:
		return
	var enemy = enemy_scn.instantiate()
	enemy.name = nome
	enemy.position = pos
	var es = enemy.get_node_or_null("EnemySystem")
	if es != null:
		es.enemy_id = e_id
		es.enemy_name = e_nome
		es.is_mission_enemy = true
		if QuestSystem != null:
			if not es.died.is_connected(QuestSystem.register_enemy_kill):
				es.died.connect(func(killed_id):
					QuestSystem.register_enemy_kill(killed_id)
					_on_salteador_morto(killed_id)
				)
	parent.add_child(enemy)
	if es != null and es.has_method("_vincular_textura_inimigo"):
		es._vincular_textura_inimigo()


func _on_salteador_morto(_killed_id) -> void:
	var root = get_node_or_null("DisputaFaccaoPonte")
	if root == null:
		return
	var vivos := 0
	for c in root.get_children():
		if str(c.name).begins_with("SalteadorPonte") and is_instance_valid(c):
			var es = c.get_node_or_null("EnemySystem")
			if es != null and not es.is_dead:
				vivos += 1
	if vivos == 0:
		if ReputationSystem != null:
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER, 80, "Disputa da Grande Ponte")
		if WorldEventManager != null and WorldEventManager.has_method("resolver_evento_jogador"):
			WorldEventManager.resolver_evento_jogador("evento_disputa_ponte_estrada_padokia", true)
		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏛️ Ponte segura! A Associação reconhece sua intervenção (+Rep).")
