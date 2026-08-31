class_name MapVisualDecorator
extends Node2D

# ============================================================
# HUNTER ONLINE - MAP VISUAL DECORATOR (CHÃO UNIVERSAL DE GRAMA)
# ============================================================
#
# Preenche todo o chão dos mapas com a textura oficial grass.png
# em repetição contínua (texture_repeat) e z_index = -100 para
# garantir que nenhum elemento fique flutuando no vazio.
#
# ============================================================

enum EstiloMapa {
	MARATONA_EXAME,
	ARENA_CELESTIAL,
	GREED_ISLAND
}

@export var estilo: EstiloMapa = EstiloMapa.MARATONA_EXAME
@export var largura_mapa: float = 6000.0
@export var altura_mapa: float = 4000.0

const PATH_GRASS = "res://assets/sprites/tilesets/grass.png"


func _ready() -> void:
	_criar_chao_grama_universal()


func _criar_chao_grama_universal() -> void:
	if get_node_or_null("ChaoGramaUniversal") != null:
		return

	var tex = load(PATH_GRASS) as Texture2D
	if tex == null:
		return

	var spr := Sprite2D.new()
	spr.name = "ChaoGramaUniversal"
	spr.texture = tex
	spr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	spr.region_enabled = true

	# Dimensões generosas com margens para cobrir toda a área navegável
	var w: float = max(largura_mapa, 6000.0) + 4000.0
	var h: float = max(altura_mapa, 4000.0) + 4000.0
	spr.region_rect = Rect2(-2000.0, -2000.0, w, h)
	spr.position = Vector2(largura_mapa / 2.0, altura_mapa / 2.0)
	spr.z_index = -100
	add_child(spr)
