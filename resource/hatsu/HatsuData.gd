class_name HatsuData
extends Resource

# ============================================================
# HUNTER ONLINE - HATSU DATA RESOURCE (CANON HXH NEN SYSTEM)
# ============================================================
#
# Define uma habilidade de Hatsu com sistema completo de:
# 1. 10 Grandes Arquétipos de Hatsu (Kite, Chrollo, Território, Dados, etc.)
# 2. Orçamento de Poder (Power Budget Engine)
# 3. Juramentos e Restrições (Vows & Limitations) em 3 Tiers (🟢, 🟡, 🔴)
# 4. Hatsu Evolutivo (Progressão do Lv. 1 ao Lv. 100)
#
# ============================================================

enum Categoria {
	INTENSIFICACAO,  # Fortalecimento físico, impacto, cura celular
	TRANSFORMACAO,   # Alteração das propriedades da aura (eletricidade, chiclete, lâmina, calor)
	EMISSAO,         # Projeção e sustentação da aura à distância (disparos, socos remotos)
	CONJURACAO,      # Materialização física de objetos, armas ou criaturas de Nen
	MANIPULACAO,     # Controle de matéria, objetos, marionetes ou comandos mentais
	ESPECIALIZACAO   # Habilidades singulares fora das outras 5 (roubo, previsão, regras)
}

enum ObjetivoPrincipal {
	DANO,
	DEFESA,
	CURA,
	MOBILIDADE,
	SUPORTE,
	CONTROLE
}

enum Forma {
	PROJETIL,
	AREA,
	PESSOAL,
	TOQUE,
	ZONA
}

enum Elemento {
	NEN_PURO,
	ELETRICIDADE,
	FOGO,
	GELO,
	VENENO,
	SOM,
	LUZ,
	SOMBRA
}

enum Alvo {
	INIMIGO_UNICO,
	AREA,
	PROPRIO_USUARIO,
	ALIADO
}

enum AlcanceTipo {
	CURTO,
	MEDIO,
	LONGO
}

enum ConsumoDesejado {
	BAIXO,
	MEDIO,
	ALTO
}

enum Tier {
	CONDICAO,    # 🟢 Tier 1: Condição Tática (+15% a +35%)
	JURAMENTO,   # 🟡 Tier 2: Juramento Sério (+40% a +90%)
	VOTO_EXTREMO # 🔴 Tier 3: Voto Extremo / Absoluto (+100% a +250%)
}

enum Arquetipo {
	SIMPLES,            # 1. Golpe Direto / Disparo Convencional
	CONJURACAO_ARMA,    # 2. Conjuração de Arma com Cargas por Abate
	ARSENAL_ROLETA,     # 3. Arsenal & Roleta Aleatória (Crazy Slots de Kite)
	LIVRO_COLECAO,      # 4. Coleção & Arquivo de Hatsu (Skill Hunter de Chrollo)
	TERRITORIO_EN,      # 5. Território de En com Regras de Área
	MARCA_TAG,          # 6. Marcação Tática por Toques (Countdown / Tag)
	OBJETO_MOEDA,       # 7. Moeda da Sorte de Nen (Cara / Coroa)
	OBJETO_CARTAS,      # 8. Baralho de Cartas de Nen (5 Naipes)
	OBJETO_DADO,        # 9. Dado Místico de 6 Faces (Risco vs Recompensa)
	TROCA_SACRIFICIO,   # 10. Troca & Sacrifício Vital (HP ↔ Dano / Aura ↔ Vel)
	CONTRATO_DUELO      # 11. Contrato de Vingança ou Duelo Inviolável
}

enum EstiloVisual {
	PURO_PULSANTE,         # 1. Orbe / Feixe de pura densidade de Nen
	CHAMAS_FOGO,           # 2. Chamas e línguas de fogo ondulantes
	RELAMPAGOS_ELETRICOS,  # 3. Raios e arcos elétricos bifurcados
	LAMINA_CORTE,          # 4. Meia-lua cortante afiada com rastro
	SHURIKEN_GIRATORIO,    # 5. Shuriken rotativo de alta velocidade
	ANEIS_IMPACTO,         # 6. Ondas sísmicas em anéis concêntricos
	NEVOA_SOMBRIAS,        # 7. Névoa e miasma espectral de trevas
	DRAGAO_SERPENTE        # 8. Serpente / Dragão de Nen ondulante (Zeno)
}

enum Condicao {
	# ------------------------------------------------------------
	# 🟢 TIER 1: CONDIÇÕES TÁTICAS LEVES
	# ------------------------------------------------------------
	HP_ABAIXO_50,             # Só ativa com HP < 50% (+30%)
	HP_CHEIO,                 # Só ativa com 100% de HP (+25%)
	AURA_MINIMA_50,           # Só ativa com pelo menos 50% de Aura (+20%)
	PARADO_CANALIZACAO,       # Fica parado canalizando por 1.5s antes do golpe (+35%)
	MOVIMENTO_CONTINUO,       # Dança dos Passos: Requer correr por 2.5s antes (+30%)
	CURTO_ALCANCE_EXTREMO,    # Toque físico ultra-curto < 40px (+35%)
	LONGO_ALCANCE_SNIPER,     # Distância de sniper > 220px (+25%)
	APOS_ESQUIVA_PERFEITA,    # Usável apenas nos 2s após esquiva perfeita (+35%)
	REQUER_TEN_ATIVO,         # Só pode ser usado após ativar Ten (+20%)
	REQUER_REN_ATIVO,         # Só pode ser usado após ativar Ren (+30%)
	COOLDOWN_LONGO,           # O dobro do tempo de recarga 2x (+35%)
	REVELACAO_HABILIDADE,     # Voto da Revelação: Explica a técnica em balão de mangá (+30%)

