class_name NenTechnique
extends RefCounted

var nome: String
var nivel: int = 0
var xp: int = 0

var ativa: bool = false

var xp_proximo_nivel: int = 100

func adicionar_xp(valor: int) -> void:
	xp += valor

	while xp >= xp_proximo_nivel:
		xp -= xp_proximo_nivel
		nivel += 1
		xp_proximo_nivel = calcular_xp_proximo()

func calcular_xp_proximo() -> int:
	return int(100 * pow(1.25, nivel))
