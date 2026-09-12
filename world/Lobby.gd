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
# - Distrito Dimensional & Santuário Espiritual (Leste Longínquo): Chrono (PQs), Curador de Bestas de Nen, Torre Celestial.
# - Continuidade da história: Guia da História (StoryGatewayNPC) na praça — teleporta ao checkpoint da missão atual.
# - NPCs Vivos com rotinas e nomes visíveis flutuando pelas grandes avenidas.
#
# ============================================================

const LivingNPCBehavior = preload("res://entities/npc/LivingNPCBehavior.gd")
const InteractionComponent = preload("res://entities/components/InteractionComponent.gd")
const NPCScheduleDataScript = preload("res://world/content/NPCScheduleData.gd")


func _ready() -> void:
	if GameManager != null and not GameManager.can_enter_lobby():
		if OS.is_debug_build():
			# Modo Debug/Editor: Inicializa caçador padrão automaticamente para permitir F6 direto no Lobby
			if PlayerData != null:
				PlayerData.is_character_ready = true
				if PlayerData.nome_personagem.is_empty():
					PlayerData.nome_personagem = "Hunter"
				if not PlayerData.attributes.has("vida"):
					PlayerData.attributes = {
						"vida": 100, "vida_max": 100,
						"forca": 10, "defesa": 10, "velocidade": 10,
						"aura": 100.0, "aura_max": 100.0,
						"nivel_nen": 1, "xp_nen": 0, "nivel": 1, "gold": 100
					}
			if GameManager != null:
				GameManager.set_flow_state(GameManager.GameFlowState.LOBBY)
				GameManager.change_state(GameManager.GameState.IN_GAME)
		else:
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
	_aplicar_grama_mais_verde()
	_suavizar_fachadas_castelo()
	_densificar_lobby_pixel_art()
	_melhorar_estradas_lobby()
	_popular_praca_central()
	_popular_distrito_mestres()
	_popular_distrito_comercial()
	_popular_distrito_dimensional()
	_popular_faccoes_e_segredos()
	_popular_portao_mundo_exterior()
	_configurar_limites_camera()
	_criar_limites_do_mapa()

	# Fluxo de Início: apenas quando o Lobby é a cena principal em execução
	if get_tree().current_scene == self:
		if not PlayerData.tutorial_concluido and not PlayerData.quest_states.get("tutorial_elena_auto_iniciado", false):
			PlayerData.quest_states["tutorial_elena_auto_iniciado"] = true
			await get_tree().create_timer(0.8).timeout
			var elena = get_node_or_null("RecepcionistaElena") as NPC
			var ply = get_tree().get_first_node_in_group("player") as CharacterBody2D
			if elena != null and ply != null and not elena._interacao_em_processamento:
				elena._on_interacted(ply)
		elif PlayerData.tutorial_concluido and not PlayerData.tour_lobby_concluido and not PlayerData.quest_states.get("tour_lobby_auto_iniciado", false):
			PlayerData.quest_states["tour_lobby_auto_iniciado"] = true
			await get_tree().create_timer(0.8).timeout
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
			elena.position = Vector2(110, -20)
			
			var spr = elena.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/npc_recepcionista_elena_8dir.png")
				spr.hframes = 8
				spr.vframes = 1
				spr.frame = 0
				spr.scale = Vector2(1.0, 1.0)
				spr.position = Vector2(0, -18)
				spr.modulate = Color.WHITE
			add_child(elena)

	# Instrutor de Combate & Tutorial
	if get_node_or_null("InstrutorCombate") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var instrutor = scn_npc.instantiate()
			instrutor.name = "InstrutorCombate"
			instrutor.set_script(load("res://entities/npc/tutorial/CombatInstructorNPC.gd"))
			instrutor.position = Vector2(-110, -20)
			var spr = instrutor.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/npc_instrutor_combate_8dir.png")
				spr.hframes = 8
				spr.vframes = 1
				spr.frame = 0
				spr.scale = Vector2(1.0, 1.0)
				spr.position = Vector2(0, -18)
				spr.modulate = Color.WHITE
			add_child(instrutor)

	# Guia da História (Story Gateway NPC / Examinador Oficial)
	if get_node_or_null("StoryGatewayNPC") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var guia = scn_npc.instantiate()
			guia.name = "StoryGatewayNPC"
			guia.set_script(load("res://entities/npc/story_gateway/StoryGatewayNPC.gd"))
			guia.position = Vector2(0, -90)
			var spr = guia.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/npc_examinador_oficial_8dir.png")
				spr.hframes = 8
				spr.vframes = 1
				spr.frame = 0
				spr.scale = Vector2(1.0, 1.0)
				spr.position = Vector2(0, -18)
				spr.modulate = Color.WHITE
			add_child(guia)

	# Estátua do 12º Presidente Isaac Netero
	if get_node_or_null("EstatuaNetero") == null:
		_criar_estatua_netero(Vector2(0, -260))

	# Quadro de Procurados (Bounties Board)
	if get_node_or_null("QuadroBounties") == null:
		_criar_quadro_bounties(Vector2(-60, 70))


