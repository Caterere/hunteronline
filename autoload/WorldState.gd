class_name WorldStateClass
extends Node

# ============================================================
# HUNTER ONLINE - WORLD STATE & CONSEQUENCE SYSTEM (AUTOLOAD)
# ============================================================
#
# Gerenciador central de Estado Mundial, Dinâmica Sistêmica e
# Causalidade de Longo Prazo:
#
# [1] WORLD: Calamidades globais, era ativa e alertas mundiais
# [2] REGIONS: Segurança, prosperidade, corrupção e densidade de feras
# [3] FACTIONS: Controle territorial, influência e tratados de guerra
# [4] NPCs: Memória de atos do jogador, status de vida e disposição
# [5] QUESTS: Ramificações causais e marcos mundiais
# [6] EVENTS: Consequências de invasões e crises ativas
# [7] ECONOMY: Escassez de mercadorias e inflação regional
# [8] DISCOVERY: Relíquias ancestrais despertadas e mapas liberados
# [9] PLAYER CONSEQUENCES: Infâmia, Notoriedade de Nen, Bounties da Máfia
# [10] TIMED EFFECTS: Efeitos com expiração baseada no TimeManager
#
# ============================================================

signal consequencia_processada(tipo: String, descricao: String, duracao_horas: float)
signal estado_regional_alterado(regiao_id: String, parametro: String, novo_valor: int)
signal faccao_influencia_alterada(faccao_id: String, nova_influencia: int, delta: int)
signal infamia_alterada(nova_infamia: int, delta: int)
signal notoriedade_nen_alterada(nova_notoriedade: int, delta: int)
signal efeito_temporario_iniciado(id_efeito: String, duracao_horas: float)
signal efeito_temporario_expirado(id_efeito: String)

var world_data: Dictionary = {}

func _ready() -> void:
	add_to_group("world_state")
	reinicializar_estado_padrao()
	_conectar_event_bus()
	print("=================================")
	print("[WorldState] SISTEMA DE ESTADO MUNDIAL & CAUSALIDADE ATIVO")
	print("=================================")


func reinicializar_estado_padrao() -> void:
	world_data = {
		"version": "1.0",
		"world": {
			"calamity_level": 0,
			"global_alert": 0,
			"active_era": "era_exame_hunter",
			"custom_flags": {}
		},
		"regions": {
			"vale_padokia": {
				"seguranca": 75,
				"prosperidade": 60,
				"corrupcao": 15,
				"presenca_predadores": 30,
				"flags": ["vila_protegida"]
			},
			"ruinas_zaban": {
				"seguranca": 20,
				"prosperidade": 10,
				"corrupcao": 40,
				"presenca_predadores": 80,
				"flags": []
			},
			"pantanal_numelle": {
				"seguranca": 15,
				"prosperidade": 5,
				"corrupcao": 10,
				"presenca_predadores": 95,
				"flags": []
			},
			"arena_celestial": {
				"seguranca": 90,
				"prosperidade": 95,
				"corrupcao": 35,
				"presenca_predadores": 5,
				"flags": ["circuito_oficial"]
			},
			"cidade_yorknew": {
				"seguranca": 60,
				"prosperidade": 90,
				"corrupcao": 70,
				"presenca_predadores": 10,
				"flags": ["leilao_ativo"]
			}
		},
		"factions": {
			"associacao_hunter": {"influencia": 65, "estado_guerra": []},
			"mafia_yorknew": {"influencia": 45, "estado_guerra": []},
			"genei_ryodan": {"influencia": 30, "estado_guerra": []},
			"zoldyck": {"influencia": 50, "estado_guerra": []},
			"gourmet": {"influencia": 40, "estado_guerra": []},
			"blacklist_hunters": {"influencia": 55, "estado_guerra": []}
		},
		"npcs": {
			"wing": {"status": "vivo", "disposicao": 80, "memoria_atos": []},
			"guardiao_zaban": {"status": "vivo", "disposicao": 0, "memoria_atos": []}
		},
		"player_consequences": {
			"infamia": 0,
			"notoriedade_nen": 0,
			"crimes_cometidos": 0,
			"recompensa_cabeca": 0,
			"bounties_ativas": []
		},
		"timed_effects": {}
	}


func _conectar_event_bus() -> void:
	if EventBus == null:
		return

	if EventBus.has_signal("enemy_defeated"):
		EventBus.enemy_defeated.connect(_on_enemy_defeated)
	if EventBus.has_signal("quest_completed"):
		EventBus.quest_completed.connect(_on_quest_completed)
	if EventBus.has_signal("nen_technique_activated"):
		EventBus.nen_technique_activated.connect(_on_nen_technique_activated)
	if EventBus.has_signal("time_hour_ticked"):
		EventBus.time_hour_ticked.connect(_on_time_hour_ticked)


# ============================================================
# API DE CONSULTA E MUTAÇÃO REGIONAL
# ============================================================

