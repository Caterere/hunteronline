extends Node2D

# ============================================================
# HUNTER ONLINE — SMOKE: UI DO PERGAMINHO (JORNAL DE MISSÕES)
# ============================================================
# Valida (headless) que o pergaminho de missões (QuestJournalUI) abre e
# fecha pelos pontos de entrada reais do jogo:
#   - Botão 📜 do QuestHUD (_abrir_jornal).
#   - Item "Jornal de Missões" do menu de pausa (_on_jornal_pressed).
# Antes da correção, ambos buscavam "/root/QuestJournalUI" que nunca era
# instanciado; agora QuestJournalUI.obter_ou_criar() garante a instância.
# ============================================================

const QuestHUDScript = preload("res://ui/hud/QuestHUD.gd")
const PauseMenuScript = preload("res://ui/PauseMenu/PauseMenuUI.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0


func assert_test(cond: bool, msg: String) -> void:
	total_tests += 1
	if cond:
		passed_tests += 1
		print("  ✅ [PASS] %s" % msg)
	else:
		failed_tests += 1
		push_error("  ❌ [FAIL] %s" % msg)
		print("  ❌ [FAIL] %s" % msg)


func _ready() -> void:
	print("================================================================================")
	print("📜 SMOKE: UI DO PERGAMINHO (JORNAL DE MISSÕES)")
	print("================================================================================")

	await _cenario_a_ciclo_de_vida()
	await _cenario_b_botao_hud()
	await _cenario_c_menu_pausa()

	print("\n================================================================================")
	print("📊 RESULTADO PERGAMINHO UI: TOTAL %d | APROVADOS %d | FALHAS %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================================\n")
	get_tree().quit(0 if failed_tests == 0 else 1)


func _journal() -> Node:
	return get_tree().root.get_node_or_null("QuestJournalUI")


func _limpar_journal() -> void:
	var j = _journal()
	if j != null:
		get_tree().root.remove_child(j)
		j.queue_free()


# ------------------------------------------------------------
# CENÁRIO A — Ciclo de vida direto (obter_ou_criar / abrir / fechar)
# ------------------------------------------------------------
func _cenario_a_ciclo_de_vida() -> void:
	print("\n[A] Ciclo de vida do pergaminho (obter_ou_criar / abrir / fechar / alternar)")
	_limpar_journal()
	await get_tree().process_frame

	assert_test(_journal() == null, "Pré-condição: /root/QuestJournalUI ainda não existe")

	var j = QuestJournalUI.obter_ou_criar(get_tree())
	await get_tree().process_frame
	assert_test(j != null, "obter_ou_criar retornou uma instância")
	assert_test(_journal() == j, "Instância registrada em /root/QuestJournalUI")

	var j2 = QuestJournalUI.obter_ou_criar(get_tree())
	assert_test(j2 == j, "obter_ou_criar reaproveita a mesma instância (sem duplicar)")

	assert_test(j.btn_aba_canonica != null and j.btn_fechar != null, "UI construída (abas + botão fechar)")

	var fechado_emitido := [false]
	j.fechado.connect(func(): fechado_emitido[0] = true)

	j.abrir()
	await get_tree().process_frame
	assert_test(j.visible, "abrir() torna o pergaminho visível")

	j.fechar()
	await get_tree().process_frame
	assert_test(not j.visible, "fechar() oculta o pergaminho")
	assert_test(fechado_emitido[0], "fechar() emite o sinal 'fechado'")

	j.alternar_menu()
	assert_test(j.visible, "alternar_menu() abre quando fechado")
	j.alternar_menu()
	assert_test(not j.visible, "alternar_menu() fecha quando aberto")


# ------------------------------------------------------------
# CENÁRIO B — Botão 📜 do QuestHUD
# ------------------------------------------------------------
func _cenario_b_botao_hud() -> void:
	print("\n[B] Botão 📜 do QuestHUD abre o pergaminho")
	_limpar_journal()
	await get_tree().process_frame

	var hud = QuestHUDScript.new()
	hud.name = "QuestHUDSmoke"
	add_child(hud)
	await get_tree().process_frame

	assert_test(hud.has_method("_abrir_jornal"), "QuestHUD possui o handler _abrir_jornal")
	hud._abrir_jornal()
	await get_tree().process_frame
	var j = _journal()
	assert_test(j != null and j.visible, "📜 do HUD instanciou e abriu o pergaminho")

	hud._abrir_jornal()
	await get_tree().process_frame
	assert_test(j != null and not j.visible, "📜 do HUD alterna e fecha o pergaminho")

	if is_instance_valid(hud):
		remove_child(hud)
		hud.queue_free()
	await get_tree().process_frame


# ------------------------------------------------------------
# CENÁRIO C — Item "Jornal de Missões" do menu de pausa
# ------------------------------------------------------------
func _cenario_c_menu_pausa() -> void:
	print("\n[C] Menu de pausa abre o pergaminho")
	# Garante pergaminho oculto
	var j0 = _journal()
	if j0 != null and j0.visible:
		j0.fechar()
	await get_tree().process_frame

	var pause = PauseMenuScript.new()
	pause.name = "PauseMenuSmoke"
	add_child(pause)
	await get_tree().process_frame

	assert_test(pause.has_method("_on_jornal_pressed"), "PauseMenu possui o handler _on_jornal_pressed")
	pause._on_jornal_pressed()
	await get_tree().process_frame
	var j = _journal()
	assert_test(j != null and j.visible, "Menu de pausa instanciou e abriu o pergaminho")

	# Limpeza
	if is_instance_valid(pause):
		remove_child(pause)
		pause.queue_free()
	_limpar_journal()
	await get_tree().process_frame
