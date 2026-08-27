extends Node

func _ready() -> void:
	print("==================================================")
	print(">>> TESTE: TRANSIÇÕES CINEMATOGRÁFICAS DE ENTRADA <<<")
	print("==================================================")

	var erros: int = 0

	# 1. Teste de Execução Direta do CinematicManager
	print("\n--- 1. TESTE DO CINEMATIC MANAGER & SPLASH CARD ---")
	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)

	var test_ids = ["hisoka", "chrollo", "netero", "meruem", "wing"]
	for tid in test_ids:
		var perfil = CinematicManagerClass.PERFIS_MANGA.get(tid, {})
		if not perfil.is_empty():
			print("✅ [PASS] Perfil encontrado: %s | Subtítulo: %s" % [perfil["nome"], perfil["subtitulo"]])
		else:
			print("❌ [FAIL] Perfil não encontrado para: ", tid)
			erros += 1

	# Testar disparo da cutscene do Hisoka
	CinematicManager.pulou_cutscene = true # Forçar avanço rápido para o teste automatizado
	CinematicManager.tocar_entrada_personagem("hisoka", player_scn)
	await CinematicManager.cutscene_finalizada

	if PlayerData.quest_states.get("cutscene_vista_hisoka", false):
		print("✅ [PASS] Flag de cutscene vista gravada com sucesso em PlayerData.")
	else:
		print("❌ [FAIL] Flag não gravada.")
		erros += 1

	# 2. Teste do CutsceneEncounterTrigger (Gatilho por Proximidade)
	print("\n--- 2. TESTE DO GATILHO POR PROXIMIDADE (SEM APERTAR 'E') ---")
	var trigger_node = CutsceneEncounterTrigger.new()
	trigger_node.character_id = "netero"
	trigger_node.trigger_distance = 100.0
	add_child(trigger_node)
	trigger_node.global_position = player_scn.global_position + Vector2(30, 0) # Dentro do raio de 100px

	CinematicManager.pulou_cutscene = true
	trigger_node._process(0.016)
	await CinematicManager.cutscene_finalizada

	if PlayerData.quest_states.get("cutscene_vista_netero", false):
		print("✅ [PASS] Gatilho de proximidade acionou a cutscene de Netero automaticamente ao aproximar!")
	else:
		print("❌ [FAIL] Gatilho de proximidade não disparou.")
		erros += 1

	trigger_node.queue_free()
	player_scn.queue_free()

	print("\n==================================================")
	if erros == 0:
		print("🎉 SISTEMA DE TRANSIÇÕES CINEMATOGRÁFICAS E ENTRADAS PASSOU COM 100% DE SUCESSO!")
	else:
		print("❌ TOTAL DE ERROS: ", erros)
	print("==================================================")
	get_tree().quit(0 if erros == 0 else 1)
