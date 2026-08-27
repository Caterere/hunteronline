class_name NGLFormigasMap
extends Node2D

# ============================================================
# HUNTER ONLINE - MAPA DAS FORMIGAS CHIMERA (ARCO 6 - NGL & PEIJIN)
# ============================================================
#
# Coordena os eventos do Arco 6:
# - Popula NPCs: Kite, Knuckle, Shoot, Morel, Netero, Meruem.
# - Configura inimigos: Formigas Soldado, Formiga Oficial, Guarda Peijin,
#   Youpi, Shaiapouf, Neferpitou.
# - Rastreia marcos da NGL, Palácio e Sala do Trono.
# - Garante a quest ativa e a UI de diálogos visuais.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"fronteira": false,
	"bosque": false,
	"palacio": false,
	"trono": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco6()
	_configurar_inimigos()
	_garantir_quest_ativa()


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 800 and not _marcos_notificados["fronteira"]:
		_marcos_notificados["fronteira"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🐜 Fronteira da NGL — Território das Formigas Quimera")

	elif px >= 800 and px < 2000 and not _marcos_notificados["bosque"]:
		_marcos_notificados["bosque"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌲 Bosque Proibido — Esquadrões de Extermínio")

	elif px >= 2000 and px < 3400 and not _marcos_notificados["palacio"]:
		_marcos_notificados["palacio"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏰 Palácio Real de Peijin — Invasão sob a Chuva de Dragões")

	elif px >= 3400 and not _marcos_notificados["trono"]:
		_marcos_notificados["trono"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("👑 Sala do Trono do Rei — Meruem e a Guarda Real")


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(6)


# ============================================================
# POPULAR NPCS DO ARCO 6
# ============================================================

func _popular_npcs_arco6() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		return

	# 1. Kite (Fronteira NGL)
	if get_node_or_null("Kite") == null:
		var kite = scn_npc.instantiate()
		kite.name = "Kite"
		kite.position = Vector2(200, -80)
		var spr = kite.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.85, 0.9, 1.0, 1.0)
		kite.npc_name = "Kite"
		kite.fala_padrao = "Cuidado onde pisa. Na NGL, as criaturas se alimentam de outros seres vivos para absorver seus genes. O Crazy Slots é imprevisível, mas faremos o trabalho."
		add_child(kite)

	# 2. Knuckle Bine (Campo de Treino de Peijin)
	if get_node_or_null("Knuckle") == null:
		var knuckle = scn_npc.instantiate()
		knuckle.name = "Knuckle"
		knuckle.position = Vector2(1200, 150)
		var spr = knuckle.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(1.0, 0.6, 0.2, 1.0)
		knuckle.npc_name = "Knuckle Bine"
		knuckle.fala_padrao = "Meu Hatsu A.P.R. empresta aura ao inimigo e cobra juros de 10% a cada 10 segundos! Quando a dívida ultrapassar sua aura máxima... Falência de Nen!"
		add_child(knuckle)

	# 3. Shoot McMahon (Base de Operações)
	if get_node_or_null("Shoot") == null:
		var shoot = scn_npc.instantiate()
		shoot.name = "Shoot"
		shoot.position = Vector2(1350, 150)
		var spr = shoot.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.7, 0.5, 0.8, 1.0)
		shoot.npc_name = "Shoot McMahon"
		shoot.fala_padrao = "Eu costumava ter medo até de olhar para meus inimigos... Mas na hora do desespero, vou voar sobre minha gaiola flutuante de mãos!"
		add_child(shoot)

	# 4. Morel Mackernasey (Comandante da Invasão)
	if get_node_or_null("Morel") == null:
		var morel = scn_npc.instantiate()
		morel.name = "Morel"
		morel.position = Vector2(2100, -120)
		var spr = morel.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.3, 0.7, 0.9, 1.0)
		morel.npc_name = "Morel Mackernasey"
		morel.fala_padrao = "Minha fumaça Deep Purple cria soldados e barreiras impossíveis de quebrar. Mantenha a respiração firme!"
		add_child(morel)

	# 5. Rei Meruem (Tranquilo no Palácio)
	if get_node_or_null("MeruemNPC") == null:
		var meruem = scn_npc.instantiate()
		meruem.name = "Meruem"
		meruem.position = Vector2(4200, 50)
		var spr = meruem.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.scale = Vector2(1.2, 1.2)
			spr.modulate = Color(0.2, 0.8, 0.5, 1.0)
		meruem.npc_name = "Rei Meruem"
		meruem.fala_padrao = "Qual é o meu nome?... Komugi me ensinou que o poder não existe para esmagar os fracos, mas para proteger o que é precioso."
		add_child(meruem)


# ============================================================
# CONFIGURAR INIMIGOS
# ============================================================

func _configurar_inimigos() -> void:
	var f1 = get_node_or_null("FormigaSoldado1")
	if f1 != null:
		var es = f1.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"formiga_soldado"
			es.enemy_name = "Formiga Soldado Quimera"

	var f2 = get_node_or_null("FormigaSoldado2")
	if f2 != null:
		var es = f2.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"formiga_oficial"
			es.enemy_name = "Formiga Oficial Quimera"

	var esq = get_node_or_null("EsquadraoQuimera")
	if esq != null:
		var es = esq.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"guarda_peijin"
			es.enemy_name = "Guarda de Peijin (Youpi & Pouf)"

	var pitou = get_node_or_null("NeferpitouInimigo")
	if pitou != null:
		var es = pitou.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"neferpitou"
			es.enemy_name = "Guarda Real Neferpitou"

	var meruem_boss = get_node_or_null("MeruemRei")
	if meruem_boss != null:
		var es = meruem_boss.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"youpi"
			es.enemy_name = "Menthuthuyoupi (Guarda Real)"
