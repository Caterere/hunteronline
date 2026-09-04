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
# Valores no Nível 1 (Humano / Aspirante inicial)
const BASE_STATS: Dictionary = {
	"vida_max": 100.0,
	"forca": 10.0,
	"defesa": 10.0,
	"velocidade": 10.0,
	"aura_max": 100.0
}

# Metas no Nível 1000 (Ápice Absoluto / Endgame Supremo)
const TARGET_STATS_LEVEL_1000: Dictionary = {
	"vida_max": 50000.0,
	"forca": 5000.0,
	"defesa": 5000.0,
	"velocidade": 160.0,
	"aura_max": 1500000.0
}

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
	"vida_max": 0.90,
	"forca": 0.95,
	"defesa": 0.95,
	"velocidade": 0.65,
	"aura_max": 0.92
}

# ------------------------------------------------------------
# 3. CURVA DE XP
# ------------------------------------------------------------
const XP_BASE: int = 300
const XP_GROWTH: float = 1.6

# ------------------------------------------------------------
# 4. MARCOS DE NÍVEL (MILESTONES CANÔNICOS)
# ------------------------------------------------------------
const MILESTONE_LEVELS: Array[int] = [1, 10, 50, 100, 250, 500, 750, 1000]

# ------------------------------------------------------------
# 5. FAIXAS DE PROGRESSÃO
# ------------------------------------------------------------
enum Bracket {
	EARLY,    # Níveis 1 a 80 (Exame Hunter)
	MID,      # Níveis 81 a 300 (Kukuroo, Arena, Yorknew, Greed Island)
	LATE,     # Níveis 301 a 700 (Chimera Ants, Eleição)
	ENDGAME   # Níveis 701 a 1000 (Continente Negro, Guerra Kakin, Expansões)
}

# ------------------------------------------------------------
# 6. FAIXAS RECOMENDADAS DE SAGA (DATA-DRIVEN)
# ------------------------------------------------------------
const SAGA_LEVEL_RANGES: Dictionary = {
	1: Vector2i(1, 80),      # 287º Exame Hunter
	2: Vector2i(70, 150),    # Montanha Kukuroo
	3: Vector2i(130, 250),   # Arena Celestial
	4: Vector2i(220, 380),   # Yorknew City & Trupe Fantasma
	5: Vector2i(350, 520),   # Greed Island
	6: Vector2i(500, 720),   # Formigas Chimera
	7: Vector2i(680, 800),   # Eleição Hunter & Alluka
	8: Vector2i(780, 900),   # Continente Negro Expedição
	9: Vector2i(880, 1000)   # Guerra de Sucessão Kakin
}


# ============================================================
# MÉTODOS DE CÁLCULO DE ATRIBUTOS BASE
# ============================================================

## Calcula o atributo base derivado estritamente do Nível do personagem.
## Aplica a fórmula determinística de Power-Law contínua:
## base + (target - base) * ((level - 1) / (MAX_LEVEL - 1)) ^ p
static func calcular_stat_base(stat_name: String, level: int) -> float:
	var lvl_clamped: int = clamp(level, BASE_LEVEL, MAX_LEVEL)
	
	if SECONDARY_STAT_DEFAULTS.has(stat_name):
		return float(SECONDARY_STAT_DEFAULTS[stat_name])
	if not BASE_STATS.has(stat_name):
		return 0.0
		
	var base_val: float = float(BASE_STATS.get(stat_name, 10.0))
	var target_val: float = float(TARGET_STATS_LEVEL_1000.get(stat_name, 100.0))
	var exponent: float = float(STAT_EXPONENTS.get(stat_name, 1.0))
	
	if lvl_clamped <= BASE_LEVEL:
		return base_val
	if lvl_clamped >= MAX_LEVEL:
		return target_val
		
	var progresso_normalizado: float = float(lvl_clamped - BASE_LEVEL) / float(MAX_LEVEL - BASE_LEVEL)
	var fator_curva: float = pow(progresso_normalizado, exponent)
	
	return base_val + (target_val - base_val) * fator_curva


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
	if level <= 80:
		return Bracket.EARLY
	elif level <= 300:
		return Bracket.MID
	elif level <= 700:
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
	# Fallback gracioso para sagas além da 9 sem quebrar o jogo
	var base_min = min(880 + (saga_id - 9) * 40, MAX_LEVEL - 50)
	return Vector2i(base_min, MAX_LEVEL)


## Avalia se o nível do jogador está adequado para uma saga
static func nivel_adequado_para_saga(level: int, saga_id: int) -> bool:
	var faixa = obter_faixa_saga(saga_id)
	return level >= faixa.x
