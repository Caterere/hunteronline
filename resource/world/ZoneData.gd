class_name ZoneData
extends Resource

# ============================================================
# HUNTER ONLINE - DADOS DE SUB-ZONA & DENSIDADE
# ============================================================

enum DensityLevel {
	BAIXA,      # Estradas, campos abertos (Baixa densidade, foco em distância)
	MEDIA,      # Florestas, trilhas (Média densidade)
	ALTA,       # Vilas, ruínas, acampamentos (Alta densidade)
	EXTREMA     # Dungeons, ninhos de chefes (Extrema densidade)
}

@export var zone_id: StringName = &""
@export var zone_name: String = "Zona"
@export var density: DensityLevel = DensityLevel.MEDIA
@export var recommended_tier: int = 1 # PowerScale.Tier
@export var danger_multiplier: float = 1.0
@export var procedural_encounter_chance: float = 0.25
