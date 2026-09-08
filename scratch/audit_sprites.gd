extends SceneTree

func _init():
	print('=== AUDITANDO SPRITES DE PERSONAGENS ===')
	var paths = [
		'res://assets/sprites/characters/player.png',
		'res://assets/sprites/characters/npc_recepcionista_elena_8dir.png',
		'res://assets/sprites/characters/npc_instrutor_combate_8dir.png',
		'res://assets/sprites/characters/npc_examinador_oficial_8dir.png',
		'res://assets/sprites/characters/npc_ferreiro_mestre_8dir.png',
		'res://assets/sprites/characters/npc_vendedor_mercador_8dir.png',
		'res://assets/sprites/characters/npc_discipulo_zushi_8dir.png',
		'res://assets/sprites/characters/npc_guarda_fronteira_8dir.png',
		'res://assets/sprites/characters/npc_viajante_scout_8dir.png'
	]
	
	for path in paths:
		var img = Image.load_from_file(ProjectSettings.globalize_path(path))
		if img == null:
			print('Falha ao carregar: ', path)
			continue
		var is_player = path.ends_with('player.png')
		var frame_w = 48 if is_player else 68
		var frame_h = 48 if is_player else 68
		
		# Pegar primeiro frame (olhando para baixo / sul)
		var frame_img = img.get_region(Rect2i(0, 0, frame_w, frame_h))
		# Encontrar bounding box de pixels não transparentes
		var min_x = frame_w
		var max_x = -1
		var min_y = frame_h
		var max_y = -1
		for y in range(frame_h):
			for x in range(frame_w):
				if frame_img.get_pixel(x, y).a > 0.05:
					if x < min_x: min_x = x
					if x > max_x: max_x = x
					if y < min_y: min_y = y
					if y > max_y: max_y = y
		
		var opaque_w = (max_x - min_x + 1) if max_x >= min_x else 0
		var opaque_h = (max_y - min_y + 1) if max_y >= min_y else 0
		print('%s -> Total: %dx%d, Frame: %dx%d, BBox: [%d,%d -> %d,%d] => Largura: %d, Altura: %d' % [
			path.get_file(), img.get_width(), img.get_height(), frame_w, frame_h, min_x, min_y, max_x, max_y, opaque_w, opaque_h
		])
	quit(0)
