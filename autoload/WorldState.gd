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
			"custom_flags": {},
			"marcos_historicos": {}
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
# DISPATCHER DE CONSEQUÊNCIAS CAUSAIS & MEMÓRIA CONTEXTUAL (TASK 3.2)
# ============================================================

func registrar_marco_historico(marco_id: String, dados: Dictionary = {}) -> void:
	if not world_data.has("world"):
		world_data["world"] = {}
	if not world_data["world"].has("marcos_historicos"):
		world_data["world"]["marcos_historicos"] = {}
	world_data["world"]["marcos_historicos"][marco_id] = {
		"timestamp_ticks": Time.get_ticks_msec(),
		"dados": dados
	}
	print("[WorldState] Marco histórico gravado: %s" % marco_id)


func tem_marco_historico(marco_id: String) -> bool:
	if not world_data.has("world") or not world_data["world"].has("marcos_historicos"):
		return false
	return world_data["world"]["marcos_historicos"].has(marco_id)


func obter_marcos_historicos() -> Dictionary:
	if not world_data.has("world") or not world_data["world"].has("marcos_historicos"):
		return {}
	return world_data["world"]["marcos_historicos"]


func registrar_treinamento_mestre(mestre_id: String, tecnica_nen: String) -> void:
	var marco = "treino_%s_%s" % [mestre_id.to_lower(), tecnica_nen.to_lower()]
	registrar_marco_historico(marco, {"mestre": mestre_id, "tecnica": tecnica_nen})
	if EventBus != null:
		EventBus.emit_toast("📜 Ensinamento gravado na memória: %s (%s)" % [mestre_id.capitalize(), tecnica_nen.to_upper()], Color(0.9, 0.85, 0.3))


func registrar_vitoria_boss(boss_id: String, boss_nome: String) -> void:
	var marco = "derrotou_%s" % boss_id.to_lower()
	registrar_marco_historico(marco, {"boss_id": boss_id, "boss_nome": boss_nome})
	if EventBus != null:
		EventBus.emit_toast("🏆 Fama Pública: Derrota de %s reconhecida pelo mundo!" % boss_nome, Color(1.0, 0.85, 0.2))


func obter_dialogo_contextual_npc(npc_id: String) -> String:
	var lower_id := npc_id.to_lower()
	match lower_id:
		"wing":
			if tem_marco_historico("treino_wing_gyo") or tem_marco_historico("treino_wing_nen"):
				return "Ainda usando aquele Gyo que ensinei? Lembre-se: ver além do óbvio é a essência do combate com Nen."
			if tem_marco_historico("derrotou_guardiao_zaban"):
				return "Soube da sua vitória contra o Guardião das Ruínas. Sua aura está consideravelmente mais estável."
			return "Ten, Zetsu, Ren e Hatsu... Nunca negligencie as quatro grandes bases."

		"biscuit":
			if tem_marco_historico("treino_biscuit_ko") or tem_marco_historico("treino_biscuit_nen"):
				return "Espero que não tenha relaxado no polimento do Ko! Seus músculos de Nen precisam de 10.000 repetições diárias!"
			if tem_marco_historico("derrotou_razor"):
				return "Você conseguiu rebater o saque de Razor?! Hohoho... Nada mal para quem parecia uma pedra bruta!"
			return "Ei, garoto! Quer aprender Nen de verdade ou vai continuar brincando de Caçador?"

		"hisoka":
			if tem_marco_historico("derrota_hisoka"):
				return "♠ Schwing~! Vejo que sobreviveu à nossa última colheita... Que fruto resiliente você se tornou. ♦"
			if tem_marco_historico("derrotou_hisoka"):
				return "♦ Um gosto amargo de derrota... Mas que promete uma colheita ainda mais esplêndida no topo da Torre. ♥"
			return "♥ Mostre-me sua sede de sangue... Não me deixe entediado. ♣"

		"razor":
			if tem_marco_historico("derrotou_razor"):
				return "🏐 Aquela recepção foi histórica. Ging tinha razão em confiar no potencial desta nova geração."
			return "🏐 Esta quadra não aceita desculpas. Firme os pés e concentre Ryu!"

		"civis", "habitante_vila", "guardiao_zaban", "aldeao":
			if tem_marco_historico("derrotou_guardiao_zaban"):
				return "Olhem! Aquele é o Caçador que derrotou o monstro das ruínas e desfez o miasma venenoso!"
			if tem_marco_historico("derrotou_hisoka"):
				return "Dizem que aquele viajante enfrentou o temido Mágico da Trupe e sobreviveu!"
			return "Dizem que feras mágicas têm rondado a floresta depois do entardecer. Tenha muito cuidado!"

	return "Saudações, Caçador. Que os ventos favoreçam sua jornada."


