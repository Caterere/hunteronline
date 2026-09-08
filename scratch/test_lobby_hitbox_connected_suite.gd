extends Node2D

var _total: int = 0
var _passados: int = 0

func _ready() -> void:
	print("\n============================================================")
	print("⚔️ TESTE INTEGRADO: HITBOXES, LOBBY, MAPAS CONECTADOS & GAME FEEL")
	print("============================================================")

	_teste_1_player_hitbox_e_baseline()
	_teste_2_npc_hitbox_e_interacao()
	_teste_3_tileset_footprints_e_lobby()
	_teste_4_mapa_estrada_padokia()
	_teste_5_mapa_floresta_vestigios()
	_teste_6_combat_dash_e_efeitos_visuais()

	print("\n============================================================")
	print("🏆 RESULTADO GERAL: %d / %d TESTES APROVADOS" % [_passados, _total])
	if _passados == _total:
		print("   STATUS: 100% SUCESSO! HITBOXES, MAPAS E COMBATE VALIDADOS!")
	else:
		printerr("   ALERTA: %d testes falharam!" % (_total - _passados))
	print("============================================================\n")
	get_tree().quit(0 if _passados == _total else 1)

func _assinalar(condicao: bool, msg_ok: String, msg_erro: String) -> void:
	_total += 1
	if condicao:
		_passados += 1
		print("  ✅ [PASS] " + msg_ok)
	else:
		printerr("  ❌ [FAIL] " + msg_erro)

# ------------------------------------------------------------------------------
# TESTE 1: PLAYER HITBOX & BASELINE
# ------------------------------------------------------------------------------
func _teste_1_player_hitbox_e_baseline() -> void:
	print("\n[TESTE 1/6] Validando Hitbox e Pés do Player...")
	var pl_scn = load("res://entities/Player/Player.tscn") as PackedScene
	_assinalar(pl_scn != null, "Cena Player.tscn carregada", "Falha ao carregar Player.tscn")
	if pl_scn == null: return

	var pl = pl_scn.instantiate()
	add_child(pl)

	# Verificar Hurtbox (Layer 2)
	var hurtbox = pl.get_node_or_null("HurtBox") as Area2D
	_assinalar(hurtbox != null, "Player possui HurtBox", "HurtBox ausente no Player")
	if hurtbox:
		var h_col = hurtbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
		_assinalar(h_col != null, "HurtBox possui CollisionShape2D", "CollisionShape2D ausente na HurtBox")
		if h_col and h_col.shape is RectangleShape2D:
			var sz = (h_col.shape as RectangleShape2D).size
			_assinalar(sz.x <= 16.0 and sz.y <= 24.0, 
				"Dimensões da Hurtbox corrigidas para silhueta real (%s)" % str(sz),
				"Hurtbox continua com tamanho excessivo (%s)" % str(sz))
			_assinalar(h_col.position.y < 0, 
				"Centro da Hurtbox elevado para cobrir tronco/cabeça (%s)" % str(h_col.position),
				"Posição da Hurtbox incorreta (%s)" % str(h_col.position))

	# Verificar Pés (CollisionShape2D raiz do CharacterBody2D)
	var feet_col = pl.get_node_or_null("CollisionShape2D") as CollisionShape2D
	_assinalar(feet_col != null, "Player possui colisão de pés raiz", "CollisionShape2D raiz ausente")
	if feet_col and feet_col.shape is RectangleShape2D:
		var sz = (feet_col.shape as RectangleShape2D).size
		_assinalar(sz.x <= 10.0 and sz.y <= 8.0,
			"Colisão de pés do Player ajustada para base 8x6 (%s)" % str(sz),
			"Colisão de pés fora do padrão (%s)" % str(sz))

	pl.queue_free()

