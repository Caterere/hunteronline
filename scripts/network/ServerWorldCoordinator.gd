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
var _tick_accumulator: float = 0.0
# peer_id -> { "players": {id: fingerprint}, "enemies": {id: fingerprint} }
var _last_interest_state: Dictionary = {}
var interest_radius_default: float = 900.0
var use_snapshot_delta: bool = true

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
signal player_damaged(peer_id: int, damage: int, source_net_id: int, hp_remaining: int, knockback_dir: Vector2)
signal player_died(peer_id: int, source_net_id: int)
signal player_respawned(peer_id: int, spawn_pos: Vector2, hp: int, aura: float)

const RESPAWN_DELAY_SEC: float = 3.5
const DEFAULT_SPAWN_POS := Vector2(100, 100)


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
	_last_interest_state.clear()
	print("[ServerWorldCoordinator] 🌍 Simulação autoritativa do servidor iniciada a %d TPS." % tick_rate)


func stop_coordinator() -> void:
	is_active = false
	players.clear()
	enemies.clear()
	_last_interest_state.clear()


# ============================================================
# GERENCIAMENTO DE JOGADORES NO SERVIDOR
# ============================================================

func register_player(peer_id: int, char_data: Dictionary, spawn_pos: Vector2 = Vector2.ZERO) -> void:
	var char_id = str(char_data.get("character_id", "hunter_%d" % peer_id))
	var p_name = str(char_data.get("name", char_data.get("nickname", "Hunter_%d" % peer_id)))
	if p_name.is_empty():
		p_name = "Hunter_%d" % peer_id
	var attrs = char_data.get("attributes", {})
	if not (attrs is Dictionary):
		attrs = {}

	var p_entity: Dictionary = {
		"peer_id": peer_id,
		"character_id": char_id,
		"name": p_name,
		"position": spawn_pos,
		"spawn_pos": spawn_pos,
		"velocity": Vector2.ZERO,
		"facing": Vector2.DOWN,
		"hp": int(attrs.get("vida", attrs.get("hp", 100))),
		"hp_max": int(attrs.get("vida_max", attrs.get("hp_max", 100))),
		"aura": float(attrs.get("aura", 100.0)),
		"aura_max": float(attrs.get("aura_max", 100.0)),
		"level": int(attrs.get("nivel", attrs.get("level", 1))),
		"defesa": float(attrs.get("defesa", attrs.get("defense", 10.0))),
		"nen_tech": str(char_data.get("tecnica_nen_ativa", "TEN")),
		"input_intent": Vector2.ZERO,
		"last_input_ts": Time.get_ticks_msec(),
		"is_dead": false,
		"respawn_timer": 0.0,
		"invuln_timer": 0.0
	}
	players[peer_id] = p_entity
	print("[ServerWorldCoordinator] 👤 Caçador registrado na simulação: %s (Peer %d)" % [p_name, peer_id])


func get_player_position(peer_id: int) -> Vector2:
	if players.has(peer_id):
		return players[peer_id]["position"] as Vector2
	return Vector2.ZERO


func get_player_entity(peer_id: int) -> Dictionary:
	return players.get(peer_id, {})


func unregister_player(peer_id: int) -> Dictionary:
	clear_interest_state(peer_id)
	if players.has(peer_id):
		var removed = players[peer_id]
		players.erase(peer_id)
		return removed
	return {}


func update_player_intent(peer_id: int, move_dir: Vector2, facing: Vector2, nen_tech: String = "") -> void:
	if not players.has(peer_id):
		return

	var p = players[peer_id]
	if bool(p.get("is_dead", false)):
		p["input_intent"] = Vector2.ZERO
		return
	p["input_intent"] = move_dir.limit_length(1.0)
	if facing != Vector2.ZERO:
		p["facing"] = facing
	if not nen_tech.is_empty():
		p["nen_tech"] = nen_tech
	p["last_input_ts"] = Time.get_ticks_msec()


