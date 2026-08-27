extends Control

# ============================================================
# HUNTER ONLINE - NEN MENU (COM BOTÕES DE ATIVAÇÃO DE TÉCNICAS)
# ============================================================
#
# Exibe todas as informações detalhadas do Sistema de Nen:
# Nível de Nen, XP, Aura, Técnicas Interativas (com botões de Ativar/Desativar),
# Afinidade Natal, Slots de Hatsu e Besta de Nen Equipada.
#
# ============================================================

@onready var titulo_label: Label = $Panel/MarginContainer/VBoxMain/TituloLabel
@onready var nen_level_label: Label = $Panel/MarginContainer/VBoxMain/HBoxContent/ColEsquerda/NenLevelLabel
@onready var nen_xp_label: Label = $Panel/MarginContainer/VBoxMain/HBoxContent/ColEsquerda/NenXPLabel
@onready var aura_label: Label = $Panel/MarginContainer/VBoxMain/HBoxContent/ColEsquerda/AuraLabel
@onready var tecnicas_label: Label = $Panel/MarginContainer/VBoxMain/HBoxContent/ColEsquerda/TecnicasLabel

@onready var afinidade_label: Label = $Panel/MarginContainer/VBoxMain/HBoxContent/ColDireita/AfinidadeLabel
@onready var afinidade_desc_label: Label = $Panel/MarginContainer/VBoxMain/HBoxContent/ColDireita/AfinidadeDescLabel
@onready var hatsus_label: Label = $Panel/MarginContainer/VBoxMain/HBoxContent/ColDireita/HatsusLabel
@onready var besta_label: Label = $Panel/MarginContainer/VBoxMain/HBoxContent/ColDireita/BestaLabel

var nen_system: NenSystem = null
var player: Node = null

var container_tecnicas: VBoxContainer = null
var botoes_tecnicas: Dictionary = {}


func _ready() -> void:
	visible = false
	var panel = get_node_or_null("Panel")
	if panel != null:
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_AURA_CYAN, 4))
	if titulo_label != null:
		titulo_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	_conectar_nen_system()
	_construir_botoes_tecnicas()
	_atualizar_nen_menu()


func _conectar_nen_system() -> void:
	if nen_system != null:
		return
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		nen_system = player.get_node_or_null("NenSystem") as NenSystem


func _process(_delta: float) -> void:
	if visible:
		_conectar_nen_system()
		_atualizar_nen_menu()


func alternar_menu() -> void:
	visible = not visible
	if visible:
		_conectar_nen_system()
		_construir_botoes_tecnicas()
		_atualizar_nen_menu()


func _construir_botoes_tecnicas() -> void:
	if container_tecnicas != null:
		return
	if tecnicas_label != null:
		tecnicas_label.visible = false

	var col_esq = get_node_or_null("Panel/MarginContainer/VBoxMain/HBoxContent/ColEsquerda")
	if col_esq == null:
		return

	var lbl_header := Label.new()
	lbl_header.text = "TÉCNICAS DE NEN:"
	lbl_header.add_theme_font_size_override("font_size", 4)
	lbl_header.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	col_esq.add_child(lbl_header)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(110, 58)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	container_tecnicas = VBoxContainer.new()
	container_tecnicas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container_tecnicas.add_theme_constant_override("separation", 1)
	scroll.add_child(container_tecnicas)
	col_esq.add_child(scroll)

	var tecs = [
		NenSystem.Tecnica.TEN,
		NenSystem.Tecnica.REN,
		NenSystem.Tecnica.ZETSU,
		NenSystem.Tecnica.GYO,
		NenSystem.Tecnica.SHU,
		NenSystem.Tecnica.KO,
		NenSystem.Tecnica.EN,
		NenSystem.Tecnica.KEN,
		NenSystem.Tecnica.RYU
	]

	for t in tecs:
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 2)

		var lbl := Label.new()
		lbl.name = "Lbl_" + str(t)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_font_size_override("font_size", 4)
		lbl.text = "Tecnica"
		row.add_child(lbl)

		var btn := Button.new()
		btn.name = "Btn_" + str(t)
		btn.custom_minimum_size = Vector2(28, 9)
		btn.add_theme_font_size_override("font_size", 3)
		btn.text = "OFF"
		btn.pressed.connect(_on_tecnica_btn_pressed.bind(t))
		row.add_child(btn)

		botoes_tecnicas[t] = {"label": lbl, "btn": btn}
		container_tecnicas.add_child(row)


