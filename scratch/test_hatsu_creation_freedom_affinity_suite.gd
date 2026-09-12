extends Node

# ============================================================
# SUÍTE: HATSU — LIBERDADE DE FORÇA + AFINIDADE HxH
# ============================================================

var passados: int = 0
var totais: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("🧪 HATSU FREEDOM + AFFINITY SUITE")
	print("============================================================\n")

	_run("1. custom_damage livre aumenta demanda (sem hard-lock por categoria)", _t_slider_power)
	_run("2. Déficit exige votos/condições (créditos sobem ao pagar)", _t_forge_gate)
	_run("3. Catálogo ampliado cobre as 6 categorias", _t_catalog)
	_run("4. Hexágono de afinidade HxH (100/80/60/40)", _t_affinity)
	_run("5. criar_hatsu propaga custom_damage no poder final", _t_factory)
	_run("6. Off-type: Intensificação→Conjuração=60%, Emissão→Conjuração=40%", _t_offtype)

	print("\n============================================================")
	print("RESULTADO: %d / %d" % [passados, totais])
	print("============================================================\n")
	get_tree().quit(0 if passados == totais else 1)


func _run(nome: String, fn: Callable) -> void:
	totais += 1
	print("▶ ", nome)
	var ok: bool = fn.call()
	if ok:
		passados += 1
		print("  ✅ PASSOU\n")
	else:
		print("  ❌ FALHOU\n")


func _t_slider_power() -> bool:
	var fraco := HatsuManager.criar_hatsu(
		"Fraco", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE,
		[], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.NEN_PURO,
		HatsuData.Alvo.INIMIGO_UNICO, HatsuData.AlcanceTipo.MEDIO, HatsuData.ConsumoDesejado.MEDIO,
		"", HatsuData.Arquetipo.SIMPLES, Color(-1, -1, -1, -1), Color(-1, -1, -1, -1),
		HatsuData.EstiloVisual.PURO_PULSANTE, [], [], [], {}, false, 3, "PERMANENT", "OPEN_BOOK", [], "ANY",
		25.0
	)
	var lendario := HatsuManager.criar_hatsu(
		"Lendario", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE,
		[], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.NEN_PURO,
		HatsuData.Alvo.INIMIGO_UNICO, HatsuData.AlcanceTipo.MEDIO, HatsuData.ConsumoDesejado.MEDIO,
		"", HatsuData.Arquetipo.SIMPLES, Color(-1, -1, -1, -1), Color(-1, -1, -1, -1),
		HatsuData.EstiloVisual.PURO_PULSANTE, [], [], [], {}, false, 3, "PERMANENT", "OPEN_BOOK", [], "ANY",
		220.0
	)
	var d_f := fraco.calcular_functional_power()
	var d_l := lendario.calcular_functional_power()
	print("  Demanda fraco=%.1f lendario=%.1f" % [d_f, d_l])
	if d_l <= d_f * 2.0:
		print("  Erro: força 220 deveria exigir bem mais créditos que 25")
		return false
	var livro := HatsuManager.criar_hatsu(
		"LivroOP", HatsuData.Categoria.CONJURACAO, HatsuData.Forma.PESSOAL,
		[], HatsuData.ObjetivoPrincipal.SUPORTE, HatsuData.Elemento.NEN_PURO,
		HatsuData.Alvo.PROPRIO_USUARIO, HatsuData.AlcanceTipo.MEDIO, HatsuData.ConsumoDesejado.MEDIO,
		"", HatsuData.Arquetipo.LIVRO_COLECAO, Color(-1, -1, -1, -1), Color(-1, -1, -1, -1),
		HatsuData.EstiloVisual.PURO_PULSANTE, [], [], [], {}, true, 5, "PERMANENT", "OPEN_BOOK", [], "ANY",
		220.0
	)
	if livro.calcular_functional_power() < d_l * 0.8:
		print("  Erro: conjuração lendária não deveria ter teto artificial baixo")
		return false
	return true


