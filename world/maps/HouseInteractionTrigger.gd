extends Node

# Permite interagir nas zonas da casa do jogador com tecla [E]
func _unhandled_input(event: InputEvent) -> void:
	var area = get_parent() as Area2D
	if area == null:
		return
	if area.get_meta("player_dentro", false):
		if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
			var cb = area.get_meta("callback", Callable())
			if cb.is_valid():
				cb.call()
