class_name ArenaRankedSeason
extends RefCounted

# ============================================================
# HUNTER ONLINE — HEAVEN'S ARENA RANKED + SEASONS (S2)
# ============================================================
#
# Ladder 1v1 por temporada na Torre Celestial:
# - MMR/Elo (K=32) sem power creep — só cosmético/título
# - Soft-reset no fim da temporada (puxa 50% em direção a 1000)
# - Leaderboard local persistido em PlayerData.attributes
# - Fila 1v1 simples (peer ou ghost async)
#
# ============================================================

const ATTR_KEY := "arena_ranked"
const DEFAULT_MMR := 1000
const K_FACTOR := 32
const SEASON_LENGTH_DAYS := 28
const LEADERBOARD_MAX := 20

## Faixas cosméticas (sem bônus de combate)
const TIERS := [
	{"id": "rookie", "nome": "Candidato do Ringue", "min_mmr": 0, "titulo": "🥊 Candidato do Ringue"},
	{"id": "floor_fighter", "nome": "Lutador de Andar", "min_mmr": 900, "titulo": "⚔️ Lutador de Andar"},
	{"id": "sky_arena", "nome": "Gladiador Celestial", "min_mmr": 1100, "titulo": "🏛️ Gladiador Celestial"},
	{"id": "floor_master", "nome": "Mestre de Andar", "min_mmr": 1300, "titulo": "👑 Mestre de Andar"},
	{"id": "zodiac_candidate", "nome": "Candidato a Zodíaco", "min_mmr": 1500, "titulo": "⭐ Candidato a Zodíaco"},
]


static func _blank_state() -> Dictionary:
	return {
		"season_id": 1,
		"season_start_day": 1,
		"mmr": DEFAULT_MMR,
		"peak_mmr": DEFAULT_MMR,
		"wins": 0,
		"losses": 0,
		"win_streak": 0,
		"titles_unlocked": [],
		"leaderboard": [], # [{name, mmr, wins, losses, floor}]
		"queue_floor": 1,
		"in_queue": false,
		"ranked_mode": false,
		"pending_opponent": {},
	}


static func load_state() -> Dictionary:
	if PlayerData == null:
		return _blank_state()
	var raw = PlayerData.attributes.get(ATTR_KEY, {})
	if typeof(raw) != TYPE_DICTIONARY or raw.is_empty():
		var st := _blank_state()
		_save_state(st)
		return st
	var st: Dictionary = (raw as Dictionary).duplicate(true)
	for k in _blank_state().keys():
		if not st.has(k):
			st[k] = _blank_state()[k]
	return st


static func _save_state(st: Dictionary) -> void:
	if PlayerData == null:
		return
	PlayerData.attributes[ATTR_KEY] = st.duplicate(true)


static func reset_for_tests() -> void:
	_save_state(_blank_state())


static func current_day() -> int:
	if TimeManager != null:
		return maxi(1, int(TimeManager.current_day))
	return 1


static func ensure_season() -> Dictionary:
	var st := load_state()
	var day := current_day()
	var start := int(st.get("season_start_day", 1))
	if day - start >= SEASON_LENGTH_DAYS:
		st = _rollover_season(st, day)
		_save_state(st)
	return st


static func _rollover_season(st: Dictionary, day: int) -> Dictionary:
	var old_mmr := int(st.get("mmr", DEFAULT_MMR))
	# Soft reset: 50% em direção ao MMR base (cosmético, sem wipe total)
	var soft := int(round(lerp(float(old_mmr), float(DEFAULT_MMR), 0.5)))
	var titles: Array = st.get("titles_unlocked", [])
	if titles is Array:
		titles = (titles as Array).duplicate()
	else:
		titles = []
	var season_n := int(st.get("season_id", 1))
	var end_title := "🏅 Veterano da Temporada %d" % season_n
	if not titles.has(end_title):
		titles.append(end_title)
		_unlock_title(end_title)
	var peak := int(st.get("peak_mmr", old_mmr))
	var peak_title := str(_tier_for_mmr(peak).get("titulo", ""))
	if not peak_title.is_empty() and not titles.has(peak_title):
		titles.append(peak_title)
		_unlock_title(peak_title)

	return {
		"season_id": season_n + 1,
		"season_start_day": day,
		"mmr": soft,
		"peak_mmr": soft,
		"wins": 0,
		"losses": 0,
		"win_streak": 0,
		"titles_unlocked": titles,
		"leaderboard": [],
		"queue_floor": int(st.get("queue_floor", 1)),
		"in_queue": false,
		"ranked_mode": bool(st.get("ranked_mode", false)),
		"pending_opponent": {},
		"last_season_peak": peak,
		"last_season_id": season_n,
	}


static func days_until_season_end(st: Dictionary = {}) -> int:
	if st.is_empty():
		st = ensure_season()
	var start := int(st.get("season_start_day", 1))
	var day := current_day()
	return maxi(0, SEASON_LENGTH_DAYS - (day - start))


