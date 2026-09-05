class_name HunterLicenseCard
extends Control

# ============================================================
# HUNTER ONLINE — OFFICIAL HUNTER LICENSE CARD COMPONENT
# ============================================================
#
# Elemento de interface tátil e canônico representando a
# Licença Hunter Oficial concedida pela Associação de Caçadores:
# - Face Frontal: Acabamento metálico, chip de Nen, estrelas de patente,
#   foto do caçador, número de registro e afinidade natal.
# - Face Traseira: Tarja magnética, código holográfico, estatuto
#   oficial da Associação e selo assinado do Presidente.
# - Interatividade: Efeito de virada 3D/2D entre frente e verso.
# ============================================================

signal licenca_virada(face_frontal: bool)

const CharacterVisualDatabase = preload("res://resource/visual/CharacterVisualDatabase.gd")

@export var numero_licenca: String = "HA-287-0405"
@export var nome_cacador: String = "Gon Freecss"
@export var afinidade_nen: String = "Intensificação"
@export var especializacao: String = "Beast Hunter"
@export var estrelas: int = 1 # 0 = Licenciado, 1 = Uma Estrela, 2 = Duas Estrelas, 3 = Três Estrelas

var _esta_na_frente: bool = true
var _container_frente: PanelContainer = null
var _container_verso: PanelContainer = null
var _btn_virar: Button = null


func _ready() -> void:
	custom_minimum_size = Vector2(280, 160)
	_sincronizar_dados_player()
	_construir_ui()


func _sincronizar_dados_player() -> void:
	if PlayerData != null:
		if not PlayerData.player_name.is_empty():
			nome_cacador = PlayerData.player_name
		var afin = PlayerData.nen_affinity
		match afin:
			0: afinidade_nen = "Intensificação"
			1: afinidade_nen = "Transformação"
			2: afinidade_nen = "Emissão"
			3: afinidade_nen = "Conjuração"
			4: afinidade_nen = "Manipulação"
			5: afinidade_nen = "Especialização"
			_: afinidade_nen = "Desperto"

		var lvl = int(PlayerData.attributes.get("nivel", 1))
		if lvl >= 800:
			estrelas = 3
		elif lvl >= 400:
			estrelas = 2
		elif lvl >= 100:
			estrelas = 1
		else:
			estrelas = 0


func _construir_ui() -> void:
	# Limpar filhos
	for c in get_children():
		c.queue_free()

	# Painel Frontal
	_container_frente = _criar_painel_frontal()
	add_child(_container_frente)

	# Painel Verso (oculto de início)
	_container_verso = _criar_painel_verso()
	_container_verso.visible = false
	add_child(_container_verso)


