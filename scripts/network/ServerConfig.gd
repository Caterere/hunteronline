class_name ServerConfig
extends RefCounted

# ============================================================
# HUNTER ONLINE — SERVER CONFIGURATION (FASE K-LAN)
# ============================================================
#
# Configurações do Servidor Dedicado LAN / VPN / VPS:
# - Portas ENet (jogo) e UDP Discovery (somente LAN)
# - Capacidade, senha opcional, tick rate e persistência
# - bind_address / public_host para hospedagem futura
# - Sobrescrita via argumentos de linha de comando
# ============================================================

const DEFAULT_CONFIG_PATH: String = "user://server_config.json"
const FALLBACK_CONFIG_PATH: String = "res://config/server_config.json"

var server_name: String = "Hunter Dedicated LAN"
var port: int = 7777
var discovery_port: int = 7778
var max_players: int = 16
var server_password: String = ""
var save_path: String = "user://server_saves/"
var tick_rate: int = 20 # 20 TPS (50ms por tick)
var starting_map: String = "res://world/lobby.tscn"
var region: String = "Capital dos Caçadores"
var bind_address: String = "*" # "*" = todas as interfaces (LAN + futuro VPS)
var public_host: String = "" # IP/DNS público opcional (VPS); vazio = só LAN/IP local
var enable_lan_discovery: bool = true # desligar em host público / VPS
var interest_radius: float = 900.0 # AoI: só envia entidades perto do jogador
var snapshot_delta: bool = true # envia só mudanças vs último snapshot do peer
var snapshot_send_hz: float = 10.0 # cap de envio (ticks de jogo podem ser 20)
var snapshot_compress: bool = true # comprime snapshots full / grandes
var snapshot_compress_min_bytes: int = 256
var snapshot_binary: bool = true # PREREQ-1: empacota snapshot via NetworkProtocol binário
var enable_master_announce: bool = false
var master_registry_host: String = "127.0.0.1"
var master_registry_port: int = 7780
var save_interval_sec: int = 60
var motd: String = "Bem-vindo ao servidor LAN de Hunter Online!"
var debug: bool = true


func to_dict() -> Dictionary:
	return {
		"server_name": server_name,
		"port": port,
		"discovery_port": discovery_port,
		"max_players": max_players,
		"server_password": server_password,
		"save_path": save_path,
		"tick_rate": tick_rate,
		"starting_map": starting_map,
		"region": region,
		"bind_address": bind_address,
		"public_host": public_host,
		"enable_lan_discovery": enable_lan_discovery,
		"interest_radius": interest_radius,
		"snapshot_delta": snapshot_delta,
		"snapshot_send_hz": snapshot_send_hz,
		"snapshot_compress": snapshot_compress,
		"snapshot_compress_min_bytes": snapshot_compress_min_bytes,
		"snapshot_binary": snapshot_binary,
		"enable_master_announce": enable_master_announce,
		"master_registry_host": master_registry_host,
		"master_registry_port": master_registry_port,
		"save_interval_sec": save_interval_sec,
		"motd": motd,
		"debug": debug
	}


static func from_dict(d: Dictionary) -> ServerConfig:
	var cfg = (load("res://scripts/network/ServerConfig.gd") as GDScript).new()
	cfg.server_name = str(d.get("server_name", "Hunter Dedicated LAN"))
	# Compat docs antigos: server_port / password
	cfg.port = int(d.get("port", d.get("server_port", 7777)))
	cfg.discovery_port = int(d.get("discovery_port", 7778))
	cfg.max_players = int(d.get("max_players", 16))
	cfg.server_password = str(d.get("server_password", d.get("password", "")))
	cfg.save_path = str(d.get("save_path", "user://server_saves/"))
	cfg.tick_rate = int(d.get("tick_rate", 20))
	cfg.starting_map = str(d.get("starting_map", d.get("default_map", "res://world/lobby.tscn")))
	cfg.region = str(d.get("region", "Capital dos Caçadores"))
	cfg.bind_address = str(d.get("bind_address", "*"))
	cfg.public_host = str(d.get("public_host", ""))
	cfg.enable_lan_discovery = bool(d.get("enable_lan_discovery", true))
	cfg.interest_radius = float(d.get("interest_radius", 900.0))
	cfg.snapshot_delta = bool(d.get("snapshot_delta", true))
	cfg.snapshot_send_hz = float(d.get("snapshot_send_hz", 10.0))
	cfg.snapshot_compress = bool(d.get("snapshot_compress", true))
	cfg.snapshot_compress_min_bytes = int(d.get("snapshot_compress_min_bytes", 256))
	cfg.snapshot_binary = bool(d.get("snapshot_binary", true))
	cfg.enable_master_announce = bool(d.get("enable_master_announce", false))
	cfg.master_registry_host = str(d.get("master_registry_host", "127.0.0.1"))
	cfg.master_registry_port = int(d.get("master_registry_port", 7780))
	cfg.save_interval_sec = int(d.get("save_interval_sec", 60))
	cfg.motd = str(d.get("motd", "Bem-vindo ao servidor LAN de Hunter Online!"))
	cfg.debug = bool(d.get("debug", true))
	return cfg


