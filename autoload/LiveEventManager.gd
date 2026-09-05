class_name LiveEventManagerClass
extends Node

# ============================================================
# HUNTER ONLINE — LIVE EVENT MANAGER (FASE L)
# ============================================================
#
# Gerenciador central de eventos temporários e vivos no mundo:
# - Controla ciclo de vida (Início -> Duração -> Conclusão / Expiração).
# - Avança o tempo de duração integrado ao TimeManager do jogo.
# - Garante recompensas justas e anti-duplicação.
# - Compatível com single-player e multiplayer co-op da Fase K.
# ============================================================

signal evento_iniciado(evento_id: StringName, dados: Dictionary)
signal evento_concluido(evento_id: StringName, participantes: Array)
signal evento_expirado(evento_id: StringName)

var active_events: Dictionary = {} # StringName -> Dictionary
var event_history: Dictionary = {} # StringName -> Dictionary { completions, last_completed }


const StoryGatingEvaluatorScript = preload("res://scripts/systems/story/StoryGatingEvaluator.gd")


func _ready() -> void:
	add_to_group("live_event_manager")
	_conectar_event_bus()
	print("=================================")
	print("[LiveEventManager] GERENCIADOR DE EVENTOS AO VIVO ATIVO (FASE L)")
	print("=================================")


func _conectar_event_bus() -> void:
	if EventBus != null and EventBus.has_signal("time_hour_ticked"):
		EventBus.time_hour_ticked.connect(_on_time_hour_ticked)


func start_live_event(event_def: Resource) -> bool:
	if event_def == null:
		return false

	var e_id = event_def.get("event_id")
	if e_id == null or String(e_id).is_empty():
		return false

	var key := StringName(e_id)
	if active_events.has(key):
		push_warning("[LiveEventManager] Evento '%s' já está em andamento." % key)
		return false

	# Avaliar requisitos de ativação
	var reqs = event_def.get("requirements")
	if reqs is Array and not reqs.is_empty():
		var check = StoryGatingEvaluatorScript.evaluate_all(reqs)
		if not bool(check.get("passed", true)):
			print("[LiveEventManager] Requisitos não atendidos para o evento '%s': %s" % [key, str(check.get("unmet"))])
			return false

	var d_h = event_def.get("duration_hours")
	var dur_hours = float(d_h) if d_h != null else 4.0
	var ev_n = event_def.get("event_name")
	var event_name_str = str(ev_n) if ev_n != null else str(key)
	var t_reg = event_def.get("target_region")
	var target_region_sn = StringName(t_reg) if t_reg != null else &""
	var rew = event_def.get("rewards")
	var rew_dict: Dictionary = (rew as Dictionary).duplicate(true) if rew is Dictionary else {}
	var coop_val = event_def.get("coop_supported")
	var is_coop = bool(coop_val) if coop_val != null else true
	var temp_val = event_def.get("is_temporary")
	var is_temp = bool(temp_val) if temp_val != null else true

	var ev_data: Dictionary = {
		"definition": event_def,
		"event_id": key,
		"event_name": event_name_str,
		"target_region": target_region_sn,
		"remaining_hours": dur_hours,
		"total_duration": dur_hours,
		"participants": [],
		"rewards": rew_dict,
		"coop_supported": is_coop,
		"is_temporary": is_temp
	}

	active_events[key] = ev_data
	evento_iniciado.emit(key, ev_data)

	if EventBus != null:
		EventBus.emit_toast("⚡ NOVO EVENTO: %s!" % ev_data["event_name"], Color(1.0, 0.8, 0.2))

	print("[LiveEventManager] 📢 EVENTO VIVO INICIADO: '%s' na região '%s' (Duração: %.1f h)" % [
		key, ev_data["target_region"], dur_hours
	])
	return true


