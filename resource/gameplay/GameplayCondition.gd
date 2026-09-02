class_name GameplayCondition
extends Resource

## Condição declarativa reutilizável para Hatsu, Skill Tree, quests, inimigos,
## bosses e eventos. O consumidor fornece o contexto atual e continua sendo o
## dono de seu estado.

enum Type {
	PLAYER_HP_BELOW,
	NO_DAMAGE_FOR_SECONDS,
	TARGET_MARKED,
	ENEMIES_NEARBY_AT_LEAST,
	SINGLE_TARGET,
	TARGET_HP_BELOW,
	PLAYER_IN_EN,
	PLAYER_STEALTH,
	HATSU_ACTIVE,
	SKILL_UNLOCKED,
	TARGET_HAS_STATE,
	TARGET_WEAK_POINT_REVEALED,
	HATSU_HAS_TAG
}

@export var condition_type: Type = Type.PLAYER_HP_BELOW
@export var threshold: float = 0.5
@export_range(0, 99, 1) var required_count: int = 1
@export var required_id: StringName = &""
@export var required_tag: String = ""
@export var inverted: bool = false


func evaluate(context: Dictionary) -> Dictionary:
	var actual: Variant = null
	var met := false
	match condition_type:
		Type.PLAYER_HP_BELOW:
			actual = float(context.get("player_hp_percent", 1.0))
			met = actual < threshold
		Type.NO_DAMAGE_FOR_SECONDS:
			actual = float(context.get("seconds_since_damage", 0.0))
			met = actual >= threshold
		Type.TARGET_MARKED:
			actual = bool(context.get("target_marked", false))
			met = actual
		Type.ENEMIES_NEARBY_AT_LEAST:
			actual = int(context.get("nearby_enemy_count", 0))
			met = actual >= required_count
		Type.SINGLE_TARGET:
			actual = int(context.get("nearby_enemy_count", 0))
			met = actual == 1
		Type.TARGET_HP_BELOW:
			actual = float(context.get("target_hp_percent", 1.0))
			met = actual < threshold
		Type.PLAYER_IN_EN:
			actual = bool(context.get("player_in_en", false))
			met = actual
		Type.PLAYER_STEALTH:
			actual = bool(context.get("player_stealth", false))
			met = actual
		Type.HATSU_ACTIVE:
			actual = context.get("active_hatsu_ids", [])
			met = _contains_id(actual, required_id)
		Type.SKILL_UNLOCKED:
			actual = context.get("unlocked_skill_ids", [])
			met = _contains_id(actual, required_id)
		Type.TARGET_HAS_STATE:
			actual = context.get("target_states", [])
			met = _contains_id(actual, required_id)
		Type.TARGET_WEAK_POINT_REVEALED:
			actual = bool(context.get("target_weak_point_revealed", false))
			met = actual
		Type.HATSU_HAS_TAG:
			actual = context.get("hatsu_tags", [])
			met = GameplayTags.has_tag(actual, required_tag)

	if inverted:
		met = not met
	return {"met": met, "type": condition_type, "actual": actual}


func _contains_id(entries: Array, id: StringName) -> bool:
	for entry in entries:
		if StringName(str(entry)) == id:
			return true
	return false


func to_dict() -> Dictionary:
	return {
		"type": int(condition_type),
		"threshold": threshold,
		"required_count": required_count,
		"required_id": String(required_id),
		"required_tag": required_tag,
		"inverted": inverted
	}


static func from_dict(data: Dictionary) -> GameplayCondition:
	var condition := GameplayCondition.new()
	condition.condition_type = int(data.get("type", Type.PLAYER_HP_BELOW)) as Type
	condition.threshold = float(data.get("threshold", 0.5))
	condition.required_count = int(data.get("required_count", 1))
	condition.required_id = StringName(data.get("required_id", ""))
	condition.required_tag = GameplayTags.canonicalize(str(data.get("required_tag", "")))
	condition.inverted = bool(data.get("inverted", false))
	return condition
