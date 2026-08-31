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
		
	# Equipamentos
	var equip_script = load("res://resource/item/EquipmentData.gd")
	if equip_script:
		var amuleto = equip_script.new()
		amuleto.item_id = &"amuleto_forca"
		amuleto.nome_item = "Amuleto de Intensificação"
		amuleto.descricao = "Concede +5 de Força e melhora o fluxo de Ko."
		amuleto.bonus_forca = 5
		equipment_registry[&"amuleto_forca"] = amuleto
		items_registry[&"amuleto_forca"] = amuleto


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
			"role": "bruiser",
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
			var dt: Array[Dictionary] = []
			for drop_item in data.get("drops", []):
				dt.append(drop_item as Dictionary)
			mob.drop_table = dt
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

func get_enemy(id: StringName) -> Resource:
	return enemies_registry.get(id, null)

func obter_inimigo(id: Variant) -> Variant:
	return get_enemy(StringName(id))

func get_all_items() -> Dictionary:
	return items_registry

func get_all_enemies() -> Dictionary:
	return enemies_registry

