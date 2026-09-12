extends Node

## Demo visual do polish pack: tema, atos, eixos/preview, composição, glossário, extras.
## Uso: godot res://scratch/demo_hatsu_creation_ui.tscn

var ui: HatsuCreationUI


func _ready() -> void:
	await get_tree().process_frame
	# Liberar criação para o demo (se o progression manager bloquear)
	if HatsuProgressionManager != null and HatsuProgressionManager.has_method("can_create_hatsu"):
		pass
	ui = HatsuCreationUI.new()
	ui.name = "HatsuCreationUI"
	get_tree().root.add_child(ui)
	# Bypass de slot se necessário: setar flags e chamar construção direta
	if ui.has_method("abrir"):
		# Força abertura mesmo se slot locked — demo visual
		ui.visible = true
		if ui.get_tree() != null:
			ui.get_tree().paused = true
		if ui.has_method("_construir_ui") and ui.panel_main == null:
			ui._construir_ui()
		ui.etapa_atual = HatsuCreationUI.Etapa.TIPO_NEN
		ui._atualizar_etapa()
	print("[Demo] HatsuCreationUI aberto — Ato Identidade")
	await get_tree().create_timer(1.2).timeout

	ui.sel_categoria = HatsuData.Categoria.TRANSFORMACAO
	ui.sel_tipo_especial = false
	ui._ir_para_etapa(HatsuCreationUI.Etapa.FUNCIONAMENTO)
	print("[Demo] Funcionamento + composição modular (props A+B)")
	await get_tree().create_timer(4.0).timeout

	ui._ir_para_etapa(HatsuCreationUI.Etapa.PODER)
	ui.sel_custom_damage = 180.0
	ui._atualizar_etapa()
	print("[Demo] Força 180 — eixos aura/CD/setup + preview combate")
	await get_tree().create_timer(6.0).timeout

	ui._ir_para_etapa(HatsuCreationUI.Etapa.CONDICOES)
	print("[Demo] Condições — glossário CONDIÇÃO ≠ PREPARAÇÃO")
	await get_tree().create_timer(3.5).timeout

	ui._ir_para_etapa(HatsuCreationUI.Etapa.RESTRICOES)
	print("[Demo] Restrições/Juramentos — glossário RESTRIÇÃO ≠ JURAMENTO")
	await get_tree().create_timer(3.5).timeout

	ui._ir_para_etapa(HatsuCreationUI.Etapa.RESUMO)
	print("[Demo] Resumo — tags, gems, bilaterais, morphs, modo, galeria")
	await get_tree().create_timer(8.0).timeout

	print("[Demo] Polish pack UI walkthrough OK")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
