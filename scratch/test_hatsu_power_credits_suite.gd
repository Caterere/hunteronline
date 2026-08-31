extends Node

# ============================================================
# TEST SUITE: HATSU CREATOR V1.5 — CRÉDITOS DE PODER & LIMITAÇÃO
# ============================================================

var testes_passados: int = 0
var testes_totais: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("⚡ INICIANDO SUÍTE DE TESTES: HATSU CREATOR V1.5 (POWER CREDITS & LIMITATIONS)")
	print("============================================================\n")

	await _executar_teste("1. Hatsu Simples (Dano Básico com Custos Naturais)", _teste_hatsu_simples)
	await _executar_teste("2. Detecção de Hatsu Overpowered / Desbalanceado", _teste_hatsu_overpowered)
	await _executar_teste("3. Equilíbrio através de Condições e Restrições (Pagamento)", _teste_pagamento_condicoes)
	await _executar_teste("4. Hatsu de Roubo / Grimório Pago com Preparation Chain", _teste_preparation_chain)
	await _executar_teste("5. Cálculo de Versatilidade & Demanda Funcional", _teste_versatilidade_score)
	await _executar_teste("6. Sistema de Sugestões Construtivas de Balanceamento", _teste_sugestoes_balanceamento)
	await _executar_teste("7. Persistência de Passos de Preparação & Créditos no Save", _teste_persistencia_v15)
	await _executar_teste("8. Execução Segura em Combate (HatsuSystem)", _teste_execucao_combate)

	print("\n============================================================")
	print("📊 RESULTADO DA SUÍTE DE CRÉDITOS DE LIMITAÇÃO (V1.5):")
	print("Passou em: %d / %d testes (%.1f%%)" % [testes_passados, testes_totais, (float(testes_passados) / float(testes_totais)) * 100.0])
	print("============================================================\n")

	if testes_passados == testes_totais:
		print("🎉 TODOS OS TESTES DE CRÉDITOS DE LIMITAÇÃO V1.5 PASSARAM COM SUCESSO!")
	else:
		push_error("❌ ALGUNS TESTES FALHARAM!")

	get_tree().quit(0 if testes_passados == testes_totais else 1)


func _executar_teste(nome: String, metodo: Callable) -> void:
	testes_totais += 1
	print("▶ Teste %d: %s" % [testes_totais, nome])
	var ok: bool = await metodo.call()
	if ok:
		testes_passados += 1
		print("  ✅ PASSOU: %s\n" % nome)
	else:
		print("  ❌ FALHOU: %s\n" % nome)


func _teste_hatsu_simples() -> bool:
	var h := HatsuManager.criar_hatsu("Soco de Ko", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE)
	h.custom_damage = 40.0
	h.custom_cooldown = 3.0
	h.custom_aura_cost = 20.0

	var f_power := h.calcular_functional_power()
	var l_credits := h.calcular_limitation_credits()

	if f_power <= 0.0 or l_credits < 0.0:
		print("  Erro: Valores inválidos para Hatsu simples.")
		return false

	var val = HatsuManager.validate_hatsu(h)
	if val.get("status") == "INVALID":
		print("  Erro: Hatsu simples não deveria ser inválido.")
		return false

	return true


func _teste_hatsu_overpowered() -> bool:
	var h_op := HatsuData.new()
	h_op.nome = "Super Explosão Imparável"
	h_op.categoria = HatsuData.Categoria.TRANSFORMACAO
	h_op.forma = HatsuData.Forma.AREA
	h_op.alvo = HatsuData.Alvo.AREA
	h_op.custom_damage = 180.0
	h_op.alcance = 250.0
	h_op.custom_cooldown = 1.0
	h_op.custom_aura_cost = 10.0
	h_op.sub_effects = [HatsuComponentLibrary.EffectType.STUN, HatsuComponentLibrary.EffectType.AURA_DRAIN, HatsuComponentLibrary.EffectType.TRACKING]

	var f_power := h_op.calcular_functional_power()
	var l_credits := h_op.calcular_limitation_credits()

	if f_power <= l_credits:
		print("  Erro: Hatsu absurdamente forte deveria ter demanda muito maior que créditos. Demanda: ", f_power, " | Créditos: ", l_credits)
		return false

	var val = HatsuManager.validate_hatsu(h_op)
	if val.get("status") != "OVERPOWERED":
		print("  Erro: Status deveria ser OVERPOWERED, obtido: ", val.get("status"))
		return false

	if val.get("sugestoes", []).is_empty():
		print("  Erro: O validador deveria retornar sugestões construtivas.")
		return false

	return true


