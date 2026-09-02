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

enum ActivationType {
	INSTANT,          # 1. Executa imediatamente e entra em cooldown (ex: Jajanken, Remote Punch)
	CHARGED,          # 2. Requer canalização ou postura prévia (ex: Jajanken Pedra, Oração)
	SUSTAINED,        # 3. Permanece ativo por tempo ou dreno contínuo (ex: Crazy Slots, Escudo)
	CHANNELED,        # 4. Requer concentração contínua e imobilidade
	TRANSFORMATION,   # 5. Transformação física/neural que altera o personagem (ex: Godspeed, Guanyin)
	OVERRIDE_LIBRARY  # 6. Grimório / Biblioteca de habilidades (ex: Skill Hunter de Chrollo)
}

enum DurationType {
	INSTANT,          # 0 segundos / Imediato
	TIMED,            # Duração fixa em segundos
	CONTINUOUS_DRAIN, # Permanece ativo enquanto houver Aura ou até cancelamento
	PERMANENT_STANCE  # Postura mantida até nova troca
}

enum HatsuChannel {
	OFFENSIVE,        # Canal de ataque/dano
	DEFENSIVE,        # Canal de proteção/escudo
	TRANSFORMATION,   # Canal exclusivo de transformação corporal
	UTILITY,          # Canal de mobilidade/suporte
	SPECIAL,          # Canal de controle/regras especiais
	LIBRARY           # Canal de grimório/arquivo de Nen
}

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

@export var hatsu_id: String = ""
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

# Arquitetura de Loadout, Canais & Compatibilidade (GDD Vol 5 & Hatsu Refined)
@export var activation_type: ActivationType = ActivationType.INSTANT
@export var duration_type: DurationType = DurationType.INSTANT
@export var channel: HatsuChannel = HatsuChannel.OFFENSIVE
@export var exclusive_group: String = "" # Ex: "transformation_mode", "barrier_mode", "library_mode"
@export var concurrent_allowed: bool = true
@export var aura_drain_per_sec: float = 0.0
@export var aura_drain_per_hit: float = 0.0
@export var skill_hunter_compatible: bool = true

# --- ARQUITETURA DEFINITIVA DE COMPONENTES MODULARES (GDD HATSU CREATOR) ---
@export var core_component: int = 0 # HatsuComponentLibrary.CoreType
@export var effect_modules: Array = [] # [{"type": EffectType, "value": float, "param": String}]
@export var modular_conditions: Array = [] # Array de ConditionType
@export var modular_restrictions: Array = [] # Array de RestrictionType
@export var modular_drawbacks: Array = [] # Array de DrawbackType

# Sliders Numéricos Customizados pelo Jogador
@export var custom_damage: float = 0.0
@export var custom_range: float = 0.0
@export var custom_radius: float = 0.0
@export var custom_duration: float = 0.0
@export var custom_cooldown: float = 0.0
@export var custom_aura_cost: float = 0.0
@export var custom_absorption_pct: float = 0.0
@export var custom_stat_bonus: Dictionary = {}

# Avaliações do Power Budget & Scores
@export var power_score: float = 0.0
@export var complexity_score: float = 0.0
@export var risk_score: float = 0.0
@export var efficiency_score: float = 0.0
@export var is_custom_created: bool = false
@export var hatsu_version: int = 2
@export var creator_id: String = ""

# Hatsu Creator v1.5 — Sistema de Créditos de Poder, Versatilidade e Cadeia de Preparação
@export var preparation_steps: Array = [] # [{"id": "step_1", "description": "...", "action_required": "...", "time_required": float, "credit_value": float}]
@export var versatility_score: float = 0.0
@export var functional_power: float = 0.0
@export var limitation_credits: float = 0.0
@export var condition_credits: float = 0.0
@export var restriction_credits: float = 0.0
@export var vow_credits: float = 0.0
@export var preparation_credits: float = 0.0
@export var sub_effects: Array = [] # HatsuComponentLibrary.EffectType

# Auditoria e Rascunhos
@export var required_credits: float = 0.0
@export var available_credits: float = 0.0
@export var credit_deficit: float = 0.0
@export var is_draft: bool = false
@export var parametros_conceito: Dictionary = {}

# Mecânica de Armazenamento e Roubo Real de Hatsu (Skill Hunter / Storage)
@export var is_storage_hatsu: bool = false
@export var storage_capacity: int = 3
@export var storage_duration_type: String = "PERMANENT" # "PERMANENT", "CHARGES", "TIMED"
@export var storage_usage_rule: String = "OPEN_BOOK" # "OPEN_BOOK", "FREE", "MARKER"
@export var steal_conditions: Array[String] = [] # ["TOUCH_REQUIRED", "OBSERVE_GYO", "TARGET_EXPLAINS", "TARGET_DEFEATED", "FOUR_STRICT_CONDITIONS"]
@export var steal_target_type: String = "ANY" # "ANY", "ELITE_BOSS", "SAME_LEVEL_OR_LOWER"

# Componentes Avançados de Especialização
@export var absorption_target_stat: String = "aura_max" # "aura_max", "forca", "defesa", "velocidade"
@export var absorption_rate: float = 0.05
@export var rollback_seconds: float = 5.0
@export var territory_rule_type: String = ""

# Perfil Visual Customizado (Sistema Cosmético)
@export var visual_profile: VisualProfile = null

# Metadados de Livro / Grimório / Sinergia de Tags
@export var tags: Array[String] = [] # ["weapon", "electricity", "teleport", "mark", "fire", "shield"]
@export var gameplay_conditions: Array[GameplayCondition] = []
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
# CÁLCULOS DE VERSATILIDADE, DEMANDA FUNCIONAL E CRÉDITOS (v1.5)
# ============================================================

