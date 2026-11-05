extends Node

# ============================================================
# HUNTER ONLINE — PROGRESSION CONFIG (SINGLE SOURCE OF TRUTH)
# ============================================================
#
# Autoridade central canônica de regras e fórmulas de progressão:
# - LEVEL CAP = 1000 (Centralizado e configurável)
# - Crescimento Automático de Atributos Base (Power-Law contínua)
# - Curva de Experiência (XP Normal)
# - Curva de Concessão de Skill Points (1 SP por nível)
# - Marcos de Nível (Milestones)
# - Faixas Canônicas de Nível por Saga (Data-Driven)
#
# FILOSOFIA:
# Level determina o poder intrínseco do Caçador.
# Skill Points determinam como o Caçador especializa esse poder.
# Nen Mastery determina o refino das técnicas de Nen.
# Hatsu Mastery determina a evolução de habilidades individuais.
# ============================================================

# ------------------------------------------------------------
# 1. CONSTANTES GLOBAIS DE NÍVEL
# ------------------------------------------------------------
const MAX_LEVEL: int = 1000
const BASE_LEVEL: int = 1

# ------------------------------------------------------------
# 2. VALORES BASE (NÍVEL 1) & ALVOS ENDGAME (NÍVEL 1000)
# ------------------------------------------------------------
# Stats físicos sobem com o NÍVEL NORMAL mesmo sem Nen.
# Nen continua sendo o grande multiplicador (aura / técnicas / afinidade).
# Âncoras early: L1 forca 8 → dano básico ≈10; L10 forca 23 → dano ≈25
# (com CombatEngine dano_base=2), crescimento mínimo e legível.
const BASE_STATS: Dictionary = {
	"vida_max": 60.0,
	"forca": 8.0,
	"defesa": 5.0,
	"velocidade": 5.0,
	"aura_max": 40.0
}

# Metas no Nível 1000 (Ápice Absoluto / Endgame Supremo)
# aura_max target ↓: curva antiga explodia cedo (lv9 ≈ 17k). Agora cresce no late.
const TARGET_STATS_LEVEL_1000: Dictionary = {
	"vida_max": 45000.0,
	"forca": 4200.0,
	"defesa": 4500.0,
	"velocidade": 150.0,
	"aura_max": 800000.0
}

## Stats físicos com âncoras early legíveis (L1 / L10 / L60), depois curva até L1000.
const PHYSICAL_STATS: Array[String] = ["vida_max", "forca", "defesa", "velocidade"]
## Valores em L1, L10 e L60 — interpolação linear entre âncoras.
const EARLY_STAT_ANCHORS: Dictionary = {
	"forca": [8.0, 23.0, 95.0],
	"vida_max": [60.0, 140.0, 480.0],
	"defesa": [5.0, 12.0, 42.0],
	"velocidade": [5.0, 7.5, 16.0],
}
const EARLY_BLEND_LEVEL: int = 60

# ------------------------------------------------------------
# VALORES PADRÃO PARA ATRIBUTOS SECUNDÁRIOS & COMBATE
# ------------------------------------------------------------
const SECONDARY_STAT_DEFAULTS: Dictionary = {
	"crit_chance": 0.05,       # 5% base crit
	"crit_damage": 1.50,       # 150% base crit damage
	"dano_ataque_basico": 0.0, # Bônus específico para ataques normais
	"dano_hatsu": 0.0,         # Multiplicador bônus de habilidades Hatsu
	"dano_fisico": 0.0,        # Bônus adicional a golpes físicos
	"dano_nen": 0.0,           # Bônus a dano de aura/técnicas
	"esquiva": 0.0,            # Chance de evasão percentual
	"bloqueio": 0.0,           # Chance de bloquear impactos
	"reducao_dano": 0.0,       # Redução plana/percentual de dano sofrido
	"life_steal": 0.0,         # Percentual do dano causado convertido em vida
	"regen_hp": 1.0,           # 1.0 HP por segundo fora de combate
	"regen_aura": 5.0,         # 5.0 Aura por segundo regeneração base
	"eficiencia_aura": 1.0,    # Eficiência energética de técnicas
	"reducao_custo_aura": 0.0, # Redução percentual de custo de aura
	"reducao_cooldown": 0.0,   # Redução percentual de tempos de recarga
	"velocidade_ataque": 1.0,  # Multiplicador de cadência de golpes
	"resistencia_controle": 0.0, # Resistência a Stun/Slow/Knockback
	"raio_percepcao_bonus": 0.0, # Alcance extra em pixels de detecção
	"zetsu_stealth": 0.0       # Bônus percentual de camuflagem de Zetsu
}

