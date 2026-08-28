class_name TileDatabase
extends RefCounted

# ============================================================
# HUNTER ONLINE - TILE DATABASE & CATALOG REGISTRY
# ============================================================

const TileDataEntryScript = preload("res://world/catalog/TileDataEntry.gd")
const WallSetScript = preload("res://world/catalog/WallSet.gd")
const CompositeTileObjectScript = preload("res://world/catalog/CompositeTileObject.gd")

const PATH_CATALOG_JSON = "res://data/world/tile_catalog_data.json"
const PATH_ROOM_BUILDER = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Room_Builder_free_16x16.png"
const PATH_INTERIORS = "res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Interiors_free/16x16/Interiors_free_16x16.png"

var tiles: Dictionary = {}               # id: String -> TileDataEntry
var wall_sets: Dictionary = {}           # id: String -> WallSet
var composite_objects: Dictionary = {}   # id: String -> CompositeTileObject

static var _instance: RefCounted = null


static func get_instance() -> RefCounted:
	if _instance == null:
		var script = load("res://world/catalog/TileDatabase.gd") as GDScript
		var db = script.new()
		if not db.load_from_json(PATH_CATALOG_JSON):
			db.initialize_default_catalog()
			db.save_to_json(PATH_CATALOG_JSON)
		_instance = db
	return _instance


func register_tile(entry: Resource) -> void:
	if entry != null and not entry.id.is_empty():
		tiles[entry.id] = entry


func register_wall_set(ws: Resource) -> void:
	if ws != null and not ws.id.is_empty():
		wall_sets[ws.id] = ws


func register_composite_object(obj: Resource) -> void:
	if obj != null and not obj.id.is_empty():
		composite_objects[obj.id] = obj


func get_tile(id: String) -> Resource:
	return tiles.get(id, null)


func get_wall_set(id: String) -> Resource:
	return wall_sets.get(id, null)


func get_composite_object(id: String) -> Resource:
	return composite_objects.get(id, null)


func find_tiles(cat: int, subcat: String = "", tag: String = "") -> Array:
	var result: Array = []
	for t in tiles.values():
		var entry = t as Resource
		if int(entry.category) != cat:
			continue
		if not subcat.is_empty() and entry.subcategory != subcat:
			continue
		if not tag.is_empty() and not entry.tags.has(tag):
			continue
		result.append(entry)
	return result


func get_random_floor(subcat: String = "wood") -> Resource:
	var list = find_tiles(TileDataEntryScript.Category.FLOOR, subcat)
	if not list.is_empty():
		return list[randi() % list.size()]
	var all_floors = find_tiles(TileDataEntryScript.Category.FLOOR)
	if not all_floors.is_empty():
		return all_floors[0]
	return null


# ============================================================
# PERSISTÊNCIA JSON
# ============================================================
func save_to_json(path: String = PATH_CATALOG_JSON) -> Error:
	var data: Dictionary = {
		"version": "1.0",
		"tiles": {},
		"wall_sets": {},
		"composite_objects": {}
	}
	
	for id in tiles.keys():
		var t = tiles[id] as Resource
		data["tiles"][id] = t.to_dict()
		
	for id in wall_sets.keys():
		var ws = wall_sets[id] as Resource
		data["wall_sets"][id] = ws.to_dict()
		
	for id in composite_objects.keys():
		var obj = composite_objects[id] as Resource
		data["composite_objects"][id] = obj.to_dict()
		
	var json_str = JSON.stringify(data, "  ")
	
	var dir_path = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
		
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[TileDatabase] Erro ao abrir arquivo para escrita: " + path)
		return FileAccess.get_open_error()
		
	file.store_string(json_str)
	file.close()
	print("[TileDatabase] Catálogo salvo com sucesso em: " + path + " (%d tiles, %d wall_sets, %d composite_objs)" % [
		tiles.size(), wall_sets.size(), composite_objects.size()
	])
	return OK


func load_from_json(path: String = PATH_CATALOG_JSON) -> bool:
	if not FileAccess.file_exists(path):
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
		
	var json_str = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err = json.parse(json_str)
	if err != OK:
		push_error("[TileDatabase] Erro no parse JSON do catálogo: " + json.get_error_message())
		return false
		
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return false
		
	tiles.clear()
	wall_sets.clear()
	composite_objects.clear()
	
	var tiles_dict = data.get("tiles", {})
	for id in tiles_dict.keys():
		var entry = TileDataEntryScript.from_dict(tiles_dict[id])
		tiles[id] = entry
		
	var ws_dict = data.get("wall_sets", {})
	for id in ws_dict.keys():
		var ws = WallSetScript.from_dict(ws_dict[id])
		wall_sets[id] = ws
		
	var comp_dict = data.get("composite_objects", {})
	for id in comp_dict.keys():
		var obj = CompositeTileObjectScript.from_dict(comp_dict[id])
		composite_objects[id] = obj
		
	print("[TileDatabase] Catálogo carregado: %d tiles, %d wall_sets, %d composite_objs" % [
		tiles.size(), wall_sets.size(), composite_objects.size()
	])
	return true


