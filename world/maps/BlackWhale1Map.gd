class_name BlackWhale1Map
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DO BLACK WHALE 1 (ARCO 9 - 26 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 9 (Guerra de Sucessão de Kakin):
# - Popula NPCs: Kurapika, Rainha Oito, Vaso, Hinrigh, Hisoka, Chrollo, Cheadle.
# - Densifica Convés 1 → Máfia → Aposentos → Conveses Profundos.
# - Sensores Nen alinhados ao CanonQuestCatalog (Gyo/Ko/Zetsu).
# - STORY GATE: Exige conclusão das 26 etapas antes da Consagração Final no Lobby.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"conves_1": false,
	"conves_3": false,
	"aposentos": false,
	"porao": false
}


func _ready() -> void:
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.WHALE)
	SagaHubConsolidator.densify_hub(self, SagaHubConsolidator.config_for_saga(9))
	SagaDistrictKit.densify_saga(self, 9)
	SagaTerritoryKit.attach(self, 9)
	SagaChapterBinder.bind_hub(self, 9)
	_garantir_dialogue_ui()
	_popular_npcs_arco9()
	_configurar_inimigos()
	_densificar_black_whale()
	_instanciar_sensores_nen_black_whale()
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

	if px >= 0 and px < 1200 and not _marcos_notificados["conves_1"]:
		_marcos_notificados["conves_1"] = true
		_toast_zona(hud, "🚢 Convés 1 — Kurapika → Rainha Oito → Vaso. Depois [G] assassinato.")

	elif px >= 1200 and px < 2400 and not _marcos_notificados["conves_3"]:
		_marcos_notificados["conves_3"] = true
		_toast_zona(hud, "🏙️ Máfia — Hinrigh → [G] Heil-Ly. GPS um assassino de cada vez.")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["aposentos"]:
		_marcos_notificados["aposentos"] = true
		_toast_zona(hud, "👑 Aposentos Tserriednich — [Z] infiltração → [G] Besta Dupla Face.")

	elif px >= 3600 and not _marcos_notificados["porao"]:
		_marcos_notificados["porao"] = true
		_toast_zona(hud, "⚓ Profundos — Chrollo / Hisoka → Woble → Cheadle. Portal após 26.")


func _toast_zona(hud: Node, msg: String) -> void:
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(msg)
	elif EventBus != null:
		EventBus.emit_toast(msg, Color(0.55, 0.65, 0.9))


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(9)