func _criar_painel_frontal() -> PanelContainer:
	var pc := PanelContainer.new()
	pc.name = "FrontFace"
	pc.custom_minimum_size = Vector2(280, 160)
	pc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.20, 1.0) # Aço escovado azulado
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = HunterUIStyle.COLOR_BORDER_GOLD
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 2)
	pc.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	pc.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	# Cabeçalho da Licença
	var hbox_hdr := HBoxContainer.new()
	vbox.add_child(hbox_hdr)

	var lbl_assoc := Label.new()
	lbl_assoc.text = "HUNTER ASSOCIATION 猎人协会"
	lbl_assoc.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_SMALL)
	lbl_assoc.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD)
	lbl_assoc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_hdr.add_child(lbl_assoc)

	# Estrelas de Hunter
	var str_estrelas := "☆☆☆"
	match estrelas:
		1: str_estrelas = "★☆☆ [Single Star]"
		2: str_estrelas = "★★☆ [Double Star]"
		3: str_estrelas = "★★★ [Triple Star]"
		_: str_estrelas = "LICENSED HUNTER"

	var lbl_rank := Label.new()
	lbl_rank.text = str_estrelas
	lbl_rank.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	lbl_rank.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	hbox_hdr.add_child(lbl_rank)

	# Divisor metálico
	var hline := HSeparator.new()
	vbox.add_child(hline)

	# Corpo Central (Foto + Chip + Dados)
	var hbox_corpo := HBoxContainer.new()
	hbox_corpo.add_theme_constant_override("separation", 10)
	hbox_corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox_corpo)

	# Foto / Retrato do Caçador
	var panel_foto := PanelContainer.new()
	panel_foto.custom_minimum_size = Vector2(54, 66)
	var style_foto := StyleBoxFlat.new()
	style_foto.bg_color = Color(0.08, 0.1, 0.14, 1.0)
	style_foto.border_width_left = 1
	style_foto.border_width_top = 1
	style_foto.border_width_right = 1
	style_foto.border_width_bottom = 1
	style_foto.border_color = HunterUIStyle.COLOR_GOLD_MUTED
	panel_foto.add_theme_stylebox_override("panel", style_foto)

	var tex_rect := TextureRect.new()
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.texture = CharacterVisualDatabase.obter_retrato(nome_cacador)
	panel_foto.add_child(tex_rect)
	hbox_corpo.add_child(panel_foto)

	# Dados do Hunter e Chip
	var vbox_dados := VBoxContainer.new()
	vbox_dados.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_dados.add_theme_constant_override("separation", 3)
	hbox_corpo.add_child(vbox_dados)

	# Microchip Nen e Número de Registro
	var hbox_chip := HBoxContainer.new()
	vbox_dados.add_child(hbox_chip)

	var lbl_chip := Label.new()
	lbl_chip.text = "IC-CHIP [NEN-AUTHENTICATED]"
	lbl_chip.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	lbl_chip.add_theme_color_override("font_color", Color(0.8, 0.7, 0.2, 1.0))
	lbl_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_chip.add_child(lbl_chip)

	var lbl_num := Label.new()
	lbl_num.text = "REG: %s" % numero_licenca
	lbl_num.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	lbl_num.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	hbox_chip.add_child(lbl_num)

	# Nome
	var lbl_nome := Label.new()
	lbl_nome.text = nome_cacador.to_upper()
	lbl_nome.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_SUBTITLE)
	lbl_nome.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
	vbox_dados.add_child(lbl_nome)

	# Afinidade de Nen
	var lbl_afin := Label.new()
	lbl_afin.text = "Afinidade de Aura: %s" % afinidade_nen
	lbl_afin.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_BODY)
	lbl_afin.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox_dados.add_child(lbl_afin)

	# Especialização
	var lbl_esp := Label.new()
	lbl_esp.text = "Especialização: %s" % especializacao
	lbl_esp.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_SMALL)
	lbl_esp.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	vbox_dados.add_child(lbl_esp)

	# Rodapé do Cartão com Botão de Virar
	var hbox_ftr := HBoxContainer.new()
	vbox.add_child(hbox_ftr)

	var lbl_secret := Label.new()
	lbl_secret.text = "CONFIDENCIAL — PROPRIEDADE INALIENÁVEL"
	lbl_secret.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	lbl_secret.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_MUTED)
	lbl_secret.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_ftr.add_child(lbl_secret)

	var btn_flip := Button.new()
	btn_flip.text = "🔄 Virar Cartão"
	btn_flip.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	btn_flip.pressed.connect(virar_cartao)
	hbox_ftr.add_child(btn_flip)

	return pc


func _criar_painel_verso() -> PanelContainer:
	var pc := PanelContainer.new()
	pc.name = "BackFace"
	pc.custom_minimum_size = Vector2(280, 160)
	pc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.10, 0.14, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = HunterUIStyle.COLOR_BORDER_GOLD
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	pc.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	pc.add_child(vbox)

	# Tarja Magnética de Nen
	var tarja := ColorRect.new()
	tarja.color = Color(0.03, 0.03, 0.04, 1.0)
	tarja.custom_minimum_size = Vector2(280, 24)
	vbox.add_child(tarja)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	vbox.add_child(margin)

	var vbox_corpo := VBoxContainer.new()
	vbox_corpo.add_theme_constant_override("separation", 4)
	margin.add_child(vbox_corpo)

	var lbl_clausula := Label.new()
	lbl_clausula.text = "TERMOS DO ESTATUTO DOS CAÇADORES (CLÁUSULA 1 A 10):\n1. Caçadores devem caçar algo em busca da verdade.\n2. O portador possui salvo-conduto em 90% dos países do globo.\n3. A perda da licença física não anula o status, mas jamais será reemitida."
	lbl_clausula.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	lbl_clausula.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_SECONDARY)
	lbl_clausula.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_corpo.add_child(lbl_clausula)

	# Linha de Assinatura e Selo
	var hbox_ass := HBoxContainer.new()
	vbox_corpo.add_child(hbox_ass)

	var lbl_selo := Label.new()
	lbl_selo.text = "CHAIRMAN SEAL:\nIsaac Netero / Cheadle"
	lbl_selo.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	lbl_selo.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD)
	lbl_selo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_ass.add_child(lbl_selo)

	var btn_flip := Button.new()
	btn_flip.text = "🔄 Frente"
	btn_flip.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	btn_flip.pressed.connect(virar_cartao)
	hbox_ass.add_child(btn_flip)

	return pc


func virar_cartao() -> void:
	_esta_na_frente = not _esta_na_frente
	_container_frente.visible = _esta_na_frente
	_container_verso.visible = not _esta_na_frente
	licenca_virada.emit(_esta_na_frente)
	var audio = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("tocar_efeito"):
		audio.tocar_efeito("ui_card_flip")
