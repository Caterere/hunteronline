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
	WorldPropsKit.attach(self, WorldPropsKit.KitKind.YORKNEW)
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
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏢 Prédio do Leilão Underground — Negócios obscuros acontecem aqui.")

	elif px >= 1200 and px < 2400 and not _marcos_notificados["ruas"]:
		_marcos_notificados["ruas"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏙️ Ruas de Yorknew City — A cidade que nunca dorme e não perdoa os fracos.")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["cemiterio"]:
		_marcos_notificados["cemiterio"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏗️ Edifício Cemitério — Onde o Réquiem começou...")

	elif px >= 3600 and not _marcos_notificados["esconderijo"]:
		_marcos_notificados["esconderijo"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🕷️ Esconderijo da Trupe Fantasma — A base das Aranhas!")


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
		leorio.fala_padrao = "E aí! Cheguei a Yorknew para o grande leilão! Vamos levantar uma fortuna para comprar o Greed Island!"
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
		kurapika.fala_padrao = "Não importa o que aconteça, vou recuperar os olhos dos meus irmãos... e as Aranhas pagarão com a vida."
		NpcSpriteBinder.aplicar(kurapika, ["npc_kurapika"])
		add_child(kurapika)

	# 3. Melody
	if get_node_or_null("Melody") == null:
		var melody = scn_npc.instantiate()
		melody.name = "Melody"
		melody.position = Vector2(450, -30)
		melody.npc_name = "Melody"
		melody.fala_padrao = "Ouço os batimentos do seu coração... você está calmo. Meu objetivo é encontrar e destruir a partitura da Sonata das Trevas."
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
		gon.fala_padrao = "Vamos arranjar dinheiro para comprar o jogo Greed Island no leilão! Killua e eu estamos tentando de tudo!"
		add_child(gon)

	# 5. Bilionário Battera
	if get_node_or_null("Battera") == null:
		var battera = scn_npc.instantiate()
		battera.name = "Battera"
		battera.position = Vector2(2800, -100)
		battera.npc_name = "Bilionário Battera"
		battera.fala_padrao = "Pago 50 bilhões de Jenny para quem zerar o Greed Island e me trouxer a carta de cura 'Sopro do Arcanjo'!"
		NpcSpriteBinder.aplicar(battera, ["npc_battera"])
		add_child(battera)

	# 6. Tsezguerra
	if get_node_or_null("Tsezguerra") == null:
		var tsezguerra = scn_npc.instantiate()
		tsezguerra.name = "Tsezguerra"
		tsezguerra.position = Vector2(2900, -80)
		tsezguerra.npc_name = "Tsezguerra"
		tsezguerra.fala_padrao = "Sou um Hunter de 1 Estrela contratado por Battera. Mostre-me o seu Ren para saber se você tem qualificações para entrar no jogo."
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
		"NobunagaInimigo": {"id": &"chrollo_boss", "nome": "Chrollo Lucilfer (Chefe)", "etapa": 34}
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


## Densifica as avenidas com mafiosos ambient (não-missão) entre os beats da história.
func _densificar_ruas_yorknew() -> void:
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if scn_enemy == null:
		return

	var fillers := [
		{"name": "MafiosoAmbient_A", "pos": Vector2(600, 40), "label": "Soldado da Máfia (Leilão)"},
		{"name": "MafiosoAmbient_B", "pos": Vector2(1500, -50), "label": "Capanga das Ruas"},
		{"name": "MafiosoAmbient_C", "pos": Vector2(2100, 60), "label": "Olheiro do Sindicato"},
		{"name": "MafiosoAmbient_D", "pos": Vector2(3100, -40), "label": "Guarda do Cemitério"},
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
		{"name": "PlacaYorkLeilao", "pos": Vector2(350, -70), "text": "📍 Distrito do Leilão Underground"},
		{"name": "PlacaYorkRuas", "pos": Vector2(1600, -90), "text": "📍 Avenida Central — Yorknew"},
		{"name": "PlacaYorkCemiterio", "pos": Vector2(2700, -110), "text": "📍 Edifício Cemitério"},
		{"name": "PlacaYorkTrupe", "pos": Vector2(3700, -90), "text": "📍 Zona da Trupe Fantasma"},
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


## Trilha Gyo pós-despertar + becos Zetsu (prática furtiva / emboscada).
func _instanciar_sensores_nen_yorknew() -> void:
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoPistaLeilaoAura", Vector2(400, -20),
			&"yorknew_leilao_aura", "Resíduo de Nen no Leilão",
			"Objetos do leilão underground vibram com aura falsa — Gyo revela falsificações.",
			"Materialização", 1, Color(0.45, 0.85, 1.0, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoPistaRuasAranha", Vector2(1800, 30),
			&"yorknew_pegada_aranha", "Pegada da Aranha",
			"Rastro diluído de Nen especial — alguém da Trupe passou pelas ruas.",
			"Especialização", 1, Color(0.95, 0.4, 0.55, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoPistaCemiterioRequiem", Vector2(2700, -80),
			&"yorknew_requiem_aura", "Eco do Réquiem",
			"Aura densa no Edifício Cemitério. O réquiem de Uvogin ainda ecoa.",
			"Emissão", 2, Color(0.7, 0.35, 0.9, 0.9)
		)
		NenSensorFactory.criar_ko(
			self, "KoCaixoteLeilao", Vector2(550, 20),
			"Caixote Blindado do Leilão", &"pocao_aura"
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
