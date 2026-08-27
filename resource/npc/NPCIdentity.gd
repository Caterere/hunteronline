class_name NPCIdentity
extends Resource

# ============================================================
# HUNTER ONLINE - NPC IDENTITY & SOCIAL PROFILE (LIVING WORLD)
# ============================================================

@export var identity_id: String = ""
@export var name: String = "Cidadão"
@export var age: int = 25
@export var profession: String = "Morador"
@export var faction_id: String = "civis"
@export var home_position: Vector2 = Vector2.ZERO
@export var work_position: Vector2 = Vector2.ZERO

# Traços de Personalidade: "corajoso", "medroso", "ganancioso", "leal", "honrado", "calculista"
@export var personality_traits: Array[String] = ["leal"]

# Valores Base com o Jogador (0 a 100)
@export var trust: float = 50.0      # Confiança (revela segredos / descontos)
@export var respect: float = 50.0    # Respeito (disposição para ajudar)
@export var fear: float = 0.0        # Medo (intimidação por Nen / infâmia)
@export var debt: float = 0.0        # Dívida moral / favores devidos

@export var is_alive: bool = true
@export var is_nen_user: bool = false
@export var nen_level_known: int = 0

# Conhecimento e Segredos que este NPC possui
@export var known_rumors: Array[String] = []
@export var secret_clues: Array[String] = []

# Histórico de Memória: Array de Dicionários {"id", "tipo", "intensidade", "timestamp_hora", "descricao"}
@export var memory_log: Array[Dictionary] = []


func adicionar_memoria(tipo: String, descricao: String, intensidade: float, timestamp_hora: int) -> void:
	var entry = {
		"tipo": tipo, # "AJUDA", "CRIME", "SALVOU_VIDA", "TESTEMUNHA_NEN", "TRAICAO", "COMERCIO"
		"descricao": descricao,
		"intensidade": intensidade,
		"hora": timestamp_hora,
		"permanente": intensidade >= 70.0
	}
	memory_log.append(entry)
	
	# Ajustar estatísticas emocionais instantaneamente
	match tipo:
		"SALVOU_VIDA":
			trust = min(100.0, trust + 40.0)
			respect = min(100.0, respect + 35.0)
			debt = min(100.0, debt + 50.0)
		"AJUDA":
			trust = min(100.0, trust + 15.0)
			respect = min(100.0, respect + 10.0)
		"CRIME":
			trust = max(0.0, trust - 35.0)
			fear = min(100.0, fear + 30.0)
		"TESTEMUNHA_NEN":
			if is_nen_user:
				respect = min(100.0, respect + 20.0)
			else:
				fear = min(100.0, fear + 25.0)
		"TRAICAO":
			trust = 0.0
			respect = max(0.0, respect - 50.0)


func obter_resumo_social() -> String:
	return "%s (%s) | Confiança: %d | Respeito: %d | Medo: %d" % [name, profession, int(trust), int(respect), int(fear)]