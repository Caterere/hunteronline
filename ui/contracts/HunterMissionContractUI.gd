class_name HunterMissionContractUI
extends Control

# ============================================================
# HUNTER ONLINE — OFFICIAL HUNTER MISSION CONTRACT COMPONENT
# ============================================================
#
# Interface de pergaminho oficial de contratação da Associação:
# - Selo de cera oficial e número de protocolo
# - Rank de Perigo Canônico (D, C, B, A, S)
# - Recompensas em Jenny e Pontos de Contribuição
# - Efeito carimbo "APROVADO PELA ASSOCIAÇÃO HUNTER"
# ============================================================

signal contrato_aceito(missao_id: String)
signal contrato_fechado

@export var missao_id: String = "hunt_chimera_scout"
@export var titulo: String = "Supressão de Batedores Quimera na Fronteira"
@export var contratante: String = "Associação Hunter — Divisão de Extermínio"
@export var localizacao: String = "Floresta Tropical de NGL"
@export var perigo_rank: String = "A" # D, C, B, A, S
@export var recompensa_jenny: int = 250000
@export var pontos_contribuicao: int = 150
@export var descricao_lore: String = "Relatórios indicam atividade anormal de criaturas desconhecidas atacando vilarejos. O uso cauteloso de In e Gyo é mandatório devido a emboscadas na névoa."

var _carimbado: bool = false
var _lbl_carimbo: Label = null


func _ready() -> void:
	custom_minimum_size = Vector2(300, 200)
	_construir_documento()


func _construir_documento() -> void:
	for c in get_children():
		c.queue_free()

	# Fundo Pergaminho Envelhecido
	var pc := PanelContainer.new()
	pc.custom_minimum_size = Vector2(300, 200)
	pc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.92, 0.88, 0.78, 1.0) # Tom pergaminho/papel antigo
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.45, 0.35, 0.22, 1.0) # Borda de couro marrom
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 8
	pc.add_theme_stylebox_override("panel", style)
	add_child(pc)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	pc.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)

	# Cabeçalho Oficial
	var hbox_hdr := HBoxContainer.new()
	vbox.add_child(hbox_hdr)

	var lbl_org := Label.new()
	lbl_org.text = "HUNTER ASSOCIATION — CONTRATO DE EXPEDIÇÃO"
	lbl_org.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_SMALL)
	lbl_org.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1, 1.0))
	lbl_org.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_hdr.add_child(lbl_org)

	# Badge de Perigo
	var cor_rank := Color.DARK_GRAY
	match perigo_rank.to_upper():
		"S": cor_rank = Color(0.8, 0.1, 0.1, 1.0)
		"A": cor_rank = Color(0.9, 0.4, 0.1, 1.0)
		"B": cor_rank = Color(0.8, 0.7, 0.1, 1.0)
		"C": cor_rank = Color(0.2, 0.5, 0.8, 1.0)
		_: cor_rank = Color(0.2, 0.6, 0.3, 1.0)

	var lbl_badge := Label.new()
	lbl_badge.text = "[RANK %s]" % perigo_rank.to_upper()
	lbl_badge.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_BODY)
	lbl_badge.add_theme_color_override("font_color", cor_rank)
	hbox_hdr.add_child(lbl_badge)

	# Divisor fino
	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Título da Missão
	var lbl_tit := Label.new()
	lbl_tit.text = titulo
	lbl_tit.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_SUBTITLE)
	lbl_tit.add_theme_color_override("font_color", Color(0.15, 0.1, 0.05, 1.0))
	lbl_tit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_tit)

	# Metadados (Contratante & Local)
	var lbl_meta := Label.new()
	lbl_meta.text = "Contratante: %s | Local: %s" % [contratante, localizacao]
	lbl_meta.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	lbl_meta.add_theme_color_override("font_color", Color(0.4, 0.3, 0.2, 1.0))
	vbox.add_child(lbl_meta)

	# Descrição / Diretiva Canônica
	var lbl_desc := Label.new()
	lbl_desc.text = descricao_lore
	lbl_desc.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_BODY)
	lbl_desc.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1, 1.0))
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(lbl_desc)

	# Recompensas
	var hbox_rec := HBoxContainer.new()
	vbox.add_child(hbox_rec)

	var lbl_rec := Label.new()
	lbl_rec.text = "💰 Jenny: %s Jenny  |  ⭐ Contribuição: +%d pts" % [_formatar_numero(recompensa_jenny), pontos_contribuicao]
	lbl_rec.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_SMALL)
	lbl_rec.add_theme_color_override("font_color", Color(0.5, 0.35, 0.05, 1.0))
	lbl_rec.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_rec.add_child(lbl_rec)

	# Carimbo de Aceite / Ações
	var hbox_act := HBoxContainer.new()
	hbox_act.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox_act)

	_lbl_carimbo = Label.new()
	_lbl_carimbo.text = "✍️ [DOCUMENTO PENDENTE DE ACEITE]"
	_lbl_carimbo.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_MICRO)
	_lbl_carimbo.add_theme_color_override("font_color", Color(0.6, 0.2, 0.2, 1.0))
	_lbl_carimbo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_act.add_child(_lbl_carimbo)

	var btn_aceitar := Button.new()
	btn_aceitar.text = "📜 Carimbar & Aceitar"
	btn_aceitar.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_SMALL)
	btn_aceitar.pressed.connect(_on_aceitar_pressionado)
	hbox_act.add_child(btn_aceitar)


func _on_aceitar_pressionado() -> void:
	if _carimbado:
		return
	_carimbado = true
	_lbl_carimbo.text = "🔴 [APROVADO PELA ASSOCIAÇÃO HUNTER]"
	var audio = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("tocar_efeito"):
		audio.tocar_efeito("ui_stamp")
	contrato_aceito.emit(missao_id)


func _formatar_numero(val: int) -> String:
	var s := str(val)
	var out := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			out = "." + out
	return out
