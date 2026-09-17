class_name MissionObjectiveResolver
extends RefCounted

# ============================================================
# HUNTER ONLINE — FONTE ÚNICA DE VERDADE: OBJETIVO + GPS
# ============================================================
#
# Pipeline estrito (nunca inventa alvo):
# 1) Quest canônica do arco/etapa (não side-quest aleatória)
# 2) Objetivo pendente real
# 3) Alvo exato no mapa (NPC/inimigo/loot/pista/zona)
# 4) Se mapa errado → portal de viagem (NUNCA story_gate)
# 5) Se mapa certo sem entidade → zona de busca (âncora/placa)
# 6) story_gate / portal de avanço SÓ com etapa completa
#
# ============================================================

const ARRIVAL_DISTANCE: float = 35.0

const ARCO_MAPAS: Dictionary = {
	1: "res://world/maps/exame_maratona.tscn",
	2: "res://world/maps/montanha_kukuroo.tscn",
	3: "res://world/maps/arena_celestial.tscn",
	4: "res://world/maps/yorknew_city.tscn",
	5: "res://world/maps/greed_island.tscn",
	6: "res://world/maps/ngl_formigas.tscn",
	7: "res://world/maps/associacao_hunter.tscn",
	8: "res://world/maps/continente_negro.tscn",
	9: "res://world/maps/black_whale_1.tscn",
}


static func empty_result() -> Dictionary:
	return {
		"found": false,
		"node": null,
		"position": Vector2.ZERO,
		"name": "",
		"type": "",
		"quest": null,
		"objective": null,
		"objective_index": -1,
		"total_objectives": 0,
		"progress": 0,
		"required": 1,
		"remaining": 0,
		"stage_complete": false,
		"is_lobby": false,
		"lobby_step": -1,
		"secret": false,
		"on_correct_map": true,
		"expected_map": "",
		"hud_title": "",
		"hud_objective": "",
		"hud_action": "",
		"gps_label": "",
		"gps_color": Color(1.0, 0.85, 0.3, 1.0),
	}


static func resolve(tree: SceneTree, player: Node2D = null) -> Dictionary:
	var result := empty_result()
	if tree == null:
		return result

	var cur_scn: Node = tree.current_scene
	if cur_scn == null:
		return result

	var cena_path: String = ""
	if cur_scn.scene_file_path != null:
		cena_path = str(cur_scn.scene_file_path)
	var cena_lower := cena_path.to_lower()
	var is_lobby: bool = ("lobby" in cena_lower or cur_scn.name == "Lobby")
	result["is_lobby"] = is_lobby

	if player == null or not is_instance_valid(player):
		var players := tree.get_nodes_in_group("player")
		if not players.is_empty() and players[0] is Node2D:
			player = players[0] as Node2D

	# ---------------------------------------------------------
	# LOBBY HUB: tutorial → Nen → saída para a missão ativa
	# ---------------------------------------------------------
	if is_lobby:
		return _resolve_lobby(cur_scn, player, result)

	# ---------------------------------------------------------
	# MUNDO / SAGA
	# ---------------------------------------------------------
	if QuestSystem == null:
		result["hud_action"] = "Sistema de missões indisponível."
		result["gps_label"] = "📜 Missões indisponíveis"
		return result

	var quest: Quest = get_focus_quest()
	if quest == null:
		QuestSystem.garantir_quest_do_arco(PlayerData.arco_atual if PlayerData != null else 1)
		quest = get_focus_quest()

	if quest == null:
		result["hud_title"] = "Sem Missão Ativa"
		result["hud_objective"] = "Aguardando início de novo arco narrativo..."
		result["hud_action"] = "Explore o mundo e converse com os cidadãos."
		result["gps_label"] = "📜 Sem missão ativa — explore o mapa"
		return result

	result["quest"] = quest
	result["hud_title"] = quest.quest_name

	if "is_secret" in quest and quest.is_secret:
		result["secret"] = true
		result["hud_objective"] = "Missão secreta: pistas ocultas no ambiente (sem GPS)."
		result["hud_action"] = "🔍 Explore sem bússola — segredo orgânico."
		result["gps_label"] = "🔍 [SEGREDO] %s — sem GPS" % quest.quest_name
		result["gps_color"] = Color(0.9, 0.7, 1.0, 1.0)
		return result

	var total: int = quest.objectives.size()
	result["total_objectives"] = total
	var pendente_idx := get_pending_objective_index(quest)
	result["objective_index"] = pendente_idx

	if pendente_idx < 0:
		result["stage_complete"] = true
		return _resolve_stage_complete(tree, cur_scn, player, quest, result)

	var obj: QuestObjective = quest.objectives[pendente_idx]
	result["objective"] = obj
	var prog: int = PlayerData.get_quest_objective_progress(quest, pendente_idx) if PlayerData != null else 0
	var req: int = max(1, obj.required_amount)
	var faltam: int = max(1, req - prog)
	result["progress"] = prog
	result["required"] = req
	result["remaining"] = faltam

	var passo := "Passo %d/%d" % [pendente_idx + 1, total]
	result["hud_objective"] = "👉 %s: %s (%d/%d)" % [passo, obj.describe(), prog, req]

	var expected_map := get_expected_map_path(quest)
	result["expected_map"] = expected_map
	var on_correct := _is_on_expected_map(cena_lower, expected_map)
	result["on_correct_map"] = on_correct

	# 1) Alvo exato no mapa atual
	var exact := _find_exact_target(tree, cur_scn, player, obj)
	if exact.get("found", false):
		_apply_target(result, exact)
		_fill_action_labels(result, player, passo, faltam)
		return result

	# 2) Mapa errado → portal de viagem (nunca story_gate)
	if not on_correct:
		var portal := _find_travel_portal(cur_scn, expected_map, false)
		if portal != null:
			_apply_target(result, {
				"found": true,
				"node": portal,
				"position": portal.global_position,
				"name": _portal_display_name(portal, "Rota para o objetivo"),
				"type": "portal",
			})
			result["hud_action"] = "⛩️ Vá até [%s] para alcançar o mapa da missão." % result["name"]
			result["gps_label"] = "%s: Viaje por [%s]" % [passo, result["name"]]
			result["gps_color"] = Color(1.0, 0.8, 0.2, 1.0)
			_fill_distance_suffix(result, player)
			return result

	# 3) Mapa certo / sem portal: zona de busca (NÃO fingir que Guia é o NPC da missão)
	var zone := _find_search_zone(cur_scn, obj)
	if zone.get("found", false):
		_apply_target(result, zone)
		result["hud_action"] = "📍 Procure na zona: %s" % result["name"]
		result["gps_label"] = "%s: Zona — %s" % [passo, result["name"]]
		result["gps_color"] = Color(0.85, 0.85, 0.55, 1.0)
		_fill_distance_suffix(result, player)
		return result

	# 4) Sem alvo: texto claro do objetivo (sem apontar portal de avanço)
	result["hud_action"] = _static_hint(obj)
	result["gps_label"] = "%s: %s (%d/%d)" % [passo, obj.describe(), prog, req]
	result["gps_color"] = Color(0.9, 0.9, 0.9, 1.0)
	return result


