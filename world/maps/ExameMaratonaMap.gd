class_name ExameMaratonaMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DO 287Ã‚Âº EXAME HUNTER (MARATONA & PANTANAL)
# ============================================================
#
# Coordena os eventos do Arco 1:
# - Garante a UI de DiÃƒÂ¡logos Visuais e balÃƒÂµes.
# - Configura status e dados dos inimigos das 4 zonas temÃƒÂ¡ticas.
# - Rastreia marcos e notificaÃƒÂ§ÃƒÂµes de imersÃƒÂ£o narrativa.
# - STORY GATE: Impede transiÃƒÂ§ÃƒÂ£o prematura para o Arco 2 sem concluir
#   as etapas obrigatÃƒÂ³rias do Exame Hunter.
# - Configura o diÃƒÂ¡logo cinematogrÃƒÂ¡fico de vitÃƒÂ³ria da 1Ã‚Âª fase
#   ao interagir com o portal da Montanha Kukuroo no fim do pantanal.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"tunel": false,
	"pantanal": false,
	"floresta_gourmet": false,
	"portao_final": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_configurar_inimigos_zonas()
	_configurar_portal_conclusao()


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 1600 and not _marcos_notificados["tunel"]:
		_marcos_notificados["tunel"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("Ã°Å¸ÂÆ’ 1Ã‚Âª Fase: Maratona SubterrÃƒÂ¢nea de Zaban (80km)")

	elif px >= 1600 and px < 3800 and not _marcos_notificados["pantanal"]:
		_marcos_notificados["pantanal"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("Ã°Å¸Å’Â«Ã¯Â¸Â Pantanal Numere Ã¢â‚¬â€ O Ninho dos Trapaceiros")

	elif px >= 3800 and px < 5400 and not _marcos_notificados["floresta_gourmet"]:
		_marcos_notificados["floresta_gourmet"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("Ã°Å¸Ââ€“ Floresta Biska Ã¢â‚¬â€ 2Ã‚Âª Fase: Hunters Gourmet (Menchi & Buhara)")

	elif px >= 5400 and not _marcos_notificados["portao_final"]:
		_marcos_notificados["portao_final"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("Ã°Å¸Å¡Âª PortÃƒÂ£o de Chegada do 287Ã‚Âº Exame Hunter")


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _configurar_inimigos_zonas() -> void:
	var data_sabotador = load("res://resource/status/CandidatoSabotador.tres")
	var data_pantanal = load("res://resource/status/MacacoPantanal.tres")
	var data_javali = load("res://resource/status/GreatStampPig.tres")

	# Sabotadores do TÃƒÂºnel
	for nome in ["InimigoMaratona1", "InimigoMaratona2", "InimigoMaratona3"]:
		var node = get_node_or_null(nome)
		if node != null:
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				if "enemy_data" in es and data_sabotador != null:
					es.set("enemy_data", data_sabotador)
				if "enemy_id" in es:
					es.set("enemy_id", &"candidato_exame")
				if "enemy_name" in es:
					es.set("enemy_name", "Candidato Sabotador")
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)

	# Criaturas do Pantanal
	for nome in ["MonstroPantanal1", "MonstroPantanal2", "MonstroPantanal3", "MonstroPantanal4"]:
		var node = get_node_or_null(nome)
		if node != null:
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				if "enemy_data" in es and data_pantanal != null:
					es.set("enemy_data", data_pantanal)
				if "enemy_id" in es:
					es.set("enemy_id", &"criatura_pantanal")
				if "enemy_name" in es:
					es.set("enemy_name", "Macaco de Rosto Humano")
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)

	# Javalis da Floresta Biska
	for nome in ["JavaliGreatStamp1", "JavaliGreatStamp2"]:
		var node = get_node_or_null(nome)
		if node != null:
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				if "enemy_data" in es and data_javali != null:
					es.set("enemy_data", data_javali)
				if "enemy_id" in es:
					es.set("enemy_id", &"great_stamp_pig")
				if "enemy_name" in es:
					es.set("enemy_name", "Grande Javali Selvagem")
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				var spr = node.get_node_or_null("Sprite2D")
				if spr != null:
					spr.modulate = Color(0.85, 0.45, 0.35, 1.0)
					node.scale = Vector2(1.3, 1.3)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalMontanhaKukuroo") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Montanha Kukuroo"
		portal.map_subtitle = "Arco 2 Ã¢â‚¬â€ Propriedade da FamÃƒÂ­lia Zoldyck"
		# Configurar StoryGate oficial exigindo a conclusÃƒÂ£o de todas as etapas do Arco 1
		portal.story_gate = StoryGate.new(1, 6, true)
		portal.story_gate.gate_title = "PortÃƒÂ£o de Chegada do 287Ã‚Âº Exame Hunter"
		portal.story_gate.default_locked_message = "VocÃƒÂª precisa concluir todas as provas do Exame Hunter antes de avanÃƒÂ§ar para o Arco 2!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_conclusao_exame_hunter(get_tree(), mudar_cena_cb)