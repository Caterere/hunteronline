class_name HunterLicenseUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - HUNTER LICENSE UI (TECLA L OU USAR ITEM)
# ============================================================
#
# Interface de Licença Hunter Interativa estilo Anime:
# - Exibe Status Oficial do Hunter e Cartão Dourado
# - Terminal Confidencial com Registro de Caça a Alvos
# - Penhor de Emergência (Venda/Recompra por 100M Jenny)
# - Benefícios & Privilégios Globais Ativos
#
# ============================================================

var panel_main: PanelContainer
var lbl_status: Label
var lbl_detalhes: Label
var btn_penhor: Button


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 16
	visible = false
	_construir_ui()


func alternar_licenca() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		_atualizar_licenca()


func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(290, 160)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_main.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_main.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel_main.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# Título
	var lbl_titulo := Label.new()
	lbl_titulo.text = "💳 LICENÇA HUNTER OFICIAL — NEN ASSOCIATION"
	lbl_titulo.add_theme_font_size_override("font_size", 7)
	lbl_titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_titulo)

	var hsep := HSeparator.new()
	vbox.add_child(hsep)

	var hbox := HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(hbox)

	# Coluna Esquerda - Status
	var col_esq := VBoxContainer.new()
	col_esq.custom_minimum_size = Vector2(130, 0)
	hbox.add_child(col_esq)

	lbl_status = Label.new()
	lbl_status.add_theme_font_size_override("font_size", 4)
	col_esq.add_child(lbl_status)

	btn_penhor = Button.new()
	btn_penhor.text = "💰 Penhorar por 100M Jenny"
	btn_penhor.add_theme_font_size_override("font_size", 4)
	btn_penhor.pressed.connect(_on_penhor_pressed)
	col_esq.add_child(btn_penhor)

	# Coluna Direita - Terminal Confidencial
	var col_dir := VBoxContainer.new()
	col_dir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(col_dir)

	var lbl_term_title := Label.new()
	lbl_term_title.text = "🔍 TERMINAL DE BANCO DE DADOS CONFIDENCIAL:"
	lbl_term_title.add_theme_font_size_override("font_size", 4)
	lbl_term_title.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1))
	col_dir.add_child(lbl_term_title)

	lbl_detalhes = Label.new()
	lbl_detalhes.add_theme_font_size_override("font_size", 4)
	lbl_detalhes.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_detalhes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_dir.add_child(lbl_detalhes)

	var lbl_fechar := Label.new()
	lbl_fechar.text = "[Pressione L para Fechar]"
	lbl_fechar.add_theme_font_size_override("font_size", 4)
	lbl_fechar.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7, 1))
	lbl_fechar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_fechar)


func _atualizar_licenca() -> void:
	var nome: String = PlayerData.nome_personagem
	var tem_licenca: bool = PlayerData.inventory.get("licenca_hunter", 0) > 0
	var penhorada: bool = PlayerData.attributes.get("licenca_penhorada", false)

	if penhorada:
		lbl_status.text = "HUNTER: %s\nSTATUS: ⚠️ PENHORADA\nID: #HXH-99482\n\nSua licença está empenhada por 100M Jenny." % nome.to_upper()
		btn_penhor.text = "🪙 Resgatar Licença (100M)"
		lbl_detalhes.text = "⚠️ ACESSO NEGADO AO TERMINAL CONFIDENCIAL.\n\nSua Licença Hunter foi empenhada. Pague 100.000.000 Jenny para recuperar seus privilégios de acesso mundial."
	elif tem_licenca:
		lbl_status.text = "HUNTER: %s\nSTATUS: 🟢 ATIVA (LICENCIADO)\nID: #HXH-99482\n\nPRIVILÉGIOS:\n• Transportes Grátis\n• Entradas Restritas\n• Banco de Dados Secretos" % nome.to_upper()
		btn_penhor.text = "💰 Penhorar por 100M Jenny"
		lbl_detalhes.text = "PRIVILÉGIOS CONFIDENCIAIS ATIVOS:\n\n1. Registros da Trupe Fantasma em Yorknew City.\n2. Ingressos de Greed Island validados.\n3. Acesso à Expedição ao Continente Negro liberado."
	else:
		lbl_status.text = "HUNTER: %s\nSTATUS: 🔴 NÃO LICENCIADO\n\nConclua o Exame Hunter com Satotz para obter sua Licença." % nome.to_upper()
		btn_penhor.visible = false
		lbl_detalhes.text = "Passe no Exame Hunter para desbloquear a Licença Oficial."


func _on_penhor_pressed() -> void:
	var penhorada: bool = PlayerData.attributes.get("licenca_penhorada", false)
	if not penhorada:
		PlayerData.attributes["licenca_penhorada"] = true
		Economy.adicionar_gold(100000000)
		print("[HunterLicense] Licença penhorada! Recebeu +100.000.000 Jenny!")
	else:
		if Economy.gastar_gold(100000000):
			PlayerData.attributes["licenca_penhorada"] = false
			print("[HunterLicense] Licença resgatada por 100.000.000 Jenny!")
		else:
			print("[HunterLicense] Jenny insuficiente para resgatar a licença!")

	_atualizar_licenca()