	# ------------------------------------------------------------
	# 🟡 TIER 2: JURAMENTOS SÉRIOS
	# ------------------------------------------------------------
	HP_ABAIXO_30,             # Só ativa com HP Crítico < 30% (+65%)
	CONTRA_QUEM_ATACOU_PRIMEIRO, # Só funciona contra quem atacou o jogador primeiro (+75%)
	IMOVEL_DURANTE_USO,       # Totalmente imóvel durante a execução (+85%)
	NAO_ESQUIVAR_DURANTE_EFEITO, # Bloqueia esquiva durante a duração (+55%)
	NAO_VIOLENCIA,            # Defesa Pacífica: Não pode atacar durante o escudo (+80%, reflete dano)
	ZETSU_POS_USO_15S,        # Entra em Zetsu forçado por 15 segundos pós-uso (+90%)
	BLOQUEIO_NEN_10S,         # Bloqueia qualquer uso de Nen por 10s pós-uso (+70%)
	DOR_ACUMULADA,            # Pain Packer: Escala com dano sofrido recente (+80% até +180%)
	ALMAS_INIMIGOS,           # Colheita de Almas: Abates acumulam cargas (+15% por alma, até +150%)
	ORACAO_GRATIDAO,          # Oração de Netero: 0.7s de concentração imóvel (+60%)
	COMBO_SEQUENCIA,          # Requer combo de ações (Ataque -> Esquiva -> Ten -> Hatsu) (+65%)
	ALVO_ELITE_BOSS,          # Chain Jail: Só afeta Chefes e Elites (+85% + Stun forçado)
	CUSTO_DUPLO,              # Consome o dobro de Aura (+45%)
	AUTO_DANO,                # Pacto de Sangue: Consome 10% do HP próprio ao usar (+55%)

	# ------------------------------------------------------------
	# 🔴 TIER 3: VOTOS EXTREMOS / CRÍTICOS
	# ------------------------------------------------------------
	HP_ABAIXO_20,             # À Beira da Morte: HP < 20% (+120%)
	USO_UNICO_POR_COMBATE,    # Só pode ser usado UMA vez por combate (+140%)
	DRENO_TOTAL_AURA,         # Zero Ko: Consome 100% da Aura atual (+150%)
	AUTO_DANO_30_SANGUE,      # Grande Sacrifício Vital: Consome 30% do HP próprio (+160%)
	PENALIDADE_MORTE_ERRO,    # Se errar sofre 50% de dano e Zetsu por 30s (+200%)
	VOTO_ABSOLUTO_CHAIN,      # Chain Jail Absoluto: Exclusivo contra Chefes, 1x combate (+220%)
	CUSTOMIZADO               # Juramento Personalizado analisado pela IA de Nen
}

@export var nome: String = "Novo Hatsu"
@export var categoria: Categoria = Categoria.INTENSIFICACAO
@export var objetivo: ObjetivoPrincipal = ObjetivoPrincipal.DANO
@export var forma: Forma = Forma.PROJETIL
@export var elemento: Elemento = Elemento.NEN_PURO
@export var alvo: Alvo = Alvo.INIMIGO_UNICO
@export var alcance_tipo: AlcanceTipo = AlcanceTipo.MEDIO
@export var consumo_desejado: ConsumoDesejado = ConsumoDesejado.MEDIO
@export var condicoes: Array[Condicao] = []

# --- ARQUÉTIPOS E MÓDULOS ESPECÍFICOS ---
@export var arquetipo: Arquetipo = Arquetipo.SIMPLES
@export var power_budget: float = 100.0 # Orçamento de Poder Balanceado

# 1. Arsenal / Roleta (Kite)
@export var armas_roleta: Array[Dictionary] = [] # [{"nome": "Foice", "dano": 120, "custo": 30}]
var arma_roleta_atual: Dictionary = {}

# 2. Objeto / Moeda
@export var moeda_cara_efeito: String = "VELOCIDADE"
@export var moeda_coroa_efeito: String = "DEFESA"

# 3. Objeto / Cartas
@export var cartas_baralho: Array[Dictionary] = []

# 4. Objeto / Dado (1 a 6)
@export var dado_faces: Dictionary = {}

# 5. Território de En
@export var territorio_raio: float = 85.0
@export var territorio_regra: String = "DESACELERACAO" # "DESACELERACAO", "DANO_CONTINUO", "TROCA_POSICAO"

# 6. Marcação Tática (Tag & Trigger)
@export var marca_toques_max: int = 3
@export var marca_efeito: String = "DETONACAO" # "DETONACAO", "TELEPORTE", "DRENO_AURA"
var marca_toques_atual: int = 0
var alvo_marcado_ref: Node = null

