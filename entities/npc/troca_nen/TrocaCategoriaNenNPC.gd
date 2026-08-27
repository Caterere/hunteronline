extends NPC

# ============================================================
# HUNTER ONLINE - NPC ESPECIAL: RITUAL DE REALINHAMENTO DE NEN
# ============================================================
#
# Permite ao jogador escolher conscientemente sua nova Categoria de Nen:
# - Categorias Básicas (Intensificação, Transformação, Emissão, Conjuração, Manipulação):
#   -> Custo: 5.000.000 Jenny (100% de Sucesso)
# - Categoria Especialista (Especialização Suprema):
#   -> Custo: 15.000.000 Jenny (15% de Chance de Despertar Lendário)
#
# ============================================================

const CUSTO_BASICO: int = 5000000
const CUSTO_ESPECIALISTA: int = 15000000
const CHANCE_ESPECIALISTA: float = 0.15

var ui_modal: CanvasLayer = null
var categoria_selecionada: int = 0
var btn_confirmar: Button = null
var lbl_custo: Label = null
var lbl_aviso_especialista: Label = null


func _ready() -> void:
	super()
	npc_name = "Mestre Alquimista de Nen"
	fala_padrao = "Posso realizar o lendário Ritual da Água Negra para realinhar seus poros de Nen!"


func _on_interacted(_player: CharacterBody2D) -> void:
	QuestSystem.register_npc_visit(&"mestre_troca_nen")
	_abrir_modal_confirmacao()


func _abrir_modal_confirmacao() -> void:
	if ui_modal != null and is_instance_valid(ui_modal):
		ui_modal.queue_free()

	ui_modal = CanvasLayer.new()
	ui_modal.layer = 50
	ui_modal.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(ui_modal)
	get_tree().paused = true

	# Painel Central
	var panel := PanelContainer.new()
	panel.position = Vector2(25, 10)
	panel.custom_minimum_size = Vector2(270, 160)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.12, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.85, 0.65, 0.2, 1.0)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	panel.add_theme_stylebox_override("panel", style)
	ui_modal.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "🔮 RITUAL DE REALINHAMENTO DE NEN"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_font_size_override("font_size", 5)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(lbl_titulo)

	var cat_atual_nome = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
	var lbl_atual := Label.new()
	lbl_atual.text = "Afinidade Atual: %s" % cat_atual_nome
	lbl_atual.add_theme_font_size_override("font_size", 3)
	lbl_atual.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	vbox.add_child(lbl_atual)

	lbl_custo = Label.new()
	lbl_custo.add_theme_font_size_override("font_size", 3)
	vbox.add_child(lbl_custo)

	lbl_aviso_especialista = Label.new()
	lbl_aviso_especialista.text = ""
	lbl_aviso_especialista.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_aviso_especialista.add_theme_font_size_override("font_size", 3)
	lbl_aviso_especialista.add_theme_color_override("font_color", Color(1.0, 0.4, 0.2))
	vbox.add_child(lbl_aviso_especialista)

	# Grid de Opções das 6 Categorias
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 2)
	vbox.add_child(grid)

	categoria_selecionada = int(PlayerData.afinidade_nen)

	var categorias = [
		{"id": 0, "nome": "🔴 Intensificação (5M J)"},
		{"id": 1, "nome": "⚡ Transformação (5M J)"},
		{"id": 2, "nome": "🟢 Emissão (5M J)"},
		{"id": 3, "nome": "🟣 Conjuração (5M J)"},
		{"id": 4, "nome": "🟡 Manipulação (5M J)"},
		{"id": 5, "nome": "🌟 Especialização (15M J / 15% Chance)"}
	]

	var botoes_cat: Array[Button] = []

	for c in categorias:
		var btn_cat := Button.new()
		btn_cat.text = c["nome"]
		btn_cat.add_theme_font_size_override("font_size", 3)
		btn_cat.toggle_mode = true
		btn_cat.button_pressed = (c["id"] == categoria_selecionada)
		
		var c_id = c["id"]
		btn_cat.pressed.connect(func():
			categoria_selecionada = c_id
			for b in botoes_cat:
				b.button_pressed = (b == btn_cat)
			_atualizar_custo_e_botao()
		)
		botoes_cat.append(btn_cat)
		grid.add_child(btn_cat)

	# Botões de Ação (Aceitar ou Cancelar)
	var hbox_botoes := HBoxContainer.new()
	hbox_botoes.add_theme_constant_override("separation", 6)
	vbox.add_child(hbox_botoes)

	btn_confirmar = Button.new()
	btn_confirmar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_confirmar.add_theme_font_size_override("font_size", 3)
	btn_confirmar.pressed.connect(_ao_confirmar_troca)
	hbox_botoes.add_child(btn_confirmar)

	var btn_cancelar := Button.new()
	btn_cancelar.text = "❌ Cancelar / Sair"
	btn_cancelar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_cancelar.add_theme_font_size_override("font_size", 3)
	btn_cancelar.pressed.connect(_fechar_modal)
	hbox_botoes.add_child(btn_cancelar)

	_atualizar_custo_e_botao()


