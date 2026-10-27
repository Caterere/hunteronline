class_name GreedIslandCardCatalog
extends RefCounted

# ============================================================
# HUNTER ONLINE — CATÁLOGO DE CARTAS GI (S4 duelável)
# ============================================================
# SSOT de cartas de Greed Island para binder + duelo.
# IDs estáveis `carta_NNN` compatíveis com PlayerData.inventory.
# ============================================================

## 24 cartas dueláveis (subset jogável). binder continua mostrando coleção.
static func duel_catalog() -> Array:
	return [
		_card("000", "carta_000", "Aliança dos Caçadores", "SS", 12, 10, "spell"),
		_card("001", "carta_001", "Sopro Secreto do Arcanjo", "SS", 8, 14, "heal"),
		_card("002", "carta_002", "Diamante do Arco-Íris", "S", 10, 8, "spell"),
		_card("003", "carta_003", "Anel de Ouro Real", "S", 7, 12, "defend"),
		_card("004", "carta_004", "Espada do Julgamento", "S", 13, 5, "attack"),
		_card("005", "carta_005", "Escudo de Gyo", "A", 5, 11, "defend"),
		_card("006", "carta_006", "Lança de Ren", "A", 11, 4, "attack"),
		_card("007", "carta_007", "Botas de Zetsu", "A", 6, 7, "spell"),
		_card("017", "carta_017", "Castelo do Sol Nascente", "A", 9, 9, "spell"),
		_card("025", "carta_025", "Dado do Risco e da Sorte", "A", 8, 6, "spell"),
		_card("030", "carta_030", "Lobo de Antokiba", "B", 9, 5, "attack"),
		_card("031", "carta_031", "Armadura de Pedra", "B", 4, 10, "defend"),
		_card("040", "carta_040", "Poção de Aura", "B", 3, 8, "heal"),
		_card("045", "carta_045", "Adaga Silenciosa", "B", 10, 3, "attack"),
		_card("050", "carta_050", "Fada da Floresta Densa", "B", 6, 8, "spell"),
		_card("055", "carta_055", "Golem de Areia", "C", 7, 7, "defend"),
		_card("060", "carta_060", "Flecha de Vento", "C", 8, 3, "attack"),
		_card("065", "carta_065", "Manto de Niebla", "C", 5, 6, "spell"),
		_card("070", "carta_070", "Bandagem de Campo", "C", 2, 7, "heal"),
		_card("075", "carta_075", "Água Sagrada de Dion", "B", 4, 9, "heal"),
		_card("080", "carta_080", "Martelo de Razor", "A", 12, 6, "attack"),
		_card("084", "carta_084", "Chave da Verdade Oculta", "A", 7, 8, "spell"),
		_card("090", "carta_090", "Trombeta da Partida", "C", 6, 4, "spell"),
		_card("099", "carta_099", "Bênção da Fada da Fortuna", "S", 9, 9, "heal"),
	]


static func binder_catalog() -> Array:
	# Compatível com GreedIslandBinderUI.cartas_catalogo shape
	var out: Array = []
	for c in duel_catalog():
		out.append({
			"num": c["num"],
			"id": c["id"],
			"nome": c["nome"],
			"rank": c["rank"],
			"bonus": _bonus_from_rank(str(c["rank"])),
		})
	return out


static func by_id(card_id: String) -> Dictionary:
	for c in duel_catalog():
		if str(c.get("id", "")) == card_id:
			return (c as Dictionary).duplicate(true)
	return {}


static func owned_duel_cards() -> Array:
	var out: Array = []
	for c in duel_catalog():
		var id := str(c.get("id", ""))
		if PlayerData != null and PlayerData.tem_item(StringName(id)):
			out.append((c as Dictionary).duplicate(true))
	return out


static func npc_deck(difficulty: String = "antokiba") -> Array:
	var pool := duel_catalog()
	var picks: Array = []
	match difficulty:
		"razor":
			for c in pool:
				if str(c.get("rank", "")) in ["SS", "S", "A"]:
					picks.append((c as Dictionary).duplicate(true))
		_:
			for c in pool:
				if str(c.get("rank", "")) in ["A", "B", "C"]:
					picks.append((c as Dictionary).duplicate(true))
	picks.shuffle()
	return picks.slice(0, mini(8, picks.size()))


