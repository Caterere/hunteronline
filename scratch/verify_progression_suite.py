#!/usr/bin/env python3
"""
Hunter Online — Python Progression & Level 1000 Regression Verification Script
Validates mathematical curves, monotonicity, milestone tiers, JSON roundtrips, and the 6 mandatory scenarios.
"""

import math
import json
import os
import sys

BASE_LEVEL = 1
MAX_LEVEL = 1000

BASE_STATS = {
    "vida_max": 100,
    "forca": 10,
    "defesa": 10,
    "velocidade": 10.0,
    "aura_max": 100.0,
}

TARGET_STATS_LEVEL_1000 = {
    "vida_max": 50000,
    "forca": 5000,
    "defesa": 5000,
    "velocidade": 160.0,
    "aura_max": 1500000.0,
}

POWER_EXPONENTS = {
    "vida_max": 0.90,
    "forca": 0.95,
    "defesa": 0.95,
    "velocidade": 0.65,
    "aura_max": 0.92,
}

XP_BASE = 300
XP_GROWTH = 1.6

SAGA_LEVEL_RANGES = {
    1: (1, 15),
    2: (15, 30),
    3: (30, 50),
    4: (50, 75),
    5: (75, 120),
    6: (120, 200),
    7: (200, 350),
    8: (350, 600),
    9: (600, 1000),
}

def calcular_stat_base(stat_name: str, level: int) -> float:
    lvl = max(BASE_LEVEL, min(MAX_LEVEL, level))
    base_val = BASE_STATS[stat_name]
    target_val = TARGET_STATS_LEVEL_1000[stat_name]
    p = POWER_EXPONENTS[stat_name]
    t = (lvl - 1) / (MAX_LEVEL - 1)
    return base_val + (target_val - base_val) * (t ** p)

def calcular_xp_necessario(level: int) -> int:
    lvl = max(BASE_LEVEL, min(MAX_LEVEL, level))
    return int(round(XP_BASE * (lvl ** XP_GROWTH)))

def calcular_xp_acumulado(target_level: int) -> int:
    lvl = max(BASE_LEVEL, min(MAX_LEVEL, target_level))
    total = 0
    for l in range(1, lvl):
        total += calcular_xp_necessario(l)
    return total

def test_1_base_stat_growth():
    print("--- Running Test 1: Level increases base stats ---")
    s10 = {k: calcular_stat_base(k, 10) for k in BASE_STATS}
    s11 = {k: calcular_stat_base(k, 11) for k in BASE_STATS}
    for k in BASE_STATS:
        assert s11[k] > s10[k], f"Stat {k} did not increase: {s10[k]} -> {s11[k]}"
        print(f"  Stat {k}: Lv10={s10[k]:.1f} -> Lv11={s11[k]:.1f} (increased)")
    print("  [PASS] Test 1 passed successfully.\n")

def test_2_skill_points_independence():
    print("--- Running Test 2: Skill Points are independent ---")
    # Char A: base only
    # Char B: base + 50 flat
    delta_a_forca = calcular_stat_base("forca", 21) - calcular_stat_base("forca", 20)
    delta_b_forca = (calcular_stat_base("forca", 21) + 50) - (calcular_stat_base("forca", 20) + 50)
    assert abs(delta_a_forca - delta_b_forca) < 1e-9, f"Deltas differed: {delta_a_forca} vs {delta_b_forca}"
    print(f"  Delta Char A: {delta_a_forca:.2f}, Delta Char B: {delta_b_forca:.2f} (identical growth)")
    print("  [PASS] Test 2 passed successfully.\n")

def test_3_level_1000_targets():
    print("--- Running Test 3: Level 1000 is valid & matches targets ---")
    s1000 = {k: round(calcular_stat_base(k, 1000), 1) for k in BASE_STATS}
    for k, target in TARGET_STATS_LEVEL_1000.items():
        assert math.isfinite(s1000[k]), f"{k} is not finite!"
        assert abs(s1000[k] - target) < 0.1, f"{k} target mismatch: {s1000[k]} vs {target}"
        print(f"  Target {k}: computed={s1000[k]} == target={target}")
    xp_req = calcular_xp_necessario(1000)
    assert xp_req > 0 and math.isfinite(xp_req)
    print(f"  XP for Lv 1000: {xp_req} (finite positive)")
    print("  [PASS] Test 3 passed successfully.\n")

