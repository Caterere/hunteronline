extends SceneTree

const WorldGeneratorTest = preload("res://world/generator/test/WorldGeneratorTest.gd")

func _init() -> void:
	print("--- EXECUTANDO TESTE DO WORLD GENERATOR ---")
	
	var scene = load("res://world/generator/test/WorldGeneratorTest.tscn")
	if scene == null:
		print("❌ Erro: Não foi possível carregar WorldGeneratorTest.tscn")
		quit(1)
		return
		
	var node = scene.instantiate() as WorldGeneratorTest
	root.add_child(node)
	
	# Aguardar o frame para _ready() completar
	await process_frame
	
	var chao: TileMapLayer = node.get_node_or_null("Chao_TileMapLayer")
	if chao != null:
		var cells = chao.get_used_cells()
		print("✅ Chao_TileMapLayer gerado com %d células ativas no grid." % cells.size())
	else:
		print("❌ Chao_TileMapLayer não encontrado!")
		
	var player = node.get_node_or_null("Player")
	if player != null:
		print("✅ Player encontrado na posição de Spawn: ", player.global_position)
	else:
		print("❌ Player não encontrado na cena!")
		
	print("--- TESTE CONCLUÍDO COM SUCESSO ---")
	quit(0)
