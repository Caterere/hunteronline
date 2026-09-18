class_name NGLFormigasMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DAS FORMIGAS CHIMERA (ARCO 6 - 48 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 6 (Formigas Chimera):
# - Popula NPCs: Kite, Killua, Netero, Morel, Knuckle, Shoot, Gon, Meruem.
# - Densifica Fronteira → Fábrica → Peijin → Palácio → Tumba (imersão longa).
# - Sensores Nen alinhados ao CanonQuestCatalog (Gyo/Ko/Zetsu).
# - STORY GATE: Exige conclusão das 48 etapas antes da Associação Hunter.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"fronteira": false,
	"fabrica": false,
	"peijin": false,
	"palacio": false,
	"tumba": false
}


func _ready() -> void:
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.NGL)
	SagaHubConsolidator.densify_hub(self, SagaHubConsolidator.config_for_saga(6))
	SagaDistrictKit.densify_saga(self, 6)
	SagaTerritoryKit.attach(self, 6)
	SagaChapterBinder.bind_hub(self, 6)
	_garantir_dialogue_ui()
	_popular_npcs_arco6()
	_configurar_inimigos()
	_densificar_ngl()
	_instanciar_sensores_nen_ngl()
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

	if px >= 0 and px < 1000 and not _marcos_notificados["fronteira"]:
		_marcos_notificados["fronteira"] = true
		_toast_zona(hud, "🌲 Fronteira NGL — Fale com Kite. Formigas à frente. Sem rush.")

	elif px >= 1000 and px < 1800 and not _marcos_notificados["fabrica"]:
		_marcos_notificados["fabrica"] = true
		_toast_zona(hud, "🏭 Fábrica D2 — [G] laboratório Gyro. Depois Rammot / ninho (GPS).")

	elif px >= 1800 and px < 2600 and not _marcos_notificados["peijin"]:
		_marcos_notificados["peijin"] = true
		_toast_zona(hud, "🎖️ Base Peijin — Netero → Morel → Knuckle/Shoot. Um mentor de cada vez.")

	elif px >= 2600 and px < 3600 and not _marcos_notificados["palacio"]:
		_marcos_notificados["palacio"] = true
		_toast_zona(hud, "🏛️ Palácio Peijin — [Z] fronteira Goruto · [G] portas Knov. Guarda Real à frente.")

	elif px >= 3600 and not _marcos_notificados["tumba"]:
		_marcos_notificados["tumba"] = true
		_toast_zona(hud, "🪦 Tumba — Meruem / Netero. Portal Associação só após as 48 etapas.")


func _toast_zona(hud: Node, msg: String) -> void:
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(msg)
	elif EventBus != null:
		EventBus.emit_toast(msg, Color(0.55, 0.85, 0.45))


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(6)


