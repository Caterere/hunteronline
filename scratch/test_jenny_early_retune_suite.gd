extends Node

# ============================================================
# HUNTER ONLINE — Retune Jenny / loot early-game
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 JENNY EARLY-GAME RETUNE SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_canon_jenny_scale()
	_test_economy_helpers()
	_test_padokia_early_gold()
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


func _test_canon_jenny_scale() -> void:
	print("\n[1] Escala Jenny canônico por arco...")
	CanonQuestCatalog._quest_cache.clear()
	var q1 = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	var q1_end = CanonQuestCatalog.obter_quest_da_etapa(1, 24)
	var q3 = CanonQuestCatalog.obter_quest_da_etapa(3, 26)
	_ok(q1 != null and q1.reward_gold <= 400, "Exam etapa1 Jenny freada (<=400, got %d)" % q1.reward_gold)
	_ok(q1.reward_gold >= 40, "Exam etapa1 Jenny mínima (>=40)")
	_ok(q1_end.reward_gold < 8000, "Exam final Jenny freada (<8000, got %d)" % q1_end.reward_gold)
	_ok(q3.reward_gold < 90000, "Arena final Jenny freada (<90k, got %d)" % q3.reward_gold)
	_ok(
		CanonQuestCatalog.escalar_jenny_narrativo(1, 800) == 320,
		"Helper arco1 800→320 (%d)" % CanonQuestCatalog.escalar_jenny_narrativo(1, 800)
	)
	_ok(
		CanonQuestCatalog.escalar_jenny_narrativo(4, 60000) == 9000,
		"Helper arco4 60000→9000 (%d)" % CanonQuestCatalog.escalar_jenny_narrativo(4, 60000)
	)


func _test_economy_helpers() -> void:
	print("\n[2] Economy drop/prêmio Arena...")
	_ok(Economy != null, "Economy autoload")
	if Economy == null:
		return
	var drop_low: int = Economy.calcular_drop_jenny_inimigo(3)
	_ok(drop_low >= 5 and drop_low <= 60, "Drop lv3 soft-cap (5..60, got %d)" % drop_low)
	var drop_mid: int = Economy.calcular_drop_jenny_inimigo(40)
	_ok(drop_mid >= 20 and drop_mid <= 1600, "Drop lv40 faixa razoável (got %d)" % drop_mid)
	var p1: int = Economy.calcular_premio_jenny_andar_arena(1)
	var p10: int = Economy.calcular_premio_jenny_andar_arena(10)
	var p100: int = Economy.calcular_premio_jenny_andar_arena(100)
	_ok(p1 < 800, "Arena andar1 <800 (got %d)" % p1)
	_ok(p10 < 3500, "Arena andar10 <3500 (got %d)" % p10)
	_ok(p10 > p1, "Arena andar10 > andar1")
	_ok(p100 > p10 * 3, "Arena andar100 cresce vs early (%d vs %d)" % [p100, p10])


func _test_padokia_early_gold() -> void:
	print("\n[3] Padokia early Jenny...")
	var qp = PadokiaQuestCatalog.obter_quest_principal()
	var qs1 = PadokiaQuestCatalog.obter_quest_secundaria_1()
	var qsec = PadokiaQuestCatalog.obter_quest_secreta()
	_ok(qp.reward_gold <= 1000, "Principal Padokia <=1000 (got %d)" % qp.reward_gold)
	_ok(qs1.reward_gold <= 300, "Secundária ervas <=300 (got %d)" % qs1.reward_gold)
	_ok(qsec.reward_gold <= 1000, "Secreta rocha <=1000 (got %d)" % qsec.reward_gold)
