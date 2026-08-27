class_name GreedIslandMap
extends Node2D

# ============================================================
# HUNTER ONLINE - MAPA DE GREED ISLAND (ARCO 5)
# ============================================================

var _marcos_notificados: Dictionary = {
	"antokiba": false,
	"montanhas": false,
	"soufrabi": false,
	"torre_final": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco5()
	_configurar_inimigos()
	_garantir_quest_ativa()


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 900 and not _marcos_notificados["antokiba"]:
		_marcos_notificados["antokiba"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏙️ Cidade de Antokiba — Mês dos Torneios Mensais!")

	elif px >= 900 and px < 2200 and not _marcos_notificados["montanhas"]:
		_marcos_notificados["montanhas"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("⛰️ Montanhas Rochosas — Monstros perigosos habitam aqui.")

	elif px >= 2200 and px < 3400 and not _marcos_notificados["soufrabi"]:
		_marcos_notificados["soufrabi"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏖️ Soufrabi — A cidade portuária dos piratas e sede da queimada mortal!")

	elif px >= 3400 and not _marcos_notificados["torre_final"]:
		_marcos_notificados["torre_final"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏰 Castelo Final — O prêmio aguarda quem reunir todas as cartas.")


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

	# 1. Battera
	if get_node_or_null("Battera") == null:
		var battera = scn_npc.instantiate()
		battera.name = "Battera"
		battera.position = Vector2(100, 0)
		var spr = battera.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.7, 0.5, 0.2, 1.0)
		battera.npc_name = "Bilionário Battera"
		battera.fala_padrao = "Eu pagarei 50 bilhões de Jenny a quem conseguir limpar o jogo Greed Island! Minha amada depende disso..."
		add_child(battera)

	# 2. Antokiba (Objeto/Área)
	if get_node_or_null("Antokiba") == null:
		var antokiba := StaticBody2D.new()
		antokiba.name = "Antokiba"
		antokiba.position = Vector2(500, 100)

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(40, 40)
		col.shape = rect
		antokiba.add_child(col)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.position = Vector2(0, -17)
		spr.scale = Vector2(1.5, 1.5)
		spr.modulate = Color(0.3, 0.5, 0.8, 1.0)
		antokiba.add_child(spr)

		var lbl := Label.new()
		lbl.text = "🏆 Antokiba\n(Quadro de Missões)"
		lbl.position = Vector2(-60, -45)
		lbl.custom_minimum_size = Vector2(120, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 3)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		antokiba.add_child(lbl)

		var inter := InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Verificar torneios"
		inter.interaction_radius = 25.0
		inter.interacted.connect(func(_player):
			QuestSystem.register_npc_visit(&"antokiba")
			var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
			if visual_dialogue:
				var falas: Array[Dictionary] = [
					{"falante": "Quadro de Antokiba", "texto": "Torneio de Pedra-Papel-Tesoura amanhã! Prêmio: Carta Espada da Verdade. Inscreva-se!"}
				]
				visual_dialogue.exibir_sequencia_falas(falas)
		)
		antokiba.add_child(inter)
		add_child(antokiba)

	# 3. Biscuit
	if get_node_or_null("Biscuit_Map") == null:
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
		
		biscuit.name = "Biscuit_Map"
		biscuit.position = Vector2(1200, -200)
		biscuit.npc_name = "Biscuit Krueger"
		biscuit.fala_padrao = "Vocês ainda têm muito o que aprender! Eu serei a mestra de vocês a partir de agora. Se preparem para o inferno!"
		add_child(biscuit)

	# 4. Goreinu
	if get_node_or_null("Goreinu") == null:
		var goreinu = scn_npc.instantiate()
		goreinu.name = "Goreinu"
		goreinu.position = Vector2(2000, 150)
		var spr = goreinu.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.5, 0.4, 0.3, 1.0)
		goreinu.npc_name = "Goreinu"
		goreinu.fala_padrao = "Meus gorilas de Nen são perfeitos para a queimada. Vamos formar uma equipe e derrotar o Razor!"
		add_child(goreinu)

	# 5. Razor
	if get_node_or_null("Razor") == null:
		var razor = scn_npc.instantiate()
		razor.name = "Razor"
		razor.position = Vector2(3000, -100)
		var spr = razor.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.8, 0.3, 0.1, 1.0)
		razor.npc_name = "Game Master Razor"
		razor.fala_padrao = "Eu sou um dos criadores deste jogo e amigo de Ging. Se querem passar, terão que me vencer na queimada. Não vou pegar leve!"
		add_child(razor)

	# 6. Elena
	if get_node_or_null("ElenaGreed") == null:
		var elena = scn_npc.instantiate()
		elena.name = "ElenaGreed"
		elena.position = Vector2(4000, 0)
		var spr = elena.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.85, 0.7, 1.0)
		elena.npc_name = "Elena"
		elena.fala_padrao = "Parabéns por reunir todas as 100 cartas com espaços designados. Como recompensa, você pode escolher três cartas para levar ao mundo real!"
		add_child(elena)


func _configurar_inimigos() -> void:
	var configs = {
		"MonstroNen1": {"id": &"golem_pedra", "nome": "Golem de Pedra"},
		"MonstroNen2": {"id": &"monstro_greed", "nome": "Monstro de Greed Island"},
		"GenthruInimigo": {"id": &"genthru", "nome": "Genthru (Bomber)"},
		"RazorInimigo": {"id": &"razor_boss", "nome": "Razor (Chefe)"}
	}
	
	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
