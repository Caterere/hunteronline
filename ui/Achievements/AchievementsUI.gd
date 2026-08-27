class_name AchievementsUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - ACHIEVEMENTS & PLATINUM TROPHIES UI
# ============================================================
#
# Interface de Troféus e Conquistas estilo Dragon Ball Xenoverse / PlayStation:
# - Barra de Progresso Global de Platina (0% a 100%).
# - Filtros de Categoria: Todas, História, Combate & Nen, Torre, Missões, Economia.
# - Ranks: Bronze 🥉, Prata 🥈, Ouro 🥇, Platina 💎.
# - Botões para resgatar Jenny, Títulos Exclusivos e Aura.
#
# ============================================================

signal fechado

var tab_container: TabContainer
var panel_main: PanelContainer
var progress_bar_platina: ProgressBar
var lbl_platina_pct: Label
var categoria_atual: String = "Todas"


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_ui()


func toggle_menu() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		_atualizar_tudo()


func _construir_ui() -> void:
	visible = false

	# Fundo Escurecido
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.position = Vector2(10, 8)
	panel_main.custom_minimum_size = Vector2(300, 164)
	panel_main.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	# Cabeçalho
	var hbox_hdr := HBoxContainer.new()
	vbox.add_child(hbox_hdr)

	var lbl_tit := Label.new()
	lbl_tit.text = "🏆 CONQUISTAS & PLATINA [K]"
	lbl_tit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_tit.add_theme_font_size_override("font_size", 5)
	lbl_tit.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	hbox_hdr.add_child(lbl_tit)

	var btn_fechar := Button.new()
	btn_fechar.text = "✖ Fechar [K]"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(toggle_menu)
	hbox_hdr.add_child(btn_fechar)

	# Barra de Progresso da Platina
	var hbox_prog := HBoxContainer.new()
	hbox_prog.add_theme_constant_override("separation", 6)
	vbox.add_child(hbox_prog)

	progress_bar_platina = ProgressBar.new()
	progress_bar_platina.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar_platina.custom_minimum_size = Vector2(160, 8)
	progress_bar_platina.show_percentage = false
	var st_plat := StyleBoxFlat.new()
	st_plat.bg_color = Color(0.2, 0.8, 1.0, 1.0)
	progress_bar_platina.add_theme_stylebox_override("fill", st_plat)
	hbox_prog.add_child(progress_bar_platina)

	lbl_platina_pct = Label.new()
	lbl_platina_pct.text = "0% (0/40)"
	lbl_platina_pct.add_theme_font_size_override("font_size", 3)
	lbl_platina_pct.add_theme_color_override("font_color", Color(0.4, 1.0, 0.8))
	hbox_prog.add_child(lbl_platina_pct)

	# Barra de Abas / Categorias
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_theme_font_size_override("font_size", 3)
	tab_container.tab_changed.connect(func(_idx): _atualizar_tudo())
	vbox.add_child(tab_container)

	var categorias = ["Todas", "História", "Combate", "Torre", "Missões", "Economia", "Coleção", "Platina"]
	for cat in categorias:
		var scroll := ScrollContainer.new()
		scroll.name = cat
		tab_container.add_child(scroll)


func _atualizar_tudo() -> void:
	if AchievementSystem == null:
		return

	AchievementSystem.verificar_todas_conquistas()

	var pct: float = AchievementSystem.obter_porcentagem_conclusao()
	var total_desbloqueadas: int = PlayerData.conquistas_desbloqueadas.size()
	var total_geral: int = AchievementSystem.CONQUISTAS_CATALOGO.size()

	if progress_bar_platina != null:
		progress_bar_platina.value = pct
	if lbl_platina_pct != null:
		lbl_platina_pct.text = "Platina: %.1f%% (%d/%d)" % [pct, total_desbloqueadas, total_geral]

	var aba_atual_control = tab_container.get_current_tab_control()
	if aba_atual_control == null:
		return

	for child in aba_atual_control.get_children():
		child.queue_free()

	var vbox_list := VBoxContainer.new()
	vbox_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_list.add_theme_constant_override("separation", 3)
	aba_atual_control.add_child(vbox_list)

	var cat_nome: String = aba_atual_control.name

	for ach_id in AchievementSystem.CONQUISTAS_CATALOGO.keys():
		var info: Dictionary = AchievementSystem.CONQUISTAS_CATALOGO[ach_id]
		if cat_nome != "Todas" and info.get("categoria", "") != cat_nome:
			continue

		var desbloqueada: bool = AchievementSystem.esta_desbloqueada(ach_id)
		var resgatada: bool = AchievementSystem.esta_resgatada(ach_id)

		var card := PanelContainer.new()
		var s := StyleBoxFlat.new()
		if desbloqueada:
			s.bg_color = Color(0.08, 0.14, 0.22, 0.95)
			s.border_color = Color(1.0, 0.85, 0.3)
		else:
			s.bg_color = Color(0.06, 0.07, 0.10, 0.90)
			s.border_color = Color(0.3, 0.35, 0.45)
		s.border_width_left = 1
		s.border_width_top = 1
		s.border_width_right = 1
		s.border_width_bottom = 1
		card.add_theme_stylebox_override("panel", s)
		vbox_list.add_child(card)

		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		card.add_child(m)

		var h := HBoxContainer.new()
		m.add_child(h)

		var v_info := VBoxContainer.new()
		v_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(v_info)

		var lbl_nome := Label.new()
		var icone: String = info.get("icone", "🏆")
		lbl_nome.text = "%s %s" % [icone, info.get("nome", "")]
		lbl_nome.add_theme_font_size_override("font_size", 3)
		lbl_nome.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3) if desbloqueada else Color(0.6, 0.6, 0.7))
		v_info.add_child(lbl_nome)

		var lbl_desc := Label.new()
		lbl_desc.text = info.get("descricao", "")
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_desc.add_theme_font_size_override("font_size", 3)
		lbl_desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85) if desbloqueada else Color(0.45, 0.45, 0.50))
		v_info.add_child(lbl_desc)

		# Progresso numérico se houver meta
		if info.has("stat_chave") and info.has("meta"):
			var stat_val = int(PlayerData.stats_globais.get(info["stat_chave"], 0))
			var meta_val = int(info["meta"])
			var lbl_stat := Label.new()
			lbl_stat.text = "Progresso: %d / %d" % [min(stat_val, meta_val), meta_val]
			lbl_stat.add_theme_font_size_override("font_size", 3)
			lbl_stat.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
			v_info.add_child(lbl_stat)

		# Botão de Recompensa
		var btn_rec := Button.new()
		var id_copy = ach_id
		if not desbloqueada:
			btn_rec.text = "🔒 Bloqueada"
			btn_rec.disabled = true
		elif resgatada:
			btn_rec.text = "✅ Resgatado"
			btn_rec.disabled = true
		else:
			var pr = info.get("recompensa_jenny", 0)
			btn_rec.text = "🎁 Resgatar (%s J)" % Economy.formatar_numero(pr)
			btn_rec.disabled = false
			btn_rec.pressed.connect(func():
				AchievementSystem.resgatar_recompensa(id_copy)
				_atualizar_tudo()
			)
		btn_rec.add_theme_font_size_override("font_size", 3)
		h.add_child(btn_rec)
