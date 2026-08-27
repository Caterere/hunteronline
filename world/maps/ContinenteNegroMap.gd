class_name ContinenteNegroMap
extends Node2D

# ============================================================
# HUNTER ONLINE - MAPA DO CONTINENTE NEGRO (ARCO 8)
# ============================================================
#
# Coordena os eventos do Arco 8:
# - Popula NPCs: Beyond Netero, Ging Freecss, Árvore do Mundo, Ging no Topo.
# - Configura inimigos: Guardiões de Brion, Brion, Serpente Hellbell, Entidade Ai.
# - Rastreia marcos do Acampamento Expedição, Ruínas Ancestrais e Árvore Titânica.
# - Garante a quest ativa e a UI de diálogos visuais.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"acampamento": false,
	"ruinas": false,
	"arvore": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco8()
	_configurar_inimigos()
	_garantir_quest_ativa()


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 1000 and not _marcos_notificados["acampamento"]:
		_marcos_notificados["acampamento"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌳 Fronteira do Continente Negro — Expedição de Beyond e Ging")

	elif px >= 1000 and px < 2800 and not _marcos_notificados["ruinas"]:
		_marcos_notificados["ruinas"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏛️ Ruínas Proibidas do Novo Mundo — As Cinco Calamidades Ancestrais")

	elif px >= 2800 and not _marcos_notificados["arvore"]:
		_marcos_notificados["arvore"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌲 Árvore do Mundo (1.784m) — O Topo da Civilização Conhecida")


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


# ============================================================
# POPULAR NPCS DO ARCO 8
# ============================================================

func _popular_npcs_arco8() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return

	# 1. Beyond Netero (Líder da Expedição)
	if get_node_or_null("Beyond") == null:
		var beyond = scn_npc.instantiate()
		beyond.name = "Beyond"
		beyond.position = Vector2(120, -60)
		var spr = beyond.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.4, 0.2, 1.0)
		beyond.npc_name = "Beyond Netero"
		beyond.fala_padrao = "Meu pai Isaac proibiu a exploração do Continente Negro... Mas agora que ele descansou, o mundo além do Lago Mobius nos pertence! Quem tiver coragem, siga-me!"
		add_child(beyond)

	# 2. Árvore do Mundo (Base Interativa)
	if get_node_or_null("ArvoreMundo") == null:
		var arvore := StaticBody2D.new()
		arvore.name = "ArvoreMundo"
		arvore.position = Vector2(3800, -100)

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(40, 60)
		col.shape = rect
		arvore.add_child(col)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.position = Vector2(0, -17)
		spr.scale = Vector2(1.5, 1.5)
		spr.modulate = Color(0.1, 0.7, 0.3, 1.0)
		arvore.add_child(spr)

		var lbl := Label.new()
		lbl.text = "🌳 Árvore do Mundo (1.784m)\n[E] Iniciar Escalada"
		lbl.position = Vector2(-70, -42)
		lbl.custom_minimum_size = Vector2(140, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 3)
		lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		arvore.add_child(lbl)

		var inter := InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Escalar a Árvore do Mundo"
		inter.interaction_radius = 25.0
		inter.interacted.connect(func(_player):
			QuestSystem.register_npc_visit(&"arvore_mundo")
			var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
			if visual_dialogue:
				var falas: Array[Dictionary] = [
					{"falante": "Narrador", "texto": "Você escala os galhos colossais que ultrapassam as nuvens até alcançar a copa da Árvore do Mundo..."},
					{"falante": "Narrador", "texto": "Lá no alto, sentado em um ninho gigante sob a brisa do horizonte, alguém está esperando por você!"}
				]
				visual_dialogue.exibir_sequencia_falas(falas)
		)
		arvore.add_child(inter)
		add_child(arvore)

	# 3. Ging Freecss no Topo do Mundo
	if get_node_or_null("GingTopo") == null:
		var ging_topo = scn_npc.instantiate()
		ging_topo.name = "GingTopo"
		ging_topo.position = Vector2(4200, -120)
		var spr = ging_topo.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.3, 0.8, 0.9, 1.0)
		ging_topo.npc_name = "Ging Freecss no Topo do Mundo"
		ging_topo.fala_padrao = "Você finalmente chegou até aqui... O que você mais procura não é o objetivo final, mas sim as pessoas e os pequenos desvios que você encontrou pelo caminho!"
		add_child(ging_topo)


# ============================================================
# CONFIGURAR INIMIGOS
# ============================================================

func _configurar_inimigos() -> void:
	var cp1 = get_node_or_null("CriaturaPrimitiva1")
	if cp1 != null:
		var es = cp1.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"guardiao_brion"
			es.enemy_name = "Guardião Botânico de Brion"

	var cp2 = get_node_or_null("CriaturaPrimitiva2")
	if cp2 != null:
		var es = cp2.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"brion_boss"
			es.enemy_name = "Arma Botânica Brion (Calamidade)"

	var bc1 = get_node_or_null("BestaCalamidade1")
	if bc1 != null:
		var es = bc1.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"hellbell_boss"
			es.enemy_name = "Serpente das Duas Caudas Hellbell"

	var bc2 = get_node_or_null("BestaCalamidade2")
	if bc2 != null:
		var es = bc2.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"ai_boss"
			es.enemy_name = "Forma Gasosa Ai (Desejo Co-dependente)"

	var guia = get_node_or_null("GuiaContinente")
	if guia != null:
		var es = guia.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"guardiao_brion"
			es.enemy_name = "Guia Titânico do Lago Mobius"
