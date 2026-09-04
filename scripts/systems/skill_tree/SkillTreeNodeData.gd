class_name SkillTreeNodeData
extends RefCounted

# ==============================================================================
# HUNTER ONLINE — SKILL TREE NODE DATA (DATA-DRIVEN PROGRESSION)
# ==============================================================================
# Representa a definição de um nó na constelação da Skill Tree do MMORPG:
# - SMALL: Nós menores de atributos (+1% atributos, utilidade básica) — 1 rank
# - MEDIUM: Nós intermediários com escalonamento (+3% atributos) — 1 a 3 ranks
# - MAJOR: Especializações de build (+8% a +12% stats e mecânicas) — 1 rank
# - KEYSTONE: Nós supremos que alteram regras do personagem e tradeoffs — 1 rank
# ==============================================================================

enum NodeType {
	SMALL = 0,
	MEDIUM = 1,
	MAJOR = 2,
	KEYSTONE = 3
}

enum ModifierType {
	FLAT = 0,
	PERCENTAGE = 1,
	MULTIPLICATIVE = 2
}

var id: StringName = &""
var name: String = ""
var description: String = ""
var region_id: StringName = &""
var node_type: NodeType = NodeType.SMALL
var position: Vector2 = Vector2.ZERO
var cost_per_rank: int = 1
var max_rank: int = 1
var prerequisites: Array[StringName] = []
var effects_per_rank: Array[Dictionary] = []
var conditions: Array = []
var tags: Array[String] = []
var icon: String = ""
var is_starting_node: bool = false

func _init(
	p_id: Variant = &"",
	p_name: String = "",
	p_desc: String = "",
	p_region: Variant = &"",
	p_type: NodeType = NodeType.SMALL,
	p_pos: Vector2 = Vector2.ZERO,
	p_cost: int = 1,
	p_max_rank: int = 1,
	p_prereqs: Array = [],
	p_effects: Array = [],
	p_conditions: Array = [],
	p_tags: Array = [],
	p_icon: String = ""
) -> void:
	id = StringName(str(p_id))
	name = p_name
	description = p_desc
	region_id = StringName(str(p_region))
	node_type = p_type
	position = p_pos
	cost_per_rank = p_cost
	max_rank = p_max_rank
	
	prerequisites.clear()
	for pr in p_prereqs:
		prerequisites.append(StringName(str(pr)))

	effects_per_rank.clear()
	for ef in p_effects:
		if ef is Dictionary:
			effects_per_rank.append(ef)

	conditions = p_conditions

	var raw_tags: Array[String] = []
	for tg in p_tags:
		raw_tags.append(str(tg))
	tags = GameplayTags.normalize(raw_tags) if GameplayTags != null else raw_tags
	icon = p_icon

	# Inicializar aliases de compatibilidade com código existente
	_sync_aliases()

var categoria: int = 0

var nome: String:
	get: return name
	set(v): name = v

var descricao: String:
	get: return description
	set(v): description = v

var nivel_max: int:
	get: return max_rank
	set(v): max_rank = v

var custo_pontos: int:
	get: return cost_per_rank
	set(v): cost_per_rank = v

var pre_requisitos: Array:
	get: return prerequisites
	set(v): prerequisites = v

var efeitos: Array:
	get: return effects_per_rank
	set(v): effects_per_rank = v

func _sync_aliases() -> void:
	match String(region_id):
		"body": categoria = 0
		"warrior": categoria = 10
		"nen": categoria = 0
		"specialization": categoria = 11
		_: categoria = 0
	if id == &"first_strike" or id == &"surrounded" or id == &"isolated_target" or id == &"hunters_mark" or id == &"bloodied":
		categoria = 10 # NenSkillTree.Categoria.COMPORTAMENTAL
	elif id == &"ken_mastery" or id == &"in_mastery" or id == &"en_expansion":
		categoria = 11 # NenSkillTree.Categoria.SINERGIA

func is_contextual() -> bool:
	return not conditions.is_empty()

func is_keystone() -> bool:
	return node_type == NodeType.KEYSTONE

func get_total_cost_for_rank(target_rank: int) -> int:
	return cost_per_rank * clamp(target_rank, 1, max_rank)

func has_tag(check_tag: String) -> bool:
	return check_tag in tags
