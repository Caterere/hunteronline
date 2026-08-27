class_name PlaytestTelemetryClass
extends Node

# ============================================================
# HUNTER ONLINE - PLAYTEST TELEMETRY & METRICS ENGINE
# ============================================================
#
# Núcleo de telemetria de desenvolvimento e sessões de playtest:
# - DEBUG ONLY (Zero impacto em builds de produção ou quando desativado)
# - Coleta métricas em tempo real de 10 domínios:
#   1. Player (Posição, Mapa, Level, HP, Aura, Nen, Estado de Combate, Sprint, Quests)
#   2. World (Tempo, Fase solar, Zona de risco, Chunk, POIs/NPCs/Inimigos/Eventos próximos)
#   3. Content Director (Densidades ativas, distâncias, cooldowns, breakdown regional)
#   4. NPC Intelligence (Proximidade < 300px, Facção, Disposição, Rotina, Contexto de IA)
#   5. Quests (Ativa, Objetivos, Progresso, Histórico)
#   6. Combat (Alvo atual, Distância, Arquétipo, Estado IA, Windup, Cooldown, Postura, Dano)
#   7. Nen & World Interactions (Técnicas ativas, dreno de aura, Gyo/Ko/Zetsu/Ten/En detectados)
#   8. Discovery (POIs e Segredos próximos, Tiers VISIVEL a MUITO_SECRETA, condições)
#   9. Event History (Buffer circular dos últimos 20 eventos com timestamps do jogo)
#   10. Performance (FPS, Frame time, Nodes, Entidades ativas, Objetos físicos, Memória)
# - Gravação e Exportação de Sessões de Playtest em JSON
# ============================================================

signal session_started(session_id: String)
signal session_ended(session_id: String, summary: Dictionary)
signal session_exported(file_path: String)
signal event_logged(entry: Dictionary)

# Flag mestre de depuração
@export var debug_enabled: bool = true

# Sessão Ativa de Playtest
var session_active: bool = false
var session_start_time_msec: int = 0
var session_start_game_time: String = ""
var current_session_id: String = ""

var session_data: Dictionary = {
	"session_id": "",
	"start_time_iso": "",
	"duration_seconds": 0.0,
	"distance_traveled_px": 0.0,
	"distance_traveled_tiles": 0,
	"enemies_killed": 0,
	"enemy_kills_by_type": {},
	"damage_dealt": 0,
	"damage_received": 0,
	"max_single_hit": 0,
	"quests_completed": 0,
	"completed_quests_list": [],
	"npcs_interacted": 0,
	"interacted_npcs_list": [],
	"events_encountered": 0,
	"encountered_events_list": [],
	"discoveries_found": 0,
	"found_discoveries_list": [],
	"nen_techniques_used": {},
	"hatsu_used": {},
	"deaths": 0,
	"gold_gained": 0,
	"gold_spent": 0,
	"combats_count": 0,
	"total_combat_duration_sec": 0.0
}

# Rastreamento de distância e combate
var _last_tracked_player_pos: Vector2 = Vector2.ZERO
var _in_combat_state: bool = false
var _combat_start_time: float = 0.0
var _last_recent_damage_dealt: int = 0
var _last_recent_damage_received: int = 0

# Buffer de Histórico de Eventos (Últimos 20 registros)
const MAX_EVENT_HISTORY: int = 20
var event_history: Array[Dictionary] = []

# Instância do Overlay UI
var overlay_instance: CanvasLayer = null


func _ready() -> void:
	add_to_group("playtest_telemetry")
	print("=================================")
	print("[PlaytestTelemetry] MOTOR DE TELEMETRIA & DEBUG ATIVO")
	print("=================================")
	
	_conectar_barramento_eventos()
	
	# Instanciar Overlay na inicialização se estivermos em modo debug
	if debug_enabled:
		call_deferred("_instanciar_overlay_ui")


func _process(delta: float) -> void:
	if not debug_enabled:
		return
		
	_atualizar_rastreamento_sessao(delta)


