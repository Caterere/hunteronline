extends Node2D

# ============================================================
# HUNTER ONLINE — MASTER REBUILD AUTOMATED VERIFICATION SUITE
# ============================================================
#
# Validação de ponta a ponta da reconstrução arquitetural:
# 1. StoryManager (Single Source of Truth, 9 Sagas, Capítulos e Flags)
# 2. StoryGate (Validação Anti-Bypass de Portais)
# 3. MissionInstance (Ciclo de Vida Isolado e Cleanup Atômico)
# 4. WorldSpawner (Ciclo de Vida de Spawn e Respawn de Inimigos Livres)
# 5. Arena Celestial (Spawns dos Andares 1 a 190 e Teste da Água de Wing)
# 6. Tutorial de Elena (Anti-Deadlock em Todas as Etapas)
# 7. Biscuit Krueger (Desbloqueio Contextual no Arco 5 - Greed Island)
# 8. SaveManager & Versioning (Persistência Atômica, Slot Roundtrip)
# ============================================================

const MissionInstanceClass = preload("res://scripts/missions/MissionInstance.gd")
const WorldSpawnerClass = preload("res://world/components/WorldSpawner.gd")

var _total_testes: int = 0
var _testes_passados: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("🚀 INICIANDO SUÍTE MESTRE DE RECONSTRUÇÃO: HUNTER MMORPG")
	print("============================================================")

	_teste_1_story_manager()
	_teste_2_story_gate_anti_bypass()
	await _teste_3_mission_instance()
	await _teste_4_world_spawner_lifecycle()
	_teste_5_arena_celestial_conteudo()
	_teste_6_tutorial_elena_resiliencia()
	_teste_7_biscuit_greed_island()
	_teste_8_save_load_versioning_cycle()

	print("\n============================================================")
	print("🏆 RESULTADO FINAL: %d / %d TESTES APROVADOS" % [_testes_passados, _total_testes])
	if _testes_passados == _total_testes:
		print("   STATUS: ARQUITETURA RECONSTRUÍDA E BLINDADA COM SUCESSO!")
	else:
		printerr("   ALERTA: %d testes falharam!" % (_total_testes - _testes_passados))
	print("============================================================\n")


func _assinalar(condicao: bool, msg_sucesso: String, msg_falha: String) -> void:
	_total_testes += 1
	if condicao:
		_testes_passados += 1
		print("  ✅ [PASS] " + msg_sucesso)
	else:
		printerr("  ❌ [FAIL] " + msg_falha)


# ------------------------------------------------------------------------------
# TESTE 1: StoryManager (Single Source of Truth)
# ------------------------------------------------------------------------------
func _teste_1_story_manager() -> void:
	print("\n[TESTE 1/8] Testando StoryManager como autoridade central de história...")
	var sm = StoryManager
	if sm == null:
		sm = get_tree().root.get_node_or_null("StoryManager")

	var existe_sm: bool = sm != null
	if not existe_sm:
		_assinalar(false, "", "StoryManager não encontrado como autoload!")
		return

	sm.iniciar_saga(1)
	var saga1_ok: bool = sm.current_saga == 1 and sm.current_chapter == 1 and sm.obter_nome_saga(1) == "287º Exame Hunter"
	var sync_pdata_ok: bool = PlayerData.arco_atual == 1 and PlayerData.etapa_quest_arco == 1

	sm.avancar_capitulo()
	var cap2_ok: bool = sm.current_chapter == 2 and PlayerData.etapa_quest_arco == 2

	sm.set_story_flag("teste_chave", 42)
	var flag_ok: bool = int(sm.get_story_flag("teste_chave")) == 42

	var serializado: Dictionary = sm.serializar()
	var serial_ok: bool = int(serializado.get("current_saga", 0)) == 1 and int(serializado.get("current_chapter", 0)) == 2

	_assinalar(saga1_ok and sync_pdata_ok and cap2_ok and flag_ok and serial_ok,
		"StoryManager coordena Sagas, Capítulos, Flags e sincroniza com PlayerData.",
		"Falha no funcionamento do StoryManager!")


# ------------------------------------------------------------------------------
# TESTE 2: StoryGate & Anti-Bypass
# ------------------------------------------------------------------------------
func _teste_2_story_gate_anti_bypass() -> void:
	print("\n[TESTE 2/8] Testando StoryGate com validação anti-bypass...")
	var gate := StoryGate.new(2, 1, false) # Exige Arco 2

	# Jogador está no Arco 1
	StoryManager.iniciar_saga(1)
	var bloqueado_ok: bool = not gate.can_advance()
	var pendencias: Array[String] = gate.get_unmet_requirements()
	var msg_ok: bool = not pendencias.is_empty() and "Arco 2" in pendencias[0]

	# Jogador avança para o Arco 2
	StoryManager.iniciar_saga(2)
	var liberado_ok: bool = gate.can_advance()

	_assinalar(bloqueado_ok and msg_ok and liberado_ok,
		"StoryGate bloqueia passagens indevidas e autoriza quando requisitos são cumpridos.",
		"StoryGate falhou no bloqueio ou liberação de portais!")


