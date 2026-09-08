extends SceneTree

func _init():
	print('=== AUDITANDO CAMADAS DE TILEMAP DO LOBBY ===')
	var lobby_scn = load('res://world/lobby.tscn') as PackedScene
	var lobby = lobby_scn.instantiate()
	for child in lobby.get_children():
		if child is TileMapLayer:
			var used = child.get_used_rect()
			print('Layer: %s -> UsedRect: pos=(%d, %d), size=(%d, %d) [Pixels: (%d, %d) a (%d, %d)]' % [
				child.name, used.position.x, used.position.y, used.size.x, used.size.y,
				used.position.x * 16, used.position.y * 16,
				(used.position.x + used.size.x) * 16, (used.position.y + used.size.y) * 16
			])
	quit(0)
