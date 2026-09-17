extends Node

# ============================================================
# Suite: Exame etapas 1–8 + combate early + dicas Nen
# godot --headless --path . res://scratch/test_exam_early_game_suite.tscn
# ============================================================

const MissionObjectiveResolverScript = preload("res://scripts/missions/MissionObjectiveResolver.gd")
const LootDropScript = preload("res://entities/world/LootDrop.gd")

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
	print("=== test_exam_early_game_suite ===")
	_test_enemy_balance()
	_test_control_tips_wiring()
	_test_corridor_align_code()
	await _test_exam_map_actors_and_gps()
	await _test_jenny_on_kill_path()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_enemy_balance() -> void:
	print("-- early enemy balance --")
	var sab = load("res://resource/status/CandidatoSabotador.tres")
	var mac = load("res://resource/status/MacacoPantanal.tres")
	var pig = load("res://resource/status/GreatStampPig.tres")
	assert_test(sab != null and int(sab.max_health) <= 60, "sabotador HP early <= 60 (got %s)" % str(sab.max_health if sab else "?"))
	assert_test(sab != null and int(sab.strength) <= 10, "sabotador str <= 10")
	assert_test(mac != null and int(mac.max_health) <= 80, "pantanal HP <= 80")
	assert_test(pig != null and int(pig.max_health) <= 180, "javali HP early <= 180")
	# Player forca 5 + base 10 ≈ 15 bruto; vs def 2 → ~14 dmg; 48/14 ≈ 4 hits
	var dmg_est: float = (10.0 + 5.0) * (100.0 / (100.0 + 2.0))
	assert_test(dmg_est >= 10.0 and float(sab.max_health) / dmg_est <= 6.0, "sabotador morre em ~4-6 hits early")


func _test_control_tips_wiring() -> void:
	print("-- nen/control tips --")
	var hud := FileAccess.get_file_as_string("res://ui/hud/PlayerHUD.gd")
	assert_test("_criar_barra_controles" in hud, "PlayerHUD tem barra de controles")
	assert_test("[Q]+3 Zetsu" in hud or "Zetsu" in hud, "tip menciona Zetsu")
	var nen := FileAccess.get_file_as_string("res://ui/hud/NenQuickActionBar.gd")
	assert_test("SEGURE [Q]" in nen and "Z/G/X" in nen, "Nen bar explica hold Q + atalhos")
	var tut := FileAccess.get_file_as_string("res://autoload/TutorialManager.gd")
	assert_test("alternar entre Ten" not in tut and "[Q]" in tut, "tutorial nen_despertar atualizado (sem [N] cycle falso)")
	var enemy := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemySystem.gd")
	assert_test("emit_toast" in enemy and "+%d XP" in enemy, "kill mostra toast de XP")
	var dist := FileAccess.get_file_as_string("res://world/components/SagaDistrictKit.gd")
	assert_test("farsa_macaco" in dist, "district kit spawna farsa_macaco")
	assert_test("macaco_pantano" not in dist or dist.count("criatura_pantanal") >= 2, "ambient pantanal usa criatura_pantanal")


func _test_corridor_align_code() -> void:
	print("-- corridor align --")
	var src := FileAccess.get_file_as_string("res://world/maps/ExameMaratonaMap.gd")
	assert_test("_alinhar_atores_ao_corredor" in src, "ExameMaratonaMap alinha atores")
	assert_test("MonstroPantanal" in src and "Satotz" in src, "alinha NPCs e monstros chave")


func _test_exam_map_actors_and_gps() -> void:
	print("-- exam map GPS etapas 1-8 --")
	var packed = load("res://world/maps/exame_maratona.tscn")
	assert_test(packed != null, "exame_maratona.tscn carrega")
	if packed == null:
		return
	var mapa = packed.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	if mapa.has_method("_alinhar_atores_ao_corredor"):
		mapa._alinhar_atores_ao_corredor()

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(80, 16)
	mapa.add_child(player)

	var checks := [
		{"etapa": 1, "node": "Tonpa", "type": "npc"},
		{"etapa": 2, "node": "Nicol", "type": "npc"},
		{"etapa": 3, "node": "Gon", "type": "npc"},
		{"etapa": 4, "node": "InimigoMaratona1", "type": "enemy"},
		{"etapa": 5, "node": "Satotz", "type": "npc"},
		{"etapa": 6, "node": "Pokkle", "type": "npc"},
		{"etapa": 8, "node": "MonstroPantanal1", "type": "enemy"},
	]

	for c in checks:
		var n = mapa.get_node_or_null(str(c["node"]))
		assert_test(n != null and n is Node2D, "ator etapa %d presente: %s" % [c["etapa"], c["node"]])
		if n != null and n is Node2D:
			assert_test(absf((n as Node2D).position.y) <= 60.0, "ator %s no corredor Y (y=%.1f)" % [c["node"], (n as Node2D).position.y])

	# GPS etapa 1 → Tonpa
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 1
	QuestSystem.active_quests.clear()
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	QuestSystem.start_quest(q1)
	var gps := MissionGPSIndicator.new()
	mapa.add_child(gps)
	gps.player_ref = player
	await get_tree().process_frame
	gps._atualizar_alvo_ativo()
	assert_test(gps.target_found, "GPS encontrou alvo etapa 1")
	assert_test(gps.current_target_type != "portal", "GPS etapa 1 não é portal")
	var tonpa = mapa.get_node_or_null("Tonpa")
	if tonpa != null and gps.target_found:
		assert_test(gps.current_target_node == tonpa or "tonpa" in gps.current_target_name.to_lower(), "GPS aponta Tonpa")

	# Expected map
	var expected := MissionObjectiveResolverScript.get_expected_map_path(q1)
	assert_test("exame_maratona" in expected, "mapa esperado = exame_maratona")

	# Etapa 7: pista farsa_macaco (spawnada no densify do mapa)
	var farsa = mapa.get_node_or_null("GyoPistaFarsaMacaco")
	assert_test(farsa != null, "pista farsa_macaco spawnada no Exame")
	if farsa != null:
		assert_test(str(farsa.clue_id) == "farsa_macaco", "clue_id = farsa_macaco")
		assert_test(farsa.requer_gyo == false, "farsa_macaco sem soft-lock de Gyo")

	gps.queue_free()
	mapa.queue_free()
	await get_tree().process_frame


func _test_jenny_on_kill_path() -> void:
	print("-- jenny direct on kill path --")
	var before: int = Economy.obter_gold()
	LootDropScript.spawn_jenny(self, Vector2(10, 10), 25)
	await get_tree().process_frame
	assert_test(Economy.obter_gold() == before + 25, "Jenny direto +25")
