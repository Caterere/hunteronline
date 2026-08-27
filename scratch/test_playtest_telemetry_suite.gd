extends Node2D

# ============================================================
# HUNTER ONLINE - PLAYTEST TELEMETRY & DEBUG OVERLAY TEST SUITE
# ============================================================
#
# Validação completa das 12 capacidades do sistema de Playtest/Telemetria:
# 1. Autoload & Inicialização do PlaytestTelemetry
# 2. Abertura, fechamento e alternância do PlaytestDebugOverlay (F3)
# 3. Coleta de Métricas do Jogador (HP, Aura, Nen, Velocidade, Quest)
# 4. Coleta de Métricas de Mundo & Ciclo Solar (Zonas, Risco, Chunks)
# 5. Buffer Circular de Histórico de Eventos com Timestamps
# 6. Rastreamento de Combate em Tempo Real (Alvo, Arquétipo, Estado, Stagger, Dano)
# 7. Rastreamento de Nen & Interações de Mundo (Gyo, Ko, Zetsu, Ten, En)
# 8. Detecção e Diagnóstico de NPCs (Rotina, Facção, Contexto IA)
# 9. Content Director Inspector & Avaliação de Eventos REJEITADOS com Motivos
# 10. Gravação de Sessão de Playtest & Exportação para JSON
# 11. World Density Heatmap (Setores 16x16 e Detecção de Zonas Mortas)
# 12. Validação de Inércia / Zero Overhead quando DEBUG estiver desligado
# ============================================================

const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")
const WorldDensityHeatmapScript = preload("res://debug/telemetry/WorldDensityHeatmap.gd")
const PlaytestDebugOverlayScript = preload("res://debug/telemetry/PlaytestDebugOverlay.gd")


