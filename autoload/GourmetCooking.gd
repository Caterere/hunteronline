class_name GourmetCookingSystem
extends Node

# ============================================================
# HUNTER ONLINE — A8 GOURMET LIFE SKILLS (LEVE)
# ============================================================
#
# Coleta → cozinha → buff temporário (StatModifier).
# Não compete com árvore de Nen: só buffs cosméticos/temporários.
#
# ============================================================

signal recipe_cooked(recipe_id: String, food_id: String)
signal food_consumed(food_id: String, buff_stat: String, value: float)
signal writ_completed(writ_id: String)

## receita_id → {nome, ingredientes{item:qtd}, food_id, jenny_custo, buff{stat,value,duration}, gourmet_xp}
const RECIPES := {
	"ensopado_javali": {
		"nome": "Ensopado de Javali",
		"ingredientes": {"carne_javali": 2},
		"food_id": "food_ensopado_javali",
		"jenny_custo": 50,
		"buff": {"stat": "vida_max", "value": 40.0, "duration": 180.0},
		"gourmet_xp": 40
	},
	"cha_erva_nen": {
		"nome": "Chá de Erva de Aura",
		"ingredientes": {"erva_nen": 3},
		"food_id": "food_cha_erva",
		"jenny_custo": 30,
		"buff": {"stat": "aura_max", "value": 25.0, "duration": 150.0},
		"gourmet_xp": 30
	},
	"banquete_magico": {
		"nome": "Banquete Mágico",
		"ingredientes": {"carne_javali": 3, "erva_nen": 2, "temperos_raros": 1},
		"food_id": "food_banquete_magico",
		"jenny_custo": 200,
		"buff": {"stat": "forca", "value": 8.0, "duration": 240.0},
		"gourmet_xp": 120
	}
}

const FOOD_CATALOG := {
	"food_ensopado_javali": {"nome": "Ensopado de Javali", "recipe": "ensopado_javali"},
	"food_cha_erva": {"nome": "Chá de Erva de Aura", "recipe": "cha_erva_nen"},
	"food_banquete_magico": {"nome": "Banquete Mágico", "recipe": "banquete_magico"}
}

var daily_writs: Array[Dictionary] = []
var _writ_day: int = -1
var _claimed_writs: Dictionary = {}


func _ready() -> void:
	_ensure_economy_ingredients()
	garantir_writs_diarios()
	print("[GourmetCooking] Life skills Gourmet ativas (A8)")


func _ensure_economy_ingredients() -> void:
	if Economy == null:
		return
	# Economy.ITEM_CATALOGO é const — só documentamos ids usados; PlayerData aceita StringName livres


func list_recipes() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for rid in RECIPES.keys():
		var r: Dictionary = RECIPES[rid].duplicate(true)
		r["id"] = rid
		out.append(r)
	return out


func pode_cozinhar(recipe_id: String) -> Dictionary:
	if not RECIPES.has(recipe_id):
		return {"ok": false, "erro": "Receita desconhecida"}
	var faccao := ""
	if FactionManager != null:
		faccao = str(FactionManager.faccao_atual)
	elif PlayerData != null:
		faccao = str(PlayerData.faccao_atual)
	if faccao != "gourmet":
		return {"ok": false, "erro": "Requer Guilda Gourmet (fale com Menchi)"}
	var r: Dictionary = RECIPES[recipe_id]
	var custo: int = int(r.get("jenny_custo", 0))
	if Economy != null and not Economy.tem_gold(custo):
		return {"ok": false, "erro": "Jenny insuficiente"}
	if PlayerData == null:
		return {"ok": false, "erro": "PlayerData ausente"}
	for ing in r.get("ingredientes", {}).keys():
		var need: int = int(r["ingredientes"][ing])
		var have: int = int(PlayerData.inventory.get(StringName(ing), PlayerData.inventory.get(ing, 0)))
		if have < need:
			return {"ok": false, "erro": "Falta %s (%d/%d)" % [ing, have, need]}
	return {"ok": true}


func cozinhar(recipe_id: String) -> Dictionary:
	var check: Dictionary = pode_cozinhar(recipe_id)
	if not bool(check.get("ok", false)):
		return check
	var r: Dictionary = RECIPES[recipe_id]
	if Economy != null:
		Economy.remover_gold(int(r.get("jenny_custo", 0)))
	for ing in r.get("ingredientes", {}).keys():
		var need: int = int(r["ingredientes"][ing])
		_remover_item(str(ing), need)
	var food_id: String = str(r.get("food_id"))
	PlayerData.adicionar_item(StringName(food_id), 1)
	if FactionManager != null:
		FactionManager.adicionar_faccao_xp(int(r.get("gourmet_xp", 20)))
	recipe_cooked.emit(recipe_id, food_id)
	if EventBus != null:
		EventBus.emit_toast("🍖 Cozinhou: %s" % str(r.get("nome")), Color(1.0, 0.7, 0.3))
	_try_complete_writ_cook(recipe_id)
	return {"ok": true, "food_id": food_id}


