class_name SimpleGrassTerrainPolicy
extends RefCounted

# ============================================================
# HUNTER ONLINE — Terreno temporário: só grama, sem estruturas
# ============================================================
# Política visual interim: todos os cenários usam grama verde
# simples e não plantam props/estruturas que destoam do estilo.
# Gameplay (NPCs, inimigos, sensores Nen, baús) permanece.
# ============================================================

## Liga o modo "grama limpa" em todos os mapas.
const ENABLED := true

## Mantém vegetação leve (arbustos/flores) se false remove tudo.
const ALLOW_LIGHT_VEGETATION := false


static func strip_structures() -> bool:
	return ENABLED


static func plant_structure_props() -> bool:
	return not ENABLED


static func grass_modulate() -> Color:
	return Color(0.55, 1.05, 0.62, 1.0)


static func apply_to_map(mapa: Node2D) -> void:
	if not ENABLED or mapa == null:
		return
	_clear_structure_layers(mapa)
	_ensure_simple_grass_floor(mapa)
	_hide_mismatched_prop_roots(mapa)


static func _clear_structure_layers(mapa: Node2D) -> void:
	for layer_name in [
		"Estruturas_TileMapLayer",
		"Paredes_TileMapLayer",
		"Decor_TileMapLayer",
		"Praca_TileMapLayer",
		"Caminhos_TileMapLayer",
	]:
		var layer := mapa.get_node_or_null(layer_name) as TileMapLayer
		if layer == null:
			continue
		# Estruturas/paredes: limpa tudo. Caminhos/decor: só limpa se strip total.
		if layer_name == "Estruturas_TileMapLayer" or layer_name == "Paredes_TileMapLayer":
			layer.clear()
			layer.visible = false
		elif layer_name == "Decor_TileMapLayer" or layer_name == "Praca_TileMapLayer":
			layer.clear()
			layer.visible = false
		elif layer_name == "Caminhos_TileMapLayer":
			# Mantém caminhabilidade limpa — só grama por baixo
			layer.clear()
			layer.visible = false

	var chao := mapa.get_node_or_null("Chao_TileMapLayer") as TileMapLayer
	if chao != null:
		chao.modulate = grass_modulate()
		chao.visible = true


static func _ensure_simple_grass_floor(mapa: Node2D) -> void:
	if mapa.get_node_or_null("SimpleGrassFloor") != null:
		return
	var path := "res://assets/sprites/tilesets/grass.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/tilesets/plains.png"
	if not ResourceLoader.exists(path):
		return
	var tex := load(path) as Texture2D
	if tex == null:
		return
	var spr := Sprite2D.new()
	spr.name = "SimpleGrassFloor"
	spr.texture = tex
	spr.modulate = grass_modulate()
	spr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	spr.region_enabled = true
	spr.region_rect = Rect2(0, 0, 12000, 8000)
	spr.centered = true
	spr.position = Vector2(2000, 0)
	spr.z_index = -100
	mapa.add_child(spr)


static func _hide_mismatched_prop_roots(mapa: Node2D) -> void:
	for root_name in [
		"PropsEstruturaYorknew",
		"PropsEstruturaNGL",
		"PropsEstruturaArena",
		"PropsEstruturaKukuroo",
		"PropsEstruturaGreed",
		"PropsEstruturaAssociacao",
		"PropsEstruturaContinente",
		"PropsEstruturaBlackWhale",
		"LobbyPixelDecorRoot",
		"Phase3Props",
		"Phase4Landmarks",
		"Phase6Polish",
		"Phase6Story",
		"WorldPropsKit",
		"WorldLandmarkKit",
		"WorldPolishKit",
	]:
		var n := mapa.get_node_or_null(root_name)
		if n != null:
			n.visible = false
			n.queue_free()
