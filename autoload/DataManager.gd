extends Node

# ============================================================
# HUNTER ONLINE - DATA MANAGER (CENTRAL DATABASE)
# ============================================================
#
# Repositório central de dados estáticos do jogo:
# - Catálogo de Itens & Equipamentos com busca O(1)
# - Catálogo de Modelos de Inimigos (EnemyData)
# - Catálogo de Quests e Cartas de Greed Island
# - Carregamento automático de arquivos .tres e definições canônicas
#
# ============================================================

var items_registry: Dictionary = {}
var equipment_registry: Dictionary = {}
var enemies_registry: Dictionary = {}


func _ready() -> void:
	print("=================================")
	print("[DataManager] BANCO DE DADOS CENTRAL ATIVO")
	print("=================================")
	_carregar_dados_estaticos()


func _carregar_dados_estaticos() -> void:
	# 1. Carregar Itens Padrão
	_inicializar_itens_canônicos()
	
	# 2. Carregar Inimigos Padrão
	_inicializar_inimigos_canônicos()
	
	print("[DataManager] Registrados: %d Itens, %d Equipamentos, %d Inimigos" % [
		items_registry.size(),
		equipment_registry.size(),
		enemies_registry.size()
	])


# ------------------------------------------------------------
# 1. REGISTRO E CONSULTA DE ITENS
# ------------------------------------------------------------
func _inicializar_itens_canônicos() -> void:
	# Licença Hunter
	var licenca = load("res://data/items/licenca_hunter.tres")
	if licenca:
		items_registry[&"licenca_hunter"] = licenca
	else:
		var item_script = load("res://resource/item/ItemData.gd")
		if item_script:
			var lic = item_script.new()
			lic.item_id = &"licenca_hunter"
			lic.nome_item = "Licença Hunter Oficial"
			lic.descricao = "A prestigiada licença conferida pela Associação Hunter."
			lic.tipo = 0 # CHAVE
			items_registry[&"licenca_hunter"] = lic
			
	# Plaqueta do Exame
	var plaqueta = load("res://data/items/plaqueta_numero.tres")
	if plaqueta:
		items_registry[&"plaqueta_numero"] = plaqueta
		
	# Poção de Vida
	var item_script = load("res://resource/item/ItemData.gd")
	if item_script:
		var pot = item_script.new()
		pot.item_id = &"pocao_vida"
		pot.nome_item = "Poção Restauradora de Vitalidade"
		pot.descricao = "Recupera 50 pontos de vida instantaneamente."
		pot.tipo = 3 # CONSUMAVEL
		pot.preco_compra = 200
		pot.preco_venda = 100
		items_registry[&"pocao_vida"] = pot
		
		var elix = item_script.new()
		elix.item_id = &"elixir_aura"
		elix.nome_item = "Elixir de Concentração de Aura"
		elix.descricao = "Acelera a recuperação de aura por 60 segundos."
		elix.tipo = 3 # CONSUMAVEL
		elix.preco_compra = 500
		elix.preco_venda = 250
		items_registry[&"elixir_aura"] = elix
		
	# Equipamentos Canônicos com Trade-offs (Task 6.2)
	var equip_script = load("res://resource/item/EquipmentData.gd")
	if equip_script:
		var amuleto = equip_script.new()
		amuleto.item_id = &"amuleto_forca"
		amuleto.nome_item = "Amuleto de Intensificação"
		amuleto.descricao = "Concede +5 de Força e melhora o fluxo de Ko."
		amuleto.bonus_forca = 5
		equipment_registry[&"amuleto_forca"] = amuleto
		items_registry[&"amuleto_forca"] = amuleto

		# Exemplo 1: Lâmina do Caçador (+8% Velocidade, -5% Defesa)
		var lamina = equip_script.new()
		lamina.item_id = &"lamina_cacador"
		lamina.nome_item = "Lâmina do Caçador"
		lamina.descricao = "Adaga afiada forjada para perseguições velozes nas savanas."
		lamina.bonus_forca = 8
		lamina.bonus_velocidade_pct = 0.08
		lamina.bonus_defesa_pct = -0.05
		lamina.trade_off_descricao = "+8% Velocidade de Movimento | -5% Defesa Física"
		lamina.lore_quote = "\"A presa não espera quem hesita. Golpear primeiro é a única defesa real.\" — Satotz"
		lamina.lore_origin = "Forjada nas oficinas de armaria da Associação Hunter para o Exame de Navegação."
		lamina.is_historical_relic = false
		equipment_registry[&"lamina_cacador"] = lamina
		items_registry[&"lamina_cacador"] = lamina

		# Exemplo 2: Traje de Nen Concentrado (+12% Dano Hatsu, +8% Custo Aura)
		var traje = equip_script.new()
		traje.item_id = &"traje_nen_concentrado"
		traje.nome_item = "Vestimenta de Nen Concentrado"
		traje.descricao = "Manto tecido com fibras condutoras que amplificam a saída de Nen."
		traje.bonus_defesa = 12
		traje.bonus_dano_hatsu_pct = 0.12
		traje.bonus_custo_aura_pct = 0.08
		traje.trade_off_descricao = "+12% Dano de Hatsu | +8% Consumo de Aura"
		traje.lore_quote = "\"Comprimir a aura gera devastação sem igual, mas cobra seu tributo em exaustão.\" — Biscuit Krueger"
		traje.lore_origin = "Utilizado pelos mestres da linhagem Shingen-ryu em treinos de resistência extrema."
		traje.is_historical_relic = true
		equipment_registry[&"traje_nen_concentrado"] = traje
		items_registry[&"traje_nen_concentrado"] = traje

		# Exemplo 3: Adaga Envenenada (+10% Dano, -10% Defesa)
		var adaga = equip_script.new()
		adaga.item_id = &"adaga_envenenada"
		adaga.nome_item = "Adaga Embebida em Toxina"
		adaga.descricao = "Lâmina tratada com secreções da serpente do Pantanal Numelle."
		adaga.bonus_forca = 14
		adaga.bonus_defesa_pct = -0.10
		adaga.trade_off_descricao = "+10% Dano Crítico | -10% Defesa Geral"
		adaga.lore_quote = "\"Uma única gota é o bastante para paralisar uma baleia azul em três segundos.\" — Assassinos Zoldyck"
		adaga.lore_origin = "Adquirida no mercado clandestino de mercenários de Yorknew."
		adaga.is_historical_relic = false
		equipment_registry[&"adaga_envenenada"] = adaga
		items_registry[&"adaga_envenenada"] = adaga

		# Anel do Explorador Ancestral (Recompensa de Exploração Orgânica - Epic 5)
		var anel = equip_script.new()
		anel.item_id = &"anel_explorador_ancestral"
		anel.nome_item = "Anel do Explorador Ancestral"
		anel.descricao = "Anel de jade lapidado concedido pelo Eremita Cego."
		anel.bonus_velocidade_pct = 0.05
		anel.bonus_vida = 30
		anel.trade_off_descricao = "+5% Velocidade | +30 Vida Máxima"
		anel.lore_quote = "\"Os maiores tesouros do mundo nunca estiveram marcados em mapas oficiais.\""
		anel.lore_origin = "Escavado nas profundezas das Ruínas Ancestrais de Zaban."
		anel.is_historical_relic = true
		equipment_registry[&"anel_explorador_ancestral"] = anel
		items_registry[&"anel_explorador_ancestral"] = anel

	# Fragmentos de Lore e Relíquias Colecionáveis (Epic 5 & 6)
	if item_script:
		var tabuleta = item_script.new()
		tabuleta.item_id = &"fragmento_lore_tabuleta"
		tabuleta.nome_item = "Tabuleta Ancestral de Zaban"
		tabuleta.descricao = "Fragmento de rocha decifrado contendo sabedoria milenar de Gyo e Zetsu."
		tabuleta.tipo = 1 # QUEST
		tabuleta.raridade = "Raro"
		tabuleta.lore_quote = "\"A visão cega pelo mundo físico é restaurada quando a aura se concentra nos olhos.\""
		tabuleta.lore_origin = "Ruínas de Zaban (Era Pré-Associação Hunter)"
		tabuleta.is_historical_relic = true
		items_registry[&"fragmento_lore_tabuleta"] = tabuleta

		var reliquia = item_script.new()
		reliquia.item_id = &"reliquia_cacador_antigo"
		reliquia.nome_item = "Broche do Pioneiro Ancestral"
		reliquia.descricao = "Insígnia de bronze usada pelos primeiros exploradores a mapear as fronteiras do mundo conhecido."
		reliquia.tipo = 1 # QUEST
		reliquia.raridade = "Muito Raro"
		reliquia.lore_quote = "\"Não há fronteira que o espírito da caça não possa cruzar.\" — Isaac Netero"
		reliquia.lore_origin = "Primeira Expedição Oficial da Associação Hunter"
		reliquia.is_historical_relic = true
		items_registry[&"reliquia_cacador_antigo"] = reliquia


