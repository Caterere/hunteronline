class_name NenSkillTreeUI
extends Control

# ============================================================
# HUNTER ONLINE - NEN SKILL TREE VISUAL (REDESIGN COMPLETO)
# ============================================================
#
# Interface de árvore de habilidades estilo RPG/MMORPG autêntico:
# - Grafo visual 2D com nós interativos e linhas conectoras dinâmicas (_draw).
# - 5 Pilares Temáticos:
#   1. DEFESA (Ten I-V, Ken Mastery, Bloodied)
#   2. OFENSA (Ren I-V, Ko I-V, First Strike, Isolated Target)
#   3. EQUILÍBRIO & SHU (Ryu Ofensivo/Defensivo/Equilibrado, Shu I)
#   4. CONTROLE & PERCEPÇÃO (Gyo I-V, En Expansion, Surrounded, Hunter's Mark)
#   5. FURTIVIDADE & REGEN (Zetsu I-III, In Mastery)
# - Estados visuais por nó: BLOQUEADO (🔒), DISPONÍVEL (⚡), DOMINADO (⭐).
# - Painel lateral de inspeção detalhado com custos, pré-requisitos, tags e botão de ação.
# - Filtros rápidos no topo por arquétipos táticos.
# - Resolução definitiva do bug de loading infinito: 0ms de espera.
#
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var skill_tree: NenSkillTree = null
var current_tab_filter: String = "todos" # "todos", "fundamentos", "defesa", "ofensa", "controle", "ryu", "comportamentais", "sinergias"
var selected_node_id: String = "ten_1"

# Coordenadas 2D de cada nó no Grafo da Árvore
const NODE_COORDINATES: Dictionary = {
	# Pilar 1: Defesa (TEN / KEN / BLOODIED)
	"ten_1": Vector2(35, 20),
	"ten_2": Vector2(35, 78),
	"bloodied": Vector2(100, 78),       # Prereq: ten_2
	"ten_3": Vector2(35, 136),
	"ten_4": Vector2(35, 194),
	"ten_5": Vector2(35, 252),

	# Pilar 2: Ofensa (REN / FIRST STRIKE)
	"ren_1": Vector2(165, 20),
	"first_strike": Vector2(100, 20),   # Prereq: ren_1
	"ren_2": Vector2(165, 78),
	"ren_3": Vector2(165, 136),
	"ren_4": Vector2(165, 194),
	"ren_5": Vector2(165, 252),

	# Pilar 2.5: Foco Ofensivo (KO / ISOLATED TARGET)
	"ko_1": Vector2(230, 20),
	"isolated_target": Vector2(295, 20), # Prereq: ko_1
	"ko_2": Vector2(230, 78),
	"ko_3": Vector2(230, 136),
	"ko_4": Vector2(230, 194),
	"ko_5": Vector2(230, 252),

	# Pilar 3: Sinergias Centrais & Modos Ryu
	"shu_1": Vector2(295, 78),
	"ken_mastery": Vector2(100, 136),   # Prereq: ten_3 + ren_3
	"ryu_equilibrado": Vector2(295, 136),
	"ryu_ofensivo": Vector2(245, 194),
	"ryu_defensivo": Vector2(345, 194),

	# Pilar 4: Percepção (GYO / EN / SURROUNDED / HUNTER'S MARK)
	"gyo_1": Vector2(415, 20),
	"gyo_2": Vector2(415, 78),
	"surrounded": Vector2(360, 78),     # Prereq: gyo_2
	"hunters_mark": Vector2(475, 78),   # Prereq: gyo_2
	"gyo_3": Vector2(415, 136),
	"en_expansion": Vector2(295, 252),  # Prereq: gyo_3 + ren_3
	"gyo_4": Vector2(415, 194),
	"gyo_5": Vector2(415, 252),

	# Pilar 5: Furtividade & Regeneração (ZETSU / IN)
	"zetsu_1": Vector2(540, 20),
	"zetsu_2": Vector2(540, 78),
	"in_mastery": Vector2(475, 136),    # Prereq: zetsu_2 + gyo_2
	"zetsu_3": Vector2(540, 136),
}