func _on_tecnica_btn_pressed(t: int) -> void:
	if nen_system == null or not PlayerData.despertou_nen:
		return

	var ativa: bool = nen_system.tecnica_ativa(t)
	if ativa:
		nen_system.desativar_tecnica(t)
	else:
		nen_system.ativar_tecnica(t)

	_atualizar_nen_menu()


func _atualizar_nen_menu() -> void:
	var nivel_nen: int = int(PlayerData.attributes.get("nivel_nen", 0))
	var xp_nen: int = int(PlayerData.attributes.get("xp_nen", 0))
	var aura: float = float(PlayerData.attributes.get("aura", 0.0))
	var aura_max: float = float(PlayerData.attributes.get("aura_max", 0.0))
	var nome: String = PlayerData.nome_personagem

	var xp_necessario: int = 100
	if nen_system != null:
		xp_necessario = nen_system.obter_nen_xp_necessario()

	if titulo_label != null:
		titulo_label.text = "MENU DE NEN — " + nome.to_upper()

	if nen_level_label != null:
		nen_level_label.text = "Nen Lv. %d" % nivel_nen

	if nen_xp_label != null:
		nen_xp_label.text = "XP Nen: %d / %d" % [xp_nen, xp_necessario]

	if aura_label != null:
		aura_label.text = "Aura: %d / %d" % [int(aura), int(aura_max)]

	# Afinidade Natal
	if afinidade_label != null and afinidade_desc_label != null:
		if PlayerData.despertou_nen:
			var af_nome: String = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
			var af_desc: String = NenAffinityData.obter_descricao_afinidade(PlayerData.afinidade_nen)
			afinidade_label.text = "Afinidade: " + af_nome
			afinidade_desc_label.text = af_desc
		else:
			afinidade_label.text = "Afinidade: Oculta (Nen Bloqueado)"
			afinidade_desc_label.text = "Faça o Teste da Água com Mestre Wing para revelar sua afinidade natal."

	# Atualizar Botões Interativos de Técnicas
	if container_tecnicas != null:
		if nen_system != null and PlayerData.despertou_nen:
			for t in botoes_tecnicas.keys():
				var info = botoes_tecnicas[t]
				var nome_t: String = nen_system.nome_tecnica(t)
				var lvl_t: int = nen_system.obter_nivel_tecnica(t)
				var ativa: bool = nen_system.tecnica_ativa(t)

				info["label"].text = "%s Lv.%d" % [nome_t, lvl_t]
				if ativa:
					info["btn"].text = "🟢 ON"
					info["btn"].modulate = Color(0.3, 1.0, 0.4, 1.0)
				else:
					info["btn"].text = "⚪ ATIVAR"
					info["btn"].modulate = Color(0.8, 0.8, 0.8, 1.0)
				info["btn"].disabled = false
		else:
			for t in botoes_tecnicas.keys():
				var info = botoes_tecnicas[t]
				info["label"].text = "Bloqueado"
				info["btn"].text = "🔒"
				info["btn"].disabled = true

	# Atualizar Slots de Hatsu (1 a 4) com Restrições e Juramentos
	if hatsus_label != null:
		var text_hatsus: String = "SLOTS DE HATSU & RESTRIÇÕES:\n"
		if PlayerData.hatsu_desbloqueado:
			for i in range(4):
				var hatsu: HatsuData = PlayerData.obter_hatsu_slot(i)
				if hatsu != null:
					var str_conds: String = ""
					if not hatsu.condicoes.is_empty():
						str_conds = " [" + str(hatsu.condicoes.size()) + " Vows]"
					text_hatsus += " [%d] %s (Pwr:%d)%s\n" % [i + 1, hatsu.nome.left(8), int(hatsu.obter_poder_final()), str_conds]
				else:
					text_hatsus += " [%d] Vazio\n" % (i + 1)
		else:
			text_hatsus += " (Bloqueado - Treine com Biscuit)"
		hatsus_label.text = text_hatsus

	# Besta de Nen Equipada
	if besta_label != null:
		if PlayerData.besta_nen_equipada != null:
			var b: NenBeastData = PlayerData.besta_nen_equipada
			besta_label.text = "Besta Guardiã: %s\n(%s)" % [b.nome_besta, b.obter_nome_tipo()]
		else:
			besta_label.text = "Besta de Nen: Nenhuma Equipada"