# ============================================================
# INICIALIZAÇÃO DO CATÁLOGO PADRÃO (PRE-CATALOGED ASSETS)
# ============================================================
func initialize_default_catalog() -> void:
	tiles.clear()
	wall_sets.clear()
	composite_objects.clear()
	
	print("[TileDatabase] Inicializando catálogo semântico padrão dos assets...")
	
	# 1. PISOS (FLOORS)
	_cadastrar_piso("wood_floor_parquet", "Piso de Madeira Nobre (Parquet)", "wood", Vector2i(1, 5), ["wood", "interior", "parquet"])
	_cadastrar_piso("wood_floor_dark", "Piso de Madeira Escura", "wood", Vector2i(2, 5), ["wood", "interior", "dark"])
	_cadastrar_piso("wood_floor_light", "Piso de Madeira Clara", "wood", Vector2i(3, 5), ["wood", "interior", "light"])
	_cadastrar_piso("ceramic_floor_white", "Piso Cerâmico Branco", "ceramic", Vector2i(1, 9), ["ceramic", "interior", "white"])
	_cadastrar_piso("stone_floor_pavement", "Calçada de Pedra Urbana", "stone", Vector2i(2, 9), ["stone", "urban", "street"])
	_cadastrar_piso("carpet_red", "Carpete Vermelho Real", "carpet", Vector2i(1, 13), ["carpet", "luxury", "red"])
	_cadastrar_piso("carpet_blue", "Carpete Azul Acolhedor", "carpet", Vector2i(2, 13), ["carpet", "bedroom", "blue"])
	_cadastrar_piso("tatami_mat", "Tatame de Treino de Nen", "tatami", Vector2i(3, 9), ["tatami", "dojo", "training"])
	
	# 2. PAREDES INDIVIDUAIS (WALL TILES)
	_cadastrar_parede("wood_wall_top", "wood", Vector2i(0, 0), ["wall", "wood", "top"])
	_cadastrar_parede("wood_wall_bottom", "wood", Vector2i(0, 2), ["wall", "wood", "bottom"])
	_cadastrar_parede("wood_wall_left", "wood", Vector2i(0, 1), ["wall", "wood", "left"])
	_cadastrar_parede("wood_wall_right", "wood", Vector2i(2, 1), ["wall", "wood", "right"])
	_cadastrar_parede("wood_wall_corner_tl", "wood", Vector2i(0, 0), ["wall", "wood", "corner", "top_left"])
	_cadastrar_parede("wood_wall_corner_tr", "wood", Vector2i(2, 0), ["wall", "wood", "corner", "top_right"])
	_cadastrar_parede("wood_wall_corner_bl", "wood", Vector2i(0, 2), ["wall", "wood", "corner", "bottom_left"])
	_cadastrar_parede("wood_wall_corner_br", "wood", Vector2i(2, 2), ["wall", "wood", "corner", "bottom_right"])
	_cadastrar_parede("wood_wall_center", "wood", Vector2i(1, 1), ["wall", "wood", "center"])
	
	_cadastrar_parede("stone_wall_top", "stone", Vector2i(3, 0), ["wall", "stone", "top"])
	_cadastrar_parede("stone_wall_bottom", "stone", Vector2i(3, 2), ["wall", "stone", "bottom"])
	_cadastrar_parede("stone_wall_left", "stone", Vector2i(3, 1), ["wall", "stone", "left"])
	_cadastrar_parede("stone_wall_right", "stone", Vector2i(5, 1), ["wall", "stone", "right"])
	_cadastrar_parede("stone_wall_corner_tl", "stone", Vector2i(3, 0), ["wall", "stone", "corner", "top_left"])
	_cadastrar_parede("stone_wall_corner_tr", "stone", Vector2i(5, 0), ["wall", "stone", "corner", "top_right"])
	_cadastrar_parede("stone_wall_corner_bl", "stone", Vector2i(3, 2), ["wall", "stone", "corner", "bottom_left"])
	_cadastrar_parede("stone_wall_corner_br", "stone", Vector2i(5, 2), ["wall", "stone", "corner", "bottom_right"])
	_cadastrar_parede("stone_wall_center", "stone", Vector2i(4, 1), ["wall", "stone", "center"])

	# 3. CONJUNTOS DE PAREDE (WALL SETS)
	var ws_wood = WallSetScript.new()
	ws_wood.id = "wood_wall_classic"
	ws_wood.display_name = "Conjunto de Parede de Madeira Clássica"
	ws_wood.subcategory = "wood"
	ws_wood.wall_top = "wood_wall_top"
	ws_wood.wall_bottom = "wood_wall_bottom"
	ws_wood.wall_left = "wood_wall_left"
	ws_wood.wall_right = "wood_wall_right"
	ws_wood.corner_top_left = "wood_wall_corner_tl"
	ws_wood.corner_top_right = "wood_wall_corner_tr"
	ws_wood.corner_bottom_left = "wood_wall_corner_bl"
	ws_wood.corner_bottom_right = "wood_wall_corner_br"
	ws_wood.center = "wood_wall_center"
	register_wall_set(ws_wood)

	var ws_stone = WallSetScript.new()
	ws_stone.id = "stone_wall_dark"
	ws_stone.display_name = "Conjunto de Parede de Pedra Ancestral"
	ws_stone.subcategory = "stone"
	ws_stone.wall_top = "stone_wall_top"
	ws_stone.wall_bottom = "stone_wall_bottom"
	ws_stone.wall_left = "stone_wall_left"
	ws_stone.wall_right = "stone_wall_right"
	ws_stone.corner_top_left = "stone_wall_corner_tl"
	ws_stone.corner_top_right = "stone_wall_corner_tr"
	ws_stone.corner_bottom_left = "stone_wall_corner_bl"
	ws_stone.corner_bottom_right = "stone_wall_corner_br"
	ws_stone.center = "stone_wall_center"
	register_wall_set(ws_stone)

	# 4. PORTAS E TRANSIÇÕES (DOORS)
	_cadastrar_porta("wood_door_simple", "Porta de Madeira Simples", Vector2i(4, 3), ["door", "wood", "entrance"])
	_cadastrar_porta("door_threshold_wood", "Soleira de Madeira", Vector2i(1, 9), ["door", "threshold", "walkable"])
	_cadastrar_porta("iron_gate_ruins", "Grade de Ferro das Ruínas", Vector2i(4, 4), ["door", "iron", "dungeon"])

	# 5. MOBÍLIAS & OBJETOS COMPOSTOS
	_cadastrar_objeto_composto("double_bed_blue", "Cama Dupla Azul", "FURNITURE", "bedroom", Vector2i(2, 3), [
		{"dx": 0, "dy": 0, "source_id": 1, "atlas_coords": [2, 2], "layer": 2, "collision": true},
		{"dx": 1, "dy": 0, "source_id": 1, "atlas_coords": [3, 2], "layer": 2, "collision": true},
		{"dx": 0, "dy": 1, "source_id": 1, "atlas_coords": [2, 3], "layer": 2, "collision": true},
		{"dx": 1, "dy": 1, "source_id": 1, "atlas_coords": [3, 3], "layer": 2, "collision": true},
		{"dx": 0, "dy": 2, "source_id": 1, "atlas_coords": [2, 4], "layer": 2, "collision": true},
		{"dx": 1, "dy": 2, "source_id": 1, "atlas_coords": [3, 4], "layer": 2, "collision": true}
	], ["bed", "bedroom", "rest", "furniture"])

	_cadastrar_objeto_composto("study_desk_pc", "Mesa de Estudos com Computador", "FURNITURE", "office", Vector2i(2, 2), [
		{"dx": 0, "dy": 0, "source_id": 1, "atlas_coords": [4, 2], "layer": 2, "collision": true},
		{"dx": 1, "dy": 0, "source_id": 1, "atlas_coords": [5, 2], "layer": 2, "collision": true},
		{"dx": 0, "dy": 1, "source_id": 1, "atlas_coords": [4, 3], "layer": 2, "collision": true},
		{"dx": 1, "dy": 1, "source_id": 1, "atlas_coords": [5, 3], "layer": 2, "collision": true}
	], ["desk", "office", "study", "pc"])

	_cadastrar_objeto_composto("bookcase_tall", "Estante de Manuscritos de Nen", "FURNITURE", "library", Vector2i(1, 2), [
		{"dx": 0, "dy": 0, "source_id": 1, "atlas_coords": [6, 2], "layer": 2, "collision": true},
		{"dx": 0, "dy": 1, "source_id": 1, "atlas_coords": [6, 3], "layer": 2, "collision": true}
	], ["bookcase", "library", "scholar"])

	_cadastrar_objeto_composto("shop_counter_wood", "Balcão de Comércio de Madeira", "FURNITURE", "shop", Vector2i(2, 1), [
		{"dx": 0, "dy": 0, "source_id": 1, "atlas_coords": [3, 2], "layer": 2, "collision": true},
		{"dx": 1, "dy": 0, "source_id": 1, "atlas_coords": [4, 2], "layer": 2, "collision": true}
	], ["counter", "shop", "merchant"])

	_cadastrar_objeto_composto("training_dummy_nen", "Boneco de Teste de Dano Nen", "OBJECT", "dojo", Vector2i(1, 2), [
		{"dx": 0, "dy": 0, "source_id": 1, "atlas_coords": [8, 2], "layer": 2, "collision": true},
		{"dx": 0, "dy": 1, "source_id": 1, "atlas_coords": [8, 3], "layer": 2, "collision": true}
	], ["dummy", "training", "dojo", "nen"])

	_cadastrar_objeto_individual("storage_chest_wood", "Baú Pessoal de Caçador", TileDataEntryScript.Category.OBJECT, "storage", 1, Vector2i(4, 2), ["chest", "storage", "loot"], false, true)
	_cadastrar_objeto_individual("house_plant_pot", "Vaso de Planta Ornamental", TileDataEntryScript.Category.DECORATION, "living", 1, Vector2i(7, 2), ["plant", "decor", "green"], false, false)