# ============================================================
# QUEST FOCO (canônica)
# ============================================================

static func get_focus_quest() -> Quest:
	if QuestSystem == null:
		return null
	var actives: Array = QuestSystem.active_quests
	if actives.is_empty():
		return null

	var arco := PlayerData.arco_atual if PlayerData != null else 1
	var etapa := PlayerData.etapa_quest_arco if PlayerData != null else 1
	var expected_path := "res://data/quests/arco%d_etapa%d.tres" % [arco, etapa]
	var expected_name_token := "%d/%d" % [etapa, CanonQuestCatalog.obter_total_quests_do_arco(arco)]

	# 1) Match exato por resource_path da etapa canônica
	for q in actives:
		if q == null:
			continue
		if "is_secret" in q and q.is_secret:
			continue
		var rp := str(q.resource_path) if "resource_path" in q else ""
		if rp == expected_path or rp.ends_with("arco%d_etapa%d.tres" % [arco, etapa]):
			return q

	# 2) Match por nome da etapa (Exame Hunter 4/24: ...)
	for q in actives:
		if q == null or (("is_secret" in q) and q.is_secret):
			continue
		var qn := str(q.quest_name)
		if expected_name_token in qn or ("Arco %d" % arco) in qn:
			return q
		if qn.begins_with("Exame Hunter") and arco == 1:
			return q
		if "Montanha Kukuroo" in qn and arco == 2:
			return q

	# 3) Primeira não-secreta
	for q in actives:
		if q != null and not (("is_secret" in q) and q.is_secret):
			return q

	return actives[0]


static func get_pending_objective_index(quest: Quest) -> int:
	if quest == null or PlayerData == null:
		return -1
	for i in range(quest.objectives.size()):
		var obj: QuestObjective = quest.objectives[i]
		if obj == null:
			continue
		if PlayerData.get_quest_objective_progress(quest, i) < obj.required_amount:
			return i
	return -1


static func get_pending_objective(quest: Quest = null) -> QuestObjective:
	if quest == null:
		quest = get_focus_quest()
	var idx := get_pending_objective_index(quest)
	if idx < 0 or quest == null:
		return null
	return quest.objectives[idx]


