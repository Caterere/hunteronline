class_name RadiantQuestGenerator
extends RefCounted

# ============================================================
# HUNTER ONLINE - RADIANT / PROCEDURAL QUEST GENERATOR
# ============================================================
#
# Gerador dinâmico de missões procedurais, repetíveis e de farm:
# - Missões de Extermínio / Caça (KILL)
# - Missões de Coleta de Drops / Materiais (COLLECT)
# - Missões de Contratos de Elite / Bounties (KILL BOSS/ELITE)
# - Escalonamento de Recompensas (Gold, XP Normal, Nen XP e Itens)
# - Suporte por Região e Nível do Jogador
#
# ============================================================

const QuestScript = preload("res://scripts/Quest.gd")
const QuestObjectiveScript = preload("res://scripts/QuestObjective.gd")

# Catálogo de Modelos de Missões Procedurais por Região
const REGION_TEMPLATES: Dictionary = {
	"lobby": [
		{
			"enemy_id": &"slime",
			"enemy_name": "Slimes da Floresta",
			"item_id": &"gosma_slime",
			"item_name": "Gosmas de Slime",
			"base_kills": 5,
			"base_items": 4,
			"min_level": 1,
			"tag": "Floresta de Zaban"
		},
		{
			"enemy_id": &"rato_gigante",
			"enemy_name": "Ratos Gigantes dos Esgotos",
			"item_id": &"gosma_slime",
			"item_name": "Resíduos Gelatinosos",
			"base_kills": 6,
			"base_items": 5,
			"min_level": 1,
			"tag": "Subterrâneos da Capital"
		},
		{
			"enemy_id": &"ladrao_estrada",
			"enemy_name": "Ladrões de Estrada",
			"item_id": &"ouro_roubado",
			"item_name": "Bolsas de Moedas Roubadas",
			"base_kills": 4,
			"base_items": 3,
			"min_level": 2,
			"tag": "Estradas de Zaban"
		}
	],
	"vale_padokia": [
		{
			"enemy_id": &"slime",
			"enemy_name": "Slimes da Floresta",
			"item_id": &"gosma_slime",
			"item_name": "Gosmas Viscosas",
			"base_kills": 6,
			"base_items": 5,
			"min_level": 1,
			"tag": "Vale de Padokia"
		},
		{
			"enemy_id": &"lobo_selvagem",
			"enemy_name": "Lobos Ferozes das Planícies",
			"item_id": &"couro_lobo",
			"item_name": "Couros de Lobo",
			"base_kills": 5,
			"base_items": 4,
			"min_level": 2,
			"tag": "Planícies de Padokia"
		},
		{
			"enemy_id": &"javali_selvagem",
			"enemy_name": "Javalis dos Bosques",
			"item_id": &"carne_javali",
			"item_name": "Carnes Nobres de Javali",
			"base_kills": 4,
			"base_items": 3,
			"min_level": 3,
			"tag": "Bosque dos Vestígios"
		},
		{
			"enemy_id": &"bandido_renegado",
			"enemy_name": "Bandidos Renegados",
			"item_id": &"ouro_roubado",
			"item_name": "Tesouros de Saque",
			"base_kills": 4,
			"base_items": 3,
			"min_level": 4,
			"tag": "Acampamento Clandestino"
		},
		{
			"enemy_id": &"besouro_blindado",
			"enemy_name": "Besouros Blindados",
			"item_id": &"carapaca_besouro",
			"item_name": "Carapaças Fortificadas",
			"base_kills": 4,
			"base_items": 3,
			"min_level": 4,
			"tag": "Pedreiras do Vale"
		},
		{
			"enemy_id": &"serpente_sombra",
			"enemy_name": "Serpentes das Sombras",
			"item_id": &"presa_serpente",
			"item_name": "Presas Peçonhentas",
			"base_kills": 5,
			"base_items": 4,
			"min_level": 5,
			"tag": "Garganta Sombria"
		},
		{
			"enemy_id": &"fera_magica_bosque",
			"enemy_name": "Bestas Mágicas Menores",
			"item_id": &"couro_besta",
			"item_name": "Couros Espessos de Besta",
			"base_kills": 3,
			"base_items": 2,
			"min_level": 6,
			"tag": "Coração da Floresta"
		}
	],
	"ruinas_zaban": [
		{
			"enemy_id": &"golem_pedra",
			"enemy_name": "Golens de Pedra Ancestrais",
			"item_id": &"nucleo_golem",
			"item_name": "Núcleos Energéticos",
			"base_kills": 3,
			"base_items": 2,
			"min_level": 8,
			"tag": "Santuário das Ruínas"
		},
		{
			"enemy_id": &"urso_caverna",
			"enemy_name": "Ursos das Cavernas",
			"item_id": &"pele_urso",
			"item_name": "Peles Maciças de Urso",
			"base_kills": 3,
			"base_items": 2,
			"min_level": 7,
			"tag": "Grutas Subterrâneas"
		},
		{
			"enemy_id": &"quimera_selvagem",
			"enemy_name": "Quimeras Menores das Cavernas",
			"item_id": &"olho_quimera",
			"item_name": "Olhos Místicos de Quimera",
			"base_kills": 3,
			"base_items": 2,
			"min_level": 10,
			"tag": "Profundezas de Zaban"
		}
	],
	"exame_hunter": [
		{
			"enemy_id": &"candidato_exame",
			"enemy_name": "Candidatos Sabotadores",
			"item_id": &"ouro_roubado",
			"item_name": "Plaquetas de Sabotadores",
			"base_kills": 4,
			"base_items": 3,
			"min_level": 3,
			"tag": "Túnel Subterrâneo"
		},
		{
			"enemy_id": &"criatura_pantanal",
			"enemy_name": "Criaturas do Pantanal Numere",
			"item_id": &"couro_besta",
			"item_name": "Peles do Nevoeiro",
			"base_kills": 5,
			"base_items": 4,
			"min_level": 4,
			"tag": "Pantanal Numere"
		}
	]
}


