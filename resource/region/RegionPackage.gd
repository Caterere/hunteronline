class_name RegionPackage
extends Resource

# ============================================================
# HUNTER ONLINE — REGION PACKAGE (FASE L)
# ============================================================
#
# Pacote modular declarativo para adição de regiões completas:
# - Mapa, áudio, clima, iluminação e identidade regional.
# - NPCs, criaturas, chefes e segredos associados.
# - Rotas de viagem conectadas (caminhada, barco, dirigível, mestre).
# ============================================================

enum DangerLevel {
	SAFE = 0,
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
	CALAMITY = 4
}

enum TravelType {
	FOOT,
	BOAT,
	AIRSHIP,
	VEHICLE,
	TRAVEL_MASTER,
	SPECIAL_TRANSIT
}

@export var region_id: StringName = &""
@export var region_name: String = ""
@export_multiline var description: String = ""
@export var scene_path: String = ""
@export var ambient_music: String = ""
@export var ambient_weather: Array[int] = [0] # 0: Limpo, 1: Chuva, 2: Neblina, 3: Aura
@export var danger_level: DangerLevel = DangerLevel.LOW
@export var recommended_level: Vector2i = Vector2i(1, 100)

# Identidade Regional (L9)
@export var regional_identity: Dictionary = {
	"lighting_tint": Color(1.0, 1.0, 1.0, 1.0),
	"ambient_sfx": "forest_wind",
	"unique_mechanic": "none",
	"architecture_style": "ruins",
	"risk_pacing": "moderate"
}

# Entidades e Conteúdo Local
@export var npcs: Array = []
@export var enemies: Array = []
@export var bosses: Array = []
@export var quests: Array = []
@export var points_of_interest: Array = []
@export var secrets: Array = []
@export var world_events: Array = []

# Rotas de Viagem Conectadas (L10, L11)
# Exemplo: [{"target_region": "porto_yorknew", "type": TravelType.BOAT, "cost_gold": 500, "unlocked": true}]
@export var travel_routes: Array = []


func _init(
	p_id: StringName = &"",
	p_name: String = "",
	p_scene: String = "",
	p_danger: DangerLevel = DangerLevel.LOW
) -> void:
	region_id = p_id
	region_name = p_name
	scene_path = p_scene
	danger_level = p_danger


func add_travel_route(target_region: StringName, travel_type: TravelType, cost: int = 0, unlocked: bool = true) -> void:
	travel_routes.append({
		"target_region": String(target_region),
		"type": int(travel_type),
		"cost_gold": cost,
		"unlocked": unlocked
	})


func add_point_of_interest(poi_id: String, poi_name: String, pos: Vector2, icon: String = "poi") -> void:
	points_of_interest.append({
		"id": poi_id,
		"name": poi_name,
		"position": [pos.x, pos.y],
		"icon": icon
	})


func add_secret(secret_id: String, secret_name: String, hint: String, pos: Vector2) -> void:
	secrets.append({
		"id": secret_id,
		"name": secret_name,
		"hint": hint,
		"position": [pos.x, pos.y],
		"discovered": false
	})


func to_dict() -> Dictionary:
	return {
		"region_id": String(region_id),
		"region_name": region_name,
		"description": description,
		"scene_path": scene_path,
		"ambient_music": ambient_music,
		"ambient_weather": ambient_weather.duplicate(),
		"danger_level": int(danger_level),
		"recommended_level": [recommended_level.x, recommended_level.y],
		"regional_identity": regional_identity.duplicate(true),
		"npcs": npcs.duplicate(),
		"enemies": enemies.duplicate(),
		"bosses": bosses.duplicate(),
		"quests": quests.duplicate(),
		"points_of_interest": points_of_interest.duplicate(true),
		"secrets": secrets.duplicate(true),
		"world_events": world_events.duplicate(),
		"travel_routes": travel_routes.duplicate(true)
	}


static func from_dict(data: Dictionary) -> Resource:
	var pkg = (load("res://resource/region/RegionPackage.gd") as GDScript).new()
	pkg.region_id = StringName(data.get("region_id", ""))
	pkg.region_name = str(data.get("region_name", ""))
	pkg.description = str(data.get("description", ""))
	pkg.scene_path = str(data.get("scene_path", ""))
	pkg.ambient_music = str(data.get("ambient_music", ""))
	
	pkg.ambient_weather.clear()
	for w in data.get("ambient_weather", [0]):
		pkg.ambient_weather.append(int(w))
		
	pkg.danger_level = int(data.get("danger_level", DangerLevel.LOW)) as DangerLevel
	
	var lvl = data.get("recommended_level", [1, 100])
	if lvl is Array and lvl.size() >= 2:
		pkg.recommended_level = Vector2i(int(lvl[0]), int(lvl[1]))
		
	pkg.regional_identity = (data.get("regional_identity", {}) as Dictionary).duplicate(true)
	
	pkg.npcs.clear()
	for n in data.get("npcs", []):
		pkg.npcs.append(str(n))
		
	pkg.enemies.clear()
	for e in data.get("enemies", []):
		pkg.enemies.append(str(e))
		
	pkg.bosses.clear()
	for b in data.get("bosses", []):
		pkg.bosses.append(str(b))
		
	pkg.quests.clear()
	for q in data.get("quests", []):
		pkg.quests.append(str(q))
		
	pkg.points_of_interest = (data.get("points_of_interest", []) as Array).duplicate(true)
	pkg.secrets = (data.get("secrets", []) as Array).duplicate(true)
	
	pkg.world_events.clear()
	for we in data.get("world_events", []):
		pkg.world_events.append(str(we))
		
	pkg.travel_routes = (data.get("travel_routes", []) as Array).duplicate(true)
	return pkg
