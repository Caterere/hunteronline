class_name MapVisualDecorator
extends Node2D

# ============================================================
# HUNTER ONLINE - MAP VISUAL DECORATOR (CHÃO UNIVERSAL)
# ============================================================
#
# Preenche o chão com textura em repetição (texture_repeat)
# e z_index = -100 para evitar vazios. Estilos por mapa HxH.
#
# ============================================================

enum EstiloMapa {
	MARATONA_EXAME,
	ARENA_CELESTIAL,
	GREED_ISLAND,
	YORKNEW_CITY,
	KUKUROO_MOUNTAIN
}

@export var estilo: EstiloMapa = EstiloMapa.MARATONA_EXAME
@export var largura_mapa: float = 6000.0
@export var altura_mapa: float = 4000.0

const PATH_GRASS = "res://assets/sprites/tilesets/grass.png"
const PATH_PLAINS = "res://assets/sprites/tilesets/plains.png"


func _ready() -> void:
	_criar_chao_base()


func _criar_chao_base() -> void:
	if get_node_or_null("ChaoGramaUniversal") != null:
		return

	var path: String = PATH_GRASS
	var modulate := Color.WHITE
	match estilo:
		EstiloMapa.YORKNEW_CITY:
			# Calçada / asfalto visual — plains com tint noite urbana
			path = PATH_PLAINS if ResourceLoader.exists(PATH_PLAINS) else PATH_GRASS
			modulate = Color(0.55, 0.58, 0.68, 1.0)
		EstiloMapa.KUKUROO_MOUNTAIN:
			path = PATH_GRASS
			modulate = Color(0.62, 0.72, 0.55, 1.0)
		EstiloMapa.ARENA_CELESTIAL:
			path = PATH_PLAINS if ResourceLoader.exists(PATH_PLAINS) else PATH_GRASS
			modulate = Color(0.85, 0.82, 0.75, 1.0)
		_:
			path = PATH_GRASS
			modulate = Color.WHITE

	var tex = load(path) as Texture2D
	if tex == null:
		return

	var spr := Sprite2D.new()
	spr.name = "ChaoGramaUniversal"
	spr.texture = tex
	spr.modulate = modulate
	spr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	spr.region_enabled = true

	var w: float = max(largura_mapa, 6000.0) + 4000.0
	var h: float = max(altura_mapa, 4000.0) + 4000.0
	spr.region_rect = Rect2(-2000.0, -2000.0, w, h)
	spr.position = Vector2(largura_mapa / 2.0, altura_mapa / 2.0)
	spr.z_index = -100
	add_child(spr)