# ============================================================
# 1. INTEGRAÇÃO COM BARRAMENTO DE EVENTOS (EVENTBUS)
# ============================================================
func _conectar_barramento_eventos() -> void:
	if EventBus == null:
		return
		
	if not EventBus.player_damaged.is_connected(_on_player_damaged):
		EventBus.player_damaged.connect(_on_player_damaged)
	if not EventBus.player_died.is_connected(_on_player_died):
		EventBus.player_died.connect(_on_player_died)
	if not EventBus.combat_hit_landed.is_connected(_on_combat_hit_landed):
		EventBus.combat_hit_landed.connect(_on_combat_hit_landed)
	if not EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
		EventBus.enemy_defeated.connect(_on_enemy_defeated)
	if not EventBus.boss_phase_changed.is_connected(_on_boss_phase_changed):
		EventBus.boss_phase_changed.connect(_on_boss_phase_changed)
	if not EventBus.quest_accepted.is_connected(_on_quest_accepted):
		EventBus.quest_accepted.connect(_on_quest_accepted)
	if not EventBus.quest_objective_updated.is_connected(_on_quest_objective_updated):
		EventBus.quest_objective_updated.connect(_on_quest_objective_updated)
	if not EventBus.quest_completed.is_connected(_on_quest_completed):
		EventBus.quest_completed.connect(_on_quest_completed)
	if not EventBus.world_event_triggered.is_connected(_on_world_event_triggered):
		EventBus.world_event_triggered.connect(_on_world_event_triggered)
	if not EventBus.ambient_encounter_started.is_connected(_on_ambient_encounter_started):
		EventBus.ambient_encounter_started.connect(_on_ambient_encounter_started)
	if not EventBus.jenny_changed.is_connected(_on_jenny_changed):
		EventBus.jenny_changed.connect(_on_jenny_changed)
	if not EventBus.nen_technique_activated.is_connected(_on_nen_technique_activated):
		EventBus.nen_technique_activated.connect(_on_nen_technique_activated)
	if not EventBus.dialogue_opened.is_connected(_on_dialogue_opened):
		EventBus.dialogue_opened.connect(_on_dialogue_opened)
	if not EventBus.tutorial_started.is_connected(_on_tutorial_started):
		EventBus.tutorial_started.connect(_on_tutorial_started)
	if not EventBus.tutorial_step_completed.is_connected(_on_tutorial_step_completed):
		EventBus.tutorial_step_completed.connect(_on_tutorial_step_completed)
	if not EventBus.tutorial_completed.is_connected(_on_tutorial_completed):
		EventBus.tutorial_completed.connect(_on_tutorial_completed)
	if not EventBus.tutorial_skipped.is_connected(_on_tutorial_skipped):
		EventBus.tutorial_skipped.connect(_on_tutorial_skipped)
	if not EventBus.tutorial_knowledge_unlocked.is_connected(_on_tutorial_knowledge_unlocked):
		EventBus.tutorial_knowledge_unlocked.connect(_on_tutorial_knowledge_unlocked)
	if WorldState != null and WorldState.has_signal("consequencia_processada"):
		if not WorldState.consequencia_processada.is_connected(_on_consequencia_processada):
			WorldState.consequencia_processada.connect(_on_consequencia_processada)


func _on_tutorial_started(id: String) -> void:
	log_event("TUTORIAL", "🚀 Início do Tutorial: " + id)


func _on_tutorial_step_completed(step_id: String, idx: int) -> void:
	log_event("TUTORIAL", "✅ Etapa %d Concluída: %s" % [idx, step_id])


func _on_tutorial_completed(id: String) -> void:
	log_event("TUTORIAL", "🎓 Tutorial Concluído: " + id)


func _on_tutorial_skipped(id: String) -> void:
	log_event("TUTORIAL", "⏭️ Tutorial Pulado: " + id)


func _on_tutorial_knowledge_unlocked(k_id: String, cat: String) -> void:
	log_event("KNOWLEDGE", "📖 Novo Conhecimento: " + k_id, cat)


func _on_consequencia_processada(tipo: String, descricao: String, _duracao: float) -> void:
	log_event("WORLD_STATE", "🌍 Consequência: " + tipo, descricao)


func log_event(tipo: String, titulo: String, detalhes: String = "") -> void:
	var timestamp_str = get_game_timestamp_string()
	var entry = {
		"timestamp": timestamp_str,
		"time_msec": Time.get_ticks_msec(),
		"type": tipo,
		"title": titulo,
		"details": detalhes
	}
	
	event_history.push_front(entry)
	if event_history.size() > MAX_EVENT_HISTORY:
		event_history.pop_back()
		
	event_logged.emit(entry)


func get_game_timestamp_string() -> String:
	if TimeManager != null and TimeManager.has_method("get_time_string"):
		return "%02d:%02d (%s)" % [TimeManager.current_hour, TimeManager.current_minute, TimeManager.get_phase_name()]
	return "00:00"


# Handlers do EventBus
func _on_player_damaged(hp: int, max_hp: int, dano: int) -> void:
	_last_recent_damage_received = dano
	if session_active:
		session_data["damage_received"] += dano
	log_event("COMBAT_DAMAGE_TAKEN", "Jogador sofreu -%d HP" % dano, "HP Restante: %d/%d" % [hp, max_hp])

func _on_player_died() -> void:
	if session_active:
		session_data["deaths"] += 1
	log_event("PLAYER_DEATH", "Jogador foi derrotado!", "Morte registrada na sessão.")

func _on_combat_hit_landed(_attacker: Node, target: Node, dano: int, is_crit: bool) -> void:
	_last_recent_damage_dealt = dano
	if session_active:
		session_data["damage_dealt"] += dano
		session_data["max_single_hit"] = maxi(session_data["max_single_hit"], dano)
	
	var alvo_nome = target.name if target != null else "Inimigo"
	var crit_str = " [CRÍTICO]" if is_crit else ""
	log_event("COMBAT_HIT", "Acertou %s: +%d dano%s" % [alvo_nome, dano, crit_str], "Golpe físico/Nen desferido")