func save_to_file(path: String = DEFAULT_CONFIG_PATH) -> Error:
	var json_str = JSON.stringify(to_dict(), "\t")
	var fa = FileAccess.open(path, FileAccess.WRITE)
	if fa == null:
		return FileAccess.get_open_error()
	fa.store_string(json_str)
	fa.close()
	return OK


static func load_from_file(path: String = DEFAULT_CONFIG_PATH) -> ServerConfig:
	var target_path = path
	if not FileAccess.file_exists(target_path):
		if FileAccess.file_exists(FALLBACK_CONFIG_PATH):
			target_path = FALLBACK_CONFIG_PATH
		else:
			var default_cfg = (load("res://scripts/network/ServerConfig.gd") as GDScript).new()
			default_cfg.save_to_file(target_path)
			return default_cfg

	var fa = FileAccess.open(target_path, FileAccess.READ)
	if fa == null:
		return (load("res://scripts/network/ServerConfig.gd") as GDScript).new()

	var content = fa.get_as_text()
	fa.close()
	# Remove BOM UTF-8 se presente
	if content.begins_with("\ufeff"):
		content = content.substr(1)

	var json = JSON.new()
	var err = json.parse(content)
	if err != OK or not (json.data is Dictionary):
		push_warning("[ServerConfig] JSON inválido em %s — usando defaults." % target_path)
		return (load("res://scripts/network/ServerConfig.gd") as GDScript).new()

	return from_dict(json.data)


func apply_cmdline_args() -> void:
	var args = OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()

	for i in range(args.size()):
		var arg = args[i]
		if arg == "--port" and i + 1 < args.size():
			port = int(args[i + 1])
		elif arg == "--discovery-port" and i + 1 < args.size():
			discovery_port = int(args[i + 1])
		elif arg == "--max-players" and i + 1 < args.size():
			max_players = int(args[i + 1])
		elif arg == "--name" and i + 1 < args.size():
			server_name = args[i + 1]
		elif arg == "--password" and i + 1 < args.size():
			server_password = args[i + 1]
		elif arg == "--tick-rate" and i + 1 < args.size():
			tick_rate = int(args[i + 1])
		elif arg == "--map" and i + 1 < args.size():
			starting_map = args[i + 1]
		elif arg == "--bind" and i + 1 < args.size():
			bind_address = args[i + 1]
		elif arg == "--public-host" and i + 1 < args.size():
			public_host = args[i + 1]
		elif arg == "--interest-radius" and i + 1 < args.size():
			interest_radius = float(args[i + 1])
		elif arg == "--snapshot-hz" and i + 1 < args.size():
			snapshot_send_hz = float(args[i + 1])
		elif arg == "--no-snapshot-compress":
			snapshot_compress = false
		elif arg == "--no-snapshot-binary":
			snapshot_binary = false
		elif arg == "--full-snapshots":
			snapshot_delta = false
		elif arg == "--master-announce":
			enable_master_announce = true
		elif arg == "--master-host" and i + 1 < args.size():
			master_registry_host = args[i + 1]
			enable_master_announce = true
		elif arg == "--master-port" and i + 1 < args.size():
			master_registry_port = int(args[i + 1])
		elif arg == "--no-lan-discovery":
			enable_lan_discovery = false
		elif arg == "--save-path" and i + 1 < args.size():
			save_path = args[i + 1]
