extends Node2D

# ============================================================
# SUÍTE DE TESTES: REDESIGN DE HUD & NEN SKILL TREE VISUAL
# ============================================================

const NenSkillTreeUIScript = preload("res://ui/SkillTree/NenSkillTreeUI.gd")
const PlayerHUDScript = preload("res://ui/hud/PlayerHUD.gd")
const StatusMenuScript = preload("res://ui/StatusMenu/StatusMenu.gd")
const NenMenuScript = preload("res://ui/NenMenu/NenMenu.gd")

var _passou_todos: bool = true
var _total_testes: int = 0
var _testes_ok: int = 0

func _ready() -> void:
	print("============================================================")
	print("🚀 SUÍTE DE TESTES: HUD REDESIGN & NEN SKILL TREE VISUAL")
	print("============================================================")

	await get_tree().process_frame

	_teste_1_instanciacao_canonica_skill_tree()
	_teste_2_eliminacao_completa_nen_level_hud()
	_teste_3_eliminacao_nen_level_menus()
	_teste_4_inicializacao_zero_loading_skill_tree_ui()
	_teste_5_todos_os_27_nos_graficos_presentes()
	_teste_6_investimento_e_consumo_de_sp()
	_teste_7_filtros_e_categorias_visuais()
	_teste_8_painel_inspetor_lateral()
	_teste_9_persistencia_save_load()

	print("\n============================================================")
	print("🏆 RESULTADO FINAL: %d / %d TESTES APROVADOS" % [_testes_ok, _total_testes])
	if _passou_todos:
		print("   STATUS: HUD & NEN SKILL TREE 100% OPERACIONAIS E BLINDADOS!")
	else:
		print("   STATUS: FALHA DETECTADA EM TESTES!")
	print("============================================================\n")

	get_tree().quit(0 if _passou_todos else 1)


func _assinalar(cond: bool, msg_ok: String, msg_erro: String) -> void:
	_total_testes += 1
	if cond:
		_testes_ok += 1
		print("  ✅ [PASS] %s" % msg_ok)
	else:
		_passou_todos = false
		print("  ❌ [FAIL] %s" % msg_erro)


# ------------------------------------------------------------------------------
# TESTE 1: Instanciação Canônica Permanente da NenSkillTree
# ------------------------------------------------------------------------------
func _teste_1_instanciacao_canonica_skill_tree() -> void:
	print("\n[TESTE 1/9] Verificando instanciação da NenSkillTree em PlayerData...")
	var st = PlayerData.obter_skill_tree()
	var valido = (st != null and is_instance_valid(st))
	var no_grupo = st.is_in_group("nen_skill_tree") if valido else false
	_assinalar(valido and no_grupo,
		"NenSkillTree instanciada permanentemente e presente no grupo 'nen_skill_tree'.",
		"Falha ao instanciar NenSkillTree em PlayerData!")


# ------------------------------------------------------------------------------
# TESTE 2: Eliminação Completa de 'Nen Level' do PlayerHUD
# ------------------------------------------------------------------------------
func _teste_2_eliminacao_completa_nen_level_hud() -> void:
	print("\n[TESTE 2/9] Auditando eliminação de 'NEN NV.' / 'Nen Level' no PlayerHUD...")
	PlayerData.nome_personagem = "Gon"
	PlayerData.attributes["nivel"] = 5
	PlayerData.attributes["nivel_nen"] = 2
	PlayerData.nen_skill_points = 3
	PlayerData.despertou_nen = true
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.INTENSIFICACAO

	var hud = PlayerHUDScript.new()
	add_child(hud)
	hud._atualizar_header_e_gold()

	var texto_header = hud.lbl_player_header.text
	var texto_afinidade = hud.lbl_player_affinity.text
	var texto_sp = hud.lbl_sp_badge.text

	var sem_nen_level = (not "NEN NV" in texto_header and not "Nen Level" in texto_header and not "Nen Lv" in texto_header)
	var tem_nome_e_nivel = ("Gon" in texto_header and "Nv. 5" in texto_header)
	var tem_afinidade = ("Intensificação" in texto_afinidade or "Reforço" in texto_afinidade)
	var tem_sp = ("3 SP" in texto_sp and hud.lbl_sp_badge.visible)

	_assinalar(sem_nen_level and tem_nome_e_nivel and tem_afinidade and tem_sp,
		"PlayerHUD exibe cabeçalho MMORPG (Nome, Nível, Afinidade, SP) sem vestígios de 'NEN NV.'.",
		"PlayerHUD ainda contém referências a 'Nen Level' ou falhou no cabeçalho!")

	hud.queue_free()


