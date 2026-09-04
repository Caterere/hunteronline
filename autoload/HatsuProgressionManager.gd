extends Node

# ============================================================
# HUNTER ONLINE — HATSU PROGRESSION MANAGER (AUTOLOAD)
# ============================================================
#
# Autoridade Central e Única (Single Source of Truth) para todo
# o ecossistema de Hatsu do MMORPG:
#
# 1. SLOTS ATIVOS PROGRESSIVOS (1 a 4) com dependência em cadeia estrita:
#    - Slot 1: Conclusão de Greed Island (Arco 5) + Iniciação com Biscuit.
#    - Slot 2: Slot 1 desbloqueado E Nível >= 600.
#    - Slot 3: Slot 2 desbloqueado E Nível >= 800.
#    - Slot 4: Slot 3 desbloqueado E Nível >= 1000 (Ápice do domínio).
#    - Slots 5+: Totalmente extensível sem tetos artificiais.
#
# 2. HATSU ARCHIVE (1 a 12):
#    - Capacidade máxima de 12 Hatsus conhecidos (HatsuConfig.MAX_ARCHIVE_SLOTS).
#    - Hatsus no Archive podem estar armazenados, equipados ou arquivados.
#
# 3. FORJA & COOLDOWNS PERSISTENTES:
#    - Cooldown de 30 minutos (1800s) persistido via timestamp Unix.
#    - Custo em Jenny (5.000 Jenny) com transação atômica e money sink.
#    - Cooldown de troca/estabilização de 10 minutos (600s) para slots ativos.
#
# 4. SISTEMA DE MASTERY (0 a 100) & ANTI-FARM:
#    - Potencial escala de 30% a 100% (Status: ★ MASTERED).
#    - Bônus em Dano, Redução de Custo de Aura (-20%), Redução de Cooldown (-20%) e Alcance (+20%).
#    - Proteção Anti-Farm contra mobs fracos e bônus para Elites (1.5x) e Chefes (2.5x).
#
# ============================================================

signal hatsu_slot_desbloqueado(slot_id: int)
signal hatsu_slots_atualizados
signal hatsu_criado(hatsu: HatsuData)
signal hatsu_mastery_alterada(hatsu_id: String, nova_mastery: float, novo_xp: float, is_mastered: bool)
signal hatsu_trocado_slot(slot_id: int, hatsu_id: String)
signal hatsu_removido_archive(hatsu_id: String)

const HatsuSlotDataScript = preload("res://scripts/systems/hatsu/HatsuSlotData.gd")

var slots_catalog: Dictionary = {} # int -> HatsuSlotData
var unlocked_slots: Dictionary = {
	1: false,
	2: false,
	3: false,
	4: false
}

# --- ESTADO DO ARCHIVE & SLOTS ATIVOS ---
var archive: Array[HatsuData] = []
var active_slots_map: Dictionary = {
	1: "",
	2: "",
	3: "",
	4: ""
}

# --- TIMESTAMPS PERSISTENTES (UNIX EPOCH) ---
var last_creation_timestamp: int = 0
var slot_switch_timestamps: Dictionary = {
	1: 0,
	2: 0,
	3: 0,
	4: 0
}


func _ready() -> void:
	_inicializar_catalogo_padrao()
	_conectar_eventos()
	print("============================================================")
	print("[HatsuProgressionManager] AUTORIDADE CENTRAL DE HATSU ATIVA")
	print("  Slots Registrados: ", slots_catalog.size())
	print("  Archive Atual: ", archive.size(), "/", HatsuConfig.MAX_ARCHIVE_SLOTS)
	print("============================================================")


