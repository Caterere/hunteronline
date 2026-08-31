class_name Lobby
extends Node2D

# ============================================================
# HUNTER ONLINE - CIDADE CENTRAL / HUNTER PLAZA (LOBBY HUB)
# ============================================================
#
# Mapa da Capital dos Caçadores com Distritos Massivos (2x Distância):
# - Praça Central (Spawn): Estátua de Netero, Elena, Instrutor, Quadro de Procurados.
# - Distrito dos Mestres (Norte Longínquo): Mestre Wing, Zushi, Biscuit, Mestre Alquimista.
# - Distrito Comercial & Bairro Residencial (Oeste Longínquo): Ferreiro, Mercador, Casa do Caçador.
# - Distrito Dimensional & Santuário Espiritual (Leste Longínquo): Portal Hunter, Chrono (PQs), Curador de Bestas de Nen, Torre Celestial.
# - NPCs Vivos com rotinas e nomes visíveis flutuando pelas grandes avenidas.
#
# ============================================================

const LivingNPCBehavior = preload("res://entities/npc/LivingNPCBehavior.gd")
const InteractionComponent = preload("res://entities/components/InteractionComponent.gd")


func _ready() -> void:
	if GameManager != null and not GameManager.can_enter_lobby():
		push_warning("[GameManager] ⚠️ ACESSO AO LOBBY BLOQUEADO: Nenhum personagem selecionado ou criado. Redirecionando para Seleção de Personagem.")
		get_tree().change_scene_to_file.call_deferred("res://ui/CharacterSelection/CharacterSelectionUI.tscn")
		return

	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.LOBBY)
		GameManager.change_state(GameManager.GameState.IN_GAME)

	if AudioManager != null:
		AudioManager.tocar_musica_lobby()

	# Customização visual do jogador
	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("_aplicar_customizacao_visual"):
		player._aplicar_customizacao_visual()

	_garantir_dialogue_ui()
	_garantir_binder_ui()
	_garantir_tutorial_ui()
	_garantir_spawn_points()
	_criar_chao_grama()
	_popular_praca_central()
	_popular_distrito_mestres()
	_popular_distrito_comercial()
	_popular_distrito_dimensional()
	_popular_faccoes_e_segredos()
	_popular_portao_mundo_exterior()

	# Fluxo de Início: Tutorial Inicial Guiado -> Conclusão -> Story Intro Tour
	if not PlayerData.tutorial_concluido:
		await get_tree().create_timer(0.6).timeout
		var elena = get_node_or_null("RecepcionistaElena") as NPC
		var ply = get_tree().get_first_node_in_group("player") as CharacterBody2D
		if elena != null and ply != null:
			elena._on_interacted(ply)
	elif not PlayerData.tour_lobby_concluido:
		await get_tree().create_timer(0.6).timeout
		var elena = get_node_or_null("RecepcionistaElena") as NPC
		var ply = get_tree().get_first_node_in_group("player") as CharacterBody2D
		if elena != null and ply != null:
			StoryCutsceneManager.executar_tour_lobby_cutscene(get_tree(), elena, ply)


func _garantir_tutorial_ui() -> void:
	var tut_ui = get_tree().get_first_node_in_group("tutorial_overlay_ui")
	if tut_ui == null:
		var scene = load("res://ui/Tutorial/TutorialOverlayUI.tscn")
		if scene:
			var ui = scene.instantiate()
			ui.add_to_group("tutorial_overlay_ui")
			add_child(ui)


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_binder_ui() -> void:
	if get_node_or_null("GreedIslandBinderUI") == null:
		var scn_binder = load("res://ui/GreedIslandBinder/GreedIslandBinderUI.gd")
		if scn_binder:
			var binder = scn_binder.new()
			binder.name = "GreedIslandBinderUI"
			add_child(binder)


# ============================================================
# 1. PRAÇA CENTRAL DA ASSOCIAÇÃO (SPAWN)
# ============================================================

