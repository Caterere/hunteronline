extends Control

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var xp_label: Label = $VBoxContainer/XPLabel
@onready var passive_label: Label = $VBoxContainer/PassiveLabel
@onready var evolution_label: Label = $VBoxContainer/EvolutionLabel
@onready var message_label: Label = $MessageLabel

func _ready() -> void:
	if not PlayerData.besta_nen_desbloqueada or PlayerData.besta_nen_equipada == null:
		_show_locked()
	else:
		_show_beast(PlayerData.besta_nen_equipada)

func _show_locked() -> void:
	var icon = get_node_or_null("VBoxContainer/BeastIcon")
	if icon != null: icon.hide()
	name_label.hide()
	level_label.hide()
	xp_label.hide()
	passive_label.hide()
	evolution_label.hide()
	message_label.show()
	message_label.text = "Besta de Nen não desbloqueada ou não equipada."

func _show_beast(beast: NenBeastData) -> void:
	message_label.hide()
	
	var icon = get_node_or_null("VBoxContainer/BeastIcon") as TextureRect
	if icon == null:
		icon = TextureRect.new()
		icon.name = "BeastIcon"
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var tex = load("res://assets/sprites/characters/nen_beast_kakin.png")
		if tex: icon.texture = tex
		$VBoxContainer.add_child(icon)
		$VBoxContainer.move_child(icon, 1)
	icon.show()

	name_label.show()
	level_label.show()
	xp_label.show()
	passive_label.show()
	evolution_label.show()
	
	name_label.text = "Nome: " + beast.nome_besta
	level_label.text = "Nível: " + str(beast.nivel)
	xp_label.text = "XP: " + str(beast.xp) + " / " + str(beast.max_xp)
	passive_label.text = "Passiva: " + beast.obter_nome_tipo()
	
	var next_evo = beast.nivel + 5 - (beast.nivel % 5)
	if next_evo == beast.nivel:
		next_evo += 5
	evolution_label.text = "Próxima Evolução: Nível " + str(next_evo)
