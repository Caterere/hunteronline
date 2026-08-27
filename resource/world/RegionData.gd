class_name RegionData
extends Resource

# ============================================================
# HUNTER ONLINE - DADOS DE REGIÃO DO MUNDO
# ============================================================

@export var region_id: StringName = &""
@export var region_name: String = "Nova Região"
@export var continent_name: String = "Continente Yorbian"
@export var recommended_tier: int = 1 # PowerScale.Tier
@export var default_bgm: String = "world_adventure"
@export var pois: Array[POIData] = []
@export var sub_zones: Array[ZoneData] = []
