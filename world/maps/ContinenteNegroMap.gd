class_name ContinenteNegroMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DO CONTINENTE NEGRO (ARCO 8 - 22 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 8 (Continente Negro & Árvore do Mundo):
# - Popula NPCs: Beyond, Cheadle, Ging, Árvore do Mundo, Ging Topo.
# - Densifica Acampamento → Costa → Ruínas → Raízes → Topo.
# - Sensores Nen alinhados ao CanonQuestCatalog (Gyo/Ko/Zetsu).
# - STORY GATE: Exige conclusão das 22 etapas antes do Black Whale 1.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"acampamento": false,
	"costa": false,
	"ruinas": false,
	"raizes": false,
	"topo": false
}


func _ready() -> void:
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.CONTINENTE)
	SagaHubConsolidator.densify_hub(self, SagaHubConsolidator.config_for_saga(8))
	SagaDistrictKit.densify_saga(self, 8)
	SagaTerritoryKit.attach(self, 8)
	SagaChapterBinder.bind_hub(self, 8)
	_garantir_dialogue_ui()
	_popular_npcs_arco8()
	_configurar_inimigos()
	_densificar_continente()
	_instanciar_sensores_nen_continente()
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

	if px >= 0 and px < 900 and not _marcos_notificados["acampamento"]:
		_marcos_notificados["acampamento"] = true
		_toast_zona(hud, "⛺ Acampamento — Beyond → Cheadle → Ging. [G] Lago Mobius. Sem rush.")

	elif px >= 900 and px < 1600 and not _marcos_notificados["costa"]:
		_marcos_notificados["costa"] = true
		_toast_zona(hud, "🌊 Costa — [Z] Águas Proibidas. Depois desembarque (Beyond).")

	elif px >= 1600 and px < 2600 and not _marcos_notificados["ruinas"]:
		_marcos_notificados["ruinas"] = true
		_toast_zona(hud, "🏛️ Ruínas Brion — [G] botânicas → guardiões → Brion Boss. GPS um de cada vez.")

	elif px >= 2600 and px < 3600 and not _marcos_notificados["raizes"]:
		_marcos_notificados["raizes"] = true
		_toast_zona(hud, "🌳 Raízes — [Z] Hellbell → Ai → Árvore do Mundo. Sem rush nas calamidades.")

	elif px >= 3600 and not _marcos_notificados["topo"]:
		_marcos_notificados["topo"] = true
		_toast_zona(hud, "☁️ Topo — Ging → [G] Horizonte. Portal Black Whale após etapa 22.")


func _toast_zona(hud: Node, msg: String) -> void:
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(msg)
	elif EventBus != null:
		EventBus.emit_toast(msg, Color(0.55, 0.7, 0.35))


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(8)


