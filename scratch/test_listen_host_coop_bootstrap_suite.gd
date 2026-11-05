extends Node

# ============================================================
# LISTEN-HOST COOP BOOTSTRAP — etapas 0–2 (Criar Mundo + identidade)
# ============================================================

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("\n======== LISTEN-HOST COOP BOOTSTRAP SUITE ========")
	_test_helpers_and_defaults()
	_test_iniciar_host_bootstrap()
	_test_character_id_duplicate_guard()
	_test_docs_beacon_aligned()
	_imprimir_resultado()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  ✅ [PASS] %s" % msg)
	else:
		_fail += 1
		push_error("  ❌ [FAIL] %s" % msg)


func _test_helpers_and_defaults() -> void:
	print("\n--- Helpers / defaults ---")
	assert_test(NetworkManager != null, "NetworkManager autoload")
	assert_test(NetworkManager.is_offline_singleplayer(), "inicia OFFLINE_SINGLEPLAYER")
	assert_test(NetworkManager.has_method("is_listen_host"), "is_listen_host disponível")
	assert_test(NetworkManager.has_method("has_authoritative_world"), "has_authoritative_world disponível")
	assert_test(NetworkManager.has_method("solicitar_ataque_host_local"), "solicitar_ataque_host_local disponível")
	assert_test(ConnectionManagerScript_padrao_porta() == 7777, "porta ENet padrão 7777")
	assert_test(_discovery_port_default() == 7778, "porta discovery padrão 7778")


func ConnectionManagerScript_padrao_porta() -> int:
	var cm = load("res://scripts/network/ConnectionManager.gd")
	return int(cm.PADRAO_PORTA)


func _discovery_port_default() -> int:
	var cfg_script = load("res://scripts/network/ServerConfig.gd")
	var cfg = cfg_script.new()
	return int(cfg.discovery_port)


func _test_iniciar_host_bootstrap() -> void:
	print("\n--- iniciar_host bootstrap ---")
	if PlayerData != null:
		if str(PlayerData.character_id).is_empty() and PlayerData.has_method("gerar_novo_character_id"):
			PlayerData.gerar_novo_character_id()
		PlayerData.nome_personagem = "HostTest"

	var err: Error = NetworkManager.iniciar_host(17881, 4, "Suite Mundo")
	assert_test(err == OK, "iniciar_host retorna OK (porta 17881)")
	assert_test(NetworkManager.is_listen_host(), "modo HOST_LISTEN")
	assert_test(NetworkManager.has_authoritative_world(), "world_coordinator ativo no listen-host")
	assert_test(NetworkManager.server_storage != null, "server_storage ativo no listen-host")
	assert_test(NetworkManager.discovery_broadcaster != null, "LAN discovery ligado no Criar Mundo")
	assert_test(NetworkManager.world_coordinator.players.has(1), "anfitrião registrado no coordinator (peer 1)")
	var info: Dictionary = NetworkManager.session.obter_peer_info(1)
	assert_test(str(info.get("character_id", "")).length() > 0, "peer 1 tem character_id na sessão")
	assert_test(str(info.get("character_id", "")) != "1", "character_id não é o peer_id numérico")

	NetworkManager.desconectar()
	assert_test(NetworkManager.is_offline_singleplayer(), "desconectar volta a OFFLINE")
	assert_test(not NetworkManager.has_authoritative_world(), "coordinator limpo após desconectar")


func _test_character_id_duplicate_guard() -> void:
	print("\n--- character_id duplicado ---")
	if PlayerData != null:
		PlayerData.character_id = "hxr-suite-dup-a"
		PlayerData.nome_personagem = "Alpha"

	var err: Error = NetworkManager.iniciar_host(17882, 4, "DupGuard")
	assert_test(err == OK, "host sobe para teste de duplicata")

	# Simula peer já presente com mesmo character_id (convidado hipotético)
	NetworkManager.session.adicionar_peer(42, {
		"name": "Beta",
		"character_id": "hxr-suite-dup-a",
		"nickname": "Beta"
	})
	assert_test(
		NetworkManager._character_id_em_uso("hxr-suite-dup-a", 1) == true,
		"detecta character_id em uso por outro peer"
	)
	assert_test(
		NetworkManager._character_id_em_uso("hxr-suite-dup-a", 42) == true,
		"detecta character_id do anfitrião quando except=convidado"
	)
	assert_test(
		NetworkManager._character_id_em_uso("hxr-suite-livre", -1) == false,
		"character_id livre não marcado"
	)

	NetworkManager.desconectar()


func _test_docs_beacon_aligned() -> void:
	print("\n--- docs beacon alinhado ao código ---")
	var path := "res://docs/multiplayer/NETWORK_PROTOCOL.md"
	if not FileAccess.file_exists(path):
		assert_test(false, "NETWORK_PROTOCOL.md existe")
		return
	var f := FileAccess.open(path, FileAccess.READ)
	var text: String = f.get_as_text()
	f.close()
	assert_test(text.contains("HUNTER_LAN_SERVER|"), "docs citam beacon pipe HUNTER_LAN_SERVER|")
	# Pode citar o magic antigo só como legado; o wire format ativo deve ser o pipe.
	var active_ok: bool = text.contains("código atual") or text.contains("wire format ativo")
	assert_test(active_ok, "docs marcam o beacon pipe como formato ativo")


func _imprimir_resultado() -> void:
	print("\n======== RESULTADO LISTEN-HOST BOOTSTRAP ========")
	print("TOTAL: %d | PASS: %d | FAIL: %d" % [_pass + _fail, _pass, _fail])
	if _fail == 0:
		print("🎉 TODOS PASSARAM")
	else:
		push_error("⚠️ FALHAS NA SUITE LISTEN-HOST")
