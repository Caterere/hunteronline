class_name HatsuCreationUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - HATSU CREATION UI (v1.5: CRÉDITOS DE LIMITAÇÃO)
# ============================================================
#
# Interface de criação de Hatsu com sistema modular de Vow & Limitation.
# Ajustada estritamente para viewport 320x180 (Painel 304x168 centralizado).
#
# FLUXO EM 9 ETAPAS COM EQUILÍBRIO DE LIMITAÇÃO:
# 1. Tipo de Nen (Reforço, Emissão, Transmutação, Conjuração, Manipulação, Especialização, Outro / Especial)
# 2. Conceito / Preset (Biblioteca com 15 Conceitos Temáticos ou Criar do Zero)
# 3. Nome & Identidade Visual
# 4. Efeito Principal & Funcionamento (Parâmetros específicos do conceito)
# 5. Efeitos Secundários & Modificadores
# 6. Condições de Ativação & Cadeia de Preparação (Preparation Chain)
# 7. Juramentos & Restrições (Vows & Limitations + IA de Nen)
# 8. Custos, Alcance & Consumo
# 9. Resumo, Auditoria de Créditos & Forjar Hatsu
#
# ============================================================

signal hatsu_criado(hatsu: HatsuData)
signal menu_fechado

enum Etapa {
	TIPO_NEN,            # 1/9
	CONCEITO,            # 2/9
	NOME,                # 3/9
	FUNCIONAMENTO,       # 4/9
	EFEITOS_SECUNDARIOS, # 5/9
	CONDICOES,           # 6/9
	RESTRICOES,          # 7/9
	CUSTOS,              # 8/9
	RESUMO               # 9/9
}

var etapa_atual: Etapa = Etapa.TIPO_NEN

# Configurações do Hatsu
var sel_tipo_especial: bool = false
var sel_preset_id: HatsuPresetLibrary.PresetId = HatsuPresetLibrary.PresetId.CRIAR_DO_ZERO
var sel_nome: String = "Meu Hatsu"
var sel_categoria: HatsuData.Categoria = HatsuData.Categoria.INTENSIFICACAO
var sel_objetivo: HatsuData.ObjetivoPrincipal = HatsuData.ObjetivoPrincipal.DANO
var sel_forma: HatsuData.Forma = HatsuData.Forma.TOQUE
var sel_elemento: HatsuData.Elemento = HatsuData.Elemento.NEN_PURO
var sel_alvo: HatsuData.Alvo = HatsuData.Alvo.INIMIGO_UNICO
var sel_alcance: HatsuData.AlcanceTipo = HatsuData.AlcanceTipo.MEDIO
var sel_consumo: HatsuData.ConsumoDesejado = HatsuData.ConsumoDesejado.MEDIO
var sel_efeitos_secundarios: Array = []
var sel_condicoes: Array = []
var sel_restricoes: Array = []
var sel_preparation_steps: Array = []
var sel_arquetipo: HatsuData.Arquetipo = HatsuData.Arquetipo.SIMPLES
var sel_cor_primaria: Color = Color(0.3, 0.7, 1.0, 1.0)
var sel_cor_secundaria: Color = Color(1.0, 1.0, 1.0, 0.9)
var sel_estilo_visual: HatsuData.EstiloVisual = HatsuData.EstiloVisual.PURO_PULSANTE
var custom_vow_input: String = ""
var sel_opcoes_preset: Dictionary = {}
var sel_opcoes_preset_escolhidas: Dictionary = {}

# Parâmetros Especializados de Storage & Roubo de Hatsu
var sel_is_storage_hatsu: bool = false
var sel_storage_capacity: int = 5
var sel_storage_duration: String = "PERMANENT"
var sel_storage_usage: String = "OPEN_BOOK"
var sel_steal_conditions: Array[String] = []
var sel_steal_target: String = "ANY"

# Elementos da UI
var panel_main: PanelContainer
var vbox_content: VBoxContainer
var hbox_tabs: HBoxContainer
var tab_buttons: Array[Button] = []
var lbl_titulo: Label
var lbl_desc: Label
var container_opcoes: VBoxContainer
var line_edit_nome: LineEdit
var line_edit_custom_vow: LineEdit
var lbl_vow_analise: Label
var btn_proximo: Button
var btn_anterior: Button
var btn_salvar_rascunho: Button
var btn_fechar: Button

# Medidor de Equilíbrio (Gauge)
var panel_gauge: PanelContainer
var lbl_compat: Label
var lbl_aura: Label
var lbl_complexidade: Label
var lbl_potencial: Label
var lbl_dica_dinamica: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30
	visible = false
	_construir_ui()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			fechar()
			get_viewport().set_input_as_handled()


func toggle_menu() -> void:
	if visible:
		fechar()
	else:
		abrir()


func abrir() -> void:
	if panel_main == null:
		_construir_ui()
	etapa_atual = Etapa.TIPO_NEN
	sel_tipo_especial = false
	sel_preset_id = HatsuPresetLibrary.PresetId.CRIAR_DO_ZERO
	sel_nome = "Novo Hatsu"
	sel_categoria = PlayerData.afinidade_nen as HatsuData.Categoria
	sel_objetivo = HatsuData.ObjetivoPrincipal.DANO
	sel_forma = HatsuData.Forma.TOQUE
	sel_elemento = HatsuData.Elemento.NEN_PURO
	sel_alvo = HatsuData.Alvo.INIMIGO_UNICO
	sel_alcance = HatsuData.AlcanceTipo.MEDIO
	sel_consumo = HatsuData.ConsumoDesejado.MEDIO
	sel_efeitos_secundarios.clear()
	sel_condicoes.clear()
	sel_restricoes.clear()
	sel_preparation_steps.clear()
	sel_opcoes_preset.clear()
	sel_opcoes_preset_escolhidas.clear()
	custom_vow_input = ""
	visible = true
	if get_tree() != null:
		get_tree().paused = true
	_atualizar_etapa()


func fechar() -> void:
	visible = false
	if get_tree() != null:
		get_tree().paused = false
	menu_fechado.emit()


func _ir_para_etapa(nova_etapa: Etapa) -> void:
	if etapa_atual == Etapa.NOME and line_edit_nome != null and not line_edit_nome.text.is_empty():
		sel_nome = line_edit_nome.text
	etapa_atual = nova_etapa
	_atualizar_etapa()


# ============================================================
# CONSTRUÇÃO DA UI (304x168)
# ============================================================

func _construir_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(304, 168)
	panel_main.size = Vector2(304, 168)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.98)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.6, 0.9, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel_main.add_theme_stylebox_override("panel", style)
	root.add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 2)
	panel_main.add_child(margin)

	var hbox_colunas := HBoxContainer.new()
	hbox_colunas.add_theme_constant_override("separation", 3)
	margin.add_child(hbox_colunas)

	# Coluna Esquerda: Forjador (195px)
	vbox_content = VBoxContainer.new()
	vbox_content.custom_minimum_size = Vector2(195, 162)
	vbox_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_content.add_theme_constant_override("separation", 1)
	hbox_colunas.add_child(vbox_content)

	# Cabeçalho
	var hbox_hdr := HBoxContainer.new()
	vbox_content.add_child(hbox_hdr)

	lbl_titulo = Label.new()
	lbl_titulo.add_theme_font_size_override("font_size", 4)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_titulo.text = "⚡ FORJADOR DE HATSU"
	hbox_hdr.add_child(lbl_titulo)

	btn_fechar = Button.new()
	btn_fechar.text = "✖ Sair"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(fechar)
	hbox_hdr.add_child(btn_fechar)

	# Barra Superior de 9 Abas Navegáveis
	_construir_barra_abas()

	lbl_desc = Label.new()
	lbl_desc.add_theme_font_size_override("font_size", 4)
	lbl_desc.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 1.0))
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_content.add_child(lbl_desc)

	# Scroll de Opções
	var scroll_opcoes := ScrollContainer.new()
	scroll_opcoes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_opcoes.custom_minimum_size = Vector2(195, 80)
	scroll_opcoes.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox_content.add_child(scroll_opcoes)

	container_opcoes = VBoxContainer.new()
	container_opcoes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container_opcoes.add_theme_constant_override("separation", 2)
	scroll_opcoes.add_child(container_opcoes)

	line_edit_nome = LineEdit.new()
	line_edit_nome.add_theme_font_size_override("font_size", 4)
	line_edit_nome.placeholder_text = "Digite o nome da habilidade..."
	line_edit_nome.visible = false
	container_opcoes.add_child(line_edit_nome)

	# Rodapé de Navegação
	var hbox_nav := HBoxContainer.new()
	hbox_nav.alignment = BoxContainer.ALIGNMENT_END
	hbox_nav.add_theme_constant_override("separation", 2)
	vbox_content.add_child(hbox_nav)

	btn_salvar_rascunho = Button.new()
	btn_salvar_rascunho.text = "💾 Rascunho"
	btn_salvar_rascunho.add_theme_font_size_override("font_size", 4)
	btn_salvar_rascunho.pressed.connect(func(): _finalizar_criacao(true))
	hbox_nav.add_child(btn_salvar_rascunho)

	btn_anterior = Button.new()
	btn_anterior.text = "< Voltar"
	btn_anterior.add_theme_font_size_override("font_size", 4)
	btn_anterior.pressed.connect(_on_voltar_pressed)
	hbox_nav.add_child(btn_anterior)

	btn_proximo = Button.new()
	btn_proximo.text = "Avançar >"
	btn_proximo.add_theme_font_size_override("font_size", 4)
	btn_proximo.pressed.connect(_on_avancar_pressed)
	hbox_nav.add_child(btn_proximo)

	# Coluna Direita: Medidor de Nen (95px)
	_construir_gauge(hbox_colunas)


