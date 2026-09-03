extends Node

# ============================================================
# HUNTER ONLINE - SUÍTE COMPLETA DE TESTES: TASKS_FUTURAS (FASES 3 A 12)
# ============================================================

const CombatEngineScript = preload("res://autoload/CombatEngine.gd")
const EnemyAIScript = preload("res://scripts/systems/EnemySystem/EnemyAI.gd")
const EnemyDataScript = preload("res://resource/status/EnemyData.gd")
const BossPhaseDataScript = preload("res://resource/status/BossPhaseData.gd")
const NPCScheduleDataScript = preload("res://world/content/NPCScheduleData.gd")
const LivingNPCBehaviorScript = preload("res://entities/npc/LivingNPCBehavior.gd")
const QuestObjectiveScript = preload("res://scripts/QuestObjective.gd")
const QuestScript = preload("res://scripts/Quest.gd")
const ZoneDataScript = preload("res://resource/world/ZoneData.gd")
const NenSkillTreeUIScript = preload("res://ui/SkillTree/NenSkillTreeUI.gd")
const TargetHUDScript = preload("res://ui/TargetHUD/TargetHUD.gd")
const BuildDebugMenuScript = preload("res://debug/BuildDebugMenu.gd")
const GameplayConditionScript = preload("res://resource/gameplay/GameplayCondition.gd")

var total_testes: int = 0
var testes_passados: int = 0

func _ready() -> void:
	print("============================================================")
	print("🎯 INICIANDO SUÍTE COMPLETA DE TESTES: TASKS_FUTURAS")
	print("============================================================")

	testar_fase_3_tags_e_mitigacao_dano()
	testar_fase_4_aggro_e_arquetipos_inimigos()
	testar_fase_5_hud_skill_tree()
	testar_fase_6_boss_phases_configuraveis()
	testar_fase_7_rotinas_e_eventos_npcs()
	testar_fase_8_quests_opcionais_e_consequencias()
	testar_fase_9_zonas_e_encontros_raros()
	testar_fase_10_target_hud_e_debug_tools()

	print("============================================================")
	print("RESULTADO FINAL: %d / %d TESTES PASSADOS COM SUCESSO" % [testes_passados, total_testes])
	print("============================================================")
	if get_tree():
		get_tree().quit(0 if testes_passados == total_testes else 1)


func assert_true(cond: bool, msg: String) -> void:
	total_testes += 1
	if cond:
		testes_passados += 1
		print("  ✅ [PASS] " + msg)
	else:
		push_error("  ❌ [FAIL] " + msg)
		print("  ❌ [FAIL] " + msg)


func testar_fase_3_tags_e_mitigacao_dano() -> void:
	print("\n[TESTE 1/8] Fase 3 — Tags de Dano & Mitigação Canônica no Combate...")

	var engine = CombatEngineScript.new()
	var dummy_atk = {"forca": 20.0, "dano_base": 10.0}
	
	# Teste contra defensor neutro
	var def_neutro = {"defesa": 10.0}
	var res_neutro = engine.calcular_dano_detalhado(dummy_atk, def_neutro, null, false, ["slashing"])
	assert_true(res_neutro.dano > 0, "Dano padrão calculado corretamente: %d" % res_neutro.dano)

	# Teste contra defensor com fraqueza
	var def_fraco = {"defesa": 10.0, "weakness_tags": ["slashing"]}
	var res_fraco = engine.calcular_dano_detalhado(dummy_atk, def_fraco, null, false, ["slashing"])
	assert_true(res_fraco.is_weakness and res_fraco.dano > res_neutro.dano, "Fraqueza a slashing aplicada (+50%% dano): %d > %d" % [res_fraco.dano, res_neutro.dano])

	# Teste contra defensor com resistência
	var def_res = {"defesa": 10.0, "resistance_tags": ["slashing"]}
	var res_res = engine.calcular_dano_detalhado(dummy_atk, def_res, null, false, ["slashing"])
	assert_true(res_res.is_resisted and res_res.dano < res_neutro.dano, "Resistência a slashing aplicada (-50%% dano): %d < %d" % [res_res.dano, res_neutro.dano])

	# Teste contra defensor imune
	var def_imune = {"defesa": 10.0, "immunity_tags": ["slashing"]}
	var res_imune = engine.calcular_dano_detalhado(dummy_atk, def_imune, null, false, ["slashing"])
	assert_true(res_imune.is_immune and res_imune.dano == 0, "Imunidade a slashing zera dano: %d" % res_imune.dano)

	# Teste de resistências no PlayerData
	PlayerData.resistance_tags = ["blunt"]
	assert_true(PlayerData.eh_resistente_a(["blunt"]), "PlayerData registra e consulta resistências a tags corretamente.")
	PlayerData.resistance_tags.clear()


func testar_fase_4_aggro_e_arquetipos_inimigos() -> void:
	print("\n[TESTE 2/8] Fase 4 — Arquétipos, Aggro e Percepção de Inimigos...")

	var ai = EnemyAIScript.new()
	var dummy_node1 = Node2D.new()
	var dummy_node2 = Node2D.new()

	ai.adicionar_ameaca(dummy_node1, 50.0)
	ai.adicionar_ameaca(dummy_node2, 100.0)

	var alvo = ai.obter_alvo_principal()
	assert_true(alvo == dummy_node2, "Aggro table prioriza o alvo de maior ameaça (dummy2 com 100 > dummy1 com 50).")

	ai._processar_decaimento_aggro(1.0)
	assert_true(ai.threat_table[dummy_node2] < 100.0, "Decaimento temporal de aggro processado com sucesso.")

	ai.limpar_ameacas()
	assert_true(ai.threat_table.is_empty(), "limpar_ameacas esvazia a tabela.")

	dummy_node1.free()
	dummy_node2.free()
	ai.free()


