extends Node

## Inventário: stacks int + metadados Dictionary no mesmo map
## godot --headless --path . res://scratch/test_inventory_meta_keys_suite.tscn

var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== inventory meta keys ===")
	_test_obter_quantidade_ignora_meta()
	_test_hunter_menu_source()
	await _test_menu_atualiza_sem_crash()
	print("=== RESULT: %d pass / %d fail ===" % [_ok, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✅ ", msg)
	else:
		_fail += 1
		print("  ❌ ", msg)


func _test_obter_quantidade_ignora_meta() -> void:
	PlayerData.inventory.clear()
	PlayerData.inventory[&"pedra_aura"] = 3
	PlayerData.inventory["equipamentos_upgrade"] = {"adaga_zaban": 2}
	PlayerData.inventory["equipamentos_nen_stones"] = {"slot_a": []}
	_assert(PlayerData.obter_item_quantidade(&"pedra_aura") == 3, "stack pedra_aura = 3")
	_assert(PlayerData.obter_item_quantidade(&"equipamentos_upgrade") == 0, "meta upgrade → 0")
	_assert(PlayerData.obter_item_quantidade(&"equipamentos_nen_stones") == 0, "meta stones → 0")
	# adicionar_item em chave meta não deve corromper o dict
	PlayerData.adicionar_item(&"equipamentos_upgrade", 1)
	_assert(PlayerData.inventory["equipamentos_upgrade"] is Dictionary, "meta upgrade intacto após adicionar_item")
	_assert(PlayerData.inventory["equipamentos_upgrade"].has("adaga_zaban"), "conteúdo meta preservado")


func _test_hunter_menu_source() -> void:
	var src := FileAccess.get_file_as_string("res://ui/HunterMenu/HunterMenuUI.gd")
	_assert("typeof(raw) != TYPE_INT" in src, "HunterMenuUI filtra meta no inventário")
	var auc := FileAccess.get_file_as_string("res://ui/Auction/AuctionHouseUI.gd")
	_assert("typeof(raw) != TYPE_INT" in auc, "Auction filtra meta")
	var shop := FileAccess.get_file_as_string("res://ui/Shop/ShopUI.gd")
	_assert("typeof(raw) != TYPE_INT" in shop, "Shop filtra meta")


func _test_menu_atualiza_sem_crash() -> void:
	PlayerData.inventory.clear()
	PlayerData.inventory[&"pedra_aura"] = 2
	PlayerData.inventory["equipamentos_upgrade"] = {"x": 1}
	var menu = load("res://ui/HunterMenu/HunterMenuUI.gd").new()
	add_child(menu)
	await get_tree().process_frame
	# Constrói lista mínima sem abrir UI completa: só a função se o container existir
	if menu.has_method("_atualizar_conteudo_inventario"):
		# Garante container para não early-return
		if menu.get("inv_list_container") == null:
			menu.set("inv_list_container", VBoxContainer.new())
			menu.add_child(menu.inv_list_container)
		menu._atualizar_conteudo_inventario()
		_assert(true, "_atualizar_conteudo_inventario sem crash com meta")
		var kids := 0
		for c in menu.inv_list_container.get_children():
			if not c.is_queued_for_deletion():
				kids += 1
		_assert(kids >= 1, "listou ao menos 1 stack (pedra_aura)")
	else:
		_assert(false, "método inventário ausente")
	menu.queue_free()
