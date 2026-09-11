class_name ServerListCatalog
extends RefCounted

# ============================================================
# HUNTER ONLINE — PUBLIC / DNS SERVER LIST
# ============================================================
#
# Catálogo estático de servidores conhecidos (LAN favoritos + VPS/DNS).
# Fonte: res://config/server_list.json (editável sem rebuild).
# ============================================================

const DEFAULT_PATH: String = "res://config/server_list.json"
const USER_OVERRIDE_PATH: String = "user://server_list.json"


static func load_servers(path: String = "") -> Array[Dictionary]:
	var target := path
	if target.is_empty():
		if FileAccess.file_exists(USER_OVERRIDE_PATH):
			target = USER_OVERRIDE_PATH
		else:
			target = DEFAULT_PATH

	var list: Array[Dictionary] = []
	if not FileAccess.file_exists(target):
		return list

	var fa := FileAccess.open(target, FileAccess.READ)
	if fa == null:
		return list
	var content := fa.get_as_text()
	fa.close()
	if content.begins_with("\ufeff"):
		content = content.substr(1)

	var json := JSON.new()
	if json.parse(content) != OK or not (json.data is Dictionary):
		return list

	var arr = json.data.get("servers", [])
	if not (arr is Array):
		return list
	for entry in arr:
		if entry is Dictionary:
			list.append({
				"id": str(entry.get("id", "")),
				"name": str(entry.get("name", "Hunter Server")),
				"host": str(entry.get("host", entry.get("public_host", "127.0.0.1"))),
				"port": int(entry.get("port", 7777)),
				"region": str(entry.get("region", "")),
				"notes": str(entry.get("notes", ""))
			})
	return list


static func find_by_id(server_id: String) -> Dictionary:
	for s in load_servers():
		if str(s.get("id", "")) == server_id:
			return s
	return {}
