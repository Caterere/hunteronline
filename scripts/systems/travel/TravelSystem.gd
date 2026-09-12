class_name TravelSystemClass
extends Node

# ============================================================
# HUNTER ONLINE — TRAVEL SYSTEM (FASE L)
# ============================================================
#
# Motor canônico de viagens conectadas e rotas de transporte:
# - Gerencia trânsito entre regiões sem quebrar a coesão do mundo.
# - Suporta: Caminhada, Barcos, Dirigíveis, Veículos e Mestres de Viagem.
# - Valida custos, desbloqueios e requisitos narrativos.
# ============================================================

signal viagem_iniciada(origem: String, destino: String, tipo: int)
signal viagem_concluida(destino: String)
signal rota_desbloqueada(rota_id: String)

var registered_regions: Dictionary = {} # StringName -> RegionPackage
var unlocked_routes: Array[String] = []


func _ready() -> void:
	add_to_group("travel_system")
	print("=================================")
	print("[TravelSystem] SISTEMA DE VIAGENS & EXPANSÃO DE MUNDO ATIVO (FASE L)")
	print("=================================")


func register_region_package(pkg: Resource) -> void:
	if pkg == null:
		return
	var r_id = pkg.get("region_id")
	if r_id == null or String(r_id).is_empty():
		return
	var key := StringName(r_id)
	registered_regions[key] = pkg
	var r_name = pkg.get("region_name")
	var name_str = str(r_name) if r_name != null else ""
	print("[TravelSystem] 🗺️ Pacote de Região Registrado: '%s' (%s)" % [key, name_str])


func get_region_package(region_id: Variant) -> Resource:
	var key := StringName(str(region_id))
	if registered_regions.has(key):
		return registered_regions[key]
	return null


func unlock_route(route_id: String) -> void:
	if not unlocked_routes.has(route_id):
		unlocked_routes.append(route_id)
		rota_desbloqueada.emit(route_id)
		print("[TravelSystem] 🚢 Nova rota de viagem desbloqueada: '%s'" % route_id)


func is_route_unlocked(route_id: String) -> bool:
	return unlocked_routes.has(route_id)


func get_available_routes_from(region_id: Variant) -> Array[Dictionary]:
	var pkg = get_region_package(region_id)
	if pkg == null or not (pkg.get("travel_routes") is Array):
		return []
	
	var res: Array[Dictionary] = []
	for r in pkg.travel_routes:
		if r is Dictionary:
			var target = str(r.get("target_region", ""))
			var route_id = "%s_to_%s" % [String(region_id), target]
			var is_unlocked = bool(r.get("unlocked", true)) or is_route_unlocked(route_id)
			var r_copy = r.duplicate()
			r_copy["route_id"] = route_id
			r_copy["is_available"] = is_unlocked
			res.append(r_copy)
	return res


func can_travel(from_region: Variant, to_region: Variant) -> Dictionary:
	var from_pkg = get_region_package(from_region)
	var to_pkg = get_region_package(to_region)
	if from_pkg == null:
		return {"allowed": false, "reason": "Região de origem não catalogada."}
	if to_pkg == null:
		return {"allowed": false, "reason": "Região de destino não catalogada."}

	var routes = get_available_routes_from(from_region)
	var target_str = String(to_region)
	var matched_route: Dictionary = {}
	for r in routes:
		if str(r.get("target_region", "")) == target_str:
			matched_route = r
			break

	if matched_route.is_empty():
		return {"allowed": false, "reason": "Não há rota de viagem direta entre estas regiões."}

	if not bool(matched_route.get("is_available", false)):
		return {"allowed": false, "reason": "Esta rota de viagem ainda está bloqueada."}

	var cost = int(matched_route.get("cost_gold", 0))
	if cost > 0:
		var cur_gold = 0
		var econ = Engine.get_main_loop().root.get_node_or_null("Economy")
		if econ != null and econ.has_method("obter_gold"):
			cur_gold = econ.obter_gold()
		elif PlayerData != null:
			cur_gold = int(PlayerData.stats_globais.get("gold", 1000))
			
		if cur_gold < cost:
			return {"allowed": false, "reason": "Jenny insuficiente (%d Jenny necessários)." % cost}

	return {"allowed": true, "route": matched_route}


