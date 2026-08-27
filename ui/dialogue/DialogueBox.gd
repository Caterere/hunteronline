class_name DialogueBox
extends Panel

# =========================================================
# REFERÊNCIAS DOS NÓS
# =========================================================

@onready var name_label: Label = $NameLabel
@onready var dialogue_label: Label = $DialogueLabel
@onready var choices_container: VBoxContainer = $ChoicesContainer


# =========================================================
# SISTEMA DE DIÁLOGO
# =========================================================

var dialogue_system: DialogueSystem = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	add_to_group("dialogue_box")

	hide()

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

	name_label.text = speaker
	dialogue_label.text = text

	_clear_choices()

	show()


# =========================================================
# MOSTRAR ESCOLHAS (RAMIFICAÇÕES)
# =========================================================

func show_choices(branches: Array[DialogueBranch]) -> void:

	_clear_choices()

	for branch in branches:

		var button = Button.new()

		button.text = branch.choice_text

		button.pressed.connect(
			func() -> void:
				if dialogue_system != null:
					dialogue_system.choose_branch(branch)
		)

		choices_container.add_child(button)


# =========================================================
# LIMPAR ESCOLHAS
# =========================================================

func _clear_choices() -> void:

	for child in choices_container.get_children():

		child.queue_free()
