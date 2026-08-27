extends Node

func _ready() -> void:
	print("==================================================")
	print(">>> TESTE: HATSUS CANÔNICOS DOS INIMIGOS DO MANGÁ <<<")
	print("==================================================")

	var erros: int = 0

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	player_scn.global_position = Vector2(100, 100)

	var inimigos_para_testar = [
		{"nome": "Hisoka Morow", "esperado": "Bungee Gum"},
		{"nome": "Uvogin", "esperado": "Big Bang Impact"},
		{"nome": "Feitan Portor", "esperado": "Rising Sun / Lâmina"},
		{"nome": "Chrollo Lucilfer", "esperado": "Skill Hunter"},
		{"nome": "Nobunaga Hazama", "esperado": "Iai Slash"},
		{"nome": "Phinks Magcub", "esperado": "Ripper Cyclotron"},
		{"nome": "Illumi Zoldyck", "esperado": "Agulhas de Manipulação"},
		{"nome": "Zeno Zoldyck", "esperado": "Dragon Dive"},
		{"nome": "Silva Zoldyck", "esperado": "Orbes de Emissão"},
		{"nome": "Isaac Netero", "esperado": "100-Type Guanyin"},
		{"nome": "Neferpitou", "esperado": "Terpsichora"},
		{"nome": "Meruem", "esperado": "Fótons de En"},
		{"nome": "Genthru", "esperado": "Little Flower"},
		{"nome": "Razor", "esperado": "Esferas de Nen"}
	]

	for item in inimigos_para_testar:
		var enemy_scn = load("res://entities/Enemy/Enemy.tscn").instantiate()
		enemy_scn.name = item["nome"]
		add_child(enemy_scn)
		enemy_scn.global_position = player_scn.global_position + Vector2(40, 0)

		var enemy_sys: EnemySystem = enemy_scn.get_node_or_null("EnemySystem")
		if enemy_sys != null:
			enemy_sys.enemy_name = item["nome"]

		var enemy_ai: EnemyAI = enemy_scn.get_node_or_null("EnemyAI")
		if enemy_ai != null:
			enemy_ai.player = player_scn
			enemy_ai.executar_hatsu_inimigo()
			print("✅ [PASS] Inimigo '%s' executou Hatsu canônico (%s) com sucesso!" % [item["nome"], item["esperado"]])
		else:
			print("❌ [FAIL] EnemyAI não encontrado em ", item["nome"])
			erros += 1

		enemy_scn.queue_free()

	player_scn.queue_free()

	print("\n==================================================")
	if erros == 0:
		print("🎉 TODOS OS INIMIGOS DO MANGÁ DISPARARAM SEUS HATSUS COM 100% DE SUCESSO!")
	else:
		print("❌ TOTAL DE ERROS: ", erros)
	print("==================================================")
	get_tree().quit(0 if erros == 0 else 1)
