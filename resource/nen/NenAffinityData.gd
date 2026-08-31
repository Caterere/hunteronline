class_name NenAffinityData
extends Resource

# ============================================================
# HUNTER ONLINE - NEN AFFINITY DATA (HEXÁGONO OFICIAL DE NEN)
# ============================================================
#
# Define as 6 categorias de afinidade natal de Nen em HxH.
# A afinidade é FIXA por personagem e concede bônus permanentes.
#
# ============================================================

enum CategoriaAfinidade {
	INTENSIFICACAO, # Enhancer
	TRANSFORMACAO,  # Transmuter
	EMISSAO,        # Emitter
	CONJURACAO,     # Conjurer
	MANIPULACAO,    # Manipulator
	ESPECIALIZACAO  # Specialist (Raro)
}


static func obter_nome_afinidade(cat: CategoriaAfinidade) -> String:
	match cat:
		CategoriaAfinidade.INTENSIFICACAO: return "Intensificação (Enhancer)"
		CategoriaAfinidade.TRANSFORMACAO: return "Transformação (Transmuter)"
		CategoriaAfinidade.EMISSAO: return "Emissão (Emitter)"
		CategoriaAfinidade.CONJURACAO: return "Conjuração (Conjurer)"
		CategoriaAfinidade.MANIPULACAO: return "Manipulação (Manipulator)"
		CategoriaAfinidade.ESPECIALIZACAO: return "Especialização (Specialist)"
	return "Desconhecida"


static func obter_descricao_afinidade(cat: CategoriaAfinidade) -> String:
	match cat:
		CategoriaAfinidade.INTENSIFICACAO:
			return "Fortalece o corpo e ataques físicos. Bônus: +20% de Vida e +20% de Força."
		CategoriaAfinidade.TRANSFORMACAO:
			return "Altera as propriedades da aura. Bônus: +25% de Aura Máxima e velocidade de regeneração."
		CategoriaAfinidade.EMISSAO:
			return "Projeta a aura à distância. Bônus: +35% de Alcance em Projéteis e -20% de Custo em Hatsu."
		CategoriaAfinidade.CONJURACAO:
			return "Materializa objetos de Nen. Bônus: +30% de Absorção em Escudos e +20% de Defesa."
		CategoriaAfinidade.MANIPULACAO:
			return "Controla objetos ou inimigos. Bônus: +25% de Velocidade de Movimento e controle."
		CategoriaAfinidade.ESPECIALIZACAO:
			return "🌟 CATEGORIA SUPREMA (1 EM 100.000): Possui TODOS os bônus das 5 outras categorias combinados! +50% Vida, +50% Força, +60% Aura Max, +50% Defesa, +40% Velocidade, -40% Custo de Aura, -25% Cooldown e 100% DE EFICIÊNCIA EM TODOS OS HATSU!"
	return ""


static func sortear_afinidade_aleatoria() -> CategoriaAfinidade:
	var rand_val: float = randf()
	if rand_val < 0.26:
		return CategoriaAfinidade.INTENSIFICACAO
	elif rand_val < 0.48:
		return CategoriaAfinidade.TRANSFORMACAO
	elif rand_val < 0.70:
		return CategoriaAfinidade.EMISSAO
	elif rand_val < 0.86:
		return CategoriaAfinidade.CONJURACAO
	elif rand_val < 0.975:
		return CategoriaAfinidade.MANIPULACAO
	else:
		return CategoriaAfinidade.ESPECIALIZACAO # 2.5% de chance (Extremamente Raro na Criação)



# ============================================================
# TABELA DE EFICIÊNCIA DO HEXÁGONO DE NEN (CANON HXH)
# ============================================================

