extends Node

## B9–B14 + live ops + rede — smoke contra APIs reais.

const NenStoneSystemScript = preload("res://scripts/systems/equipment/NenStoneSystem.gd")
const MatchmakingQueueScript = preload("res://scripts/network/MatchmakingQueue.gd")
const ContentVersionConfigScript = preload("res://scripts/core/ContentVersionConfig.gd")
const ServerStorageManagerScript = preload("res://scripts/network/ServerStorageManager.gd")

var _passed := 0
var _total := 0


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 PENDING SYSTEMS SUITE (B9–B14 / LIVE OPS / VPS)")
	print("================================================================================")
	await get_tree().process_frame
	_test_b9()
	_test_b14()
	_test_live_ops()
	_test_network()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		print("  ❌ ", label)


func _test_b9() -> void:
	print("\n[B9] Mail + Friends...")
	_ok(AssociationMailSystem != null, "AssociationMailSystem autoload")
	_ok(HunterFriendsSystem != null, "HunterFriendsSystem autoload")
	_ok(ResourceLoader.exists("res://ui/Mail/AssociationMailUI.tscn"), "AssociationMailUI.tscn")
	var pause_src := FileAccess.get_file_as_string("res://ui/PauseMenu/PauseMenuUI.gd")
	_ok("Correio" in pause_src, "PauseMenu Correio entry")


func _test_b14() -> void:
	print("\n[B14] Nen stones...")
	_ok(NenStoneSystemScript.STONES.size() >= 3, ">=3 stone types")
	if PlayerData != null:
		PlayerData.inventory["equipamentos_upgrade"] = {"adaga_zaban": 10, "colete_cacador": 10}
		PlayerData.adicionar_item(&"pedra_intensificacao", 2)
		var enc := NenStoneSystemScript.encaixar("adaga_zaban", "pedra_intensificacao")
		_ok(bool(enc.get("ok", false)), "socket at +10")
		var dup := NenStoneSystemScript.encaixar("colete_cacador", "pedra_intensificacao")
		_ok(str(dup.get("reason", "")) == "SAME_TYPE", "block same stone type twice")


func _test_live_ops() -> void:
	print("\n[Live ops]...")
	var ver := ContentVersionConfigScript.get_version_info()
	_ok(not ver.is_empty(), "get_version_info")
	var sel := FileAccess.get_file_as_string("res://ui/CharacterSelection/CharacterSelectionUI.gd")
	_ok("get_version_info" in sel, "CharacterSelection version banner")
	_ok(ContentHotReload != null, "ContentHotReload autoload")
	var sm := FileAccess.get_file_as_string("res://autoload/SaveManager.gd")
	_ok("bak.1" in sm, "rotating backups in SaveManager")


func _test_network() -> void:
	print("\n[Network VPS]...")
	_ok(MatchmakingQueueScript.list_queues().size() >= 1, "MatchmakingQueue list")
	var line := MatchmakingQueueScript.format_registry_queue_line("arena_1v1_ranked", 1, 2)
	var parsed := MatchmakingQueueScript.parse_registry_queue_line(line)
	_ok(str(parsed.get("duty_id", "")) == "arena_1v1_ranked", "QUEUE line parse")
	var storage := ServerStorageManagerScript.new("user://test_pending_server_saves/")
	var n := storage.persist_all_peers_periodic({1: {"character_id": "test_peer", "name": "T"}})
	_ok(n == 1, "persist_all_peers_periodic")
	var nm := FileAccess.get_file_as_string("res://autoload/NetworkManager.gd")
	_ok("persist_all_peers_periodic" in nm, "NetworkManager autosave hook")
