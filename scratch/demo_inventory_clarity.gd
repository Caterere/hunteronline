extends SceneTree

# Demo: prova textual do inventário com stats/lore


func _initialize() -> void:
	# Autoloads já estão no root neste ponto do ciclo SceneTree
	var pd = root.get_node_or_null("PlayerData")
	var dm = root.get_node_or_null("DataManager")
	if pd == null or dm == null:
		print("FAIL: autoloads missing pd=%s dm=%s" % [pd != null, dm != null])
		quit(1)
		return

	# Força init de itens se ainda vazio
	if dm.get_all_items().is_empty() and dm.has_method("_inicializar_itens_canônicos"):
		dm._inicializar_itens_canônicos()

	var kit = load("res://ui/common/ItemExplainKit.gd")
	pd.inventory.clear()
	pd.adicionar_item("lamina_cacador", 1)
	pd.adicionar_item("pocao_vida", 3)
	pd.adicionar_item("traje_nen_concentrado", 1)

	print("=== INVENTORY CLARITY DEMO ===")
	print("DataManager items: %d" % dm.get_all_items().size())
	for id in ["lamina_cacador", "pocao_vida", "traje_nen_concentrado"]:
		var q := int(pd.inventory.get(id, 0))
		var item = dm.get_item(StringName(id))
		print("--- id=%s resolved=%s q=%d ---" % [id, item != null, q])
		if item != null:
			print("nome=", item.nome_item)
		var txt: String = str(kit.call("formatar_detalhes", id, q, item))
		print(txt)
	print("=== DEMO OK ===")
	quit(0)
