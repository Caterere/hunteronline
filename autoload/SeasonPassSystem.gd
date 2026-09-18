extends Node

## Season Pass cosmético (grátis) — progressão por contratos/raids.
## Sem pay-to-win: só títulos / Códex / skins de viagem.

signal tier_unlocked(tier: int, reward: Dictionary)
signal xp_gained(amount: int, total: int)
signal season_changed(season_id: int)

const XP_PER_TIER := 100
const MAX_TIER := 10

const TIERS := [
	{"tier": 1, "reward": {"type": "title", "id": "pass_recruta", "label": "📜 Recruta da Temporada"}},
	{"tier": 2, "reward": {"type": "travel_skin", "id": "airship_banner_blue", "label": "Dirigível — Estandarte Azul"}},
	{"tier": 3, "reward": {"type": "title", "id": "pass_explorador", "label": "🧭 Explorador de Rotas"}},
	{"tier": 4, "reward": {"type": "codex", "id": "pass_note_01", "label": "Nota de Campo I"}},
	{"tier": 5, "reward": {"type": "travel_skin", "id": "airship_banner_gold", "label": "Dirigível — Estandarte Dourado"}},
	{"tier": 6, "reward": {"type": "title", "id": "pass_veterano", "label": "🏅 Veterano do Passe"}},
	{"tier": 7, "reward": {"type": "codex", "id": "pass_note_02", "label": "Nota de Campo II"}},
	{"tier": 8, "reward": {"type": "travel_skin", "id": "boat_sail_crimson", "label": "Barco — Vela Carmesim"}},
	{"tier": 9, "reward": {"type": "title", "id": "pass_estrela", "label": "⭐ Estrela da Associação"}},
	{"tier": 10, "reward": {"type": "title", "id": "pass_lenda", "label": "👑 Lenda da Temporada"}},
]

var season_id: int = 1
var xp: int = 0
var claimed_tiers: Array = []


func _ready() -> void:
	_sync_season()


func get_state() -> Dictionary:
	_sync_season()
	return {
		"season_id": season_id,
		"xp": xp,
		"tier": current_tier(),
		"claimed": claimed_tiers.duplicate(),
		"next_tier_xp": XP_PER_TIER - (xp % XP_PER_TIER) if current_tier() < MAX_TIER else 0,
	}


func current_tier() -> int:
	return mini(MAX_TIER, int(xp / XP_PER_TIER))


func add_xp(amount: int, _source: String = "") -> Dictionary:
	_sync_season()
	amount = maxi(0, amount)
	if amount <= 0:
		return {"ok": false, "error": "xp_zero"}
	var before := current_tier()
	xp += amount
	xp_gained.emit(amount, xp)
	var after := current_tier()
	for t in range(before + 1, after + 1):
		_auto_claim(t)
	return {"ok": true, "xp": xp, "tier": after}


func claim_tier(tier: int) -> Dictionary:
	_sync_season()
	if tier < 1 or tier > MAX_TIER:
		return {"ok": false, "error": "tier_invalido"}
	if current_tier() < tier:
		return {"ok": false, "error": "tier_bloqueado"}
	if claimed_tiers.has(tier):
		return {"ok": false, "error": "ja_reclamado"}
	return _grant(tier)


func list_tiers() -> Array:
	var out: Array = []
	for row in TIERS:
		var r: Dictionary = (row as Dictionary).duplicate(true)
		var t := int(r.get("tier", 0))
		r["unlocked"] = current_tier() >= t
		r["claimed"] = claimed_tiers.has(t)
		out.append(r)
	return out


func notify_contract_complete() -> void:
	add_xp(25, "contract")


func notify_raid_clear() -> void:
	add_xp(60, "raid")


func notify_raid_queue() -> void:
	add_xp(5, "raid_queue")


func notify_ranked_win() -> void:
	add_xp(40, "ranked")


func _auto_claim(tier: int) -> void:
	if claimed_tiers.has(tier):
		return
	_grant(tier)


func _grant(tier: int) -> Dictionary:
	var reward: Dictionary = {}
	for row in TIERS:
		if int(row.get("tier", 0)) == tier:
			reward = (row.get("reward", {}) as Dictionary).duplicate(true)
			break
	if reward.is_empty():
		return {"ok": false, "error": "sem_reward"}
	claimed_tiers.append(tier)
	match str(reward.get("type", "")):
		"title":
			if PlayerData != null and PlayerData.has_method("desbloquear_titulo"):
				PlayerData.desbloquear_titulo(str(reward.get("label", reward.get("id", ""))))
		"travel_skin":
			if TravelSystem != null and TravelSystem.has_method("unlock_skin"):
				TravelSystem.unlock_skin(str(reward.get("id", "")))
		"codex":
			if CollectionManager != null and CollectionManager.has_method("register_discovery"):
				CollectionManager.register_discovery("secrets", str(reward.get("id", "")))
			elif CollectionManager != null and CollectionManager.has_method("registrar_descoberta"):
				CollectionManager.registrar_descoberta(str(reward.get("id", "")))
	tier_unlocked.emit(tier, reward)
	return {"ok": true, "tier": tier, "reward": reward}


func _sync_season() -> void:
	var sid := 1
	if TimeManager != null and TimeManager.has_method("obter_dia"):
		sid = maxi(1, int(TimeManager.obter_dia()) / 28 + 1)
	if sid != season_id:
		season_id = sid
		xp = 0
		claimed_tiers.clear()
		season_changed.emit(season_id)