func _popular_npcs_arco9() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[BlackWhale1Map] ERRO: NPC.tscn não encontrado!")
		return

	# 1. Kurapika (Convés 1)
	if get_node_or_null("Kurapika") == null:
		var scn_kurapika = load("res://entities/npc/kurapika/Kurapika.tscn")
		var kurapika
		if scn_kurapika:
			kurapika = scn_kurapika.instantiate()
		else:
			kurapika = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(kurapika, ["npc_kurapika", "npc_viajante_scout"])
		kurapika.name = "Kurapika"
		add_child(kurapika)
	var kurapika_n = get_node_or_null("Kurapika")
	if kurapika_n != null:
		kurapika_n.position = Vector2(150, -60)
		if "npc_name" in kurapika_n:
			kurapika_n.npc_name = "Kurapika"
		if "fala_padrao" in kurapika_n:
			kurapika_n.fala_padrao = "ORDEM: Fale comigo → Rainha Oito → Vaso. Depois [G] assassinato. Sem rush no Convés 1."

	# 2. Rainha Oito & Príncipe Woble
	if get_node_or_null("RainhaOito") == null:
		var oito = scn_npc.instantiate()
		oito.name = "RainhaOito"
		oito.position = Vector2(300, -80)
		NpcSpriteBinder.aplicar(oito, ["npc_recepcionista_elena", "npc_viajante_scout"])
		add_child(oito)
	var oito_n = get_node_or_null("RainhaOito")
	if oito_n != null:
		oito_n.position = Vector2(300, -80)
		if "npc_name" in oito_n:
			oito_n.npc_name = "Rainha Oito & Príncipe Woble"
		if "fala_padrao" in oito_n:
			oito_n.fala_padrao = "ORDEM: Estabeleça o perímetro. Depois Vaso Sagrado → [G] primeiro assassinato. Proteja Woble."

	# 3. Vaso Sagrado de Kakin
	if get_node_or_null("VasoKakin") == null:
		var vaso = scn_npc.instantiate()
		vaso.name = "VasoKakin"
		vaso.position = Vector2(450, -50)
		NpcSpriteBinder.aplicar(vaso, ["npc_guarda_fronteira"])
		add_child(vaso)
	var vaso_n = get_node_or_null("VasoKakin")
	if vaso_n != null:
		vaso_n.position = Vector2(450, -50)
		if "npc_name" in vaso_n:
			vaso_n.npc_name = "Vaso Sagrado de Kakin"
		if "fala_padrao" in vaso_n:
			vaso_n.fala_padrao = "ORDEM: Examine o Vaso. Depois [G] assassinato no corredor. Bestas Parasitas vêm no GPS."

	# 4. Hinrigh Biganduffno (Máfia Xi-Yu)
	if get_node_or_null("Hinrigh") == null:
		var hinrigh = scn_npc.instantiate()
		hinrigh.name = "Hinrigh"
		hinrigh.position = Vector2(1600, -80)
		NpcSpriteBinder.aplicar(hinrigh, ["npc_guarda_fronteira", "npc_viajante_scout"])
		add_child(hinrigh)
	var hinrigh_n = get_node_or_null("Hinrigh")
	if hinrigh_n != null:
		hinrigh_n.position = Vector2(1600, -80)
		if "npc_name" in hinrigh_n:
			hinrigh_n.npc_name = "Hinrigh (Família Xi-Yu)"
		if "fala_padrao" in hinrigh_n:
			hinrigh_n.fala_padrao = "ORDEM: Fale comigo (Biohazard) → [G] seita Heil-Ly. Depois GPS: assassinos. Sem rush."

	# 5. Hisoka (Conveses intermediários / profundos)
	if get_node_or_null("Hisoka") == null:
		var scn_hisoka = load("res://entities/npc/hisoka/Hisoka.tscn")
		var hisoka
		if scn_hisoka:
			hisoka = scn_hisoka.instantiate()
		else:
			hisoka = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(hisoka, ["npc_hisoka", "npc_viajante_scout"])
		hisoka.name = "Hisoka"
		add_child(hisoka)
	var hisoka_n = get_node_or_null("Hisoka")
	if hisoka_n != null:
		hisoka_n.position = Vector2(3200, -70)
		if "npc_name" in hisoka_n:
			hisoka_n.npc_name = "Hisoka Morow"
		if "fala_padrao" in hisoka_n:
			hisoka_n.fala_padrao = "ORDEM: Marcas de goma — fale comigo. Depois Chrollo (trégua). Sem rush no duelo."

	# 6. Chrollo Lucilfer (Conveses Profundos)
	if get_node_or_null("Chrollo") == null:
		var scn_chrollo = load("res://entities/npc/chrollo/Chrollo.tscn")
		var chrollo
		if scn_chrollo:
			chrollo = scn_chrollo.instantiate()
		else:
			chrollo = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(chrollo, ["npc_viajante_scout"])
		chrollo.name = "Chrollo"
		add_child(chrollo)
	var chrollo_n = get_node_or_null("Chrollo")
	if chrollo_n != null:
		chrollo_n.position = Vector2(3600, -100)
		if "npc_name" in chrollo_n:
			chrollo_n.npc_name = "Chrollo Lucilfer"
		if "fala_padrao" in chrollo_n:
			chrollo_n.fala_padrao = "ORDEM: Fale comigo (caça Hisoka) → negocie trégua. Depois [Z] aposentos Tserriednich."

	# 7. Presidente Cheadle (conclusão / consagração)
	if get_node_or_null("Cheadle") == null:
		var cheadle = scn_npc.instantiate()
		cheadle.name = "Cheadle"
		cheadle.position = Vector2(3950, -60)
		NpcSpriteBinder.aplicar(cheadle, ["npc_recepcionista_elena", "npc_viajante_scout"])
		add_child(cheadle)
	var cheadle_n = get_node_or_null("Cheadle")
	if cheadle_n != null:
		cheadle_n.position = Vector2(3950, -60)
		if "npc_name" in cheadle_n:
			cheadle_n.npc_name = "Presidente Cheadle"
		if "fala_padrao" in cheadle_n:
			cheadle_n.fala_padrao = "ORDEM: Consagração — fale comigo. Portal Lobby após etapa 26. História 100%."