# 7. Troca & Sacrifício Vital
@export var troca_de: String = "HP" # "HP", "AURA", "DEFESA"
@export var troca_para: String = "DANO" # "DANO", "VELOCIDADE", "AURA"
@export var troca_taxa: float = 1.0
@export var troca_duracao: float = 5.0

# 8. Livro / Coleção (Chrollo)
@export var livro_hatsus_armazenados: Array[Dictionary] = []

# Stats Base
@export var poder_base: float = 25.0
@export var custo_aura_base: float = 20.0
@export var cooldown_base: float = 3.0
@export var alcance: float = 120.0
@export var raio: float = 50.0
@export var duracao: float = 5.0
@export var cor_aura: Color = Color(0.2, 0.6, 1.0, 1.0)
@export var cor_aura_secundaria: Color = Color(1.0, 1.0, 1.0, 0.8)
@export var estilo_visual: EstiloVisual = EstiloVisual.PURO_PULSANTE

# Atributos Específicos por Objetivo
@export var escudo_base: float = 0.0
@export var cura_base: float = 0.0
@export var duracao_buff: float = 5.0
@export var velocidade_bonus: float = 0.0
@export var stun_duracao: float = 1.5

# Hatsu Evolutivo (Lv. 1 ao Lv. 100)
@export var nivel_evolucao_hatsu: int = 1
@export var xp_evolucao_hatsu: int = 0

# Metadados de Livro / Grimório / Sinergia de Tags
@export var tags: Array[String] = [] # ["weapon", "electricity", "teleport", "mark", "fire", "shield"]
@export var usuario_original: String = ""
@export var status_descoberta: String = "COMPLETO" # "COMPLETO" ou "INCOMPLETO"
@export var condicoes_descobertas: Array[String] = []
var livro_data: HatsuBookData = null

# Variáveis de Runtime
var almas_acumuladas: int = 0
var dor_acumulada: float = 0.0
var tempo_movimento: float = 0.0
var usado_no_combate_atual: bool = false
var vow_custom_text: String = ""
var vow_custom_mult: float = 1.0
var vow_custom_cat: String = ""
var vow_custom_tier: Tier = Tier.CONDICAO


# ============================================================
# METADADOS DAS RESTRIÇÕES (20 CATEGORIAS & 3 TIERS)
# ============================================================