func _inicializar_catalogo_padrao() -> void:
	slots_catalog.clear()

	# Slot 1: Greed Island (Arco 5) Concluída
	register_slot(HatsuSlotDataScript.new(
		1,
		"Hatsu Slot 1",
		"Iniciação espiritual ao Hatsu forjada sob a tutela da Mestra Biscuit Krueger após a conclusão de Greed Island.",
		0,   # Sem exigência de nível
		0,   # Sem slot prévio
		5,   # Saga 5 (Greed Island)
		"greed_island_completed"
	))

	# Slot 2: Slot 1 + Nível 600
	register_slot(HatsuSlotDataScript.new(
		2,
		"Hatsu Slot 2",
		"Expansão do potencial de aura para sustentar uma segunda técnica exclusiva. Exige maestria avançada.",
		600, # Nível 600
		1,   # Requer Slot 1
		0,
		""
	))

	# Slot 3: Slot 2 + Nível 800
	register_slot(HatsuSlotDataScript.new(
		3,
		"Hatsu Slot 3",
		"Compreensão profunda das multifacetas do Nen, permitindo um terceiro vetor tático em combate.",
		800, # Nível 800
		2,   # Requer Slot 2
		0,
		""
	))

	# Slot 4: Slot 3 + Nível 1000
	register_slot(HatsuSlotDataScript.new(
		4,
		"Hatsu Slot 4",
		"Domínio supremo dos quatro cantos do Hatsu. O ápice do poder alcançado no Nível 1000.",
		1000,# Nível 1000
		3,   # Requer Slot 3
		0,
		""
	))


func register_slot(slot_data: HatsuSlotData) -> void:
	if slot_data == null:
		return
	slots_catalog[slot_data.slot_id] = slot_data
	if not unlocked_slots.has(slot_data.slot_id):
		unlocked_slots[slot_data.slot_id] = false
	if not active_slots_map.has(slot_data.slot_id):
		active_slots_map[slot_data.slot_id] = ""
	if not slot_switch_timestamps.has(slot_data.slot_id):
		slot_switch_timestamps[slot_data.slot_id] = 0


func _conectar_eventos() -> void:
	if PlayerData != null and PlayerData.has_signal("level_changed"):
		PlayerData.level_changed.connect(func(_nv): check_and_unlock_slots())
	if StoryManager != null and StoryManager.has_signal("saga_concluida"):
		StoryManager.saga_concluida.connect(func(_saga): check_and_unlock_slots())


# ============================================================
# 1. CONSULTA E DIAGNÓSTICO DE SLOTS ATIVOS (ANTI-BYPASS)
# ============================================================

func can_unlock_slot(slot_id: int) -> Dictionary:
	if not slots_catalog.has(slot_id):
		return {
			"can_unlock": false,
			"reason": "INVALID_SLOT",
			"required_level": 0,
			"current_level": 0,
			"required_slot": 0,
			"previous_slot_unlocked": false,
			"story_completed": false,
			"slot_data": null
		}

	var data: HatsuSlotData = slots_catalog[slot_id]
	var cur_level: int = PlayerData.attributes.get("nivel", 1) if PlayerData != null else 1
	var prev_unlocked: bool = true
	if data.required_slot_id > 0:
		prev_unlocked = is_slot_unlocked(data.required_slot_id)

	var story_ok: bool = true
	if data.required_saga_id > 0:
		story_ok = _is_saga_completed(data.required_saga_id)

	# 1. Se já está desbloqueado
	if is_slot_unlocked(slot_id):
		return {
			"can_unlock": false,
			"reason": "ALREADY_UNLOCKED",
			"required_level": data.required_level,
			"current_level": cur_level,
			"required_slot": data.required_slot_id,
			"previous_slot_unlocked": prev_unlocked,
			"story_completed": story_ok,
			"slot_data": data
		}

	# 2. Dependência Obrigatória em Cadeia: Slot prévio bloqueado -> IMPEDE DESBLOQUEIO
	if data.required_slot_id > 0 and not prev_unlocked:
		return {
			"can_unlock": false,
			"reason": "PREVIOUS_SLOT_LOCKED",
			"required_level": data.required_level,
			"current_level": cur_level,
			"required_slot": data.required_slot_id,
			"previous_slot_unlocked": false,
			"story_completed": story_ok,
			"slot_data": data
		}

	# 3. Requisito de História / Saga
	if data.required_saga_id > 0 and not story_ok:
		return {
			"can_unlock": false,
			"reason": "STORY_NOT_COMPLETED",
			"required_level": data.required_level,
			"current_level": cur_level,
			"required_slot": data.required_slot_id,
			"previous_slot_unlocked": prev_unlocked,
			"story_completed": false,
			"slot_data": data
		}

	# 4. Requisito de Nível
	if data.required_level > 0 and cur_level < data.required_level:
		return {
			"can_unlock": false,
			"reason": "REQUIRED_LEVEL",
			"required_level": data.required_level,
			"current_level": cur_level,
			"required_slot": data.required_slot_id,
			"previous_slot_unlocked": prev_unlocked,
			"story_completed": story_ok,
			"slot_data": data
		}

	# Todos os requisitos foram plenamente atendidos
	return {
		"can_unlock": true,
		"reason": "OK",
		"required_level": data.required_level,
		"current_level": cur_level,
		"required_slot": data.required_slot_id,
		"previous_slot_unlocked": prev_unlocked,
		"story_completed": story_ok,
		"slot_data": data
	}


