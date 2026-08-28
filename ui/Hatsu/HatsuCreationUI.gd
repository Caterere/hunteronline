class_name HatsuCreationUI
extends CanvasLayer

const VisualProfile = preload("res://resource/hatsu/VisualProfile.gd")

# ============================================================
# HUNTER ONLINE - HATSU CREATION UI (10 ETAPAS CONTEXTUAIS & IA DE NEN)
# ============================================================
#
# Interface de criação de Hatsu com sistema de Vow & Limitation.
# Ajustada estritamente para viewport 320x180 (Painel 304x168 centralizado).
# Passa por 10 etapas sequenciais guiadas e contextuais:
# 1. Nome
# 2. Objetivo Principal (Dano, Defesa, Cura, Mobilidade, Controle)
# 3. Forma de Liberação (Adaptada ao objetivo)
# 4. Elemento / Natureza (Efeitos ofensivos ou defensivos)
# 5. Alvo (Auto-alvo, Aliado, Inimigo)
# 6. Alcance / Raio de Proteção
# 7. Consumo Desejado
# 8. Condições de Ativação
# 9. Juramentos & Avaliador de Regras de Nen (Vows & Limitations)
# 10. Resumo & Medidor de Equilíbrio
#
# ============================================================

signal hatsu_criado(hatsu: HatsuData)
signal menu_fechado

enum Etapa {
	NOME,
	OBJETIVO,
	FORMA,
	ELEMENTO,
	ALVO,
	ALCANCE,
	CONSUMO,
	CONDICOES,
	RESTRICOES,
	RESUMO
}

var etapa_atual: Etapa = Etapa.NOME

# Escolhas do Hatsu
var sel_nome: String = "Meu Hatsu"
var sel_categoria: HatsuData.Categoria = HatsuData.Categoria.INTENSIFICACAO
var sel_objetivo: HatsuData.ObjetivoPrincipal = HatsuData.ObjetivoPrincipal.DANO
var sel_forma: HatsuData.Forma = HatsuData.Forma.TOQUE
var sel_elemento: HatsuData.Elemento = HatsuData.Elemento.NEN_PURO
var sel_alvo: HatsuData.Alvo = HatsuData.Alvo.INIMIGO_UNICO
var sel_alcance: HatsuData.AlcanceTipo = HatsuData.AlcanceTipo.MEDIO
var sel_consumo: HatsuData.ConsumoDesejado = HatsuData.ConsumoDesejado.MEDIO
var sel_condicoes: Array[HatsuData.Condicao] = []
var sel_arquetipo: HatsuData.Arquetipo = HatsuData.Arquetipo.SIMPLES
var sel_cor_primaria: Color = Color(0.3, 0.7, 1.0, 1.0)
var sel_cor_secundaria: Color = Color(1.0, 1.0, 1.0, 0.9)
var sel_estilo_visual: HatsuData.EstiloVisual = HatsuData.EstiloVisual.PURO_PULSANTE
var custom_vow_input: String = ""

# UI Containers
var panel_main: PanelContainer
var vbox_content: VBoxContainer
var lbl_titulo: Label
var lbl_desc: Label
var container_opcoes: VBoxContainer
var line_edit_nome: LineEdit
var line_edit_custom_vow: LineEdit
var lbl_vow_analise: Label
var btn_proximo: Button
var btn_anterior: Button
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
	etapa_atual = Etapa.NOME
	sel_nome = "Nova Técnica"
	sel_categoria = PlayerData.afinidade_nen as HatsuData.Categoria
	sel_objetivo = HatsuData.ObjetivoPrincipal.DANO
	sel_forma = HatsuData.Forma.TOQUE
	sel_elemento = HatsuData.Elemento.NEN_PURO
	sel_alvo = HatsuData.Alvo.INIMIGO_UNICO
	sel_alcance = HatsuData.AlcanceTipo.MEDIO
	sel_consumo = HatsuData.ConsumoDesejado.MEDIO
	sel_condicoes.clear()
	custom_vow_input = ""
	visible = true
	get_tree().paused = true
	_atualizar_etapa()


func fechar() -> void:
	visible = false
	get_tree().paused = false
	menu_fechado.emit()


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
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 3)
	panel_main.add_child(margin)

	var hbox_colunas := HBoxContainer.new()
	hbox_colunas.add_theme_constant_override("separation", 4)
	margin.add_child(hbox_colunas)

	# Coluna Esquerda: Forjador (195px)
	vbox_content = VBoxContainer.new()
	vbox_content.custom_minimum_size = Vector2(195, 160)
	vbox_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_content.add_theme_constant_override("separation", 2)
	hbox_colunas.add_child(vbox_content)

	# Cabeçalho
	var hbox_hdr := HBoxContainer.new()
	vbox_content.add_child(hbox_hdr)

	lbl_titulo = Label.new()
	lbl_titulo.add_theme_font_size_override("font_size", 5)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_titulo.text = "⚡ FORJAR NOVO HATSU"
	hbox_hdr.add_child(lbl_titulo)

	btn_fechar = Button.new()
	btn_fechar.text = "✖ Sair"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(fechar)
	hbox_hdr.add_child(btn_fechar)

	lbl_desc = Label.new()
	lbl_desc.add_theme_font_size_override("font_size", 4)
	lbl_desc.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 1.0))
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_content.add_child(lbl_desc)

	# Scroll de Opções
	var scroll_opcoes := ScrollContainer.new()
	scroll_opcoes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_opcoes.custom_minimum_size = Vector2(195, 88)
	scroll_opcoes.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox_content.add_child(scroll_opcoes)

	container_opcoes = VBoxContainer.new()
	container_opcoes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container_opcoes.add_theme_constant_override("separation", 2)
	scroll_opcoes.add_child(container_opcoes)

	line_edit_nome = LineEdit.new()
	line_edit_nome.add_theme_font_size_override("font_size", 5)
	line_edit_nome.placeholder_text = "Digite o nome da habilidade..."
	line_edit_nome.visible = false
	container_opcoes.add_child(line_edit_nome)

	# Rodapé de Navegação
	var hbox_nav := HBoxContainer.new()
	hbox_nav.alignment = BoxContainer.ALIGNMENT_END
	hbox_nav.add_theme_constant_override("separation", 3)
	vbox_content.add_child(hbox_nav)

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


