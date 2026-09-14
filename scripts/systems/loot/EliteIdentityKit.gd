class_name EliteIdentityKit
extends RefCounted
## Elites nomeados por saga: HP/skills/loot densos, spawns nos hubs.

const ENEMY_SCENE := "res://scripts/systems/EnemySystem/Enemy.tscn"

## saga_id (1–9) → lista de specs de elite.
const ELITES_POR_SAGA := {
	1: [ # Exame
		{
			"id": "elite_hisoka_sombra",
			"nome": "Hisoka — Sombra do Exame",
			"base_tres": "res://resource/status/enemies/candidato_exame.tres",
			"hatsu_name": "Bungee Gum",
			"level_bonus": 3,
			"hp_mult": 2.4,
			"str_mult": 1.55,
			"def_mult": 1.35,
			"xp_mult": 2.8,
			"offset": Vector2(420, -80),
		},
		{
			"id": "elite_illumi_vigilante",
			"nome": "Illumi — Vigilante",
			"base_tres": "res://resource/status/enemies/candidato_exame.tres",
			"hatsu_name": "Agulhas de Manipulação",
			"level_bonus": 2,
			"hp_mult": 2.1,
			"str_mult": 1.4,
			"def_mult": 1.5,
			"xp_mult": 2.4,
			"offset": Vector2(-380, 120),
		},
	],
	2: [ # Kukuroo
		{
			"id": "elite_mordomo_porta",
			"nome": "Mordomo da Porta de Teste",
			"base_tres": "res://resource/status/enemies/mordomo_zoldyck.tres",
			"hatsu_name": "Canhão de Aura",
			"level_bonus": 3,
			"hp_mult": 2.5,
			"str_mult": 1.6,
			"def_mult": 1.55,
			"xp_mult": 2.7,
			"offset": Vector2(360, 40),
		},
	],
	3: [ # Arena
		{
			"id": "elite_campeao_floor",
			"nome": "Campeão do Floor 200",
			"base_tres": "res://resource/status/enemies/lutador_arena.tres",
			"hatsu_name": "Impacto de Arena",
			"level_bonus": 4,
			"hp_mult": 2.6,
			"str_mult": 1.7,
			"def_mult": 1.4,
			"xp_mult": 2.9,
			"offset": Vector2(380, -20),
		},
	],
	4: [ # Yorknew
		{
			"id": "elite_uvogin_eco",
			"nome": "Uvogin — Eco da Máfia",
			"base_tres": "res://resource/status/enemies/membro_trupe.tres",
			"hatsu_name": "Big Bang Impact",
			"level_bonus": 4,
			"hp_mult": 2.8,
			"str_mult": 1.8,
			"def_mult": 1.4,
			"xp_mult": 3.0,
			"offset": Vector2(360, 40),
		},
	],
	5: [ # Greed Island
		{
			"id": "elite_bomber_eco",
			"nome": "Genthru — Eco Bomber",
			"base_tres": "res://resource/status/enemies/bomber_greed.tres",
			"hatsu_name": "Little Flower",
			"level_bonus": 4,
			"hp_mult": 2.5,
			"str_mult": 1.65,
			"def_mult": 1.35,
			"xp_mult": 2.8,
			"offset": Vector2(320, -50),
		},
	],
	6: [ # Formigas
		{
			"id": "elite_youpi_proto",
			"nome": "Youpi — Protótipo",
			"base_tres": "res://resource/status/enemies/formiga_soldado.tres",
			"hatsu_name": "Metamorfose Explosiva",
			"level_bonus": 5,
			"hp_mult": 3.2,
			"str_mult": 1.9,
			"def_mult": 1.6,
			"xp_mult": 3.5,
			"offset": Vector2(480, -40),
		},
		{
			"id": "elite_neferpitou_eco",
			"nome": "Neferpitou — Eco",
			"base_tres": "res://resource/status/enemies/formiga_lider.tres",
			"hatsu_name": "Terpsichora",
			"level_bonus": 6,
			"hp_mult": 2.6,
			"str_mult": 1.7,
			"def_mult": 1.45,
			"xp_mult": 3.8,
			"offset": Vector2(-420, 60),
		},
	],
	7: [ # Associação
		{
			"id": "elite_guarda_real_nomeado",
			"nome": "Capitão da Guarda Real",
			"base_tres": "res://resource/status/enemies/guarda_real.tres",
			"hatsu_name": "Protocolo Cerimonial",
			"level_bonus": 4,
			"hp_mult": 2.7,
			"str_mult": 1.65,
			"def_mult": 1.7,
			"xp_mult": 3.2,
			"offset": Vector2(400, 0),
		},
	],
	8: [ # Continente Negro
		{
			"id": "elite_hellbell_eco",
			"nome": "Eco de Hellbell",
			"base_tres": "res://resource/status/enemies/criatura_pantanal.tres",
			"hatsu_name": "Raízes Devoradoras",
			"level_bonus": 5,
			"hp_mult": 2.9,
			"str_mult": 1.75,
			"def_mult": 1.5,
			"xp_mult": 3.3,
			"offset": Vector2(300, -40),
		},
	],
	9: [ # Black Whale
		{
			"id": "elite_besta_principe",
			"nome": "Besta do Príncipe",
			"base_tres": "res://resource/status/enemies/nen_beast_principe.tres",
			"hatsu_name": "Visão do Futuro",
			"level_bonus": 5,
			"hp_mult": 2.8,
			"str_mult": 1.7,
			"def_mult": 1.55,
			"xp_mult": 3.4,
			"offset": Vector2(340, 20),
		},
	],
}


