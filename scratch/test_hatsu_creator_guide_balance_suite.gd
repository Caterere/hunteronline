extends Node2D

## Bases guiadas + juiz de complexidade / gates de nível.

const Judge = preload("res://scripts/systems/hatsu/HatsuComplexityJudge.gd")
const GuideBases = preload("res://resource/hatsu/HatsuGuideBases.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== HATSU CREATOR GUIDE + BALANCE ===")
	_test_bases_catalog()
	_test_level_gates()
	_test_grimorio_tradeoff()
	_test_validate_blocks_high_rank()
	_test_guide_text()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_bases_catalog() -> void:
	print("\n[1] Bases guiadas")
	var allb: Array = GuideBases.obter_todas()
	_ok(allb.size() >= 8, ">=8 bases (%d)" % allb.size())
	var names := ""
	for b in allb:
		names += str(b.get("nome", "")).to_lower() + "|"
	_ok(not ("skill hunter" in names or "jajanken" in names or "godspeed" in names or "guanyin" in names),
		"sem nomes canônicos nas bases")
	_ok(GuideBases.obter_por_id("grimorio_do_colecionador").get("preparation_steps_base", 0) == 4,
		"grimório base = 4 passos")


func _test_level_gates() -> void:
	print("\n[2] Gates de nível")
	_ok(Judge.max_rank_for_player_level(1) == Judge.Rank.FRACO, "Lv1 → Fraco")
	_ok(Judge.max_rank_for_player_level(20) == Judge.Rank.MEDIANO, "Lv20 → Mediano")
	_ok(Judge.max_rank_for_player_level(40) == Judge.Rank.FORTE, "Lv40 → Forte")
	_ok(Judge.max_rank_for_player_level(60) == Judge.Rank.LENDARIO, "Lv60 → Lendário")
	PlayerData.reset()
	PlayerData.attributes["nivel"] = 10
	var unlocked = GuideBases.obter_desbloqueadas_para_jogador()
	var has_lendario := false
	for b in unlocked:
		if int(b.get("tier", 0)) == int(GuideBases.Tier.LENDARIO):
			has_lendario = true
	_ok(not has_lendario, "Lv10 não desbloqueia bases lendárias")


func _test_grimorio_tradeoff() -> void:
	print("\n[3] Tradeoff grimório (−1 passo = mais fraco)")
	var base = GuideBases.obter_por_id("grimorio_do_colecionador")
	var h_full := HatsuData.new()
	GuideBases.aplicar_base_em_hatsu(base, h_full)
	var poder_full := h_full.poder_base
	var h_weak := HatsuData.new()
	GuideBases.aplicar_base_em_hatsu(base, h_weak)
	# Remove 1 passo
	if h_weak.preparation_steps.size() > 0:
		h_weak.preparation_steps.pop_back()
	var trade = Judge.apply_guide_tradeoffs(h_weak)
	_ok(bool(trade.get("applied", false)), "tradeoff aplicado")
	_ok(h_weak.poder_base < poder_full, "poder caiu (%.0f → %.0f)" % [poder_full, h_weak.poder_base])
	_ok(float(trade.get("power_mult", 1.0)) < 1.0, "power_mult < 1")


func _test_validate_blocks_high_rank() -> void:
	print("\n[4] Validador bloqueia rank acima do nível")
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.desbloquear_hatsu_creator()
	PlayerData.attributes["nivel"] = 5
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.INTENSIFICACAO
	var h := HatsuData.new()
	h.nome = "Explosão Absurda"
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.forma = HatsuData.Forma.AREA
	h.objetivo = HatsuData.ObjetivoPrincipal.DANO
	h.poder_base = 280.0
	h.custom_damage = 280.0
	h.custo_aura_base = 10.0
	h.cooldown_base = 1.0
	h.raio = 200.0
	# Pouquíssimas limitações → abusivo / overpowered
	var v = HatsuManager.validate_hatsu(h, {"nivel": 5, "nivel_nen": 1, "afinidade_nen": PlayerData.afinidade_nen})
	_ok(str(v.get("status", "")) != "VALID", "Lv5 não forja explosão abusiva (status=%s)" % str(v.get("status", "")))

	# Técnica fraca balanceada deve passar no Lv5 se créditos ok
	var h2 := HatsuData.new()
	h2.nome = "Soco Leve"
	h2.categoria = HatsuData.Categoria.INTENSIFICACAO
	h2.forma = HatsuData.Forma.TOQUE
	h2.objetivo = HatsuData.ObjetivoPrincipal.DANO
	h2.poder_base = 35.0
	h2.custo_aura_base = 30.0
	h2.cooldown_base = 8.0
	h2.condicoes = [HatsuData.Condicao.PARADO_CANALIZACAO]
	h2.modular_restrictions = [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE]
	h2.preparation_steps = [{
		"id": "p1", "description": "prep", "action_required": "X", "time_required": 0.0, "credit_value": 40.0
	}]
	var v2 = HatsuManager.validate_hatsu(h2, {"nivel": 5, "nivel_nen": 1, "afinidade_nen": PlayerData.afinidade_nen})
	_ok(str(v2.get("status", "")) in ["VALID", "INEFFICIENT"], "técnica fraca ok no Lv5 (%s)" % str(v2.get("status", "")))


func _test_guide_text() -> void:
	print("\n[5] Guia do jogador")
	var g := Judge.obter_guia_jogador()
	_ok("Créditos" in g and "Lendário" in g and "Bases Guiadas" in g, "guia contém seções chave")
	_ok(HatsuConfig.CREATOR_RANK_LEVEL_LENDARIO == 55, "config lendário Lv55")
