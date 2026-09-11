class_name NetworkPlayer
extends CharacterBody2D

# ============================================================
# HUNTER ONLINE — NETWORK PLAYER (REMOTE PUPPET REPRESENTATION)
# ============================================================
#
# Entidade visual no mundo que espelha os movimentos, combate,
# técnicas de Nen e status de outros Caçadores conectados.
# Utiliza interpolação com amortecimento suave para eliminar jitter.
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")
const AuraGlowEffectScript = preload("res://entities/effects/AuraGlowEffect.gd")
const PlayerNetworkState = preload("res://scripts/network/PlayerNetworkState.gd")

var peer_id: int = 0
var character_name: String = "Hunter"
var target_position: Vector2 = Vector2.ZERO
var target_velocity: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN

var sprite: Sprite2D = null
var aura_glow: Node2D = null
var lbl_nameplate: Label = null
var hp_bar: ProgressBar = null
var aura_bar: ProgressBar = null

var hp: int = 100
var hp_max: int = 100
var aura: float = 100.0
var aura_max: float = 100.0
var current_nen_mode: String = ""
var is_downed: bool = false
var _downed_indicator: Node2D = null
var _death_anim_elapsed: float = 0.0
const _DEATH_FRAMES: Array[int] = [57, 58, 59]


func _ready() -> void:
	add_to_group("remote_player")
	collision_layer = 0 # Não interfere na física local do jogador
	collision_mask = 0

	_construir_visual()
	_construir_nameplate_e_barras()


func _construir_visual() -> void:
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.position = Vector2(-0.5, -17)
	var default_tex = load("res://assets/sprites/characters/player.png")
	if default_tex != null:
		sprite.texture = default_tex
		sprite.hframes = 6
		sprite.vframes = 10
		sprite.frame = 0
	add_child(sprite)

	aura_glow = AuraGlowEffectScript.new()
	aura_glow.name = "AuraGlowEffect"
	add_child(aura_glow)

	var ind_script = load("res://entities/Player/components/DownedReviveIndicator.gd")
	if ind_script != null:
		_downed_indicator = ind_script.new()
		_downed_indicator.name = "DownedReviveIndicator"
		add_child(_downed_indicator)


func _construir_nameplate_e_barras() -> void:
	var container := VBoxContainer.new()
	container.name = "OverheadUI"
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.position = Vector2(-30, -36)
	container.custom_minimum_size = Vector2(60, 20)
	add_child(container)

	lbl_nameplate = Label.new()
	lbl_nameplate.text = character_name
	lbl_nameplate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_nameplate.add_theme_font_size_override("font_size", 4)
	lbl_nameplate.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	container.add_child(lbl_nameplate)

	hp_bar = ProgressBar.new()
	hp_bar.max_value = 100
	hp_bar.value = 100
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size = Vector2(40, 2)
	container.add_child(hp_bar)

	aura_bar = ProgressBar.new()
	aura_bar.max_value = 100
	aura_bar.value = 100
	aura_bar.show_percentage = false
	aura_bar.custom_minimum_size = Vector2(40, 2)
	container.add_child(aura_bar)


func aplicar_estado_rede(state: PlayerNetworkState) -> void:
	if state == null:
		return

	target_position = state.position
	target_velocity = state.velocity
	facing_direction = state.facing

	hp = state.hp
	hp_max = state.hp_max
	aura = state.aura
	aura_max = state.aura_max

	if lbl_nameplate != null:
		lbl_nameplate.text = "%s [Lv. %d]" % [state.character_name, state.level]

	if hp_bar != null:
		hp_bar.max_value = hp_max
		hp_bar.value = hp

	if aura_bar != null:
		aura_bar.max_value = aura_max
		aura_bar.value = aura

	if current_nen_mode != state.active_nen:
		current_nen_mode = state.active_nen
		if aura_glow != null and aura_glow.has_method("aplicar_modo_tecnica"):
			aura_glow.aplicar_modo_tecnica(current_nen_mode)


func aplicar_estado_snapshot(p_data: Dictionary) -> void:
	if is_downed:
		# Mantém corpo no chão; ainda atualiza HP para UI
		hp = int(p_data.get("hp", hp))
		if hp_bar != null:
			hp_bar.value = hp
		return
	target_position = Vector2(float(p_data.get("px", global_position.x)), float(p_data.get("py", global_position.y)))
	target_velocity = Vector2(float(p_data.get("vx", 0.0)), float(p_data.get("vy", 0.0)))
	facing_direction = Vector2(float(p_data.get("fx", 0.0)), float(p_data.get("fy", 1.0)))

	hp = int(p_data.get("hp", hp))
	hp_max = int(p_data.get("hp_max", hp_max))
	aura = float(p_data.get("aura", aura))

	if hp_bar != null:
		hp_bar.max_value = hp_max
		hp_bar.value = hp

	var nen = str(p_data.get("nen", ""))
	if current_nen_mode != nen:
		current_nen_mode = nen
		if aura_glow != null and aura_glow.has_method("aplicar_modo_tecnica"):
			aura_glow.aplicar_modo_tecnica(current_nen_mode)


func set_downed(downed: bool, corpse_pos: Vector2 = Vector2.ZERO) -> void:
	is_downed = downed
	if downed:
		if corpse_pos != Vector2.ZERO:
			global_position = corpse_pos
			target_position = corpse_pos
		_death_anim_elapsed = 0.0
		if sprite != null:
			sprite.frame = _DEATH_FRAMES[0]
			sprite.modulate = Color(0.85, 0.75, 0.75, 1.0)
		if _downed_indicator != null and _downed_indicator.has_method("show_for_ally"):
			_downed_indicator.call("show_for_ally", true)
		if hp_bar != null:
			hp_bar.value = 0
	else:
		if sprite != null:
			sprite.frame = 0
			sprite.modulate = Color.WHITE
		if _downed_indicator != null and _downed_indicator.has_method("hide_prompt"):
			_downed_indicator.call("hide_prompt")


func _physics_process(delta: float) -> void:
	if is_downed:
		_death_anim_elapsed += delta
		if sprite != null:
			# 3 frames nos primeiros 0.45s, depois segura o último
			var idx: int = mini(2, int(_death_anim_elapsed / 0.15))
			sprite.frame = _DEATH_FRAMES[idx]
		return

	# Interpolação suave em direção ao alvo (Hermite smoothing com fator 14.0)
	if target_position != Vector2.ZERO:
		global_position = global_position.lerp(target_position, clampf(14.0 * delta, 0.0, 1.0))

	# Orientação visual do sprite
	if sprite != null and facing_direction.x != 0.0:
		sprite.flip_h = (facing_direction.x < 0.0)
