extends Node

# ============================================================
# HUNTER ONLINE - NEN BEAST MANAGER (AUTOLOAD)
# ============================================================
#
# Gerencia a fábrica e o sorteio de RNG das Bestas de Nen,
# inspiradas nas Bestas Guardiãs do Império Kakin (Mangá).
#
# ============================================================

const NOMES_BESTAS_LENDARIAS := [
	"Gato de Nove Vidas (Camilla)", "Herança de Benjamin",
	"Moeda da Fortuna (Zhang Lei)", "Besta de 2 Rostos (Tserriednich)",
	"Flecha Coletiva (Halkenburg)", "Sapo Transmutador (Tubeppa)",
	"Fumaça de Névoa (Salé-salé)", "Serpente Sagrada (Woble)"
]


func gerar_besta_aleatoria() -> NenBeastData:
	var besta := NenBeastData.new()
	
	# Sorteio de Bestas Guardiãs baseadas no Mangá
	var canon_list := CanonGuardianBeasts.obter_bestas_guardias_manga()
	var idx: int = randi() % canon_list.size()
	var base_info: Dictionary = canon_list[idx]
	
	besta.nome_besta = base_info["nome_besta"]
	besta.tipo_habilidade = base_info["tipo"]
	besta.potencial_iv = snapped(randf_range(0.90, 1.50), 0.01)
	
	# Sorteio de Cor da Aura
	var r: float = randf_range(0.3, 1.0)
	var g: float = randf_range(0.3, 1.0)
	var b: float = randf_range(0.3, 1.0)
	besta.cor_aura = Color(r, g, b, 0.9)
	
	print("=================================")
	print("[NenBeastManager] BESTA GUARDIA DE NEN DESPERTADA!")
	print("INSPIRAÇÃO (MANGÁ): ", base_info["principe"])
	print("NOME DA BESTA: ", besta.nome_besta)
	print("HABILIDADE: ", besta.obter_nome_tipo())
	print("EFEITO LORE: ", base_info["efeito"])
	print("POTENCIAL IV: ", besta.potencial_iv)
	print("=================================")
	
	return besta