func _configurar_inimigos() -> void:
	var configs = {
		"GuardaRealKakin1": {"id": &"besta_parasita", "nome": "Besta Parasita Guardiã", "etapa": 6},
		"GuardaRealKakin2": {"id": &"assassino_heilly", "nome": "Assassino da Família Heil-Ly", "etapa": 11},
		"CapangaTserriednich": {"id": &"besta_tserriednich", "nome": "Besta Guardiã de Tserriednich", "etapa": 18},
		"BestaNenGuardiã": {"id": &"tserriednich_boss", "nome": "Príncipe Tserriednich Boss", "etapa": 19},
		"AssassinoMafia": {"id": &"boss_final_kakin", "nome": "Comandante da Conspiração Boss", "etapa": 24}
	}

	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 9
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 9, es.quest_etapa, -1, null, es.enemy_name)

	_spawn_fillers_combate_black_whale()


func _spawn_fillers_combate_black_whale() -> void:
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if scn_enemy == null:
		return
	var fillers := [
		{"name": "ParasitaMissao_B", "pos": Vector2(700, 40), "id": &"besta_parasita", "label": "Besta Parasita B", "mission": true, "etapa": 6},
		{"name": "ParasitaMissao_C", "pos": Vector2(850, -40), "id": &"besta_parasita", "label": "Besta Parasita C", "mission": true, "etapa": 6},
		{"name": "HeillyMissao_B", "pos": Vector2(1750, 40), "id": &"assassino_heilly", "label": "Heil-Ly B", "mission": true, "etapa": 11},
		{"name": "HeillyMissao_C", "pos": Vector2(1900, -40), "id": &"assassino_heilly", "label": "Heil-Ly C", "mission": true, "etapa": 11},
		{"name": "HeillyMissao_D", "pos": Vector2(2050, 50), "id": &"assassino_heilly", "label": "Heil-Ly D", "mission": true, "etapa": 11},
		{"name": "HeillyMissao_E", "pos": Vector2(2200, -30), "id": &"assassino_heilly", "label": "Heil-Ly E", "mission": true, "etapa": 11},
		{"name": "HeillyMissao_F", "pos": Vector2(2350, 40), "id": &"assassino_heilly", "label": "Heil-Ly F", "mission": true, "etapa": 11},
		{"name": "RevoltaMissao_A", "pos": Vector2(1450, 45), "id": &"assassino_heilly", "label": "Guarda Rebelde A", "mission": true, "etapa": 20},
		{"name": "RevoltaMissao_B", "pos": Vector2(1550, -35), "id": &"assassino_heilly", "label": "Guarda Rebelde B", "mission": true, "etapa": 20},
		{"name": "RevoltaMissao_C", "pos": Vector2(1650, 50), "id": &"assassino_heilly", "label": "Guarda Rebelde C", "mission": true, "etapa": 20},
		{"name": "RevoltaMissao_D", "pos": Vector2(1750, -25), "id": &"assassino_heilly", "label": "Guarda Rebelde D", "mission": true, "etapa": 20},
		{"name": "ParasitaProfundo_A", "pos": Vector2(3700, 40), "id": &"besta_parasita", "label": "Parasita do Porao A", "mission": true, "etapa": 21},
		{"name": "ParasitaProfundo_B", "pos": Vector2(3850, -40), "id": &"besta_parasita", "label": "Parasita do Porao B", "mission": true, "etapa": 21},
		{"name": "ConvésAmbient_A", "pos": Vector2(550, 40), "id": &"besta_parasita", "label": "Eco Parasita", "mission": false, "etapa": -1},
		{"name": "MafiaAmbient_A", "pos": Vector2(1300, 40), "id": &"assassino_heilly", "label": "Capanga Mafioso", "mission": false, "etapa": -1},
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
				es.quest_arc = 9
				es.quest_etapa = int(f["etapa"])
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, f["pos"], 9, es.quest_etapa, -1, null, es.enemy_name)
		add_child(mob)