func _construir_gauge(parent: Control) -> void:
	panel_gauge = PanelContainer.new()
	panel_gauge.custom_minimum_size = Vector2(95, 160)
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
	lbl_potencial.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
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
# ATUALIZAÇÃO DAS 10 ETAPAS CONTEXTUAIS
# ============================================================

func _atualizar_etapa() -> void:
	for child in container_opcoes.get_children():
		if child != line_edit_nome:
			child.queue_free()

	line_edit_nome.visible = false
	btn_anterior.visible = (etapa_atual != Etapa.NOME)
	btn_proximo.text = "Avançar >"

	match etapa_atual:
		Etapa.NOME:
			lbl_titulo.text = "1/10: Nome da Habilidade"
			lbl_desc.text = "Como se chamará sua técnica especial de Hatsu?"
			_montar_etapa_nome()

		Etapa.OBJETIVO:
			lbl_titulo.text = "2/10: Objetivo Principal"
			lbl_desc.text = "Qual é o foco tático desta técnica?"
			_montar_etapa_objetivo()

		Etapa.FORMA:
			lbl_titulo.text = "3/10: Manifestação de Aura"
			lbl_desc.text = "Como a energia será moldada para cumprir o objetivo?"
			_montar_etapa_forma()

		Etapa.ELEMENTO:
			lbl_titulo.text = "4/10: Propriedade / Elemento"
			lbl_desc.text = "Qual natureza ou elemento é transmutado na aura?"
			_montar_etapa_elemento()

		Etapa.ALVO:
			lbl_titulo.text = "5/10: Alvo do Hatsu"
			lbl_desc.text = "Quem receberá o efeito da sua técnica?"
			_montar_etapa_alvo()

		Etapa.ALCANCE:
			if sel_objetivo == HatsuData.ObjetivoPrincipal.DEFESA:
				lbl_titulo.text = "6/10: Densidade da Blindagem"
				lbl_desc.text = "Qual a cobertura e espessura do campo protetor?"
			elif sel_objetivo == HatsuData.ObjetivoPrincipal.CURA:
				lbl_titulo.text = "6/10: Potência Celular"
				lbl_desc.text = "Qual a intensidade da regeneração de aura?"
			else:
				lbl_titulo.text = "6/10: Alcance Efetivo"
				lbl_desc.text = "Qual distância a aura percorre?"
			_montar_etapa_alcance()

		Etapa.CONSUMO:
			lbl_titulo.text = "7/10: Consumo de Aura Desejado"
			lbl_desc.text = "Quanto maior o gasto de aura, mais densa e potente a técnica."
			_montar_etapa_consumo()

		Etapa.CONDICOES:
			lbl_titulo.text = "8/10: Condições de Ativação"
			lbl_desc.text = "Condições táticas de risco aumentam a potência (+30% a +65%)."
			_montar_etapa_condicoes()

		Etapa.RESTRICOES:
			lbl_titulo.text = "9/10: Juramentos & Vows (Mangá / IA)"
			lbl_desc.text = "Pactos, sacrifícios ou digite seu juramento personalizado livre!"
			_montar_etapa_restricoes()

		Etapa.RESUMO:
			lbl_titulo.text = "10/10: Selar Juramento & Criar Hatsu"
			lbl_desc.text = "Confira a compatibilidade e o equilíbrio da sua criação:"
			btn_proximo.text = "CRIAR HATSU!"
			_montar_etapa_resumo()

	_atualizar_gauge()


# ============================================================
# MONTAGEM DE CADA ETAPA
# ============================================================

func _montar_etapa_nome() -> void:
	line_edit_nome.visible = true
	line_edit_nome.text = sel_nome
	line_edit_nome.grab_focus()


