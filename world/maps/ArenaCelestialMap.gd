class_name ArenaCelestialMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DA ARENA CELESTIAL (ARCO 3 - 26 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 3 (Arena Celestial):
# - Popula NPCs: Recepcionista, Zushi, Mestre Wing e Hisoka.
# - Configura os Lutadores dos primeiros andares e Mestres do 200º Andar.
# - Rastreia marcos dos andares e exibe notificações de imersão.
# - STORY GATE: Exige conclusão das 26 etapas antes de Yorknew.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"recepcao": false,
	"ringues_inferiores": false,
	"ringues_superiores": false,
	"topo": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco3()
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

	if px >= 0 and px < 800 and not _marcos_notificados["recepcao"]:
		_marcos_notificados["recepcao"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏢 Recepção da Arena Celestial — Registre-se para lutar!")

	elif px >= 800 and px < 2200 and not _marcos_notificados["ringues_inferiores"]:
		_marcos_notificados["ringues_inferiores"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🥊 Ringues Inferiores — Ganhe dinheiro e suba de andar!")

	elif px >= 2200 and px < 3400 and not _marcos_notificados["ringues_superiores"]:
		_marcos_notificados["ringues_superiores"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("⚡ Ringues Superiores — Andares onde o uso de Nen é obrigatório!")

	elif px >= 3400 and not _marcos_notificados["topo"]:
		_marcos_notificados["topo"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("👑 Topo da Arena (Andar 200+) — Mestres de Andar e a aura assassina de Hisoka!")


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(3)


func _popular_npcs_arco3() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[ArenaCelestialMap] ERRO: NPC.tscn não encontrado!")
		return

	# 1. Recepcionista da Arena
	if get_node_or_null("Recepcionista") == null:
		var recepcionista = scn_npc.instantiate()
		recepcionista.name = "Recepcionista"
		recepcionista.position = Vector2(50, 0)
		var spr = recepcionista.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.8, 0.5, 1.0)
		recepcionista.npc_name = "Recepcionista da Arena"
		recepcionista.fala_padrao = "Bem-vindo à Arena Celestial! Por favor, preencha este formulário para se registrar. Boa sorte nas lutas e tente não morrer nos andares mais altos!"
		add_child(recepcionista)

	# 2. Zushi
	if get_node_or_null("Zushi") == null:
		var zushi = scn_npc.instantiate()
		zushi.name = "Zushi"
		zushi.position = Vector2(1000, -80)
		var spr = zushi.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(1.0, 0.95, 0.7, 1.0)
		zushi.npc_name = "Zushi"
		zushi.fala_padrao = "Osu! Sou Zushi, discípulo do mestre Wing! Estou aprendendo o estilo Shingen-ryu de Kung Fu. Preciso treinar mais duro! Osu!"
		add_child(zushi)

	# 3. Mestre Wing (Dojo do 200º Andar)
	if get_node_or_null("Wing") == null:
		var scn_wing = load("res://entities/npc/wing/Wing.tscn")
		var wing
		if scn_wing:
			wing = scn_wing.instantiate()
		else:
			wing = scn_npc.instantiate()
			wing.script = load("res://entities/npc/wing/Wing.gd")
		wing.name = "Wing"
		wing.position = Vector2(1100, -80)
		add_child(wing)

	# 4. Hisoka (Barreira do 200º Andar & Ringue Principal)
	if get_node_or_null("Hisoka") == null:
		var scn_hisoka = load("res://entities/npc/hisoka/Hisoka.tscn")
		var hisoka
		if scn_hisoka:
			hisoka = scn_hisoka.instantiate()
		else:
			hisoka = scn_npc.instantiate()
			var spr = hisoka.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.9, 0.1, 0.5, 1.0)
		
		hisoka.name = "Hisoka"
		hisoka.position = Vector2(3500, -100)
		hisoka.npc_name = "Hisoka Morow"
		hisoka.fala_padrao = "Oh... Você chegou até aqui? Suas frutas ainda estão muito verdes... Continue amadurecendo para que eu possa esmagá-las de uma vez. ♥"
		add_child(hisoka)


func _configurar_inimigos() -> void:
	# Lutadores dos Andares Inferiores (Arco 3, Etapas 2, 3, 4, 5)
	var lutadores = ["LutadorArena1", "LutadorArena2", "LutadorArena3", "LutadorArena4"]
	for i in range(lutadores.size()):
		var nome = lutadores[i]
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 3
				es.quest_etapa = 2 + i
				es.enemy_id = &"lutador_arena"
				es.enemy_name = "Lutador da Arena (%dº Andar)" % ((i + 1) * 45)
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"lutador_arena", node.global_position, 3, 2 + i, -1, null, es.enemy_name)

	# Mestres do 200º Andar (Gido, Riehlvelt, Kastro, Hisoka Boss)
	var configs = {
		"LutadorAndar200Gido": {"id": &"piao_gido", "nome": "Gido (Piões de Nen)", "etapa": 18},
		"LutadorAndar200Riehlvelt": {"id": &"riehlvelt", "nome": "Riehlvelt (Cadeira Elétrica)", "etapa": 19},
		"LutadorAndar200Kastro": {"id": &"kastro", "nome": "Kastro (Clone de Nen)", "etapa": 21},
		"MestreAndar200": {"id": &"hisoka_boss", "nome": "Hisoka Boss (200º Andar)", "etapa": 25}
	}
	
	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 3
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 3, es.quest_etapa, -1, null, es.enemy_name)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalYorknew") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Yorknew City"
		portal.map_subtitle = "Arco 4 — O Leilão Subterrâneo & A Trupe Fantasma"
		portal.story_gate = StoryGate.new(3, 26, true)
		portal.story_gate.gate_title = "Saída da Arena Celestial"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 26 etapas da Arena Celestial e devolver a placa a Hisoka antes de partir para Yorknew!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_arena_celestial_cutscene(get_tree(), mudar_cena_cb)