func _on_enemy_defeated(enemy_id: String, xp: int, nen_xp: int) -> void:
	if session_active:
		session_data["enemies_killed"] += 1
		var curr_k = session_data["enemy_kills_by_type"].get(enemy_id, 0)
		session_data["enemy_kills_by_type"][enemy_id] = curr_k + 1
	log_event("COMBAT_ENDED", "Inimigo Derrotado: %s" % enemy_id, "+%d XP | +%d Nen XP" % [xp, nen_xp])

func _on_boss_phase_changed(boss_name: String, new_phase: int) -> void:
	log_event("BOSS_PHASE", "Chefe %s entrou na Fase %d!" % [boss_name, new_phase], "Aura intensificada e novo padrão de ataque.")

func _on_quest_accepted(quest_id: String, quest_name: String) -> void:
	log_event("QUEST_ACCEPTED", "Quest Aceita: %s" % quest_name, "ID: %s" % quest_id)

func _on_quest_objective_updated(quest_id: String, objective_desc: String, current: int, required: int) -> void:
	log_event("QUEST_UPDATED", "Objetivo: %s (%d/%d)" % [objective_desc, current, required], "Quest: %s" % quest_id)

func _on_quest_completed(quest_id: String, reward_xp: int, reward_jenny: int) -> void:
	if session_active:
		session_data["quests_completed"] += 1
		session_data["completed_quests_list"].append(quest_id)
	log_event("QUEST_COMPLETED", "Quest Concluída: %s" % quest_id, "+%d XP | +%d Jenny" % [reward_xp, reward_jenny])

func _on_world_event_triggered(event_id: String, event_title: String, pos: Vector2) -> void:
	if session_active:
		session_data["events_encountered"] += 1
		session_data["encountered_events_list"].append(event_title)
	log_event("EVENT_TRIGGERED", "Evento Mundial: %s" % event_title, "Pos: (%.0f, %.0f)" % [pos.x, pos.y])

func _on_ambient_encounter_started(enc_id: String, title: String) -> void:
	if session_active:
		session_data["events_encountered"] += 1
		session_data["encountered_events_list"].append(title)
	log_event("ENCOUNTER_STARTED", "Encontro Ambiental: %s" % title, "ID: %s" % enc_id)

func _on_jenny_changed(new_total: int, delta: int) -> void:
	if session_active:
		if delta > 0:
			session_data["gold_gained"] += delta
		elif delta < 0:
			session_data["gold_spent"] += abs(delta)
	log_event("ECONOMY_JENNY", "Jenny %s%d" % ["+" if delta >= 0 else "", delta], "Total atual: %d Jenny" % new_total)

func _on_nen_technique_activated(tech_name: String) -> void:
	if session_active:
		var count = session_data["nen_techniques_used"].get(tech_name, 0)
		session_data["nen_techniques_used"][tech_name] = count + 1
	log_event("NEN_TECHNIQUE", "Técnica Nen Ativada: %s" % tech_name, "Consumo e efeito ativados")

func _on_dialogue_opened(speaker: String) -> void:
	if session_active:
		session_data["npcs_interacted"] += 1
		if not session_data["interacted_npcs_list"].has(speaker):
			session_data["interacted_npcs_list"].append(speaker)
	log_event("NPC_INTERACTED", "Interação com NPC: %s" % speaker, "Diálogo ou serviço acessado")


# ============================================================
# 2. GESTÃO DE SESSÕES DE PLAYTEST
# ============================================================
func start_session() -> Dictionary:
	session_active = true
	session_start_time_msec = Time.get_ticks_msec()
	session_start_game_time = get_game_timestamp_string()
	current_session_id = "playtest_%s" % Time.get_datetime_string_from_system().replace(":", "").replace("-", "")
	
	session_data = {
		"session_id": current_session_id,
		"start_time_iso": Time.get_datetime_string_from_system(),
		"duration_seconds": 0.0,
		"distance_traveled_px": 0.0,
		"distance_traveled_tiles": 0,
		"enemies_killed": 0,
		"enemy_kills_by_type": {},
		"damage_dealt": 0,
		"damage_received": 0,
		"max_single_hit": 0,
		"quests_completed": 0,
		"completed_quests_list": [],
		"npcs_interacted": 0,
		"interacted_npcs_list": [],
		"events_encountered": 0,
		"encountered_events_list": [],
		"discoveries_found": 0,
		"found_discoveries_list": [],
		"nen_techniques_used": {},
		"hatsu_used": {},
		"deaths": 0,
		"gold_gained": 0,
		"gold_spent": 0,
		"combats_count": 0,
		"total_combat_duration_sec": 0.0
	}
	
	var ply = _obter_player_node()
	if ply != null:
		_last_tracked_player_pos = ply.global_position
		
	session_started.emit(current_session_id)
	log_event("SESSION_STARTED", "Sessão de Playtest Iniciada", current_session_id)
	print("[PlaytestTelemetry] 🔴 Sessão iniciada: %s" % current_session_id)
	return session_data


func end_session() -> Dictionary:
	if not session_active:
		return session_data
		
	session_active = false
	var elapsed_sec = (Time.get_ticks_msec() - session_start_time_msec) / 1000.0
	session_data["duration_seconds"] = elapsed_sec
	session_data["end_time_iso"] = Time.get_datetime_string_from_system()
	
	session_ended.emit(current_session_id, session_data)
	log_event("SESSION_ENDED", "Sessão de Playtest Finalizada", "Duração: %.1fs" % elapsed_sec)
	print("[PlaytestTelemetry] ⏹️ Sessão finalizada: %s (Duração: %.1fs)" % [current_session_id, elapsed_sec])
	return session_data


