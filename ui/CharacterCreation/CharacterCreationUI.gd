extends Control

@onready var name_input = $VBoxContainer/NameInput
@onready var skin_picker = $VBoxContainer/SkinPicker
@onready var hair_picker = $VBoxContainer/HairPicker
@onready var clothes_picker = $VBoxContainer/ClothesPicker
@onready var diff_dropdown = $VBoxContainer/DiffDropdown
@onready var roll_btn = $VBoxContainer/HBoxContainer/RollBtn
@onready var pot_label = $VBoxContainer/HBoxContainer/PotLabel
@onready var start_btn = $VBoxContainer/StartBtn

var current_potential: float = 1.0

func _ready() -> void:
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null:
		input_ctx.set_context("CHARACTER_CREATION")
	if AudioManager != null:
		AudioManager.tocar_musica("tomodachi_ni_narouyo")

	# Populate Dropdown
	diff_dropdown.add_item("Fácil")
	diff_dropdown.add_item("Normal")
	diff_dropdown.add_item("Difícil")
	diff_dropdown.add_item("Muito Difícil")
	diff_dropdown.add_item("Hunter Supremo")
	diff_dropdown.selected = 1 # Normal
	
	roll_btn.pressed.connect(_on_roll_pressed)
	start_btn.pressed.connect(_on_start_pressed)
	_on_roll_pressed() # Roll initial potential

func _on_roll_pressed() -> void:
	current_potential = randf_range(0.60, 1.00)
	pot_label.text = "Potencial: %.0f%%" % (current_potential * 100)

func _on_start_pressed() -> void:
	PlayerData.nome_personagem = name_input.text if name_input.text != "" else "Hunter"
	
	if not PlayerData.character_colors.has("pele"):
		PlayerData.character_colors["pele"] = Color.WHITE
	
	PlayerData.character_colors["pele"] = skin_picker.color
	PlayerData.character_colors["cabelo"] = hair_picker.color
	PlayerData.character_colors["roupa"] = clothes_picker.color
	
	PlayerData.dificuldade = diff_dropdown.selected as PlayerData.Dificuldade
	PlayerData.potencial = current_potential
	
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if input_ctx != null:
		input_ctx.set_context("GAMEPLAY")
		
	get_tree().change_scene_to_file("res://world/lobby.tscn")
