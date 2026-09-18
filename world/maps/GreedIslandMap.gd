class_name GreedIslandMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DE GREED ISLAND (ARCO 5 - 36 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 5 (Greed Island):
# - Popula NPCs: Biscuit, Battera, Antokiba, Goreinu, Hisoka, Razor, Elena.
# - Densifica Antokiba → Montanhas → Soufrabi → Castelo (imersão longa).
# - Sensores Nen alinhados ao CanonQuestCatalog (Gyo/Ko/Zetsu).
# - STORY GATE: Exige conclusão das 36 etapas antes da fronteira de NGL.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"antokiba": false,
	"montanhas": false,
	"alianca": false,
	"litoral": false,
	"ginasio": false,
	"bomber": false,
	"castelo": false
}


func _ready() -> void:
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.GREED)
	SagaHubConsolidator.densify_hub(self, SagaHubConsolidator.config_for_saga(5))
	SagaDistrictKit.densify_saga(self, 5)
	SagaTerritoryKit.attach(self, 5)
	SagaChapterBinder.bind_hub(self, 5)
	_garantir_dialogue_ui()
	_popular_npcs_arco5()
	_configurar_inimigos()
	_densificar_ilha_greed()
	_instanciar_sensores_nen_greed()
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

	if px >= 0 and px < 1100 and not _marcos_notificados["antokiba"]:
		_marcos_notificados["antokiba"] = true
		_toast_zona(hud, "🏙️ Antokiba — Battera → Quadro → [G] Spell Book. Sem rush.")

	elif px >= 1100 and px < 1850 and not _marcos_notificados["montanhas"]:
		_marcos_notificados["montanhas"] = true
		_toast_zona(hud, "⛰️ Desfiladeiro — Biscuit / Killua. [G] desfiladeiro · [KO] rochas. Treino longo.")

	elif px >= 1850 and px < 2350 and not _marcos_notificados["alianca"]:
		_marcos_notificados["alianca"] = true
		_toast_zona(hud, "🤝 Aliança — Tsezguerra. [G] marca do Bomber. Proteja o Book.")

	elif px >= 2350 and px < 2750 and not _marcos_notificados["litoral"]:
		_marcos_notificados["litoral"] = true
		_toast_zona(hud, "🌊 Soufrabi — Goreinu → Hisoka → Razor. [Z] no porto. GPS um de cada vez.")

	elif px >= 2750 and px < 3150 and not _marcos_notificados["ginasio"]:
		_marcos_notificados["ginasio"] = true
		_toast_zona(hud, "🏐 Ginásio — Queimada Mortal. Demônios → Razor Boss. Sem atalho.")

	elif px >= 3150 and px < 3600 and not _marcos_notificados["bomber"]:
		_marcos_notificados["bomber"] = true
		_toast_zona(hud, "💥 Corredor Bomber — [Z] Cova-Armadilha → Genthru. Depois Castelo.")

	elif px >= 3600 and not _marcos_notificados["castelo"]:
		_marcos_notificados["castelo"] = true
		_toast_zona(hud, "🏰 Castelo — [G] Quiz 100 cartas → Elena → Accompany. Portal NGL após etapa 36.")


func _toast_zona(hud: Node, msg: String) -> void:
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(msg)
	elif EventBus != null:
		EventBus.emit_toast(msg, Color(0.55, 0.95, 0.75))


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(5)


