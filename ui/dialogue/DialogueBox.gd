class_name DialogueBox
extends CanvasLayer

# =========================================================
# REFERÊNCIAS DOS NÓS
# =========================================================

@onready var name_label: Label = find_child("NameLabel", true, false) as Label
@onready var dialogue_label: Label = find_child("DialogueLabel", true, false) as Label
@onready var choices_container: VBoxContainer = find_child("ChoicesContainer", true, false) as VBoxContainer
@onready var continue_indicator: Label = find_child("ContinueIndicator", true, false) as Label
@onready var panel_container: PanelContainer = find_child("PanelContainer", true, false) as PanelContainer


# =========================================================
# SISTEMA DE DIÁLOGO
# =========================================================

var dialogue_system: DialogueSystem = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	add_to_group("dialogue_box")
	layer = 20
	process_mode = PROCESS_MODE_ALWAYS
	hide()

	if panel_container != null:
		panel_container.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	if name_label != null:
		name_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
		name_label.add_theme_font_size_override("font_size", 10)
	if dialogue_label != null:
		dialogue_label.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		dialogue_label.add_theme_font_size_override("font_size", 9)
		dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if continue_indicator != null:
		continue_indicator.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
		continue_indicator.add_theme_font_size_override("font_size", 8)

	# Encontrar DialogueSystem
	dialogue_system = get_tree().get_first_node_in_group("dialogue_system") as DialogueSystem
	if dialogue_system == null:
		push_warning("DialogueBox: DialogueSystem não encontrado")

	# Limpar escolhas inicialmente
	_clear_choices()


# =========================================================
# MOSTRAR DIÁLOGO
# =========================================================

func show_dialogue(speaker: String, text: String) -> void:
	if name_label != null:
		name_label.text = "💬 " + speaker.to_upper()
	if dialogue_label != null:
		dialogue_label.text = text

	_clear_choices()
	if continue_indicator != null:
		continue_indicator.visible = true

	show()


# =========================================================
# MOSTRAR ESCOLHAS (RAMIFICAÇÕES)
# =========================================================

func show_choices(branches: Array[DialogueBranch]) -> void:
	_clear_choices()
	if continue_indicator != null:
		continue_indicator.visible = false

	if choices_container == null:
		return

	for branch in branches:
		var button := Button.new()
		button.text = "▶ " + branch.choice_text
		button.add_theme_font_size_override("font_size", 8)
		button.custom_minimum_size = Vector2(0, 18)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		HunterUIStyle.aplicar_estilo_botao(button, HunterUIStyle.COLOR_BORDER_GREEN)

		button.pressed.connect(
			func() -> void:
				if dialogue_system != null:
					dialogue_system.choose_branch(branch)
		)

		choices_container.add_child(button)

	if choices_container.get_child_count() > 0:
		var first_btn = choices_container.get_child(0) as Button
		if first_btn != null:
			first_btn.grab_focus()


# =========================================================
# LIMPAR ESCOLHAS
# =========================================================

func _clear_choices() -> void:
	if choices_container == null:
		return
	for child in choices_container.get_children():
		child.queue_free()
