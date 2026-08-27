class_name ContentDirector
extends Node2D

# ============================================================
# HUNTER ONLINE - CONTENT DIRECTOR
# ============================================================
#
# Diretor de Conteúdo e Densidade Espacial:
# - Opera acima do mapa sem depender do TileSet
# - Controla densidade de NPCs, PvE, Eventos, Encontros e POIs
# - Varia por zona de risco (SAFE, LOW, MEDIUM, HIGH, DANGER)
# - Controla densidade por distância percorrida (por 1000 tiles)
# - Implementa Anti-Spam (distância mínima entre eventos)
# - Coleta métricas em tempo real para debug
#
# ============================================================

const RegionContentConfigScript = preload("res://world/content/RegionContentConfig.gd")
const WorldEventDataScript = preload("res://world/content/WorldEventData.gd")
const AmbientEncounterDataScript = preload("res://world/content/AmbientEncounterData.gd")
const NPCScheduleDataScript = preload("res://world/content/NPCScheduleData.gd")

@export var config: Resource = null
@export var player_node: Node2D = null

# Contêineres de Entidades Ativas
var active_npcs: Array = []
var active_enemies: Array = []
var active_events: Array = []
var active_encounters: Array = []
var registered_pois: Array = []

# Rastreamento de Distância e Posição do Jogador
var last_player_pos: Vector2 = Vector2.ZERO
var last_event_pos: Vector2 = Vector2.ZERO
var total_distance_travelled: float = 0.0
var distance_since_last_event: float = 0.0
var distance_since_last_encounter: float = 0.0
var encounter_distances_history: Array = []

# Timers
var timer_event_cooldown: float = 0.0
var timer_encounter_cooldown: float = 0.0
var target_next_event_distance: float = 800.0 # pixels (~50 tiles)
var target_next_encounter_distance: float = 400.0

# Zona de Risco Atual
var current_risk: int = 0
var current_zone_name: String = "Vila de Padokia (SAFE)"

# RNG Determinístico com Seed
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	if config == null:
		config = RegionContentConfigScript.create_default()
		
	rng.seed = config.seed_val
	_inicializar_pois_padrao()
	_inicializar_populacao_base()
	
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
		
	if player_node != null:
		last_player_pos = player_node.global_position
		last_event_pos = last_player_pos


func _process(delta: float) -> void:
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
		if player_node != null:
			last_player_pos = player_node.global_position
			last_event_pos = last_player_pos
		return
		
	var current_pos = player_node.global_position
	var step_dist = last_player_pos.distance_to(current_pos)
	last_player_pos = current_pos
	
	total_distance_travelled += step_dist
	distance_since_last_event += step_dist
	distance_since_last_encounter += step_dist
	
	# Atualizar Timers
	if timer_event_cooldown > 0.0: timer_event_cooldown -= delta
	if timer_encounter_cooldown > 0.0: timer_encounter_cooldown -= delta
	
	# 1. Atualizar Avaliação da Zona de Risco
	_avaliar_zona_de_risco(current_pos)
	
	# 2. Verificar Gatilhos de Distância Espacial
	_verificar_gatilhos_de_conteudo(current_pos)
	
	# 3. Gerenciar Despawn de Entidades Distantes (> despawn_radius)
	_gerenciar_despawn_e_ciclo_de_vida(current_pos)


# ============================================================
# 1. AVALIAÇÃO DE ZONA DE RISCO
# ============================================================
func _avaliar_zona_de_risco(pos: Vector2) -> void:
	# Mapeamento de Zonas por Coordenadas
	if pos.x < 2200 and pos.y >= 2800:
		current_risk = 0 # SAFE (Vila)
		current_zone_name = "Vila de Padokia (SAFE)"
	elif pos.x >= 2200 and pos.x < 3600 and pos.y >= 2000 and pos.y < 4200:
		current_risk = 1 # LOW_RISK (Estrada Real)
		current_zone_name = "Estrada Real (LOW RISK)"
	elif pos.x >= 3600 and pos.x < 5600 and pos.y < 5000:
		current_risk = 2 # MEDIUM_RISK (Floresta dos Vestígios)
		current_zone_name = "Floresta dos Vestígios (MEDIUM RISK)"
	elif pos.x >= 5800 and pos.y <= 2600:
		current_risk = 3 # HIGH_RISK (Ruínas de Zaban)
		current_zone_name = "Ruínas de Zaban (HIGH RISK)"
	elif pos.x >= 5200 and pos.y >= 5200:
		current_risk = 4 # DANGER (Ravina da Névoa)
		current_zone_name = "Ravina da Névoa (DANGER)"
	else:
		current_risk = 1 # Padrão campos abertos
		current_zone_name = "Campos Exteriores (LOW RISK)"


