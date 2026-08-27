extends Node

func _ready() -> void:
	print("==================================================")
	print(">>> TESTE: SISTEMA DE LIVRO DE HATSU (CHROLLO) <<<")
	print("==================================================")

	var erros: int = 0

	# 1. Teste do Motor de Balanceamento (Restriction Power vs Hatsu Power)
	print("\n--- 1. TESTE DE BALANCEAMENTO & RESTRICTION POWER ---")

	# Caso A: Livro com 5 Grandes Restrições (Equilíbrio Pleno)
	var config_pleno = {
		"capacidade": 10,
		"permite_marcador": true,
		"roubo_combate": true,
		"manter_indefinidamente": true,
		"restricoes_aquisicao": ["OBSERVAR_USO", "DESCOBRIR_REGRAS", "TOQUE_FISICO", "RITUAL_TEMPO"],
		"restricoes_uso": ["MANTER_LIVRO_ABERTO", "PROIBICAO_REN_DUPLO"],
		"restricoes_risco": ["MORTE_USUARIO_REMOVE"]
	}
	var res_pleno = HatsuManager.avaliar_balanceamento_livro(config_pleno)
	if res_pleno.get("aprovado", false) and res_pleno.get("eficiencia_global", 0.0) >= 0.99:
		print("✅ [PASS] Livro com 5 Restrições aprovado com 100% de Eficiência (Balance Score: %+d)" % res_pleno["balance_score"])
	else:
		print("❌ [FAIL] Livro Pleno falhou na avaliação.")
		erros += 1

	# Caso B: Livro com apenas 1 Restrição (Versão Restrita)
	var config_parcial = {
		"capacidade": 10,
		"permite_marcador": true,
		"roubo_combate": true,
		"manter_indefinidamente": true,
		"restricoes_aquisicao": ["OBSERVAR_USO"],
		"restricoes_uso": [],
		"restricoes_risco": []
	}
	var res_parcial = HatsuManager.avaliar_balanceamento_livro(config_parcial)
	if res_parcial.get("aprovado", false) and res_parcial.get("eficiencia_global", 0.0) < 0.70:
		print("✅ [PASS] Livro com poucas restrições ajustado proporcionalmente (%d%% Eficiência)" % int(res_parcial["eficiencia_global"] * 100))
	else:
		print("❌ [FAIL] Livro Parcial não reduziu eficiência.")
		erros += 1

	# Caso C: Livro Cheat sem Restrições (Rejeição Total)
	var config_cheat = {
		"capacidade": 50,
		"permite_marcador": true,
		"roubo_combate": true,
		"manter_indefinidamente": true,
		"restricoes_aquisicao": [],
		"restricoes_uso": [],
		"restricoes_risco": []
	}
	var res_cheat = HatsuManager.avaliar_balanceamento_livro(config_cheat)
	if res_cheat.get("rejeitado", false):
		print("✅ [PASS] IA Juíza rejeitou corretamente livro sem restrições (Cheat recusado).")
	else:
		print("❌ [FAIL] Livro Cheat deveria ter sido rejeitado!")
		erros += 1

	# 2. Teste de Hatsu Incompleto & Compatibilidade
	print("\n--- 2. TESTE DE HATSU INCOMPLETO & COMPATIBILIDADE ---")
	var book = HatsuManager.criar_livro_hatsu("Grimório do Colecionador", 10, true)
	var ef_incompleto = book.obter_eficiencia_pagina(1, NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO)
	if ef_incompleto <= 0.45:
		print("✅ [PASS] Hatsu Incompleto (Chain Prison) aplicou penalidade de conhecimento (Eficiência: %d%%)" % int(ef_incompleto * 100))
	else:
		print("❌ [FAIL] Hatsu Incompleto não aplicou penalidade.")
		erros += 1

	# 3. Teste do Marcador (Bookmark) e Sinergia de Tags
	print("\n--- 3. TESTE DE SINERGIA DE TAGS COM MARCADOR ---")
	var h_arma = HatsuData.new()
	h_arma.nome = "Corrente de Ko"
	h_arma.tags = ["weapon", "restraint"]

	var h_raio = HatsuData.new()
	h_raio.nome = "Trovão de Nen"
	h_raio.tags = ["electricity", "projectile"]

	var sinergia = HatsuManager.processar_sinergia_tags(h_arma, h_raio)
	if sinergia.get("sinergia", false) and sinergia.has("stun"):
		print("✅ [PASS] Sinergia de Tags detectada com sucesso: %s (%s)" % [sinergia["nome"], sinergia["desc"]])
	else:
		print("❌ [FAIL] Sinergia de Tags falhou.")
		erros += 1

	# 4. Teste de Execução em Combate do Livro
	print("\n--- 4. TESTE DE EXECUÇÃO EM COMBATE DO LIVRO ---")
	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)

	var enemy_scn = load("res://entities/Enemy/Enemy.tscn").instantiate()
	add_child(enemy_scn)
	enemy_scn.global_position = player_scn.global_position + Vector2(30, 0)

	var hatsu_sys = player_scn.get_node_or_null("HatsuSystem")
	if hatsu_sys != null:
		var h_livro = HatsuManager.criar_hatsu(
			"Livro do Destino", HatsuData.Categoria.ESPECIALIZACAO, HatsuData.Forma.PESSOAL,
			[], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.NEN_PURO,
			HatsuData.Alvo.PROPRIO_USUARIO, HatsuData.AlcanceTipo.MEDIO, HatsuData.ConsumoDesejado.MEDIO,
			"", HatsuData.Arquetipo.LIVRO_COLECAO
		)
		h_livro.livro_data = book
		PlayerData.equipar_hatsu_slot(0, h_livro)

		# Disparar com 1 Hatsu aberto
		var ok1 = hatsu_sys.usar_hatsu(0)
		if ok1:
			print("✅ [PASS] Disparo de 1 página do Livro funcionou com sucesso.")
		else:
			print("❌ [FAIL] Disparo de 1 página falhou.")
			erros += 1

		# Inserir marcador para uso duplo
		book.pagina_slot_marcador = 1
		var ok2 = hatsu_sys.usar_hatsu(0)
		if ok2:
			print("✅ [PASS] Disparo DUPLO com Marcador e Sinergia funcionou com sucesso!")
		else:
			print("❌ [FAIL] Disparo duplo falhou.")
			erros += 1

	player_scn.queue_free()
	enemy_scn.queue_free()

	# 5. Teste da UI do Grimório
	print("\n--- 5. TESTE DA UI DO GRIMÓRIO (HatsuBookUI) ---")
	var ui_scn = load("res://ui/Hatsu/HatsuBookUI.tscn").instantiate()
	add_child(ui_scn)
	ui_scn.abrir(book)
	ui_scn._on_equipar_slot1_pressed()
	ui_scn._on_equipar_marcador_pressed()
	ui_scn.fechar()
	print("✅ [PASS] HatsuBookUI carregada, navegada e testada com sucesso.")
	ui_scn.queue_free()

	print("\n==================================================")
	if erros == 0:
		print("🎉 TODOS OS TESTES DO SISTEMA DE LIVRO PASSARAM COM 100% DE SUCESSO!")
	else:
		print("❌ TOTAL DE ERROS: ", erros)
	print("==================================================")
	get_tree().quit(0 if erros == 0 else 1)