func _construir_barra_abas() -> void:
	hbox_tabs = HBoxContainer.new()
	hbox_tabs.add_theme_constant_override("separation", 1)
	vbox_content.add_child(hbox_tabs)

	var nomes_abas = ["1.Tipo", "2.Conceito", "3.Nome", "4.Função", "5.Efeitos", "6.Cond.", "7.Votos", "8.Custos", "9.Resumo"]
	tab_buttons.clear()

	for i in range(nomes_abas.size()):
		var btn_tab := Button.new()
		btn_tab.text = nomes_abas[i]
		btn_tab.add_theme_font_size_override("font_size", 3)
		btn_tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var etapa_alvo = i as Etapa
		btn_tab.pressed.connect(func(): _ir_para_etapa(etapa_alvo))
		hbox_tabs.add_child(btn_tab)
		tab_buttons.append(btn_tab)


func _construir_gauge(parent: Control) -> void:
	panel_gauge = PanelContainer.new()
	panel_gauge.custom_minimum_size = Vector2(95, 162)
	var st_g := StyleBoxFlat.new()
	st_g.bg_color = Color(0.09, 0.11, 0.16, 0.95)
	st_g.border_width_left = 1
	st_g.border_width_top = 1
	st_g.border_width_right = 1
	st_g.border_width_bottom = 1
	st_g.border_color = Color(0.4, 0.7, 0.4, 1.0)
	st_g.corner_radius_top_left = 3
	st_g.corner_radius_top_right = 3
	st_g.corner_radius_bottom_right = 3
	st_g.corner_radius_bottom_left = 3
	panel_gauge.add_theme_stylebox_override("panel", st_g)
	parent.add_child(panel_gauge)

	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 3)
	m.add_theme_constant_override("margin_top", 3)
	m.add_theme_constant_override("margin_right", 3)
	m.add_theme_constant_override("margin_bottom", 3)
	panel_gauge.add_child(m)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	m.add_child(vb)

	var lbl_ghdr := Label.new()
	lbl_ghdr.text = "EQUILÍBRIO DE NEN"
	lbl_ghdr.add_theme_font_size_override("font_size", 4)
	lbl_ghdr.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 1.0))
	lbl_ghdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(lbl_ghdr)

	lbl_compat = Label.new()
	lbl_compat.add_theme_font_size_override("font_size", 4)
	lbl_compat.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
	vb.add_child(lbl_compat)

	lbl_aura = Label.new()
	lbl_aura.add_theme_font_size_override("font_size", 4)
	lbl_aura.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3, 1.0))
	vb.add_child(lbl_aura)

	lbl_potencial = Label.new()
	lbl_potencial.add_theme_font_size_override("font_size", 4)
	lbl_potencial.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6, 1.0))
	vb.add_child(lbl_potencial)

	lbl_complexidade = Label.new()
	lbl_complexidade.add_theme_font_size_override("font_size", 4)
	vb.add_child(lbl_complexidade)

	lbl_dica_dinamica = Label.new()
	lbl_dica_dinamica.add_theme_font_size_override("font_size", 4)
	lbl_dica_dinamica.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_dica_dinamica.add_theme_color_override("font_color", Color(0.9, 0.85, 0.5, 1.0))
	lbl_dica_dinamica.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(lbl_dica_dinamica)


# ============================================================
# MÁQUINA DE ESTADOS DAS 9 ETAPAS
# ============================================================

func _atualizar_etapa() -> void:
	for child in container_opcoes.get_children():
		if child != line_edit_nome:
			child.queue_free()

	line_edit_nome.visible = false
	btn_anterior.visible = (etapa_atual != Etapa.TIPO_NEN)
	btn_proximo.text = "Avançar >"
	btn_proximo.modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Atualizar estilo da barra de abas
	for i in range(tab_buttons.size()):
		var b = tab_buttons[i]
		if i == int(etapa_atual):
			b.modulate = Color(1.0, 0.85, 0.2, 1.0)
		elif i < int(etapa_atual):
			b.modulate = Color(0.5, 0.8, 1.0, 1.0)
		else:
			b.modulate = Color(0.6, 0.6, 0.7, 0.8)

	match etapa_atual:
		Etapa.TIPO_NEN:
			lbl_titulo.text = "1/9: Tipo de Hatsu"
			lbl_desc.text = "Escolha sua afinidade de Nen ou acesse o catálogo especial:"
			_montar_etapa_tipo_nen()

		Etapa.CONCEITO:
			lbl_titulo.text = "2/9: Conceito Principal / Preset"
			lbl_desc.text = "Defina O QUE seu Hatsu fará logo no início da criação:"
			_montar_etapa_conceito()

		Etapa.NOME:
			lbl_titulo.text = "3/9: Nome & Identidade Visual"
			lbl_desc.text = "Como se chamará sua técnica especial de Hatsu?"
			_montar_etapa_nome()

		Etapa.FUNCIONAMENTO:
			lbl_titulo.text = "4/9: Efeito Principal & Funcionamento"
			lbl_desc.text = "Configure objetivo, alvo, forma e parâmetros do conceito:"
			_montar_etapa_funcionamento()

		Etapa.EFEITOS_SECUNDARIOS:
			lbl_titulo.text = "5/9: Efeitos Secundários & Modificadores"
			lbl_desc.text = "Adicione propriedades táticas acopláveis ao Hatsu:"
			_montar_etapa_efeitos_secundarios()

		Etapa.CONDICOES:
			lbl_titulo.text = "6/9: Condições Táticas & Preparação"
			lbl_desc.text = "Pague pelo poder com condições de ativação e passos prévios:"
			_montar_etapa_condicoes()

		Etapa.RESTRICOES:
			lbl_titulo.text = "7/9: Juramentos & Restrições (Vows)"
			lbl_desc.text = "Pactos rígidos, limitações de combate e avaliação de Nen:"
			_montar_etapa_restricoes()

		Etapa.CUSTOS:
			lbl_titulo.text = "8/9: Custos, Alcance & Consumo"
			lbl_desc.text = "Calibre consumo de aura, alcance e ritmo do Hatsu:"
			_montar_etapa_custos()

		Etapa.RESUMO:
			lbl_titulo.text = "9/9: Resumo & Auditoria de Créditos"
			lbl_desc.text = "Confira o balanço entre poder funcional e limitações:"
			btn_proximo.text = "⚡ FORJAR HATSU!"
			_montar_etapa_resumo()

	_atualizar_gauge()


# ============================================================
# ETAPA 1: TIPO DE NEN
# ============================================================

