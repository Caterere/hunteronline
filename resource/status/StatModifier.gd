class_name StatModifier
extends RefCounted

# ============================================================
# HUNTER ONLINE - STAT MODIFIER (PIPELINE DE ATRIBUTOS)
# ============================================================
#
# Representa um modificador de atributo limpo e não-mutativo:
# - FLAT: Soma direta (+10 Força)
# - PERCENTAGE: Bônus percentual relativo à base (+20% Força)
# - MULTIPLICATIVE: Multiplicador final (x1.5 Dano / Força)
#
# ============================================================

enum Type {
	FLAT = 0,
	PERCENTAGE = 1,
	MULTIPLICATIVE = 2
}

var id: StringName = &""
var stat_name: StringName = &""
var type: Type = Type.FLAT
var value: float = 0.0
var duration: float = -1.0 # -1.0 = Permanente / Equipamento / Treino
var source: String = ""

func _init(p_id: StringName = &"", p_stat: StringName = &"", p_type: Type = Type.FLAT, p_val: float = 0.0, p_dur: float = -1.0, p_src: String = "") -> void:
	id = p_id
	stat_name = p_stat
	type = p_type
	value = p_val
	duration = p_dur
	source = p_src
