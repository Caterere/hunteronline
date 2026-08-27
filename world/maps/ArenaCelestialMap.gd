class_name ArenaCelestialMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DA ARENA CELESTIAL (ARCO 3)
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


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 800 and not _marcos_notificados["recepcao"]:
		_marcos_notificados["recepcao"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("ÃƒÂ°Ã…Â¸Ã‚ÂÃ‚Â¢ RecepÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o da Arena Celestial ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Registre-se para lutar!")

	elif px >= 800 and px < 2200 and not _marcos_notificados["ringues_inferiores"]:
		_marcos_notificados["ringues_inferiores"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("ÃƒÂ°Ã…Â¸Ã‚Â¥Ã…Â  Ringues Inferiores ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Ganhe dinheiro e suba de andar!")

	elif px >= 2200 and px < 3400 and not _marcos_notificados["ringues_superiores"]:
		_marcos_notificados["ringues_superiores"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("ÃƒÂ¢Ã…Â¡Ã‚Â¡ Ringues Superiores ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Andares onde o uso de Nen ÃƒÆ’Ã‚Â© obrigatÃƒÆ’Ã‚Â³rio!")

	elif px >= 3400 and not _marcos_notificados["topo"]:
		_marcos_notificados["topo"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("ÃƒÂ°Ã…Â¸Ã†â€™Ã‚Â Topo da Arena (Andar 200+) ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Mestres de Andar e a aura assassina de Hisoka!")


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
		print("[ArenaCelestialMap] ERRO: NPC.tscn nÃƒÆ’Ã‚Â£o encontrado!")
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
		recepcionista.fala_padrao = "Bem-vindo ÃƒÆ’Ã‚Â  Arena Celestial! Por favor, preencha este formulÃƒÆ’Ã‚Â¡rio para se registrar. Boa sorte nas lutas e tente nÃƒÆ’Ã‚Â£o morrer nos andares mais altos!"
		add_child(recepcionista)

	# 2. Zushi
	if get_node_or_null("Zushi") == null:
		var zushi = scn_npc.instantiate()
		zushi.name = "Zushi"
		zushi.position = Vector2(350, -80)
		var spr = zushi.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(1.0, 0.95, 0.7, 1.0)
		zushi.npc_name = "Zushi"
		zushi.fala_padrao = "Osu! Sou Zushi, discÃƒÆ’Ã‚Â­pulo do mestre Wing! Estou aprendendo o estilo Shingen-ryu de Kung Fu. Preciso treinar mais duro! Osu!"
		add_child(zushi)

	# 3. Hisoka
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
		hisoka.fala_padrao = "Oh... VocÃƒÆ’Ã‚Âª chegou atÃƒÆ’Ã‚Â© aqui? Suas frutas ainda estÃƒÆ’Ã‚Â£o muito verdes... Continue amadurecendo para que eu possa esmagÃƒÆ’Ã‚Â¡-las de uma vez. ÃƒÂ¢Ã¢â€žÂ¢Ã‚Â¥"
		add_child(hisoka)


func _configurar_inimigos() -> void:
	var configs = {
		"LutadorAndar200Gido": {"id": &"piao_gido", "nome": "Gido (PiÃƒÆ’Ã‚Âµes de Nen)"},
		"LutadorAndar200Riehlvelt": {"id": &"riehlvelt", "nome": "Riehlvelt (Cadeira de Rodas ElÃƒÆ’Ã‚Â©trica)"},
		"LutadorAndar200Kastro": {"id": &"kastro", "nome": "Kastro (Clone de Nen)"},
		"MestreAndar200": {"id": &"hisoka_boss", "nome": "Hisoka Boss (200Ãƒâ€šÃ‚Âº Andar)"}
	}
	
	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				
				# Adicionar fallback 'lutador_arena' via script
				# Pode nÃƒÆ’Ã‚Â£o ter mÃƒÆ’Ã‚Â©todo para isso, mas vou apenas adicionar aos ids secundÃƒÆ’Ã‚Â¡rios se nÃƒÆ’Ã‚Â£o existir.
				if "secondary_ids" in es:
					es.secondary_ids.append(&"lutador_arena")



func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalYorknew") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Yorknew City"
		portal.map_subtitle = "Arco 4 Ã¢â‚¬â€ O LeilÃƒÂ£o SubterrÃƒÂ¢neo & A Trupe Fantasma"
		portal.story_gate = StoryGate.new(3, 5, true)
		portal.story_gate.gate_title = "SaÃƒÂ­da da Arena Celestial"
		portal.story_gate.default_locked_message = "VocÃƒÂª precisa dominar o Nen e derrotar os Mestres do 200Ã‚Âº Andar antes de partir para Yorknew!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_arena_celestial_cutscene(get_tree(), mudar_cena_cb)