# Cores Temáticas de Categorias
const COR_TEN := Color(0.3, 0.75, 1.0)
const COR_REN := Color(1.0, 0.45, 0.2)
const COR_KO := Color(1.0, 0.25, 0.25)
const COR_ZETSU := Color(0.35, 1.0, 0.5)
const COR_GYO := Color(0.95, 0.85, 0.2)
const COR_RYU := Color(1.0, 0.65, 0.1)
const COR_SINERGIA := Color(0.85, 0.4, 1.0)
const COR_TATICO := Color(0.95, 0.3, 0.4)

# Componentes de UI
var lbl_pontos: Label
var lbl_maestria: Label
var tabs_container: HBoxContainer
var tree_canvas: Control
var node_buttons: Dictionary = {}

# Inspetor Lateral
var inspector_panel: PanelContainer
var lbl_insp_nome: Label
var lbl_insp_categoria: Label
var lbl_insp_nivel: Label
var lbl_insp_desc: Label
var lbl_insp_tags: Label
var lbl_insp_prereqs: Label
var lbl_insp_condicao: Label
var btn_insp_acao: Button


# Canvas Customizado para Renderizar Linhas Conectoras da Árvore
class TreeGraphCanvas extends Control:
	var ui_parent: NenSkillTreeUI = null

	func _draw() -> void:
		if ui_parent == null or ui_parent.skill_tree == null:
			return

		var tree_ref = ui_parent.skill_tree
		var definitions = tree_ref.node_definitions

		# Desenhar todas as linhas de pré-requisitos entre nós
		for node_id in definitions.keys():
			if not NenSkillTreeUI.NODE_COORDINATES.has(node_id):
				continue

			var def = definitions[node_id]
			var to_btn = ui_parent.node_buttons.get(node_id)
			if to_btn == null:
				continue

			var to_center = to_btn.position + to_btn.size * 0.5
			var child_level: int = tree_ref.obter_progresso_no(node_id)
			var child_can_buy: bool = tree_ref.pode_investir(node_id)

			for prereq_id in def.pre_requisitos:
				var from_btn = ui_parent.node_buttons.get(prereq_id)
				if from_btn == null:
					continue

				var from_center = from_btn.position + from_btn.size * 0.5
				var parent_level: int = tree_ref.obter_progresso_no(prereq_id)

				# Determinar estilo e cor da linha
				var line_color: Color
				var line_width: float = 1.5

				if child_level > 0:
					# Ambos conectados e desbloqueados: Dourado / Ciano vibrante
					line_color = Color(1.0, 0.85, 0.3, 0.9)
					line_width = 2.4
				elif parent_level > 0 and child_can_buy:
					# Pai dominado, filho pronto para comprar: Verde pulsante
					line_color = Color(0.3, 0.95, 0.5, 0.8)
					line_width = 2.0
				else:
					# Bloqueado: Linha escura sutil
					line_color = Color(0.25, 0.3, 0.38, 0.45)
					line_width = 1.2

				# Se houver filtro ativo e o nó não pertencer ao filtro, atenua a linha
				if ui_parent.current_tab_filter != "todos" and not ui_parent._corresponde_ao_filtro(def.categoria, ui_parent.current_tab_filter):
					line_color.a *= 0.2

				draw_line(from_center, to_center, line_color, line_width, true)


func _ready() -> void:
	custom_minimum_size = Vector2(440, 230)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_localizar_skill_tree()
	_construir_interface()
	_atualizar_exibicao()


func _localizar_skill_tree() -> void:
	if skill_tree != null and is_instance_valid(skill_tree):
		return

	# 1º: PlayerData canônico permanente
	if PlayerData != null and "skill_tree" in PlayerData and PlayerData.skill_tree != null:
		skill_tree = PlayerData.skill_tree as NenSkillTree

	# 2º: Busca em grupo da árvore de cena
	if skill_tree == null:
		var trees = get_tree().get_nodes_in_group("nen_skill_tree")
		if not trees.is_empty():
			skill_tree = trees[0] as NenSkillTree

	# 3º: Fallback de instanciação direta vinculada ao PlayerData
	if skill_tree == null and PlayerData != null and PlayerData.has_method("obter_skill_tree"):
		skill_tree = PlayerData.obter_skill_tree() as NenSkillTree

	if skill_tree == null:
		var st_script = load("res://scripts/systems/NenSkillTree.gd")
		if st_script != null:
			skill_tree = st_script.new()
			skill_tree.name = "NenSkillTree"
			add_child(skill_tree)

	if skill_tree != null:
		if not skill_tree.skill_investida.is_connected(_on_skill_investida):
			skill_tree.skill_investida.connect(_on_skill_investida)
		if not skill_tree.pontos_alterados.is_connected(_on_pontos_alterados):
			skill_tree.pontos_alterados.connect(_on_pontos_alterados)


