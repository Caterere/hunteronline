class_name TreinadorNen
extends Area2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 # Player layer normally
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 40.0
	shape.shape = circle
	add_child(shape)
	
	# Assume player has interaction mechanism or we just use body_entered for demo
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_iniciar_treinamento()

func _iniciar_treinamento() -> void:
	print("Treinador Nen: Vamos começar seu treinamento de Nen!")
	var minigame_scene = load("res://ui/Minigames/NenTrainingMinigame.tscn")
	if minigame_scene:
		var minigame = minigame_scene.instantiate()
		get_tree().root.add_child(minigame)
		minigame.start_minigame()
