class_name HatsuBookUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - HATSU BOOK UI (GRIMÓRIO DE NEN / SKILL HUNTER)
# ============================================================
#
# Interface visual temática de Livro Aberto ajustada para 320x180.
# Permite inspecionar páginas, ler dados completos/incompletos,
# equipar no Slot Principal ou com Marcador (Bookmark) para uso simultâneo.
#
# ============================================================

signal livro_fechado
signal pagina_equipada(slot: int, pagina_indice: int)

var livro_atual: HatsuBookData = null
var pagina_selecionada: int = 0

# UI Controls
var panel_main: PanelContainer
var vbox_content: VBoxContainer
var lbl_titulo: Label
var hbox_book: HBoxContainer

# Lado Esquerdo (Índice de Páginas)
var vbox_left: VBoxContainer
var scroll_paginas: ScrollContainer
var container_paginas: VBoxContainer

# Lado Direito (Detalhes da Página)
var vbox_right: VBoxContainer
var lbl_hab_nome: Label
var lbl_hab_categoria: Label
var lbl_hab_usuario: Label
var lbl_hab_status: Label
var lbl_hab_tags: Label
var lbl_hab_desc: Label
var lbl_hab_condicoes: Label
var btn_equipar_slot1: Button
var btn_equipar_marcador: Button

# Rodapé de Equilíbrio (Balance Score)
var lbl_balance_meter: Label
var btn_fechar: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 32
	visible = false
	_construir_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_B:
			fechar()
			get_viewport().set_input_as_handled()


func toggle_menu(book: HatsuBookData = null) -> void:
	if visible:
		fechar()
	else:
		abrir(book)


func abrir(book: HatsuBookData = null) -> void:
	if book != null:
		livro_atual = book
	elif livro_atual == null:
		livro_atual = HatsuManager.criar_livro_hatsu("Arquivo dos Segredos")

	pagina_selecionada = 0
	visible = true
	get_tree().paused = true
	_atualizar_exibicao()


func fechar() -> void:
	visible = false
	get_tree().paused = false
	livro_fechado.emit()