# ============================================================
# 2. GATILHOS DE CONTEÚDO BASEADOS EM DISTÂNCIA E RISCO
# ============================================================
func _verificar_gatilhos_de_conteudo(player_pos: Vector2) -> void:
	# A. GATILHO DE ENCONTRO AMBIENTAL
	if distance_since_last_encounter >= target_next_encounter_distance and timer_encounter_cooldown <= 0.0:
		if active_encounters.size() < config.max_active_encounters:
			_tentar_spawn_encontro_ambiental(player_pos)
			
	# B. GATILHO DE EVENTO DINÂMICO
	if distance_since_last_event >= target_next_event_distance and timer_event_cooldown <= 0.0:
		if active_events.size() < config.max_active_events:
			_tentar_spawn_evento_dinamico(player_pos)
			
	# C. MANUTENÇÃO DE POPULAÇÃO PVE NA ZONA ATUAL
	_verificar_populacao_pve_local(player_pos)


func _tentar_spawn_encontro_ambiental(player_pos: Vector2) -> void:
	var profile = config.zone_profiles.get(current_risk, {})
	var encounter_chance = profile.get("encounter_density", 0.5)
	
	# Bônus contextual: se estiver de noite ou com HP crítico
	var e_noite: bool = (TimeManager != null and TimeManager.fase_solar == TimeManager.FaseSolar.NIGHT)
	var hp_atual: int = int(PlayerData.attributes.get("vida", 100))
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	var hp_critico: bool = (hp_atual <= hp_max * 0.35)

	if rng.randf() <= encounter_chance:
		var spawn_pos = _calcular_posicao_spawn_periferica(player_pos)
		
		# Anti-Spam: Verificar distância mínima em relação ao último evento
		if spawn_pos.distance_to(last_event_pos) < config.minimum_distance_between_events:
			return
			
		var enc = AmbientEncounterDataScript.new()
		enc.id = "enc_%d" % rng.randi()
		enc.pos = spawn_pos
		enc.is_active = true
		
		# Contextual: Se HP estiver crítico em zona selvagem, spawnar socorro médico!
		if hp_critico and current_risk > 0 and rng.randf() < 0.60:
			enc.encounter_type = AmbientEncounterDataScript.EncounterType.WANDERING_MERCHANT
			enc.title = "🚑 Caravana Médica Itinerante"
			enc.dialogue_text = "Você parece ferido! Descanse em nossa fogueira para recuperar suas forças."
		# Contextual: Se estiver de noite, predadores noturnos aumentam
		elif e_noite and current_risk >= 2 and rng.randf() < 0.50:
			enc.encounter_type = AmbientEncounterDataScript.EncounterType.HUNTER_VS_CREATURE
			enc.title = "🌙 Fera Predadora Noturna (+25% XP)"
			enc.dialogue_text = "Os olhos da besta brilham no escuro da noite!"
		else:
			# Escolher tipo de acordo com a zona
			match current_risk:
				0: # SAFE
					enc.encounter_type = AmbientEncounterDataScript.EncounterType.WANDERING_MERCHANT if rng.randf() > 0.5 else AmbientEncounterDataScript.EncounterType.HUNTER_TRAVELING
					enc.title = "Comerciante Ambulante de Padokia"
					enc.dialogue_text = "Temos materiais de forja e anéis para sua jornada!"
				1: # LOW_RISK
					enc.encounter_type = AmbientEncounterDataScript.EncounterType.HUNTER_TRAVELING
					enc.title = "Caçador em Trânsito"
					enc.dialogue_text = "Cuidado mais à frente, a estrada costuma ter bandidos."
				2: # MEDIUM_RISK
					enc.encounter_type = AmbientEncounterDataScript.EncounterType.NEN_TRAINING
					enc.title = "Praticante de Nen Meditando"
					enc.dialogue_text = "Sinto o fluxo de Ten purificando minha aura..."
				3, 4: # HIGH / DANGER
					enc.encounter_type = AmbientEncounterDataScript.EncounterType.HUNTER_VS_CREATURE
					enc.title = "Caçador em Combate com Monstro"
					enc.dialogue_text = "Ajude-me a repelir esta fera voraz!"
				
		active_encounters.append(enc)
		encounter_distances_history.append(distance_since_last_encounter)
		distance_since_last_encounter = 0.0
		timer_encounter_cooldown = rng.randf_range(config.encounter_min_interval_sec, config.encounter_max_interval_sec)
		target_next_encounter_distance = rng.randf_range(300.0, 600.0)
		print("[ContentDirector] Encontro contextual ativado: %s em %s" % [enc.title, enc.pos])


