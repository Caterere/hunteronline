extends Node

const GuildHallUIScript = preload("res://ui/Guild/GuildHallUI.gd")

var _passed := 0
var _total := 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 A6 HUNTER GUILDS + NEN CONTRACTS SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_guilds()
	_test_contracts()
	await _test_ui_docs()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
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


func _test_guilds() -> void:
	print("\n[1] HunterGuildSystem...")
	HunterGuildSystem.reset_for_tests()
	PlayerData.character_id = "hunter_alpha"
	PlayerData.nome_personagem = "Alpha"
	Economy.definir_gold(20000)

	var created: Dictionary = HunterGuildSystem.create_guild("Aranhas Livres", "ARAN")
	_ok(bool(created.get("ok", false)), "create_guild ok")
	_ok(HunterGuildSystem.get_player_guild_id().begins_with("guild_"), "player em guilda")
	_ok(Economy.obter_gold() == 20000 - HunterGuildSystem.CREATE_COST, "taxa de criação cobrada")

	var inv: Dictionary = HunterGuildSystem.invite_member("hunter_beta", "Beta")
	_ok(bool(inv.get("ok", false)), "invite_member ok")
	_ok(int(inv.get("members", 0)) == 2, "2 membros")

	var dep: Dictionary = HunterGuildSystem.deposit_bank(1000)
	_ok(bool(dep.get("ok", false)), "deposit_bank ok")
	_ok(int(HunterGuildSystem.get_player_guild().get("bank_jenny", 0)) == 1000, "bank 1000")

	var wd: Dictionary = HunterGuildSystem.withdraw_bank(400)
	_ok(bool(wd.get("ok", false)), "withdraw_bank ok")
	_ok(int(HunterGuildSystem.get_player_guild().get("bank_jenny", 0)) == 600, "bank 600")

	var kick: Dictionary = HunterGuildSystem.kick_member("hunter_beta")
	_ok(bool(kick.get("ok", false)), "kick_member ok")
	_ok(int(kick.get("members", 0)) == 1, "1 membro após kick")

	for i in range(HunterGuildSystem.MAX_MEMBERS - 1):
		HunterGuildSystem.invite_member("m%d" % i, "M%d" % i)
	var full: Dictionary = HunterGuildSystem.invite_member("overflow", "Overflow")
	_ok(not bool(full.get("ok", false)), "recusa além do cap 20")
	_ok(str(full.get("error", "")) == "cheia", "erro cheia")


func _test_contracts() -> void:
	print("\n[2] NenContractManager...")
	NenContractManager.reset_for_tests()
	PlayerData.character_id = "hunter_alpha"
	var prop: Dictionary = NenContractManager.propose_contract("hunter_beta", "Protegeremos um ao outro em raids", 7)
	_ok(bool(prop.get("ok", false)), "propose_contract ok")
	_ok(NenContractManager.active_count_for() == 1, "1 contrato ativo")
	_ok(NenContractManager.list_active().size() == 1, "list_active size 1")
	var cid := str(prop.get("contract", {}).get("id", ""))
	_ok(not cid.is_empty(), "contract id")
	var fulfilled: Dictionary = NenContractManager.fulfill_contract(cid)
	_ok(bool(fulfilled.get("ok", false)), "fulfill_contract ok")
	_ok(NenContractManager.active_count_for() == 0, "0 ativos após fulfill")

	var c2: Dictionary = NenContractManager.propose_contract("hunter_gamma", "Caça conjunta Blacklist", 3)
	_ok(bool(c2.get("ok", false)), "segundo contrato ok")
	var broken: Dictionary = NenContractManager.break_contract(str(c2.get("contract", {}).get("id", "")))
	_ok(bool(broken.get("ok", false)), "break_contract ok")

	for i in range(NenContractManager.MAX_ACTIVE):
		NenContractManager.propose_contract("p%d" % i, "Juramento %d" % i)
	var over: Dictionary = NenContractManager.propose_contract("overflow", "Extra")
	_ok(not bool(over.get("ok", false)), "recusa acima do limite")


func _test_ui_docs() -> void:
	print("\n[3] UI + docs + save...")
	_ok(GuildHallUIScript != null, "GuildHallUI carrega")
	var ui = GuildHallUIScript.new()
	add_child(ui)
	await get_tree().process_frame
	ui.abrir()
	_ok(ui.visible, "UI abre")
	ui.fechar()
	_ok(not ui.visible, "UI fecha")
	ui.queue_free()

	var proj := FileAccess.get_file_as_string("res://project.godot")
	_ok("HunterGuildSystem=" in proj, "autoload guild")
	_ok("NenContractManager=" in proj, "autoload contracts")
	var save_src := FileAccess.get_file_as_string("res://autoload/SaveManager.gd")
	_ok("guild_data" in save_src and "nen_contract_data" in save_src, "SaveManager persiste A6")
	var docs := FileAccess.get_file_as_string("res://docs/multiplayer/MULTIPLAYER_GAMEPLAY.md")
	_ok("Guildas de Caçadores" in docs and "IMPLEMENTED" in docs, "Docs marcam guildas IMPLEMENTED")
	_ok(FileAccess.file_exists("res://autoload/NenContractManager.gd"), "NenContractManager arquivo existe")
