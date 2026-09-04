extends Node

# ============================================================
# HUNTER ONLINE — STORY MANAGER (SINGLE SOURCE OF TRUTH)
# ============================================================
#
# Autoridade central canônica da campanha narrativa do jogo:
# - Gerencia a progressão das 9 Sagas Oficiais e seus capítulos (254 etapas).
# - Avalia e autoriza passagens dimensionais (StoryGate anti-bypass).
# - Emite sinais estritos de progressão narrativa para UI e sistemas de mundo.
# - Sincroniza bidirecionalmente com PlayerData para total retrocompatibilidade.
# ============================================================

signal saga_iniciada(saga_id: int, nome: String)
signal capitulo_avancado(saga_id: int, capitulo: int)
signal saga_concluida(saga_id: int)
signal story_flag_alterada(flag: String, valor: Variant)
signal story_pacing_changed(novo_estado: int, estado_anterior: int)
signal character_choice_registered(choice_id: String, option: String)

enum StoryPacingState {
	EXPLORATION,
	DIALOGUE,
	CUTSCENE,
	COMBAT_EVENT,
	TRAINING_SESSION,
	REST_PACE
}

var current_pacing_state: StoryPacingState = StoryPacingState.EXPLORATION
var character_choices: Dictionary = {}

const SAGAS_CANONICAS: Dictionary = {
	1: "287º Exame Hunter",
	2: "Montanha Kukuroo",
	3: "Arena Celestial",
	4: "Yorknew City & Trupe Fantasma",
	5: "Greed Island",
	6: "Formigas Chimera",
	7: "Eleição Hunter & Alluka",
	8: "Continente Negro",
	9: "Guerra de Sucessão Kakin"
}

const CATALOGO_CHECKPOINTS: Dictionary = {
	&"exame_hunter_inicio": {
		"nome": "Entrada do 287º Exame Hunter",
		"saga": 1,
		"capitulo": 1,
		"cena": "res://world/maps/exame_maratona.tscn",
		"posicao": Vector2(100, 0),
		"safe_name": "Túnel Subterrâneo de Zaban"
	},
	&"pantano_numere": {
		"nome": "Pântano Numere (Ninho de Trapaceiros)",
		"saga": 1,
		"capitulo": 12,
		"cena": "res://world/maps/exame_maratona.tscn",
		"posicao": Vector2(1800, 0),
		"safe_name": "Posto de Controle do Pântano"
	},
	&"montanha_kukuroo_portao": {
		"nome": "Portão da Verificação (Montanha Kukuroo)",
		"saga": 2,
		"capitulo": 1,
		"cena": "res://world/maps/montanha_kukuroo.tscn",
		"posicao": Vector2(100, 0),
		"safe_name": "Guarita do Porteiro Zebro"
	},
	&"arena_celestial_recepcao": {
		"nome": "Recepção da Arena Celestial (1º Andar)",
		"saga": 3,
		"capitulo": 1,
		"cena": "res://world/maps/arena_celestial.tscn",
		"posicao": Vector2(80, 0),
		"safe_name": "Recepção da Arena"
	},
	&"arena_celestial_wing": {
		"nome": "Dojo de Mestre Wing (200º Andar)",
		"saga": 3,
		"capitulo": 9,
		"cena": "res://world/maps/arena_celestial.tscn",
		"posicao": Vector2(1100, -80),
		"safe_name": "Dojo Shingen-ryu"
	},
	&"yorknew_city_leilao": {
		"nome": "Distrito do Leilão (Yorknew City)",
		"saga": 4,
		"capitulo": 1,
		"cena": "res://world/maps/yorknew_city.tscn",
		"posicao": Vector2(100, 0),
		"safe_name": "Hotel da Máfia"
	},
	&"greed_island_planicie": {
		"nome": "Planície de Início de Greed Island",
		"saga": 5,
		"capitulo": 1,
		"cena": "res://world/maps/greed_island.tscn",
		"posicao": Vector2(100, 0),
		"safe_name": "Ponto de Chegada das Gêmeas"
	},
	&"ngl_formigas_fronteira": {
		"nome": "Fronteira Ecológica de NGL",
		"saga": 6,
		"capitulo": 1,
		"cena": "res://world/maps/ngl_formigas.tscn",
		"posicao": Vector2(100, 0),
		"safe_name": "Posto de Inspeção de NGL"
	}
}

var current_saga: int = 1
var current_chapter: int = 1
var max_saga_unlocked: int = 1
var completed_sagas: Array[int] = []
var story_flags: Dictionary = {}
var sagas_registradas: Dictionary = {}

