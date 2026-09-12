extends Node

# ============================================================
# HUNTER ONLINE — YORKNEW AUCTION HOUSE (S1)
# ============================================================
# Marketplace local com escrow de itens + taxa Jenny.
# Persistido via SaveManager ("auction_data").
# ============================================================

signal listings_changed()
signal listing_created(listing_id: String)
signal listing_sold(listing_id: String, buyer_name: String)
signal listing_cancelled(listing_id: String)
signal payout_collected(amount: int)

const LISTING_FEE_RATE := 0.05
const LISTING_FEE_MIN := 25
const MAX_PLAYER_LISTINGS := 12
const ATTR_KEY := "auction_house"

var listings: Dictionary = {} ## listing_id → Dictionary
var _active_item_uids: Dictionary = {} ## item_uid → listing_id (anti-dupe)
var pending_payouts: Dictionary = {} ## seller_id → Jenny
var _next_id: int = 1
var _seeded: bool = false


func _ready() -> void:
	_ensure_seed_listings()
	print("[AuctionHouse] Leilão de Yorknew ativo (escrow local)")


func reset_for_tests() -> void:
	listings.clear()
	pending_payouts.clear()
	_active_item_uids.clear()
	_next_id = 1
	_seeded = false
	_ensure_seed_listings()


func calc_listing_fee(price: int) -> int:
	return maxi(LISTING_FEE_MIN, int(round(float(maxi(1, price)) * LISTING_FEE_RATE)))


func _player_id() -> String:
	if PlayerData == null:
		return "local_hunter"
	var cid := str(PlayerData.character_id).strip_edges()
	return cid if not cid.is_empty() else "local_hunter"


func _player_name() -> String:
	if PlayerData == null:
		return "Caçador"
	var n := str(PlayerData.nome_personagem).strip_edges()
	return n if not n.is_empty() else "Caçador"


func _item_display_name(item_id: String) -> String:
	if Economy != null and Economy.ITEM_CATALOGO.has(item_id):
		return str(Economy.ITEM_CATALOGO[item_id].get("nome", item_id))
	return item_id


func _item_rarity(item_id: String) -> String:
	if DataManager != null and DataManager.has_method("obter_item"):
		var it = DataManager.obter_item(item_id)
		if it != null and "raridade" in it:
			return str(it.raridade)
	if Economy != null and Economy.ITEM_CATALOGO.has(item_id):
		return str(Economy.ITEM_CATALOGO[item_id].get("categoria", "Material"))
	return "Comum"


func _current_day() -> int:
	if TimeManager != null:
		return maxi(1, int(TimeManager.current_day))
	return 1


func _alloc_id() -> String:
	var id := "ah_%d" % _next_id
	_next_id += 1
	return id


func _ensure_seed_listings() -> void:
	if _seeded:
		return
	_seeded = true
	for lid in listings.keys():
		var row = listings[lid]
		if typeof(row) == TYPE_DICTIONARY and str(row.get("seller_kind", "")) == "npc":
			return
	_seed_row("npc_battera", "Battera (Corretor)", "cristal_aura", 1, 2200, "Raro")
	_seed_row("npc_mafia_clerk", "Escrivão do Sindicato", "minerio_aco", 5, 480, "Comum")
	_seed_row("npc_tsezguerra", "Tsezguerra", "nucleo_golem", 1, 1800, "Incomum")


func _seed_row(seller_id: String, seller_name: String, item_id: String, qty: int, price: int, rarity: String) -> void:
	var lid := _alloc_id()
	var uid := _make_item_uid(item_id, seller_id)
	listings[lid] = {
		"listing_id": lid,
		"seller_id": seller_id,
		"seller_name": seller_name,
		"seller_kind": "npc",
		"item_id": item_id,
		"item_uid": uid,
		"qty": qty,
		"price": price,
		"fee_paid": 0,
		"rarity": rarity,
		"nen_tag": _item_nen_tag(item_id),
		"created_day": _current_day(),
		"status": "active",
	}
	_active_item_uids[uid] = lid



func _item_nen_tag(item_id: String) -> String:
	if Economy != null and Economy.ITEM_CATALOGO.has(item_id):
		var tag = Economy.ITEM_CATALOGO[item_id].get("nen_tag", "")
		if str(tag).strip_edges() != "":
			return str(tag)
	if PlayerData != null and "afinidade_nen" in PlayerData:
		return str(PlayerData.afinidade_nen)
	return ""


