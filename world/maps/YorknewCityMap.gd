class_name YorknewCityMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DE YORKNEW CITY (ARCO 4 - 34 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 4 (Yorknew City):
# - Popula NPCs: Leorio, Kurapika, Melody, Gon, Killua, Battera, Chrollo.
# - Configura inimigos da Máfia e membros da Trupe Fantasma (Uvogin, Feitan, Pakunoda, Chrollo Boss).
# - STORY GATE: Exige conclusão das 34 etapas antes de Greed Island.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"leilao": false,
	"ruas": false,
	"cemiterio": false,
	"esconderijo": false
}


func _ready() -> void:
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.YORKNEW)
	SagaHubConsolidator.densify_hub(self, SagaHubConsolidator.config_for_saga(4))
	SagaDistrictKit.densify_saga(self, 4)
	SagaTerritoryKit.attach(self, 4)
	SagaChapterBinder.bind_hub(self, 4)
	_garantir_dialogue_ui()
	_popular_npcs_arco4()
	_configurar_inimigos()
	_densificar_ruas_yorknew()
	_instanciar_sensores_nen_yorknew()
	_configurar_portal_conclusao()
	_garantir_quest_ativa()
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 1200 and not _marcos_notificados["leilao"]:
		_marcos_notificados["leilao"] = true
		_toast_zona(hud, "🏢 Leilão Underground — Fale com Leorio. Use [G] nas antiguidades do mercado.")

	elif px >= 1200 and px < 2400 and not _marcos_notificados["ruas"]:
		_marcos_notificados["ruas"] = true
		_toast_zona(hud, "🏙️ Avenida Central — Caminhe com calma. [Z] nos becos. GPS marca o próximo objetivo.")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["cemiterio"]:
		_marcos_notificados["cemiterio"] = true
		_toast_zona(hud, "🏗️ Edifício Cemitério — Battera/Tsezguerra à frente. [G] no Réquiem. Sem rush.")

	elif px >= 3600 and not _marcos_notificados["esconderijo"]:
		_marcos_notificados["esconderijo"] = true
		_toast_zona(hud, "🕷️ Esconderijo da Trupe — Um objetivo de cada vez. Portal GI só após as 34 etapas.")


func _toast_zona(hud: Node, msg: String) -> void:
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(msg)
	elif EventBus != null:
		EventBus.emit_toast(msg, Color(0.95, 0.85, 0.45))


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(4)


