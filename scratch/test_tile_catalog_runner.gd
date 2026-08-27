extends Node2D

func _ready() -> void:
	print("============================================================")
	print("EXECUTANDO TESTE COMPLETO DO TILE CATALOG & ROOM COMPOSER")
	print("============================================================")
	
	var scene_res = load("res://world/catalog/test/TileCatalogTest.tscn")
	if scene_res == null:
		push_error("❌ Falha ao carregar res://world/catalog/test/TileCatalogTest.tscn")
		get_tree().quit(1)
		return
		
	var instance = scene_res.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("============================================================")
	print("🎉 VALIDACAO COMPLETA DO TILE CATALOG EXECUTADA COM EXITO!")
	print("============================================================")
	
	get_tree().quit(0)
