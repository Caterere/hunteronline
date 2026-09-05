class_name CollectionManagerClass
extends Node

# ============================================================
# HUNTER ONLINE — COLLECTION MANAGER (FASE L)
# ============================================================
#
# Gerenciador central de Coleções & Códex do Caçador:
# - Rastreia descobertas e domínio de 8 categorias canônicas:
#   * Hatsus descobertos e dominados
#   * Equipamentos e Relíquias únicas
#   * Títulos de Caçador
#   * Conquistas & Marcos Históricos
#   * NPCs importantes catalogados
#   * Regiões e Territórios explorados
#   * Chefes derrotados
#   * Segredos e Locais Ocultos desvelados (sem GPS)
# ============================================================

signal item_coletado(categoria: String, item_id: String)
signal colecao_marco_atingido(categoria: String, total: int)

enum Category {
	HATSU,
	EQUIPMENT,
	TITLES,
	ACHIEVEMENTS,
	NPCS,
	REGIONS,
	BOSSES,
	SECRETS
}

var collections: Dictionary = {
	"hatsu": [],
	"equipment": [],
	"titles": [],
	"achievements": [],
	"npcs": [],
	"regions": [],
	"bosses": [],
	"secrets": []
}


func _ready() -> void:
	add_to_group("collection_manager")
	print("=================================")
	print("[CollectionManager] CÓDEX DE COLEÇÕES DO CAÇADOR ATIVO (FASE L)")
	print("=================================")


func register_discovery(category: String, item_id: String) -> bool:
	var cat = category.strip_edges().to_lower()
	var it = item_id.strip_edges().to_lower()
	if not collections.has(cat):
		collections[cat] = []

	var arr: Array = collections[cat]
	if arr.has(it):
		return false

	arr.append(it)
	item_coletado.emit(cat, it)

	var total = arr.size()
	if total % 5 == 0:
		colecao_marco_atingido.emit(cat, total)

	print("[CollectionManager] 📖 Nova descoberta adicionada ao Códex [%s]: '%s' (Total: %d)" % [
		cat.to_upper(), it, total
	])
	return true


func has_discovered(category: String, item_id: String) -> bool:
	var cat = category.strip_edges().to_lower()
	var it = item_id.strip_edges().to_lower()
	if collections.has(cat):
		return collections[cat].has(it)
	return false


func get_category_count(category: String) -> int:
	var cat = category.strip_edges().to_lower()
	if collections.has(cat):
		return collections[cat].size()
	return 0


func get_all_items(category: String) -> Array:
	var cat = category.strip_edges().to_lower()
	if collections.has(cat):
		return collections[cat].duplicate()
	return []


func get_total_discoveries() -> int:
	var tot = 0
	for cat in collections.keys():
		tot += (collections[cat] as Array).size()
	return tot


# ============================================================
# PERSISTÊNCIA SERIALIZÁVEL
# ============================================================

func serializar() -> Dictionary:
	var data: Dictionary = {}
	for cat in collections.keys():
		data[cat] = (collections[cat] as Array).duplicate()
	return data


func deserializar(data: Dictionary) -> void:
	for cat in collections.keys():
		if data.has(cat) and data[cat] is Array:
			collections[cat].clear()
			for it in data[cat]:
				collections[cat].append(str(it))
