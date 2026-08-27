class_name Hurtbox
extends Area2D

var owner_entity: Node = null


func _ready() -> void:
	owner_entity = get_parent()


func receber_dano(dano: int, direcao: Vector2 = Vector2.ZERO, forca: float = 100.0, atacante: Node = null) -> void:
	var enemy = get_parent()
	if enemy != null:
		var sys = enemy.get_node_or_null("EnemySystem")
		if sys != null and sys.has_method("take_damage"):
			sys.take_damage(dano, direcao, forca, atacante)
		elif enemy.has_method("receber_dano"):
			enemy.receber_dano(dano, direcao, forca, atacante)
