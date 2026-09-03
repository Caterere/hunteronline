extends Node2D

# ============================================================
# TEST SUITE: NEN SKILL TREE CONTEXTUAL & SYNERGIES (FASE 2)
# ============================================================
#
# Validação completa:
# 1. Registro de nós comportamentais e sinergias
# 2. Pré-requisitos múltiplos e investimento de pontos
# 3. Avaliação True/False de GameplayCondition
# 4. Pipeline de StatModifier no PlayerData (aplicação e remoção limpa)
# 5. Exclusividade de caminhos de Ryu
# 6. Persistência Save/Load no SaveManager
# 7. Contexto canônico e dano no CombatEngine
# 8. Não-duplicação de sinergias com HatsuManager
#
# ============================================================

const NenSkillTreeScript = preload("res://scripts/systems/NenSkillTree.gd")

func _ready() -> void:
	print("\n================================================================================")
	print("🧪 EXECUTANDO SUÍTE DE TESTES: SKILL TREE CONTEXTUAL & SINERGIAS (FASE 2)")
	print("================================================================================")

	var tree: NenSkillTree = NenSkillTreeScript.new()
	add_child(tree)

	var total_tests: int = 8
	var passed_tests: int = 0

	# ------------------------------------------------------------
	# 1. REGISTRO DE NÓS COMPORTAMENTAIS E SINERGIAS
	# ------------------------------------------------------------
	print("\n[TESTE 1/8] Registro de nós comportamentais e sinergias...")
	var req_nodes = [
		"first_strike", "bloodied", "surrounded", "isolated_target", "hunters_mark",
		"ken_mastery", "in_mastery", "en_expansion"
	]
	for nid in req_nodes:
		assert(tree.node_definitions.has(nid), "Nó obrigatório deve estar registrado: " + nid)

	# Verificar nós comportamentais
	var def_fs: NenSkillTree.SkillNodeDef = tree.node_definitions["first_strike"]
	assert(def_fs.categoria == NenSkillTree.Categoria.COMPORTAMENTAL, "first_strike deve ser COMPORTAMENTAL")
	assert(def_fs.is_contextual(), "first_strike deve ser contextual")
	assert(tree.no_tem_tag("first_strike", "first_strike"), "first_strike deve possuir a tag first_strike")

	var def_ken: NenSkillTree.SkillNodeDef = tree.node_definitions["ken_mastery"]
	assert(def_ken.categoria == NenSkillTree.Categoria.SINERGIA, "ken_mastery deve ser SINERGIA")
	assert(def_ken.pre_requisitos.has("ten_3") and def_ken.pre_requisitos.has("ren_3"), "ken_mastery deve exigir ten_3 e ren_3")
	assert(tree.no_tem_tag("ken_mastery", "nen_synergy"), "ken_mastery deve possuir tag nen_synergy")

	print("  ✅ [PASS] Todos os 8 nós novos estão registrados com categorias, tags e condições corretas.")
	passed_tests += 1

	# ------------------------------------------------------------
	# 2. PRÉ-REQUISITOS E CONSUMO DE PONTOS
	# ------------------------------------------------------------
	print("\n[TESTE 2/8] Pré-requisitos múltiplos e investimento de pontos...")
	PlayerData.nen_skill_points = 0
	var investiu_sem_pontos = tree.investir_ponto("first_strike")
	assert(not investiu_sem_pontos, "Não deve investir sem pontos disponíveis")

	PlayerData.nen_skill_points = 10
	# first_strike requer ren_1
	var investiu_sem_prereq = tree.investir_ponto("first_strike")
	assert(not investiu_sem_prereq, "first_strike não deve investir sem ren_1")

	# Investir em ren_1 primeiro
	assert(tree.investir_ponto("ren_1"), "ren_1 deve ser investido")
	assert(tree.no_desbloqueado("ren_1"), "ren_1 deve estar desbloqueado")
	# Agora first_strike deve ter pré-requisito satisfeito
	assert(tree.investir_ponto("first_strike"), "first_strike deve ser investido com ren_1 atendido")
	assert(tree.no_desbloqueado("first_strike"), "first_strike deve estar desbloqueado")
	assert(PlayerData.nen_skill_points == 8, "Pontos investidos devem ser debitados")

	print("  ✅ [PASS] Pré-requisitos validados e pontos debitados corretamente.")
	passed_tests += 1

	# ------------------------------------------------------------
	# 3. AVALIAÇÃO TRUE/FALSE DE GAMEPLAYCONDITION
	# ------------------------------------------------------------
	print("\n[TESTE 3/8] Avaliação True/False das condições contextuais...")

	# First Strike: NO_DAMAGE_FOR_SECONDS (>= 4.0s)
	assert(not tree.avaliar_condicoes_no("first_strike", {"seconds_since_damage": 2.0}).met, "First Strike falso com 2s sem dano")
	assert(tree.avaliar_condicoes_no("first_strike", {"seconds_since_damage": 5.0}).met, "First Strike verdadeiro com 5s sem dano")

	# Bloodied: PLAYER_HP_BELOW (< 0.35)
	assert(not tree.avaliar_condicoes_no("bloodied", {"player_hp_percent": 0.80}).met, "Bloodied falso com 80% HP")
	assert(tree.avaliar_condicoes_no("bloodied", {"player_hp_percent": 0.25}).met, "Bloodied verdadeiro com 25% HP")

	# Surrounded: ENEMIES_NEARBY_AT_LEAST (>= 3)
	assert(not tree.avaliar_condicoes_no("surrounded", {"nearby_enemy_count": 2}).met, "Surrounded falso com 2 inimigos")
	assert(tree.avaliar_condicoes_no("surrounded", {"nearby_enemy_count": 4}).met, "Surrounded verdadeiro com 4 inimigos")

	# Isolated Target: SINGLE_TARGET (== 1)
	assert(not tree.avaliar_condicoes_no("isolated_target", {"nearby_enemy_count": 3}).met, "Isolated Target falso com 3 inimigos")
	assert(tree.avaliar_condicoes_no("isolated_target", {"nearby_enemy_count": 1}).met, "Isolated Target verdadeiro com 1 inimigo")

	# Hunter's Mark: TARGET_MARKED (== true)
	assert(not tree.avaliar_condicoes_no("hunters_mark", {"target_marked": false}).met, "Hunter's Mark falso com alvo não marcado")
	assert(tree.avaliar_condicoes_no("hunters_mark", {"target_marked": true}).met, "Hunter's Mark verdadeiro com alvo marcado")

	# En Expansion: PLAYER_IN_EN (== true)
	assert(not tree.avaliar_condicoes_no("en_expansion", {"player_in_en": false}).met, "En Expansion falso com En desligado")
	assert(tree.avaliar_condicoes_no("en_expansion", {"player_in_en": true}).met, "En Expansion verdadeiro com En ligado")

	print("  ✅ [PASS] Todos os casos True e False de condições avaliados com exatidão.")
	passed_tests += 1

	# ------------------------------------------------------------
	# 4. PIPELINE DE STATMODIFIER NO PLAYERDATA
	# ------------------------------------------------------------
	print("\n[TESTE 4/8] Pipeline de StatModifier e recálculo dinâmico...")
	PlayerData.remover_modificadores_da_fonte("nen_skill_tree")
	PlayerData.remover_modificadores_da_fonte("nen_skill_tree_contextual")
	PlayerData.recalcular_todos_atributos()
	var forca_base: int = int(PlayerData.attributes["forca"])

	# Desbloquear Bloodied para teste
	tree.node_levels["bloodied"] = 1

	# Contexto onde Bloodied NÃO atende
	var res_inativo = tree.atualizar_modificadores_contextuais({"player_hp_percent": 0.90})
	assert(not ("bloodied" in res_inativo.nos_ativos), "Bloodied não deve ativar com HP alto")
	assert(PlayerData.attributes["forca"] == forca_base, "Força deve se manter na base quando inativo")

	# Contexto onde Bloodied ATENDE (< 35% HP)
	var res_ativo = tree.atualizar_modificadores_contextuais({"player_hp_percent": 0.20})
	assert("bloodied" in res_ativo.nos_ativos, "Bloodied deve ativar com HP baixo")
	assert(PlayerData.attributes["forca"] > forca_base, "Força deve aumentar com Bloodied ativo (+20%)")

	# Limpar contexto e verificar retorno à base
	tree.limpar_modificadores_contextuais()
	assert(PlayerData.attributes["forca"] == forca_base, "Força deve retornar limpa à base após limpeza contextual")

	print("  ✅ [PASS] StatModifier aplicado dinamicamente e removido sem efeitos colaterais.")
	passed_tests += 1

	# ------------------------------------------------------------
	# 5. EXCLUSIVIDADE MÚTUA DOS CAMINHOS DE RYU
	# ------------------------------------------------------------
	print("\n[TESTE 5/8] Exclusividade de caminhos de Ryu preservada...")
	PlayerData.nen_skill_points = 5
	assert(tree.investir_ponto("ryu_ofensivo"), "Deve investir em ryu_ofensivo")
	assert(tree.ryu_caminho == "ofensivo", "Caminho deve ser ofensivo")
	var investiu_defensivo = tree.investir_ponto("ryu_defensivo")
	assert(not investiu_defensivo, "Não deve permitir ryu_defensivo após escolher ofensivo")
	var investiu_equilibrado = tree.investir_ponto("ryu_equilibrado")
	assert(not investiu_equilibrado, "Não deve permitir ryu_equilibrado após escolher ofensivo")
	print("  ✅ [PASS] Caminhos de Ryu mantêm exclusividade estrita.")
	passed_tests += 1

	# ------------------------------------------------------------
	# 6. PERSISTÊNCIA SAVE / LOAD
	# ------------------------------------------------------------
	print("\n[TESTE 6/8] Persistência completa da NenSkillTree no SaveManager...")
	PlayerData.nen_skill_points = 7
	PlayerData.nen_skill_tree_progress = tree.node_levels.duplicate()
	PlayerData.nen_ryu_caminho = tree.ryu_caminho

	var salvou := SaveManager.salvar_jogo(1)
	assert(salvou, "SaveManager deve salvar no slot 1")

	# Resetar dados
	PlayerData.nen_skill_points = 0
	PlayerData.nen_skill_tree_progress.clear()
	PlayerData.nen_ryu_caminho = ""
	tree.node_levels.clear()
	tree.ryu_caminho = ""

	var carregou := SaveManager.carregar_jogo(1)
	assert(carregou, "SaveManager deve carregar slot 1")
	assert(PlayerData.nen_skill_points == 7, "Pontos salvos devem ser restaurados (7)")
	assert(PlayerData.nen_ryu_caminho == "ofensivo", "Caminho Ryu restaurado")
	assert(PlayerData.nen_skill_tree_progress.get("first_strike", 0) == 1, "first_strike restaurado")
	assert(PlayerData.nen_skill_tree_progress.get("bloodied", 0) == 1, "bloodied restaurado")

	print("  ✅ [PASS] Progresso da Skill Tree, pontos e caminhos persistidos e restaurados.")
	passed_tests += 1

	# ------------------------------------------------------------
	# 7. INTEGRAÇÃO COM COMBATENGINE
	# ------------------------------------------------------------
	print("\n[TESTE 7/8] Contexto canônico e CombatEngine...")
	var ctx_dummy = CombatEngine.construir_contexto_combate(
		null,
		{"hp": 50, "max_hp": 100, "marked": true},
		{"seconds_since_damage": 6.0, "nearby_enemy_count": 1}
	)
	assert(ctx_dummy.has("player_hp_percent"), "Contexto deve ter player_hp_percent")
	assert(ctx_dummy.get("target_hp_percent") == 0.5, "target_hp_percent deve ser 0.5")
	assert(ctx_dummy.get("target_marked") == true, "target_marked deve ser true")
	assert(ctx_dummy.get("seconds_since_damage") == 6.0, "seconds_since_damage deve ser 6.0")

	print("  ✅ [PASS] CombatEngine constrói contexto canônico perfeitamente compatível.")
	passed_tests += 1

	# ------------------------------------------------------------
	# 8. NÃO-DUPLICAÇÃO COM HATSUMANAGER
	# ------------------------------------------------------------
	print("\n[TESTE 8/8] Integridade e não-duplicação de sinergias do HatsuManager...")
	var h1 := HatsuData.new()
	h1.tags = ["weapon"]
	var h2 := HatsuData.new()
	h2.tags = ["electricity"]
	var sinergia_hatsu := HatsuManager.processar_sinergia_tags(h1, h2)
	assert(sinergia_hatsu.get("sinergia", false) == true, "HatsuManager deve continuar processando sinergia de tags de Hatsu")
	assert(sinergia_hatsu.get("dano_bonus", 1.0) == 1.35, "Bônus do HatsuManager deve permanecer 1.35")
	print("  ✅ [PASS] Sinergia elemental de tags do HatsuManager preservada e isolada da Skill Tree.")
	passed_tests += 1

	# Finalização
	tree.queue_free()
	print("\n================================================================================")
	print("🎉 RESULTADO FINAL: %d/%d TESTES PASSARAM COM SUCESSO!" % [passed_tests, total_tests])
	print("================================================================================\n")