func execute_travel(from_region: Variant, to_region: Variant, _tree: SceneTree = null) -> bool:
	var check = can_travel(from_region, to_region)
	if not bool(check.get("allowed", false)):
		push_warning("[TravelSystem] Viagem recusada: " + str(check.get("reason", "")))
		return false

	var to_pkg = get_region_package(to_region)
	var s_path = to_pkg.get("scene_path")
	var dest_scene = str(s_path) if s_path != null else ""
	var r_name = to_pkg.get("region_name")
	var dest_name = str(r_name) if r_name != null else String(to_region)
	var route_info = check.get("route", {}) as Dictionary
	var travel_type = int(route_info.get("type", 0))

	# Cobrar custo de viagem se houver
	var cost = int(route_info.get("cost_gold", 0))
	if cost > 0:
		var econ = Engine.get_main_loop().root.get_node_or_null("Economy")
		if econ != null and econ.has_method("remover_gold"):
			econ.remover_gold(cost)

	viagem_iniciada.emit(String(from_region), String(to_region), travel_type)
	print("[TravelSystem] 🚀 Viagem iniciada de '%s' para '%s' (Tipo: %d | Custo: %d Jenny)" % [
		String(from_region), String(to_region), travel_type, cost
	])

	if dest_scene.is_empty():
		viagem_concluida.emit(String(to_region))
		return true

	# Transição de Cena suave
	var main_tree = Engine.get_main_loop() as SceneTree
	if main_tree != null:
		var trans = main_tree.root.get_node_or_null("SceneTransition")
		if trans != null and trans.has_method("mudar_cena"):
			trans.mudar_cena(dest_scene, "Em Trânsito...", dest_name)
		else:
			main_tree.change_scene_to_file(dest_scene)

	viagem_concluida.emit(String(to_region))
	return true


# ============================================================
# PERSISTÊNCIA SERIALIZÁVEL
# ============================================================



# ============================================================
# SKINS DE VIAGEM (B12) — cosmético only
# ============================================================

signal skin_unlocked(skin_id: String)
signal active_skin_changed(skin_id: String)

var unlocked_skins: Array[String] = ["default"]
var active_skin: String = "default"


func unlock_skin(skin_id: String) -> bool:
	skin_id = skin_id.strip_edges()
	if skin_id.is_empty():
		return false
	if not unlocked_skins.has(skin_id):
		unlocked_skins.append(skin_id)
		skin_unlocked.emit(skin_id)
		print("[TravelSystem] 🎨 Skin de viagem desbloqueada: '%s'" % skin_id)
	return true


func has_skin(skin_id: String) -> bool:
	return unlocked_skins.has(skin_id)


func set_active_skin(skin_id: String) -> bool:
	if not has_skin(skin_id):
		return false
	active_skin = skin_id
	active_skin_changed.emit(skin_id)
	return true


func get_active_skin() -> String:
	return active_skin


func list_skins() -> Array:
	return unlocked_skins.duplicate()

func serializar() -> Dictionary:
	return {
		"unlocked_routes": unlocked_routes.duplicate(),
		"unlocked_skins": unlocked_skins.duplicate(),
		"active_skin": active_skin,
	}


func deserializar(data: Dictionary) -> void:
	unlocked_routes.clear()
	for r in data.get("unlocked_routes", []):
		unlocked_routes.append(str(r))
	unlocked_skins.clear()
	unlocked_skins.append("default")
	for s in data.get("unlocked_skins", []):
		var sid := str(s)
		if not unlocked_skins.has(sid):
			unlocked_skins.append(sid)
	var ask := str(data.get("active_skin", "default"))
	active_skin = ask if unlocked_skins.has(ask) else "default"