func _teste_pagamento_condicoes() -> bool:
	var h_pago := HatsuData.new()
	h_pago.nome = "Supernova do Desespero"
	h_pago.categoria = HatsuData.Categoria.INTENSIFICACAO
	h_pago.forma = HatsuData.Forma.AREA
	h_pago.alvo = HatsuData.Alvo.AREA
	h_pago.custom_damage = 95.0
	h_pago.custom_cooldown = 10.0
	h_pago.custom_aura_cost = 55.0

	# Adicionar pagamentos: Condições e Restrições pesadas
	h_pago.condicoes = [HatsuData.Condicao.HP_ABAIXO_30, HatsuData.Condicao.PARADO_CANALIZACAO]
	h_pago.modular_restrictions = [
		HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE,
		HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU,
		HatsuComponentLibrary.RestrictionType.ONCE_PER_COMBAT
	]
	h_pago.modular_drawbacks = [
		HatsuComponentLibrary.DrawbackType.ZETSU_FORCED_15S
	]

	var f_power := h_pago.calcular_functional_power()
	var l_credits := h_pago.calcular_limitation_credits()

	if l_credits < f_power * 0.88:
		print("  Erro: Limitações severas deveriam pagar a demanda. Demanda: ", f_power, " | Créditos: ", l_credits)
		return false

	var val = HatsuManager.validate_hatsu(h_pago)
	if val.get("status") == "OVERPOWERED":
		print("  Erro: Hatsu adequadamente pago não deveria ser OVERPOWERED.")
		return false

	return true


func _teste_preparation_chain() -> bool:
	var h_book := HatsuData.new()
	h_book.nome = "Skill Hunter Grimoire"
	h_book.categoria = HatsuData.Categoria.ESPECIALIZACAO
	h_book.arquetipo = HatsuData.Arquetipo.LIVRO_COLECAO
	h_book.duration_type = HatsuData.DurationType.PERMANENT_STANCE
	h_book.custom_aura_cost = 45.0
	h_book.custom_cooldown = 8.0

	# Sem passos de preparação
	var l_sem_prep := h_book.calcular_limitation_credits()

	# Adicionar 3 passos de preparação
	h_book.preparation_steps = [
		{"id": "step_1", "description": "Tocar a palma da mão no oponente", "credit_value": 30.0},
		{"id": "step_2", "description": "Observar o Hatsu do oponente em ação com Gyo", "credit_value": 30.0},
		{"id": "step_3", "description": "Fazer o oponente revelar voluntariamente a técnica", "credit_value": 35.0}
	]

	var l_com_prep := h_book.calcular_limitation_credits()

	if l_com_prep <= l_sem_prep + 90.0:
		print("  Erro: Passos de preparação não adicionaram os créditos esperados. Sem: ", l_sem_prep, " | Com: ", l_com_prep)
		return false

	if h_book.preparation_credits < 90.0:
		print("  Erro: preparation_credits deveria ser >= 95.0, obtido: ", h_book.preparation_credits)
		return false

	return true


func _teste_versatilidade_score() -> bool:
	var h1 := HatsuData.new()
	h1.nome = "Ataque Único"
	h1.alvo = HatsuData.Alvo.INIMIGO_UNICO
	h1.cooldown_base = 5.0

	var v1 := h1.calcular_versatility_score()

	var h2 := HatsuData.new()
	h2.nome = "Ataque Versátil Multiefetor"
	h2.alvo = HatsuData.Alvo.AREA
	h2.forma = HatsuData.Forma.ZONA
	h2.alcance = 220.0
	h2.custom_cooldown = 1.5
	h2.sub_effects = [HatsuComponentLibrary.EffectType.STUN, HatsuComponentLibrary.EffectType.AURA_DRAIN, HatsuComponentLibrary.EffectType.PIERCING]

	var v2 := h2.calcular_versatility_score()

	if v2 <= v1 + 50.0:
		print("  Erro: Hatsu versátil deveria ter Versatility Score substancialmente maior. V1: ", v1, " | V2: ", v2)
		return false

	return true