func _criar_estatua_netero(pos: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = "EstatuaNetero"
	body.position = pos
	body.y_sort_enabled = true
	body.set_script(load("res://entities/npc/estatua_netero/EstatuaNetero.gd"))
	
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/sprites/objects/estatua_netero_monument.png")
	spr.hframes = 1
	spr.vframes = 1
	spr.position = Vector2(0, -44)
	spr.modulate = Color.WHITE
	body.add_child(spr)
	
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(36, 16)
	col.shape = rect
	col.position = Vector2(0, -8)
	body.add_child(col)

	var lbl := Label.new()
	lbl.text = "🏛️ Estátua de Netero"
	lbl.position = Vector2(-70, -96)
	lbl.custom_minimum_size = Vector2(140, 16)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(1.0, 0.9, 0.5))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	body.add_child(lbl)
	
	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Orar na Estátua de Netero"
	inter.interaction_radius = 28.0
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
	spr.position = Vector2(0, -12)
	body.add_child(spr)
	
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 6)
	col.shape = rect
	col.position = Vector2(0, -2)
	body.add_child(col)

	var lbl := Label.new()
	lbl.text = "📜 Quadro de Procurados"
	lbl.position = Vector2(-60, -28)
	lbl.custom_minimum_size = Vector2(120, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(1.0, 0.7, 0.4))
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
			wing.position = Vector2(200, -420)
			add_child(wing)

	# Discípulo Zushi
	if get_node_or_null("Zushi") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var zushi = scn_npc.instantiate()
			zushi.name = "Zushi"
			zushi.set_script(load("res://entities/npc/zushi/Zushi.gd"))
			zushi.position = Vector2(260, -420)
			var spr = zushi.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/npc_discipulo_zushi_8dir.png")
				spr.hframes = 8
				spr.vframes = 1
				spr.frame = 0
				spr.scale = Vector2(1.0, 1.0)
				spr.position = Vector2(0, -18)
				spr.modulate = Color.WHITE
			add_child(zushi)

	# Boneco de Treino de Artes Marciais (Wing Chun Sparring Dummy)
	if get_node_or_null("BonecoTreinoDojo") == null:
		var dummy := StaticBody2D.new()
		dummy.name = "BonecoTreinoDojo"
		dummy.position = Vector2(230, -450)
		dummy.y_sort_enabled = true
		
		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/objects/boneco_treino_dummy.png")
		spr.scale = Vector2(0.52, 0.52)
		spr.position = Vector2(0, -10)
		dummy.add_child(spr)
		
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(14, 8)
		col.shape = rect
		col.position = Vector2(0, -4)
		dummy.add_child(col)
		
		var lbl := Label.new()
		lbl.text = "🥋 Boneco de Treino"
		lbl.position = Vector2(-50, -48)
		lbl.custom_minimum_size = Vector2(100, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(1.0, 0.85, 0.4))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		dummy.add_child(lbl)
		
		add_child(dummy)

	# Biscuit Krueger (Hatsu & Vows)
	if get_node_or_null("Biscuit") == null:
		var scn_biscuit = load("res://entities/npc/biscuit/Biscuit.tscn")
		if scn_biscuit:
			var biscuit = scn_biscuit.instantiate()
			biscuit.name = "Biscuit"
			biscuit.position = Vector2(340, -420)
			add_child(biscuit)

	# Mestre Alquimista de Nen (Troca de Afinidade)
	if get_node_or_null("TrocaCategoriaNenNPC") == null:
		var scn_troca = load("res://entities/npc/troca_nen/TrocaCategoriaNenNPC.tscn")
		if scn_troca:
			var troca = scn_troca.instantiate()
			troca.name = "TrocaCategoriaNenNPC"
			troca.position = Vector2(420, -420)
			add_child(troca)


# ============================================================
# 3. DISTRITO COMERCIAL & FORJA (OESTE)
# ============================================================

