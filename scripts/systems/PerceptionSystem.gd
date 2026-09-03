# scripts/systems/PerceptionSystem.gd
extends Node

## PerceptionSystem — Single Source of Truth para Percepção, Detecção, Sentidos e Consciência.
## Desacopla cálculos de visão, ruído, stealth (Zetsu), emissão de aura (Ren/En) e segredos (Gyo).

signal alerta_emitido(origem: Node2D, alvo: Node2D, nivel_alerta: String)
signal segredo_revelado(segredo: Node2D, nivel_percepcao: int)

enum AwarenessLevel {
	IDLE,
	SUSPICIOUS,
	ALERT,
	CHASE,
	SEARCH,
	RETURN
}

func _ready() -> void:
	print("=================================")
	print("[PerceptionSystem] CAMADA CENTRAL DE SENTIDOS ATIVA")
	print("=================================")


## Calcula o raio efetivo de detecção de um observador contra um alvo
func calcular_raio_deteccao_efetivo(observador: Node, alvo: Node) -> float:
	if observador == null or not is_instance_valid(observador):
		return 0.0

	var range_base: float = 250.0
	if "detection_range" in observador:
		range_base = float(observador.detection_range)
	elif observador != null:
		var ai = observador.get_node_or_null("EnemyAI")
		if ai == null:
			for ch in observador.get_children():
				if "detection_range" in ch:
					ai = ch
					break
		if ai != null and "detection_range" in ai:
			range_base = float(ai.detection_range)

	if alvo == null or not is_instance_valid(alvo):
		return range_base

	# 1. Avaliar técnica de Nen do alvo (Zetsu vs Ren)
	var nen_sys = alvo.get_node_or_null("NenSystem")
	if nen_sys == null:
		for ch in alvo.get_children():
			if ch.has_method("esta_em_zetsu"):
				nen_sys = ch
				break

	if nen_sys != null:
		if nen_sys.has_method("esta_em_zetsu") and nen_sys.esta_em_zetsu():
			var fator_stealth: float = nen_sys.obter_fator_stealth_zetsu() if nen_sys.has_method("obter_fator_stealth_zetsu") else 0.20
			return range_base * (1.0 - fator_stealth)
		elif nen_sys.has_method("esta_em_ren") and nen_sys.esta_em_ren():
			return range_base * 1.30

	# 2. Modificador de Infâmia no mundo
	if WorldState != null and WorldState.has_method("obter_infamia") and WorldState.obter_infamia() >= 100:
		return range_base * 1.40

	return range_base


## Avalia se o alvo está dentro da percepção do observador
func verificar_alvo_detectado(observador: Node, alvo: Node) -> bool:
	if observador == null or alvo == null or not is_instance_valid(observador) or not is_instance_valid(alvo):
		return false
	var pos_obs: Vector2 = observador.global_position if (observador is Node2D) else (observador.get_parent().global_position if (observador.get_parent() is Node2D) else Vector2.ZERO)
	var pos_alvo: Vector2 = alvo.global_position if (alvo is Node2D) else (alvo.get_parent().global_position if (alvo.get_parent() is Node2D) else Vector2.ZERO)
	var dist = pos_obs.distance_to(pos_alvo)
	var raio_efetivo = calcular_raio_deteccao_efetivo(observador, alvo)
	return dist <= raio_efetivo


## Avalia a revelação de segredos e pistas no mapa
func avaliar_visibilidade_segredo(nivel_gyo_jogador: int, gyo_ativo: bool, nivel_minimo_segredo: int, requer_gyo: bool) -> bool:
	if not requer_gyo:
		return true
	return gyo_ativo and (nivel_gyo_jogador >= nivel_minimo_segredo)


## Detecta entidades dentro de uma cúpula de En
func detectar_entidades_no_raio(centro: Vector2, raio: float, tree: SceneTree, grupo: String = "enemies") -> Array[Node2D]:
	var encontradas: Array[Node2D] = []
	if tree == null:
		return encontradas

	var candidatos = tree.get_nodes_in_group(grupo)
	for cand in candidatos:
		if cand is Node2D and is_instance_valid(cand):
			if cand.global_position.distance_to(centro) <= raio:
				encontradas.append(cand)
	return encontradas
