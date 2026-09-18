class_name RaidInstance
extends CoopDungeonInstance

# ============================================================
# HUNTER ONLINE — RAID INSTANCE (8 HUNTERS)
# ============================================================
#
# Extende CoopDungeonInstance para raids verticais:
# - Cap 8 hunters (PartyManager modo raid)
# - Fases de boss + enrage timer
# - Soft wipe / checkpoint revive window (PREREQ-2)
# ============================================================

const MAX_RAID_SIZE: int = 8

signal phase_changed(phase_index: int, phase_id: String)
signal enrage_started(seconds_remaining: float)
signal raid_wiped()
signal raid_cleared(loot_seed: int)

var raid_id: String = ""
var raid_title: String = ""
var max_members: int = MAX_RAID_SIZE
var phases: Array[Dictionary] = []
var current_phase_index: int = 0
var enrage_seconds: float = 0.0
var enrage_active: bool = false
var wipe_count: int = 0
var loot_seed: int = 0


func start_raid(p_raid_id: String, members: Array[int], catalog_entry: Dictionary = {}) -> bool:
	if members.is_empty() or members.size() > MAX_RAID_SIZE:
		return false
	raid_id = p_raid_id
	raid_title = str(catalog_entry.get("title", p_raid_id))
	max_members = int(catalog_entry.get("max_members", MAX_RAID_SIZE))
	phases.clear()
	for ph in catalog_entry.get("phases", []):
		if ph is Dictionary:
			phases.append(ph.duplicate(true))
	if phases.is_empty():
		phases = [
			{"id": "approach", "hp_pct": 1.0},
			{"id": "midpoint", "hp_pct": 0.5},
			{"id": "enrage", "hp_pct": 0.25}
		]
	current_phase_index = 0
	enrage_seconds = float(catalog_entry.get("enrage_seconds", 480.0))
	enrage_active = false
	wipe_count = 0
	loot_seed = int(Time.get_ticks_msec()) ^ hash(p_raid_id)
	iniciar_instancia(p_raid_id, members)
	phase_changed.emit(0, str(phases[0].get("id", "phase_0")))
	return true


func member_count() -> int:
	return party_members.size()


func can_admit(peer_id: int) -> bool:
	if party_members.has(peer_id):
		return true
	return party_members.size() < max_members


func tick_enrage(delta: float) -> void:
	if is_cleared or enrage_seconds <= 0.0:
		return
	enrage_seconds = maxf(0.0, enrage_seconds - delta)
	if enrage_seconds <= 0.0 and not enrage_active:
		enrage_active = true
		enrage_started.emit(0.0)


func update_boss_hp_ratio(hp_ratio: float) -> void:
	if phases.is_empty() or is_cleared:
		return
	# Advance while boss HP falls through phase thresholds
	while current_phase_index + 1 < phases.size():
		var nxt: Dictionary = phases[current_phase_index + 1]
		var threshold := float(nxt.get("hp_pct", 0.0))
		if hp_ratio <= threshold + 0.0001:
			current_phase_index += 1
			phase_changed.emit(current_phase_index, str(nxt.get("id", "phase_%d" % current_phase_index)))
			if str(nxt.get("id", "")).to_lower().contains("enrage"):
				enrage_active = true
				enrage_started.emit(enrage_seconds)
		else:
			break


func register_wipe() -> void:
	wipe_count += 1
	raid_wiped.emit()


func complete_raid() -> Dictionary:
	marcar_boss_derrotado()
	raid_cleared.emit(loot_seed)
	var loot: Array = []
	for peer_id in party_members:
		loot.append(gerar_loot_sala_tesouro(peer_id))
	return {"raid_id": raid_id, "loot_seed": loot_seed, "loot": loot, "wipes": wipe_count}
