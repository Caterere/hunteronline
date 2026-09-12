extends Node

# ============================================================
# HUNTER ONLINE — S2 Heaven's Arena Ranked + Seasons
# ============================================================

const ArenaRankedSeason = preload("res://scripts/systems/arena/ArenaRankedSeason.gd")
const ArenaGhostRegistry = preload("res://scripts/systems/arena/ArenaGhostRegistry.gd")
const DuelSystemScript = preload("res://scripts/network/DuelSystem.gd")

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 S2 HEAVEN'S ARENA RANKED + SEASONS SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_elo_math()
	_test_season_soft_reset()
	_test_queue_and_report()
	_test_tower_gate_and_ui()
	_test_duel_hook()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	if not _failures.is_empty():
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


func _test_elo_math() -> void:
	print("\n[1] Elo / MMR...")
	_ok(ArenaRankedSeason.DEFAULT_MMR == 1000, "MMR base 1000")
	_ok(ArenaRankedSeason.K_FACTOR == 32, "K=32")
	var delta_even := ArenaRankedSeason.calc_mmr_delta(1000, 1000)
	_ok(delta_even == 16, "Vitória igual → +16 (%d)" % delta_even)
	var delta_under := ArenaRankedSeason.calc_mmr_delta(1000, 1200)
	_ok(delta_under > delta_even, "Upset vs 1200 dá mais MMR (%d)" % delta_under)
	var tier_low := ArenaRankedSeason._tier_for_mmr(800)
	_ok(str(tier_low.get("id", "")) == "rookie", "Tier rookie em 800")
	var tier_hi := ArenaRankedSeason._tier_for_mmr(1550)
	_ok(str(tier_hi.get("id", "")) == "zodiac_candidate", "Tier zodíaco em 1550")


func _test_season_soft_reset() -> void:
	print("\n[2] Temporada / soft reset...")
	ArenaRankedSeason.reset_for_tests()
	TimeManager.current_day = 1
	var st := ArenaRankedSeason.ensure_season()
	_ok(int(st.get("season_id", 0)) == 1, "Temporada 1 inicia")
	_ok(ArenaRankedSeason.days_until_season_end(st) == 28, "28 dias restantes")

	# Força MMR alto e avança calendário além da temporada
	st["mmr"] = 1400
	st["peak_mmr"] = 1400
	st["season_start_day"] = 1
	ArenaRankedSeason._save_state(st)
	TimeManager.current_day = 30
	var rolled := ArenaRankedSeason.ensure_season()
	_ok(int(rolled.get("season_id", 0)) == 2, "Rollover → temporada 2")
	# Soft reset: lerp(1400, 1000, 0.5) = 1200
	_ok(int(rolled.get("mmr", 0)) == 1200, "Soft reset 1400→1200 (got %d)" % int(rolled.get("mmr", 0)))
	_ok(int(rolled.get("wins", -1)) == 0, "W/L zerados no reset")
	var titles: Array = rolled.get("titles_unlocked", [])
	_ok(titles.has("🏅 Veterano da Temporada 1"), "Título cosmético de fim de temporada")
	TimeManager.current_day = 1