static func get_expected_map_path(quest: Quest = null) -> String:
	if quest == null:
		quest = get_focus_quest()
	var arco: int = PlayerData.arco_atual if PlayerData != null else 1
	var etapa: int = PlayerData.etapa_quest_arco if PlayerData != null else 1

	if quest != null:
		var q_name := quest.quest_name.to_lower()
		if "padokia" in q_name or "wing" in q_name:
			if "guardião" in q_name or "ruínas" in q_name or "dungeon" in q_name:
				return "res://world/maps/dungeon_ruinas_zaban.tscn"
			return "res://world/maps/regiao_vale_padokia.tscn"
		# Infer arco from quest name when PlayerData lags
		if "exame hunter" in q_name:
			arco = 1
		elif "kukuroo" in q_name:
			arco = 2
		elif "arena celestial" in q_name or "heaven's arena" in q_name:
			arco = 3
		elif "yorknew" in q_name:
			arco = 4
		elif "greed island" in q_name:
			arco = 5
		elif "formiga" in q_name or "chimera" in q_name:
			arco = 6
		elif "eleição" in q_name or "alluka" in q_name:
			arco = 7
		elif "continente negro" in q_name:
			arco = 8
		elif "black whale" in q_name or "sucessão" in q_name:
			arco = 9

	return str(ARCO_MAPAS.get(arco, ""))


static func npc_matches_objective(npc_id: String, npc_display_name: String, obj: QuestObjective) -> bool:
	if obj == null:
		return false
	return _score_npc_match(npc_id, npc_display_name, obj) >= 2


static func enemy_matches_objective(enemy_id: String, enemy_name: String, node_name: String, obj: QuestObjective) -> bool:
	if obj == null or obj.type != QuestObjective.Type.KILL:
		return false
	return _score_enemy_match(enemy_id, enemy_name, node_name, obj) >= 2


# ============================================================
# LOBBY
# ============================================================

static func _resolve_lobby(cur_scn: Node, player: Node2D, result: Dictionary) -> Dictionary:
	result["is_lobby"] = true
	result["hud_title"] = "Guia da Cidade dos Caçadores"
	var total_passos := 3

	if PlayerData == null or not PlayerData.tutorial_concluido:
		result["lobby_step"] = 0
		result["hud_objective"] = "👉 Passo 1/%d: Fale com a Recepcionista Elena\n⬜ Passo 2/%d: Desperte Nen com Mestre Wing\n⬜ Passo 3/%d: Saia pelo Portão Sul para a missão" % [total_passos, total_passos, total_passos]
		var elena = cur_scn.get_node_or_null("RecepcionistaElena")
		if elena != null and elena is Node2D:
			_apply_target(result, {
				"found": true,
				"node": elena,
				"position": elena.global_position,
				"name": "Recepcionista Elena",
				"type": "npc",
			})
		result["hud_action"] = "💬 [E] Fale com Elena na Praça Central"
		result["gps_label"] = "👉 Passo 1/%d: Fale com a Recepcionista Elena" % total_passos
		result["gps_color"] = Color(0.3, 0.9, 1.0, 1.0)
		_fill_distance_suffix(result, player)
		return result

	if not PlayerData.despertou_nen:
		result["lobby_step"] = 1
		result["hud_objective"] = "✅ Passo 1/%d: Treinamento com Elena\n👉 Passo 2/%d: Fale com Mestre Wing (Norte)\n⬜ Passo 3/%d: Saia pelo Portão Sul para a missão" % [total_passos, total_passos, total_passos]
		var wing = cur_scn.get_node_or_null("Wing")
		if wing == null:
			wing = _find_node_by_name_tokens(cur_scn, ["wing", "mestre wing"])
		if wing != null and wing is Node2D:
			_apply_target(result, {
				"found": true,
				"node": wing,
				"position": wing.global_position,
				"name": "Mestre Wing",
				"type": "npc",
			})
		result["hud_action"] = "🥋 Vá ao Distrito dos Mestres e fale com Wing [E]"
		result["gps_label"] = "👉 Passo 2/%d: Fale com Mestre Wing (Norte)" % total_passos
		result["gps_color"] = Color(0.35, 1.0, 0.55, 1.0)
		_fill_distance_suffix(result, player)
		return result

	# Passo 3: se já há missão canônica, aponta saída para o mapa dela
	result["lobby_step"] = 2
	var focus := get_focus_quest()
	if focus == null and QuestSystem != null:
		QuestSystem.garantir_quest_do_arco(PlayerData.arco_atual)
		focus = get_focus_quest()

	var expected := get_expected_map_path(focus)
	result["quest"] = focus
	result["expected_map"] = expected
	if focus != null:
		result["hud_title"] = focus.quest_name
		var pidx := get_pending_objective_index(focus)
		if pidx >= 0:
			var o: QuestObjective = focus.objectives[pidx]
			result["objective"] = o
			result["objective_index"] = pidx
			result["total_objectives"] = focus.objectives.size()
			result["hud_objective"] = "✅ Hub pronto\n👉 Missão: %s\n👉 Objetivo: %s\n👉 Vá ao Portão Sul / Mundo Exterior" % [focus.quest_name, o.describe()]
		else:
			result["hud_objective"] = "✅ Hub pronto\n👉 Continue a história pelo Portão Sul"

	var portao = cur_scn.get_node_or_null("PortaoMundoExterior")
	if portao == null:
		portao = _find_travel_portal(cur_scn, expected, false)
	if portao == null:
		var guia = cur_scn.get_node_or_null("StoryGatewayNPC")
		if guia != null and guia is Node2D:
			portao = guia
	if portao != null and portao is Node2D:
		var pname := "Portão Sul (Mundo Exterior)"
		if portao is MapTransitionArea:
			pname = _portal_display_name(portao, pname)
		elif str(portao.name) == "StoryGatewayNPC":
			pname = "Guia da História (Praça)"
		_apply_target(result, {
			"found": true,
			"node": portao,
			"position": (portao as Node2D).global_position,
			"name": pname,
			"type": "portal" if portao is MapTransitionArea else "npc",
		})

	result["hud_action"] = "⛩️ Saia pelo Portão Sul para cumprir o objetivo da missão"
	result["gps_label"] = "👉 Passo 3/%d: Vá ao [%s]" % [total_passos, result.get("name", "Portão Sul")]
	result["gps_color"] = Color(1.0, 0.85, 0.3, 1.0)
	_fill_distance_suffix(result, player)
	return result