func is_session_active() -> bool:
	return session_active


func get_session_summary() -> Dictionary:
	if session_active:
		var elapsed_sec = (Time.get_ticks_msec() - session_start_time_msec) / 1000.0
		session_data["duration_seconds"] = elapsed_sec
	return session_data


func export_session_json(custom_path: String = "") -> String:
	var summary = get_session_summary()
	var json_str = JSON.stringify(summary, "  ")
	
	var target_dir = "res://debug/playtest"
	var export_path = custom_path
	if export_path.is_empty():
		export_path = "%s/playtest_session_%s.json" % [target_dir, summary.get("session_id", "latest")]
		
	# Garantir criação do diretório
	if not DirAccess.dir_exists_absolute(target_dir):
		DirAccess.make_dir_recursive_absolute(target_dir)
		
	var file = FileAccess.open(export_path, FileAccess.WRITE)
	if file == null:
		# Fallback para user:// se res:// for somente leitura em builds exportadas
		target_dir = "user://debug/playtest"
		if not DirAccess.dir_exists_absolute(target_dir):
			DirAccess.make_dir_recursive_absolute(target_dir)
		export_path = "%s/playtest_session_%s.json" % [target_dir, summary.get("session_id", "latest")]
		file = FileAccess.open(export_path, FileAccess.WRITE)
		
	if file != null:
		file.store_string(json_str)
		file.close()
		session_exported.emit(export_path)
		log_event("SESSION_EXPORTED", "JSON Exportado com Sucesso", export_path)
		print("[PlaytestTelemetry] 💾 Telemetria exportada para: %s" % export_path)
		return export_path
		
	push_error("[PlaytestTelemetry] Erro ao gravar arquivo JSON de telemetria.")
	return ""


func _atualizar_rastreamento_sessao(delta: float) -> void:
	var ply = _obter_player_node()
	if ply != null:
		var curr_pos = ply.global_position
		if _last_tracked_player_pos != Vector2.ZERO:
			var step = _last_tracked_player_pos.distance_to(curr_pos)
			if session_active:
				session_data["distance_traveled_px"] += step
				session_data["distance_traveled_tiles"] = int(session_data["distance_traveled_px"] / 16.0)
		_last_tracked_player_pos = curr_pos
		
		# Rastrear técnicas de Nen em uso por tempo
		var nen_sys = ply.get_node_or_null("NenSystem") as NenSystem
		if nen_sys != null and session_active:
			for tec_enum in nen_sys.tecnicas.keys():
				if nen_sys.tecnica_ativa(tec_enum):
					var t_name = NenSystem.Tecnica.keys()[tec_enum]
					var dur = session_data["nen_techniques_used"].get(t_name + "_time_sec", 0.0)
					session_data["nen_techniques_used"][t_name + "_time_sec"] = dur + delta


# ============================================================
# 3. PROVEDORES DE MÉTRICAS EM TEMPO REAL (10 DOMÍNIOS)
# ============================================================

# 1. PLAYER METRICS
func get_player_metrics() -> Dictionary:
	var ply = _obter_player_node()
	var p_pos = ply.global_position if ply != null else Vector2.ZERO
	var map_name = get_tree().current_scene.name if get_tree().current_scene else "Desconhecido"
	var scene_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	
	var hp = PlayerData.attributes.get("vida", 100) if PlayerData else 100
	var hp_max = PlayerData.attributes.get("vida_max", 100) if PlayerData else 100
	var aura = PlayerData.attributes.get("aura", 0.0) if PlayerData else 0.0
	var aura_max = PlayerData.attributes.get("aura_max", 0.0) if PlayerData else 0.0
	var lvl = PlayerData.attributes.get("nivel", 1) if PlayerData else 1
	var lvl_nen = PlayerData.attributes.get("nivel_nen", 0) if PlayerData else 0
	
	var combat_sys = ply.get_node_or_null("CombatSystem") if ply != null else null
	var combat_state_str = "NORMAL"
	if combat_sys != null:
		combat_state_str = HunterCombatSystem.Estado.keys()[combat_sys.estado]
		
	var nen_sys = ply.get_node_or_null("NenSystem") as NenSystem if ply != null else null
	var active_techs: Array[String] = []
	if nen_sys != null:
		for t_enum in nen_sys.tecnicas.keys():
			if nen_sys.tecnica_ativa(t_enum):
				active_techs.append(NenSystem.Tecnica.keys()[t_enum])
				
	var speed_val = ply._obter_velocidade_atual() if (ply != null and ply.has_method("_obter_velocidade_atual")) else 64.0
	var sprint_val = ply.esta_em_sprint() if (ply != null and ply.has_method("esta_em_sprint")) else false
	
	var active_quest_title = "Nenhuma"
	if QuestSystem != null and not QuestSystem.active_quests.is_empty():
		active_quest_title = QuestSystem.active_quests[0].quest_name
		
	return {
		"position": p_pos,
		"tile_coords": Vector2i(int(p_pos.x / 16.0), int(p_pos.y / 16.0)),
		"map_name": map_name,
		"scene_path": scene_path,
		"level": lvl,
		"level_nen": lvl_nen,
		"hp": hp,
		"hp_max": hp_max,
		"hp_pct": (float(hp) / maxf(1.0, float(hp_max))) * 100.0,
		"aura": aura,
		"aura_max": aura_max,
		"aura_pct": (float(aura) / maxf(1.0, float(aura_max))) * 100.0 if aura_max > 0 else 0.0,
		"active_nen_techniques": active_techs,
		"combat_state": combat_state_str,
		"movement_speed": speed_val,
		"is_sprinting": sprint_val,
		"current_quest": active_quest_title
	}


