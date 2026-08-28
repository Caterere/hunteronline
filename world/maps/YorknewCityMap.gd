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
	_garantir_dialogue_ui()
	_popular_npcs_arco4()
	_configurar_inimigos()
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

	# 1. Leorio (Início da Cidade)
	if get_node_or_null("Leorio") == null:
		var leorio = scn_npc.instantiate()
		leorio.name = "Leorio"
		leorio.position = Vector2(100, -30)
		var spr = leorio.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.2, 0.3, 0.7, 1.0)
		leorio.npc_name = "Leorio"
		leorio.fala_padrao = "E aí! Cheguei a Yorknew para o grande leilão! Vamos levantar uma fortuna para comprar o Greed Island!"
		add_child(leorio)

	# 2. Kurapika
	if get_node_or_null("Kurapika") == null:
		var scn_kurapika = load("res://entities/npc/kurapika/Kurapika.tscn")
		var kurapika
		if scn_kurapika:
			kurapika = scn_kurapika.instantiate()
		else:
			kurapika = scn_npc.instantiate()
			var spr = kurapika.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(1.0, 0.3, 0.3, 1.0)
		
		kurapika.name = "Kurapika"
		kurapika.position = Vector2(300, -50)
		kurapika.npc_name = "Kurapika"
		kurapika.fala_padrao = "Não importa o que aconteça, vou recuperar os olhos dos meus irmãos... e as Aranhas pagarão com a vida."
		add_child(kurapika)

	# 3. Melody
	if get_node_or_null("Melody") == null:
		var melody = scn_npc.instantiate()
		melody.name = "Melody"
		melody.position = Vector2(450, -30)
		var spr = melody.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.8, 0.7, 1.0, 1.0)
		melody.npc_name = "Melody"
		melody.fala_padrao = "Ouço os batimentos do seu coração... você está calmo. Meu objetivo é encontrar e destruir a partitura da Sonata das Trevas."
		add_child(melody)

	# 4. Gon
	if get_node_or_null("Gon") == null:
		var scn_gon = load("res://entities/npc/gon/Gon.tscn")
		var gon
		if scn_gon:
			gon = scn_gon.instantiate()
		else:
			gon = scn_npc.instantiate()
			var spr = gon.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.2, 0.8, 0.2, 1.0)
		
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
		var spr = battera.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.7, 0.2, 1.0)
		battera.npc_name = "Bilionário Battera"
		battera.fala_padrao = "Pago 50 bilhões de Jenny para quem zerar o Greed Island e me trouxer a carta de cura 'Sopro do Arcanjo'!"
		add_child(battera)

	# 6. Tsezguerra
	if get_node_or_null("Tsezguerra") == null:
		var tsezguerra = scn_npc.instantiate()
		tsezguerra.name = "Tsezguerra"
		tsezguerra.position = Vector2(2900, -80)
		var spr = tsezguerra.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.6, 0.6, 0.6, 1.0)
		tsezguerra.npc_name = "Tsezguerra"
		tsezguerra.fala_padrao = "Sou um Hunter de 1 Estrela contratado por Battera. Mostre-me o seu Ren para saber se você tem qualificações para entrar no jogo."
		add_child(tsezguerra)

	# 7. Chrollo
	if get_node_or_null("Chrollo") == null:
		var scn_chrollo = load("res://entities/npc/chrollo/Chrollo.tscn")
		var chrollo
		if scn_chrollo:
			chrollo = scn_chrollo.instantiate()
		else:
			chrollo = scn_npc.instantiate()
			var spr = chrollo.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.1, 0.1, 0.1, 1.0)
		
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
