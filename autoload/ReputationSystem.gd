extends Node

# ============================================================
# HUNTER ONLINE - REPUTATION SYSTEM (MULTI-FACTION AUTOLOAD)
# ============================================================
#
# Gerencia a reputação independente do jogador com os diferentes grupos
# do universo de Hunter x Hunter:
# - Associação Hunter
# - Máfia / Famílias do Submundo
# - Civis & População
# - Criminosos & Fugitivos
# - Mercadores & Guildas Comerciais
# - Outros Hunters
#
# ============================================================

signal reputacao_alterada(faccao: String, novo_valor: int, delta: int)

enum Faccao {
	ASSOCIACAO_HUNTER,
	MAFIA,
	CIVIS,
	CRIMINOSOS,
	MERCADORES,
	OUTROS_HUNTERS
}

const NOMES_FACCOES := {
	Faccao.ASSOCIACAO_HUNTER: "Associação Hunter",
	Faccao.MAFIA: "Máfia / Submundo",
	Faccao.CIVIS: "Civis & Cidades",
	Faccao.CRIMINOSOS: "Criminosos & Fugitivos",
	Faccao.MERCADORES: "Mercadores & Guildas",
	Faccao.OUTROS_HUNTERS: "Outros Hunters"
}

# Reputação de -1000 (Inimigo Jurado / Procurado) até +1000 (Herói / Lenda)
var reputacao_dados: Dictionary = {
	Faccao.ASSOCIACAO_HUNTER: 150, # Começa ligeiramente favorável
	Faccao.MAFIA: 0,
	Faccao.CIVIS: 100,
	Faccao.CRIMINOSOS: -50,
	Faccao.MERCADORES: 50,
	Faccao.OUTROS_HUNTERS: 80
}


func _ready() -> void:
	add_to_group("reputation_system")
	print("=================================")
	print("[ReputationSystem] SISTEMA DE REPUTAÇÃO INICIADO")
	print("=================================")


func obter_reputacao(faccao: Faccao) -> int:
	return reputacao_dados.get(faccao, 0)


func obter_reputacao_str(nome: String) -> int:
	match nome.to_lower():
		"associacao_hunter", "hunter", "associacao":
			return obter_reputacao(Faccao.ASSOCIACAO_HUNTER)
		"mafia", "submundo":
			return obter_reputacao(Faccao.MAFIA)
		"civis", "populacao", "cidade":
			return obter_reputacao(Faccao.CIVIS)
		"criminosos", "fugitivos":
			return obter_reputacao(Faccao.CRIMINOSOS)
		"mercadores", "lojas", "guildas", "mercador":
			return obter_reputacao(Faccao.MERCADORES)
		"outros_hunters":
			return obter_reputacao(Faccao.OUTROS_HUNTERS)
	return 0



func alterar_reputacao(faccao: Faccao, delta: int, motivo: String = "") -> void:
	var atual: int = reputacao_dados.get(faccao, 0)
	var novo: int = clamp(atual + delta, -1000, 1000)
	reputacao_dados[faccao] = novo
	reputacao_alterada.emit(NOMES_FACCOES.get(faccao, "Desconhecido"), novo, delta)
	
	var sinal_str = "+" if delta >= 0 else ""
	print("[Reputation] %s: %s%d (%s) -> Novo Valor: %d" % [
		NOMES_FACCOES.get(faccao, ""), sinal_str, delta, motivo, novo
	])


func obter_status_nome(faccao: Faccao) -> String:
	var val: int = obter_reputacao(faccao)
	if val >= 750: return "Lenda / Aliado de Honra"
	elif val >= 400: return "Respeitado"
	elif val >= 100: return "Favorável"
	elif val > -100: return "Neutro"
	elif val > -400: return "Desconfiado"
	elif val > -750: return "Hostil"
	else: return "PROCURADO / INIMIGO MORTAL"


func obter_multiplicador_preco_loja() -> float:
	# Reputação com Mercadores e Civis concede até 25% de desconto
	var rep_m = float(obter_reputacao(Faccao.MERCADORES))
	var rep_c = float(obter_reputacao(Faccao.CIVIS))
	var media_rep = (rep_m * 0.7 + rep_c * 0.3)
	
	if media_rep >= 0:
		var desconto = clamp(media_rep / 1000.0 * 0.25, 0.0, 0.25)
		return 1.0 - desconto
	else:
		var taxa = clamp(abs(media_rep) / 1000.0 * 0.35, 0.0, 0.35)
		return 1.0 + taxa


func eh_procurado_pela_mafia() -> bool:
	return obter_reputacao(Faccao.MAFIA) <= -400


func eh_cacador_respeitado() -> bool:
	return obter_reputacao(Faccao.ASSOCIACAO_HUNTER) >= 300