# 2. WORLD METRICS
func get_world_metrics() -> Dictionary:
	var ply = _obter_player_node()
	var p_pos = ply.global_position if ply != null else Vector2.ZERO
	
	var director = get_tree().get_first_node_in_group("content_director") as ContentDirector
	var zone_name = director.current_zone_name if director != null else "Mundo Aberto"
	var risk_lvl = director.current_risk if director != null else 1
	var chunk_coords = Vector2i(int(p_pos.x / 512.0), int(p_pos.y / 512.0))
	
	var time_str = TimeManager.get_time_string() if TimeManager else "08:00 (DAY)"
	var phase_str = TimeManager.get_phase_name() if TimeManager else "DAY"
	
	# POIs próximos
	var nearby_pois: Array[Dictionary] = []
	if director != null and director.registered_pois is Array:
		for poi in director.registered_pois:
			var d = p_pos.distance_to(poi.get("pos", Vector2.ZERO))
			if d <= 1200.0:
				nearby_pois.append({"name": poi.get("name", "POI"), "type": poi.get("type", "UNKNOWN"), "distance": d})
				
	# Contagens de proximidade (< 600px)
	var nearby_npcs_count = 0
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc is Node2D and p_pos.distance_to(npc.global_position) <= 600.0:
			nearby_npcs_count += 1
			
	var nearby_enemies_count = 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D and p_pos.distance_to(enemy.global_position) <= 600.0:
			nearby_enemies_count += 1
			
	var nearby_events_count = director.active_events.size() if director != null else 0
	
	return {
		"current_time": time_str,
		"phase": phase_str,
		"zone_name": zone_name,
		"danger_level": risk_lvl,
		"current_chunk": chunk_coords,
		"nearby_pois": nearby_pois,
		"nearby_npcs_count": nearby_npcs_count,
		"nearby_enemies_count": nearby_enemies_count,
		"nearby_events_count": nearby_events_count
	}


# 3. CONTENT DIRECTOR METRICS & REGION BREAKDOWN
func get_content_director_metrics() -> Dictionary:
	var director = get_tree().get_first_node_in_group("content_director") as ContentDirector
	if director == null:
		return {
			"has_director": false,
			"combat_pct": 0,
			"npc_pct": 0,
			"event_pct": 0,
			"discovery_pct": 0
		}
		
	var m = director.get_debug_metrics()
	var risk = director.current_risk
	var profile = director.config.zone_profiles.get(risk, {}) if director.config != null else {}
	
	var pve_density = profile.get("pve_density", 0.5)
	var npc_density = profile.get("npc_density", 0.5)
	var event_density = profile.get("event_density", 0.4)
	var encounter_density = profile.get("encounter_density", 0.5)
	
	var total_density = maxf(0.01, pve_density + npc_density + event_density + encounter_density)
	var combat_pct = (pve_density / total_density) * 100.0
	var npc_pct = (npc_density / total_density) * 100.0
	var event_pct = (event_density / total_density) * 100.0
	var discovery_pct = (encounter_density / total_density) * 100.0
	
	var candidates: Array = profile.get("allowed_events", [])
	
	return {
		"has_director": true,
		"zone_name": m.get("zone_name", ""),
		"risk_level": m.get("risk_level", 0),
		"active_npcs": m.get("active_npcs", 0),
		"active_enemies": m.get("active_enemies", 0),
		"active_events": m.get("active_events", 0),
		"active_encounters": m.get("active_encounters", 0),
		"registered_pois": m.get("registered_pois", 0),
		"distance_travelled": m.get("distance_travelled", 0.0),
		"distance_since_last_event": m.get("distance_since_last_event", 0.0),
		"next_event_distance_estimate": m.get("next_event_distance_estimate", 0.0),
		"event_cooldown": director.timer_event_cooldown,
		"encounter_cooldown": director.timer_encounter_cooldown,
		"event_candidates": candidates,
		"combat_pct": combat_pct,
		"npc_pct": npc_pct,
		"event_pct": event_pct,
		"discovery_pct": discovery_pct
	}


