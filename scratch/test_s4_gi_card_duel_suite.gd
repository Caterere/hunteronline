extends Node

# ============================================================
# HUNTER ONLINE — S4 GREED ISLAND CARD DUEL SUITE
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 S4 GREED ISLAND CARD DUEL SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_catalog()
	_test_duel_flow()
	_test_ui_wiring()
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


func _test_catalog() -> void:
	print("\n[1] Catálogo duelável...")
	var cats: Array = GreedIslandCardCatalog.duel_catalog()
	_ok(cats.size() >= 20, "≥20 cartas dueláveis (%d)" % cats.size())
	_ok(cats.size() <= 40, "≤40 cartas (subset) (%d)" % cats.size())
	var first: Dictionary = cats[0]
	_ok(first.has("id") and first.has("atk") and first.has("def") and first.has("kind"), "Campos de combate presentes")
	var binder: Array = GreedIslandCardCatalog.binder_catalog()
	_ok(binder.size() == cats.size(), "Binder catalog alinhado ao duel catalog")
	var npc: Array = GreedIslandCardCatalog.npc_deck("antokiba")
	_ok(npc.size() == 8, "NPC deck Antokiba = 8 (%d)" % npc.size())
	var razor: Array = GreedIslandCardCatalog.npc_deck("razor")
	_ok(razor.size() == 8, "NPC deck Razor = 8")
	var by := GreedIslandCardCatalog.by_id("carta_000")
	_ok(str(by.get("nome", "")).length() > 0, "by_id carta_000 ok")


func _test_duel_flow() -> void:
	print("\n[2] CardDuelSystem fluxo...")
	var duel := CardDuelSystem.new()
	var res: Dictionary = duel.start_from_inventory("antokiba")
	_ok(bool(res.get("ok", false)), "start_from_inventory ok")
	_ok(int(res.get("player_hp", 0)) == CardDuelSystem.STARTING_HP, "HP inicial player")
	_ok(duel.can_play(), "can_play no turno do player")
	var hand: Array = res.get("hand", [])
	_ok(hand.size() == CardDuelSystem.HAND_SIZE, "Mão inicial = HAND_SIZE")

	var turns := 0
	while duel.can_play() and turns < 30:
		var play: Dictionary = duel.play_card_at(0)
		_ok(bool(play.get("ok", false)), "play_card_at ok (t%d)" % turns)
		turns += 1
		if bool(play.get("finished", false)):
			break
	var snap: Dictionary = duel.snapshot()
	_ok(str(snap.get("winner", "")).length() > 0, "Duelo termina com winner")
	_ok(str(snap.get("winner", "")) in ["player", "enemy", "draw"], "Winner válido")

	# Jogada inválida fora de turno
	var bad: Dictionary = duel.play_card_at(0)
	_ok(not bool(bad.get("ok", false)), "Recusa jogada após fim")


func _test_ui_wiring() -> void:
	print("\n[3] UI + mapa + docs...")
	var UiScript = load("res://ui/GreedIsland/CardDuelUI.gd")
	_ok(UiScript != null, "CardDuelUI.gd carrega")
	var ui = UiScript.new()
	add_child(ui)
	await get_tree().process_frame
	ui.abrir("antokiba")
	_ok(ui.visible, "UI abre")
	_ok(ui.hand_box != null and ui.hand_box.get_child_count() > 0, "Mão renderizada")
	ui.fechar()
	_ok(not ui.visible, "UI fecha")
	ui.queue_free()

	var AntScript = load("res://entities/npc/antokiba/AntokibaDuelBoard.gd")
	_ok(AntScript != null, "AntokibaDuelBoard.gd carrega")
	var map_src := FileAccess.get_file_as_string("res://world/maps/GreedIslandMap.gd")
	_ok("AntokibaDuelBoard" in map_src, "GreedIslandMap usa AntokibaDuelBoard")
	var binder_src := FileAccess.get_file_as_string("res://ui/GreedIslandBinder/GreedIslandBinderUI.gd")
	_ok("GreedIslandCardCatalog" in binder_src, "Binder usa catálogo SSOT")
	var docs := FileAccess.get_file_as_string("res://docs/multiplayer/MULTIPLAYER_GAMEPLAY.md")
	_ok("Duelo de Cartas" in docs and "IMPLEMENTED" in docs, "Docs marcam duelo IMPLEMENTED")