# ------------------------------------------------------------
# 2. REGISTRO E CONSULTA DE INIMIGOS
# ------------------------------------------------------------
func _inicializar_inimigos_canônicos() -> void:
	var enemy_paths = [
		"res://resource/status/InimigoBase.tres",
		"res://resource/status/GreatStampPig.tres",
		"res://resource/status/MacacoPantanal.tres",
		"res://resource/status/CandidatoSabotador.tres",
		"res://resource/status/enemies/slime.tres",
		"res://resource/status/enemies/formiga_lider.tres",
		"res://resource/status/enemies/bomber_greed.tres"
	]
	
	for path in enemy_paths:
		if ResourceLoader.exists(path):
			var res = load(path)
			if res and "enemy_id" in res and res.enemy_id != &"":
				enemies_registry[res.enemy_id] = res
				
	# 3. Bestiário Canônico e RPG de Inimigos Base para Farming
	_inicializar_bestiario_rpg_base()


func _inicializar_bestiario_rpg_base() -> void:
	var enemy_data_script = load("res://resource/status/EnemyData.gd")
	if not enemy_data_script:
		return

	var base_mobs: Array = [
		{
			"id": &"slime",
			"nome": "Slime da Floresta",
			"level": 1,
			"hp": 60,
			"def": 2,
			"str": 8,
			"xp": 35,
			"role": "bruiser",
			"drops": [{"item_id": "gosma_slime", "chance": 0.85, "quantidade": 1}]
		},
		{
			"id": &"slime_venenoso",
			"nome": "Slime Venenoso",
			"level": 3,
			"hp": 85,
			"def": 3,
			"str": 11,
			"xp": 55,
			"role": "bruiser",
			"drops": [{"item_id": "gosma_slime", "chance": 0.8, "quantidade": 1}, {"item_id": "veneno_concentrado", "chance": 0.4, "quantidade": 1}]
		},
		{
			"id": &"rato_gigante",
			"nome": "Rato Gigante de Esgoto",
			"level": 1,
			"hp": 50,
			"def": 1,
			"str": 7,
			"xp": 30,
			"role": "fast",
			"drops": [{"item_id": "gosma_slime", "chance": 0.5, "quantidade": 1}]
		},
		{
			"id": &"lobo_selvagem",
			"nome": "Lobo Feroz das Planícies",
			"level": 2,
			"hp": 75,
			"def": 3,
			"str": 12,
			"xp": 50,
			"role": "fast",
			"drops": [{"item_id": "couro_lobo", "chance": 0.8, "quantidade": 1}, {"item_id": "carne_javali", "chance": 0.3, "quantidade": 1}]
		},
		{
			"id": &"cao_cacador",
			"nome": "Cão de Caça Treinado",
			"level": 4,
			"hp": 95,
			"def": 4,
			"str": 14,
			"xp": 75,
			"role": "fast",
			"drops": [{"item_id": "couro_lobo", "chance": 0.7, "quantidade": 1}]
		},
		{
			"id": &"javali_selvagem",
			"nome": "Javali Selvagem dos Bosques",
			"level": 3,
			"hp": 110,
			"def": 5,
			"str": 14,
			"xp": 65,
			"role": "bruiser",
			"drops": [{"item_id": "carne_javali", "chance": 0.85, "quantidade": 1}, {"item_id": "couro_lobo", "chance": 0.35, "quantidade": 1}]
		},
		{
			"id": &"ladrao_estrada",
			"nome": "Ladrão de Estrada",
			"level": 3,
			"hp": 90,
			"def": 4,
			"str": 13,
			"xp": 60,
			"role": "fast",
			"drops": [{"item_id": "ouro_roubado", "chance": 0.8, "quantidade": 1}, {"item_id": "minerio_aco", "chance": 0.3, "quantidade": 1}]
		},
		{
			"id": &"bandido_renegado",
			"nome": "Bandido Renegado",
			"level": 6,
			"hp": 135,
			"def": 6,
			"str": 18,
			"xp": 110,
			"role": "bruiser",
			"drops": [{"item_id": "ouro_roubado", "chance": 0.9, "quantidade": 1}, {"item_id": "anel_concentracao", "chance": 0.15, "quantidade": 1}]
		},
		{
			"id": &"besouro_blindado",
			"nome": "Besouro Blindado das Rochas",
			"level": 4,
			"hp": 120,
			"def": 12,
			"str": 10,
			"xp": 80,
			"role": "tank",
			"drops": [{"item_id": "carapaca_besouro", "chance": 0.85, "quantidade": 1}, {"item_id": "gema_terra", "chance": 0.3, "quantidade": 1}]
		},
		{
			"id": &"serpente_sombra",
			"nome": "Serpente das Sombras",
			"level": 5,
			"hp": 100,
			"def": 4,
			"str": 16,
			"xp": 95,
			"role": "fast",
			"drops": [{"item_id": "presa_serpente", "chance": 0.8, "quantidade": 1}, {"item_id": "cristal_sombra", "chance": 0.25, "quantidade": 1}]
		},
		{
			"id": &"fera_magica_bosque",
			"nome": "Besta Mágica Menor",
			"level": 7,
			"hp": 165,
			"def": 8,
			"str": 20,
			"xp": 140,
			"role": "bruiser",
			"drops": [{"item_id": "couro_besta", "chance": 0.85, "quantidade": 1}, {"item_id": "cristal_aura", "chance": 0.3, "quantidade": 1}]
		},
		{
			"id": &"macaco_carnivoro",
			"nome": "Macaco Carnívoro Trapaceiro",
			"level": 5,
			"hp": 115,
			"def": 4,
			"str": 15,
			"xp": 90,
			"role": "fast",
			"drops": [{"item_id": "carne_javali", "chance": 0.6, "quantidade": 1}, {"item_id": "ouro_roubado", "chance": 0.4, "quantidade": 1}]
		},
		{
			"id": &"urso_caverna",
			"nome": "Urso Voraz das Cavernas",
			"level": 8,
			"hp": 220,
			"def": 10,
			"str": 24,
			"xp": 170,
			"role": "tank",
			"drops": [{"item_id": "pele_urso", "chance": 0.85, "quantidade": 1}, {"item_id": "carne_javali", "chance": 0.6, "quantidade": 1}]
		},
		{
			"id": &"mercenario_mafia",
			"nome": "Mercenário da Máfia",
			"level": 8,
			"hp": 180,
			"def": 9,
			"str": 22,
			"xp": 160,
			"role": "bruiser",
			"drops": [{"item_id": "ouro_roubado", "chance": 0.9, "quantidade": 1}, {"item_id": "tecido_reforcado", "chance": 0.4, "quantidade": 1}]
		},
		{
			"id": &"cacador_furtivo",
			"nome": "Caçador Furtivo Renegado",
			"level": 9,
			"hp": 170,
			"def": 7,
			"str": 24,
			"xp": 180,
			"role": "fast",
			"drops": [{"item_id": "cristal_sombra", "chance": 0.5, "quantidade": 1}, {"item_id": "pingente_agilidade", "chance": 0.2, "quantidade": 1}]
		},
		{
			"id": &"golem_pedra",
			"nome": "Golem de Pedra das Ruínas",
			"level": 10,
			"hp": 270,
			"def": 18,
			"str": 26,
			"xp": 220,
			"role": "tank",
			"drops": [{"item_id": "nucleo_golem", "chance": 0.9, "quantidade": 1}, {"item_id": "gema_terra", "chance": 0.6, "quantidade": 1}]
		},
		{
			"id": &"quimera_selvagem",
			"nome": "Quimera Selvagem das Cavernas",
			"level": 12,
			"hp": 310,
			"def": 14,
			"str": 30,
			"xp": 260,
			"role": "bruiser",
			"drops": [{"item_id": "olho_quimera", "chance": 0.75, "quantidade": 1}, {"item_id": "couro_besta", "chance": 0.85, "quantidade": 1}]
		},
		# Família BEAST de Padokia
		{
			"id": &"fera_floresta",
			"nome": "Fera da Floresta",
			"level": 3,
			"hp": 110,
			"def": 4,
			"str": 13,
			"xp": 60,
			"role": "bruiser",
			"weakness_tags": ["slashing", "fire"],
			"drops": [{"item_id": "couro_besta", "chance": 0.85, "quantidade": 1}, {"item_id": "carne_javali", "chance": 0.6, "quantidade": 1}]
		},
		{
			"id": &"lobo_padokia",
			"nome": "Lobo das Planícies",
			"level": 3,
			"hp": 85,
			"def": 3,
			"str": 14,
			"xp": 55,
			"role": "fast",
			"weakness_tags": ["blunt"],
			"drops": [{"item_id": "couro_lobo", "chance": 0.8, "quantidade": 1}, {"item_id": "presa_serpente", "chance": 0.35, "quantidade": 1}]
		},
		{
			"id": &"javali_espinhoso",
			"nome": "Javali Espinhoso",
			"level": 4,
			"hp": 135,
			"def": 7,
			"str": 15,
			"xp": 75,
			"role": "tank",
			"resistance_tags": ["piercing"],
			"drops": [{"item_id": "carne_javali", "chance": 0.9, "quantidade": 1}, {"item_id": "carapaca_besouro", "chance": 0.4, "quantidade": 1}]
		},
		{
			"id": &"predador_miasma",
			"nome": "Criatura Predadora da Névoa",
			"level": 5,
			"hp": 140,
			"def": 5,
			"str": 18,
			"xp": 95,
			"role": "ambusher",
			"weakness_tags": ["nen", "fire"],
			"drops": [{"item_id": "veneno_concentrado", "chance": 0.6, "quantidade": 1}, {"item_id": "cristal_sombra", "chance": 0.3, "quantidade": 1}]
		},
		# Família ANCIENT CONSTRUCTS (Ruínas de Zaban)
		{
			"id": &"sentinela_pedra",
			"nome": "Sentinela de Pedra das Ruínas",
			"level": 5,
			"hp": 160,
			"def": 10,
			"str": 18,
			"xp": 120,
			"role": "tank",
			"weakness_tags": ["blunt", "ko"],
			"resistance_tags": ["slashing", "piercing"],
			"drops": [{"item_id": "minerio_aco", "chance": 0.85, "quantidade": 1}, {"item_id": "fragmento_ruina", "chance": 0.4, "quantidade": 1}]
		},
		{
			"id": &"guardiao_elite",
			"nome": "Guardião de Elite da Ravina",
			"level": 7,
			"hp": 240,
			"def": 12,
			"str": 24,
			"xp": 200,
			"role": "tactician",
			"is_elite": true,
			"npc_tier": 2,
			"weakness_tags": ["ko"],
			"drops": [{"item_id": "nucleo_golem", "chance": 0.7, "quantidade": 1}, {"item_id": "cristal_aura", "chance": 0.4, "quantidade": 1}]
		},
		# Miniboss e Boss de Padokia
		{
			"id": &"lider_matilha_quimera",
			"nome": "Líder da Matilha Quimera",
			"level": 8,
			"hp": 420,
			"def": 12,
			"str": 28,
			"xp": 450,
			"role": "fast",
			"is_elite": true,
			"npc_tier": 3,
			"weakness_tags": ["nen"],
			"drops": [{"item_id": "olho_quimera", "chance": 0.9, "quantidade": 1}, {"item_id": "pele_rara", "chance": 0.5, "quantidade": 1}]
		},
		{
			"id": &"guardiao_ancestral",
			"nome": "Guardião Ancestral de Zaban",
			"level": 10,
			"hp": 600,
			"def": 15,
			"str": 32,
			"xp": 800,
			"role": "boss",
			"is_boss": true,
			"npc_tier": 4,
			"weakness_tags": ["ko", "ren"],
			"drops": [{"item_id": "nucleo_golem", "chance": 1.0, "quantidade": 2}, {"item_id": "amuleto_forca", "chance": 1.0, "quantidade": 1}]
		},
		# Família HUMANOID & BANDIT
		{
			"id": &"arqueiro_renegado",
			"nome": "Arqueiro Renegado",
			"level": 3,
			"hp": 80,
			"def": 3,
			"str": 12,
			"xp": 55,
			"role": "ranged",
			"weakness_tags": ["slashing"],
			"drops": [{"item_id": "ouro_roubado", "chance": 0.8, "quantidade": 1}]
		},
		{
			"id": &"iniciado_nen_sombrio",
			"nome": "Iniciado de Nen Sombrio",
			"level": 6,
			"hp": 175,
			"def": 6,
			"str": 20,
			"xp": 150,
			"role": "nen_user",
			"npc_tier": 2,
			"drops": [{"item_id": "cristal_aura", "chance": 0.8, "quantidade": 1}, {"item_id": "anel_concentracao", "chance": 0.2, "quantidade": 1}]
		}
	]

	for data in base_mobs:
		var eid: StringName = data["id"]
		if not enemies_registry.has(eid):
			var mob = enemy_data_script.new()
			mob.enemy_id = eid
			mob.enemy_name = data["nome"]
			mob.level = data.get("level", 1)
			mob.max_health = data.get("hp", 80)
			mob.defense = data.get("def", 3)
			mob.strength = data.get("str", 10)
			mob.xp_reward = data.get("xp", 40)
			mob.role = data.get("role", "bruiser")
			mob.is_boss = data.get("is_boss", false)
			mob.is_elite = data.get("is_elite", false)
			mob.npc_tier = data.get("npc_tier", 1)
			if data.has("weakness_tags"):
				mob.weakness_tags.clear()
				for wt in data["weakness_tags"]:
					mob.weakness_tags.append(str(wt))
			if data.has("resistance_tags"):
				mob.resistance_tags.clear()
				for rt in data["resistance_tags"]:
					mob.resistance_tags.append(str(rt))
			var dt: Array[Dictionary] = []
			for drop_item in data.get("drops", []):
				dt.append(drop_item as Dictionary)
			mob.drop_table = dt

			if eid == &"guardiao_ancestral":
				var bp_script = load("res://resource/personality/BattlePersonality.gd")
				if bp_script and bp_script.has_method("criar_guardiao_ancestral"):
					mob.battle_personality = bp_script.criar_guardiao_ancestral()
				var bphase_script = load("res://resource/status/BossPhaseData.gd")
				if bphase_script:
					var p2 = bphase_script.new()
					p2.phase_index = 2
					p2.hp_threshold = 0.50
					p2.phase_name = "Frenesi do Santuário"
					p2.dialogue_quote = "🏛️ Despertem, Sentinelas da Rocha! O Santuário não cairá!"
					p2.speed_multiplier = 1.25
					p2.attack_cd_multiplier = 0.70
					p2.hatsu_cd_multiplier = 0.65
					p2.mechanic = bphase_script.MecanicaFase.INVOCAR_MINIONS
					p2.color_modulate = Color(1.8, 0.6, 0.3, 1.0)

					var p3 = bphase_script.new()
					p3.phase_index = 3
					p3.hp_threshold = 0.25
					p3.phase_name = "Sobrecarga de Aura Telúrica"
					p3.dialogue_quote = "⚡ SOBRECARGA ANCESTRAL! Toda a energia das ruínas liberada!"
					p3.speed_multiplier = 1.35
					p3.attack_cd_multiplier = 0.50
					p3.hatsu_cd_multiplier = 0.50
					p3.mechanic = bphase_script.MecanicaFase.AOE_BURST
					p3.color_modulate = Color(2.4, 0.4, 0.4, 1.0)

					mob.boss_phases.clear()
					mob.boss_phases.append(p2)
					mob.boss_phases.append(p3)

			elif eid == &"lider_matilha_quimera":
				var bp_script = load("res://resource/personality/BattlePersonality.gd")
				if bp_script and bp_script.has_method("criar_lider_quimera"):
					mob.battle_personality = bp_script.criar_lider_quimera()

			enemies_registry[eid] = mob


