class_name StoryPacingManager
extends Node

# ============================================================
# HUNTER ONLINE - STORY PACING MANAGER (RITMO E RESPIRAS NARRATIVAS)
# ============================================================
#
# Controla a cadência da experiência de jogo:
# - Alternância saudável entre ação/combate intenso e respiro/exploração.
# - Rastreia tempo em combate contínuo e tempo em exploração/cidades.
# - Despacha micro-cenas e eventos de viagem (road encounters).
# - Apoia o ritmo variado do mangá de Hunter x Hunter.
#
# ============================================================

signal respiro_sugerido(motivo: String)
signal micro_evento_viagem_iniciado(titulo: String, tipo: String)

enum SceneCategory {
	MICRO_SCENE,       # 5 a 20 segundos: interação rápida de rua ou observação
	CHARACTER_SCENE,   # 20 a 60 segundos: desenvolvimento de relacionamento/humor
	STORY_SCENE,       # 1 a 3 minutos: virada narrativa ou encontro canônico
	MAJOR_CUTSCENE     # 3+ minutos: clímax de saga ou transição monumental
}

var tempo_em_combate: float = 0.0
var tempo_em_exploracao: float = 0.0
var combates_consecutivos: int = 0
var ultimo_respiro_timestamp: float = 0.0

const LIMITE_COMBATES_PARA_RESPIRO: int = 4
const TEMPO_MINIMO_RESPIRO: float = 120.0 # 2 minutos


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
	print("[StoryPacingManager] 🍃 MOMENTO DE RESPIRO SUGERIDO: %s" % motivo)


func iniciar_evento_viagem(ponto_origem: String, ponto_destino: String, evento_id: String = "estrada_comerciante") -> void:
	print("[StoryPacingManager] 🛤️ VIAGEM INICIADA: %s -> %s (Evento: %s)" % [ponto_origem, ponto_destino, evento_id])
	micro_evento_viagem_iniciado.emit("Viagem pela Estrada Regional", evento_id)
	if StoryManager != null:
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)


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
