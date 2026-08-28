class_name NGLFormigasMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DAS FORMIGAS CHIMERA (ARCO 6 - 48 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 6 (Formigas Chimera):
# - Popula NPCs: Kite, Killua, Netero, Morel, Knuckle, Shoot, Meruem.
# - Configura inimigos: Formigas Soldado, Guardas de Peijin, Youpi, Pouf e Pitou.
# - STORY GATE: Exige conclusão das 48 etapas antes da Associação Hunter.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"fronteira": false,
	"fabrica": false,
	"palacio": false,
	"tumba": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco6()
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

	if px >= 0 and px < 1200 and not _marcos_notificados["fronteira"]:
		_marcos_notificados["fronteira"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌲 Fronteira de NGL — Território isolado onde a Rainha Quimera começou o ninho.")

	elif px >= 1200 and px < 2400 and not _marcos_notificados["fabrica"]:
		_marcos_notificados["fabrica"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏭 Fábrica Clandestina de D2 — As ruínas sombrias de Gyro.")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["palacio"]:
		_marcos_notificados["palacio"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏛️ Palácio Real de Peijin — O covil do Rei Meruem e da Guarda Real.")

	elif px >= 3600 and not _marcos_notificados["tumba"]:
		_marcos_notificados["tumba"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🪦 Tumba de Testes Nucleares — O campo da batalha lendária de Isaac Netero.")


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
		kite.position = Vector2(100, -50)
		var spr = kite.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.7, 0.8, 0.9, 1.0)
		kite.npc_name = "Kite (Caçador de Contratos)"
		kite.fala_padrao = "Gon, Killua... Se sentirem que estão em perigo, fujam imediatamente. As Formigas Quimera são a espécie mais predatória da história."
		add_child(kite)

	# 2. Presidente Isaac Netero (Base Militar de Peijin)
	if get_node_or_null("Netero") == null:
		var scn_netero = load("res://entities/npc/netero/Netero.tscn")
		var netero
		if scn_netero:
			netero = scn_netero.instantiate()
		else:
			netero = scn_npc.instantiate()
			var spr = netero.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(1.0, 0.9, 0.4, 1.0)
		
		netero.name = "Netero"
		netero.position = Vector2(1800, -100)
		netero.npc_name = "Presidente Isaac Netero"
		netero.fala_padrao = "Ho, ho! Vocês treinaram bastante com Knuckle e Shoot. Agora, preparem-se para a Invasão da Hora Zero!"
		add_child(netero)

	# 3. Morel Mackernasey
	if get_node_or_null("Morel") == null:
		var morel = scn_npc.instantiate()
		morel.name = "Morel"
		morel.position = Vector2(1950, -80)
		var spr = morel.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.4, 0.5, 0.6, 1.0)
		morel.npc_name = "Morel Mackernasey"
		morel.fala_padrao = "Meu Deep Purple pode criar 216 soldados de fumaça. Nenhum membro da Guarda Real passará por mim!"
		add_child(morel)

	# 4. Knuckle Bine
	if get_node_or_null("Knuckle") == null:
		var knuckle = scn_npc.instantiate()
		knuckle.name = "Knuckle"
		knuckle.position = Vector2(2100, -60)
		var spr = knuckle.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.9, 0.9, 1.0)
		knuckle.npc_name = "Knuckle Bine"
		knuckle.fala_padrao = "O A.P.R. já está cobrando 10% de juros por segundo no Youpi! Não recuem!"
		add_child(knuckle)

	# 5. Shoot McMahon
	if get_node_or_null("Shoot") == null:
		var shoot = scn_npc.instantiate()
		shoot.name = "Shoot"
		shoot.position = Vector2(2250, -60)
		var spr = shoot.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.5, 0.3, 0.7, 1.0)
		shoot.npc_name = "Shoot McMahon"
		shoot.fala_padrao = "Superei meu medo! Minhas três mãos flutuantes abrirão o caminho para o Gon!"
		add_child(shoot)

	# 6. Rei Meruem (Aposentos do Palácio)
	if get_node_or_null("MeruemReiNPC") == null:
		var meruem = scn_npc.instantiate()
		meruem.name = "MeruemReiNPC"
		meruem.position = Vector2(3600, -120)
		var spr = meruem.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.scale = Vector2(1.2, 1.2)
			spr.modulate = Color(0.2, 0.7, 0.4, 1.0)
		meruem.npc_name = "Rei Meruem"
		meruem.fala_padrao = "Komugi... você ainda está aí? Vamos jogar apenas mais uma partida de Gungi..."
		add_child(meruem)


func _configurar_inimigos() -> void:
	var configs = {
		"FormigaSoldado1": {"id": &"formiga_soldado", "nome": "Formiga Soldado Quimera", "etapa": 3},
		"FormigaSoldado2": {"id": &"formiga_oficial", "nome": "Formiga Oficial Quimera", "etapa": 5},
		"EsquadraoQuimera": {"id": &"guarda_peijin", "nome": "Guarda de Peijin", "etapa": 19},
		"YoupiInimigo": {"id": &"youpi", "nome": "Menthuthuyoupi (Guarda Real)", "etapa": 32},
		"ShaiapoufInimigo": {"id": &"shaiapouf", "nome": "Shaiapouf (Guarda Real)", "etapa": 33},
		"NeferpitouInimigo": {"id": &"neferpitou", "nome": "Neferpitou Boss", "etapa": 43}
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
