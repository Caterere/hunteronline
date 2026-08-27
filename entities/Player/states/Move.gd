extends State

func enter() -> void:
	if player.sprite:
		player.sprite.play("run")

func process_physics(delta: float) -> void:
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input == Vector2.ZERO:
		transition_requested.emit("Idle")
		return
	
	# Atualiza direção para ataques direcionais
	player.facing_direction = input
	
	# Velocidade baseada no atributo Velocidade do GDD (escala 10-1000)
	var velocidade_base = 150.0
	var multiplicador = clamp(player.atributos.velocidade / 10.0, 1.0, 100.0)
	player.velocity = input * velocidade_base * sqrt(multiplicador)  # sqrt para não explodir
	
	# Flip do sprite
	if player.sprite:
		if input.x != 0:
			player.sprite.flip_h = input.x < 0
	
	player.move_and_slide()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge") and player.can_dodge:
		transition_requested.emit("Dodge")
	if event.is_action_pressed("attack"):
		transition_requested.emit("Attack")