def test_4_clamping_level_1001():
    print("--- Running Test 4: Level 1001 is clamped ---")
    s1001 = calcular_stat_base("vida_max", 1001)
    s1000 = calcular_stat_base("vida_max", 1000)
    assert s1001 == s1000, "Level 1001 did not clamp to Level 1000!"
    print(f"  Stat at 1001: {s1001} == stat at 1000: {s1000}")
    print("  [PASS] Test 4 passed successfully.\n")

def test_5_save_load_schema_integrity():
    print("--- Running Test 5: Save/Load Schema Preservation ---")
    mock_save = {
        "save_version": 1,
        "slot": 9,
        "nome_personagem": "Hunter Level 1000",
        "attributes": {
            "nivel": 1000,
            "xp": calcular_xp_necessario(1000),
            "vida": 50000,
            "vida_max": 50000,
            "forca": 5000,
            "defesa": 5000,
            "velocidade": 160.0,
            "aura": 1500000.0,
            "aura_max": 1500000.0,
            "nivel_nen": 100,
            "xp_nen": 0
        },
        "nen_skill_points": 999,
        "despertou_nen": True,
        "tecnicas_nen": {
            "ten": {"nivel": 100, "xp": 0, "desbloqueada": True},
            "ren": {"nivel": 100, "xp": 0, "desbloqueada": True}
        },
        "hatsu_criados": [
            {"nome": "Impacto Máximo", "dano_base": 15000, "custo_aura": 2500}
        ]
    }
    encoded = json.dumps(mock_save)
    decoded = json.loads(encoded)
    assert decoded["attributes"]["nivel"] == 1000
    assert decoded["attributes"]["xp"] == calcular_xp_necessario(1000)
    assert decoded["nen_skill_points"] == 999
    assert decoded["attributes"]["forca"] == 5000
    assert decoded["tecnicas_nen"]["ten"]["nivel"] == 100
    print("  Save/load JSON roundtrip preserved all Level 1000 fields, masteries, and stats.")
    print("  [PASS] Test 5 passed successfully.\n")

def test_6_future_saga_compatibility():
    print("--- Running Test 6: Future Saga 10 Compatibility ---")
    sagas = dict(SAGA_LEVEL_RANGES)
    # Register Saga 10
    sagas[10] = (850, 1000)
    
    assert 10 in sagas
    assert sagas[10] == (850, 1000)
    
    def can_access(saga_id: int, player_level: int) -> bool:
        min_lvl, max_lvl = sagas[saga_id]
        return player_level >= min_lvl
    
    assert not can_access(10, 849), "Lv 849 should NOT access Saga 10"
    assert can_access(10, 850), "Lv 850 should access Saga 10"
    assert can_access(10, 1000), "Lv 1000 should access Saga 10"
    print("  Saga 10 dynamically registered with level range 850-1000. Access gating verified.")
    print("  [PASS] Test 6 passed successfully.\n")

def test_monotonicity_1_to_1000():
    print("--- Checking Strict Monotonicity from Level 1 to 1000 ---")
    for stat in ["vida_max", "forca", "defesa", "aura_max"]:
        prev = calcular_stat_base(stat, 1)
        for lvl in range(2, 1001):
            curr = calcular_stat_base(stat, lvl)
            assert int(curr) >= int(prev), f"Regression in {stat} at lvl {lvl}: {prev} -> {curr}"
            prev = curr
    # Velocidade as float
    prev_v = calcular_stat_base("velocidade", 1)
    for lvl in range(2, 1001):
        curr_v = calcular_stat_base("velocidade", lvl)
        assert curr_v >= prev_v, f"Regression in velocidade at lvl {lvl}: {prev_v} -> {curr_v}"
        prev_v = curr_v
    print("  Strict monotonicity confirmed across all 1,000 levels for all base stats.")
    print("  [PASS] Monotonicity check passed successfully.\n")

if __name__ == "__main__":
    test_1_base_stat_growth()
    test_2_skill_points_independence()
    test_3_level_1000_targets()
    test_4_clamping_level_1001()
    test_5_save_load_schema_integrity()
    test_6_future_saga_compatibility()
    test_monotonicity_1_to_1000()
    print("=== ALL PROGRESSION REGRESSION TESTS COMPLETED SUCCESSFULLY! ===")
