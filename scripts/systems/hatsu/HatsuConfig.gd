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
# Desenhada em MARCOS (ranks a cada 20) pra evolução do mesmo Hatsu ser legível:
# - 0–20  (Despertar→Prática):   80 XP / nível  — fase rápida, feedback imediato
# - 21–40 (Prática→Afiação):    180 XP / nível — afiar a técnica
# - 41–60 (Afiação→Domínio):    320 XP / nível — meta de combate sério
# - 61–80 (Domínio→Virtuose):   450 XP / nível — polish
# - 81–100 (Virtuose→★ Mestre): 700 XP / nível — ápice OPCIONAL (não obrigatório)
# O jogador deve sentir Rank 4 (M60) como "Hatsu pronto"; 100 é prestígio.
static func get_xp_for_mastery_level(current_mastery_level: int) -> float:
	if current_mastery_level < 20:
		return 80.0
	elif current_mastery_level < 40:
		return 180.0
	elif current_mastery_level < 60:
		return 320.0
	elif current_mastery_level < 80:
		return 450.0
	else:
		return 700.0


## Limiares de rank (espelha HatsuData) — UI / tutoriais.
const MASTERY_RANK_THRESHOLDS: Array[int] = [0, 20, 40, 60, 80, 100]

# --- 6. ANTI-FARM & RELEVÂNCIA DE ALVOS ---
# Fator de ganho de Mastery XP por dano causado (base: 1 XP para cada 50 de dano efetivo).
const MASTERY_XP_PER_DAMAGE: float = 0.02

# Ganho base de XP ao atingir com sucesso uma habilidade de utilidade/suporte/cura.
const MASTERY_XP_PER_HIT_BASE: float = 5.0

# --- 6b. MASTERY POR USO CONTEXTUAL (inimigo / aliado / si / vazio) ---
# Uma barra só; a fonte muda o quanto rende. Uso vazio quase não treina (anti-spam).
enum MasteryUseTarget {
	INIMIGO,
	ALIADO,
	SELF,
	VAZIO,
}

const MASTERY_XP_USE_INIMIGO: float = 8.0
const MASTERY_XP_USE_ALIADO: float = 10.0
const MASTERY_XP_USE_SELF: float = 7.0
const MASTERY_XP_USE_VAZIO: float = 1.5

# Bônus por qualidade do uso
const MASTERY_XP_HEAL_PER_POINT: float = 0.04      # cura efetiva
const MASTERY_XP_CHARGE_BONUS_MAX: float = 4.0     # soltar feel com barra cheia
const MASTERY_XP_LOW_HP_SELF_BONUS: float = 3.0    # self sob pressão (HP < 35%)
const MASTERY_XP_IN_COMBAT_SUPPORT: float = 2.0    # suporte/cura durante combate

# Anti-spam: intervalo mínimo entre grants do mesmo Hatsu (segundos)
const MASTERY_USE_GRANT_COOLDOWN: float = 0.35
# Cap de grants VAZIO por cast (sempre 1)
const MASTERY_VAZIO_MAX_PER_CAST: int = 1

# Multiplicadores de tipo de inimigo:
const MOB_XP_MULT_NORMAL: float = 1.0
const MOB_XP_MULT_ELITE: float = 1.5
const MOB_XP_MULT_BOSS: float = 2.5


static func mastery_xp_base_for_target(alvo: int) -> float:
	match alvo:
		MasteryUseTarget.INIMIGO: return MASTERY_XP_USE_INIMIGO
		MasteryUseTarget.ALIADO: return MASTERY_XP_USE_ALIADO
		MasteryUseTarget.SELF: return MASTERY_XP_USE_SELF
		MasteryUseTarget.VAZIO: return MASTERY_XP_USE_VAZIO
	return MASTERY_XP_USE_VAZIO


static func mastery_use_target_label(alvo: int) -> String:
	match alvo:
		MasteryUseTarget.INIMIGO: return "inimigo"
		MasteryUseTarget.ALIADO: return "aliado"
		MasteryUseTarget.SELF: return "si próprio"
		MasteryUseTarget.VAZIO: return "uso vazio"
	return "uso"


static func preferred_mastery_target_for_objetivo(objetivo: int) -> int:
	## Qual contexto treina melhor este Hatsu (dica de UI).
	match objetivo:
		0: # DANO
			return MasteryUseTarget.INIMIGO
		1: # DEFESA
			return MasteryUseTarget.SELF
		2: # CURA
			return MasteryUseTarget.ALIADO
		3: # MOBILIDADE
			return MasteryUseTarget.SELF
		4: # CONTROLE
			return MasteryUseTarget.INIMIGO
		5: # SUPORTE
			return MasteryUseTarget.ALIADO
	return MasteryUseTarget.SELF

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