var current_story_checkpoint: StringName = &"exame_hunter_inicio"
var last_safe_checkpoint: StringName = &"hunter_plaza_lobby"


func _ready() -> void:
	_inicializar_sagas_canonicas()
	print("============================================================")
	print("[StoryManager] SINGLE SOURCE OF TRUTH ATIVO (DATA-DRIVEN)")
	print("  Saga Inicial: %d (%s) | Capítulo: %d" % [current_saga, obter_nome_saga(current_saga), current_chapter])
	print("============================================================")
	_sincronizar_com_player_data()


func _inicializar_sagas_canonicas() -> void:
	for s_id in SAGAS_CANONICAS.keys():
		var nome = SAGAS_CANONICAS[s_id]
		var faixa = ProgressionConfig.obter_faixa_saga(s_id) if ProgressionConfig != null else Vector2i(1, 1000)
		var total_c = CanonQuestCatalog.obter_total_quests_do_arco(s_id) if CanonQuestCatalog != null else 1
		sagas_registradas[s_id] = {
			"id": s_id,
			"nome": nome,
			"lvl_min": faixa.x,
			"lvl_max": faixa.y,
			"total_capitulos": total_c
		}


func registrar_saga(saga_id: int, nome: String, lvl_min: int = 1, lvl_max: int = 1000, total_caps: int = 1) -> void:
	sagas_registradas[saga_id] = {
		"id": saga_id,
		"nome": nome,
		"lvl_min": lvl_min,
		"lvl_max": lvl_max,
		"total_capitulos": total_caps
	}
	print("[StoryManager] 📦 NOVA SAGA REGISTRADA: Saga %d — %s (Nível %d–%d | %d caps)" % [saga_id, nome, lvl_min, lvl_max, total_caps])


func tem_saga(saga_id: int) -> bool:
	return sagas_registradas.has(saga_id) or SAGAS_CANONICAS.has(saga_id)


func tem_proxima_saga(saga_atual: int) -> bool:
	return tem_saga(saga_atual + 1)


func obter_faixa_nivel_saga(saga_id: int) -> Vector2i:
	if sagas_registradas.has(saga_id):
		return Vector2i(sagas_registradas[saga_id]["lvl_min"], sagas_registradas[saga_id]["lvl_max"])
	if ProgressionConfig != null:
		return ProgressionConfig.obter_faixa_saga(saga_id)
	return Vector2i(1, 1000)


func jogador_atende_nivel_saga(saga_id: int, nivel_jogador: int) -> bool:
	var faixa = obter_faixa_nivel_saga(saga_id)
	return nivel_jogador >= faixa.x


func _sincronizar_com_player_data() -> void:
	if PlayerData == null:
		return
	current_saga = PlayerData.arco_atual if PlayerData.arco_atual > 0 else 1
	current_chapter = PlayerData.etapa_quest_arco if PlayerData.etapa_quest_arco > 0 else 1
	max_saga_unlocked = max(max_saga_unlocked, PlayerData.max_arco_desbloqueado)


func obter_nome_saga(saga_id: int) -> String:
	if sagas_registradas.has(saga_id):
		return sagas_registradas[saga_id]["nome"]
	return SAGAS_CANONICAS.get(saga_id, "Saga %d" % saga_id)


func iniciar_saga(saga_id: int) -> void:
	if not tem_saga(saga_id):
		push_warning("[StoryManager] Tentativa de iniciar saga não registrada: %d" % saga_id)
		return

	current_saga = saga_id
	current_chapter = 1
	max_saga_unlocked = max(max_saga_unlocked, current_saga)

	if PlayerData != null:
		PlayerData.arco_atual = current_saga
		PlayerData.etapa_quest_arco = current_chapter
		PlayerData.max_arco_desbloqueado = max_saga_unlocked

	saga_iniciada.emit(current_saga, obter_nome_saga(current_saga))
	print("[StoryManager] 🏛️ SAGA INICIADA: Arco %d — %s" % [current_saga, obter_nome_saga(current_saga)])

	if QuestSystem != null and QuestSystem.has_method("garantir_quest_do_arco"):
		QuestSystem.garantir_quest_do_arco(current_saga)