func _construir_interface() -> void:
	for child in get_children():
		child.queue_free()

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 3)
	add_child(main_vbox)

	# ------------------------------------------------------------
	# 1. HEADER BAR: PONTOS DE NEN, MAESTRIA E STATUS
	# ------------------------------------------------------------
	var top_panel := PanelContainer.new()
	top_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_GOLD, 2))
	main_vbox.add_child(top_panel)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 6)
	top_margin.add_theme_constant_override("margin_right", 6)
	top_margin.add_theme_constant_override("margin_top", 3)
	top_margin.add_theme_constant_override("margin_bottom", 3)
	top_panel.add_child(top_margin)

	var top_hbox := HBoxContainer.new()
	top_margin.add_child(top_hbox)

	lbl_pontos = Label.new()
	lbl_pontos.text = "⚡ Pontos de Habilidade: 0 SP"
	lbl_pontos.add_theme_font_size_override("font_size", 6)
	lbl_pontos.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	top_hbox.add_child(lbl_pontos)

	var spacer_top := Control.new()
	spacer_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer_top)

	lbl_maestria = Label.new()
	lbl_maestria.text = "⭐ Técnicas: 0 Dominadas"
	lbl_maestria.add_theme_font_size_override("font_size", 5)
	lbl_maestria.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	top_hbox.add_child(lbl_maestria)

	# ------------------------------------------------------------
	# 2. FILTROS RÁPIDOS (CATEGORIAS)
	# ------------------------------------------------------------
	tabs_container = HBoxContainer.new()
	tabs_container.add_theme_constant_override("separation", 2)
	main_vbox.add_child(tabs_container)

	_adicionar_botao_filtro("🌐 Toda a Árvore", "todos")
	_adicionar_botao_filtro("🛡️ Defesa", "defesa")
	_adicionar_botao_filtro("⚔️ Ofensa", "ofensa")
	_adicionar_botao_filtro("⚖️ Modos Ryu", "ryu")
	_adicionar_botao_filtro("👁️ Controle", "controle")
	_adicionar_botao_filtro("🌀 Sinergias", "sinergias")
	_adicionar_botao_filtro("🎯 Táticos", "comportamentais")

	# ------------------------------------------------------------
	# 3. CORPO CENTRAL: MAPA GRÁFICO (ESQ) + INSPETOR (DIR)
	# ------------------------------------------------------------
	var body_hbox := HBoxContainer.new()
	body_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_hbox.add_theme_constant_override("separation", 4)
	main_vbox.add_child(body_hbox)

	# Scroll Container para o Grafo da Árvore
	var scroll_tree := ScrollContainer.new()
	scroll_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_tree.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_tree.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	body_hbox.add_child(scroll_tree)

	# Canvas da Árvore com nós 2D
	tree_canvas = TreeGraphCanvas.new()
	tree_canvas.name = "TreeGraphCanvas"
	tree_canvas.ui_parent = self
	tree_canvas.custom_minimum_size = Vector2(620, 310)
	scroll_tree.add_child(tree_canvas)

	_instanciar_nos_no_canvas()

	# Painel Inspetor Lateral de Técnica Selecionada
	_construir_painel_inspetor(body_hbox)


func _adicionar_botao_filtro(titulo: String, filtro: String) -> void:
	var btn := Button.new()
	btn.text = titulo
	btn.add_theme_font_size_override("font_size", 4)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_GOLD if current_tab_filter == filtro else HunterUIStyle.COLOR_BORDER_SUBTLE)
	btn.pressed.connect(func():
		current_tab_filter = filtro
		for child in tabs_container.get_children():
			if child is Button:
				var is_sel = (child.text == titulo)
				HunterUIStyle.aplicar_estilo_botao(child, HunterUIStyle.COLOR_BORDER_GOLD if is_sel else HunterUIStyle.COLOR_BORDER_SUBTLE)
		_atualizar_exibicao()
	)
	tabs_container.add_child(btn)