func testar_fase_5_hud_skill_tree() -> void:
	print("\n[TESTE 3/8] Fase 5 — HUD da Nen Skill Tree...")

	var ui = NenSkillTreeUIScript.new()
	assert_true(ui.has_method("_atualizar_exibicao"), "NenSkillTreeUI possui método de atualização.")
	assert_true(ui._corresponde_ao_filtro(NenSkillTree.Categoria.TEN, "fundamentos"), "Filtro de categoria para fundamentos mapeado.")
	assert_true(ui._corresponde_ao_filtro(NenSkillTree.Categoria.RYU_OFENSIVO, "ryu"), "Filtro de modos de Ryu mapeado.")
	assert_true(ui._corresponde_ao_filtro(NenSkillTree.Categoria.COMPORTAMENTAL, "comportamentais"), "Filtro de comportamentais mapeado.")
	assert_true(ui._corresponde_ao_filtro(NenSkillTree.Categoria.SINERGIA, "sinergias"), "Filtro de sinergias mapeado.")
	ui.free()


func testar_fase_6_boss_phases_configuraveis() -> void:
	print("\n[TESTE 4/8] Fase 6 — Fases e Mecânicas Configuráveis de Bosses...")

	var phase2 = BossPhaseDataScript.new()
	phase2.phase_index = 2
	phase2.hp_threshold = 0.60
	phase2.phase_name = "Fase 2 de Teste"
	phase2.mechanic = BossPhaseDataScript.MecanicaFase.FRENESI

	var ed = EnemyDataScript.new()
	ed.is_boss = true
	var phases: Array[Resource] = [phase2]
	ed.boss_phases = phases

	assert_true(ed.boss_phases.size() == 1, "EnemyData aceita configuração de BossPhaseData.")
	assert_true(ed.boss_phases[0].hp_threshold == 0.60, "Limiar de HP da fase configurado para 60%.")


func testar_fase_7_rotinas_e_eventos_npcs() -> void:
	print("\n[TESTE 5/8] Fase 7 — Rotinas Vivas e Eventos de NPCs...")

	var sched = NPCScheduleDataScript.new()
	sched.npc_id = "ferreiro_padokia"
	sched.workplace_pos = Vector2(100, 200)
	sched.home_pos = Vector2(300, 400)
	sched.current_state = "resting"

	var behavior = LivingNPCBehaviorScript.new()
	behavior.schedule_data = sched

	behavior._on_time_phase_changed("MORNING")
	assert_true(sched.current_state == "working" and behavior.pos_alvo == sched.workplace_pos, "Transição da manhã move NPC para local de trabalho.")

	behavior._on_time_phase_changed("NIGHT")
	assert_true(sched.current_state == "resting" and behavior.pos_alvo == sched.home_pos, "Transição da noite move NPC para residência.")
	behavior.free()


func testar_fase_8_quests_opcionais_e_consequencias() -> void:
	print("\n[TESTE 6/8] Fase 8 — Objetivos Condicionais, Opcionais e Consequências...")

	var obj_mandatory = QuestObjectiveScript.new()
	obj_mandatory.type = QuestObjectiveScript.Type.KILL
	obj_mandatory.required_amount = 3
	obj_mandatory.is_optional = false

	var obj_optional = QuestObjectiveScript.new()
	obj_optional.type = QuestObjectiveScript.Type.STEALTH_PASS
	obj_optional.required_amount = 1
	obj_optional.is_optional = true

	var quest = QuestScript.new()
	quest.quest_name = "Missão com Bônus Opcional"
	var objs: Array[QuestObjective] = [obj_mandatory, obj_optional]
	quest.objectives = objs
	var c_tags: Array[String] = ["cidade_pacificada"]
	quest.consequence_tags = c_tags
	var opt_tags: Array[String] = ["honra_furtiva"]
	quest.optional_consequence_tags = opt_tags

	assert_true(quest.has_optional_objectives(), "Quest reconhece presença de objetivo opcional.")
	assert_true(quest.get_mandatory_objectives().size() == 1, "get_mandatory_objectives filtra apenas os obrigatórios.")
	assert_true("[OPCIONAL]" in obj_optional.describe(), "describe() adiciona tag [OPCIONAL].")


func testar_fase_9_zonas_e_encontros_raros() -> void:
	print("\n[TESTE 7/8] Fase 9 — Zonas e Encontros Raros...")

	var zona = ZoneDataScript.new()
	zona.zone_name = "Floresta das Feras Mágicas"
	zona.danger_multiplier = 2.0
	var encs: Array[Dictionary] = [
		{"id": "dragao_pantanal", "nome": "Dragão do Pântano", "chance": 1.0}
	]
	zona.rare_encounters = encs

	var sorteado = zona.sortear_encontro_raro()
	assert_true(sorteado.get("id") == "dragao_pantanal", "Sorteio de encontro raro na zona funciona com multiplicador de perigo.")


func testar_fase_10_target_hud_e_debug_tools() -> void:
	print("\n[TESTE 8/8] Fases 10 & 11 — Target HUD e Debug Tools...")

	var target_hud = TargetHUDScript.new()
	assert_true(target_hud.has_method("focar_alvo") and target_hud.has_method("limpar_alvo"), "TargetHUD implementa focar_alvo e limpar_alvo.")
	target_hud.free()

	var debug_menu = BuildDebugMenuScript.new()
	assert_true(debug_menu.has_method("alternar_menu") and debug_menu.has_method("obter_contexto_debug"), "BuildDebugMenu implementa alternar_menu e obter_contexto_debug.")
	debug_menu.free()
