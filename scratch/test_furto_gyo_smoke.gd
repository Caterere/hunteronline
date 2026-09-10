extends Node2D

# ============================================================
# HUNTER ONLINE — SMOKE: INVESTIGAÇÃO DE FURTO COM GYO (PADOKIA)
# ============================================================
# Valida (headless) a quest "Vestígios do Furto de Aura":
#   - Objetivo 0: falar com o mercador (VISIT).
#   - Objetivos 1-3: inspecionar 3 pistas de aura usando GYO (INVESTIGATE).
# Verifica: gating sequencial (não avança pista antes de visitar o mercador),
# exigência de Gyo para decifrar cada pista, e progressão até a conclusão de
# todos os objetivos. As pistas são criadas pelo mesmo NenSensorFactory usado
# em RegiaoValePadokiaMap._popular_pistas_furto_gyo().
# ============================================================

const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")
const NenSensorFactoryScript = preload("res://world/components/exploration/NenSensorFactory.gd")

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
	print("🔍 SMOKE: INVESTIGAÇÃO DE FURTO COM GYO (VILA DE PADOKIA)")
	print("================================================================================")

	await _cenario_furto_gyo()

	print("\n================================================================================")
	print("📊 RESULTADO FURTO GYO: TOTAL %d | APROVADOS %d | FALHAS %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================================\n")
	get_tree().quit(0 if failed_tests == 0 else 1)


func _prog(q: Quest, idx: int) -> int:
	return PlayerData.get_quest_objective_progress(q, idx)


func _cenario_furto_gyo() -> void:
	print("\n[FURTO] Fluxo completo: visitar mercador -> 3 pistas via Gyo")

	# Estado limpo + Nen desperto
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
	if PlayerData != null:
		PlayerData.quest_states.clear()
		PlayerData.segredos_descobertos.clear()
		PlayerData.despertou_nen = true
		PlayerData.attributes["nivel_nen"] = 2
		PlayerData.attributes["aura_max"] = 200.0
		PlayerData.attributes["aura"] = 200.0
		PlayerData.attributes["xp_nen"] = 0

	# Quest real do catálogo
	var q := PadokiaQuestCatalogScript.obter_quest_investigacao_furto()
	assert_test(q.objectives.size() == 4, "Quest possui 4 objetivos (obtido: %d)" % q.objectives.size())
	assert_test(q.objectives[0].type == QuestObjective.Type.VISIT, "Objetivo 0 é VISIT (mercador)")
	var ids := []
	for i in range(1, q.objectives.size()):
		assert_test(q.objectives[i].type == QuestObjective.Type.INVESTIGATE, "Objetivo %d é INVESTIGATE" % i)
		ids.append(q.objectives[i].target_clue_id)

	# Player dummy com NenSystem real
	var player := CharacterBody2D.new()
	player.name = "PlayerFurto"
	player.add_to_group("player")
	var nen := NenSystem.new()
	nen.name = "NenSystem"
	player.add_child(nen)
	add_child(player)
	if nen.has_method("sincronizar_nen_com_player_data"):
		nen.sincronizar_nen_com_player_data()

	# Criar as 3 pistas reais (mesmo factory do mapa Padokia)
	var pistas: Array = []
	var titulos := ["Marca na Janela", "Pegada de Aura", "Esconderijo"]
	for i in range(ids.size()):
		var pista = NenSensorFactoryScript.criar_gyo(
			self, "Pista_%d" % i, Vector2(100 + i * 40, 100), ids[i], titulos[i],
			"Resíduo de aura do ladrão.", "Manipulação", 1
		)
		pistas.append(pista)
	await get_tree().process_frame
	assert_test(pistas.size() == 3 and pistas[0] != null, "3 pistas Gyo criadas via NenSensorFactory")

	# Iniciar quest
	QuestSystem.start_quest(q)
	assert_test(PlayerData.is_quest_active(q), "Quest de furto iniciada e ativa")

	# GATING: investigar antes de visitar o mercador NÃO deve avançar as pistas
	QuestSystem.register_investigation(ids[0])
	assert_test(_prog(q, 1) == 0, "Gating: pista não avança antes de visitar o mercador (obj1=%d)" % _prog(q, 1))

	# Visitar o mercador -> conclui objetivo 0
	QuestSystem.register_npc_visit(&"vendedor")
	assert_test(_prog(q, 0) >= 1, "Objetivo VISIT (mercador) concluído")

	# Exigência de Gyo: sem Gyo, a inspeção falha
	pistas[0].atualizar_estado_gyo(false)
	var r_sem_gyo = pistas[0].inspecionar(player)
	assert_test(not r_sem_gyo.get("sucesso", true), "Inspeção sem Gyo é bloqueada")
	assert_test(_prog(q, 1) == 0, "Pista 1 não avança sem Gyo (obj1=%d)" % _prog(q, 1))

	# Inspecionar as 3 pistas COM Gyo, na ordem dos objetivos
	for i in range(pistas.size()):
		pistas[i].atualizar_estado_gyo(true)
		var r = pistas[i].inspecionar(player)
		await get_tree().process_frame
		assert_test(r.get("sucesso", false), "Pista %d decifrada com Gyo" % (i + 1))
		assert_test(_prog(q, i + 1) == 1, "Objetivo INVESTIGATE %d concluído (obj%d=%d)" % [i + 1, i + 1, _prog(q, i + 1)])

	# Todos os objetivos concluídos
	assert_test(QuestSystem.is_all_active_objectives_completed(), "Todos os 4 objetivos da investigação concluídos")

	# Segredos registrados no PlayerData
	var todos_segredos := true
	for cid in ids:
		if not PlayerData.segredos_descobertos.has(str(cid)):
			todos_segredos = false
	assert_test(todos_segredos, "As 3 pistas foram registradas em segredos_descobertos")

	# Turn-in manual (auto_complete=false): conclui e paga recompensa
	QuestSystem.complete_quest(q)
	assert_test(PlayerData.is_quest_completed(q), "Quest de furto concluída após turn-in")

	# Limpeza
	for p in pistas:
		if is_instance_valid(p):
			p.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	await get_tree().process_frame
