extends CharacterBody2D

var _state_machine
var _is_attacking: bool = false
var _attack_anim_timer: float = 0.0
var _direcao_olhar: Vector2 = Vector2.DOWN

@onready var combat_system: HunterCombatSystem = $CombatSystem
@onready var nen_system: NenSystem = get_node_or_null("NenSystem") as NenSystem
@onready var hatsu_system: HatsuSystem = get_node_or_null("HatsuSystem") as HatsuSystem
@onready var nen_beast_system: NenBeastSystem = get_node_or_null("NenBeastSystem") as NenBeastSystem

@export_category("Variables")
@export var _move_speed: float = 160.0
@export var _friction: float = 0.35 # Resposta ágil e parada limpa sem patinar
@export var _acceleration: float = 0.30 # Aceleração 8-direcional precisa e imediata

@export_group("Attack Lunge / Game Feel")
@export var attack_lunge_enabled: bool = true
@export var attack_dash_distance: float = 24.0
@export var attack_dash_duration: float = 0.14
@export var attack_dash_speed: float = 260.0

var _attack_lunge_timer: float = 0.0
var _attack_lunge_total: float = 0.14
var _attack_lunge_dir: Vector2 = Vector2.ZERO
var _attack_lunge_current_speed: float = 0.0

@export_category("Objects")
@export var _animation_tree: AnimationTree = null
var controles_travados: bool = false
var _esta_desmaiado: bool = false
var _indicador_desmaio: Node2D = null

# Camera & Screen Shake (Fase 1: Juice & Game Feel)
var _camera: Camera2D = null
var _trauma: float = 0.0
var _trauma_power: float = 2.0
var _max_shake_offset: float = 8.0
var _shake_decay: float = 2.8


func _enter_tree() -> void:
	collision_layer = 2 # Layer 2 (Player)
	collision_mask = 1 | 8  # Layer 1 (Cenário / Paredes) + Layer 4/Bit 3 (NPCs sólidos na base)


func _ready() -> void:
	collision_layer = 2 # Layer 2 (Player)
	collision_mask = 1 | 8  # Layer 1 (Cenário / Paredes) + Layer 4/Bit 3 (NPCs sólidos na base)

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

	if SaveManager != null and not SaveManager.jogo_carregado.is_connected(_on_save_carregado):
		SaveManager.jogo_carregado.connect(_on_save_carregado)

	if PlayerData != null and not PlayerData.nivel_alterado.is_connected(_on_nivel_alterado):
		PlayerData.nivel_alterado.connect(_on_nivel_alterado)

	add_to_group("player")
	_aplicar_customizacao_visual()
	_garantir_indicador_desmaio()

	# Restaurar posição salva se estiver carregando save ou posicionar no SpawnPoint
	if PlayerData.posicao_salva != Vector2.ZERO:
		global_position = PlayerData.posicao_salva
		PlayerData.posicao_salva = Vector2.ZERO
	else:
		var wpm = get_node_or_null("/root/WorldProgressionManager")
		if wpm != null and wpm.has_method("posicionar_player_no_spawn"):
			wpm.call_deferred("posicionar_player_no_spawn", self)


func _on_camera_shake_requested(intensity: float, _duration: float) -> void:
	_trauma = clampf(_trauma + intensity, 0.0, 1.0)



func travar_controles(travar: bool = true) -> void:
	controles_travados = travar
	if travar:
		velocity = Vector2.ZERO
		# Em desmaio a animação "death" manda; não forçar idle aqui.
		if not _esta_desmaiado and _state_machine != null:
			_state_machine.travel("idle")


