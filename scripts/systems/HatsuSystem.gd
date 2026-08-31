class_name HatsuSystem
extends Node

const HatsuVisual = preload("res://scripts/visual/HatsuVisual.gd")

# ============================================================
# HUNTER ONLINE - HATSU SYSTEM (MOTOR DE COMBATE E VOWS)
# ============================================================
#
# Gerencia a execução de todas as habilidades Hatsu nos 4 slots.
# Suporta todos os Objetivos (Dano, Defesa, Cura, Mobilidade, Controle)
# e processa em tempo real os Juramentos do Mangá e IA de Nen:
# - Colheita de Almas (Abates acumulam cargas)
# - Pain Packer (Dano sofrido multiplica potência)
# - Oração de Netero (Canalização de reverência)
# - Voto da Revelação (Balão de fala técnico)
# - Chain Jail (Restrição contra Boss/Elites)
# - Escudos Reativos com elementos e cura celular
#
# ============================================================

signal hatsu_executado(slot: int, hatsu: HatsuData)
signal hatsu_desativado(slot: int, hatsu: HatsuData)
signal hatsu_falhou(slot: int, motivo: String)
signal hatsu_estado_alterado(slot: int, novo_estado: int)
signal cooldown_atualizado(slot: int, restante: float, total: float)
signal escudo_alterado(atual: float, maximo: float)
signal almas_atualizadas(slot: int, total_almas: int)

enum SlotState {
	EQUIPPED,   # Alocado no slot, inicializando
	READY,      # Pronto para ativação imediata
	ACTIVATING, # Em canalização ou postura de disparo
	ACTIVE,     # Sustentado em execução ativa (drenando aura / aplicando bônus)
	COOLDOWN,   # Em tempo de recarga
	DISABLED    # Temporariamente bloqueado por incompatibilidade com estado ativo
}

const ComicBalloon = preload("res://scripts/ui/ComicBalloon.gd")
const CombatComicQuotes = preload("res://resource/dialogue/CombatComicQuotes.gd")

var owner_body: CharacterBody2D = null
var nen_system: NenSystem = null
var combat_system: HunterCombatSystem = null

# Estados e Cooldowns por slot
var slot_states: Array[SlotState] = [SlotState.READY, SlotState.READY, SlotState.READY, SlotState.READY]
var slot_cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0]
var slot_cooldowns_max: Array[float] = [0.0, 0.0, 0.0, 0.0]

# Habilidades Sustentadas e Transformações Ativas
var active_sustained_hatsus: Array[Dictionary] = [] # [{"slot": int, "hatsu": HatsuData, "timer": float, "is_active": bool}]

# Escudo Ativo
var escudo_ativo: float = 0.0
var escudo_maximo: float = 0.0
var escudo_timer: float = 0.0
var escudo_elemento: HatsuData.Elemento = HatsuData.Elemento.NEN_PURO
var escudo_node_visual: Node2D = null

# Restrições e buffs ativos
var imobilizado_timer: float = 0.0
var bloquear_ataques_timer: float = 0.0
var bloqueio_esquiva_timer: float = 0.0
var zetsu_forcado_timer: float = 0.0
var bloqueio_nen_timer: float = 0.0
var pos_esquiva_timer: float = 0.0
var godspeed_timer: float = 0.0
var dor_recente_buffer: float = 0.0
var timer_resfriamento_dor: float = 0.0

# Rastreamento de Movimento & Combate
var tempo_imovel_atual: float = 0.0
var tempo_corrida_atual: float = 0.0
var primeiro_atacante_id: StringName = &""
var combo_buffer: Array[String] = []
var combo_timer: float = 0.0

# Snapshots Vitais para Rollback Temporal (Especialização)
var vital_snapshots: Array[Dictionary] = [] # [{"time": float, "hp": int, "aura": float}]
var snapshot_timer: float = 0.0


func _ready() -> void:
	add_to_group("hatsu_system")
	# Conectar ao sistema global de mortes de inimigos para Colheita de Almas e Devour
	var tree = get_tree()
	if tree != null:
		call_deferred("_conectar_eventos_globais")


func setup(body: CharacterBody2D) -> void:
	owner_body = body
	nen_system = owner_body.get_node_or_null("NenSystem") as NenSystem
	combat_system = owner_body.get_node_or_null("CombatSystem") as HunterCombatSystem


func _process(delta: float) -> void:
	_atualizar_timers(delta)
	_processar_snapshots_vitais(delta)
	_processar_input()


func _processar_snapshots_vitais(delta: float) -> void:
	snapshot_timer += delta
	if snapshot_timer >= 0.5:
		snapshot_timer = 0.0
		vital_snapshots.append({
			"time": Time.get_ticks_msec() / 1000.0,
			"hp": int(PlayerData.attributes.get("vida", 100)),
			"aura": float(PlayerData.attributes.get("aura", 100.0))
		})
		if vital_snapshots.size() > 24: # Mantém últimos 12 segundos de snapshots
			vital_snapshots.pop_front()


func _atualizar_timers(delta: float) -> void:
	# 1. Atualizar Cooldowns
	for i in range(4):
		if slot_cooldowns[i] > 0.0:
			slot_cooldowns[i] -= delta
			if slot_cooldowns[i] <= 0.0:
				slot_cooldowns[i] = 0.0
				if slot_states[i] == SlotState.COOLDOWN:
					_definir_estado_slot(i, SlotState.READY)
			cooldown_atualizado.emit(i, slot_cooldowns[i], slot_cooldowns_max[i])

	# 2. Processar Dreno e Duração de Habilidades Sustentadas Ativas
	var slots_para_desativar: Array[int] = []
	for entry in active_sustained_hatsus:
		var s_idx: int = entry.get("slot", -1)
		var h_data: HatsuData = entry.get("hatsu", null)
		if h_data == null:
			continue

		# Dreno contínuo de Aura por segundo
		if h_data.aura_drain_per_sec > 0.0:
			var drain: float = h_data.aura_drain_per_sec * delta
			var aura_paga: bool = true
			if nen_system != null:
				aura_paga = nen_system.gastar_aura_float(drain)
			else:
				var a_cur = float(PlayerData.attributes.get("aura", 0.0))
				if a_cur >= drain:
					PlayerData.attributes["aura"] = a_cur - drain
				else:
					aura_paga = false

			if not aura_paga:
				slots_para_desativar.append(s_idx)
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("⚡ AURA DE %s ESGOTADA!" % h_data.nome.to_upper(), Color(1.0, 0.4, 0.4))
				continue

		# Duração temporizada
		if entry.get("timer", 0.0) > 0.0:
			entry["timer"] -= delta
			if entry["timer"] <= 0.0:
				slots_para_desativar.append(s_idx)

	for s_deact in slots_para_desativar:
		desativar_hatsu_sustentado(s_deact)

	# 3. Avaliar Matriz de Compatibilidade Dinâmica para Slots Prontos
	_reavaliar_compatibilidade_slots()

	# Escudo
	if escudo_timer > 0.0:
		escudo_timer -= delta
		if escudo_timer <= 0.0:
			escudo_ativo = 0.0
			escudo_maximo = 0.0
			escudo_timer = 0.0
			if is_instance_valid(escudo_node_visual):
				escudo_node_visual.queue_free()
			escudo_alterado.emit(0.0, 0.0)

	# Imobilização (Oração de Netero / Canalização)
	if imobilizado_timer > 0.0:
		imobilizado_timer -= delta
		if imobilizado_timer <= 0.0:
			imobilizado_timer = 0.0

	# Bloqueios de Ações
	if bloquear_ataques_timer > 0.0:
		bloquear_ataques_timer -= delta
		if bloquear_ataques_timer <= 0.0:
			bloquear_ataques_timer = 0.0

	if bloqueio_esquiva_timer > 0.0:
		bloqueio_esquiva_timer -= delta
		if bloqueio_esquiva_timer <= 0.0:
			bloqueio_esquiva_timer = 0.0

	if zetsu_forcado_timer > 0.0:
		zetsu_forcado_timer -= delta
		if zetsu_forcado_timer <= 0.0:
			zetsu_forcado_timer = 0.0
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("✨ ZETSU ENCERRADO: NEN REATIVADO", Color(0.4, 1.0, 0.6))

	if bloqueio_nen_timer > 0.0:
		bloqueio_nen_timer -= delta
		if bloqueio_nen_timer <= 0.0:
			bloqueio_nen_timer = 0.0

	if pos_esquiva_timer > 0.0:
		pos_esquiva_timer -= delta
		if pos_esquiva_timer <= 0.0:
			pos_esquiva_timer = 0.0

	# Combo Buffer Timer
	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_buffer.clear()

	# Godspeed
	if godspeed_timer > 0.0:
		godspeed_timer -= delta
		if godspeed_timer <= 0.0:
			godspeed_timer = 0.0

	# Decaimento gradual da dor acumulada para o Pain Packer
	if timer_resfriamento_dor > 0.0:
		timer_resfriamento_dor -= delta
	else:
		if dor_recente_buffer > 0.0:
			dor_recente_buffer = max(0.0, dor_recente_buffer - (20.0 * delta))

	# Rastreamento de Movimento
	if owner_body != null:
		if owner_body.velocity.length() < 5.0:
			tempo_imovel_atual += delta
			tempo_corrida_atual = 0.0
		else:
			tempo_corrida_atual += delta
			tempo_imovel_atual = 0.0


