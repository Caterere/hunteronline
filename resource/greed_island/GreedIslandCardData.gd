class_name GreedIslandCardData
extends Resource

# ============================================================
# HUNTER ONLINE - GREED ISLAND CARD DATA
# ============================================================
#
# Define as 100 Cartas de Slot Especificado (Nº 000 a 099) de Greed Island.
#
# ============================================================

enum Rarity {
	SS,
	S,
	A,
	B,
	C,
	D
}

@export var card_number: int = 0 # 0 a 99
@export var card_name: String = "Carta de Greed Island"
@export var rarity: Rarity = Rarity.D
@export var max_transformations: int = 10
@export_multiline var card_effect_description: String = ""


func obter_raridade_str() -> String:
	match rarity:
		Rarity.SS: return "SS"
		Rarity.S: return "S"
		Rarity.A: return "A"
		Rarity.B: return "B"
		Rarity.C: return "C"
		Rarity.D: return "D"
	return "D"
