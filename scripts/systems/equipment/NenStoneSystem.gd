class_name NenStoneSystem
extends RefCounted

# B14 — Pedras de Nen (1 socket no enhance +10, sem repetir tipo no mesmo item)

const MIN_ENHANCE_FOR_SOCKET := 10
const ATTR_KEY := "equipamentos_nen_stones"

const STONES := {
	"pedra_intensificacao": {
		"id": "pedra_intensificacao",
		"nome": "Pedra de Intensificação",
		"stat": &"forca",
		"value": 3.0,
	},
	"pedra_tenacidade": {
		"id": "pedra_tenacidade",
		"nome": "Pedra de Tenacidade",
		"stat": &"defesa",
		"value": 3.0,
	},
	"pedra_agilidade": {
		"id": "pedra_agilidade",
		"nome": "Pedra de Agilidade",
		"stat": &"velocidade",
		"value": 2.0,
	},
	"pedra_reserva": {
		"id": "pedra_reserva",
		"nome": "Pedra de Reserva",
		"stat": &"aura_max",
		"value": 15.0,
	},
	"pedra_precisao": {
		"id": "pedra_precisao",
		"nome": "Pedra de Precisão",
		"stat": &"dano_fisico",
		"value": 0.05,
		"percent": true,
	},
}


static func listar_pedras() -> Array:
	var out: Array = []
	for k in STONES.keys():
		out.append((STONES[k] as Dictionary).duplicate(true))
	return out


static func obter_meta(stone_id: String) -> Dictionary:
	return STONES.get(stone_id, {}).duplicate(true)


static func _upgrade_table() -> Dictionary:
	if PlayerData == null:
		return {}
	if not PlayerData.inventory.has("equipamentos_upgrade"):
		PlayerData.inventory["equipamentos_upgrade"] = {}
	return PlayerData.inventory["equipamentos_upgrade"]


static func _socket_table() -> Dictionary:
	if PlayerData == null:
		return {}
	if not PlayerData.inventory.has(ATTR_KEY):
		PlayerData.inventory[ATTR_KEY] = {}
	return PlayerData.inventory[ATTR_KEY]


static func obter_nivel_upgrade(item_id: String) -> int:
	return int(_upgrade_table().get(item_id, 0))


static func tem_socket_livre(item_id: String) -> bool:
	if obter_nivel_upgrade(item_id) < MIN_ENHANCE_FOR_SOCKET:
		return false
	return str(_socket_table().get(item_id, "")).is_empty()


static func pedra_equipada(item_id: String) -> String:
	return str(_socket_table().get(item_id, ""))


static func pode_encaixar(item_id: String, stone_id: String) -> Dictionary:
	stone_id = stone_id.strip_edges()
	if not STONES.has(stone_id):
		return {"ok": false, "reason": "UNKNOWN_STONE"}
	if obter_nivel_upgrade(item_id) < MIN_ENHANCE_FOR_SOCKET:
		return {"ok": false, "reason": "NEED_PLUS_10"}
	var atual := pedra_equipada(item_id)
	if not atual.is_empty():
		return {"ok": false, "reason": "SOCKET_FULL"}
	for other_id in _socket_table().keys():
		if str(other_id) != item_id and str(_socket_table()[other_id]) == stone_id:
			return {"ok": false, "reason": "SAME_TYPE"}
	if not PlayerData.tem_item(StringName(stone_id)):
		return {"ok": false, "reason": "NO_STONE_ITEM"}
	return {"ok": true}


static func encaixar(item_id: String, stone_id: String) -> Dictionary:
	var check := pode_encaixar(item_id, stone_id)
	if not bool(check.get("ok", false)):
		return check
	if not PlayerData.remover_item(StringName(stone_id), 1):
		return {"ok": false, "reason": "REMOVE_FAILED"}
	_socket_table()[item_id] = stone_id
	_aplicar_modificador(item_id, stone_id)
	return {"ok": true, "stone_id": stone_id}


static func remover(item_id: String) -> Dictionary:
	var sid := pedra_equipada(item_id)
	if sid.is_empty():
		return {"ok": false, "reason": "EMPTY"}
	_remover_modificador(item_id)
	_socket_table().erase(item_id)
	PlayerData.adicionar_item(StringName(sid), 1)
	return {"ok": true, "stone_id": sid}


static func _mod_id(item_id: String) -> StringName:
	return StringName("nen_stone_%s" % item_id)


static func _aplicar_modificador(item_id: String, stone_id: String) -> void:
	var meta: Dictionary = obter_meta(stone_id)
	if meta.is_empty():
		return
	_remover_modificador(item_id)
	var mod_type := StatModifier.Type.FLAT
	var val := float(meta.get("value", 0.0))
	if bool(meta.get("percent", false)):
		mod_type = StatModifier.Type.PERCENTAGE
	PlayerData.adicionar_modificador(StatModifier.new(
		_mod_id(item_id),
		meta.get("stat", &"forca"),
		mod_type,
		val,
		-1.0,
		"nen_stone_%s" % item_id
	))


static func _remover_modificador(item_id: String) -> void:
	PlayerData.remover_modificador(_mod_id(item_id))


static func salvar_dados() -> Dictionary:
	return _socket_table().duplicate(true)


static func carregar_dados(dados: Dictionary) -> void:
	if PlayerData == null:
		return
	PlayerData.inventory[ATTR_KEY] = dados.duplicate(true)
	for item_id in dados.keys():
		var stone_id := str(dados[item_id])
		if STONES.has(stone_id):
			_aplicar_modificador(str(item_id), stone_id)

