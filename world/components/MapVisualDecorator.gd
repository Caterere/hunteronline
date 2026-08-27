class_name MapVisualDecorator
extends Node2D

# ============================================================
# HUNTER ONLINE - MAP VISUAL DECORATOR (DESATIVADO PARA TILEMAPS)
# ============================================================
#
# As texturas procedurais automáticas foram desativadas a pedido
# do usuário para permitir a pintura manual de TileMaps no Godot Editor.
#
# ============================================================

enum EstiloMapa {
	MARATONA_EXAME,
	ARENA_CELESTIAL,
	GREED_ISLAND
}

@export var estilo: EstiloMapa = EstiloMapa.MARATONA_EXAME
@export var largura_mapa: float = 2400.0
@export var altura_mapa: float = 1800.0


func _ready() -> void:
	# Não desenha nada automaticamente para deixar o mapa limpo para o TileMap do usuário
	pass
