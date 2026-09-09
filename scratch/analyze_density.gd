extends SceneTree

func _init() -> void:
	print("\n==============================================================")
	print(" ANÁLISE DETALHADA DO PLAYER.PNG — REFERÊNCIA DE DENSIDADE")
	print("==============================================================\n")
	
	var img = Image.load_from_file("res://assets/sprites/characters/player.png")
	if img == null:
		print("ERRO: player.png não encontrado")
		quit(1)
		return
	
	print("Dimensões: %d x %d" % [img.get_width(), img.get_height()])
	print("Formato: %s" % img.get_format())
	
	var FW = 48
	var FH = 48
	var cols = img.get_width() / FW
	var rows = img.get_height() / FH
	print("Grid: %d colunas x %d linhas = %d frames" % [cols, rows, cols * rows])
	
	# Analisar o frame 0 (idle south, frame 0) em detalhe
	print("\n--- ANÁLISE DO FRAME 0 (idle_south_0) ---")
	var frame0 = img.get_region(Rect2i(0, 0, FW, FH))
	
	var opaque_pixels = 0
	var colors: Dictionary = {}
	var min_x = FW
	var max_x = 0
	var min_y = FH
	var max_y = 0
	
	for y in range(FH):
		for x in range(FW):
			var c = frame0.get_pixel(x, y)
			if c.a > 0.1:
				opaque_pixels += 1
				var hex = c.to_html(false)
				colors[hex] = colors.get(hex, 0) + 1
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)
	
	print("  Pixels opacos: %d / %d (%.1f%%)" % [opaque_pixels, FW * FH, 100.0 * opaque_pixels / (FW * FH)])
	print("  Bounding box: x=[%d..%d] y=[%d..%d] → %dx%d" % [min_x, max_x, min_y, max_y, max_x - min_x + 1, max_y - min_y + 1])
	print("  Cores únicas: %d" % colors.size())
	
	# Ordenar cores por frequência
	var sorted_colors: Array = []
	for hex in colors:
		sorted_colors.append([hex, colors[hex]])
	sorted_colors.sort_custom(func(a, b): return a[1] > b[1])
	
	print("\n  PALETA COMPLETA (por frequência):")
	for entry in sorted_colors:
		var hex = entry[0]
		var count = entry[1]
		print("    #%s → %d pixels" % [hex, count])
	
	# Analisar distribuição por região do corpo
	print("\n  DISTRIBUIÇÃO POR REGIÃO:")
	var head_pixels = 0
	var body_pixels = 0
	var legs_pixels = 0
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var c = frame0.get_pixel(x, y)
			if c.a > 0.1:
				if y < min_y + 10:
					head_pixels += 1
				elif y < min_y + 17:
					body_pixels += 1
				else:
					legs_pixels += 1
	print("    Cabeça (top 10px): %d pixels" % head_pixels)
	print("    Corpo (meio 7px): %d pixels" % body_pixels)
	print("    Pernas (restante): %d pixels" % legs_pixels)
	
	# Imprimir o frame como grid visual
	print("\n  GRID VISUAL DO FRAME 0 (. = transparente, # = pixel):")
	for y in range(min_y, max_y + 1):
		var row = "    "
		for x in range(min_x, max_x + 1):
			var c = frame0.get_pixel(x, y)
			if c.a > 0.1:
				row += "#"
			else:
				row += "."
		print(row + "  (y=%d)" % y)
	
	# Agora analisar um NPC gerado para comparação
	print("\n\n--- COMPARAÇÃO: NPC_GON_8DIR.PNG (frame 0) ---")
	var npc_img = Image.load_from_file("res://assets/sprites/characters/npc_gon_8dir.png")
	if npc_img != null:
		var npc_frame = npc_img.get_region(Rect2i(0, 0, FW, FH))
		var npc_opaque = 0
		var npc_colors: Dictionary = {}
		var npc_min_x = FW
		var npc_max_x = 0
		var npc_min_y = FH
		var npc_max_y = 0
		
		for y in range(FH):
			for x in range(FW):
				var c = npc_frame.get_pixel(x, y)
				if c.a > 0.1:
					npc_opaque += 1
					var hex = c.to_html(false)
					npc_colors[hex] = npc_colors.get(hex, 0) + 1
					npc_min_x = min(npc_min_x, x)
					npc_max_x = max(npc_max_x, x)
					npc_min_y = min(npc_min_y, y)
					npc_max_y = max(npc_max_y, y)
		
		print("  Pixels opacos: %d" % npc_opaque)
		print("  Bounding box: %dx%d" % [npc_max_x - npc_min_x + 1, npc_max_y - npc_min_y + 1])
		print("  Cores únicas: %d" % npc_colors.size())
		print("  Ratio vs Player: %.2fx pixels" % [float(npc_opaque) / float(opaque_pixels)])
		
		print("\n  GRID VISUAL DO FRAME GON (. = transparente, # = pixel):")
		for y in range(npc_min_y, npc_max_y + 1):
			var row = "    "
			for x in range(npc_min_x, npc_max_x + 1):
				var c = npc_frame.get_pixel(x, y)
				if c.a > 0.1:
					row += "#"
				else:
					row += "."
			print(row + "  (y=%d)" % y)
	
	print("\n==============================================================")
	print(" ANÁLISE CONCLUÍDA")
	print("==============================================================")
	quit(0)
