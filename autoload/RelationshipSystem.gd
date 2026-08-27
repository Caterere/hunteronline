class_name RelationshipSystemClass
extends Node

# ============================================================
# HUNTER ONLINE - RELATIONSHIP SYSTEM (SOCIAL MATRIX 2.0)
# ============================================================
#
# Gerencia a rede de relações multidirecionais do mundo vivo:
# 1. PLAYER <-> NPC (Confiança, Respeito, Medo, Dívida)
# 2. NPC <-> NPC (Amizade, Rivalidade, Família, Lealdade)
# 3. NPC <-> FAÇÃO (Afiliação, Dissidência, Devoção)
# 4. FAÇÃO <-> FAÇÃO (Tratados de Paz, Alianças, Guerra Total)
#
# ============================================================

signal relacionamento_alterado(npc_id: String, nova_confianca: float, novo_respeito: float, novo_medo: float)
signal segredo_desbloqueado(npc_id: String, segredo_id: String)
signal missao_relacionamento_desbloqueada(npc_id: String, quest_id: String)

var npc_relations: Dictionary = {}
var faction_diplomacy: Dictionary = {}

func _ready() -> void:
	add_to_group("relationship_system")
	_inicializar_relacionamentos_padrao()
	print("=================================")
	print("[RelationshipSystem] MATRIZ SOCIAL & RELACIONAMENTOS ATIVO")
	print("=================================")


func _inicializar_relacionamentos_padrao() -> void:
	npc_relations = {
		"wing": {
			"trust": 80.0,
			"respect": 90.0,
			"fear": 0.0,
			"debt": 0.0,
			"faction": "associacao_hunter",
			"segredos": ["fundamentos_secretos_hatsu", "historia_mestre_netero"],
			"missoes_confianca": ["treino_avancado_nen"]
		},
		"ferreiro_padokia": {
			"trust": 50.0,
			"respect": 40.0,
			"fear": 0.0,
			"debt": 0.0,
			"faction": "mercadores",
			"segredos": ["mina_secreta_padokia"],
			"missoes_confianca": ["forja_espada_nen"]
		},
		"capitao_guarda": {
			"trust": 45.0,
			"respect": 50.0,
			"fear": 0.0,
			"debt": 0.0,
			"faction": "civis",
			"segredos": ["plano_patrulha_noturna"],
			"missoes_confianca": ["caca_aos_salteadores"]
		}
	}

	faction_diplomacy = {
		"associacao_hunter": {"mafia_yorknew": -500, "zoldyck": 200, "gourmet": 600, "civis": 800},
		"mafia_yorknew": {"associacao_hunter": -500, "genei_ryodan": -1000, "zoldyck": 300, "civis": -200},
		"genei_ryodan": {"mafia_yorknew": -1000, "associacao_hunter": -600, "zoldyck": 0, "civis": -800}
	}


# ============================================================
# API DE RELACIONAMENTO PLAYER <-> NPC
# ============================================================

func obter_dados_npc(npc_id: String) -> Dictionary:
	if not npc_relations.has(npc_id):
		npc_relations[npc_id] = {
			"trust": 50.0,
			"respect": 50.0,
			"fear": 0.0,
			"debt": 0.0,
			"faction": "civis",
			"segredos": [],
			"missoes_confianca": []
		}
	return npc_relations[npc_id]


func obter_confianca(npc_id: String) -> float:
	return obter_dados_npc(npc_id).get("trust", 50.0)


func obter_respeito(npc_id: String) -> float:
	return obter_dados_npc(npc_id).get("respect", 50.0)


func obter_medo(npc_id: String) -> float:
	return obter_dados_npc(npc_id).get("fear", 0.0)


func alterar_relacionamento(npc_id: String, d_trust: float, d_respect: float, d_fear: float, motivo: String = "") -> void:
	var dados = obter_dados_npc(npc_id)
	var old_trust = dados["trust"]
	
	dados["trust"] = clamp(dados["trust"] + d_trust, 0.0, 100.0)
	dados["respect"] = clamp(dados["respect"] + d_respect, 0.0, 100.0)
	dados["fear"] = clamp(dados["fear"] + d_fear, 0.0, 100.0)
	
	relacionamento_alterado.emit(npc_id, dados["trust"], dados["respect"], dados["fear"])
	
	# Verificar se desbloqueou segredos com confiança >= 75
	if old_trust < 75.0 and dados["trust"] >= 75.0:
		var segredos: Array = dados.get("segredos", [])
		for s in segredos:
			segredo_desbloqueado.emit(npc_id, s)
			if EventBus != null:
				EventBus.emit_toast("🔓 Novo Segredo Revelado por %s!" % npc_id.capitalize(), Color(0.3, 0.9, 1.0))
				
	# Verificar se desbloqueou missão exclusiva com confiança >= 60
	if old_trust < 60.0 and dados["trust"] >= 60.0:
		var missoes: Array = dados.get("missoes_confianca", [])
		for m in missoes:
			missao_relacionamento_desbloqueada.emit(npc_id, m)

	if not motivo.is_empty():
		print("[Relationship] %s modificado (%s): Confiança=%.1f | Respeito=%.1f | Medo=%.1f" % [
			npc_id, motivo, dados["trust"], dados["respect"], dados["fear"]
		])


func pode_revelar_segredo(npc_id: String) -> bool:
	return obter_confianca(npc_id) >= 75.0 or obter_medo(npc_id) >= 80.0


func pode_oferecer_missao(npc_id: String) -> bool:
	return obter_confianca(npc_id) >= 60.0


# ============================================================
# PERSISTÊNCIA SAVE / LOAD
# ============================================================

func salvar_dados() -> Dictionary:
	return {
		"npc_relations": npc_relations.duplicate(true),
		"faction_diplomacy": faction_diplomacy.duplicate(true)
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		_inicializar_relacionamentos_padrao()
		return
	npc_relations = dados.get("npc_relations", {}).duplicate(true)
	faction_diplomacy = dados.get("faction_diplomacy", {}).duplicate(true)