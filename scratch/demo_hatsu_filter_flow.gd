extends Node

## Demo sequencial: centro + filtro + trava de identidade.
var ui: CanvasLayer
var out_dir := "/tmp/hatsu_filter_demo"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	await get_tree().process_frame
	var script: GDScript = load("res://ui/Hatsu/HatsuCreationUI.gd")
	ui = script.new()
	ui.name = "HatsuCreationUI"
	get_tree().root.add_child(ui)
	if ui.get("panel_main") == null and ui.has_method("_construir_ui"):
		ui.call("_construir_ui")
	ui.visible = true
	if ui.get_tree() != null:
		ui.get_tree().paused = true

	ui.set("sel_categoria", HatsuData.Categoria.INTENSIFICACAO)
	ui.set("sel_tipo_especial", false)
	var preset: Dictionary = HatsuPresetLibrary.obter_preset(HatsuPresetLibrary.PresetId.PALMA_CURATIVA)
	ui.call("_aplicar_preset", preset)

	# 0 Tipo
	_goto(0)
	await _wait_shot("04_ui_centralizada_tipo.png")

	# 1 Conceito (filtrado)
	_goto(1)
	await _wait_shot("01_conceito_filtrado_intensificacao.png")

	# 2 Nome (obrigatório no caminho)
	_goto(2)
	await get_tree().create_timer(0.3).timeout

	# 3 Funcionamento travado
	_goto(3)
	await _wait_shot("02_funcionamento_travado_palma.png")
	print("[DemoFilter] etapa=", ui.get("etapa_atual"), " title=", _title())

	# 4 Efeitos filtrados
	_goto(4)
	await _wait_shot("03_efeitos_filtrados.png")
	print("[DemoFilter] etapa=", ui.get("etapa_atual"), " title=", _title())

	print("[DemoFilter] OK")
	get_tree().quit(0)

func _title() -> String:
	var lbl = ui.get("lbl_titulo")
	return str(lbl.text) if lbl != null else "?"

func _goto(idx: int) -> void:
	ui.call("_ir_para_etapa", idx)

func _wait_shot(fname: String) -> void:
	await get_tree().create_timer(0.7).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(out_dir.path_join(fname))
	print("[DemoFilter] saved ", fname, " etapa=", ui.get("etapa_atual"), " ", _title())