# ------------------------------------------------------------------------------
# TESTE 2: NPC HITBOX & INTERAÇÃO
# ------------------------------------------------------------------------------
func _teste_2_npc_hitbox_e_interacao() -> void:
	print("\n[TESTE 2/6] Validando Hitbox de NPCs (Ferreiro e Vendedor)...")
	var ferreiro_scn = load("res://entities/npc/ferreiro/Ferreiro.tscn") as PackedScene
	var vendedor_scn = load("res://entities/npc/vendedor/Vendedor.tscn") as PackedScene
	_assinalar(ferreiro_scn != null and vendedor_scn != null, "Cenas de NPCs carregadas", "Falha ao carregar NPCs")

	if ferreiro_scn:
		var fe = ferreiro_scn.instantiate()
		add_child(fe)
		var fe_col = fe.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if fe_col and fe_col.shape is CircleShape2D:
			var r = (fe_col.shape as CircleShape2D).radius
			_assinalar(r <= 6.0, "Ferreiro colisão de pés raio 5.0 (sem barreira invisível de 20px)", "Ferreiro raio = %f" % r)
		fe.queue_free()

	if vendedor_scn:
		var ve = vendedor_scn.instantiate()
		add_child(ve)
		var ve_col = ve.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if ve_col and ve_col.shape is CircleShape2D:
			var r = (ve_col.shape as CircleShape2D).radius
			_assinalar(r <= 6.0, "Vendedor colisão de pés raio 5.0", "Vendedor raio = %f" % r)
		ve.queue_free()

# ------------------------------------------------------------------------------
# TESTE 3: TILESET FOOTPRINTS & LOBBY ARCHITECTURE
# ------------------------------------------------------------------------------
func _teste_3_tileset_footprints_e_lobby() -> void:
	print("\n[TESTE 3/6] Validando Footprints no lobby_tileset.tres e estrutura do Lobby...")
	var ts = load("res://world/tilesets/lobby_tileset.tres") as TileSet
	_assinalar(ts != null, "lobby_tileset.tres carregado com sucesso", "lobby_tileset.tres nao encontrado")
	if ts:
		var src_castelo = ts.get_source(11) as TileSetAtlasSource
		_assinalar(src_castelo != null, "Source 11 (Castelo) presente no tileset", "Source 11 ausente")
		if src_castelo:
			# Linha 15 é padding transparente -> NÃO pode ter física
			var tile_pad = src_castelo.get_tile_data(Vector2i(5, 15), 0)
			var has_pad_poly = false
			if tile_pad and tile_pad.get_collision_polygons_count(0) > 0:
				has_pad_poly = true
			_assinalar(not has_pad_poly, "Padding transparente do Castelo NÃO possui colisão física", "Padding ainda colide!")

			# Linha 14 é a fundação real -> DEVE ter física de base
			var tile_fund = src_castelo.get_tile_data(Vector2i(5, 14), 0)
			var has_fund_poly = false
			if tile_fund and tile_fund.get_collision_polygons_count(0) > 0:
				has_fund_poly = true
			_assinalar(has_fund_poly, "Linha de fundação real possui colisão de base configurada", "Fundação sem física!")

	var lobby_scn = load("res://world/lobby.tscn") as PackedScene
	_assinalar(lobby_scn != null, "world/lobby.tscn carregado com sucesso", "world/lobby.tscn ausente")
	if lobby_scn:
		var lob = lobby_scn.instantiate()
		add_child(lob)
		_assinalar(lob.get_node_or_null("Chao_TileMapLayer") != null, "Lobby possui Chao_TileMapLayer", "Chao ausente")
		_assinalar(lob.get_node_or_null("Caminhos_TileMapLayer") != null, "Lobby possui Caminhos_TileMapLayer", "Caminhos ausente")
		_assinalar(lob.get_node_or_null("Estruturas_TileMapLayer") != null, "Lobby possui Estruturas_TileMapLayer", "Estruturas ausente")
		_assinalar(lob.get_node_or_null("Decor_TileMapLayer") != null, "Lobby possui Decor_TileMapLayer", "Decor ausente")
		_assinalar(lob.get_node_or_null("ColisoesEstruturasLobby") == null, 
			"Colisões duplicadas e deslocadas removidas com sucesso", 
			"ColisoesEstruturasLobby ainda detectado no Lobby!")
		lob.queue_free()

