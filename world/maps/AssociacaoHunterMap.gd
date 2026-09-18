class_name AssociacaoHunterMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DA ASSOCIAÇÃO HUNTER (ARCO 7 - 20 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 7 (Eleição Hunter & Alluka):
# - Popula NPCs: Cheadle, Pariston, Leorio, Killua, Alluka, Gon Recuperado.
# - Densifica Auditório → Hospital → Rodovia → Tribuna (imersão).
# - Sensores Nen alinhados ao CanonQuestCatalog (cela_alluka + Zetsu rodovia).
# - STORY GATE: Exige conclusão das 20 etapas antes do Continente Negro.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"auditorio": false,
	"hospital": false,
	"masmorra": false,
	"rodovia": false,
	"tribuna": false
}


func _ready() -> void:
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.ASSOC)
	SagaHubConsolidator.densify_hub(self, SagaHubConsolidator.config_for_saga(7))
	SagaDistrictKit.densify_saga(self, 7)
	SagaTerritoryKit.attach(self, 7)
	SagaChapterBinder.bind_hub(self, 7)
	_garantir_dialogue_ui()
	_popular_npcs_arco7()
	_configurar_inimigos()
	_densificar_associacao()
	_instanciar_sensores_nen_associacao()
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

	if px >= 0 and px < 1000 and not _marcos_notificados["auditorio"]:
		_marcos_notificados["auditorio"] = true
		_toast_zona(hud, "🏛️ Auditório — Cheadle → Pariston. Testamento primeiro. Sem rush.")

	elif px >= 1000 and px < 1800 and not _marcos_notificados["hospital"]:
		_marcos_notificados["hospital"] = true
		_toast_zona(hud, "🏥 Hospital — Fale com Leorio (Gon em UTI). Depois Killua / Alluka.")

	elif px >= 1800 and px < 2400 and not _marcos_notificados["masmorra"]:
		_marcos_notificados["masmorra"] = true
		_toast_zona(hud, "🔐 Acesso Alluka — [G] Cela. Depois regras de Nanika. Sem pular.")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["rodovia"]:
		_marcos_notificados["rodovia"] = true
		_toast_zona(hud, "🛣️ Rodovia — Mordomos → Homens-Agulha → Illumi. GPS um de cada vez.")

	elif px >= 3600 and not _marcos_notificados["tribuna"]:
		_marcos_notificados["tribuna"] = true
		_toast_zona(hud, "🗳️ Tribuna — Cheadle / Leorio / Gon curado. Portal Continente após etapa 20.")


func _toast_zona(hud: Node, msg: String) -> void:
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(msg)
	elif EventBus != null:
		EventBus.emit_toast(msg, Color(0.45, 0.75, 0.95))


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(7)


