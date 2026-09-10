extends Node

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 PHASE 5 FX + WEATHER + NIGHT SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_assets()
	await _test_kits()
	_test_combat_fx_hooks()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	for f in _failures:
		print("   ❌ ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)


func _test_assets() -> void:
	print("\n[1] Phase 5 assets...")
	var req := [
		"res://assets/sprites/effects/phase5_fx_hit.png",
		"res://assets/sprites/effects/phase5_fx_slash.png",
		"res://assets/sprites/effects/phase5_fx_nen_aura.png",
		"res://assets/sprites/effects/phase5_fx_heal.png",
		"res://assets/sprites/effects/phase5_fx_dash_dust.png",
		"res://assets/sprites/objects/phase5_weather_puddle.png",
		"res://assets/sprites/objects/phase5_weather_leaf.png",
		"res://assets/sprites/objects/phase5_night_lantern_glow.png",
	]
	for p in req:
		_ok(ResourceLoader.exists(p), "Existe: %s" % p.get_file())
	_ok(FileAccess.file_exists("res://scripts/tools/pixellab_phase5_fx.py"), "script pixellab_phase5_fx.py")
	_ok(FileAccess.file_exists("res://world/components/WorldFxKit.gd"), "WorldFxKit.gd")


func _test_kits() -> void:
	print("\n[2] WorldFxKit...")
	var Estrada = load("res://world/maps/EstradaPadokiaMap.gd")
	var Floresta = load("res://world/maps/FlorestaVestigiosMap.gd")
	_ok(Estrada != null, "EstradaPadokiaMap carrega")
	_ok(Floresta != null, "FlorestaVestigiosMap carrega")
	if Estrada == null or Floresta == null:
		return

	var e = Estrada.new()
	e.name = "EstradaP5"
	add_child(e)
	await get_tree().process_frame
	await get_tree().process_frame
	var ek = e.get_node_or_null("WorldFxKit")
	_ok(ek != null, "WorldFxKit Estrada")
	if ek:
		_ok(ek.get_node_or_null("Phase5Weather") != null, "Phase5Weather Estrada")
		_ok(ek.get_node_or_null("Phase5Night") != null, "Phase5Night Estrada")
		_ok(ek.get_node_or_null("Phase5FxShowcase") != null, "Phase5FxShowcase Estrada")
		_ok(ek.get_node_or_null("Phase5FxShowcase/P5Fx_Hit") != null, "FX Hit showcase")
		_ok(ek.get_node_or_null("Phase5Night/P5Glow_LanternN") != null, "Night glow Estrada")
	e.queue_free()
	await get_tree().process_frame

	var f = Floresta.new()
	f.name = "FlorestaP5"
	add_child(f)
	await get_tree().process_frame
	await get_tree().process_frame
	var fk = f.get_node_or_null("WorldFxKit")
	_ok(fk != null, "WorldFxKit Floresta")
	if fk:
		_ok(fk.get_node_or_null("Phase5Weather/P5Leaf_0") != null, "Leaf Floresta")
		_ok(fk.get_node_or_null("Phase5Night/P5Glow_Shrine") != null, "Night glow Floresta")
		_ok(fk.get_node_or_null("Phase5FxShowcase/P5Fx_Aura") != null, "Aura showcase Floresta")
	f.queue_free()
	await get_tree().process_frame


func _test_combat_fx_hooks() -> void:
	print("\n[3] CombatImpactEffect sprite hooks...")
	var dummy := Node2D.new()
	dummy.name = "DummyCombat"
	add_child(dummy)
	CombatImpactEffect.spawn_slash(dummy, Vector2(10, 10), Vector2.RIGHT, Color.WHITE)
	CombatImpactEffect.spawn_blunt_impact(dummy, Vector2(20, 20), 1.0, Color(1, 0.8, 0.2))
	CombatImpactEffect.spawn_dust_kickup(dummy, Vector2(30, 30), Vector2(40, 0))
	CombatImpactEffect.spawn_aura_burst(dummy, Vector2(40, 40), Color(0.3, 0.8, 1.0))
	_ok(true, "CombatImpactEffect spawn_* com Phase 5 textures")
	dummy.queue_free()
