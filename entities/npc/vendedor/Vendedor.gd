class_name VendedorNPC
extends NPC

var ui_instance: ShopUI = null

func _ready() -> void:
	npc_name = "Vendedor"
	fala_padrao = "Bem-vindo à minha loja! Temos equipamentos e cosméticos."
	super()

func _on_interacted(player: CharacterBody2D) -> void:
	super(player)
	
	if ui_instance == null:
		var scene = load("res://ui/Shop/ShopUI.tscn")
		if scene:
			ui_instance = scene.instantiate()
			get_tree().root.add_child(ui_instance)
		else:
			ui_instance = ShopUI.new()
			get_tree().root.add_child(ui_instance)
			
	ui_instance.abrir()