static func _resolve_stage_complete(tree: SceneTree, cur_scn: Node, player: Node2D, quest: Quest, result: Dictionary) -> Dictionary:
	result["stage_complete"] = true
	result["hud_objective"] = "✅ Todos os objetivos desta etapa concluídos!"
	var portal := _find_advance_portal(cur_scn)
	if portal != null:
		_apply_target(result, {
			"found": true,
			"node": portal,
			"position": portal.global_position,
			"name": _portal_display_name(portal, "Portão de Avanço da História"),
			"type": "portal",
		})
		result["hud_action"] = "⛩️ Entre em [%s] para avançar a história" % result["name"]
		result["gps_label"] = "✨ Etapa completa → [%s]" % result["name"]
		result["gps_color"] = Color(0.3, 1.0, 0.5, 1.0)
		_fill_distance_suffix(result, player)
		return result

	result["hud_action"] = "Siga para a próxima área da saga."
	result["gps_label"] = "✨ Objetivos concluídos — siga para a próxima área"
	result["gps_color"] = Color(0.3, 1.0, 0.5, 1.0)
	return result


# ============================================================
# BUSCA DE ALVOS
# ============================================================

static func _find_exact_target(tree: SceneTree, cur_scn: Node, player: Node2D, obj: QuestObjective) -> Dictionary:
	if obj == null:
		return {"found": false}

	match obj.type:
		QuestObjective.Type.VISIT, QuestObjective.Type.PERSUASION:
			return _find_npc_target(tree, cur_scn, player, obj)
		QuestObjective.Type.KILL:
			return _find_enemy_target(tree, cur_scn, player, obj)
		QuestObjective.Type.COLLECT:
			return _find_loot_target(tree, obj)
		QuestObjective.Type.INVESTIGATE:
			return _find_clue_target(tree, player, obj)
		QuestObjective.Type.STEALTH_PASS:
			return _find_stealth_target(tree, player, obj)
		_:
			return {"found": false}


static func _find_npc_target(tree: SceneTree, cur_scn: Node, player: Node2D, obj: QuestObjective) -> Dictionary:
	var display := obj.target_npc_name if not obj.target_npc_name.is_empty() else str(obj.target_npc_id).capitalize()
	var best: Node2D = null
	var best_score := -1
	var best_dist := 999999.0

	for n in tree.get_nodes_in_group("npc"):
		if not (n is Node2D) or not is_instance_valid(n) or n.is_queued_for_deletion():
			continue
		# Nunca tratar Guia/Placa genéricos como o NPC da missão
		var nname := str(n.name)
		if nname == "GuiaCapituloSaga" or nname == "PlacaObjetivoCapitulo" or nname == "StoryGatewayNPC":
			continue
		var custom := ""
		if "npc_name" in n and n.npc_name != null:
			custom = str(n.npc_name)
		var score := _score_npc_match(nname, custom, obj)
		if score < 2:
			continue
		var dist := 0.0
		if player != null:
			dist = player.global_position.distance_to((n as Node2D).global_position)
		if score > best_score or (score == best_score and dist < best_dist):
			best_score = score
			best_dist = dist
			best = n as Node2D

	if best == null and cur_scn != null:
		var tid := str(obj.target_npc_id).to_lower()
		var tname := obj.target_npc_name.to_lower()
		var token := tname.split(" ")[0] if not tname.is_empty() else tid
		var found := _find_node_by_name_tokens(cur_scn, [tid, token, tname])
		if found != null and found.name != "GuiaCapituloSaga":
			best = found

	if best == null:
		return {"found": false}

	if "npc_name" in best and best.npc_name != null and not str(best.npc_name).is_empty():
		display = str(best.npc_name)

	return {
		"found": true,
		"node": best,
		"position": best.global_position,
		"name": display,
		"type": "npc",
	}


