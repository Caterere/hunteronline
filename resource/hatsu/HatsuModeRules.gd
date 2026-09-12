class_name HatsuModeRules
extends RefCounted

# ============================================================
# REGRAS POR MODO — open world livre; ranked/raid com softcaps.
# ============================================================

enum GameMode {
	OPEN_WORLD,
	RANKED_PVP,
	RAID
}


static func obter_regras(mode: GameMode) -> Dictionary:
	match mode:
		GameMode.OPEN_WORLD:
			return {
				"nome": "Mundo Aberto",
				"max_custom_damage": 250.0,
				"max_credit_deficit": 9999.0,
				"min_vow_credits": 0.0,
				"min_restriction_count": 0,
				"allow_death_penalty": true,
				"desc": "Fantasia total — pague o preço que quiser."
			}
		GameMode.RANKED_PVP:
			return {
				"nome": "Ranked PvP",
				"max_custom_damage": 160.0,
				"max_credit_deficit": 0.0,
				"min_vow_credits": 40.0,
				"min_restriction_count": 1,
				"allow_death_penalty": true,
				"desc": "Déficit zero + pelo menos 1 restrição / 40 cr de juramento."
			}
		GameMode.RAID:
			return {
				"nome": "Raid",
				"max_custom_damage": 200.0,
				"max_credit_deficit": 20.0,
				"min_vow_credits": 25.0,
				"min_restriction_count": 1,
				"allow_death_penalty": false,
				"desc": "Softcap de força; déficit máximo 20; sem pena de morte."
			}
	return obter_regras(GameMode.OPEN_WORLD)


static func validar_hatsu_no_modo(hatsu: HatsuData, mode: GameMode) -> Dictionary:
	if hatsu == null:
		return {"ok": false, "reasons": ["Hatsu nulo"]}
	var rules: Dictionary = obter_regras(mode)
	var reasons: Array[String] = []
	var dmg: float = hatsu.custom_damage if hatsu.custom_damage > 0.0 else hatsu.poder_base
	if dmg > float(rules["max_custom_damage"]):
		reasons.append("Força %.0f > teto do modo %.0f" % [dmg, float(rules["max_custom_damage"])])
	if hatsu.credit_deficit > float(rules["max_credit_deficit"]):
		reasons.append("Déficit %.0f acima do permitido (%.0f)" % [hatsu.credit_deficit, float(rules["max_credit_deficit"])])
	if hatsu.vow_credits < float(rules["min_vow_credits"]):
		reasons.append("Juramentos insuficientes (%.0f / %.0f cr)" % [hatsu.vow_credits, float(rules["min_vow_credits"])])
	var restr_count: int = hatsu.modular_restrictions.size()
	if restr_count < int(rules["min_restriction_count"]):
		reasons.append("Precisa de pelo menos %d restrição(ões)" % int(rules["min_restriction_count"]))
	if not bool(rules["allow_death_penalty"]):
		if HatsuComponentLibrary.RestrictionType.DEATH_PENALTY_ON_MISS in hatsu.modular_restrictions:
			reasons.append("Pena de morte não permitida neste modo")
	return {"ok": reasons.is_empty(), "reasons": reasons, "rules": rules}
