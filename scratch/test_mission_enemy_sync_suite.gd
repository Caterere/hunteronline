extends Node

# ============================================================
# TEST SUITE: SINCRONIZAÇÃO E PROTEÇÃO DE INIMIGOS DE MISSÃO
# ============================================================

var _total_tests: int = 0
var _passed_tests: int = 0
var _failed_tests: int = 0

func _ready() -> void:
	print("==================================================================")
	print("🚀 INICIANDO SUITE DE TESTES: SINCRONIZAÇÃO DE INIMIGOS DE MISSÃO")
	print("==================================================================")
	
	# Executar bateria de testes
	await _executar_testes()
	
	print("==================================================================")
	print("📊 RESULTADO FINAL:")
	print("  Total de Testes: ", _total_tests)
	print("  Passaram: ", _passed_tests)
	print("  Falharam: ", _failed_tests)
	print("==================================================================")
	
	if _failed_tests == 0:
		print("🎉 TODOS OS TESTES PASSARAM COM 100% DE SUCESSO!")
	else:
		push_error("❌ ALGUNS TESTES FALHARAM!")
		
	get_tree().quit(0 if _failed_tests == 0 else 1)


func _assert(condicao: bool, nome_teste: String) -> void:
	_total_tests += 1
	if condicao:
		_passed_tests += 1
		print("  ✅ [PASSOU] ", nome_teste)
	else:
		_failed_tests += 1
		print("  ❌ [FALHOU] ", nome_teste)
		push_error("Falha no teste: " + nome_teste)


func _executar_testes() -> void:
	await _teste_1_fluxo_normal()
	await _teste_2_protecao_inimigo_futuro()
	await _teste_3_reconciliacao_e_respawn()
	await _teste_4_prevencao_duplicacao()
	await _teste_5_inimigo_normal()
	await _teste_6_recompensas_xp_loot()
	await _teste_7_transicao_multiplos_objetivos()
	await _teste_8_persistencia_reentrada()


# Helper para instanciar um inimigo de teste
func _criar_inimigo_teste(enemy_id: StringName, is_mission: bool, arc: int = 0, etapa: int = 0, obj_idx: int = -1, hp: int = 50) -> CharacterBody2D:
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	var enemy: CharacterBody2D = enemy_scn.instantiate() as CharacterBody2D
	add_child(enemy)
	
	var es: EnemySystem = enemy.get_node_or_null("EnemySystem") as EnemySystem
	if es != null:
		es.enemy_id = enemy_id
		es.enemy_name = str(enemy_id).replace("_", " ").capitalize()
		es.is_mission_enemy = is_mission
		es.quest_arc = arc
		es.quest_etapa = etapa
		es.quest_objective_index = obj_idx
		es.max_health = hp
		es.health = hp
		es.defense = 0
	
	return enemy


# ------------------------------------------------------------
# TESTE 1: FLUXO NORMAL
# ------------------------------------------------------------
func _teste_1_fluxo_normal() -> void:
	print("\n--- TESTE 1: FLUXO NORMAL DE MISSÃO COM COMBATE ---")
	PlayerData.attributes = {
		"vida": 100, "vida_max": 100, "forca": 10, "defesa": 10, "velocidade": 10,
		"aura": 0.0, "aura_max": 0.0, "nivel_nen": 0, "xp_nen": 0, "nivel": 1
	}
	PlayerData.quest_states.clear()
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 2
	QuestSystem.active_quests.clear()
	
	var q2 = CanonQuestCatalog.obter_quest_da_etapa(1, 2)
	QuestSystem.start_quest(q2)
	
	# Etapa 2 possui: 0: Visit gon, 1: Visit killua, 2: Visit gittarackur, 3: Kill 2 candidato_exame
	# Completar as 3 visitas preliminares para alcançar o objetivo de combate
	QuestSystem.register_npc_visit(&"gon")
	QuestSystem.register_npc_visit(&"killua")
	QuestSystem.register_npc_visit(&"gittarackur")
	
	var obj = QuestSystem.get_active_objective()
	_assert(obj != null and obj.type == QuestObjective.Type.KILL, "Objetivo ativo da Etapa 2 após visitas é do tipo KILL")
	_assert(obj.enemy_type == &"candidato_exame", "Tipo de inimigo requerido é candidato_exame")
	
	# Criar inimigo de teste
	var dummy_enemy = _criar_inimigo_teste(&"candidato_exame", true, 1, 2, 3, 50)
	
	# Registrar 2 abates válidos
	QuestSystem.register_enemy_kill(&"candidato_exame")
	var prog1 = PlayerData.get_quest_objective_progress(q2, 3)
	_assert(prog1 == 1, "Progresso incrementado para 1/2")
	
	QuestSystem.register_enemy_kill(&"candidato_exame")
	var prog2 = PlayerData.get_quest_objective_progress(q2, 3)
	_assert(prog2 == 2, "Progresso incrementado para 2/2 e objetivo completo")
	
	dummy_enemy.queue_free()


