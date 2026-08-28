extends Node

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0


func _ready() -> void:
	print("================================================================")
	print("🧪 INICIANDO SUÍTE DE TESTES: HATSU LOADOUT & COMPATIBILITY")
	print("================================================================")

	# Resetar atributos para teste limpo
	PlayerData.reset()
	PlayerData.attributes["aura"] = 200.0
	PlayerData.attributes["aura_max"] = 200.0
	PlayerData.attributes["vida"] = 100
	PlayerData.attributes["vida_max"] = 100

	_executar_todos_os_testes()

	print("================================================================")
	print("📊 RESULTADOS DA SUÍTE DE HATSU REFINED:")
	print("Total: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 100% DOS TESTES APROVADOS COM SUCESSO!")
	else:
		printerr("❌ ALGUNS TESTES FALHARAM!")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)


func assert_true(cond: bool, msg: String) -> void:
	total_tests += 1
	if cond:
		passed_tests += 1
		print("  ✅ [PASS] " + msg)
	else:
		failed_tests += 1
		printerr("  ❌ [FAIL] " + msg)


func assert_false(cond: bool, msg: String) -> void:
	assert_true(not cond, msg)


func assert_eq(a, b, msg: String) -> void:
	assert_true(a == b, "%s (Esperado: %s, Obtido: %s)" % [msg, str(b), str(a)])


func _executar_todos_os_testes() -> void:
	_teste_1_godspeed_com_jajanken()
	_teste_2_godspeed_com_remote_punch()
	_teste_3_transformacao_com_transformacao_bloqueio()
	_teste_4_instantaneos_sequenciais()
	_teste_5_canais_sustentados_exclusividade()
	_teste_6_skill_hunter_bookmark_dual_activation()
	_teste_7_feedback_incompatibilidade()
	_teste_8_bloqueio_por_aura_insuficiente()
	_teste_9_bloqueio_por_cooldown()
	_teste_10_serializacao_save_load()


func _teste_1_godspeed_com_jajanken() -> void:
	print("\n--- Teste 1: Godspeed (Sustentado/Transf) + Jajanken (Instantâneo) ---")
	var godspeed = HatsuManager.obter_hatsu_canonico("killua_kanmuru")
	var jajanken = HatsuManager.obter_hatsu_canonico("gon_jajanken_tesoura")

	assert_true(godspeed != null and jajanken != null, "Hatsus canônicos carregados com sucesso")

	var active_list: Array = [{"slot": 0, "hatsu": godspeed, "timer": 10.0, "is_active": true}]
	var ctx: Dictionary = {"aura": 150.0, "cooldown": 0.0}

	var res = HatsuManager.can_activate(jajanken, active_list, ctx)
	assert_true(res.get("allowed", false), "Jajanken pode ser ativado enquanto Godspeed está ativo")


func _teste_2_godspeed_com_remote_punch() -> void:
	print("\n--- Teste 2: Godspeed (Sustentado/Transf) + Remote Punch (Instantâneo) ---")
	var godspeed = HatsuManager.obter_hatsu_canonico("killua_kanmuru")
	var remote_punch = HatsuManager.obter_hatsu_canonico("leorio_remote_punch")

	var active_list: Array = [{"slot": 0, "hatsu": godspeed, "timer": 10.0, "is_active": true}]
	var ctx: Dictionary = {"aura": 150.0, "cooldown": 0.0}

	var res = HatsuManager.can_activate(remote_punch, active_list, ctx)
	assert_true(res.get("allowed", false), "Remote Punch pode ser ativado durante Godspeed")


func _teste_3_transformacao_com_transformacao_bloqueio() -> void:
	print("\n--- Teste 3: Duas Transformações Concorrentes (Godspeed + 100-Guanyin) ---")
	var godspeed = HatsuManager.obter_hatsu_canonico("killua_kanmuru")
	var guanyin = HatsuManager.obter_hatsu_canonico("netero_guanyin")

	var active_list: Array = [{"slot": 0, "hatsu": godspeed, "timer": 10.0, "is_active": true}]
	var ctx: Dictionary = {"aura": 150.0, "cooldown": 0.0}

	var res = HatsuManager.can_activate(guanyin, active_list, ctx)
	assert_false(res.get("allowed", true), "Segunda transformação (Guanyin) deve ser bloqueada")
	assert_true(res.get("reason", "").contains("Incompatível") or res.get("reason", "").contains("transformações"), "Mensagem de motivo clara de bloqueio fornecida: " + res.get("reason", ""))


func _teste_4_instantaneos_sequenciais() -> void:
	print("\n--- Teste 4: Hatsus Instantâneos Sequenciais ---")
	var tesoura = HatsuManager.obter_hatsu_canonico("gon_jajanken_tesoura")
	var papel = HatsuManager.obter_hatsu_canonico("gon_jajanken_papel")

	var active_list: Array = []
	var ctx: Dictionary = {"aura": 150.0, "cooldown": 0.0}

	var res1 = HatsuManager.can_activate(tesoura, active_list, ctx)
	var res2 = HatsuManager.can_activate(papel, active_list, ctx)

	assert_true(res1.get("allowed", false) and res2.get("allowed", false), "Ambos instantâneos podem ser executados sequencialmente")