static func _card(num: String, id: String, nome: String, rank: String, atk: int, defense: int, kind: String) -> Dictionary:
	return {
		"num": num,
		"id": id,
		"nome": nome,
		"rank": rank,
		"atk": atk,
		"def": defense,
		"kind": kind,
	}


static func _bonus_from_rank(rank: String) -> String:
	match rank:
		"SS": return "Carta SS — duelo elite"
		"S": return "Carta S — duelo alto"
		"A": return "Carta A — duelo sólido"
		"B": return "Carta B — duelo padrão"
		_: return "Carta C — duelo básico"


static func is_flavor_pack(item_id: String) -> bool:
	return item_id in ["carta_greed_comum", "carta_greed_rara"]


static func is_catalog_card(item_id: String) -> bool:
	return not by_id(item_id).is_empty()


static func owned_unique_count() -> int:
	var n := 0
	for c in duel_catalog():
		var id := str(c.get("id", ""))
		if PlayerData != null and PlayerData.tem_item(StringName(id)):
			n += 1
	return n


## Rola uma carta do catálogo. Packs raros priorizam ranks altos.
static func roll_loot_card_id(flavor_id: String = "carta_greed_comum") -> String:
	var pool: Array = []
	var rare := flavor_id == "carta_greed_rara"
	for c in duel_catalog():
		var rank := str(c.get("rank", "C"))
		if rare:
			if rank in ["SS", "S", "A"]:
				pool.append(c)
		else:
			if rank in ["A", "B", "C"]:
				pool.append(c)
	if pool.is_empty():
		pool = duel_catalog()
	pool.shuffle()
	# Preferir cartas ainda não obtidas
	for c in pool:
		var id := str(c.get("id", ""))
		if PlayerData == null or not PlayerData.tem_item(StringName(id)):
			return id
	return str(pool[0].get("id", "carta_030"))


## Concede cartas reais a partir de packs flavor; retorna IDs concedidos.
static func grant_from_flavor(flavor_id: String, quantidade: int = 1) -> Array:
	var granted: Array = []
	for _i in range(maxi(1, quantidade)):
		var card_id := roll_loot_card_id(flavor_id)
		if PlayerData != null:
			PlayerData.adicionar_item(StringName(card_id), 1)
		granted.append(card_id)
	return granted


static func grant_random_unowned(prefer_unowned: bool = true) -> String:
	var pool := duel_catalog().duplicate()
	pool.shuffle()
	var pick := ""
	if prefer_unowned:
		for c in pool:
			var id := str(c.get("id", ""))
			if PlayerData == null or not PlayerData.tem_item(StringName(id)):
				pick = id
				break
	if pick.is_empty() and not pool.is_empty():
		pick = str(pool[0].get("id", ""))
	if pick.is_empty():
		return ""
	if PlayerData != null:
		PlayerData.adicionar_item(StringName(pick), 1)
	return pick


## Chamado por PlayerData ao obter carta_NNN (idempotente).
static func on_catalog_card_obtained(card_id: String) -> void:
	if CollectionManager != null and CollectionManager.has_method("register_discovery"):
		CollectionManager.register_discovery("secrets", card_id)
	apply_binder_bonus()


## Bônus do binder: +3% por carta única em atributos principais (source gi_binder).
static func apply_binder_bonus() -> void:
	if PlayerData == null:
		return
	var obtidas := owned_unique_count()
	var pct := float(obtidas * 3) # alinhado ao texto da UI do binder
	PlayerData.remover_modificadores_da_fonte("gi_binder")
	if pct <= 0.0:
		return
	var stats := [&"forca", &"defesa", &"velocidade", &"vida_max", &"aura_max"]
	for st in stats:
		PlayerData.adicionar_modificador(StatModifier.new(
			StringName("gi_binder_%s" % String(st)),
			st,
			StatModifier.Type.PERCENTAGE,
			pct,
			-1.0,
			"gi_binder"
		))


static func duel_victory_reward(jenny: int = 150) -> Dictionary:
	var card_id := grant_random_unowned(true)
	if Economy != null and jenny > 0:
		Economy.adicionar_gold(jenny)
	elif PlayerData != null and jenny > 0:
		PlayerData.attributes["gold"] = int(PlayerData.attributes.get("gold", 0)) + jenny
	return {"ok": true, "card_id": card_id, "jenny": jenny}
