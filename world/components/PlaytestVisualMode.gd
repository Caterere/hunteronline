class_name PlaytestVisualMode
extends RefCounted

# ============================================================
# PLAYTEST VISUAL MODE — grama base sem tiles/props aleatórios
# ============================================================
# Objetivo: playtest de fases/balance com chão legível, sem Wang
# PixelLab nem kits de densidade visual (árvores/rochas/landmarks).
# Portais, NPCs, inimigos, sensores Nen e baús de gameplay ficam.
#
# Desligar arte completa:
#   ProjectSettings.set_setting("hunter_online/playtest_grass_floor", false)
# ou altere ENABLED_DEFAULT abaixo.
# ============================================================

const ENABLED_DEFAULT := true
const PATH_GRASS := "res://assets/sprites/tilesets/grass.png"
const SETTING_KEY := "hunter_online/playtest_grass_floor"


static func is_enabled() -> bool:
	if ProjectSettings.has_setting(SETTING_KEY):
		return bool(ProjectSettings.get_setting(SETTING_KEY))
	return ENABLED_DEFAULT


## Aplica Sprite2D de grama repetida. Retorna true se o modo playtest está ativo
## (caller deve pular WangFloor + WorldDensity/Props/Landmark/Fx/Polish).
static func apply_grass_floor(
	map: Node2D,
	size: Vector2 = Vector2(3200, 2400),
	tint: Color = Color(0.70, 0.95, 0.65, 1.0)
) -> bool:
	if not is_enabled() or map == null:
		return false
	if map.get_node_or_null("ChaoGramaPlaytest") != null:
		return true

	var tex: Texture2D = null
	if ResourceLoader.exists(PATH_GRASS):
		tex = load(PATH_GRASS) as Texture2D
	if tex == null:
		push_warning("[PlaytestVisualMode] grass.png ausente — piso playtest não criado.")
		return true

	var spr := Sprite2D.new()
	spr.name = "ChaoGramaPlaytest"
	spr.texture = tex
	spr.modulate = tint
	spr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	spr.region_enabled = true
	var w: float = maxf(size.x, 800.0) + 800.0
	var h: float = maxf(size.y, 600.0) + 800.0
	spr.region_rect = Rect2(-400.0, -400.0, w, h)
	spr.position = Vector2(size.x * 0.5, size.y * 0.5)
	spr.z_index = -100
	map.add_child(spr)
	# Esconde TileMapLayers de chão já existentes (se houver) para não competir
	_ocultar_tilemaps_chao(map)
	print("[PlaytestVisualMode] Grama playtest em %s (%.0fx%.0f)" % [map.name, size.x, size.y])
	return true


static func _ocultar_tilemaps_chao(map: Node2D) -> void:
	for child in map.get_children():
		if child is TileMapLayer:
			var n := String(child.name).to_lower()
			if "parede" in n or "wall" in n or "colis" in n:
				continue
			# Esconde só camadas de piso/decor visual; colisão permanece se for outra layer
			if "piso" in n or "chao" in n or "floor" in n or "decor" in n or "grama" in n:
				(child as CanvasItem).visible = false
		elif child is TileMap:
			(child as CanvasItem).visible = false
