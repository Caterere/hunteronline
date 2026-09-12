extends Node

# ============================================================
# HUNTER ONLINE — CAÇA BLACKLIST CO-OP (A7)
# ============================================================
# Open hunt estilo world-boss (GW2/WoW): alvo S-rank rotativo,
# rumores para localizar, threat multi-party, loot por contribuição.
# ============================================================

signal hunt_rotated(target_id: String)
signal clue_discovered(target_id: String, clue_tier: int)
signal hunt_joined(peer_id: int)
signal hunt_phase_changed(phase: int)
signal hunt_completed(target_id: String, rewards: Dictionary)

const ATTR_KEY := "blacklist_open_hunt"
const CoopWorldBossCoordinatorScript = preload("res://scripts/network/CoopWorldBossCoordinator.gd")

var target_catalog: Dictionary = {
	"bl_genthru": {
		"id": "bl_genthru",
		"name": "Genthru, o Bombardeiro",
		"rank": "S",
		"region": "greed_island",
		"level": 420,
		"max_hp": 180000,
		"jenny_pool": 250000,
		"xp_pool": 12000,
		"guaranteed_drop": "bomb_devils_guide",
		"rumor_title": "Explosões em Antokiba",
		"rumor_text": "Caçadores falam de um trio de bombas caçando binders perto do porto.",
		"clues": [
			"Cheiro de pólvora no porto de Antokiba.",
			"Um binder abandonado com a carta 'Bomb' marcada.",
			"Genthru foi visto no perímetro norte da Ilha."
		],
	},
	"bl_binolt": {
		"id": "bl_binolt",
		"name": "Binolt, o Cirurgião Canibal",
		"rank": "S",
		"region": "yorbian_wilderness",
		"level": 280,
		"max_hp": 95000,
		"jenny_pool": 90000,
		"xp_pool": 6000,
		"guaranteed_drop": "surgeon_scalpel_shard",
		"rumor_title": "Cirurgias no mato",
		"rumor_text": "Viajantes desaparecem com cortes limpos demais para bichos.",
		"clues": [
			"Trilhas de sangue seco na floresta leste.",
			"Um acampamento médico improvisado e vazio.",
			"Binolt caça perto do rio ao anoitecer."
		],
	},
	"bl_piye": {
		"id": "bl_piye",
		"name": "Piye, a Assassina Fantasma",
		"rank": "S",
		"region": "yorknew_backstreets",
		"level": 510,
		"max_hp": 140000,
		"jenny_pool": 180000,
		"xp_pool": 9000,
		"guaranteed_drop": "ghost_veil_fragment",
		"rumor_title": "Sussurros em Yorknew",
		"rumor_text": "A Máfia paga silêncio sobre mortes sem pegada de Nen.",
		"clues": [
			"Cartazes rasgados no beco dos leilões.",
			"Uma testemunha viu uma sombra no telhado do leilão.",
			"Piye marca o alvo com um selo invisível."
		],
	},
}

var active_target_id: String = ""
var clue_tier: int = 0
var location_revealed: bool = false
var hunt_active: bool = false
var joined_peers: Dictionary = {}
var _boss = null
var _completed_ids: PackedStringArray = []
var _day_seed: int = 0


func _ready() -> void:
	if active_target_id.is_empty():
		rotate_daily_target(1)
	print("[BlacklistOpenHuntSystem] Caça Blacklist co-op (A7) ativa")


func reset_for_tests() -> void:
	active_target_id = ""
	clue_tier = 0
	location_revealed = false
	hunt_active = false
	joined_peers.clear()
	_boss = null
	_completed_ids.clear()
	_day_seed = 0
	_mirror()


func list_catalog() -> Array:
	var out: Array = []
	for k in target_catalog.keys():
		out.append((target_catalog[k] as Dictionary).duplicate(true))
	return out


func get_active_target() -> Dictionary:
	if active_target_id.is_empty() or not target_catalog.has(active_target_id):
		return {}
	return (target_catalog[active_target_id] as Dictionary).duplicate(true)


func rotate_daily_target(day_seed: int = -1) -> Dictionary:
	_day_seed = day_seed if day_seed >= 0 else (_day_seed + 1)
	var keys: Array = target_catalog.keys()
	keys.sort()
	if keys.is_empty():
		return {"ok": false, "error": "catalog_empty"}
	var idx: int = absi(_day_seed) % keys.size()
	if keys.size() > 1 and str(keys[idx]) == active_target_id:
		idx = (idx + 1) % keys.size()
	active_target_id = str(keys[idx])
	clue_tier = 0
	location_revealed = false
	hunt_active = false
	joined_peers.clear()
	_boss = null
	_publish_rumor()
	_mirror()
	hunt_rotated.emit(active_target_id)
	return {"ok": true, "target_id": active_target_id, "target": get_active_target()}


func _publish_rumor() -> void:
	var t := get_active_target()
	if t.is_empty() or RumorSystem == null:
		return
	var rid := "rumor_blacklist_%s" % active_target_id
	RumorSystem.criar_rumor(
		rid,
		str(t.get("rumor_title", "Caça Blacklist")),
		str(t.get("rumor_text", "")),
		str(t.get("region", "world")),
		"blacklist_hunt_%s" % active_target_id
	)


func discover_clue(amount: int = 1) -> Dictionary:
	if active_target_id.is_empty():
		return {"ok": false, "error": "no_target"}
	var t := get_active_target()
	var max_tier: int = maxi(1, (t.get("clues", []) as Array).size())
	clue_tier = mini(max_tier, clue_tier + maxi(1, amount))
	location_revealed = clue_tier >= max_tier
	_mirror()
	clue_discovered.emit(active_target_id, clue_tier)
	return {
		"ok": true,
		"clue_tier": clue_tier,
		"location_revealed": location_revealed,
		"clue_text": _clue_text_for_tier(clue_tier),
	}