func obter_seguranca_regional(regiao_id: String) -> int:
	var r = world_data["regions"].get(regiao_id, {})
	return r.get("seguranca", 50)


func alterar_seguranca_regional(regiao_id: String, delta: int) -> void:
	if not world_data["regions"].has(regiao_id):
		world_data["regions"][regiao_id] = {"seguranca": 50, "prosperidade": 50, "corrupcao": 20, "presenca_predadores": 50, "flags": []}
	var atual: int = world_data["regions"][regiao_id].get("seguranca", 50)
	var novo: int = clamp(atual + delta, 0, 100)
	world_data["regions"][regiao_id]["seguranca"] = novo
	estado_regional_alterado.emit(regiao_id, "seguranca", novo)


func obter_prosperidade_regional(regiao_id: String) -> int:
	var r = world_data["regions"].get(regiao_id, {})
	return r.get("prosperidade", 50)


func alterar_prosperidade_regional(regiao_id: String, delta: int) -> void:
	if not world_data["regions"].has(regiao_id):
		world_data["regions"][regiao_id] = {"seguranca": 50, "prosperidade": 50, "corrupcao": 20, "presenca_predadores": 50, "flags": []}
	var atual: int = world_data["regions"][regiao_id].get("prosperidade", 50)
	var novo: int = clamp(atual + delta, 0, 100)
	world_data["regions"][regiao_id]["prosperidade"] = novo
	estado_regional_alterado.emit(regiao_id, "prosperidade", novo)


func obter_corrupcao_regional(regiao_id: String) -> int:
	var r = world_data["regions"].get(regiao_id, {})
	return r.get("corrupcao", 20)


func alterar_corrupcao_regional(regiao_id: String, delta: int) -> void:
	if not world_data["regions"].has(regiao_id):
		world_data["regions"][regiao_id] = {"seguranca": 50, "prosperidade": 50, "corrupcao": 20, "presenca_predadores": 50, "flags": []}
	var atual: int = world_data["regions"][regiao_id].get("corrupcao", 20)
	var novo: int = clamp(atual + delta, 0, 100)
	world_data["regions"][regiao_id]["corrupcao"] = novo
	estado_regional_alterado.emit(regiao_id, "corrupcao", novo)


func tem_flag_regional(regiao_id: String, flag: String) -> bool:
	var r = world_data["regions"].get(regiao_id, {})
	var flags: Array = r.get("flags", [])
	return flags.has(flag)


func adicionar_flag_regional(regiao_id: String, flag: String) -> void:
	if not world_data["regions"].has(regiao_id):
		world_data["regions"][regiao_id] = {"seguranca": 50, "prosperidade": 50, "corrupcao": 20, "presenca_predadores": 50, "flags": []}
	var flags: Array = world_data["regions"][regiao_id].get("flags", [])
	if not flags.has(flag):
		flags.append(flag)
		world_data["regions"][regiao_id]["flags"] = flags


# ============================================================
# API DE FACÇÕES E INFLUÊNCIA
# ============================================================

func obter_influencia_faccao(faccao_id: String) -> int:
	var f = world_data["factions"].get(faccao_id, {})
	return f.get("influencia", 50)


func alterar_influencia_faccao(faccao_id: String, delta: int) -> void:
	if not world_data["factions"].has(faccao_id):
		world_data["factions"][faccao_id] = {"influencia": 50, "estado_guerra": []}
	var atual: int = world_data["factions"][faccao_id].get("influencia", 50)
	var novo: int = clamp(atual + delta, 0, 100)
	world_data["factions"][faccao_id]["influencia"] = novo
	faccao_influencia_alterada.emit(faccao_id, novo, delta)


# ============================================================
# CONSEQUÊNCIAS DO JOGADOR (INFÂMIA & NOTORIEDADE NEN)
# ============================================================

func obter_infamia() -> int:
	return world_data["player_consequences"].get("infamia", 0)


func alterar_infamia(delta: int) -> void:
	var atual: int = world_data["player_consequences"].get("infamia", 0)
	var novo: int = clamp(atual + delta, 0, 1000)
	world_data["player_consequences"]["infamia"] = novo
	infamia_alterada.emit(novo, delta)


func obter_notoriedade_nen() -> int:
	return world_data["player_consequences"].get("notoriedade_nen", 0)


func alterar_notoriedade_nen(delta: int) -> void:
	var atual: int = world_data["player_consequences"].get("notoriedade_nen", 0)
	var novo: int = clamp(atual + delta, 0, 1000)
	world_data["player_consequences"]["notoriedade_nen"] = novo
	notoriedade_nen_alterada.emit(novo, delta)