func _popular_praca_central() -> void:
	# Recepcionista Elena
	if get_node_or_null("RecepcionistaElena") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var elena = scn_npc.instantiate()
			elena.name = "RecepcionistaElena"
			elena.set_script(load("res://entities/npc/recepcionista/RecepcionistaHunter.gd"))
			elena.position = Vector2(320, 0)
			
			var spr = elena.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 1
				spr.position = Vector2(0, -17)
				spr.modulate = Color(1.0, 0.85, 0.9, 1.0)
			add_child(elena)

	# Instrutor de Combate & Tutorial
	if get_node_or_null("InstrutorCombate") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var instrutor = scn_npc.instantiate()
			instrutor.name = "InstrutorCombate"
			instrutor.set_script(load("res://entities/npc/tutorial/CombatInstructorNPC.gd"))
			instrutor.position = Vector2(-320, 0)
			var spr = instrutor.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.4, 0.8, 1.0, 1.0)
			add_child(instrutor)

	# Estátua do 12º Presidente Isaac Netero
	if get_node_or_null("EstatuaNetero") == null:
		_criar_estatua_netero(Vector2(0, -280))

	# Quadro de Procurados (Bounties Board)
	if get_node_or_null("QuadroBounties") == null:
		_criar_quadro_bounties(Vector2(0, 300))


