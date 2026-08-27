class_name JournalUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - JORNAL DE MISSÕES, LORE & CONQUISTAS
# ============================================================
#
# Consolida o conhecimento de Nen, progresso de treino, Bestas e Conquistas:
# - [J]: Abrir / Alternar
# - [Q] / [E]: Navegação rápida entre abas
# - Abas: Enciclopédia | Treino de Wing | Lore & Bestas | Conquistas
# ============================================================

var tab_container: TabContainer
var panel_main: PanelContainer

# Abas
var tab_encyclopedia: ScrollContainer
var tab_wing: ScrollContainer
var tab_lore: ScrollContainer
var tab_achievements: ScrollContainer

# Sub-containers
var enc_list_container: VBoxContainer
var wing_list_container: VBoxContainer
var lore_list_container: VBoxContainer
var ach_list_container: VBoxContainer


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir_ui()


func _construir_ui() -> void:
	var root_control := Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.04, 0.07, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(bg)

	var center_container := CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(center_container)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(300, 175)
	panel_main.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GREEN, 4))
	center_container.add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# Header
	var hbox_header := HBoxContainer.new()
	vbox.add_child(hbox_header)

	var lbl_title := Label.new()
	lbl_title.text = "📖 DIÁRIO & ENCICLOPÉDIA DE NEN"
	lbl_title.add_theme_font_size_override("font_size", 6)
	lbl_title.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	hbox_header.add_child(lbl_title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(spacer)

	var lbl_hints := Label.new()
	lbl_hints.text = "[Q/E] Abas  |  [ESC/J] Fechar"
	lbl_hints.add_theme_font_size_override("font_size", 4)
	lbl_hints.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_header.add_child(lbl_hints)

	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_tab_container(tab_container)
	tab_container.tab_changed.connect(func(_idx): _atualizar_aba_atual())
	vbox.add_child(tab_container)

	_criar_aba_enciclopedia()
	_criar_aba_wing()
	_criar_aba_lore()
	_criar_aba_conquistas()


func _criar_aba_enciclopedia() -> void:
	tab_encyclopedia = ScrollContainer.new()
	tab_encyclopedia.name = "Enciclopédia"
	tab_container.add_child(tab_encyclopedia)

	enc_list_container = VBoxContainer.new()
	enc_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enc_list_container.add_theme_constant_override("separation", 3)
	tab_encyclopedia.add_child(enc_list_container)


func _criar_aba_wing() -> void:
	tab_wing = ScrollContainer.new()
	tab_wing.name = "Treino de Wing"
	tab_container.add_child(tab_wing)

	wing_list_container = VBoxContainer.new()
	wing_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wing_list_container.add_theme_constant_override("separation", 2)
	tab_wing.add_child(wing_list_container)


func _criar_aba_lore() -> void:
	tab_lore = ScrollContainer.new()
	tab_lore.name = "Lore & Bestas"
	tab_container.add_child(tab_lore)

	lore_list_container = VBoxContainer.new()
	lore_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lore_list_container.add_theme_constant_override("separation", 2)
	tab_lore.add_child(lore_list_container)


func _criar_aba_conquistas() -> void:
	tab_achievements = ScrollContainer.new()
	tab_achievements.name = "Conquistas"
	tab_container.add_child(tab_achievements)

	ach_list_container = VBoxContainer.new()
	ach_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ach_list_container.add_theme_constant_override("separation", 2)
	tab_achievements.add_child(ach_list_container)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null and input_ctx.is_text_input_focused():
		return

	if event.keycode == KEY_E or event.is_action_pressed("menu_next_tab"):
		if tab_container != null and tab_container.get_tab_count() > 0:
			var next = (tab_container.current_tab + 1) % tab_container.get_tab_count()
			definir_aba_ativa(next)
			get_viewport().set_input_as_handled()
	elif event.keycode == KEY_Q or event.is_action_pressed("menu_prev_tab"):
		if tab_container != null and tab_container.get_tab_count() > 0:
			var prev = (tab_container.current_tab - 1 + tab_container.get_tab_count()) % tab_container.get_tab_count()
			definir_aba_ativa(prev)
			get_viewport().set_input_as_handled()


func definir_aba_ativa(aba_index: int) -> void:
	if tab_container != null and aba_index >= 0 and aba_index < tab_container.get_tab_count():
		tab_container.current_tab = aba_index
		_atualizar_aba_atual()


func _atualizar_aba_atual() -> void:
	if not visible:
		return

	var cur = tab_container.get_current_tab_control()
	if cur == null:
		return

	match cur.name:
		"Enciclopédia":
			_atualizar_conteudo_enciclopedia()
		"Treino de Wing":
			_atualizar_conteudo_wing()
		"Lore & Bestas":
			_atualizar_conteudo_lore()
		"Conquistas":
			_atualizar_conteudo_conquistas()


func _atualizar_conteudo_enciclopedia() -> void:
	if enc_list_container == null:
		return
	for c in enc_list_container.get_children():
		c.queue_free()

	var entradas = [
		{"id": "aura", "nome": "1. FUNDAMENTOS DE AURA", "desc": "Energia vital presente em todos os seres vivos. Sem Ten, ela esvai-se continuamente."},
		{"id": "ten", "nome": "2. TEN (O Manto Protetor)", "desc": "Retém a aura ao redor do corpo. Reduz o dano de ataques físicos e Nen em combate."},
		{"id": "ren", "nome": "3. REN (A Emissão de Potência)", "desc": "Amplifica drasticamente o volume de aura emitido. Aumenta o alcance e intimida inimigos fracos."},
		{"id": "zetsu", "nome": "4. ZETSU (O Silêncio Absoluto)", "desc": "Fecha totalmente os nós de Nen. Concede furtividade contra sensores e acelera a regeneração de vida."},
		{"id": "gyo", "nome": "5. GYO (A Visão Concentrada)", "desc": "Foca aura nos olhos. Revela glifos invisíveis, armadilhas ocultas e aumenta a chance de acertos críticos."},
		{"id": "ko", "nome": "6. KO (A Concentração Máxima)", "desc": "Reúne 100% da aura em um ponto. Destrói barreiras maciças e causa dano massivo em combate."},
		{"id": "en", "nome": "7. EN (O Raio de Percepção)", "desc": "Expande o manto de aura esfericamente para sentir tudo o que se move em seu perímetro."},
		{"id": "hatsu", "nome": "8. HATSU (A Liberação Pessoal)", "desc": "A expressão máxima da individualidade de Nen, baseada na afinidade natal e juramentos."}
	]

	for ent in entradas:
		var p_enc := PanelContainer.new()
		p_enc.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 2))
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		p_enc.add_child(m)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 1)
		m.add_child(vb)

		var lbl_t := Label.new()
		lbl_t.text = ent["nome"]
		lbl_t.add_theme_font_size_override("font_size", 4)
		lbl_t.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
		vb.add_child(lbl_t)

		var lbl_d := Label.new()
		lbl_d.text = ent["desc"]
		lbl_d.add_theme_font_size_override("font_size", 3)
		lbl_d.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		lbl_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(lbl_d)

		enc_list_container.add_child(p_enc)