func _popular_npcs_arco4() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[YorknewCityMap] ERRO: NPC.tscn não encontrado!")
		return

	# 0. Leiloeiro do Underground (distrito do leilão)
	if get_node_or_null("Leiloeiro") == null:
		var scn_lei = load("res://entities/npc/leiloeiro/Leiloeiro.tscn")
		var leiloeiro
		if scn_lei:
			leiloeiro = scn_lei.instantiate()
		else:
			leiloeiro = scn_npc.instantiate()
			leiloeiro.npc_name = "Leiloeiro do Underground"
			leiloeiro.fala_padrao = "Bem-vindo ao leilão de Yorknew. Escrow garantido pela casa — taxa de 5% na listagem."
		leiloeiro.name = "Leiloeiro"
		leiloeiro.position = Vector2(380, -40)
		add_child(leiloeiro)

	# 1. Leorio (Início da Cidade)
	if get_node_or_null("Leorio") == null:
		var leorio = scn_npc.instantiate()
		leorio.name = "Leorio"
		leorio.position = Vector2(100, -30)
		leorio.npc_name = "Leorio"
		leorio.fala_padrao = "ORDEM: 1) Fale comigo. 2) [G] Gyo nas antiguidades do mercado (leilão). 3) Depois Kurapika (Nostrade). Um passo — sem misturar."
		NpcSpriteBinder.aplicar(leorio, ["npc_leorio"])
		add_child(leorio)

	# 2. Kurapika
	if get_node_or_null("Kurapika") == null:
		var scn_kurapika = load("res://entities/npc/kurapika/Kurapika.tscn")
		var kurapika
		if scn_kurapika:
			kurapika = scn_kurapika.instantiate()
		else:
			kurapika = scn_npc.instantiate()
			kurapika.npc_name = "Kurapika"
			NpcSpriteBinder.aplicar(kurapika, ["npc_kurapika"])
		kurapika.name = "Kurapika"
		kurapika.position = Vector2(300, -50)
		kurapika.npc_name = "Kurapika"
		kurapika.fala_padrao = "Contrato Nostrade: fale comigo, depois Melody. À noite limpe mafiosos no GPS. A Trupe vem depois — prepare-se, não rush."
		add_child(kurapika)

	# 3. Melody
	if get_node_or_null("Melody") == null:
		var melody = scn_npc.instantiate()
		melody.name = "Melody"
		melody.position = Vector2(450, -30)
		melody.npc_name = "Melody"
		melody.fala_padrao = "Ouço seu ritmo. Próximo: derrote os mafiosos marcados no GPS, depois infiltre o leilão com Kurapika. Caminhe — Yorknew é longa."
		NpcSpriteBinder.aplicar(melody, ["npc_melody"])
		add_child(melody)

	# 4. Gon
	if get_node_or_null("Gon") == null:
		var scn_gon = load("res://entities/npc/gon/Gon.tscn")
		var gon
		if scn_gon:
			gon = scn_gon.instantiate()
		else:
			gon = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(gon, ["npc_gon"])
		gon.name = "Gon"
		gon.position = Vector2(700, 50)
		gon.npc_name = "Gon Freecss"
		gon.fala_padrao = "Siga o GPS. Leilão → Ruas → Cemitério → Trupe. Killua e eu vamos no seu ritmo — sem pular etapas."
		add_child(gon)

	# 5. Bilionário Battera
	if get_node_or_null("Battera") == null:
		var battera = scn_npc.instantiate()
		battera.name = "Battera"
		battera.position = Vector2(2800, -100)
		battera.npc_name = "Bilionário Battera"
		battera.fala_padrao = "Quer Greed Island? Fale com Tsezguerra ao lado e passe o teste. Antes disso: conclua as etapas do GPS no Cemitério."
		NpcSpriteBinder.aplicar(battera, ["npc_battera"])
		add_child(battera)

	# 6. Tsezguerra
	if get_node_or_null("Tsezguerra") == null:
		var tsezguerra = scn_npc.instantiate()
		tsezguerra.name = "Tsezguerra"
		tsezguerra.position = Vector2(2900, -80)
		tsezguerra.npc_name = "Tsezguerra"
		tsezguerra.fala_padrao = "Mostre Ren quando o GPS pedir. Até lá: um objetivo de cada vez. Portal GI fica trancado até a etapa 34."
		NpcSpriteBinder.aplicar(tsezguerra, ["npc_tsezguerra"])
		add_child(tsezguerra)

	# 7. Chrollo
	if get_node_or_null("Chrollo") == null:
		var scn_chrollo = load("res://entities/npc/chrollo/Chrollo.tscn")
		var chrollo
		if scn_chrollo:
			chrollo = scn_chrollo.instantiate()
		else:
			chrollo = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(chrollo, ["npc_chrollo"])
		chrollo.name = "Chrollo"
		chrollo.position = Vector2(3300, -300)
		chrollo.npc_name = "Chrollo Lucilfer"
		chrollo.fala_padrao = "Uvogin... Você está ouvindo o réquiem que estamos tocando para você?"
		add_child(chrollo)


func _configurar_inimigos() -> void:
	var configs = {
		"SoldadoMafia1": {"id": &"mafioso_corrompido", "nome": "Mafioso Corrompido", "etapa": 5},
		"UvoginInimigo": {"id": &"uvogin", "nome": "Uvogin (Trupe Fantasma)", "etapa": 10},
		"SoldadoMafia2": {"id": &"clone_feitan", "nome": "Clone do Feitan", "etapa": 18},
		"PakunodaInimiga": {"id": &"pakunoda", "nome": "Pakunoda (Trupe Fantasma)", "etapa": 23},
		"NobunagaInimigo": {"id": &"nobunaga", "nome": "Nobunaga Hazama", "etapa": 20},
		"ChrolloBossInimigo": {"id": &"chrollo", "nome": "Chrollo Lucilfer (Chefe)", "etapa": 34}
	}
	
	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 4
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 4, es.quest_etapa, -1, null, es.enemy_name)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalGreedIsland") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Greed Island"
		portal.map_subtitle = "Arco 5 — O Jogo da JoyStation & O Treino de Biscuit"
		portal.story_gate = StoryGate.new(4, 34, true)
		portal.story_gate.gate_title = "Console JoyStation (Greed Island)"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 34 etapas de Yorknew City e derrotar a projeção de Chrollo antes de entrar em Greed Island!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_yorknew_cutscene(get_tree(), mudar_cena_cb)