func _tentar_spawn_evento_dinamico(player_pos: Vector2) -> void:
	var profile = config.zone_profiles.get(current_risk, {})
	var event_chance = profile.get("event_density", 0.4)
	var e_noite: bool = (TimeManager != null and TimeManager.fase_solar == TimeManager.FaseSolar.NIGHT)
	var nen_lvl: int = int(PlayerData.attributes.get("nivel_nen", 0))
	
	if rng.randf() <= event_chance:
		var spawn_pos = _calcular_posicao_spawn_periferica(player_pos)
		
		# Anti-Spam
		if spawn_pos.distance_to(last_event_pos) < config.minimum_distance_between_events:
			return
			
		var ev = WorldEventDataScript.new()
		ev.id = "ev_%d" % rng.randi()
		ev.spawn_pos = spawn_pos
		ev.is_active = true
		ev.duration = rng.randf_range(60.0, 180.0)
		
		# Contextual: Desafio de Nen se o jogador já domina técnicas
		if nen_lvl >= 2 and rng.randf() < 0.40 and current_risk >= 2:
			ev.type = WorldEventDataScript.EventType.HUNTER_FIGHT
			ev.title = "⚡ Duelo Tático: Andarilho de Nen"
			ev.description = "Um mestre errante deseja testar seu domínio de Ten e Ren!"

		elif e_noite and current_risk >= 2:
			ev.type = WorldEventDataScript.EventType.RARE_MONSTER
			ev.title = "🌙 Fera Quimera Noturna (+25% XP)"
			ev.description = "Uma criatura noturna de alta periculosidade surgiu na região!"
		else:
			# Escolher evento temático da zona
			match current_risk:
				0: # SAFE
					ev.type = WorldEventDataScript.EventType.MERCHANT
					ev.title = "Feira Especial de Mercadores de Yorknew"
					ev.description = "Mercadores raros chegaram à vila com itens exclusivos!"
				1: # LOW_RISK
					if WorldState != null and WorldState.tem_efeito_temporario("patrulha_bandidos_suprimida"):
						ev.type = WorldEventDataScript.EventType.MERCHANT
						ev.title = "Caravana Pacífica de Mercadores"
						ev.description = "A estrada está segura graças às suas ações recentes contra os bandidos."
					else:
						ev.type = WorldEventDataScript.EventType.BANDIT_ATTACK
						ev.title = "Emboscada de Salteadores da Estrada"
						ev.description = "Um comboio está sendo atacado por ladrões!"
				2: # MEDIUM_RISK
					ev.type = WorldEventDataScript.EventType.AMBUSH
					ev.title = "Matilha de Lobos da Floresta"
					ev.description = "Feras famintas cercaram a clareira!"
				3: # HIGH_RISK
					ev.type = WorldEventDataScript.EventType.RARE_MONSTER
					ev.title = "Guardião Ancestral Desperto"
					ev.description = "Uma criatura lendária de aura densa emergiu das ruínas!"
				4: # DANGER
					ev.type = WorldEventDataScript.EventType.WORLD_EVENT
					ev.title = "Erupção de Miasma & Feras Sombrias"
					ev.description = "A névoa corrosiva intensificou-se drasticamente!"

				
		active_events.append(ev)
		last_event_pos = spawn_pos
		distance_since_last_event = 0.0
		timer_event_cooldown = rng.randf_range(config.event_min_interval_sec, config.event_max_interval_sec)
		target_next_event_distance = rng.randf_range(600.0, 1100.0)
		print("[ContentDirector] Evento dinâmico iniciado: %s em %s" % [ev.title, ev.spawn_pos])


