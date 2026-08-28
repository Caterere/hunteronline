extends CharacterBody2D

var _state_machine
var _is_attacking: bool = false
var _attack_anim_timer: float = 0.0
var _direcao_olhar: Vector2 = Vector2.DOWN

@onready var combat_system: HunterCombatSystem = $CombatSystem
@onready var hatsu_system: HatsuSystem = get_node_or_null("HatsuSystem") as HatsuSystem
@onready var nen_beast_system: NenBeastSystem = get_node_or_null("NenBeastSystem") as NenBeastSystem



@export_category("Variables")
@export var _move_speed: float = 64.0

@export var _friction: float = 0.2
@export var _acceleration: float = 0.2

@export_category("Objects")
@export var _animation_tree: AnimationTree = null
var controles_travados: bool = false

# Camera & Screen Shake (Fase 1: Juice & Game Feel)
var _camera: Camera2D = null
var _trauma: float = 0.0
var _trauma_power: float = 2.0
var _max_shake_offset: float = 8.0
var _shake_decay: float = 2.8


func _enter_tree() -> void:
	collision_layer = 2 # Layer 2 (Player)
	collision_mask = 1  # Mask 1 (Paredes/Cenário apenas)


func _ready() -> void:
	collision_layer = 2 # Layer 2 (Player)
	collision_mask = 1  # Mask 1 (Paredes/Cenário apenas)

	_state_machine = _animation_tree["parameters/playback"]

	combat_system.setup(self)

	if hatsu_system != null:
		hatsu_system.setup(self)

	if nen_beast_system != null:
		nen_beast_system.setup(self)

	# Configurar Câmera Suave e desacoplada
	_camera = get_node_or_null("Camera2D") as Camera2D
	if _camera == null:
		_camera = Camera2D.new()
		_camera.name = "Camera2D"
		_camera.position_smoothing_enabled = true
		_camera.position_smoothing_speed = 8.0
		add_child(_camera)

	if EventBus != null and not EventBus.camera_shake_requested.is_connected(_on_camera_shake_requested):
		EventBus.camera_shake_requested.connect(_on_camera_shake_requested)

	# Attack speed escalado pelo atributo Velocidade (GDD Vol 5)
	_atualizar_attack_cooldown()

	add_to_group("player")
	_aplicar_customizacao_visual()

	# Restaurar posição salva se estiver carregando save
	if PlayerData.posicao_salva != Vector2.ZERO:
		global_position = PlayerData.posicao_salva
		PlayerData.posicao_salva = Vector2.ZERO


func _on_camera_shake_requested(intensity: float, _duration: float) -> void:
	_trauma = clampf(_trauma + intensity, 0.0, 1.0)



func travar_controles(travar: bool = true) -> void:
	controles_travados = travar
	if travar:
		velocity = Vector2.ZERO
		if _state_machine != null:
			_state_machine.travel("idle")


func reviver(pos_respawn: Vector2 = Vector2.ZERO) -> void:
	travar_controles(false)
	if combat_system != null:
		combat_system.reviver()
	if pos_respawn != Vector2.ZERO:
		global_position = pos_respawn
	if _state_machine != null:
		_state_machine.travel("idle")
	_aplicar_hit_flash()


func _aplicar_customizacao_visual() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite != null and PlayerData.character_colors.has("roupa"):
		# Aplicar Shader de troca de paleta de cor
		var shader := load("res://assets/shaders/character_color_customizer.gdshader") as Shader
		if shader != null:
			var mat := ShaderMaterial.new()
			mat.shader = shader
			var cor_cabelo: Color = PlayerData.character_colors.get("cabelo", Color.BLACK)
			var cor_roupa: Color = PlayerData.character_colors.get("roupa", Color.GREEN)
			mat.set_shader_parameter("hair_custom_color", cor_cabelo)
			mat.set_shader_parameter("clothes_custom_color", cor_roupa)
			sprite.material = mat



var em_hit_flash: bool = false


func receber_dano(dano: int, direcao_ataque: Vector2 = Vector2.ZERO, _forca_knockback: float = 0.0, atacante: Node = null) -> void:
	if combat_system != null:
		combat_system.receber_dano(dano, direcao_ataque, 0.0, atacante)
	_aplicar_hit_flash()


func _aplicar_hit_flash() -> void:
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr == null or em_hit_flash:
		return
	em_hit_flash = true
	spr.modulate = Color(3.0, 0.4, 0.4, 1.0)
	await get_tree().create_timer(0.18).timeout
	if is_instance_valid(spr):
		spr.modulate = Color.WHITE
	em_hit_flash = false