func _atualizar_custo_e_botao() -> void:
	if lbl_custo == null or btn_confirmar == null:
		return

	var eh_esp = (categoria_selecionada == 5)
	var custo_necessario = CUSTO_ESPECIALISTA if eh_esp else CUSTO_BASICO
	var gold_atual = Economy.obter_gold()
	var tem_ouro = gold_atual >= custo_necessario

	lbl_custo.text = "💰 Custo: %s Jenny (Saldo: %s J)" % [
		Economy.formatar_numero(custo_necessario), Economy.formatar_numero(gold_atual)
	]
	lbl_custo.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4) if tem_ouro else Color(1.0, 0.3, 0.3))

	if eh_esp:
		lbl_aviso_especialista.text = "⚠️ ESPECIALISTA: Categoria Suprema de 1 em 100.000! 15% de Chance de Sucesso!"
		btn_confirmar.text = "🌟 TENTAR DESPERTAR ESPECIALISTA (15M J)" if tem_ouro else "❌ Saldo Insuficiente (15M J)"
	else:
		lbl_aviso_especialista.text = "Garantia de 100% de Realinhamento com a categoria escolhida."
		btn_confirmar.text = "🔮 Confirmar Ritual (%s J)" % Economy.formatar_numero(custo_necessario) if tem_ouro else "❌ Saldo Insuficiente (%s J)" % Economy.formatar_numero(custo_necessario)

	btn_confirmar.disabled = not tem_ouro


func _ao_confirmar_troca() -> void:
	var eh_esp = (categoria_selecionada == 5)
	var custo_necessario = CUSTO_ESPECIALISTA if eh_esp else CUSTO_BASICO

	if not Economy.remover_gold(custo_necessario):
		_fechar_modal()
		return

	var hud = get_tree().get_first_node_in_group("player_hud")

	if eh_esp:
		# Sorteio de 15% de chance
		var rolou = randf()
		if rolou <= CHANCE_ESPECIALISTA:
			PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO
			PlayerData.aplicar_bonuses_afinidade()
			_fechar_modal()
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🌟 DESPERTAR LENDÁRIO! AURA DE ESPECIALISTA DESPERTA (100% EM TUDO)!")
			print("=================================")
			print("[MestreAlquimista] SUCESSO LENDÁRIO! ESPECIALISTA DESPERTO!")
			print("=================================")
		else:
			_fechar_modal()
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("❌ O Ritual de Especialista falhou! Seus nós não suportaram a mutação rara.")
			print("[MestreAlquimista] Ritual de Especialista falhou. 15M J consumidos.")
	else:
		PlayerData.afinidade_nen = categoria_selecionada as NenAffinityData.CategoriaAfinidade
		PlayerData.aplicar_bonuses_afinidade()
		var nova_cat_nome = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
		_fechar_modal()
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("✨ RITUAL CONCLUÍDO!\nNova Categoria: %s!" % nova_cat_nome.to_upper())
		print("[MestreAlquimista] Afinidade alterada com sucesso para: ", nova_cat_nome)


func _fechar_modal() -> void:
	if ui_modal != null and is_instance_valid(ui_modal):
		ui_modal.queue_free()
		ui_modal = null
	get_tree().paused = false
