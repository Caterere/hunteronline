class_name NetworkEnemyProxy
extends Node2D

# ============================================================
# HUNTER ONLINE — NETWORK ENEMY PROXY (VISUAL ONLY)
# ============================================================
#
# Representação cosmética de inimigos simulados no servidor dedicado.
# Sem EnemyAI / EnemySystem — só posição, HP e feedback de hit.
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

const SPRITE_BY_ENEMY_ID := {
	"lobo_nen": "res://assets/sprites/characters/enemy_lobo_sombras_8dir.png",
	"lobo_selva": "res://assets/sprites/characters/enemy_lobo_sombras_8dir.png",
	"fera_padokia": "res://assets/sprites/characters/enemy_phase4_fera_padokia_8dir.png",
	"quimera": "res://assets/sprites/characters/enemy_formiga_soldado_8dir.png",
	"sentinela": "res://assets/sprites/characters/enemy_sentinela_pedra_8dir.png",
}

var net_id: int = 0
var enemy_id: String = ""
var display_name: String = "Beast"
var target_position: Vector2 = Vector2.ZERO
var hp: int = 100
var hp_max: int = 100
var is_boss: bool = false
var ai_state: String = "IDLE"
var facing_x: float = 1.0

var sprite: Sprite2D = null
var lbl_name: Label = null
var hp_bar: ProgressBar = null
var _flash_timer: float = 0.0
var _base_modulate: Color = Color(1, 1, 1, 1)


func _ready() -> void:
	add_to_group("enemy_proxies")
	add_to_group("enemies") # permite targeting UX sem AI
	_construir_visual()
	_aplicar_sprite_por_id()


func _construir_visual() -> void:
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	add_child(sprite)

	var container := VBoxContainer.new()
	container.name = "OverheadUI"
	container.position = Vector2(-28, -34)
	container.custom_minimum_size = Vector2(56, 16)
	add_child(container)

	lbl_name = Label.new()
	lbl_name.text = display_name
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.add_theme_font_size_override("font_size", 4)
	lbl_name.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD if is_boss else Color(1.0, 0.7, 0.55))
	container.add_child(lbl_name)

	hp_bar = ProgressBar.new()
	hp_bar.max_value = hp_max
	hp_bar.value = hp
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size = Vector2(40, 2)
	container.add_child(hp_bar)


func _aplicar_sprite_por_id() -> void:
	if sprite == null:
		return
	var path: String = str(SPRITE_BY_ENEMY_ID.get(enemy_id, ""))
	if path.is_empty():
		# Fallback genérico
		path = "res://assets/sprites/characters/enemy_lobo_sombras_8dir.png"
	var tex = load(path)
	if tex == null:
		tex = load("res://assets/sprites/characters/player.png")
	if tex != null:
		sprite.texture = tex
		# Folhas 8dir típicas do projeto: 8 colunas x N linhas
		if path.find("_8dir") >= 0:
			sprite.hframes = 8
			sprite.vframes = max(1, int(tex.get_height() / max(1, int(tex.get_width() / 8))))
			sprite.frame = 0
		else:
			sprite.hframes = 4
			sprite.vframes = 4
			sprite.frame = 0
	_base_modulate = Color(1.0, 0.85, 0.75, 1.0) if not is_boss else Color(1.0, 0.55, 0.45, 1.0)
	sprite.modulate = _base_modulate


func aplicar_estado_snapshot(data: Dictionary) -> void:
	var prev_id := enemy_id
	target_position = Vector2(float(data.get("px", global_position.x)), float(data.get("py", global_position.y)))
	hp = int(data.get("hp", hp))
	hp_max = int(data.get("hp_max", hp_max))
	ai_state = str(data.get("state", ai_state))
	is_boss = bool(data.get("boss", is_boss))
	enemy_id = str(data.get("enemy_id", enemy_id))
	var vx: float = float(data.get("vx", 0.0))
	if absf(vx) > 1.0:
		facing_x = signf(vx)
		if sprite != null:
			sprite.flip_h = facing_x < 0.0
	var n = str(data.get("name", display_name))
	if not n.is_empty():
		display_name = n
	if lbl_name != null:
		lbl_name.text = display_name
	if hp_bar != null:
		hp_bar.max_value = max(1, hp_max)
		hp_bar.value = hp
	if enemy_id != prev_id and not enemy_id.is_empty():
		_aplicar_sprite_por_id()


func aplicar_hit_confirmado(damage: int, hp_remaining: int, is_dead: bool) -> void:
	hp = hp_remaining
	if hp_bar != null:
		hp_bar.value = hp
	_flash_timer = 0.12
	if sprite != null:
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)

	if CombatImpactEffect != null:
		CombatImpactEffect.spawn_slash(self, global_position, Vector2.RIGHT, Color(1.0, 0.9, 0.4))
	if EventBus != null:
		EventBus.emit_hitstop(0.05)
		EventBus.combat_hit_landed.emit(null, self, damage, false)

	if is_dead or hp <= 0:
		queue_free()


func _physics_process(delta: float) -> void:
	if target_position != Vector2.ZERO or global_position != Vector2.ZERO:
		global_position = global_position.lerp(target_position, clampf(12.0 * delta, 0.0, 1.0))

	# Idle animação leve nas folhas 8dir
	if sprite != null and sprite.hframes >= 8 and ai_state == "CHASE":
		sprite.frame = (sprite.frame + 1) % mini(8, sprite.hframes) if Engine.get_process_frames() % 6 == 0 else sprite.frame

	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0 and sprite != null:
			sprite.modulate = _base_modulate
