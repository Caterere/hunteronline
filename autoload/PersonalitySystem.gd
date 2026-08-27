extends Node

# ============================================================
# HUNTER ONLINE - PERSONALITY & MORALITY SYSTEM (AUTOLOAD)
# ============================================================
#
# Modela a evolução psicológica e traços de personalidade do personagem
# com base em suas escolhas em diálogos, missões e estilo de combate:
# - Agressivo
# - Covarde / Cauteloso
# - Honrado
# - Ganancioso
# - Calculista
# - Sádico
# - Leal
#
# ============================================================

signal personalidade_alterada(traco_dominante: String)

enum Traco {
	AGRESSIVO,
	COVARDE,
	HONRADO,
	GANANCIOSO,
	CALCULISTA,
	SADICO,
	LEAL
}

const NOMES_TRACOS := {
	Traco.AGRESSIVO: "Agressivo",
	Traco.COVARDE: "Cauteloso / Covarde",
	Traco.HONRADO: "Honrado",
	Traco.GANANCIOSO: "Ganancioso",
	Traco.CALCULISTA: "Calculista",
	Traco.SADICO: "Sádico",
	Traco.LEAL: "Leal"
}

var pontos_personalidade: Dictionary = {
	Traco.AGRESSIVO: 5,
	Traco.COVARDE: 0,
	Traco.HONRADO: 10,
	Traco.GANANCIOSO: 5,
	Traco.CALCULISTA: 8,
	Traco.SADICO: 0,
	Traco.LEAL: 12
}


func _ready() -> void:
	add_to_group("personality_system")
	print("=================================")
	print("[PersonalitySystem] SISTEMA DE PERSONALIDADE INICIADO")
	print("TRAÇO DOMINANTE ATUAL: ", obter_traco_dominante())
	print("=================================")


func adicionar_pontos(traco: Traco, valor: int = 1) -> void:
	var atual: int = pontos_personalidade.get(traco, 0)
	pontos_personalidade[traco] = atual + valor
	personalidade_alterada.emit(obter_traco_dominante())
	print("[Personality] +%d em %s. Dominante: %s" % [valor, NOMES_TRACOS.get(traco, ""), obter_traco_dominante()])


func obter_pontos(traco: Traco) -> int:
	return pontos_personalidade.get(traco, 0)


func obter_traco_dominante() -> String:
	var maior_pontuacao: int = -1
	var dominante: Traco = Traco.HONRADO
	
	for t in pontos_personalidade.keys():
		var pts = pontos_personalidade[t]
		if pts > maior_pontuacao:
			maior_pontuacao = pts
			dominante = t
			
	return NOMES_TRACOS.get(dominante, "Honrado")


func obter_descricao_psicologica() -> String:
	var dom = obter_traco_dominante()
	match dom:
		"Agressivo":
			return "Você resolve conflitos com força direta e intimidação. Inimigos hesitam antes de atacá-lo."
		"Cauteloso / Covarde":
			return "Você prioriza sobrevivência acima de tudo, fugindo de lutas desnecessárias com precisão."
		"Honrado":
			return "Você segue um código de conduta inabalável. NPCs civis e mestres confiam em sua palavra."
		"Ganancioso":
			return "Você calcula todas as ações pelo retorno financeiro em Jenny. Negociador implacável."
		"Calculista":
			return "Você analisa a aura, fraquezas e probabilidades antes de desferir qualquer movimento."
		"Sádico":
			return "Você se delicia com o sofrimento e a queda dos oponentes. Aura emanando crueldade."
		"Leal":
			return "Você sacrificaria a própria vida para proteger seus companheiros e aliados de caçada."
		_:
			return "Equilíbrio emocional em desenvolvimento."
