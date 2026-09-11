extends Node

# ============================================================
# HUNTER ONLINE — S1 YORKNEW AUCTION HOUSE SUITE
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 S1 YORKNEW AUCTION HOUSE SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_fee_and_seeds()
	_test_list_buy_cancel()
	_test_payout_flow()
	_test_ui_and_wiring()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	if not _failures.is_empty():
		for f in _failures:
			print("   ❌ ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)


func _test_fee_and_seeds() -> void:
	print("\n[1] Taxa + seeds NPC...")
	AuctionHouse.reset_for_tests()
	_ok(AuctionHouse.LISTING_FEE_RATE == 0.05, "Taxa 5%")
	_ok(AuctionHouse.calc_listing_fee(1000) == 50, "Fee 1000 → 50")
	_ok(AuctionHouse.calc_listing_fee(100) == 25, "Fee mínima 25")
	var active: Array = AuctionHouse.get_active_listings()
	_ok(active.size() >= 3, "≥3 anúncios semente (%d)" % active.size())
	var has_npc := false
	for row in active:
		if str(row.get("seller_kind", "")) == "npc":
			has_npc = true
			break
	_ok(has_npc, "Seeds NPC presentes")


func _test_list_buy_cancel() -> void:
	print("\n[2] List / buy NPC / cancel...")
	AuctionHouse.reset_for_tests()
	if str(PlayerData.character_id).strip_edges().is_empty():
		PlayerData.character_id = "test_seller_s1"
	PlayerData.nome_personagem = "Gon Auction"
	PlayerData.inventory.clear()
	PlayerData.adicionar_item(&"minerio_aco", 10)
	Economy.definir_gold(5000)

	var before_gold := Economy.obter_gold()
	var before_qty := PlayerData.obter_item_quantidade(&"minerio_aco")
	var listed: Dictionary = AuctionHouse.list_item("minerio_aco", 2, 400)
	_ok(bool(listed.get("ok", false)), "list_item ok")
	var fee := int(listed.get("fee", 0))
	_ok(fee == AuctionHouse.calc_listing_fee(400), "Fee cobrada corretamente")
	_ok(Economy.obter_gold() == before_gold - fee, "Jenny debitada na taxa")
	_ok(PlayerData.obter_item_quantidade(&"minerio_aco") == before_qty - 2, "Item em escrow")
	_ok(AuctionHouse.count_my_active() == 1, "1 anúncio do jogador")

	var npc_id := ""
	for row in AuctionHouse.get_active_listings():
		if str(row.get("seller_kind", "")) == "npc":
			npc_id = str(row.get("listing_id", ""))
			break
	_ok(not npc_id.is_empty(), "Encontrou listing NPC")
	var npc_price := int(AuctionHouse.listings[npc_id].get("price", 0))
	var gold_pre_buy := Economy.obter_gold()
	var buy_npc: Dictionary = AuctionHouse.buy_listing(npc_id)
	_ok(bool(buy_npc.get("ok", false)), "buy_listing NPC ok")
	_ok(Economy.obter_gold() == gold_pre_buy - npc_price, "Jenny paga no buy NPC")
	_ok(PlayerData.tem_item(StringName(str(buy_npc.get("item_id", ""))), int(buy_npc.get("qty", 1))), "Item NPC no inventário")

	var my_id := str(AuctionHouse.get_my_listings()[0].get("listing_id", ""))
	var self_buy: Dictionary = AuctionHouse.buy_listing(my_id)
	_ok(not bool(self_buy.get("ok", false)), "Bloqueia compra do próprio anúncio")
	_ok(str(self_buy.get("error", "")) == "proprio_anuncio", "Erro proprio_anuncio")

	var qty_before_cancel := PlayerData.obter_item_quantidade(&"minerio_aco")
	var cancelled: Dictionary = AuctionHouse.cancel_listing(my_id)
	_ok(bool(cancelled.get("ok", false)), "cancel_listing ok")
	_ok(PlayerData.obter_item_quantidade(&"minerio_aco") == qty_before_cancel + 2, "Escrow devolvido no cancel")


func _test_payout_flow() -> void:
	print("\n[3] Payout seller→buyer (simulado)...")
	AuctionHouse.reset_for_tests()
	PlayerData.character_id = "seller_alpha"
	PlayerData.nome_personagem = "Seller Alpha"
	PlayerData.inventory.clear()
	PlayerData.adicionar_item(&"cristal_aura", 1)
	Economy.definir_gold(3000)

	var listed: Dictionary = AuctionHouse.list_item("cristal_aura", 1, 1000)
	_ok(bool(listed.get("ok", false)), "Seller listou cristal")
	var lid := str(listed.get("listing", {}).get("listing_id", ""))
	if lid.is_empty():
		# fallback se retorno usar outra chave
		var mine: Array = AuctionHouse.get_my_listings()
		if not mine.is_empty():
			lid = str(mine[0].get("listing_id", ""))
	_ok(not lid.is_empty(), "listing_id resolvido")

	PlayerData.character_id = "buyer_beta"
	PlayerData.nome_personagem = "Buyer Beta"
	Economy.definir_gold(5000)
	var buy: Dictionary = AuctionHouse.buy_listing(lid)
	_ok(bool(buy.get("ok", false)), "Buyer comprou listing")
	_ok(AuctionHouse.get_pending_payout("seller_alpha") == 1000, "Payout pendente 1000 para seller")
	_ok(AuctionHouse.get_pending_payout("buyer_beta") == 0, "Buyer sem payout")

	PlayerData.character_id = "seller_alpha"
	var gold_before := Economy.obter_gold()
	var collected: Dictionary = AuctionHouse.collect_payout()
	_ok(bool(collected.get("ok", false)), "collect_payout ok")
	_ok(int(collected.get("amount", 0)) == 1000, "Amount 1000")
	_ok(Economy.obter_gold() == gold_before + 1000, "Jenny creditada no collect")
	_ok(AuctionHouse.get_pending_payout("seller_alpha") == 0, "Payout zerado")

	var blob: Dictionary = AuctionHouse.salvar_dados()
	AuctionHouse.reset_for_tests()
	AuctionHouse.carregar_dados(blob)
	_ok(typeof(blob.get("listings", null)) == TYPE_DICTIONARY, "salvar_dados tem listings")


func _test_ui_and_wiring() -> void:
	print("\n[4] UI + mapa + docs...")
	var UiScript = load("res://ui/Auction/AuctionHouseUI.gd")
	_ok(UiScript != null, "AuctionHouseUI.gd carrega")
	var ui = UiScript.new()
	ui._build_ui()
	_ok(ui.lbl_status != null, "UI tem lbl_status")
	_ok(ui.browse_list != null, "UI tem browse_list")
	_ok(ui.sell_list != null, "UI tem sell_list")
	_ok(ui.mine_list != null, "UI tem mine_list")
	ui.queue_free()

	var LeiScript = load("res://entities/npc/leiloeiro/Leiloeiro.gd")
	_ok(LeiScript != null, "Leiloeiro.gd carrega")
	var map_src := FileAccess.get_file_as_string("res://world/maps/YorknewCityMap.gd")
	_ok("Leiloeiro" in map_src, "Yorknew spawna Leiloeiro")
	var proj := FileAccess.get_file_as_string("res://project.godot")
	_ok("AuctionHouse=" in proj, "Autoload AuctionHouse registrado")
	var save_src := FileAccess.get_file_as_string("res://autoload/SaveManager.gd")
	_ok("auction_data" in save_src, "SaveManager persiste auction_data")
	var docs := FileAccess.get_file_as_string("res://docs/multiplayer/MULTIPLAYER_GAMEPLAY.md")
	_ok("Leilão de Yorknew" in docs and "IMPLEMENTED" in docs, "Docs marcam Leilão IMPLEMENTED")