static func _find_enemy_target(tree: SceneTree, cur_scn: Node, player: Node2D, obj: QuestObjective) -> Dictionary:
	var enemy_type_str := str(obj.enemy_type).to_lower()
	var display := "Inimigo de Missão" if enemy_type_str.is_empty() else enemy_type_str.replace("_", " ").capitalize()
	var living: Array[Node2D] = []
	for g in ["enemies", "enemy"]:
		for n in tree.get_nodes_in_group(g):
			if n is Node2D and is_instance_valid(n) and not n.is_queued_for_deletion() and not living.has(n):
				living.append(n)

	var filtered: Array[Node2D] = []
	for e in living:
		var esys = e.get_node_or_null("EnemySystem")
		if esys != null and ("is_dead" in esys and esys.is_dead):
			continue
		var e_id := str(esys.enemy_id).to_lower() if esys != null and "enemy_id" in esys else ""
		var e_nome := str(esys.enemy_name).to_lower() if esys != null and "enemy_name" in esys else ""
		var score := _score_enemy_match(e_id, e_nome, e.name, obj)
		# score >= 2 = match específico; score 1 = "any"
		if score >= 2 or (score >= 1 and (enemy_type_str.is_empty() or enemy_type_str == "any" or enemy_type_str == "monstro" or enemy_type_str == "inimigo")):
			filtered.append(e)

	# NÃO cair em "qualquer inimigo" se o tipo for específico
	if filtered.is_empty():
		# Fallback: spawn registry positions
		if QuestSystem != null and ("_mission_spawn_registry" in QuestSystem):
			var registry = QuestSystem._mission_spawn_registry
			if registry != null:
				var best_pos := Vector2.ZERO
				var achou := false
				var best_d := 999999.0
				for entry in registry:
					if typeof(entry) != TYPE_DICTIONARY:
						continue
					var eid := str(entry.get("enemy_id", "")).to_lower()
					if not enemy_type_str.is_empty() and eid != enemy_type_str and not (enemy_type_str in eid) and not (eid in enemy_type_str):
						continue
					var pos: Vector2 = entry.get("pos", Vector2.ZERO)
					var d := player.global_position.distance_to(pos) if player != null else 0.0
					if not achou or d < best_d:
						best_d = d
						best_pos = pos
						achou = true
				if achou:
					return {
						"found": true,
						"node": null,
						"position": best_pos,
						"name": display,
						"type": "enemy",
					}
		return {"found": false}

	var closest: Node2D = null
	var closest_d := 999999.0
	for e in filtered:
		var d := player.global_position.distance_to(e.global_position) if player != null else 0.0
		if d < closest_d:
			closest_d = d
			closest = e
	if closest == null:
		return {"found": false}
	var es = closest.get_node_or_null("EnemySystem")
	if es != null and "enemy_name" in es and not str(es.enemy_name).is_empty():
		display = str(es.enemy_name)
	return {
		"found": true,
		"node": closest,
		"position": closest.global_position,
		"name": display,
		"type": "enemy",
	}


static func _find_loot_target(tree: SceneTree, obj: QuestObjective) -> Dictionary:
	var display := str(obj.item_id).replace("_", " ").capitalize()
	for l in tree.get_nodes_in_group("loot"):
		if l is Node2D and is_instance_valid(l) and not l.is_queued_for_deletion():
			return {
				"found": true,
				"node": l,
				"position": l.global_position,
				"name": display,
				"type": "loot",
			}
	return {"found": false}


static func _find_clue_target(tree: SceneTree, player: Node2D, obj: QuestObjective) -> Dictionary:
	var clue_str := str(obj.target_clue_id).to_lower()
	var display := "Pista de Aura [GYO]" if clue_str.is_empty() else clue_str.replace("_", " ").capitalize()
	var best: Node2D = null
	var best_d := 999999.0
	for c in tree.get_nodes_in_group("gyo_inspectable"):
		if not (c is Node2D) or not is_instance_valid(c):
			continue
		var c_id := str(c.clue_id).to_lower() if "clue_id" in c else ""
		if clue_str.is_empty() or clue_str == c_id or clue_str in c_id or c_id in clue_str or clue_str in c.name.to_lower():
			var d := player.global_position.distance_to(c.global_position) if player != null else 0.0
			if d < best_d:
				best_d = d
				best = c
	if best == null:
		return {"found": false}
	return {"found": true, "node": best, "position": best.global_position, "name": display, "type": "clue"}