func _is_saga_completed(saga_id: int) -> bool:
	if saga_id == 5:
		if PlayerData != null and PlayerData.has_method("is_greed_island_concluida") and PlayerData.is_greed_island_concluida():
			return true

	if StoryManager != null:
		if StoryManager.completed_sagas.has(saga_id):
			return true
		if StoryManager.current_saga > saga_id:
			return true
		if StoryManager.get_story_flag("saga_%d_completed" % saga_id, false):
			return true
		if saga_id == 5 and StoryManager.get_story_flag("greed_island_completed", false):
			return true

	if PlayerData != null:
		if PlayerData.modo_historia_concluido:
			return true
		if PlayerData.arco_atual > saga_id or PlayerData.max_arco_desbloqueado > saga_id:
			return true

	return false


func unlock_slot(slot_id: int) -> bool:
	var check := can_unlock_slot(slot_id)
	if not check["can_unlock"]:
		push_warning("[HatsuProgressionManager] Bloqueio anti-bypass: Não é possível desbloquear slot %d. Motivo: %s" % [slot_id, check["reason"]])
		return false

	unlocked_slots[slot_id] = true

	if slot_id == 1:
		if PlayerData != null:
			PlayerData.hatsu_desbloqueado = true
			PlayerData.hatsu_creation_unlocked = true

	hatsu_slot_desbloqueado.emit(slot_id)
	hatsu_slots_atualizados.emit()

	_exibir_notificacao_desbloqueio(slot_id)
	print("[HatsuProgressionManager] 🔓 HATSU SLOT %d DESBLOQUEADO COM SUCESSO!" % slot_id)
	return true


func check_and_unlock_slots() -> Array[int]:
	var recem_desbloqueados: Array[int] = []
	var ids := slots_catalog.keys()
	ids.sort()

	for sid in ids:
		if not is_slot_unlocked(sid):
			var check := can_unlock_slot(sid)
			if check["can_unlock"]:
				if unlock_slot(sid):
					recem_desbloqueados.append(sid)

	return recem_desbloqueados


func is_slot_unlocked(slot_id: int) -> bool:
	return unlocked_slots.get(slot_id, false)


func get_slot_state(slot_id: int) -> int:
	if not is_slot_unlocked(slot_id):
		return HatsuSlotDataScript.SlotState.LOCKED

	var hid: String = active_slots_map.get(slot_id, "")
	if not hid.is_empty():
		return HatsuSlotDataScript.SlotState.EQUIPPED

	return HatsuSlotDataScript.SlotState.UNLOCKED


# ============================================================
# 2. COOLDOWNS & ECONOMIA DE CRIAÇÃO (30 MIN + JENNY)
# ============================================================

func get_remaining_creation_cooldown() -> float:
	var now: int = int(Time.get_unix_time_from_system())
	var elapsed: float = float(now - last_creation_timestamp)
	var rem: float = HatsuConfig.HATSU_CREATION_COOLDOWN - elapsed
	return max(0.0, rem)


func get_remaining_switch_cooldown(slot_id: int) -> float:
	var now: int = int(Time.get_unix_time_from_system())
	var last_sw: int = int(slot_switch_timestamps.get(slot_id, 0))
	var elapsed: float = float(now - last_sw)
	var rem: float = HatsuConfig.HATSU_SWITCH_COOLDOWN - elapsed
	return max(0.0, rem)


