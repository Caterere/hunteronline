extends SceneTree

func _init():
	print('=== TESTANDO INSTANCIAÇÃO DE LOBBY COM LOBBY.GD ===')
	var lobby_scn = load('res://world/lobby.tscn') as PackedScene
	var lobby = lobby_scn.instantiate()
	var script = load('res://world/Lobby.gd')
	lobby.set_script(script)
	
	# Simular PlayerData pronto para passar pelo guard de can_enter_lobby
	var pdata = root.get_node_or_null('PlayerData')
	if pdata:
		pdata.is_character_ready = true
		pdata.nome_personagem = 'Test Hunter'
		pdata.attributes = {
			'vida': 100, 'vida_max': 100,
			'forca': 10, 'defesa': 10, 'velocidade': 10,
			'aura': 100.0, 'aura_max': 100.0,
			'nivel_nen': 1, 'xp_nen': 0, 'nivel': 1, 'gold': 100
		}
	var gm = root.get_node_or_null('GameManager')
	if gm:
		gm.set_flow_state(gm.GameFlowState.LOBBY)
		gm.change_state(gm.GameState.IN_GAME)
		
	root.add_child(lobby)
	print('Nós filhos gerados no Lobby:')
	for child in lobby.get_children():
		print('  - ', child.name, ' (', child.get_class(), ') em pos: ', child.position if child is Node2D else 'N/A')
	lobby.queue_free()
	quit(0)