static func obter_info_condicao(cond: Condicao) -> Dictionary:
	match cond:
		# --- 🟢 TIER 1 ---
		Condicao.HP_ABAIXO_50:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "HP / Vida",
				"dificuldade": 2, "risco": 2, "frequencia": 3, "severidade": 2, "impacto": 2,
				"mult": 0.30,
				"nome": "Juramento de Risco (HP < 50%)",
				"desc": "Só ativa quando o HP estiver abaixo de 50%.\n+30% de Poder Final por risco moderado.",
				"lore": "A determinação em momentos de perigo iminente eleva a densidade da aura."
			}
		Condicao.HP_CHEIO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "HP / Vida",
				"dificuldade": 2, "risco": 2, "frequencia": 3, "severidade": 1, "impacto": 1,
				"mult": 0.25,
				"nome": "Condição da Plenitude (HP 100%)",
				"desc": "Só pode ser disparado com HP intacto (100%).\n+25% de Poder Final no primeiro impacto.",
				"lore": "Manter a integridade física perfeita canaliza a aura sem turbulências."
			}
		Condicao.AURA_MINIMA_50:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Recursos",
				"dificuldade": 2, "risco": 1, "frequencia": 4, "severidade": 1, "impacto": 2,
				"mult": 0.20,
				"nome": "Reserva Estável (Aura >= 50%)",
				"desc": "Requer pelo menos 50% da barra de Aura para ativar.\n+20% de Poder Final.",
				"lore": "Garante que o golpe só seja disparado com sustentação firme de Nen."
			}
		Condicao.PARADO_CANALIZACAO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Movimento",
				"dificuldade": 2, "risco": 2, "frequencia": 4, "severidade": 2, "impacto": 2,
				"mult": 0.35,
				"nome": "Canalização Estática (Parado 1.5s)",
				"desc": "O usuário precisa permanecer imóvel por 1.5s antes de liberar.\n+35% de Poder Final.",
				"lore": "Posturas estáticas acumulam a pressão de Nen como uma mola comprimida."
			}
		Condicao.MOVIMENTO_CONTINUO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Movimento",
				"dificuldade": 2, "risco": 1, "frequencia": 4, "severidade": 2, "impacto": 2,
				"mult": 0.30,
				"nome": "Dança dos Passos (Correr 2.5s)",
				"desc": "Requer estar em corrida contínua por 2.5s antes do disparo.\n+30% de Poder Final.",
				"lore": "A dança dos guerreiros Bap de Bonolenov canaliza a inércia dos passos em impacto."
			}
		Condicao.CURTO_ALCANCE_EXTREMO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Alcance",
				"dificuldade": 3, "risco": 3, "frequencia": 3, "severidade": 2, "impacto": 3,
				"mult": 0.35,
				"nome": "Ponto de Impacto Zero (< 40px)",
				"desc": "Só atinge alvos colados ao corpo do jogador.\n+35% de Poder Final por proximidade extrema.",
				"lore": "Limitar o alcance ao milímetro do toque concentra o Ko no ponto de ruptura."
			}
		Condicao.LONGO_ALCANCE_SNIPER:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Alcance",
				"dificuldade": 2, "risco": 1, "frequencia": 3, "severidade": 2, "impacto": 2,
				"mult": 0.25,
				"nome": "Disparo Sniper (> 220px)",
				"desc": "Só causa efeito em alvos a longa distância (> 220px).\n+25% de Poder Final.",
				"lore": "A precisão balística de emissão à distância requer mira impecável."
			}
		Condicao.APOS_ESQUIVA_PERFEITA:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Ativação",
				"dificuldade": 3, "risco": 2, "frequencia": 3, "severidade": 2, "impacto": 2,
				"mult": 0.35,
				"nome": "Contra-Golpe Instantâneo (Pós-Esquiva)",
				"desc": "Disponível apenas nos 2 segundos após uma Esquiva Perfeita.\n+35% de Poder Final.",
				"lore": "Aproveitar a abertura do oponente logo após desviar no último instante."
			}
		Condicao.REQUER_TEN_ATIVO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Ativação",
				"dificuldade": 1, "risco": 1, "frequencia": 4, "severidade": 1, "impacto": 2,
				"mult": 0.20,
				"nome": "Canalização de Ten",
				"desc": "Requer manter a técnica Ten ativa durante o disparo.\n+20% de Poder e resistência.",
				"lore": "O manto de Ten estabiliza o fluxo de Nen, impedindo dispersão."
			}
		Condicao.REQUER_REN_ATIVO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Ativação",
				"dificuldade": 2, "risco": 2, "frequencia": 4, "severidade": 2, "impacto": 2,
				"mult": 0.30,
				"nome": "Explosão de Ren",
				"desc": "Requer que o Ren esteja ativo no momento do golpe.\n+30% de Poder e maior área de impacto.",
				"lore": "Liberar o Ren multiplica a intensidade do Hatsu."
			}
		Condicao.COOLDOWN_LONGO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Temporal",
				"dificuldade": 1, "risco": 1, "frequencia": 5, "severidade": 2, "impacto": 2,
				"mult": 0.35,
				"nome": "Restrição Temporal (Recarga 2x)",
				"desc": "O tempo de recarga é duplicado.\n+35% de Poder Final.",
				"lore": "Longos intervalos de descanso permitem acumular maior densidade energética."
			}
		Condicao.REVELACAO_HABILIDADE:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Comportamental",
				"dificuldade": 2, "risco": 2, "frequencia": 5, "severidade": 2, "impacto": 2,
				"mult": 0.30,
				"nome": "Voto da Revelação (Countdown de Genthru)",
				"desc": "O personagem expõe as regras do Hatsu ao oponente em balão de mangá.\n+30% de Poder.",
				"lore": "Abdicar do elemento surpresa explicando a técnica fortalece o feitiço de Nen."
			}

		# --- 🟡 TIER 2 ---
		Condicao.HP_ABAIXO_30:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "HP / Vida",
				"dificuldade": 4, "risco": 4, "frequencia": 2, "severidade": 4, "impacto": 4,
				"mult": 0.65,
				"nome": "Juramento do Desespero (HP < 30%)",
				"desc": "Só pode ser usado em estado crítico (HP < 30%).\n+65% de Poder Final para viradas épicas.",
				"lore": "À beira do abismo, o instinto de sobrevivência desbloqueia o potencial oculto."
			}
		Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Alvo / Comportamental",
				"dificuldade": 3, "risco": 4, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.75,
				"nome": "Voto do Retorno (Contra quem atacou primeiro)",
				"desc": "Só funciona contra inimigos que já atacaram o jogador primeiro no combate.\n+75% de Poder Final.",
				"lore": "Princípio da Autodefesa Absoluta — a aura só reage contra a intenção assassina do agressor."
			}
		Condicao.IMOVEL_DURANTE_USO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Movimento",
				"dificuldade": 4, "risco": 4, "frequencia": 4, "severidade": 4, "impacto": 4,
				"mult": 0.85,
				"nome": "Postura Inamovível (Canhão Fixo)",
				"desc": "O personagem não pode se mover nem cancelar enquanto a técnica estiver ativa.\n+85% de Poder Final.",
				"lore": "Ancorar os pés no chão e transformar o próprio corpo em uma torre de artilharia de Nen."
			}
		Condicao.NAO_ESQUIVAR_DURANTE_EFEITO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Movimento",
				"dificuldade": 3, "risco": 4, "frequencia": 4, "severidade": 3, "impacto": 3,
				"mult": 0.55,
				"nome": "Sem Esquiva (Sem Dash)",
				"desc": "Bloqueia o Dash e Esquivas enquanto a habilidade estiver em efeito.\n+55% de Poder Final.",
				"lore": "Renunciar à evasão força o fluxo de Nen a se concentrar inteiramente no impacto."
			}
		Condicao.NAO_VIOLENCIA:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Comportamental",
				"dificuldade": 3, "risco": 3, "frequencia": 4, "severidade": 4, "impacto": 4,
				"mult": 0.80,
				"nome": "Defesa Pacífica (Sem Ataques Básicos)",
				"desc": "Impede ataques básicos enquanto o escudo durar.\n+80% de absorção e reflete 50% do dano.",
				"lore": "Abdicar totalmente da agressão fortalece o Ten e o Ken para criar uma barreira inabalável."
			}
		Condicao.ZETSU_POS_USO_15S:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Pós-Uso",
				"dificuldade": 4, "risco": 5, "frequencia": 4, "severidade": 5, "impacto": 5,
				"mult": 0.90,
				"nome": "Exaustão Absoluta (Zetsu por 15s pós-uso)",
				"desc": "Após usar, o jogador entra forçadamente em Zetsu por 15s (sem Nen nem defesa).\n+90% de Poder Final.",
				"lore": "Esgotar até o último poro de aura exige um período imediato de desligamento total dos nós."
			}
		Condicao.BLOQUEIO_NEN_10S:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Pós-Uso",
				"dificuldade": 4, "risco": 4, "frequencia": 4, "severidade": 4, "impacto": 4,
				"mult": 0.70,
				"nome": "Sobrecarga de Nen (Bloqueio por 10s)",
				"desc": "Bloqueia todas as técnicas de Nen e outros Hatsus por 10 segundos pós-uso.\n+70% de Poder Final.",
				"lore": "O circuito de nós de Nen superaquece, exigindo resfriamento biológico."
			}
		Condicao.DOR_ACUMULADA:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "HP / Dano",
				"dificuldade": 4, "risco": 4, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.80,
				"nome": "Pain Packer (Transmutação da Dor de Feitan)",
				"desc": "O poder escala diretamente com todo o dano sofrido nos últimos 10s (+80% até +180%).",
				"lore": "Transmutar a agonia e o sofrimento físico sofrido em calor, fogo e devastação."
			}
		Condicao.ALMAS_INIMIGOS:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Ativação / Alvo",
				"dificuldade": 3, "risco": 3, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.15,
				"nome": "Colheita de Almas (Pacto de Morena / Camilla)",
				"desc": "Derrotar monstros acumula almas (+15% por alma, até 10 almas = +150% poder!).",
				"lore": "Absorção de resquícios de Nen pós-morte para energizar o disparo."
			}
		Condicao.ORACAO_GRATIDAO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Movimento / Ativação",
				"dificuldade": 3, "risco": 4, "frequencia": 4, "severidade": 3, "impacto": 3,
				"mult": 0.60,
				"nome": "Oração dos 10.000 Golpes de Gratidão (Netero)",
				"desc": "O personagem realiza uma reverência imóvel de 0.7s antes do golpe.\n+60% de Poder.",
				"lore": "A reverência e os socos de gratidão de Netero que transcendem a velocidade humana."
			}
		Condicao.COMBO_SEQUENCIA:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Sequência / Combo",
				"dificuldade": 4, "risco": 3, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.65,
				"nome": "Sequência Rítmica (Ataque -> Dash -> Nen -> Hatsu)",
				"desc": "Só ativa se a sequência correta de comandos for realizada nos últimos 3s.\n+65% de Poder.",
				"lore": "Canalizar a memória muscular e o ritmo respiratório marcial."
			}
		Condicao.ALVO_ELITE_BOSS:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Alvo",
				"dificuldade": 4, "risco": 4, "frequencia": 2, "severidade": 4, "impacto": 4,
				"mult": 0.85,
				"nome": "Chain Jail (Apenas Chefes e Elites)",
				"desc": "Só pode ser ativado contra Chefes e Inimigos de Elite com Nen.\n+85% de Poder + Stun forçado.",
				"lore": "O juramento de Kurapika — apostar a própria vida contra alvos específicos concede poder absoluto."
			}
		Condicao.CUSTO_DUPLO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Recursos",
				"dificuldade": 2, "risco": 2, "frequencia": 5, "severidade": 3, "impacto": 3,
				"mult": 0.45,
				"nome": "Sacrifício de Aura (Custo 2x)",
				"desc": "Consome o dobro de Aura ao ativar.\n+45% de Poder Final por densidade extrema.",
				"lore": "Condensação maciça de aura gera ondas de choque devastadoras."
			}
		Condicao.AUTO_DANO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "HP / Vida",
				"dificuldade": 3, "risco": 4, "frequencia": 5, "severidade": 3, "impacto": 3,
				"mult": 0.55,
				"nome": "Pacto de Sangue (-10% HP Próprio)",
				"desc": "Consome 10% da vida máxima a cada uso.\n+55% de Poder Final (Troca vital).",
				"lore": "A troca de sangue biológico por energia Nen ativa aceleração celular destrutiva."
			}

		# --- 🔴 TIER 3 ---
		Condicao.HP_ABAIXO_20:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "HP / Vida",
				"dificuldade": 5, "risco": 5, "frequencia": 1, "severidade": 5, "impacto": 5,
				"mult": 1.20,
				"nome": "À Beira da Morte (HP Crítico < 20%)",
				"desc": "Exclusivo para momentos terminais com HP < 20%.\n+120% de Poder Final!",
				"lore": "O brilho final de uma vida prestes a se extinguir produz uma supernova de Nen."
			}
		Condicao.USO_UNICO_POR_COMBATE:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "Ativação / Risco",
				"dificuldade": 4, "risco": 4, "frequencia": 1, "severidade": 5, "impacto": 5,
				"mult": 1.40,
				"nome": "Único Disparo (1x por Batalha)",
				"desc": "Só pode ser usado uma única vez por combate inteiro.\n+140% de Poder Final!",
				"lore": "A cartada final que decide a vida ou a morte em um único instante."
			}
		Condicao.DRENO_TOTAL_AURA:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "Recursos",
				"dificuldade": 4, "risco": 5, "frequencia": 2, "severidade": 5, "impacto": 5,
				"mult": 1.50,
				"nome": "Zero Ko (Dreno de 100% da Aura Atual)",
				"desc": "Esvazia completamente a barra de Aura ao disparar.\n+150% de Poder Final!",
				"lore": "A técnica suprema de Netero — projetar toda a aura restante em um feixe aniquilador."
			}
		Condicao.AUTO_DANO_30_SANGUE:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "HP / Vida",
				"dificuldade": 4, "risco": 5, "frequencia": 2, "severidade": 5, "impacto": 5,
				"mult": 1.60,
				"nome": "Grande Sacrifício Vital (-30% HP)",
				"desc": "Sacrifica 30% da vida máxima do jogador ao usar.\n+160% de Poder Final!",
				"lore": "Troca de carne e espírito por destruição incondicional."
			}
		Condicao.PENALIDADE_MORTE_ERRO:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "Risco",
				"dificuldade": 5, "risco": 5, "frequencia": 2, "severidade": 5, "impacto": 5,
				"mult": 2.00,
				"nome": "Voto do Cadafalso (Se errar, sofre 50% HP e 30s Zetsu)",
				"desc": "Se o ataque não atingir ou for interrompido, o usuário sofre metade da vida e 30s de Zetsu.\n+200% de Poder!",
				"lore": "A espada de Dâmocles sobre a cabeça do usuário — errar é cortejar a própria morte."
			}
		Condicao.VOTO_ABSOLUTO_CHAIN:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "Alvo / Voto Absoluto",
				"dificuldade": 5, "risco": 5, "frequencia": 1, "severidade": 5, "impacto": 5,
				"mult": 2.20,
				"nome": "Voto da Corrente do Julgamento Absoluto (Kurapika)",
				"desc": "Uso restrito a Chefes, 1x por combate, com auto-dano vital em caso de falha.\n+220% de Poder!",
				"lore": "Um juramento cravado com a lâmina do julgamento no próprio coração."
			}
		Condicao.CUSTOMIZADO, _:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "IA de Nen Livre",
				"dificuldade": 3, "risco": 3, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.35,
				"nome": "Juramento Personalizado (IA de Nen)",
				"desc": "Juramento livre avaliado pelo motor semântico inteligente de Nen.",
				"lore": "Todo pacto baseado em sacrifício e determinação genuína é reconhecido pelo fluxo de Nen."
			}


