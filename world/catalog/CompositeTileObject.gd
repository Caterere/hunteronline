class_name CompositeTileObject
extends Resource

# ============================================================
# HUNTER ONLINE - COMPOSITE TILE OBJECT (OBJETO MULTI-TILE)
# ============================================================

@export var id: String = ""
@export var display_name: String = ""
@export var category: String = "FURNITURE"
@export var subcategory: String = "bedroom"
@export var size_in_tiles: Vector2i = Vector2i(1, 1) # Largura x Altura
@export var tags: Array = []
@export var parts: Array = [] # Array de Dictionaries {dx, dy, source_id, atlas_coords, layer, collision}
@export var can_be_placed_inside: bool = true


func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"category": category,
		"subcategory": subcategory,
		"size_in_tiles": [size_in_tiles.x, size_in_tiles.y],
		"tags": tags,
		"parts": parts,
		"can_be_placed_inside": can_be_placed_inside
	}


static func from_dict(d: Dictionary) -> Resource:
	var script = load("res://world/catalog/CompositeTileObject.gd") as GDScript
	var obj = script.new()
	obj.id = d.get("id", "")
	obj.display_name = d.get("display_name", "")
	obj.category = d.get("category", "FURNITURE")
	obj.subcategory = d.get("subcategory", "bedroom")
	
	var size_arr = d.get("size_in_tiles", [1, 1])
	obj.size_in_tiles = Vector2i(size_arr[0], size_arr[1])
	
	var tags_raw = d.get("tags", [])
	obj.tags = []
	for t in tags_raw:
		obj.tags.append(str(t))
		
	obj.parts = d.get("parts", [])
	obj.can_be_placed_inside = d.get("can_be_placed_inside", true)
	return obj
