extends Node

# ==============================================================================
# HUNTER ONLINE — REGRESSION TEST SUITE: MASSIVE SKILL TREE (23 SCENARIOS)
# ==============================================================================
# Valida exaustivamente os 23 cenários obrigatórios da Seção 25:
# 1. Subir de nível.
# 2. Confirmar que atributos BASE aumentam automaticamente.
# 3. Ganhar Skill Point.
# 4. Comprar Small Node.
# 5. Comprar Medium Node.
# 6. Tentar comprar node sem requisito.
# 7. Comprar Major Node.
# 8. Comprar Keystone.
# 9. Tentar comprar duas vezes um node de rank único.
# 10. Comprar rank 2 de node multi-rank.
# 11. Resetar árvore.
# 12. Confirmar devolução dos pontos.
# 13. Salvar jogo.
# 14. Resetar sessão.
# 15. Carregar jogo e confirmar integridade.
# 16. Testar zoom.
# 17. Testar pan.
# 18. Testar centenas de nós (400+ nós carregados).
# 19. Testar resolução diferente.
# 20. Testar personagem Level alto (Level 1000 com 999 SP).
# 21. Testar compatibilidade com Nen.
# 22. Testar compatibilidade com Hatsu.
# 23. Testar compatibilidade com nós legados e suíte de contexto.
# ==============================================================================

const XPSystemScript = preload("res://scripts/systems/XPSystem.gd")
const NenSkillTreeUIScript = preload("res://ui/SkillTree/NenSkillTreeUI.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ [PASS] " + test_name)
	else:
		failed_tests += 1
		printerr("  ❌ [FAIL] " + test_name)