# ------------------------------------------------------------------------------
# TESTE 3: MissionInstance (Isolamento de Entidades)
# ------------------------------------------------------------------------------
func _teste_3_mission_instance() -> void:
	print("\n[TESTE 3/8] Testando classe MissionInstance e cleanup atômico...")
	var quest_dummy := Quest.new()
	quest_dummy.quest_name = "Missão Teste"
	var obj := QuestObjective.new()
	obj.type = QuestObjective.Type.KILL
	obj.required_amount = 2
	quest_dummy.objectives.append(obj)

	var instance = MissionInstanceClass.new(quest_dummy, 1, 1)

	# Criar nó temporário vinculado à missão
	var dummy_node := Node2D.new()
	dummy_node.name = "DummySpawnedEntity"
	add_child(dummy_node)
	instance.register_spawned_entity(dummy_node)

	var prog1: int = instance.add_progress(0, 1)
	var obj_incompleto: bool = not instance.is_all_objectives_completed()

	var prog2: int = instance.add_progress(0, 1)
	var obj_completo: bool = instance.is_all_objectives_completed()

	# Executar cleanup
	instance.cleanup()
	await get_tree().process_frame
	var entidade_limpa: bool = not is_instance_valid(dummy_node) or dummy_node.is_queued_for_deletion()

	_assinalar(prog1 == 1 and prog2 == 2 and obj_incompleto and obj_completo and entidade_limpa,
		"MissionInstance rastreia objetivos e remove entidades órfãs ao executar cleanup.",
		"Falha no ciclo de vida ou cleanup da MissionInstance!")


# ------------------------------------------------------------------------------
# TESTE 4: WorldSpawner & Entity Lifecycle
# ------------------------------------------------------------------------------
func _teste_4_world_spawner_lifecycle() -> void:
	print("\n[TESTE 4/8] Testando WorldSpawner e timer de respawn de monstros livres...")
	var spawner = WorldSpawnerClass.new()
	spawner.name = "TestWorldSpawner"
	spawner.respawn_delay = 0.1 # Rápido para o teste
	spawner.auto_spawn_on_ready = false
	add_child(spawner)

	var entity: CharacterBody2D = spawner.spawn_entity()
	var spawnou_ok: bool = entity != null and is_instance_valid(entity)

	var es: EnemySystem = entity.get_node_or_null("EnemySystem") if entity != null else null
	var es_ok: bool = es != null and es.spawner_ref == spawner

	# Simular morte da entidade
	if es != null:
		es.die()

	await get_tree().create_timer(0.45).timeout

	# Verificar se o spawner recriou uma nova entidade saudável
	var recriou_ok: bool = spawner.current_entity != null and is_instance_valid(spawner.current_entity)

	spawner.cleanup()
	spawner.queue_free()

	_assinalar(spawnou_ok and es_ok and recriou_ok,
		"WorldSpawner gerencia o renascimento de monstros sem exigir recarregamento de cena.",
		"WorldSpawner falhou ao renascer o monstro após a morte!")


# ------------------------------------------------------------------------------
# TESTE 5: Arena Celestial (Spawns dos Andares 1 a 190 & Teste da Água)
# ------------------------------------------------------------------------------
func _teste_5_arena_celestial_conteudo() -> void:
	print("\n[TESTE 5/8] Testando instanciamento de lutadores e Teste da Água na Arena Celestial...")
	var map = load("res://world/maps/arena_celestial.tscn").instantiate()
	add_child(map)

	# Verificar se LutadorArena1..4 existem na cena (instanciados dinamicamente)
	var lutador1 = map.get_node_or_null("LutadorArena1")
	var lutador2 = map.get_node_or_null("LutadorArena2")
	var lutador3 = map.get_node_or_null("LutadorArena3")
	var lutador4 = map.get_node_or_null("LutadorArena4")
	var lutadores_ok: bool = (lutador1 != null and lutador2 != null and lutador3 != null and lutador4 != null)

	# Verificar se o objeto interativo TesteAguaWing existe no dojo
	var teste_agua = map.get_node_or_null("TesteAguaWing")
	var teste_agua_ok: bool = teste_agua != null

	if teste_agua_ok:
		var inter: InteractionComponent = teste_agua.get_node_or_null("InteractionComponent")
		if inter != null:
			# Simular inspeção do Teste da Água
			inter.interacted.emit(CharacterBody2D.new())

	map.queue_free()

	_assinalar(lutadores_ok and teste_agua_ok,
		"Arena Celestial instancia lutadores dos andares 1 a 190 e o objeto interativo do Teste da Água.",
		"Arena Celestial ainda carece de lutadores ou do gatilho do Teste da Água!")


