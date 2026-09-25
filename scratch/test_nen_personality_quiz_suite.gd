extends Node

# ============================================================
# Suite: questionário de personalidade → seed → revelação Wing
# godot --headless --path . res://scratch/test_nen_personality_quiz_suite.tscn
# ============================================================

const QuizScript = preload("res://resource/nen/NenPersonalityQuiz.gd")

var _pass := 0
var _fail := 0


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("=== test_nen_personality_quiz_suite ===")
	_test_perguntas_e_scores()
	_test_seed_deterministico()
	_test_specialist_rate_aprox()
	await _test_quiz_ui_flow()
	_test_playerdata_reveal_secrecy()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_perguntas_e_scores() -> void:
	print("-- perguntas Hisoka --")
	var qs = QuizScript.obter_perguntas()
	assert_test(qs.size() == 5, "5 perguntas")
	var scores = QuizScript.empty_scores()
	# Todas respostas “Intensificação” (índice 0)
	for q in qs:
		var opts: Array = q["options"]
		assert_test(opts.size() == 5, "cada pergunta tem 5 opções (%s)" % q["id"])
		QuizScript.aplicar_pesos(scores, opts[0]["weights"])
	assert_test(int(scores["intensificacao"]) == 10, "score intensificação = 10")
	assert_test(QuizScript.obter_candidata(scores) == NenAffinityData.CategoriaAfinidade.INTENSIFICACAO, "candidata = Intensificação")
	assert_test("determinado" in QuizScript.traco_hisoka(NenAffinityData.CategoriaAfinidade.INTENSIFICACAO), "traço Hisoka intensificador")


func _test_seed_deterministico() -> void:
	print("-- seed determinística --")
	var scores = QuizScript.empty_scores()
	scores["emissao"] = 8
	scores["conjuracao"] = 2
	var seed_a = QuizScript.gerar_seed("Killua", [2, 2, 2, 2, 2], 42)
	var seed_b = QuizScript.gerar_seed("Killua", [2, 2, 2, 2, 2], 42)
	assert_test(seed_a == seed_b, "mesma entrada → mesma seed")
	var r1 = QuizScript.resolver_afinidade(scores, seed_a)
	var r2 = QuizScript.resolver_afinidade(scores, seed_a)
	assert_test(r1 == r2, "mesma seed → mesma afinidade")
	assert_test(
		r1 == NenAffinityData.CategoriaAfinidade.EMISSAO \
		or r1 == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO,
		"resultado é candidata (Emissão) ou Specialist"
	)


func _test_specialist_rate_aprox() -> void:
	print("-- taxa Specialist ~10% --")
	var scores = QuizScript.empty_scores()
	scores["manipulacao"] = 10
	var specs := 0
	var total := 200
	for i in range(total):
		var seed_str = QuizScript.gerar_seed("Hunter%d" % i, [4, 4, 4, 4, 4], i * 17 + 3)
		var r = QuizScript.resolver_afinidade(scores, seed_str)
		if r == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
			specs += 1
	var rate := float(specs) / float(total)
	assert_test(rate >= 0.03 and rate <= 0.20, "taxa Specialist entre 3%% e 20%% (obtido %.1f%%)" % (rate * 100.0))


func _test_quiz_ui_flow() -> void:
	print("-- UI quiz --")
	var packed = load("res://ui/CharacterSelection/NenPersonalityQuizUI.tscn") as PackedScene
	assert_test(packed != null, "NenPersonalityQuizUI.tscn carrega")
	if packed == null:
		return
	var ui = packed.instantiate()
	add_child(ui)
	ui.configurar("Gon")
	await get_tree().process_frame
	assert_test(is_instance_valid(ui), "UI montada")
	assert_test(ui._perguntas.size() == 5, "UI tem 5 perguntas")
	assert_test(not ui._fase_final, "começa na fase de perguntas")
	assert_test(ui._opcoes_box.get_child_count() == 5, "5 botões de opção")

	var done := {"ok": false, "scores": {}, "seed": ""}
	ui.quiz_concluido.connect(func(sc, sd, _ans):
		done["ok"] = true
		done["scores"] = sc
		done["seed"] = sd
	)

	# Responde Intensificação em todas
	for _i in range(5):
		ui._responder(0)
		await get_tree().process_frame

	assert_test(ui._fase_final, "após 5 respostas entra no encerramento")
	assert_test(ui._btn_continuar.visible, "botão Continuar visível")
	ui._on_continuar()
	await get_tree().process_frame
	assert_test(done["ok"], "sinal quiz_concluido emitido")
	assert_test(int(done["scores"].get("intensificacao", 0)) == 10, "scores salvos corretos")
	assert_test(not str(done["seed"]).is_empty(), "seed gerada")


func _test_playerdata_reveal_secrecy() -> void:
	print("-- PlayerData seed → Wing --")
	PlayerData.nen_affinity_revealed = false
	PlayerData.nen_personality_scores = QuizScript.empty_scores()
	PlayerData.nen_personality_scores["transformacao"] = 10
	PlayerData.nen_personality_seed = QuizScript.gerar_seed("HisokaFan", [1, 1, 1, 1, 1], 99)
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.INTENSIFICACAO
	assert_test(PlayerData.obter_nome_afinidade_exibivel() == "Aura Oculta", "UI mostra Aura Oculta antes")
	# Stats sem bônus de afinidade
	var forca_antes = PlayerData.obter_stat_calculado("forca")
	PlayerData.nen_affinity_revealed = false
	var forca_oculta = PlayerData.obter_stat_calculado("forca")
	assert_test(is_equal_approx(forca_antes, forca_oculta) or forca_oculta > 0.0, "stat calculável com afinidade oculta")

	var revelada = PlayerData.revelar_afinidade_nen()
	assert_test(PlayerData.nen_affinity_revealed, "flag revelada")
	assert_test(
		revelada == NenAffinityData.CategoriaAfinidade.TRANSFORMACAO \
		or revelada == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO,
		"revelação = Transformação ou Specialist"
	)
	assert_test("Aura Oculta" not in PlayerData.obter_nome_afinidade_exibivel(), "nome público após revelar")
	var segunda = PlayerData.revelar_afinidade_nen()
	assert_test(segunda == revelada, "revelar de novo é idempotente")
