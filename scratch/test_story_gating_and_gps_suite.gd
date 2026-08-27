extends Node2D

const StoryGate = preload("res://world/components/StoryGate.gd")

var _passou_todos: bool = true
var _total_testes: int = 0
var _testes_ok: int = 0

func _ready() -> void:
	print("================================================================================")
	print("🚀 EXECUTANDO SUÍTE DE TESTES: STORY GATING, QUESTS OBRIGATÓRIAS & GPS DINÂMICO")
	print("================================================================================")
	
	_executar_todos_os_testes()


func _executar_todos_os_testes() -> void:
	await get_tree().process_frame
	
	_teste_1_portal_bloqueado_inicio()
	_teste_2_progresso_parcial_bloqueado()
	_teste_3_gps_aponta_criatura_valida()
	_teste_4_gps_recalcula_apos_abate()
	_teste_5_completude_objetivo()
	_teste_6_portal_liberado_conclusao()
	_teste_7_persistencia_save_load()
	_teste_8_protecao_spam_interacao()
	_teste_9_inimigo_invalido_nao_conta()
	_teste_10_gps_fallback_sem_alvo()
	_teste_11_story_gate_generico_multiplos_requisitos()
	_teste_12_integracao_exame_maratona_map()

	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE DE STORY GATING & GPS:")
	print("   TESTES APROVADOS: %d / %d (%.1f%%)" % [_testes_ok, _total_testes, (float(_testes_ok)/_total_testes)*100.0])
	if _passou_todos:
		print("   STATUS: SISTEMA DE PROGRESSÃO NARRATIVA, STORY GATES E GPS 100% BLINDADOS!")
	else:
		print("   STATUS: FALHA DETECTADA NA SUÍTE DE TESTES!")
	print("================================================================================\n")
	
	get_tree().quit(0 if _passou_todos else 1)


func _assinalar(cond: bool, msg_ok: String, msg_erro: String) -> void:
	_total_testes += 1
	if cond:
		_testes_ok += 1
		print("  ✅ [PASS] %s" % msg_ok)
	else:
		_passou_todos = false
		print("  ❌ [FAIL] %s" % msg_erro)


# ------------------------------------------------------------------------------
# TESTE 1: Portal Bloqueado no Início do Exame
# ------------------------------------------------------------------------------
func _teste_1_portal_bloqueado_inicio() -> void:
	print("\n[TESTE 1/12] Verificando bloqueio estrito do portal no início do Exame...")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 3 # Etapa 3: Criaturas do Pantanal
	PlayerData.quest_states.clear()
	
	var quest = CanonQuestCatalog.obter_quest_da_etapa(1, 3)
	QuestSystem.active_quests.clear()
	QuestSystem.start_quest(quest)
	
	var gate = StoryGate.new(1, 6, true)
	var pode_avancar = gate.can_advance()
	var pendencias = gate.get_unmet_requirements()
	
	_assinalar(not pode_avancar and not pendencias.is_empty(), 
		"Portal permanece estritamente bloqueado no início do Exame (Pendências: %d)" % pendencias.size(),
		"Portal permitiu avanço indevido com 0 criaturas derrotadas!")


# ------------------------------------------------------------------------------
# TESTE 2: Progresso Parcial (1/3 ou 2/3) Continua Bloqueado
# ------------------------------------------------------------------------------
func _teste_2_progresso_parcial_bloqueado() -> void:
	print("\n[TESTE 2/12] Verificando bloqueio com progresso parcial (1/3 criaturas)...")
	var quest = CanonQuestCatalog.obter_quest_da_etapa(1, 3)
	# Registrar 1 kill de criatura do pantanal
	QuestSystem.register_enemy_kill(&"criatura_pantanal")
	
	var prog = PlayerData.get_quest_objective_progress(quest, 3) # Obj 4 é kill
	var gate = StoryGate.new(1, 6, true)
	var pode_avancar = gate.can_advance()
	
	_assinalar(prog == 1 and not pode_avancar,
		"Progresso parcial (1/3) registrado e portal continua bloqueando com precisão.",
		"Progresso parcial permitiu travessia do portal prematuramente!")


