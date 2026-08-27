class_name BlackWhale1Map
extends Node2D

# ============================================================
# HUNTER ONLINE - MAPA DO BLACK WHALE 1 (ARCO 9 - GUERRA DE SUCESSÃO)
# ============================================================
#
# Coordena os eventos do Arco 9:
# - Popula NPCs: Rainha Oito & Woble, Vaso Sagrado de Kakin, Hinrigh, Chrollo, Hisoka.
# - Configura inimigos: Guardas Reais, Bestas Parasitas, Assassinos Heil-Ly,
#   Tserriednich, Boss Final.
# - Rastreia marcos do Convés 1 Real, Conveses Intermediários e Conveses Profundos.
# - Garante a quest ativa e a UI de diálogos visuais.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"conves1": false,
	"conves_mafia": false,
	"conves_fundo": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco9()
	_configurar_inimigos()
	_garantir_quest_ativa()


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 1200 and not _marcos_notificados["conves1"]:
		_marcos_notificados["conves1"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🚢 Black Whale 1 — Convés 1: Aposentos Reais dos 14 Príncipes de Kakin")

	elif px >= 1200 and px < 3000 and not _marcos_notificados["conves_mafia"]:
		_marcos_notificados["conves_mafia"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("💼 Conveses Intermediários — Território das 3 Famílias da Máfia de Kakin")

	elif px >= 3000 and not _marcos_notificados["conves_fundo"]:
		_marcos_notificados["conves_fundo"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🕷️ Conveses Profundos — A Caçada Sangrenta da Trupe Fantasma e Hisoka")


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(9)


# ============================================================
# POPULAR NPCS DO ARCO 9
# ============================================================

func _popular_npcs_arco9() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return

	# 1. Rainha Oito & Príncipe Woble (Aposentos 1014)
	if get_node_or_null("RainhaOito") == null:
		var oito = scn_npc.instantiate()
		oito.name = "RainhaOito"
		oito.position = Vector2(100, -80)
		var spr = oito.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.8, 0.9, 1.0)
		oito.npc_name = "Rainha Oito & Príncipe Woble"
		oito.fala_padrao = "Por favor, Hunter... Salve o pequeno Príncipe Woble! A Guerra de Sucessão dos 14 Príncipes e suas Bestas Guardiãs é um banho de sangue sem misericórdia!"
		add_child(oito)

	# 2. Vaso Sagrado de Kakin (Objeto Interativo de Nen)
	if get_node_or_null("VasoKakin") == null:
		var vaso := StaticBody2D.new()
		vaso.name = "VasoKakin"
		vaso.position = Vector2(600, -50)

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(24, 36)
		col.shape = rect
		vaso.add_child(col)

		var spr := Sprite2D.new()
		spr.texture = load("res://assets/sprites/characters/player.png")
		spr.hframes = 6
		spr.vframes = 10
		spr.frame = 0
		spr.position = Vector2(0, -17)
		spr.modulate = Color(1.0, 0.85, 0.2, 1.0)
		vaso.add_child(spr)

		var lbl := Label.new()
		lbl.text = "🏺 Vaso Sagrado de Kakin\n(Ritual do Ovo da Besta)"
		lbl.position = Vector2(-70, -38)
		lbl.custom_minimum_size = Vector2(140, 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 3)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		vaso.add_child(lbl)

		var inter := InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Examinar o Vaso de Kakin"
		inter.interaction_radius = 22.0
		inter.interacted.connect(func(_player):
			QuestSystem.register_npc_visit(&"vaso_kakin")
			var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
			if visual_dialogue:
				var falas: Array[Dictionary] = [
					{"falante": "Narrador", "texto": "Ao tocar no vaso ancestral da família real, você sente uma aura milenar de juramento de sangue acumulada por gerações de reis!"},
					{"falante": "Vaso Sagrado", "texto": "✨ As Bestas Guardiãs Parasitas foram despertadas nos 14 Príncipes!"}
				]
				visual_dialogue.exibir_sequencia_falas(falas)
		)
		vaso.add_child(inter)
		add_child(vaso)

	# 3. Hinrigh Biganduffno (Máfia Xi-Yu)
	if get_node_or_null("Hinrigh") == null:
		var hinrigh = scn_npc.instantiate()
		hinrigh.name = "Hinrigh"
		hinrigh.position = Vector2(1600, 150)
		var spr = hinrigh.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.3, 0.5, 0.8, 1.0)
		hinrigh.npc_name = "Hinrigh (Família Xi-Yu)"
		hinrigh.fala_padrao = "Meu Hatsu Biohazard transforma objetos em animais vivos. A família Heil-Ly de Morena Prudo enlouqueceu e quer destruir o navio inteiro. Vamos contê-los juntos!"
		add_child(hinrigh)

	# 4. Chrollo Lucilfer (Nos conveses profundos)
	if get_node_or_null("ChrolloNavio") == null:
		var scn_chrollo = load("res://entities/npc/chrollo/Chrollo.tscn")
		var chrollo = scn_chrollo.instantiate() if scn_chrollo else scn_npc.instantiate()
		chrollo.name = "Chrollo"
		chrollo.position = Vector2(3200, -120)
		if not scn_chrollo:
			chrollo.npc_name = "Chrollo Lucilfer"
			chrollo.fala_padrao = "A Trupe Fantasma vai caçar e executar Hisoka neste navio. Não fique no nosso caminho."
		add_child(chrollo)

	# 5. Hisoka Morow (Oculto no armazém)
	if get_node_or_null("HisokaNavio") == null:
		var scn_hisoka = load("res://entities/npc/hisoka/Hisoka.tscn")
		var hisoka = scn_hisoka.instantiate() if scn_hisoka else scn_npc.instantiate()
		hisoka.name = "Hisoka"
		hisoka.position = Vector2(3600, 150)
		if not scn_hisoka:
			hisoka.npc_name = "Hisoka Morow"
			hisoka.fala_padrao = "♦ 10 membros restantes da Trupe... É como um jogo de esconde-esconde no escuro... Schwing~! ♠"
		add_child(hisoka)


# ============================================================
# CONFIGURAR INIMIGOS
# ============================================================

func _configurar_inimigos() -> void:
	var g1 = get_node_or_null("GuardaRealKakin1")
	if g1 != null:
		var es = g1.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"besta_parasita"
			es.enemy_name = "Besta Parasita Guardiã de Kakin"

	var g2 = get_node_or_null("GuardaRealKakin2")
	if g2 != null:
		var es = g2.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"besta_parasita"
			es.enemy_name = "Besta Parasita de Camilla"

	var mafia = get_node_or_null("AssassinoMafia")
	if mafia != null:
		var es = mafia.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"assassino_heilly"
			es.enemy_name = "Assassino Contagiado da Família Heil-Ly"

	var capanga = get_node_or_null("CapangaTserriednich")
	if capanga != null:
		var es = capanga.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"besta_tserriednich"
			es.enemy_name = "Besta Guardiã de Tserriednich (Dupla Face)"

	var besta_final = get_node_or_null("BestaNenGuardiã")
	if besta_final != null:
		var es = besta_final.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"tserriednich_boss"
			es.enemy_name = "Príncipe Tserriednich (Zetsu Paralelo)"