## Densifica as avenidas: mafiosos ambient, walkers, placas intermediárias, props.
func _densificar_ruas_yorknew() -> void:
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if scn_enemy != null:
		var fillers := [
			{"name": "MafiosoAmbient_A", "pos": Vector2(600, 40), "label": "Soldado da Máfia (Leilão)"},
			{"name": "MafiosoAmbient_B", "pos": Vector2(1500, -50), "label": "Capanga das Ruas"},
			{"name": "MafiosoAmbient_C", "pos": Vector2(2100, 60), "label": "Olheiro do Sindicato"},
			{"name": "MafiosoAmbient_D", "pos": Vector2(3100, -40), "label": "Guarda do Cemitério"},
			{"name": "MafiosoAmbient_E", "pos": Vector2(900, -60), "label": "Capanga do Mercado"},
			{"name": "MafiosoAmbient_F", "pos": Vector2(1800, 70), "label": "Patrulha da Avenida"},
			{"name": "MafiosoAmbient_G", "pos": Vector2(2600, 50), "label": "Sentinela do Cemitério Sul"},
			{"name": "MafiosoAmbient_H", "pos": Vector2(3500, -20), "label": "Olheiro da Aranha"},
		]
		for f in fillers:
			if get_node_or_null(f["name"]) != null:
				continue
			var mob = scn_enemy.instantiate()
			mob.name = f["name"]
			mob.position = f["pos"]
			mob.add_to_group("enemy")
			mob.add_to_group("enemies")
			var es = mob.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = false
				es.enemy_id = &"mafioso_yorknew"
				es.enemy_name = f["label"]
			add_child(mob)

	var placas := [
		{"name": "PlacaYorkLeilao", "pos": Vector2(350, -70), "text": "📍 Leilão — Leorio → [G] antiguidades"},
		{"name": "PlacaYorkMercado", "pos": Vector2(800, -90), "text": "📍 Mercado — pechincha / Gyo"},
		{"name": "PlacaYorkRuas", "pos": Vector2(1600, -90), "text": "📍 Avenida — caminhe · [Z] becos"},
		{"name": "PlacaYorkDocas", "pos": Vector2(2000, -70), "text": "📍 Docas — mafiosos do GPS"},
		{"name": "PlacaYorkCemiterio", "pos": Vector2(2700, -110), "text": "📍 Cemitério — Battera / Réquiem"},
		{"name": "PlacaYorkHotel", "pos": Vector2(3200, -90), "text": "📍 Hotel Beitacle — etapas mid"},
		{"name": "PlacaYorkTrupe", "pos": Vector2(3700, -90), "text": "📍 Trupe — 34 etapas → GI"},
	]
	for p in placas:
		if get_node_or_null(p["name"]) != null:
			continue
		var marker := Node2D.new()
		marker.name = p["name"]
		marker.position = p["pos"]
		var lbl := Label.new()
		lbl.text = p["text"]
		lbl.position = Vector2(-70, -10)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.45, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		marker.add_child(lbl)
		add_child(marker)

	_popular_walkers_yorknew()
	_plantar_props_yorknew()