static func _tier_for_mmr(mmr: int) -> Dictionary:
	var best: Dictionary = TIERS[0]
	for t in TIERS:
		if mmr >= int(t.get("min_mmr", 0)):
			best = t
	return best


static func get_player_tier(st: Dictionary = {}) -> Dictionary:
	if st.is_empty():
		st = ensure_season()
	return _tier_for_mmr(int(st.get("mmr", DEFAULT_MMR)))


static func expected_score(mmr_a: int, mmr_b: int) -> float:
	return 1.0 / (1.0 + pow(10.0, float(mmr_b - mmr_a) / 400.0))


static func calc_mmr_delta(winner_mmr: int, loser_mmr: int) -> int:
	var exp_w := expected_score(winner_mmr, loser_mmr)
	return int(round(float(K_FACTOR) * (1.0 - exp_w)))


static func _player_display_name() -> String:
	if PlayerData == null:
		return "Caçador"
	var from_attr := str(PlayerData.attributes.get("nome", "")).strip_edges()
	if not from_attr.is_empty():
		return from_attr
	var from_char := str(PlayerData.nome_personagem).strip_edges()
	return from_char if not from_char.is_empty() else "Caçador"


static func _unlock_title(titulo: String) -> void:
	if titulo.is_empty():
		return
	if PlayerData != null and PlayerData.has_method("desbloquear_titulo"):
		PlayerData.desbloquear_titulo(titulo)


## Registra resultado 1v1 ranqueado. Retorna deltas/títulos desbloqueados.
static func report_match(won: bool, opponent_mmr: int = DEFAULT_MMR, floor: int = 1, opponent_name: String = "Rival") -> Dictionary:
	var st := ensure_season()
	var my_mmr := int(st.get("mmr", DEFAULT_MMR))
	var delta: int
	if won:
		delta = calc_mmr_delta(my_mmr, opponent_mmr)
	else:
		delta = -calc_mmr_delta(opponent_mmr, my_mmr)

	my_mmr = maxi(0, my_mmr + delta)
	st["mmr"] = my_mmr
	st["peak_mmr"] = maxi(int(st.get("peak_mmr", DEFAULT_MMR)), my_mmr)
	if won:
		st["wins"] = int(st.get("wins", 0)) + 1
		st["win_streak"] = int(st.get("win_streak", 0)) + 1
	else:
		st["losses"] = int(st.get("losses", 0)) + 1
		st["win_streak"] = 0

	var tier := _tier_for_mmr(my_mmr)
	var titles: Array = st.get("titles_unlocked", [])
	if titles is Array:
		titles = (titles as Array).duplicate()
	else:
		titles = []
	var new_title := ""
	var titulo := str(tier.get("titulo", ""))
	if not titulo.is_empty() and not titles.has(titulo):
		titles.append(titulo)
		new_title = titulo
		_unlock_title(titulo)
	st["titles_unlocked"] = titles
	st["in_queue"] = false
	st["pending_opponent"] = {}

	_upsert_leaderboard(st, _player_display_name(), my_mmr, int(st["wins"]), int(st["losses"]), floor)
	if not opponent_name.is_empty():
		_upsert_leaderboard(st, opponent_name, opponent_mmr, 0, 0, floor)

	_save_state(st)
	return {
		"won": won,
		"delta": delta,
		"mmr": my_mmr,
		"tier": tier,
		"new_title": new_title,
		"season_id": int(st.get("season_id", 1)),
		"days_left": days_until_season_end(st),
	}


static func _upsert_leaderboard(st: Dictionary, name: String, mmr: int, wins: int, losses: int, floor: int) -> void:
	var board: Array = st.get("leaderboard", [])
	if board is Array:
		board = (board as Array).duplicate(true)
	else:
		board = []
	var found := false
	for i in range(board.size()):
		var row = board[i]
		if typeof(row) == TYPE_DICTIONARY and str(row.get("name", "")) == name:
			row["mmr"] = mmr
			row["wins"] = maxi(int(row.get("wins", 0)), wins)
			row["losses"] = maxi(int(row.get("losses", 0)), losses)
			row["floor"] = maxi(int(row.get("floor", 1)), floor)
			board[i] = row
			found = true
			break
	if not found:
		board.append({"name": name, "mmr": mmr, "wins": wins, "losses": losses, "floor": floor})
	board.sort_custom(func(a, b): return int(a.get("mmr", 0)) > int(b.get("mmr", 0)))
	if board.size() > LEADERBOARD_MAX:
		board = board.slice(0, LEADERBOARD_MAX)
	st["leaderboard"] = board


static func get_leaderboard() -> Array:
	var st := ensure_season()
	var board = st.get("leaderboard", [])
	return board if board is Array else []


static func set_ranked_mode(enabled: bool) -> Dictionary:
	var st := ensure_season()
	st["ranked_mode"] = enabled
	if not enabled:
		st["in_queue"] = false
		st["pending_opponent"] = {}
	_save_state(st)
	return {"ok": true, "ranked_mode": enabled, "mmr": int(st["mmr"]), "season_id": int(st["season_id"])}


