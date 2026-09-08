extends SceneTree

func _init():
	print('=== TESTANDO CARREGAMENTO DO LOBBY ===')
	var lobby_scn = load('res://world/lobby.tscn') as PackedScene
	if lobby_scn == null:
		print('ERRO: Falha ao carregar lobby.tscn')
		quit(1)
		return
	var inst = lobby_scn.instantiate()
	print('Nome do nó raiz: ', inst.name)
	print('Script do nó raiz: ', inst.get_script())
	print('Filhos do nó raiz: ')
	for child in inst.get_children():
		print('  - ', child.name, ' (', child.get_class(), ')')
	quit(0)