# Expoentes de Curva de Crescimento (Power-Law)
# p < 1.0 garante crescimento sublinear controlado sem explosão
const STAT_EXPONENTS: Dictionary = {
	"vida_max": 0.95,
	"forca": 1.05,
	"defesa": 1.00,
	"velocidade": 0.70,
	# Expoente alto = aura quase flat no early (lv9 ≈ 80–150 pós-Wing), explode no late
	"aura_max": 2.05
}

# ------------------------------------------------------------
# 3. CURVA DE XP
# ------------------------------------------------------------
# Early mais exigente: Exame inteiro ~lv 6–10, não lv 15–25.
const XP_BASE: int = 550
const XP_GROWTH: float = 1.82

# ------------------------------------------------------------
# 4. MARCOS DE NÍVEL (MILESTONES CANÔNICOS)
# ------------------------------------------------------------
const MILESTONE_LEVELS: Array[int] = [1, 25, 40, 60, 85, 130, 230, 350, 500, 750, 1000]

# ------------------------------------------------------------
# 5. FAIXAS DE PROGRESSÃO
# ------------------------------------------------------------
enum Bracket {
	EARLY,    # Níveis 1 a 60 (Exame → Arena Celestial / despertar Nen)
	MID,      # Níveis 61 a 130 (Yorknew → Greed Island)
	LATE,     # Níveis 131 a 350 (Formigas → fim da história lançada)
	ENDGAME   # Níveis 351 a 1000 (paralelas, expansões, sagas futuras)
}

# ------------------------------------------------------------
# 6. FAIXAS RECOMENDADAS DE SAGA (DATA-DRIVEN)
# Soft-max = teto esperado ao concluir a saga principal.
# XP acima do soft-max da saga atual é fortemente amortecido.
# ------------------------------------------------------------
const SAGA_LEVEL_RANGES: Dictionary = {
	1: Vector2i(1, 10),      # 287º Exame Hunter (soft-cap cedo)
	2: Vector2i(8, 18),      # Montanha Kukuroo
	3: Vector2i(15, 35),     # Arena Celestial (+ descoberta Nen)
	4: Vector2i(30, 55),     # Yorknew City & Trupe Fantasma
	5: Vector2i(50, 90),     # Greed Island (+ Hatsu / princípios)
	6: Vector2i(80, 160),    # Formigas Chimera
	7: Vector2i(140, 220),   # Eleição Hunter & Alluka
	8: Vector2i(200, 280),   # Continente Negro Expedição
	9: Vector2i(250, 350)    # Guerra de Sucessão Kakin (teto história atual)
}


# ============================================================
# MÉTODOS DE CÁLCULO DE ATRIBUTOS BASE
# ============================================================

## Calcula o atributo base derivado estritamente do Nível do personagem.
## Físicos (vida/força/defesa/vel): âncoras early legíveis sem Nen, depois curva até L1000.
## Aura: power-law contínua (só relevante após despertar Nen).
static func calcular_stat_base(stat_name: String, level: int) -> float:
	var lvl_clamped: int = clamp(level, BASE_LEVEL, MAX_LEVEL)

	if SECONDARY_STAT_DEFAULTS.has(stat_name):
		return float(SECONDARY_STAT_DEFAULTS[stat_name])
	if not BASE_STATS.has(stat_name):
		return 0.0

	if stat_name in PHYSICAL_STATS:
		return _calcular_stat_fisico_por_nivel(stat_name, lvl_clamped)

	return _calcular_stat_power_law(stat_name, lvl_clamped)


static func _calcular_stat_fisico_por_nivel(stat_name: String, level: int) -> float:
	var anchors: Array = EARLY_STAT_ANCHORS.get(stat_name, [])
	if anchors.size() < 3:
		return _calcular_stat_power_law(stat_name, level)

	var a1: float = float(anchors[0])
	var a10: float = float(anchors[1])
	var a60: float = float(anchors[2])
	var target_val: float = float(TARGET_STATS_LEVEL_1000.get(stat_name, a60))
	var exponent: float = float(STAT_EXPONENTS.get(stat_name, 1.0))

	if level <= BASE_LEVEL:
		return a1
	if level >= MAX_LEVEL:
		return target_val
	if level <= 10:
		var t_early: float = float(level - 1) / 9.0
		return lerpf(a1, a10, t_early)
	if level <= EARLY_BLEND_LEVEL:
		var t_mid: float = float(level - 10) / float(EARLY_BLEND_LEVEL - 10)
		return lerpf(a10, a60, t_mid)

	# L60 → L1000: power-law a partir da âncora L60 até o alvo endgame
	var t_late: float = float(level - EARLY_BLEND_LEVEL) / float(MAX_LEVEL - EARLY_BLEND_LEVEL)
	return a60 + (target_val - a60) * pow(t_late, exponent)


