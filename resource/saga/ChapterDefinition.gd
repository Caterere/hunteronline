class_name ChapterDefinition
extends Resource

# ============================================================
# HUNTER ONLINE — CHAPTER DEFINITION (FASE L)
# ============================================================
#
# Estrutura declarativa de dados para um capítulo individual de saga.
# Permite definir missões principais, secundárias, chefes, cutscenes,
# requisitos de gating e consequências sem hardcode.
# ============================================================

@export var chapter_index: int = 1
@export var title: String = ""
@export_multiline var synopsis: String = ""

# Quests e Conteúdo
@export var main_quest_id: String = ""
@export var side_quest_ids: Array = []
@export var npc_stories: Array = []
@export var boss_id: String = ""
@export var cutscene_id: String = ""

# Recompensas do Capítulo: {"xp": 1000, "gold": 5000, "items": ["pocao_cura"]}
@export var rewards: Dictionary = {}

# Gating: Lista de requisitos para desbloquear/iniciar o capítulo
# Exemplo: [{"type": "level", "value": 25}, {"type": "quest_completed", "value": "arco1_etapa2"}]
@export var gating_requirements: Array = []

# Consequências narrativas/mundiais ao concluir o capítulo
# Exemplo: [{"type": "world_flag", "flag": "vila_liberada", "value": true}]
@export var consequences: Array = []

# Flags de categorização: story, combat, investigation, training, climax
@export var flags: Array = []


func _init(
	p_index: int = 1,
	p_title: String = "",
	p_synopsis: String = "",
	p_main_quest: String = ""
) -> void:
	chapter_index = p_index
	title = p_title
	synopsis = p_synopsis
	main_quest_id = p_main_quest


func to_dict() -> Dictionary:
	return {
		"chapter_index": chapter_index,
		"title": title,
		"synopsis": synopsis,
		"main_quest_id": main_quest_id,
		"side_quest_ids": side_quest_ids.duplicate(),
		"npc_stories": npc_stories.duplicate(),
		"boss_id": boss_id,
		"cutscene_id": cutscene_id,
		"rewards": rewards.duplicate(),
		"gating_requirements": gating_requirements.duplicate(),
		"consequences": consequences.duplicate(),
		"flags": flags.map(func(f): return String(f))
	}


static func from_dict(data: Dictionary) -> Resource:
	var def = (load("res://resource/saga/ChapterDefinition.gd") as GDScript).new()
	def.chapter_index = int(data.get("chapter_index", 1))
	def.title = str(data.get("title", ""))
	def.synopsis = str(data.get("synopsis", ""))
	def.main_quest_id = str(data.get("main_quest_id", ""))
	
	def.side_quest_ids.clear()
	for sq in data.get("side_quest_ids", []):
		def.side_quest_ids.append(str(sq))
		
	def.npc_stories.clear()
	for ns in data.get("npc_stories", []):
		def.npc_stories.append(str(ns))
		
	def.boss_id = str(data.get("boss_id", ""))
	def.cutscene_id = str(data.get("cutscene_id", ""))
	def.rewards = (data.get("rewards", {}) as Dictionary).duplicate()
	def.gating_requirements = (data.get("gating_requirements", []) as Array).duplicate(true)
	def.consequences = (data.get("consequences", []) as Array).duplicate(true)
	
	def.flags.clear()
	for f in data.get("flags", []):
		def.flags.append(StringName(f))
		
	return def
