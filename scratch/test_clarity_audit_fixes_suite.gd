extends SceneTree

# ============================================================
# Suite: Clarity audit fixes (static source + light runtime)
# ============================================================

var _passed: int = 0
var _failed: int = 0


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  ✅ PASS: ", msg)
	else:
		_failed += 1
		print("  ❌ FAIL: ", msg)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _initialize() -> void:
	print("\n=== CLARITY AUDIT FIXES SUITE ===\n")

	print("[1] ItemExplainKit exists & API")
	var kit_src := _read("res://ui/common/ItemExplainKit.gd")
	_assert(not kit_src.is_empty(), "ItemExplainKit.gd presente")
	_assert("resolver_item" in kit_src, "API resolver_item")
	_assert("formatar_detalhes" in kit_src, "API formatar_detalhes")
	_assert("bonus_forca" in kit_src or "EquipmentData" in kit_src, "stats de equipamento")

	print("\n[2] Inventory + HunterMenu wiring")
	var inv := _read("res://ui/inventory/InventoryUI.gd")
	_assert("ItemExplainKit" in inv, "InventoryUI usa ItemExplainKit")
	_assert("ItemLoreTooltip" in inv, "InventoryUI usa ItemLoreTooltip")
	var hm := _read("res://ui/HunterMenu/HunterMenuUI.gd")
	_assert("ItemExplainKit" in hm, "HunterMenu inventário usa ItemExplainKit")
	_assert("Controles" in hm and "Itens" in hm and "Personagem" in hm, "Guia inclui categorias órfãs")
	_assert("notificar_guia_aberto" in hm, "Guia tab notifica abertura")
	_assert("nen_arvore" in hm, "Nen Tree dispara tip")

	print("\n[3] TutorialManager catalog + tips")
	var tut := _read("res://autoload/TutorialManager.gd")
	_assert("perfect_dodge_maestria" in tut, "artigo Perfect Dodge")
	_assert("nen_arvore_sp" in tut, "artigo Constelação Nen")
	_assert("sistemas_atalhos" in tut, "artigo atalhos")
	_assert("once_map" in tut, "anti-spam once_map")
	_assert("\"perfect_dodge\"" in tut or "'perfect_dodge'" in tut, "tip perfect_dodge")
	_assert("\"nen_arvore\"" in tut or "'nen_arvore'" in tut, "tip nen_arvore")

	print("\n[4] CombatSystem Perfect Dodge 30%")
	var combat := _read("res://scripts/combat/CombatSystem.gd")
	_assert("perfect_dodge" in combat, "dispara tip perfect_dodge")
	_assert("0.30" in combat, "recupera 30% aura")

	print("\n[5] XPSystem level-up clarity")
	var xp := _read("res://scripts/systems/XPSystem.gd")
	_assert("delta_txt" in xp or "partes_delta" in xp, "deltas de atributos")
	_assert("toast_msg" in xp and "SP" in xp, "toast com SP")

	print("\n[6] ComicBalloon tema Hunter")
	var ball := _read("res://scripts/ui/ComicBalloon.gd")
	_assert("0.74, 0.64, 0.44" in ball, "default pergaminho")
	_assert("0.48, 0.30, 0.12" in ball, "default borda madeira/ouro")

	print("\n[7] PlayerData knowledge toast title")
	var pd := _read("res://autoload/PlayerData.gd")
	_assert("obter_artigo" in pd, "toast usa título do catálogo")

	print("\n[8] PauseMenu + Status + NenTree")
	var pause := _read("res://ui/PauseMenu/PauseMenuUI.gd")
	_assert("Sistemas" in pause, "botão sistemas")
	_assert("Conquistas" in pause, "botão conquistas")
	var status := _read("res://ui/StatusMenu/StatusMenu.gd")
	_assert("Força↑" in status or "atributos" in status.to_lower(), "explicação de atributos")
	var nen := _read("res://ui/SkillTree/NenSkillTreeUI.gd")
	_assert("nen_arvore" in nen, "primeira abertura tip")

	print("\n[9] ItemLoreTooltip tema + stats")
	var tip := _read("res://ui/common/ItemLoreTooltip.gd")
	_assert("HunterUIStyle" in tip, "tooltip no tema Hunter")
	_assert("formatar_linha_stats" in tip or "ItemExplainKit" in tip, "mostra stats")

	print("\n=== RESULTADO: %d passed, %d failed ===" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
