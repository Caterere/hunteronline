class_name FerreiroNPC
extends NPC

var ui_instance: BlacksmithUI = null

func _ready() -> void:
	npc_name = "Ferreiro"
	fala_padrao = "Quer forjar ou melhorar algum equipamento?"
	super()

func _on_interacted(player: CharacterBody2D) -> void:
	# Register visit and show dialogue if desired
	super(player)
	
	if ui_instance == null:
		var scene = load("res://ui/Blacksmith/BlacksmithUI.tscn")
		if scene:
			ui_instance = scene.instantiate()
			get_tree().root.add_child(ui_instance)
		else:
			ui_instance = BlacksmithUI.new()
			get_tree().root.add_child(ui_instance)
			
	ui_instance.abrir()