func _instanciar_nos_no_canvas() -> void:
	node_buttons.clear()
	for child in tree_canvas.get_children():
		child.queue_free()

	if skill_tree == null:
		return

	for node_id in NODE_COORDINATES.keys():
		if not skill_tree.node_definitions.has(node_id):
			continue

		var def = skill_tree.node_definitions[node_id]
		var pos: Vector2 = NODE_COORDINATES[node_id]

		var btn := Button.new()
		btn.name = "NodeBtn_" + node_id
		btn.position = pos
		btn.custom_minimum_size = Vector2(54, 30)
		btn.size = Vector2(54, 30)
		btn.add_theme_font_size_override("font_size", 4)

		# Ícone temático reduzido
		var icone_prefix = _obter_icone_no(node_id)
		btn.text = "%s\n%s" % [icone_prefix, def.nome.replace("TEN ", "T-").replace("REN ", "R-").replace("KO ", "K-").replace("GYO ", "G-").replace("ZETSU ", "Z-")]

		btn.pressed.connect(func():
			selected_node_id = node_id
			_atualizar_painel_inspetor()
			_atualizar_estilos_nos()
			tree_canvas.queue_redraw()
		)

		tree_canvas.add_child(btn)
		node_buttons[node_id] = btn


func _construir_painel_inspetor(parent_container: Control) -> void:
	inspector_panel = PanelContainer.new()
	inspector_panel.custom_minimum_size = Vector2(150, 0)
	inspector_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector_panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 2))
	parent_container.add_child(inspector_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	inspector_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# Título e Categoria
	lbl_insp_nome = Label.new()
	lbl_insp_nome.text = "Técnica"
	lbl_insp_nome.add_theme_font_size_override("font_size", 5)
	lbl_insp_nome.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_insp_nome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_insp_nome)

	lbl_insp_categoria = Label.new()
	lbl_insp_categoria.text = "Categoria"
	lbl_insp_categoria.add_theme_font_size_override("font_size", 4)
	lbl_insp_categoria.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_insp_categoria)

	lbl_insp_nivel = Label.new()
	lbl_insp_nivel.text = "Nível: 0/1"
	lbl_insp_nivel.add_theme_font_size_override("font_size", 4)
	lbl_insp_nivel.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	vbox.add_child(lbl_insp_nivel)

	var sep1 := HSeparator.new()
	vbox.add_child(sep1)

	# Efeito / Descrição
	lbl_insp_desc = Label.new()
	lbl_insp_desc.text = "Selecione um nó para visualizar os efeitos."
	lbl_insp_desc.add_theme_font_size_override("font_size", 4)
	lbl_insp_desc.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_insp_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_insp_desc)

	# Tags e Condições
	lbl_insp_tags = Label.new()
	lbl_insp_tags.text = ""
	lbl_insp_tags.add_theme_font_size_override("font_size", 3)
	lbl_insp_tags.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_PURPLE)
	vbox.add_child(lbl_insp_tags)

	lbl_insp_condicao = Label.new()
	lbl_insp_condicao.text = ""
	lbl_insp_condicao.add_theme_font_size_override("font_size", 3)
	lbl_insp_condicao.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD)
	lbl_insp_condicao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_insp_condicao)

	lbl_insp_prereqs = Label.new()
	lbl_insp_prereqs.text = ""
	lbl_insp_prereqs.add_theme_font_size_override("font_size", 3)
	lbl_insp_prereqs.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	lbl_insp_prereqs.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_insp_prereqs)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# Botão de Ação / Investimento
	btn_insp_acao = Button.new()
	btn_insp_acao.text = "Desbloquear"
	btn_insp_acao.custom_minimum_size = Vector2(0, 22)
	btn_insp_acao.add_theme_font_size_override("font_size", 5)
	btn_insp_acao.pressed.connect(_on_botao_investir_pressionado)
	vbox.add_child(btn_insp_acao)