func request_respawn(peer_id: int) -> bool:
	if not players.has(peer_id):
		return false
	var p = players[peer_id]
	if not bool(p.get("is_dead", false)):
		return false
	# Permite respawn antecipado se já passou 1s (cliente clicou Renascer)
	if float(p.get("respawn_timer", 0.0)) > (RESPAWN_DELAY_SEC - 1.0):
		p["respawn_timer"] = 0.05
	return true


func force_respawn_now(peer_id: int) -> void:
	if not players.has(peer_id):
		return
	var p = players[peer_id]
	if not bool(p.get("is_dead", false)):
		return
	_respawn_player(peer_id)


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
		"attack_cd": 0.0,
		"attack_range": 38.0 if not is_boss else 48.0,
		"attack_interval": 0.85 if not is_boss else 1.1,
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

	_tick_accumulator += delta
	# Evita spiral of death se o frame travar
	var max_catchup: int = 5
	var steps: int = 0
	while _tick_accumulator >= tick_delta and steps < max_catchup:
		_tick_accumulator -= tick_delta
		_simulate_fixed_tick(tick_delta)
		steps += 1


func _simulate_fixed_tick(dt: float) -> void:
	current_tick += 1

	# 1. Simular Movimento / respawn dos Jogadores
	for pid in players.keys():
		var p = players[pid]
		p["invuln_timer"] = max(0.0, float(p.get("invuln_timer", 0.0)) - dt)
		if bool(p.get("is_dead", false)):
			p["velocity"] = Vector2.ZERO
			p["input_intent"] = Vector2.ZERO
			p["respawn_timer"] = max(0.0, float(p.get("respawn_timer", 0.0)) - dt)
			if float(p.get("respawn_timer", 0.0)) <= 0.0:
				_respawn_player(pid)
			continue
		var intent: Vector2 = p["input_intent"]
		var speed: float = 160.0 # Velocidade canônica de base
		p["velocity"] = intent * speed
		p["position"] += p["velocity"] * dt

	# 2. Simular IA de Inimigos
	for eid in enemies.keys():
		var e = enemies[eid]
		_simulate_enemy_ai(e, dt)

	# 3. Gerar Snapshot do Mundo
	var snapshot = build_world_snapshot()
	snapshot_ready.emit(snapshot)


func _simulate_enemy_ai(e: Dictionary, delta: float) -> void:
	if e["hp"] <= 0:
		return

	e["attack_cd"] = max(0.0, float(e.get("attack_cd", 0.0)) - delta)

	# Selecionar alvo com maior ameaça ou jogador mais próximo
	var target_pos: Vector2 = Vector2.ZERO
	var target_peer: int = -1
	var min_dist: float = 999999.0

	# Avaliar threat table
	var threat_table: Dictionary = e["threat_table"]
	var max_threat: float = -1.0

	for pid in players.keys():
		var p = players[pid]
		if int(p.get("hp", 0)) <= 0:
			continue
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

	# Comportamento de perseguição / ataque
	if target_peer != -1:
		var e_pos: Vector2 = e["position"] as Vector2
		var dist_to_target: float = e_pos.distance_to(target_pos)
		var attack_range: float = float(e.get("attack_range", 38.0))
		if dist_to_target <= attack_range:
			e["velocity"] = Vector2.ZERO
			e["ai_state"] = "ATTACK"
			if float(e.get("attack_cd", 0.0)) <= 0.0:
				_aplicar_dano_em_jogador(target_peer, int(e.get("net_id", 0)), int(e.get("damage", 15)), e_pos)
				e["attack_cd"] = float(e.get("attack_interval", 0.85))
		else:
			var dir = (target_pos - e_pos).normalized()
			var spd = 110.0 if not e["is_boss"] else 95.0
			e["velocity"] = dir * spd
			e["position"] += e["velocity"] * delta
			e["ai_state"] = "CHASE"
	else:
		e["velocity"] = Vector2.ZERO
		e["ai_state"] = "IDLE"