func calcular_versatility_score() -> float:
	var score: float = 5.0
	score += float(sub_effects.size() * 22.0)
	if alvo == Alvo.AREA:
		score += 30.0
	if forma in [Forma.AREA, Forma.ZONA]:
		score += 35.0
	if alcance > 220.0:
		score += 35.0
	elif alcance > 150.0:
		score += 18.0

	var cd := custom_cooldown if custom_cooldown > 0.0 else cooldown_base
	if cd < 2.0:
		score += 40.0
	elif cd < 3.5:
		score += 20.0

	if duration_type in [DurationType.CONTINUOUS_DRAIN, DurationType.PERMANENT_STANCE]:
		score += 50.0
	elif duracao > 8.0:
		score += 25.0

	# Bônus intrínsecos de arquétipos / conceitos
	match arquetipo:
		Arquetipo.LIVRO_COLECAO: score += 80.0
		Arquetipo.TERRITORIO_EN: score += 70.0
		Arquetipo.ARSENAL_ROLETA: score += 55.0
		Arquetipo.CONTRATO_DUELO: score += 60.0
		Arquetipo.TROCA_SACRIFICIO: score += 45.0
		Arquetipo.MARCA_TAG: score += 40.0
		Arquetipo.OBJETO_DADO: score += 45.0
		Arquetipo.OBJETO_CARTAS: score += 40.0

	# Bônus para Hatsu de Armazenamento / Roubo
	if is_storage_hatsu or arquetipo == Arquetipo.LIVRO_COLECAO:
		score += 55.0
		if storage_capacity >= 10:
			score += 60.0
		elif storage_capacity >= 5:
			score += 35.0
		else:
			score += 20.0

		if storage_duration_type == "PERMANENT":
			score += 35.0
		elif storage_duration_type == "TIMED":
			score += 15.0

		if storage_usage_rule == "FREE":
			score += 50.0
		elif storage_usage_rule == "MARKER":
			score += 30.0

	# Bônus por Core Component avançado (Especialização / Absorção / Rollback / Zone)
	match core_component:
		HatsuComponentLibrary.CoreType.ABSORPTION: score += 65.0
		HatsuComponentLibrary.CoreType.RULE_ZONE: score += 70.0
		HatsuComponentLibrary.CoreType.MEMORY_ROLLBACK: score += 75.0
		HatsuComponentLibrary.CoreType.TRANSFORMATION: score += 45.0
		HatsuComponentLibrary.CoreType.SUMMON: score += 40.0

	versatility_score = score
	return score


func calcular_functional_power() -> float:
	var raw_dmg: float = custom_damage if custom_damage > 0.0 else poder_base
	var power_demand: float = 0.0

	# Curva Não-Linear por Faixas de Poder (Escala Exponencial de Nen)
	if raw_dmg <= 30.0:
		power_demand = raw_dmg * 1.0
	elif raw_dmg <= 60.0:
		power_demand = 30.0 + ((raw_dmg - 30.0) * 1.5)
	elif raw_dmg <= 100.0:
		power_demand = 30.0 + (30.0 * 1.5) + ((raw_dmg - 60.0) * 2.5)
	else:
		power_demand = 30.0 + (30.0 * 1.5) + (40.0 * 2.5) + ((raw_dmg - 100.0) * 4.0)

	# Demanda para Escudo e Cura
	if escudo_base > 0.0:
		if escudo_base <= 40.0:
			power_demand += escudo_base * 0.9
		else:
			power_demand += 36.0 + ((escudo_base - 40.0) * 1.6)

	if cura_base > 0.0:
		if cura_base <= 35.0:
			power_demand += cura_base * 1.1
		else:
			power_demand += 38.5 + ((cura_base - 35.0) * 1.8)

	if stun_duracao > 0.0 and objetivo == ObjetivoPrincipal.CONTROLE:
		power_demand += stun_duracao * 25.0
	if velocidade_bonus > 0.0:
		power_demand += (velocidade_bonus / 100.0) * 30.0

	var v_score := calcular_versatility_score()
	power_demand += v_score * 0.90

	# Se for Especialização, Roubo ou conceito de alto impacto sem dano direto
	if categoria == Categoria.ESPECIALIZACAO or is_storage_hatsu or arquetipo == Arquetipo.LIVRO_COLECAO:
		power_demand = max(power_demand, 80.0 + (v_score * 0.80))

	functional_power = max(20.0, power_demand)
	required_credits = functional_power
	return functional_power


func calcular_limitation_credits() -> float:
	# Capacidade Inata Básica Reduzida (Suficiente apenas para técnica rudimentar)
	var credits: float = 15.0
	var c_cred: float = 0.0
	var r_cred: float = 0.0
	var v_cred: float = 0.0
	var p_cred: float = 0.0

	# Créditos por Custo de Aura Realmente Alto
	var cost := custom_aura_cost if custom_aura_cost > 0.0 else custo_aura_base
	if cost >= 80.0:
		credits += 35.0
	elif cost >= 50.0:
		credits += 20.0
	elif cost >= 35.0:
		credits += 10.0

	# Créditos por Tempo de Recarga Realmente Longo
	var cd := custom_cooldown if custom_cooldown > 0.0 else cooldown_base
	if cd >= 16.0:
		credits += 35.0
	elif cd >= 10.0:
		credits += 20.0
	elif cd >= 6.0:
		credits += 10.0

	# Créditos por Requisitos e Condições de Roubo de Hatsu
	for sc in steal_conditions:
		match str(sc):
			"TOUCH_REQUIRED":
				credits += 30.0
				c_cred += 30.0
			"OBSERVE_GYO":
				credits += 25.0
				c_cred += 25.0
			"TARGET_EXPLAINS":
				credits += 35.0
				c_cred += 35.0
			"TARGET_DEFEATED":
				credits += 35.0
				c_cred += 35.0
			"FOUR_STRICT_CONDITIONS":
				credits += 120.0
				c_cred += 120.0
			_:
				credits += 20.0
				c_cred += 20.0

	for c in condicoes:
		var inf := obter_info_condicao(c)
		var val: float = float(inf.get("budget_bonus", 20.0))
		c_cred += val
	credits += c_cred

	for mc in modular_conditions:
		var mc_info = HatsuComponentLibrary.get_condition_info(int(mc))
		var mc_val: float = float(mc_info.get("budget_bonus", 20.0))
		c_cred += mc_val
		credits += mc_val

	for r in modular_restrictions:
		var r_info = HatsuComponentLibrary.get_restriction_info(int(r))
		var r_val: float = float(r_info.get("budget_bonus", 25.0))
		r_cred += r_val
	credits += r_cred

	for d in modular_drawbacks:
		var d_info = HatsuComponentLibrary.get_drawback_info(int(d))
		var d_val: float = float(d_info.get("budget_bonus", 20.0))
		r_cred += d_val
		credits += d_val

	if not vow_custom_text.is_empty():
		if vow_custom_tier == Tier.VOTO_EXTREMO:
			v_cred += 100.0
		elif vow_custom_tier == Tier.JURAMENTO:
			v_cred += 55.0
		else:
			v_cred += 25.0
	credits += v_cred

	for step in preparation_steps:
		var step_val: float = float(step.get("credit_value", 25.0))
		p_cred += step_val
	credits += p_cred

	condition_credits = c_cred
	restriction_credits = r_cred
	vow_credits = v_cred
	preparation_credits = p_cred
	limitation_credits = credits
	available_credits = credits

	var req := calcular_functional_power()
	credit_deficit = max(0.0, req - available_credits)

	return limitation_credits


