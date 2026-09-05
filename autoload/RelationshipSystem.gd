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
signal status_social_alterado(npc_id: String, dados: Dictionary)
signal escolha_social_realizada(npc_id: String, escolha: int, resultado: Dictionary)
signal segredo_desbloqueado(npc_id: String, segredo_id: String)
signal missao_relacionamento_desbloqueada(npc_id: String, quest_id: String)

enum EscolhaSocial {
	AJUDAR,
	MENTIR,
	INTIMIDAR,
	TRAIR
}

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
			"trust": 85.0,
			"respect": 90.0,
			"fear": 0.0,
			"friendship": 75.0,
			"rivalry": 0.0,
			"debt": 0.0,
			"faction": "associacao_hunter",
			"segredos": ["fundamentos_secretos_hatsu", "historia_mestre_netero"],
			"missoes_confianca": ["treino_avancado_nen"]
		},
		"biscuit": {
			"trust": 70.0,
			"respect": 85.0,
			"fear": 20.0,
			"friendship": 65.0,
			"rivalry": 10.0,
			"debt": 0.0,
			"faction": "associacao_hunter",
			"segredos": ["polimento_de_aura_avancado", "segredos_pedras_preciosas"],
			"missoes_confianca": ["treino_mestre_shingen_ryu"]
		},
		"hisoka": {
			"trust": 5.0,
			"respect": 75.0,
			"fear": 70.0,
			"friendship": 10.0,
			"rivalry": 95.0,
			"debt": 0.0,
			"faction": "genei_ryodan",
			"segredos": ["taticas_bungee_gum", "observacoes_da_trupe"],
			"missoes_confianca": ["duelo_mortal_torre"]
		},
		"killua": {
			"trust": 85.0,
			"respect": 80.0,
			"fear": 0.0,
			"friendship": 90.0,
			"rivalry": 20.0,
			"debt": 0.0,
			"faction": "civis",
			"segredos": ["tecnicas_assassinato_zoldyck"],
			"missoes_confianca": ["infiltracao_montanha_kukuroo"]
		},
		"kurapika": {
			"trust": 80.0,
			"respect": 85.0,
			"fear": 10.0,
			"friendship": 80.0,
			"rivalry": 5.0,
			"debt": 0.0,
			"faction": "associacao_hunter",
			"segredos": ["olhos_escarlates_lore", "leilao_submundo_info"],
			"missoes_confianca": ["caca_aos_olhos_escarlates"]
		},
		"leorio": {
			"trust": 90.0,
			"respect": 70.0,
			"fear": 0.0,
			"friendship": 95.0,
			"rivalry": 0.0,
			"debt": 0.0,
			"faction": "civis",
			"segredos": ["contatos_medicina_submundo"],
			"missoes_confianca": ["suprimentos_medicos_emergencia"]
		},
		"ferreiro_padokia": {
			"trust": 50.0,
			"respect": 40.0,
			"fear": 0.0,
			"friendship": 45.0,
			"rivalry": 0.0,
			"debt": 0.0,
			"faction": "mercadores",
			"segredos": ["mina_secreta_padokia"],
			"missoes_confianca": ["forja_espada_nen"]
		},
		"capitao_guarda": {
			"trust": 45.0,
			"respect": 50.0,
			"fear": 0.0,
			"friendship": 40.0,
			"rivalry": 5.0,
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
			"friendship": 50.0,
			"rivalry": 0.0,
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


func obter_amizade(npc_id: String) -> float:
	return obter_dados_npc(npc_id).get("friendship", 50.0)


func obter_rivalidade(npc_id: String) -> float:
	return obter_dados_npc(npc_id).get("rivalry", 0.0)


func obter_rotulo_relacionamento(npc_id: String) -> String:
	var dados = obter_dados_npc(npc_id)
	var t: float = dados.get("trust", 50.0)
	var r: float = dados.get("respect", 50.0)
	var f: float = dados.get("fear", 0.0)
	var fr: float = dados.get("friendship", 50.0)
	var riv: float = dados.get("rivalry", 0.0)

	if r >= 85.0 and t >= 80.0 and fr >= 70.0:
		return "Mestre / Mentor Venerado"
	elif riv >= 80.0 and r >= 70.0:
		return "Rival Mortal Respeitado"
	elif riv >= 70.0:
		return "Inimigo Jurado"
	elif fr >= 85.0 and t >= 80.0:
		return "Aliado Fraterno"
	elif f >= 75.0:
		return "Aterrorizado / Submisso"
	elif fr >= 65.0:
		return "Companheiro Leal"
	elif t >= 65.0:
		return "Contato de Confiança"
	return "Conhecido Neutro"


func alterar_relacionamento(
	npc_id: String,
	d_trust: float,
	d_respect: float,
	d_fear: float,
	d_friendship: float = 0.0,
	d_rivalry: float = 0.0,
	motivo: String = ""
) -> void:
	var dados = obter_dados_npc(npc_id)
	var old_trust = dados.get("trust", 50.0)

	dados["trust"] = clamp(dados.get("trust", 50.0) + d_trust, 0.0, 100.0)
	dados["respect"] = clamp(dados.get("respect", 50.0) + d_respect, 0.0, 100.0)
	dados["fear"] = clamp(dados.get("fear", 0.0) + d_fear, 0.0, 100.0)
	dados["friendship"] = clamp(dados.get("friendship", 50.0) + d_friendship, 0.0, 100.0)
	dados["rivalry"] = clamp(dados.get("rivalry", 0.0) + d_rivalry, 0.0, 100.0)

	relacionamento_alterado.emit(npc_id, dados["trust"], dados["respect"], dados["fear"])
	status_social_alterado.emit(npc_id, dados)

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
		print("[Relationship] %s modificado (%s): Conf=%.1f | Resp=%.1f | Medo=%.1f | Amiz=%.1f | Riv=%.1f" % [
			npc_id, motivo, dados["trust"], dados["respect"], dados["fear"], dados["friendship"], dados["rivalry"]
		])


func aplicar_escolha_social(npc_id: String, escolha: EscolhaSocial, quest_id: String = "") -> Dictionary:
	var dt: float = 0.0
	var dr: float = 0.0
	var df: float = 0.0
	var d_amiz: float = 0.0
	var d_riv: float = 0.0
	var rotulo_escolha: String = ""

	match escolha:
		EscolhaSocial.AJUDAR:
			rotulo_escolha = "Ajudar"
			dt = 15.0
			dr = 10.0
			df = -5.0
			d_amiz = 20.0
			d_riv = -10.0
		EscolhaSocial.MENTIR:
			rotulo_escolha = "Mentir"
			dt = -20.0
			dr = -5.0
			df = 0.0
			d_amiz = -10.0
			d_riv = 15.0
		EscolhaSocial.INTIMIDAR:
			rotulo_escolha = "Intimidar"
			dt = -15.0
			dr = 10.0
			df = 30.0
			d_amiz = -25.0
			d_riv = 25.0
		EscolhaSocial.TRAIR:
			rotulo_escolha = "Trair"
			dt = -50.0
			dr = -30.0
			df = 20.0
			d_amiz = -50.0
			d_riv = 60.0

	var motivo = "Escolha Social: %s (Quest: %s)" % [rotulo_escolha, quest_id if not quest_id.is_empty() else "N/A"]
	alterar_relacionamento(npc_id, dt, dr, df, d_amiz, d_riv, motivo)

	var resultado = {
		"npc_id": npc_id,
		"escolha": rotulo_escolha,
		"delta_trust": dt,
		"delta_respect": dr,
		"delta_fear": df,
		"delta_friendship": d_amiz,
		"delta_rivalry": d_riv,
		"rotulo_final": obter_rotulo_relacionamento(npc_id)
	}

	escolha_social_realizada.emit(npc_id, int(escolha), resultado)

	if EventBus != null:
		var cor_toast = Color(0.3, 0.9, 0.4) if dt > 0 else (Color(1.0, 0.4, 0.2) if escolha == EscolhaSocial.TRAIR else Color(0.9, 0.8, 0.3))
		EventBus.emit_toast("Vínculo com %s: %s (%s)" % [npc_id.capitalize(), rotulo_escolha, resultado["rotulo_final"]], cor_toast)

	if WorldState != null and WorldState.has_method("registrar_marco_historico"):
		WorldState.registrar_marco_historico("escolha_%s_%s" % [npc_id, rotulo_escolha.to_lower()], resultado)

	return resultado


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