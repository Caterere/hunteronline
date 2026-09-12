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

const QuestScript = preload("res://scripts/missions/Quest.gd")
const QuestObjectiveScript = preload("res://scripts/missions/QuestObjective.gd")

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


# ------------------------------------------------------------
# 4. CONTRATOS OFICIAIS DA ASSOCIAÇÃO (A5 — tiers B / A / S)
# ------------------------------------------------------------
# access_tier: "B" | "A" | "S"
# seed: determinístico (dia/semana + slot) para rotação estável
static func gerar_contrato_associacao(
	region_id: String,
	player_level: int,
	access_tier: String,
	seed: int,
	is_star_hunter: bool = false,
	contract_id: String = ""
) -> Quest:
	var templates: Array = REGION_TEMPLATES.get(region_id, REGION_TEMPLATES["vale_padokia"])
	if templates.is_empty():
		templates = REGION_TEMPLATES["vale_padokia"]

	var rng := RandomNumberGenerator.new()
	rng.seed = seed if seed != 0 else 1
	var template: Dictionary = templates[rng.randi() % templates.size()]

	var tier := access_tier.to_upper()
	if tier != "B" and tier != "A" and tier != "S":
		tier = "B"

	var q: Quest
	# Star Hunter e S-rank priorizam caça elite; B/A alternam caça/coleta pelo seed.
	if is_star_hunter or tier == "S" or (seed % 2 == 0):
		q = gerar_quest_caca(template, player_level, seed % 7)
	else:
		q = gerar_quest_coleta(template, player_level, seed % 5)

	var mult_gold := 1.0
	var mult_xp := 1.0
	var rep_assoc := 25
	var faction_xp := 40
	match tier:
		"A":
			mult_gold = 1.75
			mult_xp = 1.5
			rep_assoc = 60
			faction_xp = 90
		"S":
			mult_gold = 2.75
			mult_xp = 2.25
			rep_assoc = 120
			faction_xp = 180
		_:
			mult_gold = 1.0
			mult_xp = 1.0
			rep_assoc = 25
			faction_xp = 40

	if is_star_hunter:
		mult_gold *= 1.8
		mult_xp *= 1.6
		rep_assoc = int(rep_assoc * 2.5)
		faction_xp = int(faction_xp * 2.5)
		if not q.objectives.is_empty() and q.objectives[0] != null:
			q.objectives[0].required_amount = maxi(q.objectives[0].required_amount + 4, 8)

	q.reward_gold = int(q.reward_gold * mult_gold)
	q.reward_xp = int(q.reward_xp * mult_xp)
	q.min_level = maxi(q.min_level, _min_level_for_tier(tier, player_level))

	var prefix := "⭐ STAR HUNTER" if is_star_hunter else ("📜 Contrato %s" % tier)
	var base_name := q.quest_name
	if ":" in base_name:
		base_name = base_name.split(":", false, 1)[1].strip_edges()
	q.quest_name = "%s: %s" % [prefix, base_name]
	if is_star_hunter:
		q.description = "Alvo semanal da Associação Hunter (Star Hunter). Requer patente ★+. %s" % q.description
	else:
		q.description = "Contrato oficial da Associação (acesso %s). %s" % [tier, q.description]

	var mat_id := StringName(str(template.get("item_id", &"gosma_slime")))
	var mat_qty := 1
	match tier:
		"A": mat_qty = 2
		"S": mat_qty = 4
		_: mat_qty = 1
	if is_star_hunter:
		mat_qty *= 2
	var reward := QuestReward.new()
	reward.type = QuestReward.Type.ITEM
	reward.item_id = mat_id
	reward.amount = mat_qty
	var rewards: Array[QuestReward] = [reward]
	q.reward_items = rewards

	var cid := contract_id
	if cid.is_empty():
		cid = "assoc_%s_%d_%s" % [tier.to_lower(), seed, "star" if is_star_hunter else "daily"]

	q.custom_data = {
		"association_contract": true,
		"access_tier": tier,
		"is_star_hunter": is_star_hunter,
		"contract_id": cid,
		"reward_rep_associacao": rep_assoc,
		"reward_faction_xp": faction_xp,
		"region_id": region_id,
		"seed": seed,
	}
	return q


static func _min_level_for_tier(tier: String, player_level: int) -> int:
	match tier:
		"A": return maxi(3, player_level - 2)
		"S": return maxi(6, player_level - 1)
		_: return 1


## Gera pool diário determinístico: slots tipicamente 2×B + 1×A + 1×S
static func gerar_pool_contratos_associacao(
	region_id: String,
	player_level: int,
	day_index: int,
	quantidade: int = 4
) -> Array[Quest]:
	var tiers: Array[String] = []
	match quantidade:
		1:
			tiers = ["B"]
		2:
			tiers = ["B", "A"]
		3:
			tiers = ["B", "A", "S"]
		_:
			tiers = ["B", "B", "A", "S"]
			while tiers.size() < quantidade:
				tiers.append("B")
			tiers = tiers.slice(0, quantidade)

	var pool: Array[Quest] = []
	for i in range(tiers.size()):
		var seed := day_index * 1000 + i * 17 + hash(region_id) % 997
		var cid := "daily_%d_%s_%d" % [day_index, tiers[i].to_lower(), i]
		pool.append(gerar_contrato_associacao(region_id, player_level, tiers[i], seed, false, cid))
	return pool


static func gerar_star_hunter_semanal(
	region_id: String,
	player_level: int,
	week_index: int
) -> Quest:
	var seed := week_index * 7771 + hash(region_id) % 4099
	var cid := "weekly_star_%d" % week_index
	# Star Hunter oficial é acesso A (★+) com recompensas de elite
	return gerar_contrato_associacao(region_id, player_level, "A", seed, true, cid)
