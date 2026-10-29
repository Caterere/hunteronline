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
	# Verbo sempre espelha objetivos reais do catálogo (SSOT).
	quest.custom_data["playable_verb"] = _infer_verb(quest)


static func obter_meta(arco: int, etapa: int) -> Dictionary:
	match arco:
		1:
			return _meta_exame(etapa)
		2:
			return _meta_kukuroo(etapa)
		3:
			return _meta_arena(etapa)
		4:
			return _meta_yorknew(etapa)
		5:
			return _meta_greed(etapa)
		6:
			return _meta_formigas(etapa)
		7:
			return _meta_eleicao(etapa)
		8:
			return _meta_continente(etapa)
		9:
			return _meta_sucessao(etapa)
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
		3:
			return [
				{"act_id": "arena_andares", "act_name": "Escalada dos Andares", "etapas": Vector2i(1, 5)},
				{"act_id": "arena_200", "act_name": "Limiar do 200º", "etapas": Vector2i(6, 9)},
				{"act_id": "arena_nen", "act_name": "Aprendizado de Nen", "etapas": Vector2i(10, 15)},
				{"act_id": "arena_mestres", "act_name": "Mestres & Trapaceiros", "etapas": Vector2i(16, 22)},
				{"act_id": "arena_climax", "act_name": "Clímax Hisoka", "etapas": Vector2i(23, 26)},
			]
		4:
			return [
				{"act_id": "york_chegada", "act_name": "Chegada & Mercado", "etapas": Vector2i(1, 7)},
				{"act_id": "york_trupe", "act_name": "Sombra da Trupe", "etapas": Vector2i(8, 15)},
				{"act_id": "york_prisao", "act_name": "Prisão & Apagão", "etapas": Vector2i(16, 23)},
				{"act_id": "york_desfecho", "act_name": "Negociação & GI", "etapas": Vector2i(24, 34)},
			]
		2:
			return [
				{"act_id": "kuku_portao", "act_name": "Portão & Alameda", "etapas": Vector2i(1, 7)},
				{"act_id": "kuku_mansao", "act_name": "Mansão dos Mordomos", "etapas": Vector2i(8, 14)},
				{"act_id": "kuku_trono", "act_name": "Trono & Resgate", "etapas": Vector2i(15, 18)},
			]
		5:
			return [
				{"act_id": "gi_entrada", "act_name": "Entrada & Regras", "etapas": Vector2i(1, 4)},
				{"act_id": "gi_biscuit", "act_name": "Treino Biscuit", "etapas": Vector2i(5, 14)},
				{"act_id": "gi_aliancas", "act_name": "Alianças & Bomber", "etapas": Vector2i(15, 22)},
				{"act_id": "gi_razor", "act_name": "Razor & Queimada", "etapas": Vector2i(23, 28)},
				{"act_id": "gi_climax", "act_name": "Clímax GI", "etapas": Vector2i(29, 36)},
			]
		6:
			return [
				{"act_id": "ngl_fronteira", "act_name": "Fronteira NGL", "etapas": Vector2i(1, 10)},
				{"act_id": "ngl_tropa", "act_name": "Tropa de Extermínio", "etapas": Vector2i(11, 19)},
				{"act_id": "ngl_invasao", "act_name": "Invasão do Palácio", "etapas": Vector2i(20, 33)},
				{"act_id": "ngl_tumba", "act_name": "Tumba & Rosa", "etapas": Vector2i(34, 42)},
				{"act_id": "ngl_aftermath", "act_name": "Aftermath", "etapas": Vector2i(43, 48)},
			]
		7:
			return [
				{"act_id": "ele_associacao", "act_name": "Associação & UTI", "etapas": Vector2i(1, 6)},
				{"act_id": "ele_alluka", "act_name": "Resgate Alluka", "etapas": Vector2i(7, 12)},
				{"act_id": "ele_votacao", "act_name": "Votação & Milagre", "etapas": Vector2i(13, 20)},
			]
		8:
			return [
				{"act_id": "cn_expedicao", "act_name": "Expedição Beyond", "etapas": Vector2i(1, 7)},
				{"act_id": "cn_calamidades", "act_name": "Calamidades", "etapas": Vector2i(8, 14)},
				{"act_id": "cn_arvore", "act_name": "Árvore do Mundo", "etapas": Vector2i(15, 22)},
			]
		9:
			return [
				{"act_id": "bw_embarque", "act_name": "Embarque & Ritual", "etapas": Vector2i(1, 6)},
				{"act_id": "bw_mafia", "act_name": "Máfia & Heil-Ly", "etapas": Vector2i(7, 14)},
				{"act_id": "bw_principe", "act_name": "Príncipe Tserriednich", "etapas": Vector2i(15, 21)},
				{"act_id": "bw_climax", "act_name": "Estabilização", "etapas": Vector2i(22, 26)},
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


static func _meta_arena(etapa: int) -> Dictionary:
	match etapa:
		1:
			return _pack("arena_andares", "Escalada dos Andares", ROLE_SETUP, "visit")
		2, 3, 4, 5:
			return _pack("arena_andares", "Escalada dos Andares", ROLE_PROVA, "kill")
		6, 8, 9:
			return _pack("arena_200", "Limiar do 200º", ROLE_PREP if etapa < 9 else ROLE_SETUP, "visit")
		7:
			return _pack("arena_200", "Limiar do 200º", ROLE_PROVA, "stealth")
		10:
			return _pack("arena_nen", "Aprendizado de Nen", ROLE_REVELACAO, "investigate")
		11:
			return _pack("arena_nen", "Aprendizado de Nen", ROLE_SETUP, "visit")
		12:
			return _pack("arena_nen", "Aprendizado de Nen", ROLE_PROVA, "investigate")
		13:
			return _pack("arena_nen", "Aprendizado de Nen", ROLE_PROVA, "stealth")
		14:
			return _pack("arena_nen", "Aprendizado de Nen", ROLE_PROVA, "investigate")
		15:
			return _pack("arena_nen", "Aprendizado de Nen", ROLE_PROVA, "stealth")
		16, 17, 20:
			return _pack("arena_mestres", "Mestres & Trapaceiros", ROLE_PREP, "visit")
		18, 19, 21:
			return _pack("arena_mestres", "Mestres & Trapaceiros", ROLE_PROVA, "kill")
		22:
			return _pack("arena_mestres", "Mestres & Trapaceiros", ROLE_REVELACAO, "investigate")
		23:
			return _pack("arena_climax", "Clímax Hisoka", ROLE_PREP, "kill")
		24:
			return _pack("arena_climax", "Clímax Hisoka", ROLE_BOND, "persuasion")
		25:
			return _pack("arena_climax", "Clímax Hisoka", ROLE_CLIMAX, "kill")
		26:
			return _pack("arena_climax", "Clímax Hisoka", ROLE_AFTERMATH, "visit")
		_:
			return {}


static func _meta_yorknew(etapa: int) -> Dictionary:
	var atos: Array[Dictionary] = listar_atos_saga(4)
	var act := atos[0]
	for a in atos:
		var faixa: Vector2i = a.get("etapas", Vector2i(1, 1))
		if etapa >= faixa.x and etapa <= faixa.y:
			act = a
			break
	var role := ROLE_PREP
	var verb := "visit"
	match etapa:
		2, 7, 13, 19, 29, 33:
			role = ROLE_REVELACAO
			verb = "investigate"
		5, 10, 18, 23, 34:
			role = ROLE_PROVA
			verb = "kill"
		8, 15, 21, 25:
			role = ROLE_PROVA
			verb = "stealth"
		11, 24, 26, 31, 32:
			role = ROLE_PROVA
			verb = "persuasion"
		28:
			role = ROLE_REVELACAO
			verb = "investigate"
		30:
			role = ROLE_REVELACAO
			verb = "investigate"
		34:
			role = ROLE_CLIMAX
			verb = "kill"
	return _pack(str(act.get("act_id")), str(act.get("act_name")), role, verb)


static func _meta_greed(etapa: int) -> Dictionary:
	var atos: Array[Dictionary] = listar_atos_saga(5)
	var act := atos[0]
	for a in atos:
		var faixa: Vector2i = a.get("etapas", Vector2i(1, 1))
		if etapa >= faixa.x and etapa <= faixa.y:
			act = a
			break
	var role := ROLE_PREP
	var verb := "visit"
	match etapa:
		3, 6, 7, 10, 16, 19:
			role = ROLE_REVELACAO if etapa in [3, 6, 16, 19] else ROLE_PROVA
			verb = "investigate"
		4, 8, 14, 21, 25, 28, 30, 31:
			role = ROLE_PROVA
			verb = "kill"
		9, 17:
			role = ROLE_PROVA
			verb = "stealth"
		11:
			role = ROLE_PROVA
			verb = "investigate"
		12:
			role = ROLE_CLIMAX
			verb = "visit"
		15, 32:
			role = ROLE_BOND
			verb = "persuasion"
		36:
			role = ROLE_CLIMAX
			verb = "kill"
	return _pack(str(act.get("act_id")), str(act.get("act_name")), role, verb)


static func _meta_kukuroo(etapa: int) -> Dictionary:
	return _meta_atos_com_papel(2, etapa, {
		5: ROLE_REVELACAO, 6: ROLE_PROVA, 7: ROLE_PROVA, 9: ROLE_PROVA,
		11: ROLE_PROVA, 13: ROLE_REVELACAO, 14: ROLE_PROVA, 15: ROLE_PROVA,
		16: ROLE_REVELACAO, 17: ROLE_BOND, 18: ROLE_AFTERMATH,
	})


static func _meta_formigas(etapa: int) -> Dictionary:
	return _meta_atos_com_papel(6, etapa, {
		3: ROLE_PROVA, 4: ROLE_REVELACAO, 5: ROLE_PROVA, 7: ROLE_PROVA,
		8: ROLE_REVELACAO, 10: ROLE_PROVA, 12: ROLE_PROVA, 16: ROLE_REVELACAO,
		18: ROLE_PROVA, 19: ROLE_PROVA, 22: ROLE_REVELACAO, 23: ROLE_BOND,
		26: ROLE_REVELACAO, 27: ROLE_REVELACAO, 28: ROLE_PROVA, 32: ROLE_PROVA,
		33: ROLE_PROVA, 36: ROLE_PROVA, 37: ROLE_REVELACAO, 39: ROLE_REVELACAO,
		42: ROLE_CLIMAX, 43: ROLE_CLIMAX, 48: ROLE_AFTERMATH,
	})


static func _meta_eleicao(etapa: int) -> Dictionary:
	return _meta_atos_com_papel(7, etapa, {
		4: ROLE_REVELACAO, 6: ROLE_REVELACAO, 9: ROLE_PROVA, 10: ROLE_PROVA,
		11: ROLE_PROVA, 12: ROLE_CLIMAX, 13: ROLE_REVELACAO, 14: ROLE_PROVA,
		16: ROLE_BOND, 20: ROLE_AFTERMATH,
	})


static func _meta_continente(etapa: int) -> Dictionary:
	return _meta_atos_com_papel(8, etapa, {
		4: ROLE_PROVA, 5: ROLE_REVELACAO, 6: ROLE_PROVA, 8: ROLE_REVELACAO,
		9: ROLE_PROVA, 10: ROLE_PROVA, 11: ROLE_PROVA, 12: ROLE_PROVA,
		13: ROLE_PROVA, 14: ROLE_PROVA, 16: ROLE_PROVA, 17: ROLE_PROVA,
		18: ROLE_REVELACAO, 20: ROLE_BOND, 21: ROLE_REVELACAO, 22: ROLE_AFTERMATH,
	})


static func _meta_sucessao(etapa: int) -> Dictionary:
	return _meta_atos_com_papel(9, etapa, {
		3: ROLE_REVELACAO, 4: ROLE_REVELACAO, 6: ROLE_PROVA, 8: ROLE_REVELACAO,
		9: ROLE_PROVA, 10: ROLE_REVELACAO, 11: ROLE_PROVA, 12: ROLE_PROVA,
		13: ROLE_REVELACAO, 14: ROLE_BOND, 15: ROLE_PROVA, 16: ROLE_REVELACAO,
		18: ROLE_PROVA, 19: ROLE_CLIMAX, 20: ROLE_PROVA, 21: ROLE_PROVA,
		22: ROLE_PROVA, 24: ROLE_CLIMAX, 26: ROLE_AFTERMATH,
	})


static func _meta_atos_com_papel(arco: int, etapa: int, papeis: Dictionary) -> Dictionary:
	var act := _ato_da_etapa(arco, etapa)
	var role := str(papeis.get(etapa, ROLE_PREP))
	if etapa <= 2 and not papeis.has(etapa):
		role = ROLE_SETUP
	return _pack(str(act.get("act_id")), str(act.get("act_name")), role, "visit")


static func _ato_da_etapa(arco: int, etapa: int) -> Dictionary:
	var atos: Array[Dictionary] = listar_atos_saga(arco)
	var act: Dictionary = atos[0] if not atos.is_empty() else {}
	for a in atos:
		var faixa: Vector2i = a.get("etapas", Vector2i(1, 1))
		if etapa >= faixa.x and etapa <= faixa.y:
			return a
	return act


static func _meta_saga_generica(arco: int, etapa: int) -> Dictionary:
	var total: int = total_etapas_arco(arco)
	var act: Dictionary = _ato_da_etapa(arco, etapa)
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
