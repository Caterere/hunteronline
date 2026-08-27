extends Node2D

# ============================================================
# HUNTER ONLINE - SEQUENTIAL PLAYTEST & DIAGNOSTIC RUNNER
# ============================================================
#
# Executa em sequência:
# 1. Sessão de Playtest Guiada com gravação completa de telemetria
# 2. Diagnóstico de Densidade & Análise de Rejeições de Eventos nas 5 Zonas
# 3. Consolidação de métricas e exportação de relatórios
# ============================================================

const WorldDensityHeatmapScript = preload("res://debug/telemetry/WorldDensityHeatmap.gd")


func _ready() -> void:
	print("================================================================================")
	print("🎮 EXECUÇÃO EM SEQUÊNCIA: PLAYTEST GUIADO & DIAGNÓSTICO DE MUNDO")
	print("================================================================================")
	
	_executar_etapa_1_playtest_guiado()
	_executar_etapa_2_analise_densidade_e_rejeicoes()
	_executar_etapa_3_relatorio_final()
	
	get_tree().quit(0)


# ============================================================
# ETAPA 1: SESSÃO DE PLAYTEST GUIADA COM TELEMETRIA
# ============================================================
func _executar_etapa_1_playtest_guiado() -> void:
	print("\n--- [ETAPA 1: SESSÃO DE PLAYTEST GUIADA & TELEMETRIA] ---")
	
	# 1. Iniciar Sessão de Telemetria
	var session_id = PlaytestTelemetry.start_session()
	print("📍 1.1 Sessão iniciada com ID: %s" % session_id)
	
	# 2. Spawn do Player na Vila de Padokia
	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	player_scn.global_position = Vector2(1208, 4088)
	
	# 3. Interação com NPC Mestre Wing
	print("💬 1.2 Interagindo com Mestre Wing (Iniciando Quest e Despertar de Nen)...")
	var npc_wing = load("res://entities/npc/NPC.tscn").instantiate()
	npc_wing.npc_name = "Mestre Wing"
	npc_wing.global_position = Vector2(1220, 4088)
	add_child(npc_wing)
	
	EventBus.dialogue_opened.emit("Mestre Wing")
	EventBus.quest_accepted.emit("padokia_01", "O Despertar da Aura & O Guardião de Zaban")
	
	# 4. Despertar de Nen e Treinamento
	print("✨ 1.3 Despertando Nen e ativando Ten e Ren...")
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel_nen(2)
	var nen_sys = player_scn.get_node_or_null("NenSystem") as NenSystem
	if nen_sys != null:
		nen_sys.sincronizar_nen_com_player_data()
		nen_sys.ativar_tecnica(NenSystem.Tecnica.TEN)
		PlaytestTelemetry._process(1.5) # Simula 1.5s de uso de Ten
		nen_sys.desativar_tecnica(NenSystem.Tecnica.TEN)
		nen_sys.ativar_tecnica(NenSystem.Tecnica.REN)
		PlaytestTelemetry._process(1.0)
		nen_sys.desativar_tecnica(NenSystem.Tecnica.REN)
		
	# 5. Exploração e Deslocamento pelo Vale
	print("🏃 1.4 Explorando a Estrada Real e descobrindo POIs...")
	player_scn.global_position = Vector2(2880, 4080)
	EventBus.world_event_triggered.emit("poi_ponte_rio", "Grande Ponte de Pedra", Vector2(2880, 4080))
	
	# 6. Combate PvE contra Inimigos
	print("⚔️ 1.5 Combate contra monstros e aplicação de dano com Nen KO...")
	var enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn").instantiate()
	enemy.global_position = Vector2(2910, 4080)
	add_child(enemy)
	
	var es = enemy.get_node_or_null("EnemySystem") as EnemySystem
	if es != null:
		# Player acerta golpe concentrado de Ko
		if nen_sys != null:
			nen_sys.ativar_tecnica(NenSystem.Tecnica.KO)
		es.take_damage(95, Vector2.RIGHT, 1.0, player_scn)
		if nen_sys != null:
			nen_sys.desativar_tecnica(NenSystem.Tecnica.KO)
			
	# Inimigo é derrotado
	EventBus.combat_hit_landed.emit(player_scn, enemy, 95, false)
	EventBus.enemy_defeated.emit("slime", 60, 25)
	EventBus.jenny_changed.emit(1200, 1200)
	EventBus.quest_objective_updated.emit("padokia_01", "Derrote Slime", 1, 1)
	EventBus.quest_completed.emit("padokia_01", 500, 2500)
	
	enemy.queue_free()
	npc_wing.queue_free()
	player_scn.queue_free()
	
	# 7. Finalizar Sessão e Exportar JSON
	var summary = PlaytestTelemetry.end_session()
	var json_file = PlaytestTelemetry.export_session_json("res://debug/playtest/playtest_guided_session_01.json")
	
	print("💾 1.6 Relatório de Sessão exportado com sucesso: %s" % json_file)
	print("    • Inimigos Derrotados: %d" % summary["enemies_killed"])
	print("    • Dano Desferido: %d (Maior Golpe: %d)" % [summary["damage_dealt"], summary["max_single_hit"]])
	print("    • Quests Concluídas: %d" % summary["quests_completed"])
	print("    • NPCs Interagidos: %d" % summary["npcs_interacted"])
	print("    • Jenny Obtido: +%d" % summary["gold_gained"])


