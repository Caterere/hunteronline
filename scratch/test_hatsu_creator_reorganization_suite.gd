extends Node

# ============================================================
# TEST SUITE: REESTRUTURAÇÃO DO HATSU CREATOR (CONCEITO PRIMEIRO)
# ============================================================

var testes_passados: int = 0
var testes_totais: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("⚡ INICIANDO SUÍTE DE TESTES: NOVO HATSU CREATOR (CONCEITO PRIMEIRO)")
	print("============================================================\n")

	await _executar_teste("1. Catálogo Completo de 15 Presets & Conceitos", _teste_catalogo_presets)
	await _executar_teste("2. Inicialização & Etapa 1 (Tipo de Nen & Outro/Especial)", _teste_etapa_tipo_nen)
	await _executar_teste("3. Preset: Roubar Habilidades (Ability Theft)", _teste_preset_roubar_habilidades)
	await _executar_teste("4. Preset: Drenar Nen (Aura Drain)", _teste_preset_drenar_nen)
	await _executar_teste("5. Preset: Livro de Habilidades (Skill Hunter)", _teste_preset_livro_habilidades)
	await _executar_teste("6. Preset: Copiar Hatsu & Absorver Poder (Devour)", _teste_preset_copiar_absorver)
	await _executar_teste("7. Preset: Selar Hatsu & Criar Regras (Território)", _teste_preset_selar_regras)
	await _executar_teste("8. Modificação Livre de Presets (Adicionar/Remover Condições)", _teste_modificacao_presets)
	await _executar_teste("9. Fluxo Criar do Zero (Sem Presets)", _teste_criar_do_zero)
	await _executar_teste("10. Medidor de Gauge & Equilíbrio de Nen (Power Budget)", _teste_gauge_power_budget)
	await _executar_teste("11. Persistência de Hatsu Criado e Equipamento nos 4 Slots", _teste_persistencia_slots)
	await _executar_teste("12. Execução Segura em Combate (HatsuSystem)", _teste_execucao_combate)

	print("\n============================================================")
	print("📊 RESULTADO DA SUÍTE DO NOVO HATSU CREATOR:")
	print("Passou em: %d / %d testes (%.1f%%)" % [testes_passados, testes_totais, (float(testes_passados) / float(testes_totais)) * 100.0])
	print("============================================================\n")

	if testes_passados == testes_totais:
		print("🎉 TODOS OS TESTES DO NOVO HATSU CREATOR PASSARAM COM SUCESSO!")
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


func _teste_catalogo_presets() -> bool:
	var todos = HatsuPresetLibrary.obter_todos_presets()
	if todos.size() < 15:
		print("  Erro: Esperados pelo menos 15 presets, encontrados: ", todos.size())
		return false

	var slugs_esperados = [
		"roubar_habilidades", "drenar_nen", "livro_habilidades", "copiar_hatsu",
		"armazenar_hatsu", "absorver_poder", "selar_hatsu", "transferir_hatsu",
		"roubar_atributos", "transformacao_especial", "criar_regras",
		"manipular_probabilidade", "trocar_propriedades", "hatsu_evolutivo", "criar_do_zero"
	]

	for s in slugs_esperados:
		var p = HatsuPresetLibrary.obter_preset_por_slug(s)
		if p.is_empty() or p["slug"] != s:
			print("  Erro: Preset não encontrado: ", s)
			return false

	var especiais = HatsuPresetLibrary.obter_presets_especiais()
	if especiais.size() < 14:
		print("  Erro: Esperados pelo menos 14 presets na categoria Especial.")
		return false

	return true


func _teste_etapa_tipo_nen() -> bool:
	var ui := HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()

	if ui.etapa_atual != HatsuCreationUI.Etapa.TIPO_NEN:
		print("  Erro: Interface não iniciou na Etapa 1 (TIPO_NEN).")
		ui.fechar()
		ui.queue_free()
		return false

	# Testar seleção de Outro / Especial
	ui.sel_tipo_especial = true
	ui.sel_categoria = HatsuData.Categoria.ESPECIALIZACAO
	ui._on_avancar_pressed()

	if ui.etapa_atual != HatsuCreationUI.Etapa.CONCEITO:
		print("  Erro: Avanço não foi para Etapa 2 (CONCEITO).")
		ui.fechar()
		ui.queue_free()
		return false

	ui.fechar()
	ui.queue_free()
	return true


