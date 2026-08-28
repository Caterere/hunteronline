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
				
	# Se slime não estiver em arquivo, registrar programaticamente
	if not enemies_registry.has(&"slime"):
		var enemy_data_script = load("res://resource/status/EnemyData.gd")
		if enemy_data_script:
			var slime = enemy_data_script.new()
			slime.enemy_id = &"slime"
			slime.enemy_name = "Slime da Floresta"
			slime.max_health = 60
			slime.defense = 2
			slime.strength = 8
			slime.xp_reward = 35
			enemies_registry[&"slime"] = slime


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