func is_balanced() -> bool:
	calcular_functional_power()
	calcular_limitation_credits()
	return credit_deficit <= 0.0


# ============================================================
# METADADOS DAS RESTRIÇÕES (20 CATEGORIAS & 3 TIERS)
# ============================================================

static func obter_info_condicao(cond: Condicao) -> Dictionary:
	match cond:
		# --- 🟢 TIER 1 (Condições Táticas Básicas) ---
		Condicao.HP_ABAIXO_50:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "HP / Vida",
				"dificuldade": 2, "risco": 2, "frequencia": 3, "severidade": 2, "impacto": 2,
				"mult": 0.20,
				"budget_bonus": 20.0,
				"nome": "Juramento de Risco (HP < 50%)",
				"desc": "Só ativa quando o HP estiver abaixo de 50%.\n+20% de Poder Final.",
				"lore": "A determinação em momentos de perigo iminente eleva a densidade da aura."
			}
		Condicao.HP_CHEIO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "HP / Vida",
				"dificuldade": 2, "risco": 2, "frequencia": 3, "severidade": 1, "impacto": 1,
				"mult": 0.15,
				"budget_bonus": 15.0,
				"nome": "Condição da Plenitude (HP 100%)",
				"desc": "Só pode ser disparado com HP intacto (100%).\n+15% de Poder Final no primeiro impacto.",
				"lore": "Manter a integridade física perfeita canaliza a aura sem turbulências."
			}
		Condicao.AURA_MINIMA_50:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Recursos",
				"dificuldade": 2, "risco": 1, "frequencia": 4, "severidade": 1, "impacto": 2,
				"mult": 0.15,
				"budget_bonus": 15.0,
				"nome": "Reserva Estável (Aura >= 50%)",
				"desc": "Requer pelo menos 50% da barra de Aura para ativar.\n+15% de Poder Final.",
				"lore": "Garante que o golpe só seja disparado com sustentação firme de Nen."
			}
		Condicao.PARADO_CANALIZACAO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Movimento",
				"dificuldade": 2, "risco": 2, "frequencia": 4, "severidade": 2, "impacto": 2,
				"mult": 0.25,
				"budget_bonus": 25.0,
				"nome": "Canalização Estática (Parado 1.5s)",
				"desc": "O usuário precisa permanecer imóvel por 1.5s antes de liberar.\n+25% de Poder Final.",
				"lore": "Posturas estáticas acumulam a pressão de Nen como uma mola comprimida."
			}
		Condicao.MOVIMENTO_CONTINUO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Movimento",
				"dificuldade": 2, "risco": 1, "frequencia": 4, "severidade": 2, "impacto": 2,
				"mult": 0.20,
				"budget_bonus": 20.0,
				"nome": "Dança dos Passos (Correr 2.5s)",
				"desc": "Requer estar em corrida contínua por 2.5s antes do disparo.\n+20% de Poder Final.",
				"lore": "A dança dos guerreiros Bap de Bonolenov canaliza a inércia dos passos em impacto."
			}
		Condicao.CURTO_ALCANCE_EXTREMO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Alcance",
				"dificuldade": 3, "risco": 3, "frequencia": 3, "severidade": 2, "impacto": 3,
				"mult": 0.25,
				"budget_bonus": 25.0,
				"nome": "Ponto de Impacto Zero (< 40px)",
				"desc": "Só atinge alvos colados ao corpo do jogador.\n+25% de Poder Final por proximidade extrema.",
				"lore": "Limitar o alcance ao milímetro do toque concentra o Ko no ponto de ruptura."
			}
		Condicao.LONGO_ALCANCE_SNIPER:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Alcance",
				"dificuldade": 2, "risco": 1, "frequencia": 3, "severidade": 2, "impacto": 2,
				"mult": 0.20,
				"budget_bonus": 20.0,
				"nome": "Disparo Sniper (> 220px)",
				"desc": "Só causa efeito em alvos a longa distância (> 220px).\n+20% de Poder Final.",
				"lore": "A precisão balística de emissão à distância requer mira impecável."
			}
		Condicao.APOS_ESQUIVA_PERFEITA:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Ativação",
				"dificuldade": 3, "risco": 2, "frequencia": 3, "severidade": 2, "impacto": 2,
				"mult": 0.30,
				"budget_bonus": 30.0,
				"nome": "Contra-Golpe Instantâneo (Pós-Esquiva)",
				"desc": "Disponível apenas nos 2 segundos após uma Esquiva Perfeita.\n+30% de Poder Final.",
				"lore": "Aproveitar a abertura do oponente logo após desviar no último instante."
			}
		Condicao.REQUER_TEN_ATIVO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Ativação",
				"dificuldade": 1, "risco": 1, "frequencia": 4, "severidade": 1, "impacto": 2,
				"mult": 0.15,
				"budget_bonus": 15.0,
				"nome": "Canalização de Ten",
				"desc": "Requer manter a técnica Ten ativa durante o disparo.\n+15% de Poder e resistência.",
				"lore": "O manto de Ten estabiliza o fluxo de Nen, impedindo dispersão."
			}
		Condicao.REQUER_REN_ATIVO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Ativação",
				"dificuldade": 2, "risco": 2, "frequencia": 4, "severidade": 2, "impacto": 2,
				"mult": 0.20,
				"budget_bonus": 20.0,
				"nome": "Explosão de Ren",
				"desc": "Requer que o Ren esteja ativo no momento do golpe.\n+20% de Poder.",
				"lore": "Liberar o Ren multiplica a intensidade do Hatsu."
			}
		Condicao.COOLDOWN_LONGO:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Temporal",
				"dificuldade": 1, "risco": 1, "frequencia": 5, "severidade": 2, "impacto": 2,
				"mult": 0.20,
				"budget_bonus": 20.0,
				"nome": "Restrição Temporal (Recarga 2x)",
				"desc": "O tempo de recarga é duplicado.\n+20% de Poder Final.",
				"lore": "Longos intervalos de descanso permitem acumular maior densidade energética."
			}
		Condicao.REVELACAO_HABILIDADE:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "Comportamental",
				"dificuldade": 2, "risco": 2, "frequencia": 5, "severidade": 2, "impacto": 2,
				"mult": 0.20,
				"budget_bonus": 20.0,
				"nome": "Voto da Revelação (Countdown de Genthru)",
				"desc": "O personagem expõe as regras do Hatsu ao oponente em balão de mangá.\n+20% de Poder.",
				"lore": "Abdicar do elemento surpresa explicando a técnica fortalece o feitiço de Nen."
			}

		# --- 🟡 TIER 2 (Juramentos Sério) ---
		Condicao.HP_ABAIXO_30:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "HP / Vida",
				"dificuldade": 4, "risco": 4, "frequencia": 2, "severidade": 4, "impacto": 4,
				"mult": 0.45,
				"budget_bonus": 45.0,
				"nome": "Juramento do Desespero (HP < 30%)",
				"desc": "Só pode ser usado em estado crítico (HP < 30%).\n+45% de Poder Final para viradas épicas.",
				"lore": "À beira do abismo, o instinto de sobrevivência desbloqueia o potencial oculto."
			}
		Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Alvo / Comportamental",
				"dificuldade": 3, "risco": 4, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.50,
				"budget_bonus": 50.0,
				"nome": "Voto do Retorno (Contra quem atacou primeiro)",
				"desc": "Só funciona contra inimigos que já atacaram o jogador primeiro no combate.\n+50% de Poder Final.",
				"lore": "Princípio da Autodefesa Absoluta — a aura só reage contra a intenção assassina do agressor."
			}
		Condicao.IMOVEL_DURANTE_USO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Movimento",
				"dificuldade": 4, "risco": 4, "frequencia": 4, "severidade": 4, "impacto": 4,
				"mult": 0.50,
				"budget_bonus": 50.0,
				"nome": "Postura Inamovível (Canhão Fixo)",
				"desc": "O personagem não pode se mover nem cancelar enquanto a técnica estiver ativa.\n+50% de Poder Final.",
				"lore": "Ancorar os pés no chão e transformar o próprio corpo em uma torre de artilharia de Nen."
			}
		Condicao.NAO_ESQUIVAR_DURANTE_EFEITO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Movimento",
				"dificuldade": 3, "risco": 4, "frequencia": 4, "severidade": 3, "impacto": 3,
				"mult": 0.35,
				"budget_bonus": 35.0,
				"nome": "Sem Esquiva (Sem Dash)",
				"desc": "Bloqueia o Dash e Esquivas enquanto a habilidade estiver em efeito.\n+35% de Poder Final.",
				"lore": "Renunciar à evasão força o fluxo de Nen a se concentrar inteiramente no impacto."
			}
		Condicao.NAO_VIOLENCIA:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Comportamental",
				"dificuldade": 3, "risco": 3, "frequencia": 4, "severidade": 4, "impacto": 4,
				"mult": 0.50,
				"budget_bonus": 50.0,
				"nome": "Defesa Pacífica (Sem Ataques Básicos)",
				"desc": "Impede ataques básicos enquanto o escudo durar.\n+50% de absorção e reflete 50% do dano.",
				"lore": "Abdicar totalmente da agressão fortalece o Ten e o Ken para criar uma barreira inabalável."
			}
		Condicao.ZETSU_POS_USO_15S:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Pós-Uso",
				"dificuldade": 4, "risco": 5, "frequencia": 4, "severidade": 5, "impacto": 5,
				"mult": 0.60,
				"budget_bonus": 60.0,
				"nome": "Exaustão Absoluta (Zetsu por 15s pós-uso)",
				"desc": "Após usar, o jogador entra forçadamente em Zetsu por 15s (sem Nen nem defesa).\n+60% de Poder Final.",
				"lore": "Esgotar até o último poro de aura exige um período imediato de desligamento total dos nós."
			}
		Condicao.BLOQUEIO_NEN_10S:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Pós-Uso",
				"dificuldade": 4, "risco": 4, "frequencia": 4, "severidade": 4, "impacto": 4,
				"mult": 0.45,
				"budget_bonus": 45.0,
				"nome": "Sobrecarga de Nen (Bloqueio por 10s)",
				"desc": "Bloqueia todas as técnicas de Nen e outros Hatsus por 10 segundos pós-uso.\n+45% de Poder Final.",
				"lore": "O circuito de nós de Nen superaquece, exigindo resfriamento biológico."
			}
		Condicao.DOR_ACUMULADA:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "HP / Dano",
				"dificuldade": 4, "risco": 4, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.50,
				"budget_bonus": 50.0,
				"nome": "Pain Packer (Transmutação da Dor de Feitan)",
				"desc": "O poder escala diretamente com todo o dano sofrido nos últimos 10s (+50% até +120%).",
				"lore": "Transmutar a agonia e o sofrimento físico sofrido em calor, fogo e devastação."
			}
		Condicao.ALMAS_INIMIGOS:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Ativação / Alvo",
				"dificuldade": 3, "risco": 3, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.10,
				"budget_bonus": 40.0,
				"nome": "Colheita de Almas (Pacto de Morena / Camilla)",
				"desc": "Derrotar monstros acumula almas (+10% por alma, até 10 almas = +100% poder!).",
				"lore": "Absorção de resquícios de Nen pós-morte para energizar o disparo."
			}
		Condicao.ORACAO_GRATIDAO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Movimento / Ativação",
				"dificuldade": 3, "risco": 4, "frequencia": 4, "severidade": 3, "impacto": 3,
				"mult": 0.40,
				"budget_bonus": 40.0,
				"nome": "Oração dos 10.000 Golpes de Gratidão (Netero)",
				"desc": "O personagem realiza uma reverência imóvel de 0.7s antes do golpe.\n+40% de Poder.",
				"lore": "A reverência e os socos de gratidão de Netero que transcendem a velocidade humana."
			}
		Condicao.COMBO_SEQUENCIA:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Sequência / Combo",
				"dificuldade": 4, "risco": 3, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.45,
				"budget_bonus": 45.0,
				"nome": "Sequência Rítmica (Ataque -> Dash -> Nen -> Hatsu)",
				"desc": "Só ativa se a sequência correta de comandos for realizada nos últimos 3s.\n+45% de Poder.",
				"lore": "Canalizar a memória muscular e o ritmo respiratório marcial."
			}
		Condicao.ALVO_ELITE_BOSS:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Alvo",
				"dificuldade": 4, "risco": 4, "frequencia": 2, "severidade": 4, "impacto": 4,
				"mult": 0.55,
				"budget_bonus": 55.0,
				"nome": "Chain Jail (Apenas Chefes e Elites)",
				"desc": "Só pode ser ativado contra Chefes e Inimigos de Elite com Nen.\n+55% de Poder + Stun forçado.",
				"lore": "O juramento de Kurapika — apostar a própria vida contra alvos específicos concede poder absoluto."
			}
		Condicao.CUSTO_DUPLO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "Recursos",
				"dificuldade": 2, "risco": 2, "frequencia": 5, "severidade": 3, "impacto": 3,
				"mult": 0.35,
				"budget_bonus": 35.0,
				"nome": "Sacrifício de Aura (Custo 2x)",
				"desc": "Consome o dobro de Aura ao ativar.\n+35% de Poder Final por densidade extrema.",
				"lore": "Condensação maciça de aura gera ondas de choque devastadoras."
			}
		Condicao.AUTO_DANO:
			return {
				"tier": Tier.JURAMENTO,
				"categoria": "HP / Vida",
				"dificuldade": 3, "risco": 4, "frequencia": 5, "severidade": 3, "impacto": 3,
				"mult": 0.40,
				"budget_bonus": 40.0,
				"nome": "Pacto de Sangue (-10% HP Próprio)",
				"desc": "Consome 10% da vida máxima a cada uso.\n+40% de Poder Final (Troca vital).",
				"lore": "A troca de sangue biológico por energia Nen ativa aceleração celular destrutiva."
			}

		# --- 🔴 TIER 3 (Votos Extremos) ---
		Condicao.HP_ABAIXO_20:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "HP / Vida",
				"dificuldade": 5, "risco": 5, "frequencia": 1, "severidade": 5, "impacto": 5,
				"mult": 0.80,
				"budget_bonus": 80.0,
				"nome": "À Beira da Morte (HP Crítico < 20%)",
				"desc": "Exclusivo para momentos terminais com HP < 20%.\n+80% de Poder Final!",
				"lore": "O brilho final de uma vida prestes a se extinguir produz uma supernova de Nen."
			}
		Condicao.USO_UNICO_POR_COMBATE:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "Ativação / Risco",
				"dificuldade": 4, "risco": 4, "frequencia": 1, "severidade": 5, "impacto": 5,
				"mult": 0.90,
				"budget_bonus": 90.0,
				"nome": "Único Disparo (1x por Batalha)",
				"desc": "Só pode ser usado uma única vez por combate inteiro.\n+90% de Poder Final!",
				"lore": "A cartada final que decide a vida ou a morte em um único instante."
			}
		Condicao.DRENO_TOTAL_AURA:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "Recursos",
				"dificuldade": 4, "risco": 5, "frequencia": 2, "severidade": 5, "impacto": 5,
				"mult": 0.90,
				"budget_bonus": 90.0,
				"nome": "Zero Ko (Dreno de 100% da Aura Atual)",
				"desc": "Esvazia completamente a barra de Aura ao disparar.\n+90% de Poder Final!",
				"lore": "A técnica suprema de Netero — projetar toda a aura restante em um feixe aniquilador."
			}
		Condicao.AUTO_DANO_30_SANGUE:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "HP / Vida",
				"dificuldade": 4, "risco": 5, "frequencia": 2, "severidade": 5, "impacto": 5,
				"mult": 1.00,
				"budget_bonus": 100.0,
				"nome": "Grande Sacrifício Vital (-30% HP)",
				"desc": "Sacrifica 30% da vida máxima do jogador ao usar.\n+100% de Poder Final!",
				"lore": "Troca de carne e espírito por destruição incondicional."
			}
		Condicao.PENALIDADE_MORTE_ERRO:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "Risco",
				"dificuldade": 5, "risco": 5, "frequencia": 2, "severidade": 5, "impacto": 5,
				"mult": 1.20,
				"budget_bonus": 120.0,
				"nome": "Voto do Cadafalso (Se errar, sofre 50% HP e 30s Zetsu)",
				"desc": "Se o ataque não atingir ou for interrompido, o usuário sofre metade da vida e 30s de Zetsu.\n+120% de Poder!",
				"lore": "A espada de Dâmocles sobre a cabeça do usuário — errar é cortejar a própria morte."
			}
		Condicao.VOTO_ABSOLUTO_CHAIN:
			return {
				"tier": Tier.VOTO_EXTREMO,
				"categoria": "Alvo / Voto Absoluto",
				"dificuldade": 5, "risco": 5, "frequencia": 1, "severidade": 5, "impacto": 5,
				"mult": 1.40,
				"budget_bonus": 140.0,
				"nome": "Voto da Corrente do Julgamento Absoluto (Kurapika)",
				"desc": "Uso restrito a Chefes, 1x por combate, com auto-dano vital em caso de falha.\n+140% de Poder!",
				"lore": "Um juramento cravado com a lâmina do julgamento no próprio coração."
			}
		Condicao.CUSTOMIZADO, _:
			return {
				"tier": Tier.CONDICAO,
				"categoria": "IA de Nen Livre",
				"dificuldade": 3, "risco": 3, "frequencia": 3, "severidade": 3, "impacto": 3,
				"mult": 0.25,
				"budget_bonus": 25.0,
				"nome": "Juramento Personalizado (IA de Nen)",
				"desc": "Juramento livre avaliado pelo motor semântico inteligente de Nen.",
				"lore": "Todo pacto baseado em sacrifício e determinação genuína é reconhecido pelo fluxo de Nen."
			}


