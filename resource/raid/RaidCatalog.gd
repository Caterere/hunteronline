class_name RaidCatalog
extends RefCounted

# ============================================================
# HUNTER ONLINE — RAID CATALOG (S3 vertical slice)
# ============================================================

const RAIDS := {
	"ruins_zaban_vertical": {
		"id": "ruins_zaban_vertical",
		"title": "Ruínas de Zaban — Descent Vertical",
		"region": "ruins_zaban",
		"min_level": 12,
		"max_members": 8,
		"enrage_seconds": 600.0,
		"phases": [
			{"id": "gate", "hp_pct": 1.0},
			{"id": "collapse", "hp_pct": 0.7},
			{"id": "midpoint", "hp_pct": 0.45},
			{"id": "enrage", "hp_pct": 0.2}
		],
		"boss_id": "guardian_zaban_colossus",
		"map_hint": "res://world/maps/DungeonRuinasZabanMap.tscn"
	}
}


static func list_raids() -> Array[String]:
	var out: Array[String] = []
	for k in RAIDS.keys():
		out.append(str(k))
	return out


static func get_raid(raid_id: String) -> Dictionary:
	return RAIDS.get(raid_id, {}).duplicate(true)


static func has_raid(raid_id: String) -> bool:
	return RAIDS.has(raid_id)
