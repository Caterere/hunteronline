class_name CinematicCameraController
extends Node

# ============================================================
# HUNTER ONLINE - CINEMATIC CAMERA CONTROLLER (CÂMERA DINÂMICA)
# ============================================================
#
# Controla transições suaves de foco, zoom e enquadramento entre
# modo normal de gameplay e tomadas cinematográficas para diálogos.
#
# ============================================================

signal foco_iniciado(alvo_nome: String)
signal foco_concluido(alvo_nome: String)
signal camera_restaurada()

var _camera_alvo: Camera2D = null
var _player_ref: Node2D = null
var _em_cinematic_mode: bool = false
var _zoom_original: Vector2 = Vector2.ONE


func _ready() -> void:
	add_to_group("cinematic_camera_controller")


func configurar_com_player(player: Node2D) -> void:
	_player_ref = player
	if _player_ref != null:
		_camera_alvo = _player_ref.get_node_or_null("Camera2D") as Camera2D
		if _camera_alvo != null:
			_zoom_original = _camera_alvo.zoom


func transicionar_para_alvo(alvo: Node2D, zoom_level: float = 1.25, duracao: float = 0.7) -> void:
	if _camera_alvo == null or alvo == null or not is_instance_valid(alvo):
		return

	_em_cinematic_mode = true
	var nome_alvo = alvo.name
	foco_iniciado.emit(nome_alvo)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_camera_alvo, "global_position", alvo.global_position, duracao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_camera_alvo, "zoom", Vector2(zoom_level, zoom_level), duracao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished
	foco_concluido.emit(nome_alvo)


func restaurar_para_player(duracao: float = 0.6) -> void:
	if _camera_alvo == null:
		return

	var tween = create_tween()
	tween.set_parallel(true)
	if _player_ref != null and is_instance_valid(_player_ref):
		tween.tween_property(_camera_alvo, "position", Vector2.ZERO, duracao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_camera_alvo, "zoom", _zoom_original, duracao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished
	_em_cinematic_mode = false
	camera_restaurada.emit()
