class_name RegionDefinition
extends Resource

# ============================================================
# HUNTER ONLINE - REGION DEFINITION (DATA-DRIVEN WORLD REGION)
# ============================================================
#
# Estrutura orientada a dados que define formalmente cada região
# conectada do mundo MMORPG:
# - Identificadores e metadados visuais
# - Cena associada e spawn padrão
# - Saídas físicas e regiões vizinhas conectadas (Rotas)
# - Tabelas de presença (NPCs e Inimigos)
# - Requisitos de história e desbloqueio
#
# ============================================================

@export var id: StringName = &"lobby"
@export var display_name: String = "Capital dos Caçadores"
@export var subtitle: String = "Hunter Plaza — Hub Central"
@export var saga_id: int = 0
@export_file("*.tscn") var scene_path: String = "res://world/lobby.tscn"
@export var default_spawn: StringName = &"default"
@export var unlocked: bool = true

# Saídas e Conexões Físicas
# Cada item: {"portal_id": StringName, "target_region": StringName, "target_spawn": StringName, "portal_name": String, "required_stage": int}
@export var exits: Array[Dictionary] = []
@export var connected_regions: Array[StringName] = []

# População e Ecologia
# Cada item: {"enemy_id": String, "level_min": int, "level_max": int, "sub_zone": String, "density": float}
@export var enemy_spawns: Array[Dictionary] = []
# Cada item: {"npc_id": String, "role": String, "sub_zone": String, "pos": Vector2}
@export var npc_spawns: Array[Dictionary] = []

# Quests e História
@export var quest_ids: Array[String] = []
@export var story_requirements: Dictionary = {}


func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"subtitle": subtitle,
		"saga_id": saga_id,
		"scene_path": scene_path,
		"default_spawn": String(default_spawn),
		"unlocked": unlocked,
		"exits": exits,
		"connected_regions": connected_regions.map(func(r): return String(r)),
		"enemy_spawns": enemy_spawns,
		"npc_spawns": npc_spawns,
		"quest_ids": quest_ids,
		"story_requirements": story_requirements
	}


static func from_dict(data: Dictionary) -> Resource:
	var script_res = load("res://resource/world/RegionDefinition.gd") as GDScript
	var def = script_res.new()
	def.id = StringName(data.get("id", "lobby"))
	def.display_name = data.get("display_name", "Região")
	def.subtitle = data.get("subtitle", "")
	def.saga_id = int(data.get("saga_id", 0))
	def.scene_path = data.get("scene_path", "res://world/lobby.tscn")
	def.default_spawn = StringName(data.get("default_spawn", "default"))
	def.unlocked = bool(data.get("unlocked", true))
	
	def.exits.clear()
	for ex in data.get("exits", []):
		if ex is Dictionary:
			def.exits.append(ex)
			
	def.connected_regions.clear()
	for cr in data.get("connected_regions", []):
		def.connected_regions.append(StringName(cr))
		
	def.enemy_spawns.clear()
	for es in data.get("enemy_spawns", []):
		if es is Dictionary:
			def.enemy_spawns.append(es)
			
	def.npc_spawns.clear()
	for ns in data.get("npc_spawns", []):
		if ns is Dictionary:
			def.npc_spawns.append(ns)
			
	def.quest_ids.clear()
	for q in data.get("quest_ids", []):
		def.quest_ids.append(StringName(q))
		
	def.story_requirements = data.get("story_requirements", {}).duplicate()
	return def