# ============================================================
# CÁLCULO DO MULTIPLICADOR E EVOLUÇÃO
# ============================================================

func obter_multiplicador_poder() -> float:
	var bonus_total: float = 0.0

	# Bônus de Evolução de Hatsu (Lv. 1 a 100: até +25% bônus)
	var bonus_evo: float = float(nivel_evolucao_hatsu - 1) * 0.0025
	bonus_total += bonus_evo

	# Bônus intrínseco de Arquétipos com Aleatoriedade
	match arquetipo:
		Arquetipo.ARSENAL_ROLETA:
			bonus_total += 0.30
		Arquetipo.OBJETO_MOEDA:
			bonus_total += 0.20
		Arquetipo.OBJETO_DADO:
			bonus_total += 0.35

	# Condições Legadas
	for cond in condicoes:
		if cond == Condicao.ALMAS_INIMIGOS:
			bonus_total += clamp(float(almas_acumuladas) * 0.10, 0.0, 1.00)
			continue
		elif cond == Condicao.DOR_ACUMULADA:
			var bonus_dor: float = clamp(dor_acumulada / 100.0, 0.25, 1.20)
			bonus_total += bonus_dor
			continue
		elif cond == Condicao.CUSTOMIZADO:
			bonus_total += max(0.0, vow_custom_mult - 1.0)
			continue

		var info: Dictionary = obter_info_condicao(cond)
		var bonus_calculado: float = float(info.get("mult", 0.20))
		bonus_total += bonus_calculado

	# Condições Modulares
	for m_cond in modular_conditions:
		var c_info = HatsuComponentLibrary.get_condition_info(int(m_cond))
		bonus_total += float(c_info.get("budget_bonus", 15.0)) / 120.0

	# Restrições Modulares
	for m_res in modular_restrictions:
		var r_info = HatsuComponentLibrary.get_restriction_info(int(m_res))
		bonus_total += float(r_info.get("budget_bonus", 20.0)) / 120.0

	# Drawbacks Modulares
	for m_draw in modular_drawbacks:
		var d_info = HatsuComponentLibrary.get_drawback_info(int(m_draw))
		bonus_total += float(d_info.get("budget_bonus", 15.0)) / 120.0

	# Curva Suave com Diminishing Returns para somas acima de +100%
	var mult_final: float = 1.0
	if bonus_total <= 1.0:
		mult_final = 1.0 + bonus_total
	else:
		# Acima de 2.0x, os bônus adicionais rendem 50% para evitar multiplicadores absurdos
		mult_final = 2.0 + ((bonus_total - 1.0) * 0.5)

	return mult_final


