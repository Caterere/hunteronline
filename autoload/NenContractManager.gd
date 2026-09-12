extends Node

# ============================================================
# HUNTER ONLINE — NEN CONTRACTS (A6 / HATSU BIBLE)
# ============================================================
# Juramentos cooperativos entre caçadores da mesma guilda.
# Cosmético/social + leve buff temporário (sem power creep permanente).
# ============================================================

signal contract_signed(contract_id: String)
signal contract_fulfilled(contract_id: String)
signal contract_broken(contract_id: String)

const ATTR_KEY := "nen_contracts"
const MAX_ACTIVE := 3

## contract_id → Dictionary
var contracts: Dictionary = {}
var _next_id: int = 1


func _ready() -> void:
	print("[NenContractManager] Contratos de Nen ativos")


func reset_for_tests() -> void:
	contracts.clear()
	_next_id = 1
	_mirror()


func _player_id() -> String:
	if PlayerData == null:
		return "local_hunter"
	var cid := str(PlayerData.character_id).strip_edges()
	return cid if not cid.is_empty() else "local_hunter"


func active_count_for(player_id: String = "") -> int:
	var pid := player_id if not player_id.is_empty() else _player_id()
	var n := 0
	for cid in contracts.keys():
		var c: Dictionary = contracts[cid]
		if str(c.get("status", "")) != "active":
			continue
		if str(c.get("a_id", "")) == pid or str(c.get("b_id", "")) == pid:
			n += 1
	return n


func propose_contract(partner_id: String, oath: String, duration_days: int = 7, buff_id: String = "ten_sync") -> Dictionary:
	partner_id = partner_id.strip_edges()
	oath = oath.strip_edges()
	if partner_id.is_empty() or partner_id == _player_id():
		return {"ok": false, "error": "parceiro_invalido"}
	if oath.is_empty():
		return {"ok": false, "error": "juramento_vazio"}
	if active_count_for() >= MAX_ACTIVE:
		return {"ok": false, "error": "limite"}
	# Prefer same guild (soft requirement)
	var same_guild := false
	if HunterGuildSystem != null:
		var g: Dictionary = HunterGuildSystem.get_player_guild()
		for m in g.get("members", []):
			if typeof(m) == TYPE_DICTIONARY and str(m.get("id", "")) == partner_id:
				same_guild = true
				break
	var cid := "nen_%d" % _next_id
	_next_id += 1
	contracts[cid] = {
		"id": cid,
		"a_id": _player_id(),
		"b_id": partner_id,
		"oath": oath,
		"buff_id": buff_id,
		"duration_days": maxi(1, duration_days),
		"start_day": _day(),
		"status": "active",
		"same_guild": same_guild,
		"cosmetic_title": "🤝 Jurado de Nen",
	}
	_grant_title()
	_mirror()
	contract_signed.emit(cid)
	return {"ok": true, "contract": (contracts[cid] as Dictionary).duplicate(true)}


func fulfill_contract(contract_id: String) -> Dictionary:
	if not contracts.has(contract_id):
		return {"ok": false, "error": "nao_encontrado"}
	var c: Dictionary = contracts[contract_id]
	if str(c.get("status", "")) != "active":
		return {"ok": false, "error": "inativo"}
	c["status"] = "fulfilled"
	c["end_day"] = _day()
	contracts[contract_id] = c
	_mirror()
	contract_fulfilled.emit(contract_id)
	return {"ok": true, "title": str(c.get("cosmetic_title", ""))}


func break_contract(contract_id: String) -> Dictionary:
	if not contracts.has(contract_id):
		return {"ok": false, "error": "nao_encontrado"}
	var c: Dictionary = contracts[contract_id]
	if str(c.get("status", "")) != "active":
		return {"ok": false, "error": "inativo"}
	c["status"] = "broken"
	c["end_day"] = _day()
	contracts[contract_id] = c
	_mirror()
	contract_broken.emit(contract_id)
	return {"ok": true}


func tick_day() -> void:
	var day := _day()
	for cid in contracts.keys():
		var c: Dictionary = contracts[cid]
		if str(c.get("status", "")) != "active":
			continue
		var start := int(c.get("start_day", day))
		var dur := int(c.get("duration_days", 7))
		if day - start >= dur:
			c["status"] = "fulfilled"
			c["end_day"] = day
			contracts[cid] = c
			contract_fulfilled.emit(str(cid))
	_mirror()


func list_active() -> Array:
	var out: Array = []
	for cid in contracts.keys():
		var c: Dictionary = contracts[cid]
		if str(c.get("status", "")) == "active":
			out.append((c as Dictionary).duplicate(true))
	return out


func summary_text() -> String:
	return "Contratos Nen ativos: %d/%d" % [active_count_for(), MAX_ACTIVE]


func _grant_title() -> void:
	if PlayerData != null and PlayerData.has_method("desbloquear_titulo"):
		PlayerData.desbloquear_titulo("🤝 Jurado de Nen")


func _day() -> int:
	if TimeManager != null:
		return maxi(1, int(TimeManager.current_day))
	return 1


func _mirror() -> void:
	if PlayerData != null:
		PlayerData.attributes[ATTR_KEY] = salvar_dados()


func salvar_dados() -> Dictionary:
	return {"contracts": contracts.duplicate(true), "next_id": _next_id}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		contracts.clear()
		_next_id = 1
		return
	var raw = dados.get("contracts", {})
	contracts = raw.duplicate(true) if typeof(raw) == TYPE_DICTIONARY else {}
	_next_id = maxi(1, int(dados.get("next_id", 1)))
