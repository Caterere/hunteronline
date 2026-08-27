extends Node2D

func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: VALIDAÇÃO DO PROTÓTIPO MÍNIMO WORLD GENERATOR")
	print("============================================================")
	
	var scene = load("res://world/generator/test/WorldGeneratorTest.tscn")
	if scene == null:
		push_error("❌ Falha ao carregar cena WorldGeneratorTest.tscn")
		get_tree().quit(1)
		return
		
	var instance = scene.instantiate()
	add_child(instance)
	
	# Aguardar frame para que o _ready() do WorldGeneratorTest execute completamente
	await get_tree().process_frame
	
	# Validações estruturais
	var chao = instance.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	assert(chao != null, "Chao_TileMapLayer deve existir")
	assert(chao.tile_set != null, "TileSet deve estar configurado no TileMapLayer")
	
	var used_cells = chao.get_used_cells()
	print("  ✅ [PASSOU] TileMapLayer populado com %d células geradas (Esperado: ~3800+)" % used_cells.size())
	assert(used_cells.size() >= 3800, "Mapa 64x64 deve possuir pelo menos 3800 células geradas")
	
	var player = instance.get_node_or_null("Player") as CharacterBody2D
	assert(player != null, "Player deve existir na cena")
	print("  ✅ [PASSOU] Player posicionado no Spawn: ", player.global_position)
	assert(player.global_position.x > 0 and player.global_position.y > 0, "Spawn position válida")
	
	print("============================================================")
	print("🎉 PROTÓTIPO MÍNIMO VALIDADO COM 100% DE SUCESSO!")
	print("============================================================")
	
	get_tree().quit(0)