func _popular_npcs_arco5() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[GreedIslandMap] ERRO: NPC.tscn não encontrado!")
		return

	# 1. Bilionário Battera (Entrada)
	if get_node_or_null("Battera") == null:
		var battera = scn_npc.instantiate()
		battera.name = "Battera"
		battera.position = Vector2(100, -30)
		battera.npc_name = "Bilionário Battera"
		NpcSpriteBinder.aplicar(battera, ["npc_battera", "npc_viajante_scout"])
		add_child(battera)
	var battera_n = get_node_or_null("Battera")
	if battera_n != null and "fala_padrao" in battera_n:
		battera_n.fala_padrao = "ORDEM: 1) Fale comigo. 2) Vá ao Quadro de Antokiba. 3) [G] Spell Book. GI é longa — um objetivo de cada vez."

	# 2. Quadro de Antokiba (duelo de cartas S4)
	if get_node_or_null("Antokiba") == null:
		var scn_antokiba = load("res://entities/npc/antokiba/AntokibaDuelBoard.tscn")
		var antokiba
		if scn_antokiba:
			antokiba = scn_antokiba.instantiate()
		else:
			antokiba = scn_npc.instantiate()
			antokiba.npc_name = "Quadro de Antokiba"
			NpcSpriteBinder.aplicar(antokiba, ["npc_viajante_scout"])
		antokiba.name = "Antokiba"
		antokiba.position = Vector2(300, -50)
		add_child(antokiba)
	var antokiba_n = get_node_or_null("Antokiba")
	if antokiba_n != null:
		if "npc_name" in antokiba_n and str(antokiba_n.npc_name).is_empty():
			antokiba_n.npc_name = "Quadro de Antokiba"
		if "fala_padrao" in antokiba_n:
			antokiba_n.fala_padrao = "ORDEM: Aprenda as regras aqui. Depois [G] no Spell Book. Sem Book, não caçe cartas."

	# 3. Mestra Biscuit Krueger (Montanhas)
	if get_node_or_null("Biscuit") == null:
		var scn_biscuit = load("res://entities/npc/biscuit/Biscuit.tscn")
		var biscuit
		if scn_biscuit:
			biscuit = scn_biscuit.instantiate()
		else:
			biscuit = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(biscuit, ["npc_biscuit", "npc_discipulo_zushi"])
		biscuit.name = "Biscuit"
		biscuit.position = Vector2(1500, -100)
		add_child(biscuit)
	var biscuit_n = get_node_or_null("Biscuit")
	if biscuit_n != null:
		if "npc_name" in biscuit_n:
			biscuit_n.npc_name = "Mestra Biscuit Krueger"
		if "fala_padrao" in biscuit_n:
			biscuit_n.fala_padrao = "ORDEM: [G] Desfiladeiro → [KO] rochas → fale comigo de novo (Ko/Shu/Ken/Ryu). Sem pular. Hatsu só depois de zerar GI."

	# 4. Goreinu (Soufrabi)
	if get_node_or_null("Goreinu") == null:
		var goreinu = scn_npc.instantiate()
		goreinu.name = "Goreinu"
		goreinu.position = Vector2(2500, -80)
		goreinu.npc_name = "Goreinu"
		NpcSpriteBinder.aplicar(goreinu, ["npc_viajante_scout", "npc_guarda_fronteira"])
		add_child(goreinu)
	var goreinu_n = get_node_or_null("Goreinu")
	if goreinu_n != null and "fala_padrao" in goreinu_n:
		goreinu_n.fala_padrao = "ORDEM: Fale comigo → Hisoka no lago → Razor no ginásio. [Z] no porto. Sem rush na queimada."

	# 5. Game Master Razor (Ginásio)
	if get_node_or_null("Razor") == null:
		var razor = scn_npc.instantiate()
		razor.name = "Razor"
		razor.position = Vector2(2700, -100)
		razor.npc_name = "Game Master Razor"
		NpcSpriteBinder.aplicar(razor, ["npc_netero", "npc_guarda_fronteira"])
		add_child(razor)
	var razor_n = get_node_or_null("Razor")
	if razor_n != null and "fala_padrao" in razor_n:
		razor_n.fala_padrao = "ORDEM: Derrote os demônios (GPS) → monte o time → queimada → Carta 002. Um desafio de cada vez. Sem atalho."

	# 6. Elena (Castelo Final)
	if get_node_or_null("ElenaGreed") == null:
		var elena = scn_npc.instantiate()
		elena.name = "ElenaGreed"
		elena.position = Vector2(3800, -120)
		elena.npc_name = "Elena (Criadora de Greed Island)"
		NpcSpriteBinder.aplicar(elena, ["npc_recepcionista_elena"])
		add_child(elena)
	var elena_n = get_node_or_null("ElenaGreed")
	if elena_n != null and "fala_padrao" in elena_n:
		elena_n.fala_padrao = "ORDEM: [G] Quiz das 100 cartas → fale comigo → escolha Accompany. Só então o portal NGL abre. Sem rush."

	# 7. Tsezguerra (aliança mid-game)
	if get_node_or_null("Tsezguerra") == null:
		var tsez = scn_npc.instantiate()
		tsez.name = "Tsezguerra"
		tsez.position = Vector2(1900, 40)
		tsez.npc_name = "Tsezguerra"
		NpcSpriteBinder.aplicar(tsez, ["npc_tsezguerra", "npc_guarda_fronteira"])
		add_child(tsez)
	var tsez_n = get_node_or_null("Tsezguerra")
	if tsez_n != null and "fala_padrao" in tsez_n:
		tsez_n.fala_padrao = "ORDEM: Fale comigo → [G] marca do Bomber → Soufrabi (Goreinu). Proteja o Book. Um passo."

	# 8. Killua (treino mid + armadilha late)
	if get_node_or_null("Killua") == null:
		var scn_killua = load("res://entities/npc/killua/Killua.tscn")
		var killua
		if scn_killua:
			killua = scn_killua.instantiate()
		else:
			killua = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(killua, ["npc_killua"])
		killua.name = "Killua"
		killua.position = Vector2(1620, -40)
		add_child(killua)
	var killua_n = get_node_or_null("Killua")
	if killua_n != null:
		if "npc_name" in killua_n:
			killua_n.npc_name = "Killua Zoldyck"
		if "fala_padrao" in killua_n:
			killua_n.fala_padrao = "ORDEM: Treino com Biscuit primeiro. Depois Yo-yos / Sub. [Z] na Cova quando o GPS pedir. Sem rush."

	# 9. Hisoka (recruta mid — lago / Soufrabi)
	if get_node_or_null("Hisoka") == null:
		var scn_hisoka = load("res://entities/npc/hisoka/Hisoka.tscn")
		var hisoka
		if scn_hisoka:
			hisoka = scn_hisoka.instantiate()
		else:
			hisoka = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(hisoka, ["npc_hisoka"])
		hisoka.name = "Hisoka"
		hisoka.position = Vector2(2580, -60)
		add_child(hisoka)
	var hisoka_n = get_node_or_null("Hisoka")
	if hisoka_n != null:
		if "npc_name" in hisoka_n:
			hisoka_n.npc_name = "Hisoka Morow"
		if "fala_padrao" in hisoka_n:
			hisoka_n.fala_padrao = "ORDEM: Fale comigo (recruta) → ginásio com Razor. Queimada depois. Sem pular etapas. ♥"