func _popular_npcs_arco8() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[ContinenteNegroMap] ERRO: NPC.tscn não encontrado!")
		return

	# 1. Beyond Netero (Acampamento)
	if get_node_or_null("Beyond") == null:
		var beyond = scn_npc.instantiate()
		beyond.name = "Beyond"
		beyond.position = Vector2(120, -50)
		NpcSpriteBinder.aplicar(beyond, ["npc_netero", "npc_guarda_fronteira"])
		add_child(beyond)
	var beyond_n = get_node_or_null("Beyond")
	if beyond_n != null:
		if "npc_name" in beyond_n:
			beyond_n.npc_name = "Beyond Netero"
		if "fala_padrao" in beyond_n:
			beyond_n.fala_padrao = "ORDEM: Fale comigo (manifesto) → Cheadle → Ging. Depois [G] Lago Mobius. Sem rush."

	# 2. Cheadle (Zodíacos / expedição)
	if get_node_or_null("Cheadle") == null:
		var cheadle = scn_npc.instantiate()
		cheadle.name = "Cheadle"
		cheadle.position = Vector2(220, -40)
		NpcSpriteBinder.aplicar(cheadle, ["npc_recepcionista_elena", "npc_viajante_scout"])
		add_child(cheadle)
	var cheadle_n = get_node_or_null("Cheadle")
	if cheadle_n != null:
		if "npc_name" in cheadle_n:
			cheadle_n.npc_name = "Presidente Cheadle"
		if "fala_padrao" in cheadle_n:
			cheadle_n.fala_padrao = "ORDEM: Kurapika e Leorio nos Zodíacos. Fale comigo → Ging no acampamento. Um passo."

	# 3. Ging Freecss (Acampamento)
	if get_node_or_null("Ging") == null:
		var scn_ging = load("res://entities/npc/ging/Ging.tscn")
		var ging
		if scn_ging:
			ging = scn_ging.instantiate()
		else:
			ging = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(ging, ["npc_ging", "npc_viajante_scout"])
		ging.name = "Ging"
		ging.position = Vector2(350, -80)
		add_child(ging)
	var ging_n = get_node_or_null("Ging")
	if ging_n != null:
		ging_n.position = Vector2(350, -80)
		if "npc_name" in ging_n:
			ging_n.npc_name = "Ging Freecss"
		if "fala_padrao" in ging_n:
			ging_n.fala_padrao = "ORDEM: Fale comigo / teste Nen. Depois [G] Lago Mobius → [Z] Águas. Sem pular o caminho."

	# 4. Árvore do Mundo (marco)
	if get_node_or_null("ArvoreMundo") == null:
		var arvore = scn_npc.instantiate()
		arvore.name = "ArvoreMundo"
		arvore.position = Vector2(2800, -100)
		NpcSpriteBinder.aplicar(arvore, ["npc_guarda_fronteira"])
		add_child(arvore)
	var arvore_n = get_node_or_null("ArvoreMundo")
	if arvore_n != null:
		arvore_n.position = Vector2(2800, -100)
		if "npc_name" in arvore_n:
			arvore_n.npc_name = "Árvore do Mundo"
		if "fala_padrao" in arvore_n:
			arvore_n.fala_padrao = "ORDEM: Alcance a base (GPS). Depois escale. Topo = Ging. Sem rush nos 1.784m."

	# 5. Ging no Topo — NPC genérico p/ match ging_topo (visit + persuasion)
	if get_node_or_null("GingTopo") == null:
		var ging_topo = scn_npc.instantiate()
		ging_topo.name = "GingTopo"
		ging_topo.position = Vector2(3850, -120)
		NpcSpriteBinder.aplicar(ging_topo, ["npc_ging", "npc_viajante_scout"])
		add_child(ging_topo)
	var ging_topo_n = get_node_or_null("GingTopo")
	if ging_topo_n != null:
		ging_topo_n.position = Vector2(3850, -120)
		if "npc_name" in ging_topo_n:
			ging_topo_n.npc_name = "Ging Freecss no Topo"
		if "fala_padrao" in ging_topo_n:
			ging_topo_n.fala_padrao = "ORDEM: Fale comigo no topo → filosofia → [G] Horizonte → convite Kakin. Portal após 22."


func _configurar_inimigos() -> void:
	var configs = {
		"CriaturaPrimitiva1": {"id": &"guardiao_brion", "nome": "Guardião Botânico de Brion", "etapa": 9},
		"CriaturaPrimitiva2": {"id": &"brion_boss", "nome": "Calamidade Brion Boss", "etapa": 10},
		"BestaCalamidade1": {"id": &"hellbell_boss", "nome": "Serpente Hellbell Boss", "etapa": 12},
		"BestaCalamidade2": {"id": &"ai_boss", "nome": "Entidade Ai Boss", "etapa": 13}
	}

	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 8
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 8, es.quest_etapa, -1, null, es.enemy_name)

	_spawn_fillers_combate_continente()


