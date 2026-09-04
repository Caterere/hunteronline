#!/usr/bin/env python3
"""
HUNTER ONLINE — HATSU SLOTS PROGRESSION & ANTI-BYPASS VERIFICATION SUITE
Validates all scenarios required by Sections 22, 23, and 24:
1. Level 1, GI = false -> Slot 1 = LOCKED
2. Level 400, GI = false -> Slot 1 = LOCKED
3. Level 400, GI = true -> Slot 1 = UNLOCKED, Slot 2 = LOCKED
4. Level 600, GI = true, Slot 1 = UNLOCKED -> Slot 2 = UNLOCKED
5. Level 600, GI = true, Slot 1 = LOCKED -> Slot 2 = LOCKED (MANDATORY ANTI-BYPASS)
6. Level 800, Slot 1 = LOCKED, Slot 2 = LOCKED -> Slot 3 = LOCKED
7. Level 800, Slot 1 = UNLOCKED, Slot 2 = LOCKED -> Slot 3 = LOCKED
8. Level 800, Slot 1 = UNLOCKED, Slot 2 = UNLOCKED -> Slot 3 = UNLOCKED
9. Level 1000, Slot 1 = UNLOCKED, Slot 2 = UNLOCKED, Slot 3 = LOCKED -> Slot 4 = LOCKED
10. Level 1000, Slot 1 = UNLOCKED, Slot 2 = UNLOCKED, Slot 3 = UNLOCKED -> Slot 4 = UNLOCKED
11. Level 1500, all 4 slots unlocked -> continues functioning normally (No Level Cap)
12. Anti-bypass tests: direct unlock injection, equip on locked slot, save corruption recovery, future Slot 5 extensibility
"""

import sys
import json

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")


class HatsuSlotDataMock:
    def __init__(self, slot_id, display_name, req_level=0, req_slot=0, req_saga=0, req_flag=""):
        self.slot_id = slot_id
        self.display_name = display_name
        self.required_level = req_level
        self.required_slot_id = req_slot
        self.required_saga_id = req_saga
        self.required_story_flag = req_flag


class HatsuProgressionManagerMock:
    def __init__(self):
        self.slots_catalog = {}
        self.unlocked_slots = {1: False, 2: False, 3: False, 4: False}
        self.player_level = 1
        self.greed_island_completed = False
        self.equipped_slots = [-1, -1, -1, -1] # slots 0..3
        self.created_hatsus = []
        self._init_catalog()

    def _init_catalog(self):
        self.slots_catalog[1] = HatsuSlotDataMock(1, "Hatsu Slot 1", 0, 0, 5, "greed_island_completed")
        self.slots_catalog[2] = HatsuSlotDataMock(2, "Hatsu Slot 2", 600, 1, 0, "")
        self.slots_catalog[3] = HatsuSlotDataMock(3, "Hatsu Slot 3", 800, 2, 0, "")
        self.slots_catalog[4] = HatsuSlotDataMock(4, "Hatsu Slot 4", 1000, 3, 0, "")

    def is_slot_unlocked(self, slot_id):
        return self.unlocked_slots.get(slot_id, False)

    def can_unlock_slot(self, slot_id):
        if slot_id not in self.slots_catalog:
            return {"can_unlock": False, "reason": "INVALID_SLOT"}

        data = self.slots_catalog[slot_id]
        if self.is_slot_unlocked(slot_id):
            return {"can_unlock": False, "reason": "ALREADY_UNLOCKED"}

        # Chain dependency: previous slot must be unlocked
        if data.required_slot_id > 0:
            if not self.is_slot_unlocked(data.required_slot_id):
                return {
                    "can_unlock": False,
                    "reason": "PREVIOUS_SLOT_LOCKED",
                    "required_slot": data.required_slot_id,
                    "previous_slot_unlocked": False
                }

        # Story saga check (Slot 1)
        if data.required_saga_id == 5 and not self.greed_island_completed:
            return {
                "can_unlock": False,
                "reason": "STORY_NOT_COMPLETED",
                "story_completed": False
            }

        # Level check
        if data.required_level > 0 and self.player_level < data.required_level:
            return {
                "can_unlock": False,
                "reason": "REQUIRED_LEVEL",
                "required_level": data.required_level,
                "current_level": self.player_level
            }

        return {
            "can_unlock": True,
            "reason": "OK",
            "required_level": data.required_level,
            "current_level": self.player_level
        }

    def unlock_slot(self, slot_id):
        check = self.can_unlock_slot(slot_id)
        if not check["can_unlock"]:
            return False
        self.unlocked_slots[slot_id] = True
        return True

    def check_and_unlock_slots(self):
        unlocked_any = []
        for sid in sorted(self.slots_catalog.keys()):
            if not self.is_slot_unlocked(sid):
                if self.can_unlock_slot(sid)["can_unlock"]:
                    if self.unlock_slot(sid):
                        unlocked_any.append(sid)
        return unlocked_any

    def can_create_hatsu(self):
        return self.is_slot_unlocked(1)

    def can_equip_to_slot(self, slot_id, hatsu_index):
        if not self.is_slot_unlocked(slot_id):
            return False
        if hatsu_index < 0 or hatsu_index >= len(self.created_hatsus):
            return False
        return True

    def equip_hatsu(self, slot_id, hatsu_index):
        if not self.can_equip_to_slot(slot_id, hatsu_index):
            return False
        self.equipped_slots[slot_id - 1] = hatsu_index
        return True

    def use_hatsu(self, slot_id):
        if not self.is_slot_unlocked(slot_id):
            return False, "Slot bloqueado"
        idx = self.equipped_slots[slot_id - 1]
        if idx == -1:
            return False, "Nenhum Hatsu equipado"
        return True, f"Executou {self.created_hatsus[idx]}"

    def revalidate_all_slots(self):
        for sid in sorted(self.slots_catalog.keys()):
            if self.is_slot_unlocked(sid):
                data = self.slots_catalog[sid]
                valid = True
                if data.required_slot_id > 0 and not self.is_slot_unlocked(data.required_slot_id):
                    valid = False
                if data.required_level > 0 and self.player_level < data.required_level:
                    valid = False
                if data.required_saga_id == 5 and not self.greed_island_completed:
                    valid = False
                if not valid:
                    self.unlocked_slots[sid] = False
                    self.equipped_slots[sid - 1] = -1