func _popular_npcs_arco6() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[NGLFormigasMap] ERRO: NPC.tscn não encontrado!")
		return

	# 1. Kite (Fronteira NGL)
	if get_node_or_null("Kite") == null:
		var kite = scn_npc.instantiate()
		kite.name = "Kite"
		kite.position = Vector2(120, -50)
		NpcSpriteBinder.aplicar(kite, ["npc_viajante_scout", "npc_guarda_fronteira"])
		add_child(kite)
	var kite_n = get_node_or_null("Kite")
	if kite_n != null:
		if "npc_name" in kite_n:
			kite_n.npc_name = "Kite (Caçador de Contratos)"
		if "fala_padrao" in kite_n:
			kite_n.fala_padrao = "ORDEM: Fale comigo → derrote formigas (GPS) → [G] Fábrica D2. Se Pitou aparecer: fujam. Sem rush."

	# 2. Killua (fuga / Godspeed — fronteira)
	if get_node_or_null("Killua") == null:
		var scn_killua = load("res://entities/npc/killua/Killua.tscn")
		var killua
		if scn_killua:
			killua = scn_killua.instantiate()
		else:
			killua = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(killua, ["npc_killua"])
		killua.name = "Killua"
		killua.position = Vector2(280, 80)
		add_child(killua)
	var killua_n = get_node_or_null("Killua")
	if killua_n != null:
		if "npc_name" in killua_n:
			killua_n.npc_name = "Killua Zoldyck"
		if "fala_padrao" in killua_n:
			killua_n.fala_padrao = "ORDEM: Após Kite, siga o GPS. Eu cubro a fuga. Godspeed / agulha depois — um passo."
		killua_n.position = Vector2(280, 80)

	# 3. Presidente Isaac Netero (Base Peijin)
	if get_node_or_null("Netero") == null:
		var scn_netero = load("res://entities/npc/netero/Netero.tscn")
		var netero
		if scn_netero:
			netero = scn_netero.instantiate()
		else:
			netero = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(netero, ["npc_netero"])
		netero.name = "Netero"
		add_child(netero)
	var netero_n = get_node_or_null("Netero")
	if netero_n != null:
		netero_n.position = Vector2(1900, -100)
		if "npc_name" in netero_n:
			netero_n.npc_name = "Presidente Isaac Netero"
		if "fala_padrao" in netero_n:
			netero_n.fala_padrao = "ORDEM: Fale comigo → Morel → Knuckle/Shoot. Invasão só quando o GPS mandar. Sem rush."

	# 4. Morel Mackernasey
	if get_node_or_null("Morel") == null:
		var morel = scn_npc.instantiate()
		morel.name = "Morel"
		morel.position = Vector2(2050, -80)
		NpcSpriteBinder.aplicar(morel, ["npc_guarda_fronteira", "npc_viajante_scout"])
		add_child(morel)
	var morel_n = get_node_or_null("Morel")
	if morel_n != null:
		if "npc_name" in morel_n:
			morel_n.npc_name = "Morel Mackernasey"
		if "fala_padrao" in morel_n:
			morel_n.fala_padrao = "ORDEM: Prove resolução comigo → depois Knuckle e Shoot. Deep Purple na hora zero. Um de cada vez."

	# 5. Knuckle Bine
	if get_node_or_null("Knuckle") == null:
		var knuckle = scn_npc.instantiate()
		knuckle.name = "Knuckle"
		knuckle.position = Vector2(2200, -60)
		NpcSpriteBinder.aplicar(knuckle, ["npc_lutador_arena_ambient", "npc_viajante_scout"])
		add_child(knuckle)
	var knuckle_n = get_node_or_null("Knuckle")
	if knuckle_n != null:
		if "npc_name" in knuckle_n:
			knuckle_n.npc_name = "Knuckle Bine"
		if "fala_padrao" in knuckle_n:
			knuckle_n.fala_padrao = "ORDEM: Fale comigo (A.P.R.) → Shoot. Sem recuar no GPS. Juros de aura — um passo."

	# 6. Shoot McMahon
	if get_node_or_null("Shoot") == null:
		var shoot = scn_npc.instantiate()
		shoot.name = "Shoot"
		shoot.position = Vector2(2350, -60)
		NpcSpriteBinder.aplicar(shoot, ["npc_viajante_scout"])
		add_child(shoot)
	var shoot_n = get_node_or_null("Shoot")
	if shoot_n != null:
		if "npc_name" in shoot_n:
			shoot_n.npc_name = "Shoot McMahon"
		if "fala_padrao" in shoot_n:
			shoot_n.fala_padrao = "ORDEM: Fale comigo (Hotel Rafflesia) → depois GPS (nascimento / Goruto). Sem pular."

	# 7. Gon (reunião pré-invasão)
	if get_node_or_null("Gon") == null:
		var scn_gon = load("res://entities/npc/gon/Gon.tscn")
		var gon
		if scn_gon:
			gon = scn_gon.instantiate()
		else:
			gon = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(gon, ["npc_gon"])
		gon.name = "Gon"
		gon.position = Vector2(2500, 40)
		add_child(gon)
	var gon_n = get_node_or_null("Gon")
	if gon_n != null:
		if "npc_name" in gon_n:
			gon_n.npc_name = "Gon Freecss"
		if "fala_padrao" in gon_n:
			gon_n.fala_padrao = "ORDEM: Reunião na porta do Knov quando o GPS pedir. Pitou depois. Sem rush sozinho."

	# 8. Rei Meruem (Aposentos / Gungi)
	if get_node_or_null("MeruemReiNPC") == null:
		var meruem = scn_npc.instantiate()
		meruem.name = "MeruemReiNPC"
		meruem.position = Vector2(3700, -120)
		NpcSpriteBinder.aplicar(meruem, ["npc_netero", "npc_guarda_fronteira"])
		add_child(meruem)
	var meruem_n = get_node_or_null("MeruemReiNPC")
	if meruem_n != null:
		if "npc_name" in meruem_n:
			meruem_n.npc_name = "Rei Meruem"
		if "fala_padrao" in meruem_n:
			meruem_n.fala_padrao = "ORDEM: Observe o Gungi (GPS). Não ataque o Rei fora da etapa. Portal Associação só após 48."


