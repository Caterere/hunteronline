extends Node2D

# ============================================================
# HUNTER ONLINE — SMOKE: DISPUTA TERRITORIAL DA GRANDE PONTE
# ============================================================
# Valida (headless) o evento noturno de disputa na Grande Ponte em
# res://world/maps/estrada_padokia.tscn:
#   - Ao anoitecer, a disputa spawna (Guarda da Associação + 2 salteadores)
#     e registra um evento mundial ativo.
#   - Derrotar TODOS os salteadores concede +80 de reputação com a
#     Associação Hunter, +100 com Civis, resolve o evento e emite o sinal
#     reputacao_alterada.
# ============================================================

const MAPA_ESTRADA := "res://world/maps/estrada_padokia.tscn"
const EVENTO_ID := "evento_disputa_ponte_padokia"

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

var _rep_eventos: Array = []


func assert_test(cond: bool, msg: String) -> void:
	total_tests += 1
	if cond:
		passed_tests += 1
		print("  ✅ [PASS] %s" % msg)
	else:
		failed_tests += 1
		push_error("  ❌ [FAIL] %s" % msg)
		print("  ❌ [FAIL] %s" % msg)


func _ready() -> void:
	print("================================================================================")
	print("🌉 SMOKE: DISPUTA TERRITORIAL DA GRANDE PONTE (ESTRADA PADOKIA)")
	print("================================================================================")

	await _cenario_disputa_ponte()

	print("\n================================================================================")
	print("📊 RESULTADO DISPUTA PONTE: TOTAL %d | APROVADOS %d | FALHAS %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================================\n")
	get_tree().quit(0 if failed_tests == 0 else 1)


func _matar_enemy_system(es: Node) -> void:
	if es != null and es.has_method("die") and not es.is_dead:
		es.die()


func _cenario_disputa_ponte() -> void:
	print("\n[PONTE] Disputa noturna + reputação por derrotar os salteadores")

	# Estado limpo
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
	if PlayerData != null:
		PlayerData.quest_states.clear()
	if TimeManager != null:
		TimeManager.set_time(8, 0)

	# Capturar sinal de reputação
	if ReputationSystem != null:
		ReputationSystem.reputacao_alterada.connect(func(faccao, novo, delta):
			_rep_eventos.append({"faccao": faccao, "novo": novo, "delta": delta})
		)

	var rep_hunter_antes: int = ReputationSystem.obter_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER)
	var rep_civis_antes: int = ReputationSystem.obter_reputacao(ReputationSystem.Faccao.CIVIS)

	# Instanciar mapa
	var scn := load(MAPA_ESTRADA) as PackedScene
	assert_test(scn != null, "Cena da Estrada carregou")
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	# Anoitecer dispara a disputa (mapa escuta EventBus.time_phase_changed)
	TimeManager.set_time(22, 0)
	await get_tree().process_frame

	var disputa = mapa.get_node_or_null("DisputaFaccaoPonte")
	assert_test(disputa != null, "DisputaFaccaoPonte instanciada ao anoitecer")
	var salteadores: Array = []
	var tem_guarda := false
	if disputa != null:
		for c in disputa.get_children():
			if str(c.name).begins_with("SalteadorPonte"):
				salteadores.append(c)
			elif str(c.name) == "GuardaAssociacaoPonte":
				tem_guarda = true
	assert_test(tem_guarda, "Guarda da Associação presente na disputa")
	assert_test(salteadores.size() == 2, "Disputa spawnou 2 salteadores (obtido: %d)" % salteadores.size())
	assert_test(
		WorldEventManager.active_world_events.has(EVENTO_ID),
		"Evento mundial '%s' registrado como ativo" % EVENTO_ID
	)

	# Derrotar o 1º salteador — ainda há 1 vivo, reputação NÃO deve mudar.
	if salteadores.size() >= 1:
		_matar_enemy_system(salteadores[0].get_node_or_null("EnemySystem"))
		await get_tree().process_frame
	assert_test(
		ReputationSystem.obter_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER) == rep_hunter_antes,
		"Reputação Hunter inalterada com 1 salteador restante"
	)

	# Derrotar o 2º salteador — todos derrotados, reputação concedida.
	if salteadores.size() >= 2:
		_matar_enemy_system(salteadores[1].get_node_or_null("EnemySystem"))
		await get_tree().process_frame

	var rep_hunter_depois: int = ReputationSystem.obter_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER)
	var rep_civis_depois: int = ReputationSystem.obter_reputacao(ReputationSystem.Faccao.CIVIS)

	assert_test(
		rep_hunter_depois == rep_hunter_antes + 80,
		"Reputação Associação Hunter +80 (%d -> %d)" % [rep_hunter_antes, rep_hunter_depois]
	)
	assert_test(
		rep_civis_depois == rep_civis_antes + 100,
		"Reputação Civis +100 pela resolução do evento (%d -> %d)" % [rep_civis_antes, rep_civis_depois]
	)
	assert_test(
		not WorldEventManager.active_world_events.has(EVENTO_ID),
		"Evento mundial resolvido e removido dos ativos"
	)
	assert_test(_rep_eventos.size() >= 1, "Sinal reputacao_alterada emitido ao menos 1x (obtido: %d)" % _rep_eventos.size())

	if is_instance_valid(mapa):
		remove_child(mapa)
		mapa.queue_free()
	await get_tree().process_frame
