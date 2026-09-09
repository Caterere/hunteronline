extends Node2D

# ============================================================
# HUNTER ONLINE — SMOKE: DENSIDADE DA ARENA CELESTIAL (ARCO 3)
# ============================================================
# Valida (headless) que res://world/maps/arena_celestial.tscn popula seu
# conteúdo ao carregar:
#   - 4 lutadores de andares inferiores (LutadorArena1..4).
#   - 4 mestres do 200º andar (Gido, Riehlvelt, Kastro, Hisoka Boss).
#   - NPCs: Recepcionista, Zushi, Wing, Hisoka.
#   - Objeto interativo Teste da Água (Water Divination).
#   - Portal de conclusão com Story Gate das 26 etapas.
# ============================================================

const ARENA := "res://world/maps/arena_celestial.tscn"

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
	print("🥋 SMOKE: DENSIDADE DA ARENA CELESTIAL (ARCO 3)")
	print("================================================================================")

	await _cenario_densidade()

	print("\n================================================================================")
	print("📊 RESULTADO ARENA DENSIDADE: TOTAL %d | APROVADOS %d | FALHAS %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================================\n")
	get_tree().quit(0 if failed_tests == 0 else 1)


func _enemy_id(mapa: Node, nome: String) -> String:
	var node = mapa.get_node_or_null(nome)
	if node == null:
		return ""
	var es = node.get_node_or_null("EnemySystem")
	return str(es.enemy_id) if es != null else ""


func _cenario_densidade() -> void:
	print("\n[ARENA] Instanciando arena_celestial.tscn e verificando a densidade")

	if QuestSystem != null:
		QuestSystem.active_quests.clear()
	if PlayerData != null:
		PlayerData.quest_states.clear()

	var scn := load(ARENA) as PackedScene
	assert_test(scn != null, "Cena da Arena Celestial carregou")
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	# 1. Lutadores dos andares inferiores (spawn em runtime se ausentes)
	var lutadores := ["LutadorArena1", "LutadorArena2", "LutadorArena3", "LutadorArena4"]
	var lut_ok := 0
	for nome in lutadores:
		var node = mapa.get_node_or_null(nome)
		if node != null and _enemy_id(mapa, nome) == "lutador_arena":
			lut_ok += 1
	assert_test(lut_ok == 4, "4 lutadores de andar inferior presentes como 'lutador_arena' (obtido: %d)" % lut_ok)

	# 2. Mestres do 200º andar
	var mestres := {
		"LutadorAndar200Gido": "piao_gido",
		"LutadorAndar200Riehlvelt": "riehlvelt",
		"LutadorAndar200Kastro": "kastro",
		"MestreAndar200": "hisoka_boss"
	}
	var mestres_ok := 0
	for nome in mestres:
		if mapa.get_node_or_null(nome) != null and _enemy_id(mapa, nome) == mestres[nome]:
			mestres_ok += 1
	assert_test(mestres_ok == 4, "4 mestres do 200º andar configurados (obtido: %d)" % mestres_ok)

	# 3. NPCs do arco
	var npcs := ["Recepcionista", "Zushi", "Wing", "Hisoka"]
	var npcs_ok := 0
	for nome in npcs:
		if mapa.get_node_or_null(nome) != null:
			npcs_ok += 1
	assert_test(npcs_ok == 4, "4 NPCs do Arco 3 presentes (Recepcionista/Zushi/Wing/Hisoka) (obtido: %d)" % npcs_ok)

	# 4. Objeto interativo Teste da Água
	var teste = mapa.get_node_or_null("TesteAguaWing")
	assert_test(teste != null, "Objeto interativo TesteAguaWing presente")
	assert_test(teste != null and teste.get_node_or_null("InteractionComponent") != null, "TesteAguaWing possui InteractionComponent")

	# 5. Portal de conclusão com Story Gate
	var portal = mapa.get_node_or_null("PortalYorknew")
	assert_test(portal != null, "Portal de conclusão (PortalYorknew) presente")
	assert_test(portal != null and portal.story_gate != null, "Portal possui Story Gate configurado")
	if portal != null and portal.story_gate != null:
		assert_test(portal.story_gate.required_arc == 3, "Story Gate exige Arco 3 (obtido: %s)" % str(portal.story_gate.required_arc))

	# 6. Densidade total de combatentes presentes no mapa.
	# Obs.: inimigos de missão cujo objetivo ainda não está ativo são
	# desativados por sincronizar_inimigos_do_mapa() e saem do grupo "enemies";
	# por isso contamos os NÓS com EnemySystem, não a associação de grupo.
	var combatentes := 0
	for c in mapa.get_children():
		if c.get_node_or_null("EnemySystem") != null:
			combatentes += 1
	assert_test(combatentes >= 8, "Densidade: pelo menos 8 combatentes presentes na arena (obtido: %d)" % combatentes)

	remove_child(mapa)
	mapa.queue_free()
	await get_tree().process_frame
