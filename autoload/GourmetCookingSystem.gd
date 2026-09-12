extends Node

## Gourmet Hunter — coleta, receitas, buffs temporários e writs diários.
## Buffs são temporários (sem power creep permanente).

signal recipe_cooked(recipe_id: String, buffs: Dictionary)
signal ingredient_gathered(item_id: String, qty: int)
signal writ_completed(writ_id: String, reward: Dictionary)
signal writs_refreshed(day: int)

const RECIPES := {
	"banquete_magico": {
		"id": "banquete_magico",
		"name": "Banquete Mágico",
		"ingredients": {"carne_fera": 2, "tempero_proibido": 1},
		"buffs": {"max_hp_pct": 0.08, "aura_regen_pct": 0.12},
		"duration_sec": 300.0,
	},
	"caldo_ten": {
		"id": "caldo_ten",
		"name": "Caldo de Ten",
		"ingredients": {"osso_aura": 1, "erva_silvestre": 2},
		"buffs": {"defense_pct": 0.1},
		"duration_sec": 240.0,
	},
	"espeto_vulcao": {
		"id": "espeto_vulcao",
		"name": "Espeto do Vulcão",
		"ingredients": {"carne_fera": 3, "pimenta_infernal": 1},
		"buffs": {"attack_pct": 0.1, "speed_pct": 0.05},
		"duration_sec": 180.0,
	},
}

const GATHER_TABLE := [
	{"id": "erva_silvestre", "weight": 40, "qty_min": 1, "qty_max": 2},
	{"id": "carne_fera", "weight": 30, "qty_min": 1, "qty_max": 1},
	{"id": "osso_aura", "weight": 15, "qty_min": 1, "qty_max": 1},
	{"id": "tempero_proibido", "weight": 10, "qty_min": 1, "qty_max": 1},
	{"id": "pimenta_infernal", "weight": 5, "qty_min": 1, "qty_max": 1},
]

var pantry: Dictionary = {} ## item_id -> qty
var active_buffs: Dictionary = {} ## recipe_id -> {buffs, expires_at, name}
var daily_writs: Array = []
var writs_day: int = -1
var completed_writs_today: Array = []


func _ready() -> void:
	refresh_writs_if_needed()


func _process(_delta: float) -> void:
	_expire_buffs()


func gather_random(rng: RandomNumberGenerator = null) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var total := 0
	for row in GATHER_TABLE:
		total += int(row.get("weight", 1))
	var roll := rng.randi_range(1, maxi(1, total))
	var acc := 0
	var chosen: Dictionary = GATHER_TABLE[0]
	for row in GATHER_TABLE:
		acc += int(row.get("weight", 1))
		if roll <= acc:
			chosen = row
			break
	var item_id := str(chosen.get("id", "erva_silvestre"))
	var qty := rng.randi_range(int(chosen.get("qty_min", 1)), int(chosen.get("qty_max", 1)))
	pantry[item_id] = int(pantry.get(item_id, 0)) + qty
	if PlayerData != null and PlayerData.has_method("adicionar_item"):
		PlayerData.adicionar_item(StringName(item_id), qty)
	_bump_gather_writ(item_id, qty)
	ingredient_gathered.emit(item_id, qty)
	return {"ok": true, "item_id": item_id, "qty": qty}


func can_cook(recipe_id: String) -> Dictionary:
	if not RECIPES.has(recipe_id):
		return {"ok": false, "error": "receita_desconhecida"}
	var recipe: Dictionary = RECIPES[recipe_id]
	for ing in recipe.get("ingredients", {}).keys():
		var need := int(recipe["ingredients"][ing])
		if _count(str(ing)) < need:
			return {"ok": false, "error": "faltam_ingredientes", "item": str(ing), "need": need, "have": _count(str(ing))}
	return {"ok": true, "recipe": recipe.duplicate(true)}


func cook(recipe_id: String) -> Dictionary:
	var gate := can_cook(recipe_id)
	if not bool(gate.get("ok", false)):
		return gate
	var recipe: Dictionary = RECIPES[recipe_id]
	for ing in recipe.get("ingredients", {}).keys():
		_consume(str(ing), int(recipe["ingredients"][ing]))
	var now := Time.get_unix_time_from_system()
	var entry := {
		"buffs": (recipe.get("buffs", {}) as Dictionary).duplicate(true),
		"expires_at": now + float(recipe.get("duration_sec", 180.0)),
		"name": str(recipe.get("name", recipe_id)),
	}
	active_buffs[recipe_id] = entry
	_bump_cook_writ(recipe_id)
	recipe_cooked.emit(recipe_id, entry)
	return {"ok": true, "recipe_id": recipe_id, "buffs": entry}


