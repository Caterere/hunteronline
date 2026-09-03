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
@export var rare_encounters: Array[Dictionary] = []
@export var zone_tags: Array[String] = []

func sortear_encontro_raro() -> Dictionary:
	if rare_encounters.is_empty():
		return {}
	for enc in rare_encounters:
		var chance = float(enc.get("chance", 0.1)) * danger_multiplier
		if randf() <= chance:
			return enc
	return {}
