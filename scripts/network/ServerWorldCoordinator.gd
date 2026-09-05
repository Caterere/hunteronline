class_name ServerWorldCoordinator
extends RefCounted

# ============================================================
# HUNTER ONLINE — SERVER WORLD COORDINATOR (FASE K-LAN)
# ============================================================
#
# Autoridade Central de Simulação do Mundo no Servidor Dedicado:
# - Gerencia o loop de simulação em tick_rate configurável (ex: 20 TPS)
# - Processa intenções de input e simula movimento dos caçadores
# - Executa IA de inimigos e chefes exclusivamente no servidor
# - Valida combate, distribui dano, knockback e mortes
# - Separa Quests Pessoais de Quests de Party
# - Coordena eventos mundiais e dungeons cooperativas
# ============================================================

const NetworkEntitySnapshotScript = preload("res://scripts/network/NetworkEntitySnapshot.gd")

var is_active: bool = false
var tick_rate: int = 20
var tick_delta: float = 0.05
var current_tick: int = 0
var current_map_path: String = "res://world/lobby.tscn"

# peer_id -> PlayerServerEntity: { "peer_id", "char_id", "name", "pos", "vel", "facing", "hp", "hp_max", "aura", "aura_max", "nen_tech", "input_intent", "level" }
var players: Dictionary = {}

# enemy_net_id -> EnemyServerEntity: { "net_id", "enemy_id", "name", "pos", "vel", "hp", "hp_max", "def", "dmg", "target_peer", "ai_state", "is_boss" }
var enemies: Dictionary = {}
var _next_enemy_net_id: int = 2000

# Eventos ativos no servidor
var active_world_events: Array[Dictionary] = []

signal snapshot_ready(snapshot_data: Dictionary)
signal entity_damaged(net_id: int, final_damage: int, current_hp: int)
signal entity_died(net_id: int, killer_peer_id: int, rewards: Dictionary)


func _init(p_tick_rate: int = 20, p_map_path: String = "res://world/lobby.tscn") -> void:
	tick_rate = max(10, p_tick_rate)
	tick_delta = 1.0 / float(tick_rate)
	current_map_path = p_map_path


func start_coordinator() -> void:
	is_active = true
	current_tick = 0
	players.clear()
	enemies.clear()
	active_world_events.clear()
	print("[ServerWorldCoordinator] 🌍 Simulação autoritativa do servidor iniciada a %d TPS." % tick_rate)


func stop_coordinator() -> void:
	is_active = false
	players.clear()
	enemies.clear()


# ============================================================
# GERENCIAMENTO DE JOGADORES NO SERVIDOR
# ============================================================

func register_player(peer_id: int, char_data: Dictionary, spawn_pos: Vector2 = Vector2.ZERO) -> void:
	var char_id = str(char_data.get("character_id", "hunter_%d" % peer_id))
	var p_name = str(char_data.get("name", "Hunter_%d" % peer_id))
	var attrs = char_data.get("attributes", {})

	var p_entity: Dictionary = {
		"peer_id": peer_id,
		"character_id": char_id,
		"name": p_name,
		"position": spawn_pos,
		"velocity": Vector2.ZERO,
		"facing": Vector2.DOWN,
		"hp": int(attrs.get("vida", 100)),
		"hp_max": int(attrs.get("vida_max", 100)),
		"aura": float(attrs.get("aura", 100.0)),
		"aura_max": float(attrs.get("aura_max", 100.0)),
		"level": int(attrs.get("nivel", 1)),
		"nen_tech": str(char_data.get("tecnica_nen_ativa", "TEN")),
		"input_intent": Vector2.ZERO,
		"last_input_ts": Time.get_ticks_msec()
	}
	players[peer_id] = p_entity
	print("[ServerWorldCoordinator] 👤 Caçador registrado na simulação: %s (Peer %d)" % [p_name, peer_id])


func unregister_player(peer_id: int) -> Dictionary:
	if players.has(peer_id):
		var removed = players[peer_id]
		players.erase(peer_id)
		return removed
	return {}


func update_player_intent(peer_id: int, move_dir: Vector2, facing: Vector2, nen_tech: String = "") -> void:
	if not players.has(peer_id):
		return

	var p = players[peer_id]
	p["input_intent"] = move_dir.limit_length(1.0)
	if facing != Vector2.ZERO:
		p["facing"] = facing
	if not nen_tech.is_empty():
		p["nen_tech"] = nen_tech
	p["last_input_ts"] = Time.get_ticks_msec()


# ============================================================
# GERENCIAMENTO DE INIMIGOS E BOSSES NO SERVIDOR
# ============================================================

func spawn_enemy(
	enemy_id: StringName,
	enemy_name: String,
	spawn_pos: Vector2,
	max_hp: int = 200,
	damage: int = 25,
	defense: int = 15,
	is_boss: bool = false
) -> int:
	var nid: int = _next_enemy_net_id
	_next_enemy_net_id += 1

	var e_entity: Dictionary = {
		"net_id": nid,
		"enemy_id": str(enemy_id),
		"name": enemy_name,
		"position": spawn_pos,
		"velocity": Vector2.ZERO,
		"hp": max_hp,
		"hp_max": max_hp,
		"damage": damage,
		"defense": defense,
		"is_boss": is_boss,
		"target_peer": -1,
		"ai_state": "PATROL",
		"state_timer": 0.0,
		"threat_table": {} # peer_id -> float (threat)
	}
	enemies[nid] = e_entity
	return nid