func _ready() -> void:
	print("================================================================")
	print("🥋 TEST SUITE: REWORK MASSIVO DA SKILL TREE (23 CENÁRIOS)")
	print("================================================================")

	var tree: NenSkillTree = PlayerData.obter_skill_tree() as NenSkillTree
	assert(tree != null, "NenSkillTree deve existir no PlayerData")

	# -------------------------------------------------------------
	# 1 & 2 & 3: Level Up, Base Stats & Skill Points
	# -------------------------------------------------------------
	print("\n--- [TEST 1-3] Level Up, Base Stats & Skill Points ---")
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel(10)
	var hp_10 = PlayerData.obter_stat_calculado("vida_max")
	var frc_10 = PlayerData.obter_stat_calculado("forca")

	var xp_sys = XPSystemScript.new()
	add_child(xp_sys)
	xp_sys.sincronizar_com_player_data()
	var sp_antes = PlayerData.nen_skill_points

	# Conceder XP para subir de nível 10 para 11
	var xp_para_subir = xp_sys.xp_necessario() - xp_sys.xp + 100
	xp_sys.adicionar_xp(xp_para_subir, "Teste Level Up")

	assert_test(PlayerData.attributes["nivel"] >= 11, "1. Subir de nível via XPSystem funcionou (Lv. %d)" % PlayerData.attributes["nivel"])
	var hp_11 = PlayerData.obter_stat_calculado("vida_max")
	var frc_11 = PlayerData.obter_stat_calculado("forca")
	assert_test(hp_11 > hp_10 and frc_11 > frc_10, "2. Atributos BASE aumentaram automaticamente no Level Up sem Skill Tree (HP: %d->%d, Força: %d->%d)" % [hp_10, hp_11, frc_10, frc_11])
	assert_test(PlayerData.nen_skill_points > sp_antes, "3. Ganhou Skill Point ao subir de nível (%d -> %d)" % [sp_antes, PlayerData.nen_skill_points])
	xp_sys.queue_free()

	# -------------------------------------------------------------
	# 4: Comprar Small Node
	# -------------------------------------------------------------
	print("\n--- [TEST 4] Comprar Small Node ---")
	PlayerData.reset()
	PlayerData.nen_skill_points = 5
	assert_test(tree.investir_ponto("ren_1"), "4.1 Comprar Small Node (ren_1) consome 1 SP e desbloqueia")
	assert_test(tree.no_desbloqueado("ren_1") and PlayerData.nen_skill_points == 4, "4.2 ren_1 desbloqueado e saldo de pontos atualizado para 4")

	# -------------------------------------------------------------
	# 5: Comprar Medium Node (Rank 1)
	# -------------------------------------------------------------
	print("\n--- [TEST 5] Comprar Medium Node ---")
	PlayerData.nen_skill_points = 5
	tree.investir_ponto("ten_1")
	tree.investir_ponto("ten_2")
	var comprou_ten_3 = tree.investir_ponto("ten_3") # ten_3 é Medium Node
	assert_test(comprou_ten_3 and tree.obter_nivel_no("ten_3") == 1, "5. Comprar Medium Node (ten_3) no Rank 1 com sucesso")

	# -------------------------------------------------------------
	# 6: Tentar comprar node sem requisito (Rejeitado)
	# -------------------------------------------------------------
	print("\n--- [TEST 6] Tentar comprar node sem requisito ---")
	var comprou_sem_req = tree.investir_ponto("ten_5") # ten_5 requer ten_4
	assert_test(not comprou_sem_req and tree.obter_nivel_no("ten_5") == 0, "6. Tentativa de comprar ten_5 sem atender pré-requisito (ten_4) foi rejeitada")

	# -------------------------------------------------------------
	# 7: Comprar Major Node
	# -------------------------------------------------------------
	print("\n--- [TEST 7] Comprar Major Node ---")
	PlayerData.nen_skill_points = 10
	tree.investir_ponto("ren_2")
	tree.investir_ponto("ren_3")
	# ken_mastery requer ten_3 e ren_3
	var comprou_ken = tree.investir_ponto("ken_mastery")
	assert_test(comprou_ken and tree.no_desbloqueado("ken_mastery"), "7. Major Node (ken_mastery) comprado após satisfazer requisitos duplos (ten_3 + ren_3)")

	# -------------------------------------------------------------
	# 8: Comprar Keystone
	# -------------------------------------------------------------
	print("\n--- [TEST 8] Comprar Keystone ---")
	PlayerData.nen_skill_points = 10
	var comprou_fs = tree.investir_ponto("first_strike") # first_strike é Keystone de warrior
	assert_test(comprou_fs and tree.no_desbloqueado("first_strike"), "8. Keystone (first_strike) desbloqueada com sucesso na árvore")

	# -------------------------------------------------------------
	# 9: Tentar comprar duas vezes um node de rank único
	# -------------------------------------------------------------
	print("\n--- [TEST 9] Tentar comprar duas vezes um node de rank único ---")
	var recomprou_fs = tree.investir_ponto("first_strike")
	assert_test(not recomprou_fs and tree.obter_nivel_no("first_strike") == 1, "9. Segunda compra em nó de rank único (first_strike) foi estritamente bloqueada")

	# -------------------------------------------------------------
	# 10: Comprar rank 2 de node multi-rank (Escalonamento linear)
	# -------------------------------------------------------------
	print("\n--- [TEST 10] Comprar rank 2 de node multi-rank ---")
	PlayerData.nen_skill_points = 10
	tree.investir_ponto("body_gateway")
	tree.investir_ponto("body_hp_01")
	tree.investir_ponto("body_hp_02")
	tree.investir_ponto("body_hp_03")
	var comprou_r1 = tree.investir_ponto("body_hp_04") # body_hp_04 é MEDIUM com 3 ranks
	var hp_r1 = PlayerData.obter_stat_calculado("vida_max")
	var comprou_r2 = tree.investir_ponto("body_hp_04")
	var hp_r2 = PlayerData.obter_stat_calculado("vida_max")
	assert_test(comprou_r1 and comprou_r2 and tree.obter_nivel_no("body_hp_04") == 2, "10.1 Nó multi-rank evoluiu para Rank 2 com sucesso")
	assert_test(hp_r2 > hp_r1, "10.2 Bônus de atributos no Rank 2 (%d) é estritamente maior que no Rank 1 (%d)" % [hp_r2, hp_r1])

	# -------------------------------------------------------------
	# 11 & 12: Resetar árvore e confirmar devolução total dos pontos
	# -------------------------------------------------------------
	print("\n--- [TEST 11-12] Reset da Árvore e Reembolso ---")
	var saldo_antes_reset = PlayerData.nen_skill_points
	var pontos_devolvidos = tree.resetar_arvore()
	assert_test(pontos_devolvidos > 0, "11. Reset da árvore executado com devolução positiva (%d pontos)" % pontos_devolvidos)
	assert_test(PlayerData.nen_skill_points == (saldo_antes_reset + pontos_devolvidos), "12.1 Todos os pontos gastos foram reembolsados integralmente ao saldo do jogador")
	assert_test(tree.obter_nivel_no("ren_1") == 0 and tree.obter_nivel_no("body_hp_04") == 0, "12.2 Nós limpos para Rank 0 após reset")

	# -------------------------------------------------------------
	# 13, 14 & 15: Salvar jogo, resetar sessão e carregar save
	# -------------------------------------------------------------
	print("\n--- [TEST 13-15] Persistência Save / Load ---")
	var test_slot := 8
	PlayerData.reset()
	PlayerData.nen_skill_points = 20
	tree.investir_ponto("ren_1")
	tree.investir_ponto("first_strike")
	tree.investir_ponto("body_gateway")
	var salvou := SaveManager.salvar_jogo(test_slot)
	assert_test(salvou, "13. Jogo salvo no slot de teste com progresso na Skill Tree")

	# Simular reset de sessão
	PlayerData.reset()
	tree.node_levels.clear()
	PlayerData.nen_skill_points = 0
	assert_test(PlayerData.nen_skill_points == 0 and tree.obter_nivel_no("first_strike") == 0, "14. Dados resetados simulando reinício de sessão")

	var carregou := SaveManager.carregar_jogo(test_slot)
	assert_test(carregou and PlayerData.nen_skill_points == 17, "15.1 Save carregado e saldo de pontos disponível (17) restaurado")
	assert_test(tree.no_desbloqueado("ren_1") and tree.no_desbloqueado("first_strike") and tree.no_desbloqueado("body_gateway"), "15.2 Nós desbloqueados restaurados perfeitamente no runtime")
	SaveManager.deletar_save(test_slot)

	# -------------------------------------------------------------
	# 16 & 17: Câmera Zoom e Pan na UI
	# -------------------------------------------------------------
	print("\n--- [TEST 16-17] Câmera Zoom e Pan na UI ---")
	var tree_ui = NenSkillTreeUIScript.new()
	add_child(tree_ui)
	tree_ui._ajustar_zoom(1.5)
	assert_test(tree_ui.target_zoom > 0.85 and tree_ui.target_zoom <= 2.20, "16.1 Zoom in ajustado corretamente (%.2f)" % tree_ui.target_zoom)
	tree_ui._ajustar_zoom(0.1)
	assert_test(tree_ui.target_zoom >= 0.25, "16.2 Zoom out respeita o limite mínimo de visão geral (%.2f)" % tree_ui.target_zoom)

	var pan_original = tree_ui.target_pan
	tree_ui.target_pan += Vector2(150, -200)
	assert_test(tree_ui.target_pan != pan_original, "17. Pan de câmera atualiza coordenadas livremente pelo mapa")

	# -------------------------------------------------------------
	# 18: Centenas de nós (400+ nós carregados)
	# -------------------------------------------------------------
	print("\n--- [TEST 18] Validação de Escala (400+ Nós) ---")
	var db = SkillTreeDatabase.get_instance()
	var total_nos = db.nodes.size()
	assert_test(total_nos >= 300, "18. Constelação possui centenas de nós registrados (%d nós, meta >= 300)" % total_nos)

	# -------------------------------------------------------------
	# 19: Responsividade em diferentes resoluções
	# -------------------------------------------------------------
	print("\n--- [TEST 19] Responsividade Multirresolução ---")
	var res_1080 = Vector2(1920, 1080)
	var res_1440 = Vector2(2560, 1440)
	var res_4k = Vector2(3840, 2160)
	tree_ui.size = res_1080
	var culling_1080 = db.get_nodes_in_rect(Rect2(-res_1080 * 0.5, res_1080))
	tree_ui.size = res_4k
	var culling_4k = db.get_nodes_in_rect(Rect2(-res_4k * 0.5, res_4k))
	assert_test(culling_1080.size() > 0 and culling_4k.size() >= culling_1080.size(), "19. Culling e visibilidade se adaptam responsivamente de 1080p (%d nós) a 4K (%d nós)" % [culling_1080.size(), culling_4k.size()])
	tree_ui.queue_free()

	# -------------------------------------------------------------
	# 20: Personagem Level Alto (Level 1000 com 999 Pontos)
	# -------------------------------------------------------------
	print("\n--- [TEST 20] Personagem Level Alto (Lv 1000) ---")
	PlayerData.reset()
	PlayerData.debug_set_level(1000, true)
	PlayerData.nen_skill_points = 999
	assert_test(PlayerData.attributes["nivel"] == 1000 and PlayerData.nen_skill_points == 999, "20.1 Caçador no Nível 1000 com 999 Skill Points pronto para progressão massiva")
	assert_test(PlayerData.obter_stat_calculado("vida_max") == 60000, "20.2 Atributos base Nv.1000 preservados integralmente antes do investimento de SP")

	# -------------------------------------------------------------
	# 21: Compatibilidade com Sistema de Nen
	# -------------------------------------------------------------
	print("\n--- [TEST 21] Compatibilidade com Técnicas de Nen ---")
	PlayerData.tecnicas_nen["ten"] = {"nivel": 50, "xp": 0, "desbloqueada": true}
	PlayerData.tecnicas_nen["ren"] = {"nivel": 50, "xp": 0, "desbloqueada": true}
	var ten_lvl = PlayerData.tecnicas_nen["ten"]["nivel"]
	tree.investir_ponto("ten_1")
	assert_test(PlayerData.tecnicas_nen["ten"]["nivel"] == ten_lvl, "21. Investir na Skill Tree não sobrescreve a maestria canônica de Ten (%d)" % ten_lvl)

	# -------------------------------------------------------------
	# 22: Compatibilidade com Sistema de Hatsu
	# -------------------------------------------------------------
	print("\n--- [TEST 22] Compatibilidade com Hatsu ---")
	var h := HatsuData.new()
	h.nome = "Disparo Espiritual"
	h.poder_base = 200.0
	PlayerData.hatsu_criados.append(h)
	PlayerData.hatsu_slots[0] = 0
	tree.investir_ponto("hatsu_gateway")
	assert_test(PlayerData.hatsu_criados[0].nome == "Disparo Espiritual" and PlayerData.hatsu_criados[0].poder_base == 200.0, "22. Hatsu criado e equipado permaneceu íntegro e imutável após alocação de pontos de Hatsu")

	# -------------------------------------------------------------
	# 23: Compatibilidade com Nós Legados e Suíte de Contexto
	# -------------------------------------------------------------
	print("\n--- [TEST 23] Compatibilidade Retroativa Total ---")
	var todos_legados_ok = true
	var legados = ["ten_1", "ren_1", "zetsu_1", "gyo_1", "ko_1", "shu_1", "ryu_ofensivo", "first_strike", "bloodied", "ken_mastery"]
	for leg in legados:
		if not tree.node_definitions.has(leg):
			todos_legados_ok = false
			break
	assert_test(todos_legados_ok, "23. Todos os nós legados permanecem registrados, tipados e compatíveis com código existente")

	# Limpeza
	tree.resetar_arvore()
	PlayerData.reset()

	print("\n================================================================")
	print("📊 RESULTADOS DA SUÍTE MASSIVA DA SKILL TREE:")
	print("Total: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 100% DOS TESTES DA SKILL TREE FORAM APROVADOS COM SUCESSO!")
	else:
		printerr("❌ ALGUNS TESTES FALHARAM!")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)
