class_name StoryGatingEvaluator
extends RefCounted

# ============================================================
# HUNTER ONLINE — STORY GATING EVALUATOR (FASE L)
# ============================================================
#
# Motor universal de avaliação de requisitos para:
# - Acesso a Sagas, Capítulos, Quests, Regiões, Diálogos e Eventos.
# - Substitui checagens hardcoded de nível por um sistema multicritério:
#   * Level / Atributos
#   * Missões Concluídas
#   * NPCs Encontrados / Memória de Atos
#   * Reputação com Facções
#   * Itens no Inventário
#   * Hatsu Desbloqueado ou Equipado
#   * Domínio e Técnicas de Nen
#   * Escolhas Narrativas do Jogador
#   * Horário Solar e Fases do Dia
#   * Clima e Condições Atmosféricas
#   * Chefes Secretos ou Mundiais Abatidos
#   * Conquistas Desbloqueadas
# ============================================================

static func evaluate_condition(cond: Dictionary) -> Dictionary:
	var c_type: String = str(cond.get("type", "")).to_lower()
	var val = cond.get("value", null)
	
	match c_type:
		"level", "nivel_min":
			var cur_lvl: int = 1
			if PlayerData != null and PlayerData.attributes.has("nivel"):
				cur_lvl = int(PlayerData.attributes["nivel"])
			var req_lvl: int = int(val)
			if cur_lvl >= req_lvl:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer Nível %d (Atual: %d)" % [req_lvl, cur_lvl]}

		"quest_completed", "missao_concluida":
			var q_id: String = str(val)
			var comp: bool = false
			if PlayerData != null and PlayerData.quest_states.has(q_id):
				comp = (PlayerData.quest_states[q_id] == 3 or PlayerData.quest_states[q_id] == "COMPLETED")
			if comp:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer conclusão da missão '%s'" % q_id}

		"npc_met", "npc_encontrado":
			var npc_id: String = str(val)
			var met: bool = false
			if PlayerData != null and PlayerData.segredos_descobertos.has("npc_" + npc_id):
				met = true
			elif RelationshipSystem != null and RelationshipSystem.npc_relations.has(npc_id):
				met = true
			if met:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer encontro prévio com o NPC '%s'" % npc_id}

		"reputation", "reputacao_min":
			var faccao = cond.get("faction", 0)
			var req_val: int = int(val)
			var cur_rep: int = 0
			if ReputationSystem != null:
				cur_rep = ReputationSystem.obter_reputacao(faccao if faccao is int else int(faccao))
			if cur_rep >= req_val:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer reputação mínima de %d (Atual: %d)" % [req_val, cur_rep]}

		"has_item", "item_inventario":
			var item_id: String = str(val)
			var count_req: int = int(cond.get("count", 1))
			var cur_count: int = 0
			if PlayerData != null:
				for it in PlayerData.inventory:
					if it is Dictionary and str(it.get("id", "")) == item_id:
						cur_count += int(it.get("quantidade", 1))
			if cur_count >= count_req:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer %dx item '%s' (Possui: %d)" % [count_req, item_id, cur_count]}

		"has_hatsu", "hatsu_dominado":
			var hatsu_id: String = str(val)
			var has_h: bool = false
			if PlayerData != null:
				for h in PlayerData.hatsu_criados:
					if h != null and (h.get("hatsu_id") == hatsu_id or h.get("nome_habilidade") == hatsu_id):
						has_h = true
						break
				if not has_h:
					for sh in PlayerData.stored_hatsus:
						if sh is Dictionary and (sh.get("id") == hatsu_id or str(sh.get("name", "")) == hatsu_id):
							has_h = true
							break
			if has_h:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer domínio do Hatsu '%s'" % hatsu_id}

		"nen_awakened", "despertar_nen":
			var awk: bool = (PlayerData != null and PlayerData.despertou_nen)
			if awk:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer que o jogador tenha despertado a Aura (Nen)"}

		"choice", "escolha_narrativa":
			var choice_id: String = str(cond.get("choice_id", ""))
			var expected_option: String = str(val)
			var actual_option: String = ""
			if StoryManager != null:
				actual_option = StoryManager.get_choice(choice_id, "")
			if actual_option == expected_option:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer escolha de caminho narrativo '%s'" % expected_option}

		"world_flag", "flag_mundial":
			var flag_name: String = str(cond.get("flag", val))
			var expected = cond.get("expected", true)
			var cur_val = null
			if WorldState != null:
				cur_val = WorldState.obter_flag_mundial(flag_name, false)
			elif StoryManager != null:
				cur_val = StoryManager.get_story_flag(flag_name, false)
			if cur_val == expected:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer marco mundial '%s' ativo" % flag_name}

		"time_phase", "fase_tempo":
			var expected_phase: int = int(val)
			var cur_phase: int = 1
			if TimeManager != null:
				cur_phase = TimeManager.current_phase
			if cur_phase == expected_phase:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer fase solar específica"}

		"weather", "clima":
			var expected_clima: int = int(val)
			var cur_clima: int = 0
			if WorldStateManager != null:
				cur_clima = int(WorldStateManager.obter_clima_atual())
			if cur_clima == expected_clima:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer clima específico para ativação"}

		"boss_defeated", "chefe_derrotado":
			var boss_id: String = str(val)
			var def_ok: bool = false
			if PlayerData != null and PlayerData.stats_globais.has("bosses_derrotados"):
				var bd = PlayerData.stats_globais["bosses_derrotados"]
				if bd is Array and bd.has(boss_id):
					def_ok = true
			if def_ok:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer vitória prévia contra o chefe '%s'" % boss_id}

		"achievement", "conquista":
			var ach_id: String = str(val)
			var has_ach: bool = false
			if PlayerData != null and PlayerData.conquistas_desbloqueadas.has(ach_id):
				has_ach = true
			if has_ach:
				return {"passed": true, "reason": ""}
			return {"passed": false, "reason": "Requer conquista '%s' desbloqueada" % ach_id}

		_:
			# Fallback padrão
			return {"passed": true, "reason": ""}


static func evaluate_all(conditions: Array) -> Dictionary:
	var unmet: Array[String] = []
	for c in conditions:
		if c is Dictionary:
			var res = evaluate_condition(c)
			if not bool(res.get("passed", true)):
				unmet.append(str(res.get("reason", "Requisito não atendido")))
				
	return {
		"passed": unmet.is_empty(),
		"unmet": unmet
	}