# ============================================================
# CÁLCULO DO MULTIPLICADOR E EVOLUÇÃO
# ============================================================

func obter_multiplicador_poder() -> float:
	var mult: float = 1.0

	# Bônus de Evolução de Hatsu (Lv. 1 a 100: até +35% bônus)
	var bonus_evo: float = float(nivel_evolucao_hatsu - 1) * 0.0035
	mult += bonus_evo

	# Bônus intrínseco de Arquétipos com Aleatoriedade (Restrição de Imprevisibilidade)
	match arquetipo:
		Arquetipo.ARSENAL_ROLETA:
			mult += 0.45 # Não escolher a arma confere +45% de base!
		Arquetipo.OBJETO_MOEDA:
			mult += 0.30 # Cara/Coroa imprevisível
		Arquetipo.OBJETO_DADO:
			mult += 0.50 # 6 faces com risco de Zetsu

	for cond in condicoes:
		if cond == Condicao.ALMAS_INIMIGOS:
			mult += clamp(float(almas_acumuladas) * 0.15, 0.0, 1.50)
			continue
		elif cond == Condicao.DOR_ACUMULADA:
			var bonus_dor: float = clamp(dor_acumulada / 80.0, 0.40, 1.80)
			mult += bonus_dor
			continue
		elif cond == Condicao.CUSTOMIZADO:
			mult += max(0.0, vow_custom_mult - 1.0)
			continue

		var info: Dictionary = obter_info_condicao(cond)
		var bonus_calculado: float = float(info.get("mult", 0.30))
		mult += bonus_calculado

	return mult


