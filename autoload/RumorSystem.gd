class_name RumorSystemClass
extends Node

# ============================================================
# HUNTER ONLINE - RUMOR & INFORMATION PROPAGATION SYSTEM 2.0
# ============================================================
#
# Simula a transmissão orgânica de informações e boatos pela sociedade:
# 1. ORIGEM: Acontecimento gerado por player ou evento mundial
# 2. PROPAGAÇÃO: Propagação de NPC em NPC conforme o tempo passa
# 3. DISTORÇÃO: Modificação da precisão da informação com a distância
# 4. IMPACTO: Rumores geram oportunidades, medo, inflação e quests
#
# ============================================================

signal rumor_gerado(rumor_id: String, titulo: String, regiao: String)
signal rumor_propagado(rumor_id: String, npc_alvo_id: String, precisao: float)

var active_rumors: Dictionary = {}

func _ready() -> void:
	add_to_group("rumor_system")
	_inicializar_rumores_iniciais()
	_conectar_event_bus()
	print("=================================")
	print("[RumorSystem] SISTEMA DE RUMORES & PROPAGAÇÃO SOCIAL ATIVO")
	print("=================================")


func _inicializar_rumores_iniciais() -> void:
	active_rumors = {
		"rumor_exame_hunter": {
			"id": "rumor_exame_hunter",
			"titulo": "O Próximo Exame Hunter em Zaban",
			"descricao": "Dizem que o local da 1ª Fase do Exame fica escondido no subsolo da cidade.",
			"origem_regiao": "ruinas_zaban",
			"precisao": 1.0,
			"alcance_regioes": ["ruinas_zaban", "vale_padokia"],
			"tempo_horas_ativo": 0.0,
			"desbloqueia_poi": "portal_exame_zaban"
		},
		"rumor_mina_padokia": {
			"id": "rumor_mina_padokia",
			"titulo": "Depósitos Ocultos de Aço na Mina de Padokia",
			"descricao": "Garimpeiros juram que blocos de minério de alta pureza podem ser quebrados com Ko.",
			"origem_regiao": "vale_padokia",
			"precisao": 0.9,
			"alcance_regioes": ["vale_padokia"],
			"tempo_horas_ativo": 0.0,
			"desbloqueia_poi": "mina_ouro_ko"
		}
	}


func _conectar_event_bus() -> void:
	if EventBus == null:
		return
	if EventBus.has_signal("time_hour_ticked"):
		EventBus.time_hour_ticked.connect(_on_time_hour_ticked)


func criar_rumor(id: String, titulo: String, desc: String, regiao_origem: String, poi_desbloqueavel: String = "") -> void:
	active_rumors[id] = {
		"id": id,
		"titulo": titulo,
		"descricao": desc,
		"origem_regiao": regiao_origem,
		"precisao": 1.0,
		"alcance_regioes": [regiao_origem],
		"tempo_horas_ativo": 0.0,
		"desbloqueia_poi": poi_desbloqueavel
	}
	rumor_gerado.emit(id, titulo, regiao_origem)
	print("[RumorSystem] Novo rumor gerado em %s: %s" % [regiao_origem, titulo])


func propagar_rumor_para_regiao(rumor_id: String, nova_regiao: String) -> void:
	if not active_rumors.has(rumor_id):
		return
	var r = active_rumors[rumor_id]
	var regs: Array = r["alcance_regioes"]
	if not regs.has(nova_regiao):
		regs.append(nova_regiao)
		# Cada salto geográfico distorce ligeiramente a informação
		r["precisao"] = max(0.4, r["precisao"] - 0.15)
		rumor_propagado.emit(rumor_id, nova_regiao, r["precisao"])


func obter_rumor_para_npc(regiao_npc: String) -> Dictionary:
	var compativeis: Array[Dictionary] = []
	for r in active_rumors.values():
		var regs: Array = r.get("alcance_regioes", [])
		if regs.has(regiao_npc):
			compativeis.append(r)
	if compativeis.is_empty():
		return {}
	return compativeis[randi() % compativeis.size()]


func _on_time_hour_ticked(_hour: int, _minute: int) -> void:
	for r in active_rumors.values():
		r["tempo_horas_ativo"] += 1.0
		# Propagação gradual: após 6 horas, o boato alcança a região vizinha
		if r["tempo_horas_ativo"] == 6.0:
			if r["origem_regiao"] == "vale_padokia":
				propagar_rumor_para_regiao(r["id"], "ruinas_zaban")
			elif r["origem_regiao"] == "ruinas_zaban":
				propagar_rumor_para_regiao(r["id"], "vale_padokia")


# ============================================================
# PERSISTÊNCIA SAVE / LOAD
# ============================================================

func salvar_dados() -> Dictionary:
	return {"active_rumors": active_rumors.duplicate(true)}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		_inicializar_rumores_iniciais()
		return
	active_rumors = dados.get("active_rumors", {}).duplicate(true)