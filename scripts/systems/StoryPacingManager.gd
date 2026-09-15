class_name StoryPacingManager
extends Node

# ============================================================
# HUNTER ONLINE - STORY PACING MANAGER (RITMO E RESPIRAS NARRATIVAS)
# ============================================================
#
# Controla a cadência da experiência de jogo:
# - Alternância saudável entre ação/combate intenso e respiro/exploração.
# - Despacha micro-cenas e eventos de viagem (road encounters).
#
# ============================================================

signal respiro_sugerido(motivo: String)
signal micro_evento_viagem_iniciado(titulo: String, tipo: String)
signal micro_evento_viagem_concluido(evento_id: String, escolha: String)

enum SceneCategory {
	MICRO_SCENE,
	CHARACTER_SCENE,
	STORY_SCENE,
	MAJOR_CUTSCENE
}

var tempo_em_combate: float = 0.0
var tempo_em_exploracao: float = 0.0
var combates_consecutivos: int = 0
var ultimo_respiro_timestamp: float = 0.0
var _evento_em_curso: bool = false

const LIMITE_COMBATES_PARA_RESPIRO: int = 4
const TEMPO_MINIMO_RESPIRO: float = 120.0

## Catálogo de micro-eventos de estrada (semi-cutscenes curtas).
const EVENTOS_VIAGEM: Dictionary = {
	"estrada_comerciante": {
		"titulo": "Comerciante na Estrada",
		"bgm": "hunting_for_your_dream",
		"falas": [
			{"speaker": "Comerciante Errante", "text": "Ei, Hunter! A estrada até o próximo posto está movimentada. Quer um amuleto barato pra sorte?"},
			{"speaker": "Comerciante Errante", "text": "Ou prefere só um rumor? Dizem que um aspirante sumiu perto das Ruínas de Zaban..."},
		],
		"choice_id": "estrada_comerciante",
		"options": [
			{"id": "comprar", "text": "Comprar Amuleto (150 Jenny)"},
			{"id": "rumor", "text": "Ouvir o rumor"},
			{"id": "ignorar", "text": "Seguir viagem"},
		],
	},
	"patrulha_associacao": {
		"titulo": "Patrulha da Associação",
		"bgm": "departure",
		"falas": [
			{"speaker": "Patrulheiro Hunter", "text": "Documentos, por favor. A Associação reforçou a vigilância após rumores de Nen selvagem na região."},
			{"speaker": "Patrulheiro Hunter", "text": "Se estiver indo ao Exame, mantenha a Licença à mão. Boa caçada."},
		],
		"choice_id": "patrulha_associacao",
		"options": [
			{"id": "mostrar", "text": "Mostrar Licença / Credencial"},
			{"id": "perguntar", "text": "Perguntar sobre o rumores"},
			{"id": "seguir", "text": "Seguir em silêncio"},
		],
	},
	"emboscada_leve": {
		"titulo": "Assobio na Floresta",
		"bgm": "riot",
		"falas": [
			{"speaker": "Narrador", "text": "Um galho estala. Alguém observa da beira da estrada — bandido local, sem Nen."},
			{"speaker": "Bandido", "text": "Entrega a bolsa e ninguém se machuca, novato!"},
		],
		"choice_id": "emboscada_leve",
		"options": [
			{"id": "enfrentar", "text": "Enfrentar"},
			{"id": "fugir", "text": "Correr pela estrada"},
			{"id": "blefar", "text": "Blefar com postura de Hunter"},
		],
	},
}


func _ready() -> void:
	add_to_group("story_pacing_manager")
	if EventBus != null:
		if EventBus.has_signal("combat_started"):
			EventBus.connect("combat_started", _on_combat_started)
		if EventBus.has_signal("combat_ended"):
			EventBus.connect("combat_ended", _on_combat_ended)


func _process(delta: float) -> void:
	if StoryManager != null:
		var state = StoryManager.get_pacing_state()
		match state:
			StoryManager.StoryPacingState.COMBAT_EVENT:
				tempo_em_combate += delta
			StoryManager.StoryPacingState.EXPLORATION, StoryManager.StoryPacingState.REST_PACE:
				tempo_em_exploracao += delta


func notificar_combate_concluido() -> void:
	combates_consecutivos += 1
	if combates_consecutivos >= LIMITE_COMBATES_PARA_RESPIRO:
		sugerir_momento_respiro("Após sucessivos confrontos, recomenda-se explorar, descansar e reabastecer suprimentos.")


func sugerir_momento_respiro(motivo: String) -> void:
	respiro_sugerido.emit(motivo)
	combates_consecutivos = 0
	if StoryManager != null:
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.REST_PACE)
	print("[StoryPacingManager] MOMENTO DE RESPIRO SUGERIDO: %s" % motivo)