func tocar_animacao_morte() -> void:
	_esta_desmaiado = true
	velocity = Vector2.ZERO
	controles_travados = true
	var played := false
	if _animation_tree != null:
		_animation_tree.active = true
	if _state_machine != null:
		_state_machine.travel("death")
		played = true
	var anim_player := get_node_or_null("Animation") as AnimationPlayer
	if anim_player != null and anim_player.has_animation("death"):
		# Garante frames mesmo se a transição do tree falhar sem edges explícitos
		anim_player.play("death")
		played = true
	if not played:
		var spr := get_node_or_null("Sprite2D") as Sprite2D
		if spr != null:
			spr.frame = 59
	_garantir_indicador_desmaio()
	if _indicador_desmaio != null and _indicador_desmaio.has_method("show_self_downed"):
		_indicador_desmaio.call("show_self_downed")


func limpar_estado_desmaio() -> void:
	_esta_desmaiado = false
	if _indicador_desmaio != null and _indicador_desmaio.has_method("hide_prompt"):
		_indicador_desmaio.call("hide_prompt")


func reviver(pos_respawn: Vector2 = Vector2.ZERO) -> void:
	limpar_estado_desmaio()
	travar_controles(false)
	if combat_system != null:
		combat_system.reviver()
	if pos_respawn != Vector2.ZERO:
		global_position = pos_respawn
	if _animation_tree != null:
		_animation_tree.active = true
	if _state_machine != null:
		_state_machine.travel("idle")
	_aplicar_hit_flash()


func _garantir_indicador_desmaio() -> void:
	if _indicador_desmaio != null and is_instance_valid(_indicador_desmaio):
		return
	_indicador_desmaio = get_node_or_null("DownedReviveIndicator") as Node2D
	if _indicador_desmaio != null:
		return
	var script_res = load("res://entities/Player/components/DownedReviveIndicator.gd")
	if script_res == null:
		return
	_indicador_desmaio = script_res.new() as Node2D
	_indicador_desmaio.name = "DownedReviveIndicator"
	add_child(_indicador_desmaio)


func _aplicar_customizacao_visual() -> void:
	# NOTA CHIBI: player.png ainda é 48×48 (legado). NPCs quality-pack são 96×96 (~64px corpo).
	# Regenerar player no Style Lock v2 é P0 de arte — escala 2× quebra AnimationPlayer (position tracks).
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite != null and PlayerData.character_colors.has("roupa"):
		var shader := load("res://assets/shaders/character_color_customizer.gdshader") as Shader
		if shader != null:
			var mat := ShaderMaterial.new()
			mat.shader = shader
			var cor_cabelo: Color = PlayerData.character_colors.get("cabelo", Color.BLACK)
			var cor_roupa: Color = PlayerData.character_colors.get("roupa", Color.GREEN)
			var cor_olhos: Color = PlayerData.character_colors.get("olhos", Color(0.15, 0.45, 0.85, 1.0))
			mat.set_shader_parameter("hair_custom_color", cor_cabelo)
			mat.set_shader_parameter("clothes_custom_color", cor_roupa)
			mat.set_shader_parameter("eyes_custom_color", cor_olhos)
			mat.set_shader_parameter("enable_eye_tint", 1.0)
			# Cabelos claros (Killua / loiros) precisam do modo light_hair
			var luminancia: float = (cor_cabelo.r + cor_cabelo.g + cor_cabelo.b) / 3.0
			mat.set_shader_parameter("light_hair_mode", 1.0 if luminancia > 0.55 else 0.0)
			sprite.material = mat

	_atualizar_overlay_aparencia()


func _atualizar_overlay_aparencia() -> void:
	var HairStyleOverlay = load("res://entities/character_creator/HairStyleOverlay.gd")
	if HairStyleOverlay == null:
		return
	var overlay := get_node_or_null("HairStyleOverlay") as Node2D
	if overlay == null:
		overlay = HairStyleOverlay.new()
		overlay.name = "HairStyleOverlay"
		overlay.z_index = 2
		add_child(overlay)
	if overlay.has_method("configurar"):
		overlay.configurar(
			str(PlayerData.character_colors.get("hair_id", "hair_gon_01")),
			PlayerData.character_colors.get("cabelo", Color(0.1, 0.1, 0.12, 1.0)),
			PlayerData.character_colors.get("olhos", Color(0.15, 0.45, 0.85, 1.0)),
			true
		)