func _reavaliar_compatibilidade_slots() -> void:
	for i in range(4):
		# Não mexer em slots em execução ativa, canalizando ou em cooldown
		if slot_states[i] == SlotState.ACTIVE or slot_states[i] == SlotState.ACTIVATING:
			continue
		if slot_cooldowns[i] > 0.0:
			_definir_estado_slot(i, SlotState.COOLDOWN)
			continue

		var h_slot = PlayerData.obter_hatsu_slot(i)
		if h_slot == null:
			_definir_estado_slot(i, SlotState.EQUIPPED)
			continue

		var ctx := {
			"in_zetsu": zetsu_forcado_timer > 0.0,
			"nen_blocked": bloqueio_nen_timer > 0.0,
			"aura": float(PlayerData.attributes.get("aura", 100.0)),
			"cooldown": slot_cooldowns[i]
		}
		var check = HatsuManager.can_activate(h_slot, active_sustained_hatsus, ctx)
		if check.get("allowed", true):
			_definir_estado_slot(i, SlotState.READY)
		else:
			# Se o bloqueio for por incompatibilidade de canal/transformação
			if check.get("conflicting", "") != "" and check.get("conflicting") != "Aura" and check.get("conflicting") != "Cooldown":
				_definir_estado_slot(i, SlotState.DISABLED)
			else:
				_definir_estado_slot(i, SlotState.READY)


func _definir_estado_slot(slot: int, novo_estado: SlotState) -> void:
	if slot < 0 or slot >= slot_states.size():
		return
	if slot_states[slot] != novo_estado:
		slot_states[slot] = novo_estado
		hatsu_estado_alterado.emit(slot, novo_estado)


func obter_estado_slot(slot: int) -> SlotState:
	if slot >= 0 and slot < slot_states.size():
		return slot_states[slot]
	return SlotState.EQUIPPED


func desativar_hatsu_sustentado(slot_index: int) -> void:
	var hatsu_desativado_ref: HatsuData = null
	for i in range(active_sustained_hatsus.size() - 1, -1, -1):
		if active_sustained_hatsus[i].get("slot", -1) == slot_index:
			hatsu_desativado_ref = active_sustained_hatsus[i].get("hatsu", null)
			active_sustained_hatsus.remove_at(i)

	if hatsu_desativado_ref != null:
		# Resetar flags de quests/modos
		if hatsu_desativado_ref.nome.contains("Godspeed") or hatsu_desativado_ref.nome.contains("Kanmuru"):
			PlayerData.quest_states["godspeed_ativo"] = false
			godspeed_timer = 0.0
		elif hatsu_desativado_ref.nome.contains("Guanyin") or hatsu_desativado_ref.nome.contains("Bodhisattva"):
			PlayerData.quest_states["guanyin_bodhisattva_ativo"] = false
		elif hatsu_desativado_ref.nome.contains("Emperor Time"):
			PlayerData.quest_states["emperor_time_ativo"] = false

		# Iniciar Cooldown
		var cd: float = hatsu_desativado_ref.obter_cooldown_final()
		slot_cooldowns[slot_index] = cd
		slot_cooldowns_max[slot_index] = cd
		_definir_estado_slot(slot_index, SlotState.COOLDOWN)
		hatsu_desativado.emit(slot_index, hatsu_desativado_ref)
		print("[HatsuSystem] 🛑 Habilidade sustentada desativada: %s (Slot %d)" % [hatsu_desativado_ref.nome, slot_index + 1])


func esta_imobilizado() -> bool:
	return imobilizado_timer > 0.0


func esta_godspeed() -> bool:
	return godspeed_timer > 0.0


func ataques_bloqueados() -> bool:
	return bloquear_ataques_timer > 0.0


func esquivas_bloqueadas() -> bool:
	return bloqueio_esquiva_timer > 0.0 or imobilizado_timer > 0.0


func zetsu_forcado_ativo() -> bool:
	return zetsu_forcado_timer > 0.0


func nen_bloqueado() -> bool:
	return bloqueio_nen_timer > 0.0 or zetsu_forcado_timer > 0.0


# ============================================================
# EVENTOS DE JURAMENTOS EM TEMPO REAL (ALMAS & DOR)
# ============================================================

func _conectar_eventos_globais() -> void:
	var tree = get_tree()
	if tree == null:
		return
	for es in tree.get_nodes_in_group("enemy_systems"):
		if is_instance_valid(es) and es.has_signal("died") and not es.died.is_connected(_on_enemy_killed):
			es.died.connect(_on_enemy_killed)


func _on_enemy_killed(_enemy_type: StringName = &"") -> void:
	var alimentou_algum: bool = false

	for i in range(4):
		var h: HatsuData = PlayerData.obter_hatsu_slot(i)
		if h == null:
			continue

		# 1. Almas de Inimigos (Tier 1)
		if HatsuData.Condicao.ALMAS_INIMIGOS in h.condicoes or h.vow_custom_cat == "ALMAS":
			if h.almas_acumuladas < 10:
				h.almas_acumuladas += 1
				alimentou_algum = true
				almas_atualizadas.emit(i, h.almas_acumuladas)
				print("[Hatsu Almas] Slot %d (%s) absorveu uma alma! Total: %d" % [i + 1, h.nome, h.almas_acumuladas])

		# 2. Devour / Absorção de Status Permanente (Especialização)
		if h.core_component == HatsuComponentLibrary.CoreType.ABSORPTION or HatsuComponentLibrary.ConditionType.ENEMY_DEFEATED in h.modular_conditions:
			var e_info = {
				"enemy_id": str(_enemy_type),
				"name": str(_enemy_type).replace("_", " ").capitalize(),
				"level": int(PlayerData.attributes.get("nivel", 1)),
				"is_boss": false
			}
			var res_devour = HatsuManager.execute_absorption_devour(h, e_info)
			if res_devour.get("sucesso", false) and combat_system != null:
				combat_system._mostrar_texto_flutuante(res_devour.get("mensagem", ""), Color(0.85, 0.3, 1.0))

	if alimentou_algum and combat_system != null:
		combat_system._mostrar_texto_flutuante("💀 +1 ALMA DE NEN!", Color(0.7, 0.3, 1.0))


func executar_reversao_temporal(segundos_atras: float = 5.0) -> bool:
	var target_time: float = (Time.get_ticks_msec() / 1000.0) - segundos_atras
	var best_snapshot: Dictionary = {}

	for snap in vital_snapshots:
		if snap.get("time", 0.0) <= target_time:
			best_snapshot = snap

	if best_snapshot.is_empty() and not vital_snapshots.is_empty():
		best_snapshot = vital_snapshots.front()

	if not best_snapshot.is_empty():
		var hp_rest: int = int(best_snapshot.get("hp", 100))
		var aura_rest: float = float(best_snapshot.get("aura", 100.0))
		var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
		var aura_max: float = float(PlayerData.attributes.get("aura_max", 100.0))

		PlayerData.attributes["vida"] = clamp(hp_rest, 1, hp_max)
		PlayerData.attributes["aura"] = clamp(aura_rest, 0.0, aura_max)

		if combat_system != null:
			combat_system._mostrar_texto_flutuante("🌀 RETORNO TEMPORAL (+%d HP / +%d AP)" % [hp_rest, int(aura_rest)], Color(0.3, 0.9, 1.0))
		if owner_body != null:
			ComicBalloon.mostrar(owner_body, "🌀 Reversão Temporal de Nen ativada!", 2.2, -40.0)
		return true

	return false


func registrar_dano_sofrido_vow(dano_recebido: int, atacante: Node = null) -> void:
	dor_recente_buffer += float(dano_recebido)
	timer_resfriamento_dor = 10.0 # Mantém o pico por 10s

	if atacante != null:
		var a_id: StringName = &""
		if atacante.has_node("EnemySystem"):
			var es = atacante.get_node("EnemySystem")
			if "enemy_id" in es:
				a_id = es.enemy_id
		if a_id.is_empty():
			a_id = StringName(atacante.name.to_lower())

		if primeiro_atacante_id.is_empty():
			primeiro_atacante_id = a_id
			print("[Hatsu Vow] Primeiro agressor registrado: ", primeiro_atacante_id)

	for i in range(4):
		var h: HatsuData = PlayerData.obter_hatsu_slot(i)
		if h != null and (HatsuData.Condicao.DOR_ACUMULADA in h.condicoes or h.vow_custom_cat == "DOR"):
			h.dor_acumulada = dor_recente_buffer


func registrar_esquiva_perfeita() -> void:
	pos_esquiva_timer = 2.0
	registrar_acao_combo("esquiva")


func registrar_acao_combo(acao: String) -> void:
	combo_buffer.append(acao.to_lower())
	combo_timer = 3.0
	if combo_buffer.size() > 6:
		combo_buffer.pop_front()


func _processar_input() -> void:
	if owner_body == null:
		return

	if Input.is_action_just_pressed("hatsu_slot_1"):
		usar_hatsu(0)
	elif Input.is_action_just_pressed("hatsu_slot_2"):
		usar_hatsu(1)
	elif Input.is_action_just_pressed("hatsu_slot_3"):
		usar_hatsu(2)
	elif Input.is_action_just_pressed("hatsu_slot_4"):
		usar_hatsu(3)