func avancar_capitulo() -> void:
	var total_capitulos: int = 1
	if sagas_registradas.has(current_saga):
		total_capitulos = sagas_registradas[current_saga].get("total_capitulos", 1)
	elif CanonQuestCatalog != null:
		total_capitulos = CanonQuestCatalog.obter_total_quests_do_arco(current_saga)

	if current_chapter < total_capitulos:
		current_chapter += 1
		if PlayerData != null:
			PlayerData.etapa_quest_arco = current_chapter
		capitulo_avancado.emit(current_saga, current_chapter)
		print("[StoryManager] 📜 CAPÍTULO AVANÇADO: Arco %d | Etapa %d/%d" % [current_saga, current_chapter, total_capitulos])
	else:
		concluir_saga(current_saga)


func concluir_saga(saga_id: int) -> void:
	if not completed_sagas.has(saga_id):
		completed_sagas.append(saga_id)

	if saga_id == 5:
		set_story_flag("greed_island_completed", true)

	print("[StoryManager] 🏆 SAGA CONCLUÍDA: Arco %d — %s!" % [saga_id, obter_nome_saga(saga_id)])
	saga_concluida.emit(saga_id)

	if HatsuProgressionManager != null:
		HatsuProgressionManager.check_and_unlock_slots()

	if tem_proxima_saga(saga_id):
		iniciar_saga(saga_id + 1)
	else:
		set_story_flag("modo_historia_concluido", true)
		if PlayerData != null:
			PlayerData.modo_historia_concluido = true


func pode_acessar_saga(saga_id: int) -> bool:
	return saga_id <= max_saga_unlocked


func pode_atravessar_gate(required_arc: int, required_stage_min: int = 1, required_all_stages: bool = false) -> bool:
	return obter_pendencias_gate(required_arc, required_stage_min, required_all_stages).is_empty()


func obter_pendencias_gate(required_arc: int, required_stage_min: int = 1, required_all_stages: bool = false) -> Array[String]:
	var pendencias: Array[String] = []

	# Se o jogador já está em um arco superior, a passagem de arcos anteriores está liberada
	if current_saga > required_arc:
		return pendencias

	# Se o jogador ainda não alcançou o arco
	if current_saga < required_arc:
		pendencias.append("Necessário alcançar o Arco %d (%s)" % [required_arc, obter_nome_saga(required_arc)])
		return pendencias

	# Validação no mesmo arco
	var total_etapas := CanonQuestCatalog.obter_total_quests_do_arco(required_arc)
	if required_all_stages:
		if current_chapter < total_etapas:
			pendencias.append("Conclua todas as %d fases do Arco %d (Progresso: %d/%d)" % [
				total_etapas, required_arc, current_chapter, total_etapas
			])
	elif required_stage_min > 1 and current_chapter < required_stage_min:
		pendencias.append("Alcance a Etapa %d do Arco %d (Progresso atual: %d/%d)" % [
			required_stage_min, required_arc, current_chapter, required_stage_min
		])

	return pendencias


func set_story_flag(flag: String, valor: Variant) -> void:
	story_flags[flag] = valor
	story_flag_alterada.emit(flag, valor)


func get_story_flag(flag: String, default_val: Variant = false) -> Variant:
	return story_flags.get(flag, default_val)


func obter_checkpoint_ativo() -> Dictionary:
	if CATALOGO_CHECKPOINTS.has(current_story_checkpoint):
		return CATALOGO_CHECKPOINTS[current_story_checkpoint]
	
	# Fallback baseado na saga e capítulo atuais
	match current_saga:
		1:
			if current_chapter >= 12:
				return CATALOGO_CHECKPOINTS[&"pantano_numere"]
			return CATALOGO_CHECKPOINTS[&"exame_hunter_inicio"]
		2:
			return CATALOGO_CHECKPOINTS[&"montanha_kukuroo_portao"]
		3:
			if current_chapter >= 9:
				return CATALOGO_CHECKPOINTS[&"arena_celestial_wing"]
			return CATALOGO_CHECKPOINTS[&"arena_celestial_recepcao"]
		4:
			return CATALOGO_CHECKPOINTS[&"yorknew_city_leilao"]
		5:
			return CATALOGO_CHECKPOINTS[&"greed_island_planicie"]
		6:
			return CATALOGO_CHECKPOINTS[&"ngl_formigas_fronteira"]
		_:
			return CATALOGO_CHECKPOINTS[&"exame_hunter_inicio"]


func definir_checkpoint(cp_id: StringName) -> void:
	if CATALOGO_CHECKPOINTS.has(cp_id):
		current_story_checkpoint = cp_id
		var dados = CATALOGO_CHECKPOINTS[cp_id]
		last_safe_checkpoint = StringName(dados.get("safe_name", "hunter_plaza_lobby"))
		print("[StoryManager] 🚩 CHECKPOINT DEFINIDO: %s (%s)" % [cp_id, dados.get("nome", "")])


