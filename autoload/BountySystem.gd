class_name BountySystemClass
extends Node

# ============================================================
# HUNTER ONLINE - DYNAMIC BOUNTY & PURSUIT SYSTEM (FACTIONS & LAW)
# ============================================================
#
# Gerencia a caçada de recompensas em duas vias:
# 1. JOGADOR COMO ALVO: Crimes geram infâmia, preço na cabeça e caçadores
# 2. JOGADOR COMO CAÇADOR: Contratos da Lista Negra para caçar foras-da-lei
# 3. ESCALAÇÃO: A cada 100 de infâmia, o nível dos perseguidores aumenta
#
# ============================================================

signal recompensa_cabeca_alterada(novo_valor: int, faccao_emissora: String)
signal contrato_bounty_adicionado(contrato_id: String, alvo_nome: String, recompensa_jenny: int)
signal contrato_bounty_concluido(contrato_id: String, recompensa_jenny: int)
signal perseguidor_spawn_solicitado(nivel_perseguidor: int, posicao_spawn: Vector2)

# Contratos que o jogador pode aceitar
var active_bounty_contracts: Dictionary = {}
var timer_verificacao_perseguicao: float = 0.0

func _ready() -> void:
	add_to_group("bounty_system")
	_inicializar_contratos_iniciais()
	_conectar_event_bus()
	garantir_rotacao_associacao()
	print("=================================")
	print("[BountySystem] SISTEMA DE BOUNTY & PERSEGUIÇÃO ATIVO (+ A5 rotação Associação)")
	print("=================================")


func _inicializar_contratos_iniciais() -> void:
	active_bounty_contracts = {
		"bounty_ladrao_padokia": {
			"id": "bounty_ladrao_padokia",
			"nome_alvo": "Goran, o Mão-Leve",
			"regiao": "vale_padokia",
			"nivel_alvo": 3,
			"recompensa_jenny": 1500,
			"descricao": "Procurado por furtar mercadorias dos depósitos da vila.",
			"concluido": false,
			"aceito": false
		},
		"bounty_desertor_mafia": {
			"id": "bounty_desertor_mafia",
			"nome_alvo": "Vito 'Cicatriz' Morlani",
			"regiao": "ruinas_zaban",
			"nivel_alvo": 5,
			"recompensa_jenny": 5000,
			"descricao": "Ex-capo da Máfia de Yorknew em fuga com documentos sigilosos.",
			"concluido": false,
			"aceito": false
		},
		"bounty_alfa_lobos": {
			"id": "bounty_alfa_lobos",
			"nome_alvo": "Lobo Alfa das Planícies",
			"regiao": "vale_padokia",
			"nivel_alvo": 4,
			"recompensa_jenny": 2200,
			"descricao": "Líder da matilha selvagem que ameaça os comboios de suprimentos.",
			"concluido": false,
			"aceito": false
		},
		"bounty_bandidos_zaban": {
			"id": "bounty_bandidos_zaban",
			"nome_alvo": "Bando de Salteadores de Zaban",
			"regiao": "lobby",
			"nivel_alvo": 2,
			"recompensa_jenny": 1200,
			"descricao": "Grupo de criminosos assaltando novos candidatos a Hunter na periferia.",
			"concluido": false,
			"aceito": false
		},
		"bounty_cacador_renegado_zaban": {
			"id": "bounty_cacador_renegado_zaban",
			"nome_alvo": "Karkov, o Caçador Desonrado",
			"regiao": "ruinas_zaban",
			"nivel_alvo": 120,
			"recompensa_jenny": 150000,
			"descricao": "Ex-examinador que traiu a Associação vendendo credenciais a contrabandistas.",
			"concluido": false,
			"aceito": false
		},
		"bounty_exilado_greed": {
			"id": "bounty_exilado_greed",
			"nome_alvo": "Magnus, o Colecionador Impiedoso",
			"regiao": "greed_island",
			"nivel_alvo": 420,
			"recompensa_jenny": 1800000,
			"descricao": "PK lendário que extorquia jogadores novatos e roubou cartas raras de feitiço.",
			"concluido": false,
			"aceito": false
		},
		"bounty_esquadrao_rebelde_chimera": {
			"id": "bounty_esquadrao_rebelde_chimera",
			"nome_alvo": "General Formiga Renegado 'Drakon'",
			"regiao": "ngl_formigas",
			"nivel_alvo": 680,
			"recompensa_jenny": 15000000,
			"descricao": "Líder de esquadrão mutante que se recusou a obedecer a Rainha e montou fortaleza própria.",
			"concluido": false,
			"aceito": false
		},
		"bounty_assassino_heilly": {
			"id": "bounty_assassino_heilly",
			"nome_alvo": "Capitão Assassino da Família Heil-Ly",
			"regiao": "black_whale_1",
			"nivel_alvo": 850,
			"recompensa_jenny": 45000000,
			"descricao": "Braço-direito de Morena Prudo infectando guardas militares nos conveses profundos.",
			"concluido": false,
			"aceito": false
		},
		"bounty_calamidade_parasita": {
			"id": "bounty_calamidade_parasita",
			"nome_alvo": "Avatar da Besta Parasita de Brion",
			"regiao": "continente_negro",
			"nivel_alvo": 960,
			"recompensa_jenny": 150000000,
			"descricao": "Entidade simbiótica ancestral das ruínas esquecidas. Nível de ameaça de Calamidade Máxima!",
			"concluido": false,
			"aceito": false
		}
	}


