extends Node

const BlacklistHuntBoardUIScript = preload("res://ui/Bounties/BlacklistHuntBoardUI.gd")
const CoopWorldBossCoordinatorScript = preload("res://scripts/network/CoopWorldBossCoordinator.gd")

var _passed := 0
var _total := 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 A7 BLACKLIST OPEN HUNT SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_catalog_rotation()
	_test_clues_and_rumors()
	_test_coop_fight_rewards()
	await _test_ui_docs_save()
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


func _test_catalog_rotation() -> void:
	print("\n[1] Catálogo + rotação...")
	BlacklistOpenHuntSystem.reset_for_tests()
	var cat: Array = BlacklistOpenHuntSystem.list_catalog()
	_ok(cat.size() >= 3, "catálogo com ≥3 alvos S-rank")
	var r1: Dictionary = BlacklistOpenHuntSystem.rotate_daily_target(0)
	_ok(bool(r1.get("ok", false)), "rotate_daily_target ok")
	var id1 := str(r1.get("target_id", ""))
	_ok(not id1.is_empty(), "target_id preenchido")
	var r2: Dictionary = BlacklistOpenHuntSystem.rotate_daily_target(1)
	_ok(bool(r2.get("ok", false)), "segunda rotação ok")
	_ok(str(r2.get("target_id", "")) != id1 or cat.size() == 1, "rotação muda alvo quando possível")
	var snap: Dictionary = BlacklistOpenHuntSystem.get_hunt_snapshot()
	_ok(int(snap.get("clue_tier", -1)) == 0, "pistas resetam na rotação")
	_ok(not bool(snap.get("location_revealed", true)), "localização oculta após rotação")


func _test_clues_and_rumors() -> void:
	print("\n[2] Pistas + rumores...")
	BlacklistOpenHuntSystem.reset_for_tests()
	BlacklistOpenHuntSystem.rotate_daily_target(2)
	var blocked: Dictionary = BlacklistOpenHuntSystem.start_hunt()
	_ok(not bool(blocked.get("ok", false)), "caça bloqueada sem localização")
	_ok(str(blocked.get("error", "")) == "location_unknown", "erro location_unknown")

	var c1: Dictionary = BlacklistOpenHuntSystem.discover_clue(1)
	_ok(bool(c1.get("ok", false)), "discover_clue ok")
	_ok(int(c1.get("clue_tier", 0)) == 1, "tier 1")
	_ok(not str(c1.get("clue_text", "")).is_empty(), "texto de pista")

	BlacklistOpenHuntSystem.discover_clue(10)
	_ok(BlacklistOpenHuntSystem.location_revealed, "localização revelada")

	var tid := BlacklistOpenHuntSystem.active_target_id
	var rumor_id := "rumor_blacklist_%s" % tid
	_ok(RumorSystem != null and RumorSystem.active_rumors.has(rumor_id), "rumor publicado no RumorSystem")


func _test_coop_fight_rewards() -> void:
	print("\n[3] Combate co-op + loot por contribuição...")
	BlacklistOpenHuntSystem.reset_for_tests()
	BlacklistOpenHuntSystem.rotate_daily_target(0)
	BlacklistOpenHuntSystem.discover_clue(10)
	var started: Dictionary = BlacklistOpenHuntSystem.start_hunt()
	_ok(bool(started.get("ok", false)), "start_hunt ok")
	_ok(BlacklistOpenHuntSystem.hunt_active, "hunt_active")

	BlacklistOpenHuntSystem.join_hunt(1, "party_a")
	BlacklistOpenHuntSystem.join_hunt(2, "party_b")
	_ok(BlacklistOpenHuntSystem.joined_peers.size() == 2, "2 caçadores")

	var t := BlacklistOpenHuntSystem.get_active_target()
	var max_hp := int(t.get("max_hp", 100000))
	var d1: Dictionary = BlacklistOpenHuntSystem.report_damage(1, int(max_hp * 0.6), true)
	_ok(bool(d1.get("ok", false)), "dano peer1 ok")
	_ok(int(d1.get("phase", 1)) >= 2, "fase avança em 50%")
	_ok(int(d1.get("aggro", 0)) == 1, "aggro no taunt peer1")

	BlacklistOpenHuntSystem.report_damage(2, int(max_hp * 0.05))
	var kill: Dictionary = BlacklistOpenHuntSystem.report_damage(1, max_hp)
	_ok(bool(kill.get("dead", false)), "boss morto")
	_ok(not BlacklistOpenHuntSystem.hunt_active, "hunt encerra após kill")
	var rewards: Dictionary = kill.get("rewards", {})
	_ok(rewards.has(1), "recompensa peer1")
	_ok(rewards.has(2), "recompensa peer2 (≥1% contribuição)")
	_ok(int(rewards[1].get("jenny", 0)) >= int(rewards[2].get("jenny", 0)), "maior contribuição → mais Jenny")
	var drop := str(t.get("guaranteed_drop", ""))
	var itens: Array = rewards[1].get("itens", [])
	_ok(itens.size() > 0 and str(itens[0]) == drop, "drop garantido")

	var coord = CoopWorldBossCoordinatorScript.new()
	coord.inicializar_boss("x", "Test", 1000)
	coord.registrar_dano(7, 100)
	_ok(coord.obter_alvo_aggro() == 7, "coordinator aggro isolado")


func _test_ui_docs_save() -> void:
	print("\n[4] UI + docs + save...")
	_ok(BlacklistHuntBoardUIScript != null, "BlacklistHuntBoardUI carrega")
	var ui = BlacklistHuntBoardUIScript.new()
	add_child(ui)
	await get_tree().process_frame
	ui.abrir()
	_ok(ui.visible, "UI abre")
	ui.fechar()
	_ok(not ui.visible, "UI fecha")
	ui.queue_free()

	var proj := FileAccess.get_file_as_string("res://project.godot")
	_ok("BlacklistOpenHuntSystem=" in proj, "autoload BlacklistOpenHuntSystem")
	var save_src := FileAccess.get_file_as_string("res://autoload/SaveManager.gd")
	_ok("blacklist_hunt_data" in save_src, "SaveManager persiste A7")

	BlacklistOpenHuntSystem.reset_for_tests()
	BlacklistOpenHuntSystem.rotate_daily_target(1)
	BlacklistOpenHuntSystem.discover_clue(2)
	var blob: Dictionary = BlacklistOpenHuntSystem.salvar_dados()
	BlacklistOpenHuntSystem.reset_for_tests()
	BlacklistOpenHuntSystem.carregar_dados(blob)
	_ok(BlacklistOpenHuntSystem.clue_tier == 2, "save/load preserva clue_tier")

	var docs := FileAccess.get_file_as_string("res://docs/multiplayer/MULTIPLAYER_GAMEPLAY.md")
	_ok("Caça Blacklist" in docs and "IMPLEMENTED" in docs, "Docs marcam Blacklist IMPLEMENTED")
	var backlog := FileAccess.get_file_as_string("res://docs/roadmap/MMO_FEATURES_BACKLOG.md")
	_ok("### A7. Caça Blacklist" in backlog, "Backlog tem seção A7")
	_ok("[IMPLEMENTED]" in backlog and "open hunt" in backlog.to_lower(), "Backlog A7 IMPLEMENTED")
