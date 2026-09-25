class_name NenPersonalityQuiz
extends RefCounted

# ============================================================
# HUNTER ONLINE — QUESTIONÁRIO DE PERSONALIDADE (HISOKA)
# ============================================================
#
# Não revela Nen. Só mede personalidade e grava seed/scores.
# A afinidade só resolve no Teste da Água (Wing): 90% candidata / 10% Specialist.
#
# ============================================================

const QUIZ_VERSION: int = 1
const SPECIALIST_CHANCE_PERCENT: int = 10

## Chaves estáveis dos scores (não incluem Especialização).
const SCORE_KEYS: Array[String] = [
	"intensificacao",
	"transformacao",
	"emissao",
	"conjuracao",
	"manipulacao",
]


static func empty_scores() -> Dictionary:
	return {
		"intensificacao": 0,
		"transformacao": 0,
		"emissao": 0,
		"conjuracao": 0,
		"manipulacao": 0,
	}


static func obter_perguntas() -> Array[Dictionary]:
	# Personalidade à la Hisoka — sem citar Nen / classes.
	return [
		{
			"id": "objetivo",
			"prompt": "Quando você decide um objetivo…",
			"hint": "Responda com o que mais combina com você.",
			"options": [
				{"text": "Sigo reto até o fim, sem rodeio.", "weights": {"intensificacao": 2}},
				{"text": "Mudo o plano se surgir algo mais interessante.", "weights": {"transformacao": 2}},
				{"text": "Quero resultado rápido — esperar me irrita.", "weights": {"emissao": 2}},
				{"text": "Só ajo quando cada detalhe está no lugar.", "weights": {"conjuracao": 2}},
				{"text": "Primeiro convenço os outros de que meu jeito é o certo.", "weights": {"manipulacao": 2}},
			],
		},
		{
			"id": "discussao",
			"prompt": "Numa discussão, você costuma…",
			"hint": "Pense no seu reflexo, não no ideal.",
			"options": [
				{"text": "“Chega. Vou fazer do meu jeito.”", "weights": {"intensificacao": 2}},
				{"text": "Dizer uma coisa e pensar outra.", "weights": {"transformacao": 2}},
				{"text": "Perder a paciência e cortar o assunto.", "weights": {"emissao": 2}},
				{"text": "Ficar inquieto até achar a falha no argumento.", "weights": {"conjuracao": 2}},
				{"text": "Desmontar a lógica da pessoa ponto a ponto.", "weights": {"manipulacao": 2}},
			],
		},
		{
			"id": "traco",
			"prompt": "O que mais te descreve?",
			"hint": "Escolha o traço mais forte.",
			"options": [
				{"text": "Determinação simples.", "weights": {"intensificacao": 2}},
				{"text": "Humor imprevisível.", "weights": {"transformacao": 2}},
				{"text": "Pressa e espontaneidade.", "weights": {"emissao": 2}},
				{"text": "Tensão / perfeccionismo.", "weights": {"conjuracao": 2}},
				{"text": "Controle pela razão.", "weights": {"manipulacao": 2}},
			],
		},
		{
			"id": "traicao",
			"prompt": "Se alguém traísse sua confiança…",
			"hint": "Primeira reação, não a mais nobre.",
			"options": [
				{"text": "Bater de frente e resolver na hora.", "weights": {"intensificacao": 2}},
				{"text": "Sorrir, fingir que está tudo bem, e revidar depois.", "weights": {"transformacao": 2}},
				{"text": "Explodir na hora.", "weights": {"emissao": 2}},
				{"text": "Remoer em silêncio e planejar cada passo.", "weights": {"conjuracao": 2}},
				{"text": "Virar o jogo com regras e condições.", "weights": {"manipulacao": 2}},
			],
		},
		{
			"id": "grupo",
			"prompt": "Num grupo, seu papel natural é…",
			"hint": "Como os outros te veem de verdade.",
			"options": [
				{"text": "O que segura a linha e não desiste.", "weights": {"intensificacao": 2}},
				{"text": "O imprevisível que muda o clima.", "weights": {"transformacao": 2}},
				{"text": "O que age primeiro e pergunta depois.", "weights": {"emissao": 2}},
				{"text": "O que prepara tudo nos bastidores.", "weights": {"conjuracao": 2}},
				{"text": "O que organiza e dirige os outros.", "weights": {"manipulacao": 2}},
			],
		},
	]


