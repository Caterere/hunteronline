extends Node

# ============================================================
# HUNTER ONLINE - POWER SCALE & BALANCE ENGINE
# ============================================================
#
# Centralizador de Escala de Poder, Tiers, Fórmulas de Defesa,
# Escalonamento de Hatsu e Cálculo de TTK (Time-To-Kill).
#
# Escala:
# - Começo: Números na casa de 100
# - Endgame: Dezenas a centenas de milhões (50M HP / 500M Aura)
#
# ============================================================

enum Tier {
	HUMANO = 0,             # Nível 1 ~ 10 (Exame Hunter início)
	HUNTER_INICIANTE = 1,   # Nível 11 ~ 25 (Fim do Exame / Portão Zoldyck)
	HUNTER_EXPERIENTE = 2,  # Nível 26 ~ 45 (Torre Celestial andares 100~200)
	USUARIO_NEN = 3,        # Nível 46 ~ 65 (Yorknew / Greed Island)
	HUNTER_ELITE = 4,       # Nível 66 ~ 80 (Chimera Ants / Palácio)
	MONSTRO = 5,            # Nível 81 ~ 95 (Guardas Reais / Top Hunters)
	ENDGAME = 6             # Nível 96 ~ 100 (Netero & Meruem / Dark Continent)
}

enum MissionRank {
	RANK_E,
	RANK_D,
	RANK_C,
	RANK_B,
	RANK_A,
	RANK_S
}

const TIER_DATA: Dictionary = {
	Tier.HUMANO: {
		"nome": "Humano Comum",
		"power_scale": 1.0,
		"hp_ref": 100.0,
		"forca_ref": 10.0,
		"defesa_ref": 5.0,
		"aura_max_ref": 100.0,
		"dps_esperado": 15.0
	},
	Tier.HUNTER_INICIANTE: {
		"nome": "Hunter Iniciante",
		"power_scale": 5.0,
		"hp_ref": 500.0,
		"forca_ref": 40.0,
		"defesa_ref": 25.0,
		"aura_max_ref": 500.0,
		"dps_esperado": 60.0
	},
	Tier.HUNTER_EXPERIENTE: {
		"nome": "Hunter Experiente",
		"power_scale": 50.0,
		"hp_ref": 5000.0,
		"forca_ref": 250.0,
		"defesa_ref": 150.0,
		"aura_max_ref": 5000.0,
		"dps_esperado": 400.0
	},
	Tier.USUARIO_NEN: {
		"nome": "Usuário de Nen",
		"power_scale": 500.0,
		"hp_ref": 50000.0,
		"forca_ref": 2500.0,
		"defesa_ref": 1500.0,
		"aura_max_ref": 100000.0,
		"dps_esperado": 3500.0
	},
	Tier.HUNTER_ELITE: {
		"nome": "Hunter de Elite",
		"power_scale": 5000.0,
		"hp_ref": 500000.0,
		"forca_ref": 25000.0,
		"defesa_ref": 15000.0,
		"aura_max_ref": 2000000.0,
		"dps_esperado": 35000.0
	},
	Tier.MONSTRO: {
		"nome": "Monstro / Mestre",
		"power_scale": 50000.0,
		"hp_ref": 5000000.0,
		"forca_ref": 250000.0,
		"defesa_ref": 150000.0,
		"aura_max_ref": 30000000.0,
		"dps_esperado": 350000.0
	},
	Tier.ENDGAME: {
		"nome": "Endgame Supremo",
		"power_scale": 500000.0,
		"hp_ref": 50000000.0,
		"forca_ref": 2500000.0,
		"defesa_ref": 1500000.0,
		"aura_max_ref": 500000000.0,
		"dps_esperado": 3500000.0
	}
}

const RANK_MULTIPLIERS: Dictionary = {
	MissionRank.RANK_E: 0.5,
	MissionRank.RANK_D: 0.8,
	MissionRank.RANK_C: 1.0,
	MissionRank.RANK_B: 1.5,
	MissionRank.RANK_A: 2.5,
	MissionRank.RANK_S: 5.0
}


