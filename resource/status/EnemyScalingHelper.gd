class_name EnemyScalingHelper
extends RefCounted

# ============================================================
# HUNTER ONLINE — ENEMY SCALING HELPER (CANONICAL FORMULAS)
# ============================================================
#
# Autoridade central de escalonamento data-driven de inimigos (1 a 1000).
# Garante TTK (Time-To-Kill) balanceado e alinhado com o poder do jogador:
# - Mob Normal: TTK ~5-8s
# - Mob Elite: TTK ~18-25s
# - Mini-Boss: TTK ~50-70s
# - Boss de Arco / Calamidade: TTK ~120-180s
# ============================================================

const ROLE_MULTIPLIERS: Dictionary = {
	"bruiser": {"hp": 1.0, "def": 1.0, "str": 1.0},
	"tank": {"hp": 1.4, "def": 1.35, "str": 0.80},
	"fast": {"hp": 0.8, "def": 0.75, "str": 1.25},
	"ranged": {"hp": 0.7, "def": 0.70, "str": 1.30},
	"swarm": {"hp": 0.4, "def": 0.50, "str": 0.60},
	"ambusher": {"hp": 0.85, "def": 0.80, "str": 1.35},
	"boss": {"hp": 1.8, "def": 1.15, "str": 1.20},
	"tactician": {"hp": 1.1, "def": 1.10, "str": 1.05},
	"nen_user": {"hp": 1.2, "def": 1.10, "str": 1.25}
}

## Retorna um dicionário com os atributos ideais escalonados para o nível e papel informados.
static func calcular_atributos_inimigo(
	nivel: int,
	role: String = "bruiser",
	is_boss: bool = false,
	is_elite: bool = false,
	npc_tier: int = 1
) -> Dictionary:
	var lvl_clamped: int = clamp(nivel, ProgressionConfig.BASE_LEVEL, ProgressionConfig.MAX_LEVEL)
	var t: PowerScale.Tier = PowerScale.obter_tier_por_nivel(lvl_clamped)
	var dados_tier: Dictionary = PowerScale.obter_dados_tier(t)

	var dps_ref: float = float(dados_tier.get("dps_esperado", 20.0))
	var player_hp_ref: float = ProgressionConfig.calcular_stat_base("vida_max", lvl_clamped)
	var player_forca_ref: float = ProgressionConfig.calcular_stat_base("forca", lvl_clamped)
	var player_def_ref: float = ProgressionConfig.calcular_stat_base("defesa", lvl_clamped)

	# Fatores de Categoria / Ameaça (TTK em segundos)
	var ttk_segundos: float = 6.5
	var mult_def: float = 0.50
	var mult_str: float = 0.45
	var divisor_xp: float = 25.0

	if is_boss or npc_tier >= 4:
		ttk_segundos = 150.0
		mult_def = 1.10
		mult_str = 1.05
		divisor_xp = 0.65 # Concede ~1.5x o XP de um nível completo
	elif npc_tier == 3: # Mini-Boss
		ttk_segundos = 60.0
		mult_def = 0.95
		mult_str = 0.85
		divisor_xp = 3.0
	elif is_elite or npc_tier == 2: # Elite
		ttk_segundos = 22.0
		mult_def = 0.75
		mult_str = 0.65
		divisor_xp = 8.0

	# Multiplicadores de papel tático
	var r_mults: Dictionary = ROLE_MULTIPLIERS.get(role, ROLE_MULTIPLIERS["bruiser"])
	var hp_role: float = float(r_mults.get("hp", 1.0))
	var def_role: float = float(r_mults.get("def", 1.0))
	var str_role: float = float(r_mults.get("str", 1.0))

	var hp_calculado: int = maxi(50, int(round(dps_ref * ttk_segundos * hp_role)))
	var def_calculada: int = maxi(2, int(round(player_def_ref * mult_def * def_role)))
	var str_calculada: int = maxi(8, int(round(player_forca_ref * mult_str * str_role)))

	var xp_base_necessario: int = ProgressionConfig.calcular_xp_necessario(lvl_clamped)
	var xp_calculado: int = maxi(20, int(round(float(xp_base_necessario) / divisor_xp)))

	return {
		"level": lvl_clamped,
		"max_health": hp_calculado,
		"defense": def_calculada,
		"strength": str_calculada,
		"xp_reward": xp_calculado
	}