func can_create_hatsu() -> Dictionary:
	var cost: int = HatsuConfig.HATSU_CREATION_JENNY_COST
	var rem_cd: float = get_remaining_creation_cooldown()
	var cur_arch: int = archive.size()
	var max_arch: int = HatsuConfig.MAX_ARCHIVE_SLOTS

	# 1. Pré-requisito narrativo: Slot 1 desbloqueado com Biscuit pós-Greed Island
	if not is_slot_unlocked(1):
		return {
			"can_create": false,
			"reason": "SLOT_LOCKED",
			"message": "🔒 FORJA BLOQUEADA: Conclua Greed Island e treine com Biscuit para desbloquear o Hatsu Slot 1.",
			"remaining_seconds": 0,
			"cost_jenny": cost,
			"archive_count": cur_arch,
			"archive_max": max_arch
		}

	# 2. Capacidade do Archive (Máximo 12 Hatsus)
	if cur_arch >= max_arch:
		return {
			"can_create": false,
			"reason": "ARCHIVE_FULL",
			"message": "⚠️ ARCHIVE LOTADO: Capacidade máxima de %d Hatsus atingida. Exclua um Hatsu antigo para liberar espaço." % max_arch,
			"remaining_seconds": 0,
			"cost_jenny": cost,
			"archive_count": cur_arch,
			"archive_max": max_arch
		}

	# 3. Cooldown de Criação de 30 minutos (Persistente)
	if rem_cd > 0.0:
		return {
			"can_create": false,
			"reason": "COOLDOWN",
			"message": "⏳ EM COOLDOWN: O espírito precisa de repouso antes de conceber uma nova técnica. Tempo restante: %s" % _formatar_tempo(int(ceil(rem_cd))),
			"remaining_seconds": int(ceil(rem_cd)),
			"cost_jenny": cost,
			"archive_count": cur_arch,
			"archive_max": max_arch
		}

	# 4. Custo em Jenny (Money Sink)
	var saldo_jenny: int = int(PlayerData.attributes.get("gold", 0)) if PlayerData != null else 0
	if Economy != null and not Economy.tem_gold(cost):
		return {
			"can_create": false,
			"reason": "INSUFFICIENT_JENNY",
			"message": "💰 JENNY INSUFICIENTE: Forjar um Hatsu custa %d Jenny (Saldo atual: %d Jenny)." % [cost, saldo_jenny],
			"remaining_seconds": 0,
			"cost_jenny": cost,
			"archive_count": cur_arch,
			"archive_max": max_arch
		}

	# Tudo validado com sucesso
	return {
		"can_create": true,
		"reason": "OK",
		"message": "✅ Pronto para forjar nova habilidade de Hatsu.",
		"remaining_seconds": 0,
		"cost_jenny": cost,
		"archive_count": cur_arch,
		"archive_max": max_arch
	}


func is_creation_allowed_bool() -> bool:
	return can_create_hatsu().get("can_create", false)


# ============================================================
# 3. TRANSAÇÃO ATÔMICA DE FORJA DE HATSU
# ============================================================

