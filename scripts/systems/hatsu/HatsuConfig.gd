class_name HatsuConfig
extends RefCounted

# ============================================================
# HUNTER ONLINE — HATSU CONFIGURATION & BALANCE REGISTRY
# ============================================================
#
# DESIGN VALUES — INITIAL / BALANCEABLE
#
# Este arquivo centraliza todos os parâmetros numéricos e de balanceamento
# do sistema de Hatsu, permitindo ajustes rápidos de playtesting sem
# alteração de lógica ou espalhamento de valores mágicos pelo código.
#
# ============================================================

# --- 1. CAPACIDADE DO ARCHIVE ---
# Número máximo de Hatsus conhecidos/armazenados pelo caçador.
const MAX_ARCHIVE_SLOTS: int = 12

# --- 2. COOLDOWNS DE GAMEPLAY ---
# Cooldown obrigatório entre a criação de novos Hatsus (em segundos).
# 30 minutos = 1800 segundos.
const HATSU_CREATION_COOLDOWN: float = 1800.0

# Cooldown de estabilização ao equipar/trocar Hatsus entre slots ativos (em segundos).
# Impede troca instantânea em combate / contra chefes específicos.
# 10 minutos = 600 segundos.
const HATSU_SWITCH_COOLDOWN: float = 600.0

# --- 3. ECONOMIA / MONEY SINK ---
# Custo em Jenny para forjar um novo Hatsu.
# Calibrado com a economia após Greed Island (recompensas médias de 5.000 a 50.000 Jenny).
const HATSU_CREATION_JENNY_COST: int = 5000

# --- 4. MASTERY (POTENCIAL & ESCALA) ---
# Nível inicial de maestria para qualquer Hatsu recém-forjado.
const INITIAL_MASTERY: float = 0.0

# Nível máximo de maestria atingível por um Hatsu (Status: ★ MASTERED).
const MAX_MASTERY: float = 100.0

# Razão de poder inicial no Nível 0 de Mastery (30% do poder máximo).
const INITIAL_POWER_RATIO: float = 0.30

# Bônus máximo de Eficiência de Aura no Nível 100 (-20% de consumo de aura).
const MAX_AURA_EFFICIENCY_BONUS: float = 0.20

# Bônus máximo de Redução de Cooldown da habilidade no Nível 100 (-20% de cooldown base).
const MAX_COOLDOWN_REDUCTION_BONUS: float = 0.20

# Bônus máximo de Alcance / Área no Nível 100 (+20% de projeção).
const MAX_RANGE_BONUS: float = 0.20

# --- 5. CURVA DE PROGRESSÃO DE MASTERY (XP POR NÍVEL) ---
# Tabela de faixas de nível para cálculo do XP necessário para avançar cada nível de Mastery:
# - 0 a 20:   100 XP / nível (Iniciação / Progressão rápida)
# - 21 a 50:  250 XP / nível (Praticante / Moderada)
# - 51 a 80:  500 XP / nível (Especialista / Lenta)
# - 81 a 100: 1000 XP / nível (Mestre / Ápice difícil)
static func get_xp_for_mastery_level(current_mastery_level: int) -> float:
	if current_mastery_level < 20:
		return 100.0
	elif current_mastery_level < 50:
		return 250.0
	elif current_mastery_level < 80:
		return 500.0
	else:
		return 1000.0

# --- 6. ANTI-FARM & RELEVÂNCIA DE ALVOS ---
# Fator de ganho de Mastery XP por dano causado (base: 1 XP para cada 50 de dano efetivo).
const MASTERY_XP_PER_DAMAGE: float = 0.02

# Ganho base de XP ao atingir com sucesso uma habilidade de utilidade/suporte/cura.
const MASTERY_XP_PER_HIT_BASE: float = 5.0

# Multiplicadores de tipo de inimigo:
const MOB_XP_MULT_NORMAL: float = 1.0
const MOB_XP_MULT_ELITE: float = 1.5
const MOB_XP_MULT_BOSS: float = 2.5

# Diferença máxima de nível permitida sem penalidade.
const SAFE_LEVEL_DELTA: int = 10

# Diferença de nível a partir da qual o ganho de XP é zerado (Anti-Farm absoluto).
const ZERO_XP_LEVEL_DELTA: int = 30

static func calcular_penalidade_anti_farm(player_level: int, target_level: int) -> float:
	if target_level >= player_level - SAFE_LEVEL_DELTA:
		return 1.0 # 100% de XP
	
	var defasagem: int = (player_level - SAFE_LEVEL_DELTA) - target_level
	var delta_tolerancia: int = ZERO_XP_LEVEL_DELTA - SAFE_LEVEL_DELTA # 20 níveis de queda linear
	
	if defasagem >= delta_tolerancia:
		return 0.0 # 0% de XP (inimigo irrelevante para o caçador)
	
	var fator: float = 1.0 - (float(defasagem) / float(delta_tolerancia))
	return clamp(fator, 0.0, 1.0)
