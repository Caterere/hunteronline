class_name TileCatalogEditor
extends Control

# ============================================================
# HUNTER ONLINE - TILE CATALOG EDITOR (EDITOR VISUAL DE CATÁLOGO)
# ============================================================
#
# Ferramenta visual interativa para catalogação e classificação de tiles:
# - Visualização da Tilesheet com grade 16x16 overlay
# - Seleção de tiles por clique do mouse
# - Painel de propriedades para definir ID, Categoria, Tags e Regras
# - Suporte a objetos multi-tile (Largura x Altura)
# - Persistência direta em JSON e integração com TileDatabase
#
# ============================================================

const TileDatabaseScript = preload("res://world/catalog/TileDatabase.gd")
const TileDataEntryScript = preload("res://world/catalog/TileDataEntry.gd")
const CompositeTileObjectScript = preload("res://world/catalog/CompositeTileObject.gd")

@onready var texture_rect: TextureRect = get_node_or_null("%TextureRect")
@onready var grid_overlay: Control = get_node_or_null("%GridOverlay")
@onready var selection_rect: ColorRect = get_node_or_null("%SelectionRect")
@onready var preview_rect: TextureRect = get_node_or_null("%PreviewRect")

@onready var txt_id: LineEdit = get_node_or_null("%TxtID")
@onready var opt_category: OptionButton = get_node_or_null("%OptCategory")
@onready var txt_subcategory: LineEdit = get_node_or_null("%TxtSubcategory")
@onready var txt_tags: LineEdit = get_node_or_null("%TxtTags")
@onready var chk_walkable: CheckBox = get_node_or_null("%ChkWalkable")
@onready var chk_collision: CheckBox = get_node_or_null("%ChkCollision")
@onready var chk_repeatable: CheckBox = get_node_or_null("%ChkRepeatable")
@onready var spin_width: SpinBox = get_node_or_null("%SpinWidth")
@onready var spin_height: SpinBox = get_node_or_null("%SpinHeight")
@onready var opt_orientation: OptionButton = get_node_or_null("%OptOrientation")
@onready var opt_source: OptionButton = get_node_or_null("%OptSource")
@onready var lbl_status: Label = get_node_or_null("%LblStatus")

var tile_size: int = 16
var selected_coords: Vector2i = Vector2i.ZERO
var current_source_path: String = ""
var current_source_id: int = 0
var db: RefCounted = null


func _ready() -> void:
	db = TileDatabaseScript.get_instance()
	_popular_opcoes_categoria()
	_popular_opcoes_orientacao()
	_popular_opcoes_source()
	_carregar_tilesheet(0)


func _popular_opcoes_categoria() -> void:
	if opt_category == null: return
	opt_category.clear()
	for cat in TileDataEntryScript.Category.values():
		opt_category.add_item(TileDataEntryScript.category_to_string(cat), cat)


func _popular_opcoes_orientacao() -> void:
	if opt_orientation == null: return
	opt_orientation.clear()
	for ori in TileDataEntryScript.Orientation.values():
		opt_orientation.add_item(TileDataEntryScript.orientation_to_string(ori), ori)


func _popular_opcoes_source() -> void:
	if opt_source == null: return
	opt_source.clear()
	opt_source.add_item("Room Builder (Pisos, Paredes, Portas)", 0)
	opt_source.add_item("Interiors (Móveis, Decorações, Camas)", 1)
	if not opt_source.item_selected.is_connected(_carregar_tilesheet):
		opt_source.item_selected.connect(_carregar_tilesheet)


func _carregar_tilesheet(index: int) -> void:
	current_source_id = index
	match index:
		0: current_source_path = TileDatabaseScript.PATH_ROOM_BUILDER
		1: current_source_path = TileDatabaseScript.PATH_INTERIORS
		
	var tex = load(current_source_path) as Texture2D
	if tex != null and texture_rect != null:
		texture_rect.texture = tex
		texture_rect.custom_minimum_size = Vector2(tex.get_width(), tex.get_height())
		if grid_overlay:
			grid_overlay.queue_redraw()
		_selecionar_tile(Vector2i(0, 0))