# ------------------------------------------------------------------------------
# TESTE 4: MAPA PERMANENTE - ESTRADA REAL DE PADOKIA
# ------------------------------------------------------------------------------
func _teste_4_mapa_estrada_padokia() -> void:
	print("\n[TESTE 4/6] Validando Estrada Real de Padokia (estrada_padokia.tscn)...")
	var scn = load("res://world/maps/estrada_padokia.tscn") as PackedScene
	_assinalar(scn != null, "Cena estrada_padokia.tscn existe e carrega", "estrada_padokia.tscn ausente")
	if scn:
		var mapa = scn.instantiate()
		add_child(mapa)
		_assinalar(mapa is EstradaPadokiaMap, "Mapa possui script EstradaPadokiaMap", "Script incorreto")
		_assinalar(mapa.get_node_or_null("Chao_TileMapLayer") != null, "Possui camada Chao", "Chao ausente")
		_assinalar(mapa.get_node_or_null("Caminhos_TileMapLayer") != null, "Possui camada Caminhos", "Caminhos ausente")
		_assinalar(mapa.get_node_or_null("Estruturas_TileMapLayer") != null, "Possui camada Estruturas", "Estruturas ausente")
		_assinalar(mapa.get_node_or_null("Decor_TileMapLayer") != null, "Possui camada Decor", "Decor ausente")
		_assinalar(mapa.get_node_or_null("SpawnFromLobby") != null, "Possui SpawnFromLobby", "SpawnFromLobby ausente")
		_assinalar(mapa.get_node_or_null("SpawnFromFloresta") != null, "Possui SpawnFromFloresta", "SpawnFromFloresta ausente")
		_assinalar(mapa.get_node_or_null("PortaoNorteLobby") != null, "Possui Portão Norte para Capital (Lobby)", "Portão Norte ausente")
		_assinalar(mapa.get_node_or_null("PortaoSulFloresta") != null, "Possui Portão Sul para Floresta", "Portão Sul ausente")
		_assinalar(mapa.get_node_or_null("FogueiraDescanso") != null, "Possui Fogueira de Descanso funcional", "Fogueira ausente")
		_assinalar(mapa.get_node_or_null("GuardaPatrulha") != null, "Possui Guarda de Patrulha NPC", "Guarda ausente")
		_assinalar(mapa.get_node_or_null("PostoGuardaFronteira") != null, "Possui Posto de Guarda de Fronteira (Landmark)", "Posto ausente")
		_assinalar(mapa.get_node_or_null("CarrocaMercador") != null, "Possui Carroça de Mercador (Landmark)", "Carroça ausente")
		_assinalar(mapa.get_node_or_null("BatedorViajante") != null, "Possui Batedor Viajante (NPC 8-dir)", "Batedor ausente")
		_assinalar(mapa.get_node_or_null("MarcoDePedra") != null, "Possui Marco de Pedra das Milhas", "Marco ausente")
		var fogueira = mapa.get_node_or_null("FogueiraDescanso")
		if fogueira:
			_assinalar(fogueira.y_sort_enabled, "Fogueira possui Y-sort habilitado", "Fogueira sem Y-sort")
			var f_spr = fogueira.get_node_or_null("Sprite2D") as Sprite2D
			_assinalar(f_spr and f_spr.texture and f_spr.texture.resource_path.ends_with("fogueira_acampamento_prop.png"), "Fogueira usa textura definitiva fogueira_acampamento_prop.png", "Fogueira com placeholder")
		var guarda = mapa.get_node_or_null("GuardaPatrulha")
		if guarda:
			_assinalar(guarda.y_sort_enabled, "Guarda possui Y-sort habilitado", "Guarda sem Y-sort")
			var g_spr = guarda.get_node_or_null("Sprite2D") as Sprite2D
			_assinalar(g_spr and g_spr.texture and g_spr.texture.resource_path.ends_with("npc_guarda_fronteira_8dir.png") and g_spr.hframes == 8, "Guarda usa folha 8-direções npc_guarda_fronteira_8dir.png", "Guarda com sprite incorreto")
		var batedor = mapa.get_node_or_null("BatedorViajante")
		if batedor:
			_assinalar(batedor.y_sort_enabled, "Batedor possui Y-sort habilitado", "Batedor sem Y-sort")
			var b_spr = batedor.get_node_or_null("Sprite2D") as Sprite2D
			_assinalar(b_spr and b_spr.texture and b_spr.texture.resource_path.ends_with("npc_viajante_scout_8dir.png") and b_spr.hframes == 8, "Batedor usa folha 8-direções npc_viajante_scout_8dir.png", "Batedor com sprite incorreto")
		mapa.queue_free()