func _make_item_uid(item_id: String, seller_id: String) -> String:
	return "%s::%s::%d" % [seller_id, item_id, Time.get_ticks_msec()]


func get_active_listings(filter_rarity: String = "", filter_query: String = "", filter_nen: String = "") -> Array:
	_ensure_seed_listings()
	var out: Array = []
	var q := filter_query.strip_edges().to_lower()
	for lid in listings.keys():
		var row = listings[lid]
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if str(row.get("status", "")) != "active":
			continue
		if not filter_rarity.is_empty() and str(row.get("rarity", "")) != filter_rarity:
			continue
		if not filter_nen.is_empty() and str(row.get("nen_tag", "")) != filter_nen:
			continue
		if not q.is_empty():
			var hay := ("%s %s %s" % [
				str(row.get("item_id", "")),
				_item_display_name(str(row.get("item_id", ""))),
				str(row.get("seller_name", "")),
			]).to_lower()
			if hay.find(q) < 0:
				continue
		out.append((row as Dictionary).duplicate(true))
	out.sort_custom(func(a, b): return int(a.get("price", 0)) < int(b.get("price", 0)))
	return out


func get_my_listings() -> Array:
	var pid := _player_id()
	var out: Array = []
	for lid in listings.keys():
		var row = listings[lid]
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if str(row.get("seller_id", "")) == pid and str(row.get("status", "")) == "active":
			out.append((row as Dictionary).duplicate(true))
	return out


func count_my_active() -> int:
	return get_my_listings().size()


func get_pending_payout(seller_id: String = "") -> int:
	var sid := seller_id if not seller_id.is_empty() else _player_id()
	return int(pending_payouts.get(sid, 0))


func collect_payout() -> Dictionary:
	var sid := _player_id()
	var amt := int(pending_payouts.get(sid, 0))
	if amt <= 0:
		return {"ok": false, "error": "sem_payout", "amount": 0}
	pending_payouts[sid] = 0
	if Economy != null:
		Economy.adicionar_gold(amt)
	_mirror_attr()
	payout_collected.emit(amt)
	listings_changed.emit()
	return {"ok": true, "amount": amt}


func list_item(item_id: String, qty: int, price: int) -> Dictionary:
	item_id = item_id.strip_edges()
	qty = maxi(1, qty)
	price = maxi(1, price)
	if item_id.is_empty():
		return {"ok": false, "error": "item_vazio"}
	if count_my_active() >= MAX_PLAYER_LISTINGS:
		return {"ok": false, "error": "limite_anuncios"}
	# Anti-dupe: same seller cannot re-list same item while active
	var preferred_uid := "%s::%s" % [_player_id(), item_id]
	for uid_key in _active_item_uids.keys():
		if str(uid_key).begins_with(preferred_uid + "::") or str(uid_key) == preferred_uid:
			var other_lid := str(_active_item_uids[uid_key])
			if listings.has(other_lid) and str(listings[other_lid].get("status", "")) == "active":
				return {"ok": false, "error": "item_uid_duplicado", "item_uid": str(uid_key)}

	if PlayerData == null or not PlayerData.tem_item(StringName(item_id), qty):
		return {"ok": false, "error": "sem_item"}
	var fee := calc_listing_fee(price)
	if Economy == null or not Economy.tem_gold(fee):
		return {"ok": false, "error": "sem_jenny_taxa", "fee": fee}
	if not Economy.remover_gold(fee):
		return {"ok": false, "error": "taxa_falhou", "fee": fee}
	if not PlayerData.remover_item(StringName(item_id), qty):
		Economy.adicionar_gold(fee)
		return {"ok": false, "error": "escrow_falhou"}

	var lid := _alloc_id()
	var item_uid := _make_item_uid(item_id, _player_id())
	listings[lid] = {
		"listing_id": lid,
		"seller_id": _player_id(),
		"seller_name": _player_name(),
		"seller_kind": "player",
		"item_id": item_id,
		"item_uid": item_uid,
		"qty": qty,
		"price": price,
		"fee_paid": fee,
		"rarity": _item_rarity(item_id),
		"nen_tag": _item_nen_tag(item_id),
		"created_day": _current_day(),
		"status": "active",
	}
	_active_item_uids[item_uid] = lid
	_mirror_attr()
	listings_changed.emit()
	listing_created.emit(lid)
	return {"ok": true, "listing": listings[lid].duplicate(true), "fee": fee}