func _atualizar_exibicao() -> void:
	if skill_tree == null:
		_localizar_skill_tree()

	var pts: int = skill_tree.obter_pontos_disponiveis() if skill_tree != null else PlayerData.nen_skill_points
	if lbl_pontos != null:
		lbl_pontos.text = "⚡ Pontos de Habilidade: %d SP" % pts

	var total_desbloqueados: int = 0
	if skill_tree != null:
		for nid in skill_tree.node_definitions.keys():
			if skill_tree.obter_progresso_no(nid) > 0:
				total_desbloqueados += 1

	if lbl_maestria != null:
		var total_defs = skill_tree.node_definitions.size() if skill_tree != null else 35
		lbl_maestria.text = "⭐ Técnicas: %d / %d Dominadas" % [total_desbloqueados, total_defs]

	_atualizar_estilos_nos()
	_atualizar_painel_inspetor()

	if tree_canvas != null:
		tree_canvas.queue_redraw()


func _atualizar_estilos_nos() -> void:
	if skill_tree == null:
		return

	for node_id in node_buttons.keys():
		var btn: Button = node_buttons[node_id]
		var def = skill_tree.node_definitions.get(node_id)
		if def == null:
			continue

		var lvl: int = skill_tree.obter_progresso_no(node_id)
		var pode: bool = skill_tree.pode_investir(node_id)
		var maximo: bool = (lvl >= def.nivel_max)
		var is_selected: bool = (node_id == selected_node_id)

		# Aplicação de Filtros Visuais de Abas
		var visivel_pelo_filtro: bool = _corresponde_ao_filtro(def.categoria, current_tab_filter)
		btn.modulate.a = 1.0 if visivel_pelo_filtro else 0.25

		# Seleção de Borda e Cores de Fundo
		var border_color: Color = HunterUIStyle.COLOR_BORDER_SUBTLE
		if is_selected:
			border_color = Color(1.0, 1.0, 1.0, 1.0) # Branco realçado para o selecionado
		elif maximo:
			border_color = HunterUIStyle.COLOR_BORDER_GOLD
		elif pode:
			border_color = HunterUIStyle.COLOR_BORDER_GREEN

		var bg_color := Color(0.06, 0.08, 0.12, 0.95)
		if maximo:
			bg_color = Color(0.12, 0.15, 0.2, 0.98)

		var st := StyleBoxFlat.new()
		st.bg_color = bg_color
		st.border_color = border_color
		st.border_width_left = 2 if is_selected else 1
		st.border_width_top = 2 if is_selected else 1
		st.border_width_right = 2 if is_selected else 1
		st.border_width_bottom = 2 if is_selected else 1
		st.corner_radius_top_left = 3
		st.corner_radius_top_right = 3
		st.corner_radius_bottom_right = 3
		st.corner_radius_bottom_left = 3
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st)
		btn.add_theme_stylebox_override("pressed", st)

		# Badge de texto no botão
		var status_txt = "⭐" if maximo else ("⚡" if pode else "🔒")
		var cor_cat = _obter_cor_categoria(def.categoria)
		btn.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT if maximo else (cor_cat if pode else Color(0.5, 0.55, 0.6)))
		btn.text = "%s %s\n[%d/%d]" % [status_txt, def.nome.left(8), lvl, def.nivel_max]


