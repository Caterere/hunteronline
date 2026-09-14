class_name MapVisualDecorator
extends Node2D

# ============================================================
# HUNTER ONLINE - MAP VISUAL DECORATOR (CHÃO UNIVERSAL)
# Fallback de chão repetido + tint por saga (sem PixelLab).
# ============================================================

enum EstiloMapa {
	MARATONA_EXAME,
	ARENA_CELESTIAL,
	GREED_ISLAND,
	YORKNEW_CITY,
	KUKUROO_MOUNTAIN,
	NGL_FORMIGAS,
	ASSOCIACAO_HUNTER,
	CONTINENTE_NEGRO,
	BLACK_WHALE,
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
			path = PATH_PLAINS if ResourceLoader.exists(PATH_PLAINS) else PATH_GRASS
			modulate = Color(0.45, 0.48, 0.58, 1.0)
		EstiloMapa.KUKUROO_MOUNTAIN:
			path = PATH_GRASS
			modulate = Color(0.62, 0.72, 0.55, 1.0)
		EstiloMapa.ARENA_CELESTIAL:
			path = PATH_PLAINS if ResourceLoader.exists(PATH_PLAINS) else PATH_GRASS
			modulate = Color(0.85, 0.82, 0.75, 1.0)
		EstiloMapa.GREED_ISLAND:
			path = PATH_GRASS
			modulate = Color(0.55, 1.05, 0.65, 1.0)
		EstiloMapa.NGL_FORMIGAS:
			path = PATH_GRASS
			modulate = Color(0.45, 0.70, 0.48, 1.0)
		EstiloMapa.ASSOCIACAO_HUNTER:
			path = PATH_PLAINS if ResourceLoader.exists(PATH_PLAINS) else PATH_GRASS
			modulate = Color(0.78, 0.82, 0.88, 1.0)
		EstiloMapa.CONTINENTE_NEGRO:
			path = PATH_PLAINS if ResourceLoader.exists(PATH_PLAINS) else PATH_GRASS
			modulate = Color(0.42, 0.30, 0.45, 1.0)
		EstiloMapa.BLACK_WHALE:
			path = PATH_PLAINS if ResourceLoader.exists(PATH_PLAINS) else PATH_GRASS
			modulate = Color(0.55, 0.48, 0.42, 1.0)
		_:
			path = PATH_GRASS
			modulate = Color(0.70, 0.95, 0.65, 1.0)

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
