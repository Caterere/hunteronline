class_name EnemyNameplate
extends Node2D

# Name + thin HP bar above enemy (world-space HUD).

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

const Y_OFFSET: float = -34.0
const BAR_W: float = 48.0
const BAR_H: float = 4.0

var _enemy_system: EnemySystem = null
var _root: Control = null
var _lbl_name: Label = null
var _hp_bar: ProgressBar = null


func _ready() -> void:
	z_index = 30
	_enemy_system = _resolver_enemy_system()
	_construir_ui()
	if _enemy_system != null:
		if not _enemy_system.health_changed.is_connected(_on_health_changed):
			_enemy_system.health_changed.connect(_on_health_changed)
		_atualizar_nome()
		_on_health_changed(_enemy_system.health, _enemy_system.max_health)
		if not _enemy_system.died.is_connected(_on_enemy_died):
			_enemy_system.died.connect(_on_enemy_died)


func _resolver_enemy_system() -> EnemySystem:
	var parent_body := get_parent()
	if parent_body == null:
		return null
	for child in parent_body.get_children():
		if child is EnemySystem:
			return child as EnemySystem
	return null


func _construir_ui() -> void:
	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.custom_minimum_size = Vector2(BAR_W, 22.0)
	_root.position = Vector2(-BAR_W * 0.5, Y_OFFSET)
	add_child(_root)

	_lbl_name = Label.new()
	_lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_name.custom_minimum_size = Vector2(BAR_W, 10.0)
	_lbl_name.position = Vector2(0, 0)
	HunterUIStyle.aplicar_fonte_pixel(_lbl_name, 6, HunterUIStyle.COLOR_GLASS_TEXT)
	_lbl_name.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_lbl_name.add_theme_constant_override("shadow_offset_x", 1)
	_lbl_name.add_theme_constant_override("shadow_offset_y", 1)
	_root.add_child(_lbl_name)

	_hp_bar = ProgressBar.new()
	_hp_bar.show_percentage = false
	_hp_bar.custom_minimum_size = Vector2(BAR_W, BAR_H)
	_hp_bar.position = Vector2(0, 12.0)
	_hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	HunterUIStyle.aplicar_estilo_progress_bar(_hp_bar, HunterUIStyle.COLOR_HP_CRIMSON)
	_root.add_child(_hp_bar)


func _atualizar_nome() -> void:
	if _lbl_name == null or _enemy_system == null:
		return
	var nome: String = _enemy_system.enemy_name
	var cor_nome: Color = HunterUIStyle.COLOR_GLASS_TEXT
	if _enemy_system.is_boss:
		cor_nome = HunterUIStyle.COLOR_GOLD_LIGHT
	elif _enemy_system.enemy_data != null and _enemy_system.enemy_data.is_elite:
		cor_nome = HunterUIStyle.COLOR_AURA_CYAN
	_lbl_name.text = nome
	_lbl_name.add_theme_color_override("font_color", cor_nome)


func _on_health_changed(current: int, max_hp: int) -> void:
	if _hp_bar == null:
		return
	_hp_bar.max_value = maxi(1, max_hp)
	_hp_bar.value = clampi(current, 0, max_hp)
	if current <= 0:
		visible = false


func _on_enemy_died(_tipo: StringName) -> void:
	visible = false
