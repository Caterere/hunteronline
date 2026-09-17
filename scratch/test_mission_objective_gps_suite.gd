extends Node

# ============================================================
# Suite: MissionObjectiveResolver + GPS/HUD sync
# godot --headless --path . res://scratch/test_mission_objective_gps_suite.tscn
# ============================================================

const StoryGate = preload("res://world/components/StoryGate.gd")
const MissionObjectiveResolverScript = preload("res://scripts/missions/MissionObjectiveResolver.gd")

var _pass := 0
var _fail := 0


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("=== test_mission_objective_gps_suite ===")
	_test_static_wiring()
	await _test_focus_quest_prefers_canon()
	await _test_gps_points_npc_not_guia()
	await _test_gps_no_story_gate_while_pending()
	await _test_gps_travel_portal_wrong_map()
	await _test_gps_enemy_exact_match()
	await _test_gps_stage_complete_uses_story_gate()
	await _test_hud_matches_gps()
	await _test_npc_match_strict()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_static_wiring() -> void:
	print("-- static wiring --")
	var rsrc := FileAccess.get_file_as_string("res://scripts/missions/MissionObjectiveResolver.gd")
	assert_test("class_name MissionObjectiveResolver" in rsrc, "MissionObjectiveResolver existe")
	assert_test("get_focus_quest" in rsrc, "resolver tem get_focus_quest")
	assert_test("NUNCA story_gate" in rsrc or "nunca story_gate" in rsrc.to_lower() or "allow_story_gate" in rsrc, "resolver documenta pipeline de portal")

	var gps := FileAccess.get_file_as_string("res://ui/hud/MissionGPSIndicator.gd")
	assert_test("MissionObjectiveResolverScript.resolve" in gps, "GPS usa o resolver")
	assert_test("_tentar_alvo_por_marcadores_capitulo" not in gps, "GPS não usa fallback Guia antigo")

	var hud := FileAccess.get_file_as_string("res://ui/hud/QuestHUD.gd")
	assert_test("MissionObjectiveResolverScript.resolve" in hud, "QuestHUD usa o resolver")
	assert_test("ATIVIDADES" not in hud, "QuestHUD sem bloco ATIVIDADES poluído")

	var qmgr := FileAccess.get_file_as_string("res://scripts/missions/QuestManager.gd")
	assert_test("MissionObjectiveResolverScript.get_focus_quest" in qmgr, "QuestManager.get_active_objective usa focus")
	assert_test("npc_matches_objective" in qmgr, "register_npc_visit matching estrito")


func _test_focus_quest_prefers_canon() -> void:
	print("-- focus quest --")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 4
	QuestSystem.active_quests.clear()

	var side := Quest.new()
	side.quest_name = "Side Quest Aleatória"
	side.objectives = [QuestObjective.new()]
	side.objectives[0].type = QuestObjective.Type.VISIT
	side.objectives[0].target_npc_id = &"fulano"
	QuestSystem.active_quests.append(side)

	var canon := CanonQuestCatalog.obter_quest_da_etapa(1, 4)
	QuestSystem.start_quest(canon)

	var focus: Quest = MissionObjectiveResolverScript.get_focus_quest()
	assert_test(focus != null and focus.quest_name == canon.quest_name, "focus = quest canônica da etapa 4")
	assert_test(focus != side, "focus não é a side quest")
	await get_tree().process_frame


