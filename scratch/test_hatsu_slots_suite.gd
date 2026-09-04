extends Node

# ============================================================
# HUNTER ONLINE — IN-ENGINE TEST SUITE: HATSU SLOTS PROGRESSION
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
	print("🥋 TEST SUITE: PROGRESSÃO CANÔNICA DE HATSU SLOTS")
	print("============================================================")

	var hpm = HatsuProgressionManager
	if hpm == null:
		hpm = get_node_or_null("/root/HatsuProgressionManager")
	assert(hpm != null, "HatsuProgressionManager deve estar ativo")

	PlayerData.reset()

	# TEST 1 & 2: Level baixo e sem Greed Island
	print("\n--- [TEST 1-2] Sem Greed Island ---")
	PlayerData.attributes["nivel"] = 1
	StoryManager.current_saga = 1
	assert_test(not hpm.is_slot_unlocked(1) and not hpm.can_unlock_slot(1)["can_unlock"], "1. Level 1 sem Greed Island: Slot 1 bloqueado")
	PlayerData.attributes["nivel"] = 400
	assert_test(not hpm.is_slot_unlocked(1) and not hpm.can_unlock_slot(1)["can_unlock"], "2. Level 400 sem Greed Island: Slot 1 continua bloqueado")

	# TEST 3: Completar Greed Island e desbloquear Slot 1
	print("\n--- [TEST 3] Conclusão de Greed Island ---")
	StoryManager.concluir_saga(5)
	assert_test(hpm.is_slot_unlocked(1), "3.1 Greed Island concluída: Slot 1 desbloqueado automaticamente")
	assert_test(not hpm.is_slot_unlocked(2) and hpm.can_unlock_slot(2)["reason"] == "REQUIRED_LEVEL", "3.2 Slot 2 permanece bloqueado por nível (400 < 600)")

	# TEST 4: Level 600 com Slot 1 desbloqueado
	print("\n--- [TEST 4] Level 600 + Slot 1 ---")
	PlayerData.aplicar_nivel(600)
	assert_test(hpm.is_slot_unlocked(2), "4. Level 600 com Slot 1 desbloqueia Slot 2 automaticamente")

	# TEST 5 (Anti-Bypass): Level 600 com Slot 1 travado
	print("\n--- [TEST 5] Anti-Bypass Level 600 ---")
	hpm.unlocked_slots[1] = false
	hpm.unlocked_slots[2] = false
	var check_s2 = hpm.can_unlock_slot(2)
	assert_test(not check_s2["can_unlock"] and check_s2["reason"] == "PREVIOUS_SLOT_LOCKED", "5. Level 600 com Slot 1 bloqueado rejeita estritamente Slot 2")
	hpm.unlocked_slots[1] = true
	hpm.unlocked_slots[2] = true

	# TEST 6 & 7 (Anti-Bypass): Level 800 sem Slot 2
	print("\n--- [TEST 6-7] Anti-Bypass Level 800 ---")
	PlayerData.attributes["nivel"] = 800
	hpm.unlocked_slots[2] = false
	var check_s3 = hpm.can_unlock_slot(3)
	assert_test(not check_s3["can_unlock"] and check_s3["reason"] == "PREVIOUS_SLOT_LOCKED", "6-7. Level 800 sem Slot 2 rejeita estritamente Slot 3")

	# TEST 8: Level 800 com Slot 2 desbloqueado
	print("\n--- [TEST 8] Level 800 + Slot 2 ---")
	hpm.unlocked_slots[2] = true
	PlayerData.aplicar_nivel(800)
	assert_test(hpm.is_slot_unlocked(3), "8. Level 800 com Slot 2 desbloqueia Slot 3 com sucesso")

	# TEST 9 & 10: Level 1000 + Slot 4
	print("\n--- [TEST 9-10] Level 1000 + Slot 4 ---")
	hpm.unlocked_slots[3] = false
	hpm.unlocked_slots[4] = false
	assert_test(hpm.can_unlock_slot(4)["reason"] == "PREVIOUS_SLOT_LOCKED", "9. Level 1000 com Slot 3 bloqueado rejeita Slot 4")
	hpm.unlocked_slots[3] = true
	PlayerData.aplicar_nivel(1000)
	assert_test(hpm.is_slot_unlocked(4), "10. Level 1000 com Slot 3 desbloqueia Slot 4 com sucesso")

	# TEST 11: Level 1500 (Além de 1000)
	print("\n--- [TEST 11] Level 1500 ---")
	PlayerData.attributes["nivel"] = 1500
	assert_test(hpm.is_slot_unlocked(4) and PlayerData.attributes["nivel"] == 1500, "11. Level 1500 opera perfeitamente sem tetos artificiais")

	# TEST 12: Tentativas de Burla e Revalidação de Save
	print("\n--- [TEST 12] Anti-Bypass e Revalidação ---")
	# Criar Hatsu falso e tentar equipar em slot bloqueado
	var h := HatsuData.new()
	h.nome = "Impacto Fatal"
	PlayerData.hatsu_criados.append(h)
	hpm.unlocked_slots[3] = false
	var equipou_bloq = PlayerData.equipar_hatsu(2, 0) # Slot 3
	assert_test(not equipou_bloq and PlayerData.hatsu_slots[2] == -1, "12.1 Equipar em slot bloqueado foi barrado pelo PlayerData")

	# Simular Save adulterado com Slot 4 desbloqueado no Level 100
	PlayerData.attributes["nivel"] = 100
	hpm.unlocked_slots = {1: true, 2: true, 3: true, 4: true}
	PlayerData.hatsu_slots[3] = 0
	hpm.revalidate_all_slots()
	assert_test(not hpm.is_slot_unlocked(2) and not hpm.is_slot_unlocked(3) and not hpm.is_slot_unlocked(4), "12.2 Revalidação expurgou slots 2, 3 e 4 por falta de nível")
	assert_test(PlayerData.hatsu_slots[3] == -1, "12.3 Hatsu desequipado de slot revogado")

	print("\n============================================================")
	print("📊 RESULTADOS DA SUÍTE DE HATSU SLOTS:")
	print("Total: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests])
	print("============================================================")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)
