extends Node

const Primer = preload("res://scripts/story/ProgressionSystemsPrimer.gd")

var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== progression systems primer ===")
	_test_primer_content()
	_test_wing_wiring()
	print("=== RESULT: %d pass / %d fail ===" % [_ok, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✅ ", msg)
	else:
		_fail += 1
		print("  ❌ ", msg)


func _test_primer_content() -> void:
	var tops: Array = Primer.topicos()
	_assert(tops.size() >= 5, "≥5 tópicos no guia")
	var ids: Array = []
	for t in tops:
		ids.append(str(t.get("id", "")))
	_assert("nivel" in ids, "tópico nivel")
	_assert("nen" in ids, "tópico nen")
	_assert("nen_tree" in ids, "tópico nen_tree")
	_assert("hatsu" in ids, "tópico hatsu")
	_assert(Primer.falas_nivel().size() >= 3, "falas nível")
	_assert(Primer.falas_nen_tree().size() >= 3, "falas nen tree")
	_assert(Primer.falas_hatsu().size() >= 3, "falas hatsu")
	var blob := ""
	for f in Primer.falas_nen():
		blob += str(f.get("texto", ""))
	_assert("[Z]" in blob and "[G]" in blob and "[X]" in blob, "controles Z/G/X nas falas Nen")
	_assert("PASSIV" in blob.to_upper() or "passiv" in blob, "Ten/Ren como passivas")


func _test_wing_wiring() -> void:
	var wing_src := FileAccess.get_file_as_string("res://entities/npc/wing/Wing.gd")
	_assert("_on_opcao_guia_progressao" in wing_src, "Wing tem opção Guia")
	_assert("ProgressionSystemsPrimerScript.abrir_menu_guia" in wing_src, "Wing abre primer")
	var vale := FileAccess.get_file_as_string("res://world/maps/RegiaoValePadokiaMap.gd")
	_assert("_abrir_guia_progressao_vale" in vale, "Vale abre guia no Training Wing")
	var arena := FileAccess.get_file_as_string("res://world/maps/ArenaCelestialMap.gd")
	_assert("ProgressionSystemsPrimerScript" in arena, "Arena Training Wing liga ao guia")
	var modal: CanvasLayer = Primer.abrir_menu_guia(self, func(_f): pass)
	_assert(modal != null, "abrir_menu_guia cria CanvasLayer")
	if modal != null:
		modal.queue_free()
	if get_tree() != null:
		get_tree().paused = false