func _on_enemy_defeated(enemy_id: String, _xp: int, _nen_xp: int) -> void:
	var e_lower = enemy_id.to_lower()
	registrar_vitoria_boss(e_lower, enemy_id)

	match e_lower:
		"guardiao_zaban", "guardiao_ancestral":
			adicionar_flag_regional("ruinas_zaban", "guardiao_derrotado")
			adicionar_flag_regional("vale_padokia", "posto_hunter_ativo")
			alterar_seguranca_regional("vale_padokia", +25)
			alterar_prosperidade_regional("vale_padokia", +20)
			alterar_corrupcao_regional("vale_padokia", -15)
			alterar_influencia_faccao("associacao_hunter", +20)
			alterar_notoriedade_nen(+35)
			adicionar_efeito_temporario("miasma_dissipado_zaban", 48.0)
			consequencia_processada.emit("BOSS_DEFEATED", "Guardião de Zaban derrotado: Miasma dissipado por 48h e Posto Hunter liberado.", 48.0)

		"hisoka", "boss_hisoka":
			alterar_notoriedade_nen(+75)
			adicionar_efeito_temporario("reconhecimento_torre_celestial", 72.0)
			consequencia_processada.emit("BOSS_DEFEATED", "Hisoka derrotado na Torre Celestial: Mestre do Andar liberado.", 72.0)

		"razor", "boss_razor":
			alterar_notoriedade_nen(+80)
			adicionar_flag_regional("arena_celestial", "saque_de_razor_superado")
			consequencia_processada.emit("BOSS_DEFEATED", "Razor derrotado em Greed Island: Provação dos 14 Demônios concluída.", 72.0)

		"meruem", "boss_meruem":
			alterar_notoriedade_nen(+150)
			adicionar_flag_regional("ruinas_zaban", "ameaca_quimera_aniquilada")
			consequencia_processada.emit("BOSS_DEFEATED", "Rei das Formigas Quimera Meruem superado: A humanidade respira aliviada.", 120.0)

		"bandido", "ladrao_padokia":
			alterar_seguranca_regional("vale_padokia", +2)
			alterar_prosperidade_regional("vale_padokia", +1)
			adicionar_efeito_temporario("patrulha_bandidos_suprimida", 24.0)


func _on_quest_completed(quest_id: String, _xp: int, _jenny: int) -> void:
	var q_lower = quest_id.to_lower()
	if "wing" in q_lower or "treino" in q_lower:
		registrar_treinamento_mestre("wing", "gyo")
		alterar_notoriedade_nen(+40)
		adicionar_efeito_temporario("bônus_maestria_wing", 24.0, {"bonus_xp_pct": 50})
		consequencia_processada.emit("QUEST_WING", "Treino de Wing Concluído: Bônus de +50% Nen XP ativado por 24h.", 24.0)
	elif "biscuit" in q_lower:
		registrar_treinamento_mestre("biscuit", "ko")
		alterar_notoriedade_nen(+45)
		adicionar_efeito_temporario("bônus_maestria_biscuit", 24.0, {"bonus_xp_pct": 60})
		consequencia_processada.emit("QUEST_BISCUIT", "Treino de Biscuit Concluído: Polimento de Aura ativado por 24h.", 24.0)


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