var em_hit_flash: bool = false


func receber_dano(dano: int, direcao_ataque: Vector2 = Vector2.ZERO, _forca_knockback: float = 0.0, atacante: Node = null) -> void:
	if combat_system != null:
		combat_system.receber_dano(dano, direcao_ataque, 0.0, atacante)
	_aplicar_hit_flash()


## Dano já calculado pelo servidor dedicado — só feedback visual/local.
func receber_dano_rede(dano: int, direcao_ataque: Vector2 = Vector2.ZERO, _source_net_id: int = 0) -> void:
	_aplicar_hit_flash()
	if combat_system != null and combat_system.has_method("_executar_hit_flash"):
		combat_system._executar_hit_flash()
	if DamageNumberSystem != null and dano > 0:
		DamageNumberSystem.spawn_dano(global_position, dano, false)
	if dano > 0:
		velocity += direcao_ataque.normalized() * 120.0


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

	# Atualizar avanço físico de ataque (Attack Lunge / Dash de Golpe)
	if _attack_lunge_timer > 0.0:
		_attack_lunge_timer -= delta
		var progresso: float = clampf(1.0 - (_attack_lunge_timer / _attack_lunge_total), 0.0, 1.0)
		var fator_velocidade: float = 1.0 - (progresso * 0.75) # Ímpeto marcial rápido com desaceleração
		velocity = _attack_lunge_dir * (_attack_lunge_current_speed * fator_velocidade)
	elif _is_attacking:
		# Pós-avanço: pés firmes no chão para impacto e recuperação do golpe
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)

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
	_attack(delta)
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
				_attack_lunge_timer = 0.0
				velocity = dir * 220.0
				_gerar_efeito_poeira_passos(dir)
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

	# Se estiver executando o avanço de golpe (attack lunge) ou esquiva, não sobrescrever com o movimento padrão
	if _attack_lunge_timer > 0.0 or (combat_system != null and combat_system.esquivando):
		return

	if _is_attacking:
		# Pés firmes no chão para impacto e recuperação do golpe
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * get_physics_process_delta_time())
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


var _attack_charge_timer: float = 0.0


func _attack(delta: float = 0.016) -> void:
	if not combat_system.pode_atacar or combat_system.esquivando:
		_attack_charge_timer = 0.0
		return

	var quer_ataque_pesado_direto: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or (InputMap.has_action("heavy_attack") and Input.is_action_just_pressed("heavy_attack"))

	if quer_ataque_pesado_direto:
		_executar_golpe_pesado()
		return

	if Input.is_action_pressed("attack"):
		_attack_charge_timer += delta

	if Input.is_action_just_released("attack"):
		if _attack_charge_timer >= 0.35:
			_executar_golpe_pesado()
		else:
			_executar_golpe_normal()
		_attack_charge_timer = 0.0


func _executar_golpe_normal() -> void:
	if TutorialManager != null and TutorialManager.em_tutorial:
		TutorialManager.notificar_ataque_executado()

	_atualizar_attack_cooldown()
	_is_attacking = true
	_attack_anim_timer = min(combat_system.ataque_cooldown, 0.4)

	var direcao_ataque: Vector2 = _direcao_olhar
	var input_dir: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input_dir != Vector2.ZERO:
		direcao_ataque = input_dir.normalized()
		_direcao_olhar = direcao_ataque
	elif velocity != Vector2.ZERO:
		direcao_ataque = velocity.normalized()
		_direcao_olhar = direcao_ataque

	_animation_tree["parameters/attack/blend_position"] = direcao_ataque

	# 1. Iniciar avanço físico de ataque (Attack Lunge)
	if attack_lunge_enabled:
		_attack_lunge_total = attack_dash_duration
		_attack_lunge_timer = attack_dash_duration
		_attack_lunge_dir = direcao_ataque
		_attack_lunge_current_speed = attack_dash_speed
		velocity = _attack_lunge_dir * _attack_lunge_current_speed
		_gerar_efeito_poeira_passos(_attack_lunge_dir)

	# 2. Gerar onda de pressão de ar direcional (Wind Slash)
	_gerar_efeito_corte_ar(direcao_ataque, false)

	# 3. Disparar lógica de combate
	combat_system.tentar_atacar(direcao_ataque)
	_state_machine.travel("attack")

	# 4. Micro-shake de feedback de impacto
	if EventBus != null:
		var shake_trauma: float = 0.28 if combat_system != null and combat_system.combo_step == 2 else 0.12
		var shake_dur: float = 0.15 if combat_system != null and combat_system.combo_step == 2 else 0.08
		EventBus.camera_shake_requested.emit(shake_trauma, shake_dur)