# ============================================================
# LOOP DE SIMULAÇÃO (SERVER TICK)
# ============================================================

func tick(delta: float) -> void:
	if not is_active:
		return

	current_tick += 1

	# 1. Simular Movimento dos Jogadores
	for pid in players.keys():
		var p = players[pid]
		var intent: Vector2 = p["input_intent"]
		var speed: float = 160.0 # Velocidade canônica de base
		p["velocity"] = intent * speed
		p["position"] += p["velocity"] * delta

	# 2. Simular IA de Inimigos
	for eid in enemies.keys():
		var e = enemies[eid]
		_simulate_enemy_ai(e, delta)

	# 3. Gerar Snapshot do Mundo
	var snapshot = build_world_snapshot()
	snapshot_ready.emit(snapshot)


func _simulate_enemy_ai(e: Dictionary, delta: float) -> void:
	if e["hp"] <= 0:
		return

	# Selecionar alvo com maior ameaça ou jogador mais próximo
	var target_pos: Vector2 = Vector2.ZERO
	var target_peer: int = -1
	var min_dist: float = 999999.0

	# Avaliar threat table
	var threat_table: Dictionary = e["threat_table"]
	var max_threat: float = -1.0

	for pid in players.keys():
		var p = players[pid]
		var dist = (p["position"] as Vector2).distance_to(e["position"] as Vector2)
		var threat = float(threat_table.get(pid, 0.0))

		if threat > max_threat and threat > 0.0:
			max_threat = threat
			target_peer = pid
			target_pos = p["position"]
		elif target_peer == -1 and dist < 250.0 and dist < min_dist:
			min_dist = dist
			target_peer = pid
			target_pos = p["position"]

	e["target_peer"] = target_peer

	# Comportamento de perseguição
	if target_peer != -1:
		var dir = (target_pos - (e["position"] as Vector2)).normalized()
		var spd = 110.0 if not e["is_boss"] else 95.0
		e["velocity"] = dir * spd
		e["position"] += e["velocity"] * delta
		e["ai_state"] = "CHASE"
	else:
		e["velocity"] = Vector2.ZERO
		e["ai_state"] = "IDLE"


# ============================================================
# COMBATE AUTORITATIVO NO SERVIDOR
# ============================================================

func apply_player_attack(
	attacker_peer: int,
	attack_origin: Vector2,
	attack_dir: Vector2,
	base_dmg: int,
	reach: float = 45.0,
	is_heavy: bool = false
) -> Array[Dictionary]:
	var hits: Array[Dictionary] = []
	if not players.has(attacker_peer):
		return hits

	var atk_pos = (players[attacker_peer]["position"] as Vector2)
	var final_dmg_calc = base_dmg * (2 if is_heavy else 1)

	for eid in enemies.keys():
		var e = enemies[eid]
		if e["hp"] <= 0:
			continue

		var e_pos: Vector2 = e["position"]
		var dist = atk_pos.distance_to(e_pos)
		if dist <= reach:
			# Cálculo de mitigação via defesa
			var def_factor = 100.0 / (100.0 + max(0.0, float(e["defense"])))
			var dealt = max(1, int(round(float(final_dmg_calc) * def_factor)))

			e["hp"] = max(0, e["hp"] - dealt)

			# Adicionar ameaça (threat) ao atacante
			var tt: Dictionary = e["threat_table"]
			tt[attacker_peer] = float(tt.get(attacker_peer, 0.0)) + float(dealt)

			var hit_info: Dictionary = {
				"net_id": eid,
				"damage": dealt,
				"hp_remaining": e["hp"],
				"is_dead": e["hp"] <= 0
			}
			hits.append(hit_info)
			entity_damaged.emit(eid, dealt, e["hp"])

			if e["hp"] <= 0:
				var rewards: Dictionary = {
					"xp": 500 if not e["is_boss"] else 5000,
					"gold": 1000 if not e["is_boss"] else 15000,
					"enemy_id": e["enemy_id"]
				}
				entity_died.emit(eid, attacker_peer, rewards)

	return hits


# ============================================================
# SERIALIZAÇÃO DE SNAPSHOT
# ============================================================

func build_world_snapshot() -> Dictionary:
	var p_snaps: Array = []
	for pid in players.keys():
		var p = players[pid]
		p_snaps.append({
			"id": pid,
			"px": snappedf(p["position"].x, 0.1),
			"py": snappedf(p["position"].y, 0.1),
			"vx": snappedf(p["velocity"].x, 0.1),
			"vy": snappedf(p["velocity"].y, 0.1),
			"fx": snappedf(p["facing"].x, 0.1),
			"fy": snappedf(p["facing"].y, 0.1),
			"hp": p["hp"],
			"hp_max": p["hp_max"],
			"aura": p["aura"],
			"nen": p["nen_tech"]
		})

	var e_snaps: Array = []
	for eid in enemies.keys():
		var e = enemies[eid]
		if e["hp"] > 0:
			e_snaps.append({
				"id": eid,
				"name": e["name"],
				"px": snappedf(e["position"].x, 0.1),
				"py": snappedf(e["position"].y, 0.1),
				"hp": e["hp"],
				"hp_max": e["hp_max"],
				"state": e["ai_state"],
				"boss": e["is_boss"]
			})

	return {
		"tick": current_tick,
		"ts": Time.get_ticks_msec(),
		"players": p_snaps,
		"enemies": e_snaps
	}
