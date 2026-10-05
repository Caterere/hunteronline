extends SceneTree

## G5 route smoke — carrega mapas da rota early
## godot --headless --path . -s res://scratch/test_g5_route_playtest_suite.gd

var _pass := 0
var _fail := 0
var _notes: PackedStringArray = []


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		print("  FAIL: ", msg)
		_notes.append("FAIL: " + msg)


func _note(msg: String) -> void:
	_notes.append(msg)
	print("  NOTE: ", msg)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("\n=== G5 ROUTE PLAYTEST SUITE (agent) ===\n")
	var pd = root.get_node_or_null("/root/PlayerData")
	if pd != null:
		pd.despertou_nen = true
		pd.arco_atual = 1
		pd.etapa_quest_arco = 1
	_check_cutscenes()
	await _check_map("res://world/maps/exame_maratona.tscn", "exame", [
		"CkptExameLargada", "HatsuMomentExame", "GyoPistaMarcaSabotador"
	])
	await _check_map("res://world/lobby.tscn", "lobby", [
		"PortaoMundoExterior"
	])
	await _check_map("res://world/maps/estrada_padokia.tscn", "estrada", [
		"HatsuMomentEstrada", "ZetsuMataLateralEstrada", "BauEstradaClareira",
		"AgenteAssociacaoEstrada", "ObservadorMafiaEstrada"
	])
	await _check_map("res://world/maps/floresta_vestigios.tscn", "floresta", [
		"AlfaNinhoElite", "GyoClueEliteNinho", "HatsuMomentFloresta",
		"CkptFlorestaNinho", "BauFlorestaProfunda"
	])
	await _check_map("res://world/maps/regiao_vale_padokia.tscn", "vale", [
		"HatsuMomentVale", "CkptValeWing"
	])
	await _check_map("res://world/maps/dungeon_ruinas_zaban.tscn", "ruinas", [
		"HatsuMomentRuinas", "CkptRuinasBoss", "ZetsuCorredorSentinelas",
		"GyoCluePortaoEntrada"
	])
	_check_hud_source()
	_write_notes()
	print("\n=== RESULT: %d pass, %d fail ===\n" % [_pass, _fail])
	quit(0 if _fail == 0 else 1)


func _check_cutscenes() -> void:
	print("[cutscenes early]")
	var lib = load("res://scripts/cutscenes/CheckpointCutsceneLibrary.gd")
	_assert(lib != null, "CheckpointCutsceneLibrary")
	if lib == null:
		return
	for id in ["exame_largada", "vale_wing_nen", "floresta_ninho", "ruinas_antes_guardiao"]:
		var passos = lib.obter_passos(StringName(id))
		_assert(passos.size() >= 4, "cutscene %s (%d passos)" % [id, passos.size()])


func _check_map(path: String, label: String, required_nodes: Array) -> void:
	print("\n[%s] %s" % [label, path])
	var scn = load(path)
	_assert(scn != null, "%s carrega" % label)
	if scn == null:
		return
	var map = scn.instantiate()
	root.add_child(map)
	await process_frame
	await process_frame
	await process_frame
	var found := 0
	for n in required_nodes:
		var node = map.get_node_or_null(str(n))
		if node == null:
			node = map.find_child(str(n), true, false)
		var ok = node != null
		_assert(ok, "%s tem %s" % [label, n])
		if ok:
			found += 1
	var gyo := 0
	var zetsu := 0
	var ko := 0
	for c in map.get_children():
		var nm := str(c.name)
		if nm.begins_with("Gyo") or c.get_class() == "GyoInspectable" or nm.contains("Gyo"):
			gyo += 1
		if nm.begins_with("Zetsu"):
			zetsu += 1
		if nm.begins_with("Ko"):
			ko += 1
	_note("%s sensores approx Gyo=%d Zetsu=%d Ko=%d required_ok=%d/%d" % [
		label, gyo, zetsu, ko, found, required_nodes.size()
	])
	map.queue_free()
	await process_frame


func _check_hud_source() -> void:
	print("\n[QuestHUD]")
	var src := FileAccess.get_file_as_string("res://ui/hud/QuestHUD.gd")
	_assert("_atualizar_historia_atividades" in src, "História% vs Atividades no HUD")
	_assert("lbl_historia" in src, "lbl_historia")
	_assert("lbl_atividades" in src, "lbl_atividades")


func _write_notes() -> void:
	var abs_path := "/opt/cursor/artifacts/g5_agent_route_notes.txt"
	var f := FileAccess.open(abs_path, FileAccess.WRITE)
	if f == null:
		print("could not write notes")
		return
	f.store_line("G5 AGENT ROUTE NOTES — " + Time.get_datetime_string_from_system())
	f.store_line("Suite pass=%d fail=%d" % [_pass, _fail])
	f.store_line("Live GUI: lobby entered; História/Atividades HUD confirmed in screenshots.")
	f.store_line("Portal interact flaky under xdotool (chat steals keys / pause menu).")
	f.store_line("Human G5 still required for dead-time perception.")
	f.store_line("---")
	for n in _notes:
		f.store_line(n)
	f.close()
	print("notes -> ", abs_path)