func obter_contratos_por_regiao(regiao_id: String) -> Array:
	var lista: Array = []
	for c_id in active_bounty_contracts.keys():
		var c = active_bounty_contracts[c_id]
		if c.get("regiao", "") == regiao_id or regiao_id == "todos" or regiao_id == "lobby":
			lista.append(c)
	return lista


func aceitar_contrato(contrato_id: String) -> bool:
	if not active_bounty_contracts.has(contrato_id):
		return false
	var c = active_bounty_contracts[contrato_id]
	if c.get("aceito", false):
		return true
	c["aceito"] = true
	contrato_bounty_adicionado.emit(contrato_id, c["nome_alvo"], c["recompensa_jenny"])
	if EventBus != null and EventBus.has_signal("toast_requested"):
		EventBus.emit_toast("📜 Contrato Aceito: %s!" % c["nome_alvo"], Color(0.4, 0.9, 1.0))
	return true


func _conectar_event_bus() -> void:
	if EventBus == null:
		return
	if EventBus.has_signal("enemy_defeated"):
		EventBus.enemy_defeated.connect(_on_enemy_defeated)
	if EventBus.has_signal("time_hour_ticked"):
		EventBus.time_hour_ticked.connect(_on_time_hour_ticked)


func obter_recompensa_cabeca_jogador() -> int:
	if WorldState == null:
		return 0
	var infamia = WorldState.obter_infamia()
	return infamia * 50 # Ex: 100 de infâmia = 5.000 Jenny de recompensa


func concluir_contrato(contrato_id: String) -> void:
	if not active_bounty_contracts.has(contrato_id):
		return
	var c = active_bounty_contracts[contrato_id]
	if c["concluido"]:
		return
	c["concluido"] = true
	var premio = c["recompensa_jenny"]
	
	if Economy != null:
		Economy.adicionar_gold(premio)
	if ReputationSystem != null:
		ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER, +80, "Contrato de Bounty Cumprido")
	if EventBus != null and EventBus.has_signal("player_stat_changed"):
		EventBus.player_stat_changed.emit("xp", premio / 5)
		
	contrato_bounty_concluido.emit(contrato_id, premio)
	if EventBus != null and EventBus.has_signal("toast_requested"):
		EventBus.emit_toast("💰 Recompensa Coletada: +%d Jenny (%s)!" % [premio, c["nome_alvo"]], Color(1.0, 0.85, 0.2))


func _on_enemy_defeated(enemy_id: String, _xp: int, _nen_xp: int) -> void:
	for c_id in active_bounty_contracts.keys():
		var c = active_bounty_contracts[c_id]
		if enemy_id.to_lower() in c["nome_alvo"].to_lower() or c["id"] == enemy_id:
			concluir_contrato(c_id)