static func is_ranked_mode() -> bool:
	return bool(ensure_season().get("ranked_mode", false))


static func join_queue(floor: int = 1) -> Dictionary:
	var st := ensure_season()
	st["ranked_mode"] = true
	st["queue_floor"] = maxi(1, floor)
	st["in_queue"] = true
	var opp := _build_opponent(floor, int(st.get("mmr", DEFAULT_MMR)))
	st["pending_opponent"] = opp
	_save_state(st)
	return {
		"ok": true,
		"floor": st["queue_floor"],
		"mmr": int(st["mmr"]),
		"season_id": int(st["season_id"]),
		"opponent": opp,
	}


static func leave_queue() -> void:
	var st := ensure_season()
	st["in_queue"] = false
	st["pending_opponent"] = {}
	_save_state(st)


static func is_in_queue() -> bool:
	return bool(ensure_season().get("in_queue", false))


static func get_pending_opponent() -> Dictionary:
	var raw = ensure_season().get("pending_opponent", {})
	return raw if typeof(raw) == TYPE_DICTIONARY else {}


static func _ghost_mmr(ghost: Dictionary, floor: int) -> int:
	return DEFAULT_MMR + int(ghost.get("andar_origem", floor)) * 8 + int(ghost.get("nivel", 1)) * 4


static func _build_opponent(floor: int, my_mmr: int) -> Dictionary:
	var ghost: Dictionary = ArenaGhostRegistry.obter_para_andar(floor)
	if not ghost.is_empty():
		return {
			"kind": "ghost",
			"name": str(ghost.get("nome", "Fantasma da Arena")),
			"mmr": _ghost_mmr(ghost, floor),
			"floor": floor,
			"ghost": ghost,
		}
	var rival_mmr := my_mmr + (hash(floor + current_day()) % 201) - 100
	return {
		"kind": "synthetic",
		"name": "Rival do %dº Andar" % floor,
		"mmr": maxi(600, rival_mmr),
		"floor": floor,
		"ghost": {},
	}


## Resolve fila: ghost do andar se existir; senão rival sintético na faixa.
static func pop_match_opponent(floor: int = -1) -> Dictionary:
	var st := ensure_season()
	if floor < 1:
		floor = int(st.get("queue_floor", 1))
	var pending = st.get("pending_opponent", {})
	st["in_queue"] = false
	if typeof(pending) == TYPE_DICTIONARY and not pending.is_empty():
		st["pending_opponent"] = {}
		_save_state(st)
		return (pending as Dictionary).duplicate(true)
	var opp := _build_opponent(floor, int(st.get("mmr", DEFAULT_MMR)))
	st["pending_opponent"] = {}
	_save_state(st)
	return opp


## Vitória/derrota na torre: só aplica MMR se ranked_mode estiver ligado.
static func report_tower_result(won: bool, floor: int) -> Dictionary:
	var st := ensure_season()
	if not bool(st.get("ranked_mode", false)):
		return {"skipped": true, "reason": "ranked_off"}
	var raw = st.get("pending_opponent", {})
	var opp: Dictionary = raw if typeof(raw) == TYPE_DICTIONARY else {}
	if opp.is_empty():
		opp = _build_opponent(floor, int(st.get("mmr", DEFAULT_MMR)))
	return report_match(won, int(opp.get("mmr", DEFAULT_MMR)), floor, str(opp.get("name", "Rival")))


## Duelo consensual 1v1: reporta se ranked_mode ativo.
static func report_duel_result(won: bool, opponent_mmr: int = DEFAULT_MMR, opponent_name: String = "Duelista") -> Dictionary:
	if not is_ranked_mode():
		return {"skipped": true, "reason": "ranked_off"}
	var floor := 1
	if PlayerData != null:
		floor = maxi(1, int(PlayerData.attributes.get("andar_arena", PlayerData.torre_andar_atual)))
	return report_match(won, opponent_mmr, floor, opponent_name)


static func summary_text() -> String:
	var st := ensure_season()
	var tier := get_player_tier(st)
	var mode := "ON" if bool(st.get("ranked_mode", false)) else "OFF"
	return "T%d · MMR %d · %s · %dW/%dL · reset %dd · ranked %s" % [
		int(st.get("season_id", 1)),
		int(st.get("mmr", DEFAULT_MMR)),
		str(tier.get("nome", "?")),
		int(st.get("wins", 0)),
		int(st.get("losses", 0)),
		days_until_season_end(st),
		mode,
	]


static func leaderboard_text(limit: int = 5) -> String:
	var board := get_leaderboard()
	if board.is_empty():
		return "(sem entradas)"
	var lines: PackedStringArray = []
	var n := mini(limit, board.size())
	for i in range(n):
		var row: Dictionary = board[i]
		lines.append("%d. %s — %d MMR (A%d)" % [
			i + 1,
			str(row.get("name", "?")),
			int(row.get("mmr", 0)),
			int(row.get("floor", 1)),
		])
	return "\n".join(lines)
