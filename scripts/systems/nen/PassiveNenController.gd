class_name PassiveNenController
extends RefCounted

# ============================================================
# HUNTER ONLINE — PASSIVE NEN CONTROLLER
# ============================================================
#
# Gerencia as Técnicas Passivas de Nen:
# - Ten (Mitigação de Dano & Estabilidade)
# - Ren (Potência de Ataque Básico & Capacidade de Aura)
# - Shu (Imbuição de Armas / Equipamentos)
# - Ko  (Burst Destrutivo no Finalizador do Ataque Básico)
# - Ken (Blindagem geral — Ren no corpo inteiro)
# - Ryu (Distribuição Contínua de Fluxo)
#
# Não requer ativação manual por teclas.
# Os bônus são permanentes e escalonados via Nen Skill Tree.
# ============================================================


func obter_mitigacao_ten() -> float:
	if PlayerData == null or not PlayerData.despertou_nen:
		return 0.0
	# Base: 8% da aura máxima + modificadores de ten da Skill Tree
	var aura_max: float = float(PlayerData.attributes.get("aura_max", 100.0))
	var mod_def: float = float(PlayerData.obter_modificador_total("defesa"))
	return (aura_max * 0.08) + (mod_def * 0.5)


func obter_multiplicador_ren_dano() -> float:
	if PlayerData == null or not PlayerData.despertou_nen:
		return 1.0
	# Base: +15% de dano físico + modificadores de dano/ren da Skill Tree
	var mod_dano: float = float(PlayerData.obter_modificador_total("dano_fisico"))
	return 1.15 + mod_dano


func obter_bonus_shu_equipamento() -> float:
	if PlayerData == null or not PlayerData.despertou_nen:
		return 0.0
	# Bônus de perfuração de armadura ao usar armas
	return float(PlayerData.obter_modificador_total("dano_arma"))


func obter_bonus_ko_finalizador() -> float:
	if PlayerData == null or not PlayerData.despertou_nen:
		return 0.0
	# Burst damage no 3º golpe do combo
	var mod_ko: float = float(PlayerData.obter_modificador_total("ko_burst"))
	return 0.50 + mod_ko # +50% base até +120%


func obter_modificador_ryu() -> Dictionary:
	if PlayerData == null or not PlayerData.despertou_nen:
		return {"ataque": 1.0, "defesa": 1.0}
	
	var mod_ataque: float = 1.0 + float(PlayerData.obter_modificador_total("ryu_ataque"))
	var mod_defesa: float = 1.0 + float(PlayerData.obter_modificador_total("ryu_defesa"))
	return {"ataque": mod_ataque, "defesa": mod_defesa}


## Multiplicador de dano recebido com Ken ativo (passivo). Rank 1 ≈ 0.65.
func obter_multiplicador_ken_dano(nivel: int = 1) -> float:
	if PlayerData == null or not PlayerData.despertou_nen:
		return 1.0
	var n: int = maxi(1, nivel)
	var mitigacao: float = minf(0.35 + 0.05 * float(n - 1), 0.65)
	# Synergy leve com defesa da árvore (ken_mastery)
	var mod_def: float = float(PlayerData.obter_modificador_total("defesa"))
	mitigacao = minf(mitigacao + clampf(mod_def * 0.05, 0.0, 0.08), 0.70)
	return 1.0 - mitigacao