func _cadastrar_piso(id: String, _nome: String, subcat: String, coords: Vector2i, tags: Array) -> void:
	var t = TileDataEntryScript.new()
	t.id = id
	t.source_texture_path = PATH_ROOM_BUILDER
	t.source_id = 0
	t.atlas_coords = coords
	t.category = TileDataEntryScript.Category.FLOOR
	t.subcategory = subcat
	for tag in tags: t.tags.append(str(tag))
	for default_tag in ["floor", "walkable", "repeatable"]:
		if not t.tags.has(default_tag): t.tags.append(default_tag)
	t.layer = 0
	t.walkable = true
	t.collision = false
	t.repeatable = true
	t.can_fill_area = true
	register_tile(t)


func _cadastrar_parede(id: String, subcat: String, coords: Vector2i, tags: Array) -> void:
	var t = TileDataEntryScript.new()
	t.id = id
	t.source_texture_path = PATH_ROOM_BUILDER
	t.source_id = 0
	t.atlas_coords = coords
	t.category = TileDataEntryScript.Category.WALL
	t.subcategory = subcat
	for tag in tags: t.tags.append(str(tag))
	t.layer = 1
	t.walkable = false
	t.collision = true
	t.can_form_boundary = true
	t.repeatable = true
	register_tile(t)


