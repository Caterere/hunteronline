extends Node2D

@export var duration: float = 0.75
@export var move_distance: float = 32.0

@onready var label: Label = $Label


func mostrar_dano(dano: int, tipo: String = "fisico", is_crit: bool = false) -> void:
	if label == null:
		label = get_node_or_null("Label") as Label
	if label == null:
		return

	var offset_x: float = randf_range(-16.0, 16.0)
	var scale_alvo: Vector2 = Vector2.ONE
	var cor_texto: Color = Color.WHITE

	if is_crit:
		label.text = "💥 %d!" % dano
		cor_texto = Color(1.0, 0.85, 0.2, 1.0) # Ouro / Crítico de Ko
		scale_alvo = Vector2(1.35, 1.35)
	elif tipo == "ten_mitigado":
		label.text = "🛡️ -%d" % dano
		cor_texto = Color(0.4, 0.85, 1.0, 1.0) # Ciano / Mitigação Ten
	elif tipo == "cura":
		label.text = "+%d" % dano
		cor_texto = Color(0.2, 1.0, 0.4, 1.0) # Verde / Zetsu Cura
	elif tipo == "dodge":
		label.text = "💨 MISS"
		cor_texto = Color(0.8, 0.8, 0.9, 0.8)
	elif tipo == "hatsu":
		label.text = "🌀 -%d" % dano
		cor_texto = Color(0.8, 0.4, 1.0, 1.0) # Púrpura / Hatsu
	else:
		label.text = "-%d" % dano
		cor_texto = Color(1.0, 0.35, 0.35, 1.0) if dano > 20 else Color.WHITE

	label.add_theme_color_override("font_color", cor_texto)

	scale = Vector2(0.5, 0.5)
	var tween := create_tween()
	var posicao_final := position + Vector2(offset_x, -move_distance)

	# Efeito de 'Pop-in' elástico seguido de flutuação suave
	tween.set_parallel(true)
	tween.tween_property(self, "position", posicao_final, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", scale_alvo, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, duration * 0.4).set_delay(duration * 0.6)

	await tween.finished
	queue_free()
