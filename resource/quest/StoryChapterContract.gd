class_name StoryChapterContract
extends RefCounted

# ============================================================
# HUNTER ONLINE — CONTRATO DE CAPÍTULO (FASE 0)
# ============================================================
#
# Metadado leve sobre cada etapa do CanonQuestCatalog.
# NÃO altera resource_path / quest_states — só preenche Quest.custom_data.
#
# Campos:
#   act_id           — agrupador narrativo (4–8 capítulos)
#   act_name         — rótulo legível do ato
#   narrative_role   — setup | bond | prep | prova | revelacao | climax | aftermath
#   playable_verb    — visit | kill | investigate | stealth | persuasion | collect | mixed
#   contract_version — "phase0"
# ============================================================

const ROLE_SETUP := "setup"
const ROLE_BOND := "bond"
const ROLE_PREP := "prep"
const ROLE_PROVA := "prova"
const ROLE_REVELACAO := "revelacao"
const ROLE_CLIMAX := "climax"
const ROLE_AFTERMATH := "aftermath"

const CONTRACT_VERSION := "phase0"


## Aplica metadado de ato/papel na quest. Idempotente.
static func aplicar(quest: Quest, arco: int, etapa: int) -> void:
	if quest == null:
		return
	var meta: Dictionary = obter_meta(arco, etapa)
	if meta.is_empty():
		meta = _meta_fallback(arco, etapa, quest)
	for k in meta.keys():
		quest.custom_data[k] = meta[k]
	quest.custom_data["contract_version"] = CONTRACT_VERSION
	quest.custom_data["arco"] = arco
	quest.custom_data["etapa"] = etapa
	if not quest.custom_data.has("playable_verb"):
		quest.custom_data["playable_verb"] = _infer_verb(quest)


static func obter_meta(arco: int, etapa: int) -> Dictionary:
	match arco:
		1:
			return _meta_exame(etapa)
		_:
			return _meta_saga_generica(arco, etapa)


## Totais espelhados de CanonQuestCatalog (evita dependência circular de class_name).
const TOTAIS_POR_ARCO := {
	1: 24, 2: 18, 3: 26, 4: 34, 5: 36, 6: 48, 7: 20, 8: 22, 9: 26,
}


static func total_etapas_arco(arco: int) -> int:
	return int(TOTAIS_POR_ARCO.get(arco, 1))


static func listar_atos_saga(arco: int) -> Array[Dictionary]:
	match arco:
		1:
			return [
				{"act_id": "exame_maratona", "act_name": "Maratona de Zaban", "etapas": Vector2i(1, 5)},
				{"act_id": "exame_numere", "act_name": "Pantanal Numere", "etapas": Vector2i(6, 10)},
				{"act_id": "exame_gourmet", "act_name": "Prova Gourmet", "etapas": Vector2i(11, 13)},
				{"act_id": "exame_dirigivel", "act_name": "Dirigível da Associação", "etapas": Vector2i(14, 15)},
				{"act_id": "exame_trick_tower", "act_name": "Trick Tower", "etapas": Vector2i(16, 19)},
				{"act_id": "exame_zevil", "act_name": "Ilha Zevil", "etapas": Vector2i(20, 23)},
				{"act_id": "exame_climax", "act_name": "Prova Final", "etapas": Vector2i(24, 24)},
			]
		_:
			var total: int = total_etapas_arco(arco)
			return [
				{"act_id": "saga%d_inicio" % arco, "act_name": "Abertura", "etapas": Vector2i(1, mini(4, total))},
				{"act_id": "saga%d_meio" % arco, "act_name": "Desenvolvimento", "etapas": Vector2i(mini(5, total), maxi(1, total - 3))},
				{"act_id": "saga%d_climax" % arco, "act_name": "Clímax", "etapas": Vector2i(maxi(1, total - 2), total)},
			]