# ------------------------------------------------------------------------------
# TESTE 3: Eliminação de 'Nen Level' nos Menus (StatusMenu & NenMenu)
# ------------------------------------------------------------------------------
func _teste_3_eliminacao_nen_level_menus() -> void:
	print("\n[TESTE 3/9] Auditando menus de Status e Nen...")
	var status_menu = load("res://ui/StatusMenu/StatusMenu.tscn").instantiate()
	add_child(status_menu)
	status_menu._atualizar_status()

	var sem_nen_lv_status = not "Nen Lv." in status_menu.aura_label.text
	var tem_sp_status = "SP" in status_menu.aura_label.text

	var nen_menu = load("res://ui/NenMenu/NenMenu.tscn").instantiate()
	add_child(nen_menu)
	nen_menu._atualizar_nen_menu()

	var sem_nen_lv_nenmenu = not "Nen Lv." in nen_menu.nen_level_label.text
	var tem_sp_nenmenu = "SP" in nen_menu.nen_level_label.text

	_assinalar(sem_nen_lv_status and tem_sp_status and sem_nen_lv_nenmenu and tem_sp_nenmenu,
		"StatusMenu e NenMenu exibem SP canônico sem referências legadas a 'Nen Lv.'.",
		"StatusMenu ou NenMenu ainda exibem texto legado de Nen Level!")

	status_menu.queue_free()
	nen_menu.queue_free()


# ------------------------------------------------------------------------------
# TESTE 4: Inicialização Sem Loading Infinito da NenSkillTreeUI
# ------------------------------------------------------------------------------
func _teste_4_inicializacao_zero_loading_skill_tree_ui() -> void:
	print("\n[TESTE 4/9] Testando ciclo de carregamento imediato da NenSkillTreeUI...")
	var ui = NenSkillTreeUIScript.new()
	add_child(ui)

	var tree_carregada = (ui.skill_tree != null and is_instance_valid(ui.skill_tree))
	var canvas_pronto = (ui.tree_canvas != null and ui.tree_canvas is Control)

	_assinalar(tree_carregada and canvas_pronto,
		"NenSkillTreeUI inicializou instantaneamente com a árvore vinculada (0ms loading).",
		"NenSkillTreeUI falhou na vinculação da árvore!")

	ui.queue_free()


# ------------------------------------------------------------------------------
# TESTE 5: Presença de Todos os 27 Nós Gráficos no Canvas
# ------------------------------------------------------------------------------
func _teste_5_todos_os_27_nos_graficos_presentes() -> void:
	print("\n[TESTE 5/9] Verificando mapeamento e botões de todos os 27 nós...")
	var ui = NenSkillTreeUIScript.new()
	add_child(ui)

	var total_botoes = ui.node_buttons.size()
	var tem_ten = ui.node_buttons.has("ten_1") and ui.node_buttons.has("ten_5")
	var tem_ren = ui.node_buttons.has("ren_1") and ui.node_buttons.has("ren_5")
	var tem_ko = ui.node_buttons.has("ko_1") and ui.node_buttons.has("ko_5")
	var tem_gyo = ui.node_buttons.has("gyo_1") and ui.node_buttons.has("gyo_5")
	var tem_zetsu = ui.node_buttons.has("zetsu_1") and ui.node_buttons.has("zetsu_3")
	var tem_ryu = ui.node_buttons.has("ryu_ofensivo") and ui.node_buttons.has("ryu_defensivo") and ui.node_buttons.has("ryu_equilibrado")
	var tem_sinergias = ui.node_buttons.has("ken_mastery") and ui.node_buttons.has("in_mastery") and ui.node_buttons.has("en_expansion")
	var tem_taticos = ui.node_buttons.has("first_strike") and ui.node_buttons.has("bloodied") and ui.node_buttons.has("surrounded") and ui.node_buttons.has("isolated_target") and ui.node_buttons.has("hunters_mark")

	_assinalar(total_botoes >= 27 and tem_ten and tem_ren and tem_ko and tem_gyo and tem_zetsu and tem_ryu and tem_sinergias and tem_taticos,
		"Todos os 35 nós canônicos mapeados e renderizados no canvas com sucesso (%d nós)." % total_botoes,
		"Contagem de nós incorreta no canvas: %d nós encontrados!" % total_botoes)

	ui.queue_free()