# ------------------------------------------------------------
# 3. INTERFACE DE BUSCA PÚBLICA
# ------------------------------------------------------------
func get_item(id: StringName) -> Resource:
	if items_registry.has(id):
		return items_registry[id]
	if Economy != null and Economy.ITEM_CATALOGO.has(str(id)):
		var cat_info = Economy.ITEM_CATALOGO[str(id)]
		var item_script = load("res://resource/item/ItemData.gd")
		if item_script:
			var it = item_script.new()
			it.item_id = id
			it.nome_item = cat_info.get("nome", str(id))
			it.descricao = cat_info.get("descricao", "")
			it.preco_compra = cat_info.get("preco", 100)
			items_registry[id] = it
			return it
	return null

func obter_item(id: Variant) -> Variant:
	return get_item(StringName(id))

func get_equipment(id: StringName) -> Resource:
	return equipment_registry.get(id, null)

func obter_equipamento(id: Variant) -> Variant:
	return get_equipment(StringName(id))

func get_enemy(id: Variant) -> Resource:
	var sid := StringName(id)
	if enemies_registry.has(sid):
		return enemies_registry[sid]
	var lower_id := StringName(str(id).to_lower())
	if enemies_registry.has(lower_id):
		return enemies_registry[lower_id]
	var target_str := str(id).to_lower()
	for k in enemies_registry.keys():
		var k_str := str(k).to_lower()
		if k_str == target_str or k_str in target_str or target_str in k_str:
			return enemies_registry[k]
	return null

func obter_inimigo(id: Variant) -> Variant:
	return get_enemy(id)

func get_all_items() -> Dictionary:
	return items_registry

func get_all_enemies() -> Dictionary:
	return enemies_registry

