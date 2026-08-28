class_name StatusMenu
extends Control

# ============================================================
# REFERÊNCIAS
# ============================================================

@onready var titulo_label: Label = find_child("TituloLabel", true, false) as Label
@onready var level_label: Label = find_child("LevelLabel", true, false) as Label
@onready var hp_label: Label = find_child("HPLabel", true, false) as Label
@onready var forca_label: Label = find_child("ForcaLabel", true, false) as Label
@onready var defesa_label: Label = find_child("DefesaLabel", true, false) as Label
@onready var aura_label: Label = find_child("AuraLabel", true, false) as Label

var lbl_titulo_personagem: Label = null
var lbl_faccao: Label = null
var lbl_segredos: Label = null

# ============================================================
# XP SYSTEM
# ============================================================

var xp_system: XPSystem


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	visible = false
	var panel = find_child("PanelContainer", true, false) as PanelContainer
	if panel == null:
		panel = get_node_or_null("Panel") as PanelContainer
	if panel != null:
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	if titulo_label != null:
		titulo_label.text = "STATUS DO CAÇADOR"
		titulo_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
		titulo_label.add_theme_font_size_override("font_size", 11)
	
	_criar_labels_extras()
	xp_system = get_tree().get_first_node_in_group("xp_system") as XPSystem
	_atualizar_status()


func _criar_labels_extras() -> void:
	var vbox = find_child("VBoxContainer", true, false) as VBoxContainer
	if vbox == null:
		return
		
	if lbl_titulo_personagem == null:
		lbl_titulo_personagem = Label.new()
		lbl_titulo_personagem.name = "TituloPersLabel"
		lbl_titulo_personagem.add_theme_font_size_override("font_size", 8)
		lbl_titulo_personagem.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		lbl_titulo_personagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_titulo_personagem)
		vbox.move_child(lbl_titulo_personagem, 2)

	if lbl_faccao == null:
		lbl_faccao = Label.new()
		lbl_faccao.name = "FaccaoLabel"
		lbl_faccao.add_theme_font_size_override("font_size", 8)
		lbl_faccao.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
		vbox.add_child(lbl_faccao)

	if lbl_segredos == null:
		lbl_segredos = Label.new()
		lbl_segredos.name = "SegredosLabel"
		lbl_segredos.add_theme_font_size_override("font_size", 8)
		lbl_segredos.add_theme_color_override("font_color", Color(0.9, 0.4, 1.0, 1.0))
		vbox.add_child(lbl_segredos)


# ============================================================
# PROCESS & INPUT
# ============================================================

func _process(_delta: float) -> void:
	if visible:
		_atualizar_status()


func alternar_menu() -> void:
	visible = not visible
	if visible:
		_atualizar_status()


# ============================================================
# ATUALIZAR STATUS
# ============================================================

func _atualizar_status() -> void:
	if xp_system == null:
		xp_system = get_tree().get_first_node_in_group("xp_system") as XPSystem

	# Título Equipado
	if lbl_titulo_personagem != null and PlayerData != null:
		lbl_titulo_personagem.text = "[%s]" % PlayerData.titulo_equipado

	# XP
	if xp_system != null:
		var xp: int = xp_system.obter_xp()
		var xp_necessario: int = xp_system.obter_xp_necessario()
		level_label.text = "XP: %d / %d" % [xp, xp_necessario]
	else:
		level_label.text = "XP: 0 / 0"

	# HP, Força, Defesa, Aura
	if PlayerData != null:
		var hp: int = PlayerData.attributes.get("vida", 0)
		var hp_max: int = PlayerData.attributes.get("vida_max", 0)
		hp_label.text = "HP: %d / %d" % [hp, hp_max]

		var forca: int = PlayerData.attributes.get("forca", 0)
		forca_label.text = "Força: " + str(forca)

		var defesa: int = PlayerData.attributes.get("defesa", 0)
		defesa_label.text = "Defesa: " + str(defesa)

		var aura: int = int(PlayerData.attributes.get("aura", 0))
		var aura_max: int = int(PlayerData.attributes.get("aura_max", 0))
		var nen_lv: int = PlayerData.attributes.get("nivel_nen", 0)
		aura_label.text = "Aura (Nen Lv.%d): %d / %d" % [nen_lv, aura, aura_max]

		# Facção & Rank
		if lbl_faccao != null:
			var faccao_txt = FactionManager.obter_nome_faccao_atual() if FactionManager else "Independente"
			var rank_txt = FactionManager.obter_nome_rank_atual() if FactionManager else "Sem Rank"
			lbl_faccao.text = "Facção: %s (%s)" % [faccao_txt, rank_txt]

		# Segredos Descobertos
		if lbl_segredos != null:
			var segredos_count = PlayerData.segredos_descobertos.size()
			lbl_segredos.text = "Segredos: %d / 10 Ocultos" % segredos_count
