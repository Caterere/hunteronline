class_name SagaDefinition
extends Resource

# ============================================================
# HUNTER ONLINE — SAGA DEFINITION (FASE L)
# ============================================================
#
# Recurso central declarativo para cadastro de Novas Sagas.
# Suporta sagas canônicas e expansões live-content modulares.
# Permite adicionar arcos de história, capítulos, regiões e inimigos
# sem modificar o código interno do StoryManager ou do motor.
# ============================================================

@export var saga_id: StringName = &""
@export var order_index: int = 10
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var recommended_level: Vector2i = Vector2i(1, 1000)
@export var difficulty: int = 1 # 1: Iniciante, 2: Intermediário, 3: Hunter Pro, 4: Calamidade
@export var is_canonical: bool = false

# Capítulos da Saga
@export var chapters: Array[Resource] = []

# Regiões, Entidades e Conteúdo Associado
@export var regions: Array = []
@export var characters: Array = []
@export var enemies: Array = []
@export var bosses: Array = []

# Recompensas Globais ao Concluir a Saga
@export var rewards: Dictionary = {} # {"xp": 50000, "gold": 200000, "items": ["licenca_dupla"]}
@export var reputations: Dictionary = {} # {"associacao_hunter": 500}
@export var titles: Array = [] # ["Explorador Lendário"]
@export var events: Array = []

# Requisitos Globais de Acesso à Saga
@export var requirements: Array = []

# Flags de Classificação (L32): story, side, secret, event, endgame, coop, solo, temporary
@export var flags: Array = [&"story", &"coop"]


func _init(
	p_id: StringName = &"",
	p_order: int = 10,
	p_name: String = "",
	p_desc: String = "",
	p_lvl_range: Vector2i = Vector2i(1, 1000)
) -> void:
	saga_id = p_id
	order_index = p_order
	display_name = p_name
	description = p_desc
	recommended_level = p_lvl_range


func add_chapter(chapter: Resource) -> void:
	if chapter == null:
		return
	chapters.append(chapter)


func get_total_chapters() -> int:
	return max(1, chapters.size())


func get_chapter(index: int) -> Resource:
	for c in chapters:
		if int(c.get("chapter_index")) == index:
			return c
	if index >= 1 and index <= chapters.size():
		return chapters[index - 1]
	return null


func has_flag(flag: StringName) -> bool:
	return flags.has(flag)


func to_dict() -> Dictionary:
	var caps_serialized: Array = []
	for c in chapters:
		if c != null:
			caps_serialized.append(c.to_dict())
			
	return {
		"saga_id": String(saga_id),
		"order_index": order_index,
		"display_name": display_name,
		"description": description,
		"recommended_level": [recommended_level.x, recommended_level.y],
		"difficulty": difficulty,
		"is_canonical": is_canonical,
		"chapters": caps_serialized,
		"regions": regions.duplicate(),
		"characters": characters.duplicate(),
		"enemies": enemies.duplicate(),
		"bosses": bosses.duplicate(),
		"rewards": rewards.duplicate(),
		"reputations": reputations.duplicate(),
		"titles": titles.duplicate(),
		"events": events.duplicate(),
		"requirements": requirements.duplicate(true),
		"flags": flags.map(func(f): return String(f))
	}


const ChapterDefinitionScript = preload("res://resource/saga/ChapterDefinition.gd")


static func from_dict(data: Dictionary) -> Resource:
	var def = (load("res://resource/saga/SagaDefinition.gd") as GDScript).new()
	def.saga_id = StringName(data.get("saga_id", ""))
	def.order_index = int(data.get("order_index", 10))
	def.display_name = str(data.get("display_name", ""))
	def.description = str(data.get("description", ""))
	
	var lvl = data.get("recommended_level", [1, 1000])
	if lvl is Array and lvl.size() >= 2:
		def.recommended_level = Vector2i(int(lvl[0]), int(lvl[1]))
		
	def.difficulty = int(data.get("difficulty", 1))
	def.is_canonical = bool(data.get("is_canonical", false))
	
	def.chapters.clear()
	for c_data in data.get("chapters", []):
		if c_data is Dictionary:
			def.chapters.append(ChapterDefinitionScript.from_dict(c_data))
			
	def.regions.clear()
	for r in data.get("regions", []):
		def.regions.append(str(r))
		
	def.characters.clear()
	for ch in data.get("characters", []):
		def.characters.append(str(ch))
		
	def.enemies.clear()
	for en in data.get("enemies", []):
		def.enemies.append(str(en))
		
	def.bosses.clear()
	for b in data.get("bosses", []):
		def.bosses.append(str(b))
		
	def.rewards = (data.get("rewards", {}) as Dictionary).duplicate()
	def.reputations = (data.get("reputations", {}) as Dictionary).duplicate()
	
	def.titles.clear()
	for t in data.get("titles", []):
		def.titles.append(str(t))
		
	def.events.clear()
	for ev in data.get("events", []):
		def.events.append(str(ev))
		
	def.requirements = (data.get("requirements", []) as Array).duplicate(true)
	
	def.flags.clear()
	for f in data.get("flags", []):
		def.flags.append(StringName(f))
		
	return def