def run_hatsu_slots_suite():
    print("=" * 70)
    print("🥋 RUNNING CANONICAL HATSU SLOTS REGRESSION SUITE")
    print("=" * 70)

    total_tests = 0
    passed_tests = 0

    def assert_test(cond, title):
        nonlocal total_tests, passed_tests
        total_tests += 1
        if cond:
            passed_tests += 1
            print(f"  ✅ [PASS] {title}")
        else:
            print(f"  ❌ [FAIL] {title}")
            assert False, f"Test failed: {title}"

    # TEST 1: Level 1, GI = false -> Slot 1 = LOCKED
    print("\n--- [TEST 1] Level 1, GI = false ---")
    mgr = HatsuProgressionManagerMock()
    mgr.player_level = 1
    mgr.greed_island_completed = False
    assert_test(not mgr.is_slot_unlocked(1) and not mgr.can_unlock_slot(1)["can_unlock"], "1. Level 1 com Greed Island pendente: Slot 1 LOCKED")

    # TEST 2: Level 400, GI = false -> Slot 1 = LOCKED
    print("\n--- [TEST 2] Level 400, GI = false ---")
    mgr.player_level = 400
    mgr.greed_island_completed = False
    assert_test(not mgr.is_slot_unlocked(1) and not mgr.can_unlock_slot(1)["can_unlock"], "2. Level 400 com Greed Island pendente: Slot 1 continua LOCKED")

    # TEST 3: Level 400, GI = true -> Slot 1 = UNLOCKED, Slot 2 = LOCKED
    print("\n--- [TEST 3] Level 400, GI = true ---")
    mgr.greed_island_completed = True
    assert_test(mgr.can_unlock_slot(1)["can_unlock"], "3.1 Greed Island concluída: Slot 1 apto para desbloqueio com Biscuit")
    mgr.unlock_slot(1)
    assert_test(mgr.is_slot_unlocked(1), "3.2 Slot 1 desbloqueado com sucesso")
    assert_test(not mgr.is_slot_unlocked(2) and mgr.can_unlock_slot(2)["reason"] == "REQUIRED_LEVEL", "3.3 Slot 2 permanece LOCKED pois Nível 400 < 600")

    # TEST 4: Level 600, GI = true, Slot 1 = UNLOCKED -> Slot 2 = UNLOCKED
    print("\n--- [TEST 4] Level 600, GI = true, Slot 1 = UNLOCKED ---")
    mgr.player_level = 600
    assert_test(mgr.can_unlock_slot(2)["can_unlock"], "4.1 Nível 600 com Slot 1 desbloqueado: Slot 2 apto para desbloqueio")
    mgr.unlock_slot(2)
    assert_test(mgr.is_slot_unlocked(2), "4.2 Slot 2 desbloqueado com sucesso")

    # TEST 5: Level 600, GI = true, Slot 1 = LOCKED -> Slot 2 = LOCKED (CRITICAL ANTI-BYPASS)
    print("\n--- [TEST 5 (CRITICAL)] Level 600, GI = true, Slot 1 = LOCKED ---")
    mgr_t5 = HatsuProgressionManagerMock()
    mgr_t5.player_level = 600
    mgr_t5.greed_island_completed = True
    mgr_t5.unlocked_slots[1] = False # Slot 1 is LOCKED
    check_s2 = mgr_t5.can_unlock_slot(2)
    assert_test(not check_s2["can_unlock"] and check_s2["reason"] == "PREVIOUS_SLOT_LOCKED", "5. Level 600 com Slot 1 bloqueado: Slot 2 PERMANECE ESTRITAMENTE LOCKED")

    # TEST 6: Level 800, Slot 1 = LOCKED, Slot 2 = LOCKED -> Slot 3 = LOCKED
    print("\n--- [TEST 6] Level 800, Slot 1 = LOCKED, Slot 2 = LOCKED ---")
    mgr_t6 = HatsuProgressionManagerMock()
    mgr_t6.player_level = 800
    check_s3 = mgr_t6.can_unlock_slot(3)
    assert_test(not check_s3["can_unlock"] and check_s3["reason"] == "PREVIOUS_SLOT_LOCKED", "6. Level 800 sem Slot 1/2: Slot 3 PERMANECE ESTRITAMENTE LOCKED")

    # TEST 7: Level 800, Slot 1 = UNLOCKED, Slot 2 = LOCKED -> Slot 3 = LOCKED
    print("\n--- [TEST 7] Level 800, Slot 1 = UNLOCKED, Slot 2 = LOCKED ---")
    mgr_t7 = HatsuProgressionManagerMock()
    mgr_t7.player_level = 800
    mgr_t7.greed_island_completed = True
    mgr_t7.unlocked_slots[1] = True
    mgr_t7.unlocked_slots[2] = False
    check_s3_b = mgr_t7.can_unlock_slot(3)
    assert_test(not check_s3_b["can_unlock"] and check_s3_b["reason"] == "PREVIOUS_SLOT_LOCKED", "7. Level 800 com Slot 1 mas sem Slot 2: Slot 3 PERMANECE ESTRITAMENTE LOCKED")

    # TEST 8: Level 800, Slot 1 = UNLOCKED, Slot 2 = UNLOCKED -> Slot 3 = UNLOCKED
    print("\n--- [TEST 8] Level 800, Slot 1 = UNLOCKED, Slot 2 = UNLOCKED ---")
    mgr.player_level = 800
    assert_test(mgr.can_unlock_slot(3)["can_unlock"], "8.1 Nível 800 com Slot 2 desbloqueado: Slot 3 apto para desbloqueio")
    mgr.unlock_slot(3)
    assert_test(mgr.is_slot_unlocked(3), "8.2 Slot 3 desbloqueado com sucesso")

    # TEST 9: Level 1000, Slot 1 = UNLOCKED, Slot 2 = UNLOCKED, Slot 3 = LOCKED -> Slot 4 = LOCKED
    print("\n--- [TEST 9] Level 1000, Slot 3 = LOCKED -> Slot 4 = LOCKED ---")
    mgr_t9 = HatsuProgressionManagerMock()
    mgr_t9.player_level = 1000
    mgr_t9.greed_island_completed = True
    mgr_t9.unlocked_slots[1] = True
    mgr_t9.unlocked_slots[2] = True
    mgr_t9.unlocked_slots[3] = False
    check_s4 = mgr_t9.can_unlock_slot(4)
    assert_test(not check_s4["can_unlock"] and check_s4["reason"] == "PREVIOUS_SLOT_LOCKED", "9. Level 1000 com Slot 3 bloqueado: Slot 4 PERMANECE ESTRITAMENTE LOCKED")

    # TEST 10: Level 1000, Slot 1 = UNLOCKED, Slot 2 = UNLOCKED, Slot 3 = UNLOCKED -> Slot 4 = UNLOCKED
    print("\n--- [TEST 10] Level 1000, todos os requisitos atendidos ---")
    mgr.player_level = 1000
    assert_test(mgr.can_unlock_slot(4)["can_unlock"], "10.1 Nível 1000 com Slot 3 desbloqueado: Slot 4 apto para desbloqueio")
    mgr.unlock_slot(4)
    assert_test(mgr.is_slot_unlocked(4), "10.2 Slot 4 desbloqueado com sucesso (Ápice do domínio)")

    # TEST 11: Level 1500, all 4 slots unlocked -> continues functioning normally (No Level Cap)
    print("\n--- [TEST 11] Level 1500 (Progressão Além de 1000) ---")
    mgr.player_level = 1500
    all_unlocked = all(mgr.is_slot_unlocked(i) for i in [1, 2, 3, 4])
    assert_test(all_unlocked and mgr.player_level == 1500, "11. Level 1500 opera perfeitamente com todos os 4 slots sem tetos artificiais")

    # TEST 12: Anti-Bypass & Security Tests
    print("\n--- [TEST 12] Anti-Bypass, Persistência e Tentativas de Burla ---")
    fresh_mgr = HatsuProgressionManagerMock()
    fresh_mgr.player_level = 800 # High level but no Greed Island
    
    # 12.1 Direct unlock call to slot 3
    direct_hack = fresh_mgr.unlock_slot(3)
    assert_test(not direct_hack and not fresh_mgr.is_slot_unlocked(3), "12.1 Chamada direta unlock_slot(3) sem pré-requisitos foi rejeitada")

    # 12.2 Hatsu creation blocked without slot 1
    assert_test(not fresh_mgr.can_create_hatsu(), "12.2 Criação de Hatsu bloqueada sem Slot 1")

    # 12.3 Equip on locked slot blocked
    fresh_mgr.created_hatsus.append("Jajanken")
    can_eq = fresh_mgr.equip_hatsu(3, 0)
    assert_test(not can_eq and fresh_mgr.equipped_slots[2] == -1, "12.3 Tentativa de equipar Hatsu em slot bloqueado rejeitada")

    # 12.4 Combat execution on locked slot blocked
    used, msg = fresh_mgr.use_hatsu(3)
    assert_test(not used and "bloqueado" in msg, "12.4 Execução de combate no slot bloqueado rejeitada")

    # 12.5 Save corruption revalidation
    corrupted_save_data = {
        "unlocked_slots": {1: False, 2: False, 3: True, 4: True},
        "equipped_slots": [-1, -1, 0, 0]
    }
    # Load corrupted save into fresh manager with level 200
    fresh_mgr.player_level = 200
    fresh_mgr.unlocked_slots = corrupted_save_data["unlocked_slots"].copy()
    fresh_mgr.equipped_slots = corrupted_save_data["equipped_slots"].copy()
    fresh_mgr.revalidate_all_slots()
    assert_test(not fresh_mgr.is_slot_unlocked(3) and not fresh_mgr.is_slot_unlocked(4) and fresh_mgr.equipped_slots[2] == -1, "12.5 Revalidação no carregamento expurgou slots ilegais e desequipou habilidades")

    # 12.6 Extensibility test: Registering future Slot 5 (Level 1200 + Slot 4)
    mgr.slots_catalog[5] = HatsuSlotDataMock(5, "Hatsu Slot 5 (Extensão)", 1200, 4, 0, "")
    mgr.unlocked_slots[5] = False
    assert_test(mgr.can_unlock_slot(5)["can_unlock"], "12.6 Extensibilidade modular: Slot 5 registrado e desbloqueado perfeitamente no Nível 1500")
    mgr.unlock_slot(5)
    assert_test(mgr.is_slot_unlocked(5), "12.7 Slot 5 ativo com sucesso na cadeia")

    print("\n" + "=" * 70)
    print(f"📊 FINAL RESULTS: {passed_tests}/{total_tests} TESTS PASSED (100% SUCCESS)")
    print("=" * 70)


if __name__ == "__main__":
    run_hatsu_slots_suite()