func obter_poder_final() -> float:
	var base_dmg: float = custom_damage if custom_damage > 0.0 else poder_base
	return base_dmg * obter_multiplicador_poder()


func obter_custo_final() -> float:
	if custom_aura_cost > 0.0:
		return custom_aura_cost
	var mult: float = 1.0
	if Condicao.CUSTO_DUPLO in condicoes:
		mult *= 2.0
	return custo_aura_base * mult


func obter_cooldown_final() -> float:
	if custom_cooldown > 0.0:
		return custom_cooldown
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
	if (Condicao.USO_UNICO_POR_COMBATE in condicoes or Condicao.VOTO_ABSOLUTO_CHAIN in condicoes or HatsuComponentLibrary.RestrictionType.ONCE_PER_COMBAT in modular_restrictions) and usado_no_combate_atual:
		return {"pode": false, "motivo": "Voto Extremo: Esta técnica só pode ser usada 1x por combate!"}

	# HP Checks
	if (Condicao.HP_ABAIXO_50 in condicoes or HatsuComponentLibrary.ConditionType.HP_BELOW_50 in modular_conditions) and pct_hp >= 0.5:
		return {"pode": false, "motivo": "Juramento de Risco: Requer HP abaixo de 50%!"}
	if (Condicao.HP_ABAIXO_30 in condicoes or HatsuComponentLibrary.ConditionType.HP_BELOW_30 in modular_conditions) and pct_hp >= 0.3:
		return {"pode": false, "motivo": "Juramento do Desespero: Requer HP Crítico abaixo de 30%!"}
	if (Condicao.HP_ABAIXO_20 in condicoes or HatsuComponentLibrary.ConditionType.HP_BELOW_20 in modular_conditions) and pct_hp >= 0.2:
		return {"pode": false, "motivo": "Voto Extremo: Requer estar à beira da morte (HP < 20%)!"}
	if (Condicao.HP_CHEIO in condicoes or HatsuComponentLibrary.ConditionType.HP_FULL in modular_conditions) and pct_hp < 0.99:
		return {"pode": false, "motivo": "Condição da Plenitude: Requer 100% de HP intacto!"}

	# Aura Checks
	if (Condicao.AURA_MINIMA_50 in condicoes or HatsuComponentLibrary.ConditionType.AURA_MIN_50 in modular_conditions) and pct_aura < 0.5:
		return {"pode": false, "motivo": "Reserva Estável: Requer pelo menos 50% de Aura!"}

	# Estados de Nen
	if (Condicao.REQUER_TEN_ATIVO in condicoes or HatsuComponentLibrary.ConditionType.REQUIRES_TEN in modular_conditions) and not em_ten:
		return {"pode": false, "motivo": "Canalização de Ten: Requer manter o Ten ativo!"}
	if (Condicao.REQUER_REN_ATIVO in condicoes or HatsuComponentLibrary.ConditionType.REQUIRES_REN in modular_conditions) and not em_ren:
		return {"pode": false, "motivo": "Explosão de Ren: Requer manter o Ren ativo!"}

	# Esquiva Perfeita
	if (Condicao.APOS_ESQUIVA_PERFEITA in condicoes or HatsuComponentLibrary.ConditionType.POST_PERFECT_DODGE in modular_conditions) and not pos_esquiva_recente:
		return {"pode": false, "motivo": "Contra-Golpe: Só usável nos 2s após Esquiva Perfeita!"}

	# Contra quem atacou primeiro
	if (Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO in condicoes or HatsuComponentLibrary.ConditionType.FIRST_ATTACKER_ONLY in modular_conditions):
		if primeiro_atacante_id.is_empty():
			return {"pode": false, "motivo": "Voto do Retorno: Só usável contra quem atacar o jogador primeiro!"}
		if not target_id.is_empty() and target_id != primeiro_atacante_id:
			return {"pode": false, "motivo": "Voto do Retorno: O alvo selecionado não foi quem atacou primeiro!"}

	# Alvo Chefes / Elites
	if (Condicao.ALVO_ELITE_BOSS in condicoes or Condicao.VOTO_ABSOLUTO_CHAIN in condicoes or HatsuComponentLibrary.ConditionType.TARGET_BOSS_ELITE in modular_conditions) and not target_is_boss and not target_id.is_empty():
		return {"pode": false, "motivo": "Chain Jail: Este juramento só pode atingir Chefes/Elites com Nen!"}

	# Alcances
	if (Condicao.CURTO_ALCANCE_EXTREMO in condicoes or HatsuComponentLibrary.ConditionType.CLOSE_RANGE_ZERO in modular_conditions) and target_distance > 45.0:
		return {"pode": false, "motivo": "Ponto de Impacto Zero: Requer proximidade extrema (< 40px)!"}
	if (Condicao.LONGO_ALCANCE_SNIPER in condicoes or HatsuComponentLibrary.ConditionType.LONG_RANGE_SNIPER in modular_conditions) and target_distance < 200.0:
		return {"pode": false, "motivo": "Disparo Sniper: Alvo muito próximo! Requer distância > 220px."}

	# Almas
	if Condicao.ALMAS_INIMIGOS in condicoes and almas_acumuladas <= 0:
		return {"pode": false, "motivo": "Colheita de Almas: Requer ao menos 1 alma acumulada de abates!"}

	var gameplay_context := player_context.duplicate(true)
	gameplay_context.merge(target_context, true)
	gameplay_context["player_hp_percent"] = pct_hp
	gameplay_context["target_hp_percent"] = float(target_context.get("hp_percent", 1.0))
	gameplay_context["hatsu_tags"] = GameplayTags.normalize(tags)
	for gameplay_condition in gameplay_conditions:
		if gameplay_condition == null:
			continue
		if not gameplay_condition.evaluate(gameplay_context).get("met", false):
			return {"pode": false, "motivo": "Condição de combate não atendida."}

	return {"pode": true, "motivo": ""}


