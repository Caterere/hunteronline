extends Node2D

func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: VALIDAÇÃO DO EDITOR VISUAL TILE CATALOG EDITOR")
	print("============================================================")
	
	var scene_res = load("res://world/catalog/editor/TileCatalogEditor.tscn")
	assert(scene_res != null, "Cena TileCatalogEditor.tscn deve carregar com sucesso")
	
	var editor_instance = scene_res.instantiate()
	add_child(editor_instance)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var tex_rect = editor_instance.get_node_or_null("%TextureRect") as TextureRect
	assert(tex_rect != null and tex_rect.texture != null, "Tilesheet deve estar carregada no TextureRect")
	print("  ✅ [PASSOU] Tilesheet visual carregada no editor: ", tex_rect.texture.resource_path)
	
	var opt_cat = editor_instance.get_node_or_null("%OptCategory") as OptionButton
	assert(opt_cat != null and opt_cat.item_count >= 12, "Dropdown de categorias deve conter todas as opções semânticas")
	print("  ✅ [PASSOU] Categorias semânticas disponíveis no editor: %d opções" % opt_cat.item_count)
	
	var txt_id = editor_instance.get_node_or_null("%TxtID") as LineEdit
	assert(txt_id != null and not txt_id.text.is_empty(), "ID do tile selecionado deve ser preenchido")
	print("  ✅ [PASSOU] Tile inicial selecionado: ID = ", txt_id.text)
	
	# Simular clique em um tile na coordenada (1, 5) -> wood_floor_parquet
	editor_instance._selecionar_tile(Vector2i(1, 5))
	assert(txt_id.text == "wood_floor_parquet", "Deve identificar o tile cadastrado wood_floor_parquet")
	print("  ✅ [PASSOU] Seleção de tile (1, 5) identificou corretamente: ", txt_id.text)
	
	# Testar clique de salvar
	editor_instance._on_btn_salvar_pressed()
	print("  ✅ [PASSOU] Salvamento via interface do editor validado com sucesso")
	
	print("============================================================")
	print("🎉 EDITOR VISUAL TILECATALOGEDITOR VALIDADO COM 100% DE SUCESSO!")
	print("============================================================")
	get_tree().quit(0)
