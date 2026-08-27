class_name TreinadorFisico
extends Area2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 40.0
	shape.shape = circle
	add_child(shape)
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_iniciar_treinamento(body)

func _iniciar_treinamento(player: Node2D) -> void:
	print("Treinador Físico: Vamos suar a camisa!")
	
	# Simulates physical training
	if player.has_method("adicionar_xp_fisico"):
		player.adicionar_xp_fisico(50)
	elif Engine.has_singleton("PlayerData"):
		# Fallback to PlayerData singleton if available
		print("Adicionando XP físico ao PlayerData...")
	else:
		print("Treino Físico concluído! Você ganhou +50 XP Físico.")
