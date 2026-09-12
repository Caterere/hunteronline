class_name NpcSheetAnimator
extends Node

# ============================================================
# Anima idle/walk a partir das folhas quality-pack (*_idle_8xN / *_walk_8xN).
# Colunas = 8 direções; linhas = frames da animação.
# ============================================================

var sprite: Sprite2D
var asset_id: String = ""
var idle_tex: Texture2D
var walk_tex: Texture2D
var frame_w: int = 96
var frame_h: int = 96
var cols: int = 8
var idle_rows: int = 1
var walk_rows: int = 1
var dir_index: int = 0 # 0=S ... clockwise quality-pack
var anim_name: String = "idle"
var frame_timer: float = 0.0
var frame_index: int = 0
var fps: float = 8.0
var body: Node = null


func setup(p_sprite: Sprite2D, p_asset_id: String, p_body: Node = null) -> void:
	sprite = p_sprite
	asset_id = p_asset_id
	body = p_body
	var idle_path := "res://assets/sprites/characters/%s_idle_8xN.png" % asset_id
	var walk_path := "res://assets/sprites/characters/%s_walk_8xN.png" % asset_id
	if ResourceLoader.exists(idle_path):
		idle_tex = load(idle_path)
	if ResourceLoader.exists(walk_path):
		walk_tex = load(walk_path)
	if idle_tex != null:
		idle_rows = max(1, int(idle_tex.get_height() / float(frame_h)))
	if walk_tex != null:
		walk_rows = max(1, int(walk_tex.get_height() / float(frame_h)))
	_aplicar_folha(false)


func _process(delta: float) -> void:
	if sprite == null or not is_instance_valid(sprite):
		return
	var moving := false
	var dir := Vector2.DOWN
	if body != null and is_instance_valid(body):
		if body.get("velocity") != null:
			var vel: Vector2 = body.velocity
			moving = vel.length() > 8.0
			if moving:
				dir = vel
		elif body.has_method("get_move_direction"):
			dir = body.get_move_direction()
			moving = dir.length() > 0.1
	_atualizar_direcao(dir)
	var want := "walk" if moving and walk_tex != null else "idle"
	if want != anim_name:
		anim_name = want
		frame_index = 0
		frame_timer = 0.0
		_aplicar_folha(moving)
	var rows: int = walk_rows if anim_name == "walk" else idle_rows
	frame_timer += delta * fps
	if frame_timer >= 1.0:
		frame_timer = 0.0
		frame_index = (frame_index + 1) % max(rows, 1)
		_aplicar_frame()


func _atualizar_direcao(dir: Vector2) -> void:
	if dir.length() < 0.1:
		return
	# Mapeamento aproximado 8 dir quality-pack: S, SE, E, NE, N, NW, W, SW
	var ang := dir.angle() # -PI..PI, 0 = east
	# Converter para índice com south=0
	var deg := rad_to_deg(ang)
	# Godot: 90=south-ish depending on y-down. y+ is down.
	# angle: 0 east, PI/2 south, ±PI west, -PI/2 north
	var idx := 2 # east default
	if deg >= -22.5 and deg < 22.5:
		idx = 2 # E
	elif deg >= 22.5 and deg < 67.5:
		idx = 1 # SE
	elif deg >= 67.5 and deg < 112.5:
		idx = 0 # S
	elif deg >= 112.5 and deg < 157.5:
		idx = 7 # SW
	elif deg >= 157.5 or deg < -157.5:
		idx = 6 # W
	elif deg >= -157.5 and deg < -112.5:
		idx = 5 # NW
	elif deg >= -112.5 and deg < -67.5:
		idx = 4 # N
	elif deg >= -67.5 and deg < -22.5:
		idx = 3 # NE
	dir_index = idx


func _aplicar_folha(moving: bool) -> void:
	if sprite == null:
		return
	var tex: Texture2D = walk_tex if moving and walk_tex != null else idle_tex
	if tex == null:
		return
	sprite.texture = tex
	var rows: int = walk_rows if moving and walk_tex != null else idle_rows
	sprite.hframes = cols
	sprite.vframes = max(rows, 1)
	sprite.position = Vector2(0, -34)
	_aplicar_frame()


func _aplicar_frame() -> void:
	if sprite == null:
		return
	var rows: int = sprite.vframes
	var f: int = clampi(dir_index, 0, cols - 1) + clampi(frame_index, 0, max(rows - 1, 0)) * cols
	sprite.frame = clampi(f, 0, cols * rows - 1)