func complete_live_event(event_id: StringName, participant_id: String = "player") -> Dictionary:
	if not active_events.has(event_id):
		return {"success": false, "reason": "Evento não está ativo."}

	var ev_data: Dictionary = active_events[event_id]
	var parts: Array = ev_data.get("participants", [])
	if not parts.has(participant_id):
		parts.append(participant_id)

	# Distribuir recompensas se for o jogador local
	var rewards: Dictionary = ev_data.get("rewards", {})
	if participant_id == "player" and PlayerData != null:
		var xp = int(rewards.get("xp", 0))
		var gold = int(rewards.get("gold", 0))
		if xp > 0:
			var tree = Engine.get_main_loop() as SceneTree
			var xp_sys = tree.get_first_node_in_group("xp_system") if tree != null else null
			if xp_sys != null and xp_sys.has_method("adicionar_xp"):
				xp_sys.adicionar_xp(xp, "LiveEvent")
			elif PlayerData != null:
				PlayerData.attributes["xp"] = int(PlayerData.attributes.get("xp", 0)) + xp
		if gold > 0:
			var econ = Engine.get_main_loop().root.get_node_or_null("Economy")
			if econ != null and econ.has_method("adicionar_gold"):
				econ.adicionar_gold(gold)
			else:
				PlayerData.stats_globais["gold"] = int(PlayerData.stats_globais.get("gold", 0)) + gold

	# Registrar no histórico
	var hist_entry = event_history.get(event_id, {"completions": 0, "last_completed": ""})
	hist_entry["completions"] = int(hist_entry.get("completions", 0)) + 1
	hist_entry["last_completed"] = Time.get_datetime_string_from_system()
	event_history[event_id] = hist_entry

	evento_concluido.emit(event_id, parts)
	active_events.erase(event_id)

	if EventBus != null:
		EventBus.emit_toast("🏆 Evento Concluído: %s!" % ev_data.get("event_name", ""), Color(0.3, 1.0, 0.4))

	print("[LiveEventManager] 🏆 Evento '%s' concluído com sucesso por %s!" % [event_id, str(parts)])
	return {"success": true, "rewards": rewards}


func cancel_or_expire_event(event_id: StringName) -> void:
	if not active_events.has(event_id):
		return

	var ev_data = active_events[event_id]
	active_events.erase(event_id)
	evento_expirado.emit(event_id)

	if EventBus != null:
		EventBus.emit_toast("⏳ O evento '%s' expirou." % ev_data.get("event_name", ""), Color.GRAY)

	print("[LiveEventManager] ⏳ Evento '%s' expirou e foi encerrado." % event_id)


func is_event_active(event_id: StringName) -> bool:
	return active_events.has(event_id)


func get_active_events_in_region(region_id: StringName) -> Array[Dictionary]:
	var res: Array[Dictionary] = []
	for k in active_events.keys():
		var ev = active_events[k]
		if ev.get("target_region") == region_id:
			res.append(ev)
	return res


func _on_time_hour_ticked(_hour: int, _minute: int) -> void:
	var to_expire: Array[StringName] = []
	for k in active_events.keys():
		var ev = active_events[k]
		var rem = float(ev.get("remaining_hours", 0.0)) - 1.0
		ev["remaining_hours"] = rem
		if rem <= 0.0:
			to_expire.append(k)

	for exp_id in to_expire:
		cancel_or_expire_event(exp_id)


# ============================================================
# PERSISTÊNCIA SERIALIZÁVEL
# ============================================================

func serializar() -> Dictionary:
	var active_serialized: Dictionary = {}
	for k in active_events.keys():
		var ev = active_events[k]
		active_serialized[String(k)] = {
			"event_id": String(ev.get("event_id")),
			"event_name": str(ev.get("event_name")),
			"target_region": String(ev.get("target_region")),
			"remaining_hours": float(ev.get("remaining_hours")),
			"total_duration": float(ev.get("total_duration")),
			"participants": (ev.get("participants", []) as Array).duplicate(),
			"rewards": (ev.get("rewards", {}) as Dictionary).duplicate(true)
		}

	var hist_serialized: Dictionary = {}
	for h in event_history.keys():
		hist_serialized[String(h)] = (event_history[h] as Dictionary).duplicate(true)

	return {
		"active_events": active_serialized,
		"event_history": hist_serialized
	}


func deserializar(data: Dictionary) -> void:
	active_events.clear()
	event_history.clear()

	if data.has("active_events") and data["active_events"] is Dictionary:
		var act = data["active_events"] as Dictionary
		for k in act.keys():
			var entry = act[k]
			if entry is Dictionary:
				active_events[StringName(k)] = entry.duplicate(true)

	if data.has("event_history") and data["event_history"] is Dictionary:
		var hist = data["event_history"] as Dictionary
		for h in hist.keys():
			var entry = hist[h]
			if entry is Dictionary:
				event_history[StringName(h)] = entry.duplicate(true)