static func _find_stealth_target(tree: SceneTree, player: Node2D, obj: QuestObjective) -> Dictionary:
	var zone_str := str(obj.target_zone_id).to_lower()
	var display := "Zona Furtiva [ZETSU]" if zone_str.is_empty() else zone_str.replace("_", " ").capitalize()
	var best: Node2D = null
	var best_d := 999999.0
	for z in tree.get_nodes_in_group("zetsu_sensor_zone"):
		if not (z is Node2D) or not is_instance_valid(z):
			continue
		var z_id := str(z.zone_id).to_lower() if "zone_id" in z else ""
		if zone_str.is_empty() or zone_str == z_id or zone_str in z_id or z_id in zone_str or zone_str in z.name.to_lower():
			var d := player.global_position.distance_to(z.global_position) if player != null else 0.0
			if d < best_d:
				best_d = d
				best = z
	if best == null:
		return {"found": false}
	return {"found": true, "node": best, "position": best.global_position, "name": display, "type": "stealth"}


static func _find_search_zone(cur_scn: Node, obj: QuestObjective) -> Dictionary:
	var hint_name := "Zona do Objetivo"
	if obj != null:
		match obj.type:
			QuestObjective.Type.VISIT, QuestObjective.Type.PERSUASION:
				hint_name = obj.target_npc_name if not obj.target_npc_name.is_empty() else str(obj.target_npc_id).capitalize()
			QuestObjective.Type.KILL:
				hint_name = str(obj.enemy_type).replace("_", " ").capitalize() if not str(obj.enemy_type).is_empty() else "Área de Combate"
			QuestObjective.Type.COLLECT:
				hint_name = str(obj.item_id).replace("_", " ").capitalize()
			QuestObjective.Type.INVESTIGATE:
				hint_name = str(obj.target_clue_id).replace("_", " ").capitalize()
			QuestObjective.Type.STEALTH_PASS:
				hint_name = str(obj.target_zone_id).replace("_", " ").capitalize()

	# Placa/âncora = zona de busca (tipo zone), nunca "npc" falso
	if cur_scn != null:
		var placa = cur_scn.get_node_or_null("PlacaObjetivoCapitulo")
		if placa != null and placa is Node2D:
			return {
				"found": true,
				"node": placa,
				"position": (placa as Node2D).global_position,
				"name": hint_name,
				"type": "zone",
			}

	var arco := 1
	var etapa := 1
	if PlayerData != null:
		arco = int(PlayerData.arco_atual)
		etapa = max(1, int(PlayerData.etapa_quest_arco))
	var pos: Vector2 = SagaChapterBinder._district_anchor_for_etapa(arco, etapa)
	return {
		"found": true,
		"node": null,
		"position": pos,
		"name": hint_name,
		"type": "zone",
	}


# ============================================================
# PORTAIS
# ============================================================

static func _find_travel_portal(cur_scn: Node, expected_map: String, allow_story_gate: bool) -> Node2D:
	var transicoes: Array = []
	_collect_transitions(cur_scn, transicoes)

	if not expected_map.is_empty():
		for t in transicoes:
			if t is MapTransitionArea:
				if allow_story_gate == false and t.story_gate != null:
					continue
				var tp := str(t.target_scene_path)
				if tp == expected_map or expected_map in tp or tp.get_file() == expected_map.get_file():
					return t

	# Portão nomeado do lobby / saída
	for preferred in ["PortaoMundoExterior", "PortalExame", "PortalHunter", "SaidaLobby"]:
		var n = cur_scn.get_node_or_null(preferred) if cur_scn != null else null
		if n != null and n is Node2D:
			return n as Node2D

	for t in transicoes:
		if t is MapTransitionArea:
			if allow_story_gate == false and t.story_gate != null:
				continue
			var target_p := t.target_scene_path.to_lower()
			var t_name := t.name.to_lower()
			if "interior" in target_p or "casa" in target_p or "retorno" in t_name or "lobby" in target_p:
				continue
			return t
	return null


static func _find_advance_portal(cur_scn: Node) -> Node2D:
	var transicoes: Array = []
	_collect_transitions(cur_scn, transicoes)

	for t in transicoes:
		if t is MapTransitionArea and t.story_gate != null:
			return t

	for t in transicoes:
		if t is MapTransitionArea:
			var t_name := t.name.to_lower()
			var target_p := t.target_scene_path.to_lower()
			if "retorno" in t_name or "lobby" in target_p or "interior" in target_p or "casa" in target_p:
				continue
			return t

	if not transicoes.is_empty() and transicoes[0] is Node2D:
		return transicoes[0] as Node2D
	return null


static func _portal_display_name(portal: Node, fallback: String) -> String:
	if portal is MapTransitionArea and not (portal as MapTransitionArea).portal_name.is_empty():
		return (portal as MapTransitionArea).portal_name
	return fallback


# ============================================================
# MATCHING
# ============================================================