func _configurar_inimigos() -> void:
	var configs = {
		"FormigaSoldado1": {"id": &"formiga_soldado", "nome": "Formiga Soldado Quimera", "etapa": 3},
		"FormigaSoldado2": {"id": &"formiga_oficial", "nome": "Formiga Oficial Quimera", "etapa": 5},
		"EsquadraoQuimera": {"id": &"guarda_peijin", "nome": "Guarda de Peijin", "etapa": 19},
		"YoupiInimigo": {"id": &"youpi", "nome": "Menthuthuyoupi (Guarda Real)", "etapa": 32},
		"ShaiapoufInimigo": {"id": &"shaiapouf", "nome": "Shaiapouf (Guarda Real)", "etapa": 33},
		"NeferpitouInimigo": {"id": &"neferpitou", "nome": "Neferpitou Boss", "etapa": 43},
		"MeruemRei": {"id": &"meruem", "nome": "Rei Meruem", "etapa": 46}
	}

	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 6
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 6, es.quest_etapa, -1, null, es.enemy_name)

	_spawn_fillers_combate_ngl()


func _spawn_fillers_combate_ngl() -> void:
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if scn_enemy == null:
		return
	var fillers := [
		{"name": "FormigaMissao_B", "pos": Vector2(700, 40), "id": &"formiga_soldado", "label": "Formiga Soldado B", "mission": true, "etapa": 3},
		{"name": "FormigaMissao_C", "pos": Vector2(850, -40), "id": &"formiga_soldado", "label": "Formiga Soldado C", "mission": true, "etapa": 3},
		{"name": "FormigaMissao_D", "pos": Vector2(1000, 50), "id": &"formiga_soldado", "label": "Formiga Soldado D", "mission": true, "etapa": 3},
		{"name": "FormigaMissao_E", "pos": Vector2(1100, -30), "id": &"formiga_soldado", "label": "Formiga Soldado E", "mission": true, "etapa": 3},
		{"name": "FormigaOficial_B", "pos": Vector2(1500, 40), "id": &"formiga_oficial", "label": "Formiga Oficial B", "mission": true, "etapa": 5},
		{"name": "FormigaColinas_A", "pos": Vector2(1300, -50), "id": &"formiga_soldado", "label": "Formiga das Colinas A", "mission": true, "etapa": 7},
		{"name": "FormigaColinas_B", "pos": Vector2(1450, 30), "id": &"formiga_soldado", "label": "Formiga das Colinas B", "mission": true, "etapa": 7},
		{"name": "FormigaColinas_C", "pos": Vector2(1600, -40), "id": &"formiga_soldado", "label": "Formiga das Colinas C", "mission": true, "etapa": 7},
		{"name": "GuardaPeijin_B", "pos": Vector2(2700, 40), "id": &"guarda_peijin", "label": "Guarda de Peijin B", "mission": true, "etapa": 19},
		{"name": "GuardaPeijin_C", "pos": Vector2(2850, -30), "id": &"guarda_peijin", "label": "Guarda de Peijin C", "mission": true, "etapa": 19},
		{"name": "GuardaPeijin_D", "pos": Vector2(3000, 50), "id": &"guarda_peijin", "label": "Guarda de Peijin D", "mission": true, "etapa": 19},
		{"name": "FormigaAmbient_A", "pos": Vector2(500, 50), "id": &"formiga_soldado", "label": "Patrulha da Fronteira", "mission": false, "etapa": -1},
		{"name": "FormigaAmbient_B", "pos": Vector2(3200, -40), "id": &"guarda_peijin", "label": "Vigia do Palácio", "mission": false, "etapa": -1},
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
				es.quest_arc = 6
				es.quest_etapa = int(f["etapa"])
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, f["pos"], 6, es.quest_etapa, -1, null, es.enemy_name)
		add_child(mob)


