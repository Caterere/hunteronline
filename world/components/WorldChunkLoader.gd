class_name WorldChunkLoader
extends Node2D

# ============================================================
# HUNTER ONLINE - WORLD CHUNK STREAMING & PERFORMANCE
# ============================================================
#
# Gerencia o streaming de chunks do mapa para permitir mundos
# gigantescos mantendo 60 FPS estáveis:
# - Chunks próximos (< 800px): Processamento ativo e visível.
# - Chunks distantes (> 800px): Pausados (PROCESS_MODE_DISABLED) e ocultados.
# - Atualização periódica leve (a cada 0.3s).
#
# ============================================================

@export var raio_ativo: float = 850.0
@export var intervalo_atualizacao: float = 0.3

var timer: float = 0.0
var jogador: Node2D = null
var chunks: Array[Node2D] = []

func _ready() -> void:
	add_to_group("world_chunk_loader")
	_coletar_chunks()
	_localizar_jogador()
	atualizar_chunks()

func _coletar_chunks() -> void:
	chunks.clear()
	for child in get_children():
		if child is Node2D:
			chunks.append(child as Node2D)

func _localizar_jogador() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		jogador = players[0] as Node2D

func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		timer = intervalo_atualizacao
		if jogador == null or not is_instance_valid(jogador):
			_localizar_jogador()
		if jogador != null:
			atualizar_chunks()

func atualizar_chunks() -> void:
	if jogador == null:
		return
		
	var pos_jogador = jogador.global_position
	
	for chunk in chunks:
		if chunk == null or not is_instance_valid(chunk):
			continue
			
		var dist = chunk.global_position.distance_to(pos_jogador)
		var deve_ativar = dist <= raio_ativo
		
		if deve_ativar:
			if chunk.process_mode != PROCESS_MODE_INHERIT:
				chunk.process_mode = PROCESS_MODE_INHERIT
				chunk.visible = true
		else:
			if chunk.process_mode != PROCESS_MODE_DISABLED:
				chunk.process_mode = PROCESS_MODE_DISABLED
				chunk.visible = false
