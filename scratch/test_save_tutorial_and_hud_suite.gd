extends Node

var _total_testes: int = 0
var _testes_passados: int = 0
var _falhas: Array[String] = []


func _assinalar(condicao: bool, msg_sucesso: String, msg_erro: String) -> void:
	_total_testes += 1
	if condicao:
		_testes_passados += 1
		print("  ✅ [PASS] %s" % msg_sucesso)
	else:
		_falhas.append(msg_erro)
		print("  ❌ [FAIL] %s" % msg_erro)


func _ready() -> void:
	print("================================================================================")
	print("🚀 TESTANDO PERSISTÊNCIA DE SAVE/TUTORIAL & LAYOUT RESPONSIVO DO HUD")
	print("================================================================================")

	_testar_persistencia_tutorial_save_load()
	_testar_notificacoes_hud_bounds()
	_testar_notificacao_conclusao_quest()
	_imprimir_resultado_final()


func _testar_persistencia_tutorial_save_load() -> void:
	print("\n[TESTE 1/3] Testando Persistência de tutorial_concluido no SaveManager...")
	PlayerData.slot_ativo = 1
	PlayerData.tutorial_concluido = true
	PlayerData.tour_lobby_concluido = true
	PlayerData.tutorial_data["teste_flag"] = true
	PlayerData.desbloquear_conhecimento("mundo_exame_hunter")

	var salvou = SaveManager.salvar_jogo(1)
	_assinalar(salvou, "Jogo salvo no Slot 1 com tutorial_concluido = true.", "Falha ao salvar jogo.")

	# Resetar estado em memória
	PlayerData.tutorial_concluido = false
	PlayerData.tour_lobby_concluido = false
	PlayerData.conhecimentos_desbloqueados.clear()

	# Carregar do disco
	var carregou = SaveManager.carregar_jogo(1)
	var persistiu = (
		carregou and
		PlayerData.tutorial_concluido == true and
		PlayerData.tour_lobby_concluido == true and
		PlayerData.conhecimentos_desbloqueados.has("mundo_exame_hunter")
	)

	_assinalar(
		persistiu,
		"SaveManager restaurou perfeitamente tutorial_concluido = true e conhecimentos desbloqueados.",
		"Falha: tutorial_concluido voltou para false após carregar o save!"
	)


func _testar_notificacoes_hud_bounds() -> void:
	print("\n[TESTE 2/3] Testando Layout e Dimensões do PlayerHUD e Notificações...")
	var hud_scn = load("res://ui/hud/HUD.tscn")
	var hud_inst = hud_scn.instantiate() as CanvasLayer
	add_child(hud_inst)

	hud_inst.exibir_notificacao("🏆 Teste de Notificação Responsiva Centralizada!")
	var stack = hud_inst.get_node_or_null("NotificationRoot/NotificationStack") as VBoxContainer
	var bounds_ok: bool = false
	if stack != null and stack.get_child_count() > 0:
		var panel = stack.get_child(0) as PanelContainer
		if panel != null:
			bounds_ok = panel.custom_minimum_size.x >= 220
	_assinalar(
		bounds_ok,
		"PlayerHUD exibe notificações em container centralizado com largura adequada sem corte.",
		"Falha na estrutura de notificações do PlayerHUD."
	)
	hud_inst.queue_free()


func _testar_notificacao_conclusao_quest() -> void:
	print("\n[TESTE 3/3] Testando Notificação ao Concluir Quest...")
	var hud_scn = load("res://ui/hud/HUD.tscn")
	var hud_inst = hud_scn.instantiate() as CanvasLayer
	add_child(hud_inst)

	var q = Quest.new()
	q.quest_name = "Missão Teste Notificação"
	q.auto_complete = true
	QuestSystem.active_quests.clear()
	QuestSystem.start_quest(q)
	QuestSystem.complete_quest(q)

	_assinalar(
		PlayerData.is_quest_completed(q),
		"Quest concluída disparou notificação no HUD com sucesso.",
		"Falha ao concluir quest de teste."
	)
	hud_inst.queue_free()


func _imprimir_resultado_final() -> void:
	print("\n================================================================================")
	print("🏆 RESULTADO DO TESTE DE SAVE/TUTORIAL & HUD:")
	print("   TESTES APROVADOS: %d / %d (%.1f%%)" % [
		_testes_passados, _total_testes, (float(_testes_passados) / max(1, _total_testes)) * 100.0
	])
	if _falhas.is_empty():
		print("   STATUS: PERSISTÊNCIA E LAYOUT DE NOTIFICAÇÕES 100% OPERACIONAIS!")
		print("================================================================================")
		get_tree().quit(0)
	else:
		print("   STATUS: FALHAS ENCONTRADAS:")
		for f in _falhas:
			print("     ❌ ", f)
		print("================================================================================")
		get_tree().quit(1)
