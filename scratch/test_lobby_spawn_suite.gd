extends Node2D

func _ready():
	print('=== TESTANDO LOBBY COM AUTOLOADS ATIVOS ===')
	var lobby_scn = load('res://world/lobby.tscn') as PackedScene
	print('lobby_scn carregado: ', lobby_scn != null)
	var lobby = lobby_scn.instantiate()
	var script = load('res://world/Lobby.gd')
	lobby.set_script(script)
	
	if PlayerData != null:
		PlayerData.is_character_ready = true
		PlayerData.nome_personagem = 'Test Hunter'
		PlayerData.attributes = {
			'vida': 100, 'vida_max': 100,
			'forca': 10, 'defesa': 10, 'velocidade': 10,
			'aura': 100.0, 'aura_max': 100.0,
			'nivel_nen': 1, 'xp_nen': 0, 'nivel': 1, 'gold': 100
		}
	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.LOBBY)
		GameManager.change_state(GameManager.GameState.IN_GAME)
		
	add_child(lobby)
	print('Total de nós filhos no Lobby após _ready(): ', lobby.get_child_count())
	for child in lobby.get_children():
		print('  - ', child.name, ' (', child.get_class(), ')')
	get_tree().quit(0)
