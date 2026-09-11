extends Node2D

# ============================================================
# HUNTER ONLINE — TEST SUITE: PREREQ-1 NetworkProtocol binary
# ============================================================

var _ok: int = 0
var _total: int = 0
var _pass: bool = true


func _ready() -> void:
	print("================================================================================")
	print("🚀 SUÍTE PREREQ-1: NETWORKPROTOCOL BINARY SNAPSHOTS")
	print("================================================================================")
	await get_tree().process_frame
	_run()
	print("--------------------------------------------------------------------------------")
	print("RESULTADO: %d/%d" % [_ok, _total])
	if _pass:
		print("✅ PREREQ-1 BINARY NETWORKPROTOCOL SUITE PASSED")
		get_tree().quit(0)
	else:
		print("❌ PREREQ-1 BINARY NETWORKPROTOCOL SUITE FAILED")
		get_tree().quit(1)


func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_total += 1
	if cond:
		_ok += 1
		print("  ✅ [PASS] %s" % ok_msg)
	else:
		_pass = false
		print("  ❌ [FAIL] %s" % fail_msg)


func _sample_snapshot(n_players: int = 8, n_enemies: int = 12) -> Dictionary:
	var players: Array = []
	for i in range(n_players):
		players.append({
			"id": 1000 + i,
			"px": 120.5 + i * 10.0,
			"py": -40.2 + i * 3.0,
			"vx": 1.5,
			"vy": -0.5,
			"fx": 1.0,
			"fy": 0.0,
			"hp": 80 + i,
			"hp_max": 100,
			"aura": 55.5,
			"nen": "TEN" if i % 2 == 0 else "REN",
			"dead": false
		})
	var enemies: Array = []
	for i in range(n_enemies):
		enemies.append({
			"id": 2000 + i,
			"enemy_id": "slime",
			"name": "Slime %d" % i,
			"px": i * 16.0,
			"py": i * 8.0,
			"vx": 0.0,
			"vy": 0.2,
			"hp": 30,
			"hp_max": 30,
			"state": "chase",
			"boss": i == 0
		})
	return {
		"tick": 12345,
		"ts": 999001,
		"full": true,
		"players": players,
		"enemies": enemies,
		"removed_players": [9, 11],
		"removed_enemies": [77]
	}


func _run() -> void:
	print("\n[1] Player state binary roundtrip")
	var packed: PackedByteArray = NetworkProtocol.pack_player_state_binary(
		42, Vector2(10.5, -3.2), Vector2(1.0, 0.0), Vector2(0.0, 1.0), 77, 12.3, "GYO"
	)
	_check(packed.size() > 20, "Player binary payload não-vazio (%d B)" % packed.size(), "Payload vazio")
	var up: Dictionary = NetworkProtocol.unpack_player_state_binary(packed)
	_check(int(up.get("id", -1)) == 42, "net_id roundtrip", "id=%s" % str(up.get("id")))
	_check(is_equal_approx(float(up.get("px", 0.0)), 10.5), "px roundtrip 10.5", "px=%s" % str(up.get("px")))
	_check(int(up.get("hp", 0)) == 77, "hp roundtrip", "hp=%s" % str(up.get("hp")))
	_check(str(up.get("nen", "")) == "GYO", "nen roundtrip", "nen=%s" % str(up.get("nen")))

	print("\n[2] World snapshot binary roundtrip")
	var snap := _sample_snapshot()
	var bin: PackedByteArray = NetworkProtocol.pack_world_snapshot(snap)
	_check(NetworkProtocol.is_world_snapshot_binary(bin), "Magic HOS1 detectado", "Magic inválido")
	var decoded: Dictionary = NetworkProtocol.unpack_world_snapshot(bin)
	_check(int(decoded.get("tick", 0)) == 12345, "tick roundtrip", "tick=%s" % str(decoded.get("tick")))
	_check(bool(decoded.get("full", false)), "flag full preservada", "full missing")
	_check((decoded.get("players", []) as Array).size() == 8, "8 players decodificados", "players=%s" % str((decoded.get("players", []) as Array).size()))
	_check((decoded.get("enemies", []) as Array).size() == 12, "12 enemies decodificados", "enemies size fail")
	_check((decoded.get("removed_players", []) as Array).has(9), "removed_players preservado", "removed players fail")
	var p0: Dictionary = (decoded.get("players", []) as Array)[0]
	_check(int(p0.get("id", 0)) == 1000, "player[0].id", "id fail")
	_check(is_equal_approx(float(p0.get("px", 0.0)), 120.5), "player[0].px fixed-point", "px=%s" % str(p0.get("px")))

	print("\n[3] Size vs var_to_bytes(dict)")
	var sizes: Dictionary = NetworkProtocol.measure_snapshot_sizes(snap)
	print("    dict=%d B | binary=%d B | ratio=%.2f | saved=%d B" % [
		int(sizes.get("dict_size", 0)),
		int(sizes.get("binary_size", 0)),
		float(sizes.get("ratio", 1.0)),
		int(sizes.get("saved_bytes", 0))
	])
	_check(int(sizes.get("binary_size", 999999)) < int(sizes.get("dict_size", 0)),
		"Binário menor que var_to_bytes(dict)",
		"Sem ganho de tamanho")
	_check(float(sizes.get("ratio", 1.0)) < 0.85,
		"Compressão estrutural >= 15%% vs dict",
		"ratio=%.2f" % float(sizes.get("ratio", 1.0)))

	print("\n[4] ServerConfig flag snapshot_binary")
	var cfg := ServerConfig.new()
	_check(cfg.snapshot_binary == true, "snapshot_binary default true", "default false")
	cfg.snapshot_binary = false
	var d := cfg.to_dict()
	_check(d.has("snapshot_binary"), "to_dict inclui snapshot_binary", "missing key")
	var cfg2 := ServerConfig.from_dict(d)
	_check(cfg2.snapshot_binary == false, "from_dict restaura snapshot_binary", "restore fail")

	print("\n[5] NetworkManager RPC hooks present")
	_check(NetworkManager != null, "NetworkManager autoload", "null")
	_check(NetworkManager.has_method("rpc_receber_snapshot_mundo_binario"),
		"RPC binário registrado", "rpc binário ausente")
	_check(NetworkManager.has_method("rpc_receber_snapshot_mundo_binario_comprimido"),
		"RPC binário+deflate registrado", "rpc comprimido ausente")