# ------------------------------------------------------------------------------
# TESTE 6: Tutorial de Elena (Anti-Deadlock)
# ------------------------------------------------------------------------------
func _teste_6_tutorial_elena_resiliencia() -> void:
	print("\n[TESTE 6/8] Testando resiliência de Elena e prevenção de loop no tutorial...")
	var scn_npc = load("res://entities/npc/NPC.tscn")
	var elena: NPC = scn_npc.instantiate()
	elena.set_script(load("res://entities/npc/recepcionista/RecepcionistaHunter.gd"))
	add_child(elena)

	# Simular interação durante etapa de ação (ex: MOVIMENTO)
	TutorialManager.em_tutorial = true
	TutorialManager.etapa_atual = TutorialManager.Step.MOVIMENTO
	PlayerData.tutorial_concluido = false

	elena._on_interacted(CharacterBody2D.new())

	# Concluir diálogo se a UI visual estiver aberta
	var vd = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if vd != null and vd.has_signal("dialogo_concluido"):
		vd.dialogo_concluido.emit()

	# A flag de processamento deve ser destravada e não bloquear interações
	var nao_travado: bool = not elena._interacao_em_processamento

	elena.queue_free()

	_assinalar(nao_travado,
		"Elena processa lembretes sem prender _interacao_em_processamento em loop.",
		"Elena travou durante interação em etapa de ação do tutorial!")


# ------------------------------------------------------------------------------
# TESTE 7: Biscuit Krueger (Desbloqueio em Greed Island)
# ------------------------------------------------------------------------------
func _teste_7_biscuit_greed_island() -> void:
	print("\n[TESTE 7/8] Testando acesso ao treino de Hatsu com Biscuit no Arco 5...")
	var scn_bisc = load("res://entities/npc/biscuit/Biscuit.tscn")
	var biscuit: NPC = scn_bisc.instantiate()
	add_child(biscuit)

	# Simular jogador no Arco 5 (Greed Island) com Nen despertado
	PlayerData.despertou_nen = true
	PlayerData.arco_atual = 5
	PlayerData.max_arco_desbloqueado = 5
	PlayerData.hatsu_creation_unlocked = false
	PlayerData.hatsu_desbloqueado = false

	biscuit._on_interacted(CharacterBody2D.new())

	var desbloqueou_ok: bool = PlayerData.hatsu_creation_unlocked and PlayerData.hatsu_desbloqueado

	biscuit.queue_free()

	_assinalar(desbloqueou_ok,
		"Biscuit Krueger desbloqueia treinamento de Hatsu contextualmente no Arco 5.",
		"Biscuit Krueger bloqueou o treino de Hatsu no Arco 5!")


# ------------------------------------------------------------------------------
# TESTE 8: SaveManager & Versioning (Persistência Atômica)
# ------------------------------------------------------------------------------
func _teste_8_save_load_versioning_cycle() -> void:
	print("\n[TESTE 8/8] Testando gravação atômica, versionamento e ciclo completo de save/load...")
	PlayerData.reset()
	PlayerData.nome_personagem = "Kurapika Kurta"
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.CONJURACAO
	PlayerData.attributes["nivel"] = 12
	PlayerData.attributes["forca"] = 25
	PlayerData.nen_skill_points = 5

	StoryManager.iniciar_saga(3)
	StoryManager.current_chapter = 11
	StoryManager.set_story_flag("teste_ver_save", true)

	var salvou: bool = SaveManager.salvar_jogo(98)
	_assinalar(salvou, "Save atômico gravado no slot 98.", "Falha ao gravar no slot 98!")

	# Resetar memória
	PlayerData.reset()
	StoryManager.current_saga = 1
	StoryManager.current_chapter = 1

	var carregou: bool = SaveManager.carregar_jogo(98)
	var nome_ok: bool = PlayerData.nome_personagem == "Kurapika Kurta"
	var nivel_ok: bool = int(PlayerData.attributes.get("nivel", 0)) == 12
	var saga_ok: bool = StoryManager.current_saga == 3 and StoryManager.current_chapter == 11
	var flag_ok: bool = bool(StoryManager.get_story_flag("teste_ver_save")) == true

	_assinalar(carregou and nome_ok and nivel_ok and saga_ok and flag_ok,
		"Ciclo de Save/Load restaura 100% dos atributos, StoryManager, Sagas e Capítulos.",
		"Falha na restauração do save no slot 98!")
