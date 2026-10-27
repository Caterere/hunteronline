extends Node2D

## Fluxo principal A→B→C do Hatsu CreationUI (salta abas avançadas).

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== HATSU CREATOR FLUXO A→B→C ===")
	_test_fluxo()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_fluxo() -> void:
	var ui := HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()
	_ok(ui.etapa_atual == HatsuCreationUI.Etapa.TIPO_NEN, "inicia A1")
	ui._on_avancar_pressed()
	_ok(ui.etapa_atual == HatsuCreationUI.Etapa.CONCEITO, "A2 conceito")
	ui._on_avancar_pressed()
	_ok(ui.etapa_atual == HatsuCreationUI.Etapa.NOME, "A3 nome")
	ui._on_avancar_pressed()
	_ok(ui.etapa_atual == HatsuCreationUI.Etapa.CONDICOES, "pula Função* → B1 Cond")
	ui._on_avancar_pressed()
	_ok(ui.etapa_atual == HatsuCreationUI.Etapa.RESTRICOES, "B2 Votos")
	ui._on_avancar_pressed()
	_ok(ui.etapa_atual == HatsuCreationUI.Etapa.RESUMO, "C Árvore/Forja")
	# Voltar pelo fluxo principal
	ui._on_voltar_pressed()
	_ok(ui.etapa_atual == HatsuCreationUI.Etapa.RESTRICOES, "voltar para B2")
	ui.fechar()
	ui.queue_free()