func _on_time_hour_ticked(_hour: int, _minute: int) -> void:
	garantir_rotacao_associacao()
	if WorldState == null:
		return
	var infamia = WorldState.obter_infamia()
	if infamia >= 100:
		# Se a infâmia do jogador for alta, avaliar se um caçador deve iniciar perseguição
		var nivel_cassador = clamp(int(infamia / 50), 2, 10)
		perseguidor_spawn_solicitado.emit(nivel_cassador, Vector2.ZERO)
		print("[BountySystem] Alerta: Caçador de Recompensa Nível %d rastreando jogador!" % nivel_cassador)


# ============================================================
# A5 — CONTRATOS ROTATIVOS DA ASSOCIAÇÃO HUNTER
# ============================================================

const RadiantQuestGeneratorScript = preload("res://resource/quest/RadiantQuestGenerator.gd")

const DAYS_PER_WEEK := 7
const DAILY_POOL_SIZE := 4
const FREE_REFRESHES_PER_DAY := 1
const PAID_REFRESH_COST_JENNY := 500

enum LicenseAccess {
	NONE = -1,
	B = 0,
	A = 1,
	S = 2
}

signal rotacao_associacao_atualizada(day_index: int, week_index: int)

var rotation_day_index: int = -1
var rotation_week_index: int = -1
var daily_association_quests: Array[Quest] = []
var weekly_star_quest: Quest = null
var accepted_daily_ids: Array[String] = []
var claimed_daily_ids: Array[String] = []
var accepted_weekly_id: String = ""
var claimed_weekly_id: String = ""
var free_refreshes_used_today: int = 0
var last_region_id: String = "vale_padokia"


func _obter_dia_jogo() -> int:
	if TimeManager != null:
		return maxi(1, TimeManager.current_day)
	return 1


func _obter_semana_jogo() -> int:
	return int((_obter_dia_jogo() - 1) / DAYS_PER_WEEK)


func _obter_nivel_jogador() -> int:
	if PlayerData != null:
		return int(PlayerData.attributes.get("nivel", PlayerData.attributes.get("level", 1)))
	return 1


func _obter_regiao_atual() -> String:
	if GameManager != null and not str(GameManager.current_region_id).is_empty():
		return str(GameManager.current_region_id)
	if not last_region_id.is_empty():
		return last_region_id
	return "vale_padokia"


## Estrelas: rank Associação (1=licenciado→0★) ou atributo hunter_stars
func obter_estrelas_hunter() -> int:
	if FactionManager != null and FactionManager.faccao_atual == "associacao_hunter":
		return maxi(0, int(FactionManager.faccao_rank) - 1)
	if PlayerData != null:
		return maxi(0, int(PlayerData.attributes.get("hunter_stars", 0)))
	return 0


func obter_access_tier_jogador() -> int:
	var stars := obter_estrelas_hunter()
	if stars >= 2:
		return LicenseAccess.S
	if stars >= 1:
		return LicenseAccess.A
	var tem_licenca := false
	if PlayerData != null:
		if PlayerData.has_method("tem_item"):
			tem_licenca = PlayerData.tem_item(&"licenca_hunter")
		else:
			tem_licenca = int(PlayerData.inventory.get("licenca_hunter", 0)) > 0
		if bool(PlayerData.attributes.get("licenca_penhorada", false)):
			tem_licenca = false
	if tem_licenca or _obter_nivel_jogador() >= 1:
		return LicenseAccess.B
	return LicenseAccess.NONE


func access_tier_to_string(tier: int) -> String:
	match tier:
		LicenseAccess.S:
			return "S"
		LicenseAccess.A:
			return "A"
		LicenseAccess.B:
			return "B"
		_:
			return "-"


func pode_aceitar_tier(required_tier: String) -> bool:
	var need := LicenseAccess.B
	match required_tier.to_upper():
		"S":
			need = LicenseAccess.S
		"A":
			need = LicenseAccess.A
		_:
			need = LicenseAccess.B
	return obter_access_tier_jogador() >= need