func consumir_comida(food_id: String) -> Dictionary:
	if not FOOD_CATALOG.has(food_id):
		return {"ok": false, "erro": "Não é comida Gourmet"}
	var recipe_id: String = str(FOOD_CATALOG[food_id].get("recipe"))
	if not RECIPES.has(recipe_id):
		return {"ok": false, "erro": "Receita órfã"}
	if PlayerData == null:
		return {"ok": false, "erro": "PlayerData ausente"}
	var have: int = int(PlayerData.inventory.get(StringName(food_id), PlayerData.inventory.get(food_id, 0)))
	if have <= 0:
		return {"ok": false, "erro": "Sem comida no inventário"}
	_remover_item(food_id, 1)
	var buff: Dictionary = RECIPES[recipe_id].get("buff", {})
	var stat: String = str(buff.get("stat", "vida_max"))
	var value: float = float(buff.get("value", 10.0))
	var duration: float = float(buff.get("duration", 120.0))
	var mod = StatModifier.new(
		StringName("gourmet_%s" % food_id),
		StringName(stat),
		StatModifier.Type.FLAT,
		value,
		duration,
		"gourmet"
	)
	PlayerData.adicionar_modificador(mod)
	# Timer de expiração leve
	if duration > 0.0:
		var tree := get_tree()
		if tree != null:
			tree.create_timer(duration).timeout.connect(func():
				if PlayerData != null:
					PlayerData.remover_modificador(StringName("gourmet_%s" % food_id))
			)
	food_consumed.emit(food_id, stat, value)
	if EventBus != null:
		EventBus.emit_toast("✨ Buff Gourmet: +%s %s (%.0fs)" % [str(int(value)), stat, duration], Color(0.4, 1.0, 0.55))
	if AudioManager != null:
		AudioManager.tocar_sfx_tipo("item_pickup", 0.9)
	return {"ok": true, "stat": stat, "value": value, "duration": duration}


func garantir_writs_diarios(force: bool = false) -> void:
	var day := 1
	if TimeManager != null:
		day = maxi(1, int(TimeManager.current_day))
	if not force and day == _writ_day and not daily_writs.is_empty():
		return
	_writ_day = day
	daily_writs = [
		{
			"id": "writ_coleta_erva_%d" % day,
			"tipo": "coleta",
			"titulo": "Colheita de Erva de Aura",
			"item_id": "erva_nen",
			"quantidade": 3,
			"jenny": 200,
			"gourmet_xp": 50
		},
		{
			"id": "writ_cozinhar_ensopado_%d" % day,
			"tipo": "cozinhar",
			"titulo": "Preparar Ensopado de Javali",
			"recipe_id": "ensopado_javali",
			"quantidade": 1,
			"jenny": 300,
			"gourmet_xp": 80
		}
	]
	# Seed ingredients leves para onboarding
	if PlayerData != null:
		if int(PlayerData.inventory.get(StringName("erva_nen"), 0)) <= 0:
			PlayerData.adicionar_item(&"erva_nen", 2)
		if int(PlayerData.inventory.get(StringName("carne_javali"), 0)) <= 0:
			PlayerData.adicionar_item(&"carne_javali", 2)


func obter_writs() -> Array[Dictionary]:
	garantir_writs_diarios()
	return daily_writs.duplicate(true)


func coletar_ingrediente(item_id: String, qtd: int = 1) -> void:
	if PlayerData == null:
		return
	PlayerData.adicionar_item(StringName(item_id), qtd)
	_try_complete_writ_coleta(item_id, qtd)
	if EventBus != null:
		EventBus.emit_toast("+%dx %s" % [qtd, item_id], Color(0.55, 0.95, 0.45))


func _try_complete_writ_coleta(item_id: String, _qtd: int) -> void:
	for w in daily_writs:
		if str(w.get("tipo")) != "coleta":
			continue
		var wid := str(w.get("id"))
		if _claimed_writs.get(wid, false):
			continue
		if str(w.get("item_id")) != item_id:
			continue
		var need: int = int(w.get("quantidade", 1))
		var have: int = int(PlayerData.inventory.get(StringName(item_id), 0))
		if have >= need:
			_claim_writ(w)


func _try_complete_writ_cook(recipe_id: String) -> void:
	for w in daily_writs:
		if str(w.get("tipo")) != "cozinhar":
			continue
		var wid := str(w.get("id"))
		if _claimed_writs.get(wid, false):
			continue
		if str(w.get("recipe_id")) == recipe_id:
			_claim_writ(w)


func _claim_writ(w: Dictionary) -> void:
	var wid := str(w.get("id"))
	_claimed_writs[wid] = true
	if Economy != null:
		Economy.adicionar_gold(int(w.get("jenny", 0)))
	if FactionManager != null:
		FactionManager.adicionar_faccao_xp(int(w.get("gourmet_xp", 20)))
	writ_completed.emit(wid)
	if EventBus != null:
		EventBus.emit_toast("📜 Writ Gourmet concluído: %s" % str(w.get("titulo")), Color(1.0, 0.85, 0.4))


func _remover_item(item_id: String, qtd: int) -> void:
	if PlayerData == null:
		return
	var key := StringName(item_id)
	var have: int = int(PlayerData.inventory.get(key, PlayerData.inventory.get(item_id, 0)))
	var left: int = maxi(0, have - qtd)
	if PlayerData.inventory.has(key):
		PlayerData.inventory[key] = left
	elif PlayerData.inventory.has(item_id):
		PlayerData.inventory[item_id] = left
	else:
		PlayerData.inventory[key] = left


func salvar_dados() -> Dictionary:
	return {"writ_day": _writ_day, "claimed": _claimed_writs.duplicate(true)}


func carregar_dados(dados: Dictionary) -> void:
	_writ_day = int(dados.get("writ_day", -1))
	var c = dados.get("claimed", {})
	_claimed_writs = c.duplicate(true) if typeof(c) == TYPE_DICTIONARY else {}
	garantir_writs_diarios()
