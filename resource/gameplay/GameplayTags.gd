class_name GameplayTags
extends RefCounted

## Utilitário canônico de tags de gameplay.
## Tags mantêm Hatsu, combate, equipamentos e futuras Skill Trees desacoplados
## de enums rígidos. Exemplos: "projectile", "offensive", "long_range".

static func canonicalize(tag: String) -> String:
	var normalized := tag.strip_edges().to_lower().replace("-", "_").replace(" ", "_")
	match normalized:
		"aoe", "area", "area_damage":
			return "area_of_effect"
		"single", "single_target_damage":
			return "single_target"
		"longrange", "long_distance":
			return "long_range"
	return normalized


static func normalize(tags: Array) -> Array[String]:
	var result: Array[String] = []
	for raw_tag in tags:
		var tag := canonicalize(str(raw_tag))
		if not tag.is_empty() and tag not in result:
			result.append(tag)
	return result


static func has_tag(tags: Array, required_tag: String) -> bool:
	return canonicalize(required_tag) in normalize(tags)


static func has_all(tags: Array, required_tags: Array) -> bool:
	for required_tag in required_tags:
		if not has_tag(tags, str(required_tag)):
			return false
	return true


static func has_any(tags: Array, required_tags: Array) -> bool:
	for required_tag in required_tags:
		if has_tag(tags, str(required_tag)):
			return true
	return false
