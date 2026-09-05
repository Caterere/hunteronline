class_name ServerStorageManager
extends RefCounted

# ============================================================
# HUNTER ONLINE — SERVER STORAGE MANAGER (FASE K-LAN)
# ============================================================
#
# Persistência autoritativa de dados no Servidor Dedicado:
# - Armazena e carrega personagens em 'user://server_saves/players/'
# - Preserva estado de mundo, flags e chefes globais
# - Previne duplicação de itens (loot e transações validados server-side)
# - Suporta autosave periódico e salvamento seguro em logout
# ============================================================

var base_save_path: String = "user://server_saves/"
var players_save_path: String = "user://server_saves/players/"
var world_save_path: String = "user://server_saves/world_state.json"

# character_id -> Player Data Dictionary
var _online_cache: Dictionary = {}


func _init(p_base_path: String = "user://server_saves/") -> void:
	base_save_path = p_base_path
	players_save_path = base_save_path.path_join("players/")
	world_save_path = base_save_path.path_join("world_state.json")
	_garantir_diretorios()


func _garantir_diretorios() -> void:
	DirAccess.make_dir_recursive_absolute(base_save_path)
	DirAccess.make_dir_recursive_absolute(players_save_path)


func has_player_save(character_id: String) -> bool:
	if character_id.is_empty():
		return false
	var file_path = players_save_path.path_join("%s.json" % character_id)
	return FileAccess.file_exists(file_path)


func save_player_state(character_id: String, player_data: Dictionary) -> Error:
	if character_id.is_empty():
		return ERR_INVALID_PARAMETER

	_garantir_diretorios()
	var file_path = players_save_path.path_join("%s.json" % character_id)
	var copy_data = player_data.duplicate(true)
	copy_data["server_saved_at_ms"] = Time.get_ticks_msec()
	copy_data["schema_version"] = "2.4"

	var json_str = JSON.stringify(copy_data, "\t")
	var fa = FileAccess.open(file_path, FileAccess.WRITE)
	if fa == null:
		push_error("[ServerStorageManager] Falha ao salvar jogador '%s': Erro %d" % [character_id, FileAccess.get_open_error()])
		return FileAccess.get_open_error()

	fa.store_string(json_str)
	fa.close()

	_online_cache[character_id] = copy_data
	return OK


func load_player_state(character_id: String) -> Dictionary:
	if character_id.is_empty():
		return {}

	if _online_cache.has(character_id):
		return _online_cache[character_id]

	var file_path = players_save_path.path_join("%s.json" % character_id)
	if not FileAccess.file_exists(file_path):
		return {}

	var fa = FileAccess.open(file_path, FileAccess.READ)
	if fa == null:
		return {}

	var text = fa.get_as_text()
	fa.close()

	var json = JSON.new()
	var err = json.parse(text)
	if err != OK or not (json.data is Dictionary):
		return {}

	var loaded: Dictionary = json.data
	_online_cache[character_id] = loaded
	return loaded


func unload_player(character_id: String) -> void:
	if _online_cache.has(character_id):
		save_player_state(character_id, _online_cache[character_id])
		_online_cache.erase(character_id)


func save_world_state(world_data: Dictionary) -> Error:
	_garantir_diretorios()
	var json_str = JSON.stringify(world_data, "\t")
	var fa = FileAccess.open(world_save_path, FileAccess.WRITE)
	if fa == null:
		return FileAccess.get_open_error()
	fa.store_string(json_str)
	fa.close()
	return OK


func load_world_state() -> Dictionary:
	if not FileAccess.file_exists(world_save_path):
		return {}

	var fa = FileAccess.open(world_save_path, FileAccess.READ)
	if fa == null:
		return {}

	var text = fa.get_as_text()
	fa.close()

	var json = JSON.new()
	var err = json.parse(text)
	if err != OK or not (json.data is Dictionary):
		return {}

	return json.data
