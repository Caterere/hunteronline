extends Resource
class_name ItemResource


# =========================================================
# IDENTIDADE
# =========================================================

@export_category("Identity")

@export var item_id: StringName = &""
@export var item_name: String = "Item"


# =========================================================
# DESCRIÇÃO
# =========================================================

@export_category("Description")

@export_multiline var description: String = ""


# =========================================================
# PROPRIEDADES
# =========================================================

@export_category("Properties")

@export var max_stack: int = 1
@export var rarity: String = "comum"


# =========================================================
# UTILIDADES
# =========================================================

func get_display_name() -> String:

	if item_name.is_empty():
		return String(item_id)

	return item_name
