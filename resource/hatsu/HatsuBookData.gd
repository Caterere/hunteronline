class_name HatsuBookData
extends Resource

# ============================================================
# HUNTER ONLINE - HATSU BOOK DATA (GRIMÓRIO DE NEN / SKILL HUNTER)
# ============================================================
#
# Representa um Livro/Grimório de Nen flexível e baseado em regras.
# Gerencia armazenamento de páginas, roubo de habilidades pelo mundo,
# habilidades incompletas (investigação), uso simultâneo com Marcador
# e a pesagem de equilíbrio (Restriction Power vs Hatsu Power).
#
# ============================================================

@export var nome_livro: String = "Arquivo dos Segredos"
@export var capacidade_maxima: int = 10
@export var permite_marcador_duplo: bool = true
@export var permite_roubo_combate: bool = true
@export var manter_indefinidamente: bool = true

# Slots de Uso
@export var pagina_slot_principal: int = 0
@export var pagina_slot_marcador: int = -1 # -1 = sem marcador inserido

# Listas de Restrições Ativas
@export var restricoes_aquisicao: Array[String] = [
	"OBSERVAR_USO",      # 1. Precisa ver o Hatsu sendo usado em combate
	"DESCOBRIR_REGRAS",  # 2. Precisa descobrir o nome e funcionamento
	"TOQUE_FISICO",      # 3. Precisa tocar a palma da mão no oponente
	"RITUAL_TEMPO"       # 4. Precisa cumprir as etapas em até 1 hora
]

@export var restricoes_uso: Array[String] = [
	"MANTER_LIVRO_ABERTO", # Precisa manter o livro aberto na mão direita
	"PROIBICAO_REN_DUPLO"  # Bloqueia Ren enquanto usar 2 Hatsus simultâneos
]

@export var restricoes_risco: Array[String] = [
	"MORTE_USUARIO_REMOVE" # Se o dono original morrer, o Hatsu desaparece
]

# Páginas Armazenadas no Livro
# Cada página é um Dictionary com:
# {
#   "id": "chain_prison",
#   "nome": "Chain Prison",
#   "categoria": HatsuData.Categoria.CONJURACAO,
#   "usuario_original": "Kurapika",
#   "descricao": "Corrente indestrutível que impõe Zetsu em membros da Aranha.",
#   "tags": ["weapon", "restraint", "zetsu_lock"],
#   "status_descoberta": "COMPLETO", # "COMPLETO" ou "INCOMPLETO"
#   "condicoes_descobertas": ["Uso exclusivo contra a Genei Ryodan", "Se errar o usuário morre"],
#   "eficiencia_base": 1.0,
#   "hatsu_ref": HatsuData
# }
@export var paginas: Array[Dictionary] = []

# Balanço Matemático
@export var hatsu_power: int = 100
@export var restriction_power: int = 115
@export var balance_score: int = 15


# ============================================================
# CÁLCULO DE PODER E BALANCE SCORE
# ============================================================

