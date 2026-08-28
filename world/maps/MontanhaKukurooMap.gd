class_name MontanhaKukurooMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DA MONTANHA KUKUROO (ARCO 2 - 18 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 2 (Montanha Kukuroo):
# - Popula NPCs necessários: Guia, Zebro, Canary, Gotoh, Silva, Killua
#   e o Portão da Testagem (Testing Gate).
# - Configura dados dos inimigos (Cão Mike, Mordomos de Combate).
# - Rastreia marcos de zona e exibe notificações de imersão.
# - STORY GATE: Exige conclusão das 18 etapas antes da Arena Celestial.
# - Dispara a cutscene oficial de resgate de Killua.
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
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 600 and not _marcos_notificados["portao"]:
		_marcos_notificados["portao"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("⛰️ Portão da Testagem — Montanha Kukuroo (República de Padokia)")

	elif px >= 600 and px < 1800 and not _marcos_notificados["alameda"]:
		_marcos_notificados["alameda"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌲 Alameda das Árvores Proibidas — Cuidado com os Cães de Guarda!")

	elif px >= 1800 and px < 3000 and not _marcos_notificados["mansao"]:
		_marcos_notificados["mansao"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏰 Mansão dos Mordomos Zoldyck — Mordomo-Chefe Gotoh")

	elif px >= 3000 and not _marcos_notificados["trono"]:
		_marcos_notificados["trono"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("👑 Sala do Trono dos Assassinos — Silva Zoldyck")


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
		print("[MontanhaKukurooMap] ERRO: NPC.tscn não encontrado!")
		return

	# 0. Guia de Turismo de Padokia (Início)
	if get_node_or_null("GuiaTurismo") == null:
		var guia = scn_npc.instantiate()
		guia.name = "GuiaTurismo"
		guia.position = Vector2(50, -50)
		var spr = guia.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.8, 0.3, 1.0)
		guia.npc_name = "Guia de Turismo de Padokia"
		guia.fala_padrao = "Bem-vindo a Padokia! A montanha adiante pertence à temível família de assassinos Zoldyck. Poucos entram e quase ninguém retorna!"
		add_child(guia)

	# 1. Guarda Zebro (Portão da Testagem)
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
			spr.modulate = Color(0.6, 0.5, 0.3, 1.0)
		zebro.npc_name = "Guarda Zebro"
		zebro.fala_padrao = "Sou Zebro, guarda do Portão da Testagem da família Zoldyck. Se quiser entrar, precisa abrir o portão com sua própria força!"
		add_child(zebro)

	# 2. Portão da Testagem (Objeto de Interação)
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
		spr.modulate = Color(0.45, 0.45, 0.5, 1.0)
		portao.add_child(spr)

		var lbl := Label.new()
		lbl.text = "🚪 Portão da Testagem\n(Testing Gate)"
		lbl.position = Vector2(-60, -38)
		lbl.custom_minimum_size = Vector2(120, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 3)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		portao.add_child(lbl)

		var inter := InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Empurrar o Portão da Testagem"
		inter.interaction_radius = 22.0
		inter.interacted.connect(func(_player):
			QuestSystem.register_npc_visit(&"portao_testagem")
			var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
			if visual_dialogue:
				var falas: Array[Dictionary] = [
					{"falante": "Narrador", "texto": "Você agarra as enormes portas de ferro com as duas mãos... O portão pesa 4 toneladas! Concentrando toda a sua força muscular..."},
					{"falante": "Portão da Testagem", "texto": "🔓 *CRRRRK!* O portão abre lentamente! Você superou a primeira barreira dos Zoldyck!"}
				]
				visual_dialogue.exibir_sequencia_falas(falas)
		)
		portao.add_child(inter)
		add_child(portao)

	# 3. Mordoma Canary (Alameda das Árvores Proibidas)
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
			spr.modulate = Color(0.4, 0.3, 0.6, 1.0)
		canary.npc_name = "Mordoma Canary"
		canary.fala_padrao = "Eu sou Canary, mordoma aprendiz. Não posso permitir que visitantes passem desta alameda... Mas se seus sentimentos por Killua forem reais, talvez eu feche os olhos."
		add_child(canary)

	# 4. Mordomo-Chefe Gotoh (Mansão dos Mordomos)
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
			spr.modulate = Color(0.2, 0.2, 0.2, 1.0)
		gotoh.npc_name = "Mordomo-Chefe Gotoh"
		gotoh.fala_padrao = "Bem-vindo à Mansão Zoldyck. Sou Gotoh, o mordomo-chefe. Antes de ver o jovem mestre Killua, você precisa passar no meu teste de moedas."
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
			spr.modulate = Color(0.7, 0.7, 0.8, 1.0)
		silva.npc_name = "Silva Zoldyck"
		silva.fala_padrao = "Eu sou Silva Zoldyck, chefe da família de assassinos. Killua pode sair, mas sob uma condição: jamais traia seus amigos."
		add_child(silva)

	# 6. Killua Zoldyck (Ao lado de Silva para resgate)
	if get_node_or_null("Killua") == null:
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
		killua.name = "Killua"
		killua.position = Vector2(3500, -180)
		killua.npc_name = "Killua Zoldyck"
		killua.fala_padrao = "Gon! Vocês realmente vieram me buscar! Vamos logo sair daqui antes que meu irmão Milluki tente algo. Próxima parada: Arena Celestial!"
		add_child(killua)


# ============================================================
# CONFIGURAR INIMIGOS
# ============================================================

func _configurar_inimigos() -> void:
	# Cães de Guarda Mike (Arco 2, Etapa 7)
	for nome in ["CaoDeGuardaMike", "CaoDeGuardaMike2"]:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 2
				es.quest_etapa = 7
				es.enemy_id = &"mike"
				es.enemy_name = "Cão de Guarda Mike"
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"mike", node.global_position, 2, 7, -1, null, "Cão de Guarda Mike")

	# Mordomos de Combate (Arco 2, Etapa 14)
	for nome in ["GuardaZoldyck1", "GuardaZoldyck2", "GuardaPortaoTeste"]:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 2
				es.quest_etapa = 14
				es.enemy_id = &"mordomo_combate"
				es.enemy_name = "Mordomo de Combate Zoldyck"
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"mordomo_combate", node.global_position, 2, 14, -1, null, "Mordomo de Combate Zoldyck")


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalArenaCelestial") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Arena Celestial"
		portal.map_subtitle = "Arco 3 — O Despertar do Nen & A Torre Celestial"
		portal.story_gate = StoryGate.new(2, 18, true)
		portal.story_gate.gate_title = "Portão dos Zoldyck (Saída)"
		portal.story_gate.default_locked_message = "Você precisa resgatar Killua e concluir todas as 18 etapas da Família Zoldyck antes de avançar para a Arena Celestial!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_montanha_kukuroo_cutscene(get_tree(), mudar_cena_cb)