func _spawn_fillers_combate_continente() -> void:
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if scn_enemy == null:
		return
	var fillers := [
		{"name": "BrionMissao_B", "pos": Vector2(1700, 40), "id": &"guardiao_brion", "label": "Guardião Brion B", "mission": true, "etapa": 9},
		{"name": "BrionMissao_C", "pos": Vector2(1850, -40), "id": &"guardiao_brion", "label": "Guardião Brion C", "mission": true, "etapa": 9},
		{"name": "BrionMissao_D", "pos": Vector2(2000, 50), "id": &"guardiao_brion", "label": "Guardião Brion D", "mission": true, "etapa": 9},
		{"name": "BrionMissao_E", "pos": Vector2(2150, -30), "id": &"guardiao_brion", "label": "Guardião Brion E", "mission": true, "etapa": 9},
		{"name": "FeraAlada_A", "pos": Vector2(3000, 40), "id": &"guardiao_brion", "label": "Fera Alada A", "mission": true, "etapa": 16},
		{"name": "FeraAlada_B", "pos": Vector2(3150, -40), "id": &"guardiao_brion", "label": "Fera Alada B", "mission": true, "etapa": 16},
		{"name": "FeraAlada_C", "pos": Vector2(3300, 50), "id": &"guardiao_brion", "label": "Fera Alada C", "mission": true, "etapa": 16},
		{"name": "FeraAlada_D", "pos": Vector2(3450, -30), "id": &"guardiao_brion", "label": "Fera Alada D", "mission": true, "etapa": 16},
		{"name": "CostaAmbient_A", "pos": Vector2(1100, 40), "id": &"guardiao_brion", "label": "Fera da Costa", "mission": false, "etapa": -1},
		{"name": "RaizAmbient_A", "pos": Vector2(2700, 40), "id": &"guardiao_brion", "label": "Eco das Raízes", "mission": false, "etapa": -1},
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
			es.is_mission_enemy = bool(f["mission"])
			es.enemy_id = f["id"]
			es.enemy_name = f["label"]
			if bool(f["mission"]):
				es.quest_arc = 8
				es.quest_etapa = int(f["etapa"])
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, f["pos"], 8, es.quest_etapa, -1, null, es.enemy_name)
		add_child(mob)


