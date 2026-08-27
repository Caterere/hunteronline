extends State

@export var attack_duration: float = 0.3
@export var attack_cooldown: float = 0.2

var timer: float = 0.0
var atacou: bool = false

func enter() -> void:
	timer = attack_duration
	atacou = false
	if player.sprite:
		player.sprite.play("attack")
	
	# Posiciona a hitbox na direção do player
	_posicionar_hitbox()

func process_physics(delta: float) -> void:
	timer -= delta
	player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * 2000)  # Friction
	
	# Ativa hitbox no meio da animação
	if not atacou and timer <= attack_duration * 0.5:
		atacou = true
		_executar_ataque()
	
	if timer <= 0:
		transition_requested.emit("Idle")

func _posicionar_hitbox() -> void:
	var hitbox = player.hitbox
	var dir = player.facing_direction
	
	# Posiciona a hitbox relativa ao player (ajuste os valores conforme seu sprite)
	if abs(dir.x) > abs(dir.y):
		hitbox.position = Vector2(20 if dir.x > 0 else -20, 0)
	else:
		hitbox.position = Vector2(0, 20 if dir.y > 0 else -20)

func _executar_ataque() -> void:
	player.hitbox.monitoring = true
	await player.get_tree().create_timer(0.1).timeout
	player.hitbox.monitoring = false

func exit() -> void:
	player.hitbox.monitoring = false
