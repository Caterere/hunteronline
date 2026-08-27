extends ProgressBar

@export var enemy_system: EnemySystem

@onready var hp_label: Label = $HPLabel


func _ready() -> void:
	if enemy_system == null:
		enemy_system = get_parent().get_node_or_null("EnemySystem") as EnemySystem

	if hp_label != null:
		hp_label.anchor_left = 0.0
		hp_label.anchor_right = 1.0
		hp_label.anchor_top = 0.0
		hp_label.anchor_bottom = 1.0
		hp_label.offset_left = 0.0
		hp_label.offset_right = 0.0
		hp_label.offset_top = -2.0
		hp_label.offset_bottom = 0.0
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if enemy_system != null:
		atualizar(enemy_system.health, enemy_system.max_health)
		if not enemy_system.health_changed.is_connected(_on_health_changed):
			enemy_system.health_changed.connect(_on_health_changed)


func _on_health_changed(current_health: int, max_hp: int) -> void:
	atualizar(current_health, max_hp)


func atualizar(current_health: int, max_hp: int) -> void:
	max_value = max(1, max_hp)
	value = current_health
	if hp_label != null:
		hp_label.text = "%s/%s" % [_format_number(current_health), _format_number(max_hp)]


func _format_number(val: int) -> String:
	if val >= 1000000:
		return "%.1fM" % (float(val) / 1000000.0)
	elif val >= 10000:
		return "%.1fk" % (float(val) / 1000.0)
	elif val >= 1000:
		return "%.1fk" % (float(val) / 1000.0)
	return "%d" % val