func _test_queue_and_report() -> void:
	print("\n[3] Fila + report_match...")
	ArenaRankedSeason.reset_for_tests()
	TimeManager.current_day = 5
	PlayerData.attributes["nome"] = "Killua Ranked"
	PlayerData.nome_personagem = "Killua Ranked"
	ArenaGhostRegistry.limpar()

	var q := ArenaRankedSeason.join_queue(12)
	_ok(bool(q.get("ok", false)), "join_queue ok")
	_ok(ArenaRankedSeason.is_ranked_mode(), "ranked_mode ligado pela fila")
	_ok(ArenaRankedSeason.is_in_queue(), "in_queue true")
	var opp := ArenaRankedSeason.pop_match_opponent()
	_ok(not opp.is_empty(), "pop_match_opponent retorna rival")
	_ok(str(opp.get("kind", "")) == "synthetic", "Sem ghost → sintético")
	_ok(not ArenaRankedSeason.is_in_queue(), "fila limpa após pop")

	# Registra ghost e refila
	var snap := ArenaGhostRegistry.capturar_do_jogador(12)
	ArenaGhostRegistry.registrar(snap)
	ArenaRankedSeason.join_queue(12)
	var ghost_opp := ArenaRankedSeason.pop_match_opponent(12)
	_ok(str(ghost_opp.get("kind", "")) == "ghost", "Com ghost → kind ghost")
	_ok(str(ghost_opp.get("name", "")).contains("Killua"), "Ghost usa nome do jogador")

	var before := int(ArenaRankedSeason.ensure_season().get("mmr", 0))
	var res := ArenaRankedSeason.report_match(true, int(ghost_opp.get("mmr", 1000)), 12, str(ghost_opp.get("name", "Rival")))
	_ok(bool(res.get("won", false)), "report win")
	_ok(int(res.get("mmr", 0)) > before, "MMR sobe após vitória")
	_ok(int(ArenaRankedSeason.ensure_season().get("wins", 0)) == 1, "wins=1")
	var board := ArenaRankedSeason.get_leaderboard()
	_ok(board.size() >= 1, "leaderboard tem entradas")
	_ok(str(board[0].get("name", "")).length() > 0, "leaderboard nome preenchido")


func _test_tower_gate_and_ui() -> void:
	print("\n[4] Torre gate + UI...")
	ArenaRankedSeason.reset_for_tests()
	var skipped := ArenaRankedSeason.report_tower_result(true, 3)
	_ok(bool(skipped.get("skipped", false)), "Sem ranked_mode → skip")

	ArenaRankedSeason.set_ranked_mode(true)
	ArenaRankedSeason.join_queue(3)
	var applied := ArenaRankedSeason.report_tower_result(true, 3)
	_ok(not bool(applied.get("skipped", false)), "Com ranked_mode → aplica")
	_ok(int(applied.get("delta", 0)) != 0, "delta MMR não-zero")

	var UiScript = load("res://ui/Arena/HeavensArenaTowerUI.gd")
	_ok(UiScript != null, "HeavensArenaTowerUI carrega")
	var ui = UiScript.new()
	ui._construir_ui()
	_ok(ui.lbl_ranked != null, "UI tem lbl_ranked")
	_ok(ui.btn_ranked != null, "UI tem btn_ranked")
	_ok(ui.btn_fila != null, "UI tem btn_fila")
	ui._atualizar_torneio()
	_ok(str(ui.lbl_ranked.text).contains("MMR"), "summary_text na UI")
	_ok(str(ui.btn_ranked.text).contains("ON"), "botão mostra ranked ON")
	ui.free()

	var TowerScript = load("res://world/maps/CelestialTowerArena.gd")
	_ok(TowerScript != null, "CelestialTowerArena carrega")
	var src := FileAccess.get_file_as_string("res://world/maps/CelestialTowerArena.gd")
	_ok("report_tower_result" in src, "Torre chama report_tower_result")


func _test_duel_hook() -> void:
	print("\n[5] DuelSystem hook ranqueado...")
	ArenaRankedSeason.reset_for_tests()
	var duel = DuelSystemScript.new()
	var skip := duel.reportar_ranqueado(true, 1000, "Rival")
	_ok(bool(skip.get("skipped", false)), "Duelo sem ranked → skip")
	ArenaRankedSeason.set_ranked_mode(true)
	var mmr0 := int(ArenaRankedSeason.ensure_season().get("mmr", 0))
	var hit := duel.reportar_ranqueado(true, 1000, "Rival")
	_ok(not bool(hit.get("skipped", false)), "Duelo com ranked → aplica")
	_ok(int(ArenaRankedSeason.ensure_season().get("mmr", 0)) > mmr0, "MMR sobe via duelo")
	var docs := FileAccess.get_file_as_string("res://docs/multiplayer/MULTIPLAYER_GAMEPLAY.md")
	_ok("ArenaRankedSeason" in docs or "[IMPLEMENTED]" in docs and "Arena Ranqueada" in docs, "Docs marcam Arena Ranqueada")
	_ok(docs.contains("Arena Ranqueada na Torre Celestial") and docs.contains("[IMPLEMENTED]"), "Status IMPLEMENTED no gameplay doc")
