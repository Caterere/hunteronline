class_name TileDataEntry
extends Resource

# ============================================================
# HUNTER ONLINE - TILE DATA ENTRY (ENTRADA SEMÂNTICA DE TILE)
# ============================================================

enum Category {
	FLOOR = 0,
	WALL = 1,
	DOOR = 2,
	WINDOW = 3,
	STAIR = 4,
	ROOF = 5,
	FURNITURE = 6,
	DECORATION = 7,
	OBJECT = 8,
	STRUCTURE = 9,
	TRANSITION = 10,
	SPECIAL = 11,
	UNKNOWN = 12
}

enum Orientation {
	NONE = 0,
	NORTH = 1,
	SOUTH = 2,
	WEST = 3,
	EAST = 4
}

@export var id: String = ""
@export var source_texture_path: String = ""
@export var source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var category: int = 12 # Category.UNKNOWN
@export var subcategory: String = ""
@export var tags: Array = []

@export_category("Regras de Utilização")
@export var layer: int = 0 # 0=Chão, 1=Paredes, 2=Decoração/Mobília, 3=Acima
@export var walkable: bool = true
@export var collision: bool = false
@export var repeatable: bool = false
@export var can_fill_area: bool = false
@export var can_form_boundary: bool = false
@export var can_connect_rooms: bool = false

@export_category("Dimensões & Orientação")
@export var size_in_tiles: Vector2i = Vector2i(1, 1) # Largura x Altura
@export var orientation: int = 0 # Orientation.NONE


func to_dict() -> Dictionary:
	return {
		"id": id,
		"source_texture_path": source_texture_path,
		"source_id": source_id,
		"atlas_coords": [atlas_coords.x, atlas_coords.y],
		"category": category_to_string(category),
		"subcategory": subcategory,
		"tags": tags,
		"layer": layer,
		"walkable": walkable,
		"collision": collision,
		"repeatable": repeatable,
		"can_fill_area": can_fill_area,
		"can_form_boundary": can_form_boundary,
		"can_connect_rooms": can_connect_rooms,
		"size_in_tiles": [size_in_tiles.x, size_in_tiles.y],
		"orientation": orientation_to_string(orientation)
	}


static func from_dict(d: Dictionary) -> Resource:
	var script = load("res://world/catalog/TileDataEntry.gd") as GDScript
	var entry = script.new()
	entry.id = d.get("id", "")
	entry.source_texture_path = d.get("source_texture_path", "")
	entry.source_id = d.get("source_id", 0)
	var coords_arr = d.get("atlas_coords", [0, 0])
	entry.atlas_coords = Vector2i(coords_arr[0], coords_arr[1])
	entry.category = string_to_category(d.get("category", "UNKNOWN"))
	entry.subcategory = d.get("subcategory", "")
	
	var tags_raw = d.get("tags", [])
	entry.tags = []
	for t in tags_raw:
		entry.tags.append(String(t))
		
	entry.layer = d.get("layer", 0)
	entry.walkable = d.get("walkable", true)
	entry.collision = d.get("collision", false)
	entry.repeatable = d.get("repeatable", false)
	entry.can_fill_area = d.get("can_fill_area", false)
	entry.can_form_boundary = d.get("can_form_boundary", false)
	entry.can_connect_rooms = d.get("can_connect_rooms", false)
	
	var size_arr = d.get("size_in_tiles", [1, 1])
	entry.size_in_tiles = Vector2i(size_arr[0], size_arr[1])
	entry.orientation = string_to_orientation(d.get("orientation", "NONE"))
	return entry


static func category_to_string(cat: int) -> String:
	match cat:
		Category.FLOOR: return "FLOOR"
		Category.WALL: return "WALL"
		Category.DOOR: return "DOOR"
		Category.WINDOW: return "WINDOW"
		Category.STAIR: return "STAIR"
		Category.ROOF: return "ROOF"
		Category.FURNITURE: return "FURNITURE"
		Category.DECORATION: return "DECORATION"
		Category.OBJECT: return "OBJECT"
		Category.STRUCTURE: return "STRUCTURE"
		Category.TRANSITION: return "TRANSITION"
		Category.SPECIAL: return "SPECIAL"
		_: return "UNKNOWN"


static func string_to_category(s: String) -> int:
	match s.to_upper():
		"FLOOR": return Category.FLOOR
		"WALL": return Category.WALL
		"DOOR": return Category.DOOR
		"WINDOW": return Category.WINDOW
		"STAIR": return Category.STAIR
		"ROOF": return Category.ROOF
		"FURNITURE": return Category.FURNITURE
		"DECORATION": return Category.DECORATION
		"OBJECT": return Category.OBJECT
		"STRUCTURE": return Category.STRUCTURE
		"TRANSITION": return Category.TRANSITION
		"SPECIAL": return Category.SPECIAL
		_: return Category.UNKNOWN


static func orientation_to_string(ori: int) -> String:
	match ori:
		Orientation.NORTH: return "NORTH"
		Orientation.SOUTH: return "SOUTH"
		Orientation.WEST: return "WEST"
		Orientation.EAST: return "EAST"
		_: return "NONE"


static func string_to_orientation(s: String) -> int:
	match s.to_upper():
		"UP", "NORTH": return Orientation.NORTH
		"DOWN", "SOUTH": return Orientation.SOUTH
		"LEFT", "WEST": return Orientation.WEST
		"RIGHT", "EAST": return Orientation.EAST
		_: return Orientation.NONE