func _executar_golpe_pesado() -> void:
	if TutorialManager != null and TutorialManager.em_tutorial:
		TutorialManager.notificar_ataque_executado()

	_is_attacking = true
	_attack_anim_timer = 0.60

	var direcao_ataque: Vector2 = _direcao_olhar
	var input_dir: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input_dir != Vector2.ZERO:
		direcao_ataque = input_dir.normalized()
		_direcao_olhar = direcao_ataque
	elif velocity != Vector2.ZERO:
		direcao_ataque = velocity.normalized()
		_direcao_olhar = direcao_ataque

	_animation_tree["parameters/attack/blend_position"] = direcao_ataque

	# 1. Iniciar avanço físico potente para o golpe pesado
	if attack_lunge_enabled:
		_attack_lunge_total = attack_dash_duration * 1.2
		_attack_lunge_timer = _attack_lunge_total
		_attack_lunge_dir = direcao_ataque
		_attack_lunge_current_speed = attack_dash_speed * 1.35
		velocity = _attack_lunge_dir * _attack_lunge_current_speed
		_gerar_efeito_poeira_passos(_attack_lunge_dir)

	# 2. Gerar onda de choque pesada de pressão do ar
	_gerar_efeito_corte_ar(direcao_ataque, true)

	# 3. Disparar lógica de combate pesado
	combat_system.tentar_ataque_pesado(direcao_ataque)
	_state_machine.travel("attack")

	# 4. Feedback de impacto reforçado
	if EventBus != null:
		EventBus.camera_shake_requested.emit(0.45, 0.22)


func _gerar_efeito_poeira_passos(dir: Vector2) -> void:
	var dust_cls = load("res://entities/effects/DashDustPuff.gd")
	if dust_cls != null:
		var dust = dust_cls.new()
		dust.setup(global_position, dir)
		if get_parent() != null:
			get_parent().add_child(dust)
		else:
			add_child(dust)


func _gerar_efeito_corte_ar(dir: Vector2, is_heavy: bool = false) -> void:
	var wave_cls = load("res://entities/effects/AirPressureWave.gd")
	if wave_cls != null:
		var wave = wave_cls.new()
		var cor_nen: Color = Color.TRANSPARENT
		if nen_system != null and nen_system.has_method("tecnica_ativa"):
			if nen_system.tecnica_ativa(NenSystem.Tecnica.KO):
				cor_nen = Color(1.0, 0.85, 0.2, 0.8) # Ko dourado
			elif nen_system.tecnica_ativa(NenSystem.Tecnica.REN):
				cor_nen = Color(0.3, 0.8, 1.0, 0.7) # Ren azul ciano
		if hatsu_system != null and hatsu_system.has_method("esta_godspeed") and hatsu_system.esta_godspeed():
			cor_nen = Color(0.4, 0.9, 1.0, 0.9) # Kanmuru elétrico

		var spawn_pos: Vector2 = global_position + (dir.normalized() * 16.0) + Vector2(0, -6)
		wave.setup(spawn_pos, dir, is_heavy, cor_nen)
		if get_parent() != null:
			get_parent().add_child(wave)
		else:
			add_child(wave)


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

	if _is_attacking or _esta_desmaiado:
		return


	if velocity.length() > 2:

		_state_machine.travel("walk")

		return


	_state_machine.travel("idle")


