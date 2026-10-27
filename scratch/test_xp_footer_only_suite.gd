extends Node
## XP só no footer (sem barra ornamentada no card) + tamanho reduzido
var _ok := 0
var _fail := 0

func _ready() -> void:
	print("=== XP FOOTER ONLY / RESIZE ===")
	var src := FileAccess.get_file_as_string("res://ui/hud/PlayerHUD.gd")
	_assert("var xp_box := _criar_barra_framed" not in src, "card sem barra XP ornamentada")
	_assert("XpFooterBar" in src, "footer presente")
	_assert("offset_left = -144.0" in src and "offset_right = 144.0" in src, "comprimento -10% (±144)")
	_assert("offset_top = -68.0" in src and "offset_bottom = -50.0" in src, "footer acima do hotbar Hatsu")
	_assert("Vector2(270, 8)" in src, "fill 270×8 (-10% / -15%)")

	var hud_scene: PackedScene = load("res://ui/hud/HUD.tscn")
	_assert(hud_scene != null, "HUD.tscn carrega")
	if hud_scene != null:
		var hud: Node = hud_scene.instantiate()
		add_child(hud)
		await get_tree().process_frame
		_assert(hud.get("bar_xp") == null, "runtime bar_xp null")
		_assert(hud.get("bar_xp_footer") != null, "runtime bar_xp_footer ok")
		var footer: Control = hud.get_node_or_null("XpFooterBar") as Control
		_assert(footer != null, "nó XpFooterBar na árvore")
		if footer != null:
			var w: float = footer.offset_right - footer.offset_left
			var h: float = footer.offset_bottom - footer.offset_top
			_assert(is_equal_approx(w, 288.0), "footer width 288 (got %.0f)" % w)
			_assert(is_equal_approx(h, 18.0), "footer height 18 (got %.0f)" % h)
			_assert(footer.offset_bottom <= -48.0, "footer acima dos slots Hatsu (bottom %.0f)" % footer.offset_bottom)
		hud.queue_free()

	print("Resultado: %d/%d | falhas %d" % [_ok, _ok + _fail, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)

func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✅ ", msg)
	else:
		_fail += 1
		print("  ❌ ", msg)