func _configurar_inimigos() -> void:
	var configs = {
		"MonstroNen1": {"id": &"monstro_greed", "nome": "Monstro Mágico de Greed", "etapa": 4},
		"MonstroNen2": {"id": &"monstro_greed", "nome": "Monstro Mágico de Greed", "etapa": 4},
		"GolemPedra1": {"id": &"golem_pedra", "nome": "Golem de Pedra das Montanhas", "etapa": 8},
		"DemonioRazor1": {"id": &"demonio_razor", "nome": "Demônio de Nen de Razor", "etapa": 21},
		"RazorInimigo": {"id": &"razor_boss", "nome": "Game Master Razor Boss", "etapa": 25},
		"GenthruInimigo": {"id": &"genthru", "nome": "Genthru Bomber (Chefe)", "etapa": 31}
	}

	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 5
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 5, es.quest_etapa, -1, null, es.enemy_name)

	_spawn_fillers_combate()


func _spawn_fillers_combate() -> void:
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if scn_enemy == null:
		return
	var fillers := [
		{"name": "MonstroAmbient_A", "pos": Vector2(550, 40), "id": &"monstro_greed", "label": "Monstro da Colina (Antokiba)", "mission": false, "etapa": -1},
		{"name": "MonstroAmbient_B", "pos": Vector2(900, -40), "id": &"monstro_greed", "label": "Monstro da Trilha", "mission": false, "etapa": -1},
		{"name": "MonstroCaçada_A", "pos": Vector2(1050, 50), "id": &"monstro_greed", "label": "Monstro da Caçada Mid", "mission": true, "etapa": 14},
		{"name": "MonstroCaçada_B", "pos": Vector2(1180, -30), "id": &"monstro_greed", "label": "Monstro da Caçada Mid B", "mission": true, "etapa": 14},
		{"name": "GolemAmbient_A", "pos": Vector2(1400, 50), "id": &"golem_pedra", "label": "Golem do Desfiladeiro", "mission": false, "etapa": -1},
		{"name": "GolemAmbient_B", "pos": Vector2(1750, -60), "id": &"golem_pedra", "label": "Golem do Treino", "mission": false, "etapa": -1},
		{"name": "GolemMissao_B", "pos": Vector2(1550, -20), "id": &"golem_pedra", "label": "Golem de Missão B", "mission": true, "etapa": 8},
		{"name": "GolemMissao_C", "pos": Vector2(1680, 40), "id": &"golem_pedra", "label": "Golem de Missão C", "mission": true, "etapa": 8},
		{"name": "PirataAmbient_A", "pos": Vector2(2400, 40), "id": &"monstro_greed", "label": "Pirata de Soufrabi", "mission": false, "etapa": -1},
		{"name": "PirataAmbient_B", "pos": Vector2(2900, 50), "id": &"monstro_greed", "label": "Guarda do Ginásio", "mission": false, "etapa": -1},
		{"name": "DemonioMissao_B", "pos": Vector2(2780, 30), "id": &"demonio_razor", "label": "Demônio de Nen B", "mission": true, "etapa": 21},
		{"name": "DemonioMissao_C", "pos": Vector2(2850, -50), "id": &"demonio_razor", "label": "Demônio de Nen C", "mission": true, "etapa": 21},
		{"name": "DemonioMissao_D", "pos": Vector2(2920, 20), "id": &"demonio_razor", "label": "Demônio de Nen D", "mission": true, "etapa": 21},
		{"name": "DemonioMissao_E", "pos": Vector2(3000, -30), "id": &"demonio_razor", "label": "Demônio de Nen E", "mission": true, "etapa": 21},
		{"name": "DemonioMissao_F", "pos": Vector2(3080, 40), "id": &"demonio_razor", "label": "Demônio de Nen F", "mission": true, "etapa": 21},
		{"name": "BomberScout_A", "pos": Vector2(3300, -40), "id": &"genthru", "label": "Olheiro do Bomber", "mission": false, "etapa": -1},
		{"name": "BomberAlly_A", "pos": Vector2(3380, 50), "id": &"monstro_greed", "label": "Subordinado do Bomber", "mission": true, "etapa": 28},
		{"name": "BomberAlly_B", "pos": Vector2(3450, -20), "id": &"monstro_greed", "label": "Subordinado do Bomber B", "mission": true, "etapa": 28},
		{"name": "CasteloGuard_A", "pos": Vector2(3600, 40), "id": &"monstro_greed", "label": "Guarda do Castelo", "mission": false, "etapa": -1},
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
				es.quest_arc = 5
				es.quest_etapa = int(f["etapa"])
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, f["pos"], 5, es.quest_etapa, -1, null, es.enemy_name)
		add_child(mob)