func garantir_rotacao_associacao(force_region: String = "") -> void:
	var day := _obter_dia_jogo()
	var week := _obter_semana_jogo()
	var region := force_region if not force_region.is_empty() else _obter_regiao_atual()
	last_region_id = region

	var day_changed := day != rotation_day_index
	var week_changed := week != rotation_week_index
	var needs_pool := daily_association_quests.is_empty() or weekly_star_quest == null

	if not day_changed and not week_changed and not needs_pool:
		return

	if day_changed:
		rotation_day_index = day
		accepted_daily_ids.clear()
		claimed_daily_ids.clear()
		free_refreshes_used_today = 0
		_regenerar_pool_diario(region)

	if week_changed or weekly_star_quest == null:
		rotation_week_index = week
		accepted_weekly_id = ""
		claimed_weekly_id = ""
		_regenerar_star_hunter(region)

	if needs_pool and not day_changed and daily_association_quests.is_empty():
		_regenerar_pool_diario(region)
	if weekly_star_quest == null:
		_regenerar_star_hunter(region)

	rotacao_associacao_atualizada.emit(rotation_day_index, rotation_week_index)


func _regenerar_pool_diario(region: String) -> void:
	var lvl := _obter_nivel_jogador()
	daily_association_quests = RadiantQuestGeneratorScript.gerar_pool_contratos_associacao(
		region, lvl, rotation_day_index, DAILY_POOL_SIZE
	)


func _regenerar_star_hunter(region: String) -> void:
	var lvl := _obter_nivel_jogador()
	weekly_star_quest = RadiantQuestGeneratorScript.gerar_star_hunter_semanal(
		region, lvl, rotation_week_index
	)


func obter_contratos_diarios() -> Array[Quest]:
	garantir_rotacao_associacao()
	return daily_association_quests


func obter_contrato_star_hunter() -> Quest:
	garantir_rotacao_associacao()
	return weekly_star_quest


func obter_contract_id(q: Quest) -> String:
	if q == null:
		return ""
	return str(q.custom_data.get("contract_id", q.quest_name))


func is_contrato_diario_aceito(q: Quest) -> bool:
	return obter_contract_id(q) in accepted_daily_ids


func is_contrato_diario_reclamado(q: Quest) -> bool:
	return obter_contract_id(q) in claimed_daily_ids


func is_star_aceito() -> bool:
	if weekly_star_quest == null:
		return false
	return accepted_weekly_id == obter_contract_id(weekly_star_quest)


func is_star_reclamado() -> bool:
	if weekly_star_quest == null:
		return false
	return claimed_weekly_id == obter_contract_id(weekly_star_quest)


func aceitar_contrato_associacao(q: Quest) -> Dictionary:
	## Retorno: { ok: bool, motivo: String }
	garantir_rotacao_associacao()
	if q == null:
		return {"ok": false, "motivo": "Contrato inválido."}

	var cid := obter_contract_id(q)
	var is_star: bool = bool(q.custom_data.get("is_star_hunter", false))
	var tier := str(q.custom_data.get("access_tier", "B"))

	if is_star:
		if not pode_aceitar_tier("A"):
			return {"ok": false, "motivo": "Star Hunter exige Hunter de 1 Estrela (★)."}
		if claimed_weekly_id == cid:
			return {"ok": false, "motivo": "Star Hunter desta semana já concluído."}
		if accepted_weekly_id == cid:
			return {"ok": false, "motivo": "Star Hunter já aceito."}
	else:
		if not pode_aceitar_tier(tier):
			return {"ok": false, "motivo": "Licença insuficiente para contratos %s." % tier}
		if cid in claimed_daily_ids:
			return {"ok": false, "motivo": "Contrato diário já concluído."}
		if cid in accepted_daily_ids:
			return {"ok": false, "motivo": "Contrato já aceito."}

	if QuestSystem != null:
		if not QuestSystem.start_quest(q):
			return {"ok": false, "motivo": "Não foi possível iniciar a missão."}
	else:
		return {"ok": false, "motivo": "QuestSystem indisponível."}

	if is_star:
		accepted_weekly_id = cid
	elif not accepted_daily_ids.has(cid):
		accepted_daily_ids.append(cid)

	if EventBus != null:
		EventBus.emit_toast("📜 Associação: %s" % q.quest_name, Color(0.95, 0.85, 0.35))
	return {"ok": true, "motivo": ""}


