class_name POIData
extends Resource

# ============================================================
# HUNTER ONLINE - PONTO DE INTERESSE (POI)
# ============================================================

enum POIType {
	TOWN,
	OUTPOST,
	DUNGEON_ENTRANCE,
	SECRET_CAVE,
	BOSS_ARENA,
	TRAINER_SHRINE,
	NEN_PUZZLE,
	SHORTCUT
}

@export var poi_id: StringName = &""
@export var poi_name: String = "Ponto de Interesse"
@export var type: POIType = POIType.TOWN
@export var is_secret: bool = false
@export var requires_nen: NenSystem.Tecnica = NenSystem.Tecnica.TEN
@export_multiline var description: String = ""
@export var world_position: Vector2 = Vector2.ZERO