static func calcular_eficiencia_categoria(afinidade_natal: CategoriaAfinidade, categoria_hatsu: HatsuData.Categoria) -> float:
	# ESPECIALISTA: 100% em absolutamente TUDO!
	if afinidade_natal == CategoriaAfinidade.ESPECIALIZACAO:
		return 1.0
		
	# Emperor Time (Kurapika) concede 100% em tudo
	var main_loop := Engine.get_main_loop() as SceneTree
	if main_loop and main_loop.root and main_loop.root.has_node("PlayerData"):
		var p_data: Node = main_loop.root.get_node("PlayerData")
		if p_data and p_data.get("quest_states") and p_data.get("quest_states").get("emperor_time_ativo", false):
			return 1.0

	match afinidade_natal:
		CategoriaAfinidade.INTENSIFICACAO:
			match categoria_hatsu:
				HatsuData.Categoria.INTENSIFICACAO: return 1.0  # 100%
				HatsuData.Categoria.TRANSFORMACAO: return 0.8   # 80% (Adjacente)
				HatsuData.Categoria.EMISSAO: return 0.8         # 80% (Adjacente)
				HatsuData.Categoria.CONJURACAO: return 0.6      # 60% (2 passos)
				HatsuData.Categoria.MANIPULACAO: return 0.6     # 60% (2 passos)
				HatsuData.Categoria.ESPECIALIZACAO: return 0.4  # 40% (Oposta)
				_: return 0.6
				
		CategoriaAfinidade.TRANSFORMACAO:
			match categoria_hatsu:
				HatsuData.Categoria.TRANSFORMACAO: return 1.0   # 100%
				HatsuData.Categoria.INTENSIFICACAO: return 0.8  # 80% (Adjacente)
				HatsuData.Categoria.CONJURACAO: return 0.8      # 80% (Adjacente)
				HatsuData.Categoria.EMISSAO: return 0.6         # 60% (2 passos)
				HatsuData.Categoria.MANIPULACAO: return 0.4     # 40% (Oposta)
				HatsuData.Categoria.ESPECIALIZACAO: return 0.4
				_: return 0.6
				
		CategoriaAfinidade.CONJURACAO:
			match categoria_hatsu:
				HatsuData.Categoria.CONJURACAO: return 1.0      # 100%
				HatsuData.Categoria.TRANSFORMACAO: return 0.8   # 80% (Adjacente)
				HatsuData.Categoria.INTENSIFICACAO: return 0.6  # 60% (2 passos)
				HatsuData.Categoria.MANIPULACAO: return 0.6     # 60% (2 passos)
				HatsuData.Categoria.EMISSAO: return 0.4         # 40% (Oposta)
				HatsuData.Categoria.ESPECIALIZACAO: return 0.4
				_: return 0.6
				
		CategoriaAfinidade.EMISSAO:
			match categoria_hatsu:
				HatsuData.Categoria.EMISSAO: return 1.0         # 100%
				HatsuData.Categoria.INTENSIFICACAO: return 0.8  # 80% (Adjacente)
				HatsuData.Categoria.MANIPULACAO: return 0.8     # 80% (Adjacente)
				HatsuData.Categoria.TRANSFORMACAO: return 0.6   # 60% (2 passos)
				HatsuData.Categoria.CONJURACAO: return 0.4      # 40% (Oposta)
				HatsuData.Categoria.ESPECIALIZACAO: return 0.4
				_: return 0.6
				
		CategoriaAfinidade.MANIPULACAO:
			match categoria_hatsu:
				HatsuData.Categoria.MANIPULACAO: return 1.0     # 100%
				HatsuData.Categoria.EMISSAO: return 0.8         # 80% (Adjacente)
				HatsuData.Categoria.CONJURACAO: return 0.6      # 60% (2 passos)
				HatsuData.Categoria.INTENSIFICACAO: return 0.6  # 60% (2 passos)
				HatsuData.Categoria.TRANSFORMACAO: return 0.4   # 40% (Oposta)
				HatsuData.Categoria.ESPECIALIZACAO: return 0.4
				_: return 0.6

	return 1.0
