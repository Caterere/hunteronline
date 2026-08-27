extends SceneTree

func _init() -> void:
	print("--- TESTANDO MODERN INTERIORS SHOWCASE ---")
	var scene = load("res://world/generator/test/ModernInteriorsShowcase.tscn")
	if scene == null:
		print("❌ Erro: Não foi possível carregar ModernInteriorsShowcase.tscn")
		quit(1)
		return
		
	var node = scene.instantiate()
	root.add_child(node)
	
	await process_frame
	
	var chao = node.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	var paredes = node.get_node_or_null("Paredes_TileMapLayer") as TileMapLayer
	var decor = node.get_node_or_null("Decor_TileMapLayer") as TileMapLayer
	
	if chao != null and paredes != null and decor != null:
		print("✅ Todas as 3 camadas de TileMapLayer carregadas com sucesso!")
		print("   - Células de Chão: %d" % chao.get_used_cells().size())
		print("   - Células de Parede: %d" % paredes.get_used_cells().size())
		print("   - Células de Decoração/Móveis: %d" % decor.get_used_cells().size())
	else:
		print("❌ Camadas não encontradas!")
		quit(1)
		return
		
	print("✅ Showcase validado com sucesso!")
	quit(0)