func _criar_estatua_netero(pos: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = "EstatuaNetero"
	body.position = pos
	body.set_script(load("res://entities/npc/estatua_netero/EstatuaNetero.gd"))
	
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/sprites/characters/player.png")
	spr.hframes = 6
	spr.vframes = 10
	spr.frame = 0
	spr.position = Vector2(0, -18)
	spr.scale = Vector2(1.2, 1.2)
	spr.modulate = Color(0.82, 0.78, 0.72, 1.0)
	body.add_child(spr)
	
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(18, 12)
	col.shape = rect
	col.position = Vector2(0, -4)
	body.add_child(col)

	var lbl := Label.new()
	lbl.text = "🏛️ Estátua de Netero"
	lbl.position = Vector2(-50, -32)
	lbl.custom_minimum_size = Vector2(100, 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	body.add_child(lbl)
	
	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Orar na Estátua de Netero"
	inter.interaction_radius = 18.0
	body.add_child(inter)
		
	add_child(body)


func _criar_quadro_bounties(pos: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = "QuadroBounties"
	body.position = pos
	body.set_script(load("res://entities/npc/bounties_board/QuadroBounties.gd"))
	
	var spr := Sprite2D.new()
	var tex = load("res://assets/sprites/tilesets/Pixel Art Top Down - Basic v1.2.3/Texture/TX Props.png")
	if tex:
		spr.texture = tex
		spr.region_enabled = true
		spr.region_rect = Rect2(96, 64, 32, 32)
	else:
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.modulate = Color(0.7, 0.5, 0.2, 1.0)
	spr.position = Vector2(0, -10)
	spr.scale = Vector2(0.8, 0.8)
	body.add_child(spr)
	
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 8)
	col.shape = rect
	body.add_child(col)

	var lbl := Label.new()
	lbl.text = "📜 Quadro de Procurados"
	lbl.position = Vector2(-50, -26)
	lbl.custom_minimum_size = Vector2(100, 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.7, 0.4))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	body.add_child(lbl)
	
	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Ver Quadro de Procurados"
	inter.interaction_radius = 18.0
	body.add_child(inter)
		
	add_child(body)


# ============================================================
# 2. DISTRITO DOS MESTRES DE NEN (NORTE LONGÍNQUO)
# ============================================================

func _popular_distrito_mestres() -> void:
	# Mestre Wing
	if get_node_or_null("Wing") == null:
		var scn_wing = load("res://entities/npc/wing/Wing.tscn")
		if scn_wing:
			var wing = scn_wing.instantiate()
			wing.name = "Wing"
			wing.position = Vector2(400, -640)
			add_child(wing)

	# Discípulo Zushi
	if get_node_or_null("Zushi") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var zushi = scn_npc.instantiate()
			zushi.name = "Zushi"
			zushi.set_script(load("res://entities/npc/zushi/Zushi.gd"))
			zushi.position = Vector2(640, -640)
			var spr = zushi.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(1.0, 0.95, 0.7, 1.0)
			add_child(zushi)

	# Biscuit Krueger (Hatsu & Vows)
	if get_node_or_null("Biscuit") == null:
		var scn_biscuit = load("res://entities/npc/biscuit/Biscuit.tscn")
		if scn_biscuit:
			var biscuit = scn_biscuit.instantiate()
			biscuit.name = "Biscuit"
			biscuit.position = Vector2(880, -640)
			add_child(biscuit)

	# Mestre Alquimista de Nen (Troca de Afinidade)
	if get_node_or_null("TrocaCategoriaNenNPC") == null:
		var scn_troca = load("res://entities/npc/troca_nen/TrocaCategoriaNenNPC.tscn")
		if scn_troca:
			var troca = scn_troca.instantiate()
			troca.name = "TrocaCategoriaNenNPC"
			troca.position = Vector2(1120, -640)
			add_child(troca)


# ============================================================
# 3. DISTRITO COMERCIAL & FORJA (OESTE LONGÍNQUO)
# ============================================================

func _popular_distrito_comercial() -> void:
	# Ferreiro de Equipamentos & Acessórios
	if get_node_or_null("Ferreiro") == null:
		var scn_ferreiro = load("res://entities/npc/ferreiro/Ferreiro.tscn")
		if scn_ferreiro:
			var ferreiro = scn_ferreiro.instantiate()
			ferreiro.name = "Ferreiro"
			ferreiro.position = Vector2(-640, -240)
			add_child(ferreiro)

	# Vendedor / Mercador de Suprimentos Hunter
	if get_node_or_null("Vendedor") == null:
		var scn_vendedor = load("res://entities/npc/vendedor/Vendedor.tscn")
		if scn_vendedor:
			var vendedor = scn_vendedor.instantiate()
			vendedor.name = "Vendedor"
			vendedor.position = Vector2(-640, 240)
			add_child(vendedor)


# ============================================================
# 4. DISTRITO DIMENSIONAL & SANTUÁRIO ESPIRITUAL (LESTE LONGÍNQUO)
# ============================================================

func _popular_distrito_dimensional() -> void:
	# Portal Hunter (Viagem para os 9 Arcos do Modo História)
	var portal = get_node_or_null("PortalHunter")
	if portal != null:
		portal.position = Vector2(560, 440)

	# Examinador Chrono (Fendas Temporais - 50 Missões Paralelas)
	var pq_npc = get_node_or_null("ParallelQuestNPC")
	if pq_npc != null:
		pq_npc.position = Vector2(840, 440)

	# Curador das Bestas de Nen (Santuário & Catálogo)
	if get_node_or_null("CuradorBestasNen") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var curador = scn_npc.instantiate()
			curador.name = "CuradorBestasNen"
			curador.set_script(load("res://entities/npc/curador_besta/NenBeastHandlerNPC.gd"))
			curador.position = Vector2(1120, 440)
			var spr = curador.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.85, 0.4, 1.0, 1.0)
			add_child(curador)

	_popular_bairro_residencial()
	_popular_torre_celestial()
	_popular_npcs_vivos()


# ============================================================
# 5. BAIRRO RESIDENCIAL (CASA DO JOGADOR - OESTE LONGÍNQUO)
# ============================================================