func _aplicar_dano_em_jogador(peer_id: int, source_net_id: int, raw_damage: int, from_pos: Vector2) -> void:
	if not players.has(peer_id):
		return
	var p = players[peer_id]
	if bool(p.get("is_dead", false)):
		return
	if float(p.get("invuln_timer", 0.0)) > 0.0:
		return
	var hp: int = int(p.get("hp", 0))
	if hp <= 0:
		return

	var dealt: int = _calcular_dano_sofrido_servidor(p, raw_damage)
	hp = max(0, hp - dealt)
	p["hp"] = hp
	var kb_dir: Vector2 = ((p["position"] as Vector2) - from_pos).normalized()
	if kb_dir == Vector2.ZERO:
		kb_dir = Vector2.RIGHT
	player_damaged.emit(peer_id, dealt, source_net_id, hp, kb_dir)

	if hp <= 0:
		_matar_jogador(peer_id, source_net_id)


## Mitigação server-side aproximando TEN/KEN/REN/ZETSU + defesa/nível.
func _calcular_dano_sofrido_servidor(p: Dictionary, raw_damage: int) -> int:
	var dano: float = float(maxi(1, raw_damage))
	var tech: String = str(p.get("nen_tech", "")).to_upper()
	var aura: float = float(p.get("aura", 0.0))
	var aura_cost: float = 0.0
	var fator_nen: float = 1.0

	match tech:
		"TEN":
			fator_nen = 0.82
			aura_cost = 4.0
		"KEN":
			fator_nen = 0.68
			aura_cost = 10.0
		"REN":
			fator_nen = 0.92
			aura_cost = 2.0
		"GYO":
			fator_nen = 0.90
			aura_cost = 3.0
		"RYU":
			fator_nen = 0.78
			aura_cost = 6.0
		"ZETSU":
			fator_nen = 1.35 # vulnerável sem aura
			aura_cost = 0.0
		_:
			fator_nen = 1.0
			aura_cost = 0.0

	# Sem aura suficiente, perde o bônus defensivo de Nen (exceto Zetsu que já é pior)
	if aura_cost > 0.0:
		if aura >= aura_cost:
			p["aura"] = max(0.0, aura - aura_cost)
			dano *= fator_nen
		else:
			# Aura insuficiente: mitigação parcial
			dano *= lerpf(1.0, fator_nen, clampf(aura / aura_cost, 0.0, 1.0))
			p["aura"] = 0.0
	else:
		dano *= fator_nen

	var defesa: float = float(p.get("defesa", 10.0))
	var nivel: int = int(p.get("level", 1))
	var fator_def: float = 1.0
	if PowerScale != null and PowerScale.has_method("calcular_fator_defensivo_por_nivel"):
		fator_def = PowerScale.calcular_fator_defensivo_por_nivel(defesa, nivel)
	else:
		fator_def = 100.0 / (100.0 + max(0.0, defesa))

	return max(1, int(round(dano * fator_def)))


func _matar_jogador(peer_id: int, source_net_id: int) -> void:
	if not players.has(peer_id):
		return
	var p = players[peer_id]
	p["is_dead"] = true
	p["hp"] = 0
	p["velocity"] = Vector2.ZERO
	p["input_intent"] = Vector2.ZERO
	p["respawn_timer"] = RESPAWN_DELAY_SEC
	player_died.emit(peer_id, source_net_id)
	print("[ServerWorldCoordinator] ☠️ Peer %d morreu (src %d). Respawn em %.1fs" % [peer_id, source_net_id, RESPAWN_DELAY_SEC])