func obter_poder_final() -> float:
	return poder_base * obter_multiplicador_poder()


func obter_custo_final() -> float:
	var mult: float = 1.0
	if Condicao.CUSTO_DUPLO in condicoes:
		mult *= 2.0
	return custo_aura_base * mult


func obter_cooldown_final() -> float:
	var mult: float = 1.0
	if Condicao.COOLDOWN_LONGO in condicoes:
		mult *= 2.0
	return cooldown_base * mult


func adicionar_xp_evolucao(ganho_xp: int) -> bool:
	xp_evolucao_hatsu += ganho_xp
	var xp_prox: int = nivel_evolucao_hatsu * 100
	if xp_evolucao_hatsu >= xp_prox and nivel_evolucao_hatsu < 100:
		xp_evolucao_hatsu -= xp_prox
		nivel_evolucao_hatsu += 1
		print("[Hatsu Evolutivo] %s evoluiu para o Nível %d!" % [nome, nivel_evolucao_hatsu])
		return true
	return false


# ============================================================
# VERIFICAÇÃO DE CONDIÇÕES PARA USO EM COMBATE
# ============================================================

func pode_usar(player_context: Dictionary, target_context: Dictionary = {}) -> Dictionary:
	var hp: int = int(player_context.get("hp", 100))
	var hp_max: int = int(player_context.get("hp_max", 100))
	var aura: float = float(player_context.get("aura", 100.0))
	var aura_max: float = float(player_context.get("aura_max", 100.0))
	var pct_hp: float = float(hp) / max(1.0, float(hp_max))
	var pct_aura: float = aura / max(1.0, aura_max)
	var em_ten: bool = bool(player_context.get("em_ten", false))
	var em_ren: bool = bool(player_context.get("em_ren", false))
	var pos_esquiva_recente: bool = bool(player_context.get("pos_esquiva_recente", false))
	var primeiro_atacante_id: StringName = player_context.get("primeiro_atacante_id", &"")
	var target_id: StringName = target_context.get("enemy_id", &"")
	var target_is_boss: bool = bool(target_context.get("is_boss", false))
	var target_distance: float = float(target_context.get("distance", 50.0))

	# Uso Único por Combate
	if (Condicao.USO_UNICO_POR_COMBATE in condicoes or Condicao.VOTO_ABSOLUTO_CHAIN in condicoes) and usado_no_combate_atual:
		return {"pode": false, "motivo": "Voto Extremo: Esta técnica só pode ser usada 1x por combate!"}

	# HP Checks
	if Condicao.HP_ABAIXO_50 in condicoes and pct_hp >= 0.5:
		return {"pode": false, "motivo": "Juramento de Risco: Requer HP abaixo de 50%!"}
	if Condicao.HP_ABAIXO_30 in condicoes and pct_hp >= 0.3:
		return {"pode": false, "motivo": "Juramento do Desespero: Requer HP Crítico abaixo de 30%!"}
	if Condicao.HP_ABAIXO_20 in condicoes and pct_hp >= 0.2:
		return {"pode": false, "motivo": "Voto Extremo: Requer estar à beira da morte (HP < 20%)!"}
	if Condicao.HP_CHEIO in condicoes and pct_hp < 0.99:
		return {"pode": false, "motivo": "Condição da Plenitude: Requer 100% de HP intacto!"}

	# Aura Checks
	if Condicao.AURA_MINIMA_50 in condicoes and pct_aura < 0.5:
		return {"pode": false, "motivo": "Reserva Estável: Requer pelo menos 50% de Aura!"}

	# Estados de Nen
	if Condicao.REQUER_TEN_ATIVO in condicoes and not em_ten:
		return {"pode": false, "motivo": "Canalização de Ten: Requer manter o Ten ativo!"}
	if Condicao.REQUER_REN_ATIVO in condicoes and not em_ren:
		return {"pode": false, "motivo": "Explosão de Ren: Requer manter o Ren ativo!"}

	# Esquiva Perfeita
	if Condicao.APOS_ESQUIVA_PERFEITA in condicoes and not pos_esquiva_recente:
		return {"pode": false, "motivo": "Contra-Golpe: Só usável nos 2s após Esquiva Perfeita!"}

	# Contra quem atacou primeiro
	if Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO in condicoes:
		if primeiro_atacante_id.is_empty():
			return {"pode": false, "motivo": "Voto do Retorno: Só usável contra quem atacar o jogador primeiro!"}
		if not target_id.is_empty() and target_id != primeiro_atacante_id:
			return {"pode": false, "motivo": "Voto do Retorno: O alvo selecionado não foi quem atacou primeiro!"}

	# Alvo Chefes / Elites
	if (Condicao.ALVO_ELITE_BOSS in condicoes or Condicao.VOTO_ABSOLUTO_CHAIN in condicoes) and not target_is_boss and not target_id.is_empty():
		return {"pode": false, "motivo": "Chain Jail: Este juramento só pode atingir Chefes/Elites com Nen!"}

	# Alcances
	if Condicao.CURTO_ALCANCE_EXTREMO in condicoes and target_distance > 45.0:
		return {"pode": false, "motivo": "Ponto de Impacto Zero: Requer proximidade extrema (< 40px)!"}
	if Condicao.LONGO_ALCANCE_SNIPER in condicoes and target_distance < 200.0:
		return {"pode": false, "motivo": "Disparo Sniper: Alvo muito próximo! Requer distância > 220px."}

	# Almas
	if Condicao.ALMAS_INIMIGOS in condicoes and almas_acumuladas <= 0:
		return {"pode": false, "motivo": "Colheita de Almas: Requer ao menos 1 alma acumulada de abates!"}

	return {"pode": true, "motivo": ""}