func calcular_balanco() -> Dictionary:
	var power_calc: int = 0

	# 1. Custos de Capacidade (Hatsu Power)
	power_calc += 20 # Armazenamento base (até 5 páginas)
	if capacidade_maxima > 5:
		power_calc += (capacidade_maxima - 5) * 3 # +3 pts por página extra
	if permite_roubo_combate:
		power_calc += 25
	if manter_indefinidamente:
		power_calc += 20
	if permite_marcador_duplo:
		power_calc += 45 # Marcador (Uso Simultâneo) é uma habilidade de altíssimo calibre

	hatsu_power = power_calc

	# 2. Bônus de Restrições (Restriction Power)
	var rest_calc: int = 0
	for r in restricoes_aquisicao:
		match r:
			"OBSERVAR_USO": rest_calc += 20
			"DESCOBRIR_REGRAS": rest_calc += 25
			"TOQUE_FISICO": rest_calc += 30
			"RITUAL_TEMPO": rest_calc += 20
			_: rest_calc += 15

	for r in restricoes_uso:
		match r:
			"MANTER_LIVRO_ABERTO": rest_calc += 25
			"PROIBICAO_REN_DUPLO": rest_calc += 35
			"ZETSU_POS_USO": rest_calc += 40
			"UNICA_VEZ_DIA": rest_calc += 45
			_: rest_calc += 15

	for r in restricoes_risco:
		match r:
			"MORTE_USUARIO_REMOVE": rest_calc += 20
			"FALHA_CAUSA_DANO_HP": rest_calc += 35
			"FALHA_PERDE_HABILIDADE": rest_calc += 40
			_: rest_calc += 15

	restriction_power = rest_calc
	balance_score = restriction_power - hatsu_power

	var status: String = "EQUILIBRADO"
	var ef_global: float = 1.0

	if balance_score >= 0:
		status = "EQUILIBRADO_MAXIMO"
		ef_global = 1.0
	elif balance_score >= -25:
		status = "EQUILIBRADO_PARCIAL"
		ef_global = clamp(1.0 + float(balance_score) * 0.012, 0.70, 0.95)
	elif balance_score >= -60:
		status = "RESTRITO_PESADO"
		ef_global = clamp(0.70 + float(balance_score + 25) * 0.015, 0.30, 0.65)
	else:
		status = "REJEITADO_DESBALANCEADO"
		ef_global = 0.0

	return {
		"hatsu_power": hatsu_power,
		"restriction_power": restriction_power,
		"balance_score": balance_score,
		"status": status,
		"eficiencia_global": ef_global
	}


func obter_eficiencia_global() -> float:
	return float(calcular_balanco().get("eficiencia_global", 1.0))


# ============================================================
# GERENCIAMENTO DE PÁGINAS E HATSUS
# ============================================================

func adicionar_pagina(pagina_data: Dictionary) -> bool:
	if paginas.size() >= capacidade_maxima:
		print("[HatsuBookData] Livro cheio! Capacidade máxima: ", capacidade_maxima)
		return false

	paginas.append(pagina_data)
	print("[HatsuBookData] Nova habilidade arquivada no Livro: #%03d %s" % [paginas.size(), pagina_data.get("nome", "Hatsu")])
	return true


func remover_pagina(indice: int) -> bool:
	if indice >= 0 and indice < paginas.size():
		paginas.remove_at(indice)
		if pagina_slot_principal >= paginas.size():
			pagina_slot_principal = max(0, paginas.size() - 1)
		if pagina_slot_marcador >= paginas.size():
			pagina_slot_marcador = -1
		return true
	return false


func obter_pagina(indice: int) -> Dictionary:
	if indice >= 0 and indice < paginas.size():
		return paginas[indice]
	return {}


func obter_hatsu_ativo() -> HatsuData:
	if pagina_slot_principal >= 0 and pagina_slot_principal < paginas.size():
		return paginas[pagina_slot_principal].get("hatsu_ref", null)
	return null


func obter_hatsu_marcador() -> HatsuData:
	if permite_marcador_duplo and pagina_slot_marcador >= 0 and pagina_slot_marcador < paginas.size():
		return paginas[pagina_slot_marcador].get("hatsu_ref", null)
	return null


func obter_eficiencia_pagina(indice: int, afinidade_jogador: int) -> float:
	var pag = obter_pagina(indice)
	if pag.is_empty(): return 0.0

	var ef_global = obter_eficiencia_global()
	var cat_hatsu: int = int(pag.get("categoria", 0))
	var compat_natal: float = NenAffinityData.calcular_eficiencia_categoria(afinidade_jogador, cat_hatsu)

	# Se for incompleto, sofre penalidade adicional de 40%
	var mult_descoberta: float = 1.0
	if pag.get("status_descoberta", "COMPLETO") == "INCOMPLETO":
		mult_descoberta = 0.40

	return ef_global * compat_natal * mult_descoberta