func _atualizar_painel_inspetor() -> void:
	if skill_tree == null or not skill_tree.node_definitions.has(selected_node_id):
		return

	var def = skill_tree.node_definitions[selected_node_id]
	var lvl: int = skill_tree.obter_progresso_no(selected_node_id)
	var pode: bool = skill_tree.pode_investir(selected_node_id)
	var maximo: bool = (lvl >= def.nivel_max)

	lbl_insp_nome.text = def.nome
	lbl_insp_categoria.text = "Categoria: %s" % _obter_nome_categoria(def.categoria)
	lbl_insp_categoria.add_theme_color_override("font_color", _obter_cor_categoria(def.categoria))
	lbl_insp_nivel.text = "Progresso: Nível %d / %d" % [lvl, def.nivel_max]
	lbl_insp_desc.text = def.descricao

	if not def.tags.is_empty():
		lbl_insp_tags.text = "Tags: #" + " #".join(def.tags)
	else:
		lbl_insp_tags.text = ""

	# Condições em combate
	if not def.conditions.is_empty():
		var cond = def.conditions[0]
		lbl_insp_condicao.text = "⚡ Condição de Ativação:\n%s" % _descrever_condicao(cond)
	else:
		lbl_insp_condicao.text = "✨ Efeito Passivo Permanente"

	# Pré-requisitos
	if def.pre_requisitos.is_empty():
		lbl_insp_prereqs.text = "Pré-requisitos: Nenhum"
	else:
		var req_strs: Array[String] = []
		for p in def.pre_requisitos:
			var p_lvl = skill_tree.obter_progresso_no(p)
			var p_def = skill_tree.node_definitions.get(p)
			var p_nome = p_def.nome if p_def else p
			req_strs.append("%s %s" % ["✅" if p_lvl > 0 else "❌", p_nome])
		lbl_insp_prereqs.text = "Requisitos:\n" + "\n".join(req_strs)

	# Configuração do Botão de Ação
	if maximo:
		btn_insp_acao.text = "⭐ TÉCNICA DOMINADA"
		btn_insp_acao.disabled = true
		HunterUIStyle.aplicar_estilo_botao(btn_insp_acao, HunterUIStyle.COLOR_BORDER_SUBTLE)
	elif pode:
		btn_insp_acao.text = "⚡ DESBLOQUEAR (-1 SP)"
		btn_insp_acao.disabled = false
		HunterUIStyle.aplicar_estilo_botao(btn_insp_acao, HunterUIStyle.COLOR_BORDER_GREEN)
	elif def.id.begins_with("ryu_") and not skill_tree.ryu_caminho.is_empty() and skill_tree.ryu_caminho != skill_tree._extrair_caminho_ryu(def.id):
		btn_insp_acao.text = "❌ OUTRO RYU ATIVO"
		btn_insp_acao.disabled = true
		HunterUIStyle.aplicar_estilo_botao(btn_insp_acao, HunterUIStyle.COLOR_BORDER_SUBTLE)
	elif PlayerData.nen_skill_points <= 0:
		btn_insp_acao.text = "⚠️ REQUER PONTOS (0 SP)"
		btn_insp_acao.disabled = true
		HunterUIStyle.aplicar_estilo_botao(btn_insp_acao, HunterUIStyle.COLOR_BORDER_SUBTLE)
	else:
		btn_insp_acao.text = "🔒 PRÉ-REQUISITO BLOQUEADO"
		btn_insp_acao.disabled = true
		HunterUIStyle.aplicar_estilo_botao(btn_insp_acao, HunterUIStyle.COLOR_BORDER_SUBTLE)


func _on_botao_investir_pressionado() -> void:
	if skill_tree == null:
		return

	var sucesso = skill_tree.investir_ponto(selected_node_id)
	if sucesso:
		var def = skill_tree.node_definitions.get(selected_node_id)
		var nome_tec = def.nome if def else selected_node_id
		if EventBus != null:
			EventBus.emit_toast("⚡ %s desbloqueado com sucesso!" % nome_tec, HunterUIStyle.COLOR_GOLD_LIGHT)
		if AudioManager != null and AudioManager.has_method("tocar_ui_click"):
			AudioManager.tocar_ui_click(true)
		_atualizar_exibicao()


func _corresponde_ao_filtro(cat: int, filtro: String) -> bool:
	match filtro:
		"todos":
			return true
		"fundamentos":
			return cat in [NenSkillTree.Categoria.TEN, NenSkillTree.Categoria.ZETSU, NenSkillTree.Categoria.REN, NenSkillTree.Categoria.GYO, NenSkillTree.Categoria.KO, NenSkillTree.Categoria.SHU]
		"defesa":
			return cat in [NenSkillTree.Categoria.TEN, NenSkillTree.Categoria.RYU_DEFENSIVO, NenSkillTree.Categoria.COMPORTAMENTAL, NenSkillTree.Categoria.SINERGIA]
		"ofensa":
			return cat in [NenSkillTree.Categoria.REN, NenSkillTree.Categoria.KO, NenSkillTree.Categoria.RYU_OFENSIVO, NenSkillTree.Categoria.COMPORTAMENTAL]
		"controle":
			return cat in [NenSkillTree.Categoria.GYO, NenSkillTree.Categoria.ZETSU, NenSkillTree.Categoria.SHU, NenSkillTree.Categoria.SINERGIA, NenSkillTree.Categoria.COMPORTAMENTAL]
		"ryu":
			return cat in [NenSkillTree.Categoria.RYU_OFENSIVO, NenSkillTree.Categoria.RYU_DEFENSIVO, NenSkillTree.Categoria.RYU_EQUILIBRADO]
		"comportamentais":
			return cat == NenSkillTree.Categoria.COMPORTAMENTAL
		"sinergias":
			return cat == NenSkillTree.Categoria.SINERGIA
	return true