func _popular_distrito_comercial() -> void:
	# 1. Forja & Oficina do Ferreiro (Landmark)
	if get_node_or_null("ForjaFerreiroWorkshop") == null:
		var forge := StaticBody2D.new()
		forge.name = "ForjaFerreiroWorkshop"
		forge.position = Vector2(-360, -140)
		forge.y_sort_enabled = true
		
		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/objects/forja_ferreiro_workshop.png")
		spr.position = Vector2(0, -26)
		forge.add_child(spr)
		
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(40, 24)
		col.shape = rect
		col.position = Vector2(0, -12)
		forge.add_child(col)
		
		add_child(forge)

	# Ferreiro de Equipamentos & Acessórios
	if get_node_or_null("Ferreiro") == null:
		var scn_ferreiro = load("res://entities/npc/ferreiro/Ferreiro.tscn")
		if scn_ferreiro:
			var ferreiro = scn_ferreiro.instantiate()
			ferreiro.name = "Ferreiro"
			ferreiro.position = Vector2(-320, -140)
			add_child(ferreiro)
			_anexar_rotina_comercial(ferreiro, "Ferreiro Duran", Vector2(-320, -140), Vector2(60, 80), "blacksmith")

	# 2. Tenda do Mercador Hunter (Landmark)
	if get_node_or_null("TendaMercadorStall") == null:
		var stall := StaticBody2D.new()
		stall.name = "TendaMercadorStall"
		stall.position = Vector2(-240, -140)
		stall.y_sort_enabled = true
		
		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/objects/tenda_mercador_stall.png")
		spr.position = Vector2(0, -26)
		stall.add_child(spr)
		
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(42, 22)
		col.shape = rect
		col.position = Vector2(0, -10)
		stall.add_child(col)
		
		add_child(stall)

	# Vendedor / Mercador de Suprimentos Hunter
	if get_node_or_null("Vendedor") == null:
		var scn_vendedor = load("res://entities/npc/vendedor/Vendedor.tscn")
		if scn_vendedor:
			var vendedor = scn_vendedor.instantiate()
			vendedor.name = "Vendedor"
			vendedor.position = Vector2(-200, -140)
			add_child(vendedor)
			_anexar_rotina_comercial(vendedor, "Mercador Zael", Vector2(-200, -140), Vector2(100, 90), "merchant")


func _anexar_rotina_comercial(npc: Node, nome: String, work: Vector2, tavern: Vector2, marcador: String) -> void:
	if npc == null:
		return
	if npc.get_node_or_null("LivingNPCBehavior") != null:
		return
	var living := LivingNPCBehavior.new()
	living.name = "LivingNPCBehavior"
	living.npc_nome = nome
	living.tipo_marcador = marcador
	living.hierarchy = LivingNPCBehavior.NPCHierarchy.FUNCTIONAL
	living.raio_patrulha = 36.0
	var sched = NPCScheduleDataScript.new()
	sched.npc_name = nome
	sched.workplace_pos = work
	sched.home_pos = tavern # Praça / "taverna" improvisada à noite
	sched.patrol_route = [work + Vector2(40, 0), work + Vector2(-20, 30), tavern]
	sched.move_speed = 22.0
	living.schedule_data = sched
	npc.add_child(living)


# ============================================================
# 4. DISTRITO DIMENSIONAL & SANTUÁRIO ESPIRITUAL (LESTE LONGÍNQUO)
# ============================================================


func _remover_portal_historia_legado() -> void:
	# Remove de vez o Portal Hunter / Portal da Missão (seletor e landmark).
	for nome in ["PortalHunter", "PortalHunter_LEGACY_REMOVING", "PortalDaMissao"]:
		var n = get_node_or_null(nome)
		if n != null:
			n.name = nome + "_REMOVING"
			n.queue_free()
	# Também remove UI legado se ainda estiver na árvore
	var ui = get_tree().root.get_node_or_null("PortalHunterUI") if get_tree() != null else null
	if ui != null:
		ui.queue_free()