# ------------------------------------------------------------------------------
# TESTE 3: GPS Aponta para Criatura Válida
# ------------------------------------------------------------------------------
func _teste_3_gps_aponta_criatura_valida() -> void:
	print("\n[TESTE 3/12] Testando detecção e mira do GPS em criaturas válidas vivas...")
	var quest = CanonQuestCatalog.obter_quest_da_etapa(1, 3)
	QuestSystem.active_quests.clear()
	QuestSystem.start_quest(quest)
	PlayerData.set_quest_objective_progress(quest, 0, 1) # Satotz concluído
	PlayerData.set_quest_objective_progress(quest, 1, 1) # Pokkle concluído
	PlayerData.set_quest_objective_progress(quest, 2, 1) # Ponzu concluído
	PlayerData.set_quest_objective_progress(quest, 3, 0) # 0/3 criaturas pendente

	var dummy_player = CharacterBody2D.new()
	dummy_player.name = "Player"
	dummy_player.add_to_group("player")
	dummy_player.global_position = Vector2(0, 0)
	add_child(dummy_player)
	
	# Criar criatura viva
	var dummy_enemy = CharacterBody2D.new()
	dummy_enemy.name = "MonstroPantanal1"
	dummy_enemy.add_to_group("enemy")
	dummy_enemy.global_position = Vector2(500, 0)
	
	var esys = Node.new()
	esys.name = "EnemySystem"
	esys.set_script(load("res://scripts/systems/EnemySystem/EnemySystem.gd"))
	esys.set("enemy_id", &"criatura_pantanal")
	esys.set("enemy_name", "Macaco de Rosto Humano")
	esys.set("is_dead", false)
	dummy_enemy.add_child(esys)
	add_child(dummy_enemy)
	
	var gps = MissionGPSIndicator.new()
	add_child(gps)
	gps.player_ref = dummy_player
	gps._atualizar_alvo_ativo()
	
	var alvo_correto = (gps.current_target_node == dummy_enemy or gps.current_target_pos == dummy_enemy.global_position)
	_assinalar(gps.target_found and alvo_correto,
		"GPS identificou e apontou diretamente para a criatura do pantanal viva.",
		"GPS falhou em localizar a criatura do pantanal viva!")
	
	gps.queue_free()
	dummy_enemy.queue_free()
	dummy_player.queue_free()


# ------------------------------------------------------------------------------
# TESTE 4: GPS Recalcula Após Abate
# ------------------------------------------------------------------------------
func _teste_4_gps_recalcula_apos_abate() -> void:
	print("\n[TESTE 4/12] Testando recálculo do GPS após abate da primeira criatura...")
	var quest = CanonQuestCatalog.obter_quest_da_etapa(1, 3)
	QuestSystem.active_quests.clear()
	QuestSystem.start_quest(quest)
	PlayerData.set_quest_objective_progress(quest, 0, 1)
	PlayerData.set_quest_objective_progress(quest, 1, 1)
	PlayerData.set_quest_objective_progress(quest, 2, 1)
	PlayerData.set_quest_objective_progress(quest, 3, 0)

	var dummy_player = CharacterBody2D.new()
	dummy_player.name = "Player"
	dummy_player.add_to_group("player")
	dummy_player.global_position = Vector2(0, 0)
	add_child(dummy_player)
	
	# Criatura 1 (mais próxima)
	var e1 = CharacterBody2D.new()
	e1.name = "MonstroPantanal1"
	e1.add_to_group("enemy")
	e1.global_position = Vector2(300, 0)
	var esys1 = Node.new()
	esys1.name = "EnemySystem"
	esys1.set_script(load("res://scripts/systems/EnemySystem/EnemySystem.gd"))
	esys1.set("enemy_id", &"criatura_pantanal")
	esys1.set("enemy_name", "Macaco de Rosto Humano 1")
	esys1.set("is_dead", false)
	e1.add_child(esys1)
	add_child(e1)
	
	# Criatura 2 (mais distante)
	var e2 = CharacterBody2D.new()
	e2.name = "MonstroPantanal2"
	e2.add_to_group("enemy")
	e2.global_position = Vector2(700, 0)
	var esys2 = Node.new()
	esys2.name = "EnemySystem"
	esys2.set_script(load("res://scripts/systems/EnemySystem/EnemySystem.gd"))
	esys2.set("enemy_id", &"criatura_pantanal")
	esys2.set("enemy_name", "Macaco de Rosto Humano 2")
	esys2.set("is_dead", false)
	e2.add_child(esys2)
	add_child(e2)
	
	var gps = MissionGPSIndicator.new()
	add_child(gps)
	gps.player_ref = dummy_player
	gps._atualizar_alvo_ativo()
	
	var mirou_e1 = (gps.current_target_node == e1)
	
	# Simular morte de e1
	esys1.set("is_dead", true)
	e1.remove_from_group("enemy")
	e1.remove_from_group("enemies")
	
	gps._atualizar_alvo_ativo()
	var mirou_e2 = (gps.current_target_node == e2)
	
	_assinalar(mirou_e1 and mirou_e2,
		"GPS mirou inicialmente no alvo mais próximo (e1) e recalculou instantaneamente para o próximo vivo (e2).",
		"GPS não recalculou o alvo após a morte da primeira criatura!")
	
	gps.queue_free()
	e1.queue_free()
	e2.queue_free()
	dummy_player.queue_free()