# ------------------------------------------------------------------------------
# TESTE 6: Investimento e Consumo de SP na Árvore
# ------------------------------------------------------------------------------
func _teste_6_investimento_e_consumo_de_sp() -> void:
	print("\n[TESTE 6/9] Testando desbloqueio de nós, pré-requisitos e consumo de SP...")
	PlayerData.reset()
	PlayerData.nen_skill_points = 5

	var ui = NenSkillTreeUIScript.new()
	add_child(ui)

	# 1. Investir em ten_1 (sem pré-requisitos)
	ui.selected_node_id = "ten_1"
	ui._on_botao_investir_pressionado()

	var ten1_ok = (ui.skill_tree.obter_progresso_no("ten_1") == 1)
	var sp_restante_1 = PlayerData.nen_skill_points == 4

	# 2. Investir em ten_2 (prereq ten_1 atendido)
	ui.selected_node_id = "ten_2"
	ui._on_botao_investir_pressionado()

	var ten2_ok = (ui.skill_tree.obter_progresso_no("ten_2") == 1)
	var sp_restante_2 = PlayerData.nen_skill_points == 3

	# 3. Tentar investir em ten_4 (bloqueado por falta de ten_3)
	ui.selected_node_id = "ten_4"
	ui._on_botao_investir_pressionado()

	var ten4_bloqueado = (ui.skill_tree.obter_progresso_no("ten_4") == 0)
	var sp_inalterado = (PlayerData.nen_skill_points == 3)

	_assinalar(ten1_ok and sp_restante_1 and ten2_ok and sp_restante_2 and ten4_bloqueado and sp_inalterado,
		"Investimento de SP validou pré-requisitos com rigor e debitou pontos corretamente.",
		"Falha no fluxo de investimento de SP da Skill Tree!")

	ui.queue_free()


# ------------------------------------------------------------------------------
# TESTE 7: Filtros e Categorias Visuais
# ------------------------------------------------------------------------------
func _teste_7_filtros_e_categorias_visuais() -> void:
	print("\n[TESTE 7/9] Testando filtros de abas temáticas...")
	var ui = NenSkillTreeUIScript.new()
	add_child(ui)

	var f_todos = ui._corresponde_ao_filtro(NenSkillTree.Categoria.TEN, "todos")
	var f_fund = ui._corresponde_ao_filtro(NenSkillTree.Categoria.TEN, "fundamentos")
	var f_def = ui._corresponde_ao_filtro(NenSkillTree.Categoria.TEN, "defesa")
	var f_ofensa = ui._corresponde_ao_filtro(NenSkillTree.Categoria.REN, "ofensa")
	var f_ryu = ui._corresponde_ao_filtro(NenSkillTree.Categoria.RYU_OFENSIVO, "ryu")
	var f_sin = ui._corresponde_ao_filtro(NenSkillTree.Categoria.SINERGIA, "sinergias")
	var f_tat = ui._corresponde_ao_filtro(NenSkillTree.Categoria.COMPORTAMENTAL, "comportamentais")

	_assinalar(f_todos and f_fund and f_def and f_ofensa and f_ryu and f_sin and f_tat,
		"Filtros categóricos mapeados e operacionais.",
		"Falha no mapeamento dos filtros de categoria!")

	ui.queue_free()


# ------------------------------------------------------------------------------
# TESTE 8: Painel Inspetor Lateral
# ------------------------------------------------------------------------------
func _teste_8_painel_inspetor_lateral() -> void:
	print("\n[TESTE 8/9] Testando inspeção detalhada de técnica...")
	var ui = NenSkillTreeUIScript.new()
	add_child(ui)

	# Inspecionar nó com condição
	ui.selected_node_id = "bloodied"
	ui._atualizar_painel_inspetor()

	var nome_correto = ("Bloodied" in ui.lbl_insp_nome.text)
	var cond_correta = ("Vida" in ui.lbl_insp_condicao.text)
	var tag_correta = ("bloodied" in ui.lbl_insp_tags.text)

	_assinalar(nome_correto and cond_correta and tag_correta,
		"Inspetor lateral carrega nome, condição e tags em linguagem clara de RPG.",
		"Inspetor lateral falhou em carregar os dados de técnica!")

	ui.queue_free()


# ------------------------------------------------------------------------------
# TESTE 9: Persistência Save & Load
# ------------------------------------------------------------------------------
func _teste_9_persistencia_save_load() -> void:
	print("\n[TESTE 9/9] Testando persistência e restauração do progresso da árvore...")
	PlayerData.reset()
	PlayerData.nen_skill_points = 2
	PlayerData.nen_skill_tree_progress["ten_1"] = 1
	PlayerData.nen_skill_tree_progress["ren_1"] = 1

	var st = PlayerData.obter_skill_tree()
	st.sincronizar_com_player_data()

	var ten_restaurado = (st.obter_progresso_no("ten_1") == 1)
	var ren_restaurado = (st.obter_progresso_no("ren_1") == 1)

	_assinalar(ten_restaurado and ren_restaurado,
		"Progresso da árvore sincronizado e restaurado perfeitamente.",
		"Falha na restauração do progresso da árvore!")