func _popular_distrito_dimensional() -> void:
	# Portal Hunter / Portal da Missão removidos — continuidade só via StoryGatewayNPC.
	_remover_portal_historia_legado()

	# Examinador Chrono (Fendas Temporais - 50 Missões Paralelas)
	var pq_npc = get_node_or_null("ParallelQuestNPC")
	if pq_npc != null:
		pq_npc.position = Vector2(1080, 40)

	# Curador das Bestas de Nen (Santuário & Catálogo)
	if get_node_or_null("CuradorBestasNen") == null:
		var scn_npc = load("res://entities/npc/NPC.tscn")
		if scn_npc:
			var curador = scn_npc.instantiate()
			curador.name = "CuradorBestasNen"
			curador.set_script(load("res://entities/npc/curador_besta/NenBeastHandlerNPC.gd"))
			curador.position = Vector2(440, 80)
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
# 5. BAIRRO RESIDENCIAL (CASA DO JOGADOR - OESTE)
# ============================================================

func _popular_bairro_residencial() -> void:
	if get_node_or_null("PortaCasaJogador") != null:
		return

	var body := StaticBody2D.new()
	body.name = "PortaCasaJogador"
	body.position = Vector2(-480, 0)
	body.y_sort_enabled = true

	var spr := Sprite2D.new()
	spr.texture = load("res://assets/sprites/objects/casa_cacador_facade.png")
	spr.hframes = 1
	spr.vframes = 1
	spr.position = Vector2(0, -26)
	spr.modulate = Color.WHITE
	body.add_child(spr)

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(44, 20)
	col.shape = box
	col.position = Vector2(0, -14)
	body.add_child(col)

	var lbl := Label.new()
	lbl.text = "🏠 Casa do Caçador\n[E] Entrar"
	lbl.position = Vector2(-60, -66)
	lbl.custom_minimum_size = Vector2(120, 16)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(0.4, 1.0, 0.6))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	body.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Entrar na Casa"
	inter.interaction_radius = 28.0
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
# 6. DISTRITO DA TORRE CELESTIAL (LESTE)
# ============================================================

