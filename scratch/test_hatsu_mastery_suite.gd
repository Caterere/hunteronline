extends Node

# ============================================================
# HUNTER ONLINE — IN-ENGINE TEST SUITE: HATSU MASTERY & ARCHIVE
# ============================================================

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ [PASS] " + test_name)
	else:
		failed_tests += 1
		printerr("  ❌ [FAIL] " + test_name)

func _ready() -> void:
	print("============================================================")
	print("🥋 TEST SUITE: HATSU MASTERY, ARCHIVE & PROGRESSION IN-ENGINE")
	print("============================================================")

	var hpm = HatsuProgressionManager
	if hpm == null:
		hpm = get_node_or_null("/root/HatsuProgressionManager")
	assert(hpm != null, "HatsuProgressionManager deve estar ativo")

	PlayerData.reset()

	# 1. Criação bloqueada antes de Greed Island
	print("\n--- [TEST 1] Bloqueio Pré-Greed Island ---")
	PlayerData.attributes["nivel"] = 1
	StoryManager.current_saga = 1
	var chk1: Dictionary = hpm.can_create_hatsu()
	assert_test(not chk1["can_create"] and chk1["reason"] == "SLOT_LOCKED", "1. Criação bloqueada antes de Greed Island")

	# 2. Desbloquear Greed Island e criar 1º Hatsu
	print("\n--- [TEST 2] Criação pós-Greed Island ---")
	StoryManager.concluir_saga(5)
	hpm.unlock_slot(1)
	PlayerData.attributes["gold"] = 10000

	var h1 := HatsuData.new()
	h1.nome = "Impacto de Ko"
	h1.poder_base = 100.0
	h1.custo_aura_base = 40.0
	h1.cooldown_base = 8.0
	h1.alcance = 50.0

	var forge_res = hpm.criar_e_registrar_hatsu(h1)
	assert_test(forge_res["success"] and int(PlayerData.attributes["gold"]) == 5000, "2. Transação atômica deduziu 5000 Jenny")
	assert_test(hpm.archive.size() == 1, "3. Hatsu registrado no Archive (1/12)")
	assert_test(hpm.active_slots_map[1] == h1.hatsu_id, "4. Auto-equipado no Slot 1")

	# 3. Cooldown de 30 minutos
	print("\n--- [TEST 3] Cooldown de Criação de 30 minutos ---")
	var h2 := HatsuData.new()
	h2.nome = "Lança de Emissão"
	var chk_cd = hpm.can_create_hatsu()
	assert_test(not chk_cd["can_create"] and chk_cd["reason"] == "COOLDOWN", "5. Tentativa durante cooldown rejeitada")

	# 4. Simulação de tempo de cooldown
	hpm.last_creation_timestamp -= 1801
	assert_test(hpm.can_create_hatsu()["can_create"], "6. Cooldown expirado permite nova criação")

	# 5. Mastery 0 e poder inicial de 30%
	print("\n--- [TEST 5] Mastery Inicial e Escala ---")
	assert_test(h1.mastery == 0.0, "7. Mastery inicial é 0.0")
	assert_test(abs(h1.obter_multiplicador_mastery() - 0.30) < 0.001, "8. Multiplicador inicial é 30%")
	assert_test(abs(h1.obter_poder_final() - 30.0) < 0.001, "9. Poder efetivo inicial é 30.0")

	# 6. Ganho de Mastery e Bônus Multifacetados
	print("\n--- [TEST 6] Ganho de Mastery e Bônus ---")
	PlayerData.attributes["nivel"] = 100
	hpm.conceder_mastery_xp(h1.hatsu_id, 1000, {"level": 100})
	assert_test(h1.mastery > 0.0, "10. Ganho de Mastery XP com sucesso")

	h1.mastery = 100.0
	assert_test(h1.is_mastered(), "11. Hatsu é ★ MASTERED no Nível 100")
	assert_test(abs(h1.obter_custo_final() - 32.0) < 0.001, "12. Custo de Aura reduzido em 20%")
	assert_test(abs(h1.obter_cooldown_final() - 6.4) < 0.001, "13. Cooldown reduzido em 20%")
	assert_test(abs(h1.obter_alcance_final() - 60.0) < 0.001, "14. Alcance aumentado em 20%")

	# 7. Anti-Farm
	print("\n--- [TEST 7] Proteção Anti-Farm ---")
	var res_farm = hpm.conceder_mastery_xp(h1.hatsu_id, 1000, {"level": 20})
	assert_test(res_farm.get("reason", "") == "ANTI_FARM_PENALTY" or res_farm.get("gained_xp", 0.0) == 0.0, "15. Mob Lv.20 vs Player Lv.100 concedeu 0 XP (Anti-Farm)")

	# 8. Archive Capped at 12
	print("\n--- [TEST 8] Archive Capped at 12 ---")
	while hpm.archive.size() < 12:
		hpm.last_creation_timestamp = 0
		PlayerData.attributes["gold"] = 10000
		var h_fill := HatsuData.new()
		h_fill.nome = "Hatsu %d" % hpm.archive.size()
		hpm.criar_e_registrar_hatsu(h_fill)
	assert_test(hpm.archive.size() == 12, "16. Archive com exatamente 12 Hatsus")
	hpm.last_creation_timestamp = 0
	PlayerData.attributes["gold"] = 10000
	var h_extra := HatsuData.new()
	h_extra.nome = "Hatsu 13"
	var chk_arch = hpm.can_create_hatsu()
	assert_test(not chk_arch["can_create"] and chk_arch["reason"] == "ARCHIVE_FULL", "17. Criação do 13º Hatsu bloqueada por ARCHIVE_FULL")

	print("\n============================================================")
	print("📊 RESULTADO FINAL: %d/%d TESTES APROVADOS (%d falhas)" % [passed_tests, total_tests, failed_tests])
	print("============================================================")