func continuar_do_checkpoint(tree: SceneTree = null) -> bool:
	var cp := obter_checkpoint_ativo()
	var cena_alvo: String = cp.get("cena", "")
	var pos_alvo: Vector2 = cp.get("posicao", Vector2.ZERO)

	if cena_alvo.is_empty():
		push_warning("[StoryManager] Cena do checkpoint está vazia!")
		return false

	print("[StoryManager] 🚀 CONTINUANDO DA HISTÓRIA A PARTIR DO CHECKPOINT:")
	print("  Checkpoint: ", cp.get("nome", ""))
	print("  Cena Alvo: ", cena_alvo, " | Posição: ", pos_alvo)

	if PlayerData != null:
		PlayerData.posicao_salva = pos_alvo
		PlayerData.mapa_atual_salvo = cena_alvo

	if tree == null:
		tree = get_tree()

	if tree != null:
		var trans = tree.root.get_node_or_null("SceneTransition")
		if trans != null and trans.has_method("mudar_cena"):
			trans.mudar_cena(cena_alvo, obter_nome_saga(current_saga), str(cp.get("nome", "")))
		else:
			tree.change_scene_to_file(cena_alvo)
		return true

	return false


func set_pacing_state(novo_estado: StoryPacingState) -> void:
	if current_pacing_state != novo_estado:
		var ant := current_pacing_state
		current_pacing_state = novo_estado
		story_pacing_changed.emit(int(novo_estado), int(ant))
		print("[StoryManager] 🎭 RITMO NARRATIVO: %s -> %s" % [StoryPacingState.keys()[ant], StoryPacingState.keys()[novo_estado]])


func get_pacing_state() -> StoryPacingState:
	return current_pacing_state


func register_choice(choice_id: String, option: String) -> void:
	character_choices[choice_id] = option
	set_story_flag("choice_" + choice_id, option)
	character_choice_registered.emit(choice_id, option)
	print("[StoryManager] ⚖️ ESCOLHA REGISTRADA: [%s] = '%s'" % [choice_id, option])


func has_choice(choice_id: String) -> bool:
	return character_choices.has(choice_id)


func get_choice(choice_id: String, default_val: String = "") -> String:
	return str(character_choices.get(choice_id, default_val))


func obter_progresso_saga_atual() -> float:
	var total_capitulos: int = 1
	if sagas_registradas.has(current_saga):
		total_capitulos = sagas_registradas[current_saga].get("total_capitulos", 1)
	elif CanonQuestCatalog != null:
		total_capitulos = CanonQuestCatalog.obter_total_quests_do_arco(current_saga)
	if total_capitulos <= 0:
		return 0.0
	return clampf((float(current_chapter) / float(total_capitulos)) * 100.0, 0.0, 100.0)


# ============================================================
# PERSISTÊNCIA SERIALIZÁVEL
# ============================================================

func serializar() -> Dictionary:
	return {
		"current_saga": current_saga,
		"current_chapter": current_chapter,
		"max_saga_unlocked": max_saga_unlocked,
		"completed_sagas": completed_sagas.duplicate(),
		"story_flags": story_flags.duplicate(),
		"current_story_checkpoint": String(current_story_checkpoint),
		"last_safe_checkpoint": String(last_safe_checkpoint),
		"current_pacing_state": int(current_pacing_state),
		"character_choices": character_choices.duplicate()
	}


func deserializar(data: Dictionary) -> void:
	current_saga = int(data.get("current_saga", 1))
	current_chapter = int(data.get("current_chapter", 1))
	max_saga_unlocked = int(data.get("max_saga_unlocked", max(1, current_saga)))
	completed_sagas.clear()
	for s in data.get("completed_sagas", []):
		completed_sagas.append(int(s))
	story_flags = data.get("story_flags", {}).duplicate()
	current_story_checkpoint = StringName(data.get("current_story_checkpoint", "exame_hunter_inicio"))
	last_safe_checkpoint = StringName(data.get("last_safe_checkpoint", "hunter_plaza_lobby"))
	current_pacing_state = int(data.get("current_pacing_state", StoryPacingState.EXPLORATION)) as StoryPacingState
	character_choices = data.get("character_choices", {}).duplicate()

	# Refletir no PlayerData
	if PlayerData != null:
		PlayerData.arco_atual = current_saga
		PlayerData.etapa_quest_arco = current_chapter
		PlayerData.max_arco_desbloqueado = max_saga_unlocked