func buy_listing(listing_id: String) -> Dictionary:
	if not listings.has(listing_id):
		return {"ok": false, "error": "nao_encontrado"}
	var row: Dictionary = listings[listing_id]
	if str(row.get("status", "")) != "active":
		return {"ok": false, "error": "inativo"}
	if str(row.get("seller_id", "")) == _player_id():
		return {"ok": false, "error": "proprio_anuncio"}
	var price := int(row.get("price", 0))
	if Economy == null or not Economy.tem_gold(price):
		return {"ok": false, "error": "sem_jenny", "price": price}
	if not Economy.remover_gold(price):
		return {"ok": false, "error": "pagamento_falhou"}

	var item_id := str(row.get("item_id", ""))
	var qty := int(row.get("qty", 1))
	PlayerData.adicionar_item(StringName(item_id), qty)

	var seller_kind := str(row.get("seller_kind", "npc"))
	var seller_id := str(row.get("seller_id", ""))
	if seller_kind == "player" and not seller_id.is_empty():
		pending_payouts[seller_id] = int(pending_payouts.get(seller_id, 0)) + price
	# NPC: Jenny afundada (taxa da casa / sindicato)

	var sold_uid := str(row.get("item_uid", ""))
	if not sold_uid.is_empty():
		_active_item_uids.erase(sold_uid)
	row["status"] = "sold"
	row["buyer_id"] = _player_id()
	row["buyer_name"] = _player_name()
	row["sold_day"] = _current_day()
	listings[listing_id] = row
	_mirror_attr()
	listings_changed.emit()
	listing_sold.emit(listing_id, _player_name())
	return {
		"ok": true,
		"item_id": item_id,
		"qty": qty,
		"price": price,
		"name": _item_display_name(item_id),
	}


func cancel_listing(listing_id: String) -> Dictionary:
	if not listings.has(listing_id):
		return {"ok": false, "error": "nao_encontrado"}
	var row: Dictionary = listings[listing_id]
	if str(row.get("status", "")) != "active":
		return {"ok": false, "error": "inativo"}
	if str(row.get("seller_id", "")) != _player_id():
		return {"ok": false, "error": "nao_e_seu"}
	var item_id := str(row.get("item_id", ""))
	var qty := int(row.get("qty", 1))
	PlayerData.adicionar_item(StringName(item_id), qty)
	var cancel_uid := str(row.get("item_uid", ""))
	if not cancel_uid.is_empty():
		_active_item_uids.erase(cancel_uid)
	row["status"] = "cancelled"
	listings[listing_id] = row
	_mirror_attr()
	listings_changed.emit()
	listing_cancelled.emit(listing_id)
	return {"ok": true, "item_id": item_id, "qty": qty}


func summary_text() -> String:
	return "Leilão Yorknew · %d anúncios · taxa %d%% (mín %d Jenny) · payout %d" % [
		get_active_listings().size(),
		int(LISTING_FEE_RATE * 100.0),
		LISTING_FEE_MIN,
		get_pending_payout(),
	]


func _mirror_attr() -> void:
	if PlayerData == null:
		return
	PlayerData.attributes[ATTR_KEY] = salvar_dados()


func salvar_dados() -> Dictionary:
	return {
		"listings": listings.duplicate(true),
		"pending_payouts": pending_payouts.duplicate(true),
		"next_id": _next_id,
		"seeded": _seeded,
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		listings.clear()
		pending_payouts.clear()
		_next_id = 1
		_seeded = false
		_ensure_seed_listings()
		return
	var raw = dados.get("listings", {})
	listings = raw.duplicate(true) if typeof(raw) == TYPE_DICTIONARY else {}
	var pay = dados.get("pending_payouts", {})
	pending_payouts = pay.duplicate(true) if typeof(pay) == TYPE_DICTIONARY else {}
	_next_id = maxi(1, int(dados.get("next_id", 1)))
	_seeded = bool(dados.get("seeded", false))
	_ensure_seed_listings()
	listings_changed.emit()
