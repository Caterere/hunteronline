class_name GreedIslandMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DE GREED ISLAND (ARCO 5 - 36 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 5 (Greed Island):
# - Popula NPCs: Biscuit, Battera, Antokiba, Goreinu, Hisoka, Razor, Elena.
# - Configura monstros, golens, demônios de Nen, Razor Boss e Genthru Bomber.
# - STORY GATE: Exige conclusão das 36 etapas antes da fronteira de NGL.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"antokiba": false,
	"montanhas": false,
	"litoral": false,
	"castelo": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco5()
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

	if px >= 0 and px < 1200 and not _marcos_notificados["antokiba"]:
		_marcos_notificados["antokiba"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏙️ Cidade de Antokiba — A cidade inicial dos jogadores de Greed Island.")

	elif px >= 1200 and px < 2400 and not _marcos_notificados["montanhas"]:
		_marcos_notificados["montanhas"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("⛰️ Desfiladeiro Rochoso — Área de treinamento extremo da Mestra Biscuit.")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["litoral"]:
		_marcos_notificados["litoral"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌊 Cidade Portuária de Soufrabi — O ginásio da Queimada Mortal de Razor!")

	elif px >= 3600 and not _marcos_notificados["castelo"]:
		_marcos_notificados["castelo"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏰 Castelo de Conclusão — Cidade de Premiação de Greed Island!")


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
		var spr = battera.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.7, 0.2, 1.0)
		battera.npc_name = "Bilionário Battera"
		battera.fala_padrao = "Estou investindo tudo o que tenho... por favor, tragam a carta de cura para salvar quem eu amo!"
		add_child(battera)

	# 2. Quadro de Antokiba (Objeto)
	if get_node_or_null("Antokiba") == null:
		var antokiba = scn_npc.instantiate()
		antokiba.name = "Antokiba"
		antokiba.position = Vector2(300, -50)
		antokiba.npc_name = "Quadro de Antokiba"
		antokiba.fala_padrao = "Regras de Greed Island: Colete 100 cartas de espaço designado para zerar o jogo. Use 'Book' para invocar o fichário."
		add_child(antokiba)

	# 3. Mestra Biscuit Krueger (Montanhas)
	if get_node_or_null("Biscuit") == null:
		var scn_biscuit = load("res://entities/npc/biscuit/Biscuit.tscn")
		var biscuit
		if scn_biscuit:
			biscuit = scn_biscuit.instantiate()
		else:
			biscuit = scn_npc.instantiate()
			var spr = biscuit.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(1.0, 0.6, 0.8, 1.0)
		
		biscuit.name = "Biscuit"
		biscuit.position = Vector2(1500, -100)
		biscuit.npc_name = "Mestra Biscuit Krueger"
		biscuit.fala_padrao = "Sou uma caçadora de joias de 57 anos! Vamos cavar essas rochas e treinar Ko, Shu, Ryu e Ken até você desmaiar!"
		add_child(biscuit)

	# 4. Goreinu (Soufrabi)
	if get_node_or_null("Goreinu") == null:
		var goreinu = scn_npc.instantiate()
		goreinu.name = "Goreinu"
		goreinu.position = Vector2(2500, -80)
		var spr = goreinu.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.4, 0.4, 0.5, 1.0)
		goreinu.npc_name = "Goreinu"
		goreinu.fala_padrao = "Meus gorilas de Nen estão prontos para a queimada. Vamos acabar com esses piratas de Soufrabi!"
		add_child(goreinu)

	# 5. Game Master Razor (Ginásio)
	if get_node_or_null("Razor") == null:
		var razor = scn_npc.instantiate()
		razor.name = "Razor"
		razor.position = Vector2(2700, -100)
		var spr = razor.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.scale = Vector2(1.2, 1.2)
			spr.modulate = Color(0.8, 0.2, 0.2, 1.0)
		razor.npc_name = "Game Master Razor"
		razor.fala_padrao = "Ging me tirou da prisão e confiou em mim para proteger esta rota. Se querem a Carta 002, terão que me vencer na queimada!"
		add_child(razor)

	# 6. Elena (Castelo Final)
	if get_node_or_null("ElenaGreed") == null:
		var elena = scn_npc.instantiate()
		elena.name = "ElenaGreed"
		elena.position = Vector2(3800, -120)
		var spr = elena.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.3, 0.9, 0.7, 1.0)
		elena.npc_name = "Elena (Criadora de Greed Island)"
		elena.fala_padrao = "Parabéns por zerar o Greed Island! Como recompensa, você pode escolher 3 cartas para levar ao mundo real."
		add_child(elena)


func _configurar_inimigos() -> void:
	var configs = {
		"MonstroNen1": {"id": &"monstro_greed", "nome": "Monstro Mágico de Greed", "etapa": 4},
		"GolemPedra1": {"id": &"golem_pedra", "nome": "Golem de Pedra das Montanhas", "etapa": 8},
		"DemonioRazor1": {"id": &"demonio_razor", "nome": "Demônio de Nen de Razor", "etapa": 21},
		"RazorBossInimigo": {"id": &"razor_boss", "nome": "Game Master Razor Boss", "etapa": 25},
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