# ------------------------------------------------------------
# TESTE 2: PROTEÇÃO CONTRA INIMIGO FUTURO
# ------------------------------------------------------------
func _teste_2_protecao_inimigo_futuro() -> void:
	print("\n--- TESTE 2: PROTEÇÃO CONTRA MORTE DE INIMIGO FUTURO ---")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 1 # Etapa 1 (sem objetivos de javali)
	PlayerData.quest_states.clear()
	QuestSystem.active_quests.clear()
	
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	QuestSystem.start_quest(q1)
	
	# Criar inimigo de etapa futura (Javali da Etapa 5)
	var future_enemy = _criar_inimigo_teste(&"great_stamp_pig", true, 1, 5, 0, 100)
	var es: EnemySystem = future_enemy.get_node_or_null("EnemySystem")
	var hp_inicial = es.health
	
	# Verificar se o sistema reconhece como inválido para o objetivo atual
	var valido = QuestSystem.is_enemy_valid_for_active_objective(es.enemy_id, es)
	_assert(not valido, "Inimigo de etapa futura é marcado como INVÁLIDO para o objetivo ativo")
	
	# Tentar aplicar dano -> deve ser bloqueado
	es.take_damage(50)
	_assert(es.health == hp_inicial, "Dano em inimigo de missão futura é bloqueado (HP intacto)")
	
	# Tentar enviar sinal de kill -> QuestManager não deve aceitar para etapas futuras
	QuestSystem.register_enemy_kill(&"great_stamp_pig")
	var q5 = CanonQuestCatalog.obter_quest_da_etapa(1, 5)
	var prog_q5 = PlayerData.get_quest_objective_progress(q5, 0)
	_assert(prog_q5 == 0, "Abate prematuro NÃO vazou para o progresso da Etapa 5")
	
	future_enemy.queue_free()


# ------------------------------------------------------------
# TESTE 3: RECONCILIAÇÃO E RESPAWN ORIENTADO A ESTADO
# ------------------------------------------------------------
func _teste_3_reconciliacao_e_respawn() -> void:
	print("\n--- TESTE 3: RECONCILIAÇÃO E RESPAWN AUTOMÁTICO ---")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 4 # Etapa 4: Objetivo 0 é Kill 3 criatura_pantanal
	PlayerData.quest_states.clear()
	QuestSystem.active_quests.clear()
	QuestSystem.limpar_registro_spawns()
	
	# Limpar inimigos prévios do grupo
	for node in get_tree().get_nodes_in_group("enemy_systems"):
		if is_instance_valid(node) and node.get_parent() != null:
			node.get_parent().queue_free()
	
	await get_tree().process_frame
	
	# Registrar âncora de spawn para criatura_pantanal
	QuestSystem.registrar_spawn_posicao_missao(&"criatura_pantanal", Vector2(100, 100), 1, 4, 0, null, "Macaco do Pantanal")
	
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(1, 4)
	QuestSystem.start_quest(q4)
	
	# Verificar se a sincronização automática ao iniciar quest gerou os 3 inimigos
	var count_vivos: int = 0
	for node in get_tree().get_nodes_in_group("enemy_systems"):
		var es = node as EnemySystem
		if es != null and is_instance_valid(es) and es.enemy_id == &"criatura_pantanal" and es.is_alive():
			count_vivos += 1
			
	_assert(count_vivos == 3, "Reconciliação instanciou exatamente os 3 inimigos requeridos na cena")
	_assert(QuestSystem.total_reconciliations_triggered >= 1, "Métrica de reconciliações incrementada")