func _verificar_populacao_pve_local(player_pos: Vector2) -> void:
	var profile = config.zone_profiles.get(current_risk, {})
	var pve_density = profile.get("pve_density", 0.0)
	
	if pve_density <= 0.0:
		return # Zona Segura tem ZERO monstros
		
	var limite_zona = int(config.max_active_enemies * pve_density)
	if active_enemies.size() < limite_zona and rng.randf() < 0.15:
		var spawn_pos = _calcular_posicao_spawn_periferica(player_pos)
		var enemy_info = {
			"id": "mob_%d" % rng.randi(),
			"pos": spawn_pos,
			"risk": current_risk,
			"is_elite": (rng.randf() <= config.elite_spawn_chance)
		}
		active_enemies.append(enemy_info)


func _calcular_posicao_spawn_periferica(center: Vector2) -> Vector2:
	var angulo = rng.randf_range(0, TAU)
	var raio = rng.randf_range(config.spawn_radius_min, config.spawn_radius_max)
	return center + Vector2(cos(angulo), sin(angulo)) * raio


# ============================================================
# 3. RECICLAGEM E DESPAWN (ANTI-LEAK)
# ============================================================
func _gerenciar_despawn_e_ciclo_de_vida(player_pos: Vector2) -> void:
	# Limpar Inimigos distantes
	for i in range(active_enemies.size() - 1, -1, -1):
		var e = active_enemies[i]
		if player_pos.distance_to(e["pos"]) > config.despawn_radius:
			active_enemies.remove_at(i)
			
	# Limpar Encontros distantes
	for i in range(active_encounters.size() - 1, -1, -1):
		var enc = active_encounters[i] as Resource
		if enc and player_pos.distance_to(enc.pos) > config.despawn_radius:
			active_encounters.remove_at(i)
			
	# Limpar Eventos distantes ou expirados
	for i in range(active_events.size() - 1, -1, -1):
		var ev = active_events[i] as Resource
		if ev and player_pos.distance_to(ev.spawn_pos) > config.despawn_radius:
			active_events.remove_at(i)


# ============================================================
# 4. INICIALIZAÇÃO DE POIS E POPULAÇÃO BASE
# ============================================================
func _inicializar_pois_padrao() -> void:
	registered_pois = [
		{"id": "poi_vila_praca", "name": "Praça de Padokia", "pos": Vector2(1200, 4080), "type": "TOWN"},
		{"id": "poi_ponte_rio", "name": "Grande Ponte de Pedra", "pos": Vector2(2880, 4080), "type": "BRIDGE"},
		{"id": "poi_arvore_milenar", "name": "Árvore Milenar dos Espíritos", "pos": Vector2(4000, 3200), "type": "LANDMARK"},
		{"id": "poi_caverna_hermitao", "name": "Caverna do Ermitão (Nen KO)", "pos": Vector2(3600, 800), "type": "SECRET"},
		{"id": "poi_ravina_ten", "name": "Ravina da Névoa (Nen TEN)", "pos": Vector2(6400, 6400), "type": "HAZARD"},
		{"id": "poi_ruinas_zaban", "name": "Ruínas de Zaban (Dungeon)", "pos": Vector2(6880, 1440), "type": "DUNGEON"}
	]


