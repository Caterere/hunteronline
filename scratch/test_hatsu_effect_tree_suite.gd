extends Node2D

const EffectTree = preload("res://scripts/systems/hatsu/HatsuEffectTree.gd")
const DB = preload("res://scripts/systems/hatsu/HatsuEffectTreeDatabase.gd")
const Cfg = preload("res://scripts/systems/hatsu/HatsuConfig.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== HATSU EFFECT TREE (Creator radial + evolve) ===")
	_test_db_compact()
	_test_budget_and_allocate()
	_test_off_category_cost()
	_test_apply_to_hatsu()
	_test_combat_bundle_and_commitment()
	_test_ring_gates()
	_test_deepen_points_and_snapshot()
	_test_max_budget_scarce()
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


func _test_db_compact() -> void:
	print("\n[1] DB compacta")
	var nodes: Dictionary = DB.build_tree()
	_ok(nodes.size() >= 30 and nodes.size() <= 80, "nós entre 30–80 (got %d)" % nodes.size())
	_ok(nodes.has(&"hx_center"), "tem centro")
	var cats := {}
	var has_ring3 := false
	for nid in nodes.keys():
		var c: int = int(nodes[nid].get("categoria", -1))
		if c >= 0:
			cats[c] = true
		if int(nodes[nid].get("ring", 0)) >= 3:
			has_ring3 = true
	_ok(cats.size() == 6, "6 categorias Nen (%d)" % cats.size())
	_ok(has_ring3, "existe anel 3 (keystone)")


func _test_budget_and_allocate() -> void:
	print("\n[2] Budget + alocação")
	var h := HatsuData.new()
	h.poder_base = 40.0
	h.custo_aura_base = 40.0
	h.cooldown_base = 12.0
	h.condicoes = [HatsuData.Condicao.PARADO_CANALIZACAO, HatsuData.Condicao.AUTO_DANO]
	h.modular_restrictions = [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE]
	h.preparation_steps = [
		{"id": "a", "description": "p", "action_required": "x", "time_required": 0.0, "credit_value": 30.0},
		{"id": "b", "description": "p2", "action_required": "x", "time_required": 0.0, "credit_value": 30.0}
	]
	var pts: int = EffectTree.calcular_budget_de_hatsu(h)
	_ok(pts >= Cfg.TREE_BUDGET_MIN and pts <= Cfg.TREE_BUDGET_MAX, "budget em faixa dura (%d)" % pts)
	var tree := EffectTree.new()
	tree.reset(pts, int(HatsuData.Categoria.INTENSIFICACAO), 40, 50.0)
	_ok(tree.obter_saldo() == pts, "saldo inicial")
	var hub := &"hx_c0_hub"
	_ok(tree.pode_alocar(hub).get("ok", false), "hub intensificação disponível")
	_ok(tree.alocar(hub), "alocou hub")
	_ok(tree.obter_saldo() < pts, "saldo caiu")


func _test_off_category_cost() -> void:
	print("\n[3] Custo maior fora da categoria")
	var tree := EffectTree.new()
	tree.reset(20, int(HatsuData.Categoria.INTENSIFICACAO), 40, 50.0)
	var cost_same: int = tree.obter_custo_efetivo(&"hx_c0_hub")
	var cost_opp: int = tree.obter_custo_efetivo(&"hx_c3_hub")
	_ok(cost_opp >= cost_same + 2, "raio oposto bem mais caro (%d >= %d+2)" % [cost_opp, cost_same])


func _test_apply_to_hatsu() -> void:
	print("\n[4] Aplicar efeitos no HatsuData")
	var tree := EffectTree.new()
	tree.reset(20, int(HatsuData.Categoria.EMISSAO), 40, 50.0)
	var em_hub := StringName("hx_c%d_hub" % int(HatsuData.Categoria.EMISSAO))
	var em_n0 := StringName("hx_c%d_n0" % int(HatsuData.Categoria.EMISSAO))
	tree.alocar(em_hub)
	tree.alocar(em_n0)
	var h := HatsuData.new()
	h.nome = "Teste Emissão"
	h.categoria = HatsuData.Categoria.EMISSAO
	h.poder_base = 40.0
	h.alcance = 60.0
	h.forma = HatsuData.Forma.TOQUE
	var alcance_before := h.alcance
	tree.aplicar_em_hatsu(h)
	_ok(h.alcance > alcance_before or h.forma == HatsuData.Forma.PROJETIL, "árvore alterou alcance/forma")
	_ok("eft:tree" in h.tags, "tag eft:tree")
	_ok(h.parametros_conceito.get("effect_tree", {}).has("forge_snapshot"), "forge_snapshot salvo")