func _densificar_ilha_greed() -> void:
	var placas := [
		{"name": "PlacaGIAntokiba", "pos": Vector2(250, -70), "text": "📍 Antokiba — Battera → Quadro → Book"},
		{"name": "PlacaGIColinas", "pos": Vector2(800, -90), "text": "📍 Colinas — monstros / Trace"},
		{"name": "PlacaGIDesfiladeiro", "pos": Vector2(1500, -120), "text": "📍 Desfiladeiro — Biscuit / Ko·Shu"},
		{"name": "PlacaGIAlianca", "pos": Vector2(1950, -100), "text": "📍 Aliança — Tsezguerra / Bomber"},
		{"name": "PlacaGISoufrabi", "pos": Vector2(2500, -110), "text": "📍 Soufrabi — Goreinu → Hisoka → Razor"},
		{"name": "PlacaGIGinasio", "pos": Vector2(2800, -90), "text": "📍 Ginásio — Demônios → Queimada"},
		{"name": "PlacaGIBomber", "pos": Vector2(3250, -100), "text": "📍 Bomber — [Z] Cova → Genthru"},
		{"name": "PlacaGICastelo", "pos": Vector2(3700, -110), "text": "📍 Castelo — Quiz → Elena → NGL"},
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
		lbl.add_theme_color_override("font_color", Color(0.55, 0.95, 0.75, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		marker.add_child(lbl)
		add_child(marker)

	_popular_walkers_greed()
	_plantar_props_greed()


func _popular_walkers_greed() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return
	var walkers := [
		{"name": "JogadorNovatoA", "pos": Vector2(200, 50), "npc": "Jogador Novato", "fala": "Book primeiro. Sem [G] no Spell Book você não entende Gain/Trace. Fale com Battera.", "ids": ["npc_viajante_scout"], "r": 44.0},
		{"name": "ColecionadorCartas", "pos": Vector2(650, -50), "npc": "Colecionador de Cartas", "fala": "Monstros nas colinas dropam Trace. Um kill de missão por vez — GPS. Depois Biscuit nas montanhas.", "ids": ["npc_viajante_scout"], "r": 48.0},
		{"name": "MineradorDesfiladeiro", "pos": Vector2(1350, 40), "npc": "Minerador do Desfiladeiro", "fala": "Biscuit manda escavar. [G] no desfiladeiro, depois [KO] nas rochas. Sem Nen no início do treino.", "ids": ["npc_guarda_fronteira"], "r": 40.0},
		{"name": "DiscipuloBiscuit", "pos": Vector2(1580, 55), "npc": "Discípulo do Desfiladeiro", "fala": "ORDEM: Ko → Shu → Ken → Ryu com Biscuit. Killua treina Yo-yos ao lado. Sem pular.", "ids": ["npc_discipulo_zushi", "npc_viajante_scout"], "r": 36.0},
		{"name": "AliadoTsez", "pos": Vector2(2000, -50), "npc": "Caçador da Aliança", "fala": "ORDEM: Fale com Tsezguerra → [G] marca do Bomber. Book protegido. Depois Soufrabi.", "ids": ["npc_guarda_fronteira"], "r": 42.0},
		{"name": "PirataSoufrabi", "pos": Vector2(2350, 50), "npc": "Habitante de Soufrabi", "fala": "Goreinu → Hisoka no lago → Razor. [Z] nos corredores do porto. A queimada espera — não rush.", "ids": ["npc_viajante_scout"], "r": 42.0},
		{"name": "JuizGinasio", "pos": Vector2(2650, 40), "npc": "Juiz da Queimada", "fala": "ORDEM: Demônios (GPS) → time → saque → Razor Boss → Carta 002. Um de cada vez.", "ids": ["npc_guarda_fronteira"], "r": 36.0},
		{"name": "TorcedorQueimada", "pos": Vector2(2950, -70), "npc": "Torcedor do Ginásio", "fala": "Razor não libera a 002 sem a queimada. Biscuit e Killua têm etapas no GPS antes do Bomber.", "ids": ["npc_viajante_scout"], "r": 40.0},
		{"name": "ScoutBomberTrail", "pos": Vector2(3180, 45), "npc": "Scout do Corredor", "fala": "ORDEM: [Z] na Cova-Armadilha. Sem Zetsu = Bomber alerta. Depois Genthru. Castelo só no fim.", "ids": ["npc_guarda_fronteira"], "r": 38.0},
		{"name": "GuardaCasteloGI", "pos": Vector2(3550, 30), "npc": "Guarda do Castelo", "fala": "ORDEM: [G] Quiz das 100 cartas → Elena → Accompany. Portal NGL trancado até a etapa 36.", "ids": ["npc_guarda_fronteira"], "r": 38.0},
		{"name": "CuradorCastelo", "pos": Vector2(3720, 50), "npc": "Curador do Castelo", "fala": "Sopro do Arcanjo cura feridas do Bomber. Fale com Goreinu se o GPS pedir, depois quiz com Elena.", "ids": ["npc_viajante_scout"], "r": 34.0},
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


func _plantar_props_greed() -> void:
	if get_node_or_null("PropsEstruturaGreed") != null:
		return
	var root := Node2D.new()
	root.name = "PropsEstruturaGreed"
	add_child(root)
	var specs := [
		{"name": "MarcoAntokiba", "pos": Vector2(280, 30), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
		{"name": "LanternaColinas", "pos": Vector2(850, 20), "tex": "res://assets/sprites/objects/hunter_road_lantern.png"},
		{"name": "RochaDesfiladeiro", "pos": Vector2(1450, 30), "tex": "res://assets/sprites/objects/phase2_rock_boulder.png"},
		{"name": "PosteAlianca", "pos": Vector2(1980, 15), "tex": "res://assets/sprites/objects/hunter_road_lantern.png"},
		{"name": "PosteSoufrabi", "pos": Vector2(2550, 20), "tex": "res://assets/sprites/objects/phase3_lantern_post.png"},
		{"name": "MarcoGinasio", "pos": Vector2(2820, 25), "tex": "res://assets/sprites/objects/marco_pedra_milestone.png"},
		{"name": "RochaBomber", "pos": Vector2(3220, 25), "tex": "res://assets/sprites/objects/phase2_rock_boulder.png"},
		{"name": "MonolitoCastelo", "pos": Vector2(3650, 20), "tex": "res://assets/sprites/objects/nen_stone_monolith.png"},
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


## Gyo/Ko/Zetsu alinhados ao CanonQuestCatalog (arco 5) — early + mid/late.
func _instanciar_sensores_nen_greed() -> void:
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoLivroGreed", Vector2(350, -20),
			&"livro_greed", "Spell Book (Livro de Magia)",
			"Resíduo de Nen no Book. Comandos Book/Gain. Próximo: derrote monstros nas colinas (GPS).",
			"Conjuração", 1, Color(0.45, 0.95, 0.75, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoDesfiladeiroBiscuit", Vector2(1480, -40),
			&"desfiladeiro_biscuit", "Desfiladeiro de Pedras (Biscuit)",
			"Marcas de escavação sem Nen. Treine Ko depois — fale com Biscuit. Um exercício de cada vez.",
			"Intensificação", 1, Color(0.95, 0.7, 0.4, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoExplosaoBomber", Vector2(2100, 20),
			&"explosao_bomber", "Marca da Explosão do Bomber",
			"Aura de Conjuração explosiva. Genthru passou aqui. Proteja o Book — siga o GPS.",
			"Conjuração", 2, Color(1.0, 0.4, 0.25, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoPortoSoufrabi", Vector2(2480, -20),
			&"porto_soufrabi", "Porto de Soufrabi",
			"Resíduo de emissão no cais. Fale com Goreinu, depois Hisoka, depois Razor no ginásio.",
			"Emissão", 1, Color(0.4, 0.75, 1.0, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoGinasioRazor", Vector2(2720, -40),
			&"ginasio_razor", "Ginásio da Queimada Mortal",
			"Aura densa de Razor. Demônios primeiro (GPS), depois a queimada. Carta 002 só no fim.",
			"Emissão", 2, Color(0.95, 0.55, 0.35, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoCarta002", Vector2(2680, 50),
			&"carta_002_litoral", "Eco da Carta 002 (Litoral)",
			"Após vencer Razor, a Carta 002 vibra aqui. Fale com Razor de novo — depois estratégia Bomber.",
			"Conjuração", 2, Color(0.55, 0.9, 0.7, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoSoproArcanjo", Vector2(3680, -40),
			&"sopro_arcanjo", "Sopro do Arcanjo (Carta 017)",
			"Cura mágica residual. Fale com Goreinu se o GPS pedir, depois [G] no Quiz das 100 cartas.",
			"Especialização", 2, Color(0.85, 0.95, 0.55, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoQuiz100Cartas", Vector2(3750, -60),
			&"quiz_100_cartas", "Altar das 100 Cartas",
			"Elena espera o quiz final. Complete as etapas restantes antes de escolher recompensas.",
			"Especialização", 2, Color(0.7, 0.55, 1.0, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoTraceColinas", Vector2(700, 10),
			&"greed_rastro_trace", "Rastro de Trace",
			"Feitiço Trace ainda vibra. Use o GPS para os monstros de missão — caminhe as colinas.",
			"Emissão", 1, Color(0.55, 0.85, 1.0, 0.9)
		)
		NenSensorFactory.criar_ko(
			self, "KoRochaDesfiladeiro", Vector2(1600, 30),
			"Rocha de Treino do Desfiladeiro", &"pocao_aura", &"greed_ko_desfiladeiro"
		)
		NenSensorFactory.criar_ko(
			self, "KoBaúSoufrabi", Vector2(2600, 40),
			"Baú Selado de Soufrabi", &"elixir_aura"
		)
		NenSensorFactory.criar_ko(
			self, "KoRochaBomber", Vector2(3350, 35),
			"Rocha Rachada do Corredor Bomber", &"pocao_aura", &"greed_ko_bomber"
		)

	NenSensorFactory.criar_zetsu(
		self, "ZetsuColinasAntokiba", Vector2(850, -80),
		&"greed_colinas_furtivas", "Colinas Vigiladas de Antokiba",
		Vector2(140, 100), &"monstro_greed", "Monstro Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuCorredorSoufrabi", Vector2(2450, -30),
		&"greed_corredor_soufrabi", "Corredor do Porto de Soufrabi",
		Vector2(150, 100), &"monstro_greed", "Pirata Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuGinasioVestibulo", Vector2(2880, -20),
		&"greed_ginasio_vestibulo", "Vestíbulo do Ginásio",
		Vector2(140, 90), &"demonio_razor", "Demônio Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuArmadilhaCovaGon", Vector2(3200, 20),
		&"armadilha_cova_gon", "Cova-Armadilha (Gon)",
		Vector2(140, 90), &"genthru", "Bomber Alertado"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuCasteloFinal", Vector2(3550, -50),
		&"greed_castelo_vigias", "Vigias do Castelo",
		Vector2(130, 90), &"monstro_greed", "Guarda Alertado"
	)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalNGL") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Fronteira da NGL"
		portal.map_subtitle = "Arco 6 — Formigas Chimera & A Crise de Peijin"
		portal.story_gate = StoryGate.new(5, 36, true)
		portal.story_gate.gate_title = "Feitiço Accompany (Saída de Greed Island)"
		portal.story_gate.default_locked_message = "Você precisa completar todas as 36 etapas de Greed Island e coletar as 100 cartas antes de voar para NGL!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_greed_island_cutscene(get_tree(), mudar_cena_cb)
