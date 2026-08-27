extends Node

func _ready() -> void:
	print("==================================================")
	print(">>> EXECUTANDO SUITE COMPLETA DE TESTES GLOBAIS <<<")
	print("==================================================")

	var erros: int = 0

	# 1. TESTE DE TODAS AS CENAS DO PROJETO
	print("\n--- 1. VERIFICANDO CARREGAMENTO DE TODAS AS CENAS ---")
	var cenas_testar = [
		"res://world/Lobby.tscn",
		"res://world/maps/WhaleIsland.tscn",
		"res://world/maps/ZabanCity.tscn",
		"res://world/maps/NumereSwamp.tscn",
		"res://world/maps/TrickTower.tscn",
		"res://world/maps/ZevilIsland.tscn",
		"res://world/maps/KukurooMountain.tscn",
		"res://world/maps/HeavensArena.tscn",
		"res://world/maps/YorknewCity.tscn",
		"res://world/maps/GreedIsland.tscn",
		"res://world/maps/CelestialTowerArena.tscn",
		"res://entities/Player/Player.tscn",
		"res://entities/Enemy/Enemy.tscn",
		"res://ui/HUD.tscn",
		"res://ui/Hatsu/HatsuCreationUI.tscn"
	]

	for c_path in cenas_testar:
		if ResourceLoader.exists(c_path):
			var res = load(c_path)
			if res is PackedScene:
				var node = res.instantiate()
				if node != null:
					add_child(node)
					print("✅ [OK] Cena carregada com sucesso: ", c_path.get_file())
					node.queue_free()
				else:
					print("❌ [FAIL] Erro ao instanciar: ", c_path)
					erros += 1
			else:
				print("❌ [FAIL] Não é PackedScene: ", c_path)
				erros += 1

	# 2. TESTE DE INTERAÇÃO DO COMBATE COM HATSU & JURAMENTOS
	print("\n--- 2. TESTE DE COMBATE COM JURAMENTOS ---")
	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn").instantiate()

	add_child(enemy_scn)
	enemy_scn.global_position = player_scn.global_position + Vector2(30, 0)

	var hatsu_sys = player_scn.get_node_or_null("HatsuSystem")
	var combat_sys = player_scn.get_node_or_null("CombatSystem")
	var nen_sys = player_scn.get_node_or_null("NenSystem")

	if hatsu_sys != null and combat_sys != null and nen_sys != null:
		print("✅ [PASS] Sistemas essenciais encontrados no Player.")

		# Despertar Nen e inicializar aura para testes de Hatsu
		PlayerData.despertou_nen = true
		PlayerData.aplicar_nivel_nen(5)
		PlayerData.attributes["aura"] = PlayerData.attributes["aura_max"]
		nen_sys.sincronizar_nen_com_player_data()


		# Criar e equipar Hatsu de Voto do Retorno
		var h_retorno = HatsuManager.criar_hatsu(
			"Vingança de Nen", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE,
			[HatsuData.Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO]
		)
		PlayerData.equipar_hatsu_slot(0, h_retorno)


		# Tentar usar ANTES de ser atacado -> DEVE FALHAR
		var usou_antes = hatsu_sys.usar_hatsu(0)
		if not usou_antes:
			print("✅ [PASS] Hatsu bloqueado corretamente pois o jogador ainda não foi atacado.")
		else:
			print("❌ [FAIL] Hatsu ativou indevidamente antes do ataque!")
			erros += 1

		# Simular ataque do inimigo
		combat_sys.receber_dano(10, Vector2.LEFT, 0.0, enemy_scn)

		# Tentar usar DEPOIS de ser atacado -> DEVE FUNCIONAR
		var usou_depois = hatsu_sys.usar_hatsu(0)
		if usou_depois:
			print("✅ [PASS] Hatsu executou com sucesso após o ataque do inimigo!")
		else:
			print("❌ [FAIL] Hatsu não disparou após o ataque do inimigo!")
			erros += 1

		# Criar e equipar Hatsu com Zetsu Pós-Uso 15s
		var h_zetsu = HatsuManager.criar_hatsu(
			"Golpe do Esgotamento", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE,
			[HatsuData.Condicao.ZETSU_POS_USO_15S]
		)
		PlayerData.equipar_hatsu_slot(1, h_zetsu)
		hatsu_sys.usar_hatsu(1)

		# Verificar se o jogador entrou em Zetsu forçado
		if hatsu_sys.zetsu_forcado_ativo():
			print("✅ [PASS] Estado forçado de Zetsu pós-uso ativo com sucesso (15s).")
		else:
			print("❌ [FAIL] Zetsu pós-uso não ativou!")
			erros += 1

		# Tentar ativar Ren durante Zetsu forçado -> DEVE SER BLOQUEADO
		var tentou_ren = nen_sys.ativar_tecnica(NenSystem.Tecnica.REN)
		if not tentou_ren:
			print("✅ [PASS] Ativação de Ren bloqueada com sucesso durante Zetsu forçado.")
		else:
			print("❌ [FAIL] Ren ativou indevidamente durante Zetsu forçado!")
			erros += 1
	else:
		print("❌ [FAIL] Falha ao encontrar componentes no Player.")
		erros += 1

	player_scn.queue_free()
	enemy_scn.queue_free()

	print("\n==================================================")
	if erros == 0:
		print("🎉 SUITE COMPLETA CONCLUÍDA COM 100% DE SUCESSO! 0 ERROS.")
	else:
		print("❌ TOTAL DE ERROS NA SUITE: ", erros)
	print("==================================================")
	get_tree().quit(0 if erros == 0 else 1)