func criar_e_registrar_hatsu(hatsu: HatsuData) -> Dictionary:
	if hatsu == null:
		return {"success": false, "reason": "NULL_DATA", "message": "Dados de Hatsu inválidos."}

	# 1. Validação estrita preliminar
	var check := can_create_hatsu()
	if not check.get("can_create", false):
		push_warning("[HatsuProgressionManager] Tentativa de criação rejeitada: %s" % check.get("reason"))
		return {"success": false, "reason": check.get("reason"), "message": check.get("message")}

	var cost: int = HatsuConfig.HATSU_CREATION_JENNY_COST

	# 2. Transação Atômica: Deduzir Jenny primeiro
	if Economy != null:
		var ok: bool = Economy.remover_gold(cost)
		if not ok:
			return {"success": false, "reason": "INSUFFICIENT_JENNY", "message": "Falha na dedução de Jenny."}
	elif PlayerData != null:
		var saldo = int(PlayerData.attributes.get("gold", 0))
		if saldo < cost:
			return {"success": false, "reason": "INSUFFICIENT_JENNY", "message": "Jenny insuficiente."}
		PlayerData.attributes["gold"] = saldo - cost

	# 3. Gerar ID Único e Configurar Mastery Inicial
	if hatsu.hatsu_id.is_empty():
		hatsu.gerar_novo_id()
	hatsu.created_timestamp = int(Time.get_unix_time_from_system())
	hatsu.mastery = HatsuConfig.INITIAL_MASTERY
	hatsu.mastery_xp = 0.0
	hatsu.nivel_evolucao_hatsu = 0

	# 4. Registrar no Archive
	archive.append(hatsu)

	# 5. Iniciar Cooldown de 30 minutos
	last_creation_timestamp = int(Time.get_unix_time_from_system())

	# 6. Sincronizar com PlayerData
	_sync_player_data_archive()

	# Auto-equipar no primeiro slot ativo livre que esteja desbloqueado
	for sid in [1, 2, 3, 4]:
		if is_slot_unlocked(sid) and active_slots_map.get(sid, "").is_empty():
			equipar_hatsu(sid, hatsu.hatsu_id)
			break

	# 7. Salvar Jogo Atomicamente
	if SaveManager != null:
		SaveManager.salvar_jogo()

	# 8. Emitir Eventos e Notificação
	hatsu_criado.emit(hatsu)
	hatsu_slots_atualizados.emit()

	var msg := "⚡ HATSU FORJADO COM SUCESSO!\n'%s' adicionado ao Archive (%d/%d).\nMastery inicial: 0/100 (30%% Potencial)." % [hatsu.nome, archive.size(), HatsuConfig.MAX_ARCHIVE_SLOTS]
	if EventBus != null and EventBus.has_signal("toast_enviado"):
		EventBus.emit_toast(msg, Color(0.4, 1.0, 0.6))

	print("[HatsuProgressionManager] ⚡ Transação atômica concluída: Hatsu '%s' [ID: %s] | Jenny pago: -%d" % [hatsu.nome, hatsu.hatsu_id, cost])
	return {
		"success": true,
		"reason": "OK",
		"hatsu": hatsu,
		"archive_index": archive.size() - 1,
		"message": msg
	}


# ============================================================
# 4. GESTÃO DO ARCHIVE (12 SLOTS) & CONSULTA
# ============================================================

func obter_todos_hatsus_archive() -> Array[HatsuData]:
	var lista: Array[HatsuData] = []
	for h in archive:
		if h is HatsuData:
			lista.append(h)
	return lista


func obter_hatsu_archive_por_id(hid: String) -> HatsuData:
	if hid.is_empty():
		return null
	for h in archive:
		if h is HatsuData and h.hatsu_id == hid:
			return h
	return null


func obter_hatsu_archive_por_indice(idx: int) -> HatsuData:
	if idx >= 0 and idx < archive.size():
		return archive[idx]
	return null


func excluir_hatsu_archive(hatsu_id: String) -> Dictionary:
	# Não permitir excluir Hatsu que esteja equipado em slot ativo
	for s in active_slots_map.keys():
		if active_slots_map[s] == hatsu_id:
			return {
				"success": false,
				"reason": "IS_EQUIPPED",
				"message": "❌ Não é possível excluir um Hatsu enquanto ele estiver equipado no Slot Ativo %d. Desequipe-o primeiro." % s
			}

	for i in range(archive.size()):
		if archive[i] is HatsuData and archive[i].hatsu_id == hatsu_id:
			var h_removido = archive[i]
			archive.remove_at(i)
			_sync_player_data_archive()
			_sync_player_data_slots()
			hatsu_removido_archive.emit(hatsu_id)
			hatsu_slots_atualizados.emit()
			if SaveManager != null:
				SaveManager.salvar_jogo()
			print("[HatsuProgressionManager] 🗑️ Hatsu '%s' excluído do Archive." % h_removido.nome)
			return {
				"success": true,
				"reason": "OK",
				"message": "Hatsu '%s' excluído com sucesso. Espaço liberado no Archive." % h_removido.nome
			}

	return {
		"success": false,
		"reason": "NOT_FOUND",
		"message": "Hatsu não encontrado no Archive."
	}


# ============================================================
# 5. GESTÃO DE SLOTS ATIVOS (EQUIP / UNEQUIP & SWITCH COOLDOWN)
# ============================================================