func _popular_npcs_arco7() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[AssociacaoHunterMap] ERRO: NPC.tscn não encontrado!")
		return

	# 1. Cheadle Yorkshire (Auditório)
	if get_node_or_null("Cheadle") == null:
		var cheadle = scn_npc.instantiate()
		cheadle.name = "Cheadle"
		cheadle.position = Vector2(150, -60)
		NpcSpriteBinder.aplicar(cheadle, ["npc_recepcionista_elena", "npc_viajante_scout"])
		add_child(cheadle)
	var cheadle_n = get_node_or_null("Cheadle")
	if cheadle_n != null:
		if "npc_name" in cheadle_n:
			cheadle_n.npc_name = "Cheadle Yorkshire (Zodíaco Cão)"
		if "fala_padrao" in cheadle_n:
			cheadle_n.fala_padrao = "ORDEM: Fale comigo (testamento) → Pariston → Hospital (Leorio). Eleição longa — um passo."

	# 2. Pariston Hill (Auditório)
	if get_node_or_null("Pariston") == null:
		var pariston = scn_npc.instantiate()
		pariston.name = "Pariston"
		pariston.position = Vector2(300, -80)
		NpcSpriteBinder.aplicar(pariston, ["npc_viajante_scout"])
		add_child(pariston)
	var pariston_n = get_node_or_null("Pariston")
	if pariston_n != null:
		if "npc_name" in pariston_n:
			pariston_n.npc_name = "Pariston Hill (Vice-Presidente)"
		if "fala_padrao" in pariston_n:
			pariston_n.fala_padrao = "ORDEM: Fale comigo (jogo político). Depois Hospital — GPS. Divirta-se… com calma."

	# 3. Leorio (Hospital)
	if get_node_or_null("Leorio") == null:
		var scn_leorio = load("res://entities/npc/leorio/Leorio.tscn")
		var leorio
		if scn_leorio:
			leorio = scn_leorio.instantiate()
		else:
			leorio = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(leorio, ["npc_leorio"])
		leorio.name = "Leorio"
		add_child(leorio)
	var leorio_n = get_node_or_null("Leorio")
	if leorio_n != null:
		leorio_n.position = Vector2(1400, -80)
		if "npc_name" in leorio_n:
			leorio_n.npc_name = "Leorio Paradinight"
		if "fala_padrao" in leorio_n:
			leorio_n.fala_padrao = "ORDEM: Gon está na UTI. Fale comigo → Killua busca Alluka. Depois votação / soco — GPS."

	# 4. Killua (Hospital / resgate)
	if get_node_or_null("Killua") == null and get_node_or_null("KilluaAlluka") == null:
		var scn_killua = load("res://entities/npc/killua/Killua.tscn")
		var killua
		if scn_killua:
			killua = scn_killua.instantiate()
		else:
			killua = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(killua, ["npc_killua"])
		killua.name = "Killua"
		killua.position = Vector2(1600, -60)
		add_child(killua)
	# Reaproveita KilluaAlluka da cena antiga se existir
	var killua_n = get_node_or_null("Killua")
	if killua_n == null:
		killua_n = get_node_or_null("KilluaAlluka")
	if killua_n != null:
		killua_n.position = Vector2(1600, -60)
		if "npc_name" in killua_n:
			killua_n.npc_name = "Killua Zoldyck"
		if "fala_padrao" in killua_n:
			killua_n.fala_padrao = "ORDEM: Vou buscar Alluka. [G] Cela → regras Nanika → rodovia (Illumi). Sem rush."

	# 5. Alluka & Nanika (acesso / milagre)
	if get_node_or_null("Alluka") == null:
		var alluka = scn_npc.instantiate()
		alluka.name = "Alluka"
		alluka.position = Vector2(1950, -40)
		NpcSpriteBinder.aplicar(alluka, ["npc_killua", "npc_viajante_scout"])
		add_child(alluka)
	var alluka_n = get_node_or_null("Alluka")
	if alluka_n != null:
		if "npc_name" in alluka_n:
			alluka_n.npc_name = "Alluka & Nanika"
		if "fala_padrao" in alluka_n:
			alluka_n.fala_padrao = "ORDEM: Após [G] Cela, fale comigo (regras). No hospital: cure Gon quando o GPS pedir."

	# 6. Gon Freecss Recuperado (Tribuna final) — NPC genérico p/ match gon_recuperado
	if get_node_or_null("GonRecuperado") == null:
		var gon = scn_npc.instantiate()
		gon.name = "GonRecuperado"
		gon.position = Vector2(3800, -80)
		NpcSpriteBinder.aplicar(gon, ["npc_gon"])
		add_child(gon)
	var gon_n = get_node_or_null("GonRecuperado")
	if gon_n != null:
		gon_n.position = Vector2(3800, -80)
		if "npc_name" in gon_n:
			gon_n.npc_name = "Gon Freecss Recuperado"
		if "fala_padrao" in gon_n:
			gon_n.fala_padrao = "ORDEM: Estou de volta. Fale comigo → Leorio → Cheadle → despedida Killua. Portal depois da 20."


func _configurar_inimigos() -> void:
	var configs = {
		"AgenteIlicito1": {"id": &"mordomo_perseguidor", "nome": "Mordomo Perseguidor", "etapa": 10},
		"AgenteIlicito2": {"id": &"mordomo_perseguidor", "nome": "Mordomo Perseguidor", "etapa": 10},
		"NeedleMan1": {"id": &"humano_agulha", "nome": "Homem-Agulha de Illumi", "etapa": 11},
		"NeedleMan2": {"id": &"humano_agulha", "nome": "Homem-Agulha Elite", "etapa": 11},
		"IllumiInimigo": {"id": &"illumi", "nome": "Illumi Zoldyck (Chefe)", "etapa": 12}
	}

	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 7
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 7, es.quest_etapa, -1, null, es.enemy_name)

	# Illumi na rodovia (não na tribuna)
	var illumi = get_node_or_null("IllumiInimigo")
	if illumi != null:
		illumi.position = Vector2(3100, -40)

	_spawn_fillers_combate_associacao()