func _construir_ui() -> void:
	# Fundo escurecido
	var bg_overlay := ColorRect.new()
	bg_overlay.color = Color(0, 0, 0, 0.75)
	bg_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg_overlay)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(304, 168)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_main.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 3)
	panel_main.add_child(margin)

	vbox_content = VBoxContainer.new()
	vbox_content.add_theme_constant_override("separation", 2)
	margin.add_child(vbox_content)

	# Cabeçalho
	lbl_titulo = Label.new()
	lbl_titulo.text = "📖 GRIMÓRIO DE NEN — ARQUIVO DE HATSUS"
	lbl_titulo.add_theme_font_size_override("font_size", 5)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_content.add_child(lbl_titulo)

	# Livro Aberto (2 Lados)
	hbox_book = HBoxContainer.new()
	hbox_book.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_book.add_theme_constant_override("separation", 6)
	vbox_content.add_child(hbox_book)

	# Lado Esquerdo: Lista de Páginas
	vbox_left = VBoxContainer.new()
	vbox_left.custom_minimum_size = Vector2(110, 0)
	hbox_book.add_child(vbox_left)

	var lbl_idx := Label.new()
	lbl_idx.text = "ÍNDICE DE PÁGINAS:"
	lbl_idx.add_theme_font_size_override("font_size", 4)
	lbl_idx.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
	vbox_left.add_child(lbl_idx)

	scroll_paginas = ScrollContainer.new()
	scroll_paginas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_left.add_child(scroll_paginas)

	container_paginas = VBoxContainer.new()
	container_paginas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container_paginas.add_theme_constant_override("separation", 1)
	scroll_paginas.add_child(container_paginas)

	# Separador vertical
	var vsep := VSeparator.new()
	hbox_book.add_child(vsep)

	# Lado Direito: Ficha da Técnica
	vbox_right = VBoxContainer.new()
	vbox_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_right.add_theme_constant_override("separation", 2)
	hbox_book.add_child(vbox_right)

	lbl_hab_nome = Label.new()
	lbl_hab_nome.text = "Selecione uma página"
	lbl_hab_nome.add_theme_font_size_override("font_size", 5)
	lbl_hab_nome.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
	vbox_right.add_child(lbl_hab_nome)

	lbl_hab_categoria = Label.new()
	lbl_hab_categoria.add_theme_font_size_override("font_size", 4)
	vbox_right.add_child(lbl_hab_categoria)

	lbl_hab_usuario = Label.new()
	lbl_hab_usuario.add_theme_font_size_override("font_size", 4)
	lbl_hab_usuario.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9, 1.0))
	vbox_right.add_child(lbl_hab_usuario)

	lbl_hab_status = Label.new()
	lbl_hab_status.add_theme_font_size_override("font_size", 4)
	vbox_right.add_child(lbl_hab_status)

	lbl_hab_tags = Label.new()
	lbl_hab_tags.add_theme_font_size_override("font_size", 4)
	lbl_hab_tags.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5, 1.0))
	vbox_right.add_child(lbl_hab_tags)

	lbl_hab_desc = Label.new()
	lbl_hab_desc.add_theme_font_size_override("font_size", 4)
	lbl_hab_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_right.add_child(lbl_hab_desc)

	lbl_hab_condicoes = Label.new()
	lbl_hab_condicoes.add_theme_font_size_override("font_size", 4)
	lbl_hab_condicoes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_hab_condicoes.add_theme_color_override("font_color", Color(0.9, 0.5, 0.3, 1.0))
	vbox_right.add_child(lbl_hab_condicoes)

	# Botões de Equipamento
	var hbox_btns := HBoxContainer.new()
	hbox_btns.add_theme_constant_override("separation", 3)
	vbox_right.add_child(hbox_btns)

	btn_equipar_slot1 = Button.new()
	btn_equipar_slot1.text = "📖 Equipar Slot 1"
	btn_equipar_slot1.add_theme_font_size_override("font_size", 4)
	btn_equipar_slot1.pressed.connect(_on_equipar_slot1_pressed)
	hbox_btns.add_child(btn_equipar_slot1)

	btn_equipar_marcador = Button.new()
	btn_equipar_marcador.text = "🔖 Inserir Marcador (Slot 2)"
	btn_equipar_marcador.add_theme_font_size_override("font_size", 4)
	btn_equipar_marcador.pressed.connect(_on_equipar_marcador_pressed)
	hbox_btns.add_child(btn_equipar_marcador)

	# Rodapé
	var hsep_bot := HSeparator.new()
	vbox_content.add_child(hsep_bot)

	var hbox_footer := HBoxContainer.new()
	vbox_content.add_child(hbox_footer)

	lbl_balance_meter = Label.new()
	lbl_balance_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_balance_meter.add_theme_font_size_override("font_size", 4)
	lbl_balance_meter.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
	hbox_footer.add_child(lbl_balance_meter)

	btn_fechar = Button.new()
	btn_fechar.text = "Fechar [ESC]"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(fechar)
	hbox_footer.add_child(btn_fechar)