func can_equip_to_slot(slot_id: int, hatsu_ref: Variant = null) -> Dictionary:
	if not is_slot_unlocked(slot_id):
		return {"can_equip": false, "reason": "SLOT_LOCKED", "message": "Slot %d bloqueado." % slot_id}

	var rem_sw: float = get_remaining_switch_cooldown(slot_id)
	if rem_sw > 0.0:
		return {
			"can_equip": false,
			"reason": "SWITCH_COOLDOWN",
			"remaining_seconds": int(ceil(rem_sw)),
			"message": "⏳ Estabilização de Aura ativa no Slot %d. Tempo restante: %s" % [slot_id, _formatar_tempo(int(ceil(rem_sw)))]
		}

	if hatsu_ref != null:
		var h: HatsuData = null
		if hatsu_ref is String:
			h = obter_hatsu_archive_por_id(hatsu_ref)
		elif hatsu_ref is int:
			h = obter_hatsu_archive_por_indice(hatsu_ref)
		elif hatsu_ref is HatsuData:
			h = hatsu_ref

		if h == null:
			return {"can_equip": false, "reason": "NOT_FOUND", "message": "Hatsu não encontrado no Archive."}

	return {"can_equip": true, "reason": "OK", "message": "Apto para equipar."}


func equipar_hatsu(slot_id: int, hatsu_ref: Variant) -> bool:
	var check := can_equip_to_slot(slot_id, hatsu_ref)
	if not check.get("can_equip", false):
		push_warning("[HatsuProgressionManager] Bloqueio ao equipar Slot %d: %s" % [slot_id, check.get("reason")])
		return false

	var target_hid: String = ""
	if hatsu_ref is String:
		target_hid = hatsu_ref
	elif hatsu_ref is int:
		var h_idx = obter_hatsu_archive_por_indice(hatsu_ref)
		if h_idx != null:
			target_hid = h_idx.hatsu_id
	elif hatsu_ref is HatsuData:
		target_hid = hatsu_ref.hatsu_id

	if target_hid.is_empty():
		return false

	# Se a habilidade já estiver equipada em outro slot, desequipar daquele slot para evitar duplicações
	for s in active_slots_map.keys():
		if active_slots_map[s] == target_hid and s != slot_id:
			active_slots_map[s] = ""

	active_slots_map[slot_id] = target_hid
	slot_switch_timestamps[slot_id] = int(Time.get_unix_time_from_system())

	_sync_player_data_slots()
	hatsu_trocado_slot.emit(slot_id, target_hid)
	hatsu_slots_atualizados.emit()

	print("[HatsuProgressionManager] ⚔️ Slot %d equipado com Hatsu ID '%s'" % [slot_id, target_hid])
	return true


func desequipar_hatsu(slot_id: int) -> bool:
	if not active_slots_map.has(slot_id):
		return false

	active_slots_map[slot_id] = ""
	_sync_player_data_slots()
	hatsu_trocado_slot.emit(slot_id, "")
	hatsu_slots_atualizados.emit()
	print("[HatsuProgressionManager] 🛡️ Slot %d desequipado." % slot_id)
	return true


func obter_hatsu_ativo(slot_id: int) -> HatsuData:
	if not is_slot_unlocked(slot_id):
		return null
	var hid: String = active_slots_map.get(slot_id, "")
	if hid.is_empty():
		return null
	return obter_hatsu_archive_por_id(hid)


# ============================================================
# 6. SISTEMA DE MASTERY & ANTI-FARM
# ============================================================