func _inicializar_populacao_base() -> void:
	# NPCs urbanos fixos na vila com rotinas
	active_npcs = [
		{"id": "npc_mestre_wing", "name": "Mestre Wing", "pos": Vector2(1100, 3800), "role": "DOJO_MASTER"},
		{"id": "npc_ferreiro_padokia", "name": "Ferreiro Duran", "pos": Vector2(1350, 3950), "role": "BLACKSMITH"},
		{"id": "npc_mercador_zaban", "name": "Mercador Zael", "pos": Vector2(1200, 4150), "role": "MERCHANT"},
		{"id": "npc_cacador_novato", "name": "Explorador Ron", "pos": Vector2(1050, 4200), "role": "HUNTER_NPC"},
		{"id": "npc_ancio_erudito", "name": "Ancião Garen", "pos": Vector2(1400, 3750), "role": "SCHOLAR"}
	]


# ============================================================
# 5. MÉTRICAS E DEBUG
# ============================================================
func get_debug_metrics() -> Dictionary:
	var avg_dist: float = 0.0
	if not encounter_distances_history.is_empty():
		var sum: float = 0.0
		for d in encounter_distances_history: sum += d
		avg_dist = sum / encounter_distances_history.size()
	else:
		avg_dist = distance_since_last_encounter
		
	var dist_next = maxf(0.0, target_next_event_distance - distance_since_last_event)
	
	return {
		"zone_name": current_zone_name,
		"risk_level": current_risk,
		"active_npcs": active_npcs.size(),
		"active_enemies": active_enemies.size(),
		"active_events": active_events.size(),
		"active_encounters": active_encounters.size(),
		"registered_pois": registered_pois.size(),
		"distance_travelled": total_distance_travelled,
		"distance_since_last_event": distance_since_last_event,
		"average_encounter_distance": avg_dist,
		"next_event_distance_estimate": dist_next
	}


