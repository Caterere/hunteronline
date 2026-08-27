extends Node2D

const RegionConfig = preload("res://resource/world/RegionConfig.gd")
const RegionWorldGenerator = preload("res://world/generator/RegionWorldGenerator.gd")
const WorldValidator = preload("res://world/generator/WorldValidator.gd")

func _ready() -> void:
	print("============================================================")
	print("EXECUTANDO VALIDADOR AUTOMATIZADO DA PRIMEIRA REGIÃO REAL")
	print("============================================================")
	
	var gen = RegionWorldGenerator.new()
	gen.name = "RegionWorldGeneratorInstance"
	
	# Criar camadas TileMapLayer
	var chao = TileMapLayer.new()
	chao.name = "Chao_TileMapLayer"
	gen.add_child(chao)
	
	var paredes = TileMapLayer.new()
	paredes.name = "Paredes_TileMapLayer"
	gen.add_child(paredes)
	
	var decor = TileMapLayer.new()
	decor.name = "Decor_TileMapLayer"
	gen.add_child(decor)
	
	var loader = WorldChunkLoader.new()
	loader.name = "WorldChunkLoader"
	gen.add_child(loader)
	
	add_child(gen)
	
	# Aguardar frame para que o _ready() execute e gere o mundo
	await get_tree().process_frame
	
	var report = WorldValidator.validar_regiao(gen)
	
	if report.is_valid():
		print("\n🎉 PARABÉNS! TODOS OS CRITÉRIOS DE VALIDAÇÃO DO MUNDO FORAM ATENDIDOS!")
	else:
		push_error("\n❌ ERRO NA VALIDAÇÃO DO MUNDO!")
		
	get_tree().quit(0 if report.is_valid() else 1)
