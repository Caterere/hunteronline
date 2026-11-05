class_name FarmZone
extends Resource

# ============================================================
# HUNTER ONLINE — FARM ZONE (ZONA DE FARMING ESTILO PRISTON)
# ============================================================
#
# Define uma faixa de level + pool de inimigos + drops de buff
# para o mundo permanente (Padokia e expansões futuras).
#
# ============================================================

@export var zone_id: StringName = &""
@export var display_name: String = "Zona de Farming"
@export_file("*.tscn") var map_scene_path: String = ""
@export var level_min: int = 1
@export var level_max: int = 30
@export var max_alive: int = 8
@export var respawn_delay: float = 18.0
@export var spawn_margin: float = 48.0
## Área de spawn local ao mapa (pixels).
@export var spawn_rect: Rect2 = Rect2(80, 100, 640, 440)

## Pool: {enemy_id, weight, elite_chance, force_hatsu}
@export var enemy_pool: Array = []
## Drops de buff da zona: {item_id, chance, quantidade, elite_bonus}
@export var buff_drop_table: Array = []


func faixa_level_texto() -> String:
	return "Lv %d–%d" % [level_min, level_max]


func sortear_inimigo(rng: RandomNumberGenerator) -> Dictionary:
	if enemy_pool.is_empty():
		return {}
	var total_w: float = 0.0
	for entry in enemy_pool:
		total_w += maxf(0.01, float(entry.get("weight", 1.0)))
	var roll: float = rng.randf() * total_w
	var acc: float = 0.0
	for entry in enemy_pool:
		acc += maxf(0.01, float(entry.get("weight", 1.0)))
		if roll <= acc:
			return entry
	return enemy_pool[enemy_pool.size() - 1]


func sortear_nivel(rng: RandomNumberGenerator) -> int:
	var lo: int = mini(level_min, level_max)
	var hi: int = maxi(level_min, level_max)
	return rng.randi_range(lo, hi)


func ponto_spawn_aleatorio(rng: RandomNumberGenerator) -> Vector2:
	var r: Rect2 = spawn_rect
	var m: float = maxf(0.0, spawn_margin)
	var x0: float = r.position.x + m
	var y0: float = r.position.y + m
	var x1: float = r.position.x + r.size.x - m
	var y1: float = r.position.y + r.size.y - m
	if x1 <= x0 or y1 <= y0:
		return r.get_center()
	return Vector2(rng.randf_range(x0, x1), rng.randf_range(y0, y1))


func to_dict() -> Dictionary:
	return {
		"zone_id": String(zone_id),
		"display_name": display_name,
		"map_scene_path": map_scene_path,
		"level_min": level_min,
		"level_max": level_max,
		"max_alive": max_alive,
		"respawn_delay": respawn_delay,
		"spawn_margin": spawn_margin,
		"spawn_rect": [spawn_rect.position.x, spawn_rect.position.y, spawn_rect.size.x, spawn_rect.size.y],
		"enemy_pool": enemy_pool.duplicate(true),
		"buff_drop_table": buff_drop_table.duplicate(true),
	}


static func from_dict(data: Dictionary) -> Resource:
	var z = new()
	z.zone_id = StringName(str(data.get("zone_id", "")))
	z.display_name = str(data.get("display_name", "Zona"))
	z.map_scene_path = str(data.get("map_scene_path", ""))
	z.level_min = int(data.get("level_min", 1))
	z.level_max = int(data.get("level_max", 30))
	z.max_alive = int(data.get("max_alive", 8))
	z.respawn_delay = float(data.get("respawn_delay", 18.0))
	z.spawn_margin = float(data.get("spawn_margin", 48.0))
	var rect_arr = data.get("spawn_rect", [80, 100, 640, 440])
	if rect_arr is Array and rect_arr.size() >= 4:
		z.spawn_rect = Rect2(float(rect_arr[0]), float(rect_arr[1]), float(rect_arr[2]), float(rect_arr[3]))
	z.enemy_pool.clear()
	for e in data.get("enemy_pool", []):
		if e is Dictionary:
			z.enemy_pool.append(e)
	z.buff_drop_table.clear()
	for b in data.get("buff_drop_table", []):
		if b is Dictionary:
			z.buff_drop_table.append(b)
	return z
