extends Node2D

const EffectTree = preload("res://scripts/systems/hatsu/HatsuEffectTree.gd")
const Cfg = preload("res://scripts/systems/hatsu/HatsuConfig.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== HATSU DEEPEN + BOND ===")
	_test_can_deepen_gates()
	_test_bond_chapters()
	_test_finalizar_aprofundamento()
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


func _make_hatsu() -> HatsuData:
	var h := HatsuData.new()
	h.gerar_novo_id()
	h.nome = "Pacto de Teste"
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.poder_base = 40.0
	h.mastery = 25.0
	h.is_draft = false
	h.condicoes = [HatsuData.Condicao.PARADO_CANALIZACAO]
	h.modular_restrictions = [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE]
	h.preparation_steps = [
		{"id": "a", "description": "prep", "action_required": "x", "time_required": 0.0, "credit_value": 40.0}
	]
	h.parametros_conceito = {
		"effect_tree": {
			"allocated": ["hx_center", "hx_c0_hub", "hx_c0_n0"],
			"budget_total": 6,
			"budget_spent": 2,
			"primary_category": int(HatsuData.Categoria.INTENSIFICACAO),
			"deepen_count": 0,
			"bond_uses": 5,
			"forge_snapshot": {"poder_base": 40.0, "alcance": 120.0, "cura_base": 0.0, "raio": 50.0, "duracao": 5.0, "custo_aura_base": 20.0, "cooldown_base": 3.0, "forma": 0, "activation_type": 0, "stun_duracao": 1.5, "aura_drain_per_sec": 0.0, "exclusive_group": "", "concurrent_allowed": true, "arquetipo": 0, "is_storage_hatsu": false, "storage_capacity": 3, "core_component": 0, "absorption_rate": 0.05, "categoria": 0, "objetivo": 0}
		}
	}
	return h


func _test_can_deepen_gates() -> void:
	print("\n[1] can_deepen gates")
	if HatsuProgressionManager == null:
		_ok(false, "HatsuProgressionManager ausente")
		return
	HatsuProgressionManager.archive.clear()
	var h := _make_hatsu()
	h.mastery = 5.0
	HatsuProgressionManager.archive.append(h)
	if PlayerData != null:
		PlayerData.attributes["gold"] = 99999
	var low := HatsuProgressionManager.can_deepen_hatsu(h.hatsu_id)
	_ok(not low.get("can_deepen", true), "bloqueia mastery baixa")
	h.mastery = 25.0
	var ok := HatsuProgressionManager.can_deepen_hatsu(h.hatsu_id)
	_ok(ok.get("can_deepen", false), "libera com mastery suficiente")


func _test_bond_chapters() -> void:
	print("\n[2] Capítulos de vínculo")
	_ok(EffectTree.obter_bond_chapter(0) == 1, "capítulo 1 inicial")
	_ok(EffectTree.obter_bond_chapter(Cfg.BOND_USES_PER_CHAPTER) == 2, "capítulo 2")
	_ok(EffectTree.bond_titulo(5) == "Lenda Pessoal", "título ápice")


func _test_finalizar_aprofundamento() -> void:
	print("\n[3] finalizar aprofundamento")
	if HatsuProgressionManager == null:
		_ok(false, "manager ausente")
		return
	HatsuProgressionManager.archive.clear()
	HatsuProgressionManager.last_deepen_timestamps.clear()
	var h := _make_hatsu()
	h.mastery = 30.0
	HatsuProgressionManager.archive.append(h)
	if PlayerData != null:
		PlayerData.attributes["gold"] = 99999
	var before := h.calcular_limitation_credits()
	# voto mais pesado
	h.condicoes.append(HatsuData.Condicao.AUTO_DANO)
	h.preparation_steps.append({
		"id": "b", "description": "voto", "action_required": "x", "time_required": 0.0, "credit_value": 50.0
	})
	var tree := EffectTree.new()
	tree.configurar_contexto(40, 30.0, 5, 0)
	tree.restaurar_alocacao(h.parametros_conceito["effect_tree"])
	var pts := EffectTree.calcular_pontos_deepen(before, h.calcular_limitation_credits(), 0)
	tree.expandir_budget(pts)
	var cob := HatsuProgressionManager.cobrar_deepen_jenny(h.hatsu_id)
	_ok(cob.get("success", false), "cobrou jenny deepen")
	var res := HatsuProgressionManager.finalizar_aprofundamento(h, before, tree)
	_ok(res.get("success", false), "finalizou deepen (%s)" % str(res.get("reason", res.get("message", ""))))
	_ok(int(h.parametros_conceito["effect_tree"].get("deepen_count", 0)) == 1, "deepen_count=1")