func _t_forge_gate() -> bool:
	var h := HatsuData.new()
	h.nome = "MundoQuebrado"
	h.categoria = HatsuData.Categoria.ESPECIALIZACAO
	h.forma = HatsuData.Forma.AREA
	h.alvo = HatsuData.Alvo.AREA
	h.custom_damage = 200.0
	h.custom_cooldown = 2.0
	h.custom_aura_cost = 15.0
	h.calcular_functional_power()
	h.calcular_limitation_credits()
	if h.credit_deficit <= 0.0:
		print("  Erro: esperado déficit sem votos. deficit=", h.credit_deficit)
		return false
	var val = HatsuManager.validate_hatsu(h)
	if val.get("status") != "OVERPOWERED" and h.credit_deficit <= 0.0:
		print("  Erro: status/déficit inesperados: ", val.get("status"), h.credit_deficit)
		return false

	h.condicoes = [
		HatsuData.Condicao.HP_ABAIXO_30,
		HatsuData.Condicao.PARADO_CANALIZACAO,
		HatsuData.Condicao.USO_UNICO_POR_COMBATE
	]
	h.modular_restrictions = [
		HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE,
		HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU,
		HatsuComponentLibrary.RestrictionType.ONCE_PER_COMBAT,
		HatsuComponentLibrary.RestrictionType.DEATH_PENALTY_ON_MISS,
		HatsuComponentLibrary.RestrictionType.SACRIFICE_HP
	]
	h.preparation_steps = [
		{"id": "a", "description": "Ritual longo", "action_required": "RITUAL", "time_required": 3.0, "credit_value": 50.0},
		{"id": "b", "description": "Declarar alvo", "action_required": "DECLARAR", "time_required": 0.0, "credit_value": 40.0},
		{"id": "c", "description": "Sacrificar aura", "action_required": "SACRIFICIO", "time_required": 0.0, "credit_value": 45.0}
	]
	h.custom_cooldown = 18.0
	h.custom_aura_cost = 80.0
	h.calcular_functional_power()
	h.calcular_limitation_credits()
	print("  Após votos: demanda=%.1f creditos=%.1f deficit=%.1f" % [h.required_credits, h.limitation_credits, h.credit_deficit])
	if h.limitation_credits < 80.0:
		print("  Erro: votos deveriam gerar muitos créditos")
		return false
	return true


func _t_catalog() -> bool:
	var todos = HatsuPresetLibrary.obter_todos_presets()
	var tematicos := 0
	var por_cat := {}
	for p in todos:
		if p["id"] == HatsuPresetLibrary.PresetId.CRIAR_DO_ZERO:
			continue
		tematicos += 1
		var c = p["categoria"]
		por_cat[c] = int(por_cat.get(c, 0)) + 1
		if not p.has("desc") or str(p["desc"]).is_empty():
			print("  Erro: preset sem desc: ", p.get("slug"))
			return false
	print("  Conceitos temáticos=", tematicos, " por categoria=", por_cat)
	if tematicos < 28:
		print("  Erro: catálogo deveria ter 28+ conceitos")
		return false
	for cat in [
		HatsuData.Categoria.INTENSIFICACAO,
		HatsuData.Categoria.TRANSFORMACAO,
		HatsuData.Categoria.EMISSAO,
		HatsuData.Categoria.CONJURACAO,
		HatsuData.Categoria.MANIPULACAO,
		HatsuData.Categoria.ESPECIALIZACAO
	]:
		if int(por_cat.get(cat, 0)) < 2:
			print("  Erro: categoria sem diversidade: ", cat)
			return false
	var intens = HatsuPresetLibrary.obter_presets_por_categoria(HatsuData.Categoria.INTENSIFICACAO)
	var outros = HatsuPresetLibrary.obter_presets_exceto_categoria(HatsuData.Categoria.INTENSIFICACAO)
	if intens.is_empty() or outros.is_empty():
		print("  Erro: helper de catálogo amplo falhou")
		return false
	var soco = HatsuPresetLibrary.obter_preset_por_slug("soco_carregado")
	var bala = HatsuPresetLibrary.obter_preset_por_slug("bala_memoria")
	if soco.get("slug", "") != "soco_carregado" or bala.get("slug", "") != "bala_memoria":
		print("  Erro: presets novos ausentes")
		return false
	return true


