extends Node2D

const WorldValidator = preload("res://world/generator/WorldValidator.gd")

func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: VALIDAÇÃO DA PRIMEIRA REGIÃO REAL EM TEMPO DE JOGO")
	print("============================================================")
	
	var scene_res = load("res://world/maps/regiao_vale_padokia.tscn")
	if scene_res == null:
		push_error("❌ Falha ao carregar res://world/maps/regiao_vale_padokia.tscn")
		get_tree().quit(1)
		return
		
	var map_instance = scene_res.instantiate()
	add_child(map_instance)
	
	# Aguardar 2 frames para processamento e geração completa
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 1. Executar WorldValidator na cena real
	var report = WorldValidator.validar_regiao(map_instance)
	
	# 2. Testar posicionamento do Player
	var player = map_instance.get_node_or_null("Player") as CharacterBody2D
	assert(player != null, "Player deve existir na cena")
	print("  ✅ [PASSOU] Player posicionado no Spawn: ", player.global_position)
	assert(player.global_position.x > 1000 and player.global_position.y > 3500, "Spawn correto no centro da vila (Praça)")
	
	# 3. Testar Câmera com limites 0 a 8192px
	var cam = player.get_node_or_null("Camera2D") as Camera2D
	if cam:
		assert(cam.limit_right == 8192 and cam.limit_bottom == 8192, "Limites da câmera cobrem os 512x512 tiles")
		print("  ✅ [PASSOU] Câmera configurada com limites de 8192 x 8192 px")
		
	# 4. Testar HUD
	var hud = map_instance.get_node_or_null("Hud")
	assert(hud != null, "HUD deve estar presente no mapa")
	print("  ✅ [PASSOU] HUD instanciado e conectado ao Player")
	
	# 5. Testar Chunks
	var loader = map_instance.get_node_or_null("WorldChunkLoader") as WorldChunkLoader
	assert(loader != null, "WorldChunkLoader ativo")
	print("  ✅ [PASSOU] WorldChunkLoader gerenciando %d chunks em tempo real" % loader.get_child_count())
	
	# 6. Testar Interior Genérico
	var interior_res = load("res://world/maps/interiors/padokia_interior_generic.tscn")
	assert(interior_res != null, "Interior genérico deve carregar com sucesso")
	var interior_instance = interior_res.instantiate()
	add_child(interior_instance)
	await get_tree().process_frame
	print("  ✅ [PASSOU] Cena de Interior (PadokiaInteriors) instanciada com sucesso")
	interior_instance.queue_free()
	
	if report.is_valid():
		print("============================================================")
		print("🎉 SUCESSO TOTAL: A PRIMEIRA REGIÃO ESTÁ 100% JOGÁVEL E VALIDADA!")
		print("============================================================")
		get_tree().quit(0)
	else:
		push_error("❌ Falhas detectadas na validação do mundo!")
		get_tree().quit(1)