func _popular_bairro_residencial() -> void:
	if get_node_or_null("PortaCasaJogador") != null:
		return

	var body := StaticBody2D.new()
	body.name = "PortaCasaJogador"
	body.position = Vector2(-1040, 0)

	var spr := Sprite2D.new()
	spr.texture = load("res://assets/sprites/characters/player.png")
	spr.hframes = 6
	spr.vframes = 10
	spr.frame = 0
	spr.position = Vector2(0, -17)
	spr.modulate = Color(0.2, 0.8, 0.4, 1.0)
	body.add_child(spr)

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(18, 14)
	col.shape = box
	body.add_child(col)

	var lbl := Label.new()
	lbl.text = "🏠 Casa do Caçador\n[E] Entrar"
	lbl.position = Vector2(-50, -32)
	lbl.custom_minimum_size = Vector2(100, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	body.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Entrar na Casa"
	inter.interaction_radius = 20.0
	inter.interacted.connect(func(_player):
		var trans = get_node_or_null("/root/SceneTransition")
		if trans != null and trans.has_method("mudar_cena"):
			trans.mudar_cena("res://world/maps/PlayerHouse.tscn", "Residência Pessoal", "Distrito Residencial — Hunter Plaza")
		else:
			get_tree().change_scene_to_file("res://world/maps/PlayerHouse.tscn")
	)
	body.add_child(inter)

	add_child(body)


# ============================================================
# 6. DISTRITO DA TORRE CELESTIAL (LESTE LONGÍNQUO)
# ============================================================

func _popular_torre_celestial() -> void:
	if get_node_or_null("PortalTorreCelestial") != null:
		return

	var body := StaticBody2D.new()
	body.name = "PortalTorreCelestial"
	body.position = Vector2(1400, 0)

	var spr := Sprite2D.new()
	spr.texture = load("res://assets/sprites/characters/player.png")
	spr.hframes = 6
	spr.vframes = 10
	spr.frame = 0
	spr.position = Vector2(0, -17)
	spr.modulate = Color(1.0, 0.8, 0.2, 1.0)
	body.add_child(spr)

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(18, 14)
	col.shape = box
	body.add_child(col)

	var lbl := Label.new()
	lbl.text = "🏯 Torre Celestial\n[E] Entrar no Elevador"
	lbl.position = Vector2(-60, -32)
	lbl.custom_minimum_size = Vector2(120, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	body.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Entrar na Torre Celestial"
	inter.interaction_radius = 20.0
	inter.interacted.connect(func(_player):
		var trans = get_node_or_null("/root/SceneTransition")
		if trans != null and trans.has_method("mudar_cena"):
			trans.mudar_cena("res://world/maps/CelestialTowerArena.tscn", "Torre Celestial (200 Andares)", "Desafio Solo & Batalha dos Mestres")
		else:
			get_tree().change_scene_to_file("res://world/maps/CelestialTowerArena.tscn")
	)

	body.add_child(inter)

	add_child(body)


# ============================================================
# 7. NPCS VIVOS COM ROTINA NA CIDADE
# ============================================================

func _popular_npcs_vivos() -> void:
	var posicoes = [
		Vector2(-360, 480),
		Vector2(360, -360),
		Vector2(720, 0)
	]
	var nomes = ["Cidadão Hunter", "Mercador Viajante", "Aspirante a Hunter"]

	for i in range(posicoes.size()):
		var n_name = "LivingNPC_%d" % i
		if get_node_or_null(n_name) != null:
			continue

		var body := CharacterBody2D.new()
		body.name = n_name
		body.position = posicoes[i]

		var col := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(16, 24)
		col.shape = box
		body.add_child(col)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.position = Vector2(0, -17)
		spr.modulate = Color(0.7 + i * 0.1, 0.8, 0.9, 0.9)
		body.add_child(spr)

		var living := LivingNPCBehavior.new()
		living.npc_nome = nomes[i]
		body.add_child(living)

		add_child(body)


# ============================================================
# 8. NPCS DE FACÇÕES, GUILDAS E MISSÕES SECRETAS
# ============================================================

func _popular_faccoes_e_segredos() -> void:
	# 1. Chrollo Lucilfer (Genei Ryodan / Trupe Fantasma - Leste Sombrio)
	if get_node_or_null("Chrollo") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var chrollo = scn_npc.instantiate()
			chrollo.name = "Chrollo"
			chrollo.set_script(load("res://entities/npc/chrollo/Chrollo.gd"))
			chrollo.position = Vector2(700, 600)
			var spr = chrollo.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.4, 0.1, 0.6, 1.0)
			add_child(chrollo)

	# 2. Kurapika (Caçadores da Lista Negra & Bounties - Praça Central)
	if get_node_or_null("Kurapika") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var kurapika = scn_npc.instantiate()
			kurapika.name = "Kurapika"
			kurapika.set_script(load("res://entities/npc/kurapika/Kurapika.gd"))
			kurapika.position = Vector2(180, 260)
			var spr = kurapika.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(1.0, 0.3, 0.3, 1.0)
			add_child(kurapika)

	# 3. Tonpa (O Esmaga-Novatos & Suco Batizado - Entrada da Praça)
	if get_node_or_null("Tonpa") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var tonpa = scn_npc.instantiate()
			tonpa.name = "Tonpa"
			tonpa.set_script(load("res://entities/npc/tonpa/Tonpa.gd"))
			tonpa.position = Vector2(-180, 100)
			var spr = tonpa.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(1.0, 0.7, 0.2, 1.0)
			add_child(tonpa)

	# 4. Hisoka Morow (O Mágico & Bungee Gum - Leste/Nordeste)
	if get_node_or_null("Hisoka") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var hisoka = scn_npc.instantiate()
			hisoka.name = "Hisoka"
			hisoka.set_script(load("res://entities/npc/hisoka/Hisoka.gd"))
			hisoka.position = Vector2(950, 200)
			var spr = hisoka.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.9, 0.1, 0.5, 1.0)
			add_child(hisoka)

	# 5. Menchi (Guilda dos Hunters Gourmet - Distrito Comercial Oeste)
	if get_node_or_null("Menchi") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var menchi = scn_npc.instantiate()
			menchi.name = "Menchi"
			menchi.set_script(load("res://entities/npc/gourmet/Menchi.gd"))
			menchi.position = Vector2(-800, 360)
			var spr = menchi.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.9, 0.3, 0.5, 1.0)
			add_child(menchi)