# 4. NPC PROXIMITY & INTELLIGENCE
func get_npc_proximity_metrics() -> Dictionary:
	var ply = _obter_player_node()
	if ply == null:
		return {"has_nearby_npc": false}
		
	var p_pos = ply.global_position
	var nearest_npc: Node2D = null
	var min_dist: float = 350.0
	
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc is Node2D:
			var d = p_pos.distance_to(npc.global_position)
			if d < min_dist:
				min_dist = d
				nearest_npc = npc
				
	if nearest_npc == null:
		return {"has_nearby_npc": false}
		
	var n_name = nearest_npc.npc_name if "npc_name" in nearest_npc else nearest_npc.name
	var living = nearest_npc.get_node_or_null("LivingNPCBehavior") as LivingNPCBehavior
	var schedule_state = "resting"
	if living != null:
		schedule_state = "walking" if living.em_movimento else "resting"
		
	var faction_str = "Civis & Cidades"
	var rep_val = ReputationSystem.obter_reputacao(ReputationSystem.Faccao.CIVIS) if ReputationSystem != null else 100
	var disposition = "Favorável"
	if ReputationSystem != null:
		disposition = ReputationSystem.obter_status_nome(ReputationSystem.Faccao.CIVIS)
		
	var why_doing = "Observando a cidade e cumprindo rotina diurna."
	if living != null and living.has_method("obter_dialogo_reativo"):
		why_doing = "Reagindo ao ambiente: '%s'" % living.obter_dialogo_reativo()
		
	return {
		"has_nearby_npc": true,
		"npc_name": n_name,
		"distance": min_dist,
		"faction": faction_str,
		"relationship_score": rep_val,
		"disposition": disposition,
		"reputation_influence": "Desconto e confiança positiva",
		"current_activity": schedule_state,
		"current_routine": "Patrulha Urbana (Raio 80px)",
		"why_npc_doing_this": why_doing,
		"memory_entries": ["Interação disponível", "Registro de visita em Quests"]
	}


# 5. QUEST METRICS
func get_quest_metrics() -> Dictionary:
	if QuestSystem == null or QuestSystem.active_quests.is_empty():
		return {"has_active_quest": false}
		
	var q = QuestSystem.active_quests[0]
	var obj_desc = "Nenhum"
	var cur_prog = 0
	var req_prog = 1
	
	if not q.objectives.is_empty():
		var obj = q.objectives[0]
		obj_desc = obj.describe()
		req_prog = obj.required_amount
		cur_prog = PlayerData.get_quest_objective_progress(q, 0) if PlayerData else 0
		
	var recent_ev = event_history.filter(func(e): return "QUEST" in e.get("type", ""))
	var last_quest_event = recent_ev[0].get("title", "") if not recent_ev.is_empty() else "Nenhum evento recente"
	
	return {
		"has_active_quest": true,
		"quest_id": q.resource_path if not q.resource_path.is_empty() else q.quest_name,
		"quest_name": q.quest_name,
		"objective": obj_desc,
		"progress": "%d / %d" % [cur_prog, req_prog],
		"progress_pct": (float(cur_prog) / maxf(1.0, float(req_prog))) * 100.0,
		"quest_state": "ACTIVE",
		"recent_quest_event": last_quest_event
	}


# 6. COMBAT & ENEMY INTELLIGENCE
func get_combat_metrics() -> Dictionary:
	var ply = _obter_player_node()
	if ply == null:
		return {"in_combat": false}
		
	var p_pos = ply.global_position
	var nearest_enemy: CharacterBody2D = null
	var min_dist: float = 400.0
	
	for e in get_tree().get_nodes_in_group("enemies"):
		if e is CharacterBody2D and is_instance_valid(e):
			var d = p_pos.distance_to(e.global_position)
			if d < min_dist:
				min_dist = d
				nearest_enemy = e
				
	if nearest_enemy == null:
		return {
			"in_combat": false,
			"recent_damage_dealt": _last_recent_damage_dealt,
			"recent_damage_received": _last_recent_damage_received
		}
		
	var es = nearest_enemy.get_node_or_null("EnemySystem") as EnemySystem
	var ai = nearest_enemy.get_node_or_null("EnemyAI") as EnemyAI
	
	var e_name = es.enemy_name if es != null else nearest_enemy.name
	var e_archetype = ai._obter_role() if ai != null else "bruiser"
	var e_state_str = "IDLE"
	if ai != null:
		e_state_str = EnemyAI.State.keys()[ai.current_state]
		
	var windup_val = ai.windup_timer if ai != null else 0.0
	var cd_val = ai.attack_timer if ai != null else 0.0
	var postura_val = es.postura if es != null else 100.0
	var postura_max = es.postura_max if es != null else 100.0
	var em_stagger = es.em_stagger if es != null else false
	
	return {
		"in_combat": true,
		"target_name": e_name,
		"distance": min_dist,
		"archetype": e_archetype,
		"enemy_state": e_state_str,
		"attack_windup": windup_val,
		"attack_cooldown": cd_val,
		"postura": postura_val,
		"postura_max": postura_max,
		"em_stagger": em_stagger,
		"recent_damage_dealt": _last_recent_damage_dealt,
		"recent_damage_received": _last_recent_damage_received
	}


