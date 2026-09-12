extends Node

## Demo headless/visual: abre HatsuCreationUI e navega até o slider de força.
## Uso: godot res://scratch/demo_hatsu_creation_ui.tscn

var ui: HatsuCreationUI


func _ready() -> void:
	await get_tree().process_frame
	ui = HatsuCreationUI.new()
	ui.name = "HatsuCreationUI"
	get_tree().root.add_child(ui)
	ui.abrir()
	print("[Demo] HatsuCreationUI aberto — etapa Tipo")
	await get_tree().create_timer(0.8).timeout

	# Tipo → Intensificação
	if ui.has_method("_ir_para_etapa"):
		ui.sel_categoria = HatsuData.Categoria.INTENSIFICACAO
		ui.sel_tipo_especial = false
		ui._ir_para_etapa(HatsuCreationUI.Etapa.CONCEITO)
		print("[Demo] Etapa Conceito (catálogo amplo)")
		await get_tree().create_timer(4.0).timeout

		ui._ir_para_etapa(HatsuCreationUI.Etapa.PODER)
		print("[Demo] Etapa Força (slider)")
		ui.sel_custom_damage = 140.0
		if ui.has_method("_atualizar_etapa"):
			ui._atualizar_etapa()
		await get_tree().create_timer(8.0).timeout

		ui._ir_para_etapa(HatsuCreationUI.Etapa.CONDICOES)
		print("[Demo] Etapa Condições (após força)")
		await get_tree().create_timer(4.0).timeout

		ui._ir_para_etapa(HatsuCreationUI.Etapa.PODER)
		print("[Demo] Voltar para Força")
		await get_tree().create_timer(1.0).timeout

	print("[Demo] Fluxo força→votos→voltar OK")
	# Mantém UI aberta para captura manual; sai após alguns segundos em CI
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
