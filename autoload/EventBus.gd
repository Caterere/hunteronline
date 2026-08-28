extends Node

# ============================================================
# HUNTER ONLINE - GLOBAL EVENT BUS
# ============================================================
#
# Barramento global de eventos para desacoplamento de sistemas:
# - Eventos de Jogador (dano, cura, atributos, morte)
# - Eventos de Combate (golpes, stagger, derrotas)
# - Eventos de Nen (ativação de técnicas, nível, aura)
# - Eventos de Quests (início, progresso, conclusão)
# - Eventos de Mundo & Tempo (zonas, dia/noite, horas)
# - Eventos de Economia & Inventário (itens, Jenny)
# - Eventos de Interface (toasts, menus, diálogos)
# - Eventos de Rede (pacotes recebidos/enviados)
#
# ============================================================

# ------------------------------------------------------------
# 1. EVENTOS DO JOGADOR
# ------------------------------------------------------------
signal player_spawned(player_node: Node2D)
signal player_damaged(current_hp: int, max_hp: int, damage_taken: int)
signal player_healed(current_hp: int, max_hp: int, amount: int)
signal player_stat_changed(stat_name: String, new_value: Variant)
signal player_died()

# ------------------------------------------------------------
# 2. EVENTOS DE NEN
# ------------------------------------------------------------
signal nen_technique_activated(tech_name: String)
signal nen_technique_deactivated(tech_name: String)
signal nen_aura_changed(current_aura: float, max_aura: float)
signal nen_level_up(new_nen_level: int)
signal nen_xp_gained(amount: int, current_xp: int)

# ------------------------------------------------------------
# 3. EVENTOS DE COMBATE & PVE
# ------------------------------------------------------------
signal combat_hit_landed(attacker: Node, target: Node, damage: int, is_crit: bool)
signal hitstop_requested(duration: float)
signal camera_shake_requested(trauma_intensity: float, duration: float)
signal enemy_spawned(enemy_id: String, position: Vector2)
signal enemy_damaged(enemy_node: Node, current_hp: int, max_hp: int)
signal enemy_staggered(enemy_node: Node)
signal enemy_defeated(enemy_id: String, xp_reward: int, nen_xp_reward: int)
signal boss_phase_changed(boss_name: String, new_phase: int)



var _hitstop_end_time_msec: int = 0


func emit_hitstop(duration: float = 0.04) -> void:
	hitstop_requested.emit(duration)
	if duration <= 0.0:
		return
	var tree = get_tree()
	if tree == null:
		return
	
	var now := Time.get_ticks_msec()
	var new_end := now + int(duration * 1000.0)
	if new_end > _hitstop_end_time_msec:
		_hitstop_end_time_msec = new_end

	Engine.time_scale = 0.05
	var timer = tree.create_timer(duration, true, false, true)
	timer.timeout.connect(func():
		if Time.get_ticks_msec() >= _hitstop_end_time_msec:
			Engine.time_scale = 1.0
	)


func emit_camera_shake(intensity: float = 0.3, duration: float = 0.2) -> void:
	camera_shake_requested.emit(intensity, duration)


# ------------------------------------------------------------
# 4. EVENTOS DE QUESTS
# ------------------------------------------------------------
signal quest_accepted(quest_id: String, quest_name: String)
signal quest_objective_updated(quest_id: String, objective_desc: String, current: int, required: int)
signal quest_completed(quest_id: String, reward_xp: int, reward_jenny: int)
signal quest_failed(quest_id: String)

# ------------------------------------------------------------
# 5. EVENTOS DE MUNDO, ZONAS & TEMPO
# ------------------------------------------------------------
signal zone_entered(zone_name: String, risk_level: int)
signal time_hour_ticked(hour: int, minute: int)
signal time_phase_changed(phase_name: String) # DAWN, DAY, DUSK, NIGHT
signal world_event_triggered(event_id: String, event_title: String, position: Vector2)
signal ambient_encounter_started(encounter_id: String, title: String)

# ------------------------------------------------------------
# 6. EVENTOS DE INVENTÁRIO & ECONOMIA
# ------------------------------------------------------------
signal item_obtained(item_id: String, quantity: int)
signal item_used(item_id: String)
signal item_removed(item_id: String, quantity: int)
signal jenny_changed(new_amount: int, delta: int)
signal equipment_updated(slot: String, equipment_id: String)

# ------------------------------------------------------------
# 7. EVENTOS DE INTERFACE & NOTIFICAÇÕES
# ------------------------------------------------------------
signal toast_requested(message: String, color: Color)
signal dialogue_opened(speaker_name: String)
signal dialogue_closed()
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)

# ------------------------------------------------------------
# 9. EVENTOS DE TUTORIAL, CONHECIMENTO & ONBOARDING (HUNTER GUIDE)
# ------------------------------------------------------------
signal tutorial_started(tutorial_id: String)
signal tutorial_step_started(step_id: String, step_index: int)
signal tutorial_step_completed(step_id: String, step_index: int)
signal tutorial_completed(tutorial_id: String)
signal tutorial_skipped(tutorial_id: String)
signal tutorial_knowledge_unlocked(knowledge_id: String, category: String)
signal tutorial_contextual_requested(context_type: String, title: String, message: String)


func _ready() -> void:
	print("=================================")
	print("[EventBus] BARRAMENTO GLOBAL ATIVO")
	print("=================================")


# Helper para emitir toasts visuais rapidamente
func emit_toast(msg: String, color: Color = Color.WHITE) -> void:
	toast_requested.emit(msg, color)
