class_name WorldEventManagerClass
extends Node

# ============================================================
# HUNTER ONLINE - DYNAMIC WORLD EVENT SYSTEM 2.0
# ============================================================
#
# Gerencia crises, oportunidades e eventos sistêmicos em tempo real:
# 1. CICLO ORGÂNICO: Eventos surgem baseados na segurança e risco da região
# 2. RESOLUÇÃO PELO JOGADOR: Participação ativa gera recompensas e respeito
# 3. RESOLUÇÃO AUTÔNOMA: O mundo simula desfechos mesmo sem o jogador
# 4. CONSEQUÊNCIA REAL: Sucessos e falhas alteram prosperidade, preços e rumores
#
# ============================================================

signal evento_iniciado(evento_id: String, titulo: String, regiao: String)
signal evento_resolvido(evento_id: String, sucesso: bool, intervenção_jogador: bool, recompensa_desc: String)

enum StatusEvento {
	INATIVO,
	EM_ANDAMENTO,
	CONCLUIDO_JOGADOR,
	CONCLUIDO_AUTONOMO,
	FALHADO
}

# Dicionário de Eventos Ativos: { evento_id: { "tipo", "titulo", "desc", "regiao", "duracao_horas", "dificuldade", "status" } }
var active_world_events: Dictionary = {}
var timer_sorteio_horas: float = 0.0

func _ready() -> void:
	add_to_group("world_event_manager")
	_conectar_event_bus()
	print("=================================")
	print("[WorldEventManager] SISTEMA DE EVENTOS DINÂMICOS & RESOLUÇÃO AUTÔNOMA ATIVO")
	print("=================================")


func _conectar_event_bus() -> void:
	if EventBus == null:
		return
	if EventBus.has_signal("time_hour_ticked"):
		EventBus.time_hour_ticked.connect(_on_time_hour_ticked)


func criar_evento_dinamico(id: String, titulo: String, desc: String, regiao: String, duracao_horas: float, dificuldade: int = 50) -> void:
	active_world_events[id] = {
		"id": id,
		"titulo": titulo,
		"descricao": desc,
		"regiao": regiao,
		"horas_restantes": duracao_horas,
		"duracao_total": duracao_horas,
		"dificuldade": dificuldade, # Requer segurança >= dificuldade para resolução autônoma bem sucedida
		"status": StatusEvento.EM_ANDAMENTO
	}
	evento_iniciado.emit(id, titulo, regiao)
	if EventBus != null and EventBus.has_signal("toast_requested"):
		EventBus.emit_toast("⚡ [Evento Mundial] %s (%s)" % [titulo, regiao.capitalize()], Color(1.0, 0.8, 0.2))
	print("[WorldEventManager] Evento Ativado [%s] em %s: %s" % [id, regiao, titulo])


func resolver_evento_jogador(id: String, sucesso: bool) -> void:
	if not active_world_events.has(id):
		return
	var ev = active_world_events[id]
	ev["status"] = StatusEvento.CONCLUIDO_JOGADOR if sucesso else StatusEvento.FALHADO
	
	if sucesso:
		if WorldState != null:
			WorldState.alterar_seguranca_regional(ev["regiao"], +10)
			WorldState.alterar_prosperidade_regional(ev["regiao"], +15)
			WorldState.alterar_notoriedade_nen(+20)
		if ReputationSystem != null:
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CIVIS, +100, "Evento Mundial Resolvido: " + ev["titulo"])
		if RumorSystem != null:
			RumorSystem.criar_rumor("rumor_heroismo_" + id, "Herói Salva " + ev["regiao"].capitalize(), "O jogador interveio e protegeu a região!", ev["regiao"])
		evento_resolvido.emit(id, true, true, "+100 Reputação, +15 Prosperidade")
	else:
		if WorldState != null:
			WorldState.alterar_seguranca_regional(ev["regiao"], -10)
		evento_resolvido.emit(id, false, true, "Falha na missão")

	active_world_events.erase(id)


func processar_resolucao_autonoma(id: String) -> void:
	if not active_world_events.has(id):
		return
	var ev = active_world_events[id]
	var seguranca_atual: int = 50
	if WorldState != null:
		seguranca_atual = WorldState.obter_seguranca_regional(ev["regiao"])

	# Se a segurança regional for maior ou igual à dificuldade do evento, guardas/locais vencem
	var sucesso_autonomo: bool = (seguranca_atual >= ev["dificuldade"])
	
	if sucesso_autonomo:
		ev["status"] = StatusEvento.CONCLUIDO_AUTONOMO
		if WorldState != null:
			WorldState.alterar_seguranca_regional(ev["regiao"], +5)
		if RumorSystem != null:
			RumorSystem.criar_rumor("rumor_guardas_" + id, "Patrulhas Locais Triunfam", "Guardas da região contiveram a crise com sucesso.", ev["regiao"])
		evento_resolvido.emit(id, true, false, "Resolvido autonomamente pelas patrulhas locais")
	else:
		ev["status"] = StatusEvento.FALHADO
		if WorldState != null:
			WorldState.alterar_seguranca_regional(ev["regiao"], -15)
			WorldState.alterar_prosperidade_regional(ev["regiao"], -15)
		if RumorSystem != null:
			RumorSystem.criar_rumor("rumor_desastre_" + id, "Crise em " + ev["regiao"].capitalize(), "A região sofreu perdas graves após ataque não contido!", ev["regiao"])
		evento_resolvido.emit(id, false, false, "Crise não contida: Prosperidade e Segurança reduzidas")

	active_world_events.erase(id)


func _on_time_hour_ticked(_hour: int, _minute: int) -> void:
	var para_resolver: Array[String] = []
	
	for id in active_world_events.keys():
		var ev = active_world_events[id]
		ev["horas_restantes"] -= 1.0
		if ev["horas_restantes"] <= 0.0:
			para_resolver.append(id)

	for id in para_resolver:
		processar_resolucao_autonoma(id)

	# Sorteio orgânico a cada 12 horas
	timer_sorteio_horas += 1.0
	if timer_sorteio_horas >= 12.0:
		timer_sorteio_horas = 0.0
		_sortear_crise_organica()


func _sortear_crise_organica() -> void:
	var regioes = ["vale_padokia", "ruinas_zaban"]
	var reg = regioes[randi() % regioes.size()]
	var ev_id = "crise_" + str(randi() % 10000)
	criar_evento_dinamico(
		ev_id,
		"Ataque de Salteadores da Noite",
		"Bandidos tentam emboscar caravanas de mantimentos na estrada de " + reg,
		reg,
		6.0, # 6 horas para expirar ou resolver
		60   # Dificuldade 60
	)


# ============================================================
# PERSISTÊNCIA SAVE / LOAD
# ============================================================

func salvar_dados() -> Dictionary:
	return {
		"active_world_events": active_world_events.duplicate(true),
		"timer_sorteio_horas": timer_sorteio_horas
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		active_world_events.clear()
		timer_sorteio_horas = 0.0
		return
	active_world_events = dados.get("active_world_events", {}).duplicate(true)
	timer_sorteio_horas = float(dados.get("timer_sorteio_horas", 0.0))