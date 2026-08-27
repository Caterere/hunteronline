extends SceneTree

func _init() -> void:
	print("--- TESTANDO CARREGAMENTO DE TODOS OS 9 MAPAS ---")
	
	var mapas = [
		{"arco": 1, "path": "res://world/maps/exame_maratona.tscn"},
		{"arco": 2, "path": "res://world/maps/montanha_kukuroo.tscn"},
		{"arco": 3, "path": "res://world/maps/arena_celestial.tscn"},
		{"arco": 4, "path": "res://world/maps/yorknew_city.tscn"},
		{"arco": 5, "path": "res://world/maps/greed_island.tscn"},
		{"arco": 6, "path": "res://world/maps/ngl_formigas.tscn"},
		{"arco": 7, "path": "res://world/maps/associacao_hunter.tscn"},
		{"arco": 8, "path": "res://world/maps/continente_negro.tscn"},
		{"arco": 9, "path": "res://world/maps/black_whale_1.tscn"},
	]

	for item in mapas:
		var scn = load(item["path"])
		if scn == null:
			printerr("ERRO: Falha ao carregar ", item["path"])
			continue
			
		var inst = scn.instantiate()
		if inst == null:
			printerr("ERRO: Falha ao instanciar ", item["path"])
			continue
			
		root.add_child(inst)
		
		# Verificar se o nó raiz possui script
		var scr = inst.get_script()
		var scr_name = scr.resource_path if scr else "SEM SCRIPT"
		print("✅ Arco %d (%s): Carregado com sucesso | Script: %s" % [item["arco"], item["path"].get_file(), scr_name.get_file()])
		
		inst.queue_free()

	print("--- TESTE CONCLUÍDO COM SUCESSO ---")
	quit()