# ============================================================
# IDENTIFICAÇÃO DE TIER
# ============================================================

func obter_tier_por_nivel(nivel: int) -> Tier:
	if nivel <= 10:
		return Tier.HUMANO
	elif nivel <= 25:
		return Tier.HUNTER_INICIANTE
	elif nivel <= 45:
		return Tier.HUNTER_EXPERIENTE
	elif nivel <= 65:
		return Tier.USUARIO_NEN
	elif nivel <= 80:
		return Tier.HUNTER_ELITE
	elif nivel <= 95:
		return Tier.MONSTRO
	else:
		return Tier.ENDGAME


func obter_dados_tier(tier: Tier) -> Dictionary:
	return TIER_DATA.get(tier, TIER_DATA[Tier.HUMANO])


# ============================================================
# CÁLCULO DE DEFESA UNIVERSAL (CURVA ASSINTÓTICA ADAPTATIVA)
# ============================================================
#
# Fórmula: Fator = K / (K + Defesa)
# K = Defesa de referência do Tier
#
# Propriedades:
# - Defesa = K -> 50% de redução (Fator 0.50)
# - Defesa = 2K -> 66.6% de redução (Fator 0.33)
# - Nunca atinge 0 absoluto
# - Mantém coerência perfeita de 5 de Defesa a 1.500.000 de Defesa
#
# ============================================================

func calcular_fator_defensivo(defesa: float, tier: Tier = Tier.HUMANO) -> float:
	var dados = obter_dados_tier(tier)
	var k: float = dados.get("defesa_ref", 5.0)
	var def_val: float = max(0.0, defesa)
	return k / (k + def_val)


# ============================================================
# ESCALONAMENTO MODULAR DE HATSU
# ============================================================
#
# DanoHatsu = PoderBase * (Forca * w_forca + Aura * w_aura) * ModAfinidade
#
# ============================================================

func calcular_dano_hatsu(
	forca: float,
	aura_atual: float,
	poder_base: float = 1.4,
	peso_forca: float = 0.4,
	peso_aura: float = 0.6,
	mod_afinidade: float = 1.0
) -> float:
	var poder_bruto: float = (forca * peso_forca) + (aura_atual * peso_aura)
	var dano_final: float = poder_base * poder_bruto * mod_afinidade
	return max(1.0, dano_final)


# ============================================================
# TIME-TO-KILL (TTK) PARA BALANCEAMENTO DE INIMIGOS
# ============================================================
#
# Inimigo Normal: 5 a 10s
# Inimigo Elite: 15 a 30s
# Mini-Boss: 45 a 75s
# Boss de Arco: 120 a 240s
#
# ============================================================

func calcular_hp_por_ttk(
	tier: Tier,
	ttk_segundos: float,
	mult_dificuldade: float = 1.0
) -> int:
	var dados = obter_dados_tier(tier)
	var dps: float = dados.get("dps_esperado", 15.0)
	var hp_calculado: float = dps * ttk_segundos * mult_dificuldade
	return int(round(hp_calculado))


func obter_multiplicador_rank(rank: MissionRank) -> float:
	return RANK_MULTIPLIERS.get(rank, 1.0)


# ============================================================
# FORMATADOR DE NÚMEROS GIGANTES (100 -> 500M)
# ============================================================

func formatar_numero(valor: float) -> String:
	var v_abs = abs(valor)
	if v_abs >= 1_000_000_000.0:
		return "%.1fB" % (valor / 1_000_000_000.0)
	elif v_abs >= 1_000_000.0:
		return "%.1fM" % (valor / 1_000_000.0)
	elif v_abs >= 10_000.0:
		return "%.1fk" % (valor / 1_000.0)
	else:
		return str(int(round(valor)))


func formatar_numero_completo(valor: int) -> String:
	var s: String = str(valor)
	var res: String = ""
	var cont: int = 0
	for i in range(s.length() - 1, -1, -1):
		if cont > 0 and cont % 3 == 0:
			res = "." + res
		res = s[i] + res
		cont += 1
	return res
