extends Node2D

# ============================================================
# HUNTER ONLINE — ZETSU AMBUSH + ARENA DENSITY SMOKE SUITE
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 ZETSU AMBUSH + ARENA DENSITY SMOKE")
	print("================================================================================")
	await get_tree().process_frame
	await _run_all()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d (%.0f%%)" % [
		_passed, _total, 100.0 * float(_passed) / float(maxi(_total, 1))
	])
	if not _failures.is_empty():
		print("❌ FALHAS:")
		for f in _failures:
			print("   - ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ [PASS] ", label)
	else:
		_failures.append(label)
		print("  ❌ [FAIL] ", label)


func _run_all() -> void:
	await _test_floresta_zetsu_zones()
	await _test_zetsu_ambush_fail_spawns()
	await _test_zetsu_stealth_pass()
	_test_zetsu_instinctive_before_awakening()
	await _test_ravina_zetsu_wiring()
	await _test_arena_density()


func _test_floresta_zetsu_zones() -> void:
	print("\n[TESTE 1] Floresta: zonas Zetsu + marcador + enemy_id...")
	var scn := load("res://world/maps/floresta_vestigios.tscn") as PackedScene
	_ok(scn != null, "floresta_vestigios.tscn carrega")
	if scn == null:
		return
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	var z1 = mapa.get_node_or_null("ZetsuAcampamentoNorte")
	var z2 = mapa.get_node_or_null("ZetsuClareiraLeste")
	_ok(z1 != null and z1 is ZetsuSensorZone, "ZetsuAcampamentoNorte existe")
	_ok(z2 != null and z2 is ZetsuSensorZone, "ZetsuClareiraLeste existe")
	if z1 != null:
		_ok(z1.get_node_or_null("ZetsuHintLabel") != null, "Marcador visual no acampamento")
		_ok(String(z1.enemy_id) != "slime" and String(z1.enemy_id).length() > 0, "enemy_id temático no acampamento")
	if z2 != null:
		_ok(z2.enemy_id == &"lobo_sombras", "Clareira usa lobo_sombras")

	mapa.queue_free()
	await get_tree().process_frame


func _test_zetsu_ambush_fail_spawns() -> void:
	print("\n[TESTE 2] Falha sem Zetsu spawna emboscada...")
	var zona := ZetsuSensorZone.new()
	zona.name = "ZetsuSmokeFail"
	zona.zone_id = &"smoke_fail"
	zona.zone_name = "Zona Smoke"
	zona.enemy_id = &"lobo_sombras"
	zona.enemy_name = "Fera Smoke"
	zona.mostrar_marcador = true
	zona.spawn_inimigos_ao_falhar = true
	zona.position = Vector2(100, 100)
	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(80, 80)
	col.shape = box
	zona.add_child(col)
	add_child(zona)
	await get_tree().process_frame

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.collision_layer = 2
	add_child(player)
	player.global_position = zona.global_position
	await get_tree().process_frame

	zona._on_body_entered(player)
	await get_tree().process_frame

	_ok(zona.falhou_stealth == true, "falhou_stealth=true sem Zetsu")
	var embush_count := 0
	for c in get_children():
		if str(c.name).begins_with("Emboscada_smoke_fail"):
			embush_count += 1
	_ok(embush_count >= 3, "3 emboscadores spawnados (%d)" % embush_count)

	player.queue_free()
	zona.queue_free()
	for c in get_children():
		if str(c.name).begins_with("Emboscada_"):
			c.queue_free()
	await get_tree().process_frame


func _test_zetsu_stealth_pass() -> void:
	print("\n[TESTE 3] Travessia com Zetsu não falha...")
	var zona := ZetsuSensorZone.new()
	zona.name = "ZetsuSmokePass"
	zona.zone_id = &"smoke_pass"
	zona.zone_name = "Zona Pass"
	zona.spawn_inimigos_ao_falhar = false
	zona.mostrar_marcador = false
	add_child(zona)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	var NenScript = load("res://scripts/systems/NenSystem.gd")
	var nen = null
	if NenScript != null:
		nen = NenScript.new()
		nen.name = "NenSystem"
		player.add_child(nen)
	add_child(player)

	if PlayerData != null:
		PlayerData.despertou_nen = false
	var ativou := false
	if nen != null and nen.active_controller != null:
		ativou = bool(nen.active_controller.ativar_zetsu())
		# Mantém dict de técnicas sincronizado (caminho completo de ativar_tecnica)
		if ativou and nen.get("tecnicas") != null:
			nen.tecnicas[NenSystem.Tecnica.ZETSU]["ativo"] = true
	_ok(ativou, "Zetsu ativado via active_controller")
	var em_zetsu := false
	if nen != null:
		if nen.has_method("esta_em_zetsu"):
			em_zetsu = bool(nen.esta_em_zetsu())
		elif nen.active_controller != null:
			em_zetsu = bool(nen.active_controller.zetsu_ativo)
	_ok(em_zetsu, "esta_em_zetsu()/controller.zetsu_ativo=true")

	zona._on_body_entered(player)
	await get_tree().process_frame
	_ok(zona.falhou_stealth == false, "Com Zetsu não falha stealth")
	zona._on_body_exited(player)
	await get_tree().process_frame
	_ok(true, "Exit com Zetsu sem crash")

	player.queue_free()
	zona.queue_free()
	await get_tree().process_frame