func iniciar_evento_viagem(ponto_origem: String, ponto_destino: String, evento_id: String = "estrada_comerciante", tree: SceneTree = null, ao_concluir: Callable = Callable()) -> void:
	print("[StoryPacingManager] VIAGEM: %s -> %s (Evento: %s)" % [ponto_origem, ponto_destino, evento_id])
	micro_evento_viagem_iniciado.emit("Viagem pela Estrada Regional", evento_id)
	if StoryManager != null:
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)

	var t: SceneTree = tree
	if t == null and Engine.get_main_loop() is SceneTree:
		t = Engine.get_main_loop() as SceneTree

	if t == null or _evento_em_curso:
		if ao_concluir.is_valid():
			ao_concluir.call()
		return

	# Evita repetir o mesmo evento na mesma sessão de save
	var flag_key: String = "travel_event_%s" % evento_id
	if StoryManager != null and StoryManager.get_story_flag(flag_key, false):
		if ao_concluir.is_valid():
			ao_concluir.call()
		return

	_evento_em_curso = true
	var dados: Dictionary = EVENTOS_VIAGEM.get(evento_id, EVENTOS_VIAGEM["estrada_comerciante"])
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.15, 1.15), "duration": 0.3},
	]
	var bgm: String = str(dados.get("bgm", ""))
	if not bgm.is_empty():
		passos.append({"type": CutsceneSequenceRunner.StepType.AUDIO_BGM, "bgm": bgm})

	for fala in dados.get("falas", []):
		passos.append({
			"type": CutsceneSequenceRunner.StepType.DIALOGUE,
			"speaker": str(fala.get("speaker", "Viajante")),
			"text": str(fala.get("text", "")),
		})

	passos.append({
		"type": CutsceneSequenceRunner.StepType.CHOICE,
		"choice_id": str(dados.get("choice_id", evento_id)),
		"speaker": "Estrada",
		"text": "O que você faz?",
		"options": dados.get("options", [{"id": "seguir", "text": "Seguir"}]),
	})
	passos.append({"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": flag_key, "value": true})
	passos.append({"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.0, 1.0), "duration": 0.2})
	passos.append({"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false})

	var titulo: String = str(dados.get("titulo", evento_id))
	if EventBus != null:
		EventBus.emit_toast("🛤️ %s" % titulo, Color(0.7, 0.9, 1.0))

	CutsceneSequenceRunner.executar(t, passos, "Travel_%s" % evento_id, func():
		_evento_em_curso = false
		var escolha: String = ""
		if StoryManager != null:
			escolha = str(StoryManager.get_choice(str(dados.get("choice_id", evento_id)), ""))
		_aplicar_consequencia_viagem(evento_id, escolha)
		micro_evento_viagem_concluido.emit(evento_id, escolha)
		if ao_concluir.is_valid():
			ao_concluir.call()
	)


func _aplicar_consequencia_viagem(evento_id: String, escolha: String) -> void:
	match evento_id:
		"estrada_comerciante":
			match escolha:
				"comprar":
					if Economy != null and Economy.remover_gold(150):
						if not PlayerData.tem_item(&"amuleto_forca"):
							PlayerData.adicionar_item(&"amuleto_forca", 1)
						elif not PlayerData.tem_item(&"anel_aura"):
							PlayerData.adicionar_item(&"anel_aura", 1)
						else:
							PlayerData.adicionar_item(&"amuleto_forca", 1)
						if EventBus != null:
							EventBus.emit_toast("Comprou um amuleto na estrada!", Color(0.55, 0.95, 0.45))
					elif EventBus != null:
						EventBus.emit_toast("Jenny insuficiente — o comerciante ri e parte.", Color(1.0, 0.5, 0.35))
				"rumor":
					if StoryManager != null:
						StoryManager.set_story_flag("rumor_zaban_sumico", true)
					if EventBus != null:
						EventBus.emit_toast("Rumor anotado: sumiço perto das Ruínas de Zaban.", Color(0.85, 0.8, 0.4))
		"patrulha_associacao":
			if escolha == "mostrar" and ReputationSystem != null and ReputationSystem.has_method("modificar_reputacao"):
				ReputationSystem.modificar_reputacao("associacao_hunter", 5)
			elif escolha == "perguntar" and EventBus != null:
				EventBus.emit_toast("Patrulha: 'Aura estranha nas Ruínas. Cuidado.'", Color(0.7, 0.85, 1.0))
		"emboscada_leve":
			match escolha:
				"enfrentar":
					# Micro-recompensa de combate simbólico
					var player = get_tree().get_first_node_in_group("player") if get_tree() else null
					if player != null:
						var xp_sys = player.get_node_or_null("XPSystem")
						if xp_sys != null:
							xp_sys.adicionar_xp(40, "Emboscada na Estrada")
					if not PlayerData.tem_item(&"adaga_zaban"):
						PlayerData.adicionar_item(&"adaga_zaban", 1)
						if EventBus != null:
							EventBus.emit_toast("O bandido largou uma Adaga de Zaban!", Color(1.0, 0.85, 0.35))
				"fugir":
					PlayerData.attributes["aura"] = max(5.0, float(PlayerData.attributes.get("aura", 50)) - 8.0)
					if EventBus != null:
						EventBus.emit_toast("Você escapou — um pouco de aura gasta na corrida.", Color(0.8, 0.75, 0.5))
				"blefar":
					if EventBus != null:
						EventBus.emit_toast("O bandido recua. Sua postura de Hunter funcionou.", Color(0.55, 0.95, 0.55))


func classificar_cena(duracao_segundos: float) -> SceneCategory:
	if duracao_segundos <= 20.0:
		return SceneCategory.MICRO_SCENE
	elif duracao_segundos <= 60.0:
		return SceneCategory.CHARACTER_SCENE
	elif duracao_segundos <= 180.0:
		return SceneCategory.STORY_SCENE
	return SceneCategory.MAJOR_CUTSCENE


func _on_combat_started() -> void:
	if StoryManager != null:
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.COMBAT_EVENT)


func _on_combat_ended() -> void:
	notificar_combate_concluido()
	if StoryManager != null:
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)
