class_name QuestReward
extends Resource


enum Type {
	XP,
	GOLD,
	ITEM,
	NEN_XP,
	ATTRIBUTE_XP
}


@export_category("Reward")

@export var type: Type = Type.XP

@export var amount: int = 1


@export_category("Item")

@export var item_id: StringName = &""


@export_category("Attribute")

@export var attribute_id: StringName = &""


@export_category("Nen")

@export var nen_technique_id: StringName = &""