static func _score_npc_match(node_name: String, display_name: String, obj: QuestObjective) -> int:
	var tid := str(obj.target_npc_id).strip_edges().to_lower()
	var tname := obj.target_npc_name.strip_edges().to_lower()
	var n := node_name.strip_edges().to_lower()
	var c := display_name.strip_edges().to_lower()
	if tid.is_empty() and tname.is_empty():
		return -1

	# Exact
	if (not tid.is_empty() and (tid == n or tid == c)) or (not tname.is_empty() and (tname == n or tname == c)):
		return 4
	# Prefix / begins_with
	if (not tid.is_empty() and tid.length() >= 3 and (n.begins_with(tid) or c.begins_with(tid) or tid.begins_with(n))) \
			or (not tname.is_empty() and tname.length() >= 3 and (n.begins_with(tname) or c.begins_with(tname) or tname.begins_with(c))):
		return 3
	# Token forte (>= 4 chars)
	var token := tname.split(" ")[0] if not tname.is_empty() else tid
	if token.length() >= 4 and (token == n or token == c or n.begins_with(token) or c.begins_with(token)):
		return 2
	# Contém token longo — evita "guia"/"npc" genéricos
	if token.length() >= 4 and ((token in n) or (token in c) or (not tid.is_empty() and tid.length() >= 4 and (tid in n or tid in c))):
		return 2
	return -1


static func _score_enemy_match(enemy_id: String, enemy_name: String, node_name: String, obj: QuestObjective) -> int:
	var target := str(obj.enemy_type).to_lower()
	var e_id := enemy_id.to_lower()
	var e_nome := enemy_name.to_lower()
	var n_name := node_name.to_lower()
	if target.is_empty() or target == "any" or target == "monstro" or target == "inimigo":
		return 1
	if target == e_id or target == e_nome or target == n_name:
		return 4
	if target in e_id or e_id in target or target in n_name or target in e_nome:
		return 3
	var keywords := target.split("_")
	for kw in keywords:
		if kw.length() >= 4 and (kw in e_id or kw in n_name or kw in e_nome):
			return 2
	return -1


# ============================================================
# LABELS / HELPERS
# ============================================================

static func _apply_target(result: Dictionary, exact: Dictionary) -> void:
	result["found"] = true
	result["node"] = exact.get("node", null)
	result["position"] = exact.get("position", Vector2.ZERO)
	result["name"] = str(exact.get("name", ""))
	result["type"] = str(exact.get("type", ""))


static func _fill_action_labels(result: Dictionary, player: Node2D, passo: String, faltam: int) -> void:
	var t: String = str(result.get("type", ""))
	var nome: String = str(result.get("name", ""))
	var near := false
	if player != null and result.get("found", false):
		near = player.global_position.distance_to(result["position"]) <= ARRIVAL_DISTANCE

	match t:
		"npc":
			result["hud_action"] = ("💬 [E] Fale com %s agora!" % nome) if near else ("💬 Fale com %s" % nome)
			result["gps_label"] = ("💬 [E] Fale com [%s] agora!" % nome) if near else ("%s: Fale com [%s]" % [passo, nome])
			result["gps_color"] = Color(0.2, 1.0, 0.4, 1.0) if near else Color(0.3, 0.9, 1.0, 1.0)
		"enemy":
			result["hud_action"] = ("⚔️ [Ataque] Derrote %s!" % nome) if near else ("⚔️ Derrote %s (faltam %d)" % [nome, faltam])
			result["gps_label"] = ("⚔️ [Ataque] Derrote [%s]! (Faltam %d)" % [nome, faltam]) if near else ("%s: Derrote [%s] (Faltam %d)" % [passo, nome, faltam])
			result["gps_color"] = Color(1.0, 0.35, 0.35, 1.0)
		"loot":
			result["hud_action"] = ("🎒 [E] Colete %s!" % nome) if near else ("🎒 Colete %s" % nome)
			result["gps_label"] = ("🎒 [E] Colete [%s]!" % nome) if near else ("%s: Colete [%s]" % [passo, nome])
			result["gps_color"] = Color(1.0, 0.85, 0.3, 1.0)
		"clue":
			result["hud_action"] = ("🔍 [GYO] Examine %s!" % nome) if near else ("🔍 Investigue %s com GYO" % nome)
			result["gps_label"] = ("🔍 [GYO] Examine [%s]!" % nome) if near else ("%s: Investigue [%s]" % [passo, nome])
			result["gps_color"] = Color(0.2, 0.9, 1.0, 1.0)
		"stealth":
			result["hud_action"] = ("🥷 [ZETSU] Atravesse %s!" % nome) if near else ("🥷 Atravesse %s com ZETSU" % nome)
			result["gps_label"] = ("🥷 [ZETSU] Atravesse [%s]!" % nome) if near else ("%s: Atravesse [%s]" % [passo, nome])
			result["gps_color"] = Color(0.4, 1.0, 0.7, 1.0)
		"zone":
			result["hud_action"] = "📍 Procure na zona: %s" % nome
			result["gps_label"] = "%s: Zona — %s" % [passo, nome]
			result["gps_color"] = Color(0.85, 0.85, 0.55, 1.0)
		"portal":
			result["hud_action"] = ("⛩️ [E] Entre em %s!" % nome) if near else ("⛩️ Siga pelo %s" % nome)
			result["gps_label"] = ("⛩️ [E] Entre no [%s]!" % nome) if near else ("%s: Siga pelo [%s]" % [passo, nome])
			result["gps_color"] = Color(1.0, 0.9, 0.2, 1.0)
		_:
			result["hud_action"] = "🎯 Alvo: %s" % nome
			result["gps_label"] = "%s: %s" % [passo, nome]

	_fill_distance_suffix(result, player)