func _popular_torre_celestial() -> void:
	if get_node_or_null("PortalTorreCelestial") != null:
		return

	var body := StaticBody2D.new()
	body.name = "PortalTorreCelestial"
	body.position = Vector2(560, 0)

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
	lbl.position = Vector2(-70, -34)
	lbl.custom_minimum_size = Vector2(140, 16)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 7, Color(1.0, 0.85, 0.3))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	body.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Entrar na Torre Celestial"
	inter.interaction_radius = 20.0
	inter.interacted.connect(func(_player):
		if PlayerData != null:
			PlayerData.attributes["torre_cena_retorno"] = "res://world/lobby.tscn"
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
		body.collision_layer = 8
		body.collision_mask = 1

		var col := CollisionShape2D.new()
		var circ := CircleShape2D.new()
		circ.radius = 6.0
		col.shape = circ
		col.position = Vector2(0, -3)
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
	portao.portal_name = "Estrada Real de Padokia (Mundo Exterior)"
	portao.map_subtitle = "Caminho dos Caçadores — Conexão para a Floresta dos Vestígios"
	portao.target_scene_path = "res://world/maps/estrada_padokia.tscn"
	portao.target_spawn_id = &"from_lobby"
	portao.requires_e_key = true

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(32, 16)
	col.shape = box
	col.position = Vector2(0, 0)
	portao.add_child(col)

	var spr := Sprite2D.new()
	spr.texture = load("res://assets/sprites/objects/portao_padokia_arch.png")
	spr.hframes = 1
	spr.vframes = 1
	spr.position = Vector2(0, -28)
	spr.modulate = Color.WHITE
	portao.add_child(spr)

	# Pilares de pedra sólidos nas laterais do arco (passagem livre no centro)
	var pilares := StaticBody2D.new()
	pilares.name = "PortaoPilaresColisao"
	pilares.collision_layer = 1
	pilares.collision_mask = 0

	var col_esq := CollisionShape2D.new()
	var rect_esq := RectangleShape2D.new()
	rect_esq.size = Vector2(14, 16)
	col_esq.shape = rect_esq
	col_esq.position = Vector2(-24, -8)
	pilares.add_child(col_esq)

	var col_dir := CollisionShape2D.new()
	var rect_dir := RectangleShape2D.new()
	rect_dir.size = Vector2(14, 16)
	col_dir.shape = rect_dir
	col_dir.position = Vector2(24, -8)
	pilares.add_child(col_dir)

	portao.add_child(pilares)
	add_child(portao)


func _criar_chao_grama() -> void:
	# O terreno, estradas e estruturas do Lobby são renderizados pelas camadas
	# TileMapLayer nativas (Chao, Caminhos, Praca, Estruturas, Decor) configuradas em world/lobby.tscn
	var old_chao = get_node_or_null("ChaoGramaLobby")
	if old_chao != null:
		old_chao.queue_free()


func _aplicar_grama_mais_verde() -> void:
	# Referência visual: grama saturada (menos amarelada) como no print de floresta densificada
	var chao := get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	if chao != null:
		chao.modulate = Color(0.72, 1.12, 0.82, 1.0)
	var decor := get_node_or_null("Decor_TileMapLayer") as TileMapLayer
	if decor != null:
		decor.modulate = Color(0.85, 1.08, 0.90, 1.0)


func _suavizar_fachadas_castelo() -> void:
	# Remove fachadas castelo/torre/mosteiro (sources 10/11/14) — só decorações PixelLab
	var estruturas := get_node_or_null("Estruturas_TileMapLayer") as TileMapLayer
	if estruturas == null:
		return
	var remover := {10: true, 11: true, 14: true}
	for cell in estruturas.get_used_cells():
		var sid := estruturas.get_cell_source_id(cell)
		if remover.has(sid):
			estruturas.erase_cell(cell)
	estruturas.modulate = Color(0.95, 1.02, 0.92, 1.0)

func _densificar_lobby_pixel_art() -> void:
	if get_node_or_null("LobbyPixelDecorRoot") != null:
		return
	var root := Node2D.new()
	root.name = "LobbyPixelDecorRoot"
	root.y_sort_enabled = true
	add_child(root)

	# Densidade estilo MMORPG 2D: bordas de praça/distritos, sem bloquear spawn (~0,0) nem portais.
	var placements: Array = [
		{"tex": "res://assets/sprites/objects/lobby_tent_decor.png", "pos": Vector2(-180, 40), "name": "TendaDecorA"},
		{"tex": "res://assets/sprites/objects/lobby_tent_decor.png", "pos": Vector2(200, 90), "name": "TendaDecorB"},
		{"tex": "res://assets/sprites/objects/lobby_tent_decor.png", "pos": Vector2(-320, -80), "name": "TendaDecorC"},
		{"tex": "res://assets/sprites/objects/lobby_cottage_decor.png", "pos": Vector2(-420, 120), "name": "CasinhaDecorA"},
		{"tex": "res://assets/sprites/objects/lobby_cottage_decor.png", "pos": Vector2(480, -40), "name": "CasinhaDecorB"},
		{"tex": "res://assets/sprites/objects/lobby_cottage_decor.png", "pos": Vector2(-90, 200), "name": "CasinhaDecorC"},
		{"tex": "res://assets/sprites/objects/lobby_stall_decor.png", "pos": Vector2(90, 130), "name": "BarracaDecorA"},
		{"tex": "res://assets/sprites/objects/lobby_stall_decor.png", "pos": Vector2(-250, 160), "name": "BarracaDecorB"},
		{"tex": "res://assets/sprites/objects/lobby_stall_decor.png", "pos": Vector2(280, -160), "name": "BarracaDecorC"},
		{"tex": "res://assets/sprites/objects/lobby_cottage_decor.png", "pos": Vector2(1100, -80), "name": "CasinhaDecorLesteA"},
		{"tex": "res://assets/sprites/objects/lobby_cottage_decor.png", "pos": Vector2(1240, 60), "name": "CasinhaDecorLesteB"},
		{"tex": "res://assets/sprites/objects/lobby_tent_decor.png", "pos": Vector2(1050, -120), "name": "TendaDecorLeste"},
		{"tex": "res://assets/sprites/objects/lobby_stall_decor.png", "pos": Vector2(1000, 20), "name": "BarracaDecorLeste"},
		# Distrito comercial (oeste) — caixas/barris/placas
		{"tex": "res://assets/sprites/objects/phase3_crate.png", "pos": Vector2(-360, 90), "name": "CaixaComercialA", "foot": Vector2(14, 8)},
		{"tex": "res://assets/sprites/objects/phase3_crate_large.png", "pos": Vector2(-390, 115), "name": "CaixaComercialB", "foot": Vector2(18, 10)},
		{"tex": "res://assets/sprites/objects/phase3_barrel.png", "pos": Vector2(-330, 140), "name": "BarrilComercialA", "foot": Vector2(12, 8)},
		{"tex": "res://assets/sprites/objects/phase3_barrel.png", "pos": Vector2(-300, 95), "name": "BarrilComercialB", "foot": Vector2(12, 8)},
		{"tex": "res://assets/sprites/objects/phase3_signpost.png", "pos": Vector2(-210, 70), "name": "PlacaComercial", "foot": Vector2(10, 8)},
		{"tex": "res://assets/sprites/objects/phase3_lantern_post.png", "pos": Vector2(-280, 50), "name": "LanternaComercial", "foot": Vector2(8, 8)},
		{"tex": "res://assets/sprites/objects/phase3_well.png", "pos": Vector2(-150, 175), "name": "PocoPraca", "foot": Vector2(22, 12)},
		# Distrito mestres (norte) — vegetação
		{"tex": "res://assets/sprites/objects/phase2_tree_green_a.png", "pos": Vector2(-120, -240), "name": "ArvoreMestresA", "foot": Vector2(16, 10)},
		{"tex": "res://assets/sprites/objects/phase2_tree_green_b.png", "pos": Vector2(80, -260), "name": "ArvoreMestresB", "foot": Vector2(16, 10)},
		{"tex": "res://assets/sprites/objects/phase2_tree_autumn_a.png", "pos": Vector2(200, -220), "name": "ArvoreMestresC", "foot": Vector2(16, 10)},
		{"tex": "res://assets/sprites/objects/phase2_stump.png", "pos": Vector2(-40, -200), "name": "TocoMestres", "foot": Vector2(12, 8)},
		{"tex": "res://assets/sprites/objects/phase2_bush_berry.png", "pos": Vector2(40, -180), "name": "ArbustoMestresA", "foot": Vector2(12, 8)},
		{"tex": "res://assets/sprites/objects/phase2_bush_round.png", "pos": Vector2(160, -190), "name": "ArbustoMestresB", "foot": Vector2(12, 8)},
		{"tex": "res://assets/sprites/objects/phase3_lantern_post.png", "pos": Vector2(0, -170), "name": "LanternaMestres", "foot": Vector2(8, 8)},
		# Beiras da praça / caminhos
		{"tex": "res://assets/sprites/objects/phase2_flowers_white.png", "pos": Vector2(-70, 85), "name": "FlorPracaA", "foot": Vector2(8, 6)},
		{"tex": "res://assets/sprites/objects/phase2_flowers_white.png", "pos": Vector2(75, 70), "name": "FlorPracaB", "foot": Vector2(8, 6)},
		{"tex": "res://assets/sprites/objects/phase2_rock_cluster.png", "pos": Vector2(240, 40), "name": "PedrasPraca", "foot": Vector2(14, 8)},
		{"tex": "res://assets/sprites/objects/phase2_rock_boulder.png", "pos": Vector2(-260, -40), "name": "PedraGrandeOeste", "foot": Vector2(18, 10)},
		{"tex": "res://assets/sprites/objects/phase3_fence_wood.png", "pos": Vector2(320, 120), "name": "CercaSulA", "foot": Vector2(20, 8)},
		{"tex": "res://assets/sprites/objects/phase3_fence_wood_post.png", "pos": Vector2(350, 120), "name": "CercaSulPoste", "foot": Vector2(8, 8)},
		# Portão sul → Estrada (handoff visual)
		{"tex": "res://assets/sprites/objects/phase3_signpost.png", "pos": Vector2(-40, 280), "name": "PlacaPortaoSul", "foot": Vector2(10, 8)},
		{"tex": "res://assets/sprites/objects/phase3_lantern_post.png", "pos": Vector2(-70, 300), "name": "LanternaPortaoL", "foot": Vector2(8, 8)},
		{"tex": "res://assets/sprites/objects/phase3_lantern_post.png", "pos": Vector2(70, 300), "name": "LanternaPortaoR", "foot": Vector2(8, 8)},
		{"tex": "res://assets/sprites/objects/phase3_crate.png", "pos": Vector2(95, 270), "name": "CaixaPortao", "foot": Vector2(14, 8)},
		{"tex": "res://assets/sprites/objects/lobby_stall_decor.png", "pos": Vector2(-140, 250), "name": "BarracaPortao"},
		# Leste / residencial fill
		{"tex": "res://assets/sprites/objects/phase2_tree_green_a.png", "pos": Vector2(1180, -160), "name": "ArvoreLesteA", "foot": Vector2(16, 10)},
		{"tex": "res://assets/sprites/objects/phase2_bush_berry.png", "pos": Vector2(1080, 80), "name": "ArbustoLeste", "foot": Vector2(12, 8)},
		{"tex": "res://assets/sprites/objects/phase3_barrel.png", "pos": Vector2(1020, -40), "name": "BarrilLeste", "foot": Vector2(12, 8)},
		{"tex": "res://assets/sprites/objects/phase3_fence_wood.png", "pos": Vector2(960, 100), "name": "CercaLeste", "foot": Vector2(20, 8)},
	]


	if ResourceLoader.exists("res://assets/sprites/objects/lobby_bush_flowers_decor.png"):
		placements.append_array([
			{"tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "pos": Vector2(-60, 50), "name": "ArbustoFlorA"},
			{"tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "pos": Vector2(140, -50), "name": "ArbustoFlorB"},
			{"tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "pos": Vector2(-200, -200), "name": "ArbustoFlorC"},
			{"tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "pos": Vector2(350, 80), "name": "ArbustoFlorD"},
			{"tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "pos": Vector2(1120, 30), "name": "ArbustoFlorLeste"},
			{"tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "pos": Vector2(-100, 260), "name": "ArbustoFlorPortao"},
			{"tex": "res://assets/sprites/objects/lobby_bush_flowers_decor.png", "pos": Vector2(120, 255), "name": "ArbustoFlorPortaoB"},
		])

	for p in placements:
		if not ResourceLoader.exists(p["tex"]):
			continue
		var body := StaticBody2D.new()
		body.name = p["name"]
		body.position = p["pos"]
		body.y_sort_enabled = true
		var spr := Sprite2D.new()
		spr.texture = load(p["tex"])
		spr.centered = true
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.position = Vector2(0, -8)
		body.add_child(spr)
		# Colisão leve só nos pés (decoração sem entrar)
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		var foot: Vector2 = p.get("foot", Vector2(20, 10))
		rect.size = foot
		col.shape = rect
		col.position = Vector2(0, 4)
		body.add_child(col)
		root.add_child(body)


## Estradas com relevo (PixelLab path tiles 32px) sobre a cruz de caminhos existente
func _melhorar_estradas_lobby() -> void:
	if get_node_or_null("LobbyPathReliefLayer") != null:
		return

	var caminhos := get_node_or_null("Caminhos_TileMapLayer") as TileMapLayer
	if caminhos == null:
		return

	var tileset := _criar_tileset_caminhos_relevo()
	if tileset == null:
		return

	var layer := TileMapLayer.new()
	layer.name = "LobbyPathReliefLayer"
	layer.tile_set = tileset
	layer.z_index = caminhos.z_index + 1
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Path tiles são 32px; camada de caminhos do lobby costuma ser 16px → escala 0.5 no espaço de célula
	layer.position = caminhos.position
	add_child(layer)
	move_child(layer, caminhos.get_index() + 1)

	# Suaviza pedra plana antiga (ainda serve de máscara de footprint)
	caminhos.modulate = Color(1, 1, 1, 0.18)

	var used: Array[Vector2i] = caminhos.get_used_cells()
	if used.is_empty():
		_pintar_cruz_estradas_padrao(layer)
		return

	# Autotile 4-edge: agrupa em células 32px (2×2 do mapa 16px)
	var path_cells: Dictionary = {} # Vector2i (32-space) -> true
	for c: Vector2i in used:
		var key := Vector2i(int(floor(float(c.x) / 2.0)), int(floor(float(c.y) / 2.0)))
		path_cells[key] = true

	for key: Vector2i in path_cells.keys():
		var mask := 0
		if path_cells.has(key + Vector2i(0, -1)):
			mask |= 1 # N
		if path_cells.has(key + Vector2i(1, 0)):
			mask |= 2 # E
		if path_cells.has(key + Vector2i(0, 1)):
			mask |= 4 # S
		if path_cells.has(key + Vector2i(-1, 0)):
			mask |= 8 # W
		var atlas := _atlas_para_mask_caminho(mask)
		layer.set_cell(key, atlas.x, Vector2i(0, 0))

	# Extra densificação: flores/arbustos ao longo das bordas da estrada
	_espalhar_detalhe_beira_estrada(path_cells)


func _criar_tileset_caminhos_relevo() -> TileSet:
	var prefix := "res://assets/tiles/lobby_paths/vibrant_green_grass_with_a_worn_reddish-brown_dirt_"
	if not ResourceLoader.exists(prefix + "0.png"):
		return null
	var ts := TileSet.new()
	ts.tile_size = Vector2i(32, 32)
	for i in range(18):
		var p := prefix + str(i) + ".png"
		if not ResourceLoader.exists(p):
			continue
		var src := TileSetAtlasSource.new()
		src.texture = load(p)
		src.texture_region_size = Vector2i(32, 32)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src, i)
	return ts


func _atlas_para_mask_caminho(mask: int) -> Vector2i:
	# Retorna source_id no tileset (atlas coords sempre 0,0). Mapeamento PixelLab:
	var by_mask := {
		0: 1,
		1: 2,
		2: 3,
		4: 4,
		8: 5,
		3: 10, # NE
		5: 7, # NS
		9: 11, # NW
		7: 8, # NES
		11: 6, # NEW
		13: 9, # NSW
		15: 12, # ALL
	}
	if by_mask.has(mask):
		return Vector2i(int(by_mask[mask]), 0)
	# Fallbacks para máscaras sem tile dedicado
	match mask:
		6: # ES
			return Vector2i(8, 0)
		10: # EW
			return Vector2i(7, 0)
		12: # SW
			return Vector2i(9, 0)
		14: # ESW
			return Vector2i(15, 0)
		_:
			return Vector2i(12, 0)


func _pintar_cruz_estradas_padrao(layer: TileMapLayer) -> void:
	for x in range(-20, 21):
		var sid := _atlas_para_mask_caminho(10 if abs(x) > 0 else 15).x
		layer.set_cell(Vector2i(x, 0), sid, Vector2i(0, 0))
	for y in range(-16, 17):
		if y == 0:
			continue
		layer.set_cell(Vector2i(0, y), _atlas_para_mask_caminho(5).x, Vector2i(0, 0))


func _espalhar_detalhe_beira_estrada(path_cells: Dictionary) -> void:
	var root := get_node_or_null("LobbyPixelDecorRoot") as Node2D
	if root == null:
		return
	var bush_path := "res://assets/sprites/objects/lobby_bush_flowers_decor.png"
	if not ResourceLoader.exists(bush_path):
		return
	var tex: Texture2D = load(bush_path)
	var i := 0
	for key: Vector2i in path_cells.keys():
		if (key.x + key.y * 3) % 5 != 0:
			continue
		# Offset para a beira (fora do centro da estrada)
		var world := Vector2(key.x * 32 + 16, key.y * 32 - 10)
		# Só coloca se vizinho N/S/E/W não for path (borda)
		var is_edge := false
		for d in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
			if not path_cells.has(key + d):
				is_edge = true
				break
		if not is_edge:
			continue
		var spr := Sprite2D.new()
		spr.name = "BeiraFlor_%d" % i
		spr.texture = tex
		spr.centered = true
		spr.position = world + Vector2((i % 3) * 6 - 6, (i % 2) * 4)
		spr.scale = Vector2(0.55, 0.55)
		spr.z_index = 1
		root.add_child(spr)
		i += 1
		if i > 28:
			break


# ============================================================
# 10. LIMITES DE CÂMERA & BARREIRAS FÍSICAS PERIMETRAIS
# ============================================================

func _configurar_limites_camera() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		var cam = player.get_node_or_null("Camera2D") as Camera2D
		if cam != null:
			cam.limit_left = -1180
			cam.limit_top = -880
			cam.limit_right = 1680
			cam.limit_bottom = 800
			cam.position_smoothing_enabled = true
			cam.position_smoothing_speed = 8.0


func _criar_limites_do_mapa() -> void:
	if get_node_or_null("LimitesLobbyPerimetro") != null:
		return

	var parent_limites := StaticBody2D.new()
	parent_limites.name = "LimitesLobbyPerimetro"
	parent_limites.collision_layer = 1
	parent_limites.collision_mask = 0

	# 1. Barreira Norte (Muralha Norte da Capital)
	_adicionar_segmento_colisao(parent_limites, Vector2(250, -860), Vector2(2860, 48))

	# 2. Barreira Oeste (Colinas e Muros do Distrito Residencial)
	_adicionar_segmento_colisao(parent_limites, Vector2(-1180, -40), Vector2(48, 1680))

	# 3. Barreira Leste (Abismo e Muralhas da Torre Celestial)
	_adicionar_segmento_colisao(parent_limites, Vector2(1680, -40), Vector2(48, 1680))

	# 4. Barreira Sul (Muro Sul com vão para o Portão do Mundo Exterior em X=0)
	_adicionar_segmento_colisao(parent_limites, Vector2(-600, 780), Vector2(1160, 48))
	_adicionar_segmento_colisao(parent_limites, Vector2(860, 780), Vector2(1640, 48))

	add_child(parent_limites)


func _adicionar_segmento_colisao(parent: Node2D, pos: Vector2, tamanho: Vector2) -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = tamanho
	col.shape = rect
	col.position = pos
	parent.add_child(col)