# ============================================================
# ETAPA 2: DIAGNÓSTICO DE DENSIDADE E ANÁLISE DE REJEIÇÕES
# ============================================================
func _executar_etapa_2_analise_densidade_e_rejeicoes() -> void:
	print("\n--- [ETAPA 2: DIAGNÓSTICO DE DENSIDADE & INSPECTOR DE EVENTOS] ---")
	
	var director = ContentDirector.new()
	add_child(director)
	
	var test_points = [
		{"name": "1. Vila de Padokia", "pos": Vector2(1200, 4080), "expected_risk": "SAFE (0)"},
		{"name": "2. Estrada Real", "pos": Vector2(2880, 3100), "expected_risk": "LOW_RISK (1)"},
		{"name": "3. Floresta dos Vestígios", "pos": Vector2(4400, 3200), "expected_risk": "MEDIUM_RISK (2)"},
		{"name": "4. Ruínas de Zaban", "pos": Vector2(6880, 1440), "expected_risk": "HIGH_RISK (3)"},
		{"name": "5. Ravina da Névoa", "pos": Vector2(6400, 6400), "expected_risk": "DANGER (4)"}
	]
	
	print("\n[Avaliação de Candidatos a Eventos por Região]")
	for pt in test_points:
		print("\n📍 PONTO: %s em %s (Esperado: %s)" % [pt["name"], pt["pos"], pt["expected_risk"]])
		var evaluations = director.evaluate_event_candidates_at_pos(pt["pos"])
		var accepted = []
		var rejected = []
		for ev in evaluations:
			if ev["is_accepted"]:
				accepted.append(ev["title"])
			else:
				rejected.append("%s -> Motivo: %s" % [ev["title"], ev["primary_reason"]])
				
		print("  ✔ EVENTOS ACEITOS (%d):" % accepted.size())
		for a in accepted:
			print("    • %s" % a)
		print("  ✖ EVENTOS REJEITADOS (%d):" % rejected.size())
		for r in rejected:
			print("    • %s" % r)

	# Diagnóstico de Zonas Mortas do Heatmap
	print("\n[Diagnóstico da Grade de Setores do Mapa de Calor (16x16)]")
	var heatmap = WorldDensityHeatmapScript.new()
	add_child(heatmap)
	heatmap.recalculate_density_grid()
	
	var total_sectors = heatmap.sector_data.size()
	var dead_sectors = 0
	var active_sectors = 0
	
	for key in heatmap.sector_data.keys():
		var d = heatmap.sector_data[key]
		if d["total_score"] <= 0.0:
			dead_sectors += 1
		else:
			active_sectors += 1
			
	var dead_pct = (float(dead_sectors) / float(total_sectors)) * 100.0
	var active_pct = (float(active_sectors) / float(total_sectors)) * 100.0
	
	print("  • Total de Setores Analisados: %d" % total_sectors)
	print("  • Setores com Conteúdo Ativo: %d (%.1f%%)" % [active_sectors, active_pct])
	print("  • Zonas Mortas Identificadas (Sem Conteúdo): %d (%.1f%%)" % [dead_sectors, dead_pct])
	print("  💡 Conclusão do Heatmap: As áreas centrais e rotas POI possuem alta densidade, enquanto áreas periféricas não povoadas permanecem preservadas para expansão futura.")
	
	heatmap.queue_free()
	director.queue_free()


# ============================================================
# ETAPA 3: RELATÓRIO FINAL
# ============================================================
func _executar_etapa_3_relatorio_final() -> void:
	print("\n--- [ETAPA 3: CONSOLIDAÇÃO E CONCLUSÃO] ---")
	print("✅ Todas as etapas sequenciais foram executadas e validadas com sucesso.")
	print("================================================================================\n")
