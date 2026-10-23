extends Node2D

const EffectTree = preload("res://scripts/systems/hatsu/HatsuEffectTree.gd")
const DB = preload("res://scripts/systems/hatsu/HatsuEffectTreeDatabase.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== HATSU EFFECT TREE (Creator radial) ===")
	_test_db_compact()
	_test_budget_and_allocate()
	_test_off_category_cost()
	_test_apply_to_hatsu()
	_test_combat_bundle_and_commitment()
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
	for nid in nodes.keys():
		var c: int = int(nodes[nid].get("categoria", -1))
		if c >= 0:
			cats[c] = true
	_ok(cats.size() == 6, "6 categorias Nen (%d)" % cats.size())


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
	_ok(pts >= 3 and pts <= 28, "budget em faixa (%d)" % pts)
	var tree := EffectTree.new()
	tree.reset(pts, int(HatsuData.Categoria.INTENSIFICACAO))
	_ok(tree.obter_saldo() == pts, "saldo inicial")
	# Aloca hub intensificação
	var hub := &"hx_c0_hub"
	_ok(tree.pode_alocar(hub).get("ok", false), "hub intensificação disponível")
	_ok(tree.alocar(hub), "alocou hub")
	_ok(tree.obter_saldo() < pts, "saldo caiu")


func _test_off_category_cost() -> void:
	print("\n[3] Custo maior fora da categoria")
	var tree := EffectTree.new()
	tree.reset(20, int(HatsuData.Categoria.INTENSIFICACAO))
	var cost_same: int = tree.obter_custo_efetivo(&"hx_c0_hub")
	var cost_opp: int = tree.obter_custo_efetivo(&"hx_c3_hub") # conjuração vs intensificação
	_ok(cost_opp > cost_same, "raio oposto mais caro (%d > %d)" % [cost_opp, cost_same])


func _test_apply_to_hatsu() -> void:
	print("\n[4] Aplicar efeitos no HatsuData")
	var tree := EffectTree.new()
	tree.reset(20, int(HatsuData.Categoria.EMISSAO))
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
	_ok(h.alcance > alcance_before or h.forma == HatsuData.Forma.PROJETIL, "árvore alterou alcance/forma (alc %.0f→%.0f forma=%d)" % [alcance_before, h.alcance, int(h.forma)])
	_ok("eft:tree" in h.tags, "tag eft:tree")


func _test_combat_bundle_and_commitment() -> void:
	print("\n[5] Compromisso + pacote de combate")
	var tree := EffectTree.new()
	tree.reset(24, int(HatsuData.Categoria.EMISSAO))
	_ok(not tree.tem_compromisso_categoria(), "sem compromisso no início")
	var em_hub := StringName("hx_c%d_hub" % int(HatsuData.Categoria.EMISSAO))
	_ok(tree.alocar(em_hub), "hub emissão")
	_ok(tree.tem_compromisso_categoria(), "compromisso após hub")
	# Cadeia até rajada dupla (n0..n3)
	for i in range(4):
		var nid := StringName("hx_c%d_n%d" % [int(HatsuData.Categoria.EMISSAO), i])
		if tree.pode_alocar(nid).get("ok", false):
			tree.alocar(nid)
	var h := HatsuData.new()
	h.categoria = HatsuData.Categoria.EMISSAO
	h.poder_base = 40.0
	h.forma = HatsuData.Forma.TOQUE
	tree.aplicar_em_hatsu(h)
	var combat: Dictionary = h.parametros_conceito.get("effect_tree", {})
	var has_multi := int(combat.get("multishot", 0)) >= 2 or ("multishot" in h.tags)
	_ok(has_multi or h.forma == HatsuData.Forma.PROJETIL, "pacote combate/multishot ou forma projetil")
	# Ramo lateral existe
	var side0 := StringName("hx_c%d_s0" % int(HatsuData.Categoria.EMISSAO))
	_ok(tree.nodes.has(side0), "ramo lateral s0 existe")

