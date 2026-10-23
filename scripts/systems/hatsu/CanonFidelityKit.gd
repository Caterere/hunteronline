class_name CanonFidelityKit
extends RefCounted

# ============================================================
# Pacote recomendado (relatório D1-B … D8-B)
# ============================================================
#
# D1-B  Chain Jail: elite/boss + Zetsu (já no catálogo)
# D2-A  Godspeed: modo unificado
# D3-C  Emperor Time: esperança_vida + duração longa
# D4-B  Judgement Chain só após Chain Jail no alvo
# D5-B  Crazy Slots: 3 armas (foice/clava/rifle)
# D6-A  Bungee multi-âncora (+ Texture cosmético D6-C)
# D7-C  Pedra hold-to-charge cancelável
# D8-B  Lendários: unlock por saga + vow pesado
#
# ============================================================

## id canônico → arco mínimo (max_arco_desbloqueado / arco_atual)
const LEGENDARY_SAGA_GATE: Dictionary = {
	"netero_guanyin": 6,
	"meruem_aura_devour": 6,
	"chrollo_skill_hunter": 4,
	"chrollo_indoor_fish": 4,
	"feitan_pain_packer": 4,
	"pitou_terpsichora": 6,
	"pitou_doctor_blythe": 6,
	"zeno_dragon_head": 4,
	"zeno_dragon_dive": 4,
	"silva_explosive_orbs": 4,
}

const CHARGE_MAX_SEC: float = 2.0
const CHARGE_MIN_RATIO: float = 0.30
const EMPEROR_ESPERANCA_COST: float = 6.0
const EMPEROR_DURATION_SEC: float = 90.0
const CHAIN_JAIL_MARK_SEC: float = 12.0
const JUDGEMENT_UNMARKED_MULT: float = 0.28


static func is_legendary_id(hatsu_id: String) -> bool:
	return LEGENDARY_SAGA_GATE.has(hatsu_id)


static func resolve_canon_id(hatsu: HatsuData) -> String:
	if hatsu == null:
		return ""
	if not hatsu.hatsu_id.is_empty() and LEGENDARY_SAGA_GATE.has(hatsu.hatsu_id):
		return hatsu.hatsu_id
	var n := hatsu.nome.to_lower()
	if "guanyin" in n or "bodhisattva" in n:
		return "netero_guanyin"
	if "skill hunter" in n or "segredo do roubo" in n:
		return "chrollo_skill_hunter"
	if "devour" in n or "síntese predadora" in n or "sintese predadora" in n:
		return "meruem_aura_devour"
	if "pain packer" in n or "rising sun" in n:
		return "feitan_pain_packer"
	if "terpsichora" in n:
		return "pitou_terpsichora"
	if "doctor blythe" in n or "blythe" in n:
		return "pitou_doctor_blythe"
	if "dragon dive" in n:
		return "zeno_dragon_dive"
	if "dragon head" in n:
		return "zeno_dragon_head"
	if "explosive" in n and "orb" in n:
		return "silva_explosive_orbs"
	return hatsu.hatsu_id


static func can_player_use_legendary(hatsu: HatsuData) -> Dictionary:
	var cid := resolve_canon_id(hatsu)
	if cid.is_empty() or not LEGENDARY_SAGA_GATE.has(cid):
		return {"allowed": true, "reason": "OK", "canon_id": cid}
	var need: int = int(LEGENDARY_SAGA_GATE[cid])
	var arco: int = 1
	if PlayerData != null:
		arco = maxi(int(PlayerData.arco_atual), int(PlayerData.max_arco_desbloqueado))
		if bool(PlayerData.modo_historia_concluido):
			arco = 99
	if arco < need:
		return {
			"allowed": false,
			"reason": "🔒 Lendário: avance até a Saga %d (vow + arco) para usar %s." % [need, hatsu.nome],
			"canon_id": cid,
			"required_arco": need,
			"current_arco": arco
		}
	# Vow pesado: exige despertar Nen + creator desbloqueado (Biscuit/GI)
	if PlayerData != null:
		if not PlayerData.despertou_nen:
			return {"allowed": false, "reason": "🔒 Desperte Nen antes de canalizar Hatsu lendário.", "canon_id": cid}
		if not (PlayerData.hatsu_creation_unlocked or PlayerData.hatsu_desbloqueado):
			return {
				"allowed": false,
				"reason": "🔒 Complete Greed Island / Biscuit — vow para Hatsus lendários.",
				"canon_id": cid
			}
	return {"allowed": true, "reason": "OK", "canon_id": cid}


static func charge_power_mult(charge_sec: float) -> float:
	var ratio: float = clampf(charge_sec / CHARGE_MAX_SEC, 0.0, 1.0)
	return CHARGE_MIN_RATIO + (1.0 - CHARGE_MIN_RATIO) * ratio


static func is_charged_hatsu(hatsu: HatsuData) -> bool:
	if hatsu == null:
		return false
	if hatsu.activation_type == HatsuData.ActivationType.CHARGED:
		return true
	var n := hatsu.nome.to_lower()
	return "jajanken" in n and "pedra" in n


static func is_bungee(hatsu: HatsuData) -> bool:
	if hatsu == null:
		return false
	var n := hatsu.nome.to_lower()
	if "bungee" in n or ("goma" in n and "elást" in n):
		return true
	for t in hatsu.tags:
		if "bungee" in str(t).to_lower() or "elastic" in str(t).to_lower():
			return true
	return false


static func is_chain_jail(hatsu: HatsuData) -> bool:
	if hatsu == null:
		return false
	return "chain jail" in hatsu.nome.to_lower() or "aprisionamento" in hatsu.nome.to_lower()


static func is_judgement(hatsu: HatsuData) -> bool:
	if hatsu == null:
		return false
	return "judgement" in hatsu.nome.to_lower() or "julgamento" in hatsu.nome.to_lower()


static func is_texture_surprise(hatsu: HatsuData) -> bool:
	if hatsu == null:
		return false
	return "texture" in hatsu.nome.to_lower() or "textura" in hatsu.nome.to_lower()


static func is_emperor_time(hatsu: HatsuData) -> bool:
	if hatsu == null:
		return false
	return "emperor time" in hatsu.nome.to_lower() or "tempo do imperador" in hatsu.nome.to_lower()


static func ensure_esperanca_vida() -> float:
	if PlayerData == null:
		return 100.0
	if not PlayerData.attributes.has("esperanca_vida"):
		PlayerData.attributes["esperanca_vida"] = 100.0
	return float(PlayerData.attributes["esperanca_vida"])


static func gastar_esperanca_vida(custo: float) -> bool:
	var cur := ensure_esperanca_vida()
	if cur < custo:
		return false
	PlayerData.attributes["esperanca_vida"] = maxf(0.0, cur - custo)
	return true
