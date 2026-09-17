extends Node

## Territory Wars — meta semanal Associação × Máfia × Salteadores.
## Estende LiveEventManager / WorldEventManager; ownership persistente leve.

signal territory_claimed(route_id: String, faction_id: String)
signal weekly_war_started(week_id: int, contested: Array)
signal weekly_war_resolved(week_id: int, results: Dictionary)

const ROUTES := {
	"ponte_padokia": {
		"id": "ponte_padokia",
		"name": "Ponte de Padokia",
		"factions": ["associacao", "salteadores", "mafia"],
		"default_owner": "associacao",
	},
	"rota_yorknew": {
		"id": "rota_yorknew",
		"name": "Rota Comercial Yorknew",
		"factions": ["associacao", "mafia"],
		"default_owner": "mafia",
	},
	"passagem_yorbian": {
		"id": "passagem_yorbian",
		"name": "Passagem Yorbian",
		"factions": ["associacao", "salteadores"],
		"default_owner": "salteadores",
	},
}

var ownership: Dictionary = {} ## route_id -> faction_id
var week_id: int = -1
var contested_this_week: Array = []
var war_scores: Dictionary = {} ## route_id -> {faction: score}


func _ready() -> void:
	_ensure_week()
	for rid in ROUTES.keys():
		if not ownership.has(rid):
			ownership[rid] = str(ROUTES[rid].get("default_owner", "associacao"))


func _process(_delta: float) -> void:
	_ensure_week()


func get_route_owner(route_id: String) -> String:
	_ensure_week()
	return str(ownership.get(route_id, ROUTES.get(route_id, {}).get("default_owner", "")))


func list_routes() -> Array:
	_ensure_week()
	var out: Array = []
	for rid in ROUTES.keys():
		var row: Dictionary = (ROUTES[rid] as Dictionary).duplicate(true)
		row["owner"] = get_route_owner(rid)
		row["contested"] = contested_this_week.has(rid)
		row["scores"] = (war_scores.get(rid, {}) as Dictionary).duplicate(true)
		out.append(row)
	return out


func start_skirmish(route_id: String) -> Dictionary:
	_ensure_week()
	if not ROUTES.has(route_id):
		return {"ok": false, "error": "rota_desconhecida"}
	if not contested_this_week.has(route_id):
		contested_this_week.append(route_id)
	if not war_scores.has(route_id):
		war_scores[route_id] = {}
		for f in ROUTES[route_id].get("factions", []):
			war_scores[route_id][str(f)] = 0
	# Bridge to live events when available
	# LiveEventManager.start_live_event expects a Resource — skip stub bridge here.
	if WorldEventManager != null and WorldEventManager.has_method("iniciar_evento_disputa_ponte") and route_id == "ponte_padokia":
		WorldEventManager.iniciar_evento_disputa_ponte()
	weekly_war_started.emit(week_id, contested_this_week.duplicate())
	return {"ok": true, "route_id": route_id, "week_id": week_id}


func report_skirmish_result(route_id: String, winner_faction: String, points: int = 10) -> Dictionary:
	_ensure_week()
	if not ROUTES.has(route_id):
		return {"ok": false, "error": "rota_desconhecida"}
	if not war_scores.has(route_id):
		start_skirmish(route_id)
	var scores: Dictionary = war_scores[route_id]
	if not scores.has(winner_faction):
		return {"ok": false, "error": "faccao_invalida"}
	scores[winner_faction] = int(scores[winner_faction]) + maxi(1, points)
	war_scores[route_id] = scores
	return {"ok": true, "scores": scores.duplicate(true)}


func resolve_week(force: bool = false) -> Dictionary:
	_ensure_week()
	var results := {}
	for rid in contested_this_week:
		var scores: Dictionary = war_scores.get(rid, {})
		var best_f := str(ownership.get(rid, ""))
		var best_s := -1
		for f in scores.keys():
			var s := int(scores[f])
			if s > best_s:
				best_s = s
				best_f = str(f)
		if best_s >= 0 and not best_f.is_empty():
			ownership[rid] = best_f
			territory_claimed.emit(rid, best_f)
			# Persist light flag
			if WorldState != null and WorldState.has_method("set_flag"):
				WorldState.set_flag("territory_%s" % rid, best_f)
		results[rid] = {"owner": ownership.get(rid, ""), "scores": scores.duplicate(true)}
	weekly_war_resolved.emit(week_id, results)
	if force:
		week_id = _current_week()
	contested_this_week.clear()
	war_scores.clear()
	return {"ok": true, "week_id": week_id, "results": results}


func claim_for_tests(route_id: String, faction_id: String) -> void:
	ownership[route_id] = faction_id
	territory_claimed.emit(route_id, faction_id)


func _ensure_week() -> void:
	var w := _current_week()
	if w != week_id:
		if week_id >= 0 and not contested_this_week.is_empty():
			resolve_week()
		week_id = w
		# Auto-contest 1–2 routes each week
		contested_this_week = ["ponte_padokia"]
		if (w % 2) == 0:
			contested_this_week.append("rota_yorknew")
		else:
			contested_this_week.append("passagem_yorbian")
		war_scores.clear()
		for rid in contested_this_week:
			war_scores[rid] = {}
			for f in ROUTES.get(rid, {}).get("factions", []):
				war_scores[rid][str(f)] = 0
		weekly_war_started.emit(week_id, contested_this_week.duplicate())


func _current_week() -> int:
	if TimeManager != null and TimeManager.has_method("obter_dia"):
		return int(TimeManager.obter_dia()) / 7
	return int(Time.get_unix_time_from_system() / 604800.0)