func get_active_buff_totals() -> Dictionary:
	_expire_buffs()
	var totals := {
		"max_hp_pct": 0.0,
		"aura_regen_pct": 0.0,
		"defense_pct": 0.0,
		"attack_pct": 0.0,
		"speed_pct": 0.0,
	}
	for rid in active_buffs.keys():
		var b: Dictionary = active_buffs[rid].get("buffs", {})
		for k in totals.keys():
			totals[k] = float(totals[k]) + float(b.get(k, 0.0))
	return totals


func list_recipes() -> Array:
	var out: Array = []
	for k in RECIPES.keys():
		out.append((RECIPES[k] as Dictionary).duplicate(true))
	return out


func get_daily_writs() -> Array:
	refresh_writs_if_needed()
	return daily_writs.duplicate(true)


func complete_writ(writ_id: String) -> Dictionary:
	refresh_writs_if_needed()
	if completed_writs_today.has(writ_id):
		return {"ok": false, "error": "ja_completo"}
	var found: Dictionary = {}
	for w in daily_writs:
		if str(w.get("id", "")) == writ_id:
			found = w
			break
	if found.is_empty():
		return {"ok": false, "error": "writ_desconhecido"}
	if int(found.get("progress", 0)) < int(found.get("target", 1)):
		return {"ok": false, "error": "progresso_insuficiente"}
	completed_writs_today.append(writ_id)
	var reward: Dictionary = found.get("reward", {"jenny": 500, "rep": 10}).duplicate(true)
	if Economy != null:
		if Economy.has_method("adicionar_gold"):
			Economy.adicionar_gold(int(reward.get("jenny", 0)))
		elif Economy.has_method("adicionar_jenny"):
			Economy.adicionar_jenny(int(reward.get("jenny", 0)))
	writ_completed.emit(writ_id, reward)
	return {"ok": true, "reward": reward}


func refresh_writs_if_needed() -> void:
	var day := _day()
	if day == writs_day and not daily_writs.is_empty():
		return
	writs_day = day
	completed_writs_today.clear()
	daily_writs = [
		{"id": "writ_gather_erva", "type": "gather", "item_id": "erva_silvestre", "target": 3, "progress": 0, "reward": {"jenny": 400, "rep": 5}},
		{"id": "writ_cook_banquete", "type": "cook", "recipe_id": "banquete_magico", "target": 1, "progress": 0, "reward": {"jenny": 800, "rep": 12}},
		{"id": "writ_gather_carne", "type": "gather", "item_id": "carne_fera", "target": 2, "progress": 0, "reward": {"jenny": 500, "rep": 8}},
	]
	writs_refreshed.emit(day)


func _bump_gather_writ(item_id: String, qty: int) -> void:
	refresh_writs_if_needed()
	for i in range(daily_writs.size()):
		var w: Dictionary = daily_writs[i]
		if str(w.get("type", "")) == "gather" and str(w.get("item_id", "")) == item_id:
			w["progress"] = mini(int(w.get("target", 1)), int(w.get("progress", 0)) + qty)
			daily_writs[i] = w


func _bump_cook_writ(recipe_id: String) -> void:
	refresh_writs_if_needed()
	for i in range(daily_writs.size()):
		var w: Dictionary = daily_writs[i]
		if str(w.get("type", "")) == "cook" and str(w.get("recipe_id", "")) == recipe_id:
			w["progress"] = mini(int(w.get("target", 1)), int(w.get("progress", 0)) + 1)
			daily_writs[i] = w


func _day() -> int:
	if TimeManager != null and TimeManager.has_method("obter_dia"):
		return int(TimeManager.obter_dia())
	return int(Time.get_unix_time_from_system() / 86400.0)


func _count(item_id: String) -> int:
	return int(pantry.get(item_id, 0))


func _consume(item_id: String, qty: int) -> void:
	pantry[item_id] = maxi(0, int(pantry.get(item_id, 0)) - qty)


func _expire_buffs() -> void:
	var now := Time.get_unix_time_from_system()
	var dead: Array = []
	for rid in active_buffs.keys():
		if float(active_buffs[rid].get("expires_at", 0.0)) <= now:
			dead.append(rid)
	for rid in dead:
		active_buffs.erase(rid)
