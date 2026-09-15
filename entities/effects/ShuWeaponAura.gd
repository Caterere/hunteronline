class_name ShuWeaponAura
extends Node2D

# ============================================================
# HUNTER ONLINE — SHU WEAPON AURA (VISUAL PASSIVO)
# ============================================================
# Aura violeta na arma equipada (slot mao_princ) quando Nen
# está despertado. Shu é passivo — não exige toggle.
# ============================================================

var _pulse: float = 0.0
var _ativo: bool = false
var _weapon_sprite: Polygon2D = null
var _glow: Sprite2D = null


func _ready() -> void:
	z_index = 3
	_construir_visual()
	if PlayerData != null and PlayerData.has_signal("atributos_recalculados"):
		if not PlayerData.atributos_recalculados.is_connected(_atualizar_estado):
			PlayerData.atributos_recalculados.connect(_atualizar_estado)
	_atualizar_estado()


func _construir_visual() -> void:
	_weapon_sprite = Polygon2D.new()
	_weapon_sprite.name = "ShuBlade"
	# Silhueta simples de lâmina (pixel-friendly)
	_weapon_sprite.polygon = PackedVector2Array([
		Vector2(2, -2), Vector2(14, -6), Vector2(16, -4),
		Vector2(6, 2), Vector2(2, 4), Vector2(0, 2),
	])
	_weapon_sprite.color = Color(0.75, 0.55, 1.0, 0.0)
	_weapon_sprite.position = Vector2(8, -6)
	add_child(_weapon_sprite)

	_glow = Sprite2D.new()
	_glow.name = "ShuGlow"
	# Glow via modulate em um retângulo pequeno via Polygon2D filho
	var glow_poly := Polygon2D.new()
	glow_poly.polygon = PackedVector2Array([
		Vector2(-4, -8), Vector2(18, -10), Vector2(20, 2), Vector2(-2, 6),
	])
	glow_poly.color = Color(0.55, 0.35, 0.95, 0.0)
	glow_poly.z_index = -1
	_glow.add_child(glow_poly)
	_glow.position = Vector2(8, -6)
	add_child(_glow)


func _process(delta: float) -> void:
	if not _ativo:
		return
	_pulse += delta * 3.2
	var a: float = 0.35 + sin(_pulse) * 0.15
	if _weapon_sprite != null:
		_weapon_sprite.color.a = a + 0.25
		# Espelha direção do player via CombatSystem ou velocity
		var body := get_parent() as Node2D
		if body != null:
			var dir_x: float = 0.0
			var cs = body.get_node_or_null("CombatSystem")
			if cs != null and "ultima_direcao" in cs:
				dir_x = cs.ultima_direcao.x
			elif body is CharacterBody2D:
				dir_x = (body as CharacterBody2D).velocity.x
			if dir_x < -0.1:
				_weapon_sprite.scale.x = -1.0
				_glow.scale.x = -1.0
			elif dir_x > 0.1:
				_weapon_sprite.scale.x = 1.0
				_glow.scale.x = 1.0
	if _glow != null and _glow.get_child_count() > 0:
		var gp := _glow.get_child(0) as Polygon2D
		if gp != null:
			gp.color.a = a * 0.55


func _atualizar_estado(_args = null) -> void:
	var tem_arma: bool = false
	if PlayerData != null:
		var arma: String = PlayerData.obter_equipado("mao_princ")
		tem_arma = not arma.is_empty() and PlayerData.despertou_nen
	_ativo = tem_arma
	visible = _ativo
	if not _ativo:
		if _weapon_sprite != null:
			_weapon_sprite.color.a = 0.0
		if _glow != null and _glow.get_child_count() > 0:
			var gp := _glow.get_child(0) as Polygon2D
			if gp != null:
				gp.color.a = 0.0
