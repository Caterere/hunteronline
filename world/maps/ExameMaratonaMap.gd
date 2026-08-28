class_name ExameMaratonaMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DO 287º EXAME HUNTER (MARATONA & PANTANAL)
# ============================================================
#
# Coordena os eventos do Arco 1 (24 etapas):
# - Garante a UI de Diálogos Visuais e balões.
# - Configura status e dados dos inimigos das 4 zonas temáticas.
# - Rastreia marcos e notificações de imersão narrativa.
# - STORY GATE: Impede transição prematura para o Arco 2 sem concluir
#   as 24 etapas obrigatórias do Exame Hunter.
# - Configura o diálogo cinematográfico de vitória ao interagir com o portal.
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
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 1600 and not _marcos_notificados["tunel"]:
		_marcos_notificados["tunel"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏃 1ª Fase: Maratona Subterrânea de Zaban (80km)")

	elif px >= 1600 and px < 3800 and not _marcos_notificados["pantanal"]:
		_marcos_notificados["pantanal"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌫️ Pantanal Numere — O Ninho dos Trapaceiros")

	elif px >= 3800 and px < 5400 and not _marcos_notificados["floresta_gourmet"]:
		_marcos_notificados["floresta_gourmet"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🍖 Floresta Biska — 2ª Fase: Hunters Gourmet (Menchi & Buhara)")

	elif px >= 5400 and not _marcos_notificados["portao_final"]:
		_marcos_notificados["portao_final"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🚪 Portão de Chegada do 287º Exame Hunter")


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

	# Sabotadores do Túnel e Competidores (Arco 1, Etapas 4, 19, 21)
	for nome in ["InimigoMaratona1", "InimigoMaratona2", "InimigoMaratona3"]:
		var node = get_node_or_null(nome)
		if node != null:
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 1
				es.quest_etapa = 4
				if "enemy_data" in es and data_sabotador != null:
					es.set("enemy_data", data_sabotador)
				if "enemy_id" in es:
					es.set("enemy_id", &"candidato_exame")
				if "enemy_name" in es:
					es.set("enemy_name", "Candidato Sabotador")
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"candidato_exame", node.global_position, 1, 4, -1, data_sabotador, "Candidato Sabotador")
					QuestSystem.registrar_spawn_posicao_missao(&"candidato_exame", node.global_position, 1, 19, -1, data_sabotador, "Prisioneiro Condenado")
					QuestSystem.registrar_spawn_posicao_missao(&"candidato_exame", node.global_position, 1, 21, -1, data_sabotador, "Competidor Veterano de Zevil")

	# Criaturas do Pantanal (Arco 1, Etapas 8 e 10)
	for nome in ["MonstroPantanal1", "MonstroPantanal2", "MonstroPantanal3", "MonstroPantanal4"]:
		var node = get_node_or_null(nome)
		if node != null:
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 1
				es.quest_etapa = 8
				if "enemy_data" in es and data_pantanal != null:
					es.set("enemy_data", data_pantanal)
				if "enemy_id" in es:
					es.set("enemy_id", &"criatura_pantanal")
				if "enemy_name" in es:
					es.set("enemy_name", "Macaco de Rosto Humano")
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"criatura_pantanal", node.global_position, 1, 8, -1, data_pantanal, "Macaco de Rosto Humano")
					QuestSystem.registrar_spawn_posicao_missao(&"criatura_pantanal", node.global_position, 1, 10, -1, data_pantanal, "Criatura Voraz do Nevoeiro")

	# Javalis da Floresta Biska (Arco 1, Etapa 12)
	for nome in ["JavaliGreatStamp1", "JavaliGreatStamp2"]:
		var node = get_node_or_null(nome)
		if node != null:
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 1
				es.quest_etapa = 12
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
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"great_stamp_pig", node.global_position, 1, 12, -1, data_javali, "Grande Javali Selvagem")


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalMontanhaKukuroo") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Montanha Kukuroo"
		portal.map_subtitle = "Arco 2 — Propriedade da Família Zoldyck"
		portal.story_gate = StoryGate.new(1, 24, true)
		portal.story_gate.gate_title = "Portão de Chegada do 287º Exame Hunter"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 24 etapas do Exame Hunter antes de avançar para a Montanha Kukuroo!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_conclusao_exame_hunter(get_tree(), mudar_cena_cb)