func notificar_quest_associacao_concluida(q: Quest) -> void:
	if q == null or not bool(q.custom_data.get("association_contract", false)):
		return
	var cid := obter_contract_id(q)
	var is_star: bool = bool(q.custom_data.get("is_star_hunter", false))
	if is_star:
		claimed_weekly_id = cid
		accepted_weekly_id = cid
	else:
		if not claimed_daily_ids.has(cid):
			claimed_daily_ids.append(cid)
		if not accepted_daily_ids.has(cid):
			accepted_daily_ids.append(cid)


func obter_segundos_ate_reset_diario() -> int:
	if TimeManager == null:
		return 0
	var mins_left := (23 - TimeManager.current_hour) * 60 + (60 - TimeManager.current_minute)
	var scale := maxf(1.0, TimeManager.time_scale)
	return int((mins_left / scale) * 60.0)


func obter_segundos_ate_reset_semanal() -> int:
	var day := _obter_dia_jogo()
	var day_in_week := (day - 1) % DAYS_PER_WEEK
	var days_left := DAYS_PER_WEEK - 1 - day_in_week
	return days_left * 24 * 3600 + obter_segundos_ate_reset_diario()


func refreshes_gratis_restantes() -> int:
	garantir_rotacao_associacao()
	return maxi(0, FREE_REFRESHES_PER_DAY - free_refreshes_used_today)


func solicitar_refresh_diario(pago: bool = false) -> Dictionary:
	garantir_rotacao_associacao()
	if free_refreshes_used_today < FREE_REFRESHES_PER_DAY and not pago:
		free_refreshes_used_today += 1
		_regenerar_pool_diario(last_region_id)
		accepted_daily_ids.clear()
		claimed_daily_ids.clear()
		rotacao_associacao_atualizada.emit(rotation_day_index, rotation_week_index)
		return {"ok": true, "motivo": "Quadro diário renovado (grátis)."}

	if Economy == null or not Economy.gastar_gold(PAID_REFRESH_COST_JENNY):
		return {"ok": false, "motivo": "Refresh pago: %d Jenny necessários." % PAID_REFRESH_COST_JENNY}

	_regenerar_pool_diario(last_region_id)
	accepted_daily_ids.clear()
	claimed_daily_ids.clear()
	rotacao_associacao_atualizada.emit(rotation_day_index, rotation_week_index)
	return {"ok": true, "motivo": "Quadro renovado (−%d Jenny)." % PAID_REFRESH_COST_JENNY}


# ============================================================
# PERSISTÊNCIA SAVE / LOAD
# ============================================================

func salvar_dados() -> Dictionary:
	return {
		"active_bounty_contracts": active_bounty_contracts.duplicate(true),
		"rotation_day_index": rotation_day_index,
		"rotation_week_index": rotation_week_index,
		"accepted_daily_ids": accepted_daily_ids.duplicate(),
		"claimed_daily_ids": claimed_daily_ids.duplicate(),
		"accepted_weekly_id": accepted_weekly_id,
		"claimed_weekly_id": claimed_weekly_id,
		"free_refreshes_used_today": free_refreshes_used_today,
		"last_region_id": last_region_id,
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		_inicializar_contratos_iniciais()
		rotation_day_index = -1
		rotation_week_index = -1
		garantir_rotacao_associacao()
		return
	active_bounty_contracts = dados.get("active_bounty_contracts", {}).duplicate(true)
	if active_bounty_contracts.is_empty():
		_inicializar_contratos_iniciais()

	rotation_day_index = int(dados.get("rotation_day_index", -1))
	rotation_week_index = int(dados.get("rotation_week_index", -1))
	accepted_daily_ids.clear()
	for x in dados.get("accepted_daily_ids", []):
		accepted_daily_ids.append(str(x))
	claimed_daily_ids.clear()
	for x in dados.get("claimed_daily_ids", []):
		claimed_daily_ids.append(str(x))
	accepted_weekly_id = str(dados.get("accepted_weekly_id", ""))
	claimed_weekly_id = str(dados.get("claimed_weekly_id", ""))
	free_refreshes_used_today = int(dados.get("free_refreshes_used_today", 0))
	last_region_id = str(dados.get("last_region_id", "vale_padokia"))

	if rotation_day_index >= 1:
		_regenerar_pool_diario(last_region_id)
	if rotation_week_index >= 0:
		_regenerar_star_hunter(last_region_id)
	garantir_rotacao_associacao()