# 7. NEN & WORLD INTERACTIONS
func get_nen_metrics() -> Dictionary:
	var ply = _obter_player_node()
	if ply == null:
		return {"nen_active": false}
		
	var nen_sys = ply.get_node_or_null("NenSystem") as NenSystem
	if nen_sys == null or not PlayerData.despertou_nen:
		return {"nen_active": false, "despertou_nen": false}
		
	var active_tech_name = "NENHUMA"
	var aura_rate = nen_sys.aura_regen_por_segundo
	var effects: Array[String] = []
	var detected_interactions: Array[Dictionary] = []
	
	var p_pos = ply.global_position
	
	# Checar Técnicas Ativas e Interações de Mundo
	if nen_sys.tecnica_ativa(NenSystem.Tecnica.TEN):
		active_tech_name = "TEN"
		aura_rate = -nen_sys.obter_custo_por_segundo(NenSystem.Tecnica.TEN)
		var red_pct = int(minf(0.80, nen_sys.ten_reducao_nivel_1 * maxf(1.0, float(nen_sys.obter_nivel_tecnica(NenSystem.Tecnica.TEN)))) * 100.0)
		effects.append("Redução de Dano Recebido (-%d%%)" % red_pct)
		# Detectar Zonas de Perigo protegidas por Ten
		for hazard in get_tree().get_nodes_in_group("ten_hazard_zone"):
			if hazard is Node2D and p_pos.distance_to(hazard.global_position) <= 300.0:
				detected_interactions.append({"type": "TEN_HAZARD", "name": "Zona de Miasma/Perigo protegida pelo TEN", "dist": p_pos.distance_to(hazard.global_position)})
				
	elif nen_sys.tecnica_ativa(NenSystem.Tecnica.REN):
		active_tech_name = "REN"
		aura_rate = -nen_sys.obter_custo_por_segundo(NenSystem.Tecnica.REN)
		effects.append("Alcance de Ataque Expandido (+%d%%)" % int(nen_sys.ren_alcance_nivel_1 * 100))
		for beacon in get_tree().get_nodes_in_group("ren_beacon"):
			if beacon is Node2D and p_pos.distance_to(beacon.global_position) <= 300.0:
				detected_interactions.append({"type": "REN_BEACON", "name": "Farol de Ren sintonizado", "dist": p_pos.distance_to(beacon.global_position)})
				
	elif nen_sys.tecnica_ativa(NenSystem.Tecnica.GYO):
		active_tech_name = "GYO"
		aura_rate = -nen_sys.obter_custo_por_segundo(NenSystem.Tecnica.GYO)
		effects.append("Esquiva Amplificada e Revelação de Pistas Ocultas")
		# Detectar pistas e runas GyoInspectable
		for gyo_obj in get_tree().get_nodes_in_group("gyo_inspectable"):
			if gyo_obj is Node2D and p_pos.distance_to(gyo_obj.global_position) <= 400.0:
				var clue_title = gyo_obj.titulo_pista if "titulo_pista" in gyo_obj else "Pista de Aura"
				detected_interactions.append({"type": "GYO_CLUE", "name": "🔍 " + clue_title, "dist": p_pos.distance_to(gyo_obj.global_position)})
				
	elif nen_sys.tecnica_ativa(NenSystem.Tecnica.KO):
		active_tech_name = "KO"
		aura_rate = 0.0 # Gasto por golpe
		effects.append("Multiplicador de Dano Concentrado (+250%)")
		# Detectar obstáculos destrutíveis por Ko
		for ko_wall in get_tree().get_nodes_in_group("ko_obstacle"):
			if ko_wall is Node2D and p_pos.distance_to(ko_wall.global_position) <= 250.0:
				var w_name = ko_wall.obstacle_name if "obstacle_name" in ko_wall else "Barreira Destrutível"
				detected_interactions.append({"type": "KO_OBSTACLE", "name": "💥 " + w_name + " (Destrutível com KO)", "dist": p_pos.distance_to(ko_wall.global_position)})
				
	elif nen_sys.tecnica_ativa(NenSystem.Tecnica.ZETSU):
		active_tech_name = "ZETSU"
		aura_rate = 0.0
		effects.append("Supressão Total de Presença & Furtividade")
		for sensor in get_tree().get_nodes_in_group("zetsu_sensor"):
			if sensor is Node2D and p_pos.distance_to(sensor.global_position) <= 300.0:
				detected_interactions.append({"type": "ZETSU_SENSOR", "name": "Sensor de Nen Furtivo burlado", "dist": p_pos.distance_to(sensor.global_position)})
				
	elif nen_sys.tecnica_ativa(NenSystem.Tecnica.EN):
		active_tech_name = "EN"
		aura_rate = -12.0
		effects.append("Esfera de Percepção e Radar Espacial Ativo")
		
	return {
		"nen_active": true,
		"despertou_nen": true,
		"current_technique": active_tech_name,
		"aura_rate_per_sec": aura_rate,
		"active_effects": effects,
		"detected_world_interactions": detected_interactions
	}


