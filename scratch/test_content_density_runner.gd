extends Node2D

func _ready() -> void:
	print("============================================================")
	print("RUNNER DE TESTE AUTOMATIZADO: CONTENT DENSITY SYSTEM")
	print("============================================================")
	
	var scene_res = load("res://world/content/test/ContentDensityTest.tscn")
	assert(scene_res != null, "Cena ContentDensityTest.tscn deve carregar com sucesso")
	
	var instance = scene_res.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var director = instance.get_node_or_null("ContentDirector")
	assert(director != null, "ContentDirector deve estar ativo na cena")
	
	var overlay = instance.get_node_or_null("ContentDebugOverlay")
	assert(overlay != null, "ContentDebugOverlay deve estar presente")
	
	var metrics = director.get_debug_metrics()
	print("  ✅ [PASSOU] Métricas ao vivo do ContentDirector: ", metrics)
	assert(metrics.get("registered_pois", 0) >= 6, "POIs registrados com sucesso")
	assert(metrics.get("active_npcs", 0) >= 5, "NPCs da vila instanciados")
	
	print("============================================================")
	print("🎉 VALIDACAO COMPLETA DO CONTENT DENSITY SYSTEM EXECUTADA!")
	print("============================================================")
	get_tree().quit(0)