func _test_combat_bundle_and_commitment() -> void:
	print("\n[5] Compromisso + pacote de combate")
	var tree := EffectTree.new()
	tree.reset(24, int(HatsuData.Categoria.EMISSAO), 40, 50.0)
	_ok(not tree.tem_compromisso_categoria(), "sem compromisso no início")
	var em_hub := StringName("hx_c%d_hub" % int(HatsuData.Categoria.EMISSAO))
	_ok(tree.alocar(em_hub), "hub emissão")
	_ok(tree.tem_compromisso_categoria(), "compromisso após hub")
	for i in range(4):
		var nid := StringName("hx_c%d_n%d" % [int(HatsuData.Categoria.EMISSAO), i])
		if tree.pode_alocar(nid).get("ok", false):
			tree.alocar(nid)
	var h := HatsuData.new()
	h.categoria = HatsuData.Categoria.EMISSAO
	h.poder_base = 40.0
	h.forma = HatsuData.Forma.TOQUE
	tree.aplicar_em_hatsu(h)
	var combat: Dictionary = h.parametros_conceito.get("effect_tree", {}).get("combat", {})
	if combat.is_empty():
		combat = h.parametros_conceito.get("effect_tree", {})
	var has_multi := int(combat.get("multishot", 0)) >= 2 or ("multishot" in h.tags)
	_ok(has_multi or h.forma == HatsuData.Forma.PROJETIL, "pacote combate/multishot ou forma projetil")
	var side0 := StringName("hx_c%d_s0" % int(HatsuData.Categoria.EMISSAO))
	_ok(tree.nodes.has(side0), "ramo lateral s0 existe")


func _test_ring_gates() -> void:
	print("\n[6] Gates de anel (Lv + mastery)")
	var tree := EffectTree.new()
	tree.reset(30, int(HatsuData.Categoria.INTENSIFICACAO), 1, 0.0)
	tree.alocar(&"hx_c0_hub")
	tree.alocar(&"hx_c0_n0")
	# n2 is ring 2 — blocked at lv1 mastery0
	var mid := &"hx_c0_n2"
	var blocked := not bool(tree.pode_alocar(mid).get("ok", false))
	_ok(blocked, "anel 2 bloqueado no Lv1/M0")
	tree.configurar_contexto(20, 25.0)
	# need n1 first
	tree.alocar(&"hx_c0_n1")
	_ok(bool(tree.pode_alocar(mid).get("ok", false)), "anel 2 libera com Lv20 ou M25")
	# keystone needs both
	tree.configurar_contexto(40, 10.0)
	for i in range(2, 4):
		var nid := StringName("hx_c0_n%d" % i)
		if tree.pode_alocar(nid).get("ok", false):
			tree.alocar(nid)
	var key := &"hx_c0_n4"
	var key_blocked := not bool(tree.pode_alocar(key).get("ok", false))
	_ok(key_blocked, "keystone bloqueado sem mastery alta")
	tree.configurar_contexto(40, 45.0)
	_ok(bool(tree.pode_alocar(key).get("ok", false)), "keystone libera com Lv+Mastery")


func _test_deepen_points_and_snapshot() -> void:
	print("\n[7] Deepen pts + snapshot sem duplicar poder")
	var pts0 := EffectTree.calcular_pontos_deepen(50.0, 50.0, 0)
	_ok(pts0 == 0, "sem ganho de crédito = 0 pts deepen")
	var pts1 := EffectTree.calcular_pontos_deepen(50.0, 80.0, 0)
	_ok(pts1 > 0 and pts1 < 10, "deepen rende pouco (%d)" % pts1)
	var pts2 := EffectTree.calcular_pontos_deepen(50.0, 80.0, 3)
	_ok(pts2 <= pts1, "deepens seguintes menos eficientes (%d<=%d)" % [pts2, pts1])

	var tree := EffectTree.new()
	tree.reset(12, int(HatsuData.Categoria.INTENSIFICACAO), 40, 50.0)
	tree.alocar(&"hx_c0_hub")
	tree.alocar(&"hx_c0_n0")
	var h := HatsuData.new()
	h.poder_base = 40.0
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	tree.aplicar_em_hatsu(h)
	var poder1 := h.poder_base
	tree.aplicar_em_hatsu(h)
	_ok(is_equal_approx(h.poder_base, poder1), "reapply não duplica poder (%.1f==%.1f)" % [h.poder_base, poder1])


func _test_max_budget_scarce() -> void:
	print("\n[8] Maximizar é escasso")
	_ok(Cfg.TREE_BUDGET_MAX <= 16, "teto de budget baixo (%d)" % Cfg.TREE_BUDGET_MAX)
	var nodes: Dictionary = DB.build_tree()
	var cost_one_spoke := 0
	var cat := int(HatsuData.Categoria.INTENSIFICACAO)
	for nid in nodes.keys():
		var def: Dictionary = nodes[nid]
		if int(def.get("categoria", -1)) == cat:
			cost_one_spoke += int(def.get("cost", 0))
	_ok(cost_one_spoke > Cfg.TREE_BUDGET_MAX, "um raio completo custa mais que o teto (%d > %d)" % [cost_one_spoke, Cfg.TREE_BUDGET_MAX])