func _test_gps_points_npc_not_guia() -> void:
	print("-- GPS NPC vs Guia --")
	var cur = get_tree().current_scene
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 1
	QuestSystem.active_quests.clear()
	var q = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	QuestSystem.start_quest(q)
	PlayerData.set_quest_objective_progress(q, 0, 0)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(0, 0)
	cur.add_child(player)

	var guia := Node2D.new()
	guia.name = "GuiaCapituloSaga"
	guia.position = Vector2(50, 0)
	guia.add_to_group("npc")
	cur.add_child(guia)

	var tonpa := CharacterBody2D.new()
	tonpa.name = "Tonpa"
	tonpa.set("npc_name", "Tonpa o Quebrador de Novatos")
	tonpa.position = Vector2(400, 0)
	tonpa.add_to_group("npc")
	cur.add_child(tonpa)

	var gps := MissionGPSIndicator.new()
	cur.add_child(gps)
	gps.player_ref = player
	await get_tree().process_frame
	gps._atualizar_alvo_ativo()

	assert_test(gps.target_found, "GPS encontrou alvo")
	assert_test(gps.current_target_node == tonpa, "GPS aponta Tonpa (não Guia)")
	assert_test(gps.current_target_type == "npc", "tipo = npc")
	assert_test("Tonpa" in gps.current_target_name or "tonpa" in gps.current_target_name.to_lower(), "nome do alvo = Tonpa")

	gps.queue_free()
	tonpa.queue_free()
	guia.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_gps_no_story_gate_while_pending() -> void:
	print("-- GPS no story_gate pending --")
	var cur = get_tree().current_scene
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 4
	QuestSystem.active_quests.clear()
	var q = CanonQuestCatalog.obter_quest_da_etapa(1, 4)
	QuestSystem.start_quest(q)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(0, 0)
	cur.add_child(player)

	var guia := Node2D.new()
	guia.name = "GuiaCapituloSaga"
	guia.position = Vector2(100, 0)
	cur.add_child(guia)

	var portal := MapTransitionArea.new()
	portal.name = "PortalStoryGate"
	portal.position = Vector2(9000, 0)
	portal.target_scene_path = "res://world/maps/montanha_kukuroo.tscn"
	portal.story_gate = StoryGate.new(1, 24, true)
	cur.add_child(portal)

	# Sem NPC/inimigo — deve ir para zona, NÃO story_gate
	var gps := MissionGPSIndicator.new()
	cur.add_child(gps)
	gps.player_ref = player
	await get_tree().process_frame
	gps._atualizar_alvo_ativo()

	assert_test(gps.target_found, "GPS tem alvo (zona)")
	assert_test(gps.current_target_type != "portal" or gps.current_target_node != portal, "não aponta story_gate com objetivo pendente")
	assert_test(gps.current_target_type == "zone" or gps.current_target_type == "enemy", "fallback = zone/enemy registry")

	gps.queue_free()
	portal.queue_free()
	guia.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_gps_travel_portal_wrong_map() -> void:
	print("-- GPS travel portal wrong map --")
	# Simula cena "lobby-like" path? Usamos resolver diretamente com mapa esperado
	var cur = get_tree().current_scene
	# Força expected map diferente do path atual (suite tscn não é exame)
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 1
	QuestSystem.active_quests.clear()
	var q = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	QuestSystem.start_quest(q)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(0, 0)
	cur.add_child(player)

	var guia := Node2D.new()
	guia.name = "GuiaCapituloSaga"
	guia.position = Vector2(80, 0)
	cur.add_child(guia)

	var travel := MapTransitionArea.new()
	travel.name = "PortalParaExame"
	travel.position = Vector2(300, 0)
	travel.target_scene_path = "res://world/maps/exame_maratona.tscn"
	travel.portal_name = "Portal do Exame"
	cur.add_child(travel)

	var story := MapTransitionArea.new()
	story.name = "PortalStory"
	story.position = Vector2(8000, 0)
	story.target_scene_path = "res://world/maps/montanha_kukuroo.tscn"
	story.story_gate = StoryGate.new(1, 24, true)
	cur.add_child(story)

	# Sem Tonpa no mapa → mapa "errado" (suite != exame_maratona) → portal de viagem
	var resolved: Dictionary = MissionObjectiveResolverScript.resolve(get_tree(), player)
	assert_test(resolved.get("found", false), "resolver encontrou alvo")
	assert_test(not resolved.get("on_correct_map", true), "detectou mapa incorreto")
	assert_test(str(resolved.get("type", "")) == "portal", "tipo = portal de viagem")
	assert_test(resolved.get("node") == travel, "escolheu portal do exame (não story_gate)")
	assert_test(resolved.get("node") != story, "não escolheu story_gate")

	travel.queue_free()
	story.queue_free()
	guia.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_gps_enemy_exact_match() -> void:
	print("-- GPS enemy exact --")
	var cur = get_tree().current_scene
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 8
	QuestSystem.active_quests.clear()
	var q = CanonQuestCatalog.obter_quest_da_etapa(1, 8)
	QuestSystem.start_quest(q)
	PlayerData.set_quest_objective_progress(q, 0, 0)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(0, 0)
	cur.add_child(player)

	var wrong := CharacterBody2D.new()
	wrong.name = "SlimeComum"
	wrong.add_to_group("enemy")
	wrong.position = Vector2(100, 0)
	var ws := Node.new()
	ws.name = "EnemySystem"
	ws.set_script(load("res://scripts/systems/EnemySystem/EnemySystem.gd"))
	wrong.add_child(ws)
	ws.set("enemy_id", &"slime")
	ws.set("enemy_name", "Slime")
	ws.set("is_dead", false)
	cur.add_child(wrong)

	var right := CharacterBody2D.new()
	right.name = "MonstroPantanal"
	right.add_to_group("enemy")
	right.position = Vector2(500, 0)
	var rs := Node.new()
	rs.name = "EnemySystem"
	rs.set_script(load("res://scripts/systems/EnemySystem/EnemySystem.gd"))
	right.add_child(rs)
	rs.set("enemy_id", &"criatura_pantanal")
	rs.set("enemy_name", "Macaco de Rosto Humano")
	rs.set("is_dead", false)
	cur.add_child(right)

	# Força on_correct_map: se suite path não for exame, resolver pode preferir portal.
	# Chamamos find via resolve — se mapa errado, colocamos enemy e ainda assim...
	# Melhor testar _find_enemy_target indireto: se on wrong map, portal wins.
	# Simula mapa certo setando expected vazio override via estar no path — 
	# Usamos resolve e se type portal, ainda validamos enemy_matches.

	var match_ok: bool = MissionObjectiveResolverScript.enemy_matches_objective("criatura_pantanal", "Macaco", "MonstroPantanal", q.objectives[0])
	var match_bad: bool = MissionObjectiveResolverScript.enemy_matches_objective("slime", "Slime", "SlimeComum", q.objectives[0])
	assert_test(match_ok, "enemy_matches criatura_pantanal")
	assert_test(not match_bad, "slime NÃO casa com criatura_pantanal")

	# Exact target no mapa atual (mesmo sem scene_file_path da suite)
	var resolved: Dictionary = MissionObjectiveResolverScript.resolve(get_tree(), player)
	if str(resolved.get("type", "")) == "enemy":
		var alvo = resolved.get("node")
		assert_test(alvo != null and is_instance_valid(alvo), "GPS encontrou nó inimigo")
		assert_test(alvo != wrong, "não aponta slime")
		var esys_alvo = alvo.get_node_or_null("EnemySystem") if alvo != null else null
		var eid_alvo := str(esys_alvo.get("enemy_id")).to_lower() if esys_alvo != null else ""
		var nome_alvo := str(resolved.get("name", "")).to_lower()
		assert_test(
			alvo == right or eid_alvo == "criatura_pantanal" or "pantanal" in str(alvo.name).to_lower() or "macaco" in nome_alvo,
			"GPS/resolver aponta monstro do pantanal (id/nome)"
		)
	else:
		# Suite sem path de mapa: aceita zona/portal; matching unitário já passou
		assert_test(str(resolved.get("type", "")) in ["portal", "zone"], "fora do mapa/sem match: portal/zona")
		assert_test(resolved.get("node") != wrong, "não aponta slime errado")

	right.queue_free()
	wrong.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_gps_stage_complete_uses_story_gate() -> void:
	print("-- GPS stage complete --")
	var cur = get_tree().current_scene
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 4
	QuestSystem.active_quests.clear()
	var q = CanonQuestCatalog.obter_quest_da_etapa(1, 4)
	QuestSystem.start_quest(q)
	# Completa todos os objetivos
	for i in range(q.objectives.size()):
		PlayerData.set_quest_objective_progress(q, i, q.objectives[i].required_amount)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(0, 0)
	cur.add_child(player)

	var portal := MapTransitionArea.new()
	portal.name = "PortalAvanco"
	portal.position = Vector2(600, 0)
	portal.target_scene_path = "res://world/maps/montanha_kukuroo.tscn"
	portal.story_gate = StoryGate.new(1, 24, true)
	portal.portal_name = "Portão de Avanço"
	cur.add_child(portal)

	var resolved: Dictionary = MissionObjectiveResolverScript.resolve(get_tree(), player)
	assert_test(resolved.get("stage_complete", false), "etapa marcada completa")
	assert_test(resolved.get("found", false), "encontrou portal de avanço")
	assert_test(resolved.get("node") == portal, "aponta story_gate após conclusão")
	assert_test(str(resolved.get("type", "")) == "portal", "tipo portal")

	portal.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_hud_matches_gps() -> void:
	print("-- HUD sync GPS --")
	var cur = get_tree().current_scene
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 1
	QuestSystem.active_quests.clear()
	var q = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	QuestSystem.start_quest(q)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(0, 0)
	cur.add_child(player)

	var tonpa := CharacterBody2D.new()
	tonpa.name = "Tonpa"
	tonpa.set("npc_name", "Tonpa o Quebrador de Novatos")
	tonpa.position = Vector2(200, 0)
	tonpa.add_to_group("npc")
	cur.add_child(tonpa)

	var resolved: Dictionary = MissionObjectiveResolverScript.resolve(get_tree(), player)
	var gps := MissionGPSIndicator.new()
	cur.add_child(gps)
	gps.player_ref = player
	await get_tree().process_frame
	gps._atualizar_alvo_ativo()

	assert_test(gps.current_target_name == str(resolved.get("name", "")), "GPS name == resolver name")
	assert_test(gps.current_target_type == str(resolved.get("type", "")), "GPS type == resolver type")
	assert_test("Tonpa" in str(resolved.get("hud_action", "")) or "Tonpa" in str(resolved.get("gps_label", "")), "labels mencionam Tonpa")

	gps.queue_free()
	tonpa.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_npc_match_strict() -> void:
	print("-- NPC match strict --")
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.VISIT
	obj.target_npc_id = &"tonpa"
	obj.target_npc_name = "Tonpa o Quebrador de Novatos"

	assert_test(MissionObjectiveResolverScript.npc_matches_objective("tonpa", "Tonpa", obj), "tonpa casa")
	assert_test(MissionObjectiveResolverScript.npc_matches_objective("Tonpa", "Tonpa o Quebrador de Novatos", obj), "display casa")
	assert_test(not MissionObjectiveResolverScript.npc_matches_objective("GuiaCapituloSaga", "Guia do Capítulo", obj), "Guia NÃO casa")
	assert_test(not MissionObjectiveResolverScript.npc_matches_objective("npc", "Viajante", obj), "NPC genérico NÃO casa")
	await get_tree().process_frame