func _physics_process(delta: float) -> void:
	var input_ctx = get_node_or_null("/root/InputContextManager")
	if controles_travados or StoryCutsceneManager.em_cutscene or (input_ctx != null and not input_ctx.is_gameplay_input_allowed()):
		velocity = Vector2.ZERO
		_animate()
		move_and_slide()
		return

	# Atualizar timer de animação de ataque
	if _attack_anim_timer > 0.0:
		_attack_anim_timer -= delta
		if _attack_anim_timer <= 0.0:
			_is_attacking = false

	# Atualizar Screen Shake (Trauma Decay)
	if _trauma > 0.0 and _camera != null:
		_trauma = max(0.0, _trauma - _shake_decay * delta)
		var shake = pow(_trauma, _trauma_power)
		_camera.offset = Vector2(
			randf_range(-1.0, 1.0) * _max_shake_offset * shake,
			randf_range(-1.0, 1.0) * _max_shake_offset * shake
		)
	elif _camera != null and _camera.offset != Vector2.ZERO:
		_camera.offset = Vector2.ZERO


	_dash()
	_move()
	_attack()
	_animate()

	move_and_slide()

	if TutorialManager != null and TutorialManager.em_tutorial and velocity.length() > 5.0:
		TutorialManager.notificar_movimento(velocity.length() * delta)



func _dash() -> void:
	if Input.is_action_just_pressed("dash"):
		if combat_system != null and combat_system.pode_esquivar:
			var dir: Vector2 = Vector2(
				Input.get_axis("move_left", "move_right"),
				Input.get_axis("move_up", "move_down")
			).normalized()
			if dir == Vector2.ZERO:
				dir = velocity.normalized() if velocity != Vector2.ZERO else Vector2.DOWN
			if combat_system.tentar_esquivar(dir):
				_is_attacking = false
				_attack_anim_timer = 0.0
				velocity = dir * 220.0
				if TutorialManager != null and TutorialManager.em_tutorial:
					TutorialManager.notificar_esquiva_executada()




var em_sprint: bool = false


func esta_em_sprint() -> bool:
	return em_sprint


func _obter_velocidade_atual() -> float:
	var vel_attr: float = float(PlayerData.attributes.get("velocidade", 10))
	var spd: float = _move_speed + (vel_attr * 0.4)
	
	em_sprint = false
	var sprint_pressed = Input.is_key_pressed(KEY_SHIFT) or (InputMap.has_action("sprint") and Input.is_action_pressed("sprint"))
	if sprint_pressed and not _is_attacking:
		em_sprint = true
		spd = 110.0 + (vel_attr * 0.7)

	if hatsu_system != null and hatsu_system.esta_godspeed():
		spd *= 2.4 # Velocidade Divina (Kanmuru) do Killua!
	return spd




func _move() -> void:

	if StoryCutsceneManager.em_cutscene or (hatsu_system != null and hatsu_system.esta_imobilizado()):
		velocity = Vector2.ZERO
		return

	var _direction: Vector2 = Vector2(

		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	var current_spd: float = _obter_velocidade_atual()

	if _direction != Vector2.ZERO:
		_direcao_olhar = _direction.normalized()

		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction

		velocity.x = lerp(
			velocity.x,
			_direction.normalized().x * current_spd,
			_acceleration
		)

		velocity.y = lerp(
			velocity.y,
			_direction.normalized().y * current_spd,
			_acceleration
		)

		return


	velocity.x = lerp(
		velocity.x,
		0.0,
		_friction
	)

	velocity.y = lerp(
		velocity.y,
		0.0,
		_friction
	)


func _attack() -> void:

	if not Input.is_action_just_pressed("attack"):
		return

	if TutorialManager != null and TutorialManager.em_tutorial:
		TutorialManager.notificar_ataque_executado()

	if not combat_system.pode_atacar:
		return

	if combat_system.esquivando:
		return

	# Atualizar cooldown baseado na Velocidade (GDD Vol 5)
	_atualizar_attack_cooldown()

	_is_attacking = true
	_attack_anim_timer = min(combat_system.ataque_cooldown, 0.4)

	var direcao_ataque: Vector2 = _direcao_olhar

	if velocity != Vector2.ZERO:
		direcao_ataque = velocity.normalized()
		_direcao_olhar = direcao_ataque

	_animation_tree["parameters/attack/blend_position"] = direcao_ataque

	combat_system.tentar_atacar(direcao_ataque)

	_state_machine.travel("attack")


# Escalona o cooldown do ataque básico baseado no atributo Velocidade
# GDD Vol 5: "velocidade baseada no atributo Velocidade"
# Velocidade 10 (inicial) -> 0.50s entre ataques
# Velocidade 100 -> 0.38s
# Velocidade 500 -> 0.25s
# Velocidade 1000 (max) -> 0.20s
func _atualizar_attack_cooldown() -> void:
	var vel_attr: float = float(PlayerData.attributes.get("velocidade", 10))
	# Fórmula: cooldown diminui com velocidade, range 0.50s -> 0.20s
	var cooldown: float = 0.50 / (1.0 + vel_attr * 0.003)
	cooldown = clamp(cooldown, 0.20, 0.50)
	combat_system.ataque_cooldown = cooldown


func _animate() -> void:

	if _is_attacking:
		return


	if velocity.length() > 2:

		_state_machine.travel("walk")

		return


	_state_machine.travel("idle")