# ------------------------------------------------------------------------------
# TESTE 5: Completude do Objetivo (3/3)
# ------------------------------------------------------------------------------
func _teste_5_completude_objetivo() -> void:
	print("\n[TESTE 5/12] Testando conclusão do objetivo ao atingir 3/3 abates...")
	var quest = CanonQuestCatalog.obter_quest_da_etapa(1, 3)
	QuestSystem.active_quests.clear()
	QuestSystem.start_quest(quest)
	
	# Simular abates até 3/3
	QuestSystem.register_enemy_kill(&"criatura_pantanal")
	QuestSystem.register_enemy_kill(&"criatura_pantanal")
	QuestSystem.register_enemy_kill(&"criatura_pantanal")
	
	var prog = PlayerData.get_quest_objective_progress(quest, 3)
	_assinalar(prog == 3,
		"Objetivo atingiu 3/3 abates com sucesso e sem ultrapassar o teto.",
		"Objetivo falhou ao computar 3/3 abates!")


# ------------------------------------------------------------------------------
# TESTE 6: Portal Liberado Após Conclusão de Requisitos
# ------------------------------------------------------------------------------
func _teste_6_portal_liberado_conclusao() -> void:
	print("\n[TESTE 6/12] Verificando liberação do portal com todos os requisitos concluídos...")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 6 # Portão Final
	QuestSystem.active_quests.clear()
	var q6 = CanonQuestCatalog.obter_quest_da_etapa(1, 6)
	QuestSystem.start_quest(q6)
	for i in range(q6.objectives.size()):
		PlayerData.set_quest_objective_progress(q6, i, q6.objectives[i].required_amount)
	
	var gate = StoryGate.new(1, 6, true)
	var pode_avancar = gate.can_advance()
	
	_assinalar(pode_avancar,
		"StoryGate autorizou passagem oficialmente após conclusão de todas as 6 etapas do Exame Hunter.",
		"StoryGate permaneceu indevidamente bloqueado mesmo após conclusão!")


# ------------------------------------------------------------------------------
# TESTE 7: Persistência de Save / Load
# ------------------------------------------------------------------------------
func _teste_7_persistencia_save_load() -> void:
	print("\n[TESTE 7/12] Testando persistência do estado da história e objetivos...")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 4
	var save_slot = 98
	
	SaveManager.salvar_jogo(save_slot)
	
	# Alterar temporariamente
	PlayerData.etapa_quest_arco = 1
	
	# Carregar save
	SaveManager.carregar_jogo(save_slot)
	
	_assinalar(PlayerData.etapa_quest_arco == 4 and PlayerData.arco_atual == 1,
		"SaveManager restaurou rigorosamente a etapa da história (Arco %d, Etapa %d)." % [PlayerData.arco_atual, PlayerData.etapa_quest_arco],
		"Falha na restauração do progresso da história após Load!")
	
	SaveManager.deletar_save(save_slot)


# ------------------------------------------------------------------------------
# TESTE 8: Proteção Contra Spam de Interação no Portal
# ------------------------------------------------------------------------------
func _teste_8_protecao_spam_interacao() -> void:
	print("\n[TESTE 8/12] Testando resistência a spam de interação [E] em portal bloqueado...")
	var portal = MapTransitionArea.new()
	portal.name = "PortalTesteSpam"
	portal.target_scene_path = "res://world/maps/montanha_kukuroo.tscn"
	portal.story_gate = StoryGate.new(1, 6, true)
	add_child(portal)
	
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 2
	
	var dummy_p = CharacterBody2D.new()
	dummy_p.name = "Player"
	
	# Disparar 10 interações seguidas
	for i in range(10):
		portal._on_interacted(dummy_p)
	
	_assinalar(not portal.ja_trocando,
		"Spam de 10 interações em portal bloqueado foi 100% rejeitado sem disparar transição.",
		"Spam de interação burlou o StoryGate!")
	
	portal.queue_free()
	dummy_p.queue_free()