func registrar_crime(tipo_crime: String, gravidade: int, regiao_id: String = "vale_padokia") -> void:
	var pc = world_data["player_consequences"]
	pc["crimes_cometidos"] = pc.get("crimes_cometidos", 0) + 1
	var delta_infamia = gravidade * 10
	alterar_infamia(delta_infamia)
	alterar_seguranca_regional(regiao_id, -gravidade * 5)
	
	if ReputationSystem != null:
		ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CIVIS, -gravidade * 15, "Crime: " + tipo_crime)
		ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CRIMINOSOS, gravidade * 10, "Reputação no Submundo")

	# Adicionar efeito temporário de Alerta Máximo
	adicionar_efeito_temporario("alerta_guardas_" + regiao_id, 24.0, {"regiao": regiao_id, "gravidade": gravidade})
	consequencia_processada.emit("CRIME", "Crime registrado: %s em %s" % [tipo_crime, regiao_id], 24.0)


# ============================================================
# API DE EFEITOS TEMPORÁRIOS & TIMED CONSEQUENCES
# ============================================================

func adicionar_efeito_temporario(id_efeito: String, duracao_horas: float, dados: Dictionary = {}) -> void:
	world_data["timed_effects"][id_efeito] = {
		"horas_restantes": duracao_horas,
		"duracao_total": duracao_horas,
		"dados": dados
	}
	efeito_temporario_iniciado.emit(id_efeito, duracao_horas)


func remover_efeito_temporario(id_efeito: String) -> void:
	if world_data["timed_effects"].has(id_efeito):
		world_data["timed_effects"].erase(id_efeito)
		efeito_temporario_expirado.emit(id_efeito)


func tem_efeito_temporario(id_efeito: String) -> bool:
	return world_data["timed_effects"].has(id_efeito)


func obter_horas_restantes_efeito(id_efeito: String) -> float:
	var ef = world_data["timed_effects"].get(id_efeito, {})
	return ef.get("horas_restantes", 0.0)


func processar_tick_tempo(horas_passadas: float) -> void:
	var timed: Dictionary = world_data["timed_effects"]
	var expirados: Array[String] = []

	for k in timed.keys():
		timed[k]["horas_restantes"] -= horas_passadas
		if timed[k]["horas_restantes"] <= 0.0:
			expirados.append(k)

	for exp_id in expirados:
		timed.erase(exp_id)
		efeito_temporario_expirado.emit(exp_id)

	# Decaimento natural de infâmia (-1 a cada 12 horas)
	if obter_infamia() > 0:
		var decaimento = int(horas_passadas / 12.0)
		if decaimento > 0:
			alterar_infamia(-decaimento)


func _on_time_hour_ticked(_hour: int, _minute: int) -> void:
	processar_tick_tempo(1.0)


# ============================================================
# DISPATCHER DE CONSEQUÊNCIAS CAUSAIS
# ============================================================

func _on_enemy_defeated(enemy_id: String, _xp: int, _nen_xp: int) -> void:
	match enemy_id.to_lower():
		"guardiao_zaban", "guardiao_ancestral":
			# Consequência 1: Derrota do Boss das Ruínas
			adicionar_flag_regional("ruinas_zaban", "guardiao_derrotado")
			adicionar_flag_regional("vale_padokia", "posto_hunter_ativo")
			alterar_seguranca_regional("vale_padokia", +25)
			alterar_prosperidade_regional("vale_padokia", +20)
			alterar_corrupcao_regional("vale_padokia", -15)
			alterar_influencia_faccao("associacao_hunter", +20)
			alterar_notoriedade_nen(+35)
			adicionar_efeito_temporario("miasma_dissipado_zaban", 48.0)
			consequencia_processada.emit("BOSS_DEFEATED", "Guardião de Zaban derrotado: Miasma dissipado por 48h e Posto Hunter liberado.", 48.0)

		"bandido", "ladrao_padokia":
			# Consequência 4: Limpeza de Bandidos
			alterar_seguranca_regional("vale_padokia", +2)
			alterar_prosperidade_regional("vale_padokia", +1)
			adicionar_efeito_temporario("patrulha_bandidos_suprimida", 24.0)


func _on_quest_completed(quest_id: String, _xp: int, _jenny: int) -> void:
	if "wing" in quest_id.to_lower() or "treino" in quest_id.to_lower():
		# Consequência 3: Treino com Mestre Wing
		alterar_notoriedade_nen(+40)
		adicionar_efeito_temporario("bônus_maestria_wing", 24.0, {"bonus_xp_pct": 50})
		consequencia_processada.emit("QUEST_WING", "Treino de Wing Concluído: Bônus de +50% Nen XP ativado por 24h.", 24.0)


func _on_nen_technique_activated(tech_name: String) -> void:
	if tech_name == "KO":
		# Consequência 5: Uso de KO
		alterar_notoriedade_nen(+2)


# ============================================================
# PERSISTÊNCIA MULTI-SLOT (JSON SAVE/LOAD)
# ============================================================

func salvar_dados() -> Dictionary:
	return world_data.duplicate(true)


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		reinicializar_estado_padrao()
		return
	world_data = dados.duplicate(true)