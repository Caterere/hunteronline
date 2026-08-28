extends Resource
class_name EnemyData


# =========================================================
# IDENTIDADE
# =========================================================

@export_category("Identity")

@export var enemy_id: StringName = &""

@export var enemy_name: String = "Inimigo"
@export var level: int = 1


# =========================================================
# STATUS
# =========================================================

@export_category("Stats")

@export var max_health: int = 100
@export var defense: int = 5
@export var strength: int = 10


# =========================================================
# PROGRESSÃO
# =========================================================

@export_category("Progression")

@export var xp_reward: int = 40


# =========================================================
# COMBATE
# =========================================================

@export_category("Combat")

@export var is_boss: bool = false
@export var knockback_resistance: float = 0.0
@export var hit_invulnerability_time: float = 0.15
@export var hatsu_name: String = ""
@export var hatsu_cooldown: float = 5.0
@export var nen_type: int = 0
@export var modular_hatsu: HatsuData = null
@export var attack_windup: float = 0.25
@export var attack_recovery: float = 0.35
@export var attack_telegraph_type: String = "flash" # "flash", "exclamation", "aoe_circle"
@export var role: String = "bruiser" # "bruiser", "fast", "tank", "ranged", "boss"



# =========================================================
# DROPS & LOOT (VOL 8)
# =========================================================

@export_category("Loot")

# Array de dicionários: [{"item_id": "minerio_aco", "chance": 0.8, "quantidade": 1}]
@export var drop_table: Array[Dictionary] = []