func _t_affinity() -> bool:
	var Aff = NenAffinityData.CategoriaAfinidade
	var Cat = HatsuData.Categoria
	var natal = Aff.INTENSIFICACAO
	var e100 = NenAffinityData.calcular_eficiencia_categoria(natal, Cat.INTENSIFICACAO)
	var e80a = NenAffinityData.calcular_eficiencia_categoria(natal, Cat.TRANSFORMACAO)
	var e80b = NenAffinityData.calcular_eficiencia_categoria(natal, Cat.EMISSAO)
	var e60a = NenAffinityData.calcular_eficiencia_categoria(natal, Cat.CONJURACAO)
	var e60b = NenAffinityData.calcular_eficiencia_categoria(natal, Cat.MANIPULACAO)
	var e40 = NenAffinityData.calcular_eficiencia_categoria(natal, Cat.ESPECIALIZACAO)
	print("  Intens natal → I=%.2f T=%.2f E=%.2f C=%.2f M=%.2f S=%.2f" % [e100, e80a, e80b, e60a, e60b, e40])
	if not is_equal_approx(e100, 1.0):
		return false
	if not is_equal_approx(e80a, 0.8) or not is_equal_approx(e80b, 0.8):
		return false
	if not is_equal_approx(e60a, 0.6) or not is_equal_approx(e60b, 0.6):
		return false
	if not is_equal_approx(e40, 0.4):
		return false
	var esp = NenAffinityData.calcular_eficiencia_categoria(Aff.ESPECIALIZACAO, Cat.CONJURACAO)
	if not is_equal_approx(esp, 1.0):
		print("  Erro: especialista deveria ter 100% em conjuração")
		return false
	return true


func _t_factory() -> bool:
	var h := HatsuManager.criar_hatsu(
		"SliderTest", HatsuData.Categoria.TRANSFORMACAO, HatsuData.Forma.TOQUE,
		[], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.ELETRICIDADE,
		HatsuData.Alvo.INIMIGO_UNICO, HatsuData.AlcanceTipo.MEDIO, HatsuData.ConsumoDesejado.MEDIO,
		"", HatsuData.Arquetipo.SIMPLES, Color(-1, -1, -1, -1), Color(-1, -1, -1, -1),
		HatsuData.EstiloVisual.PURO_PULSANTE, [], [], [], {}, false, 3, "PERMANENT", "OPEN_BOOK", [], "ANY",
		140.0
	)
	if not is_equal_approx(h.custom_damage, 140.0):
		print("  Erro: custom_damage não propagou: ", h.custom_damage)
		return false
	# Demanda de créditos usa o dano pedido (slider), não o poder pós-maestria
	if h.calcular_functional_power() < 200.0:
		print("  Erro: demanda funcional deveria refletir custom_damage 140: ", h.calcular_functional_power())
		return false
	# Com maestria máxima, poder final ≈ custom_damage * mult poder
	h.mastery = 100.0
	var pf := h.obter_poder_final()
	print("  custom_damage=%.1f poder_final(mastery max)=%.1f demanda=%.1f" % [h.custom_damage, pf, h.functional_power])
	if pf < 140.0 * 0.9:
		print("  Erro: obter_poder_final com mastery max deveria ~140, got ", pf)
		return false
	return true


func _t_offtype() -> bool:
	var ef = NenAffinityData.calcular_eficiencia_categoria(
		NenAffinityData.CategoriaAfinidade.INTENSIFICACAO,
		HatsuData.Categoria.CONJURACAO
	)
	if not is_equal_approx(ef, 0.6):
		print("  Erro: livro off-type deveria ser 60%, got ", ef)
		return false
	var ef2 = NenAffinityData.calcular_eficiencia_categoria(
		NenAffinityData.CategoriaAfinidade.EMISSAO,
		HatsuData.Categoria.CONJURACAO
	)
	if not is_equal_approx(ef2, 0.4):
		print("  Erro: emissão→conjuração deveria ser 40%, got ", ef2)
		return false
	return true
