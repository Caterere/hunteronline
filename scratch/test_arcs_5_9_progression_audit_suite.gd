extends Node

# ============================================================
# HUNTER ONLINE — Auditoria de progressão arcos 5–9
# Verifica NPCs (visit/persuasion), clues Gyo, zonas Zetsu e
# quotas de kill vs inimigos de missão no mapa.
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []
var _findings: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 ARCS 5–9 PROGRESSION AUDIT (cenas .tscn)")
	print("================================================================================")
	await get_tree().process_frame
	await _audit_arc(5, "res://world/maps/greed_island.tscn", 36)
	await _audit_arc(6, "res://world/maps/ngl_formigas.tscn", 48)
	await _audit_arc(7, "res://world/maps/associacao_hunter.tscn", 20)
	await _audit_arc(8, "res://world/maps/continente_negro.tscn", 22)
	await _audit_arc(9, "res://world/maps/black_whale_1.tscn", 26)
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	if not _failures.is_empty():
		print("FALHAS:")
		for f in _failures:
			print("   ❌ ", f)
	if not _findings.is_empty():
		print("FINDINGS (blockers / gaps):")
		for f in _findings:
			print("   ⚠️  ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)


func _note(msg: String) -> void:
	_findings.append(msg)
	print("  ⚠️  ", msg)


func _audit_arc(arco: int, scene_path: String, max_etapa: int) -> void:
	print("\n========== ARCO %d (%s) ==========" % [arco, scene_path.get_file()])
	CanonQuestCatalog._quest_cache.clear()
	PlayerData.despertou_nen = true
	PlayerData.arco_atual = arco

	var packed = load(scene_path) as PackedScene
	_ok(packed != null, "arco%d cena carrega" % arco)
	if packed == null:
		return

	var mapa = packed.instantiate()
	mapa.name = "AuditMap_%d" % arco
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var visit_ids: Dictionary = {}
	var persuasion_ids: Dictionary = {}
	var clue_ids: Dictionary = {}
	var zone_ids: Dictionary = {}
	var kill_needs: Dictionary = {} # id -> max required across etapas

	for e in range(1, max_etapa + 1):
		var q = CanonQuestCatalog.obter_quest_da_etapa(arco, e)
		if q == null or q.objectives.is_empty():
			_note("arco%d etapa%d sem quest/objetivo" % [arco, e])
			continue
		for obj in q.objectives:
			if obj == null:
				continue
			match obj.type:
				QuestObjective.Type.VISIT:
					visit_ids[str(obj.target_npc_id)] = obj
				QuestObjective.Type.PERSUASION:
					persuasion_ids[str(obj.target_npc_id)] = obj
				QuestObjective.Type.INVESTIGATE:
					clue_ids[str(obj.target_clue_id)] = true
				QuestObjective.Type.STEALTH_PASS:
					zone_ids[str(obj.target_zone_id)] = true
				QuestObjective.Type.KILL:
					var eid := str(obj.enemy_type)
					var need := int(obj.required_amount)
					if not kill_needs.has(eid) or int(kill_needs[eid]) < need:
						kill_needs[eid] = need

	# Collect NPC candidates (name + npc_name)
	var npc_nodes: Array = []
	_collect_npcs(mapa, npc_nodes)

	# Visit coverage
	for tid in visit_ids.keys():
		var obj: QuestObjective = visit_ids[tid]
		var found := _find_matching_npc(npc_nodes, obj)
		if found:
			_ok(true, "arco%d visit '%s' → %s" % [arco, tid, found])
		else:
			_ok(false, "arco%d visit '%s' SEM NPC" % [arco, tid])
			_note("BLOCKER arco%d: visit %s / %s sem NPC no mapa" % [arco, tid, obj.target_npc_name])

	# Persuasion coverage
	for tid in persuasion_ids.keys():
		var obj: QuestObjective = persuasion_ids[tid]
		var found := _find_matching_npc(npc_nodes, obj)
		if found:
			_ok(true, "arco%d persuasion '%s' → %s" % [arco, tid, found])
		else:
			_ok(false, "arco%d persuasion '%s' SEM NPC" % [arco, tid])
			_note("BLOCKER arco%d: persuasion %s sem NPC" % [arco, tid])

	# Clue Gyo sensors
	for cid in clue_ids.keys():
		var sensor := _find_clue_sensor(mapa, StringName(cid))
		if sensor != "":
			_ok(true, "arco%d clue '%s' → %s" % [arco, cid, sensor])
		else:
			_ok(false, "arco%d clue '%s' SEM Gyo" % [arco, cid])
			_note("BLOCKER arco%d: investigate %s sem GyoInspectable" % [arco, cid])

	# Stealth zones
	for zid in zone_ids.keys():
		var zone := _find_zetsu_zone(mapa, StringName(zid))
		if zone != "":
			_ok(true, "arco%d stealth '%s' → %s" % [arco, zid, zone])
		else:
			_ok(false, "arco%d stealth '%s' SEM Zetsu" % [arco, zid])
			_note("BLOCKER arco%d: stealth %s sem ZetsuSensorZone" % [arco, zid])

	# Kill quotas vs mission enemies present
	for eid in kill_needs.keys():
		var need: int = int(kill_needs[eid])
		var have := _count_mission_enemies(mapa, StringName(eid))
		# sincronizar_inimigos can spawn more — warn if have < need
		if have >= need:
			_ok(true, "arco%d kill '%s' have %d >= need %d" % [arco, eid, have, need])
		elif have > 0:
			_ok(true, "arco%d kill '%s' have %d < need %d (rely sync)" % [arco, eid, have, need])
			_note("GAP arco%d: kill %s only %d on map, need %d (depends on sincronizar)" % [arco, eid, have, need])
		else:
			_ok(false, "arco%d kill '%s' ZERO on map (need %d)" % [arco, eid, need])
			_note("BLOCKER arco%d: kill %s sem inimigo de missão no mapa" % [arco, eid])

	mapa.queue_free()
	await get_tree().process_frame
	PlayerData.despertou_nen = false
	PlayerData.arco_atual = 1


func _collect_npcs(node: Node, out: Array) -> void:
	if node == null:
		return
	# Heuristic: CharacterBody2D or has npc_name
	if ("npc_name" in node) or node.is_in_group("npc") or node.is_in_group("npcs"):
		out.append(node)
	for c in node.get_children():
		_collect_npcs(c, out)


func _find_matching_npc(npc_nodes: Array, obj: QuestObjective) -> String:
	for n in npc_nodes:
		if n == null or not is_instance_valid(n):
			continue
		var nname := str(n.name)
		var display := nname
		if "npc_name" in n:
			display = str(n.npc_name)
		# Same as live register: display name as id
		if MissionObjectiveResolver.npc_matches_objective(display.to_lower(), display.to_lower(), obj):
			return "%s (%s)" % [nname, display]
		if MissionObjectiveResolver.npc_matches_objective(nname.to_lower(), display.to_lower(), obj):
			return "%s (%s)" % [nname, display]
		# Special scripts often register &"killua" etc.
		var token := str(obj.target_npc_id).to_lower()
		if token != "" and (token == nname.to_lower() or token == display.to_lower()):
			return "%s (%s)" % [nname, display]
	return ""


func _find_clue_sensor(root: Node, clue_id: StringName) -> String:
	return _find_prop_recursive(root, "clue_id", clue_id)


func _find_zetsu_zone(root: Node, zone_id: StringName) -> String:
	return _find_prop_recursive(root, "zone_id", zone_id)


func _find_prop_recursive(node: Node, prop: String, want: StringName) -> String:
	if node == null:
		return ""
	if prop in node and str(node.get(prop)) == str(want):
		return str(node.name)
	for c in node.get_children():
		var r := _find_prop_recursive(c, prop, want)
		if r != "":
			return r
	return ""


func _count_mission_enemies(root: Node, enemy_id: StringName) -> int:
	return _count_mission_enemies_rec(root, enemy_id)


func _count_mission_enemies_rec(node: Node, enemy_id: StringName) -> int:
	var total := 0
	var es = node.get_node_or_null("EnemySystem")
	if es != null and ("is_mission_enemy" in es) and es.is_mission_enemy:
		if QuestSystem != null and QuestSystem._enemy_id_corresponde(enemy_id, es.enemy_id):
			total += 1
	for c in node.get_children():
		total += _count_mission_enemies_rec(c, enemy_id)
	return total