func _respawn_player(peer_id: int) -> void:
	if not players.has(peer_id):
		return
	var p = players[peer_id]
	var spawn: Vector2 = p.get("spawn_pos", DEFAULT_SPAWN_POS) as Vector2
	p["is_dead"] = false
	p["respawn_timer"] = 0.0
	p["position"] = spawn
	p["velocity"] = Vector2.ZERO
	p["input_intent"] = Vector2.ZERO
	p["hp"] = int(p.get("hp_max", 100))
	p["aura"] = float(p.get("aura_max", 100.0))
	p["invuln_timer"] = 1.5
	player_respawned.emit(peer_id, spawn, int(p["hp"]), float(p["aura"]))
	print("[ServerWorldCoordinator] ✨ Peer %d respawnou em %s" % [peer_id, str(spawn)])


func build_kill_rewards(enemy: Dictionary) -> Dictionary:
	var is_boss: bool = bool(enemy.get("is_boss", false))
	var level_proxy: int = 8 if not is_boss else 25
	var jenny: int = 0
	if Economy != null and Economy.has_method("calcular_drop_jenny_inimigo"):
		jenny = Economy.calcular_drop_jenny_inimigo(level_proxy)
	else:
		jenny = 80 if not is_boss else 600
	return {
		"xp": 120 if not is_boss else 900,
		"xp_nen": 25 if not is_boss else 180,
		"gold": jenny,
		"enemy_id": str(enemy.get("enemy_id", "")),
		"enemy_name": str(enemy.get("name", "Beast")),
		"is_boss": is_boss
	}


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
	if bool(players[attacker_peer].get("is_dead", false)):
		return hits

	var atk_pos = (players[attacker_peer]["position"] as Vector2)
	# Soft validation: se o cliente reportou origem absurda, usa posição autoritativa
	if attack_origin != Vector2.ZERO and atk_pos.distance_to(attack_origin) <= 96.0:
		atk_pos = atk_pos.lerp(attack_origin, 0.35)
	var facing: Vector2 = attack_dir
	if facing == Vector2.ZERO:
		facing = players[attacker_peer]["facing"] as Vector2
	facing = facing.normalized() if facing != Vector2.ZERO else Vector2.RIGHT
	var final_dmg_calc = base_dmg * (2 if is_heavy else 1)

	for eid in enemies.keys():
		var e = enemies[eid]
		if e["hp"] <= 0:
			continue

		var e_pos: Vector2 = e["position"]
		var dist = atk_pos.distance_to(e_pos)
		if dist > reach:
			continue
		# Cone frontal ~120° (dot >= -0.5) — evita acertar costas sem facing
		var to_enemy: Vector2 = (e_pos - atk_pos).normalized()
		if to_enemy != Vector2.ZERO and facing.dot(to_enemy) < -0.5:
			continue

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
			"is_dead": e["hp"] <= 0,
			"enemy_id": e["enemy_id"],
			"px": snappedf(e_pos.x, 0.1),
			"py": snappedf(e_pos.y, 0.1)
		}
		hits.append(hit_info)
		entity_damaged.emit(eid, dealt, e["hp"])

		if e["hp"] <= 0:
			var rewards: Dictionary = build_kill_rewards(e)
			entity_died.emit(eid, attacker_peer, rewards)

	return hits


# ============================================================
# SERIALIZAÇÃO DE SNAPSHOT
# ============================================================

func build_world_snapshot() -> Dictionary:
	var p_snaps: Array = []
	for pid in players.keys():
		p_snaps.append(_serialize_player(pid, players[pid]))

	var e_snaps: Array = []
	for eid in enemies.keys():
		var e = enemies[eid]
		if e["hp"] > 0:
			e_snaps.append(_serialize_enemy(eid, e))

	return {
		"tick": current_tick,
		"ts": Time.get_ticks_msec(),
		"full": true,
		"players": p_snaps,
		"enemies": e_snaps,
		"removed_players": [],
		"removed_enemies": []
	}


func _serialize_player(pid: int, p: Dictionary) -> Dictionary:
	return {
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
		"nen": p["nen_tech"],
		"dead": bool(p.get("is_dead", false))
	}