func _spawn_fillers_combate_associacao() -> void:
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if scn_enemy == null:
		return
	var fillers := [
		{"name": "MordomoMissao_C", "pos": Vector2(2500, 40), "id": &"mordomo_perseguidor", "label": "Mordomo Perseguidor C", "mission": true, "etapa": 10},
		{"name": "MordomoMissao_D", "pos": Vector2(2650, -30), "id": &"mordomo_perseguidor", "label": "Mordomo Perseguidor D", "mission": true, "etapa": 10},
		{"name": "NeedleMissao_C", "pos": Vector2(2750, 50), "id": &"humano_agulha", "label": "Homem-Agulha C", "mission": true, "etapa": 11},
		{"name": "NeedleMissao_D", "pos": Vector2(2880, -40), "id": &"humano_agulha", "label": "Homem-Agulha D", "mission": true, "etapa": 11},
		{"name": "NeedleMissao_E", "pos": Vector2(2950, 30), "id": &"humano_agulha", "label": "Homem-Agulha E", "mission": true, "etapa": 11},
		{"name": "NeedleMissao_F", "pos": Vector2(3200, 45), "id": &"humano_agulha", "label": "Homem-Agulha F", "mission": true, "etapa": 11},
		{"name": "NeedleMissao_G", "pos": Vector2(3300, -35), "id": &"humano_agulha", "label": "Homem-Agulha G", "mission": true, "etapa": 11},
		{"name": "NeedleMissao_H", "pos": Vector2(3400, 40), "id": &"humano_agulha", "label": "Homem-Agulha H", "mission": true, "etapa": 11},
		{"name": "AuditorioGuard_A", "pos": Vector2(450, 40), "id": &"mordomo_perseguidor", "label": "Guarda do Auditório", "mission": false, "etapa": -1},
		{"name": "HospitalAmbient_A", "pos": Vector2(1550, 50), "id": &"humano_agulha", "label": "Vigia do Hospital", "mission": false, "etapa": -1},
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
				es.quest_arc = 7
				es.quest_etapa = int(f["etapa"])
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, f["pos"], 7, es.quest_etapa, -1, null, es.enemy_name)
		add_child(mob)


