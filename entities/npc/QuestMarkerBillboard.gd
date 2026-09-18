class_name QuestMarkerBillboard
extends Node2D

# ============================================================
# HUNTER ONLINE — QUEST MARKER (mini "?" stylized)
# ============================================================
# Indicador pequeno acima do NPC quando há quest / objetivo / entrega.
# Estados: offer (!) disponível · objective (?) falar/agir · turn_in (✓ pronto)
# ============================================================

enum Kind { NONE, OFFER, OBJECTIVE, TURN_IN }

var kind: Kind = Kind.NONE
var _bob_t: float = 0.0
var _base_y: float = -34.0


func _ready() -> void:
	z_index = 20
	position = Vector2(0, _base_y)
	set_process(true)
	queue_redraw()


func set_kind(novo: Kind) -> void:
	if kind == novo:
		return
	kind = novo
	visible = kind != Kind.NONE
	queue_redraw()


func _process(delta: float) -> void:
	if kind == Kind.NONE:
		return
	_bob_t += delta * 2.4
	position.y = _base_y + sin(_bob_t) * 2.0
	queue_redraw()


func _draw() -> void:
	if kind == Kind.NONE:
		return
	var cor_borda := Color(0.22, 0.14, 0.06, 0.95)
	var cor_fill := Color(1.0, 0.86, 0.28, 0.95)
	var glyph := "?"
	match kind:
		Kind.OFFER:
			cor_fill = Color(1.0, 0.82, 0.22, 0.96)
			glyph = "!"
		Kind.OBJECTIVE:
			cor_fill = Color(0.55, 0.85, 1.0, 0.96)
			glyph = "?"
		Kind.TURN_IN:
			cor_fill = Color(0.45, 0.95, 0.55, 0.96)
			glyph = "!"
		_:
			pass

	# Cápsula minúscula (estilo MMO clássico, sem card pesado)
	var r := Rect2(-5.5, -11.0, 11.0, 14.0)
	draw_rect(r.grow(1.0), cor_borda, true)
	draw_rect(r, cor_fill, true)
	# Ponteirinho
	var tip := PackedVector2Array([Vector2(-3, 3), Vector2(3, 3), Vector2(0, 7)])
	draw_colored_polygon(tip, cor_fill)
	draw_polyline(PackedVector2Array([Vector2(-3, 3), Vector2(0, 7), Vector2(3, 3)]), cor_borda, 1.0)

	var font := ThemeDB.fallback_font
	if font != null:
		var fs := 8
		var sz := font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		draw_string(font, Vector2(-sz.x * 0.5, -1.0), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.18, 0.10, 0.04, 1.0))