func _test_zetsu_instinctive_before_awakening() -> void:
	print("\n[TESTE 4] Zetsu instintivo antes de despertar Nen...")
	if PlayerData != null:
		PlayerData.despertou_nen = false
	var ctrl_script = load("res://scripts/systems/nen/ActiveNenController.gd")
	_ok(ctrl_script != null, "ActiveNenController carrega")
	if ctrl_script == null:
		return
	var ctrl = ctrl_script.new()
	var ok: bool = ctrl.ativar_zetsu()
	_ok(ok == true, "ativar_zetsu() funciona sem despertou_nen")
	_ok(ctrl.zetsu_ativo == true, "zetsu_ativo=true após ativação instintiva")
	ctrl.desativar_zetsu()


func _test_ravina_zetsu_wiring() -> void:
	print("\n[TESTE 5] Ravina Padokia: wiring Zetsu no gerador...")
	var src := FileAccess.get_file_as_string("res://world/generator/RegionWorldGenerator.gd")
	_ok(src.contains("ZetsuSensorPredadores") or src.contains("ninho_feras_padokia"), "Gerador cria sensor predadores")
	_ok(src.contains("acampamento_salteadores_ravina"), "Gerador cria acampamento ravina")
	_ok(src.contains("lobo_sombras") and src.contains("candidato_exame"), "Ravina usa enemy_ids temáticos")

	var zone = NenSensorFactory.criar_zetsu(
		self, "ZetsuFactorySmoke", Vector2(10, 10),
		&"factory_smoke", "Factory Smoke",
		Vector2(60, 60), &"lobo_sombras", "Fera Factory"
	)
	_ok(zone != null and zone.enemy_id == &"lobo_sombras", "NenSensorFactory.criar_zetsu passa enemy_id")
	_ok(zone != null and zone.get_node_or_null("ZetsuHintLabel") != null, "Factory cria marcador visual")
	if zone:
		zone.queue_free()
	await get_tree().process_frame


func _test_arena_density() -> void:
	print("\n[TESTE 6] Arena Celestial densidade...")
	var scn := load("res://world/maps/arena_celestial.tscn") as PackedScene
	_ok(scn != null, "arena_celestial.tscn carrega")
	if scn == null:
		return
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	var wing = mapa.get_node_or_null("Wing")
	_ok(wing != null and wing.position.x >= 900.0, "Wing alinhado ao dojo (x>=900)")

	var fillers := 0
	for n in ["LutadorAmbient_A", "LutadorAmbient_B", "LutadorAmbient_C", "LutadorAmbient_D"]:
		if mapa.get_node_or_null(n) != null:
			fillers += 1
	_ok(fillers >= 4, "4 lutadores ambient (%d)" % fillers)

	var placas := 0
	for n in ["PlacaAndar1", "PlacaAndar50", "PlacaAndar100", "PlacaAndar190", "PlacaAndar200"]:
		if mapa.get_node_or_null(n) != null:
			placas += 1
	_ok(placas >= 5, "5 placas de andar (%d)" % placas)

	var story := 0
	for n in ["LutadorArena1", "LutadorArena2", "LutadorArena3", "LutadorArena4"]:
		if mapa.get_node_or_null(n) != null:
			story += 1
	_ok(story >= 4, "4 lutadores de missão presentes")

	_ok(
		mapa.get_node_or_null("HeavensArenaTowerUI") != null \
		or mapa.get_node_or_null("TorneioAndaresTrigger") != null,
		"Tower UI ou trigger de torneio presente"
	)

	var marcos = mapa.get("_marcos_notificados")
	_ok(marcos != null and typeof(marcos) == TYPE_DICTIONARY, "_marcos_notificados inicializado")

	mapa.queue_free()
	await get_tree().process_frame
