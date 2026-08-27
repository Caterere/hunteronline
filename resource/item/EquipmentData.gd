class_name EquipmentData
extends ItemData

@export var bonus_vida: int = 0
@export var bonus_forca: int = 0
@export var bonus_defesa: int = 0
@export var bonus_velocidade: int = 0
@export var nivel_upgrade: int = 0

func _init():
	tipo = TipoItem.EQUIPAMENTO
	acumulavel = false