# ============================================================
# SERIALIZAÇÃO & PERSISTÊNCIA SAVE/LOAD MULTI-VERSÃO
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


func gerar_novo_id() -> String:
	if hatsu_id.is_empty():
		hatsu_id = "hatsu_%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]
	return hatsu_id


func to_dict() -> Dictionary:
	if hatsu_id.is_empty():
		gerar_novo_id()

	var conds: Array[int] = []
	for c in condicoes:
		conds.append(int(c))

	var m_conds: Array[int] = []
	for mc in modular_conditions:
		m_conds.append(int(mc))
	var serialized_gameplay_conditions: Array[Dictionary] = []
	for gameplay_condition in gameplay_conditions:
		if gameplay_condition != null:
			serialized_gameplay_conditions.append(gameplay_condition.to_dict())

	var m_res: Array[int] = []
	for mr in modular_restrictions:
		m_res.append(int(mr))

	var m_draw: Array[int] = []
	for md in modular_drawbacks:
		m_draw.append(int(md))

	return {
		"hatsu_id": hatsu_id,
		"hatsu_version": hatsu_version,
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
		"tags": GameplayTags.normalize(tags),
		"gameplay_conditions": serialized_gameplay_conditions,
		"usuario_original": usuario_original,
		"activation_type": int(activation_type),
		"duration_type": int(duration_type),
		"channel": int(channel),
		"exclusive_group": exclusive_group,
		"concurrent_allowed": concurrent_allowed,
		"aura_drain_per_sec": aura_drain_per_sec,
		"aura_drain_per_hit": aura_drain_per_hit,
		"skill_hunter_compatible": skill_hunter_compatible,
		# Componentes Modulares
		"core_component": core_component,
		"effect_modules": effect_modules.duplicate(true),
		"modular_conditions": m_conds,
		"modular_restrictions": m_res,
		"modular_drawbacks": m_draw,
		# Custom Sliders
		"custom_damage": custom_damage,
		"custom_range": custom_range,
		"custom_radius": custom_radius,
		"custom_duration": custom_duration,
		"custom_cooldown": custom_cooldown,
		"custom_aura_cost": custom_aura_cost,
		"custom_absorption_pct": custom_absorption_pct,
		"custom_stat_bonus": custom_stat_bonus.duplicate(),
		# Scores
		"power_score": power_score,
		"complexity_score": complexity_score,
		"risk_score": risk_score,
		"efficiency_score": efficiency_score,
		"is_custom_created": is_custom_created,
		"creator_id": creator_id,
		"absorption_target_stat": absorption_target_stat,
		"absorption_rate": absorption_rate,
		"rollback_seconds": rollback_seconds,
		"territory_rule_type": territory_rule_type,
		"visual_profile": visual_profile.to_dict() if visual_profile != null else null,
		# Hatsu Creator v1.5
		"preparation_steps": preparation_steps.duplicate(true),
		"versatility_score": versatility_score,
		"functional_power": functional_power,
		"limitation_credits": limitation_credits,
		"condition_credits": condition_credits,
		"restriction_credits": restriction_credits,
		"vow_credits": vow_credits,
		"preparation_credits": preparation_credits,
		"sub_effects": sub_effects.duplicate(),
		"required_credits": required_credits,
		"available_credits": available_credits,
		"credit_deficit": credit_deficit,
		"is_draft": is_draft,
		"parametros_conceito": parametros_conceito.duplicate(true),
		# Mecânica de Armazenamento e Roubo de Hatsu
		"is_storage_hatsu": is_storage_hatsu,
		"storage_capacity": storage_capacity,
		"storage_duration_type": storage_duration_type,
		"storage_usage_rule": storage_usage_rule,
		"steal_conditions": steal_conditions.duplicate(),
		"steal_target_type": steal_target_type
	}


