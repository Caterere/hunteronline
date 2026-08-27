class_name WallSet
extends Resource

# ============================================================
# HUNTER ONLINE - WALL SET (CONJUNTO DE PAREDES 9-SLICE)
# ============================================================

@export var id: String = ""
@export var display_name: String = ""
@export var subcategory: String = "wood" # wood, stone, brick, plaster

@export_category("Bordas Cardeais (IDs de Tile)")
@export var wall_top: String = ""
@export var wall_bottom: String = ""
@export var wall_left: String = ""
@export var wall_right: String = ""

@export_category("Cantos (IDs de Tile)")
@export var corner_top_left: String = ""
@export var corner_top_right: String = ""
@export var corner_bottom_left: String = ""
@export var corner_bottom_right: String = ""

@export_category("Preenchimento / Centro")
@export var center: String = ""


func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"subcategory": subcategory,
		"wall_top": wall_top,
		"wall_bottom": wall_bottom,
		"wall_left": wall_left,
		"wall_right": wall_right,
		"corner_top_left": corner_top_left,
		"corner_top_right": corner_top_right,
		"corner_bottom_left": corner_bottom_left,
		"corner_bottom_right": corner_bottom_right,
		"center": center
	}


static func from_dict(d: Dictionary) -> Resource:
	var script = load("res://world/catalog/WallSet.gd") as GDScript
	var ws = script.new()
	ws.id = d.get("id", "")
	ws.display_name = d.get("display_name", "")
	ws.subcategory = d.get("subcategory", "wood")
	ws.wall_top = d.get("wall_top", "")
	ws.wall_bottom = d.get("wall_bottom", "")
	ws.wall_left = d.get("wall_left", "")
	ws.wall_right = d.get("wall_right", "")
	ws.corner_top_left = d.get("corner_top_left", "")
	ws.corner_top_right = d.get("corner_top_right", "")
	ws.corner_bottom_left = d.get("corner_bottom_left", "")
	ws.corner_bottom_right = d.get("corner_bottom_right", "")
	ws.center = d.get("center", "")
	return ws
