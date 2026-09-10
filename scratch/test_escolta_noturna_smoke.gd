extends Node2D

# ============================================================
# HUNTER ONLINE — SMOKE: ESCOLTA NOTURNA DA CARAVANA REAL
# ============================================================
# Valida ponta a ponta (headless) o fluxo da escolta noturna em
# res://world/maps/estrada_padokia.tscn:
#   A. Aceitar escolta -> anoitecer -> emboscada spawna -> derrotar
#      salteadores -> quest conclui e paga recompensa.
#   B. Falha ao se afastar da carroça >8s durante a noite.
#   C. Falha ao abandonar o mapa durante a noite.
# ============================================================

const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")
const MAPA_ESTRADA := "res://world/maps/estrada_padokia.tscn"

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0


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
	print("🛡️ SMOKE: ESCOLTA NOTURNA DA CARAVANA REAL (ESTRADA PADOKIA)")
	print("================================================================================")

	await _cenario_a_emboscada_e_sucesso()
	await _cenario_b_falha_afastar()
	await _cenario_c_falha_abandonar_mapa()

	print("\n================================================================================")
	print("📊 RESULTADO ESCOLTA NOTURNA: TOTAL %d | APROVADOS %d | FALHAS %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================================\n")
	get_tree().quit(0 if failed_tests == 0 else 1)


func _quest_escolta() -> Quest:
	return PadokiaQuestCatalogScript.obter_quest_secundaria_estrada()


func _reset_estado() -> void:
	# Estado global limpo entre cenários (processo headless isolado).
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
	if PlayerData != null:
		PlayerData.quest_states.clear()
	if TimeManager != null:
		TimeManager.set_time(8, 0) # DIA


func _instanciar_mapa() -> Node:
	var scn := load(MAPA_ESTRADA) as PackedScene
	assert_test(scn != null, "Cena da Estrada carregou (%s)" % MAPA_ESTRADA)
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	return mapa


func _liberar_mapa(mapa: Node) -> void:
	if is_instance_valid(mapa):
		remove_child(mapa)
		mapa.queue_free()
	await get_tree().process_frame


func _aceitar_escolta(q: Quest) -> void:
	QuestSystem.start_quest(q)
	QuestSystem.register_npc_visit(&"guarda_patrulha")


func _matar_enemy_system(es: Node) -> void:
	if es != null and es.has_method("die") and not es.is_dead:
		es.die()


# ------------------------------------------------------------
# CENÁRIO A — Emboscada + sucesso + recompensa
# ------------------------------------------------------------
func _cenario_a_emboscada_e_sucesso() -> void:
	print("\n[A] Emboscada noturna + derrota dos salteadores + conclusão")
	_reset_estado()
	var mapa = await _instanciar_mapa()
	var q := _quest_escolta()

	_aceitar_escolta(q)
	assert_test(PlayerData.is_quest_active(q), "Escolta ativa após falar com o Guarda")
	assert_test(PlayerData.get_quest_objective_progress(q, 0) >= 1, "Objetivo VISIT (Guarda) concluído")

	# Anoitecer dispara a emboscada (mapa escuta EventBus.time_phase_changed).
	TimeManager.set_time(22, 0)
	await get_tree().process_frame

	var emboscada = mapa.get_node_or_null("EmboscadaSalteadores")
	assert_test(emboscada != null, "EmboscadaSalteadores instanciada ao anoitecer")
	var salteadores: Array = []
	if emboscada != null:
		for c in emboscada.get_children():
			if str(c.name).begins_with("SalteadorEscolta"):
				salteadores.append(c)
	assert_test(salteadores.size() == 2, "Emboscada spawnou 2 salteadores (obtido: %d)" % salteadores.size())

	# Derrotar o 1º salteador — objetivo exige 2, então NÃO deve concluir ainda.
	if salteadores.size() >= 1:
		_matar_enemy_system(salteadores[0].get_node_or_null("EnemySystem"))
		await get_tree().process_frame
	assert_test(
		PlayerData.get_quest_objective_progress(q, 1) == 1,
		"Após 1 kill, progresso KILL = 1/2 (obtido: %d)" % PlayerData.get_quest_objective_progress(q, 1)
	)
	assert_test(not PlayerData.is_quest_completed(q), "Quest NÃO concluída com apenas 1 salteador morto")

	# Derrotar o 2º salteador — agora deve concluir e pagar recompensa.
	if salteadores.size() >= 2:
		_matar_enemy_system(salteadores[1].get_node_or_null("EnemySystem"))
		await get_tree().process_frame
	assert_test(
		PlayerData.get_quest_objective_progress(q, 1) == 2,
		"Após 2 kills, progresso KILL = 2/2 (obtido: %d)" % PlayerData.get_quest_objective_progress(q, 1)
	)
	assert_test(PlayerData.is_quest_completed(q), "Escolta CONCLUÍDA após derrotar os 2 salteadores")

	await _liberar_mapa(mapa)


# ------------------------------------------------------------
# CENÁRIO B — Falha ao se afastar >8s da carroça à noite
# ------------------------------------------------------------
func _cenario_b_falha_afastar() -> void:
	print("\n[B] Falha ao se afastar da caravana por mais de 8s à noite")
	_reset_estado()
	var mapa = await _instanciar_mapa()
	var q := _quest_escolta()

	_aceitar_escolta(q)
	TimeManager.set_time(22, 0)
	await get_tree().process_frame
	assert_test(mapa.get_node_or_null("EmboscadaSalteadores") != null, "Emboscada ativa (pré-condição da vigilância)")

	# Jogador fora da zona por 9s durante a noite -> falha.
	mapa._escolta_jogador_na_zona = false
	mapa._atualizar_vigilancia_escolta(9.0)
	await get_tree().process_frame

	assert_test(mapa._escolta_falhou, "Flag interna de falha da escolta ativada")
	assert_test(not PlayerData.is_quest_active(q), "Quest não está mais ativa após falhar")
	var st := ""
	var qid := q.quest_name
	if PlayerData.quest_states.has(qid):
		st = str(PlayerData.quest_states[qid].get("status", ""))
	assert_test(st == "failed", "Status da quest = 'failed' (obtido: '%s')" % st)

	await _liberar_mapa(mapa)


# ------------------------------------------------------------
# CENÁRIO C — Falha ao abandonar o mapa à noite
# ------------------------------------------------------------
func _cenario_c_falha_abandonar_mapa() -> void:
	print("\n[C] Falha ao abandonar o mapa durante a noite")
	_reset_estado()
	var mapa = await _instanciar_mapa()
	var q := _quest_escolta()

	_aceitar_escolta(q)
	TimeManager.set_time(22, 0)
	await get_tree().process_frame

	# Simula a saída do mapa (sinal tree_exiting) à noite com escolta ativa.
	mapa._on_estrada_tree_exiting()
	await get_tree().process_frame

	assert_test(mapa._escolta_falhou, "Flag interna de falha ativada ao abandonar o mapa")
	var st := ""
	var qid := q.quest_name
	if PlayerData.quest_states.has(qid):
		st = str(PlayerData.quest_states[qid].get("status", ""))
	assert_test(st == "failed", "Status da quest = 'failed' ao abandonar à noite (obtido: '%s')" % st)

	await _liberar_mapa(mapa)