static func score_key_para_categoria(cat: int) -> String:
	match cat:
		NenAffinityData.CategoriaAfinidade.INTENSIFICACAO:
			return "intensificacao"
		NenAffinityData.CategoriaAfinidade.TRANSFORMACAO:
			return "transformacao"
		NenAffinityData.CategoriaAfinidade.EMISSAO:
			return "emissao"
		NenAffinityData.CategoriaAfinidade.CONJURACAO:
			return "conjuracao"
		NenAffinityData.CategoriaAfinidade.MANIPULACAO:
			return "manipulacao"
	return ""


static func categoria_para_score_key(key: String) -> int:
	match key:
		"intensificacao":
			return NenAffinityData.CategoriaAfinidade.INTENSIFICACAO
		"transformacao":
			return NenAffinityData.CategoriaAfinidade.TRANSFORMACAO
		"emissao":
			return NenAffinityData.CategoriaAfinidade.EMISSAO
		"conjuracao":
			return NenAffinityData.CategoriaAfinidade.CONJURACAO
		"manipulacao":
			return NenAffinityData.CategoriaAfinidade.MANIPULACAO
	return NenAffinityData.CategoriaAfinidade.INTENSIFICACAO


static func aplicar_pesos(scores: Dictionary, weights: Dictionary) -> void:
	for k in weights.keys():
		var key := str(k)
		if not scores.has(key):
			continue
		scores[key] = int(scores[key]) + int(weights[k])


static func obter_candidata(scores: Dictionary) -> int:
	var best_key := "intensificacao"
	var best_val := -1
	# Empate: prioriza perguntas “Hisoka” (intensificação → manipulação na ordem do hexágono).
	for key in SCORE_KEYS:
		var v := int(scores.get(key, 0))
		if v > best_val:
			best_val = v
			best_key = key
	return categoria_para_score_key(best_key)


static func gerar_seed(nome: String, answer_indices: Array, salt: int = -1) -> String:
	var s := salt
	if s < 0:
		s = int(Time.get_unix_time_from_system()) ^ randi()
	var answers := PackedStringArray()
	for i in answer_indices:
		answers.append(str(int(i)))
	var parts: PackedStringArray = [
		"nq%d" % QUIZ_VERSION,
		nome.strip_edges().to_lower(),
		"|".join(answers),
		str(s),
	]
	return "|".join(parts)


static func _hash_u32(text: String) -> int:
	# FNV-1a 32-bit — estável entre sessões / plataformas.
	var hash_val := 2166136261
	var bytes := text.to_utf8_buffer()
	for b in bytes:
		hash_val ^= int(b)
		hash_val = (hash_val * 16777619) & 0xFFFFFFFF
	return hash_val


static func resolver_afinidade(scores: Dictionary, seed_str: String) -> int:
	var candidata := obter_candidata(scores)
	var roll := _hash_u32(str(seed_str) + "|wing_reveal") % 100
	if roll >= (100 - SPECIALIST_CHANCE_PERCENT):
		return NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO
	return candidata


static func traco_hisoka(cat: int) -> String:
	match cat:
		NenAffinityData.CategoriaAfinidade.INTENSIFICACAO:
			return "simples e determinado"
		NenAffinityData.CategoriaAfinidade.TRANSFORMACAO:
			return "caprichoso e imprevisível — alguém que muda de máscara com facilidade"
		NenAffinityData.CategoriaAfinidade.EMISSAO:
			return "impaciente, de pavio curto"
		NenAffinityData.CategoriaAfinidade.CONJURACAO:
			return "tenso, meticuloso, sempre inquieto com os detalhes"
		NenAffinityData.CategoriaAfinidade.MANIPULACAO:
			return "argumentativo e lógico — quer que o mundo siga sua razão"
		NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
			return "…alguém cuja aura não se encaixa em nenhum canto do hexágono"
	return "único"
