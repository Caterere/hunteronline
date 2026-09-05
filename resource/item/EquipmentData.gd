class_name EquipmentData
extends ItemData

@export var bonus_vida: int = 0
@export var bonus_forca: int = 0
@export var bonus_defesa: int = 0
@export var bonus_velocidade: int = 0
@export var nivel_upgrade: int = 0

@export_category("Trade-offs & Gameplay Implications")
@export var bonus_velocidade_pct: float = 0.0
@export var bonus_defesa_pct: float = 0.0
@export var bonus_dano_hatsu_pct: float = 0.0
@export var bonus_custo_aura_pct: float = 0.0
@export var trade_off_descricao: String = ""

func _init():
	tipo = TipoItem.EQUIPAMENTO
	acumulavel = false
