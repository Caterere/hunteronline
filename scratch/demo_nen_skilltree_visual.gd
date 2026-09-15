extends Node

# Demo curta: mantém a UI aberta ~4s para screen recording dos FX.
const NenSkillTreeUIScript = preload("res://ui/SkillTree/NenSkillTreeUI.gd")

func _ready() -> void:
	await get_tree().process_frame
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel_nen(3)
	PlayerData.nen_skill_points = 25
	var tree = PlayerData.obter_skill_tree()
	if tree != null:
		for nid in [&"ten_1", &"ten_2", &"ren_1", &"ren_2", &"gyo_1", &"zetsu_1", &"ko_1"]:
			if tree.pode_investir(nid):
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
	await get_tree().process_frame
	ui.is_fullscreen = true
	ui._atualizar_layout_responsivo()
	ui._navegar_para_posicao_mundo(Vector2(320, -40), 1.05)
	ui.selected_node_id = &"ren_2"
	ui._rebuild_path_highlight(&"ren_2")
	ui._atualizar_inspector()
	ui._spawn_unlock_burst(&"ren_2")

	await get_tree().create_timer(1.2).timeout
	ui.search_filter = "ten"
	ui._rebuild_search_matches()
	ui._ir_proximo_match_busca()
	await get_tree().create_timer(1.4).timeout
	ui.search_filter = ""
	ui._rebuild_search_matches()
	ui._centralizar_no_nexus()
	ui._spawn_unlock_burst(&"nexus_center")
	# Mantém aberto para screen recording / inspeção manual
	await get_tree().create_timer(8.0).timeout
	get_tree().quit(0)