func _popular_walkers_yorknew() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return
	var walkers := [
		{"name": "ComercianteMercado", "pos": Vector2(750, 40), "npc": "Comerciante do Mercado", "fala": "Quer pechincha? Ative [G] Gyo nas antiguidades do leilão. Sem aura, você compra lixo.", "ids": ["npc_viajante_scout"], "r": 48.0},
		{"name": "GuardaNostrade", "pos": Vector2(1100, -40), "npc": "Guarda Nostrade", "fala": "Kurapika é o chefe da comitiva. Fale com ele, depois Melody. Não atravessa a avenida sem GPS.", "ids": ["npc_guarda_fronteira"], "r": 40.0},
		{"name": "ApostadorLeilao", "pos": Vector2(500, 60), "npc": "Apostador do Underground", "fala": "O leilão é longo. Caminhe distrito a distrito. Um objetivo — depois o próximo.", "ids": ["npc_viajante_scout"], "r": 44.0},
		{"name": "ReporterAvenida", "pos": Vector2(1700, -70), "npc": "Reporter da Avenida", "fala": "Aranhas foram vistas no Cemitério. Use [Z] nos becos. Não grite aura.", "ids": ["npc_viajante_scout"], "r": 52.0},
		{"name": "PorteiroCemiterio", "pos": Vector2(2550, 40), "npc": "Porteiro do Cemitério", "fala": "Battera e Tsezguerra ficam dentro. [G] no Eco do Réquiem. Portal GI ainda longe.", "ids": ["npc_guarda_fronteira"], "r": 36.0},
		{"name": "CivilAssustado", "pos": Vector2(3400, 50), "npc": "Civil Assustado", "fala": "A Trupe está à frente. Siga o GPS etapa a etapa. Yorknew não perdoa quem rusha.", "ids": ["npc_viajante_scout"], "r": 42.0},
	]
	for w in walkers:
		if get_node_or_null(w["name"]) != null:
			continue
		var npc = scn_npc.instantiate()
		npc.name = w["name"]
		npc.position = w["pos"]
		npc.npc_name = w["npc"]
		npc.fala_padrao = w["fala"]
		NpcSpriteBinder.aplicar(npc, w["ids"])
		var living := LivingNPCBehavior.new()
		living.name = "LivingNPCBehavior"
		living.npc_nome = w["npc"]
		living.tipo_marcador = "ambient"
		living.hierarchy = LivingNPCBehavior.NPCHierarchy.COMMON
		living.raio_patrulha = float(w["r"])
		npc.add_child(living)
		add_child(npc)