func _gui_input_tilesheet(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos_local = event.position
		var tile_x = int(pos_local.x / tile_size)
		var tile_y = int(pos_local.y / tile_size)
		_selecionar_tile(Vector2i(tile_x, tile_y))


func _selecionar_tile(coords: Vector2i) -> void:
	selected_coords = coords
	
	# Atualizar retângulo de seleção visual
	if selection_rect != null:
		selection_rect.position = Vector2(coords.x * tile_size, coords.y * tile_size)
		var w = int(spin_width.value) if spin_width else 1
		var h = int(spin_height.value) if spin_height else 1
		selection_rect.size = Vector2(w * tile_size, h * tile_size)
		
	# Atualizar Preview do Tile Selecionado
	if preview_rect != null and texture_rect != null and texture_rect.texture != null:
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = texture_rect.texture
		atlas_tex.region = Rect2(coords.x * tile_size, coords.y * tile_size, tile_size, tile_size)
		preview_rect.texture = atlas_tex
		
	# Buscar no banco se já existe cadastro para este tile
	var tile_encontrado: Resource = null
	if db != null:
		for t in db.tiles.values():
			var entry = t as Resource
			if entry.source_id == current_source_id and entry.atlas_coords == coords:
				tile_encontrado = entry
				break
				
	if tile_encontrado != null:
		_preencher_formulario(tile_encontrado)
		_exibir_status("Tile carregado do catálogo: " + tile_encontrado.id, Color.GREEN)
	else:
		_limpar_formulario_para_novo(coords)
		_exibir_status("Novo Tile selecionado (%d, %d)" % [coords.x, coords.y], Color.YELLOW)


func _preencher_formulario(entry: Resource) -> void:
	if txt_id: txt_id.text = entry.id
	if opt_category: opt_category.select(entry.category)
	if txt_subcategory: txt_subcategory.text = entry.subcategory
	if txt_tags: txt_tags.text = ", ".join(entry.tags)
	if chk_walkable: chk_walkable.button_pressed = entry.walkable
	if chk_collision: chk_collision.button_pressed = entry.collision
	if chk_repeatable: chk_repeatable.button_pressed = entry.repeatable
	if spin_width: spin_width.value = entry.size_in_tiles.x
	if spin_height: spin_height.value = entry.size_in_tiles.y
	if opt_orientation: opt_orientation.select(entry.orientation)


func _limpar_formulario_para_novo(coords: Vector2i) -> void:
	var prefix = "tile_rb" if current_source_id == 0 else "tile_int"
	if txt_id: txt_id.text = "%s_%d_%d" % [prefix, coords.x, coords.y]
	if opt_category: opt_category.select(TileDataEntryScript.Category.UNKNOWN)
	if txt_subcategory: txt_subcategory.text = ""
	if txt_tags: txt_tags.text = "interior"
	if chk_walkable: chk_walkable.button_pressed = true
	if chk_collision: chk_collision.button_pressed = false
	if chk_repeatable: chk_repeatable.button_pressed = false
	if spin_width: spin_width.value = 1
	if spin_height: spin_height.value = 1
	if opt_orientation: opt_orientation.select(TileDataEntryScript.Orientation.NONE)


func _on_btn_salvar_pressed() -> void:
	if txt_id == null or txt_id.text.strip_edges().is_empty():
		_exibir_status("Erro: ID do tile não pode ser vazio!", Color.RED)
		return
		
	var entry = TileDataEntryScript.new()
	entry.id = txt_id.text.strip_edges()
	entry.source_texture_path = current_source_path
	entry.source_id = current_source_id
	entry.atlas_coords = selected_coords
	entry.category = opt_category.selected if opt_category else TileDataEntryScript.Category.UNKNOWN
	entry.subcategory = txt_subcategory.text.strip_edges() if txt_subcategory else ""
	
	if txt_tags != null:
		entry.tags.clear()
		for tag in txt_tags.text.split(","):
			var clean = tag.strip_edges()
			if not clean.is_empty():
				entry.tags.append(clean)
				
	entry.walkable = chk_walkable.button_pressed if chk_walkable else true
	entry.collision = chk_collision.button_pressed if chk_collision else false
	entry.repeatable = chk_repeatable.button_pressed if chk_repeatable else false
	entry.size_in_tiles = Vector2i(int(spin_width.value), int(spin_height.value)) if (spin_width and spin_height) else Vector2i(1, 1)
	entry.orientation = opt_orientation.selected if opt_orientation else TileDataEntryScript.Orientation.NONE
	
	# Se for objeto multi-tile (> 1x1), cadastrar também como CompositeTileObject
	if entry.size_in_tiles.x > 1 or entry.size_in_tiles.y > 1:
		var comp = CompositeTileObjectScript.new()
		comp.id = entry.id
		comp.display_name = entry.id.capitalize()
		comp.category = TileDataEntryScript.category_to_string(entry.category)
		comp.subcategory = entry.subcategory
		comp.size_in_tiles = entry.size_in_tiles
		comp.tags = entry.tags.duplicate()
		comp.parts.clear()
		
		for dy in range(entry.size_in_tiles.y):
			for dx in range(entry.size_in_tiles.x):
				comp.parts.append({
					"dx": dx,
					"dy": dy,
					"source_id": entry.source_id,
					"atlas_coords": [entry.atlas_coords.x + dx, entry.atlas_coords.y + dy],
					"layer": 2,
					"collision": entry.collision
				})
		db.register_composite_object(comp)
		
	db.register_tile(entry)
	db.save_to_json()
	_exibir_status("✅ Tile [%s] salvo com sucesso no catálogo!" % entry.id, Color.GREEN)


func _on_btn_exportar_json_pressed() -> void:
	var err = db.save_to_json()
	if err == OK:
		_exibir_status("🎉 Catálogo exportado para JSON com sucesso!", Color.GREEN)
	else:
		_exibir_status("❌ Erro ao exportar JSON: %d" % err, Color.RED)


func _exibir_status(msg: String, cor: Color) -> void:
	if lbl_status != null:
		lbl_status.text = msg
		lbl_status.add_theme_color_override("font_color", cor)
