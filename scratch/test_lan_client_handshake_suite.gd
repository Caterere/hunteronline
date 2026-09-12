extends Node

# Smoke client: conecta a um HunterServer dedicado e valida handshake.
# Args: --lan-smoke-host --lan-smoke-port --lan-smoke-pass-file

var _host: String = "127.0.0.1"
var _port: int = 7791
var _pass_file: String = "/tmp/hunter_lan_smoke_pass.flag"
var _done: bool = false
var _timeout: float = 12.0


func _ready() -> void:
	_parse_args()
	print("[lan-client] connecting to %s:%d" % [_host, _port])
	if NetworkManager == null:
		push_error("[lan-client] NetworkManager missing")
		get_tree().quit(1)
		return
	NetworkManager.handshake_completed.connect(_on_handshake)
	var err = NetworkManager.conectar_com_handshake(_host, _port, "")
	if err != OK:
		push_error("[lan-client] connect socket failed: %d" % err)
		get_tree().quit(1)


func _process(delta: float) -> void:
	_timeout -= delta
	if _done:
		return
	if _timeout <= 0.0:
		push_error("[lan-client] handshake timeout")
		get_tree().quit(1)


func _parse_args() -> void:
	var args = OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()
	for i in range(args.size()):
		var a = args[i]
		if a == "--lan-smoke-host" and i + 1 < args.size():
			_host = args[i + 1]
		elif a == "--lan-smoke-port" and i + 1 < args.size():
			_port = int(args[i + 1])
		elif a == "--lan-smoke-pass-file" and i + 1 < args.size():
			_pass_file = args[i + 1]


func _on_handshake(success: bool, reason: String) -> void:
	if _done:
		return
	_done = true
	if not success:
		push_error("[lan-client] handshake rejected: %s" % reason)
		get_tree().quit(1)
		return
	print("[lan-client] handshake OK")
	var fa = FileAccess.open(_pass_file, FileAccess.WRITE)
	if fa != null:
		fa.store_string("PASS\n")
		fa.close()
	NetworkManager.desconectar()
	get_tree().quit(0)
