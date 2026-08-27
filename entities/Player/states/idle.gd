extends State

func enter() -> void:
	player.velocity = Vector2.ZERO
	if player.sprite:
		player.sprite.play("idle")

func process_physics(delta: float) -> void:
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input != Vector2.ZERO:
		transition_requested.emit("Move")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge") and player.can_dodge:
		transition_requested.emit("Dodge")
	if event.is_action_pressed("attack"):
		transition_requested.emit("Attack")