func _densificar_continente() -> void:
	var placas := [
		{"name": "PlacaCNAcampamento", "pos": Vector2(200, -100), "text": "📍 Acampamento — Beyond → Ging"},
		{"name": "PlacaCNCosta", "pos": Vector2(1200, -100), "text": "📍 Costa — [Z] Águas Proibidas"},
		{"name": "PlacaCNRuinas", "pos": Vector2(1900, -110), "text": "📍 Ruínas — [G] Brion → Boss"},
		{"name": "PlacaCNRaizes", "pos": Vector2(2800, -110), "text": "📍 Raízes — Hellbell → Árvore"},
		{"name": "PlacaCNTopo", "pos": Vector2(3800, -110), "text": "📍 Topo — Ging → Horizonte → Whale"},
	]
	for p in placas:
		if get_node_or_null(p["name"]) != null:
			continue
		var marker := Node2D.new()
		marker.name = p["name"]
		marker.position = p["pos"]
		var lbl := Label.new()
		lbl.text = p["text"]
		lbl.position = Vector2(-75, -10)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.add_theme_color_override("font_color", Color(0.55, 0.8, 0.4, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		marker.add_child(lbl)
		add_child(marker)

	_popular_walkers_continente()
	_plantar_props_continente()


func _popular_walkers_continente() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return
	var walkers := [
		{"name": "MercenarioExpedicao", "pos": Vector2(400, 50), "npc": "Mercenário da Expedição", "fala": "ORDEM: Beyond → Cheadle → Ging. Sem [G] no Lago Mobius você não entende o mapa.", "ids": ["npc_guarda_fronteira"], "r": 40.0},
		{"name": "CientistaV5", "pos": Vector2(600, -40), "npc": "Cientista do V5", "fala": "Tratado quebrado. Siga o GPS — um calamidade de cada vez. Sem rush na costa.", "ids": ["npc_viajante_scout"], "r": 38.0},
		{"name": "MarinheiroCosta", "pos": Vector2(1050, 45), "npc": "Marinheiro da Costa", "fala": "ORDEM: [Z] Águas Proibidas. Sem Zetsu = feras. Depois Beyond no desembarque.", "ids": ["npc_guarda_fronteira"], "r": 36.0},
		{"name": "BotanicoRuinas", "pos": Vector2(1750, 40), "npc": "Botânico das Ruínas", "fala": "ORDEM: [G] Ruínas Botânicas → guardiões (GPS) → Brion Boss. Sem pular calamidades.", "ids": ["npc_viajante_scout"], "r": 40.0},
		{"name": "ScoutHellbell", "pos": Vector2(2500, -50), "npc": "Scout da Caverna", "fala": "ORDEM: [Z] Caverna Hellbell. Depois Hellbell Boss → Ai. Proteja a mente.", "ids": ["npc_guarda_fronteira"], "r": 38.0},
		{"name": "EscaladorRaizes", "pos": Vector2(2900, 45), "npc": "Escalador das Raízes", "fala": "Fale com a Árvore (GPS). Depois feras aladas → topo com Ging. Sem rush nos 1.784m.", "ids": ["npc_viajante_scout"], "r": 36.0},
		{"name": "ObservadorTopo", "pos": Vector2(3700, 40), "npc": "Observador do Topo", "fala": "ORDEM: Ging no topo → [G] Horizonte → convite Kakin. Portal Black Whale após etapa 22.", "ids": ["npc_guarda_fronteira"], "r": 32.0},
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


func _plantar_props_continente() -> void:
	if get_node_or_null("PropsEstruturaContinente") != null:
		return
	var root := Node2D.new()
	root.name = "PropsEstruturaContinente"
	add_child(root)
	var specs := [
		{"name": "MarcoAcampamento", "pos": Vector2(250, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
		{"name": "LanternaAcampamento", "pos": Vector2(500, 20), "tex": "res://assets/sprites/objects/hunter_road_lantern.png"},
		{"name": "PosteCosta", "pos": Vector2(1150, 20), "tex": "res://assets/sprites/objects/phase3_lantern_post.png"},
		{"name": "RochaRuinas", "pos": Vector2(1800, 25), "tex": "res://assets/sprites/objects/phase2_rock_boulder.png"},
		{"name": "ArbustoRuinas", "pos": Vector2(2100, 20), "tex": "res://assets/sprites/objects/calibration_bush_a.png"},
		{"name": "MonolitoRaizes", "pos": Vector2(2750, 20), "tex": "res://assets/sprites/objects/nen_stone_monolith.png"},
		{"name": "MarcoTopo", "pos": Vector2(3750, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
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


## Gyo/Ko/Zetsu alinhados ao CanonQuestCatalog (arco 8).
func _instanciar_sensores_nen_continente() -> void:
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoMapaLagoMobius", Vector2(450, -20),
			&"mapa_lago_mobius", "Mapa Secreto do Lago Mobius",
			"O mundo humano é só uma lagoa. Depois [Z] Águas Proibidas — GPS.",
			"Especialização", 2, Color(0.4, 0.7, 1.0, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoRuinasBotanicas", Vector2(1950, -40),
			&"ruinas_botanicas", "Ruínas Botânicas Ancestrais",
			"Sementes de longevidade. Depois guardiões de Brion (GPS).",
			"Conjuração", 2, Color(0.45, 0.9, 0.4, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoHorizonteInfinito", Vector2(4000, -50),
			&"horizonte_infinito", "Horizonte Sem Fim",
			"Além do Lago Mobius. Fale com Ging no topo, depois convite Kakin.",
			"Especialização", 2, Color(0.85, 0.75, 0.35, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoNitroRice", Vector2(2600, -30),
			&"cn_nitro_rice_aura", "Aura do Nitro Rice",
			"Sementes que prolongam a vida. Colete quando o GPS pedir.",
			"Transformação", 2, Color(0.9, 0.85, 0.5, 0.9)
		)
		NenSensorFactory.criar_ko(
			self, "KoRaizSelada", Vector2(2300, 35),
			"Raiz Selada de Brion", &"pocao_aura", &"cn_ko_brion"
		)
		NenSensorFactory.criar_ko(
			self, "KoTroncoArvore", Vector2(2950, 35),
			"Tronco Rachado da Árvore", &"elixir_aura"
		)

	NenSensorFactory.criar_zetsu(
		self, "ZetsuAguasProibidas", Vector2(1250, -20),
		&"aguas_proibidas", "Águas Proibidas",
		Vector2(160, 100), &"guardiao_brion", "Fera Marinha Alertada"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuCavernaHellbell", Vector2(2450, -30),
		&"caverna_hellbell", "Caverna da Serpente Hellbell",
		Vector2(150, 100), &"hellbell_boss", "Hellbell Alertada"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuCopaIntermediaria", Vector2(3200, -40),
		&"cn_copa_intermediaria", "Copa Intermediária da Árvore",
		Vector2(140, 90), &"guardiao_brion", "Fera Alada Alertada"
	)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalBlackWhale") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Black Whale 1"
		portal.map_subtitle = "Arco 9 — A Guerra de Sucessão de Kakin"
		portal.story_gate = StoryGate.new(8, 22, true)
		portal.story_gate.gate_title = "Embarque no Navio Imperial Black Whale 1"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 22 etapas do Continente Negro e conversar com Ging no Topo da Árvore antes de embarcar no Black Whale 1!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_continente_negro_cutscene(get_tree(), mudar_cena_cb)