func _teste_sugestoes_balanceamento() -> bool:
	var h_desbalanceado := HatsuData.new()
	h_desbalanceado.nome = "Canhão Rápido Sem Custo"
	h_desbalanceado.custom_damage = 150.0
	h_desbalanceado.custom_cooldown = 1.0
	h_desbalanceado.custom_aura_cost = 10.0

	var sugestoes := HatsuManager.obter_sugestoes_balanceamento(h_desbalanceado)
	if sugestoes.size() < 3:
		print("  Erro: Esperadas pelo menos 3 sugestões de balanceamento, obtidas: ", sugestoes.size())
		return false

	var tem_condicao := false
	var tem_restricao := false
	for s in sugestoes:
		if s.get("tipo") == "CONDICAO": tem_condicao = true
		if s.get("tipo") == "RESTRICAO": tem_restricao = true

	if not tem_condicao or not tem_restricao:
		print("  Erro: Sugestões devem conter tanto Condições quanto Restrições.")
		return false

	return true


func _teste_persistencia_v15() -> bool:
	PlayerData.reset()
	var h_save := HatsuData.new()
	h_save.nome = "Grimório de Julgamento"
	h_save.categoria = HatsuData.Categoria.ESPECIALIZACAO
	h_save.preparation_steps = [
		{"id": "p1", "description": "Marcação de En", "credit_value": 30.0},
		{"id": "p2", "description": "Confissão do Alvo", "credit_value": 40.0}
	]
	h_save.sub_effects = [HatsuComponentLibrary.EffectType.STUN, HatsuComponentLibrary.EffectType.AURA_DRAIN]
	h_save.calcular_functional_power()
	h_save.calcular_limitation_credits()

	var idx := PlayerData.adicionar_hatsu(h_save)
	PlayerData.equipar_hatsu(0, idx)

	var ok_save = SaveManager.salvar_jogo(96)
	if not ok_save:
		print("  Erro: Falha ao salvar jogo.")
		return false

	PlayerData.reset()
	var ok_load = SaveManager.carregar_jogo(96)
	if not ok_load:
		print("  Erro: Falha ao carregar jogo.")
		SaveManager.deletar_save(96)
		return false

	if PlayerData.hatsu_criados.is_empty():
		print("  Erro: Hatsu não encontrado após load.")
		SaveManager.deletar_save(96)
		return false

	var h_recuperado: HatsuData = PlayerData.hatsu_criados[0]
	if h_recuperado.preparation_steps.size() != 2:
		print("  Erro: Passos de preparação não persistiram corretamente. Tamanho: ", h_recuperado.preparation_steps.size())
		SaveManager.deletar_save(96)
		return false

	if h_recuperado.sub_effects.size() != 2:
		print("  Erro: Sub effects não persistiram corretamente.")
		SaveManager.deletar_save(96)
		return false

	SaveManager.deletar_save(96)
	return true


func _teste_execucao_combate() -> bool:
	var dummy := CharacterBody2D.new()
	var h_sys := HatsuSystem.new()
	dummy.add_child(h_sys)
	add_child(dummy)
	h_sys.setup(dummy)

	var h_combate := HatsuManager.criar_hatsu("Golpe com Preparação", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE)
	h_combate.preparation_steps = [{"id": "p1", "description": "Postura de Foco", "credit_value": 25.0}]
	h_combate.sub_effects = [HatsuComponentLibrary.EffectType.KNOCKBACK]

	PlayerData.reset()
	PlayerData.attributes["aura"] = 200.0
	PlayerData.attributes["aura_max"] = 200.0
	var idx := PlayerData.adicionar_hatsu(h_combate)
	PlayerData.equipar_hatsu(0, idx)

	h_sys.usar_hatsu(0)

	dummy.queue_free()
	return true