# ------------------------------------------------------------
# 1. GERAÇÃO DE MISSÕES DE CAÇA (KILL QUEST)
# ------------------------------------------------------------
static func gerar_quest_caca(template: Dictionary, player_level: int = 1, seed_offset: int = 0) -> Quest:
	var q = QuestScript.new()
	var enemy_id: StringName = template.get("enemy_id", &"slime")
	var enemy_name: String = template.get("enemy_name", "Monstros")
	var tag: String = template.get("tag", "Região")
	var kills_req: int = template.get("base_kills", 5) + int(seed_offset % 3)
	
	q.quest_name = "⚔️ Contrato de Caça: %s (%s)" % [enemy_name, tag]
	q.description = "A guilda local e os viajantes emitiram um contrato para conter a superpopulação de %s em %s. Elimine os alvos e garanta a segurança da rota." % [enemy_name, tag]
	q.auto_complete = true
	q.min_level = template.get("min_level", 1)
	
	# Cálculo de Recompensas Escalonadas
	var base_gold: int = 400 + (template.get("min_level", 1) * 150) + (kills_req * 60)
	var base_xp: int = 120 + (template.get("min_level", 1) * 80) + (kills_req * 30)
	q.reward_gold = base_gold
	q.reward_xp = base_xp
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.KILL
	obj.enemy_type = enemy_id
	obj.required_amount = kills_req
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 2. GERAÇÃO DE MISSÕES DE COLETA DE MATERIAIS (COLLECT QUEST)
# ------------------------------------------------------------
static func gerar_quest_coleta(template: Dictionary, player_level: int = 1, seed_offset: int = 0) -> Quest:
	var q = QuestScript.new()
	var item_id: StringName = template.get("item_id", &"gosma_slime")
	var item_name: String = template.get("item_name", "Materiais")
	var tag: String = template.get("tag", "Região")
	var items_req: int = template.get("base_items", 4) + int(seed_offset % 2)
	
	q.quest_name = "📦 Coleta de Suprimentos: %s (%s)" % [item_name, tag]
	q.description = "Mercadores e artesãos da guilda precisam de %s obtidos de criaturas em %s para confeccionar equipamentos e itens de sobrevivência." % [item_name, tag]
	q.auto_complete = true
	q.min_level = template.get("min_level", 1)
	
	var base_gold: int = 500 + (template.get("min_level", 1) * 180) + (items_req * 80)
	var base_xp: int = 140 + (template.get("min_level", 1) * 90) + (items_req * 40)
	q.reward_gold = base_gold
	q.reward_xp = base_xp
	
	var obj = QuestObjectiveScript.new()
	obj.type = QuestObjectiveScript.Type.COLLECT
	obj.item_id = item_id
	obj.required_amount = items_req
	
	var objs: Array[QuestObjective] = [obj]
	q.objectives = objs
	return q


# ------------------------------------------------------------
# 3. GERAÇÃO DE POOL ROTATIVO DE RADIANT QUESTS POR REGIÃO
# ------------------------------------------------------------
static func gerar_pool_radiant_quests(region_id: String, player_level: int = 1, quantidade: int = 4) -> Array[Quest]:
	var pool: Array[Quest] = []
	var templates: Array = REGION_TEMPLATES.get(region_id, REGION_TEMPLATES["vale_padokia"])
	
	for i in range(quantidade):
		var t_idx = i % templates.size()
		var template: Dictionary = templates[t_idx]
		
		var q: Quest = null
		if i % 2 == 0:
			q = gerar_quest_caca(template, player_level, i)
		else:
			q = gerar_quest_coleta(template, player_level, i)
			
		if q != null:
			pool.append(q)
			
	return pool
