extends SceneTree

func _init() -> void:
	print("--- DETALHES DE LAYOUT DOS SPRITES DE PERSONAGEM ---")
	
	# 1. Player canônico atual (player.png)
	var tex_player = load("res://assets/sprites/characters/player.png") as Texture2D
	print("Player atual (player.png):")
	print("  Tamanho total: %d x %d px" % [tex_player.get_width(), tex_player.get_height()])
	print("  Frames: hframes=6, vframes=10 -> Cada frame = %d x %d px" % [tex_player.get_width() / 6, tex_player.get_height() / 10])
	
	# 2. Personagens Modern Interiors (Adam_16x16.png)
	var tex_adam = load("res://assets/sprites/tilesets/Modern_Interiors_Free_v2.2/Modern tiles_Free/Characters_free/Adam_16x16.png") as Texture2D
	print("Modern Interiors (Adam_16x16.png):")
	print("  Tamanho total: %d x %d px" % [tex_adam.get_width(), tex_adam.get_height()])
	print("  Frames: 24 colunas de 16px x 7 linhas de 32px (6 frames por direção: Down, Up, Left, Right)")
	
	quit()