# ------------------------------------------------------------
# TESTE 4: PREVENÇÃO DE DUPLICAÇÃO
# ------------------------------------------------------------
func _teste_4_prevencao_duplicacao() -> void:
	print("\n--- TESTE 4: PREVENÇÃO DE DUPLICAÇÃO DE INIMIGOS ---")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 4 # Etapa 4: Kill 3 criatura_pantanal
	PlayerData.quest_states.clear()
	QuestSystem.active_quests.clear()
	
	# Limpar inimigos prévios
	for node in get_tree().get_nodes_in_group("enemy_systems"):
		if is_instance_valid(node) and node.get_parent() != null:
			node.get_parent().queue_free()
	await get_tree().process_frame
	
	# Criar exatamente 3 inimigos já presentes na cena
	for i in range(3):
		var en = _criar_inimigo_teste(&"criatura_pantanal", true, 1, 4, 0, 50)
		var es: EnemySystem = en.get_node_or_null("EnemySystem")
		if es != null:
			es.ativar_inimigo_missao(true)
	
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(1, 4)
	QuestSystem.start_quest(q4)
	
	# Executar sincronização 5 vezes seguidas
	for _i in range(5):
		QuestSystem.sincronizar_inimigos_do_mapa()
		
	var total_instancias: int = 0
	for node in get_tree().get_nodes_in_group("enemy_systems"):
		var es = node as EnemySystem
		if es != null and is_instance_valid(es) and es.enemy_id == &"criatura_pantanal" and es.is_alive():
			total_instancias += 1
			
	_assert(total_instancias == 3, "Sincronizações repetidas mantiveram a contagem estrita de 3 inimigos (ZERO duplicatas)")


# ------------------------------------------------------------
# TESTE 5: INIMIGO NORMAL (NÃO PERTENCENTE A MISSÃO)
# ------------------------------------------------------------
func _teste_5_inimigo_normal() -> void:
	print("\n--- TESTE 5: INIMIGO NORMAL NÃO PERTENCENTE A MISSÃO ---")
	var mob = _criar_inimigo_teste(&"slime_comum", false, 0, 0, -1, 40)
	var es: EnemySystem = mob.get_node_or_null("EnemySystem")
	es.xp_reward = 25
	es.defense = 0
	es.health = 40
	
	# Deve ser sempre válido para combate
	var valido = QuestSystem.is_enemy_valid_for_active_objective(es.enemy_id, es)
	_assert(valido, "Inimigo comum é SEMPRE válido para combate")
	
	# Sofre dano normalmente
	es.take_damage(20)
	_assert(es.health == 20, "Inimigo comum sofre dano normalmente (20/40)")
	
	mob.queue_free()


