extends Node

# Regressão: spawn do Exame Hunter deve ficar em área walkable.
# godot --headless --path . res://scratch/test_exame_spawn_walkable_suite.tscn

var _passed: int = 0
var _failed: int = 0


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  PASS: ", msg)
	else:
		_failed += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("\n========== TEST EXAME SPAWN WALKABLE ==========")
	await get_tree().process_frame
	var packed = load("res://world/maps/exame_maratona.tscn")
	var mapa: Node2D = packed.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout

	var spawn = mapa.get_node_or_null("SpawnDefault")
	_assert(spawn != null, "SpawnDefault existe")
	var pos: Vector2 = spawn.global_position if spawn else Vector2.ZERO
	_assert(abs(pos.y) <= 40.0, "spawn no corredor Y≈0 (pos=%s)" % str(pos))

	var kit = mapa.get_node_or_null("SagaTerritoryKit")
	_assert(kit != null, "SagaTerritoryKit anexado")
	var layer = kit.get_node_or_null("SagaTerritoryGround") if kit else null
	_assert(layer != null, "layer de territorio existe")
	if layer != null:
		_assert(layer.collision_enabled == false, "territorio sem collision physics")

	var body := CharacterBody2D.new()
	body.name = "ProbeBody"
	body.collision_layer = 1
	body.collision_mask = 0xFFFFFFFF
	var cs := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	cs.shape = shape
	body.add_child(cs)
	body.global_position = pos
	mapa.add_child(body)
	await get_tree().physics_frame
	await get_tree().physics_frame

	var space = body.get_world_2d().direct_space_state
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, pos)
	params.collision_mask = 0xFFFFFFFF
	params.collide_with_areas = false
	params.collide_with_bodies = true
	# Ignora o Player já embutido na cena do exame
	var exclude: Array[RID] = [body.get_rid()]
	for n in mapa.get_tree().get_nodes_in_group("player"):
		if n is CollisionObject2D:
			exclude.append((n as CollisionObject2D).get_rid())
		for c in n.get_children():
			if c is CollisionObject2D:
				exclude.append((c as CollisionObject2D).get_rid())
	params.exclude = exclude
	var hits = space.intersect_shape(params, 32)
	_assert(hits.is_empty(), "sem colisao de ambiente no spawn (hits=%d)" % hits.size())

	var x0 := body.global_position.x
	body.velocity = Vector2(220, 0)
	body.move_and_slide()
	_assert(body.global_position.x > x0 + 2.0, "consegue andar para a direita (x=%.1f)" % body.global_position.x)

	# Conta só slides contra ambiente (não player)
	var env_slides := 0
	for i in body.get_slide_collision_count():
		var col = body.get_slide_collision(i).get_collider()
		if col != null and not (col is CharacterBody2D) and not String(col.name).contains("Hurt"):
			env_slides += 1
	_assert(env_slides == 0, "sem slide ambiental no spawn")

	print("========== RESULTADO: %d ok / %d fail ==========" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)
