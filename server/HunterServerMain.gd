extends Node

# ============================================================
# HUNTER MMORPG — DEDICATED SERVER MAIN PROCESS (FASE K-LAN)
# ============================================================
#
# Processo dedicado autônomo do HunterServer:
# - Executável headless ou console sem janela/render/áudio
# - Ponto de entrada oficial para hosts LAN, Radmin VPN ou VPS
# - Carrega server_config.json e inicializa NetworkManager
# ============================================================

const ServerConfigScript = preload("res://scripts/network/ServerConfig.gd")

var config: ServerConfig = null


func _ready() -> void:
	print("\n>>> INICIALIZANDO HUNTER MMORPG DEDICATED SERVER <<<")

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


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("\n[HunterServerMain] 🛑 Encerrando servidor dedicado de forma limpa...")
		NetworkManager.desconectar()
		get_tree().quit(0)
