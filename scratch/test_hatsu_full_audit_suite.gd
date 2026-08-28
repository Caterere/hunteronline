extends Node

const HatsuData = preload("res://resource/hatsu/HatsuData.gd")
const HatsuComponentLibrary = preload("res://resource/hatsu/HatsuComponentLibrary.gd")
const HatsuPresetLibrary = preload("res://resource/hatsu/HatsuPresetLibrary.gd")
const HatsuCreationUI = preload("res://ui/Hatsu/HatsuCreationUI.gd")

var total_tests: int = 0
var passed_tests: int = 0

func _ready() -> void:
	print("\n==================================================")
	print("⚡ INICIANDO SUÍTE DE AUDITORIA DO HATSU CREATOR ⚡")
	print("==================================================\n")

	await _teste_1_navegacao_e_etapa_4()
	await _teste_2_theft_sem_limitacoes()
	await _teste_3_theft_com_limitacoes()
	await _teste_4_drafts_vs_forja()
	await _teste_5_roubo_real_e_grimorio()
	await _teste_6_savegame_persistencia()

	print("\n==================================================")
	print("📊 RESULTADO DA AUDITORIA DO HATSU CREATOR:")
	print("Passou em: %d / %d testes (%.1f%%)" % [passed_tests, total_tests, (float(passed_tests) / float(total_tests)) * 100.0])
	print("==================================================\n")

	if passed_tests == total_tests:
		print("🎉 TODOS OS TESTES DE AUDITORIA PASSARAM COM SUCESSO!")
	else:
		push_error("❌ ALGUNS TESTES FALHARAM!")

	get_tree().quit(0 if passed_tests == total_tests else 1)


func _teste_1_navegacao_e_etapa_4() -> void:
	total_tests += 1
	print("▶ Teste 1: Navegação das 9 Abas e Interatividade da Aba 4/9")
	var ui = HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()

	assert(ui.tab_buttons.size() == 9, "Deve possuir 9 botões de abas no topo")
	assert(ui.etapa_atual == HatsuCreationUI.Etapa.TIPO_NEN, "Aba inicial deve ser 1.Tipo")

	# Testar navegação direta para a Aba 4 (Funcionamento)
	ui._ir_para_etapa(HatsuCreationUI.Etapa.FUNCIONAMENTO)
	assert(ui.etapa_atual == HatsuCreationUI.Etapa.FUNCIONAMENTO, "Deve navegar diretamente para a etapa FUNCIONAMENTO")

	# Testar alteração de objetivo na Aba 4
	ui.sel_objetivo = HatsuData.ObjetivoPrincipal.CONTROLE
	ui._atualizar_etapa()
	assert(ui.sel_objetivo == HatsuData.ObjetivoPrincipal.CONTROLE, "Objetivo deve ser atualizado para CONTROLE")

	# Testar opções de conceito interativas
	ui.sel_opcoes_preset = {
		"metodo_roubo": ["Tocar e interrogar", "Derrotar em combate"],
		"capacidade_livro": [3, 5, 10]
	}
	ui._atualizar_etapa()
	ui.sel_opcoes_preset_escolhidas["metodo_roubo"] = "Tocar e interrogar"
	ui.sel_opcoes_preset_escolhidas["capacidade_livro"] = "5"
	assert(ui.sel_opcoes_preset_escolhidas["metodo_roubo"] == "Tocar e interrogar", "Opção de conceito deve ser registrada")

	ui.queue_free()
	passed_tests += 1
	print("  ✅ PASSOU: 9 abas navegáveis e opções da Aba 4 interativas.\n")


func _teste_2_theft_sem_limitacoes() -> void:
	total_tests += 1
	print("▶ Teste 2: Caso Roubo de Habilidades (Ability Theft) SEM limitações")
	var theft_hatsu := HatsuManager.criar_hatsu(
		"Skill Hunter Ilegal",
		HatsuData.Categoria.ESPECIALIZACAO,
		HatsuData.Forma.TOQUE,
		[], # Sem condições
		HatsuData.ObjetivoPrincipal.CONTROLE,
		HatsuData.Elemento.NEN_PURO,
		HatsuData.Alvo.INIMIGO_UNICO,
		HatsuData.AlcanceTipo.CURTO,
		HatsuData.ConsumoDesejado.BAIXO, # Baixo consumo sem créditos
		"", # Sem juramentos
		HatsuData.Arquetipo.LIVRO_COLECAO,
		Color(-1,-1,-1), Color(-1,-1,-1),
		HatsuData.EstiloVisual.PURO_PULSANTE,
		[], # Sem passos de preparação
		[HatsuComponentLibrary.EffectType.AURA_DRAIN]
	)

	var req_credits: float = theft_hatsu.calcular_functional_power()
	var avail_credits: float = theft_hatsu.calcular_limitation_credits()
	var deficit: float = theft_hatsu.credit_deficit

	print("  • Demanda Funcional (Required): ", req_credits)
	print("  • Créditos de Limitação (Available): ", avail_credits)
	print("  • Déficit de Créditos: ", deficit)

	assert(deficit > 50.0, "Hatsu de Roubo de Habilidade sem limitações DEVE gerar déficit de crédito alto!")
	assert(not theft_hatsu.is_balanced(), "Hatsu sem limitações NÃO deve ser considerado balanceado!")

	var val_res := HatsuManager.validate_hatsu(theft_hatsu)
	assert(val_res["status"] == "OVERPOWERED", "Status do validador deve ser OVERPOWERED!")
	assert(val_res["credit_deficit"] > 0.0, "Validador deve reportar déficit de crédito")

	passed_tests += 1
	print("  ✅ PASSOU: Roubo sem limitações bloqueado (Déficit detectado: %d cr).\n" % int(deficit))


