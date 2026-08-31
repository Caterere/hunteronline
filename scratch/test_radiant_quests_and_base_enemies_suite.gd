extends Node2D

# ============================================================
# HUNTER ONLINE - TEST SUITE: BASE RPG ENEMIES & RADIANT QUESTS
# ============================================================

const RadiantQuestGenerator = preload("res://resource/quest/RadiantQuestGenerator.gd")
const BountiesBoardUI = preload("res://ui/Bounties/BountiesBoardUI.gd")

var _passou_todos: bool = true
var _total_testes: int = 0
var _testes_ok: int = 0


func _ready() -> void:
	print("================================================================================")
	print("🚀 EXECUTANDO SUÍTE DE TESTES: INIMIGOS BASE DE RPG & RADIANT FARMING QUESTS")
	print("================================================================================")
	_executar_todos_os_testes()


func _assinalar(cond: bool, msg_ok: String, msg_erro: String) -> void:
	_total_testes += 1
	if cond:
		_testes_ok += 1
		print("  ✅ [PASS] %s" % msg_ok)
	else:
		_passou_todos = false
		print("  ❌ [FAIL] %s" % msg_erro)


func _executar_todos_os_testes() -> void:
	await get_tree().process_frame

	# TESTE 1: Bestiário de Inimigos Base no DataManager
	print("\n[TESTE 1/7] Verificando Bestiário Completo de Inimigos Base no DataManager...")
	var mobs_esperados = [
		"slime", "slime_venenoso", "rato_gigante", "lobo_selvagem",
		"cao_cacador", "javali_selvagem", "ladrao_estrada", "bandido_renegado",
		"besouro_blindado", "serpente_sombra", "fera_magica_bosque",
		"macaco_carnivoro", "urso_caverna", "mercenario_mafia",
		"cacador_furtivo", "golem_pedra", "quimera_selvagem"
	]
	var todos_encontrados: bool = true
	for m_id in mobs_esperados:
		var mob = DataManager.obter_inimigo(m_id)
		if mob == null:
			todos_encontrados = false
			print("    ❌ Mob não encontrado no DataManager: ", m_id)
	_assinalar(
		todos_encontrados,
		"Todos os 17 tipos de Inimigos Base de RPG foram catalogados no DataManager.",
		"Falha: Um ou mais inimigos base não foram encontrados no catálogo."
	)

	# TESTE 2: Materiais e Drops de Monstros na Economia
	print("\n[TESTE 2/7] Verificando Itens de Drop e Economia de Farm...")
	var drops_esperados = [
		"gosma_slime", "couro_lobo", "carapaca_besouro", "presa_serpente",
		"carne_javali", "nucleo_golem", "ouro_roubado", "gema_terra",
		"veneno_concentrado", "cristal_sombra", "pele_urso", "olho_quimera"
	]
	var todos_drops_ok: bool = true
	for d_id in drops_esperados:
		var item = DataManager.obter_item(d_id)
		if item == null:
			todos_drops_ok = false
			print("    ❌ Drop não encontrado na Economia: ", d_id)
	_assinalar(
		todos_drops_ok,
		"Todos os 12 materiais de monstros e drops de farm estão registrados e precificados.",
		"Falha: Itens de drop não encontrados no catálogo da Economia."
	)

	# TESTE 3: Geração de Quests Procedurais / Radiant Quests
	print("\n[TESTE 3/7] Testando Gerador de Radiant Quests (Caça & Coleta)...")
	var pool_padokia = RadiantQuestGenerator.gerar_pool_radiant_quests("vale_padokia", 5, 4)
	var tem_caca: bool = false
	var tem_coleta: bool = false
	for q in pool_padokia:
		if q.objectives.size() > 0:
			if q.objectives[0].type == QuestObjective.Type.KILL:
				tem_caca = true
			elif q.objectives[0].type == QuestObjective.Type.COLLECT:
				tem_coleta = true
	var geracao_ok: bool = (pool_padokia.size() == 4 and tem_caca and tem_coleta)
	_assinalar(
		geracao_ok,
		"RadiantQuestGenerator gerou pool balanceado com missões de Caça e Coleta.",
		"Falha na geração de pool de missões de farm."
	)

	# TESTE 4: Aceitação e Conclusão de Kill Quest de Farm no QuestManager
	print("\n[TESTE 4/7] Testando Execução e Conclusão de Kill Quest de Farm...")
	QuestSystem.active_quests.clear()
	PlayerData.attributes["nivel"] = 5
	PlayerData.attributes["level"] = 5
	var t_lobo = {
		"enemy_id": &"lobo_selvagem",
		"enemy_name": "Lobos Ferozes",
		"tag": "Planícies de Padokia",
		"base_kills": 3,
		"min_level": 2
	}
	var q_lobo = RadiantQuestGenerator.gerar_quest_caca(t_lobo, 2, 0)
	QuestSystem.start_quest(q_lobo)
	
	var ouro_antes: int = Economy.obter_gold()
	QuestSystem.register_enemy_kill(&"lobo_selvagem")
	QuestSystem.register_enemy_kill(&"lobo_selvagem")
	QuestSystem.register_enemy_kill(&"lobo_selvagem")
	
	var ouro_depois: int = Economy.obter_gold()
	var concluiu_lobo: bool = PlayerData.is_quest_completed(q_lobo) and (ouro_depois > ouro_antes)
	_assinalar(
		concluiu_lobo,
		"Kill Quest de Lobos concluiu perfeitamente ao atingir 3/3 abates e concedeu recompensa em Gold.",
		"Falha na progressão ou conclusão da Kill Quest de farm."
	)

	# TESTE 5: Aceitação e Conclusão de Collect Quest no QuestManager
	print("\n[TESTE 5/7] Testando Execução e Conclusão de Collect Quest...")
	QuestSystem.active_quests.clear()
	var t_gosma = {
		"item_id": &"gosma_slime",
		"item_name": "Gosmas de Slime",
		"tag": "Floresta",
		"base_items": 2,
		"min_level": 1
	}
	var q_coleta = RadiantQuestGenerator.gerar_quest_coleta(t_gosma, 1, 0)
	QuestSystem.start_quest(q_coleta)
	
	QuestSystem.register_item_collected(&"gosma_slime", 1)
	QuestSystem.register_item_collected(&"gosma_slime", 1)
	
	var concluiu_coleta: bool = PlayerData.is_quest_completed(q_coleta)
	_assinalar(
		concluiu_coleta,
		"Collect Quest de Gosmas de Slime completada com sucesso ao coletar 2/2 itens.",
		"Falha na progressão da Collect Quest de farm."
	)

	# TESTE 6: Sistema de Contratos do BountySystem
	print("\n[TESTE 6/7] Testando Contratos do BountySystem & Abate de Foras-da-Lei...")
	var contratos_padokia = BountySystem.obter_contratos_por_regiao("vale_padokia")
	var tem_bounties: bool = contratos_padokia.size() >= 2
	BountySystem.aceitar_contrato("bounty_ladrao_padokia")
	var c_aceito: bool = BountySystem.active_bounty_contracts["bounty_ladrao_padokia"].get("aceito", false)
	
	# Simular derrota do alvo de bounty
	BountySystem._on_enemy_defeated("Goran, o Mão-Leve", 100, 50)
	var c_concluido: bool = BountySystem.active_bounty_contracts["bounty_ladrao_padokia"].get("concluido", false)
	
	_assinalar(
		tem_bounties and c_aceito and c_concluido,
		"BountySystem gerou contratos, aceitou e resgatou recompensa de procurado.",
		"Falha na integração de contratos do BountySystem."
	)

	# TESTE 7: UI do Quadro de Caças (BountiesBoardUI)
	print("\n[TESTE 7/7] Testando Interface do Quadro de Caças (BountiesBoardUI)...")
	var board_ui = BountiesBoardUI.new()
	add_child(board_ui)
	board_ui.abrir()
	var tem_filhos_ui: bool = board_ui.container_bounties.get_child_count() > 0
	board_ui.fechar()
	board_ui.queue_free()
	
	_assinalar(
		tem_filhos_ui,
		"BountiesBoardUI instanciou e populou dinamicamente os cartazes de contratos.",
		"Falha na renderização dos cartazes no BountiesBoardUI."
	)

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE INIMIGOS BASE & RADIANT FARMING:")
	print("   TESTES APROVADOS: %d / %d (%.1f%%)" % [_testes_ok, _total_testes, (float(_testes_ok)/_total_testes)*100.0])
	if _passou_todos:
		print("   STATUS: SISTEMA DE FARM, BESTIÁRIO BASE E RADIANT QUESTS 100% OPERACIONAIS!")
	else:
		print("   STATUS: FALHA DETECTADA NA SUÍTE!")
	print("================================================================================\n")

	get_tree().quit(0 if _passou_todos else 1)