func _obter_icone_no(node_id: String) -> String:
	if node_id.begins_with("ten"): return "🛡️"
	if node_id.begins_with("ren"): return "🔥"
	if node_id.begins_with("ko"): return "💥"
	if node_id.begins_with("gyo"): return "👁️"
	if node_id.begins_with("zetsu"): return "🍃"
	if node_id.begins_with("shu"): return "⚔️"
	if node_id.begins_with("ryu"): return "⚖️"
	if node_id == "ken_mastery": return "🛡️"
	if node_id == "in_mastery": return "👻"
	if node_id == "en_expansion": return "🌐"
	if node_id == "first_strike": return "⚡"
	if node_id == "bloodied": return "🩸"
	if node_id == "surrounded": return "⚠️"
	if node_id == "isolated_target": return "🎯"
	if node_id == "hunters_mark": return "🏹"
	return "🔹"


func _obter_cor_categoria(cat: int) -> Color:
	match cat:
		NenSkillTree.Categoria.TEN: return COR_TEN
		NenSkillTree.Categoria.REN: return COR_REN
		NenSkillTree.Categoria.KO: return COR_KO
		NenSkillTree.Categoria.ZETSU: return COR_ZETSU
		NenSkillTree.Categoria.GYO: return COR_GYO
		NenSkillTree.Categoria.SHU: return COR_TEN
		NenSkillTree.Categoria.RYU_OFENSIVO, NenSkillTree.Categoria.RYU_DEFENSIVO, NenSkillTree.Categoria.RYU_EQUILIBRADO: return COR_RYU
		NenSkillTree.Categoria.SINERGIA: return COR_SINERGIA
		NenSkillTree.Categoria.COMPORTAMENTAL: return COR_TATICO
	return HunterUIStyle.COLOR_TEXT_PRIMARY


func _obter_nome_categoria(cat: int) -> String:
	match cat:
		NenSkillTree.Categoria.TEN: return "Fundamento: Ten"
		NenSkillTree.Categoria.REN: return "Fundamento: Ren"
		NenSkillTree.Categoria.KO: return "Técnica Avançada: Ko"
		NenSkillTree.Categoria.ZETSU: return "Fundamento: Zetsu"
		NenSkillTree.Categoria.GYO: return "Aplicação: Gyo"
		NenSkillTree.Categoria.SHU: return "Aplicação: Shu"
		NenSkillTree.Categoria.RYU_OFENSIVO: return "Modo Ryu: Ofensivo"
		NenSkillTree.Categoria.RYU_DEFENSIVO: return "Modo Ryu: Defensivo"
		NenSkillTree.Categoria.RYU_EQUILIBRADO: return "Modo Ryu: Equilibrado"
		NenSkillTree.Categoria.SINERGIA: return "Sinergia entre Técnicas"
		NenSkillTree.Categoria.COMPORTAMENTAL: return "Tática Comportamental"
	return "Técnica de Nen"


func _descrever_condicao(cond: GameplayCondition) -> String:
	match cond.condition_type:
		GameplayCondition.Type.PLAYER_HP_BELOW:
			return "Vida do jogador abaixo de %d%%" % int(cond.threshold * 100.0)
		GameplayCondition.Type.NO_DAMAGE_FOR_SECONDS:
			return "Sem sofrer dano nos últimos %.1fs" % cond.threshold
		GameplayCondition.Type.ENEMIES_NEARBY_AT_LEAST:
			return "%d ou mais inimigos ao redor" % cond.required_count
		GameplayCondition.Type.SINGLE_TARGET:
			return "Combate individual contra alvo isolado"
		GameplayCondition.Type.TARGET_MARKED:
			return "Alvo atual sob efeito de Marcação"
		GameplayCondition.Type.PLAYER_IN_EN:
			return "Enquanto a técnica En estiver ativada"
	return "Condição tática especial"


func _on_skill_investida(_node_id: String, _novo_nivel: int) -> void:
	_atualizar_exibicao()


func _on_pontos_alterados(_pontos: int) -> void:
	_atualizar_exibicao()