func _densificar_associacao() -> void:
	var placas := [
		{"name": "PlacaAssocAuditorio", "pos": Vector2(200, -100), "text": "📍 Auditório — Cheadle → Pariston"},
		{"name": "PlacaAssocHospital", "pos": Vector2(1450, -110), "text": "📍 Hospital — Leorio / Gon UTI"},
		{"name": "PlacaAssocCela", "pos": Vector2(2000, -100), "text": "📍 Cela Alluka — [G] → Nanika"},
		{"name": "PlacaAssocRodovia", "pos": Vector2(2800, -100), "text": "📍 Rodovia — Mordomos → Illumi"},
		{"name": "PlacaAssocTribuna", "pos": Vector2(3750, -110), "text": "📍 Tribuna — Gon curado → Portal"},
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
		lbl.add_theme_color_override("font_color", Color(0.45, 0.8, 0.95, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		marker.add_child(lbl)
		add_child(marker)

	_popular_walkers_associacao()
	_plantar_props_associacao()


func _popular_walkers_associacao() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return
	var walkers := [
		{"name": "ZodiacoAmbientA", "pos": Vector2(400, 50), "npc": "Zodíaco Observador", "fala": "ORDEM: Cheadle lê o testamento. Depois Pariston. Hospital só quando o GPS pedir.", "ids": ["npc_guarda_fronteira"], "r": 40.0},
		{"name": "ReporterEleicao", "pos": Vector2(550, -40), "npc": "Repórter da Eleição", "fala": "Quórum 95%. Siga o GPS — um debate de cada vez. Sem rush no plenário.", "ids": ["npc_viajante_scout"], "r": 42.0},
		{"name": "EnfermeiraHunter", "pos": Vector2(1300, 45), "npc": "Enfermeira Hunter", "fala": "ORDEM: Fale com Leorio na UTI. Gon está frágil. Killua vai buscar Alluka.", "ids": ["npc_viajante_scout"], "r": 36.0},
		{"name": "GuardaCela", "pos": Vector2(1900, 40), "npc": "Guarda da Masmorra", "fala": "ORDEM: [G] Cela de Alluka. Depois fale com Alluka (regras Nanika). Sem pular pedidos.", "ids": ["npc_guarda_fronteira"], "r": 34.0},
		{"name": "MotoristaRodovia", "pos": Vector2(2550, 50), "npc": "Motorista da Ambulância", "fala": "ORDEM: Mordomos (GPS) → Homens-Agulha → Illumi. Abra a rota. Sem rush.", "ids": ["npc_guarda_fronteira"], "r": 38.0},
		{"name": "HunterVotante", "pos": Vector2(3600, 40), "npc": "Hunter Votante", "fala": "Após Illumi: Cheadle → Leorio (soco) → Nanika cura → Gon curado. Portal só na 20.", "ids": ["npc_viajante_scout"], "r": 36.0},
		{"name": "OficialTribuna", "pos": Vector2(4000, -40), "npc": "Oficial da Tribuna", "fala": "ORDEM: Cheadle presidente → despedida Killua/Alluka. Portal Continente Negro após etapa 20.", "ids": ["npc_guarda_fronteira"], "r": 32.0},
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


func _plantar_props_associacao() -> void:
	if get_node_or_null("PropsEstruturaAssociacao") != null:
		return
	var root := Node2D.new()
	root.name = "PropsEstruturaAssociacao"
	add_child(root)
	var specs := [
		{"name": "MarcoAuditorio", "pos": Vector2(220, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
		{"name": "LanternaAuditorio", "pos": Vector2(500, 20), "tex": "res://assets/sprites/objects/hunter_road_lantern.png"},
		{"name": "PosteHospital", "pos": Vector2(1450, 20), "tex": "res://assets/sprites/objects/phase3_lantern_post.png"},
		{"name": "MonolitoCela", "pos": Vector2(2000, 20), "tex": "res://assets/sprites/objects/nen_stone_monolith.png"},
		{"name": "RochaRodovia", "pos": Vector2(2700, 25), "tex": "res://assets/sprites/objects/phase2_rock_boulder.png"},
		{"name": "PosteRodovia", "pos": Vector2(3000, 20), "tex": "res://assets/sprites/objects/phase3_lantern_post.png"},
		{"name": "MarcoTribuna", "pos": Vector2(3700, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
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


## Gyo/Ko/Zetsu alinhados ao CanonQuestCatalog (arco 7).
func _instanciar_sensores_nen_associacao() -> void:
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoCelaAlluka", Vector2(2050, -30),
			&"cela_alluka", "Cela / Cofre de Alluka",
			"Aura selada da masmorra Zoldyck. Depois fale com Alluka (regras Nanika). Um passo.",
			"Especialização", 2, Color(0.7, 0.55, 1.0, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoUtiGon", Vector2(1480, -20),
			&"uti_gon_associacao", "UTI de Gon",
			"Aura frágil sob suporte vital. Fale com Leorio. Killua busca Alluka — GPS.",
			"Intensificação", 1, Color(0.45, 0.9, 0.7, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoPlenario", Vector2(3700, -40),
			&"plenario_eleicao", "Plenário da Eleição",
			"Pressão política residual. Após Illumi: Cheadle → Leorio → milagre. Sem rush.",
			"Emissão", 1, Color(0.5, 0.75, 1.0, 0.9)
		)
		NenSensorFactory.criar_ko(
			self, "KoGradeCela", Vector2(2100, 35),
			"Grade Selada da Cela", &"pocao_aura", &"assoc_ko_cela"
		)
		NenSensorFactory.criar_ko(
			self, "KoBarreiraRodovia", Vector2(2900, 35),
			"Barreira Rachada da Rodovia", &"elixir_aura"
		)

	NenSensorFactory.criar_zetsu(
		self, "ZetsuCorredorHospital", Vector2(1550, -50),
		&"assoc_corredor_hospital", "Corredor do Hospital Hunter",
		Vector2(140, 90), &"humano_agulha", "Vigia Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuRodoviaIllumi", Vector2(2800, -20),
		&"assoc_rodovia_illumi", "Rodovia Noturna (Illumi)",
		Vector2(160, 100), &"mordomo_perseguidor", "Mordomo Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuTribunaBastidores", Vector2(3900, -30),
		&"assoc_tribuna_bastidores", "Bastidores da Tribuna",
		Vector2(130, 90), &"humano_agulha", "Agente Alertado"
	)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalContinenteNegro") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Continente Negro"
		portal.map_subtitle = "Arco 8 — A Expedição de Beyond & A Árvore do Mundo"
		portal.story_gate = StoryGate.new(7, 20, true)
		portal.story_gate.gate_title = "Expedição da Associação Hunter"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 20 etapas da Eleição Hunter e curar Gon antes de partir para a Expedição do Continente Negro!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_eleicao_hunter_cutscene(get_tree(), mudar_cena_cb)