func _serialize_enemy(eid: int, e: Dictionary) -> Dictionary:
	return {
		"id": eid,
		"enemy_id": e["enemy_id"],
		"name": e["name"],
		"px": snappedf(e["position"].x, 0.1),
		"py": snappedf(e["position"].y, 0.1),
		"vx": snappedf(e["velocity"].x, 0.1),
		"vy": snappedf(e["velocity"].y, 0.1),
		"hp": e["hp"],
		"hp_max": e["hp_max"],
		"state": e["ai_state"],
		"boss": e["is_boss"]
	}


func _fingerprint_entity(data: Dictionary) -> String:
	return "%s|%s|%s|%s|%s|%s|%s" % [
		str(data.get("px", 0)),
		str(data.get("py", 0)),
		str(data.get("vx", 0)),
		str(data.get("vy", 0)),
		str(data.get("hp", 0)),
		str(data.get("nen", data.get("state", ""))),
		str(data.get("dead", false))
	]


## Snapshot filtrado por Area-of-Interest + opcionalmente delta vs último envio do peer.
func build_interest_snapshot(for_peer_id: int, radius: float = -1.0, force_full: bool = false) -> Dictionary:
	var r: float = radius if radius > 0.0 else interest_radius_default
	var origin := Vector2.ZERO
	if players.has(for_peer_id):
		origin = players[for_peer_id]["position"] as Vector2

	var visible_players: Dictionary = {} # id -> serialized
	var visible_enemies: Dictionary = {}

	for pid in players.keys():
		var p = players[pid]
		var pos: Vector2 = p["position"] as Vector2
		# Sempre inclui o próprio jogador; outros só dentro do raio
		if pid == for_peer_id or origin.distance_to(pos) <= r:
			visible_players[pid] = _serialize_player(pid, p)

	for eid in enemies.keys():
		var e = enemies[eid]
		if int(e.get("hp", 0)) <= 0:
			continue
		var pos: Vector2 = e["position"] as Vector2
		if origin.distance_to(pos) <= r:
			visible_enemies[eid] = _serialize_enemy(eid, e)

	var prev: Dictionary = _last_interest_state.get(for_peer_id, {"players": {}, "enemies": {}})
	var prev_p: Dictionary = prev.get("players", {})
	var prev_e: Dictionary = prev.get("enemies", {})
	var do_full: bool = force_full or (not use_snapshot_delta) or prev_p.is_empty()

	var out_players: Array = []
	var out_enemies: Array = []
	var removed_players: Array = []
	var removed_enemies: Array = []
	var next_p: Dictionary = {}
	var next_e: Dictionary = {}

	for pid in visible_players.keys():
		var data: Dictionary = visible_players[pid]
		var fp := _fingerprint_entity(data)
		next_p[pid] = fp
		if do_full or str(prev_p.get(pid, "")) != fp:
			out_players.append(data)

	for eid in visible_enemies.keys():
		var data: Dictionary = visible_enemies[eid]
		var fp := _fingerprint_entity(data)
		next_e[eid] = fp
		if do_full or str(prev_e.get(eid, "")) != fp:
			out_enemies.append(data)

	if not do_full:
		for pid in prev_p.keys():
			if not visible_players.has(pid):
				removed_players.append(pid)
		for eid in prev_e.keys():
			if not visible_enemies.has(eid):
				removed_enemies.append(eid)

	_last_interest_state[for_peer_id] = {"players": next_p, "enemies": next_e}

	return {
		"tick": current_tick,
		"ts": Time.get_ticks_msec(),
		"full": do_full,
		"players": out_players,
		"enemies": out_enemies,
		"removed_players": removed_players,
		"removed_enemies": removed_enemies,
		"interest_radius": r
	}


func clear_interest_state(peer_id: int) -> void:
	if _last_interest_state.has(peer_id):
		_last_interest_state.erase(peer_id)