func conceder_mastery_xp(hatsu_id: String, dano_causado: int, inimigo_context: Dictionary = {}) -> Dictionary:
	var h: HatsuData = obter_hatsu_archive_por_id(hatsu_id)
	if h == null:
		return {"success": false, "reason": "NOT_FOUND"}

	if h.is_mastered():
		return {"success": true, "gained_xp": 0.0, "subiu_nivel": false, "mastered": true}

	var ply_level: int = PlayerData.attributes.get("nivel", 1) if PlayerData != null else 1
	var mob_level: int = int(inimigo_context.get("level", ply_level))

	# 1. Penalidade Anti-Farm
	var anti_farm_factor: float = HatsuConfig.calcular_penalidade_anti_farm(ply_level, mob_level)
	if anti_farm_factor <= 0.0:
		return {
			"success": true,
			"gained_xp": 0.0,
			"reason": "ANTI_FARM_PENALTY",
			"subiu_nivel": false,
			"mastered": false
		}

	# 2. Multiplicadores de Elite / Boss
	var mob_mult: float = HatsuConfig.MOB_XP_MULT_NORMAL
	if inimigo_context.get("is_boss", false):
		mob_mult = HatsuConfig.MOB_XP_MULT_BOSS
	elif inimigo_context.get("is_elite", false):
		mob_mult = HatsuConfig.MOB_XP_MULT_ELITE

	# 3. Cálculo do ganho de XP
	var xp_from_dmg: float = float(max(1, dano_causado)) * HatsuConfig.MASTERY_XP_PER_DAMAGE
	var total_xp: float = (xp_from_dmg + HatsuConfig.MASTERY_XP_PER_HIT_BASE) * anti_farm_factor * mob_mult

	var res: Dictionary = h.adicionar_mastery_xp(total_xp)
	res["gained_xp"] = total_xp
	res["anti_farm_factor"] = anti_farm_factor

	hatsu_mastery_alterada.emit(hatsu_id, h.mastery, h.mastery_xp, h.is_mastered())

	if res.get("subiu_nivel", false):
		_exibir_notificacao_mastery(h, res.get("mastered", false))

	return res


func _exibir_notificacao_mastery(h: HatsuData, mastered: bool) -> void:
	var msg: String = ""
	if mastered:
		msg = "━━━━━━━━━━━━━━━━━━━━\n★ HATSU MASTERED! ★\n━━━━━━━━━━━━━━━━━━━━\n'%s' atingiu Mastery Máxima (100)!\nPotencial Pleno e Eficiência Absoluta liberados." % h.nome
	else:
		msg = "⭐ MASTERY DE HATSU: '%s' evoluiu para Nível %d/100!\nPoder: %d%% | Eficiência: +%d%%" % [
			h.nome, int(h.mastery), int(h.obter_multiplicador_mastery() * 100), int((1.0 - h.obter_reducao_custo_mastery()) * 100)
		]

	if EventBus != null and EventBus.has_signal("toast_enviado"):
		EventBus.emit_toast(msg, Color(1.0, 0.85, 0.2) if not mastered else Color(1.0, 0.95, 0.3))
	print("[HatsuProgressionManager] ", msg)


# ============================================================
# 7. SINCRONIZAÇÃO COM PLAYERDATA
# ============================================================

func _sync_player_data_archive() -> void:
	if PlayerData == null:
		return
	PlayerData.hatsu_criados = archive.duplicate()


func _sync_player_data_slots() -> void:
	if PlayerData == null:
		return
	var slots_arr: Array = [-1, -1, -1, -1]
	for sid in range(1, 5):
		var hid: String = active_slots_map.get(sid, "")
		if hid.is_empty():
			slots_arr[sid - 1] = -1
		else:
			var idx: int = -1
			for i in range(archive.size()):
				if archive[i] is HatsuData and archive[i].hatsu_id == hid:
					idx = i
					break
			slots_arr[sid - 1] = idx
	PlayerData.hatsu_slots = slots_arr


# ============================================================
# 8. AUDITORIA E REVALIDAÇÃO CONTRA MODIFICAÇÕES / CORRUPÇÃO
# ============================================================

func revalidate_all_slots() -> void:
	var ids := slots_catalog.keys()
	ids.sort()

	for sid in ids:
		if is_slot_unlocked(sid):
			var data: HatsuSlotData = slots_catalog[sid]
			var valido := true

			# Revalidar cadeia: slot anterior deve estar desbloqueado
			if data.required_slot_id > 0 and not is_slot_unlocked(data.required_slot_id):
				valido = false

			# Revalidar nível
			var cur_lvl: int = PlayerData.attributes.get("nivel", 1) if PlayerData != null else 1
			if data.required_level > 0 and cur_lvl < data.required_level:
				valido = false

			# Revalidar saga (para slot 1)
			if data.required_saga_id > 0 and not _is_saga_completed(data.required_saga_id):
				valido = false

			if not valido:
				push_warning("[HatsuProgressionManager] ⚠️ REVALIDAÇÃO: Slot %d revogado por violação de requisitos!" % sid)
				unlocked_slots[sid] = false
				active_slots_map[sid] = ""

	# Expurgar active slots apontando para Hatsus inexistentes
	for sid in active_slots_map.keys():
		var hid = active_slots_map[sid]
		if not hid.is_empty() and obter_hatsu_archive_por_id(hid) == null:
			active_slots_map[sid] = ""

	# Sincronizar flags de PlayerData
	if PlayerData != null:
		PlayerData.hatsu_desbloqueado = is_slot_unlocked(1)
		PlayerData.hatsu_creation_unlocked = is_slot_unlocked(1)

	_sync_player_data_archive()
	_sync_player_data_slots()
	hatsu_slots_atualizados.emit()