static func _fill_distance_suffix(result: Dictionary, player: Node2D) -> void:
	if player == null or not result.get("found", false):
		return
	var dist: float = player.global_position.distance_to(result["position"])
	if dist <= ARRIVAL_DISTANCE:
		return
	var metros := max(1, int(dist / 10.0))
	var seta := direction_arrow((result["position"] - player.global_position).normalized())
	result["gps_label"] = "%s ➔ %s (%dm)" % [result["gps_label"], seta, metros]
	result["hud_action"] = "%s — %s (%dm)" % [result["hud_action"], seta, metros]


static func direction_arrow(dir: Vector2) -> String:
	var deg := rad_to_deg(dir.angle())
	if deg >= -22.5 and deg < 22.5:
		return "➡ Leste"
	elif deg >= 22.5 and deg < 67.5:
		return "↘ Sudeste"
	elif deg >= 67.5 and deg < 112.5:
		return "⬇ Sul"
	elif deg >= 112.5 and deg < 157.5:
		return "↙ Sudoeste"
	elif deg >= -67.5 and deg < -22.5:
		return "↗ Nordeste"
	elif deg >= -112.5 and deg < -67.5:
		return "⬆ Norte"
	elif deg >= -157.5 and deg < -112.5:
		return "↖ Noroeste"
	else:
		return "⬅ Oeste"


static func _static_hint(obj: QuestObjective) -> String:
	if obj == null:
		return "Siga o objetivo da missão."
	match obj.type:
		QuestObjective.Type.KILL:
			return "⚔️ Derrote as criaturas indicadas na área"
		QuestObjective.Type.VISIT, QuestObjective.Type.PERSUASION:
			if not obj.target_npc_name.is_empty():
				return "💬 Encontre %s neste mapa" % obj.target_npc_name
			return "💬 Fale com o NPC da história"
		QuestObjective.Type.COLLECT:
			return "🎒 Colete os itens indicados no mapa"
		QuestObjective.Type.INVESTIGATE:
			return "🔍 Ative GYO e examine a pista"
		QuestObjective.Type.STEALTH_PASS:
			return "🥷 Ative ZETSU e atravesse a zona"
	return obj.describe()


static func _is_on_expected_map(cena_lower: String, expected_map: String) -> bool:
	if expected_map.is_empty() or cena_lower.is_empty():
		return true
	var dest_leaf := expected_map.get_file().to_lower().replace(".tscn", "")
	return dest_leaf in cena_lower or expected_map.to_lower() in cena_lower


static func _collect_transitions(node: Node, out_list: Array) -> void:
	if node == null:
		return
	if node is MapTransitionArea:
		out_list.append(node)
	for child in node.get_children():
		_collect_transitions(child, out_list)


static func _find_node_by_name_tokens(parent: Node, tokens: Array) -> Node2D:
	if parent == null:
		return null
	var cleaned: Array[String] = []
	for t in tokens:
		var s := str(t).strip_edges().to_lower()
		if s.length() >= 3:
			cleaned.append(s)
	if cleaned.is_empty():
		return null
	return _find_node_by_name_tokens_rec(parent, cleaned)


static func _find_node_by_name_tokens_rec(parent: Node, tokens: Array[String]) -> Node2D:
	if parent is Node2D:
		var p_name := parent.name.to_lower()
		if p_name in ["guiacapitulosaga", "placaobjetivocapitulo", "storygatewaynpc"]:
			pass
		else:
			for tok in tokens:
				if tok == p_name or p_name.begins_with(tok) or (tok.length() >= 4 and tok in p_name):
					return parent as Node2D
			if "npc_name" in parent and parent.npc_name != null:
				var cn := str(parent.npc_name).to_lower()
				for tok in tokens:
					if tok == cn or cn.begins_with(tok) or (tok.length() >= 4 and tok in cn):
						return parent as Node2D
	for child in parent.get_children():
		var found := _find_node_by_name_tokens_rec(child, tokens)
		if found != null:
			return found
	return null
