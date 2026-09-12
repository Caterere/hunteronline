extends Node

## Demo visual do polish pack (bypass de slot lock).
## Uso: godot res://scratch/demo_hatsu_creation_ui.tscn

var ui: CanvasLayer


func _ready() -> void:
	await get_tree().process_frame
	var script: GDScript = load("res://ui/Hatsu/HatsuCreationUI.gd")
	if script == null or not script.can_instantiate():
		push_error("[Demo] HatsuCreationUI não carrega")
		get_tree().quit(1)
		return
	ui = script.new()
	ui.name = "HatsuCreationUI"
	get_tree().root.add_child(ui)

	# Bypass ProgressionManager: monta UI direto
	if ui.get("panel_main") == null and ui.has_method("_construir_ui"):
		ui.call("_construir_ui")
	ui.set("visible", true)
	ui.set("etapa_atual", 0)
	if ui.get_tree() != null:
		ui.get_tree().paused = true
	if ui.has_method("_atualizar_etapa"):
		ui.call("_atualizar_etapa")

	print("[Demo] HatsuCreationUI aberto — Ato Identidade (tema HunterUIStyle)")
	await get_tree().create_timer(2.0).timeout

	_goto(3) # FUNCIONAMENTO
	print("[Demo] Funcionamento + composição modular")
	await get_tree().create_timer(5.0).timeout

	_goto(5) # PODER
	ui.set("sel_custom_damage", 180.0)
	ui.call("_atualizar_etapa")
	print("[Demo] Força 180 — eixos aura/CD/setup + preview combate")
	await get_tree().create_timer(8.0).timeout

	_goto(6) # CONDICOES
	print("[Demo] Condições — glossário CONDIÇÃO ≠ PREPARAÇÃO")
	await get_tree().create_timer(7.0).timeout

	_goto(7) # RESTRICOES
	print("[Demo] Restrições/Juramentos — glossário RESTRIÇÃO ≠ JURAMENTO")
	await get_tree().create_timer(7.0).timeout

	_goto(9) # RESUMO
	print("[Demo] Resumo — tags, gems, bilaterais, morphs, modo, galeria")
	await get_tree().create_timer(12.0).timeout

	print("[Demo] Polish pack UI walkthrough OK")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)


func _goto(idx: int) -> void:
	if ui == null:
		return
	if ui.has_method("_ir_para_etapa"):
		ui.call("_ir_para_etapa", idx)
	else:
		ui.set("etapa_atual", idx)
		ui.call("_atualizar_etapa")
