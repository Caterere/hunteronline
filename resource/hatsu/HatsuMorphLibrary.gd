class_name HatsuMorphLibrary
extends RefCounted

# ============================================================
# MORPHS / LOADOUTS (estilo ESO) — mesmo Hatsu, 3 faces.
# ============================================================

enum MorphId {
	PVE_BURST,
	PVP_CONTROL,
	SUPORTE
}


static func obter_morphs_padrao() -> Array[Dictionary]:
	return [
		{
			"id": MorphId.PVE_BURST,
			"nome": "Morph PvE Burst",
			"desc": "Mais dano e setup; pior em duelo curto.",
			"damage_mult": 1.18,
			"cooldown_mult": 1.15,
			"aura_mult": 1.10,
			"control_mult": 0.85,
			"mastery_req": 60.0
		},
		{
			"id": MorphId.PVP_CONTROL,
			"nome": "Morph PvP Control",
			"desc": "Mais CC/utility; dano um pouco menor.",
			"damage_mult": 0.88,
			"cooldown_mult": 0.95,
			"aura_mult": 1.05,
			"control_mult": 1.25,
			"mastery_req": 60.0
		},
		{
			"id": MorphId.SUPORTE,
			"nome": "Morph Suporte",
			"desc": "Cura/escudo/buff; ofensiva reduzida.",
			"damage_mult": 0.70,
			"cooldown_mult": 0.90,
			"aura_mult": 1.00,
			"control_mult": 1.10,
			"support_mult": 1.35,
			"mastery_req": 60.0
		}
	]


static func aplicar_morph(hatsu: HatsuData, morph_id: int) -> Dictionary:
	if hatsu == null:
		return {"ok": false, "reason": "Hatsu inválido"}
	var mastery: float = float(hatsu.mastery)
	for m in obter_morphs_padrao():
		if int(m["id"]) != morph_id:
			continue
		if mastery < float(m.get("mastery_req", 60.0)):
			return {"ok": false, "reason": "Requer Maestria %.0f (Domínio)" % float(m["mastery_req"])}
		hatsu.set_meta("active_morph", morph_id)
		hatsu.set_meta("morph_damage_mult", float(m.get("damage_mult", 1.0)))
		hatsu.set_meta("morph_cooldown_mult", float(m.get("cooldown_mult", 1.0)))
		hatsu.set_meta("morph_aura_mult", float(m.get("aura_mult", 1.0)))
		hatsu.set_meta("morph_control_mult", float(m.get("control_mult", 1.0)))
		hatsu.set_meta("morph_support_mult", float(m.get("support_mult", 1.0)))
		return {"ok": true, "morph": m}
	return {"ok": false, "reason": "Morph desconhecido"}