func _clue_text_for_tier(tier: int) -> String:
	var t := get_active_target()
	var clues: Array = t.get("clues", [])
	if clues.is_empty() or tier <= 0:
		return ""
	return str(clues[mini(clues.size(), tier) - 1])


func start_hunt() -> Dictionary:
	if active_target_id.is_empty():
		return {"ok": false, "error": "no_target"}
	if not location_revealed:
		return {"ok": false, "error": "location_unknown"}
	if hunt_active and _boss != null and not _boss.esta_morto():
		return {"ok": false, "error": "already_active"}
	var t := get_active_target()
	_boss = CoopWorldBossCoordinatorScript.new()
	_boss.inicializar_boss(active_target_id, str(t.get("name", "Blacklist")), int(t.get("max_hp", 100000)))
	hunt_active = true
	joined_peers.clear()
	_mirror()
	return {"ok": true, "target_id": active_target_id, "max_hp": int(t.get("max_hp", 0))}


func join_hunt(peer_id: int, party_tag: String = "") -> Dictionary:
	if not hunt_active or _boss == null:
		return {"ok": false, "error": "hunt_inactive"}
	joined_peers[peer_id] = party_tag if not party_tag.is_empty() else "solo"
	hunt_joined.emit(peer_id)
	_mirror()
	return {"ok": true, "hunters": joined_peers.size()}


func report_damage(peer_id: int, damage: int, is_taunt: bool = false) -> Dictionary:
	if not hunt_active or _boss == null:
		return {"ok": false, "error": "hunt_inactive"}
	if not joined_peers.has(peer_id):
		join_hunt(peer_id)
	var prev_phase: int = int(_boss.current_phase)
	_boss.registrar_dano(peer_id, maxi(0, damage), is_taunt)
	var phase: int = int(_boss.current_phase)
	if phase != prev_phase:
		hunt_phase_changed.emit(phase)
	var out := {
		"ok": true,
		"hp": int(_boss.current_hp),
		"phase": phase,
		"aggro": int(_boss.obter_alvo_aggro()),
		"dead": bool(_boss.esta_morto()),
	}
	if _boss.esta_morto():
		out["rewards"] = _finalize_rewards()
	_mirror()
	return out


func _finalize_rewards() -> Dictionary:
	var t := get_active_target()
	var rewards: Dictionary = _boss.calcular_recompensas_coop(
		int(t.get("xp_pool", 1000)),
		int(t.get("jenny_pool", 1000)),
		str(t.get("guaranteed_drop", ""))
	)
	if rewards.has(1) and Economy != null and Economy.has_method("adicionar_gold"):
		Economy.adicionar_gold(int(rewards[1].get("jenny", 0)))
	if not _completed_ids.has(active_target_id):
		_completed_ids.append(active_target_id)
	hunt_active = false
	hunt_completed.emit(active_target_id, rewards)
	_mirror()
	return rewards


func get_hunt_snapshot() -> Dictionary:
	return {
		"target_id": active_target_id,
		"target": get_active_target(),
		"clue_tier": clue_tier,
		"location_revealed": location_revealed,
		"hunt_active": hunt_active,
		"hunters": joined_peers.size(),
		"hp": 0 if _boss == null else int(_boss.current_hp),
		"phase": 1 if _boss == null else int(_boss.current_phase),
		"completed": Array(_completed_ids),
	}


func _mirror() -> void:
	if PlayerData != null:
		PlayerData.attributes[ATTR_KEY] = salvar_dados()


func salvar_dados() -> Dictionary:
	return {
		"active_target_id": active_target_id,
		"clue_tier": clue_tier,
		"location_revealed": location_revealed,
		"hunt_active": hunt_active,
		"joined_peers": joined_peers.duplicate(true),
		"completed_ids": Array(_completed_ids),
		"day_seed": _day_seed,
		"boss": null if _boss == null else {
			"hp": int(_boss.current_hp),
			"phase": int(_boss.current_phase),
			"threat": _boss.threat_table.duplicate(true),
			"damage": _boss.damage_contribution.duplicate(true),
		},
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		return
	active_target_id = str(dados.get("active_target_id", ""))
	clue_tier = int(dados.get("clue_tier", 0))
	location_revealed = bool(dados.get("location_revealed", false))
	hunt_active = bool(dados.get("hunt_active", false))
	joined_peers = dados.get("joined_peers", {}).duplicate(true) if dados.get("joined_peers", {}) is Dictionary else {}
	_completed_ids = PackedStringArray(dados.get("completed_ids", []))
	_day_seed = int(dados.get("day_seed", 0))
	_boss = null
	var boss_blob = dados.get("boss", null)
	if hunt_active and boss_blob is Dictionary and not active_target_id.is_empty():
		var t := get_active_target()
		_boss = CoopWorldBossCoordinatorScript.new()
		_boss.inicializar_boss(active_target_id, str(t.get("name", "Blacklist")), int(t.get("max_hp", 100000)))
		_boss.current_hp = int(boss_blob.get("hp", _boss.max_hp))
		_boss.current_phase = int(boss_blob.get("phase", 1))
		_boss.threat_table = boss_blob.get("threat", {}).duplicate(true) if boss_blob.get("threat", {}) is Dictionary else {}
		_boss.damage_contribution = boss_blob.get("damage", {}).duplicate(true) if boss_blob.get("damage", {}) is Dictionary else {}
	if active_target_id.is_empty():
		rotate_daily_target(1)
