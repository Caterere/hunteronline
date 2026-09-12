class_name HatsuExorcismSystem
extends RefCounted

# ============================================================
# EXORCISMO / ANTI-HATSU — purge de efeitos, marcas e votos.
# ============================================================

enum ExorcismTier {
	BASIC,    # Remove DoT/mark leves
	ADVANCED, # Remove controle e vínculos
	MASTER    # Pode diluir juramento inimigo (custo alto)
}


static func obter_kits() -> Array[Dictionary]:
	return [
		{
			"id": ExorcismTier.BASIC,
			"nome": "Exorcismo Básico",
			"aura_cost": 25.0,
			"cooldown": 12.0,
			"desc": "Remove marcas leves e lingering do alvo aliado.",
			"purge_marks": true,
			"purge_control": false,
			"dilute_vow": false
		},
		{
			"id": ExorcismTier.ADVANCED,
			"nome": "Exorcismo Avançado",
			"aura_cost": 45.0,
			"cooldown": 18.0,
			"desc": "Purge de controle/vínculo + marcas.",
			"purge_marks": true,
			"purge_control": true,
			"dilute_vow": false
		},
		{
			"id": ExorcismTier.MASTER,
			"nome": "Caçador de Hatsu",
			"aura_cost": 70.0,
			"cooldown": 30.0,
			"desc": "Tenta diluir juramento inimigo (40% base).",
			"purge_marks": true,
			"purge_control": true,
			"dilute_vow": true,
			"dilute_chance": 0.40
		}
	]


static func executar(tier: int, caster: Node, target: Node) -> Dictionary:
	if target == null:
		return {"ok": false, "reason": "Alvo inválido"}
	var kit: Dictionary = {}
	for k in obter_kits():
		if int(k["id"]) == tier:
			kit = k
			break
	if kit.is_empty():
		return {"ok": false, "reason": "Kit desconhecido"}

	var purged: Array[String] = []
	if bool(kit.get("purge_marks", false)):
		if target.has_method("clear_nen_marks"):
			target.clear_nen_marks()
			purged.append("marcas")
		elif target.has_meta("nen_marks"):
			target.remove_meta("nen_marks")
			purged.append("marcas")
	if bool(kit.get("purge_control", false)):
		if target.has_method("clear_control_effects"):
			target.clear_control_effects()
			purged.append("controle")
		elif target.has_meta("nen_control"):
			target.remove_meta("nen_control")
			purged.append("controle")

	var diluted := false
	if bool(kit.get("dilute_vow", false)):
		var chance: float = float(kit.get("dilute_chance", 0.4))
		if randf() <= chance:
			if target.has_method("dilute_active_vow"):
				target.dilute_active_vow(0.25)
			elif target.has_meta("vow_power_mult"):
				var cur: float = float(target.get_meta("vow_power_mult", 1.0))
				target.set_meta("vow_power_mult", maxf(0.5, cur - 0.25))
			diluted = true
			purged.append("juramento_diluido")

	return {
		"ok": true,
		"kit": kit["nome"],
		"purged": purged,
		"diluted": diluted,
		"aura_cost": float(kit.get("aura_cost", 0.0)),
		"cooldown": float(kit.get("cooldown", 0.0)),
		"caster": caster
	}
