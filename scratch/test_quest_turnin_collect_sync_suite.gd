extends Node2D

const SimpleGrassTerrainPolicyScript = preload("res://world/components/SimpleGrassTerrainPolicy.gd")
## Suite: turn-in Padokia, COLLECT canônico, sync StoryManager, matching NPC estrito.

const MissionObjectiveResolverScript = preload("res://scripts/missions/MissionObjectiveResolver.gd")
const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")
const CanonQuestCatalogScript = preload("res://resource/quest/CanonQuestCatalog.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== QUEST turn-in / collect / sync / match ===")
	_test_npc_match_hardening()
	_test_padokia_turn_in()
	_test_collect_ovo_aguia()
	_test_story_sync_on_complete()
	_test_grass_policy()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_npc_match_hardening() -> void:
	print("\n[1] matching NPC estrito")
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.VISIT
	obj.target_npc_id = &"cheadle"
	obj.target_npc_name = "Cheadle"
	_ok(MissionObjectiveResolverScript.npc_matches_objective("cheadle", "Cheadle", obj), "cheadle exato casa")
	_ok(not MissionObjectiveResolverScript.npc_matches_objective("AssistenteCheadle", "Assistente de Cheadle", obj), "assistente NÃO rouba cheadle")

	var ging := QuestObjective.new()
	ging.type = QuestObjective.Type.VISIT
	ging.target_npc_id = &"ging_topo"
	ging.target_npc_name = "Ging no Topo"
	_ok(not MissionObjectiveResolverScript.npc_matches_objective("ging", "Ging Freecss", ging), "ging base NÃO completa ging_topo")
	_ok(MissionObjectiveResolverScript.npc_matches_objective("ging_topo", "Ging no Topo", ging), "ging_topo exato casa")


func _test_padokia_turn_in() -> void:
	print("\n[2] turn-in Padokia (Wing)")
	if QuestSystem == null or PlayerData == null:
		_ok(false, "QuestSystem/PlayerData disponíveis")
		return
	# Limpa estado
	QuestSystem.active_quests.clear()
	PlayerData.quest_states.clear()

	var q = PadokiaQuestCatalogScript.obter_quest_principal()
	_ok(q != null and q.auto_complete == false, "principal auto_complete=false")
	_ok(str(q.turn_in_npc_key) == "wing", "turn_in = wing")
	_ok(QuestSystem.start_quest(q), "start_quest principal")

	# Completa objetivos manualmente
	for i in range(q.objectives.size()):
		PlayerData.set_quest_objective_progress(q, i, q.objectives[i].required_amount)
	_ok(QuestSystem.is_all_objectives_done(q), "objetivos todos feitos")

	var before_active := QuestSystem.active_quests.size()
	QuestSystem.register_npc_visit(&"wing")
	_ok(not PlayerData.is_quest_active(q), "quest não está mais active após turn-in")
	_ok(QuestSystem.active_quests.size() < before_active or not QuestSystem.active_quests.has(q), "removida de active_quests")


func _test_collect_ovo_aguia() -> void:
	print("\n[3] COLLECT ovo_aguia via Menchi path")
	if QuestSystem == null or PlayerData == null:
		_ok(false, "autoloads")
		return
	QuestSystem.active_quests.clear()
	var q = CanonQuestCatalogScript.obter_quest_da_etapa(1, 13)
	_ok(q != null, "quest exame 13 existe")
	if q == null:
		return
	_ok(q.objectives.size() > 0 and q.objectives[0].type == QuestObjective.Type.COLLECT, "obj COLLECT")
	_ok(QuestSystem.start_quest(q), "start exame 13")
	QuestSystem.register_item_collected(&"ovo_aguia")
	_ok(not PlayerData.is_quest_active(q) or QuestSystem.is_all_objectives_done(q) or q.auto_complete, "progresso/complete ovo_aguia")


func _test_story_sync_on_complete() -> void:
	print("\n[4] StoryManager sync ao completar")
	if StoryManager == null or PlayerData == null or QuestSystem == null:
		_ok(false, "autoloads story")
		return
	PlayerData.arco_atual = 5
	PlayerData.etapa_quest_arco = 3
	StoryManager.current_saga = 1  # dessinc proposital
	StoryManager.current_chapter = 1
	if StoryManager.has_method("_sincronizar_com_player_data"):
		StoryManager._sincronizar_com_player_data()
	_ok(StoryManager.current_saga == 5, "sync saga → 5")
	_ok(StoryManager.current_chapter == 3, "sync chapter → 3")


func _test_grass_policy() -> void:
	print("\n[5] SimpleGrassTerrainPolicy")
	_ok(SimpleGrassTerrainPolicyScript.ENABLED == true, "ENABLED")
	_ok(SimpleGrassTerrainPolicyScript.plant_structure_props() == false, "não planta estruturas")
	var dummy := Node2D.new()
	add_child(dummy)
	var layer := TileMapLayer.new()
	layer.name = "Estruturas_TileMapLayer"
	dummy.add_child(layer)
	SimpleGrassTerrainPolicyScript.apply_to_map(dummy)
	_ok(dummy.get_node_or_null("SimpleGrassFloor") != null, "SimpleGrassFloor criado")
	_ok(layer.visible == false or layer.get_used_cells().is_empty(), "estruturas limpas/ocultas")
	dummy.queue_free()