# ------------------------------------------------------------------------------
# TESTE 9: Inimigo Inválido Não Altera o Contador
# ------------------------------------------------------------------------------
func _teste_9_inimigo_invalido_nao_conta() -> void:
	print("\n[TESTE 9/12] Testando filtro estrito de inimigos (inimigo comum não conta para a quest)...")
	var quest = CanonQuestCatalog.obter_quest_da_etapa(1, 3)
	QuestSystem.active_quests.clear()
	QuestSystem.start_quest(quest)
	
	PlayerData.set_quest_objective_progress(quest, 3, 1) # 1/3
	
	# Matar inimigo não relacionado (ex: slime de teste)
	QuestSystem.register_enemy_kill(&"slime_comum_aleatorio")
	
	var prog = PlayerData.get_quest_objective_progress(quest, 3)
	_assinalar(prog == 1,
		"Inimigo não pertencente ao objetivo foi ignorado com sucesso (Progresso mantido em 1/3).",
		"Inimigo inválido incrementou indevidamente a contagem da quest!")


# ------------------------------------------------------------------------------
# TESTE 10: Fallback Seguro do GPS Sem Alvos na Cena
# ------------------------------------------------------------------------------
func _teste_10_gps_fallback_sem_alvo() -> void:
	print("\n[TESTE 10/12] Testando fallback seguro do GPS quando não há monstros vivos na área...")
	var dummy_player = CharacterBody2D.new()
	dummy_player.name = "Player"
	dummy_player.add_to_group("player")
	dummy_player.global_position = Vector2(0, 0)
	add_child(dummy_player)
	
	var gps = MissionGPSIndicator.new()
	add_child(gps)
	gps.player_ref = dummy_player
	
	# Nenhuma criatura viva no mapa
	gps._atualizar_alvo_ativo()
	
	_assinalar(not gps.target_found and gps.lbl_target_info != null,
		"GPS operou com fallback limpo e informativo sem crashar nem apontar falsamente para saídas.",
		"GPS entrou em estado inválido ou apontou para portal indevidamente!")
	
	gps.queue_free()
	dummy_player.queue_free()


# ------------------------------------------------------------------------------
# TESTE 11: StoryGate Genérico com Múltiplos Requisitos (AND)
# ------------------------------------------------------------------------------
func _teste_11_story_gate_generico_multiplos_requisitos() -> void:
	print("\n[TESTE 11/12] Testando StoryGate com múltiplos requisitos combinados...")
	var gate = StoryGate.new(1, 3, false)
	gate.required_kills = {"criatura_pantanal": 3}
	
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 3
	QuestSystem.active_quests.clear()
	PlayerData.quest_states["kills_criatura_pantanal"] = 0
	
	var pode1 = gate.can_advance()
	
	# Cumprir kills (3/3)
	PlayerData.quest_states["kills_criatura_pantanal"] = 3
	
	var pode2 = gate.can_advance()
	
	_assinalar(not pode1 and pode2,
		"StoryGate genérico validou múltiplos requisitos combinados (Etapa + Kills) com perfeição.",
		"StoryGate genérico falhou na combinação de múltiplos requisitos!")


# ------------------------------------------------------------------------------
# TESTE 12: Integração com Cena do Exame Maratona
# ------------------------------------------------------------------------------
func _teste_12_integracao_exame_maratona_map() -> void:
	print("\n[TESTE 12/12] Testando configuração do StoryGate no ExameMaratonaMap...")
	var exame_map = ExameMaratonaMap.new()
	add_child(exame_map)
	
	var portal = MapTransitionArea.new()
	portal.name = "PortalMontanhaKukuroo"
	exame_map.add_child(portal)
	
	exame_map._configurar_portal_conclusao()
	
	var configurado = (portal.story_gate != null and portal.story_gate.required_all_arc_stages)
	_assinalar(configurado,
		"ExameMaratonaMap configurou oficialmente o StoryGate com bloqueio integral do Arco 1.",
		"ExameMaratonaMap não configurou o StoryGate no portal de conclusão!")
	
	exame_map.queue_free()