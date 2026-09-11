extends SceneTree

# Smoke: QUERY master registry e valida ENTRY do game server anunciado.
# Args: --registry-host --registry-port --pass-file

var _host: String = "127.0.0.1"
var _port: int = 7780
var _pass_file: String = "/tmp/hunter_registry_smoke_pass.flag"
var _frames: int = 0
var _querier = null


func _initialize() -> void:
	_parse_args()
	call_deferred("_start")


func _start() -> void:
	var MasterServerRegistryScript = load("res://scripts/network/MasterServerRegistry.gd")
	_querier = MasterServerRegistryScript.new()
	var err: Error = _querier.query_servers(_host, _port)
	if err != OK:
		push_error("[registry-query] query failed: %d" % err)
		quit(1)
		return
	print("[registry-query] QUERY sent to %s:%d" % [_host, _port])


func _process(_delta: float) -> bool:
	_frames += 1
	if _querier == null:
		return true
	_querier.update(0.05)
	var listed: Array = _querier.get_server_list()
	if listed.size() >= 1:
		print("[registry-query] got %d server(s): %s" % [listed.size(), listed[0]])
		var fa := FileAccess.open(_pass_file, FileAccess.WRITE)
		if fa:
			fa.store_string("ok")
			fa.close()
		_querier.stop()
		quit(0)
		return true
	if _frames > 90:
		push_error("[registry-query] timeout waiting for LIST")
		_querier.stop()
		quit(1)
	return true


func _parse_args() -> void:
	var args = OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()
	for i in range(args.size()):
		var a = args[i]
		if a == "--registry-host" and i + 1 < args.size():
			_host = args[i + 1]
		elif a == "--registry-port" and i + 1 < args.size():
			_port = int(args[i + 1])
		elif a == "--pass-file" and i + 1 < args.size():
			_pass_file = args[i + 1]