func _atualizar_conteudo_wing() -> void:
	if wing_list_container == null:
		return
	for c in wing_list_container.get_children():
		c.queue_free()

	var step = PlayerData.quest_states.get("wing_tutorial_progresso", 1)
	var licoes = [
		{"texto": "✅ Lição 1: Despertar dos Nós de Nen e Percepção de Aura", "concluida": true},
		{"texto": "Lição 2: O Manto Protetor de TEN" if step >= 2 else "Lição 2: O Manto Protetor de TEN (Fale com Wing)", "concluida": step >= 2},
		{"texto": "Lição 3: O Fluxo de REN", "concluida": step >= 3},
		{"texto": "Lição 4: O Silêncio Furtivo de ZETSU", "concluida": step >= 4},
		{"texto": "Lição 5: A Visão Reveladora de GYO", "concluida": step >= 5}
	]

	for lic in licoes:
		var p_lic := PanelContainer.new()
		var cor_b = HunterUIStyle.COLOR_BORDER_GREEN if lic["concluida"] else HunterUIStyle.COLOR_BORDER_SUBTLE
		p_lic.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(cor_b, 2))
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		p_lic.add_child(m)

		var lbl := Label.new()
		lbl.text = ("✅ " if lic["concluida"] else "🔒 ") + lic["texto"]
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY if lic["concluida"] else HunterUIStyle.COLOR_TEXT_MUTED)
		m.add_child(lbl)

		wing_list_container.add_child(p_lic)