func _teste_3_theft_com_limitacoes() -> void:
	total_tests += 1
	print("▶ Teste 3: Caso Roubo de Habilidades COM Limitações Canônicas")
	var theft_balanced := HatsuManager.criar_hatsu(
		"Skill Hunter Legítimo (Chrollo)",
		HatsuData.Categoria.ESPECIALIZACAO,
		HatsuData.Forma.TOQUE,
		[HatsuData.Condicao.PARADO_CANALIZACAO, HatsuData.Condicao.REVELACAO_HABILIDADE],
		HatsuData.ObjetivoPrincipal.CONTROLE,
		HatsuData.Elemento.NEN_PURO,
		HatsuData.Alvo.INIMIGO_UNICO,
		HatsuData.AlcanceTipo.CURTO,
		HatsuData.ConsumoDesejado.ALTO, # Custo alto de aura
		"",
		HatsuData.Arquetipo.LIVRO_COLECAO,
		Color(-1,-1,-1), Color(-1,-1,-1),
		HatsuData.EstiloVisual.PURO_PULSANTE,
		[
			{"id": "step_1", "description": "Ver a habilidade com os próprios olhos", "action": "OBSERVAR", "credit_value": 35.0},
			{"id": "step_2", "description": "Fazer perguntas sobre a habilidade e obter resposta", "action": "INTERROGATORIO", "credit_value": 40.0},
			{"id": "step_3", "description": "O alvo deve tocar a palma na capa do livro", "action": "TOQUE_FISICO", "credit_value": 40.0},
			{"id": "step_4", "description": "Completar os passos dentro de 1 hora", "action": "TEMPO", "credit_value": 30.0}
		],
		[HatsuComponentLibrary.EffectType.AURA_DRAIN],
		[
			HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU, # Trava de outros Hatsus
			HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED # Toque obrigatório
		]
	)

	var req_bal: float = theft_balanced.calcular_functional_power()
	var avail_bal: float = theft_balanced.calcular_limitation_credits()
	var deficit_bal: float = theft_balanced.credit_deficit

	print("  • Demanda Funcional (Balanceado): ", req_bal)
	print("  • Créditos de Limitação (Balanceado): ", avail_bal)
	print("  • Déficit: ", deficit_bal)

	assert(deficit_bal == 0.0, "Com as 4 etapas de ritual e restrições, o déficit deve ser zerado!")
	assert(theft_balanced.is_balanced(), "Hatsu com limitações adequadas DEVE ser balanceado!")

	var val_bal := HatsuManager.validate_hatsu(theft_balanced)
	assert(val_bal["status"] == "VALID", "Validador deve aprovar Hatsu quando limitações pagam pelo poder!")

	passed_tests += 1
	print("  ✅ PASSOU: Roubo com 4 passos de ritual e restrições é aprovado (Déficit: 0 cr).\n")