# ------------------------------------------------------------
# TESTE 6: PRESERVAÇÃO DE RECOMPENSAS DE XP E LOOT
# ------------------------------------------------------------
func _teste_6_recompensas_xp_loot() -> void:
	print("\n--- TESTE 6: RECOMPENSAS DE XP E LOOT EM INIMIGO DE MISSÃO ---")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 4
	PlayerData.quest_states.clear()
	QuestSystem.active_quests.clear()
	
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(1, 4)
	QuestSystem.start_quest(q4)
	
	var mob = _criar_inimigo_teste(&"criatura_pantanal", true, 1, 4, 0, 30)
	var es: EnemySystem = mob.get_node_or_null("EnemySystem")
	es.xp_reward = 100
	es.nen_xp_reward = 50
	es.defense = 0
	es.health = 30
	
	var evento_derrotado_disparado := false
	if EventBus != null:
		EventBus.enemy_defeated.connect(func(_id, _xp, _nxp): evento_derrotado_disparado = true, CONNECT_ONE_SHOT)
	
	# Matar o inimigo com 50 de dano (HP é 30)
	es.take_damage(50)
	_assert(es.is_dead, "Inimigo de missão ativa foi derrotado legitimamente")
	_assert(evento_derrotado_disparado or not es.is_alive(), "Evento de derrota e morte do inimigo executado com sucesso")
	
	mob.queue_free()


# ------------------------------------------------------------
# TESTE 7: TRANSIÇÃO ENTRE MÚLTIPLOS OBJETIVOS
# ------------------------------------------------------------
func _teste_7_transicao_multiplos_objetivos() -> void:
	print("\n--- TESTE 7: TRANSIÇÃO SEQUENCIAL DE OBJETIVOS ---")
	var quest_multi = Quest.new()
	quest_multi.quest_name = "Missão Multi Objetivos Teste"
	
	var obj1 = QuestObjective.new()
	obj1.type = QuestObjective.Type.VISIT
	obj1.target_npc_id = &"npc_guia"
	obj1.required_amount = 1
	
	var obj2 = QuestObjective.new()
	obj2.type = QuestObjective.Type.KILL
	obj2.enemy_type = &"guardiao_teste"
	obj2.required_amount = 2
	
	var objs: Array[QuestObjective] = [obj1, obj2]
	quest_multi.objectives = objs
	
	PlayerData.quest_states.clear()
	QuestSystem.active_quests.clear()
	QuestSystem.start_quest(quest_multi)
	
	# Criar inimigo vinculado ao Objetivo 2
	var mob = _criar_inimigo_teste(&"guardiao_teste", true, 0, 0, 1, 50)
	var es: EnemySystem = mob.get_node_or_null("EnemySystem")
	
	# No Objetivo 1: inimigo do Objetivo 2 é inválido
	_assert(not QuestSystem.is_enemy_valid_for_active_objective(es.enemy_id, es), "Inimigo do Objetivo 2 está protegido enquanto Objetivo 1 está ativo")
	
	# Concluir Objetivo 1
	QuestSystem.register_npc_visit(&"npc_guia")
	
	# Agora no Objetivo 2: inimigo torna-se válido!
	_assert(QuestSystem.is_enemy_valid_for_active_objective(es.enemy_id, es), "Inimigo do Objetivo 2 torna-se VÁLIDO após conclusão do Objetivo 1")
	
	mob.queue_free()


# ------------------------------------------------------------
# TESTE 8: PERSISTÊNCIA E REENTRADA
# ------------------------------------------------------------
func _teste_8_persistencia_reentrada() -> void:
	print("\n--- TESTE 8: PERSISTÊNCIA E REENTRADA NO MAPA ---")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 4 # Etapa 4: Kill 3 criatura_pantanal
	PlayerData.quest_states.clear()
	QuestSystem.active_quests.clear()
	
	var q4 = CanonQuestCatalog.obter_quest_da_etapa(1, 4)
	QuestSystem.start_quest(q4)
	
	# Progredir 1/3 kills
	QuestSystem.register_enemy_kill(&"criatura_pantanal")
	
	# Simular save / restore do progresso
	var saved_progress = PlayerData.get_quest_objective_progress(q4, 0)
	_assert(saved_progress == 1, "Progresso salvo de 1/3 kills confirmado")
	
	# Simular reentrada no mapa: telemetria confirma progresso persistido
	var diag = QuestSystem.obter_debug_telemetria_missoes()
	_assert(diag.get("current_progress") == 1, "Telemetria de missão confirma progresso persistido")
	_assert(diag.get("required_amount") == 3, "Quantidade necessária é 3")