func _atualizar_conteudo_lore() -> void:
	if lore_list_container == null:
		return
	for c in lore_list_container.get_children():
		c.queue_free()

	var desc_besta = "Nenhuma Besta de Nen despertada ainda. Realize juramentos arriscados ou alcance Nen Lv. 10 para despertar seu guardião de aura."
	if PlayerData.besta_nen_desbloqueada and PlayerData.besta_nen_equipada != null:
		desc_besta = "Besta Ativa: %s | Arquétipo de Combate & Proteção Ativo." % PlayerData.besta_nen_equipada

	var lores = [
		{"titulo": "🐉 BESTAS DE NEN & GUARDIÕES", "desc": desc_besta},
		{"titulo": "👑 O EXAME HUNTER & A ASSOCIAÇÃO", "desc": "Organização global liderada por caçadores de elite. A licença concede privilégios absolutos."},
		{"titulo": "💎 GREED ISLAND", "desc": "Um jogo lendário para usuários de Nen, onde cartas mágicas moldam a realidade."}
	]

	for item in lores:
		var p_lore := PanelContainer.new()
		p_lore.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_SUBTLE, 2))
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		p_lore.add_child(m)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 1)
		m.add_child(vb)

		var lbl_t := Label.new()
		lbl_t.text = item["titulo"]
		lbl_t.add_theme_font_size_override("font_size", 4)
		lbl_t.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
		vb.add_child(lbl_t)

		var lbl_d := Label.new()
		lbl_d.text = item["desc"]
		lbl_d.add_theme_font_size_override("font_size", 3)
		lbl_d.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		lbl_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(lbl_d)

		lore_list_container.add_child(p_lore)


func _atualizar_conteudo_conquistas() -> void:
	if ach_list_container == null:
		return
	for c in ach_list_container.get_children():
		c.queue_free()

	if AchievementSystem == null:
		var lbl = Label.new()
		lbl.text = "Sistema de Conquistas Carregando..."
		lbl.add_theme_font_size_override("font_size", 4)
		ach_list_container.add_child(lbl)
		return

	var catalogo: Array = []
	if AchievementSystem.has_method("obter_catalogo_completo"):
		catalogo = AchievementSystem.obter_catalogo_completo()
	elif "CONQUISTAS_REGISTRADAS" in AchievementSystem:
		catalogo = AchievementSystem.CONQUISTAS_REGISTRADAS

	if catalogo.is_empty():
		var lbl = Label.new()
		lbl.text = "🏆 Conquistas Desbloqueadas: %d" % AchievementSystem.conquistas_desbloqueadas.size()
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
		ach_list_container.add_child(lbl)
		return

	for ach in catalogo:
		var ach_id = ach.get("id", "")
		var nome = ach.get("nome", ach.get("title", "Conquista"))
		var desc = ach.get("desc", ach.get("description", ""))
		var desbloq = AchievementSystem.tem_conquista(ach_id)

		var p_ach := PanelContainer.new()
		var cor_b = HunterUIStyle.COLOR_BORDER_GOLD if desbloq else HunterUIStyle.COLOR_BORDER_SUBTLE
		p_ach.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(cor_b, 2))
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		p_ach.add_child(m)

		var hbox := HBoxContainer.new()
		m.add_child(hbox)

		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.add_theme_constant_override("separation", 0)
		hbox.add_child(vb)

		var lbl_n := Label.new()
		lbl_n.text = ("🏆 " if desbloq else "🔒 ") + nome
		lbl_n.add_theme_font_size_override("font_size", 4)
		lbl_n.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT if desbloq else HunterUIStyle.COLOR_TEXT_MUTED)
		vb.add_child(lbl_n)

		var lbl_d := Label.new()
		lbl_d.text = desc
		lbl_d.add_theme_font_size_override("font_size", 3)
		lbl_d.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY if desbloq else HunterUIStyle.COLOR_TEXT_MUTED)
		vb.add_child(lbl_d)

		var lbl_st := Label.new()
		lbl_st.text = "[DESBLOQUEADA]" if desbloq else "[BLOQUEADA]"
		lbl_st.add_theme_font_size_override("font_size", 3)
		lbl_st.add_theme_color_override("font_color", HunterUIStyle.COLOR_HUNTER_GREEN_LIGHT if desbloq else HunterUIStyle.COLOR_TEXT_MUTED)
		hbox.add_child(lbl_st)

		ach_list_container.add_child(p_ach)


func abrir() -> void:
	visible = true
	_atualizar_aba_atual()