func _atualizar_exibicao() -> void:
	if livro_atual == null: return

	# 1. Limpar e preencher lista de páginas
	for child in container_paginas.get_children():
		child.queue_free()

	for i in range(livro_atual.paginas.size()):
		var pag = livro_atual.paginas[i]
		var btn_pag := Button.new()
		var badge: String = "🟢" if pag.get("status_descoberta", "COMPLETO") == "COMPLETO" else "🟡"
		var slot_ind: String = ""
		if i == livro_atual.pagina_slot_principal: slot_ind = " [📖 S1]"
		elif i == livro_atual.pagina_slot_marcador: slot_ind = " [🔖 S2]"

		btn_pag.text = "%s #%02d %s%s" % [badge, i + 1, pag.get("nome", "Hatsu").substr(0, 14), slot_ind]
		btn_pag.add_theme_font_size_override("font_size", 4)
		btn_pag.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if i == pagina_selecionada:
			btn_pag.modulate = Color(1.3, 1.3, 0.8, 1.0)

		var idx = i
		btn_pag.pressed.connect(func():
			pagina_selecionada = idx
			_atualizar_exibicao()
		)
		container_paginas.add_child(btn_pag)

	# 2. Exibir Detalhes da Página Selecionada
	var pag_sel: Dictionary = livro_atual.obter_pagina(pagina_selecionada)
	if not pag_sel.is_empty():
		var ef: float = livro_atual.obter_eficiencia_pagina(pagina_selecionada, PlayerData.afinidade_nen)
		var cat_nome: String = HatsuManager.obter_nome_categoria(pag_sel.get("categoria", 0))

		lbl_hab_nome.text = "#%02d: %s" % [pagina_selecionada + 1, pag_sel.get("nome", "Hatsu")]
		lbl_hab_categoria.text = "Categoria: %s | Eficiência: %d%%" % [cat_nome, int(ef * 100)]
		lbl_hab_usuario.text = "Usuário Original: %s" % pag_sel.get("usuario_original", "Desconhecido")

		if pag_sel.get("status_descoberta", "COMPLETO") == "COMPLETO":
			lbl_hab_status.text = "Status: 🟢 CONHECIMENTO COMPLETO"
			lbl_hab_status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 1.0))
		else:
			lbl_hab_status.text = "Status: 🟡 INCOMPLETO (Penalidade: 40% Eficiência)"
			lbl_hab_status.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2, 1.0))

		var tags_arr: Array = pag_sel.get("tags", [])
		lbl_hab_tags.text = "Propriedades / Tags: " + ", ".join(tags_arr)
		lbl_hab_desc.text = "Efeito: " + pag_sel.get("descricao", "")

		var conds_arr: Array = pag_sel.get("condicoes_descobertas", [])
		lbl_hab_condicoes.text = "Regras & Restrições:\n• " + "\n• ".join(conds_arr)

		btn_equipar_slot1.disabled = false
		btn_equipar_marcador.disabled = not livro_atual.permite_marcador_duplo
	else:
		lbl_hab_nome.text = "Nenhuma página no Livro"
		lbl_hab_categoria.text = ""
		lbl_hab_usuario.text = ""
		lbl_hab_status.text = ""
		lbl_hab_tags.text = ""
		lbl_hab_desc.text = "Explore o mundo e cumpra as 4 etapas de Nen para catalogar novas habilidades."
		lbl_hab_condicoes.text = ""
		btn_equipar_slot1.disabled = true
		btn_equipar_marcador.disabled = true

	# 3. Rodapé do Balanço
	var bal: Dictionary = livro_atual.calcular_balanco()
	lbl_balance_meter.text = "Capacidade: %d/%d | Hatsu Power: %d | Restriction Power: %d | Balance Score: %+d (%d%% EF)" % [
		livro_atual.paginas.size(),
		livro_atual.capacidade_maxima,
		bal["hatsu_power"],
		bal["restriction_power"],
		bal["balance_score"],
		int(bal["eficiencia_global"] * 100)
	]


func _on_equipar_slot1_pressed() -> void:
	if livro_atual == null: return
	livro_atual.pagina_slot_principal = pagina_selecionada
	pagina_equipada.emit(0, pagina_selecionada)
	_atualizar_exibicao()


func _on_equipar_marcador_pressed() -> void:
	if livro_atual == null or not livro_atual.permite_marcador_duplo: return
	if livro_atual.pagina_slot_marcador == pagina_selecionada:
		livro_atual.pagina_slot_marcador = -1 # Remove marcador
	else:
		livro_atual.pagina_slot_marcador = pagina_selecionada
	pagina_equipada.emit(1, pagina_selecionada)
	_atualizar_exibicao()