static func densify_saga(mapa: Node2D, saga_id: int, anchor: Vector2 = Vector2.ZERO) -> int:
	if mapa == null:
		return 0
	if not ELITES_POR_SAGA.has(saga_id):
		return 0
	var spawned := 0
	var list: Array = ELITES_POR_SAGA[saga_id]
	for i in range(list.size()):
		var spec = list[i]
		if typeof(spec) != TYPE_DICTIONARY:
			continue
		if _spawn_elite(mapa, spec as Dictionary, anchor, i):
			spawned += 1
	return spawned


static func criar_enemy_data(spec: Dictionary) -> EnemyData:
	var path := String(spec.get("base_tres", ""))
	var base: EnemyData = null
	if ResourceLoader.exists(path):
		base = load(path) as EnemyData
	if base == null:
		base = EnemyData.new()
		base.enemy_id = &"candidato_exame"
		base.enemy_name = "Candidato"
		base.max_health = 80
		base.strength = 12
		base.defense = 6
		base.level = 5
		base.xp_reward = 40
	var d: EnemyData = base.duplicate(true) as EnemyData
	if d == null:
		d = EnemyData.new()
	var base_id := String(base.enemy_id)
	if base_id.is_empty():
		base_id = path.get_file().get_basename()
	d.enemy_id = StringName(String(spec.get("id", base_id + "_elite")))
	d.enemy_name = String(spec.get("nome", "Elite " + base.enemy_name))
	d.is_elite = true
	d.is_boss = false
	d.npc_tier = EnemyData.NPCTier.TIER_2_SPECIAL
	d.level = int(base.level) + int(spec.get("level_bonus", 2))
	d.max_health = int(round(float(base.max_health) * float(spec.get("hp_mult", 2.0))))
	d.strength = int(round(float(base.strength) * float(spec.get("str_mult", 1.4))))
	d.defense = int(round(float(base.defense) * float(spec.get("def_mult", 1.3))))
	d.xp_reward = int(round(float(base.xp_reward) * float(spec.get("xp_mult", 2.5))))
	var hatsu := String(spec.get("hatsu_name", ""))
	if not hatsu.is_empty():
		d.hatsu_name = hatsu
	d.drop_table.clear()
	for entry in LootIdentityKit.tabela_elite_de(base_id):
		if typeof(entry) == TYPE_DICTIONARY:
			d.drop_table.append(entry as Dictionary)
	return d


static func listar_elites(saga_id: int) -> Array:
	if not ELITES_POR_SAGA.has(saga_id):
		return []
	return (ELITES_POR_SAGA[saga_id] as Array).duplicate(true)


static func _spawn_elite(mapa: Node2D, spec: Dictionary, anchor: Vector2, index: int) -> bool:
	var eid := String(spec.get("id", "elite_%d" % index))
	var node_name := "Elite_%s" % eid
	if mapa.get_node_or_null(node_name) != null:
		return false
	var data := criar_enemy_data(spec)
	if data == null:
		return false
	var scn = load(ENEMY_SCENE)
	if scn == null:
		return false
	var enemy = scn.instantiate()
	if enemy == null:
		return false
	enemy.name = node_name
	var offset: Vector2 = spec.get("offset", Vector2(200, 0))
	if typeof(offset) != TYPE_VECTOR2:
		offset = Vector2(200, 0)
	offset += Vector2(index * 48, index * 24)
	enemy.position = anchor + offset
	enemy.add_to_group("enemy")
	enemy.add_to_group("enemies")
	var es = enemy.get_node_or_null("EnemySystem")
	if es != null:
		if "enemy_data" in es:
			es.enemy_data = data
		if "enemy_id" in es:
			es.enemy_id = data.enemy_id
		if "enemy_name" in es:
			es.enemy_name = data.enemy_name
		if "is_mission_enemy" in es:
			es.is_mission_enemy = false
	mapa.add_child(enemy)
	return true