func _montar_etapa_objetivo() -> void:
	var objetivos = [
		{"id": HatsuData.ObjetivoPrincipal.DANO, "nome": "1. Dano Ofensivo", "desc": "Causar alto impacto, cortes ou rajadas elementais."},
		{"id": HatsuData.ObjetivoPrincipal.DEFESA, "nome": "2. Defesa / Blindagem", "desc": "Criar armadura de aura, barreiras e absorção de dano."},
		{"id": HatsuData.ObjetivoPrincipal.CURA, "nome": "3. Cura / Regeneração", "desc": "Acelerar recuperação biológica celular própria ou de aliados."},
		{"id": HatsuData.ObjetivoPrincipal.MOBILIDADE, "nome": "4. Mobilidade Rápida", "desc": "Dash supersônico de aura, impulsão e reflexos aumentados."},
		{"id": HatsuData.ObjetivoPrincipal.CONTROLE, "nome": "5. Controle / Imobilização", "desc": "Atordoar, paralisar ou restringir opositores."}
	]
	for ob in objetivos:
		var btn = Button.new()
		btn.text = ob["nome"] + "\n  " + ob["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if ob["id"] == sel_objetivo: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_objetivo = ob["id"]
			# Auto-ajustar forma e alvo para coerência imediata
			if sel_objetivo == HatsuData.ObjetivoPrincipal.DEFESA or sel_objetivo == HatsuData.ObjetivoPrincipal.CURA or sel_objetivo == HatsuData.ObjetivoPrincipal.MOBILIDADE:
				sel_alvo = HatsuData.Alvo.PROPRIO_USUARIO
				sel_forma = HatsuData.Forma.PESSOAL
			else:
				sel_alvo = HatsuData.Alvo.INIMIGO_UNICO
				sel_forma = HatsuData.Forma.TOQUE
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


func _montar_etapa_forma() -> void:
	var formas: Array = []
	match sel_objetivo:
		HatsuData.ObjetivoPrincipal.DEFESA:
			formas = [
				{"id": HatsuData.Forma.PESSOAL, "nome": "1. Armadura Pessoal de Aura", "desc": "Envolve o corpo em blindagem densa de alta absorção."},
				{"id": HatsuData.Forma.AREA, "nome": "2. Cúpula Protetora (Área 360°)", "desc": "Ergue um domo de aura que resguarda a área ao redor."},
				{"id": HatsuData.Forma.TOQUE, "nome": "3. Barreira Reativa ao Impacto", "desc": "Escudo frontal que repele ataques com contra-golpe."}
			]
		HatsuData.ObjetivoPrincipal.CURA:
			formas = [
				{"id": HatsuData.Forma.PESSOAL, "nome": "1. Regeneração Celular (Em Si)", "desc": "Restaura instantaneamente seus pontos de vida."},
				{"id": HatsuData.Forma.AREA, "nome": "2. Círculo Restaurador de Aura", "desc": "Onda de cura que restaura em área ao redor."},
				{"id": HatsuData.Forma.TOQUE, "nome": "3. Toque Curativo Instantâneo", "desc": "Foco de Ko nas mãos para cura rápida de emergência."}
			]
		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			formas = [
				{"id": HatsuData.Forma.PESSOAL, "nome": "1. Dash / Impulsão Rápida", "desc": "Avanço supersônico com I-frames temporários."},
				{"id": HatsuData.Forma.PROJETIL, "nome": "2. Salto Dimensional / Teleporte", "desc": "Projeta a aura à frente e avança instantaneamente."}
			]
		HatsuData.ObjetivoPrincipal.CONTROLE:
			formas = [
				{"id": HatsuData.Forma.PROJETIL, "nome": "1. Disparo de Aprisionamento", "desc": "Agulhas ou fios de Nen que imobilizam o alvo."},
				{"id": HatsuData.Forma.AREA, "nome": "2. Onda Sísmica / Pulso de Stun", "desc": "Explosão de intimidação que atordoa em 360°."}
			]
		HatsuData.ObjetivoPrincipal.DANO, _:
			formas = [
				{"id": HatsuData.Forma.TOQUE, "nome": "1. Golpe Direto / Toque Físico", "desc": "Concentração máxima de Nen no ponto de contato."},
				{"id": HatsuData.Forma.PROJETIL, "nome": "2. Projétil de Aura (Disparo)", "desc": "Dispara esferas ou feixes na direção do olhar."},
				{"id": HatsuData.Forma.AREA, "nome": "3. Onda de Choque em Área", "desc": "Libera explosão de Nen em 360° em volta do corpo."}
			]

	for f in formas:
		var btn = Button.new()
		btn.text = f["nome"] + "\n  " + f["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if f["id"] == sel_forma: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_forma = f["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


func _montar_etapa_elemento() -> void:
	var elementos = [
		{"id": HatsuData.Elemento.NEN_PURO, "nome": "Nen Puro"},
		{"id": HatsuData.Elemento.ELETRICIDADE, "nome": "Eletricidade"},
		{"id": HatsuData.Elemento.FOGO, "nome": "Fogo / Calor"},
		{"id": HatsuData.Elemento.GELO, "nome": "Gelo"},
		{"id": HatsuData.Elemento.VENENO, "nome": "Veneno"},
		{"id": HatsuData.Elemento.SOM, "nome": "Som / Vibração"},
		{"id": HatsuData.Elemento.LUZ, "nome": "Luz / Clarão"},
		{"id": HatsuData.Elemento.SOMBRA, "nome": "Sombra"}
	]
	for el in elementos:
		var desc_ctx: String = HatsuManager.obter_desc_elemento_contextual(el["id"], sel_objetivo)
		var btn = Button.new()
		btn.text = el["nome"] + "\n  " + desc_ctx
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if el["id"] == sel_elemento: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_elemento = el["id"]
			# Auto-ajustar cor e estilo padrão pelo elemento
			match el["id"]:
				HatsuData.Elemento.ELETRICIDADE:
					sel_cor_primaria = Color(0.2, 0.9, 1.0, 1.0)
					sel_estilo_visual = HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS
				HatsuData.Elemento.FOGO:
					sel_cor_primaria = Color(1.0, 0.3, 0.1, 1.0)
					sel_estilo_visual = HatsuData.EstiloVisual.CHAMAS_FOGO
				HatsuData.Elemento.GELO:
					sel_cor_primaria = Color(0.6, 0.9, 1.0, 1.0)
					sel_estilo_visual = HatsuData.EstiloVisual.LAMINA_CORTE
				HatsuData.Elemento.SOMBRA:
					sel_cor_primaria = Color(0.3, 0.1, 0.4, 1.0)
					sel_estilo_visual = HatsuData.EstiloVisual.NEVOA_SOMBRIAS
				HatsuData.Elemento.SOM:
					sel_cor_primaria = Color(0.9, 0.9, 0.3, 1.0)
					sel_estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
				HatsuData.Elemento.LUZ:
					sel_cor_primaria = Color(1.0, 1.0, 0.8, 1.0)
					sel_estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
				_:
					sel_cor_primaria = Color(0.3, 0.8, 1.0, 1.0)
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)

	# --- SEÇÃO DE CUSTOMIZAÇÃO VISUAL PROCEDURAL ---
	var sep := HSeparator.new()
	container_opcoes.add_child(sep)

	var lbl_vis_hdr := Label.new()
	lbl_vis_hdr.text = "🎨 APARÊNCIA & ESTILO VISUAL (PROCEDURAL):"
	lbl_vis_hdr.add_theme_font_size_override("font_size", 4)
	lbl_vis_hdr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	container_opcoes.add_child(lbl_vis_hdr)

	# Paleta de Cores
	var grid_cores := GridContainer.new()
	grid_cores.columns = 4
	container_opcoes.add_child(grid_cores)

	var paleta_cores = [
		{"nome": "🔵 Azul Celeste", "cor": Color(0.2, 0.7, 1.0)},
		{"nome": "🔴 Carmesim", "cor": Color(1.0, 0.25, 0.2)},
		{"nome": "🟡 Dourado", "cor": Color(1.0, 0.85, 0.2)},
		{"nome": "🟣 Roxo Nen", "cor": Color(0.7, 0.2, 1.0)},
		{"nome": "🟢 Esmeralda", "cor": Color(0.2, 0.9, 0.4)},
		{"nome": "⚪ Radiante", "cor": Color(0.95, 0.95, 1.0)},
		{"nome": "🌑 Trevas", "cor": Color(0.25, 0.15, 0.35)},
		{"nome": "🌸 Rosa Choque", "cor": Color(1.0, 0.3, 0.7)}
	]

	for cp in paleta_cores:
		var btn_c := Button.new()
		btn_c.text = cp["nome"]
		btn_c.add_theme_font_size_override("font_size", 4)
		if sel_cor_primaria == cp["cor"]: btn_c.modulate = Color(1.5, 1.5, 1.5, 1.0)
		btn_c.pressed.connect(func():
			sel_cor_primaria = cp["cor"]
			_atualizar_etapa()
		)
		grid_cores.add_child(btn_c)

	# Seletor de Estilos Visuais
	var grid_estilos := GridContainer.new()
	grid_estilos.columns = 2
	container_opcoes.add_child(grid_estilos)

	var estilos = [
		{"id": HatsuData.EstiloVisual.PURO_PULSANTE, "nome": "🌟 Pulso / Orbe Puro"},
		{"id": HatsuData.EstiloVisual.CHAMAS_FOGO, "nome": "🔥 Chamas Ondulantes"},
		{"id": HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS, "nome": "⚡ Raios Elétricos"},
		{"id": HatsuData.EstiloVisual.LAMINA_CORTE, "nome": "🌙 Lâmina Cortante"},
		{"id": HatsuData.EstiloVisual.SHURIKEN_GIRATORIO, "nome": "🌀 Shuriken Rotativo"},
		{"id": HatsuData.EstiloVisual.ANEIS_IMPACTO, "nome": "💫 Anéis de Choque"},
		{"id": HatsuData.EstiloVisual.NEVOA_SOMBRIAS, "nome": "🌫️ Névoa Sombria"},
		{"id": HatsuData.EstiloVisual.DRAGAO_SERPENTE, "nome": "🐉 Dragão de Nen"}
	]

	for es in estilos:
		var btn_e := Button.new()
		btn_e.text = es["nome"]
		btn_e.add_theme_font_size_override("font_size", 4)
		if es["id"] == sel_estilo_visual: btn_e.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn_e.pressed.connect(func():
			sel_estilo_visual = es["id"]
			_atualizar_etapa()
		)
		grid_estilos.add_child(btn_e)


func _montar_etapa_alvo() -> void:
	var alvos: Array = []
	if sel_objetivo == HatsuData.ObjetivoPrincipal.DEFESA or sel_objetivo == HatsuData.ObjetivoPrincipal.CURA or sel_objetivo == HatsuData.ObjetivoPrincipal.MOBILIDADE:
		alvos = [
			{"id": HatsuData.Alvo.PROPRIO_USUARIO, "nome": "1. Próprio Usuário (Auto-alvo)", "desc": "Aplica o efeito diretamente no seu próprio corpo."},
			{"id": HatsuData.Alvo.AREA, "nome": "2. Área ao Redor", "desc": "Cria o campo protetor/curativo ao redor de você."},
			{"id": HatsuData.Alvo.ALIADO, "nome": "3. Aliado / Grupo", "desc": "Direciona a aura para fortalecer um companheiro."}
		]
	else:
		alvos = [
			{"id": HatsuData.Alvo.INIMIGO_UNICO, "nome": "1. Inimigo Único (Alvo Direto)", "desc": "Foco concentrado em um único oponente."},
			{"id": HatsuData.Alvo.AREA, "nome": "2. Área de Inimigos (Múltiplos)", "desc": "Atinge todos os inimigos presentes na área de efeito."}
		]

	for a in alvos:
		var btn = Button.new()
		btn.text = a["nome"] + "\n  " + a["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if a["id"] == sel_alvo: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_alvo = a["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


func _montar_etapa_alcance() -> void:
	var alcances: Array = []
	if sel_objetivo == HatsuData.ObjetivoPrincipal.DEFESA:
		alcances = [
			{"id": HatsuData.AlcanceTipo.CURTO, "nome": "1. Blindagem Compacta", "desc": "Escudo aderido ao corpo (+20% resistência física)."},
			{"id": HatsuData.AlcanceTipo.MEDIO, "nome": "2. Barreira Padrão", "desc": "Raio de proteção equilibrado (65px)."},
			{"id": HatsuData.AlcanceTipo.LONGO, "nome": "3. Domo Expandido", "desc": "Grande cúpula protetora de área (95px)."}
		]
	elif sel_objetivo == HatsuData.ObjetivoPrincipal.CURA:
		alcances = [
			{"id": HatsuData.AlcanceTipo.CURTO, "nome": "1. Concentração Local", "desc": "Cura direta rápida de emergência."},
			{"id": HatsuData.AlcanceTipo.MEDIO, "nome": "2. Regeneração Padrão", "desc": "Restauração contínua equilibrada."},
			{"id": HatsuData.AlcanceTipo.LONGO, "nome": "3. Pulso Expandido", "desc": "Cura potente de ampla área."}
		]
	else:
		alcances = [
			{"id": HatsuData.AlcanceTipo.CURTO, "nome": "1. Curto Alcance (Corpo a corpo, 45px)", "desc": "Máximo impacto físico no ponto de impacto."},
			{"id": HatsuData.AlcanceTipo.MEDIO, "nome": "2. Médio Alcance (Disparo Padrão, 130px)", "desc": "Projeção equilibrada de média distância."},
			{"id": HatsuData.AlcanceTipo.LONGO, "nome": "3. Longo Alcance (Sniper de Nen, 220px)", "desc": "Disparo veloz de longa distância."}
		]

	for alc in alcances:
		var btn = Button.new()
		btn.text = alc["nome"] + "\n  " + alc["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if alc["id"] == sel_alcance: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_alcance = alc["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


func _montar_etapa_consumo() -> void:
	var consumos = [
		{"id": HatsuData.ConsumoDesejado.BAIXO, "nome": "Baixo Consumo (~15 Aura, spammável)", "desc": "Rápida utilização e recarga veloz."},
		{"id": HatsuData.ConsumoDesejado.MEDIO, "nome": "Médio Consumo (~28 Aura, equilibrado)", "desc": "Excelente custo-benefício para batalhas normais."},
		{"id": HatsuData.ConsumoDesejado.ALTO, "nome": "Alto Consumo (~48 Aura, devastador/impenetrável)", "desc": "Densidade máxima de Nen para momentos decisivos."}
	]
	for cons in consumos:
		var btn = Button.new()
		btn.text = cons["nome"] + "\n  " + cons["desc"]
		btn.add_theme_font_size_override("font_size", 4)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if cons["id"] == sel_consumo: btn.modulate = Color(0.4, 0.9, 1.0, 1.0)
		btn.pressed.connect(func():
			sel_consumo = cons["id"]
			_atualizar_etapa()
		)
		container_opcoes.add_child(btn)


func _montar_etapa_condicoes() -> void:
	var condicoes_disponiveis = [
		{"id": HatsuData.Condicao.HP_ABAIXO_50, "nome": "🟢 Risco Moderado: HP < 50% (+30% poder)"},
		{"id": HatsuData.Condicao.HP_CHEIO, "nome": "🟢 Plenitude: HP Intacto 100% (+25% poder)"},
		{"id": HatsuData.Condicao.AURA_MINIMA_50, "nome": "🟢 Reserva Estável: Aura >= 50% (+20% poder)"},
		{"id": HatsuData.Condicao.PARADO_CANALIZACAO, "nome": "🟢 Foco Estático: Parado por 1.5s (+35% poder)"},
		{"id": HatsuData.Condicao.MOVIMENTO_CONTINUO, "nome": "🟢 Dança dos Passos: Correr por 2.5s (+30% poder)"},
		{"id": HatsuData.Condicao.CURTO_ALCANCE_EXTREMO, "nome": "🟢 Ponto Zero: Toque Físico < 40px (+35% poder)"},
		{"id": HatsuData.Condicao.LONGO_ALCANCE_SNIPER, "nome": "🟢 Sniper: Longa Distância > 220px (+25% poder)"},
		{"id": HatsuData.Condicao.APOS_ESQUIVA_PERFEITA, "nome": "🟢 Contra-Golpe: Pós-Esquiva Perfeita (+35% poder)"},
		{"id": HatsuData.Condicao.REQUER_TEN_ATIVO, "nome": "🟢 Manto de Ten: Requer Ten Ativo (+20% poder)"},
		{"id": HatsuData.Condicao.REQUER_REN_ATIVO, "nome": "🟢 Explosão de Ren: Requer Ren Ativo (+30% poder)"},
		{"id": HatsuData.Condicao.COOLDOWN_LONGO, "nome": "🟢 Tempo de Recarga Duplicado 2x (+35% poder)"},
		{"id": HatsuData.Condicao.REVELACAO_HABILIDADE, "nome": "🟢 Voto da Revelação: Explica a técnica (+30% poder)"}
	]
	for c in condicoes_disponiveis:
		var chk = CheckBox.new()
		chk.text = c["nome"]
		chk.add_theme_font_size_override("font_size", 4)
		chk.button_pressed = (c["id"] in sel_condicoes)
		chk.toggled.connect(func(toggled: bool):
			if toggled:
				if not (c["id"] in sel_condicoes): sel_condicoes.append(c["id"])
			else:
				sel_condicoes.erase(c["id"])
			_atualizar_gauge()
		)
		container_opcoes.add_child(chk)


func _montar_etapa_restricoes() -> void:
	# --- SEÇÃO: JURAMENTOS SÉRIOS ---
	var lbl_jur_hdr := Label.new()
	lbl_jur_hdr.text = "🟡 JURAMENTOS SÉRIOS (+40% a +90%):"
	lbl_jur_hdr.add_theme_font_size_override("font_size", 4)
	lbl_jur_hdr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	container_opcoes.add_child(lbl_jur_hdr)

	var juramentos = [
		{"id": HatsuData.Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO, "nome": "🟡 Voto do Retorno: Só contra quem me atacou primeiro (+75%)"},
		{"id": HatsuData.Condicao.HP_ABAIXO_30, "nome": "🟡 Juramento do Desespero: HP Crítico < 30% (+65%)"},
		{"id": HatsuData.Condicao.IMOVEL_DURANTE_USO, "nome": "🟡 Canhão Fixo: Totalmente imóvel durante o uso (+85%)"},
		{"id": HatsuData.Condicao.ZETSU_POS_USO_15S, "nome": "🟡 Exaustão: Entra em Zetsu por 15s pós-uso (+90%)"},
		{"id": HatsuData.Condicao.BLOQUEIO_NEN_10S, "nome": "🟡 Sobrecarga: Bloqueia Nen por 10s pós-uso (+70%)"},
		{"id": HatsuData.Condicao.DOR_ACUMULADA, "nome": "🟡 Pain Packer: Escala com o dano sofrido (+80% a +180%)"},
		{"id": HatsuData.Condicao.ALMAS_INIMIGOS, "nome": "🟡 Colheita de Almas: Abates acumulam cargas (+15%/alma)"},
		{"id": HatsuData.Condicao.ORACAO_GRATIDAO, "nome": "🟡 Oração de Netero: 0.7s de postura de oração (+60%)"},
		{"id": HatsuData.Condicao.ALVO_ELITE_BOSS, "nome": "🟡 Chain Jail: Apenas contra Chefes e Elites (+85% + Stun)"},
		{"id": HatsuData.Condicao.NAO_VIOLENCIA, "nome": "🟡 Defesa Pacífica: Não ataca durante o escudo (+80% e reflete)"},
		{"id": HatsuData.Condicao.NAO_ESQUIVAR_DURANTE_EFEITO, "nome": "🟡 Sem Esquiva: Bloqueia Dash durante o efeito (+55%)"},
		{"id": HatsuData.Condicao.AUTO_DANO, "nome": "🟡 Pacto de Sangue: Consome 10% do HP próprio (+55%)"},
		{"id": HatsuData.Condicao.CUSTO_DUPLO, "nome": "🟡 Sacrifício de Aura: Consome 2x Aura (+45%)"}
	]
	for j in juramentos:
		var chk = CheckBox.new()
		chk.text = j["nome"]
		chk.add_theme_font_size_override("font_size", 4)
		chk.button_pressed = (j["id"] in sel_condicoes)
		chk.toggled.connect(func(toggled: bool):
			if toggled:
				if not (j["id"] in sel_condicoes): sel_condicoes.append(j["id"])
			else:
				sel_condicoes.erase(j["id"])
			_atualizar_gauge()
		)
		container_opcoes.add_child(chk)

	# --- SEÇÃO: VOTOS EXTREMOS ---
	var sep1 := HSeparator.new()
	container_opcoes.add_child(sep1)

	var lbl_voto_hdr := Label.new()
	lbl_voto_hdr.text = "🔴 VOTOS EXTREMOS / RISCO CRÍTICO (+100% a +220%):"
	lbl_voto_hdr.add_theme_font_size_override("font_size", 4)
	lbl_voto_hdr.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))
	container_opcoes.add_child(lbl_voto_hdr)

	var votos_extremos = [
		{"id": HatsuData.Condicao.HP_ABAIXO_20, "nome": "🔴 À Beira da Morte: HP Crítico < 20% (+120%)"},
		{"id": HatsuData.Condicao.USO_UNICO_POR_COMBATE, "nome": "🔴 Decisão Única: 1x por combate inteiro (+140%)"},
		{"id": HatsuData.Condicao.DRENO_TOTAL_AURA, "nome": "🔴 Zero Ko: Consome 100% da Aura atual (+150%)"},
		{"id": HatsuData.Condicao.AUTO_DANO_30_SANGUE, "nome": "🔴 Sacrifício Vital Extremo: Consome 30% HP próprio (+160%)"},
		{"id": HatsuData.Condicao.PENALIDADE_MORTE_ERRO, "nome": "🔴 Voto do Cadafalso: Se falhar perde 50% HP e 30s Zetsu (+200%)"},
		{"id": HatsuData.Condicao.VOTO_ABSOLUTO_CHAIN, "nome": "🔴 Julgamento Absoluto: Exclusivo Boss + 1x Combate (+220%)"}
	]
	for v in votos_extremos:
		var chk = CheckBox.new()
		chk.text = v["nome"]
		chk.add_theme_font_size_override("font_size", 4)
		chk.button_pressed = (v["id"] in sel_condicoes)
		chk.toggled.connect(func(toggled: bool):
			if toggled:
				if not (v["id"] in sel_condicoes): sel_condicoes.append(v["id"])
			else:
				sel_condicoes.erase(v["id"])
			_atualizar_gauge()
		)
		container_opcoes.add_child(chk)

	# --- SEÇÃO: GRANDES ARQUÉTIPOS CANÔNICOS ---
	var sep0 := HSeparator.new()
	container_opcoes.add_child(sep0)

	var lbl_arq_hdr := Label.new()
	lbl_arq_hdr.text = "🏛️ ATALHOS DE ARQUÉTIPOS CANÔNICOS:"
	lbl_arq_hdr.add_theme_font_size_override("font_size", 4)
	lbl_arq_hdr.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
	container_opcoes.add_child(lbl_arq_hdr)

	var grid_arqs := GridContainer.new()
	grid_arqs.columns = 2
	container_opcoes.add_child(grid_arqs)

	var arquetipos_presets = [
		{"nome": "🎲 Roleta (Crazy Slots)", "vow": "roleta de armas aleatórias estilo crazy slots de kite", "arq": HatsuData.Arquetipo.ARSENAL_ROLETA},
		{"nome": "📖 Coleção (Skill Hunter)", "vow": "livro de hatsu para armazenar habilidades de hunters", "arq": HatsuData.Arquetipo.LIVRO_COLECAO},
		{"nome": "🌐 Território de En", "vow": "território com círculo no chão que desacelera inimigos", "arq": HatsuData.Arquetipo.TERRITORIO_EN},
		{"nome": "🎯 Marcação (Tag 3x)", "vow": "tocar 3 vezes no alvo para detonar explosão de nen", "arq": HatsuData.Arquetipo.MARCA_TAG},
		{"nome": "🪙 Moeda da Sorte", "vow": "jogar moeda de nen: cara velocidade, coroa escudo", "arq": HatsuData.Arquetipo.OBJETO_MOEDA},
		{"nome": "🃏 Cartas (5 Naipes)", "vow": "baralho de cartas com naipes de cura, dano e velocidade", "arq": HatsuData.Arquetipo.OBJETO_CARTAS},
		{"nome": "🎲 Dado Místico (1 a 6)", "vow": "dado de 6 faces: face 6 supernova, face 1 zetsu forçado", "arq": HatsuData.Arquetipo.OBJETO_DADO},
		{"nome": "🩸 Troca Vital (HP ↔ Dano)", "vow": "trocar 30% de hp por 100% de dano durante 5 segundos", "arq": HatsuData.Arquetipo.TROCA_SACRIFICIO},
		{"nome": "⚔️ Lâmina com Cargas", "vow": "espada que ganha cargas a cada inimigo derrotado", "arq": HatsuData.Arquetipo.CONJURACAO_ARMA}
	]

	for ap in arquetipos_presets:
		var btn_arq := Button.new()
		btn_arq.text = ap["nome"]
		btn_arq.add_theme_font_size_override("font_size", 4)
		btn_arq.pressed.connect(func():
			sel_arquetipo = ap["arq"]
			line_edit_custom_vow.text = ap["vow"]
			custom_vow_input = ap["vow"]
			var analise = HatsuManager.analisar_juramento_inteligente(custom_vow_input)
			if not (HatsuData.Condicao.CUSTOMIZADO in sel_condicoes):
				sel_condicoes.append(HatsuData.Condicao.CUSTOMIZADO)
			_atualizar_gauge()
		)
		grid_arqs.add_child(btn_arq)

	# --- SEÇÃO: JURAMENTO LIVRE / AVALIADOR DE NEN ---
	var sep2 := HSeparator.new()
	container_opcoes.add_child(sep2)

	var lbl_custom_title := Label.new()
	lbl_custom_title.text = "✍️ JURAMENTO PERSONALIZADO (MOTOR DE IA DE NEN):"
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
				var t_nome: String = "🟢 Condição"
				var t_cor: Color = Color(0.4, 1.0, 0.6, 1.0)
				if analise.get("tier") == HatsuData.Tier.VOTO_EXTREMO:
					t_nome = "🔴 Voto Extremo"
					t_cor = Color(1.0, 0.3, 0.3, 1.0)
				elif analise.get("tier") == HatsuData.Tier.JURAMENTO:
					t_nome = "🟡 Juramento Sério"
					t_cor = Color(1.0, 0.85, 0.2, 1.0)

				lbl_vow_analise.add_theme_color_override("font_color", t_cor)
				lbl_vow_analise.text = "[%s] %s (x%.2f)\n%s\nImpacto: %s" % [
					t_nome,
					analise.get("nome_reconhecido", ""),
					analise.get("multiplicador", 1.0),
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


func _montar_etapa_resumo() -> void:
	var h_temp := HatsuManager.criar_hatsu(
		sel_nome, sel_categoria, sel_forma, sel_condicoes,
		sel_objetivo, sel_elemento, sel_alvo, sel_alcance, sel_consumo, custom_vow_input, sel_arquetipo
	)
	var ef: float = NenAffinityData.calcular_eficiencia_categoria(PlayerData.afinidade_nen, sel_categoria)

	var lbl_res := Label.new()
	lbl_res.add_theme_font_size_override("font_size", 4)
	lbl_res.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var obj_nome: String = "Dano"
	match sel_objetivo:
		HatsuData.ObjetivoPrincipal.DEFESA: obj_nome = "Defesa / Blindagem"
		HatsuData.ObjetivoPrincipal.CURA: obj_nome = "Cura / Regeneração"
		HatsuData.ObjetivoPrincipal.MOBILIDADE: obj_nome = "Mobilidade Rápida"
		HatsuData.ObjetivoPrincipal.CONTROLE: obj_nome = "Controle / Imobilização"

	lbl_res.text = "Nome: %s\nObjetivo: %s\nCategoria: %s (%d%% Eficiência)\nForma: %s\nPotência Final: %d | Custo: %d Aura\nRecarga: %.1fs | Juramentos: %d" % [
		sel_nome,
		obj_nome,
		HatsuManager.obter_nome_categoria(sel_categoria),
		int(ef * 100),
		HatsuManager.obter_nome_forma_contextual(sel_forma, sel_objetivo),
		int(h_temp.obter_poder_final()),
		int(h_temp.obter_custo_final()),
		h_temp.obter_cooldown_final(),
		h_temp.condicoes.size()
	]
	container_opcoes.add_child(lbl_res)


func _atualizar_gauge() -> void:
	if not is_instance_valid(panel_gauge): return

	var ef: float = NenAffinityData.calcular_eficiencia_categoria(PlayerData.afinidade_nen, sel_categoria)
	var compat_pct: int = int(ef * 100)

	var h_temp := HatsuManager.criar_hatsu(
		sel_nome, sel_categoria, sel_forma, sel_condicoes,
		sel_objetivo, sel_elemento, sel_alvo, sel_alcance, sel_consumo, custom_vow_input, sel_arquetipo,
		sel_cor_primaria, sel_cor_secundaria, sel_estilo_visual
	)

	var base_aura: int = int(h_temp.obter_custo_final())
	var pot: int = int(h_temp.obter_poder_final())
	var mult: float = h_temp.obter_multiplicador_poder()
	var complex: String = "Baixa"
	var tier_label: String = "Padrão"
	var dica: String = "Habilidade equilibrada com a sua afinidade de Nen."

	var rests: int = h_temp.condicoes.size()
	if rests > 0 or not custom_vow_input.is_empty():
		var tem_extremo: bool = false
		var tem_juramento: bool = false
		for c in h_temp.condicoes:
			var inf = HatsuData.obter_info_condicao(c)
			if inf.get("tier") == HatsuData.Tier.VOTO_EXTREMO:
				tem_extremo = true
			elif inf.get("tier") == HatsuData.Tier.JURAMENTO:
				tem_juramento = true
		if h_temp.vow_custom_tier == HatsuData.Tier.VOTO_EXTREMO:
			tem_extremo = true
		elif h_temp.vow_custom_tier == HatsuData.Tier.JURAMENTO:
			tem_juramento = true

		if tem_extremo:
			tier_label = "🔴 Voto Extremo"
			complex = "Suprema (x%.2f)" % mult
			dica = "🔴 Risco Crítico: Multiplicador extremo em troca de sacrifício vital ou uso único!"
		elif tem_juramento:
			tier_label = "🟡 Juramento"
			complex = "Alta (x%.2f)" % mult
			dica = "🟡 Juramento Sério: Bônus massivo vinculado a restrições rígidas de combate."
		else:
			tier_label = "🟢 Condição"
			complex = "Média (x%.2f)" % mult
			dica = "🟢 Condição Tática: Limitação moderada que amplia o dano/cura."

	if sel_objetivo == HatsuData.ObjetivoPrincipal.DEFESA:
		dica = "🛡️ Modo Defensivo: Fornece escudo de absorção ativa com contra-ataques elementais."
	elif sel_objetivo == HatsuData.ObjetivoPrincipal.CURA:
		dica = "❤️ Modo Regenerativo: Recupera pontos de vida com base na afinidade celular."
	elif sel_objetivo == HatsuData.ObjetivoPrincipal.MOBILIDADE:
		dica = "⚡ Modo Velocidade: Dash rápido com I-frames para esquivas perfeitas."

	if HatsuData.Condicao.ALMAS_INIMIGOS in h_temp.condicoes:
		dica = "💀 Colheita de Almas: Derrotar monstros em combate aumentará o poder até +150%!"
	elif HatsuData.Condicao.DOR_ACUMULADA in h_temp.condicoes:
		dica = "🔥 Pain Packer: Quanto mais dano você sofrer em batalha, mais destruição causará!"
	elif HatsuData.Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO in h_temp.condicoes:
		dica = "⚔️ Voto do Retorno: Só dispara contra quem tiver iniciado o ataque contra você (+75%)!"

	lbl_compat.text = "Compatib.: %d%%" % compat_pct
	lbl_aura.text = "Custo Aura: %d" % base_aura
	lbl_potencial.text = "Potência: %d" % pot
	lbl_complexidade.text = "Tier: " + tier_label
	lbl_dica_dinamica.text = "[%s - %s]\n%s" % [HatsuData.obter_nome_arquetipo(h_temp.arquetipo), HatsuData.obter_nome_estilo_visual(h_temp.estilo_visual), dica]


func _on_voltar_pressed() -> void:
	if etapa_atual > Etapa.NOME:
		etapa_atual = (int(etapa_atual) - 1) as Etapa
		_atualizar_etapa()


func _on_avancar_pressed() -> void:
	if etapa_atual == Etapa.NOME:
		if not line_edit_nome.text.is_empty():
			sel_nome = line_edit_nome.text

	if etapa_atual < Etapa.RESUMO:
		etapa_atual = (int(etapa_atual) + 1) as Etapa
		_atualizar_etapa()
	else:
		_finalizar_criacao()


func _finalizar_criacao() -> void:
	var novo_hatsu := HatsuManager.criar_hatsu(
		sel_nome, sel_categoria, sel_forma, sel_condicoes,
		sel_objetivo, sel_elemento, sel_alvo, sel_alcance, sel_consumo, custom_vow_input, sel_arquetipo,
		sel_cor_primaria, sel_cor_secundaria, sel_estilo_visual
	)

	# Integrar componentes modulares
	novo_hatsu.is_custom_created = true
	novo_hatsu.hatsu_version = 2
	novo_hatsu.creator_id = str(PlayerData.nome_personagem)

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

	# Validar Power Budget
	var validacao = HatsuManager.validate_hatsu(novo_hatsu)
	HatsuManager.calculate_power_budget(novo_hatsu)

	if validacao.get("status") == "OVERPOWERED":
		print("[HatsuCreationUI] ⚠️ Atenção: Hatsu criado com aviso de Overpowered: ", validacao.get("reason"))

	var index: int = PlayerData.adicionar_hatsu(novo_hatsu)
	hatsu_criado.emit(novo_hatsu)
	print("[HatsuCreationUI] Novo Hatsu Definitivo forjado com sucesso! Slot index: ", index, " | Core: ", novo_hatsu.core_component, " | Visual: ", vp.primary_color)
	fechar()