func obter_visual_profile() -> VisualProfile:
	if visual_profile != null:
		return visual_profile
	var vp := VisualProfile.new()
	vp.primary_color = cor_aura
	vp.secondary_color = cor_aura_secundaria
	vp.core_color = Color(1.0, 1.0, 1.0, 1.0)
	vp.glow_color = cor_aura
	vp.glow_intensity = 0.8
	match forma:
		Forma.PROJETIL: vp.shape = VisualProfile.VisualShape.SPHERE
		Forma.AREA, Forma.ZONA: vp.shape = VisualProfile.VisualShape.RING
		Forma.TOQUE: vp.shape = VisualProfile.VisualShape.BLADE
		_: vp.shape = VisualProfile.VisualShape.SPHERE
	return vp


static func from_dict(data: Dictionary) -> HatsuData:
	var h := HatsuData.new()
	var ver: int = data.get("hatsu_version", 1)
	h.hatsu_version = ver
	h.hatsu_id = data.get("hatsu_id", "")
	if h.hatsu_id.is_empty():
		h.gerar_novo_id()
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
	h.activation_type = data.get("activation_type", ActivationType.INSTANT)
	h.duration_type = data.get("duration_type", DurationType.INSTANT)
	h.channel = data.get("channel", HatsuChannel.OFFENSIVE)
	h.exclusive_group = data.get("exclusive_group", "")
	h.concurrent_allowed = data.get("concurrent_allowed", true)
	h.aura_drain_per_sec = float(data.get("aura_drain_per_sec", 0.0))
	h.aura_drain_per_hit = float(data.get("aura_drain_per_hit", 0.0))
	h.skill_hunter_compatible = bool(data.get("skill_hunter_compatible", true))

	# Tags
	var tags_in = data.get("tags", [])
	var typed_tags: Array[String] = []
	for t in tags_in:
		typed_tags.append(str(t))
	h.tags = GameplayTags.normalize(typed_tags)

	var conditions_in = data.get("gameplay_conditions", [])
	var typed_gameplay_conditions: Array[GameplayCondition] = []
	for condition_data in conditions_in:
		if condition_data is Dictionary:
			typed_gameplay_conditions.append(GameplayCondition.from_dict(condition_data))
	h.gameplay_conditions = typed_gameplay_conditions

	# Condições Legadas
	var conds_in = data.get("condicoes", [])
	var typed_conds: Array[Condicao] = []
	for c in conds_in:
		typed_conds.append(int(c) as Condicao)
	h.condicoes = typed_conds

	# Componentes Modulares (Versão 2+)
	h.core_component = data.get("core_component", 0)
	var eff_in = data.get("effect_modules", [])
	var typed_eff: Array = []
	for e in eff_in:
		if e is Dictionary: typed_eff.append(e)
	h.effect_modules = typed_eff

	var mc_in = data.get("modular_conditions", [])
	var typed_mc: Array = []
	for mc in mc_in: typed_mc.append(int(mc))
	h.modular_conditions = typed_mc

	var mr_in = data.get("modular_restrictions", [])
	var typed_mr: Array = []
	for mr in mr_in: typed_mr.append(int(mr))
	h.modular_restrictions = typed_mr

	var md_in = data.get("modular_drawbacks", [])
	var typed_md: Array = []
	for md in md_in: typed_md.append(int(md))
	h.modular_drawbacks = typed_md

	# Custom Sliders
	h.custom_damage = float(data.get("custom_damage", 0.0))
	h.custom_range = float(data.get("custom_range", 0.0))
	h.custom_radius = float(data.get("custom_radius", 0.0))
	h.custom_duration = float(data.get("custom_duration", 0.0))
	h.custom_cooldown = float(data.get("custom_cooldown", 0.0))
	h.custom_aura_cost = float(data.get("custom_aura_cost", 0.0))
	h.custom_absorption_pct = float(data.get("custom_absorption_pct", 0.0))
	h.custom_stat_bonus = data.get("custom_stat_bonus", {})

	# Scores & Especialização
	h.power_score = float(data.get("power_score", 0.0))
	h.complexity_score = float(data.get("complexity_score", 0.0))
	h.risk_score = float(data.get("risk_score", 0.0))
	h.efficiency_score = float(data.get("efficiency_score", 0.0))
	h.is_custom_created = bool(data.get("is_custom_created", false))
	h.creator_id = str(data.get("creator_id", ""))
	h.absorption_target_stat = str(data.get("absorption_target_stat", "aura_max"))
	h.absorption_rate = float(data.get("absorption_rate", 0.05))
	h.rollback_seconds = float(data.get("rollback_seconds", 5.0))
	h.territory_rule_type = str(data.get("territory_rule_type", ""))

	# Hatsu Creator v1.5
	var prep_in = data.get("preparation_steps", [])
	var typed_prep: Array = []
	for p in prep_in:
		if p is Dictionary: typed_prep.append(p)
	h.preparation_steps = typed_prep

	h.versatility_score = float(data.get("versatility_score", 0.0))
	h.functional_power = float(data.get("functional_power", 0.0))
	h.limitation_credits = float(data.get("limitation_credits", 0.0))
	h.condition_credits = float(data.get("condition_credits", 0.0))
	h.restriction_credits = float(data.get("restriction_credits", 0.0))
	h.vow_credits = float(data.get("vow_credits", 0.0))
	h.preparation_credits = float(data.get("preparation_credits", 0.0))

	var sub_in = data.get("sub_effects", [])
	var typed_sub: Array = []
	for s in sub_in:
		typed_sub.append(int(s))
	h.sub_effects = typed_sub

	h.required_credits = float(data.get("required_credits", h.functional_power))
	h.available_credits = float(data.get("available_credits", h.limitation_credits))
	h.credit_deficit = float(data.get("credit_deficit", max(0.0, h.required_credits - h.available_credits)))
	h.is_draft = bool(data.get("is_draft", false))
	h.parametros_conceito = data.get("parametros_conceito", {})

	# Mecânica de Armazenamento e Roubo de Hatsu
	h.is_storage_hatsu = bool(data.get("is_storage_hatsu", false))
	h.storage_capacity = int(data.get("storage_capacity", 3))
	h.storage_duration_type = str(data.get("storage_duration_type", "PERMANENT"))
	h.storage_usage_rule = str(data.get("storage_usage_rule", "OPEN_BOOK"))
	var steal_conds_in = data.get("steal_conditions", [])
	var typed_sc: Array[String] = []
	for sc in steal_conds_in:
		typed_sc.append(str(sc))
	h.steal_conditions = typed_sc
	h.steal_target_type = str(data.get("steal_target_type", "ANY"))

	# Perfil Visual Customizado
	if data.has("visual_profile") and data["visual_profile"] is Dictionary:
		h.visual_profile = VisualProfile.from_dict(data["visual_profile"])

	# Auto-migração de Versão 1 para Versão 2 se necessário
	if ver < 2:
		h.hatsu_version = 2
		if h.core_component == 0 and h.forma == Forma.PROJETIL:
			h.core_component = HatsuComponentLibrary.CoreType.PROJECTILE
		elif h.core_component == 0 and h.forma == Forma.AREA:
			h.core_component = HatsuComponentLibrary.CoreType.ZONE

	return h
