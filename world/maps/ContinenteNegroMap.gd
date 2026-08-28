class_name ContinenteNegroMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DO CONTINENTE NEGRO (ARCO 8 - 22 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 8 (Continente Negro & Árvore do Mundo):
# - Popula NPCs: Beyond Netero, Ging Freecss (Acampamento e Topo da Árvore).
# - Configura inimigos: Guardiões de Brion, Brion Boss, Hellbell e Ai.
# - STORY GATE: Exige conclusão das 22 etapas antes do Black Whale 1.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"acampamento": false,
	"ruinas": false,
	"raizes": false,
	"topo": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco8()
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

	if px >= 0 and px < 1200 and not _marcos_notificados["acampamento"]:
		_marcos_notificados["acampamento"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("⛺ Acampamento da Expedição — Beyond Netero e os Caçadores do Novo Mundo.")

	elif px >= 1200 and px < 2400 and not _marcos_notificados["ruinas"]:
		_marcos_notificados["ruinas"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏛️ Ruas Ancestrais de Brion — O território das 5 Grandes Calamidades!")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["raizes"]:
		_marcos_notificados["raizes"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌳 Raízes Continentais — A base da colossal Árvore do Mundo (1.784m).")

	elif px >= 3600 and not _marcos_notificados["topo"]:
		_marcos_notificados["topo"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("☁️ Topo do Mundo — O ninho de criaturas lendárias ao lado de Ging Freecss.")


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
		beyond.position = Vector2(100, -50)
		var spr = beyond.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.scale = Vector2(1.2, 1.2)
			spr.modulate = Color(0.8, 0.4, 0.2, 1.0)
		beyond.npc_name = "Beyond Netero"
		beyond.fala_padrao = "Vamos romper as correntes do Tratado V5 e conquistar o continente que meu pai nos proibiu de explorar!"
		add_child(beyond)

	# 2. Ging Freecss (Acampamento de Recrutamento)
	if get_node_or_null("Ging") == null:
		var scn_ging = load("res://entities/npc/ging/Ging.tscn")
		var ging
		if scn_ging:
			ging = scn_ging.instantiate()
		else:
			ging = scn_npc.instantiate()
			var spr = ging.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.3, 0.6, 0.3, 1.0)
		
		ging.name = "Ging"
		ging.position = Vector2(300, -80)
		ging.npc_name = "Ging Freecss"
		ging.fala_padrao = "O que realmente importa não é o que está diante de nós... são as coisas que encontramos pelo caminho!"
		add_child(ging)

	# 3. Árvore do Mundo (Marco de Interação)
	if get_node_or_null("ArvoreMundo") == null:
		var arvore = scn_npc.instantiate()
		arvore.name = "ArvoreMundo"
		arvore.position = Vector2(2500, -100)
		arvore.npc_name = "Árvore do Mundo (1.784m)"
		arvore.fala_padrao = "[E] Escale os 1.784 metros de tronco colossal acima da camada de nuvens."
		add_child(arvore)

	# 4. Ging Freecss no Topo
	if get_node_or_null("GingTopo") == null:
		var scn_ging = load("res://entities/npc/ging/Ging.tscn")
		var ging_topo
		if scn_ging:
			ging_topo = scn_ging.instantiate()
		else:
			ging_topo = scn_npc.instantiate()
			var spr = ging_topo.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.3, 0.6, 0.3, 1.0)
		
		ging_topo.name = "GingTopo"
		ging_topo.position = Vector2(3800, -120)
		ging_topo.npc_name = "Ging Freecss no Topo"
		ging_topo.fala_padrao = "Olhe para aquele horizonte infinito além do Lago Mobius... É lá que o verdadeiro mundo dos Caçadores começa!"
		add_child(ging_topo)


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
