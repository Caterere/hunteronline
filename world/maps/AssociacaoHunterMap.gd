class_name AssociacaoHunterMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DA ASSOCIAÇÃO HUNTER (ARCO 7 - 20 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 7 (Eleição Hunter & Alluka):
# - Popula NPCs: Cheadle, Pariston, Leorio, Killua, Alluka, Gon Recuperado.
# - Configura inimigos: Mordomos Perseguidores, Homens-Agulha e Illumi Boss.
# - STORY GATE: Exige conclusão das 20 etapas antes do Continente Negro.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"auditorio": false,
	"hospital": false,
	"rodovia": false,
	"tribuna": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco7()
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

	if px >= 0 and px < 1200 and not _marcos_notificados["auditorio"]:
		_marcos_notificados["auditorio"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏛️ Auditório Principal da Associação — O debate dos 12 Zodíacos.")

	elif px >= 1200 and px < 2400 and not _marcos_notificados["hospital"]:
		_marcos_notificados["hospital"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏥 Hospital Geral Hunter — Onde Gon está sob suporte vital.")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["rodovia"]:
		_marcos_notificados["rodovia"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🛣️ Rodovia Noturna — Emboscada dos Homens-Agulha de Illumi!")

	elif px >= 3600 and not _marcos_notificados["tribuna"]:
		_marcos_notificados["tribuna"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🗳️ Plenário de Votação — A eleição da 13ª Presidência Hunter!")


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
		var spr = cheadle.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.3, 0.8, 0.5, 1.0)
		cheadle.npc_name = "Cheadle Yorkshire (Zodíaco Cão)"
		cheadle.fala_padrao = "Precisamos preservar a integridade da Associação Hunter e cumprir o testamento deixado pelo Presidente Netero."
		add_child(cheadle)

	# 2. Pariston Hill (Auditório)
	if get_node_or_null("Pariston") == null:
		var pariston = scn_npc.instantiate()
		pariston.name = "Pariston"
		pariston.position = Vector2(300, -80)
		var spr = pariston.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.8, 0.2, 1.0)
		pariston.npc_name = "Pariston Hill (Vice-Presidente)"
		pariston.fala_padrao = "Eu só quero que todos se divirtam! Quem vocês acham que seria o melhor presidente? Haha!"
		add_child(pariston)

	# 3. Leorio Paradinight (Hospital / Tribuna)
	if get_node_or_null("Leorio") == null:
		var scn_leorio = load("res://entities/npc/leorio/Leorio.tscn")
		var leorio
		if scn_leorio:
			leorio = scn_leorio.instantiate()
		else:
			leorio = scn_npc.instantiate()
			var spr = leorio.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.2, 0.4, 0.8, 1.0)
		
		leorio.name = "Leorio"
		leorio.position = Vector2(1500, -80)
		leorio.npc_name = "Leorio Paradinight"
		leorio.fala_padrao = "Gon... Você não pode morrer aqui! Se eu me tornar presidente, vou usar todo o poder da Associação para te salvar!"
		add_child(leorio)

	# 4. Killua Zoldyck (Com Alluka nos Braços)
	if get_node_or_null("KilluaAlluka") == null:
		var scn_killua = load("res://entities/npc/killua/Killua.tscn")
		var killua
		if scn_killua:
			killua = scn_killua.instantiate()
		else:
			killua = scn_npc.instantiate()
			var spr = killua.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.4, 0.8, 1.0, 1.0)
		
		killua.name = "KilluaAlluka"
		killua.position = Vector2(1700, -80)
		killua.npc_name = "Killua & Alluka"
		killua.fala_padrao = "Nanika... Por favor, cure o Gon! Eu prometo que vou te proteger para sempre!"
		add_child(killua)

	# 5. Gon Freecss Recuperado (Auditório Final)
	if get_node_or_null("GonRecuperado") == null:
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
				spr.modulate = Color(0.2, 0.9, 0.3, 1.0)
		
		gon.name = "GonRecuperado"
		gon.position = Vector2(3800, -80)
		gon.npc_name = "Gon Freecss Recuperado"
		gon.fala_padrao = "Leorio! Killua! Pessoal! Eu estou de volta! Obrigado por nunca desistirem de mim!"
		add_child(gon)


func _configurar_inimigos() -> void:
	var configs = {
		"AgenteIlicito1": {"id": &"mordomo_perseguidor", "nome": "Mordomo Perseguidor", "etapa": 10},
		"NeedleMan1": {"id": &"humano_agulha", "nome": "Homem-Agulha de Illumi", "etapa": 11},
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
