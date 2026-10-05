class_name CheckpointCutsceneLibrary
extends RefCounted

const CutsceneSequenceRunnerScript = preload("res://scripts/cutscenes/CutsceneSequenceRunner.gd")
const StoryCutsceneManagerScript = preload("res://scripts/cutscenes/StoryCutsceneManager.gd")

# ============================================================
# HUNTER ONLINE — Checkpoint cutscenes mid/late (15–40s beats)
# ============================================================
# Micro-cenas nos marcos de rota — não substituem cutscenes de
# portal de arco (StoryCutsceneManager).
# ============================================================


static func executar(tree: SceneTree, cutscene_id: StringName, callback: Callable = Callable()) -> void:
	if tree == null:
		return
	if StoryCutsceneManagerScript.em_cutscene:
		return
	var flag := "ckpt_%s" % String(cutscene_id)
	if StoryManager != null and bool(StoryManager.get_story_flag(flag, false)):
		return
	var passos := obter_passos(cutscene_id)
	if passos.is_empty():
		return
	StoryCutsceneManagerScript.em_cutscene = true
	CutsceneSequenceRunnerScript.executar(tree, passos, "ckpt_%s" % String(cutscene_id), func():
		if StoryManager != null:
			StoryManager.set_story_flag(flag, true)
		StoryCutsceneManagerScript.em_cutscene = false
		if callback.is_valid():
			callback.call()
	)


static func obter_passos(cutscene_id: StringName) -> Array[Dictionary]:
	match String(cutscene_id):
		"exame_largada":
			return _pack(
				"Satotz (eco)",
				"287º Exame. Corra LESTE. GPS marca o próximo marco.",
				"Um objetivo de cada vez. Evite emboscadas no corredor.",
				"exame_largada_seen"
			)
		"vale_wing_nen":
			return _pack(
				"Mestre Wing",
				"Antes das Ruínas: Gyo → Zetsu → Ko. Nesta ordem.",
				"ORDEM clara. Sem misturar. Depois Floresta.",
				"vale_wing_nen_seen"
			)
		"floresta_ninho":
			return _pack(
				"Herbalista (eco)",
				"Ninho profundo à frente. [G] pistas, [Z] acampamento, [KO] atalho.",
				"Elites escondem fraqueza Nen. Leia o telegraph.",
				"floresta_ninho_seen"
			)
		"ruinas_antes_guardiao":
			return _pack(
				"Guia das Ruínas",
				"Guardião Ancestral: 3 fases. Telegraph vermelho = saia.",
				"Loot no chão. Wipe → checkpoint. Sem rush.",
				"ruinas_antes_guardiao_seen"
			)
		"kukuroo_alameda":
			return _pack(
				"Killua",
				"A alameda dos Zoldyck não perdoa quem grita aura.",
				"Canary te espera depois do Mike. Um objetivo.",
				"kukuroo_alameda_seen"
			)
		"kukuroo_mansao":
			return _pack(
				"Gotoh (eco)",
				"Precisão. Moedas. Sem pressa.",
				"Passe o teste — o trono vem depois.",
				"kukuroo_mansao_seen"
			)
		"arena_wing_dojo":
			return _pack(
				"Mestre Wing",
				"Nen não é atalho. É identidade.",
				"Teste da Água, depois andares. Respire entre ranks.",
				"arena_wing_seen"
			)
		"arena_pre_200":
			return _pack(
				"Killua",
				"200º andar. Hisoka brinca com quem rusha.",
				"Termine mestres do GPS. Depois portal Yorknew.",
				"arena_pre200_seen"
			)
		"yorknew_avenida":
			return _pack(
				"Kurapika",
				"Yorknew é longa de propósito. Micro-passos.",
				"[G] no mercado, [Z] nos becos. Um distrito.",
				"yorknew_avenida_seen"
			)
		"yorknew_cemiterio":
			return _pack(
				"Leorio",
				"Cemitério à frente. Battera e o GI ainda longe.",
				"Sem rush na Trupe. GPS marca a ordem.",
				"yorknew_cem_seen"
			)
		"greed_biscuit":
			return _pack(
				"Biscuit",
				"Treino antes de Bomber. Ko, Ren, identidade.",
				"Quando o Hatsu responder, você sobe de nível de verdade.",
				"greed_biscuit_seen"
			)
		"greed_soufrabi":
			return _pack(
				"Gon",
				"Porto Soufrabi. Razor espera no ginásio.",
				"Goreinu → Hisoka → Razor. Ordem clara.",
				"greed_soufrabi_seen"
			)
		"ngl_palacio":
			return _pack(
				"Morel (eco)",
				"Palácio. Guardas Reais. Sem improvisar.",
				"Um GPS. Uma luta. Sem misturar.",
				"ngl_palacio_seen"
			)
		"black_whale_conves":
			return _pack(
				"Kurapika",
				"Black Whale. Corredores longos — recompensa a cada bloco.",
				"Gyo nos vestígios. Zetsu quando o GPS pedir.",
				"bw_conves_seen"
			)
		_:
			return []


static func _pack(speaker_a: String, text_a: String, text_b: String, flag: String) -> Array[Dictionary]:
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunnerScript.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunnerScript.StepType.CAMERA_ZOOM, "zoom": Vector2(1.15, 1.15), "duration": 0.3},
		{"type": CutsceneSequenceRunnerScript.StepType.WAIT, "seconds": 0.35},
		{"type": CutsceneSequenceRunnerScript.StepType.DIALOGUE, "speaker": speaker_a, "text": text_a},
		{"type": CutsceneSequenceRunnerScript.StepType.WAIT, "seconds": 0.25},
		{"type": CutsceneSequenceRunnerScript.StepType.DIALOGUE, "speaker": "Narrador", "text": text_b},
		{"type": CutsceneSequenceRunnerScript.StepType.SET_FLAG, "flag": flag, "value": true},
		{"type": CutsceneSequenceRunnerScript.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.25},
		{"type": CutsceneSequenceRunnerScript.StepType.LOCK_INPUT, "lock": false},
	]
	return passos
