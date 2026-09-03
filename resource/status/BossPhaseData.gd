class_name BossPhaseData
extends Resource

# ============================================================
# HUNTER ONLINE - BOSS PHASE DATA (FASE 6)
# ============================================================
#
# Estrutura declarativa de fase de chefe orientada a dados:
# - Limiar de vida (ex: 0.70, 0.40, 0.20)
# - Nome da fase e grito de guerra / telegrafia
# - Modificadores de velocidade, windup e cooldown de habilidades
# - Mecânica especial (summon, aoe_burst, frenzy, shield, overload)
#
# ============================================================

enum MecanicaFase {
	NENHUMA,
	FRENESI,          # Aumento de velocidade e dano
	INVOCAR_MINIONS,  # Spawna lacaios para auxílio
	AOE_BURST,        # Ondas de choque no chão
	ESCUDO_AURA,      # Mitigação temporária com Ren máximo
	OVERLOAD          # Sobrecarga final desesperada
}

@export var phase_index: int = 2
@export var hp_threshold: float = 0.50 # Dispara quando HP <= hp_threshold
@export var phase_name: String = "Frenesi de Ren"
@export var dialogue_quote: String = "⚡ Você ainda não viu nada do meu verdadeiro poder!"
@export var speed_multiplier: float = 1.25
@export var attack_cd_multiplier: float = 0.70
@export var windup_multiplier: float = 0.75
@export var hatsu_cd_multiplier: float = 0.65
@export var mechanic: MecanicaFase = MecanicaFase.FRENESI
@export var color_modulate: Color = Color(1.8, 0.4, 0.4, 1.0)
@export var camera_shake_intensity: float = 0.60
@export var camera_shake_duration: float = 0.40
