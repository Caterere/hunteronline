extends Node

# ============================================================
# HUNTER MMORPG — DEDICATED SERVER MAIN PROCESS (FASE K-LAN)
# ============================================================
#
# Processo dedicado autônomo do HunterServer:
# - Executável headless ou console sem janela/render/áudio
# - Ponto de entrada oficial para hosts LAN, Radmin VPN ou VPS
# - Carrega server_config.json e inicializa NetworkManager
# - Modo opcional: --master-registry [porta] (só lista dinâmica)
# ============================================================

const ServerConfigScript = preload("res://scripts/network/ServerConfig.gd")

var config: ServerConfig = null
var _registry_only: bool = false


func _ready() -> void:
	print("\n>>> INICIALIZANDO HUNTER MMORPG DEDICATED SERVER <<<")

	if _try_start_master_registry_only():
		return

	# Carregar configuração e aplicar parâmetros CLI
	config = ServerConfigScript.load_from_file()
	config.apply_cmdline_args()

	# Configurar título da janela se houver display
	DisplayServer.window_set_title("Hunter MMORPG — Dedicated Server [%s:%d]" % [config.server_name, config.port])

	# Iniciar servidor dedicado no NetworkManager
	var err = NetworkManager.iniciar_servidor_dedicado(config)
	if err != OK:
		push_error("[HunterServerMain] ❌ Erro fatal ao iniciar servidor: %d" % err)
		get_tree().quit(1)
		return

	print("[HunterServerMain] 🚀 Servidor dedicado em execução com sucesso.")


func _try_start_master_registry_only() -> bool:
	var args = OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()
	var listen_port: int = 7780
	var found := false
	for i in range(args.size()):
		if args[i] == "--master-registry":
			found = true
			if i + 1 < args.size() and str(args[i + 1]).is_valid_int():
				listen_port = int(args[i + 1])
			break
	if not found:
		return false

	_registry_only = true
	DisplayServer.window_set_title("Hunter MMORPG — Master Server Registry [%d]" % listen_port)
	var err: Error = NetworkManager.iniciar_master_registry(listen_port)
	if err != OK:
		push_error("[HunterServerMain] ❌ Falha ao iniciar Master Registry: %d" % err)
		get_tree().quit(1)
		return true
	print("[HunterServerMain] 🛰️ Master Registry ativo na porta UDP %d" % listen_port)
	print("[HunterServerMain] Game servers: --master-announce --master-host <ip> --master-port %d" % listen_port)
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("\n[HunterServerMain] 🛑 Encerrando servidor dedicado de forma limpa...")
		if _registry_only and NetworkManager.master_registry != null:
			NetworkManager.master_registry.stop()
			NetworkManager.master_registry = null
		else:
			NetworkManager.desconectar()
		get_tree().quit(0)
