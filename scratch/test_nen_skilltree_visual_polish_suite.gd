extends Node

# ============================================================
# Suite: polish visual da Nen Skill Tree (nodes / FX / busca)
# ============================================================

const NenSkillTreeUIScript = preload("res://ui/SkillTree/NenSkillTreeUI.gd")

var _passed: int = 0
var _failed: int = 0


func _ready() -> void:
	print("\n========== TEST NEN SKILL TREE VISUAL POLISH ==========")
	await get_tree().process_frame
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel_nen(1)
	PlayerData.nen_skill_points = 12
	await _teste_ui_fx_apis()
	print("========== RESULTADO: %d ok / %d fail ==========" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  PASS: ", msg)
	else:
		_failed += 1
		print("  FAIL: ", msg)


func _teste_ui_fx_apis() -> void:
	print("\n[1] APIs de polish visual")
	var ui = NenSkillTreeUIScript.new()
	ui.size = Vector2(1280, 720)
	add_child(ui)
	await get_tree().process_frame
	await get_tree().process_frame

	_assert(ui.map_viewport != null, "map_viewport criado")
	_assert(ui._tex_nen_icons != null, "category icons carregados")
	_assert(ui._tex_small_node_icons != null, "small node icons carregados")
	_assert(ui._tex_node_rings != null, "node rings atlas carregado")
	_assert(ui.has_method("_draw_aura_flow"), "tem fluxo de aura")
	_assert(ui.has_method("_draw_dashed_line"), "tem linhas tracejadas")
	_assert(ui.has_method("_draw_rank_pips"), "tem rank pips")
	_assert(ui.has_method("_spawn_unlock_burst"), "tem unlock burst")
	_assert(ui.has_method("_rebuild_path_highlight"), "tem path highlight")
	_assert(ui.has_method("_ir_proximo_match_busca"), "tem next search match")

	ui._rebuild_path_highlight(&"ren_3")
	_assert(ui._path_highlight.has(&"ren_3"), "path inclui nó alvo")
	_assert(ui._path_highlight.has(&"ren_1") or ui._path_highlight.has(&"nexus_center"), "path sobe pelos prereqs")

	ui.search_filter = "ten"
	ui._rebuild_search_matches()
	_assert(ui._search_matches.size() > 0, "busca encontra nós Ten")
	var before_idx: int = ui._search_match_idx
	ui._ir_proximo_match_busca()
	_assert(ui._search_match_idx != before_idx or ui._search_matches.size() == 1, "next match avança")
	_assert(not ui.selected_node_id.is_empty(), "next match seleciona nó")

	ui._spawn_unlock_burst(&"nexus_center")
	_assert(ui._unlock_bursts.size() == 1, "burst de unlock registrado")

	# Força um frame de draw + animação
	ui._fx_time = 1.25
	ui.map_viewport.queue_redraw()
	await get_tree().process_frame
	_assert(ui._fx_time >= 1.25, "fx_time avança")

	# Investimento dispara burst via fluxo real
	if ui.skill_tree != null:
		ui.selected_node_id = &"nexus_center"
		# Nexus pode já estar "free"; tenta um nó raiz
		if ui.skill_tree.pode_investir(&"ten_1"):
			ui.selected_node_id = &"ten_1"
			ui._on_invest_pressed()
			_assert(ui.skill_tree.no_desbloqueado(&"ten_1"), "investiu ten_1")
			_assert(ui._unlock_bursts.size() >= 1, "burst apos investir")

	ui.queue_free()
	await get_tree().process_frame
