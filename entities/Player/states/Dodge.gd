extends State

@export var dodge_speed: float = 350.0
@export var dodge_duration: float = 0.25

var dodge_direction: Vector2 = Vector2.ZERO
var timer: float = 0.0

func enter() -> void:
	timer = dodge_duration
	player.ativar_invulnerabilidade_dodge()
	player.iniciar_cooldown_dodge()
	
	# Mantém a direção atual ou última direção de movimento
	dodge_direction = player.facing_direction
	if dodge_direction == Vector2.ZERO:
		dodge_direction = Vector2(0, 1)  # Default para baixo
	
	if player.sprite:
		player.sprite.play("dodge")

func process_physics(delta: float) -> void:
	timer -= delta
	player.velocity = dodge_direction.normalized() * dodge_speed
	player.move_and_slide()
	
	if timer <= 0:
		transition_requested.emit("Idle")

func exit() -> void:
	player.desativar_invulnerabilidade_dodge()
	player.velocity = Vector2.ZERO
