class_name BuildDebugMenu
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - BUILD & COMBAT DEBUG MENU (FASE 11)
# ============================================================
#
# Ferramenta in-game de desenvolvimento para testes rápidos:
# - Gestão de Pontos de Skill Tree (+10 SP, Reset)
# - Injeção e teste de Condições de Combate (HP < 30%, Cercado, Alvo Isolado)
# - Teste de Fraquezas & Tags de Dano
# - Disparo manual de Fases de Boss para testes imediatos
# ============================================================

var panel: PanelContainer
var is_open: bool = false

# Condições simuladas
var sim_low_hp: bool = false
var sim_surrounded: bool = false
var sim_isolated: bool = false
var sim_marked: bool = false

func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F2:
			alternar_menu()
			get_viewport().set_input_as_handled()

func alternar_menu() -> void:
	is_open = not is_open
	visible = is_open

func _construir_ui() -> void:
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 260)
	panel.position = Vector2(20, 40)
	panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 3))
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var lbl_title := Label.new()
	lbl_title.text = "🛠️ DEBUG MENU: BUILDS & COMBATE [F2]"
	lbl_title.add_theme_font_size_override("font_size", 6)
	lbl_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vbox.add_child(lbl_title)

	# Seção 1: Nen Skill Tree
	var lbl_st := Label.new()
	lbl_st.text = "⚡ Skill Tree & Pontos:"
	lbl_st.add_theme_font_size_override("font_size", 4)
	lbl_st.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_st)

	var hbox_sp := HBoxContainer.new()
	hbox_sp.add_theme_constant_override("separation", 4)
	vbox.add_child(hbox_sp)

	var btn_add_sp := Button.new()
	btn_add_sp.text = "+10 Nen SP"
	btn_add_sp.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_add_sp, HunterUIStyle.COLOR_BORDER_GREEN)
	btn_add_sp.pressed.connect(func():
		PlayerData.nen_skill_points += 10
		if EventBus != null:
			EventBus.emit_toast("+10 Nen Skill Points Adicionados!", HunterUIStyle.COLOR_GOLD_LIGHT)
	)
	hbox_sp.add_child(btn_add_sp)

	var btn_reset_sp := Button.new()
	btn_reset_sp.text = "Reset Tree"
	btn_reset_sp.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_reset_sp, Color(0.9, 0.3, 0.3))
	btn_reset_sp.pressed.connect(func():
		PlayerData.nen_skill_tree_progress.clear()
		PlayerData.nen_skill_points = 15
		if EventBus != null:
			EventBus.emit_toast("Skill Tree Resetada (15 SP concedidos)", Color.WHITE)
	)
	hbox_sp.add_child(btn_reset_sp)

	# Seção 2: Simulação de Condições de Combate
	var lbl_cond := Label.new()
	lbl_cond.text = "🎯 Injeção de Condições de Combate:"
	lbl_cond.add_theme_font_size_override("font_size", 4)
	lbl_cond.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vbox.add_child(lbl_cond)

	var grid_cond := GridContainer.new()
	grid_cond.columns = 2
	grid_cond.add_theme_constant_override("h_separation", 4)
	grid_cond.add_theme_constant_override("v_separation", 3)
	vbox.add_child(grid_cond)

	_adicionar_toggle_condicao(grid_cond, "HP Crítico (<30%)", func(v):
		sim_low_hp = v
		if v:
			PlayerData.attributes["vida"] = int(float(PlayerData.attributes.get("vida_max", 100)) * 0.25)
		else:
			PlayerData.attributes["vida"] = PlayerData.attributes.get("vida_max", 100)
	)
	_adicionar_toggle_condicao(grid_cond, "Cercado (3+ Inimigos)", func(v): sim_surrounded = v)
	_adicionar_toggle_condicao(grid_cond, "Alvo Isolado", func(v): sim_isolated = v)
	_adicionar_toggle_condicao(grid_cond, "Alvo Marcado", func(v): sim_marked = v)

	# Seção 3: Disparo de Fases de Boss
	var lbl_boss := Label.new()
	lbl_boss.text = "👑 Teste de Fases de Chefe:"
	lbl_boss.add_theme_font_size_override("font_size", 4)
	lbl_boss.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	vbox.add_child(lbl_boss)

	var hbox_boss := HBoxContainer.new()
	hbox_boss.add_theme_constant_override("separation", 4)
	vbox.add_child(hbox_boss)

	var btn_fase2 := Button.new()
	btn_fase2.text = "Fase 2 (Frenesi)"
	btn_fase2.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_fase2, Color(0.9, 0.5, 0.2))
	btn_fase2.pressed.connect(func():
		_forcar_fase_boss(2)
	)
	hbox_boss.add_child(btn_fase2)

	var btn_fase3 := Button.new()
	btn_fase3.text = "Fase 3 (Overload)"
	btn_fase3.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_fase3, Color(0.9, 0.2, 0.2))
	btn_fase3.pressed.connect(func():
		_forcar_fase_boss(3)
	)
	hbox_boss.add_child(btn_fase3)

func _adicionar_toggle_condicao(parent: Control, texto: String, callback: Callable) -> void:
	var chk := CheckBox.new()
	chk.text = texto
	chk.add_theme_font_size_override("font_size", 4)
	chk.toggled.connect(callback)
	parent.add_child(chk)

func _forcar_fase_boss(fase: int) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var achou := false
	for e in enemies:
		var ai = e.get_node_or_null("EnemyAI") as EnemyAI
		var es = e.get_node_or_null("EnemySystem") as EnemySystem
		if ai != null and es != null and (es.is_boss or (es.enemy_data != null and es.enemy_data.is_boss)):
			achou = true
			if fase == 2:
				ai._entrar_fase_2_boss()
			elif fase == 3:
				ai._entrar_fase_3_boss()
	if EventBus != null:
		if achou:
			EventBus.emit_toast("⚡ Boss forçado para Fase %d!" % fase, Color(1.0, 0.4, 0.4))
		else:
			EventBus.emit_toast("Nenhum boss ativo na cena atual.", Color.GRAY)

func obter_contexto_debug() -> Dictionary:
	return {
		"nearby_enemy_count": 4 if sim_surrounded else (0 if sim_isolated else 1),
		"target_marked": sim_marked,
		"player_hp_percent": 0.25 if sim_low_hp else 1.0
	}