func _cadastrar_porta(id: String, _nome: String, coords: Vector2i, tags: Array) -> void:
	var t = TileDataEntryScript.new()
	t.id = id
	t.source_texture_path = PATH_ROOM_BUILDER
	t.source_id = 0
	t.atlas_coords = coords
	t.category = TileDataEntryScript.Category.DOOR
	t.subcategory = "door"
	for tag in tags: t.tags.append(str(tag))
	t.layer = 1
	t.walkable = true
	t.collision = false
	t.can_connect_rooms = true
	register_tile(t)


func _cadastrar_objeto_individual(id: String, _nome: String, cat: int, subcat: String, src_id: int, coords: Vector2i, tags: Array, is_walkable: bool, has_col: bool) -> void:
	var t = TileDataEntryScript.new()
	t.id = id
	t.source_texture_path = PATH_INTERIORS if src_id == 1 else PATH_ROOM_BUILDER
	t.source_id = src_id
	t.atlas_coords = coords
	t.category = cat as TileDataEntryScript.Category
	t.subcategory = subcat
	for tag in tags: t.tags.append(str(tag))
	t.layer = 2
	t.walkable = is_walkable
	t.collision = has_col
	register_tile(t)


func _cadastrar_objeto_composto(id: String, nome: String, cat: String, subcat: String, size: Vector2i, parts: Array, tags: Array) -> void:
	var obj = CompositeTileObjectScript.new()
	obj.id = id
	obj.display_name = nome
	obj.category = cat
	obj.subcategory = subcat
	obj.size_in_tiles = size
	obj.parts = parts
	for tag in tags: obj.tags.append(str(tag))
	register_composite_object(obj)