static func _meta_exame(etapa: int) -> Dictionary:
	match etapa:
		1:
			return _pack("exame_maratona", "Maratona de Zaban", ROLE_SETUP, "persuasion")
		2, 3:
			return _pack("exame_maratona", "Maratona de Zaban", ROLE_BOND, "visit")
		4:
			return _pack("exame_maratona", "Maratona de Zaban", ROLE_PROVA, "kill")
		5:
			return _pack("exame_maratona", "Maratona de Zaban", ROLE_SETUP, "visit")
		6:
			return _pack("exame_numere", "Pantanal Numere", ROLE_PREP, "visit")
		7:
			return _pack("exame_numere", "Pantanal Numere", ROLE_REVELACAO, "investigate")
		8, 10:
			return _pack("exame_numere", "Pantanal Numere", ROLE_PROVA, "kill")
		9:
			return _pack("exame_numere", "Pantanal Numere", ROLE_BOND, "visit")
		11:
			return _pack("exame_gourmet", "Prova Gourmet", ROLE_PREP, "visit")
		12:
			return _pack("exame_gourmet", "Prova Gourmet", ROLE_PROVA, "kill")
		13:
			return _pack("exame_gourmet", "Prova Gourmet", ROLE_PROVA, "collect")
		14, 15:
			return _pack("exame_dirigivel", "Dirigível da Associação", ROLE_SETUP, "visit")
		16:
			return _pack("exame_trick_tower", "Trick Tower", ROLE_REVELACAO, "investigate")
		17:
			return _pack("exame_trick_tower", "Trick Tower", ROLE_PROVA, "persuasion")
		18:
			return _pack("exame_trick_tower", "Trick Tower", ROLE_REVELACAO, "investigate")
		19:
			return _pack("exame_trick_tower", "Trick Tower", ROLE_PROVA, "kill")
		20:
			return _pack("exame_zevil", "Ilha Zevil", ROLE_PREP, "mixed")
		21:
			return _pack("exame_zevil", "Ilha Zevil", ROLE_PROVA, "kill")
		22:
			return _pack("exame_zevil", "Ilha Zevil", ROLE_PROVA, "stealth")
		23:
			return _pack("exame_zevil", "Ilha Zevil", ROLE_PROVA, "mixed")
		24:
			return _pack("exame_climax", "Prova Final", ROLE_CLIMAX, "mixed")
		_:
			return {}


static func _meta_saga_generica(arco: int, etapa: int) -> Dictionary:
	var total: int = total_etapas_arco(arco)
	var atos: Array[Dictionary] = listar_atos_saga(arco)
	var act: Dictionary = atos[0]
	for a in atos:
		var faixa: Vector2i = a.get("etapas", Vector2i(1, 1))
		if etapa >= faixa.x and etapa <= faixa.y:
			act = a
			break
	var role := ROLE_PREP
	if etapa <= 2:
		role = ROLE_SETUP
	elif etapa >= total:
		role = ROLE_CLIMAX
	elif etapa >= total - 2:
		role = ROLE_PROVA
	return _pack(str(act.get("act_id", "saga")), str(act.get("act_name", "Ato")), role, "visit")


static func _meta_fallback(arco: int, etapa: int, quest: Quest) -> Dictionary:
	return {
		"act_id": "saga%d_fallback" % arco,
		"act_name": "Capítulo %d" % etapa,
		"narrative_role": ROLE_PREP,
		"playable_verb": _infer_verb(quest),
	}


static func _pack(act_id: String, act_name: String, role: String, verb: String) -> Dictionary:
	return {
		"act_id": act_id,
		"act_name": act_name,
		"narrative_role": role,
		"playable_verb": verb,
	}


static func _infer_verb(quest: Quest) -> String:
	if quest == null or quest.objectives.is_empty():
		return "visit"
	var kinds: Dictionary = {}
	for obj in quest.objectives:
		if obj == null:
			continue
		match obj.type:
			QuestObjective.Type.KILL:
				kinds["kill"] = true
			QuestObjective.Type.COLLECT:
				kinds["collect"] = true
			QuestObjective.Type.INVESTIGATE:
				kinds["investigate"] = true
			QuestObjective.Type.STEALTH_PASS:
				kinds["stealth"] = true
			QuestObjective.Type.PERSUASION:
				kinds["persuasion"] = true
			_:
				kinds["visit"] = true
	if kinds.size() > 1:
		return "mixed"
	if kinds.has("kill"):
		return "kill"
	if kinds.has("collect"):
		return "collect"
	if kinds.has("investigate"):
		return "investigate"
	if kinds.has("stealth"):
		return "stealth"
	if kinds.has("persuasion"):
		return "persuasion"
	return "visit"


## True se a etapa só tem objetivos soft (visit/investigate/persuasion).
static func eh_soft_only(quest: Quest) -> bool:
	if quest == null:
		return true
	for obj in quest.objectives:
		if obj == null:
			continue
		if obj.type in [
			QuestObjective.Type.KILL,
			QuestObjective.Type.COLLECT,
			QuestObjective.Type.STEALTH_PASS,
			QuestObjective.Type.CRAFT,
		]:
			return false
	return true