func _on_save_carregado(_slot: int) -> void:
	sincronizar_progresso()
	_atualizar_attack_cooldown()


func _on_nivel_alterado(_novo_nivel: int) -> void:
	sincronizar_progresso()
	_atualizar_attack_cooldown()


func obter_nivel() -> int:
	var xp_sys = get_node_or_null("XPSystem") as XPSystem
	if xp_sys != null:
		return xp_sys.obter_level()
	return int(PlayerData.attributes.get("nivel", 1))


func obter_xp() -> int:
	var xp_sys = get_node_or_null("XPSystem") as XPSystem
	if xp_sys != null:
		return xp_sys.obter_xp()
	return int(PlayerData.attributes.get("xp", 0))


func obter_xp_necessario() -> int:
	var xp_sys = get_node_or_null("XPSystem") as XPSystem
	if xp_sys != null:
		return xp_sys.obter_xp_necessario()
	return ProgressionConfig.calcular_xp_necessario(obter_nivel())


func sincronizar_progresso() -> void:
	var xp_sys = get_node_or_null("XPSystem") as XPSystem
	if xp_sys != null and xp_sys.has_method("sincronizar_com_player_data"):
		xp_sys.sincronizar_com_player_data()


# ============================================================
# CÂMERA & GAME FEEL (Fase J / polish MMORPG 2D)
# ============================================================

func configurar_limites_camera(limites: Rect2) -> void:
	if _camera == null:
		_camera = get_node_or_null("Camera2D") as Camera2D
	if _camera == null:
		return
	_camera.limit_left = int(limites.position.x)
	_camera.limit_top = int(limites.position.y)
	_camera.limit_right = int(limites.position.x + limites.size.x)
	_camera.limit_bottom = int(limites.position.y + limites.size.y)
	_camera.limit_enabled = true


func definir_zoom_camera(zoom: Vector2) -> void:
	if _camera == null:
		_camera = get_node_or_null("Camera2D") as Camera2D
	if _camera == null:
		return
	_camera.zoom = zoom


func _spawn_afterimage(tint: Color = Color(0.45, 0.85, 1.0, 0.45), lifetime: float = 0.22) -> void:
	## Trail de velocidade (Godspeed / dash) — sprite fantasma curto.
	var src: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
	if src == null or src.texture == null:
		return
	var ghost := Sprite2D.new()
	ghost.texture = src.texture
	ghost.hframes = src.hframes
	ghost.vframes = src.vframes
	ghost.frame = src.frame
	ghost.flip_h = src.flip_h
	ghost.modulate = tint
	ghost.z_index = z_index - 1
	ghost.global_position = global_position
	ghost.scale = scale
	var parent_n: Node = get_parent()
	if parent_n == null:
		return
	parent_n.add_child(ghost)
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, lifetime)
	tw.tween_callback(ghost.queue_free)


func _obter_tipo_chao() -> String:
	## Classificação simples de superfície sob os pés (áudio de passo / poeira).
	var space := get_world_2d().direct_space_state
	if space == null:
		return "default"
	var query := PhysicsPointQueryParameters2D.new()
	query.position = global_position + Vector2(0, 8)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1
	var hits: Array = space.intersect_point(query, 4)
	for hit in hits:
		var collider = hit.get("collider")
		if collider == null:
			continue
		var n := str(collider.name).to_lower()
		if "water" in n or "agua" in n or "rio" in n:
			return "water"
		if "sand" in n or "areia" in n:
			return "sand"
		if "grass" in n or "grama" in n or "floresta" in n:
			return "grass"
		if "stone" in n or "pedra" in n or "rock" in n or "dungeon" in n:
			return "stone"
		if "wood" in n or "madeira" in n or "floor" in n:
			return "wood"
	return "default"