static func _calcular_stat_power_law(stat_name: String, level: int) -> float:
	var base_val: float = float(BASE_STATS.get(stat_name, 10.0))
	var target_val: float = float(TARGET_STATS_LEVEL_1000.get(stat_name, 100.0))
	var exponent: float = float(STAT_EXPONENTS.get(stat_name, 1.0))

	if level <= BASE_LEVEL:
		return base_val
	if level >= MAX_LEVEL:
		return target_val

	var progresso_normalizado: float = float(level - BASE_LEVEL) / float(MAX_LEVEL - BASE_LEVEL)
	var fator_curva: float = pow(progresso_normalizado, exponent)
	return base_val + (target_val - base_val) * fator_curva


## Dano básico estimado sem Nen (dano_base CombatEngine + forca).
static func estimar_dano_basico_sem_nen(level: int, dano_base: float = 2.0) -> int:
	var forca: float = calcular_stat_base("forca", level)
	return maxi(1, int(round(dano_base + forca)))


## Retorna o valor inteiro arredondado do atributo base
static func calcular_stat_base_int(stat_name: String, level: int) -> int:
	return int(round(calcular_stat_base(stat_name, level)))


# ============================================================
# MÉTODOS DE XP
# ============================================================

## Retorna a quantidade de XP necessária para avançar do nível atual para o próximo.
## No nível máximo (1000), retorna o XP do nível final para manter barras completas.
static func calcular_xp_necessario(level: int) -> int:
	var lvl_clamped: int = clamp(level, BASE_LEVEL, MAX_LEVEL)
	return int(float(XP_BASE) * pow(float(lvl_clamped), XP_GROWTH))


## Retorna o XP total acumulado necessário para atingir determinado nível a partir do 1.
static func calcular_xp_acumulado(target_level: int) -> int:
	if target_level <= BASE_LEVEL:
		return 0
	var total: int = 0
	var t_clamped: int = min(target_level, MAX_LEVEL)
	for l in range(BASE_LEVEL, t_clamped):
		total += calcular_xp_necessario(l)
	return total


## Verifica se determinado nível atingiu o teto configurado.
static func eh_nivel_maximo(level: int) -> bool:
	return level >= MAX_LEVEL


# ============================================================
# SKILL POINTS & PROGRESSÃO
# ============================================================

## Retorna a quantidade de Skill Points concedida pelo level up
static func obter_skill_points_por_level(_level: int) -> int:
	return 1


## Retorna a categoria/faixa de progressão do personagem
static func obter_bracket_por_nivel(level: int) -> Bracket:
	if level <= 60:
		return Bracket.EARLY
	elif level <= 130:
		return Bracket.MID
	elif level <= 350:
		return Bracket.LATE
	else:
		return Bracket.ENDGAME


## Retorna o nome legível da faixa de progressão
static func obter_nome_bracket(level: int) -> String:
	match obter_bracket_por_nivel(level):
		Bracket.EARLY: return "Early Game (Aspirante)"
		Bracket.MID: return "Mid Game (Hunter Licenciado)"
		Bracket.LATE: return "Late Game (Mestre de Nen)"
		Bracket.ENDGAME: return "Endgame (Ápice Absoluto)"
		_: return "Desconhecido"


# ============================================================
# FAIXAS DE NÍVEL DE SAGAS (DATA-DRIVEN)
# ============================================================

## Retorna a faixa recomendada de nível (min, max) para a saga
static func obter_faixa_saga(saga_id: int) -> Vector2i:
	if SAGA_LEVEL_RANGES.has(saga_id):
		return SAGA_LEVEL_RANGES[saga_id]
	# Fallback: sagas futuras além da história lançada (rumo ao teto 1000)
	var base_min = mini(350 + (saga_id - 9) * 80, MAX_LEVEL - 80)
	return Vector2i(base_min, MAX_LEVEL)


## Soft-max (teto esperado) da saga atual do jogador
static func obter_soft_max_saga_atual() -> int:
	var arco: int = 1
	if PlayerData != null:
		arco = clampi(int(PlayerData.arco_atual), 1, 99)
	return obter_faixa_saga(arco).y


## Multiplicador de XP quando o nível passa do soft-max da saga atual.
## Mantém progressão residual (paralelas / farm) sem estourar a curva narrativa.
static func obter_multiplicador_xp_soft_cap(level: int, saga_id: int = -1) -> float:
	var arco: int = saga_id
	if arco < 1:
		arco = 1
		if PlayerData != null:
			arco = clampi(int(PlayerData.arco_atual), 1, 99)
	var soft_max: int = obter_faixa_saga(arco).y
	if level < soft_max:
		return 1.0
	var over: int = level - soft_max
	# No teto da saga: 30%. Cada nível acima reduz mais (mínimo 5%).
	return maxf(0.05, 0.30 / (1.0 + float(over) * 0.40))


## Avalia se o nível do jogador está adequado para uma saga
static func nivel_adequado_para_saga(level: int, saga_id: int) -> bool:
	var faixa = obter_faixa_saga(saga_id)
	return level >= faixa.x