func _teste_preset_roubar_habilidades() -> bool:
	var p = HatsuPresetLibrary.obter_preset_por_slug("roubar_habilidades")
	var ui := HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()

	ui._aplicar_preset(p)
	if ui.sel_categoria != HatsuData.Categoria.ESPECIALIZACAO:
		print("  Erro: Categoria incorreta para Roubar Habilidades.")
		ui.fechar()
		ui.queue_free()
		return false

	if ui.sel_arquetipo != HatsuData.Arquetipo.LIVRO_COLECAO:
		print("  Erro: Arquétipo incorreto para Roubar Habilidades.")
		ui.fechar()
		ui.queue_free()
		return false

	if not (HatsuComponentLibrary.EffectType.STUN in ui.sel_efeitos_secundarios):
		print("  Erro: Efeito secundário Stun esperado.")
		ui.fechar()
		ui.queue_free()
		return false

	ui.fechar()
	ui.queue_free()
	return true


func _teste_preset_drenar_nen() -> bool:
	var p = HatsuPresetLibrary.obter_preset_por_slug("drenar_nen")
	var ui := HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()

	ui._aplicar_preset(p)
	if not (HatsuComponentLibrary.EffectType.AURA_GAIN in ui.sel_efeitos_secundarios):
		print("  Erro: Drenar Nen deveria incluir Aura Gain.")
		ui.fechar()
		ui.queue_free()
		return false

	if not ui.sel_opcoes_preset.has("destino_aura"):
		print("  Erro: Opções de destino_aura não encontradas.")
		ui.fechar()
		ui.queue_free()
		return false

	ui.fechar()
	ui.queue_free()
	return true


func _teste_preset_livro_habilidades() -> bool:
	var p = HatsuPresetLibrary.obter_preset_por_slug("livro_habilidades")
	var ui := HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()

	ui._aplicar_preset(p)
	if ui.sel_arquetipo != HatsuData.Arquetipo.LIVRO_COLECAO:
		print("  Erro: Arquétipo do Livro deveria ser LIVRO_COLECAO.")
		ui.fechar()
		ui.queue_free()
		return false

	ui.fechar()
	ui.queue_free()
	return true


func _teste_preset_copiar_absorver() -> bool:
	var p_copy = HatsuPresetLibrary.obter_preset_por_slug("copiar_hatsu")
	var p_absorb = HatsuPresetLibrary.obter_preset_por_slug("absorver_poder")

	if p_copy["efeito_principal"] != HatsuComponentLibrary.EffectType.REFLECTION:
		print("  Erro: Efeito principal de Copiar Hatsu deveria ser REFLECTION.")
		return false

	if p_absorb["efeito_principal"] != HatsuComponentLibrary.EffectType.DEVOUR_STATS:
		print("  Erro: Efeito principal de Absorver Poder deveria ser DEVOUR_STATS.")
		return false

	return true


func _teste_preset_selar_regras() -> bool:
	var p_seal = HatsuPresetLibrary.obter_preset_por_slug("selar_hatsu")
	var p_rule = HatsuPresetLibrary.obter_preset_por_slug("criar_regras")

	if p_seal["objetivo"] != HatsuData.ObjetivoPrincipal.CONTROLE:
		print("  Erro: Selar Hatsu deveria ser CONTROLE.")
		return false

	if p_rule["core"] != HatsuComponentLibrary.CoreType.RULE_ZONE:
		print("  Erro: Criar Regras deveria ter Core RULE_ZONE.")
		return false

	return true


func _teste_modificacao_presets() -> bool:
	var p = HatsuPresetLibrary.obter_preset_por_slug("transformacao_especial")
	var ui := HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()
	ui._aplicar_preset(p)

	# Modificar: Adicionar nova condição e remover restrição
	var cond_nova = HatsuData.Condicao.HP_ABAIXO_50
	if not (cond_nova in ui.sel_condicoes):
		ui.sel_condicoes.append(cond_nova)

	ui.sel_restricoes.clear() # Jogador removeu as restrições
	ui.sel_nome = "Godspeed Personalizado"

	if not (cond_nova in ui.sel_condicoes):
		print("  Erro: Falha ao adicionar nova condição.")
		ui.fechar()
		ui.queue_free()
		return false

	if not ui.sel_restricoes.is_empty():
		print("  Erro: Falha ao limpar restrições.")
		ui.fechar()
		ui.queue_free()
		return false

	ui.fechar()
	ui.queue_free()
	return true


