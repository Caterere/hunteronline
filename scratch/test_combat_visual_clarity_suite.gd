extends Node

# godot --headless --path . res://scratch/test_combat_visual_clarity_suite.tscn

const ComicBalloonScript = preload("res://scripts/ui/ComicBalloon.gd")

var _pass := 0
var _fail := 0


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("\n=== test_combat_visual_clarity_suite ===")
	await _test_dns_clarity()
	_test_comic_suppress_enemies()
	_test_combat_system_heavy_no_arc()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_dns_clarity() -> void:
	print("-- DamageNumberSystem clarity --")
	assert_test(DamageNumberSystem != null, "DamageNumberSystem autoload")
	assert_test(DamageNumberSystem.COMBAT_CLARITY == true, "COMBAT_CLARITY ligado")
	var src := FileAccess.get_file_as_string("res://autoload/DamageNumberSystem.gd")
	assert_test('texto = "-%d"' in src or 'texto: String = "-%d"' in src, "dano limpo só -N")
	assert_test("if COMBAT_CLARITY:" in src and "spawn_xp" in src, "spawn_xp gated")
	assert_test("force_show" in src, "spawn_texto tem force_show para dano")

	# Runtime: spawn_xp não cria Label no mundo
	var before := _count_labels()
	DamageNumberSystem.spawn_xp(Vector2(40, 40), 99)
	DamageNumberSystem.spawn_jenny(Vector2(40, 40), 50)
	DamageNumberSystem.spawn_esquiva(Vector2(40, 40))
	DamageNumberSystem.spawn_texto(Vector2(40, 40), "IMPACTO PESADO!", Color.YELLOW)
	await get_tree().process_frame
	var after_spam := _count_labels()
	assert_test(after_spam == before, "XP/Jenny/esquiva/tático não spawnam Label")

	DamageNumberSystem.spawn_dano(Vector2(80, 80), 42, true)
	await get_tree().process_frame
	var after_dmg := _count_labels()
	assert_test(after_dmg > before, "dano ainda spawna Label")
	# Limpa floats
	for c in get_tree().current_scene.get_children() if get_tree().current_scene else []:
		if c is Node2D and c.get_child_count() > 0:
			var lbl = c.get_child(0)
			if lbl is Label and str(lbl.text).begins_with("-"):
				c.queue_free()


func _count_labels() -> int:
	var n := 0
	var root := get_tree().current_scene if get_tree().current_scene else get_tree().root
	n += _count_labels_under(root)
	return n


func _count_labels_under(node: Node) -> int:
	var n := 0
	if node is Label:
		n += 1
	for c in node.get_children():
		n += _count_labels_under(c)
	return n


func _test_comic_suppress_enemies() -> void:
	print("-- ComicBalloon suppress on enemies --")
	assert_test(ComicBalloonScript.suppress_on_enemies == true, "suppress_on_enemies default true")
	var enemy := CharacterBody2D.new()
	enemy.name = "DummyEnemy"
	enemy.add_to_group("enemies")
	var es := Node.new()
	es.name = "EnemySystem"
	enemy.add_child(es)
	add_child(enemy)
	var balloon = ComicBalloonScript.mostrar(enemy, "FRASE DE COMBATE!", 1.0)
	assert_test(balloon == null, "balão em inimigo é suprimido")
	var npc := CharacterBody2D.new()
	npc.name = "DummyNPC"
	add_child(npc)
	var balloon_npc = ComicBalloonScript.mostrar(npc, "Olá Hunter!", 0.4)
	assert_test(balloon_npc != null, "balão em NPC/não-inimigo ainda funciona")
	if balloon_npc != null:
		balloon_npc.queue_free()
	enemy.queue_free()
	npc.queue_free()


func _test_combat_system_heavy_no_arc() -> void:
	print("-- heavy sem arco/círculo --")
	var src := FileAccess.get_file_as_string("res://scripts/combat/CombatSystem.gd")
	assert_test("IMPACTO PESADO" not in src or "Sem arco/círculo dourado no heavy" in src, "sem float IMPACTO PESADO no heavy")
	assert_test("tentar_ataque_pesado" in src, "heavy path existe")
	# O windup do heavy não chama mais spawn_swing_arc
	var heavy_fn_start := src.find("func tentar_ataque_pesado")
	var heavy_fn_end := src.find("func solicitar_heavy_buffer", heavy_fn_start)
	assert_test(heavy_fn_start >= 0 and heavy_fn_end > heavy_fn_start, "localizou tentar_ataque_pesado")
	if heavy_fn_start >= 0 and heavy_fn_end > heavy_fn_start:
		var heavy_body := src.substr(heavy_fn_start, heavy_fn_end - heavy_fn_start)
		assert_test("spawn_swing_arc" not in heavy_body, "heavy windup sem spawn_swing_arc")
		assert_test("IMPACTO PESADO" not in heavy_body, "heavy windup sem texto IMPACTO PESADO")
	assert_test("not is_heavy_attack and combo_step == 2" in src, "arco fino só no finisher leve")
