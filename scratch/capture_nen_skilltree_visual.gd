extends Node

# Captura screenshots da NenSkillTreeUI polida para walkthrough.
const NenSkillTreeUIScript = preload("res://ui/SkillTree/NenSkillTreeUI.gd")

func _ready() -> void:
	await get_tree().process_frame
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel_nen(3)
	PlayerData.nen_skill_points = 25
	var tree = PlayerData.obter_skill_tree()
	if tree != null:
		for nid in [&"nexus_center", &"ten_1", &"ten_2", &"ren_1", &"ren_2", &"gyo_1", &"zetsu_1"]:
			if tree.pode_investir(nid) or tree.no_desbloqueado(nid):
				if not tree.no_desbloqueado(nid):
					tree.investir_ponto(nid)

	var root := CanvasLayer.new()
	root.layer = 80
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Color(0.09, 0.06, 0.035, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var ui = NenSkillTreeUIScript.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.set_deferred("size", Vector2(1280, 720))
	root.add_child(ui)
	ui.is_fullscreen = true
	ui._atualizar_layout_responsivo()
	ui._centralizar_no_nexus()
	ui.selected_node_id = &"ren_2"
	ui._rebuild_path_highlight(&"ren_2")
	ui._atualizar_inspector()
	ui._fx_time = 1.4
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout

	_save_shot("nen_skilltree_polish_overview.png")

	ui.search_filter = "ten"
	ui._rebuild_search_matches()
	ui._ir_proximo_match_busca()
	ui._fx_time = 2.1
	await get_tree().process_frame
	await get_tree().create_timer(0.25).timeout
	_save_shot("nen_skilltree_polish_search.png")

	ui.search_filter = ""
	ui._rebuild_search_matches()
	ui._navegar_para_posicao_mundo(Vector2(450, -150), 1.15)
	ui.selected_node_id = &"ren_2"
	ui._rebuild_path_highlight(&"ren_2")
	ui._spawn_unlock_burst(&"ren_2")
	ui._fx_time = 0.2
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	_save_shot("nen_skilltree_polish_nodes_closeup.png")

	print("[Capture] Screenshots salvos em /opt/cursor/artifacts/")
	get_tree().quit(0)


func _save_shot(name: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		push_error("Falha ao capturar viewport")
		return
	var path := "/opt/cursor/artifacts/%s" % name
	img.save_png(path)
	print("[Capture] ", path)