# ============================================================
# MÉTODOS ESTÁTICOS DE SUPORTE
# ============================================================

static func obter_nome_condicao(cond: Condicao) -> String:
	return obter_info_condicao(cond).get("nome", "Condição Desconhecida")

static func obter_descricao_condicao(cond: Condicao) -> String:
	return obter_info_condicao(cond).get("desc", "")

static func obter_lore_condicao(cond: Condicao) -> String:
	return obter_info_condicao(cond).get("lore", "")

static func obter_nome_arquetipo(arq: Arquetipo) -> String:
	match arq:
		Arquetipo.SIMPLES: return "1. Simples / Reforço Direto"
		Arquetipo.CONJURACAO_ARMA: return "2. Conjuração de Arma (Cargas)"
		Arquetipo.ARSENAL_ROLETA: return "3. Arsenal & Roleta (Crazy Slots / Kite)"
		Arquetipo.LIVRO_COLECAO: return "4. Coleção & Arquivo (Skill Hunter / Chrollo)"
		Arquetipo.TERRITORIO_EN: return "5. Território de En (Regras de Área)"
		Arquetipo.MARCA_TAG: return "6. Marcação Tática (Tag & Trigger)"
		Arquetipo.OBJETO_MOEDA: return "7. Moeda da Sorte de Nen"
		Arquetipo.OBJETO_CARTAS: return "8. Baralho de Cartas (5 Naipes)"
		Arquetipo.OBJETO_DADO: return "9. Dado Místico de 6 Faces"
		Arquetipo.TROCA_SACRIFICIO: return "10. Troca & Sacrifício de Recursos"
		Arquetipo.CONTRATO_DUELO: return "11. Contrato & Duelo"
	return "Desconhecido"


