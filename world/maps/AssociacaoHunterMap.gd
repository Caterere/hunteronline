class_name AssociacaoHunterMap
extends Node2D

# ============================================================
# HUNTER ONLINE - MAPA DA ASSOCIAÇÃO HUNTER (ARCO 7 - ELEIÇÃO)
# ============================================================
#
# Coordena os eventos do Arco 7:
# - Popula NPCs: Cheadle, Pariston, Alluka, Gon Recuperado, Killua, Leorio.
# - Configura inimigos: Agentes Ilícitos, Needle Men (Humanos Manipulados), Illumi.
# - Rastreia marcos do Auditório dos Zodíacos, Rodovia e Hospital.
# - Garante a quest ativa e a UI de diálogos visuais.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"auditorio": false,
	"rodovia": false,
	"hospital": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco7()
	_configurar_inimigos()
	_garantir_quest_ativa()


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 1200 and not _marcos_notificados["auditorio"]:
		_marcos_notificados["auditorio"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏛️ Auditório Principal da Associação — Eleição do 13º Presidente")

	elif px >= 1200 and px < 3000 and not _marcos_notificados["rodovia"]:
		_marcos_notificados["rodovia"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🚗 Rodovia Expressa — Emboscada dos Homens-Agulha de Illumi")

	elif px >= 3000 and not _marcos_notificados["hospital"]:
		_marcos_notificados["hospital"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏥 Hospital Hunter Geral — O Milagre de Nanika & Recuperação de Gon")


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


# ============================================================
# POPULAR NPCS DO ARCO 7
# ============================================================

func _popular_npcs_arco7() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return

	# 1. Cheadle Yorkshire (Zodíaco Cão)
	if get_node_or_null("Cheadle") == null:
		var cheadle = scn_npc.instantiate()
		cheadle.name = "Cheadle"
		cheadle.position = Vector2(100, -80)
		var spr = cheadle.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.3, 0.8, 0.6, 1.0)
		cheadle.npc_name = "Cheadle Yorkshire"
		cheadle.fala_padrao = "Como médica e Zodíaco Cão, meu compromisso é defender a vontade do Presidente Netero e preservar a integridade da Associação contra políticos corruptos."
		add_child(cheadle)

	# 2. Pariston Hill (Vice-Presidente)
	if get_node_or_null("Pariston") == null:
		var pariston = scn_npc.instantiate()
		pariston.name = "Pariston"
		pariston.position = Vector2(250, 60)
		var spr = pariston.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(1.0, 0.9, 0.4, 1.0)
		pariston.npc_name = "Pariston Hill"
		pariston.fala_padrao = "Hehe... Todos me odeiam tanto, não é fascinante? Eu não quero vencer nem perder. Só quero brincar com as regras até que tudo fique em caos absoluto!"
		add_child(pariston)

	# 3. Killua (Na escolta de Alluka)
	if get_node_or_null("KilluaEscolta") == null:
		var killua = scn_npc.instantiate()
		killua.name = "Killua"
		killua.position = Vector2(1400, -100)
		var spr = killua.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.3, 0.8, 1.0, 1.0)
		killua.npc_name = "Killua Zoldyck"
		killua.fala_padrao = "Eu nunca vou abandonar a Alluka! O Illumi não entende o valor de uma família. Vamos levar ela até o quarto do Gon a qualquer custo!"
		add_child(killua)

	# 4. Alluka & Nanika
	if get_node_or_null("Alluka") == null:
		var alluka = scn_npc.instantiate()
		alluka.name = "Alluka"
		alluka.position = Vector2(3400, -50)
		var spr = alluka.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(1.0, 0.6, 0.8, 1.0)
		alluka.npc_name = "Alluka & Nanika"
		alluka.fala_padrao = "‘Ai... Faça um pedido!’... ‘Irmãozinho Killua, eu amo você!’"
		add_child(alluka)

	# 5. Gon Recuperado (No quarto do hospital)
	if get_node_or_null("GonRecuperado") == null:
		var gon = scn_npc.instantiate()
		gon.name = "GonRecuperado"
		gon.position = Vector2(3600, -50)
		var spr = gon.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.2, 0.9, 0.3, 1.0)
		gon.npc_name = "Gon Freecss Recuperado"
		gon.fala_padrao = "Killua! Leorio! Vocês estão todos aqui!... Obrigado por nunca desistirem de mim. Eu finalmente posso ir encontrar meu pai no topo da Árvore do Mundo!"
		add_child(gon)


# ============================================================
# CONFIGURAR INIMIGOS
# ============================================================

func _configurar_inimigos() -> void:
	var a1 = get_node_or_null("AgenteIlicito1")
	if a1 != null:
		var es = a1.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"mordomo_perseguidor"
			es.enemy_name = "Mordomo Perseguidor Zoldyck"

	var a2 = get_node_or_null("AgenteIlicito2")
	if a2 != null:
		var es = a2.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"mordomo_perseguidor"
			es.enemy_name = "Agente Imediato de Pariston"

	var nm1 = get_node_or_null("NeedleMan1")
	if nm1 != null:
		var es = nm1.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"humano_agulha"
			es.enemy_name = "Humano Hipnotizado por Agulha"

	var nm2 = get_node_or_null("NeedleMan2")
	if nm2 != null:
		var es = nm2.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"humano_agulha"
			es.enemy_name = "Humano Hipnotizado por Agulha"

	var illumi = get_node_or_null("IllumiInimigo")
	if illumi != null:
		var es = illumi.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"illumi"
			es.enemy_name = "Illumi Zoldyck (Manipulador)"
