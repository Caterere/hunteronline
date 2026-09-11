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
