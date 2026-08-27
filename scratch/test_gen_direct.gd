extends SceneTree

const RegionConfig = preload("res://resource/world/RegionConfig.gd")
const RegionWorldGenerator = preload("res://world/generator/RegionWorldGenerator.gd")
const WorldValidator = preload("res://world/generator/WorldValidator.gd")

func _init() -> void:
	print("--- TEST DIRECT GEN INICIANDO ---")
	var t0 = Time.get_ticks_msec()
	
	var gen = RegionWorldGenerator.new()
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
	
	root.add_child(gen)
	print("--- GERACAO CONCLUIDA EM %d ms ---" % (Time.get_ticks_msec() - t0))
	
	var report = WorldValidator.validar_regiao(gen)
	print("--- VALIDATION REPORT: %s (%d ms) ---" % [report.is_valid(), Time.get_ticks_msec() - t0])
	quit(0 if report.is_valid() else 1)