func _teste_criar_do_zero() -> bool:
	var p = HatsuPresetLibrary.obter_preset(HatsuPresetLibrary.PresetId.CRIAR_DO_ZERO)
	var ui := HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()
	ui._aplicar_preset(p)

	if not ui.sel_condicoes.is_empty() or not ui.sel_restricoes.is_empty() or not ui.sel_efeitos_secundarios.is_empty():
		print("  Erro: Criar do Zero deveria iniciar com listas vazias.")
		ui.fechar()
		ui.queue_free()
		return false

	ui.fechar()
	ui.queue_free()
	return true


func _teste_gauge_power_budget() -> bool:
	var ui := HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()

	# Configurar Hatsu poderoso com Juramentos
	ui.sel_nome = "Impacto Máximo"
	ui.sel_categoria = HatsuData.Categoria.INTENSIFICACAO
	ui.sel_condicoes = [HatsuData.Condicao.HP_ABAIXO_30, HatsuData.Condicao.PARADO_CANALIZACAO]
	ui.custom_vow_input = "Só uso contra quem me atacar primeiro"
	ui._atualizar_gauge()

	if ui.lbl_potencial.text.is_empty():
		print("  Erro: Label de potencial está vazio no Gauge.")
		ui.fechar()
		ui.queue_free()
		return false

	ui.fechar()
	ui.queue_free()
	return true


func _teste_persistencia_slots() -> bool:
	PlayerData.reset()
	var h1 := HatsuManager.criar_hatsu("Skill Theft Test", HatsuData.Categoria.ESPECIALIZACAO, HatsuData.Forma.TOQUE)
	h1.arquetipo = HatsuData.Arquetipo.LIVRO_COLECAO
	h1.is_custom_created = true

	var idx := PlayerData.adicionar_hatsu(h1)
	if idx < 0:
		print("  Erro: Falha ao adicionar Hatsu no PlayerData.")
		return false

	# Equipar no slot 0
	PlayerData.equipar_hatsu_slot(0, 0)
	if PlayerData.equipped_hatsu_slots[0] != 0:
		print("  Erro: Falha ao equipar Hatsu no slot 0.")
		return false

	# Salvar e recarregar
	var save_ok = SaveManager.salvar_jogo(95)
	if not save_ok:
		print("  Erro: Falha ao salvar jogo.")
		return false

	PlayerData.reset()
	var load_ok = SaveManager.carregar_jogo(95)
	if not load_ok:
		print("  Erro: Falha ao carregar jogo.")
		SaveManager.deletar_save(95)
		return false

	if PlayerData.hatsus_salvos.is_empty():
		print("  Erro: Hatsu customizado não persistiu no save.")
		SaveManager.deletar_save(95)
		return false

	SaveManager.deletar_save(95)
	return true


func _teste_execucao_combate() -> bool:
	var dummy_body := CharacterBody2D.new()
	var hatsu_sys := HatsuSystem.new()
	dummy_body.add_child(hatsu_sys)
	add_child(dummy_body)
	hatsu_sys.setup(dummy_body)

	var h_combate := HatsuManager.criar_hatsu("Devour Aura Strike", HatsuData.Categoria.ESPECIALIZACAO, HatsuData.Forma.TOQUE)
	h_combate.core_component = HatsuComponentLibrary.CoreType.ABSORPTION
	h_combate.sub_effects = [HatsuComponentLibrary.EffectType.AURA_DRAIN]

	PlayerData.reset()
	PlayerData.attributes["aura"] = 200.0
	PlayerData.attributes["aura_max"] = 200.0
	PlayerData.adicionar_hatsu(h_combate)
	PlayerData.equipar_hatsu_slot(0, 0)

	# Executar no HatsuSystem
	hatsu_sys.executar_hatsu_slot(0)

	# Se não houve crash, o teste passou com sucesso
	dummy_body.queue_free()
	return true