func _montar_etapa_tipo_nen() -> void:
	var tipos = [
		{"cat": HatsuData.Categoria.INTENSIFICACAO, "especial": false, "nome": "👊 1. Reforço (Intensificação)", "desc": "Fortalecimento físico, impacto devastador e cura."},
		{"cat": HatsuData.Categoria.EMISSAO, "especial": false, "nome": "🎯 2. Emissão", "desc": "Projeção e sustentação de aura à distância."},
		{"cat": HatsuData.Categoria.TRANSFORMACAO, "especial": false, "nome": "⚡ 3. Transmutação (Transformação)", "desc": "Alteração das propriedades da aura (eletricidade, calor)."},
		{"cat": HatsuData.Categoria.CONJURACAO, "especial": false, "nome": "🗡️ 4. Conjuração (Materialização)", "desc": "Materialização física de objetos, armas e armaduras."},
		{"cat": HatsuData.Categoria.MANIPULACAO, "especial": false, "nome": "🧵 5. Manipulação", "desc": "Controle de matéria, marionetes e comandos condicionais."},
		{"cat": HatsuData.Categoria.ESPECIALIZACAO, "especial": false, "nome": "🌟 6. Especialização", "desc": "Habilidades singulares fora dos 5 arquétipos."},
		{"cat": HatsuData.Categoria.ESPECIALIZACAO, "especial": true, "nome": "🔮 7. Outro / Especial (Biblioteca)", "desc": "Catálogo completo: Roubo, Dreno, Livro, Cópia, Selamento."}
	]

	for t in tipos:
		var btn := Button.new()
		btn.text = t["nome"] + "\n  " + t["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if sel_tipo_especial and t["especial"]:
			btn.modulate = Color(1.0, 0.85, 0.2, 1.0)
		elif not sel_tipo_especial and not t["especial"] and t["cat"] == sel_categoria:
			btn.modulate = Color(0.4, 0.9, 1.0, 1.0)

		btn.pressed.connect(func():
			sel_tipo_especial = t["especial"]
			sel_categoria = t["cat"]
			_on_avancar_pressed()
		)
		container_opcoes.add_child(btn)


# ============================================================
# ETAPA 2: CONCEITO / PRESET
# ============================================================

func _montar_etapa_conceito() -> void:
	var presets: Array[Dictionary] = []
	if sel_tipo_especial:
		presets = HatsuPresetLibrary.obter_presets_especiais()
		presets.append(HatsuPresetLibrary.obter_preset(HatsuPresetLibrary.PresetId.CRIAR_DO_ZERO))
	else:
		presets = HatsuPresetLibrary.obter_presets_por_categoria(sel_categoria)
		presets.append(HatsuPresetLibrary.obter_preset(HatsuPresetLibrary.PresetId.CRIAR_DO_ZERO))

	for p in presets:
		var btn := Button.new()
		btn.text = p["nome"] + "\n  " + p["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if p["id"] == sel_preset_id:
			btn.modulate = Color(0.4, 1.0, 0.6, 1.0)

		btn.pressed.connect(func():
			_aplicar_preset(p)
			_on_avancar_pressed()
		)
		container_opcoes.add_child(btn)


func _aplicar_preset(preset: Dictionary) -> void:
	sel_preset_id = preset["id"]
	sel_opcoes_preset_escolhidas.clear()

	if preset["id"] == HatsuPresetLibrary.PresetId.CRIAR_DO_ZERO:
		sel_nome = "Nova Técnica"
		sel_efeitos_secundarios.clear()
		sel_condicoes.clear()
		sel_restricoes.clear()
		sel_preparation_steps.clear()
		sel_opcoes_preset.clear()
		sel_is_storage_hatsu = false
		sel_steal_conditions.clear()
		custom_vow_input = ""
		return

	sel_nome = preset["nome"].replace("🗡️ ", "").replace("🩸 ", "").replace("📖 ", "").replace("🪞 ", "").replace("📦 ", "").replace("🌀 ", "").replace("⛓️ ", "").replace("🤝 ", "").replace("📉 ", "").replace("⚡ ", "").replace("📐 ", "").replace("🎲 ", "").replace("🧪 ", "").replace("🌱 ", "")
	sel_categoria = preset["categoria"]
	sel_arquetipo = preset["arquetipo"]
	sel_objetivo = preset["objetivo"]
	sel_forma = preset["forma"]
	sel_elemento = preset["elemento"]
	sel_alvo = preset["alvo"]
	sel_efeitos_secundarios = preset["efeitos_secundarios"].duplicate()
	sel_condicoes = preset["condicoes"].duplicate()
	sel_restricoes = preset["restricoes"].duplicate()
	sel_preparation_steps = preset.get("preparation_steps", []).duplicate(true)
	custom_vow_input = preset["custom_vow_sugerido"]
	sel_opcoes_preset = preset["opcoes_funcionamento"].duplicate(true)

	sel_is_storage_hatsu = (sel_arquetipo == HatsuData.Arquetipo.LIVRO_COLECAO or preset["id"] in [HatsuPresetLibrary.PresetId.ROUBAR_HABILIDADES, HatsuPresetLibrary.PresetId.LIVRO_HABILIDADES, HatsuPresetLibrary.PresetId.ARMAZENAR_HATSU])
	if sel_is_storage_hatsu:
		sel_storage_capacity = 5
		sel_storage_duration = "PERMANENT"
		sel_storage_usage = "OPEN_BOOK"
		sel_steal_conditions = ["TOUCH_REQUIRED", "OBSERVE_GYO", "TARGET_EXPLAINS"]

	# Inicializar opções escolhidas com o primeiro valor de cada chave
	for chave in sel_opcoes_preset.keys():
		var arr = sel_opcoes_preset[chave]
		if arr is Array and not arr.is_empty():
			sel_opcoes_preset_escolhidas[chave] = arr[0]


# ============================================================
# ETAPA 3: NOME & ESTILO VISUAL
# ============================================================

func _montar_etapa_nome() -> void:
	var lbl_n := Label.new()
	lbl_n.text = "Nome da Técnica Especial:"
	lbl_n.add_theme_font_size_override("font_size", 4)
	container_opcoes.add_child(lbl_n)

	line_edit_nome.visible = true
	line_edit_nome.text = sel_nome

	var sep := HSeparator.new()
	container_opcoes.add_child(sep)

	var lbl_v := Label.new()
	lbl_v.text = "Estilo Visual da Manifestação:"
	lbl_v.add_theme_font_size_override("font_size", 4)
	container_opcoes.add_child(lbl_v)

	var estilos = [
		{"id": HatsuData.EstiloVisual.PURO_PULSANTE, "nome": "1. Puro Pulsante (Densidade de Nen)", "cor": Color(0.3, 0.7, 1.0, 1.0)},
		{"id": HatsuData.EstiloVisual.CHAMAS_FOGO, "nome": "2. Chamas Ondulantes de Fogo", "cor": Color(1.0, 0.3, 0.1, 1.0)},
		{"id": HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS, "nome": "3. Arcos e Raios Elétricos", "cor": Color(0.2, 0.9, 1.0, 1.0)},
		{"id": HatsuData.EstiloVisual.LAMINA_CORTE, "nome": "4. Lâmina / Meia-Lua Cortante", "cor": Color(0.8, 0.9, 1.0, 1.0)},
		{"id": HatsuData.EstiloVisual.SHURIKEN_GIRATORIO, "nome": "5. Shuriken Rotativo", "cor": Color(0.9, 0.8, 0.2, 1.0)},
		{"id": HatsuData.EstiloVisual.ANEIS_IMPACTO, "nome": "6. Ondas Sísmicas de Choque", "cor": Color(0.9, 0.5, 0.2, 1.0)},
		{"id": HatsuData.EstiloVisual.NEVOA_SOMBRIAS, "nome": "7. Névoa e Miasma Espectral", "cor": Color(0.4, 0.1, 0.5, 1.0)},
		{"id": HatsuData.EstiloVisual.DRAGAO_SERPENTE, "nome": "8. Dragão / Serpente de Nen", "cor": Color(1.0, 0.8, 0.2, 1.0)}
	]

	for est in estilos:
		var btn := Button.new()
		btn.text = est["nome"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if est["id"] == sel_estilo_visual:
			btn.modulate = Color(0.4, 1.0, 0.6, 1.0)
		btn.pressed.connect(func():
			sel_estilo_visual = est["id"]
			sel_cor_primaria = est["cor"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


# ============================================================
# ETAPA 4: EFEITO PRINCIPAL & FUNCIONAMENTO (AUDITADO)
# ============================================================

func _montar_etapa_funcionamento() -> void:
	if sel_is_storage_hatsu:
		# FLUXO ESPECIALIZADO: GRIMÓRIO / LIVRO DE HABILIDADES / ARMAZENAMENTO
		var lbl_cap := Label.new()
		lbl_cap.text = "📖 1. CAPACIDADE DO GRIMÓRIO / ARMAZENAMENTO:"
		lbl_cap.add_theme_font_size_override("font_size", 4)
		lbl_cap.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		container_opcoes.add_child(lbl_cap)

		var capacidades = [
			{"val": 3, "nome": "3 Slots / Páginas (+15 Demanda)", "desc": "Grimório compacto e balanceado."},
			{"val": 5, "nome": "5 Slots / Páginas (+35 Demanda)", "desc": "Grimório avançado de média capacidade."},
			{"val": 10, "nome": "10 Páginas com Marcador Duplo (+70 Demanda)", "desc": "Grimório lendário para mestres da Especialização."}
		]
		for c in capacidades:
			var btn := Button.new()
			var ativo: bool = (sel_storage_capacity == c["val"])
			btn.text = ("✅ " if ativo else "⬜ ") + c["nome"] + "\n  " + c["desc"]
			btn.add_theme_font_size_override("font_size", 4)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			if ativo: btn.modulate = Color(0.4, 1.0, 0.6, 1.0)
			var cap_val: int = int(c["val"])
			btn.pressed.connect(func():
				sel_storage_capacity = cap_val
				_atualizar_etapa()
			)
			container_opcoes.add_child(btn)

		var sep1 := HSeparator.new()
		container_opcoes.add_child(sep1)

		var lbl_dur := Label.new()
		lbl_dur.text = "⏳ 2. PERSISTÊNCIA DAS TÉCNICAS ROUBADAS:"
		lbl_dur.add_theme_font_size_override("font_size", 4)
		lbl_dur.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
		container_opcoes.add_child(lbl_dur)

		var duracoes = [
			{"id": "PERMANENT", "nome": "Permanente até Descarte (+40 Demanda)", "desc": "Permanece guardado no savegame até ser substituído."},
			{"id": "CHARGES", "nome": "3 Usos por Técnica (+0 Demanda / Limitação de Cargas)", "desc": "A técnica é consumida e removida após 3 conjurações."},
			{"id": "TIMED", "nome": "Temporário / 5 Minutos (+15 Demanda)", "desc": "Expira automaticamente após 5 minutos de combate."}
		]
		for d in duracoes:
			var btn := Button.new()
			var ativo: bool = (sel_storage_duration == d["id"])
			btn.text = ("✅ " if ativo else "⬜ ") + d["nome"] + "\n  " + d["desc"]
			btn.add_theme_font_size_override("font_size", 4)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			if ativo: btn.modulate = Color(0.4, 1.0, 0.6, 1.0)
			var dur_id: String = str(d["id"])
			btn.pressed.connect(func():
				sel_storage_duration = dur_id
				_atualizar_etapa()
			)
			container_opcoes.add_child(btn)

		var sep2 := HSeparator.new()
		container_opcoes.add_child(sep2)

		var lbl_rule := Label.new()
		lbl_rule.text = "✋ 3. REGRA DE UTILIZAÇÃO EM COMBATE:"
		lbl_rule.add_theme_font_size_override("font_size", 4)
		lbl_rule.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3, 1.0))
		container_opcoes.add_child(lbl_rule)

		var regras = [
			{"id": "OPEN_BOOK", "nome": "Manter o Livro Aberto na Mão Direita (+0 Demanda / Canônico)", "desc": "Bloqueia o uso de outras armas ou técnicas enquanto ativo."},
			{"id": "BOOKMARK", "nome": "Uso com Marcador de Página (+30 Demanda)", "desc": "Permite fechar o livro mantendo as duas mãos livres."},
			{"id": "FREE_CAST", "nome": "Invocação Livre Instantânea (+50 Demanda)", "desc": "Dispara qualquer Hatsu roubado sem necessidade do livro físico."}
		]
		for r in regras:
			var btn := Button.new()
			var ativo: bool = (sel_storage_usage == r["id"])
			btn.text = ("✅ " if ativo else "⬜ ") + r["nome"] + "\n  " + r["desc"]
			btn.add_theme_font_size_override("font_size", 4)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			if ativo: btn.modulate = Color(0.4, 1.0, 0.6, 1.0)
			var rule_id: String = str(r["id"])
			btn.pressed.connect(func():
				sel_storage_usage = rule_id
				_atualizar_etapa()
			)
			container_opcoes.add_child(btn)
		return

	# 1. Objetivo Principal
	var lbl_obj := Label.new()
	lbl_obj.text = "🎯 OBJETIVO PRINCIPAL DO HATSU:"
	lbl_obj.add_theme_font_size_override("font_size", 4)
	lbl_obj.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	container_opcoes.add_child(lbl_obj)

	var objetivos = [
		{"id": HatsuData.ObjetivoPrincipal.DANO, "nome": "💥 Dano / Impacto Destrutivo", "desc": "Foco ofensivo em eliminar oponentes."},
		{"id": HatsuData.ObjetivoPrincipal.DEFESA, "nome": "🛡️ Defesa / Barreira de Aura", "desc": "Criação de escudos, cúpulas e armaduras de Nen."},
		{"id": HatsuData.ObjetivoPrincipal.CURA, "nome": "💖 Cura / Regeneração Celular", "desc": "Restauração de vitalidade e estancamento celular."},
		{"id": HatsuData.ObjetivoPrincipal.MOBILIDADE, "nome": "🏃 Mobilidade / Aceleração", "desc": "Passos rápidos, teletransporte e esquiva com I-frames."},
		{"id": HatsuData.ObjetivoPrincipal.CONTROLE, "nome": "⛓️ Controle / Imobilização", "desc": "Paralisia, selamento de Hatsu, Zetsu e desaceleração."},
		{"id": HatsuData.ObjetivoPrincipal.SUPORTE, "nome": "🤝 Suporte / Concessão de Nen", "desc": "Buffs de equipe, transferência e acumulação de aura."}
	]
	for obj in objetivos:
		var btn := Button.new()
		var ativo: bool = (obj["id"] == sel_objetivo)
		btn.text = ("✅ " if ativo else "⬜ ") + obj["nome"] + "\n  " + obj["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if ativo:
			btn.modulate = Color(0.4, 1.0, 0.6, 1.0)
		btn.pressed.connect(func():
			sel_objetivo = obj["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)

	var sep0 := HSeparator.new()
	container_opcoes.add_child(sep0)

	# 2. Parâmetros Específicos do Conceito (Interativos)
	if not sel_opcoes_preset.is_empty():
		var lbl_opt_hdr := Label.new()
		lbl_opt_hdr.text = "⚙️ PARÂMETROS ESPECÍFICOS DO CONCEITO:"
		lbl_opt_hdr.add_theme_font_size_override("font_size", 4)
		lbl_opt_hdr.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
		container_opcoes.add_child(lbl_opt_hdr)

		for chave in sel_opcoes_preset.keys():
			var opcoes_array = sel_opcoes_preset[chave]
			var lbl_k := Label.new()
			lbl_k.text = "• " + chave.capitalize().replace("_", " ") + ":"
			lbl_k.add_theme_font_size_override("font_size", 4)
			container_opcoes.add_child(lbl_k)

			for opt in opcoes_array:
				var btn_opt := Button.new()
				var escolhida: bool = (sel_opcoes_preset_escolhidas.get(chave, "") == str(opt))
				btn_opt.text = ("  [x] " if escolhida else "  [ ] ") + str(opt)
				btn_opt.add_theme_font_size_override("font_size", 4)
				btn_opt.alignment = HORIZONTAL_ALIGNMENT_LEFT
				if escolhida:
					btn_opt.modulate = Color(0.4, 1.0, 0.6, 1.0)

				var chave_captura = chave
				var opt_captura = str(opt)
				btn_opt.pressed.connect(func():
					sel_opcoes_preset_escolhidas[chave_captura] = opt_captura
					_atualizar_etapa()
				)
				container_opcoes.add_child(btn_opt)

		var sep := HSeparator.new()
		container_opcoes.add_child(sep)

	# 3. Alvo do Hatsu
	var lbl_alvo := Label.new()
	lbl_alvo.text = "🎯 Alvo do Hatsu:"
	lbl_alvo.add_theme_font_size_override("font_size", 4)
	container_opcoes.add_child(lbl_alvo)

	var alvos = [
		{"id": HatsuData.Alvo.INIMIGO_UNICO, "nome": "1. Inimigo Único (Foco)"},
		{"id": HatsuData.Alvo.AREA, "nome": "2. Área / Múltiplos Inimigos (+25 Demanda)"},
		{"id": HatsuData.Alvo.PROPRIO_USUARIO, "nome": "3. Próprio Usuário (Auto-alvo)"},
		{"id": HatsuData.Alvo.ALIADO, "nome": "4. Aliado (Suporte)"}
	]
	for a in alvos:
		var btn := Button.new()
		var ativo: bool = (a["id"] == sel_alvo)
		btn.text = ("✅ " if ativo else "⬜ ") + a["nome"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if ativo: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_alvo = a["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)

	var sep2 := HSeparator.new()
	container_opcoes.add_child(sep2)

	# 4. Forma de Liberação
	var lbl_forma := Label.new()
	lbl_forma.text = "✨ Forma de Liberação:"
	lbl_forma.add_theme_font_size_override("font_size", 4)
	container_opcoes.add_child(lbl_forma)

	var formas = [
		{"id": HatsuData.Forma.TOQUE, "nome": "1. Toque Físico / Curto Alcance (Ko)"},
		{"id": HatsuData.Forma.PROJETIL, "nome": "2. Projétil / Disparo à Distância"},
		{"id": HatsuData.Forma.AREA, "nome": "3. Explosão / Cúpula em Área 360° (+30 Demanda)"},
		{"id": HatsuData.Forma.PESSOAL, "nome": "4. Revestimento Corporal Pessoal"},
		{"id": HatsuData.Forma.ZONA, "nome": "5. Domínio Territorial / Zona de En (+30 Demanda)"}
	]
	for f in formas:
		var btn := Button.new()
		var ativo: bool = (f["id"] == sel_forma)
		btn.text = ("✅ " if ativo else "⬜ ") + f["nome"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if ativo: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_forma = f["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


# ============================================================
# ETAPA 5: EFEITOS SECUNDÁRIOS & MODIFICADORES
# ============================================================

func _montar_etapa_efeitos_secundarios() -> void:
	if sel_is_storage_hatsu:
		# FLUXO ESPECIALIZADO: CONDIÇÕES & REQUISITOS DE ROUBO DE HATSU
		var lbl_hdr := Label.new()
		lbl_hdr.text = "📖 REQUISITOS & CONDIÇÕES DE ROUBO DE HATSU:"
		lbl_hdr.add_theme_font_size_override("font_size", 4)
		lbl_hdr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		container_opcoes.add_child(lbl_hdr)

		var lbl_sub := Label.new()
		lbl_sub.text = "Selecione as condições táticas obrigatórias para extrair a habilidade do oponente (cada uma concede Créditos de Limitação):"
		lbl_sub.add_theme_font_size_override("font_size", 4)
		lbl_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		container_opcoes.add_child(lbl_sub)

		var requisitos = [
			{"id": "TOUCH_REQUIRED", "nome": "1. Toque Físico Obrigatório (+35 Créditos)", "desc": "Requer encostar a palma da mão diretamente no oponente."},
			{"id": "OBSERVE_GYO", "nome": "2. Observar Hatsu com Gyo (+30 Créditos)", "desc": "O usuário deve testemunhar o Hatsu do oponente em ação usando Gyo."},
			{"id": "TARGET_EXPLAINS", "nome": "3. O Alvo Deve Revelar/Explicar (+45 Créditos)", "desc": "Fazer o oponente responder perguntas ou revelar como o Hatsu funciona."},
			{"id": "TARGET_DEFEATED", "nome": "4. Derrota em Duelo Individual (+40 Créditos)", "desc": "A técnica só pode ser extraída com o alvo derrotado ou em stagger."},
			{"id": "FOUR_STRICT_CONDITIONS", "nome": "5. Ritual Estrito de 4 Etapas Canônicas (+140 Créditos)", "desc": "Exige cumprir todas as 4 regras lendárias de Skill Hunter (Chrollo)."}
		]

		for req in requisitos:
			var btn := Button.new()
			var ativo: bool = (req["id"] in sel_steal_conditions)
			btn.text = ("✅ " if ativo else "⬜ ") + req["nome"] + "\n  " + req["desc"]
			btn.add_theme_font_size_override("font_size", 4)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			if ativo: btn.modulate = Color(0.4, 1.0, 0.6, 1.0)
			var r_id: String = str(req["id"])
			btn.pressed.connect(func():
				if r_id in sel_steal_conditions:
					sel_steal_conditions.erase(r_id)
				else:
					sel_steal_conditions.append(r_id)
				_atualizar_etapa()
			)
			container_opcoes.add_child(btn)
		return

	var efeitos = [
		{"id": HatsuComponentLibrary.EffectType.STUN, "nome": "⚡ Paralisia / Stun (+20 Demanda)", "desc": "Interrompe e imobiliza temporariamente o alvo."},
		{"id": HatsuComponentLibrary.EffectType.KNOCKBACK, "nome": "💨 Impacto / Repulsão (+15 Demanda)", "desc": "Empurra inimigos com força cinética."},
		{"id": HatsuComponentLibrary.EffectType.AURA_DRAIN, "nome": "🩸 Queima de Aura (+25 Demanda)", "desc": "Esgota a energia Nen do oponente."},
		{"id": HatsuComponentLibrary.EffectType.AURA_GAIN, "nome": "🔋 Recuperação de Aura (+20 Demanda)", "desc": "Regenera aura através do contato ou impacto."},
		{"id": HatsuComponentLibrary.EffectType.PIERCING, "nome": "🎯 Perfuração de Ten (+20 Demanda)", "desc": "Ignora 40% da defesa e blindagem do alvo."},
		{"id": HatsuComponentLibrary.EffectType.TRACKING, "nome": "🧭 Perseguição Homing (+25 Demanda)", "desc": "Projétil rastreia o oponente em movimento."},
		{"id": HatsuComponentLibrary.EffectType.AREA_BURST, "nome": "💥 Detonação em Área (+25 Demanda)", "desc": "Explosão secundária ao impactar."},
		{"id": HatsuComponentLibrary.EffectType.STAT_MOD, "nome": "📊 Modificador de Status (+20 Demanda)", "desc": "Aplica buffs ou debuffs em atributos vitais."},
		{"id": HatsuComponentLibrary.EffectType.MOVEMENT_DASH, "nome": "🏃 Avanço Rápido (Dash) (+20 Demanda)", "desc": "Concede impulsão veloz e esquiva com I-frames."},
		{"id": HatsuComponentLibrary.EffectType.DEVOUR_STATS, "nome": "🌀 Devour / Extração Vital (+35 Demanda)", "desc": "Absorve frações de atributos de oponentes derrotados."}
	]

	for ef in efeitos:
		var btn := Button.new()
		var ativo: bool = (ef["id"] in sel_efeitos_secundarios)
		btn.text = ("✅ " if ativo else "⬜ ") + ef["nome"] + "\n  " + ef["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if ativo:
			btn.modulate = Color(0.4, 1.0, 0.6, 1.0)

		btn.pressed.connect(func():
			if ef["id"] in sel_efeitos_secundarios:
				sel_efeitos_secundarios.erase(ef["id"])
			else:
				sel_efeitos_secundarios.append(ef["id"])
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


# ============================================================
# ETAPA 6: CONDIÇÕES DE ATIVAÇÃO & PREPARAÇÃO
# ============================================================

func _montar_etapa_condicoes() -> void:
	var lbl_p := Label.new()
	lbl_p.text = "⛓️ PASSOS DE PREPARAÇÃO PRÉVIA (PREPARATION CHAIN):"
	lbl_p.add_theme_font_size_override("font_size", 4)
	lbl_p.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	container_opcoes.add_child(lbl_p)

	var passos_disponiveis = [
		{"id": "step_toque", "description": "Tocar a palma da mão no oponente", "action": "TOQUE_FISICO", "credit_value": 25.0},
		{"id": "step_observar", "description": "Observar o Hatsu do oponente com Gyo", "action": "OBSERVAR", "credit_value": 25.0},
		{"id": "step_interrogar", "description": "O alvo precisa revelar voluntariamente sua técnica", "action": "INTERROGATORIO", "credit_value": 30.0},
		{"id": "step_canalizar", "description": "Permanecer imóvel canalizando por 2.0s", "action": "CANALIZAR", "credit_value": 30.0}
	]

	for ps in passos_disponiveis:
		var ativo: bool = false
		for sp in sel_preparation_steps:
			if sp.get("id") == ps["id"]:
				ativo = true
				break

		var btn_p := Button.new()
		btn_p.text = ("✅ [Passo] " if ativo else "⬜ [Passo] ") + ps["description"] + " (+%d Créditos)" % int(ps["credit_value"])
		btn_p.add_theme_font_size_override("font_size", 4)
		btn_p.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if ativo:
			btn_p.modulate = Color(0.4, 1.0, 0.6, 1.0)

		btn_p.pressed.connect(func():
			if ativo:
				for i in range(sel_preparation_steps.size() - 1, -1, -1):
					if sel_preparation_steps[i].get("id") == ps["id"]:
						sel_preparation_steps.remove_at(i)
			else:
				sel_preparation_steps.append(ps.duplicate())
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn_p)

	var sep := HSeparator.new()
	container_opcoes.add_child(sep)

	var lbl_c := Label.new()
	lbl_c.text = "🎯 CONDIÇÕES TÁTICAS DE ATIVAÇÃO:"
	lbl_c.add_theme_font_size_override("font_size", 4)
	lbl_c.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
	container_opcoes.add_child(lbl_c)

	var condicoes_catalogo = [
		{"id": HatsuData.Condicao.HP_ABAIXO_50, "nome": "1. Vida Abaixo de 50% (+20 Créditos)", "desc": "Só ativa quando o usuário estiver ferido (< 50% HP)."},
		{"id": HatsuData.Condicao.HP_ABAIXO_30, "nome": "2. Vida Crítica < 30% (+45 Créditos)", "desc": "Supernova desesperada ativada à beira da derrota."},
		{"id": HatsuData.Condicao.AURA_MINIMA_50, "nome": "3. Aura Restante >= 50% (+15 Créditos)", "desc": "Requer disciplina e metade da barra de aura."},
		{"id": HatsuData.Condicao.REQUER_TEN_ATIVO, "nome": "4. Manter Postura Ten (+15 Créditos)", "desc": "O usuário precisa estar mantendo Ten ativo."},
		{"id": HatsuData.Condicao.REQUER_REN_ATIVO, "nome": "5. Manter Postura Ren (+20 Créditos)", "desc": "Requer explosão de Ren contínua."},
		{"id": HatsuData.Condicao.APOS_ESQUIVA_PERFEITA, "nome": "6. Pós-Esquiva Perfeita (+30 Créditos)", "desc": "Janela de 2s após esquivar no momento exato."},
		{"id": HatsuData.Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO, "nome": "7. Apenas Contra Agressor (+50 Créditos)", "desc": "Só dispara contra quem desferiu o primeiro golpe."},
		{"id": HatsuData.Condicao.PARADO_CANALIZACAO, "nome": "8. Canalização Estática (+25 Créditos)", "desc": "Requer permanecer completamente imóvel por 1.5s."},
		{"id": HatsuData.Condicao.CURTO_ALCANCE_EXTREMO, "nome": "9. Toque / Proximidade Extrema (+25 Créditos)", "desc": "Requer contato direto a menos de 40px."},
		{"id": HatsuData.Condicao.ALMAS_INIMIGOS, "nome": "10. Gatilho no Abate (+40 Créditos)", "desc": "Ativado imediatamente após eliminar um oponente."},
		{"id": HatsuData.Condicao.REVELACAO_HABILIDADE, "nome": "11. Voto da Revelação (+20 Créditos)", "desc": "Explica a técnica em voz alta para ganhar multiplicador."},
		{"id": HatsuData.Condicao.ALVO_ELITE_BOSS, "nome": "12. Exclusivo: Chefes / Elites (+55 Créditos)", "desc": "Juramento de Chain Jail — restrito a líderes e elites."}
	]

	for c in condicoes_catalogo:
		var btn := Button.new()
		var ativa: bool = (c["id"] in sel_condicoes)
		btn.text = ("✅ " if ativa else "⬜ ") + c["nome"] + "\n  " + c["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if ativa:
			btn.modulate = Color(0.4, 1.0, 0.6, 1.0)

		btn.pressed.connect(func():
			if c["id"] in sel_condicoes:
				sel_condicoes.erase(c["id"])
			else:
				sel_condicoes.append(c["id"])
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


# ============================================================
# ETAPA 7: JURAMENTOS & RESTRIÇÕES (VOWS)
# ============================================================

func _montar_etapa_restricoes() -> void:
	var restricoes_catalogo = [
		{"id": HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE, "nome": "1. Imóvel Durante o Golpe (+40 Créditos)", "desc": "Velocidade zerada durante a execução da habilidade."},
		{"id": HatsuComponentLibrary.RestrictionType.CANNOT_DODGE, "nome": "2. Bloqueio de Esquiva (+35 Créditos)", "desc": "Não pode realizar Dash durante o efeito."},
		{"id": HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU, "nome": "3. Trava de Outros Hatsus (+30 Créditos)", "desc": "Trava outros 3 slots enquanto este estiver ativo."},
		{"id": HatsuComponentLibrary.RestrictionType.ONCE_PER_COMBAT, "nome": "4. 1 Uso por Combate (+90 Créditos)", "desc": "Apenas um único disparo em toda a batalha."},
		{"id": HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED, "nome": "5. Requer Toque Físico (+30 Créditos)", "desc": "Requer encostar a palma da mão no oponente."},
		{"id": HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY, "nome": "6. Voto da Revelação (+20 Créditos)", "desc": "O personagem anuncia em voz alta o funcionamento do golpe."},
		{"id": HatsuComponentLibrary.RestrictionType.SACRIFICE_HP, "nome": "7. Sacrifício Vital (-20% HP) (+50 Créditos)", "desc": "Consome frações de vida máxima própria ao disparar."},
		{"id": HatsuComponentLibrary.RestrictionType.SACRIFICE_AURA_MAX, "nome": "8. Zero Ko (Dreno Total de Aura) (+90 Créditos)", "desc": "Zera completamente a barra de energia Nen."},
		{"id": HatsuComponentLibrary.RestrictionType.DEATH_PENALTY_ON_MISS, "nome": "9. Voto do Cadafalso (+120 Créditos)", "desc": "Se errar ou for interrompido, sofre 50% HP e Zetsu forçado."}
	]

	for r in restricoes_catalogo:
		var btn := Button.new()
		var ativa: bool = (r["id"] in sel_restricoes)
		btn.text = ("✅ " if ativa else "⬜ ") + r["nome"] + "\n  " + r["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if ativa:
			btn.modulate = Color(1.0, 0.85, 0.2, 1.0)

		btn.pressed.connect(func():
			if r["id"] in sel_restricoes:
				sel_restricoes.erase(r["id"])
			else:
				sel_restricoes.append(r["id"])
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)

	var sep := HSeparator.new()
	container_opcoes.add_child(sep)

	var lbl_custom_title := Label.new()
	lbl_custom_title.text = "✍️ JURAMENTO PERSONALIZADO LIVRE (MOTOR DE IA DE NEN):"
	lbl_custom_title.add_theme_font_size_override("font_size", 4)
	lbl_custom_title.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
	container_opcoes.add_child(lbl_custom_title)

	line_edit_custom_vow = LineEdit.new()
	line_edit_custom_vow.placeholder_text = "Ex: só posso usar contra quem me atacar primeiro, e se errar morro..."
	line_edit_custom_vow.add_theme_font_size_override("font_size", 4)
	line_edit_custom_vow.text = custom_vow_input
	container_opcoes.add_child(line_edit_custom_vow)

	lbl_vow_analise = Label.new()
	lbl_vow_analise.add_theme_font_size_override("font_size", 4)
	lbl_vow_analise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container_opcoes.add_child(lbl_vow_analise)

	var atualizar_custom = func(new_text: String):
		custom_vow_input = new_text
		if not custom_vow_input.is_empty():
			var analise = HatsuManager.analisar_juramento_inteligente(custom_vow_input)
			if analise.get("rejeitado", false):
				lbl_vow_analise.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
				lbl_vow_analise.text = "🚫 REJEITADO PELA REGRA DE NEN:\n%s" % analise.get("analise_mestre", "")
				sel_condicoes.erase(HatsuData.Condicao.CUSTOMIZADO)
			else:
				var t_nome: String = "🟢 Condição (+25 cr)"
				var t_cor: Color = Color(0.4, 1.0, 0.6, 1.0)
				if analise.get("tier") == HatsuData.Tier.VOTO_EXTREMO:
					t_nome = "🔴 Voto Extremo (+100 cr)"
					t_cor = Color(1.0, 0.3, 0.3, 1.0)
				elif analise.get("tier") == HatsuData.Tier.JURAMENTO:
					t_nome = "🟡 Juramento Sério (+55 cr)"
					t_cor = Color(1.0, 0.85, 0.2, 1.0)

				lbl_vow_analise.add_theme_color_override("font_color", t_cor)
				lbl_vow_analise.text = "[%s] %s\n%s\nImpacto: %s" % [
					t_nome,
					analise.get("nome_reconhecido", ""),
					analise.get("analise_mestre", ""),
					analise.get("impacto_jogo", "")
				]
				if not (HatsuData.Condicao.CUSTOMIZADO in sel_condicoes):
					sel_condicoes.append(HatsuData.Condicao.CUSTOMIZADO)
				if analise.has("arquetipo"):
					sel_arquetipo = analise.get("arquetipo")
		else:
			lbl_vow_analise.text = ""
			sel_condicoes.erase(HatsuData.Condicao.CUSTOMIZADO)
		_atualizar_gauge()

	line_edit_custom_vow.text_changed.connect(atualizar_custom)
	if not custom_vow_input.is_empty():
		atualizar_custom.call(custom_vow_input)


# ============================================================
# ETAPA 8: CUSTOS & ALCANCE
# ============================================================

func _montar_etapa_custos() -> void:
	var lbl_c := Label.new()
	lbl_c.text = "💧 Consumo de Aura Desejado:"
	lbl_c.add_theme_font_size_override("font_size", 4)
	container_opcoes.add_child(lbl_c)

	var consumos = [
		{"id": HatsuData.ConsumoDesejado.BAIXO, "nome": "1. Baixo Consumo (~15 Aura)", "desc": "Spam frequente de golpes leves (+0 créditos)."},
		{"id": HatsuData.ConsumoDesejado.MEDIO, "nome": "2. Médio Consumo (~30 Aura)", "desc": "Equilíbrio padrão (+10 créditos de limitação)."},
		{"id": HatsuData.ConsumoDesejado.ALTO, "nome": "3. Alto Consumo (~55 Aura)", "desc": "Golpes decisivos de impacto (+30 créditos de limitação)."}
	]
	for cs in consumos:
		var btn := Button.new()
		btn.text = cs["nome"] + "\n  " + cs["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if cs["id"] == sel_consumo: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_consumo = cs["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)

	var sep := HSeparator.new()
	container_opcoes.add_child(sep)

	var lbl_a := Label.new()
	lbl_a.text = "📏 Alcance Efetivo:"
	lbl_a.add_theme_font_size_override("font_size", 4)
	container_opcoes.add_child(lbl_a)

	var alcances = [
		{"id": HatsuData.AlcanceTipo.CURTO, "nome": "1. Curto Alcance (45px)", "desc": "Impacto corpo a corpo concentrado."},
		{"id": HatsuData.AlcanceTipo.MEDIO, "nome": "2. Médio Alcance (130px)", "desc": "Distância tática intermediária."},
		{"id": HatsuData.AlcanceTipo.LONGO, "nome": "3. Longo Alcance (220px)", "desc": "Projeção estendida de artilharia sniper (+25 Demanda)."}
	]
	for al in alcances:
		var btn := Button.new()
		btn.text = al["nome"] + "\n  " + al["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if al["id"] == sel_alcance: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_alcance = al["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


# ============================================================
# ETAPA 9: RESUMO, AUDITORIA DE CRÉDITOS & CRIAÇÃO
# ============================================================

func _montar_etapa_resumo() -> void:
	var h_temp := HatsuManager.criar_hatsu(
		sel_nome, sel_categoria, sel_forma, sel_condicoes,
		sel_objetivo, sel_elemento, sel_alvo, sel_alcance, sel_consumo, custom_vow_input, sel_arquetipo,
		sel_cor_primaria, sel_cor_secundaria, sel_estilo_visual,
		sel_preparation_steps, sel_efeitos_secundarios,
		sel_restricoes, sel_opcoes_preset_escolhidas,
		sel_is_storage_hatsu, sel_storage_capacity, sel_storage_duration, sel_storage_usage, sel_steal_conditions, sel_steal_target
	)
	var ef: float = NenAffinityData.calcular_eficiencia_categoria(PlayerData.afinidade_nen, sel_categoria)
	var f_power := h_temp.calcular_functional_power()
	var l_credits := h_temp.calcular_limitation_credits()
	var deficit := int(h_temp.credit_deficit)

	var lbl_res := Label.new()
	lbl_res.add_theme_font_size_override("font_size", 4)
	lbl_res.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var obj_nome: String = "Dano"
	match sel_objetivo:
		HatsuData.ObjetivoPrincipal.DEFESA: obj_nome = "Defesa / Blindagem"
		HatsuData.ObjetivoPrincipal.CURA: obj_nome = "Cura / Regeneração"
		HatsuData.ObjetivoPrincipal.MOBILIDADE: obj_nome = "Mobilidade Rápida"
		HatsuData.ObjetivoPrincipal.CONTROLE: obj_nome = "Controle / Imobilização"
		HatsuData.ObjetivoPrincipal.SUPORTE: obj_nome = "Suporte / Concessão"

	var status_text: String = "✨ TÉCNICA 100%% EQUILIBRADA (Pronta para Forjar!)" if deficit == 0 else "⚠️ DÉFICIT DE %d CRÉDITOS (Bloqueado para Forja)" % deficit

	if sel_is_storage_hatsu:
		lbl_res.text = "Nome: %s\nTipo: %s (%d%% Eficiência)\nArquétipo: Grimório / Armazenamento de Hatsu\nCapacidade: %d Páginas | Duração: %s\nRegra: %s | Exigências de Roubo: %d\nDemanda Funcional: %d pts | Créditos Obtidos: %d pts\nDéficit de Limitações: %d pts\nStatus: %s\nPassos: %d | Condições: %d | Restrições: %d" % [
			sel_nome,
			HatsuManager.obter_nome_categoria(sel_categoria),
			int(ef * 100),
			sel_storage_capacity,
			sel_storage_duration,
			sel_storage_usage,
			sel_steal_conditions.size(),
			int(f_power),
			int(l_credits),
			deficit,
			status_text,
			sel_preparation_steps.size(),
			h_temp.condicoes.size(),
			sel_restricoes.size()
		]
	else:
		lbl_res.text = "Nome: %s\nTipo: %s (%d%% Eficiência)\nObjetivo: %s | Forma: %s\nDemanda Funcional: %d pts | Créditos Obtidos: %d pts\nDéficit de Limitações: %d pts\nStatus: %s\nPassos: %d | Condições: %d | Restrições: %d" % [
			sel_nome,
			HatsuManager.obter_nome_categoria(sel_categoria),
			int(ef * 100),
			obj_nome,
			HatsuManager.obter_nome_forma_contextual(sel_forma, sel_objetivo),
			int(f_power),
			int(l_credits),
			deficit,
			status_text,
			sel_preparation_steps.size(),
			h_temp.condicoes.size(),
			sel_restricoes.size()
		]
	container_opcoes.add_child(lbl_res)

	if deficit > 0:
		btn_proximo.modulate = Color(1.0, 0.4, 0.4, 1.0)
		btn_proximo.text = "⚠️ Déficit Pendente"
	else:
		btn_proximo.modulate = Color(0.4, 1.0, 0.6, 1.0)
		btn_proximo.text = "⚡ FORJAR HATSU!"


# ============================================================
# ATUALIZAÇÃO DO GAUGE DE EQUILÍBRIO (v1.6)
# ============================================================

func _atualizar_gauge() -> void:
	if not is_instance_valid(panel_gauge): return

	var ef: float = NenAffinityData.calcular_eficiencia_categoria(PlayerData.afinidade_nen, sel_categoria)
	var compat_pct: int = int(ef * 100)

	var h_temp := HatsuManager.criar_hatsu(
		sel_nome, sel_categoria, sel_forma, sel_condicoes,
		sel_objetivo, sel_elemento, sel_alvo, sel_alcance, sel_consumo, custom_vow_input, sel_arquetipo,
		sel_cor_primaria, sel_cor_secundaria, sel_estilo_visual,
		sel_preparation_steps, sel_efeitos_secundarios,
		sel_restricoes, sel_opcoes_preset_escolhidas,
		sel_is_storage_hatsu, sel_storage_capacity, sel_storage_duration, sel_storage_usage, sel_steal_conditions, sel_steal_target
	)

	var f_power: int = int(h_temp.calcular_functional_power())
	var l_credits: int = int(h_temp.calcular_limitation_credits())
	var deficit: int = int(h_temp.credit_deficit)
	var v_score: int = int(h_temp.calcular_versatility_score())
	var equilibrado: bool = (deficit == 0)

	lbl_compat.text = "Compatib.: " + str(compat_pct) + "%"
	lbl_aura.text = "Demanda: %d cr" % f_power
	lbl_potencial.text = "Créditos: %d cr" % l_credits
	lbl_complexidade.text = "Déficit: %d cr" % deficit

	if equilibrado:
		lbl_dica_dinamica.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6, 1.0))
		lbl_dica_dinamica.text = "✅ TÉCNICA 100%% EQUILIBRADA\nNecessários: %d cr | Pagos: %d cr\nDéficit: 0 cr\nPronto para forjar!" % [f_power, l_credits]
	else:
		lbl_dica_dinamica.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
		lbl_dica_dinamica.text = "⚠️ DÉFICIT DE %d CRÉDITOS:\nNecessários: %d cr | Pagos: %d cr\nAdicione condições, restrições ou passos de preparação!" % [deficit, f_power, l_credits]


# ============================================================
# NAVEGAÇÃO & FINALIZAÇÃO
# ============================================================

func _on_voltar_pressed() -> void:
	if etapa_atual > Etapa.TIPO_NEN:
		etapa_atual = (int(etapa_atual) - 1) as Etapa
		_atualizar_etapa()


func _on_avancar_pressed() -> void:
	if etapa_atual == Etapa.NOME:
		if line_edit_nome != null and not line_edit_nome.text.is_empty():
			sel_nome = line_edit_nome.text

	if etapa_atual < Etapa.RESUMO:
		etapa_atual = (int(etapa_atual) + 1) as Etapa
		_atualizar_etapa()
	else:
		_finalizar_criacao(false)


func _finalizar_criacao(is_draft: bool = false) -> void:
	if line_edit_nome != null and not line_edit_nome.text.is_empty():
		sel_nome = line_edit_nome.text

	var novo_hatsu := HatsuManager.criar_hatsu(
		sel_nome, sel_categoria, sel_forma, sel_condicoes,
		sel_objetivo, sel_elemento, sel_alvo, sel_alcance, sel_consumo, custom_vow_input, sel_arquetipo,
		sel_cor_primaria, sel_cor_secundaria, sel_estilo_visual,
		sel_preparation_steps, sel_efeitos_secundarios,
		sel_restricoes, sel_opcoes_preset_escolhidas,
		sel_is_storage_hatsu, sel_storage_capacity, sel_storage_duration, sel_storage_usage, sel_steal_conditions, sel_steal_target
	)

	novo_hatsu.is_custom_created = true
	novo_hatsu.is_draft = is_draft
	novo_hatsu.hatsu_version = 2
	novo_hatsu.creator_id = str(PlayerData.nome_personagem)
	novo_hatsu.preparation_steps = sel_preparation_steps.duplicate(true)
	novo_hatsu.sub_effects = sel_efeitos_secundarios.duplicate()
	novo_hatsu.modular_restrictions = sel_restricoes.duplicate()
	novo_hatsu.parametros_conceito = sel_opcoes_preset_escolhidas.duplicate(true)

	# Mapear Core Component
	match sel_forma:
		HatsuData.Forma.PROJETIL: novo_hatsu.core_component = HatsuComponentLibrary.CoreType.PROJECTILE
		HatsuData.Forma.AREA, HatsuData.Forma.ZONA: novo_hatsu.core_component = HatsuComponentLibrary.CoreType.ZONE
		HatsuData.Forma.PESSOAL:
			if sel_categoria == HatsuData.Categoria.TRANSFORMACAO:
				novo_hatsu.core_component = HatsuComponentLibrary.CoreType.TRANSFORMATION
			elif sel_categoria == HatsuData.Categoria.CONJURACAO:
				novo_hatsu.core_component = HatsuComponentLibrary.CoreType.SUMMON
			else:
				novo_hatsu.core_component = HatsuComponentLibrary.CoreType.STRIKE
		_: novo_hatsu.core_component = HatsuComponentLibrary.CoreType.STRIKE

	# Configurar Perfil Visual Customizado
	var vp := VisualProfile.new()
	vp.primary_color = sel_cor_primaria
	vp.secondary_color = sel_cor_secundaria
	vp.core_color = Color(1.0, 1.0, 1.0, 1.0)
	vp.glow_color = sel_cor_primaria
	vp.glow_intensity = 0.85
	vp.trail_enabled = (sel_forma == HatsuData.Forma.PROJETIL)
	vp.trail_color = sel_cor_primaria
	match sel_forma:
		HatsuData.Forma.PROJETIL: vp.shape = VisualProfile.VisualShape.SPHERE
		HatsuData.Forma.AREA, HatsuData.Forma.ZONA: vp.shape = VisualProfile.VisualShape.RING
		HatsuData.Forma.TOQUE: vp.shape = VisualProfile.VisualShape.BLADE
		_: vp.shape = VisualProfile.VisualShape.SPHERE
	novo_hatsu.visual_profile = vp

	# Validar Power & Limitation Budget
	var validacao = HatsuManager.validate_hatsu(novo_hatsu)
	HatsuManager.calculate_power_budget(novo_hatsu)

	# Se NÃO for rascunho e houver déficit pendente, BLOQUEIA a forja
	if not is_draft and novo_hatsu.credit_deficit > 0:
		lbl_desc.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
		lbl_desc.text = "❌ DÉFICIT DE %d CRÉDITOS: Não é possível forjar o Hatsu até pagar todas as limitações! Adicione condições/restrições ou salve como Rascunho." % int(novo_hatsu.credit_deficit)
		print("[HatsuCreationUI] ❌ Criação bloqueada devido a Déficit de Créditos: ", novo_hatsu.credit_deficit)
		return

	var index: int = PlayerData.adicionar_hatsu(novo_hatsu)
	hatsu_criado.emit(novo_hatsu)

	if SaveManager != null:
		SaveManager.salvar_jogo()

	if EventBus != null:
		EventBus.emit_toast("⚡ Hatsu '%s' forjado com sucesso!" % novo_hatsu.nome, Color(0.4, 1.0, 0.6))

	# Atualizar HunterMenuUI se estiver instanciado
	var root = get_tree().root if get_tree() else null
	if root != null:
		var hm = root.get_node_or_null("HunterMenuUI")
		if hm != null and hm.has_method("_atualizar_conteudo_hatsu"):
			hm._atualizar_conteudo_hatsu()

	if is_draft:
		print("[HatsuCreationUI] 💾 Rascunho de Hatsu salvo com sucesso! Slot index: ", index, " | Déficit: ", novo_hatsu.credit_deficit)
	else:
		print("[HatsuCreationUI] ⚡ Novo Hatsu v1.6 forjado com sucesso! Slot index: ", index, " | Demanda: ", novo_hatsu.functional_power, " | Créditos: ", novo_hatsu.limitation_credits)

	fechar()