func _densificar_ngl() -> void:
	var placas := [
		{"name": "PlacaNGLFronteira", "pos": Vector2(200, -90), "text": "📍 Fronteira — Kite → Formigas"},
		{"name": "PlacaNGLFabrica", "pos": Vector2(1300, -100), "text": "📍 Fábrica D2 — [G] Gyro"},
		{"name": "PlacaNGLPeijin", "pos": Vector2(2000, -110), "text": "📍 Peijin — Netero → Mentores"},
		{"name": "PlacaNGLPalacio", "pos": Vector2(2900, -100), "text": "📍 Palácio — [Z] Goruto · Knov"},
		{"name": "PlacaNGLTumba", "pos": Vector2(3800, -110), "text": "📍 Tumba — Meruem → Associação"},
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
		lbl.add_theme_color_override("font_color", Color(0.55, 0.9, 0.45, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		marker.add_child(lbl)
		add_child(marker)

	_popular_walkers_ngl()
	_plantar_props_ngl()


func _popular_walkers_ngl() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return
	var walkers := [
		{"name": "ScoutFronteiraNGL", "pos": Vector2(350, 50), "npc": "Scout da Fronteira", "fala": "ORDEM: Kite primeiro. Formigas no GPS. Sem [G] na Fábrica D2 você não entende o Gyro.", "ids": ["npc_guarda_fronteira"], "r": 42.0},
		{"name": "SobreviventeD2", "pos": Vector2(1250, 40), "npc": "Sobrevivente da Fábrica", "fala": "ORDEM: [G] no laboratório D2. Depois Rammot. Não vá ao ninho sem Kite.", "ids": ["npc_viajante_scout"], "r": 40.0},
		{"name": "SoldadoPeijinA", "pos": Vector2(1850, 40), "npc": "Soldado de Peijin", "fala": "Netero → Morel → Knuckle/Shoot. A.P.R. e Rafflesia antes da invasão. GPS um de cada vez.", "ids": ["npc_guarda_fronteira"], "r": 38.0},
		{"name": "MedicoCampo", "pos": Vector2(2150, 50), "npc": "Médico de Campo", "fala": "Após o nascimento do Rei, Morel vai ao ninho. [Z] em Goruto quando o GPS pedir.", "ids": ["npc_viajante_scout"], "r": 36.0},
		{"name": "InfiltradoGoruto", "pos": Vector2(2650, -50), "npc": "Infiltrado de Goruto", "fala": "ORDEM: [Z] Fronteira Goruto. Sem Zetsu = alerta. Depois guardas de Peijin (GPS).", "ids": ["npc_guarda_fronteira"], "r": 40.0},
		{"name": "ObservadorPalacio", "pos": Vector2(3100, 40), "npc": "Observador do Palácio", "fala": "[G] Portas do Knov → Gungi com Meruem → Hora Zero. Sem rush na Guarda Real.", "ids": ["npc_viajante_scout"], "r": 38.0},
		{"name": "EvacuacaoTumba", "pos": Vector2(3900, 40), "npc": "Oficial de Evacuação", "fala": "Portal Associação trancado até a etapa 48. Siga o GPS até Meruem / Netero.", "ids": ["npc_guarda_fronteira"], "r": 34.0},
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


func _plantar_props_ngl() -> void:
	if get_node_or_null("PropsEstruturaNGL") != null:
		return
	var root := Node2D.new()
	root.name = "PropsEstruturaNGL"
	add_child(root)
	var specs := [
		{"name": "MarcoFronteira", "pos": Vector2(250, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
		{"name": "ArbustoFronteira", "pos": Vector2(600, 20), "tex": "res://assets/sprites/objects/calibration_bush_a.png"},
		{"name": "PosteFabrica", "pos": Vector2(1350, 20), "tex": "res://assets/sprites/objects/phase3_lantern_post.png"},
		{"name": "RochaColinas", "pos": Vector2(1550, 25), "tex": "res://assets/sprites/objects/phase2_rock_boulder.png"},
		{"name": "LanternaPeijin", "pos": Vector2(2100, 20), "tex": "res://assets/sprites/objects/hunter_road_lantern.png"},
		{"name": "MonolitoPalacio", "pos": Vector2(3000, 20), "tex": "res://assets/sprites/objects/nen_stone_monolith.png"},
		{"name": "MarcoTumba", "pos": Vector2(3850, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
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


## Gyo/Ko/Zetsu alinhados ao CanonQuestCatalog (arco 6).
func _instanciar_sensores_nen_ngl() -> void:
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoFabricaD2", Vector2(1280, -20),
			&"fabrica_d2_gyro", "Fábrica Clandestina de D2 (Gyro)",
			"Resíduo tóxico de aura. Gyro produzia D2 aqui. Depois Rammot — GPS um passo.",
			"Conjuração", 2, Color(0.7, 0.9, 0.35, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoNascimentoRei", Vector2(1700, -30),
			&"nascimento_rei_meruem", "Vestígio do Nascimento do Rei",
			"Aura monstruosa residual do nascimento prematuro. Fale com Morel depois — GPS.",
			"Especialização", 2, Color(0.3, 0.85, 0.45, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoPortasKnov", Vector2(2550, -40),
			&"portas_knov", "Portas Dimensionais de Knov",
			"Distorção espacial. Hide and Seek. Reúna o time antes da Hora Zero.",
			"Conjuração", 2, Color(0.55, 0.45, 0.95, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoChuvaDragoes", Vector2(3050, -50),
			&"chuva_dragoes_zeno", "Marcas da Chuva de Dragões",
			"Impactos de Nen de Zeno no teto do palácio. Siga o GPS — Youpi nas escadas.",
			"Emissão", 2, Color(0.95, 0.55, 0.35, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoAuraPitou", Vector2(900, -60),
			&"ngl_aura_pitou", "Intenção Assassina (Pitou)",
			"Aura avermelhada do ninho. Fale com Kite. Se o GPS mandar fugir — fuja.",
			"Especialização", 2, Color(1.0, 0.35, 0.35, 0.9)
		)
		NenSensorFactory.criar_ko(
			self, "KoBarreiraFabrica", Vector2(1400, 35),
			"Barreira Rachada da Fábrica D2", &"pocao_aura", &"ngl_ko_fabrica"
		)
		NenSensorFactory.criar_ko(
			self, "KoPilastraPalacio", Vector2(2950, 35),
			"Pilastra Rachada do Palácio", &"elixir_aura"
		)

	NenSensorFactory.criar_zetsu(
		self, "ZetsuPatrulhaFronteira", Vector2(750, -40),
		&"ngl_patrulha_fronteira", "Patrulha da Fronteira NGL",
		Vector2(150, 100), &"formiga_soldado", "Formiga Alertada"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuFronteiraGoruto", Vector2(2600, -20),
		&"fronteira_goruto", "Fronteira Fortificada de Goruto",
		Vector2(160, 100), &"guarda_peijin", "Guarda Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuCorredorPalacio", Vector2(3300, -30),
		&"ngl_corredor_palacio", "Corredor do Palácio Real",
		Vector2(140, 90), &"guarda_peijin", "Guarda Alertado"
	)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalAssociacao") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Associação Hunter"
		portal.map_subtitle = "Arco 7 — A Eleição dos 12 Zodíacos & Alluka"
		portal.story_gate = StoryGate.new(6, 48, true)
		portal.story_gate.gate_title = "Evacuação de NGL & Goruto Oriental"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 48 etapas da Crise das Formigas Chimera antes de voltar para a sede da Associação Hunter!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_chimera_ant_cutscene(get_tree(), mudar_cena_cb)
