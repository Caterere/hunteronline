extends Node

func _ready() -> void:
	print("==================================================")
	print(">>> TESTE: 10 ARQUÉTIPOS DE HATSU & IA JUÍZA <<<")
	print("==================================================")

	var erros: int = 0

	# --- TESTE 1: RECONHECIMENTO E REJEIÇÃO DA IA JUÍZA ---
	print("\n--- TESTE 1: AVALIADOR INTELIGENTE DE ARQUÉTIPOS ---")

	var testes_ia = [
		{"input": "quero conjurar uma arma aleatória estilo crazy slots de kite", "arq_esperado": HatsuData.Arquetipo.ARSENAL_ROLETA, "valido": true},
		{"input": "livro de hatsu para armazenar e roubar habilidades de hunters", "arq_esperado": HatsuData.Arquetipo.LIVRO_COLECAO, "valido": true},
		{"input": "criar um território de en com círculo no chão que desacelera inimigos", "arq_esperado": HatsuData.Arquetipo.TERRITORIO_EN, "valido": true},
		{"input": "preciso tocar 3 vezes no alvo para detonar a marca de nen", "arq_esperado": HatsuData.Arquetipo.MARCA_TAG, "valido": true},
		{"input": "jogar uma moeda de nen: cara velocidade, coroa escudo", "arq_esperado": HatsuData.Arquetipo.OBJETO_MOEDA, "valido": true},
		{"input": "puxar cartas de um baralho de 5 naipes com efeitos de cura e dano", "arq_esperado": HatsuData.Arquetipo.OBJETO_CARTAS, "valido": true},
		{"input": "jogar um dado de 6 faces: face 6 supernova, face 1 zetsu", "arq_esperado": HatsuData.Arquetipo.OBJETO_DADO, "valido": true},
		{"input": "trocar 30% do meu hp por dano aumentado em 100% durante 5 segundos", "arq_esperado": HatsuData.Arquetipo.TROCA_SACRIFICIO, "valido": true},
		{"input": "espada que ganha cargas a cada inimigo derrotado", "arq_esperado": HatsuData.Arquetipo.CONJURACAO_ARMA, "valido": true},
		{"input": "espada de 1000x dano sem custo e invencivel", "rejeitado": true},
		{"input": "sou bonito", "rejeitado": true}
	]

	for t in testes_ia:
		var res = HatsuManager.analisar_juramento_inteligente(t["input"])
		if t.get("rejeitado", false):
			if res.get("rejeitado", false):
				print("✅ [PASS] IA Juíza rejeitou corretamente: '%s'" % t["input"])
			else:
				print("❌ [FAIL] IA Juíza deveria ter rejeitado: '%s'" % t["input"])
				erros += 1
		else:
			if res.get("valido", false) and res.get("arquetipo") == t["arq_esperado"]:
				print("✅ [PASS] Reconheceu Arquétipo %s: '%s'" % [HatsuData.obter_nome_arquetipo(res["arquetipo"]), t["input"]])
			else:
				print("❌ [FAIL] Falha no reconhecimento de: '%s' (Obteve: %s)" % [t["input"], str(res.get("arquetipo"))])
				erros += 1

	# --- TESTE 2: EXECUÇÃO DOS ARQUÉTIPOS EM COMBATE ---
	print("\n--- TESTE 2: EXECUÇÃO DOS ARQUÉTIPOS EM COMBATE ---")
	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)

	var enemy_scn = load("res://entities/Enemy/Enemy.tscn").instantiate()
	add_child(enemy_scn)
	enemy_scn.global_position = player_scn.global_position + Vector2(30, 0)

	var hatsu_sys = player_scn.get_node_or_null("HatsuSystem")
	var combat_sys = player_scn.get_node_or_null("CombatSystem")

	if hatsu_sys != null and combat_sys != null:
		# 1. Roleta / Crazy Slots
		var h_roleta = HatsuManager.criar_hatsu("Crazy Slots", HatsuData.Categoria.CONJURACAO, HatsuData.Forma.TOQUE, [], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.NEN_PURO, HatsuData.Alvo.INIMIGO_UNICO, HatsuData.AlcanceTipo.MEDIO, HatsuData.ConsumoDesejado.MEDIO, "", HatsuData.Arquetipo.ARSENAL_ROLETA)
		PlayerData.equipar_hatsu_slot(0, h_roleta)
		var ok_roleta = hatsu_sys.usar_hatsu(0)
		if ok_roleta and not h_roleta.arma_roleta_atual.is_empty():
			print("✅ [PASS] Roleta executou e sorteou: %s" % h_roleta.arma_roleta_atual.get("nome"))
		else:
			print("❌ [FAIL] Roleta falhou na execução.")
			erros += 1

		# 2. Moeda da Sorte
		var h_moeda = HatsuManager.criar_hatsu("Moeda da Sorte", HatsuData.Categoria.ESPECIALIZACAO, HatsuData.Forma.PESSOAL, [], HatsuData.ObjetivoPrincipal.SUPORTE, HatsuData.Elemento.NEN_PURO, HatsuData.Alvo.PROPRIO_USUARIO, HatsuData.AlcanceTipo.CURTO, HatsuData.ConsumoDesejado.BAIXO, "", HatsuData.Arquetipo.OBJETO_MOEDA)
		PlayerData.equipar_hatsu_slot(1, h_moeda)
		var ok_moeda = hatsu_sys.usar_hatsu(1)
		if ok_moeda:
			print("✅ [PASS] Moeda de Nen lançada e buff aplicado com sucesso.")
		else:
			print("❌ [FAIL] Moeda falhou na execução.")
			erros += 1

		# 3. Dado Místico (1 a 6)
		var h_dado = HatsuManager.criar_hatsu("Risky Dice", HatsuData.Categoria.ESPECIALIZACAO, HatsuData.Forma.PESSOAL, [], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.NEN_PURO, HatsuData.Alvo.PROPRIO_USUARIO, HatsuData.AlcanceTipo.CURTO, HatsuData.ConsumoDesejado.MEDIO, "", HatsuData.Arquetipo.OBJETO_DADO)
		PlayerData.equipar_hatsu_slot(2, h_dado)
		var ok_dado = hatsu_sys.usar_hatsu(2)
		if ok_dado:
			print("✅ [PASS] Dado de Nen rolado com sucesso.")
		else:
			print("❌ [FAIL] Dado falhou.")
			erros += 1

		# 4. Território de En
		var h_ter = HatsuManager.criar_hatsu("Campo de En", HatsuData.Categoria.EMISSAO, HatsuData.Forma.ZONA, [], HatsuData.ObjetivoPrincipal.CONTROLE, HatsuData.Elemento.NEN_PURO, HatsuData.Alvo.AREA, HatsuData.AlcanceTipo.MEDIO, HatsuData.ConsumoDesejado.MEDIO, "", HatsuData.Arquetipo.TERRITORIO_EN)
		PlayerData.equipar_hatsu_slot(3, h_ter)
		var ok_ter = hatsu_sys.usar_hatsu(3)
		if ok_ter:
			print("✅ [PASS] Território de En estabelecido no solo.")
		else:
			print("❌ [FAIL] Território de En falhou.")
			erros += 1

		# 5. Hatsu Evolutivo
		print("\n--- TESTE 3: EVOLUÇÃO DE HATSU (Lv. 1 ao 100) ---")
		var lvl_antes = h_roleta.nivel_evolucao_hatsu
		h_roleta.adicionar_xp_evolucao(120) # Passa de 100 XP
		if h_roleta.nivel_evolucao_hatsu > lvl_antes:
			print("✅ [PASS] Hatsu evoluiu de nível organicamente (%d -> %d)!" % [lvl_antes, h_roleta.nivel_evolucao_hatsu])
		else:
			print("❌ [FAIL] Hatsu não evoluiu.")
			erros += 1

	player_scn.queue_free()
	enemy_scn.queue_free()

	print("\n==================================================")
	if erros == 0:
		print("🎉 TODOS OS TESTES DE ARQUÉTIPOS E IA PASSARAM COM 100% DE SUCESSO!")
	else:
		print("❌ TOTAL DE ERROS: ", erros)
	print("==================================================")
	get_tree().quit(0 if erros == 0 else 1)