# ------------------------------------------------------------------------------
# TESTE 5: MAPA PERMANENTE - FLORESTA DOS VESTÍGIOS
# ------------------------------------------------------------------------------
func _teste_5_mapa_floresta_vestigios() -> void:
	print("\n[TESTE 5/6] Validando Floresta dos Vestígios (floresta_vestigios.tscn)...")
	var scn = load("res://world/maps/floresta_vestigios.tscn") as PackedScene
	_assinalar(scn != null, "Cena floresta_vestigios.tscn existe e carrega", "floresta_vestigios.tscn ausente")
	if scn:
		var mapa = scn.instantiate()
		add_child(mapa)
		_assinalar(mapa is FlorestaVestigiosMap, "Mapa possui script FlorestaVestigiosMap", "Script incorreto")
		_assinalar(mapa.get_node_or_null("Chao_TileMapLayer") != null, "Possui camada Chao", "Chao ausente")
		_assinalar(mapa.get_node_or_null("Caminhos_TileMapLayer") != null, "Possui camada Caminhos", "Caminhos ausente")
		_assinalar(mapa.get_node_or_null("SpawnFromEstrada") != null, "Possui SpawnFromEstrada", "SpawnFromEstrada ausente")
		_assinalar(mapa.get_node_or_null("SpawnFromDungeon") != null, "Possui SpawnFromDungeon", "SpawnFromDungeon ausente")
		_assinalar(mapa.get_node_or_null("PortaoNorteEstrada") != null, "Possui Portão Norte para Estrada Real", "Portão Norte ausente")
		_assinalar(mapa.get_node_or_null("PortaoSulDungeon") != null, "Possui Portão Sul para Ruínas de Zaban (Dungeon)", "Portão Sul ausente")
		_assinalar(mapa.get_node_or_null("ArvoreMilenar") != null, "Possui Árvore Milenar Sagrada", "ArvoreMilenar ausente")
		_assinalar(mapa.get_node_or_null("KoObstacleFloresta") != null, "Possui Rocha Quebrável KoObstacle", "KoObstacle ausente")
		mapa.queue_free()

# ------------------------------------------------------------------------------
# TESTE 6: GAME FEEL, ATTACK DASH & VISUAL EFFECTS
# ------------------------------------------------------------------------------
func _teste_6_combat_dash_e_efeitos_visuais() -> void:
	print("\n[TESTE 6/6] Validando Game Feel (Aceleração, Dash Dust e Air Pressure Wave)...")
	var pl_scn = load("res://entities/Player/Player.tscn") as PackedScene
	if pl_scn:
		var pl = pl_scn.instantiate()
		add_child(pl)
		_assinalar(pl.get("_acceleration") == 0.30, "Aceleração responsiva marcial (_acceleration = 0.30)", "ACCELERATION incorreta")
		_assinalar(pl.get("_friction") == 0.35, "Fricção precisa e parada ágil sem patinar (_friction = 0.35)", "FRICTION incorreta")
		_assinalar(pl.get("attack_dash_speed") == 260.0, "Velocidade de avanço no ataque (attack_dash_speed = 260.0)", "Lunge incorreto")
		_assinalar(pl.get("attack_lunge_enabled") == true, "Avanço físico de golpe (Attack Lunge) habilitado", "Attack lunge desabilitado")

		# Testar AirPressureWave
		var wave_script = load("res://entities/effects/AirPressureWave.gd")
		_assinalar(wave_script != null, "AirPressureWave.gd existe", "AirPressureWave.gd ausente")
		if wave_script:
			var wave = wave_script.new()
			add_child(wave)
			wave.setup(Vector2.ZERO, Vector2.RIGHT, false)
			_assinalar(wave.direcao == Vector2.RIGHT, "AirPressureWave configurada para direção correta", "Direção incorreta")
			_assinalar(wave.duracao == 0.16, "Duração do corte de ar calibrada (0.16s)", "Duração incorreta")
			wave.queue_free()

		# Testar DashDustPuff
		var dust_script = load("res://entities/effects/DashDustPuff.gd")
		_assinalar(dust_script != null, "DashDustPuff.gd existe", "DashDustPuff.gd ausente")
		if dust_script:
			var dust = dust_script.new()
			add_child(dust)
			dust.setup(Vector2.ZERO, Vector2.DOWN)
			_assinalar(dust.sprite != null, "DashDustPuff cria Sprite2D com frames de poeira nos pés", "Sprite ausente")
			_assinalar(dust.duracao == 0.20, "Duração do puff de poeira calibrada (0.20s)", "Duração incorreta")
			dust.queue_free()

		pl.queue_free()