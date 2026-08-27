class_name MontanhaKukurooMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DA MONTANHA KUKUROO (ARCO 2)
# ============================================================
#
# Coordena os eventos do Arco 2 (Montanha Kukuroo):
# - Popula NPCs necessÃƒÆ’Ã‚Â¡rios para as quests: Zebro, Canary,
#   Gotoh, Silva e o PortÃƒÆ’Ã‚Â£o da Testagem.
# - Configura dados dos inimigos (Guardas Zoldyck, CÃƒÆ’Ã‚Â£o Mike).
# - Rastreia marcos de zona e exibe notificaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes de imersÃƒÆ’Ã‚Â£o.
# - Garante a UI de DiÃƒÆ’Ã‚Â¡logos Visuais.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"portao": false,
	"alameda": false,
	"mansao": false,
	"trono": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco2()
	_configurar_inimigos()
	_configurar_portal_conclusao()
	_garantir_quest_ativa()


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 600 and not _marcos_notificados["portao"]:
		_marcos_notificados["portao"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("ÃƒÂ¢Ã¢â‚¬ÂºÃ‚Â°ÃƒÂ¯Ã‚Â¸Ã‚Â PortÃƒÆ’Ã‚Â£o da Testagem ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Montanha Kukuroo (RepÃƒÆ’Ã‚Âºblica de Padokia)")

	elif px >= 600 and px < 1800 and not _marcos_notificados["alameda"]:
		_marcos_notificados["alameda"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("ÃƒÂ°Ã…Â¸Ã…â€™Ã‚Â² Alameda das ÃƒÆ’Ã‚Ârvores Proibidas ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Cuidado com os CÃƒÆ’Ã‚Â£es de Guarda!")

	elif px >= 1800 and px < 3000 and not _marcos_notificados["mansao"]:
		_marcos_notificados["mansao"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("ÃƒÂ°Ã…Â¸Ã‚ÂÃ‚Â° MansÃƒÆ’Ã‚Â£o dos Mordomos Zoldyck ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Mordomo-Chefe Gotoh")

	elif px >= 3000 and not _marcos_notificados["trono"]:
		_marcos_notificados["trono"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("ÃƒÂ°Ã…Â¸Ã¢â‚¬ËœÃ¢â‚¬Ëœ Sala do Trono dos Assassinos ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Silva Zoldyck")


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(2)


# ============================================================
# POPULAR NPCS DO ARCO 2 (MONTANHA KUKUROO)
# ============================================================

func _popular_npcs_arco2() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[MontanhaKukurooMap] ERRO: NPC.tscn nÃƒÆ’Ã‚Â£o encontrado!")
		return

	# 1. Guarda Zebro (PortÃƒÆ’Ã‚Â£o da Testagem - InÃƒÆ’Ã‚Â­cio do mapa)
	if get_node_or_null("Zebro") == null:
		var zebro = scn_npc.instantiate()
		zebro.name = "Zebro"
		zebro.position = Vector2(200, -100)
		var spr = zebro.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.6, 0.5, 0.3, 1.0) # Marrom velho
		zebro.npc_name = "Guarda Zebro"
		zebro.fala_padrao = "Sou Zebro, guarda do PortÃƒÆ’Ã‚Â£o da Testagem da famÃƒÆ’Ã‚Â­lia Zoldyck. Se quiser entrar, precisa abrir o portÃƒÆ’Ã‚Â£o com sua prÃƒÆ’Ã‚Â³pria forÃƒÆ’Ã‚Â§a!"
		add_child(zebro)

	# 2. PortÃƒÆ’Ã‚Â£o da Testagem (Objeto de InteraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â logo apÃƒÆ’Ã‚Â³s o Zebro)
	if get_node_or_null("PortaoTestagem") == null:
		var portao := StaticBody2D.new()
		portao.name = "PortaoTestagem"
		portao.position = Vector2(400, -50)

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(30, 50)
		col.shape = rect
		portao.add_child(col)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.position = Vector2(0, -17)
		spr.scale = Vector2(1.3, 1.3)
		spr.modulate = Color(0.45, 0.45, 0.5, 1.0) # Cinza metÃƒÆ’Ã‚Â¡lico
		portao.add_child(spr)

		var lbl := Label.new()
		lbl.text = "ÃƒÂ°Ã…Â¸Ã…Â¡Ã‚Âª PortÃƒÆ’Ã‚Â£o da Testagem\n(Testing Gate)"
		lbl.position = Vector2(-60, -38)
		lbl.custom_minimum_size = Vector2(120, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 3)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		portao.add_child(lbl)

		var inter := InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Tentar Abrir o PortÃƒÆ’Ã‚Â£o da Testagem"
		inter.interaction_radius = 22.0
		inter.interacted.connect(func(_player):
			QuestSystem.register_npc_visit(&"portao_testagem")
			var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
			if visual_dialogue:
				var falas: Array[Dictionary] = [
					{"falante": "Narrador", "texto": "VocÃƒÆ’Ã‚Âª agarra as enormes portas de ferro com as duas mÃƒÆ’Ã‚Â£os... O portÃƒÆ’Ã‚Â£o pesa 4 toneladas! Concentrando toda a sua forÃƒÆ’Ã‚Â§a muscular..."},
					{"falante": "PortÃƒÆ’Ã‚Â£o da Testagem", "texto": "ÃƒÂ°Ã…Â¸Ã¢â‚¬ÂÃ¢â‚¬Å“ *CRRRRK!* O portÃƒÆ’Ã‚Â£o abre lentamente! VocÃƒÆ’Ã‚Âª superou a primeira barreira dos Zoldyck!"}
				]
				visual_dialogue.exibir_sequencia_falas(falas)
		)
		portao.add_child(inter)
		add_child(portao)

	# 3. Mordoma Canary (Alameda das ÃƒÆ’Ã‚Ârvores Proibidas)
	if get_node_or_null("Canary") == null:
		var canary = scn_npc.instantiate()
		canary.name = "Canary"
		canary.position = Vector2(1200, 100)
		var spr = canary.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.4, 0.3, 0.6, 1.0) # Roxo escuro
		canary.npc_name = "Mordoma Canary"
		canary.fala_padrao = "Eu sou Canary, mordoma aprendiz. NÃƒÆ’Ã‚Â£o posso permitir que visitantes passem desta alameda... Mas se seus sentimentos por Killua forem reais, talvez eu feche os olhos."
		add_child(canary)

	# 4. Mordomo-Chefe Gotoh (MansÃƒÆ’Ã‚Â£o dos Mordomos)
	if get_node_or_null("Gotoh") == null:
		var gotoh = scn_npc.instantiate()
		gotoh.name = "Gotoh"
		gotoh.position = Vector2(2400, -150)
		var spr = gotoh.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.2, 0.2, 0.2, 1.0) # Preto formal
		gotoh.npc_name = "Mordomo-Chefe Gotoh"
		gotoh.fala_padrao = "Bem-vindo ÃƒÆ’Ã‚Â  MansÃƒÆ’Ã‚Â£o Zoldyck. Sou Gotoh, o mordomo-chefe. Antes de ver o jovem mestre Killua, vocÃƒÆ’Ã‚Âª precisa passar no meu teste de moedas."
		add_child(gotoh)

	# 5. Silva Zoldyck (Sala do Trono dos Assassinos)
	if get_node_or_null("Silva") == null:
		var silva = scn_npc.instantiate()
		silva.name = "Silva"
		silva.position = Vector2(3400, -200)
		var spr = silva.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.scale = Vector2(1.15, 1.15)
			spr.modulate = Color(0.7, 0.7, 0.8, 1.0) # Cinza prateado
		silva.npc_name = "Silva Zoldyck"
		silva.fala_padrao = "Eu sou Silva Zoldyck, chefe da famÃƒÆ’Ã‚Â­lia de assassinos. Killua pode sair, mas sob uma condiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o: jamais traia seus amigos."
		add_child(silva)


# ============================================================
# CONFIGURAR INIMIGOS
# ============================================================

func _configurar_inimigos() -> void:
	# Guardas Zoldyck
	for nome in ["GuardaZoldyck1", "GuardaZoldyck2", "GuardaPortaoTeste"]:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.enemy_id = &"guarda_zoldyck"
				es.enemy_name = "Guarda Zoldyck"

	# CÃƒÆ’Ã‚Â£o de Guarda Mike
	var mike = get_node_or_null("CaoDeGuardaMike")
	if mike != null:
		var es = mike.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"mike"
			es.enemy_name = "CÃƒÆ’Ã‚Â£o de Guarda Mike"

	# Mordomos de Combate (reutiliza inimigos existentes como mordomos)
	for nome in ["GuardaZoldyck1", "GuardaZoldyck2"]:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.enemy_id = &"mordomo_combate"
				es.enemy_name = "Mordomo de Combate Zoldyck"



func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalArenaCelestial") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Arena Celestial"
		portal.map_subtitle = "Arco 3 Ã¢â‚¬â€ O Despertar do Nen & A Torre Celestial"
		portal.story_gate = StoryGate.new(2, 4, true)
		portal.story_gate.gate_title = "PortÃƒÂ£o dos Zoldyck (SaÃƒÂ­da)"
		portal.story_gate.default_locked_message = "VocÃƒÂª precisa resgatar o Killua e concluir os testes da FamÃƒÂ­lia Zoldyck antes de avanÃƒÂ§ar para a Arena Celestial!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_montanha_kukuroo_cutscene(get_tree(), mudar_cena_cb)