func _densificar_black_whale() -> void:
	var placas := [
		{"name": "PlacaBWConves1", "pos": Vector2(200, -100), "text": "📍 Convés 1 — Kurapika → Woble"},
		{"name": "PlacaBWMafia", "pos": Vector2(1500, -100), "text": "📍 Máfia — Hinrigh → Heil-Ly"},
		{"name": "PlacaBWAposentos", "pos": Vector2(2700, -110), "text": "📍 Aposentos — [Z] → [G] Besta"},
		{"name": "PlacaBWProfundos", "pos": Vector2(3700, -110), "text": "📍 Profundos — Chrollo / Hisoka"},
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
		lbl.add_theme_color_override("font_color", Color(0.55, 0.7, 0.95, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		marker.add_child(lbl)
		add_child(marker)

	_popular_walkers_black_whale()
	_plantar_props_black_whale()


func _popular_walkers_black_whale() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return
	var walkers := [
		{"name": "GuardaConvés1", "pos": Vector2(400, 50), "npc": "Guarda do Convés 1", "fala": "ORDEM: Kurapika → Rainha → Vaso. Sem [G] no assassinato você não vê a aura.", "ids": ["npc_guarda_fronteira"], "r": 40.0},
		{"name": "MordomoNostrade", "pos": Vector2(600, -40), "npc": "Mordomo Nostrade", "fala": "Woble é o 14º. Proteja a câmara. Depois bestas parasitárias no GPS.", "ids": ["npc_viajante_scout"], "r": 38.0},
		{"name": "CapangaXiYu", "pos": Vector2(1400, 45), "npc": "Capanga Xi-Yu", "fala": "ORDEM: Fale com Hinrigh. Depois [G] seita Heil-Ly. Sem rush nos conveses.", "ids": ["npc_guarda_fronteira"], "r": 36.0},
		{"name": "EspiaoHeilLy", "pos": Vector2(2000, 40), "npc": "Espião do Convés 4", "fala": "ORDEM: [G] Contágio de Morena. Depois GPS: 6 assassinos Heil-Ly. Um de cada vez.", "ids": ["npc_viajante_scout"], "r": 40.0},
		{"name": "ScoutAposentos", "pos": Vector2(2550, -50), "npc": "Scout dos Aposentos", "fala": "ORDEM: [Z] Aposentos Tserriednich. Sem Zetsu = sentinelas. Depois [G] Besta Dupla Face.", "ids": ["npc_guarda_fronteira"], "r": 38.0},
		{"name": "MembroTrupe", "pos": Vector2(3450, 45), "npc": "Membro da Trupe", "fala": "Chrollo caça Hisoka. Fale com ambos. Negocie trégua antes dos aposentos finais.", "ids": ["npc_viajante_scout"], "r": 36.0},
		{"name": "OficialComando", "pos": Vector2(3900, 40), "npc": "Oficial de Comando", "fala": "ORDEM: Boss conspiração → Kurapika (ordem) → Cheadle. Portal Lobby após etapa 26.", "ids": ["npc_guarda_fronteira"], "r": 32.0},
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


func _plantar_props_black_whale() -> void:
	if get_node_or_null("PropsEstruturaBlackWhale") != null:
		return
	var root := Node2D.new()
	root.name = "PropsEstruturaBlackWhale"
	add_child(root)
	var specs := [
		{"name": "MarcoConves1", "pos": Vector2(250, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
		{"name": "LanternaConves1", "pos": Vector2(500, 20), "tex": "res://assets/sprites/objects/hunter_road_lantern.png"},
		{"name": "PosteMafia", "pos": Vector2(1550, 20), "tex": "res://assets/sprites/objects/phase3_lantern_post.png"},
		{"name": "BarrilArmazem", "pos": Vector2(1850, 25), "tex": "res://assets/sprites/objects/phase2_rock_boulder.png"},
		{"name": "MonolitoAposentos", "pos": Vector2(2650, 20), "tex": "res://assets/sprites/objects/nen_stone_monolith.png"},
		{"name": "ArbustoCorredor", "pos": Vector2(2900, 20), "tex": "res://assets/sprites/objects/calibration_bush_a.png"},
		{"name": "MarcoProfundos", "pos": Vector2(3750, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
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


## Gyo/Ko/Zetsu alinhados ao CanonQuestCatalog (arco 9).
func _instanciar_sensores_nen_black_whale() -> void:
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoPrimeiroAssassinato", Vector2(750, -20),
			&"primeiro_assassinato_kakin", "Primeiro Assassinato a Bordo",
			"Guardas eliminados por Nen invisível. Depois Stealth Dolphin com Kurapika.",
			"Especialização", 2, Color(0.85, 0.35, 0.4, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoSeitaHeilLy", Vector2(1950, -40),
			&"seita_heilly", "Contágio da Seita Heil-Ly",
			"Níveis de sangue de Morena. Depois GPS: assassinos Heil-Ly.",
			"Manipulação", 2, Color(0.7, 0.25, 0.55, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoBestaTserriednich", Vector2(2850, -40),
			&"besta_tserriednich", "Aura da Besta de Dupla Face",
			"Rosto de mulher, patas de cavalo. Depois Zetsu do Futuro com Kurapika.",
			"Especialização", 2, Color(0.9, 0.55, 0.25, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoMarcaBungee", Vector2(3100, -30),
			&"bw_marca_bungee", "Marca de Bungee Gum",
			"Goma elástica de Hisoka. Fale com ele nos armazéns.",
			"Transformação", 2, Color(0.95, 0.45, 0.7, 0.9)
		)
		NenSensorFactory.criar_ko(
			self, "KoPortaCegada", Vector2(900, 35),
			"Porta Cegada do Corredor", &"pocao_aura", &"bw_ko_corredor"
		)
		NenSensorFactory.criar_ko(
			self, "KoCofreXiYu", Vector2(1700, 35),
			"Cofre Selado Xi-Yu", &"elixir_aura"
		)

	NenSensorFactory.criar_zetsu(
		self, "ZetsuAposentosTserriednich", Vector2(2600, -20),
		&"aposentos_tserriednich", "Aposentos do 4º Príncipe Tserriednich",
		Vector2(160, 100), &"besta_tserriednich", "Sentinela dos Aposentos"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuArmazemProfundo", Vector2(3500, -30),
		&"bw_armazem_profundo", "Armazém dos Conveses Profundos",
		Vector2(150, 100), &"assassino_heilly", "Assassino Alertado"
	)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalLobby") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Lobby Central (Conclusão Suprema)"
		portal.map_subtitle = "Vitória Total — Modo História 100% Concluído!"
		portal.story_gate = StoryGate.new(9, 26, true)
		portal.story_gate.gate_title = "Consagração do Maior Caçador da História"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 26 etapas da Guerra de Sucessão de Kakin antes de eternizar sua lenda!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_guerra_sucessao_cutscene(get_tree(), mudar_cena_cb)