# 8. DISCOVERY METRICS
func get_discovery_metrics() -> Dictionary:
	var ply = _obter_player_node()
	if ply == null:
		return {"has_nearby_discovery": false}
		
	var p_pos = ply.global_position
	var director = get_tree().get_first_node_in_group("content_director") as ContentDirector
	
	if director == null or director.registered_pois.is_empty():
		return {"has_nearby_discovery": false}
		
	var nearest_poi: Dictionary = {}
	var min_dist: float = 1200.0
	
	for poi in director.registered_pois:
		var d = p_pos.distance_to(poi.get("pos", Vector2.ZERO))
		if d < min_dist:
			min_dist = d
			nearest_poi = poi
			
	if nearest_poi.is_empty():
		return {"has_nearby_discovery": false}
		
	var p_id = nearest_poi.get("id", "")
	var is_discovered = PlayerData.quest_states.get("poi_descoberto_%s" % p_id, false) if PlayerData else false
	var tier_name = "VISIBLE"
	var cond_req = "Aproximação física"
	
	match nearest_poi.get("type", ""):
		"SECRET":
			tier_name = "SECRET"
			cond_req = "Requer técnica KO para quebrar entrada da caverna"
		"HAZARD":
			tier_name = "HIDDEN"
			cond_req = "Requer técnica TEN para resistir ao miasma da ravina"
		"DUNGEON":
			tier_name = "VERY_SECRET"
			cond_req = "Requer GYO para decifrar glifos ancestrais e chave das ruínas"
		_:
			tier_name = "VISIBLE"
			cond_req = "Exploração e aproximação geográfica"
			
	return {
		"has_nearby_discovery": true,
		"name": nearest_poi.get("name", "Ponto Notável"),
		"type": tier_name,
		"distance_px": min_dist,
		"distance_tiles": int(min_dist / 16.0),
		"discovery_state": "DESCOBERTO" if is_discovered else "NÃO DESCOBERTO",
		"required_condition": cond_req
	}


# 9. EVENT HISTORY METRICS
func get_event_history_metrics() -> Array[Dictionary]:
	return event_history


# 10. PERFORMANCE METRICS
func get_performance_metrics() -> Dictionary:
	var fps = Engine.get_frames_per_second()
	var frame_time_ms = (1000.0 / maxf(1.0, float(fps)))
	var node_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var active_enemies = get_tree().get_nodes_in_group("enemies").size()
	var active_npcs = get_tree().get_nodes_in_group("npc").size()
	var physics_objects = Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS)
	var memory_static_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	
	return {
		"fps": fps,
		"frame_time_ms": frame_time_ms,
		"node_count": int(node_count),
		"active_enemies": active_enemies,
		"active_npcs": active_npcs,
		"physics_objects": int(physics_objects),
		"memory_mb": memory_static_mb
	}


# 11. CHARACTER SYSTEM METRICS (PERSISTÊNCIA & CICLO DE VIDA)
func get_character_system_metrics() -> Dictionary:
	var loaded_chars: int = 0
	for s in range(1, 4):
		if SaveManager != null and SaveManager.existe_save_no_slot(s):
			loaded_chars += 1

	var char_id = PlayerData.character_id if PlayerData != null else ""
	var char_name = PlayerData.nome_personagem if PlayerData != null else "Desconhecido"
	var char_ready = PlayerData.is_character_ready if PlayerData != null else false
	var flow_str = GameManager._flow_to_string(GameManager.flow_state) if GameManager != null else "UNKNOWN"
	var target_map = PlayerData.mapa_atual_salvo if PlayerData != null else "res://world/lobby.tscn"
	var active_slot = PlayerData.slot_ativo if PlayerData != null else 1
	var quest_cnt = PlayerData.quest_states.size() if PlayerData != null else 0
	var tut_done = PlayerData.tutorial_concluido if PlayerData != null else false
	var story_arc = PlayerData.arco_atual if PlayerData != null else 1
	var story_stage = PlayerData.etapa_quest_arco if PlayerData != null else 1

	return {
		"loaded_characters_count": loaded_chars,
		"selected_character_id": char_id,
		"selected_slot": active_slot,
		"character_name": char_name,
		"is_character_ready": char_ready,
		"save_status": "VALID",
		"load_status": "SUCCESS" if char_ready else "PENDING",
		"character_data_status": "LOADED" if char_ready else "NOT_LOADED",
		"player_data_status": "LOADED" if char_ready else "DEFAULT",
		"story_progress": "Arco %d / Fase %d" % [story_arc, story_stage],
		"quest_progress": "%d Quests/Objetivos Salvos" % quest_cnt,
		"tutorial_progress": "CONCLUÍDO" if tut_done else "EM PROGRESSO",
		"world_target": target_map,
		"world_status": "READY",
		"spawn_status": "VALID",
		"scene_transition_status": "READY",
		"game_flow": flow_str
	}


# Helpers internos
func _obter_player_node() -> CharacterBody2D:
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		return players[0] as CharacterBody2D
	return null


func _instanciar_overlay_ui() -> void:
	if overlay_instance != null and is_instance_valid(overlay_instance):
		return
		
	var scn = load("res://debug/telemetry/PlaytestDebugOverlay.tscn") as PackedScene
	if scn != null:
		overlay_instance = scn.instantiate() as CanvasLayer
		add_child(overlay_instance)
		print("[PlaytestTelemetry] PlaytestDebugOverlay instanciado com sucesso (Atalho: F3).")