# ============================================================
# 6. CONTENT DIRECTOR INSPECTOR & SIMULAÇÃO DE CANDIDATOS
# ============================================================
func evaluate_event_candidates_at_pos(inspect_pos: Vector2) -> Array[Dictionary]:
	var evaluated_risk: int = 0
	var evaluated_zone_name: String = "Vila de Padokia (SAFE)"
	
	if inspect_pos.x < 2200 and inspect_pos.y >= 2800:
		evaluated_risk = 0
		evaluated_zone_name = "Vila de Padokia (SAFE)"
	elif inspect_pos.x >= 2200 and inspect_pos.x < 3600 and inspect_pos.y >= 2000 and inspect_pos.y < 4200:
		evaluated_risk = 1
		evaluated_zone_name = "Estrada Real (LOW RISK)"
	elif inspect_pos.x >= 3600 and inspect_pos.x < 5600 and inspect_pos.y < 5000:
		evaluated_risk = 2
		evaluated_zone_name = "Floresta dos Vestígios (MEDIUM RISK)"
	elif inspect_pos.x >= 5800 and inspect_pos.y <= 2600:
		evaluated_risk = 3
		evaluated_zone_name = "Ruínas de Zaban (HIGH RISK)"
	elif inspect_pos.x >= 5200 and inspect_pos.y >= 5200:
		evaluated_risk = 4
		evaluated_zone_name = "Ravina da Névoa (DANGER)"
	else:
		evaluated_risk = 1
		evaluated_zone_name = "Campos Exteriores (LOW RISK)"

	var e_noite: bool = (TimeManager != null and TimeManager.fase_solar == TimeManager.FaseSolar.NIGHT)
	var nen_lvl: int = int(PlayerData.attributes.get("nivel_nen", 0)) if PlayerData else 0
	var player_lvl: int = int(PlayerData.attributes.get("nivel", 1)) if PlayerData else 1
	
	var all_templates = [
		{
			"id": "ev_merchant_fair",
			"title": "Feira Especial de Mercadores de Yorknew",
			"type": "MERCHANT",
			"min_risk": 0,
			"max_risk": 0,
			"req_night": false,
			"req_nen_lvl": 0,
			"chance": 0.40
		},
		{
			"id": "ev_bandit_road",
			"title": "Emboscada de Salteadores da Estrada",
			"type": "BANDIT_ATTACK",
			"min_risk": 1,
			"max_risk": 2,
			"req_night": false,
			"req_nen_lvl": 0,
			"chance": 0.35
		},
		{
			"id": "ev_wolf_pack",
			"title": "Matilha de Lobos da Floresta",
			"type": "AMBUSH",
			"min_risk": 2,
			"max_risk": 3,
			"req_night": false,
			"req_nen_lvl": 0,
			"chance": 0.50
		},
		{
			"id": "ev_nen_wanderer",
			"title": "Duelo Tático: Andarilho de Nen",
			"type": "HUNTER_FIGHT",
			"min_risk": 2,
			"max_risk": 4,
			"req_night": false,
			"req_nen_lvl": 2,
			"chance": 0.40
		},
		{
			"id": "ev_night_chimera",
			"title": "Fera Quimera Noturna (+25% XP)",
			"type": "RARE_MONSTER",
			"min_risk": 2,
			"max_risk": 4,
			"req_night": true,
			"req_nen_lvl": 1,
			"chance": 0.45
		},
		{
			"id": "ev_ancient_guardian",
			"title": "Guardião Ancestral Desperto",
			"type": "RARE_MONSTER",
			"min_risk": 3,
			"max_risk": 4,
			"req_night": false,
			"req_nen_lvl": 1,
			"chance": 0.30
		},
		{
			"id": "ev_miasma_eruption",
			"title": "Erupção de Miasma & Feras Sombrias",
			"type": "WORLD_EVENT",
			"min_risk": 4,
			"max_risk": 4,
			"req_night": false,
			"req_nen_lvl": 2,
			"chance": 0.60
		},
		{
			"id": "ev_medical_caravan",
			"title": "Caravana Médica Itinerante",
			"type": "WANDERING_MERCHANT",
			"min_risk": 1,
			"max_risk": 4,
			"req_night": false,
			"req_nen_lvl": 0,
			"chance": 0.60
		}
	]
	
	var results: Array[Dictionary] = []
	
	for t in all_templates:
		var is_accepted = true
		var rejection_reasons: Array[String] = []
		
		# 1. Checagem de Zona de Risco
		if evaluated_risk < t["min_risk"] or evaluated_risk > t["max_risk"]:
			is_accepted = false
			rejection_reasons.append("Zona incompatível (Requer risco %d..%d, atual: %d - %s)" % [t["min_risk"], t["max_risk"], evaluated_risk, evaluated_zone_name])
			
		# 2. Checagem de Nível de Nen
		if nen_lvl < t["req_nen_lvl"]:
			is_accepted = false
			rejection_reasons.append("Nível de Nen insuficiente (Requer Nen Lv %d, jogador tem Lv %d)" % [t["req_nen_lvl"], nen_lvl])
			
		# 3. Checagem de Ciclo Solar (Dia / Noite)
		if t["req_night"] and not e_noite:
			is_accepted = false
			rejection_reasons.append("Condição de horário: Requer NOITE (Fase atual: %s)" % (TimeManager.get_phase_name() if TimeManager else "DAY"))
			
		# 4. Checagem de Cooldown de Eventos
		if timer_event_cooldown > 0.0:
			rejection_reasons.append("Cooldown de eventos ativo (%.1fs restantes)" % timer_event_cooldown)
			# Cooldown afeta a ativação real no momento
			
		# 5. Checagem de Anti-Spam de Distância
		var dist_to_last = inspect_pos.distance_to(last_event_pos)
		if dist_to_last < config.minimum_distance_between_events:
			rejection_reasons.append("Distância anti-spam violada (%.0f px < %.0f px mínimo)" % [dist_to_last, config.minimum_distance_between_events])
			
		# 6. Limite de capacidade ativa
		if active_events.size() >= config.max_active_events:
			rejection_reasons.append("Limite máximo de eventos atingido (%d/%d ativos)" % [active_events.size(), config.max_active_events])
			
		results.append({
			"id": t["id"],
			"title": t["title"],
			"type": t["type"],
			"status": "ACCEPTED" if (is_accepted and rejection_reasons.is_empty()) else "REJECTED",
			"is_accepted": (is_accepted and rejection_reasons.is_empty()),
			"rejection_reasons": rejection_reasons,
			"primary_reason": "Pronto para spawn (Condições satisfeitas)" if rejection_reasons.is_empty() else rejection_reasons[0],
			"weight_chance": t["chance"],
			"target_zone": evaluated_zone_name,
			"target_risk": evaluated_risk
		})
		
	return results