func _exibir_notificacao_desbloqueio(slot_id: int) -> void:
	var msg := "━━━━━━━━━━━━━━━━━━━━\nHATSU SLOT %d DESBLOQUEADO\n━━━━━━━━━━━━━━━━━━━━\nVocê dominou o suficiente para desenvolver uma nova habilidade de Hatsu." % slot_id
	if EventBus != null and EventBus.has_signal("toast_enviado"):
		EventBus.emit_toast(msg, Color(1.0, 0.85, 0.3))
	elif get_tree() != null:
		print("[NOTIFICAÇÃO] ", msg)


func _formatar_tempo(segundos: int) -> String:
	var m: int = segundos / 60
	var s: int = segundos % 60
	return "%02d:%02d" % [m, s]


# ============================================================
# 9. PERSISTÊNCIA SERIALIZÁVEL & MIGRAÇÃO (SCHEMA V3)
# ============================================================

func serializar() -> Dictionary:
	var arch_ser: Array = []
	for h in archive:
		if h != null and h.has_method("to_dict"):
			arch_ser.append(h.to_dict())

	return {
		"version": 3,
		"unlocked_slots": unlocked_slots.duplicate(),
		"active_slots_map": active_slots_map.duplicate(),
		"last_creation_timestamp": last_creation_timestamp,
		"slot_switch_timestamps": slot_switch_timestamps.duplicate(),
		"archive": arch_ser
	}


func deserializar(data: Dictionary) -> void:
	var ver: int = int(data.get("version", 1))

	# 1. Carregar Slots Desbloqueados
	if data.has("unlocked_slots") and data["unlocked_slots"] is Dictionary:
		for k in data["unlocked_slots"].keys():
			unlocked_slots[int(k)] = bool(data["unlocked_slots"][k])

	# 2. Carregar Timestamps
	last_creation_timestamp = int(data.get("last_creation_timestamp", 0))
	if data.has("slot_switch_timestamps") and data["slot_switch_timestamps"] is Dictionary:
		for k in data["slot_switch_timestamps"].keys():
			slot_switch_timestamps[int(k)] = int(data["slot_switch_timestamps"][k])

	# 3. Carregar Archive (Schema V3) ou Migrar (Schema V1/V2)
	archive.clear()
	if data.has("archive") and data["archive"] is Array:
		for hd in data["archive"]:
			if hd is Dictionary:
				archive.append(HatsuData.from_dict(hd))
	elif PlayerData != null and not PlayerData.hatsu_criados.is_empty():
		# Migração segura de saves legados
		print("[HatsuProgressionManager] 🔄 Migrando saves legados para o Hatsu Archive v3...")
		for old_h in PlayerData.hatsu_criados:
			if old_h is HatsuData:
				if old_h.hatsu_id.is_empty():
					old_h.gerar_novo_id()
				if archive.size() < HatsuConfig.MAX_ARCHIVE_SLOTS:
					archive.append(old_h)

	# 4. Carregar Mapeamento de Slots Ativos
	if data.has("active_slots_map") and data["active_slots_map"] is Dictionary:
		for k in data["active_slots_map"].keys():
			active_slots_map[int(k)] = str(data["active_slots_map"][k])
	elif PlayerData != null and not PlayerData.hatsu_slots.is_empty():
		# Migrar array [0, 1, -1, -1] para IDs do Archive
		for i in range(min(PlayerData.hatsu_slots.size(), 4)):
			var s_idx: int = PlayerData.hatsu_slots[i]
			if s_idx >= 0 and s_idx < archive.size():
				active_slots_map[i + 1] = archive[s_idx].hatsu_id
			else:
				active_slots_map[i + 1] = ""

	revalidate_all_slots()