func _plantar_props_yorknew() -> void:
	if get_node_or_null("PropsEstruturaYorknew") != null:
		return
	var root := Node2D.new()
	root.name = "PropsEstruturaYorknew"
	add_child(root)
	var specs := [
		{"name": "LanternaLeilao", "pos": Vector2(420, 30), "tex": "res://assets/sprites/objects/phase3_lantern_post.png"},
		{"name": "MarcoAvenida", "pos": Vector2(1550, 40), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
		{"name": "LanternaCemiterio", "pos": Vector2(2650, 20), "tex": "res://assets/sprites/objects/hunter_road_lantern.png"},
		{"name": "MonolitoTrupe", "pos": Vector2(3600, 30), "tex": "res://assets/sprites/objects/nen_stone_monolith.png"},
		{"name": "MarcoHotel", "pos": Vector2(3150, 40), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
	]
	for s in specs:
		var n := Node2D.new()
		n.name = s["name"]
		n.position = s["pos"]
		var spr := Sprite2D.new()
		spr.centered = true
		spr.position = Vector2(0, -12)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if ResourceLoader.exists(s["tex"]):
			spr.texture = load(s["tex"])
		n.add_child(spr)
		root.add_child(n)


## Trilha Gyo (inclui clues do CanonQuest) + becos Zetsu + KO.
func _instanciar_sensores_nen_yorknew() -> void:
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoPistaLeilaoAura", Vector2(400, -20),
			&"yorknew_leilao_aura", "Resíduo de Nen no Leilão",
			"Objetos do leilão underground vibram com aura falsa — Gyo revela falsificações.",
			"Materialização", 1, Color(0.45, 0.85, 1.0, 0.9)
		)
		# Clue canônico etapa 2
		NenSensorFactory.criar_gyo(
			self, "GyoAntiguidadeMercado", Vector2(720, -10),
			&"antiguidade_mercado", "Antiguidade do Mercado",
			"Peça rara com aura residual. Avalie com Gyo — pechincha sem Nen é furada. Próximo: Kurapika (Nostrade).",
			"Materialização", 1, Color(0.95, 0.8, 0.35, 0.9)
		)
		# Clue canônico etapa 7-ish cofre
		NenSensorFactory.criar_gyo(
			self, "GyoCofreVazioLeilao", Vector2(480, 50),
			&"cofre_vazio_leilao", "Cofre Vazio do Leilão",
			"O cofre foi limpo pela Trupe. Aura recente de Especialização — as Aranhas passaram aqui.",
			"Especialização", 1, Color(0.9, 0.35, 0.45, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoPistaRuasAranha", Vector2(1800, 30),
			&"yorknew_pegada_aranha", "Pegada da Aranha",
			"Rastro diluído de Nen especial — alguém da Trupe passou pelas ruas. Caminhe até o Cemitério.",
			"Especialização", 1, Color(0.95, 0.4, 0.55, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoPistaCemiterioRequiem", Vector2(2700, -80),
			&"yorknew_requiem_aura", "Eco do Réquiem",
			"Aura densa no Edifício Cemitério. O réquiem de Uvogin ainda ecoa.",
			"Emissão", 2, Color(0.7, 0.35, 0.9, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoRequiemChrollo", Vector2(3350, -200),
			&"requiem_chrollo", "Marca do Réquiem de Chrollo",
			"Assinatura de Nen do líder. Próximo passo no GPS — não enfrente a Trupe fora de ordem.",
			"Especialização", 2, Color(0.75, 0.25, 0.85, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoHotelBeitacle", Vector2(3180, -40),
			&"yorknew_hotel_beitacle", "Resíduo no Hotel Beitacle",
			"Negociações de reféns deixaram aura tensionada. Siga o GPS — Yorknew é longa de propósito.",
			"Manipulação", 1, Color(0.55, 0.75, 1.0, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoCopiaKortopi", Vector2(2900, -60),
			&"copia_kortopi", "Cópia de Nen (Gallery Fake)",
			"Corpos falsos de Kortopi. Depois Hotel Beitacle (Melody). Sem rush.",
			"Conjuração", 2, Color(0.65, 0.55, 0.95, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoMemoriaPakunoda", Vector2(3600, -50),
			&"memoria_pakunoda", "Memórias de Pakunoda",
			"Resíduo do Memory Bomb. Depois leilão GI com Leorio.",
			"Especialização", 2, Color(0.9, 0.5, 0.7, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoFitaGing", Vector2(4200, -40),
			&"fita_ging", "Fita Cassete de Ging",
			"Mensagem oculta de Ging. Depois boss sombra de Chrollo (GPS).",
			"Emissão", 1, Color(0.4, 0.85, 0.55, 0.9)
		)
		NenSensorFactory.criar_ko(
			self, "KoCaixoteLeilao", Vector2(550, 20),
			"Caixote Blindado do Leilão", &"pocao_aura", &"yorknew_ko_caixote"
		)
		NenSensorFactory.criar_ko(
			self, "KoPortaoCemiterio", Vector2(2450, -20),
			"Portão Selado do Cemitério", &"elixir_aura"
		)

	NenSensorFactory.criar_zetsu(
		self, "ZetsuBecoRuasNorte", Vector2(1400, -120),
		&"yorknew_beco_norte", "Beco Vigiado da Máfia",
		Vector2(140, 100), &"mafioso_yorknew", "Mafioso Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuBecoCemiterio", Vector2(2500, 100),
		&"yorknew_beco_cemiterio", "Alameda do Cemitério",
		Vector2(160, 110), &"mafioso_yorknew", "Sentinela Mafiosa Alertada"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuBecoEsconderijo", Vector2(3800, -80),
		&"yorknew_beco_esconderijo", "Beco do Esconderijo da Trupe",
		Vector2(150, 100), &"mafioso_yorknew", "Olheiro da Aranha"
	)
	# Clue canônico etapa 21 — apagão
	NenSensorFactory.criar_zetsu(
		self, "ZetsuApagaoSubestacao", Vector2(2200, -40),
		&"apagao_yorknew", "Subestação do Apagão",
		Vector2(150, 100), &"mafioso_yorknew", "Guarda da Subestação"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuDocasLeilao", Vector2(1000, 80),
		&"yorknew_docas_leilao", "Docas do Leilão",
		Vector2(130, 90), &"mafioso_yorknew", "Capanga das Docas"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuPerseguicaoGordeau", Vector2(1900, -30),
		&"deserto_gordeau", "Corredor da Perseguição (Gordeau)",
		Vector2(160, 100), &"mafioso_yorknew", "Perseguidor Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuGalpaoMachiNobunaga", Vector2(2800, 40),
		&"galpao_machinobunaga", "Galpão Machi / Nobunaga",
		Vector2(160, 100), &"mafioso_yorknew", "Sentinela da Aranha"
	)
