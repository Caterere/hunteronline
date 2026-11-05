class_name ConsumableBuffCatalog
extends RefCounted

# ============================================================
# Consumíveis de buff do farming open-world.
# Usáveis no inventário → StatModifier timed em PlayerData.
# ============================================================

## item_id → {nome, descricao, raridade, preco, buff:{stat,value,duration,type}}
const CATALOG: Dictionary = {
	"tonico_forca": {
		"nome": "Tônico de Intensificação",
		"descricao": "Buff de combate: +8 Força por 120s. Drop comum das farm zones.",
		"raridade": "Comum",
		"preco_compra": 180,
		"preco_venda": 70,
		"buff": {"stat": "forca", "value": 8.0, "duration": 120.0, "type": 0},
	},
	"oleo_ken": {
		"nome": "Óleo de Ken",
		"descricao": "Buff de combate: +10 Defesa por 150s. Endurece a aura superficial.",
		"raridade": "Comum",
		"preco_compra": 200,
		"preco_venda": 80,
		"buff": {"stat": "defesa", "value": 10.0, "duration": 150.0, "type": 0},
	},
	"essencia_velocidade": {
		"nome": "Essência de Velocidade",
		"descricao": "Buff de combate: +6 Velocidade por 90s.",
		"raridade": "Incomum",
		"preco_compra": 240,
		"preco_venda": 95,
		"buff": {"stat": "velocidade", "value": 6.0, "duration": 90.0, "type": 0},
	},
	"ampola_aura": {
		"nome": "Ampola de Aura",
		"descricao": "Buff de Nen: +30 Aura Máxima por 180s.",
		"raridade": "Incomum",
		"preco_compra": 280,
		"preco_venda": 110,
		"buff": {"stat": "aura_max", "value": 30.0, "duration": 180.0, "type": 0},
	},
	"elixir_cacador": {
		"nome": "Elixir do Caçador",
		"descricao": "Buff raro: +12 Força por 180s. Drop raro das Ruínas.",
		"raridade": "Raro",
		"preco_compra": 450,
		"preco_venda": 180,
		"buff": {"stat": "forca", "value": 12.0, "duration": 180.0, "type": 0},
	},
}


static func eh_buff_consumivel(item_id: Variant) -> bool:
	return CATALOG.has(str(item_id))


static func obter(item_id: Variant) -> Dictionary:
	return CATALOG.get(str(item_id), {})


static func obter_buff(item_id: Variant) -> Dictionary:
	var info: Dictionary = obter(item_id)
	return info.get("buff", {}) as Dictionary


static func ids() -> Array:
	return CATALOG.keys()


static func registrar_em_data_manager() -> void:
	if DataManager == null:
		return
	var item_script = load("res://resource/item/ItemData.gd")
	if item_script == null:
		return
	for id_str in CATALOG.keys():
		var sid := StringName(id_str)
		if DataManager.items_registry.has(sid):
			continue
		var info: Dictionary = CATALOG[id_str]
		var it = item_script.new()
		it.item_id = sid
		it.nome_item = str(info.get("nome", id_str))
		it.descricao = str(info.get("descricao", ""))
		it.tipo = ItemData.TipoItem.CONSUMAVEL
		it.raridade = str(info.get("raridade", "Comum"))
		it.preco_compra = int(info.get("preco_compra", 100))
		it.preco_venda = int(info.get("preco_venda", 50))
		it.acumulavel = true
		DataManager.items_registry[sid] = it