static func obter_nome_estilo_visual(est: EstiloVisual) -> String:
	match est:
		EstiloVisual.PURO_PULSANTE: return "1. Esfera / Pulso de Nen Puro"
		EstiloVisual.CHAMAS_FOGO: return "2. Chamas Flamejantes Ondulantes"
		EstiloVisual.RELAMPAGOS_ELETRICOS: return "3. Arcos Voltaicos de Eletricidade"
		EstiloVisual.LAMINA_CORTE: return "4. Lâmina / Meia-Lua Cortante"
		EstiloVisual.SHURIKEN_GIRATORIO: return "5. Shuriken / Espiral Rotativa"
		EstiloVisual.ANEIS_IMPACTO: return "6. Anéis de Onda Sísmica"
		EstiloVisual.NEVOA_SOMBRIAS: return "7. Névoa e Miasma Sombrio"
		EstiloVisual.DRAGAO_SERPENTE: return "8. Serpente / Dragão de Nen (Zeno)"
	return "Padrão"


func to_dict() -> Dictionary:
	var conds: Array[int] = []
	for c in condicoes:
		conds.append(int(c))
	return {
		"nome": nome,
		"categoria": int(categoria),
		"objetivo": int(objetivo),
		"forma": int(forma),
		"elemento": int(elemento),
		"alvo": int(alvo),
		"alcance_tipo": int(alcance_tipo),
		"consumo_desejado": int(consumo_desejado),
		"condicoes": conds,
		"arquetipo": int(arquetipo),
		"power_budget": power_budget,
		"poder_base": poder_base,
		"custo_aura_base": custo_aura_base,
		"cooldown_base": cooldown_base,
		"alcance": alcance,
		"raio": raio,
		"duracao": duracao,
		"nivel_evolucao_hatsu": nivel_evolucao_hatsu,
		"xp_evolucao_hatsu": xp_evolucao_hatsu,
		"vow_custom_text": vow_custom_text,
		"vow_custom_mult": vow_custom_mult,
		"tags": tags.duplicate(),
		"usuario_original": usuario_original
	}


static func from_dict(data: Dictionary) -> HatsuData:
	var h := HatsuData.new()
	h.nome = data.get("nome", "Hatsu")
	h.categoria = data.get("categoria", Categoria.INTENSIFICACAO)
	h.objetivo = data.get("objetivo", ObjetivoPrincipal.DANO)
	h.forma = data.get("forma", Forma.PROJETIL)
	h.elemento = data.get("elemento", Elemento.NEN_PURO)
	h.alvo = data.get("alvo", Alvo.INIMIGO_UNICO)
	h.alcance_tipo = data.get("alcance_tipo", AlcanceTipo.MEDIO)
	h.consumo_desejado = data.get("consumo_desejado", ConsumoDesejado.MEDIO)
	h.arquetipo = data.get("arquetipo", Arquetipo.SIMPLES)
	h.power_budget = data.get("power_budget", 100.0)
	h.poder_base = data.get("poder_base", 25.0)
	h.custo_aura_base = data.get("custo_aura_base", 20.0)
	h.cooldown_base = data.get("cooldown_base", 3.0)
	h.alcance = data.get("alcance", 120.0)
	h.raio = data.get("raio", 50.0)
	h.duracao = data.get("duracao", 5.0)
	h.nivel_evolucao_hatsu = data.get("nivel_evolucao_hatsu", 1)
	h.xp_evolucao_hatsu = data.get("xp_evolucao_hatsu", 0)
	h.vow_custom_text = data.get("vow_custom_text", "")
	h.vow_custom_mult = data.get("vow_custom_mult", 1.0)
	h.usuario_original = data.get("usuario_original", "")
	var tags_in = data.get("tags", [])
	var typed_tags: Array[String] = []
	for t in tags_in:
		typed_tags.append(str(t))
	h.tags = typed_tags

	var conds_in = data.get("condicoes", [])
	var typed_conds: Array[Condicao] = []
	for c in conds_in:
		typed_conds.append(int(c) as Condicao)
	h.condicoes = typed_conds
	return h