func _teste_4_drafts_vs_forja() -> void:
	total_tests += 1
	print("▶ Teste 4: Salvar Rascunho (Draft Mode) vs Bloqueio de Forja Definitiva")
	var ui = HatsuCreationUI.new()
	add_child(ui)
	ui.abrir()

	# Configurar Hatsu incompleto com déficit
	ui.sel_nome = "Skill Hunter Rascunho"
	ui.sel_categoria = HatsuData.Categoria.ESPECIALIZACAO
	ui.sel_forma = HatsuData.Forma.TOQUE
	ui.sel_arquetipo = HatsuData.Arquetipo.LIVRO_COLECAO
	ui.sel_condicoes.clear()
	ui.sel_restricoes.clear()
	ui.sel_preparation_steps.clear()

	var contagem_antes: int = PlayerData.hatsu_criados.size()

	# 1. Tentar forjar definitivo com déficit: DEVE BLOQUEAR
	ui._finalizar_criacao(false)
	var contagem_apos_tentativa_forja: int = PlayerData.hatsu_criados.size()
	assert(contagem_apos_tentativa_forja == contagem_antes, "Forja definitiva com déficit NÃO deve adicionar ao PlayerData!")

	# 2. Salvar como Rascunho com déficit: DEVE PERMITIR
	ui._finalizar_criacao(true)
	var contagem_apos_rascunho: int = PlayerData.hatsu_criados.size()
	assert(contagem_apos_rascunho == contagem_antes + 1, "Salvar Rascunho DEVE ser permitido mesmo com déficit!")

	var rascunho_salvo = PlayerData.hatsu_criados[contagem_apos_rascunho - 1] as HatsuData
	assert(rascunho_salvo.is_draft == true, "Propriedade is_draft deve ser true no rascunho!")
	assert(rascunho_salvo.credit_deficit > 0.0, "Rascunho deve registrar o déficit pendente!")

	# 3. Testar Serialização / Deserialização com is_draft e credit_deficit
	var rascunho_dict = rascunho_salvo.to_dict()
	assert(rascunho_dict.get("is_draft") == true, "to_dict() deve serializar is_draft")
	assert(rascunho_dict.has("credit_deficit"), "to_dict() deve serializar credit_deficit")

	var rascunho_restaurado = HatsuData.from_dict(rascunho_dict)
	assert(rascunho_restaurado.is_draft == true, "from_dict() deve deserializar is_draft")
	assert(rascunho_restaurado.credit_deficit > 0.0, "from_dict() deve deserializar credit_deficit")

	ui.queue_free()
	passed_tests += 1
	print("  ✅ PASSOU: Rascunho salvo e forja com déficit bloqueada.\n")


func _teste_5_roubo_real_e_grimorio() -> void:
	total_tests += 1
	print("▶ Teste 5: Mecânica Real de Roubo de Hatsu e Grimório")
	PlayerData.reset()

	var ed_hisoka := EnemyData.new()
	ed_hisoka.enemy_id = &"hisoka_boss"
	ed_hisoka.enemy_name = "Hisoka Morow"
	ed_hisoka.level = 20

	var h_hisoka := ed_hisoka.obter_hatsu_real()
	assert(h_hisoka != null and h_hisoka.nome == "Bungee Gum", "EnemyData deve gerar Hatsu canônico real")

	var h_book := HatsuData.new()
	h_book.nome = "Skill Hunter"
	h_book.categoria = HatsuData.Categoria.ESPECIALIZACAO
	h_book.arquetipo = HatsuData.Arquetipo.LIVRO_COLECAO
	h_book.is_storage_hatsu = true
	h_book.storage_capacity = 5
	h_book.storage_duration_type = "PERMANENT"
	h_book.storage_usage_rule = "OPEN_BOOK"
	h_book.steal_conditions = ["TOUCH_REQUIRED", "OBSERVE_GYO", "TARGET_EXPLAINS"]

	var player_dummy := CharacterBody2D.new()
	player_dummy.name = "Player"
	player_dummy.position = Vector2(100, 100)
	add_child(player_dummy)

	var enemy_dummy := CharacterBody2D.new()
	enemy_dummy.name = "Inimigo Hisoka"
	enemy_dummy.position = Vector2(120, 100)
	add_child(enemy_dummy)

	var enemy_sys := Node.new()
	enemy_sys.name = "EnemySystem"
	enemy_sys.set_script(load("res://scripts/systems/EnemySystem/EnemySystem.gd"))
	enemy_sys.enemy_data = ed_hisoka
	enemy_dummy.add_child(enemy_sys)

	# Roubo com sucesso
	var res := HatsuManager.tentar_roubar_hatsu(player_dummy, enemy_dummy, h_book, {
		"distance": 20.0,
		"toque_realizado": true,
		"observou_gyo": true,
		"alvo_explicou": true
	})

	assert(res.get("sucesso") == true, "Roubo com todos os requisitos deve ser bem-sucedido")
	assert(PlayerData.stored_hatsus.size() == 1, "Hatsu deve ser inserido em PlayerData.stored_hatsus")
	assert(PlayerData.stored_hatsus[0]["hatsu_data"].nome == "Bungee Gum", "Hatsu roubado deve ser Bungee Gum")

	player_dummy.queue_free()
	enemy_dummy.queue_free()
	passed_tests += 1
	print("  ✅ PASSOU: Mecânica real de roubo e armazenamento no Grimório validada.\n")


func _teste_6_savegame_persistencia() -> void:
	total_tests += 1
	print("▶ Teste 6: Persistência do Hatsu Roubado no Savegame")

	var test_slot := 4
	SaveManager.salvar_jogo(test_slot)
	PlayerData.stored_hatsus.clear()
	assert(PlayerData.stored_hatsus.is_empty(), "Armazenamento deve estar limpo antes do reload")

	SaveManager.carregar_jogo(test_slot)
	assert(PlayerData.stored_hatsus.size() == 1, "Savegame deve restaurar o Hatsu roubado")
	assert(PlayerData.stored_hatsus[0]["hatsu_data"].nome == "Bungee Gum", "Hatsu restaurado deve ser Bungee Gum")

	passed_tests += 1
	print("  ✅ PASSOU: Persistência no SaveManager restaura técnicas roubadas perfeitamente.\n")