# ============================================================
# 9. SPAWN POINTS & PORTÃO DE SAÍDA PARA O MUNDO EXTERIOR
# ============================================================

func _garantir_spawn_points() -> void:
	if get_node_or_null("SpawnDefault") == null:
		var sp_default := SpawnPoint.new()
		sp_default.name = "SpawnDefault"
		sp_default.spawn_id = &"default"
		sp_default.is_default_spawn = true
		sp_default.position = Vector2(0, 0)
		add_child(sp_default)

	if get_node_or_null("SpawnFromWorld") == null:
		var sp_world := SpawnPoint.new()
		sp_world.name = "SpawnFromWorld"
		sp_world.spawn_id = &"from_world"
		sp_world.is_default_spawn = false
		sp_world.position = Vector2(0, 420)
		add_child(sp_world)


func _popular_portao_mundo_exterior() -> void:
	if get_node_or_null("PortaoMundoExterior") != null:
		return

	var portao := MapTransitionArea.new()
	portao.name = "PortaoMundoExterior"
	portao.position = Vector2(0, 480)
	portao.portal_name = "Rota do 287º Exame Hunter"
	portao.map_subtitle = "287º Exame Hunter — Início da Jornada"
	portao.target_scene_path = "res://world/maps/exame_maratona.tscn"
	portao.target_spawn_id = &"default"
	portao.requires_e_key = true

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(60, 24)
	col.shape = box
	portao.add_child(col)

	var spr := Sprite2D.new()
	spr.texture = load("res://assets/sprites/characters/player.png")
	spr.hframes = 6
	spr.vframes = 10
	spr.frame = 0
	spr.position = Vector2(0, -14)
	spr.scale = Vector2(1.5, 1.2)
	spr.modulate = Color(0.2, 0.9, 0.5, 0.9)
	portao.add_child(spr)

	add_child(portao)


func _criar_chao_grama() -> void:
	if get_node_or_null("ChaoGramaLobby") != null:
		return

	var tex = load("res://assets/sprites/tilesets/grass.png") as Texture2D
	if tex == null:
		return

	var spr := Sprite2D.new()
	spr.name = "ChaoGramaLobby"
	spr.texture = tex
	spr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	spr.region_enabled = true
	spr.region_rect = Rect2(-4000.0, -4000.0, 14000.0, 10000.0)
	spr.position = Vector2(1500.0, 400.0)
	spr.z_index = -100
	add_child(spr)
	move_child(spr, 0)