# ============================================================
# EXECUÇÃO DE HATSU
# ============================================================

func usar_hatsu(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= 4:
		return false

	var hatsu: HatsuData = PlayerData.obter_hatsu_slot(slot_index)
	if hatsu == null:
		hatsu_falhou.emit(slot_index, "Nenhum Hatsu equipado")
		return false

	# Se a habilidade já estiver ativa e for sustentada, desativar ao pressionar novamente (Toggle Off)
	if slot_states[slot_index] == SlotState.ACTIVE:
		desativar_hatsu_sustentado(slot_index)
		if combat_system != null:
			combat_system._mostrar_texto_flutuante("🛑 %s DESATIVADO" % hatsu.nome.to_upper(), Color(0.8, 0.8, 0.9))
		return true

	# Montar Contexto do Jogador
	var em_ten: bool = false
	var em_ren: bool = false
	if nen_system != null:
		em_ten = nen_system.tecnica_ativa(NenSystem.Tecnica.TEN)
		em_ren = nen_system.tecnica_ativa(NenSystem.Tecnica.REN)

	var player_ctx: Dictionary = {
		"hp": int(PlayerData.attributes["vida"]),
		"hp_max": int(PlayerData.attributes["vida_max"]),
		"aura": float(PlayerData.attributes.get("aura", 100.0)),
		"aura_max": float(PlayerData.attributes.get("aura_max", 100.0)),
		"em_ten": em_ten,
		"em_ren": em_ren,
		"pos_esquiva_recente": pos_esquiva_timer > 0.0,
		"primeiro_atacante_id": primeiro_atacante_id,
		"tempo_imovel": tempo_imovel_atual,
		"tempo_corrida": tempo_corrida_atual
	}

	# Montar Contexto do Alvo mais próximo
	var target_ctx: Dictionary = {}
	var enemies = get_tree().get_nodes_in_group("enemies") if get_tree() else []
	var menor_dist: float = 9999.0
	var alvo_prox: CharacterBody2D = null
	for e in enemies:
		if e is CharacterBody2D and is_instance_valid(e) and owner_body != null:
			var d: float = owner_body.global_position.distance_to(e.global_position)
			if d < menor_dist:
				menor_dist = d
				alvo_prox = e

	if alvo_prox != null:
		var es = alvo_prox.get_node_or_null("EnemySystem")
		target_ctx["distance"] = menor_dist
		if es != null:
			target_ctx["enemy_id"] = es.enemy_id
			target_ctx["is_boss"] = es.is_boss or (es.enemy_data != null and es.enemy_data.is_boss)
		else:
			target_ctx["enemy_id"] = StringName(alvo_prox.name.to_lower())
			target_ctx["is_boss"] = false

	# Avaliar Matriz de Compatibilidade via HatsuManager
	var custo_aura: float = hatsu.obter_custo_final()
	if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
		custo_aura *= 0.60
	elif PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.EMISSAO:
		custo_aura *= 0.80

	var check_ctx: Dictionary = {
		"in_zetsu": zetsu_forcado_timer > 0.0,
		"nen_blocked": bloqueio_nen_timer > 0.0,
		"aura": float(PlayerData.attributes.get("aura", 100.0)),
		"cooldown": slot_cooldowns[slot_index],
		"player_context": player_ctx,
		"target_context": target_ctx,
		"is_skill_hunter_override": (hatsu.arquetipo == HatsuData.Arquetipo.LIVRO_COLECAO or hatsu.activation_type == HatsuData.ActivationType.OVERRIDE_LIBRARY)
	}

	var compat_check: Dictionary = HatsuManager.can_activate(hatsu, active_sustained_hatsus, check_ctx)
	if not compat_check.get("allowed", true):
		var motivo: String = compat_check.get("reason", "Habilidade não pode ser ativada")
		hatsu_falhou.emit(slot_index, motivo)
		if combat_system != null:
			combat_system._mostrar_texto_flutuante(motivo, Color(1.0, 0.4, 0.4))
		return false

	# Gastar Aura Inicial
	if nen_system != null:
		if not nen_system.gastar_aura_float(custo_aura):
			hatsu_falhou.emit(slot_index, "Aura insuficiente!")
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("Aura insuficiente!", Color(1.0, 0.4, 0.4))
			return false
	else:
		var a_cur = float(PlayerData.attributes.get("aura", 0.0))
		PlayerData.attributes["aura"] = max(0.0, a_cur - custo_aura)

	# Aplicar penalidades e efeitos dos Juramentos (Oração, Revelação, Troca Vital, etc.)
	_aplicar_efeitos_juramentos(hatsu)

	# Calcular Eficiência de Nen (Hexágono de Afinidade)
	var eficiencia: float = NenAffinityData.calcular_eficiencia_categoria(PlayerData.afinidade_nen, hatsu.categoria)

	# Cooldown base
	var cd: float = hatsu.obter_cooldown_final()
	if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
		cd *= 0.75

	# Transição de Estado do Slot
	var is_sustained: bool = (hatsu.activation_type in [HatsuData.ActivationType.SUSTAINED, HatsuData.ActivationType.TRANSFORMATION, HatsuData.ActivationType.OVERRIDE_LIBRARY])
	if is_sustained:
		active_sustained_hatsus.append({
			"slot": slot_index,
			"hatsu": hatsu,
			"timer": hatsu.duracao,
			"is_active": true
		})
		slot_cooldowns[slot_index] = 0.0
		slot_cooldowns_max[slot_index] = cd
		_definir_estado_slot(slot_index, SlotState.ACTIVE)
	else:
		slot_cooldowns[slot_index] = cd
		slot_cooldowns_max[slot_index] = cd
		_definir_estado_slot(slot_index, SlotState.COOLDOWN)

	# Executar habilidade por Objetivo & Categoria
	_executar_por_objetivo(hatsu, eficiencia)

	# Balão de fala estilo quadrinho
	if owner_body != null:
		var fala: String = ""
		if HatsuData.Condicao.REVELACAO_HABILIDADE in hatsu.condicoes or hatsu.vow_custom_cat == "REVELACAO":
			fala = "VOTO DA REVELAÇÃO: Observe meu %s!" % hatsu.nome
		elif HatsuData.Condicao.ORACAO_GRATIDAO in hatsu.condicoes:
			fala = "10.000 Golpes de Gratidão... %s!" % hatsu.nome
		else:
			fala = CombatComicQuotes.obter_frase_hatsu(hatsu.nome)
		ComicBalloon.mostrar(owner_body, fala, 2.2, -42.0)

	# Limpar cargas de almas após descarga bem sucedida
	if HatsuData.Condicao.ALMAS_INIMIGOS in hatsu.condicoes or hatsu.vow_custom_cat == "ALMAS":
		if hatsu.almas_acumuladas > 0:
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("💥 %d ALMAS LIBERADAS!" % hatsu.almas_acumuladas, Color(0.9, 0.2, 1.0))
			hatsu.almas_acumuladas = 0
			almas_atualizadas.emit(slot_index, 0)

	hatsu_executado.emit(slot_index, hatsu)
	registrar_acao_combo("hatsu")
	var subiu_nivel: bool = hatsu.adicionar_xp_evolucao(15)
	if subiu_nivel and combat_system != null:
		combat_system._mostrar_texto_flutuante("⭐ %s EVOLUIU PARA LV.%d!" % [hatsu.nome, hatsu.nivel_evolucao_hatsu], Color(1.0, 0.85, 0.2))

	print("=================================")
	print("[HatsuSystem] Executou com sucesso: ", hatsu.nome, " (Lv. ", hatsu.nivel_evolucao_hatsu, ")")
	print("OBJETIVO: ", hatsu.objetivo, " | EFICIÊNCIA: ", int(eficiencia * 100), "% | ARQUÉTIPO: ", HatsuData.obter_nome_arquetipo(hatsu.arquetipo))
	print("=================================")
	return true


func _aplicar_efeitos_juramentos(hatsu: HatsuData) -> void:
	for cond in hatsu.condicoes:
		match cond:
			HatsuData.Condicao.AUTO_DANO:
				var hp_max: int = int(PlayerData.attributes["vida_max"])
				var auto_dano: int = max(1, int(hp_max * 0.10))
				var hp_atual: int = int(PlayerData.attributes["vida"])
				PlayerData.attributes["vida"] = max(1, hp_atual - auto_dano)
				print("[Hatsu Vow] Sacrifício Vital: -", auto_dano, " HP")
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("🩸 PACTO DE SANGUE -%d HP" % auto_dano, Color(1.0, 0.2, 0.2))

			HatsuData.Condicao.AUTO_DANO_30_SANGUE:
				var hp_max: int = int(PlayerData.attributes["vida_max"])
				var auto_dano: int = max(1, int(hp_max * 0.30))
				var hp_atual: int = int(PlayerData.attributes["vida"])
				PlayerData.attributes["vida"] = max(1, hp_atual - auto_dano)
				print("[Hatsu Vow] Grande Sacrifício: -", auto_dano, " HP")
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("🩸 GRANDE SACRIFÍCIO -%d HP" % auto_dano, Color(1.0, 0.1, 0.1))

			HatsuData.Condicao.DRENO_TOTAL_AURA:
				PlayerData.attributes["aura"] = 0.0
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("⚡ ZERO KO: AURA TOTAL ESGOTADA!", Color(1.0, 0.85, 0.2))

			HatsuData.Condicao.ZETSU_POS_USO_15S:
				zetsu_forcado_timer = 15.0
				if nen_system != null:
					nen_system.desativar_todas()
					nen_system.ativar_tecnica(NenSystem.Tecnica.ZETSU)
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("💤 ZETSU FORÇADO (15s)", Color(0.6, 0.6, 0.8))

			HatsuData.Condicao.BLOQUEIO_NEN_10S:
				bloqueio_nen_timer = 10.0
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("⚠️ NEN BLOQUEADO (10s)", Color(1.0, 0.5, 0.2))

			HatsuData.Condicao.PARADO_CANALIZACAO, HatsuData.Condicao.IMOVEL_DURANTE_USO:
				imobilizado_timer = 1.5
				if owner_body != null:
					owner_body.velocity = Vector2.ZERO
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("⚓ POSTURA INAMOVÍVEL", Color(1.0, 0.85, 0.3))

			HatsuData.Condicao.ORACAO_GRATIDAO:
				imobilizado_timer = 0.7
				if owner_body != null:
					owner_body.velocity = Vector2.ZERO
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("🙏 ORAÇÃO DE GRATIDÃO", Color(1.0, 0.9, 0.3))

			HatsuData.Condicao.NAO_VIOLENCIA:
				bloquear_ataques_timer = hatsu.duracao
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("🛡️ DEFESA PACÍFICA ATIVA", Color(0.3, 0.8, 1.0))

			HatsuData.Condicao.NAO_ESQUIVAR_DURANTE_EFEITO:
				bloqueio_esquiva_timer = hatsu.duracao
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("🚫 ESQUIVA BLOQUEADA", Color(1.0, 0.4, 0.4))

			HatsuData.Condicao.USO_UNICO_POR_COMBATE, HatsuData.Condicao.VOTO_ABSOLUTO_CHAIN:
				hatsu.usado_no_combate_atual = true


# ============================================================
# ROTEAMENTO PRINCIPAL POR OBJETIVO E ARQUÉTIPO
# ============================================================

func _executar_por_objetivo(hatsu: HatsuData, eficiencia: float) -> void:
	# 1. Verificar Core Component Modular (Hatsu Creator Definitivo)
	match hatsu.core_component:
		HatsuComponentLibrary.CoreType.MEMORY_ROLLBACK:
			executar_reversao_temporal(hatsu.rollback_seconds)
			return
		HatsuComponentLibrary.CoreType.ABSORPTION:
			_executar_absorcao_ativa(hatsu, eficiencia)
			return
		HatsuComponentLibrary.CoreType.RULE_ZONE:
			_executar_territorio_en(hatsu, eficiencia)
			return
		HatsuComponentLibrary.CoreType.EXCHANGE:
			_executar_troca_recursos(hatsu, eficiencia)
			return
		HatsuComponentLibrary.CoreType.BARRIER:
			_executar_defesa(hatsu, eficiencia)
			return

	# 2. Verificar se é um Arquétipo Especial Legado
	match hatsu.arquetipo:
		HatsuData.Arquetipo.ARSENAL_ROLETA:
			_executar_arsenal_roleta(hatsu, eficiencia)
			return
		HatsuData.Arquetipo.OBJETO_MOEDA:
			_executar_objeto_moeda(hatsu, eficiencia)
			return
		HatsuData.Arquetipo.OBJETO_CARTAS:
			_executar_objeto_cartas(hatsu, eficiencia)
			return
		HatsuData.Arquetipo.OBJETO_DADO:
			_executar_objeto_dado(hatsu, eficiencia)
			return
		HatsuData.Arquetipo.TERRITORIO_EN:
			_executar_territorio_en(hatsu, eficiencia)
			return
		HatsuData.Arquetipo.MARCA_TAG:
			_executar_marca_tag(hatsu, eficiencia)
			return
		HatsuData.Arquetipo.TROCA_SACRIFICIO:
			_executar_troca_recursos(hatsu, eficiencia)
			return
		HatsuData.Arquetipo.LIVRO_COLECAO:
			_executar_livro_colecao(hatsu, eficiencia)
			return

	# 3. Execução Padrão por Objetivo
	match hatsu.objetivo:
		HatsuData.ObjetivoPrincipal.DEFESA:
			_executar_defesa(hatsu, eficiencia)
		HatsuData.ObjetivoPrincipal.CURA:
			_executar_cura(hatsu, eficiencia)
		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			_executar_mobilidade(hatsu, eficiencia)
		HatsuData.ObjetivoPrincipal.CONTROLE:
			_executar_controle(hatsu, eficiencia)
		HatsuData.ObjetivoPrincipal.SUPORTE:
			_executar_defesa(hatsu, eficiencia)
		HatsuData.ObjetivoPrincipal.DANO, _:
			_executar_dano_categorizado(hatsu, eficiencia)


func _executar_absorcao_ativa(hatsu: HatsuData, _eficiencia: float) -> void:
	if owner_body == null: return
	var enemies = get_tree().get_nodes_in_group("enemies") if get_tree() else []
	var menor_dist: float = 90.0
	var alvo_proximo: CharacterBody2D = null
	for e in enemies:
		if e is CharacterBody2D and is_instance_valid(e) and e != owner_body:
			var d = owner_body.global_position.distance_to(e.global_position)
			if d < menor_dist:
				menor_dist = d
				alvo_proximo = e

	var e_info = {"enemy_id": "enemy_target", "name": "Inimigo", "level": int(PlayerData.attributes.get("nivel", 1)), "is_boss": false}
	if alvo_proximo != null:
		e_info["enemy_id"] = alvo_proximo.name
		e_info["name"] = alvo_proximo.name
		var es = alvo_proximo.get_node_or_null("EnemySystem")
		if es != null and "enemy_data" in es and es.enemy_data != null:
			e_info["level"] = es.enemy_data.level
			e_info["is_boss"] = es.enemy_data.is_boss
			e_info["name"] = es.enemy_data.enemy_name

	var res = HatsuManager.execute_absorption_devour(hatsu, e_info)
	if combat_system != null:
		combat_system._mostrar_texto_flutuante(res.get("mensagem", "Absorção executada!"), Color(0.85, 0.3, 1.0))


# ============================================================
# EXECUTORES DOS 10 GRANDES ARQUÉTIPOS
# ============================================================

func _aplicar_dano_area_imediato(hatsu: HatsuData, dano_val: int, raio_val: float) -> void:
	if owner_body == null: return

	var enemies = get_tree().get_nodes_in_group("enemies") if get_tree() else []
	for e in enemies:
		if e is CharacterBody2D and is_instance_valid(e) and e != owner_body:
			var dist: float = owner_body.global_position.distance_to(e.global_position)
			if dist <= raio_val:
				var enemy_sys = e.get_node_or_null("EnemySystem")
				if enemy_sys != null and enemy_sys.has_method("take_damage"):
					var dir: Vector2 = (e.global_position - owner_body.global_position).normalized()
					enemy_sys.take_damage(dano_val, dir, 200.0, owner_body)
					print("[Hatsu Dano Área] Atingiu ", e.name, " com Dano: ", dano_val)


func _aplicar_dano_toque_imediato(hatsu: HatsuData, dano_val: int, dir_atk: Vector2, alcance_val: float) -> void:
	if owner_body == null: return

	var enemies = get_tree().get_nodes_in_group("enemies") if get_tree() else []
	for e in enemies:
		if e is CharacterBody2D and is_instance_valid(e) and e != owner_body:
			var dist: float = owner_body.global_position.distance_to(e.global_position)
			if dist <= alcance_val:
				var enemy_sys = e.get_node_or_null("EnemySystem")
				if enemy_sys != null and enemy_sys.has_method("take_damage"):
					enemy_sys.take_damage(dano_val, dir_atk, 220.0, owner_body)
					print("[Hatsu Golpe Toque] Atingiu ", e.name, " com Dano: ", dano_val)


func _executar_arsenal_roleta(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null: return

	var armas: Array[Dictionary] = hatsu.armas_roleta
	if armas.is_empty():
		armas = [
			{"nome": "Foice Silenciosa", "dano_mult": 1.6, "tipo": "AREA", "raio": 80.0},
			{"nome": "Lança Perfurante", "dano_mult": 1.4, "tipo": "PROJETIL", "alcance": 180.0},
			{"nome": "Espada de Ko", "dano_mult": 1.3, "tipo": "TOQUE", "alcance": 45.0}
		]

	var sorteada: Dictionary = armas[randi() % armas.size()]
	hatsu.arma_roleta_atual = sorteada
	var arma_nome: String = sorteada.get("nome", "Arma de Nen")
	var dano_mult: float = float(sorteada.get("dano_mult", 1.3))

	if combat_system != null:
		combat_system._mostrar_texto_flutuante("🎲 CRAZY SLOTS: [%s]!" % arma_nome, Color(1.0, 0.85, 0.2))

	ComicBalloon.mostrar(owner_body, "🎲 Sorteou: %s!" % arma_nome, 2.0, -38.0)

	var dano_calculado: int = int(hatsu.obter_poder_final() * dano_mult * eficiencia)
	var tipo_arma: String = sorteada.get("tipo", "TOQUE")

	match tipo_arma:
		"AREA":
			var fx := HatsuAreaExplosionNode.new()
			fx.setup(float(sorteada.get("raio", 75.0)), hatsu.cor_aura)
			owner_body.add_child(fx)
			_aplicar_dano_area_imediato(hatsu, dano_calculado, float(sorteada.get("raio", 75.0)))
		"PROJETIL":
			var dir_proj: Vector2 = combat_system.ultima_direcao if combat_system != null else Vector2.RIGHT
			var proj := HatsuProjectileNode.new()
			proj.setup(owner_body.global_position, dir_proj, float(sorteada.get("alcance", 180.0)), 280.0, dano_calculado, hatsu.cor_aura, owner_body, hatsu)
			owner_body.get_parent().add_child(proj)
		_: # TOQUE
			var dir_atk: Vector2 = combat_system.ultima_direcao if combat_system != null else Vector2.RIGHT
			var fx := HatsuAreaExplosionNode.new()
			fx.setup(float(sorteada.get("raio", 45.0)), hatsu.cor_aura)
			owner_body.add_child(fx)
			_aplicar_dano_toque_imediato(hatsu, dano_calculado, dir_atk, 50.0)


func _executar_objeto_moeda(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null: return

	var is_cara: bool = randf() < 0.5
	var fx := HatsuCoinFlipNode.new()
	fx.setup(owner_body, "CARA" if is_cara else "COROA")
	owner_body.add_child(fx)

	if is_cara:
		godspeed_timer = 6.0
		if combat_system != null:
			combat_system._mostrar_texto_flutuante("🪙 CARA: VELOCIDADE +120!", Color(0.4, 0.9, 1.0))
		ComicBalloon.mostrar(owner_body, "🪙 CARA! Aceleração Máxima!", 2.0, -38.0)
	else:
		var valor_esc: float = 90.0 * eficiencia
		escudo_ativo = valor_esc
		escudo_maximo = valor_esc
		escudo_timer = 6.0
		escudo_alterado.emit(escudo_ativo, escudo_maximo)
		if combat_system != null:
			combat_system._mostrar_texto_flutuante("🪙 COROA: ESCUDO +%d!" % int(valor_esc), Color(1.0, 0.85, 0.2))
		ComicBalloon.mostrar(owner_body, "🪙 COROA! Blindagem Total!", 2.0, -38.0)


func _executar_objeto_cartas(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null: return

	var baralho: Array[Dictionary] = hatsu.cartas_baralho
	if baralho.is_empty():
		baralho = [
			{"naipe": "♥ Copas", "nome": "Cura Celular", "efeito": "CURA", "valor": 60.0},
			{"naipe": "♠ Espadas", "nome": "Lâmina Vorpal", "efeito": "DANO_CRITICO", "valor": 120.0},
			{"naipe": "♦ Ouros", "nome": "Muralha de Diamante", "efeito": "ESCUDO", "valor": 80.0},
			{"naipe": "♣ Paus", "nome": "Passo Supersônico", "efeito": "VELOCIDADE", "valor": 140.0},
			{"naipe": "★ Joker", "nome": "Truque Supremo", "efeito": "SUPREMO", "valor": 180.0}
		]

	var carta: Dictionary = baralho[randi() % baralho.size()]
	var naipe_nome: String = str(carta.get("naipe", "♠ Espadas"))
	var efeito: String = str(carta.get("efeito", "DANO_CRITICO"))
	var valor: float = float(carta.get("valor", 80.0)) * eficiencia

	var fx := HatsuCardDrawNode.new()
	fx.setup(owner_body, naipe_nome)
	owner_body.add_child(fx)

	match efeito:
		"CURA":
			var hp_atual: int = int(PlayerData.attributes.get("vida", 100))
			var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
			PlayerData.attributes["vida"] = min(hp_max, hp_atual + int(valor))
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🃏 %s: +%d HP!" % [naipe_nome, int(valor)], Color(0.2, 1.0, 0.4))
		"ESCUDO":
			escudo_ativo = valor
			escudo_maximo = valor
			escudo_timer = 6.0
			escudo_alterado.emit(escudo_ativo, escudo_maximo)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🃏 %s: ESCUDO +%d!" % [naipe_nome, int(valor)], Color(0.3, 0.8, 1.0))
		"VELOCIDADE":
			godspeed_timer = 5.0
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🃏 %s: VELOCIDADE +%d!" % [naipe_nome, int(valor)], Color(0.9, 0.9, 0.2))
		"SUPREMO":
			var hp_atual: int = int(PlayerData.attributes.get("vida", 100))
			var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
			PlayerData.attributes["vida"] = min(hp_max, hp_atual + 50)
			escudo_ativo = 100.0 * eficiencia
			escudo_maximo = escudo_ativo
			escudo_timer = 8.0
			escudo_alterado.emit(escudo_ativo, escudo_maximo)
			_aplicar_dano_area_imediato(hatsu, int(valor), 110.0)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("★ JOKER SUPREMO ATIVADO!", Color(1.0, 0.2, 0.8))
		_: # DANO_CRITICO
			_aplicar_dano_area_imediato(hatsu, int(valor), 70.0)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🃏 %s: DANO %d!" % [naipe_nome, int(valor)], Color(1.0, 0.4, 0.4))


func _executar_objeto_dado(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null: return

	var face: int = randi_range(1, 6)
	var fx := HatsuDiceRollNode.new()
	fx.setup(owner_body, face)
	owner_body.add_child(fx)

	match face:
		1:
			zetsu_forcado_timer = 5.0
			if nen_system != null:
				nen_system.desativar_todas()
				nen_system.ativar_tecnica(NenSystem.Tecnica.ZETSU)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🎲 FACE 1: ZETSU FORÇADO (5s)!", Color(0.9, 0.2, 0.2))
			ComicBalloon.mostrar(owner_body, "🎲 Face 1... ZETSU FORÇADO!", 2.0, -38.0)
		2:
			var hp_atual: int = int(PlayerData.attributes.get("vida", 100))
			var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
			PlayerData.attributes["vida"] = min(hp_max, hp_atual + 35)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🎲 FACE 2: REGENERAÇÃO +35 HP!", Color(0.3, 1.0, 0.5))
		3:
			escudo_ativo = 60.0 * eficiencia
			escudo_maximo = escudo_ativo
			escudo_timer = 6.0
			escudo_alterado.emit(escudo_ativo, escudo_maximo)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🎲 FACE 3: ESCUDO +60!", Color(0.3, 0.7, 1.0))
		4:
			godspeed_timer = 5.0
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🎲 FACE 4: VELOCIDADE +90!", Color(0.9, 0.9, 0.2))
		5:
			var dano_rajada: int = int(95.0 * eficiencia)
			_aplicar_dano_area_imediato(hatsu, dano_rajada, 80.0)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🎲 FACE 5: RAJADA DE NEN (%d DANO)!" % dano_rajada, Color(1.0, 0.5, 0.2))
		6:
			var dano_supremo: int = int(220.0 * eficiencia)
			var fx_exp := HatsuAreaExplosionNode.new()
			fx_exp.setup(120.0, Color(1.0, 0.9, 0.2, 0.95))
			owner_body.add_child(fx_exp)
			_aplicar_dano_area_imediato(hatsu, dano_supremo, 120.0)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🎲 FACE 6: SUPERNOVA CÓSMICA (%d DANO)!" % dano_supremo, Color(1.0, 0.9, 0.1))
			ComicBalloon.mostrar(owner_body, "🎲 FACE 6! SUPERNOVA DE NEN!", 2.5, -42.0)


func _executar_territorio_en(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null: return

	var fx := HatsuTerritoryZoneNode.new()
	fx.setup(hatsu.territorio_raio, hatsu.cor_aura, 7.0, hatsu.territorio_regra, owner_body, hatsu.obter_poder_final() * eficiencia)
	fx.global_position = owner_body.global_position
	owner_body.get_parent().add_child(fx)

	if combat_system != null:
		combat_system._mostrar_texto_flutuante("🌐 TERRITÓRIO DE EN ATIVO!", hatsu.cor_aura)
	ComicBalloon.mostrar(owner_body, "🌐 Domínio de En Estabelecido!", 2.2, -38.0)


func _executar_marca_tag(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null: return

	hatsu.marca_toques_atual += 1
	if hatsu.marca_toques_atual < hatsu.marca_toques_max:
		if combat_system != null:
			combat_system._mostrar_texto_flutuante("🎯 MARCA %d/%d!" % [hatsu.marca_toques_atual, hatsu.marca_toques_max], Color(1.0, 0.8, 0.2))
	else:
		hatsu.marca_toques_atual = 0
		var dano_detonacao: int = int(hatsu.obter_poder_final() * 2.2 * eficiencia)
		var fx := HatsuAreaExplosionNode.new()
		fx.setup(90.0, Color(1.0, 0.2, 0.1, 0.95))
		owner_body.add_child(fx)
		_aplicar_dano_area_imediato(hatsu, dano_detonacao, 90.0)
		if combat_system != null:
			combat_system._mostrar_texto_flutuante("💥 MARCA DETONADA: %d DANO!" % dano_detonacao, Color(1.0, 0.2, 0.1))
		ComicBalloon.mostrar(owner_body, "💥 COUNTDOWN: DETONAÇÃO TOTAL!", 2.2, -40.0)


func _executar_troca_recursos(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null: return

	var hp_atual: int = int(PlayerData.attributes.get("vida", 100))
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	var auto_dano: int = max(1, int(hp_max * 0.25))
	PlayerData.attributes["vida"] = max(1, hp_atual - auto_dano)

	var dano_troca: int = int(hatsu.obter_poder_final() * 2.0 * eficiencia)
	_aplicar_dano_area_imediato(hatsu, dano_troca, 85.0)

	if combat_system != null:
		combat_system._mostrar_texto_flutuante("🩸 TROCA VITAL (-%d HP ↔ +100%% DANO)" % auto_dano, Color(1.0, 0.1, 0.3))
	ComicBalloon.mostrar(owner_body, "🩸 Sacrifício de Sangue... TROCA VITAL!", 2.2, -40.0)


func _executar_livro_colecao(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null: return

	# 1. Se houver alvo próximo e o Hatsu possuir regras de roubo
	var enemies = get_tree().get_nodes_in_group("enemies") if get_tree() else []
	var menor_dist: float = 9999.0
	var alvo_prox: CharacterBody2D = null
	for e in enemies:
		if e is CharacterBody2D and is_instance_valid(e) and owner_body != null:
			var d: float = owner_body.global_position.distance_to(e.global_position)
			if d < menor_dist:
				menor_dist = d
				alvo_prox = e

	if alvo_prox != null and menor_dist <= 70.0 and (not hatsu.steal_conditions.is_empty() or "roubo" in hatsu.nome.to_lower() or "theft" in hatsu.nome.to_lower()):
		var steal_res = HatsuManager.tentar_roubar_hatsu(owner_body, alvo_prox, hatsu, {
			"distance": menor_dist,
			"toque_realizado": menor_dist <= 50.0,
			"observou_gyo": nen_system != null and nen_system.tecnica_ativa(NenSystem.Tecnica.GYO),
			"alvo_explicou": true,
			"alvo_derrotado": alvo_prox.has_node("EnemySystem") and alvo_prox.get_node("EnemySystem").health <= 0
		})
		if steal_res.get("sucesso", false):
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("📖 HATSU ROUBADO: %s!" % steal_res.hatsu_roubado.nome, Color(0.4, 1.0, 0.6))
			ComicBalloon.mostrar(owner_body, "📖 SKILL HUNTER: %s Roubado!" % steal_res.hatsu_roubado.nome, 2.5, -45.0)
			return

	# 2. Se possuir habilidades armazenadas em PlayerData.stored_hatsus
	if not PlayerData.stored_hatsus.is_empty():
		var stored_entry = PlayerData.stored_hatsus[0]
		var stored_h: HatsuData = stored_entry.get("hatsu_data", null)
		if stored_h != null:
			var ef_stored: float = NenAffinityData.calcular_eficiencia_categoria(PlayerData.afinidade_nen, stored_h.categoria)
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("📖 %s (%d%% EF)" % [stored_h.nome, int(ef_stored * 100)], stored_h.cor_aura)
			ComicBalloon.mostrar(owner_body, "📖 %s: Manifestação do Grimório!" % stored_h.nome, 2.2, -40.0)
			_executar_por_objetivo(stored_h, ef_stored)
			PlayerData.consumir_uso_hatsu_armazenado(0)
			return

	# 3. Fallback para HatsuBookData
	var book: HatsuBookData = hatsu.livro_data
	if book == null:
		book = HatsuManager.criar_livro_hatsu(hatsu.nome)
		hatsu.livro_data = book

	var h_principal: HatsuData = book.obter_hatsu_ativo()
	var h_marcador: HatsuData = book.obter_hatsu_marcador()

	if h_principal == null:
		if combat_system != null:
			combat_system._mostrar_texto_flutuante("📖 O LIVRO ESTÁ VAZIO!", Color(0.8, 0.8, 0.8))
		ComicBalloon.mostrar(owner_body, "📖 Nenhuma habilidade selecionada no Livro!", 2.0, -38.0)
		return

	# Caso Marcador Duplo
	if h_marcador != null and book.permite_marcador_duplo:
		var sinergia: Dictionary = HatsuManager.processar_sinergia_tags(h_principal, h_marcador)
		var nome_combo: String = str(sinergia.get("nome", "Fusão de Nen"))
		var cor_combo: Color = sinergia.get("cor_sinergia", Color(0.9, 0.8, 1.0))
		var bonus_combo: float = float(sinergia.get("dano_bonus", 1.20))

		if combat_system != null:
			combat_system._mostrar_texto_flutuante("📖🔖 %s!" % nome_combo, cor_combo)

		ComicBalloon.mostrar(owner_body, "📖🔖 DUPLO HATSU: %s + %s!" % [h_principal.nome, h_marcador.nome], 2.2, -40.0)

		var ef_p: float = book.obter_eficiencia_pagina(book.pagina_slot_principal, PlayerData.afinidade_nen) * bonus_combo
		var ef_m: float = book.obter_eficiencia_pagina(book.pagina_slot_marcador, PlayerData.afinidade_nen) * bonus_combo

		_executar_por_objetivo(h_principal, ef_p)
		_executar_por_objetivo(h_marcador, ef_m)
		return

	# Caso Página Única
	var ef_final: float = book.obter_eficiencia_pagina(book.pagina_slot_principal, PlayerData.afinidade_nen) * eficiencia
	var pag_info: Dictionary = book.obter_pagina(book.pagina_slot_principal)
	var nome_hab: String = pag_info.get("nome", h_principal.nome)

	if combat_system != null:
		combat_system._mostrar_texto_flutuante("📖 %s (%d%% EF)" % [nome_hab, int(ef_final * 100)], hatsu.cor_aura)

	ComicBalloon.mostrar(owner_body, "📖 %s, manifestar!" % nome_hab, 2.0, -38.0)
	_executar_por_objetivo(h_principal, ef_final)


# ============================================================
# EXECUTOR DE DEFESA (ESCUDOS & ARMADURA DE NEN)
# ============================================================

func _executar_defesa(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null:
		return

	var poder: float = hatsu.obter_poder_final()
	var valor_escudo: float = (hatsu.escudo_base if hatsu.escudo_base > 0.0 else poder * 1.5) * eficiencia
	
	if HatsuData.Condicao.NAO_VIOLENCIA in hatsu.condicoes:
		valor_escudo *= 1.8 # Bônus massivo do voto de não-violência

	escudo_ativo = valor_escudo
	escudo_maximo = valor_escudo
	escudo_timer = hatsu.duracao
	escudo_elemento = hatsu.elemento
	escudo_alterado.emit(escudo_ativo, escudo_maximo)

	# Instanciar Efeito Visual do Escudo de Aura
	if is_instance_valid(escudo_node_visual):
		escudo_node_visual.queue_free()

	var fx := HatsuShieldAuraNode.new()
	var raio_fx: float = hatsu.raio if hatsu.forma == HatsuData.Forma.AREA else 24.0
	fx.setup(raio_fx, hatsu.cor_aura, hatsu.duracao)
	owner_body.add_child(fx)
	escudo_node_visual = fx

	if combat_system != null:
		combat_system._mostrar_texto_flutuante("🛡️ ESCUDO DE NEN +%d" % int(escudo_ativo), hatsu.cor_aura)
	print("[Hatsu Defesa] Escudo criado: ", int(escudo_ativo), " pontos por ", hatsu.duracao, "s")


# ============================================================
# EXECUTOR DE CURA (REGENERAÇÃO BIOLÓGICA CELULAR)
# ============================================================

func _executar_cura(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null:
		return

	var poder: float = hatsu.obter_poder_final()
	var valor_cura: int = max(10, int((hatsu.cura_base if hatsu.cura_base > 0.0 else poder * 1.2) * eficiencia))

	var hp_atual: int = int(PlayerData.attributes.get("vida", 100))
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	PlayerData.attributes["vida"] = min(hp_max, hp_atual + valor_cura)

	# Efeito visual de pulso curativo
	var fx := HatsuHealPulseNode.new()
	fx.setup(hatsu.cor_aura)
	owner_body.add_child(fx)

	if combat_system != null:
		combat_system._mostrar_texto_flutuante("❤️ +%d HP" % valor_cura, Color(0.2, 1.0, 0.4))
	print("[Hatsu Cura] Regenerou +", valor_cura, " HP! Total: ", PlayerData.attributes["vida"], "/", hp_max)


# ============================================================
# EXECUTOR DE MOBILIDADE (DASH SUPERSÔNICO & SHUNPO)
# ============================================================

func _executar_mobilidade(hatsu: HatsuData, _eficiencia: float) -> void:
	if owner_body == null:
		return

	var direcao: Vector2 = Vector2.DOWN
	if combat_system != null and combat_system.ultima_direcao != Vector2.ZERO:
		direcao = combat_system.ultima_direcao
	elif owner_body.velocity != Vector2.ZERO:
		direcao = owner_body.velocity.normalized()

	# Conceder I-frames e avanço veloz
	if combat_system != null:
		combat_system.invulneravel = true
		combat_system._mostrar_texto_flutuante("⚡ AVANÇO DE AURA!", hatsu.cor_aura)
		var t := owner_body.get_tree().create_timer(0.35)
		t.timeout.connect(func():
			if combat_system != null and not combat_system.esquivando:
				combat_system.invulneravel = false
		)

	var dist: float = hatsu.alcance
	var vel: float = 480.0
	var tween := owner_body.create_tween()
	tween.tween_property(owner_body, "global_position", owner_body.global_position + (direcao * dist), dist / vel)


# ============================================================
# EXECUTOR DE CONTROLE (ONDA SÍSMICA & IMOBILIZAÇÃO)
# ============================================================

func _executar_controle(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null:
		return

	var area := Area2D.new()
	area.name = "HatsuControle"
	area.collision_layer = 1 << 3
	area.collision_mask = 1 << 4

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = hatsu.raio
	col.shape = shape
	area.add_child(col)

	owner_body.add_child(area)
	area.position = Vector2.ZERO

	var fx := HatsuAreaExplosionNode.new()
	fx.setup(hatsu.raio, hatsu.cor_aura)
	owner_body.add_child(fx)

	area.area_entered.connect(func(alvo_area: Area2D):
		var enemy: Node = alvo_area.get_parent()
		if enemy != null and enemy != owner_body:
			var enemy_sys = enemy.get_node_or_null("EnemySystem")
			if enemy_sys != null:
				var dano_hatsu: int = int(_calcular_dano_hatsu(hatsu, eficiencia, enemy) * 0.5)
				var dir: Vector2 = (enemy.global_position - owner_body.global_position).normalized()
				enemy_sys.take_damage(dano_hatsu, dir, 220.0, owner_body)
				print("[Hatsu Controle] Stun/Paralisia em ", enemy.name)
	)

	var timer := owner_body.get_tree().create_timer(0.25)
	await timer.timeout
	if is_instance_valid(area):
		area.queue_free()


# ============================================================
# EXECUTORES DE DANO OFENSIVO (6 CATEGORIAS)
# ============================================================

func _executar_dano_categorizado(hatsu: HatsuData, eficiencia: float) -> void:
	match hatsu.categoria:
		HatsuData.Categoria.INTENSIFICACAO:
			if hatsu.forma == HatsuData.Forma.TOQUE or hatsu.nome.contains("Pedra"):
				_criar_golpe_direto(hatsu, eficiencia * 1.6)
			elif hatsu.forma == HatsuData.Forma.PESSOAL:
				_executar_cura(hatsu, eficiencia)
			else:
				_criar_explosao_area(hatsu, eficiencia)

		HatsuData.Categoria.TRANSFORMACAO:
			if hatsu.nome.contains("Godspeed") or hatsu.nome.contains("Kanmuru"):
				godspeed_timer = hatsu.duracao
				PlayerData.quest_states["godspeed_ativo"] = true
				if owner_body != null:
					var fx := GodspeedElectricEffect.new()
					fx.setup(owner_body, hatsu.duracao)
					owner_body.get_parent().add_child(fx)
					owner_body.get_tree().create_timer(hatsu.duracao).timeout.connect(func():
						PlayerData.quest_states["godspeed_ativo"] = false
					)
			elif hatsu.nome.contains("Pain Packer") or hatsu.nome.contains("Rising Sun") or (HatsuData.Condicao.DOR_ACUMULADA in hatsu.condicoes):
				_criar_explosao_area(hatsu, eficiencia)
			elif hatsu.forma == HatsuData.Forma.TOQUE or hatsu.nome.contains("Tesoura"):
				_criar_golpe_direto(hatsu, eficiencia)
			elif hatsu.forma == HatsuData.Forma.PROJETIL or hatsu.nome.contains("Narukami") or hatsu.nome.contains("Bungee"):
				_criar_projetil(hatsu, eficiencia)
			else:
				_criar_explosao_area(hatsu, eficiencia)

		HatsuData.Categoria.EMISSAO:
			if hatsu.nome.contains("Remote Punch") or hatsu.nome.contains("Soco Remoto"):
				_criar_golpe_remoto_emissao(hatsu, eficiencia)
			elif hatsu.forma == HatsuData.Forma.AREA or hatsu.nome.contains("Dragon Dive"):
				_criar_explosao_area(hatsu, eficiencia)
			else:
				_criar_projetil(hatsu, eficiencia)

		HatsuData.Categoria.CONJURACAO:
			if hatsu.nome.contains("Crazy Slots"):
				if owner_body != null:
					var fx := CrazySlotsWheelEffect.new()
					fx.setup(owner_body)
					owner_body.add_child(fx)
			elif hatsu.nome.contains("Guanyin") or hatsu.nome.contains("Bodhisattva"):
				PlayerData.quest_states["guanyin_bodhisattva_ativo"] = true
				if owner_body != null:
					var fx := GuanyinBodhisattvaEffect.new()
					fx.setup(owner_body, hatsu.duracao)
					owner_body.add_child(fx)
					owner_body.get_tree().create_timer(hatsu.duracao).timeout.connect(func():
						PlayerData.quest_states["guanyin_bodhisattva_ativo"] = false
					)
			elif hatsu.nome.contains("Holy Chain"):
				_executar_cura(hatsu, eficiencia)
			elif hatsu.forma == HatsuData.Forma.TOQUE or hatsu.nome.contains("Chain Jail"):
				_criar_golpe_direto(hatsu, eficiencia)
			else:
				_criar_explosao_area(hatsu, eficiencia)

		HatsuData.Categoria.MANIPULACAO:
			_criar_projetil(hatsu, eficiencia)

		HatsuData.Categoria.ESPECIALIZACAO:
			if hatsu.nome.contains("Emperor Time"):
				PlayerData.quest_states["emperor_time_ativo"] = true
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("👁️ EMPEROR TIME 100%!", Color(1.0, 0.1, 0.3))
				owner_body.get_tree().create_timer(hatsu.duracao).timeout.connect(func():
					PlayerData.quest_states["emperor_time_ativo"] = false
				)
			elif hatsu.forma == HatsuData.Forma.PROJETIL:
				_criar_projetil(hatsu, eficiencia)
			else:
				_criar_explosao_area(hatsu, eficiencia)

		_:
			_criar_projetil(hatsu, eficiencia)


# ============================================================
# CÁLCULO UNIFICADO DE DANO COM JURAMENTOS E NEN
# ============================================================

func _calcular_dano_hatsu(hatsu: HatsuData, eficiencia: float, inimigo_alvo: Node = null) -> int:
	var poder_base: float = hatsu.obter_poder_final()
	var forca: float = float(PlayerData.attributes.get("forca", 10))
	var nivel_nen: int = int(PlayerData.attributes.get("nivel_nen", 0))
	var aura_max: float = float(PlayerData.attributes.get("aura_max", 100.0))

	# 1. Multiplicador de Afinidade Natal (Hexágono) + Força Física
	var dano: float = (poder_base * eficiencia) + forca

	# 2. Escalonamento com o Domínio de Nen e Quantidade de Aura
	var bonus_nen: float = 1.0 + (float(nivel_nen) * 0.015) + (max(0.0, aura_max - 100.0) / 400.0)
	dano *= max(1.0, bonus_nen)

	# 3. Técnicas Avançadas de Nen Ativas
	if nen_system != null:
		dano = nen_system.aplicar_shu_no_dano(dano)
		dano = nen_system.aplicar_ryu_no_dano_ataque(dano)

		if nen_system.tecnica_ativa(NenSystem.Tecnica.KO):
			dano *= (1.0 + nen_system.obter_bonus_ko())

		if nen_system.tecnica_ativa(NenSystem.Tecnica.GYO):
			dano *= 1.35

		if nen_system.tecnica_ativa(NenSystem.Tecnica.ZETSU) and inimigo_alvo != null:
			dano *= 3.0
			if combat_system != null:
				combat_system._mostrar_texto_flutuante("🗡️ HATSU FURTIVO x3!", Color(0.9, 0.2, 1.0))

	# 4. Bônus da Besta de Nen
	var nen_beast_sys = owner_body.get_node_or_null("NenBeastSystem") if owner_body != null else null
	if nen_beast_sys != null and nen_beast_sys.berserker_ativo:
		dano *= 1.5

	return max(int(round(dano)), 1)


func _criar_golpe_remoto_emissao(hatsu: HatsuData, eficiencia: float) -> void:
	if owner_body == null:
		return

	var enemies = owner_body.get_tree().get_nodes_in_group("enemy")
	var alvo_proximo: CharacterBody2D = null
	var menor_dist: float = 220.0

	for e in enemies:
		if e is CharacterBody2D and is_instance_valid(e):
			var d: float = owner_body.global_position.distance_to(e.global_position)
			if d < menor_dist:
				menor_dist = d
				alvo_proximo = e

	if alvo_proximo != null:
		var dir: Vector2 = Vector2.UP
		var dano: int = _calcular_dano_hatsu(hatsu, eficiencia, alvo_proximo)
		var enemy_sys = alvo_proximo.get_node_or_null("EnemySystem")
		if enemy_sys != null:
			enemy_sys.take_damage(dano, dir, 250.0, owner_body)
			print("[Soco Remoto] Impacto sob ", alvo_proximo.name, " Dano: ", dano)


func _criar_projetil(hatsu: HatsuData, eficiencia: float = 1.0) -> void:
	if owner_body == null:
		return

	var direcao: Vector2 = Vector2.DOWN
	if combat_system != null and combat_system.ultima_direcao != Vector2.ZERO:
		direcao = combat_system.ultima_direcao
	elif owner_body.velocity != Vector2.ZERO:
		direcao = owner_body.velocity.normalized()

	# Resolver perfil visual com herança opcional da aura do personagem
	var raw_vp: VisualProfile = hatsu.obter_visual_profile()
	var vp: VisualProfile = PlayerData.aura_visual_profile.blend_with_hatsu(raw_vp) if PlayerData.aura_visual_profile != null else raw_vp

	var area := Area2D.new()
	area.name = "HatsuProjetil"
	area.collision_layer = 1 << 3
	area.collision_mask = 1 << 4

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 6.0
	col.shape = shape
	area.add_child(col)

	# Renderizador Visual Modular
	var visual := HatsuVisual.new()
	visual.setup(vp)
	area.add_child(visual)

	owner_body.get_parent().add_child(area)
	area.global_position = owner_body.global_position

	# Efeito de Cast ao Disparar
	HatsuVisual.spawn_cast_effect(owner_body.global_position, vp, owner_body.get_parent())

	var velocidade: float = 240.0
	var alcance_max: float = hatsu.alcance

	area.area_entered.connect(func(alvo_area: Area2D):
		var enemy: Node = alvo_area.get_parent()
		if enemy != null and enemy != owner_body:
			var enemy_sys = enemy.get_node_or_null("EnemySystem")
			if enemy_sys != null:
				var dano_hatsu: int = _calcular_dano_hatsu(hatsu, eficiencia, enemy)
				enemy_sys.take_damage(dano_hatsu, direcao, 120.0, owner_body)
				if is_instance_valid(area):
					HatsuVisual.spawn_impact_effect(area.global_position, vp, owner_body.get_parent())
					area.queue_free()
	)

	var tween := area.create_tween()
	tween.tween_property(area, "global_position", area.global_position + (direcao * alcance_max), alcance_max / velocidade)
	tween.tween_callback(func():
		if is_instance_valid(area):
			HatsuVisual.spawn_impact_effect(area.global_position, vp, owner_body.get_parent())
			area.queue_free()
	)


func _criar_explosao_area(hatsu: HatsuData, eficiencia: float = 1.0) -> void:
	if owner_body == null:
		return

	var raw_vp: VisualProfile = hatsu.obter_visual_profile()
	var vp: VisualProfile = PlayerData.aura_visual_profile.blend_with_hatsu(raw_vp) if PlayerData.aura_visual_profile != null else raw_vp

	var area := Area2D.new()
	area.name = "HatsuArea"
	area.collision_layer = 1 << 3
	area.collision_mask = 1 << 4

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = hatsu.raio
	col.shape = shape
	area.add_child(col)

	owner_body.add_child(area)
	area.position = Vector2.ZERO

	var fx := HatsuAreaExplosionNode.new()
	fx.setup(hatsu.raio, vp.primary_color)
	owner_body.add_child(fx)
	fx.position = Vector2.ZERO

	# Efeito de Impacto Imediato
	HatsuVisual.spawn_impact_effect(owner_body.global_position, vp, owner_body.get_parent())

	area.area_entered.connect(func(alvo_area: Area2D):
		var enemy: Node = alvo_area.get_parent()
		if enemy != null and enemy != owner_body:
			var enemy_sys = enemy.get_node_or_null("EnemySystem")
			if enemy_sys != null:
				var dano_hatsu: int = _calcular_dano_hatsu(hatsu, eficiencia, enemy)
				var dir: Vector2 = (enemy.global_position - owner_body.global_position).normalized()
				enemy_sys.take_damage(dano_hatsu, dir, 150.0, owner_body)
	)

	var timer := owner_body.get_tree().create_timer(0.2)
	await timer.timeout
	if is_instance_valid(area):
		area.queue_free()


func _criar_golpe_direto(hatsu: HatsuData, eficiencia: float = 1.0) -> void:
	if owner_body == null:
		return

	var direcao: Vector2 = Vector2.DOWN
	if combat_system != null and combat_system.ultima_direcao != Vector2.ZERO:
		direcao = combat_system.ultima_direcao

	var raw_vp: VisualProfile = hatsu.obter_visual_profile()
	var vp: VisualProfile = PlayerData.aura_visual_profile.blend_with_hatsu(raw_vp) if PlayerData.aura_visual_profile != null else raw_vp

	var area := Area2D.new()
	area.name = "HatsuToque"
	area.collision_layer = 1 << 3
	area.collision_mask = 1 << 4

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = hatsu.alcance
	col.shape = shape
	area.add_child(col)

	owner_body.add_child(area)
	area.position = direcao * hatsu.alcance

	# Efeito de Cast
	HatsuVisual.spawn_cast_effect(owner_body.global_position + (direcao * hatsu.alcance * 0.5), vp, owner_body.get_parent())

	area.area_entered.connect(func(alvo_area: Area2D):
		var enemy: Node = alvo_area.get_parent()
		if enemy != null and enemy != owner_body:
			var enemy_sys = enemy.get_node_or_null("EnemySystem")
			if enemy_sys != null:
				var dano_hatsu: int = _calcular_dano_hatsu(hatsu, eficiencia, enemy)
				enemy_sys.take_damage(dano_hatsu, direcao, 200.0, owner_body)
				HatsuVisual.spawn_impact_effect(enemy.global_position, vp, owner_body.get_parent())
	)

	var timer := owner_body.get_tree().create_timer(0.15)
	await timer.timeout
	if is_instance_valid(area):
		area.queue_free()


# ============================================================
# GERENCIAMENTO DE ESCUDO E RETALIAÇÃO ELEMENTAL
# ============================================================

func absorver_dano_escudo(dano: int, atacante: Node = null) -> int:
	if escudo_ativo <= 0.0:
		return dano

	if dano <= 0:
		return 0

	# Contra-ataque elemental
	if atacante != null:
		_aplicar_retaliacao_escudo(atacante)

	var dano_float: float = float(dano)
	if escudo_ativo >= dano_float:
		escudo_ativo -= dano_float
		escudo_alterado.emit(escudo_ativo, escudo_maximo)
		print("[Hatsu Escudo] Absorveu todo o dano (", dano, "). Escudo restante: ", escudo_ativo)
		return 0
	else:
		var restante: int = int(dano_float - escudo_ativo)
		escudo_ativo = 0.0
		escudo_maximo = 0.0
		escudo_timer = 0.0
		if is_instance_valid(escudo_node_visual):
			escudo_node_visual.queue_free()
		escudo_alterado.emit(0.0, 0.0)
		print("[Hatsu Escudo] Escudo quebrou! Dano restante: ", restante)
		return restante


func _aplicar_retaliacao_escudo(atacante: Node) -> void:
	var enemy_sys = atacante.get_node_or_null("EnemySystem") if atacante != null else null
	if enemy_sys != null:
		var dir_ret: Vector2 = (atacante.global_position - owner_body.global_position).normalized()
		match escudo_elemento:
			HatsuData.Elemento.ELETRICIDADE:
				enemy_sys.take_damage(15, dir_ret, 140.0, owner_body)
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("⚡ CONTRA-CHOQUE!", Color(0.2, 0.9, 1.0))
			HatsuData.Elemento.FOGO:
				enemy_sys.take_damage(20, dir_ret, 120.0, owner_body)
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("🔥 RETALIAÇÃO DE FOGO!", Color(1.0, 0.3, 0.1))
			HatsuData.Elemento.GELO:
				enemy_sys.take_damage(12, dir_ret, 80.0, owner_body)
				if combat_system != null:
					combat_system._mostrar_texto_flutuante("❄️ CONTRA-GELO!", Color(0.6, 0.9, 1.0))
			_:
				pass


# ============================================================
# CLASSES DE EFEITOS VISUAIS DE HATSU
# ============================================================

class HatsuShieldAuraNode extends Node2D:
	var raio: float = 24.0
	var cor: Color = Color(0.2, 0.6, 1.0, 1.0)
	var tempo_vida: float = 6.0
	var pulse: float = 0.0

	func setup(r: float, c: Color, dur: float) -> void:
		raio = r
		cor = c
		tempo_vida = dur

	func _process(delta: float) -> void:
		pulse += delta * 4.0
		queue_redraw()
		tempo_vida -= delta
		if tempo_vida <= 0.0:
			queue_free()

	func _draw() -> void:
		var p_r: float = raio + sin(pulse) * 2.0
		var c_fill := Color(cor.r, cor.g, cor.b, 0.20 + sin(pulse) * 0.05)
		draw_circle(Vector2.ZERO, p_r, c_fill)
		draw_arc(Vector2.ZERO, p_r, 0, TAU, 32, cor, 1.5)


class HatsuHealPulseNode extends Node2D:
	var cor: Color = Color(0.3, 1.0, 0.4, 1.0)
	var raio: float = 8.0
	var alpha: float = 0.9

	func setup(c: Color) -> void:
		cor = c

	func _ready() -> void:
		var tw := create_tween()
		tw.tween_property(self, "raio", 36.0, 0.6)
		tw.parallel().tween_property(self, "alpha", 0.0, 0.6)
		tw.tween_callback(queue_free)

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var c := Color(cor.r, cor.g, cor.b, alpha)
		draw_arc(Vector2.ZERO, raio, 0, TAU, 32, c, 2.0)
		draw_circle(Vector2.ZERO, raio * 0.7, Color(cor.r, cor.g, cor.b, alpha * 0.2))
