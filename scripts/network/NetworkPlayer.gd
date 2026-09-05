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


func _ready() -> void:
	add_to_group("remote_player")
	collision_layer = 0 # Não interfere na física local do jogador
	collision_mask = 0

	_construir_visual()
	_construir_nameplate_e_barras()


func _construir_visual() -> void:
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	var default_tex = load("res://assets/sprites/characters/player.png")
	if default_tex != null:
		sprite.texture = default_tex
		sprite.hframes = 4
		sprite.vframes = 4
		sprite.frame = 0
	add_child(sprite)

	aura_glow = AuraGlowEffectScript.new()
	aura_glow.name = "AuraGlowEffect"
	add_child(aura_glow)


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


func _physics_process(delta: float) -> void:
	# Interpolação suave em direção ao alvo (Hermite smoothing com fator 14.0)
	if target_position != Vector2.ZERO:
		global_position = global_position.lerp(target_position, clampf(14.0 * delta, 0.0, 1.0))

	# Orientação visual do sprite
	if sprite != null and facing_direction.x != 0.0:
		sprite.flip_h = (facing_direction.x < 0.0)