func _teste_5_canais_sustentados_exclusividade() -> void:
	print("\n--- Teste 5: Canais Sustentados e Exclusividade ---")
	var crazy_slots = HatsuManager.obter_hatsu_canonico("kite_crazy_slots") # UTILITY
	var godspeed = HatsuManager.obter_hatsu_canonico("killua_kanmuru")       # TRANSFORMATION

	var active_list: Array = [{"slot": 0, "hatsu": crazy_slots, "timer": 10.0, "is_active": true}]
	var ctx: Dictionary = {"aura": 150.0, "cooldown": 0.0}

	var res = HatsuManager.can_activate(godspeed, active_list, ctx)
	assert_true(res.get("allowed", false), "Sustentado de Utilidade e Transformação em canais distintos coexistem")


func _teste_6_skill_hunter_bookmark_dual_activation() -> void:
	print("\n--- Teste 6: Skill Hunter com Marcador Duplo (Dual-Activation & Sinergia) ---")
	var book = HatsuManager.criar_livro_hatsu("Skill Hunter")
	book.permite_marcador_duplo = true

	var h1 = HatsuManager.obter_hatsu_canonico("killua_narukami")
	var h2 = HatsuManager.obter_hatsu_canonico("gon_jajanken_pedra")

	var t1: Array[String] = ["electricity", "ranged"]
	var t2: Array[String] = ["impact", "heavy"]
	h1.tags = t1
	h2.tags = t2

	book.adicionar_pagina({"id": "pag1", "nome": h1.nome, "categoria": h1.categoria, "hatsu_ref": h1, "tags": h1.tags})
	book.adicionar_pagina({"id": "pag2", "nome": h2.nome, "categoria": h2.categoria, "hatsu_ref": h2, "tags": h2.tags})

	book.definir_pagina_ativa(0)
	book.definir_pagina_marcador(1)

	var sinergia = HatsuManager.processar_sinergia_tags(h1, h2)
	assert_true(sinergia.has("dano_bonus"), "Sinergia de tags processada com sucesso")

	var h_ativo1 = book.obter_hatsu_ativo()
	var h_ativo2 = book.obter_hatsu_marcador()
	assert_true(h_ativo1 != null and h_ativo2 != null, "Duas habilidades ativas simultaneamente no Grimório")


func _teste_7_feedback_incompatibilidade() -> void:
	print("\n--- Teste 7: Feedback de Incompatibilidade ---")
	var emperor_time = HatsuManager.obter_hatsu_canonico("kurapika_emperor_time")
	var godspeed = HatsuManager.obter_hatsu_canonico("killua_kanmuru")

	var active_list: Array = [{"slot": 1, "hatsu": emperor_time, "timer": 10.0, "is_active": true}]
	var ctx: Dictionary = {"aura": 100.0, "cooldown": 0.0}

	var res = HatsuManager.can_activate(godspeed, active_list, ctx)
	assert_false(res.get("allowed", true), "Ativação incompatível detectada")
	assert_true(res.get("conflicting", "") == emperor_time.nome, "Habilidade em conflito identificada corretamente")


func _teste_8_bloqueio_por_aura_insuficiente() -> void:
	print("\n--- Teste 8: Bloqueio por Aura Insuficiente ---")
	var jajanken_pedra = HatsuManager.obter_hatsu_canonico("gon_jajanken_pedra")

	var active_list: Array = []
	var ctx: Dictionary = {"aura": 10.0, "cooldown": 0.0} # Custo é 45.0

	var res = HatsuManager.can_activate(jajanken_pedra, active_list, ctx)
	assert_false(res.get("allowed", true), "Bloqueado quando aura < custo")
	assert_true(res.get("reason", "").contains("Aura insuficiente"), "Mensagem de aura insuficiente retornada")


func _teste_9_bloqueio_por_cooldown() -> void:
	print("\n--- Teste 9: Bloqueio por Cooldown Ativo ---")
	var tesoura = HatsuManager.obter_hatsu_canonico("gon_jajanken_tesoura")

	var active_list: Array = []
	var ctx: Dictionary = {"aura": 100.0, "cooldown": 5.2}

	var res = HatsuManager.can_activate(tesoura, active_list, ctx)
	assert_false(res.get("allowed", true), "Bloqueado quando cooldown > 0")
	assert_true(res.get("reason", "").contains("recarga"), "Mensagem de recarga retornada")


func _teste_10_serializacao_save_load() -> void:
	print("\n--- Teste 10: Serialização Save/Load de HatsuData com Novos Canais ---")
	var h_original = HatsuManager.obter_hatsu_canonico("killua_kanmuru")
	assert_true(h_original != null, "Hatsu original instanciado")

	var dict = h_original.to_dict()
	assert_true(dict.has("activation_type"), "to_dict possui campo activation_type")
	assert_true(dict.has("channel"), "to_dict possui campo channel")
	assert_true(dict.has("exclusive_group"), "to_dict possui campo exclusive_group")
	assert_true(dict.has("aura_drain_per_sec"), "to_dict possui campo aura_drain_per_sec")

	var h_restaurado = HatsuData.from_dict(dict)
	assert_eq(h_restaurado.nome, h_original.nome, "Nome preservado")
	assert_eq(h_restaurado.activation_type, h_original.activation_type, "ActivationType preservado")
	assert_eq(h_restaurado.channel, h_original.channel, "Channel preservado")
	assert_eq(h_restaurado.exclusive_group, h_original.exclusive_group, "ExclusiveGroup preservado")
	assert_eq(h_restaurado.aura_drain_per_sec, h_original.aura_drain_per_sec, "AuraDrainPerSec preservado")