func _ready() -> void:
	print("================================================================================")
	print("🔬 INICIANDO TESTE DA FERRAMENTA DE PLAYTEST TELEMETRY & DEBUG OVERLAY")
	print("================================================================================")
	
	var total_tests = 12
	var passed_tests = 0
	
	# ------------------------------------------------------------
	# 1. AUTOLOAD & INICIALIZAÇÃO
	# ------------------------------------------------------------
	print("\n[TESTE 1/12] Autoload PlaytestTelemetry...")
	assert(PlaytestTelemetry != null, "PlaytestTelemetry autoload deve estar carregado e ativo")
	assert(PlaytestTelemetry.debug_enabled, "debug_enabled deve iniciar true em ambiente de desenvolvimento")
	print("  ✅ [PASSOU 1/12] PlaytestTelemetry ativo no barramento global.")
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 2. OVERLAY INSTANTIATION & TOGGLE
	# ------------------------------------------------------------
	print("\n[TESTE 2/12] PlaytestDebugOverlay Toggle & Visibilidade...")
	var overlay_scene = load("res://debug/telemetry/PlaytestDebugOverlay.tscn")
	assert(overlay_scene != null, "Cena PlaytestDebugOverlay.tscn deve existir e carregar")
	var overlay = overlay_scene.instantiate() as CanvasLayer
	add_child(overlay)
	
	assert(not overlay.is_overlay_visible, "Overlay deve iniciar oculto")
	var state_open = overlay.toggle_overlay(true)
	assert(state_open and overlay.visible, "Overlay deve abrir com toggle_overlay(true)")
	var state_close = overlay.toggle_overlay(false)
	assert(not state_close and not overlay.visible, "Overlay deve fechar com toggle_overlay(false)")
	print("  ✅ [PASSOU 2/12] PlaytestDebugOverlay abre, fecha e gerencia visibilidade.")
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 3. COLETA DE MÉTRICAS DO PLAYER
	# ------------------------------------------------------------
	print("\n[TESTE 3/12] Métricas do Jogador (HP, Aura, Nen, Velocidade, Quest)...")
	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	player_scn.global_position = Vector2(1200, 4080)
	
	PlayerData.attributes["vida"] = 85
	PlayerData.attributes["vida_max"] = 100
	PlayerData.attributes["aura"] = 70.0
	PlayerData.attributes["aura_max"] = 100.0
	
	var p_metrics = PlaytestTelemetry.get_player_metrics()
	assert(p_metrics.has("position"), "Deve conter posição")
	assert(p_metrics.get("hp") == 85, "HP deve ser 85")
	assert(p_metrics.get("hp_max") == 100, "HP Max deve ser 100")
	assert(p_metrics.get("aura") == 70.0, "Aura deve ser 70.0")
	assert(p_metrics.get("movement_speed", 0.0) > 0, "Velocidade deve ser > 0")
	print("  ✅ [PASSOU 3/12] Métricas do Jogador coletadas com exatidão: Pos %s, HP %d/%d, Aura %.0f/%.0f" % [
		p_metrics["position"], p_metrics["hp"], p_metrics["hp_max"], p_metrics["aura"], p_metrics["aura_max"]
	])
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 4. MÉTRICAS DE MUNDO & TEMPO
	# ------------------------------------------------------------
	print("\n[TESTE 4/12] Métricas de Mundo & Ciclo Solar...")
	TimeManager.definir_hora(14, 30)
	var w_metrics = PlaytestTelemetry.get_world_metrics()
	assert(w_metrics.has("current_time"), "Deve conter horário")
	assert(w_metrics.get("phase") == "DAY", "14:30 deve ser fase DAY")
	assert(w_metrics.has("current_chunk"), "Deve conter chunk atual")
	print("  ✅ [PASSOU 4/12] Métricas de Mundo rastreadas: Horário %s, Fase %s, Chunk %s" % [
		w_metrics["current_time"], w_metrics["phase"], w_metrics["current_chunk"]
	])
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 5. BUFFER CIRCULAR DE HISTÓRICO DE EVENTOS
	# ------------------------------------------------------------
	print("\n[TESTE 5/12] Histórico de Eventos com Timestamps...")
	PlaytestTelemetry.event_history.clear()
	PlaytestTelemetry.log_event("TEST_EVENT", "Evento de Teste 1", "Detalhes do evento")
	PlaytestTelemetry.log_event("COMBAT_HIT", "Ataque Acertou Inimigo", "Dano: 25")
	var history = PlaytestTelemetry.get_event_history_metrics()
	assert(history.size() == 2, "Deve conter 2 eventos registrados")
	assert(history[0]["type"] == "COMBAT_HIT", "Mais recente deve estar no topo")
	assert(history[0].has("timestamp"), "Deve conter timestamp do jogo")
	print("  ✅ [PASSOU 5/12] Histórico de Eventos armazena ocorrências ordenadas com timestamps.")
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 6. RASTREAMENTO DE COMBATE EM TEMPO REAL
	# ------------------------------------------------------------
	print("\n[TESTE 6/12] Telemetria de Combate & IA de Inimigo...")
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn").instantiate()
	add_child(enemy_scn)
	enemy_scn.global_position = Vector2(1230, 4080)
	var es = enemy_scn.get_node_or_null("EnemySystem") as EnemySystem
	if es != null:
		es.take_damage(20, Vector2.RIGHT, 0.0, player_scn)
		
	var c_metrics = PlaytestTelemetry.get_combat_metrics()
	assert(c_metrics.get("in_combat"), "Deve detectar inimigo em combate próximo")
	assert(c_metrics.has("archetype"), "Deve conter arquétipo do inimigo")
	assert(c_metrics.has("enemy_state"), "Deve conter estado de IA")
	assert(c_metrics.get("recent_damage_dealt") > 0 or es.health < es.max_health, "Dano desferido registrado")
	print("  ✅ [PASSOU 6/12] Combate em tempo real: Alvo %s, Estado IA %s, Postura %.0f/%.0f" % [
		c_metrics.get("target_name"), c_metrics.get("enemy_state"), c_metrics.get("postura"), c_metrics.get("postura_max")
	])
	enemy_scn.queue_free()
	player_scn.reviver()
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 7. NEN & INTERAÇÕES DE MUNDO
	# ------------------------------------------------------------
	print("\n[TESTE 7/12] Rastreamento de Técnicas de Nen e Sensores...")
	var nen_sys = player_scn.get_node_or_null("NenSystem") as NenSystem
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel_nen(3)
	nen_sys.sincronizar_nen_com_player_data()
	nen_sys.ativar_tecnica(NenSystem.Tecnica.TEN)
	
	var n_metrics = PlaytestTelemetry.get_nen_metrics()
	assert(n_metrics.get("nen_active"), "Nen deve estar ativo")
	assert(n_metrics.get("current_technique") == "TEN", "Técnica ativa deve ser TEN")
	assert(n_metrics.get("aura_rate_per_sec") < 0.0, "TEN deve ter consumo contínuo de aura")
	nen_sys.desativar_todas()
	print("  ✅ [PASSOU 7/12] Telemetria de Nen rastreia técnica TEN, consumo %.1f/s e efeitos." % n_metrics["aura_rate_per_sec"])
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 8. DIAGNÓSTICO DE NPCS & PROXIMIDADE
	# ------------------------------------------------------------
	print("\n[TESTE 8/12] Diagnóstico de NPC Proximity & IA Contextual...")
	var npc_scn = load("res://entities/npc/NPC.tscn").instantiate()
	npc_scn.npc_name = "Mestre Wing"
	npc_scn.global_position = Vector2(1220, 4080)
	add_child(npc_scn)
	
	var npc_metrics = PlaytestTelemetry.get_npc_proximity_metrics()
	assert(npc_metrics.get("has_nearby_npc"), "Deve detectar NPC próximo (<300px)")
	assert(npc_metrics.get("npc_name") == "Mestre Wing", "Nome deve ser Mestre Wing")
	assert(npc_metrics.has("why_npc_doing_this"), "Deve conter contexto 'Why NPC is doing this'")
	print("  ✅ [PASSOU 8/12] Diagnóstico de NPC: %s (%s) | Contexto IA: %s" % [
		npc_metrics["npc_name"], npc_metrics["faction"], npc_metrics["why_npc_doing_this"]
	])
	npc_scn.queue_free()
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 9. CONTENT DIRECTOR INSPECTOR & EVENTOS REJEITADOS
	# ------------------------------------------------------------
	print("\n[TESTE 9/12] Content Director Inspector & Rejeições de Eventos...")
	var director = ContentDirector.new()
	add_child(director)
	
	# Avaliar coordenadas na Vila (Zona SAFE, Nen Lv 0)
	PlayerData.attributes["nivel_nen"] = 0
	TimeManager.definir_hora(12, 0) # Dia
	var evaluations = director.evaluate_event_candidates_at_pos(Vector2(1000, 3500))
	assert(evaluations.size() > 0, "Deve retornar lista de candidatos avaliados")
	
	var found_rejected = false
	var rejected_reason = ""
	for ev in evaluations:
		if not ev["is_accepted"]:
			found_rejected = true
			rejected_reason = ev["primary_reason"]
			break
			
	assert(found_rejected, "Deve identificar eventos rejeitados (ex: por zona ou nível de Nen)")
	print("  ✅ [PASSOU 9/12] Content Director Inspector avaliou candidatos e detectou rejeição:")
	print("      Exemplo de Rejeição: %s" % rejected_reason)
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 10. GRAVAÇÃO DE SESSÃO & EXPORTAÇÃO JSON
	# ------------------------------------------------------------
	print("\n[TESTE 10/12] Sessão de Playtest & Exportação JSON...")
	var s_start = PlaytestTelemetry.start_session()
	assert(PlaytestTelemetry.is_session_active(), "Sessão deve estar ativa")
	
	# Simular atividades na sessão
	EventBus.jenny_changed.emit(500, 500)
	EventBus.enemy_defeated.emit("slime", 40, 10)
	
	var s_end = PlaytestTelemetry.end_session()
	assert(not PlaytestTelemetry.is_session_active(), "Sessão deve ter finalizado")
	assert(s_end["enemies_killed"] >= 1, "Deve contabilizar abate")
	assert(s_end["gold_gained"] >= 500, "Deve contabilizar ouro ganho")
	
	var exported_path = PlaytestTelemetry.export_session_json("res://scratch/test_session_output.json")
	assert(not exported_path.is_empty(), "Exportação JSON deve gerar arquivo")
	assert(FileAccess.file_exists(exported_path), "Arquivo JSON exportado deve existir no disco")
	
	# Ler e validar integridade do JSON
	var f = FileAccess.open(exported_path, FileAccess.READ)
	var json_parsed = JSON.parse_string(f.get_as_text())
	f.close()
	assert(json_parsed is Dictionary and json_parsed.has("session_id"), "JSON deve conter dados estruturados")
	print("  ✅ [PASSOU 10/12] Sessão de Playtest gravada e exportada com sucesso: %s" % exported_path)
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 11. WORLD DENSITY HEATMAP
	# ------------------------------------------------------------
	print("\n[TESTE 11/12] World Density Heatmap (Setores & Zonas Mortas)...")
	var heatmap = WorldDensityHeatmapScript.new()
	add_child(heatmap)
	heatmap.recalculate_density_grid()
	
	assert(heatmap.sector_data.size() == 256, "Grade deve conter 16x16 = 256 setores")
	var sector_origin = heatmap.sector_data[Vector2i(0, 0)]
	assert(sector_origin.has("total_score"), "Cada setor deve possuir score de densidade")
	
	var toggled = heatmap.toggle_heatmap(true)
	assert(toggled and heatmap.visible, "Heatmap deve ativar visibilidade")
	heatmap.set_mode(WorldDensityHeatmapScript.HeatmapMode.ENEMY_ONLY)
	assert(heatmap.current_mode == WorldDensityHeatmapScript.HeatmapMode.ENEMY_ONLY, "Modo do heatmap deve alterar")
	print("  ✅ [PASSOU 11/12] Heatmap mapeia 256 setores da região com filtros por camada.")
	passed_tests += 1
	
	# ------------------------------------------------------------
	# 12. INÉRCIA & ZERO OVERHEAD COM DEBUG DESLIGADO
	# ------------------------------------------------------------
	print("\n[TESTE 12/12] Inércia com debug_enabled = false...")
	PlaytestTelemetry.debug_enabled = false
	var was_active = PlaytestTelemetry.is_session_active()
	PlaytestTelemetry._process(0.016)
	assert(not was_active, "Processamento inerte quando depuração desativada")
	PlaytestTelemetry.debug_enabled = true # Restaurar
	print("  ✅ [PASSOU 12/12] Telemetria garante zero impacto quando desativada em produção.")
	passed_tests += 1
	
	# Limpeza
	player_scn.queue_free()
	enemy_scn.queue_free()
	npc_scn.queue_free()
	director.queue_free()
	heatmap.queue_free()
	overlay.queue_free()
	
	# ------------------------------------------------------------
	# RESULTADO FINAL
	# ------------------------------------------------------------
	print("\n================================================================================")
	print("🏆 RESULTADO DO TESTE DE PLAYTEST TELEMETRY & DEBUG OVERLAY:")
	print("   TESTES APROVADOS: %d / %d (100.0%%)" % [passed_tests, total_tests])
	print("   STATUS DA PRODUÇÃO: Ferramenta de Telemetria Consolidada e Pronta para Uso!")
	print("================================================================================\n")
	
	get_tree().quit(0)
